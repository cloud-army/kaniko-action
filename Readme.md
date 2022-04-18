context *1	Path to the build context. Default to the workspace	-
file *1	Path to the Dockerfile. Default to Dockerfile. It must be in the context. If set, this action passes the relative path to Kaniko, same as the behavior of docker build	--dockerfile
build-args *1	List of build args	--build-arg
labels *1	List of metadata for an image	--label
push *1	Push an image to the registry. Default to true	--no-push
tags *1	List of tags	--destination
target *1	Target stage to build	--target
cache	Enable caching layers	--cache
cache-repository	Repository for storing cached layers	--cache-repo
cache-ttl	Cache timeout	--cache-ttl
push-retry	Number of retries for the push of an image	--push-retry
registry-mirror	Use registry mirror(s)	--registry-mirror
verbosity	Set the logging level	--verbosity