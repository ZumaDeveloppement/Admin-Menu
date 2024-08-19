----- Bought from https://a-n.tebex.io/
----- For Support, Join my Discord: https://discord.gg/f2Nbv9Ebf5
----- For custom services or help, check my Fiverr: https://www.fiverr.com/aymannajim

-- Loading Framework
ESX = nil
local QBCore
local usingESX = false

if Config.Framework == 'ESX' then
	if Config.esxLegacy then
		ESX = exports["es_extended"]:getSharedObject()
	else
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	end
	usingESX = true
elseif Config.Framework == 'QBCORE' then
	QBCore = exports['qb-core']:GetCoreObject()
	usingESX = false
end

-- Events Protector | Anti Lua Injection
local pass

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		pass = math.random(1111,9999)
		
		Citizen.Wait(1000)

		print([[^3
																											 
				 █████  ███    ██  ████
				██   ██ ████   ██
				███████ ██ ██  ██
				██   ██ ██  ██ ██
				██   ██ ██   ████^1
				A N  A D M I N  M E N U
				I N I T I A L I Z I N G
				.	.	.
				^4AN Admin Menu Started - Lezz Goo!!
				^5Thank you for buying this script!
				^6Visit: https://a-n.tebex.io/ for more!
				^7Join: https://discord.gg/f2Nbv9Ebf5 for Support!

		]])
	end
end)                                      


-- Variables
local savedCoords = {}
local players = {}

-- Callbacks & Commands
if usingESX then
	-- item callback
	ESX.RegisterServerCallback('an_adminmenu:getItems', function(source, cb)
		cb(ESX.Items)
	end)
	ESX.RegisterServerCallback('an_adminmenu:getAcc', function(source, cb, pid, acctype)
		local xTarget = ESX.GetPlayerFromId(pid)
		local amount = xTarget.getAccount(acctype).money or 0
		if xTarget ~= nil and amount ~= nil then 
			cb(amount)
		else
			cb("error")
		end
	end)
	-- getting players for player management
	ESX.RegisterServerCallback('an_adminmenu:getAllPlayers', function(source, cb)
		-- local players = ESX.GetPlayers()
		cb(players)
	end)
	-- menu open command
	RegisterCommand(Config.commandName, function(src,args,rawCmd)
		local xPlayer = ESX.GetPlayerFromId(src)
		if isAllowed(xPlayer) then
			TriggerClientEvent('an_adminmenu:openmenu', xPlayer.source, pass)
		else
			TriggerClientEvent('an_adminmenu:notify', xPlayer.source, 'You are not allowed to do that.', 'error')
		end
	end)
else
	for i=1, #Config.allowedGroups do 
        QBCore.Commands.Add(Config.commandName, 'AN Admin Menu (Admin Only)', {}, false, function(source)
            TriggerClientEvent('an_adminmenu:openmenu', source, pass)
        end, Config.allowedGroups[i])
    end
	QBCore.Functions.CreateCallback("an_adminmenu:getAcc", function(source, cb, pid, acctype)
		local Player = QBCore.Functions.GetPlayer(pid)
		local amount = Player.PlayerData.money[acctype] or 0
		if Player ~= nil and amount ~= nil then 
			cb(amount)
		else
			cb('error')
		end
	end)
	QBCore.Functions.CreateCallback("an_adminmenu:getAllPlayers", function(source, cb)
		cb(players)
	end)
end

-- Events
RegisterServerEvent('an_adminmenu:requestUpdatePerm')
AddEventHandler('an_adminmenu:requestUpdatePerm', function()
	local src = source
	local hasGodPerm = false
	local hasAccessPerm = false
	if usingESX then
		local xPlayer = ESX.GetPlayerFromId(src)
		local grp = xPlayer.getGroup()
		if contains(Config.allowedGroups, grp) then
			hasAccessPerm = true
		end
		if contains(Config.godGroups, grp) then
			hasGodPerm = true
		end
	else
		if isAllowed2(src) then
			hasAccessPerm = true
		end
		if isGodAllowed(src) then
			hasGodPerm = true
		end
	end
	local data = { hasAccessPerm, hasGodPerm }
	TriggerClientEvent('an_adminmenu:accessUpdated', src, data)
end)

