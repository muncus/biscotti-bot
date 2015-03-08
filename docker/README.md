## Setting up Docker images to run the bot

To use the `redis-brain` hubot plugin, you'll need to run a redis instance. with docker, this is pretty easy:

      docker run -d -t -P --name botbrain redis

Build the hubot docker container:

      docker build -t $USER/hubot .

The `-P` should only be needed until i get a newer version of the docker tools, where container linking updates `/etc/hosts`. In the meantime, the bot container needs to get some info about the other container...

      export REDISHOST=`docker inspect -f '{{ .NetworkSettings.IPAddress }}' botbrain`
      docker run -d -t --link botbrain:redis -e HUBOT_SLACK_TOKEN=YOURMAGICTOKENHERE -e REDIS_URL=redis://${REDISHOST}/wiggles -p 127.0.0.1:9980:9980 --name hubot $USER/hubot
