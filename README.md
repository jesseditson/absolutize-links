# absolutize-links
A bash script to convert relative node_modules symlinks to absolute ones, so we can use with docker volumes.

This repo was created in tandem with this issue comment: https://github.com/npm/npm/issues/14325#issuecomment-285566020

**installation**

`npm install -g absolutize-links`

**purpose**

When you run `npm link`, what it's doing under the hood is creating a symlink from `.` to `/usr/local/lib/node_modules`.
On the other side, when you `npm link package-name`, it creates a link from `node_modules/package-name` to `/usr/local/lib/node_modules/package-name`.

If you were to run `docker run --rm -it your-image-name:latest ls -al node_modules | grep -e "->"`, you'll likely see something like this:
```
package-name -> ../../../../../../usr/local/lib/node_modules/package-name
```

It's very unlikely that there's anything at all in your docker container at that path, which is why npm is telling you that file doesn't exist - it's right, it doesn't!

**the problem**

Unfortunately AFAIK `npm` doesn't allow you to create non-relative symlinks with `npm link`, which is problematic in that the directory structure of your docker container is pretty much never going to be the same as the directory structure of your local laptop.

In addition, since nothing is copied from `/usr/local` to the image, even _if_ your directory structure were to match, the file still wouldn't exist.

**a complex workaround, aka how to use this lib**

Because `npm link` makes relative symlinks, and because docker doesn't allow using volumes outside of `$HOME` by default, I can't think of a solution that doesn't require modifying your local fs and docker settings.

However, here's one way:

1. Update Docker for Mac settings to include `/usr/local/lib/node_modules` in the shared folders so you can use it as a volume:

![image](https://cloud.githubusercontent.com/assets/370239/23780845/1d563e58-04fe-11e7-9edf-094c6fe36e1e.png)

2. Update any local symlinks to be absolute. Link them using `npm link package-name`, then run this script (`absolutize-links`)

3. Add a volume to your docker config:

To run a `docker` command, add a `-v /usr/local/lib/node_modules:/usr/local/lib/node_modules` - this will mount your local npm node_modules on your docker container, which will make them available. You'll unfortunately also need to add a `-v` flag referencing the local linked modules' folder.

If you're using `docker-compose`, you can add these entries as `volumes` keys in your `docker-compose.yml`, so they'll always be there when you restart your container.

There's quite a lot of nuance when it comes to setting up docker volumes, so I'll leave it at the above for now, but the idea here is that you'll need **both** `/usr/local/lib/node_modules` and `/path/to/the/linked/module` defined as volumes when you run your docker image.

**usage**

```
absolutize-links [node_modules_dir]
```

`node_modules_dir` defaults to `node_modules`, so if you're in the same directory as `package.json`, you should be fine running just `absolutize-links`.
