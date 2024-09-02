#BULDING...
FROM node:20-alpine as BUILDER-BACK

WORKDIR /api-app
COPY ./api /api-app/

RUN yarn install
RUN yarn build

FROM node:20-alpine as BUILDER-FRONT
WORKDIR /front-app
COPY ./front /front-app/

ARG NEXT_PUBLIC_API_KEY
ARG NEXT_PUBLIC_API_BASE_URL
ARG NEXT_PUBLIC_CAMPUS_API_BASE_URL
ARG NEXT_PUBLIC_TINYMCE_API_KEY

RUN yarn install
RUN NEXT_PUBLIC_API_KEY=$NEXT_PUBLIC_API_KEY  \
    NEXT_PUBLIC_API_BASE_URL=$NEXT_PUBLIC_API_BASE_URL  \
    NEXT_PUBLIC_CAMPUS_API_BASE_URL=$NEXT_PUBLIC_CAMPUS_API_BASE_URL \
    NEXT_PUBLIC_TINYMCE_API_KEY=$NEXT_PUBLIC_TINYMCE_API_KEY \
    yarn build

FROM node:20-alpine as PROD

WORKDIR /api
COPY --from=BUILDER-BACK /api-app/node_modules /api/node_modules
COPY --from=BUILDER-BACK /api-app/dist /api/dist
COPY --from=BUILDER-BACK /api-app/package.json /api/package.json

WORKDIR /front
COPY --from=BUILDER-FRONT /front-app/node_modules /front/node_modules
COPY --from=BUILDER-FRONT /front-app/.next /front/.next
COPY --from=BUILDER-FRONT /front-app/package.json /front/package.json

WORKDIR /api
ENTRYPOINT [ "/bin/sh -c", "yarn", "start:prod", "&" ]

WORKDIR /front
CMD [ "/bin/sh -c", "yarn", "start"]
