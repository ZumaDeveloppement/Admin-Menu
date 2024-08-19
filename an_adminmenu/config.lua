----- Bought from https://a-n.tebex.io/
----- For Support, Join my Discord: https://discord.gg/f2Nbv9Ebf5
----- For custom services or help, check my Fiverr: https://www.fiverr.com/aymannajim



Config = {}

---------------------------------------
------------- BASE CONFIG -------------
---------------------------------------

Config.Framework = 'QBCORE' -- 'QBCORE' or 'ESX'

Config.esxLegacy = true -- If you're using ESX Legacy, enable this or disable this if you're on ESX 1.2

Config.useMythic = false -- mythic_notify

Config.useESXnotif = false -- use built-in ESX notifications -- only works with ESX !!

Config.useQBnotif = true -- use built-in QBCore notifications -- only works with QBCore !!

Config.useCustomNotif = false -- use custom notification -- Edit "function CustomNotif(text,type)" below

Config.usevSync = true -- vSync ( https://github.com/DevTestingPizza/vSync/releases ) -- lets you change weather and time | Only for ESX | QBCore is using qb-weathersync

Config.commandName = 'adminmenu' -- Command to open admin menu - can be whatever you want

Config.maxMenuITems = 20 -- Max Items and Options showed in the menu | Once there is more than this number of items, you will need to scroll down for the rest.

Config.QBAccounts = { -- Accounts used on QBCore, this is in default but it's added here in case you've changed them [ you can find them on qbcore/config.lua ]
	{name = "cash", label = "Cash"},
	{name = "bank", label = "Bank Money"},
	{name = "crypto", label = "Crypto"},
}

Config.ESXAccounts = { -- Accounts used if you're using ESX, this is in default but it's added here in case you've changed them [ you can find them on es_extended/config.lua ]
	{name = "money", label = "Cash"},
	{name = "bank", label = "Bank Money"},
	{name = "black_money", label = "Black Money"},
}

---------------------------------------
---------- PERMISSIONS CONFIG ---------
---------------------------------------

---- Permission groups that should have access to the admin menu ----
Config.allowedGroups = { 'dev', 'god', 'admin' }
---- Permission groups that should be able to change user groups ----
Config.godGroups = { 'dev', 'god' }
---- List of permission groups that you have in your server ----
Config.Groups = {
	['god'] = { label = "God" },
	['dev'] = { label = "Developer" },
	['admin'] = { label = "Admin" },
	['sradmin'] = { label = "Senior Admin" },
	['jradmin'] = { label = "Junior Admin" },
	['moderator'] = { label = "Moderator" },
	['jrmoderator'] = { label = "Junior Moderator" },
	['user'] = { label = "User" },
	-- Template:
	-- ['group_name'] = { label = "group_label" }, -- replace group_name with the group name and group_label with the label that you want to show in the menu
}
-- 'moderator', 'jradmin', 'jrmoderator', 'sradmin' and 'dev' are my own created groups
-- so you need to edit this list to match with the groups that you have on your server
-- it is by default: 'user' and 'admin' for ESX 1.2+ | 'user' and 'superadmin' for ESX 1.1- | 'god', 'admin' and 'user' for QBCore

---------------------------------------
----------- FEATURES CONFIG -----------
---------------------------------------

Config.bringAllPlayers = true -- Enables two buttons in the Server Management that lets you teleport all players to you and bring them back where they were.

Config.accManage = true -- Enables managing players' accounts ( remove cash / give bank money ...etc )

Config.tuneCar = true -- Enables the Tune Vehicle Button in the Self Options Menu ---> TuneCarMenu()

Config.giveFaceMenu = true -- Enables the Give Face Menu Button in the Player Options Menu ---> GiveFaceMenu()

Config.giveClothingMenu = true -- Enables the Give Clothing Menu Button in the Player Options Menu ---> GiveClothingMenu()

Config.respawnPlayer = true -- Enables the Respawn Button in the Player Options Menu ---> spawnSelector()

Config.openPlayerInventory = true -- Enables the Open Inventory Button in the Player Options Menu ---> OpenPlayerInv(id)

Config.useNoClipShortcutKey = true -- Makes it easier for admins to Enable/Disable NoClip mode with a key ( See: Config.NoClipKey )

Config.logNoClipActions = true -- Disable this if you don't like the script to log every time an admin uses NoClip

Config.showPlayerVehicles = true -- Allows you to see players' vehicles on the map when the Show Player Blips option is enabled

Config.ClearAreaFromVehsRadius = 30 -- Radius size for the Clear Area from Vehicles

Config.ClearAreaFromPedsRadius = 30 -- Radius size for the Clear Area from Peds

Config.distanceForNames = 20 -- Distance for showing player names above their heads

---------------------------------------
------------- KEYS CONFIG -------------
---------------------------------------

--- Here you can find a list of all supported keys: https://docs.fivem.net/docs/game-references/controls/

Config.KeyOpenMenu = 121 -- Key to open Admin Menu | 121 = INSERT KEY

Config.NoClipKey = 243 -- Shortcut Key to Activate/Deactivate NoClip | 243 = ` or ~ key

Config.QuitSpectateKey = 55 -- Shortcut Key to quit spectating a player | 55 = 'SPACEBAR'

Config.QuitSpectateKeyLabel = "SPACEBAR" -- Name shown for the Shortcut key above

---------------------------------------
---- Customizable Client Functions ----
---------------------------------------

--[[

					 //!\\ ATTENTION PLEASE //!\\
		We can provide further help regarding the implementation
		of your own scripts in this admin menu if you join
		our Discord Server and claim your roles: https://discord.gg/f2Nbv9Ebf5
		and then type your request in the #an_adminmenu channel

]]--

function GiveFaceMenu()
	---- Here add your own event/export/code that triggers the face Menu for Players
	-- Default for QBCore:
	if Config.Framework == 'QBCORE' then
		TriggerEvent('qb-clothing:client:openMenu')
	end
end

function GiveClothingMenu()
	---- Here add your own event/export/code that triggers the clothing Menu for Players
	-- Default for QBCore:
	if Config.Framework == 'QBCORE' then
		TriggerEvent('qb-clothing:client:openMenu')
	end
end

function TuneCarMenu()
	---- Here add your own event/export/code that triggers the tuning Menu for your car
	-- Default for QBCore:
	if Config.Framework == 'QBCORE' then
		TriggerEvent('event:control:bennys', 1)
	end
end

function spawnSelector()
	---- Here add your own event/export/code that triggers the Menu for selecting a spawn point
	---- Example for this script ( https://forum.cfx.re/t/esx-resource-spawn-selector/1879873 )
	---- TriggerEvent('finesserp-selector:setNui')
	-- Default for QBCore:
	if Config.Framework == 'QBCORE' then
		TriggerEvent('qb-spawn:client:openUI')
	end
end

function OpenPlayerInv(playerID)
	---- Here add your own event/export/code that triggers opening a player inventory
	---- Example for people using esx_inventoryhud ( https://github.com/Trsak/esx_inventoryhud )
	-- TriggerEvent('esx_inventoryhud:openPlayerInventory', playerID, 'Player ID: '..playerID)
	-- Default for QBCore:
	if Config.Framework == 'QBCORE' then
		TriggerEvent('qb-admin:client:inventory', playerID)
	end
end

function CustomNotif(text,type)
	if type == "error" then
		-- insert your own notification system
	elseif type == "success" then
		-- insert your own notification system
	elseif type == "inform" then
		-- insert your own notification system
	end
end

function GiveKeysForThisCar(plate)
	---- Here add your own event/export/code that gives the keys of a car to the player
	-- if you're using QBCore default key system, don't worry about this one you can leave it empty
end



----- Bought from https://a-n.tebex.io/
----- For Support, Join my Discord: https://discord.gg/f2Nbv9Ebf5
----- For custom services or help, check my Fiverr: https://www.fiverr.com/aymannajim