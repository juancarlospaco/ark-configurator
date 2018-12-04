import ospaths, os, strutils, parsecfg, streams, json, tables, times

const gameini_header = """
# $1

[/Script/Engine.GameSession]
MaxPlayers=250  # Server Slots, will be ignored if your Hosting overwrites it.
MaxSpectators=1 # If you have 1 Admin,but more than 1 Spectator,then someone hacked your server password.

[/script/shootergame.shootergamemode]
"""

const
  EngramEntryAutoUnlocks = "EngramEntryAutoUnlocks=(EngramClassName=\"$1\",LevelToAutoUnlock=$2)\n"
  OverrideNamedEngramEntries_true = "OverrideNamedEngramEntries=(EngramClassName=\"$1\",EngramHidden=False,RemoveEngramPreReq=True)\n"
  OverrideNamedEngramEntries_false = "OverrideNamedEngramEntries=(EngramClassName=\"$1\",EngramHidden=True,RemoveEngramPreReq=False,EngramLevelRequirement=999)\n"
  NPCReplacements = "NPCReplacements=(FromClassName=\"$1\",ToClassName=\"$2\")  # $1 --> $2\n"
  TamedDinoClassResistanceMultipliers = "TamedDinoClassResistanceMultipliers=(ClassName=\"$1\",Multiplier=$2)\n"
  TamedDinoClassDamageMultipliers = "TamedDinoClassDamageMultipliers=(ClassName=\"$1\",Multiplier=$2)\n"
  DinoClassResistanceMultipliers = TamedDinoClassResistanceMultipliers.replace("Tamed", "")
  DinoClassDamageMultipliers = TamedDinoClassDamageMultipliers.replace("Tamed", "")
  ConfigOverrideItemCraftingCosts = "ConfigOverrideItemCraftingCosts=(ItemClassString=\"$1\",BaseCraftingResourceRequirements=($2))\n"
  ResourceItemTypeString = "(ResourceItemTypeString=\"$1\",BaseResourceRequirement=$2.0)"
  LootItem = "(EntryWeight=1.0,ItemClassStrings=(\"$1\"),$2,bForceBlueprint=false)"
  ConfigOverrideSupplyCrateItems = "ConfigOverrideSupplyCrateItems=(SupplyCrateClassString=\"$1\",MinItemSets=1,MaxItemSets=2,NumItemSetsPower=1.0,bSetsRandomWithoutReplacement=true,ItemSets=($2))\n"
  innerItemSet = "(MinNumItems=5,MaxNumItems=15,NumItemsPower=1.0,SetWeight=1.0,bItemsRandomWithoutReplacement=true,ItemEntries=($1))"
  PlayerStat = {
    "health":      "PlayerBaseStatMultipliers[0]",
    "stamina":     "PlayerBaseStatMultipliers[1]",
    "torpor":      "PlayerBaseStatMultipliers[2]",
    "oxygen":      "PlayerBaseStatMultipliers[3]",
    "food":        "PlayerBaseStatMultipliers[4]",
    "water":       "PlayerBaseStatMultipliers[5]",
    "temperature": "PlayerBaseStatMultipliers[6]",
    "weight":      "PlayerBaseStatMultipliers[7]",
    "melee":       "PlayerBaseStatMultipliers[8]",
    "speed":       "PlayerBaseStatMultipliers[9]",
    "fortitude":   "PlayerBaseStatMultipliers[10]",
    "crafting":    "PlayerBaseStatMultipliers[11]",
  }.toTable
  PerLvlPlayerStat = {
    "health":      "PerLevelStatsMultiplier_Player[0]",
    "stamina":     "PerLevelStatsMultiplier_Player[1]",
    "torpor":      "PerLevelStatsMultiplier_Player[2]",
    "oxygen":      "PerLevelStatsMultiplier_Player[3]",
    "food":        "PerLevelStatsMultiplier_Player[4]",
    "water":       "PerLevelStatsMultiplier_Player[5]",
    "temperature": "PerLevelStatsMultiplier_Player[6]",
    "weight":      "PerLevelStatsMultiplier_Player[7]",
    "melee":       "PerLevelStatsMultiplier_Player[8]",
    "speed":       "PerLevelStatsMultiplier_Player[9]",
    "fortitude":   "PerLevelStatsMultiplier_Player[10]",
    "crafting":    "PerLevelStatsMultiplier_Player[11]",
    }.toTable
  PerLvlDinoStat = {
    "health":      "PerLevelStatsMultiplier_DinoTamed[0]",
    "stamina":     "PerLevelStatsMultiplier_DinoTamed[1]",
    "torpor":      "PerLevelStatsMultiplier_DinoTamed[2]",
    "oxygen":      "PerLevelStatsMultiplier_DinoTamed[3]",
    "food":        "PerLevelStatsMultiplier_DinoTamed[4]",
    "water":       "PerLevelStatsMultiplier_DinoTamed[5]",
    "temperature": "PerLevelStatsMultiplier_DinoTamed[6]",
    "weight":      "PerLevelStatsMultiplier_DinoTamed[7]",
    "melee":       "PerLevelStatsMultiplier_DinoTamed[8]",
    "speed":       "PerLevelStatsMultiplier_DinoTamed[9]",
    "fortitude":   "PerLevelStatsMultiplier_DinoTamed[10]",
    "crafting":    "PerLevelStatsMultiplier_DinoTamed[11]",
    }.toTable
  config_files = {
    "ConfigOverrideItemCraftingCosts.json":    staticRead("config/ConfigOverrideItemCraftingCosts.json"),
    "DinoClassResistanceMultipliers.ini":      staticRead("config/DinoClassResistanceMultipliers.ini"),
    "OverrideNamedEngramEntries.ini":          staticRead("config/OverrideNamedEngramEntries.ini"),
    "PlayerBaseStatMultipliers.ini":           staticRead("config/PlayerBaseStatMultipliers.ini"),
    "base.ini":                                staticRead("config/base.ini"),
    "ConfigOverrideSupplyCrateItems.json":     staticRead("config/ConfigOverrideSupplyCrateItems.json"),
    "EngramEntryAutoUnlocks.ini":              staticRead("config/EngramEntryAutoUnlocks.ini"),
    "PerLevelStatsMultiplier_DinoTamed.ini":   staticRead("config/PerLevelStatsMultiplier_DinoTamed.ini"),
    "TamedDinoClassDamageMultipliers.ini":     staticRead("config/TamedDinoClassDamageMultipliers.ini"),
    "DinoClassDamageMultipliers.ini":          staticRead("config/DinoClassDamageMultipliers.ini"),
    "NPCReplacements.ini":                     staticRead("config/NPCReplacements.ini"),
    "PerLevelStatsMultiplier_Player.ini":      staticRead("config/PerLevelStatsMultiplier_Player.ini"),
    "TamedDinoClassResistanceMultipliers.ini": staticRead("config/TamedDinoClassResistanceMultipliers.ini"),
  }.toTable

