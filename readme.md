# ZIMBRA 9 WITH DOCKER
## BUILDING
build the dockerfile with
docker build --tag zimbra9docker .

## USING
You can run the image with the follow command

```docker run -it -h HOSTNAME zimbra9docker```

### POST RUNNING THE IMAGE
When you run the image, you need go to zimbra installer folder, with:
```
cd /root/zimbra-installer
```
So, to start the installer use the following command
```
./install.sh --platform-override.
```
