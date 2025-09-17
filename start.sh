docker build . -t project611 --platform=linux/amd64

docker run --platform linux/amd64 \
  -e USERID=$(id -u) \
  -e GROUPID=$(id -g) \
  -v $(pwd):/home/rstudio/work \
  -v $HOME/.ssh:/home/rstudio/.ssh \
  -v $HOME/.gitconfig:/home/rstudio/.gitconfig \
  -p 8787:8787 -it project611
