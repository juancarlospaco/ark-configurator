# Ark-Configurator

- Advanced Configuration for Ark Survival Evolved Dedicated Servers.
- Based on tiny and simple flat plain-text files of `key = value`.
- Makes your Configuration compatible with Git.


# FAQ

- Why not Mobile App?.

Ark has so many configurations that you will be a year just scrolling thru the configurations on a tiny screen.

- Why not Web App?.

Web App looks cool, but you can not use Git to track changes on your configurations.

With this you can upload your configurations to GitHub or GitLab,
use Git branches to maintain parallel configurations updated,
quickly switch configurations using a different branch,
event-only configurations like Xmas special configurations,
or weekends-only configurations.

Use your favorite text editor or programming IDE to update the configurations.
Atom, VS Code, Notepad++ is still better than an HTML `<textarea>`.

Besides if you play Ark you already have a PC ;P

- I dont know how to use Git?.

Use a Pastebin or GitHub Gist.

- How to install?.

Dont need install. just run it.

- How to uninstall?.

Dont need uninstall. just delete it.

- How to download?.

https://github.com/juancarlospaco/ark-configurator/releases

- How to configure `GameUserSettings.ini`?.

https://ini.arkforum.de/index.php?lang=en&mode=all

- Can I trust your App?.

Read the code, scan it with all the Anti-Virus, run it on VirtualBox, or even compile it yourself.

- This generates a `Game.ini` from `*.ini` files, is not that stupid?.

Resulting `Game.ini` is more than 2000 lines, with very long lines, weird syntax, a lot of repetition, super verbose.

The `*.ini` files that this app uses are tiny and simple, few lines, very short lines, `key = value` syntax, no repetition, no verbose.

You can say its like `Game.ini` "Pre-Processor" :)


#### Tips

<details>

Set `MaxSpectators` to the same number of **active Admins** on your server, for security,
lets say you have 1 Admin, but more than 1 Spectator, then that means that someone hacked your server password.

Some configuration can be repeated on `Game.ini` & `GameUserSettings.ini`

On start Ark reads `Game.ini` first, then reads `GameUserSettings.ini`

Repeated configurations on `Game.ini` can be overwritten by `GameUserSettings.ini`

Not all configurations can be set on `GameUserSettings.ini`, for example core game configurations.

Not all configurations can be set on `Game.ini`, for example Mods.

This simple script reads all the `config/*.ini` and `config/*.json` files and generates 1 `*.ini` config file for all the ARK Survival Evolved settings.

To reduce lag, disable Brontos, replace them with other tameable dino.

To reduce lag, disable Volcano on Ragnarok.

To reduce lag, make your players spawn with 250~500 Kg weight, and disable adding more weight, if the player holds too much inventory the server lags, but if you set too low weight everyone complains.

To reduce lag, make your players spawn with very high Water stat, its annoying to drink water all the time and people make pipes everywhere.

To reduce lag, disable all Thatch structures, they sux anyways.

Any mod that makes the birds go faster makes lag (Classic Flyer, Speed Saddle, Speed Soup, etc), instead make land dinos and water dinos faster to reduce lag and allows to travel faster.

Make Herbivores stronger and cheap Veggy Cakes so people tame more varied dinos, else everyone only tame Rexes and Gigas.

Dont use a high Harvest multiplier it makes lag, instead make stuff cheaper by reducing the crafting costs.

Make possible to use stuff from other maps without mods by adding those items to the supply crates.

Make possible to use dinos from other maps without mods by replacing useless dinos with the ones from other maps.

Dont use too high Speed multiplier on the player, makes lag and allows speed hacks.

Disable the Industrial Grinder it allows Dupes and hacks.

Prefer tiny mods to big heavy mods, multiple tiny mods are still better than one big heavy mod.

To reduce lag, periodically check for Meshing bases and wipe them.

To reduce lag, make corpses disappear faster.

To reduce lag, disable wooden raft.

</details>
