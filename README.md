# Alpine Linux on WSL2

This repo contains a script to grab the latest version of Alpine Linux, install it in a WSL2 box, and update all the packages and stuff. There's also pre-built packages if you'd prefer that sorta thing.

> Note: yeah I know there are other repos out there with pre-build Alpine packages, and there's the Alpine distro available in the MS Store. But I don't trust anything, so I made this repo instead. You really shouldn't trust the pre-build packages in `releases`, but I wanted them there so _I_ can use them.

## License

The documentation, scripts, and instructions in this repository are licensed under the MIT License. The Alpine Linux root filesystem is provided as-is from the official Alpine Linux project.

For license information about Alpine Linux packages, see: https://alpinelinux.org/
For the source code of packages, use: `apk list -I` to see installed packages and their licenses.
