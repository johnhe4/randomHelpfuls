# Remotely debug a Linux console C++ app from Mac
The idea here is to debug a C++ Linux application from a different machine, in this case a Mac. Visual Studio Code (VSCode) is used to accomplish this.

## Why bother?
Server-side Linux applications often run from a command line. The servers running these are often headless, which means they don't have a monitor attached and probably don't have a graphical user interface (GUI) installed. Debugging on these machines can be tedious because without a monitor and GUI, you're probably  debugging from an SSH console. Emacs users are nodding their heads while the rest of us are shaking it.

Remote debugging is nice when you as a developer want to use a graphical IDE on your (local) machine while debuggig an application running on a headless server (remote) machine. You can benefit from this if any of the following are true:
- your code won't compile on your Mac because it targets Linux-specific features
- your code won't run on your Mac due to hardware requirements (who else misses NVidia support?)
- your code won't behave the same on your Mac as on Linux
- your code needs specific co-location or networking infrastructure (in a public or private cloud, for example)
  
Remote debugging doesn't require the Linux server to have a GUI, and this approach uses far less bandwidth than a screen-sharing approach.

## Why not remote debug with gdb or lldb?
Mac uses `mach-o` format for executables and `lldb` for debugging, while Linux (usually) uses `ELF` format for exectuables and `gdb` for debugging.
Both `lldb` and `gdb` support remote debugging and even claim some compatibility with each other; however, because of the different executable file formats, remote debugging using these tools isn't straightforward.

I spent a bit of time trying to compile 'gdb' on my Mac so that it understood `ELF`, but it wouldn't compile and the documentation was sparse. I tried every permutation of lldb/gdb and each one failed for one reason or another. Some posters boldly claimed this was a waste of time and it would be better to install a Linux VM and be done with it.

Installing a VM for this is a big and slow hammer IMO. Since `gdb` and/or `lldb` were not straightforward to get working, I pivoted and found VSCode has solved this problem beautifully.

## Prepare Linux
- Ensure you have SSH configured as a server
- Ensure you have a proper C/C++ development environment installed
- Ensure gdb is installed
- Clone your code repository. Remember where you put this code because we'll be navigating to it remotely

## Prepare Mac
- Ensure you can connect to your Linux server remotely via SSH.
I recommend you create/modify your `~/.ssh/config` file so VSCode can prepopulate your connections automatically
- From VSCode, install the `Remote Development`, `C/C++`,and `CMake Tools` packs from Microsoft

## Develop
The rest happens from VSCode

- Click the green icon at the bottom left of VSCode
- Select `Remote-SSH: Connect to Host...`
- Select the host from the prepopulated list. This will open a new VSCode window and begin the connection to your Linux server
- `Open folder...` to the folder _on the Linux server_ that contains the code you cloned earlier
- From VSCode, install the same packages _on the Linux server_ that you installed on your local machine. You should seen an "Install on server" option next to each extension

Continue developing, building, and debugging using VSCode, kowing that it's all happpening on your Linux server :)
