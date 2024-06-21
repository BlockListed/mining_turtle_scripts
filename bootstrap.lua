-- This downloads all this files from github to make sure you have the latest stuff
fs.delete("mine.lua")
fs.delete("ore_excavate.lua")

shell.run("wget", "https://github.com/BlockListed/mining_turtle_scripts/raw/main/mine.lua")
shell.run("wget", "https://github.com/BlockListed/mining_turtle_scripts/raw/main/ore_excavate.lua")

shell.run("mine")
