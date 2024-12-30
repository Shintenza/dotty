# Dotty
Dotty is a simple dotfiles manager written in Perl and configured in YAML. Keep your dotfiles in the centralized store and symlink them to allow synchronization with git and other
devices.

# Why?
The term "dotfiles" refers to files used for configuring Linux desktops. These files can include configurations for tiling window managers, shells, terminals, utilities, 
and more, as well as custom scripts or wallpapers. Many users store their dotfiles in remote Git repositories to share them with others or to easily retrieve them after 
reinstalling the system or purchasing a new device.

However, manually updating a configuration file, copying the changes to the Git repository, and pushing them every time you make a tweak can be tedious and error-prone. 
A better approach is to maintain a centralized location for all your dotfiles and link them to their respective destinations. This way, changes made in the central store 
are immediately reflected, and it's easier to track those changes using tools like Git. Dotty is a tool made to manage those links in a better, more portable way.

# Perl dependencies:
- [YAML:XS](https://metacpan.org/dist/YAML-LibYAML/view/lib/YAML/XS.pod) - simple and fast YAML parsing utility
- [File::Globstar](https://metacpan.org/dist/File-Globstar/view/lib/File/Globstar.pod) - utility for handling glob paths

# Store config file walkthrough

### Example configuration

- `~/.dotfiles/dotty.yaml`
```
---
links:
  # entry name
  .local/**:
    glob: true
  .config/dunst/dunstrc: null
  starship.toml:
    path: ~/.config/starship.toml
    force: true
  hypr:
    path: ~/.config/hypr

```
- `tree -a ~/.dotfiles`
```
├── .config
│   └── dunst
│       └── dunstrc
├── dotty.yaml
├── .dwm
│   └── autostart.sh
├── hypr
│   └── hyprland.conf
├── .local
│   └── bin
│       ├── wl-lock
│       ├── wl-passmenu
│       └── wl-sysmenu
└── starship.toml
```
### Exmplanation
| Option           | Description                                                                                                                                    |
|------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| `path`           |  specifies where an entry from the store should be placed, when path is not provided, placement from the store is reflected in the home folder |
| `glob`           |  enables glob matching e.g. you can use `*` to match all files in a directory, if glob enabled `path` is going to be ignored                   |
| `force`          |  if a file exists at a given location, `force` option would replace that file with a symlink to the file/directory from the store              |