-- getting players for blips
RegisterServerEvent('an_adminmenu:getPlayers', function()
	local src = source
	-- local players = {}
	-- if usingESX then
	-- 	for k, v in pairs(ESX.GetPlayers()) do
	-- 		local targetped = GetPlayerPed(v)
	-- 		players[#players+1] = {
	-- 			ID = v,
	-- 			coords = GetEntityCoords(targetped),
	-- 		}
	-- 	end
	-- else
	-- 	for k, v in pairs(QBCore.Functions.GetPlayers()) do
	-- 		local targetped = GetPlayerPed(v)
	-- 		local ped = QBCore.Functions.GetPlayer(v)
	-- 		players[#players+1] = {
	-- 			ID = v,
	-- 			coords = GetEntityCoords(targetped),
	-- 		}
	-- 	end
	-- end
	TriggerClientEvent("an_adminmenu:showBlips", src, players)
end)

RegisterServerEvent('an_adminmenu:giveItem')
AddEventHandler('an_adminmenu:giveItem', function(item, pw)
	local src = source
	if pass == pw then
		if usingESX then
			local xPlayer = ESX.GetPlayerFromId(src)
			xPlayer.addInventoryItem(item, 1)
			TriggerClientEvent('an_adminmenu:notify', xPlayer.source, 'You spawned a '..ESX.GetItemLabel(item), 'success')
			logDatShit('**`[spawn item]` '..GetPlayerName(src)..'** [ID:'..src..'] spawned a **'..ESX.GetItemLabel(item)..'** [`'..item..'`]', src) -- discord log
		else
			local Player = QBCore.Functions.GetPlayer(src)
			if Player.Functions.AddItem(item, 1) then
				TriggerClientEvent('an_adminmenu:notify', src, 'You spawned a '..QBCore.Shared.Items[item].label, 'success')
				TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add")
				logDatShit('**`[spawn item]` '..GetPlayerName(src)..'** [ID:'..src..'] spawned a **'..QBCore.Shared.Items[item].label..'** [`'..item..'`]', src) -- discord log
			else
				TriggerClientEvent('an_adminmenu:notify', src, 'Action Impossible', 'error')
			end
		end
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent('an_adminmenu:makeannouncement')
AddEventHandler('an_adminmenu:makeannouncement', function(text, pw)
	local src = source
	if pass == pw then
		TriggerClientEvent('chat:addMessage', -1, { color = {244, 33, 0}, args = { "^*📢 ^1Admin Announcement ["..GetPlayerName(src).."]: ^0^r", text } } );
	else
		BanCheater(src, 'Lua Injection')
	end
end)

------- PLAYER OPTIONS --------
RegisterServerEvent('an_adminmenu:specPlayer')
AddEventHandler('an_adminmenu:specPlayer', function(pid, pw)
	local src = source
	if pass == pw then
		TriggerClientEvent('an_adminmenu:splyCLXD', src, pid)
		TriggerClientEvent('an_adminmenu:notify', src, 'You are now spectating '..GetPlayerName(pid)..' ID: ['..pid..']', 'success')
		logDatShit('**`[spectate player]` '..GetPlayerName(src)..'** [ID:'..src..'] started spectating **'..GetPlayerName(pid)..'**  [ID:'..pid..']', src) -- discord log
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent('an_adminmenu:revivePlayer')
AddEventHandler('an_adminmenu:revivePlayer', function(pid, pw)
	local src = source
	if pass == pw then
		if usingESX then
			TriggerClientEvent('esx_ambulancejob:revive', pid)
		else
			TriggerClientEvent('hospital:client:Revive', pid)
		end
		TriggerClientEvent('an_adminmenu:notify', src, 'You revived '..GetPlayerName(pid)..' ID: ['..pid..']', 'success')
		TriggerClientEvent('an_adminmenu:notify', pid, 'You have been revived by an admin', 'success')
		logDatShit('**`[revive player]` '..GetPlayerName(src)..'** [ID:'..src..'] revived **'..GetPlayerName(pid)..'**  [ID:'..pid..']', src) -- discord log
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent('an_adminmenu:healPlayer')
AddEventHandler('an_adminmenu:healPlayer', function(pid, pw)
	local src = source
	if pass == pw then
		if usingESX then
			TriggerClientEvent('esx_basicneeds:healPlayer', pid)
		else
			TriggerClientEvent('hospital:client:adminHeal', pid)
		end
		TriggerClientEvent('an_adminmenu:notify', src, 'You healed '..GetPlayerName(pid)..' ID: ['..pid..']', 'success')
		TriggerClientEvent('an_adminmenu:notify', pid, 'You have been healed by an admin', 'success')
		logDatShit('**`[heal player]` '..GetPlayerName(src)..'** [ID:'..src..'] healed **'..GetPlayerName(pid)..'**  [ID:'..pid..']', src) -- discord log
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent("an_adminmenu:killPlayer")
AddEventHandler("an_adminmenu:killPlayer", function(pid, pw)
	local src = source
	if pass == pw then
		TriggerClientEvent('an_adminmenu:kill', pid)
		TriggerClientEvent('an_adminmenu:notify', src, 'You killed '..GetPlayerName(pid)..' ID: ['..pid..']', 'success')
		TriggerClientEvent('an_adminmenu:notify', pid, 'You have been killed by an admin', 'error')
		logDatShit('**`[kill player]` '..GetPlayerName(src)..'** [ID:'..src..'] killed **'..GetPlayerName(pid)..'**  [ID:'..pid..']', src) -- discord log
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent("an_adminmenu:clearInv")
AddEventHandler("an_adminmenu:clearInv", function(pid, pw)
	local src = source
	if pass == pw then
		if usingESX then
			local xPlayer = ESX.GetPlayerFromId(pid)
			for k,v in ipairs(xPlayer.inventory) do
				if v.count > 0 then
					xPlayer.setInventoryItem(v.name, 0)
				end
			end
		else
			local Player = QBCore.Functions.GetPlayer(pid)
			Player.Functions.ClearInventory()
		end
		TriggerClientEvent('an_adminmenu:notify', src, 'You cleared the inventory for '..GetPlayerName(pid)..' ID: ['..pid..']', 'success')
		TriggerClientEvent('an_adminmenu:notify', pid, 'Your inventory was cleared by an Admin', 'error')
		logDatShit('**`[clear inventory]` '..GetPlayerName(src)..'** [ID:'..src..'] cleared the inventory for **'..GetPlayerName(pid)..'**  [ID:'..pid..']', src) -- discord log
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent("an_adminmenu:noclipPlayer")
AddEventHandler("an_adminmenu:noclipPlayer", function(pid, pw)
	local src = source
	if pass == pw then
		TriggerClientEvent('an_adminmenu:toggleNoClip', pid)
		TriggerClientEvent('an_adminmenu:notify', src, 'You toggled NoClip for '..GetPlayerName(pid)..' ID: ['..pid..']', 'success')
		TriggerClientEvent('an_adminmenu:notify', pid, 'An admin toggled NoClip mode for you.', 'success')
		logDatShit('**`[noclip player]` '..GetPlayerName(src)..'** [ID:'..src..'] toggled NoClip for **'..GetPlayerName(pid)..'** [ID:'..pid..']', src) -- discord log
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent("an_adminmenu:freezePlayer")
AddEventHandler("an_adminmenu:freezePlayer", function(pid, tog, pw)
	local src = source
	if pass == pw then
		TriggerClientEvent('an_adminmenu:freezePlayerCL', pid, tog)
		if tog then
			TriggerClientEvent('an_adminmenu:notify', src, 'You froze '..GetPlayerName(pid)..' ID: ['..pid..']', 'success')
			TriggerClientEvent('an_adminmenu:notify', pid, 'You have been frozen by an admin', 'success')
			logDatShit('**`[freeze player]` '..GetPlayerName(src)..'** [ID:'..src..'] froze **'..GetPlayerName(pid)..'** [ID:'..pid..']', src) -- discord log
		else
			TriggerClientEvent('an_adminmenu:notify', src, 'You unfroze '..GetPlayerName(pid)..' ID: ['..pid..']', 'success')
			TriggerClientEvent('an_adminmenu:notify', pid, 'You have been unfrozen by an admin', 'success')
			logDatShit('**`[unfreeze player]` '..GetPlayerName(src)..'** [ID:'..src..'] unfroze **'..GetPlayerName(pid)..'** [ID:'..pid..']', src) -- discord log
		end
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent("an_adminmenu:givefacemenu")
AddEventHandler("an_adminmenu:givefacemenu", function(pid, pw)
	local src = source
	if pass == pw then
		TriggerClientEvent('an_adminmenu:gfmCL', pid)
		TriggerClientEvent('an_adminmenu:notify', src, 'You gave face menu to '..GetPlayerName(pid)..' ID: ['..pid..']', 'success')
		TriggerClientEvent('an_adminmenu:notify', pid, 'You have been given Face Menu by an admin', 'success')
		logDatShit('**`[face menu]` '..GetPlayerName(src)..'** [ID:'..src..'] gave Face Menu to **'..GetPlayerName(pid)..'** [ID:'..pid..']', src) -- discord log
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent("an_adminmenu:giveclothes")
AddEventHandler("an_adminmenu:giveclothes", function(pid, pw)
	local src = source
	if pass == pw then
		TriggerClientEvent('an_adminmenu:gcmCL', pid)
		TriggerClientEvent('an_adminmenu:notify', src, 'You gave clothes menu to '..GetPlayerName(pid)..' ID: ['..pid..']', 'success')
		TriggerClientEvent('an_adminmenu:notify', pid, 'You have been given Clothes Menu by an admin', 'success')
		logDatShit('**`[clothes menu]` '..GetPlayerName(src)..'** [ID:'..src..'] gave Clothes Menu to **'..GetPlayerName(pid)..'** [ID:'..pid..']', src) -- discord log
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent("an_adminmenu:respawnPlayer")
AddEventHandler("an_adminmenu:respawnPlayer", function(pid, pw)
	local src = source
	if pass == pw then
		TriggerClientEvent('an_adminmenu:respawnCL', pid)
		TriggerClientEvent('an_adminmenu:notify', src, 'You respawned '..GetPlayerName(pid)..' ID: ['..pid..']', 'success')
		TriggerClientEvent('an_adminmenu:notify', pid, 'You have been respawned by an admin', 'success')
		logDatShit('**`[respawn player]` '..GetPlayerName(src)..'** [ID:'..src..'] respawned **'..GetPlayerName(pid)..'** [ID:'..pid..']', src) -- discord log
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent("an_adminmenu:giveCar")
AddEventHandler("an_adminmenu:giveCar", function(pid, model, pw)
	local src = source
	if pass == pw then
		TriggerClientEvent('an_adminmenu:spawnVeh', pid, model, true)
	else
		BanCheater(src, 'Lua Injection')
	end
end)


RegisterServerEvent("an_adminmenu:setAcc")
AddEventHandler("an_adminmenu:setAcc", function(type, amount, pid, pw)
	local src = source
	if pass == pw then
		if usingESX then
			local xPlayer = ESX.GetPlayerFromId(pid)
			if xPlayer then
				xPlayer.setAccountMoney(type, amount)
				TriggerClientEvent('an_adminmenu:notify', src, "You successfully set "..GetPlayerName(pid).."s ".. string.upper(type) .." money to $"..amount, 'success')
				TriggerClientEvent('an_adminmenu:notify', pid, "An Admin set your ".. string.upper(type) .." money to $"..amount, 'error')
			else
				TriggerClientEvent('an_adminmenu:notify', src, 'INVALID PLAYER!', 'error')
			end
		else
			local Player = QBCore.Functions.GetPlayer(pid)
			if Player then
				Player.Functions.SetMoney(type, amount)
				TriggerClientEvent('an_adminmenu:notify', src, "You successfully set "..GetPlayerName(pid).."s ".. string.upper(type) .." money to $"..amount, 'success')
				TriggerClientEvent('an_adminmenu:notify', pid, "An Admin set your ".. string.upper(type) .." money to $"..amount, 'error')
			else
				TriggerClientEvent('an_adminmenu:notify', src, 'INVALID PLAYER!', 'error')
			end
		end
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent("an_adminmenu:msgPlayer")
AddEventHandler("an_adminmenu:msgPlayer", function(pid, reason, pw)
	local src = source
	if pass == pw then
		local ok = false
		if usingESX then
			local xPlayer = ESX.GetPlayerFromId(src)
			if isAllowed(xPlayer) then
				ok = true
			end
		else
			if isAllowed2(src) then
				ok = true
			end
		end
		if ok then
			TriggerClientEvent('an_adminmenu:notify', src, 'You messaged '..GetPlayerName(pid)..' ID: ['..pid..'] the following mmessage: ['.. reason ..']', 'inform')
			TriggerClientEvent('an_adminmenu:notify', pid, 'You have been messaged by an Admin, read the chat!', 'error')
			TriggerClientEvent('chat:addMessage', pid, { color = {255, 255, 255}, args = { "^*✉️ ^2Admin (".. GetPlayerName(src) ..") messaged you: ^0", reason } } );
			logDatShit('**`[DM player]` '..GetPlayerName(src)..'** [ID:'..src..'] DMed **'..GetPlayerName(pid)..'**  [ID:'..pid..'] - Message: ['.. reason ..']', src) -- discord log
		end
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent("an_adminmenu:kickPlayer")
AddEventHandler("an_adminmenu:kickPlayer", function(pid, reason, pw)
	local src = source
	if pass == pw then
		if usingESX then
			local xPlayer = ESX.GetPlayerFromId(src)
			if isAllowed(xPlayer) then
				TriggerClientEvent('an_adminmenu:notify', src, 'You kicked '..GetPlayerName(pid)..' ID: ['..pid..'] - Reason: ['.. reason ..']', 'error')
				DropPlayer(pid, 'You have been kicked by an admin | Reason: '..reason)
				logDatShit('**`[kick player]` '..GetPlayerName(src)..'** [ID:'..src..'] kicked **'..GetPlayerName(pid)..'**  [ID:'..pid..'] - Reason: ['.. reason ..']', src) -- discord log
			end
		else
			if isAllowed2(src) then
				TriggerClientEvent('an_adminmenu:notify', src, 'You kicked '..GetPlayerName(pid)..' ID: ['..pid..'] - Reason: ['.. reason ..']', 'error')
				DropPlayer(pid, 'You have been kicked by an admin | Reason: '..reason)
				logDatShit('**`[kick player]` '..GetPlayerName(src)..'** [ID:'..src..'] kicked **'..GetPlayerName(pid)..'**  [ID:'..pid..'] - Reason: ['.. reason ..']', src) -- discord log
			end
		end
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent("an_adminmenu:warnPlayer")
AddEventHandler("an_adminmenu:warnPlayer", function(pid, reason, pw)
	local src = source
	if pass == pw then
		if usingESX then
			local xPlayer = ESX.GetPlayerFromId(src)
			if isAllowed(xPlayer) then
				TriggerClientEvent('an_adminmenu:notify', src, 'You warned '..GetPlayerName(pid)..' ID: ['..pid..'] - Reason: ['.. reason ..']', 'error')
				TriggerClientEvent('an_adminmenu:notify', pid, 'You have been warned - Reason: ['.. reason ..']', 'error')
				TriggerClientEvent('chat:addMessage', pid, { color = {255, 255, 255}, args = { "^*⚠️ ^1You have been warned by an admin | Reason: ^0", reason } } );
				logDatShit('**`[warn player]` '..GetPlayerName(src)..'** [ID:'..src..'] warned **'..GetPlayerName(pid)..'**  [ID:'..pid..'] - Reason: ['.. reason ..']', src) -- discord log
			end
		else
			if isAllowed2(src) then
				TriggerClientEvent('an_adminmenu:notify', src, 'You warned '..GetPlayerName(pid)..' ID: ['..pid..'] - Reason: ['.. reason ..']', 'error')
				TriggerClientEvent('an_adminmenu:notify', pid, 'You have been warned - Reason: ['.. reason ..']', 'error')
				TriggerClientEvent('chat:addMessage', pid, { color = {255, 255, 255}, args = { "^*⚠️ ^1You have been warned by an admin | Reason: ^0", reason } } );
				logDatShit('**`[warn player]` '..GetPlayerName(src)..'** [ID:'..src..'] warned **'..GetPlayerName(pid)..'**  [ID:'..pid..'] - Reason: ['.. reason ..']', src) -- discord log
			end
		end
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent("an_adminmenu:banPlayer")
AddEventHandler("an_adminmenu:banPlayer", function(pid, reason, length, pw)
	local src = source
	if pass == pw then
		if usingESX then
			local xPlayer = ESX.GetPlayerFromId(src)
			if isAllowed(xPlayer) then
				TriggerClientEvent('an_adminmenu:notify', src, 'You banned '..GetPlayerName(pid)..' ID: ['..pid..'] - Duration: ['.. length..' days] - Reason: ['.. reason ..']', 'error')
				Ban(pid, reason)
				logDatShit('**`[ban player]` '..GetPlayerName(src)..'** [ID:'..src..'] banned **'..GetPlayerName(pid)..'**  [ID:'..pid..'] - Duration: ['.. length..' days] - Reason: ['.. reason ..']', src) -- discord log
			end
		else
			if isAllowed2(src) then
				TriggerClientEvent('an_adminmenu:notify', src, 'You banned '..GetPlayerName(pid)..' ID: ['..pid..'] - Reason: ['.. reason ..']', 'error')
				Ban(pid, reason)
				logDatShit('**`[ban player]` '..GetPlayerName(src)..'** [ID:'..src..'] banned **'..GetPlayerName(pid)..'**  [ID:'..pid..'] - Duration: ['.. length..' days] - Reason: ['.. reason ..']', src) -- discord log
			end
		end
	else
		BanCheater(src, 'Lua Injection')
	end
end)

------- TELEPORT OPTIONS --------
RegisterServerEvent('an_adminmenu:bringAll')
AddEventHandler('an_adminmenu:bringAll', function(pw)
	local src = source
	if pass == pw then
		if usingESX then
			local xPlayer = ESX.GetPlayerFromId(src)
			if isAllowed(xPlayer) then
				local xPlayers = ESX.GetPlayers()
				for i=1, #xPlayers, 1 do
					local xTarget = ESX.GetPlayerFromId(xPlayers[i])
					local targetCoords = xTarget.getCoords()
					local playerCoords = xPlayer.getCoords()
					savedCoords[i] = targetCoords
					xTarget.setCoords(playerCoords)
					TriggerClientEvent('an_adminmenu:notify', xPlayers[i], 'You have been teleported by admin.', 'inform')
				end
				logDatShit('**`[bring all]` '..GetPlayerName(src)..'** [ID:'..src..'] teleported all players to them', src) -- discord log
				TriggerClientEvent('an_adminmenu:notify', src, 'You brought everyone to you.', 'success')
			end
		else
			if isAllowed2(src) then
				local players = QBCore.Functions.GetQBPlayers()
				for _,v in pairs(players) do
					local svID = v.PlayerData.source
					local targetCoords = GetEntityCoords(GetPlayerPed(svID))
					local playerCoords = GetEntityCoords(GetPlayerPed(src))
					savedCoords[svID] = targetCoords
					SetEntityCoords(svID, playerCoords)
					TriggerClientEvent('an_adminmenu:notify', svID, 'You have been teleported by admin.', 'inform')
				end
				logDatShit('**`[bring all]` '..GetPlayerName(src)..'** [ID:'..src..'] teleported all players to them', src) -- discord log
				TriggerClientEvent('an_adminmenu:notify', src, 'You brought everyone to you.', 'success')
			end
		end
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent('an_adminmenu:bringAllBack')
AddEventHandler('an_adminmenu:bringAllBack', function(pw)
	local src = source
	if pass == pw then
		if usingESX then
			local xPlayer = ESX.GetPlayerFromId(src)
			if isAllowed(xPlayer) then
				local xPlayers = ESX.GetPlayers()
				for k, v in pairs(xPlayers) do
					local xTarget = ESX.GetPlayerFromId(v)
					if savedCoords[v] then
						xTarget.setCoords(savedCoords[v])
						TriggerClientEvent('an_adminmenu:notify', v, 'An Admin teleported you back where you were.', 'inform')
					end
				end
				logDatShit('**`[bring all back]` '..GetPlayerName(src)..'** [ID:'..src..'] teleported all players back where they were', src) -- discord log
				TriggerClientEvent('an_adminmenu:notify', src, 'You brought everyone back where they were.', 'success')
			end
		else
			if isAllowed2(src) then
				local players = QBCore.Functions.GetQBPlayers()
				for _,v in pairs(players) do
					local svID = v.PlayerData.source
					if savedCoords[svID] then
						SetEntityCoords(svID, savedCoords[svID])
						TriggerClientEvent('an_adminmenu:notify', svID, 'An Admin teleported you back where you were.', 'inform')
					end
				end
				logDatShit('**`[bring all back]` '..GetPlayerName(src)..'** [ID:'..src..'] teleported all players back where they were', src) -- discord log
				TriggerClientEvent('an_adminmenu:notify', src, 'You brought everyone back where they were.', 'success')
			end
		end
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent('an_adminmenu:bring')
AddEventHandler('an_adminmenu:bring', function(target, pw)
	local src = source
	if pass == pw then
		if usingESX then
			local xPlayer = ESX.GetPlayerFromId(src)
			if isAllowed(xPlayer) then
				local xTarget = ESX.GetPlayerFromId(target)
				local targetCoords = xTarget.getCoords()
				local playerCoords = xPlayer.getCoords()
				savedCoords[target] = targetCoords
				xTarget.setCoords(playerCoords)
			end
		else
			if isAllowed2(src) then
				local targetCoords = GetEntityCoords(GetPlayerPed(target))
				local playerCoords = GetEntityCoords(GetPlayerPed(src))
				savedCoords[target] = targetCoords
				SetEntityCoords(target, playerCoords)
			end
		end
		TriggerClientEvent('an_adminmenu:notify', target, 'You have been teleported by admin.', 'inform')
		logDatShit('**`[bring]` '..GetPlayerName(src)..'** [ID:'..src..'] teleported **'..GetPlayerName(target)..'** [ID:'..target..'] to them', src) -- discord log
		TriggerClientEvent('an_adminmenu:notify', src, 'You brought '.. GetPlayerName(target) ..' ['.. target ..'] to you.', 'success')
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent('an_adminmenu:goback')
AddEventHandler('an_adminmenu:goback', function(pw)
	local src = source
	if pass == pw then
		if usingESX then
			local xPlayer = ESX.GetPlayerFromId(src)
			if isAllowed(xPlayer) then
				if savedCoords[src] ~= nil then
					xPlayer.setCoords(savedCoords[src])
					savedCoords[src] = nil
					TriggerClientEvent('an_adminmenu:notify', src, 'Teleported back where you were before.', 'inform')
					logDatShit('**`[goback]` '..GetPlayerName(src)..'** [ID:'..src..'] teleported back where they were before', src) -- discord log
				else
					TriggerClientEvent('an_adminmenu:notify', src, 'No where to go back to?', 'error')
				end
			end
		else
			if isAllowed2(src) then
				if savedCoords[src] ~= nil then
					SetEntityCoords(src, savedCoords[src])
					savedCoords[src] = nil
					TriggerClientEvent('an_adminmenu:notify', src, 'Teleported back where you were before.', 'inform')
					logDatShit('**`[goback]` '..GetPlayerName(src)..'** [ID:'..src..'] teleported back where they were before', src) -- discord log
				else
					TriggerClientEvent('an_adminmenu:notify', src, 'No where to go back to?', 'error')
				end
			end
		end
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent('an_adminmenu:goto')
AddEventHandler('an_adminmenu:goto', function(target, pw)
	local src = source
	if pass == pw then
		if usingESX then
			local xPlayer = ESX.GetPlayerFromId(src)
			if isAllowed(xPlayer) then
				local xTarget = ESX.GetPlayerFromId(target)
				local targetCoords = xTarget.getCoords()
				local playerCoords = xPlayer.getCoords()
				savedCoords[src] = playerCoords
				xPlayer.setCoords(targetCoords)
			end
		else
			if isAllowed2(src) then
				local targetCoords = GetEntityCoords(GetPlayerPed(target))
				local playerCoords = GetEntityCoords(GetPlayerPed(src))
				savedCoords[src] = playerCoords
				SetEntityCoords(src, targetCoords)
			end
		end
		TriggerClientEvent('an_adminmenu:notify', target, 'An admin has teleported to you.', 'inform')
		logDatShit('**`[goto]` '..GetPlayerName(src)..'** [ID:'..src..'] teleported themselves to **'..GetPlayerName(target)..'** [ID:'..target..']', src) -- discord log
		TriggerClientEvent('an_adminmenu:notify', src, 'You teleported to '.. GetPlayerName(target) ..' ['.. target ..'].', 'success')
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent('an_adminmenu:bringBack')
AddEventHandler('an_adminmenu:bringBack', function(target, pw)
	local src = source
	if pass == pw then
		if usingESX then
			local xPlayer = ESX.GetPlayerFromId(src)
			if isAllowed(xPlayer) then
				if savedCoords[target] ~= nil then
					local xTarget = ESX.GetPlayerFromId(target)
					xTarget.setCoords(savedCoords[target])
					savedCoords[target] = nil
				else
					TriggerClientEvent('an_adminmenu:notify', src, 'No where to bring them back.', 'error')
				end
			end
		else
			if isAllowed2(src) then
				if savedCoords[target] ~= nil then
					SetEntityCoords(target, savedCoords[target])
					savedCoords[target] = nil
				else
					TriggerClientEvent('an_adminmenu:notify', src, 'No where to bring them back.', 'error')
				end
			end
		end
		TriggerClientEvent('an_adminmenu:notify', target, 'You have been teleported back by admin.', 'inform')
		TriggerClientEvent('an_adminmenu:notify', src, 'You brought '.. GetPlayerName(target) ..' ['.. target ..'] back where they were before.', 'success')
		logDatShit('**`[bring back]` '..GetPlayerName(src)..'** [ID:'..src..'] teleported **'..GetPlayerName(target)..'** [ID:'..target..'] back where they were before', src) -- discord log
	else
		BanCheater(src, 'Lua Injection')
	end
end)

RegisterServerEvent('an_adminmenu:setGroup', function(target, group)
    local src = source
	if usingESX then
		local xPlayer = ESX.GetPlayerFromId(src)
		if contains(Config.godGroups, xPlayer.getGroup()) then
			local xTarget = ESX.GetPlayerFromId(target)
			if xTarget then
				xTarget.setGroup(group)
				TriggerClientEvent('an_adminmenu:notify', target, "Your group has been set to: "..Config.Groups[group].label.." by an Admin.", 'success')
				TriggerClientEvent('an_adminmenu:notify', src, "You changed " ..GetPlayerName(target).. "'s group to: "..Config.Groups[group].label, 'success')
				logDatShit('**`[set group]` '..GetPlayerName(src)..'** [ID:'..src..'] changed **'..GetPlayerName(target)..'**\'s group [ID:'..target..'] to '..Config.Groups[group].label, src) -- discord log
			end
		else
			TriggerClientEvent('an_adminmenu:notify', src, 'No permission!', 'error')
		end
	else
		if isGodAllowed(src) then
			QBCore.Functions.AddPermission(target, group)
			TriggerClientEvent('an_adminmenu:notify', target, "Your group has been set to: "..Config.Groups[group].label.." by an Admin.", 'success')
			TriggerClientEvent('an_adminmenu:notify', src, "You changed " ..GetPlayerName(target).. "'s group to: "..Config.Groups[group].label, 'success')
			logDatShit('**`[set group]` '..GetPlayerName(src)..'** [ID:'..src..'] changed **'..GetPlayerName(target)..'**\'s group [ID:'..target..'] to '..Config.Groups[group].label, src) -- discord log
		else
			TriggerClientEvent('an_adminmenu:notify', src, 'No permission!', 'error')
		end
    end
end)

RegisterServerEvent('an_adminmenu:logClientShit')
AddEventHandler('an_adminmenu:logClientShit', function(text)
	local src = source
	logDatShit(text, src)
end)

-- Functions
function isAllowed2(src) -- QBCore group check
	for k, v in pairs(Config.allowedGroups) do
		if QBCore.Functions.HasPermission(src, v) then
			return true
		end
	end
	return false
end

function isGodAllowed(src) -- QBCore God group check
	for k, v in pairs(Config.godGroups) do
		if QBCore.Functions.HasPermission(src, v) then
			return true
		end
	end
	return false
end

function isAllowed(player) -- ESX group check
	local grp = player.getGroup()
	if contains(Config.allowedGroups, grp) then
		return true
	end
	return false
end

function contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

function logDatShit(text, pid)
	local playerShit = ExtractIdentifiers(pid)
	local message = text .. '\n\n**Player ID:** '.. pid ..'\n**Rockstar License:** '.. playerShit.license ..'\n**Steam Identifier:** '.. playerShit.steam ..'\n**Player IP:** '.. playerShit.ip ..'\n**Discord:** <@'..playerShit.discord..'>'
	PerformHttpRequest(webhookSettings.url, function(err, text, headers) end, 'POST', json.encode({username = webhookSettings.username, embeds = {{["color"] = webhookSettings.color, ["author"] = {["name"] = webhookSettings.serverName,["icon_url"] = webhookSettings.serverLogo}, ["description"] = "".. message .."",["footer"] = {["text"] = "© AN Admin Menu - "..os.date("%x %X %p"),["icon_url"] = "https://i.imgur.com/fW6kEAe.png",},}}, avatar_url = webhookSettings.avatar}), { ['Content-Type'] = 'application/json' })
end

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "N/A",
        ip = "N/A",
        discord = "N/A",
        license = "N/A",
        xbl = "N/A",
        live = "N/A"
    }

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        if string.find(id, "steam") then
            identifiers.steam = id:gsub("steam:", "")
        elseif string.find(id, "ip") then
            identifiers.ip = id:gsub("ip:", "")
        elseif string.find(id, "discord") then
            identifiers.discord = id:gsub("discord:", "")
        elseif string.find(id, "license") then
            identifiers.license = id:gsub("license2:", "")
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end

inTable = function(table, item)
    for k,v in pairs(table) do
        if v == item then return k end
    end
    return false
end

CreateThread(function()
    while true do
		if usingESX then
			local tempPlayers = {}
			for k, v in pairs(ESX.GetPlayers()) do

				local targetped = GetPlayerPed(v)
				local plyr = ESX.GetPlayerFromId(v)
				tempPlayers[#tempPlayers + 1] = {
					name = GetPlayerName(v),
					ID = plyr.source,
					coords = GetEntityCoords(targetped),
					sources = GetPlayerPed(plyr.source),
				}
				-- local targetped = GetPlayerPed(v)
				-- players[#players+1] = {
				-- 	ID = v,
				-- 	coords = GetEntityCoords(targetped),
				-- }
			end
			players = tempPlayers
		else
			local tempPlayers = {}
			for _, v in pairs(QBCore.Functions.GetPlayers()) do
				local targetped = GetPlayerPed(v)
				local plyr = QBCore.Functions.GetPlayer(v)
				tempPlayers[#tempPlayers + 1] = {
					name = (plyr.PlayerData.charinfo.firstname or '') .. ' ' .. (plyr.PlayerData.charinfo.lastname or '') .. ' | (' .. (GetPlayerName(v) or '') .. ')',
					ID = v,
					coords = GetEntityCoords(targetped),
					sources = GetPlayerPed(plyr.PlayerData.source),
				}
			end
			players = tempPlayers
		end
        Wait(1500)
    end
end)

----- Bought from https://a-n.tebex.io/
----- For Support, Join my Discord: https://discord.gg/f2Nbv9Ebf5
----- For custom services or help, check my Fiverr: https://www.fiverr.com/aymannajim