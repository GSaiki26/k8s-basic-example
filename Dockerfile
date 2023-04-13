# Basics.
FROM node:19.2-alpine
WORKDIR /app

# Update the container.
RUN apt-get update
RUN apt-get upgrade -y
RUN chown node app

# Install the packages.
COPY --chown=node package.json .
RUN yarn install

# Start the project.
COPY --chown=node src ./src
CMD yarn run start:prod