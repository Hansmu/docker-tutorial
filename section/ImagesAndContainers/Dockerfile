# Here we define the image we want to use as a base, what we are building on top of
# In this case we are using the node image from docker hub
# The image can exist on your local machine or on a remote repository
# When productionizing your application, you should use a specific version of the image
FROM node

# If the WORKDIR command is executed before the COPY command, then the COPY command will be executed within whatever directory is specified by the WORKDIR command
# If the WORKDIR command is executed after the COPY command, then the COPY command will be executed within the root directory
# The WORKDIR command is not required, but it is good practice to use it
# COPY . /app # This is how the COPY command would be executed if the WORKDIR command was not used
# However, as we we have defined the WORKDIR before the COPY command, then we can work with relative paths and those relative paths will be relative to the WORKDIR
# Which in this case is /app

# Here we define the working directory for the container
# This is the directory that will be used when running commands
WORKDIR /app

# Here we can define what files we want to copy from our local machine to the container
# In this case we are copying everything from the current directory to the container's app directory
# The first parameter refers to our local machine, the second parameter refers to the container
#COPY . ./
# While you can use relative paths, it might be more obvious to use absolute paths so that the reader wouldn't have to refer to the WORKDIR command to understand what is going on
COPY . /app

# Here we define the command that will be run when the container is started
# In this case we are running the npm install command
# Note that setting the working directory is important here, as the command will be run from the working directory
# By default, the working directory is the root directory, but as we copied everything to /app, then that means we have to perform our actions inside of /app
RUN npm install

# Here we define the port that we want to expose
# Remember, a Docker container is isolated from the host machine
# Thus, if we want to access the container from the host machine, we need to expose the port
# As our Node server is running on port 80, we need to expose port 80
# HOWEVER, THIS IS ONLY FOR DOCUMENTATION PURPOSES. IT DOES NOT ACTUALLY EXPOSE THE PORT
# IT'S A BEST PRACTICE TO INCLUDE THIS LINE SO THAT THE READER KNOWS WHAT PORT THE CONTAINER IS RUNNING ON
EXPOSE 80

# Remember, the above commands define the image, but they do not run the image
# These are the commands that are used to build the image, not run it.
# Thus, if we want to run a Node server here, we wouldn't use the `RUN` command.
# Instead, we would use the `CMD` command, which is defined below
# The CMD command has multiple syntactic forms that could be used.
# The preferred form is using the exec form, which is every parameter being a string in an array
# CMD ["executable","param1","param2"]
# The CMD command should always be the last command in the Dockerfile
CMD ["node", "server.js"]