let
  gameini_folder = getCurrentDir() / "config"
  gameini_output = getCurrentDir() / "game.ini"

proc existsOrCreateDefaultDir(path=gameini_folder) =
  echo "Checking config folder: " & $existsOrCreateDir(gameini_folder)
  var temp: string
  for file in config_files.pairs:
    temp = gameini_folder / file[0]
    if temp.existsFile:
      echo "Config file found: " & temp
    else:
      writeFile(gameini_folder / file[0], file[1])

proc parsero(filename: string): JsonNode =
  doAssert filename.existsFile, "INI Configuration file can not be read: " & filename
  var stream = newFileStream(filename, fmRead)
  if stream != nil:
    var parser: CfgParser
    var config = %*{}
    open(parser, stream, filename)
    while true:
      var e = next(parser)
      case e.kind
      of cfgKeyValuePair:
        config.add($e.key, %e.value)
      of cfgOption, cfgSectionStart: discard
      of cfgError: echo(e.msg)
      of cfgEof: break
    close(parser)
    doAssert config.len > 0, "INI Configuration file must not be empty: " & $config
    return config

proc main(): string =
  existsOrCreateDefaultDir()
  var gameini = gameini_header.format(now())
  for it in walkDirRec(gameini_folder):
    if it.endsWith(".ini"):
      let config = parsero(it)
      if it.toLowerAscii.endsWith("base.ini"):
        for it in config.pairs:
          if $it.key.toLowerAscii == "max_player_level":
            # Adds 99 Engram points per each player lvl, enought to craft everything.
            for indx in 1..replace($it.val, "\"", "").parseInt:
              gameini.add "OverridePlayerLevelEngramPoints=99  # Player Level $1\n".format(indx)
          else:
            gameini.add $it.key & "=" & replace($it.val, "\"", "") & "\n"
      elif it.toLowerAscii.endsWith("engramentryautounlocks.ini"):
        for it in config.pairs:
          gameini.add EngramEntryAutoUnlocks.format(it.key, replace($it.val, "\"", ""))
      elif it.toLowerAscii.endsWith("overridenamedengramentries.ini"):
        for it in config.pairs:
          if replace($it.val, "\"", "").parseBool:
            gameini.add OverrideNamedEngramEntries_true.format(it.key)
          else:
            gameini.add OverrideNamedEngramEntries_false.format(it.key)
      elif it.toLowerAscii.endsWith("npcreplacements.ini"):
        for it in config.pairs:
          gameini.add NPCReplacements.format(it.key, replace($it.val, "\"", ""))
      elif it.toLowerAscii.endsWith("tameddinoclassresistancemultipliers.ini"):
        for it in config.pairs:
          gameini.add TamedDinoClassResistanceMultipliers.format(it.key, replace($it.val, "\"", ""))
      elif it.toLowerAscii.endsWith("tameddinoclassdamagemultipliers.ini"):
        for it in config.pairs:
          gameini.add TamedDinoClassDamageMultipliers.format(it.key, replace($it.val, "\"", ""))
      elif it.toLowerAscii.endsWith("dinoclassresistancemultipliers.ini"):
        for it in config.pairs:
          gameini.add DinoClassResistanceMultipliers.format(it.key, replace($it.val, "\"", ""))
      elif it.toLowerAscii.endsWith("dinoclassdamagemultipliers.ini"):
        for it in config.pairs:
          gameini.add DinoClassDamageMultipliers.format(it.key, replace($it.val, "\"", ""))
      elif it.toLowerAscii.endsWith("playerbasestatmultipliers.ini"):
        for it in config.pairs:
          gameini.add PlayerStat[it.key.toLowerAscii] & "=" & replace($it.val, "\"", "") & "  # " & it.key & "\n"
      elif it.toLowerAscii.endsWith("perlevelstatsmultiplier_player.ini"):
        for it in config.pairs:
          gameini.add PerLvlPlayerStat[it.key.toLowerAscii] & "=" & replace($it.val, "\"", "") & "  # " & it.key & "\n"
      elif it.toLowerAscii.endsWith("perlevelstatsmultiplier_dinotamed.ini"):
        for it in config.pairs:
          gameini.add PerLvlDinoStat[it.key.toLowerAscii] & "=" & replace($it.val, "\"", "") & "  # " & it.key & "\n"
    elif it.endsWith(".json"):
      let config = parseFile(it)
      if it.toLowerAscii.endsWith("configoverrideitemcraftingcosts.json"):
        for it in config.pairs:
          var resources: seq[string] = @[]
          for resource in it.val.pairs:
            resources.add ResourceItemTypeString.format(resource.key, resource.val)
          gameini.add ConfigOverrideItemCraftingCosts.format(it.key, resources.join(","))
      # elif it.toLowerAscii.endsWith("configoverridesupplycrateitems.json"):
      #   for it in config.pairs:
      #     var all_itemssets: seq[string] = @[]
      #     for itemset in it.val:
      #       var all_items: seq[string] = @[]
      #       for items in itemset.pairs:
      #         var all_configs: seq[string] = @[]
      #         for configs in items.val.pairs:
      #           all_configs.add configs.key & "=" & $configs.val & ".0"
      #         all_items.add LootItem.format(items.key, all_configs.join(",")) & "\n"
      #       all_itemssets.add innerItemSet.format(all_items.join(","))
      #     gameini.add ConfigOverrideSupplyCrateItems.format(it.key, all_itemssets.join(","))
  writeFile(gameini_output, gameini)
  result = "\nCreated new Ark Survival Evolved Dedicated Server config: " & gameini_output


when is_main_module:
  echo main()
