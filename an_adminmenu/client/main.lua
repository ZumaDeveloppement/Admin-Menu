----- Bought from https://a-n.tebex.io/
----- For Support, Join my Discord: https://discord.gg/f2Nbv9Ebf5
----- For custom services or help, check my Fiverr: https://www.fiverr.com/aymannajim

-- Connecting to Framework
ESX = nil
-- PlayerData = nil -- not needed for now
local QBCore
local isLoggedIn = false
local usingESX = false

Citizen.CreateThread(function()
	if Config.Framework == 'ESX' then
		if Config.esxLegacy then
			ESX = exports["es_extended"]:getSharedObject()
		else
			while ESX == nil do
				TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
				Citizen.Wait(0)
			end
				
			while ESX.GetPlayerData().job == nil do
				Citizen.Wait(10)
			end
		end
		-- PlayerData = ESX.GetPlayerData() -- not needed for now
		TriggerServerEvent('an_adminmenu:requestUpdatePerm')
		usingESX = true
	elseif Config.Framework == 'QBCORE' then
		QBCore = exports['qb-core']:GetCoreObject()
		usingESX = false
	end
end)

AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
	TriggerServerEvent('an_adminmenu:requestUpdatePerm')
end)

-- Script Variables
local hasAccess = false
local hasGodGroup = false
local password = nil
local isNOCLIP = false
local isFrozen = false
local plyFrozen = false
local isInvisible = false
local isGod = false
local infAmmo = false
local baseNoClipSpeed = 3
local PlyNoClip = false -- player management noclip toggle
local deleteLazer = false
local deleteLazerObjDetails = false
local svItems = {}
local target
local savedCoords
local playerBlips = {}
local showNames = false
local showBlips = false
local superRun = false
local superJump = false
local superSwim = false
local accType = nil
local svPlayers = {}
--
local currentPlayerMenu = nil
local currentPlayer = 0
local currentVehCategory = "bikes"
--
local LastSpecPosition, cam
local InSpectatorMode =  false
local specradius = -3.5
local polarAngleDeg = 0
local azimuthAngleDeg = 90

-- Prepare Menus
Citizen.CreateThread(function()


	-- Variables
    local menus = {
        "admin",
        "playerMan",
        "serverMan",
        currentPlayer,
        currentVehCategory,
        "playerOptions",
        "setGroupPerms",
        "manageAccs",
        "teleportOptions",
        "adminOpt",
        "selfOptions",
        "devOptions",
        "superPowers",
        "weatherSet",
        "timeSet",
        "spawnItems",
        "spawnWeapons",
        "weapAttachments",
        "weapTints",
        "spawnVehicles",
    }
	local times = {
        "00 00",
        "01 00",
        "02 00",
        "03 00",
        "04 00",
        "05 00",
        "06 00",
        "07 00",
        "08 00",
        "09 00",
        "10 00",
        "11 00",
        "12 00",
        "13 00",
        "14 00",
        "15 00",
        "16 00",
        "17 00",
        "18 00",
        "19 00",
        "20 00",
        "21 00",
        "22 00",
        "23 00",
    }
	local weathers = {
		"EXTRASUNNY",
		"BLIZZARD",
		"CLEAR",
		"CLEARING",
		"CLOUDS",
		"FOGGY",
		"HALLOWEEN",
		"OVERCAST",
		"RAIN",
		"SMOG",
		"SNOWLIGHT",
		"THUNDER",
		"XMAS",
	}
	
	-- Getting Server Data
	if Config.Framework == 'ESX' then
		ESX.TriggerServerCallback('an_adminmenu:getItems', function(items)
			svItems = items	
		end)
	else
		svItems = QBCore.Shared.Items
	end
	
	-- Set Indexes
	local currentBanIndex = 1
    local selectedBanIndex = 1
    
    local currentMinTimeIndex = 1
    local selectedMinTimeIndex = 1

    local currentMaxTimeIndex = 1
    local selectedMaxTimeIndex = 1

    local currentPermIndex = 1
    local selectedPermIndex = 1
	
	-- Creating Menus and Sub Menus
	WarMenu.CreateMenu('admin', 'Admin Menu')
    WarMenu.CreateSubMenu('playerMan', 'admin')
    WarMenu.CreateSubMenu('serverMan', 'admin')
    WarMenu.CreateSubMenu('adminOpt', 'admin')
    WarMenu.CreateSubMenu('devOptions', 'admin')
    WarMenu.CreateSubMenu('selfOptions', 'adminOpt')
    WarMenu.CreateSubMenu('superPowers', 'selfOptions')
    WarMenu.CreateSubMenu('spawnItems', 'adminOpt')
    WarMenu.CreateSubMenu('spawnWeapons', 'adminOpt')
    WarMenu.CreateSubMenu('weapAttachments', 'adminOpt')
    WarMenu.CreateSubMenu('weapTints', 'adminOpt')
    WarMenu.CreateSubMenu('spawnVehicles', 'adminOpt')
    WarMenu.CreateSubMenu('weatherSet', 'serverMan')
    WarMenu.CreateSubMenu('timeSet', 'serverMan')
	
	-- Sub Title
	WarMenu.SetSubTitle('admin', 'MAIN MENU')
	WarMenu.SetSubTitle('adminOpt', 'Admin Options')
	WarMenu.SetSubTitle('playerMan', 'Player Management')
	WarMenu.SetSubTitle('serverMan', 'Server Management')
	WarMenu.SetSubTitle('selfOptions', 'Self Options')
	WarMenu.SetSubTitle('devOptions', 'Developer Options')
	WarMenu.SetSubTitle('superPowers', 'Super Powers')
	WarMenu.SetSubTitle('spawnItems', 'Spawn Items')
	WarMenu.SetSubTitle('spawnWeapons', 'Spawn (Native) Weapons')
	WarMenu.SetSubTitle('weapAttachments', 'Weapon Attachments')
	WarMenu.SetSubTitle('weapTints', 'Weapon Tints')
	WarMenu.SetSubTitle('spawnVehicles', 'Spawn Vehicles')
	WarMenu.SetSubTitle('weatherSet', 'Change Weather')
	WarMenu.SetSubTitle('timeSet', 'Change Time')
	
	for k, v in pairs(menus) do
        WarMenu.SetMenuX(v, 0.71)
        WarMenu.SetMenuY(v, 0.15)
        WarMenu.SetMenuWidth(v, 0.23)
        WarMenu.SetTitleColor(v, 255, 255, 255, 255)
        WarMenu.SetTitleBackgroundColor(v, 0, 0, 0, 150)
		WarMenu.SetMenuMaxOptionCountOnScreen(v, Config.maxMenuITems)
    end
	
	
	while true do
		Citizen.Wait(3)
		if WarMenu.IsMenuOpened('admin') then
			WarMenu.MenuButton('Admin Options >', 'adminOpt')
            if WarMenu.MenuButton('Player Management >', 'playerMan') then
				getAllPlayers()
			end
            WarMenu.MenuButton('Server Management >', 'serverMan')
            WarMenu.MenuButton('Dev Options >', 'devOptions')
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('adminOpt') then
            WarMenu.MenuButton('Self Options >', 'selfOptions')
			WarMenu.CheckBox("Show Player Names and IDs Above Head", showNames, function(checked)
				showNames = checked
				if showNames then
					getAllPlayers()
				end
			end)
            if WarMenu.CheckBox("Show Player Blips In Map", showBlips, function(checked) showBlips = checked end) then
                if showBlips then
					Notify('BLIPS ENABLED', 'success')
					TriggerServerEvent('an_adminmenu:logClientShit', '**`[PLAYER_BLIPS]` :green_circle: '..GetPlayerName(PlayerId())..'** has enabled Player Blips')
				else
					Notify('BLIPS DISABLED', 'inform')
					TriggerServerEvent('an_adminmenu:logClientShit', '**`[PLAYER_BLIPS]` :red_circle: '..GetPlayerName(PlayerId())..'** has disabled Player Blips')
					TriggerServerEvent('an_adminmenu:getPlayers')
				end
            end
            WarMenu.MenuButton('Spawn Items >', 'spawnItems')
            WarMenu.MenuButton('Spawn Weapons >', 'spawnWeapons')
            WarMenu.MenuButton('Weapon Attachments >', 'weapAttachments')
            WarMenu.MenuButton('Weapon Tints >', 'weapTints')
            WarMenu.MenuButton('Spawn Vehicles >', 'spawnVehicles')
            if WarMenu.MenuButton('~HUD_COLOUR_TENNIS~Make an announcement', 'admin') then
				exports['an_dialogBox']:showDialog('adminmenu_announce', 'Make an Announcement:', '', 'This announcement will be showed in the chat to all online players.', onAnnouncementMade)
			end
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('selfOptions') then
			if WarMenu.CheckBox("NoClip", isNOCLIP, function(checked) isNOCLIP = checked end) then
                if isNOCLIP then
					NoClipON()
					Notify('NOCLIP ENABLED', 'success')
					if Config.logNoClipActions then TriggerServerEvent('an_adminmenu:logClientShit', '**`[noclip]` '..GetPlayerName(PlayerId())..'** has entered NOCLIP mode') end
                else
					NoClipOFF()
					Notify('NOCLIP DISABLED', 'inform')
					if Config.logNoClipActions then TriggerServerEvent('an_adminmenu:logClientShit', '**`[noclip]` '..GetPlayerName(PlayerId())..'** has exited NOCLIP mode') end
                end
            end
			if WarMenu.Button('Revive') then
				if usingESX then
					TriggerEvent('esx_ambulancejob:revive')
				else
					TriggerEvent('hospital:client:Revive', PlayerPedId())
				end
				TriggerServerEvent('an_adminmenu:logClientShit', '**`[revive]` '..GetPlayerName(PlayerId())..'** revived themselves')
			end
			if WarMenu.Button('Heal') then
				if usingESX then
					TriggerEvent('esx_basicneeds:healPlayer')
				else
					TriggerEvent('hospital:client:adminHeal', PlayerId())
				end
				TriggerServerEvent('an_adminmenu:logClientShit', '**`[heal]` '..GetPlayerName(PlayerId())..'** healed themselves')
			end
			if WarMenu.CheckBox("Godmode", isGod, function(checked) isGod = checked end) then
                local ped = PlayerPedId()
				
				if isGod then
					Notify('GOD MODE ENABLED', 'success')
					SetEntityCanBeDamaged(ped, false)
					SetPedCanBeKnockedOffVehicle(ped, false)
					SetPedCanBeDraggedOut(ped, false)
					SetEntityProofs(ped, true, true, true, true, true, true, 1, true)
					SetPedCanRagdoll(ped, false)
					SetPedCanRagdollFromPlayerImpact(ped, true)
					TriggerServerEvent('an_adminmenu:logClientShit', '**`[godmode]` '..GetPlayerName(PlayerId())..'** enabled GodMode')
				else
					Notify('GOD MODE DISABLED', 'inform')
					SetEntityCanBeDamaged(ped, true)
					SetPedCanBeKnockedOffVehicle(ped, true)
					SetPedCanBeDraggedOut(ped, true)
					SetEntityProofs(ped, false, false, false, false, false, false, 1, false)
					SetPedCanRagdoll(ped, true)
					SetPedCanRagdollFromPlayerImpact(ped, false)
					TriggerServerEvent('an_adminmenu:logClientShit', '**`[godmode]` '..GetPlayerName(PlayerId())..'** disabled GodMode')
				end
            end
			if WarMenu.CheckBox("Invisible", isInvisible, function(checked) isInvisible = checked end) then
                local ped = PlayerPedId()
				
                if isInvisible then
                    SetEntityVisible(ped, false, false)
					Notify('INVISIBLE MODE ENABLED', 'success')
                else
                    SetEntityVisible(ped, true, false)
					Notify('INVISIBLE MODE DISABLED', 'inform')
                end
            end
			if WarMenu.Button('Repair Vehicle') then
				local ped = PlayerPedId()
				
				if IsPedInAnyVehicle(ped, false) then
					local veh = GetVehiclePedIsUsing(ped)
					SetVehicleFixed(veh)
					Notify('Vehicle successfully repaired', 'success')
				else
					Notify('Where is your vehicle?', 'error')
				end
			end
			if WarMenu.Button('Drift Mode') then
				local ped = PlayerPedId()
				if IsPedInAnyVehicle(ped, false) then
					local veh = GetVehiclePedIsUsing(ped)
					if GetDriftTyresEnabled(veh) then
						SetDriftTyresEnabled(veh, false)
						Notify('Drift Mode Disabled for this vehicle!', 'error')
					else
						SetDriftTyresEnabled(veh, true)
						Notify('Drift Mode Enabled for this vehicle!', 'success')
					end
				else
					Notify('Where is your vehicle?', 'error')
				end
			end
			if WarMenu.Button("Delete Vehicle") then
				deleteVeh()
			end
			if Config.tuneCar then
				if WarMenu.Button('Tune Vehicle') then
					local ped = PlayerPedId()
					
					if IsPedInAnyVehicle(ped, false) then
						TuneCarMenu()
					else
						Notify('Where is your vehicle?', 'error')
					end
				end
			end
			if WarMenu.Button('Max Ammo') then
				local ped = PlayerPedId()
				local weap = GetSelectedPedWeapon(ped)
				-- print(weap ~= GetHashKey('WEAPON_UNARMED'))
				if weap ~= GetHashKey('WEAPON_UNARMED') then
					SetPedAmmo(ped, weap, 9999)
					Notify('MAX AMMUNITION SET ON YOUR WEAPON!', 'success')
				else
					Notify('You have no weapon selected.', 'error')
				end
			end
			if WarMenu.Button('Remove All Weapons') then
				local ped = PlayerPedId()
				RemoveAllPedWeapons(ped)
				Notify('YOU ARE CLEARED FROM WEAPONS!', 'success')
			end
			if WarMenu.Button('Change Ped Model') then
				exports['an_dialogBox']:showDialog('ped_change_menu', 'Enter Ped Model:', 'a_c_rat', 'List of Ped Models: https://wiki.rage.mp/index.php?title=Peds', onEnterPedModel)
			end
			WarMenu.MenuButton('Super Powers >', 'superPowers')
			if WarMenu.Button('Teleport to Marker') then
				TriggerEvent("an_adminmenu:tpm")
			end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('superPowers') then
			if WarMenu.CheckBox("Super Run", superRun, function(checked) superRun = checked end) then
				if superRun then 
					SetRunSprintMultiplierForPlayer(PlayerId(),1.5)
					Notify('SUPER RUN ACTIVATED', 'success')
				else
					SetRunSprintMultiplierForPlayer(PlayerId(),1.0)
					Notify('SUPER RUN DEACTIVATED', 'error')
				end
			end
			if WarMenu.CheckBox("Super Swim", superSwim, function(checked) superSwim = checked end) then
				if superSwim then 
					SetSwimMultiplierForPlayer(PlayerId(), 1.49)
					Notify('SUPER SWIM ACTIVATED', 'success')
				else
					SetSwimMultiplierForPlayer(PlayerId(), 1.00)
					Notify('SUPER SWIM DEACTIVATED', 'error')
				end
			end
			if WarMenu.CheckBox("Super Jump", superJump, function(checked) superJump = checked end) then
				if superJump then 
					Notify('SUPER JUMP ACTIVATED', 'success')
				else
					Notify('SUPER JUMP DEACTIVATED', 'error')
				end
			end
			if WarMenu.IsItemHovered() then
				WarMenu.ToolTip("Make sure to activate God Mode so you don't get your balls busted.", nil, true)
			end
			if WarMenu.CheckBox("Infinite Ammo", infAmmo, function(checked) infAmmo = checked end) then
				local ped = PlayerPedId()
				local weap = GetSelectedPedWeapon(ped)
				if infAmmo then
					SetPedInfiniteAmmoClip(ped, true)
					Notify('INFINITE AMMUNITION ENABLED', 'success')
                else
					SetPedInfiniteAmmoClip(ped, false)
					Notify('INFINITE AMMUNITION DISABLED', 'inform')
                end
            end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('devOptions') then
			if WarMenu.Button('Copy vector3 to clipboard') then
				local ped = PlayerPedId()
				local coords = GetEntityCoords(ped)
				local x, y, z = round(coords.x, 2), round(coords.y, 2), round(coords.z, 2)
				local str = string.format('vector3(%s, %s, %s)', x, y, z)
				CopyToClipboard(str)
			end
			if WarMenu.Button('Copy vector4 to clipboard') then
				local ped = PlayerPedId()
				local coords = GetEntityCoords(ped)
				local x, y, z = round(coords.x, 2), round(coords.y, 2), round(coords.z, 2)
				local heading = GetEntityHeading(ped)
				local h = round(heading, 2)
				local str = string.format('vector4(%s, %s, %s, %s)', x, y, z, h)
				CopyToClipboard(str)
			end
			if WarMenu.Button('Copy heading to clipboard') then
				local ped = PlayerPedId()
				local heading = GetEntityHeading(ped)
				local h = round(heading, 2)
				CopyToClipboard(h)
			end
			if WarMenu.CheckBox("Delete Lazer", deleteLazer, function(checked) deleteLazer = checked end) then
				if deleteLazer then
					PlaySoundFrontend(-1, 'Node_Release', 'dlc_xm_silo_laser_hack_sounds', 1)
				else
					PlaySoundFrontend(-1, 'Node_Select', 'dlc_xm_silo_laser_hack_sounds', 1)
				end
            end
			if WarMenu.Button('Clear area from peds') then
				TriggerEvent("an_adminmenu:clearareaofpeds")
			end
			if WarMenu.Button('Clear area from vehicles') then
				TriggerEvent("an_adminmenu:clearareaofvehs")
			end
			WarMenu.Display()
		------- START OF PLAYER MANAGEMENT SECTION
		elseif WarMenu.IsMenuOpened('playerMan') then
            local players = svPlayers
            for k, v in pairs(players) do
                WarMenu.CreateSubMenu(v["id"], 'playerMan', "ID: "..v["serverid"].." | "..v["name"].."")
            end
            if WarMenu.MenuButton('ID: '..GetPlayerServerId(PlayerId()).." | "..GetPlayerName(PlayerId()).." >>", GetPlayerServerId(PlayerId())) then
                currentPlayer = GetPlayerServerId(PlayerId())
                if WarMenu.CreateSubMenu('playerOptions', currentPlayer) then
                    currentPlayerMenu = 'playerOptions'
                elseif WarMenu.CreateSubMenu('teleportOptions', currentPlayer) then
                    currentPlayerMenu = 'teleportOptions'
                elseif WarMenu.CreateSubMenu('adminOptions', currentPlayer) then
                    currentPlayerMenu = 'adminOptions'
                end
            end
            for k, v in pairs(players) do
                if v["id"] ~= GetPlayerServerId(PlayerId()) then
                    if WarMenu.MenuButton("ID: "..v["serverid"].." | "..v["name"], v["id"]) then
                        currentPlayer = v["id"]
                        if WarMenu.CreateSubMenu('playerOptions', currentPlayer) then
                            currentPlayerMenu = 'playerOptions'
                        elseif WarMenu.CreateSubMenu('teleportOptions', currentPlayer) then
                            currentPlayerMenu = 'teleportOptions'
                        elseif WarMenu.CreateSubMenu('adminOptions', currentPlayer) then
                            currentPlayerMenu = 'adminOptions'
                        end
                    end
                end
            end
            WarMenu.Display()
		elseif WarMenu.IsMenuOpened(currentPlayer) then
            WarMenu.MenuButton('Player Options >', 'playerOptions')
            WarMenu.MenuButton('Teleport Options >', 'teleportOptions')
            if WarMenu.MenuButton('Spectate', currentPlayer) then
				TriggerServerEvent('an_adminmenu:specPlayer', currentPlayer, password)
			end
            WarMenu.Display()
		elseif WarMenu.IsMenuOpened('playerOptions') then
			if WarMenu.MenuButton('Heal', currentPlayer) then
				TriggerServerEvent('an_adminmenu:healPlayer', currentPlayer, password)
			end
			if WarMenu.MenuButton('Revive', currentPlayer) then
				TriggerServerEvent('an_adminmenu:revivePlayer', currentPlayer, password)
			end
			if WarMenu.MenuButton('Kill', currentPlayer) then
				TriggerServerEvent('an_adminmenu:killPlayer', currentPlayer, password)
			end
			if WarMenu.CheckBox("Toggle NoClip", PlyNoClip, function(checked) PlyNoClip = checked end) then
				TriggerServerEvent('an_adminmenu:noclipPlayer', currentPlayer, password)
            end
			if WarMenu.CheckBox("Freeze", plyFrozen, function(checked) plyFrozen = checked end) then
                TriggerServerEvent("an_adminmenu:freezePlayer", currentPlayer, plyFrozen, password)
            end
			if WarMenu.MenuButton("Give Car", currentPlayer) then
				exports['an_dialogBox']:showDialog('adminmenu_givecar_'..currentPlayer, 'Car Model:', 'sultan', 'Specify the car model to spawn for '..svPlayers[currentPlayer].name..' - ID: '..currentPlayer, onGiveCarToPlayer)
			end
			if Config.giveFaceMenu then
				if WarMenu.MenuButton("Give Face Menu", currentPlayer) then
					TriggerServerEvent('an_adminmenu:givefacemenu', currentPlayer, password)
				end
			end
			if Config.giveClothingMenu then
				if WarMenu.MenuButton("Give Clothing Menu", currentPlayer) then
					TriggerServerEvent('an_adminmenu:giveclothes', currentPlayer, password)
				end
			end
			if Config.respawnPlayer then
				if WarMenu.MenuButton("Respawn", currentPlayer) then
					TriggerServerEvent('an_adminmenu:respawnPlayer', currentPlayer, password)
				end
			end
			if Config.openPlayerInventory then
				if WarMenu.MenuButton("Open Inventory", currentPlayer) then
					if Config.Framework ~= 'QBCORE' then
						OpenPlayerInv(currentPlayer)
					else
						TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", currentPlayer)
					end
				end
			end
			if Config.accManage then
				WarMenu.CreateSubMenu('manageAccs', currentPlayer)
				WarMenu.MenuButton('Manage Accounts >', "manageAccs")
			end
			if hasGodGroup then
				WarMenu.CreateSubMenu('setGroupPerms', currentPlayer)
				WarMenu.MenuButton('Set Group >', 'setGroupPerms')
			end
			if WarMenu.MenuButton("~r~Clear Inventory", "playerMan") then
				TriggerServerEvent("an_adminmenu:clearInv", currentPlayer, password)
			end
			if WarMenu.MenuButton("~b~DM Player", "playerMan") then
				exports['an_dialogBox']:showDialog('adminmenu_text_'..currentPlayer, 'Your Messsage', '', 'Specify your message to '..svPlayers[currentPlayer].name..' - ID: '..currentPlayer, onTextPlayer)
			end
			if WarMenu.MenuButton("~y~Warn Player", "playerMan") then
				exports['an_dialogBox']:showDialog('adminmenu_warn_'..currentPlayer, 'Warn Reason', '', 'Specify the reason for warning '..svPlayers[currentPlayer].name..' - ID: '..currentPlayer, onWarnPlayer)
			end
			if WarMenu.MenuButton("~r~Kick Player", "playerMan") then
				exports['an_dialogBox']:showDialog('adminmenu_kick_'..currentPlayer, 'Kick Reason', '', 'Specify the reason for kicking '..svPlayers[currentPlayer].name..' - ID: '..currentPlayer..' | This action is irreversible!', onKickPlayer)
			end
			if WarMenu.MenuButton("~r~Ban Player", "playerMan") then
				exports['an_dialogBox']:showDialog('adminmenu_ban_'..currentPlayer, 'Ban Reason:', '', 'Specify the reason for banning '..svPlayers[currentPlayer].name..' - ID: '..currentPlayer..' | This action is irreversible!', onBanPlayer)
			end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('manageAccs') then
			if usingESX then
				for k,v in pairs(Config.ESXAccounts) do
					if WarMenu.MenuButton("Set "..v.label, "manageAccs") then
						ESX.TriggerServerCallback("an_adminmenu:getAcc", function(amount)
							accType = v.name
							exports['an_dialogBox']:showDialog('set_player_acc_money', 'Set new '..v.label..' amount:', '0', 'Current '..v.label..' amount for '..svPlayers[currentPlayer].name..': $'..amount, onEnterNewAccAmount)
						end, currentPlayer, v.name)
					end
				end
			else
				for k,v in pairs(Config.QBAccounts) do
					if WarMenu.MenuButton("Set "..v.label, "manageAccs") then
						QBCore.Functions.TriggerCallback('an_adminmenu:getAcc', function(amount)
							accType = v.name
							exports['an_dialogBox']:showDialog('set_player_acc_money', 'Set new '..v.label..' amount:', '0', 'Current '..v.label..' amount for '..svPlayers[currentPlayer].name..': $'..amount, onEnterNewAccAmount)
						end, currentPlayer, v.name)
					end
				end
			end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('setGroupPerms') then
			for k,v in pairs(Config.Groups) do
				if WarMenu.Button(v.label) then
					TriggerServerEvent('an_adminmenu:setGroup', currentPlayer, k)
				end
			end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('teleportOptions') then
            if WarMenu.MenuButton('Goto', currentPlayer) then
				local targetId = currentPlayer
				TriggerServerEvent('an_adminmenu:goto', targetId, password)
                -- local target = GetPlayerPed(currentPlayer)
                -- local ped = PlayerPedId()
				-- if NetworkIsPlayerActive(currentPlayer) then
				-- 	savedCoords = GetEntityCoords(ped)
				-- 	if isNOCLIP then
				-- 		NoClipOFF()
				-- 		SetEntityCoords(ped, GetEntityCoords(target))
				-- 		NoClipON()
				-- 	else
				-- 		SetEntityCoords(ped, GetEntityCoords(target))
				-- 	end
				-- 	Notify('Teleported to '..svPlayers[currentPlayer].name .. ' - ID: '..currentPlayer, 'success')
				-- else
				-- 	Notify('Player Offline?', 'error')
				-- end
            end
            if WarMenu.MenuButton('Bring', currentPlayer) then
				local targetId = currentPlayer
				TriggerServerEvent('an_adminmenu:bring', targetId, password)
            end
			if WarMenu.MenuButton('Bring Back', currentPlayer) then
                local targetId = currentPlayer
				TriggerServerEvent('an_adminmenu:bringBack', targetId, password)
            end
			if WarMenu.MenuButton('Go Back', currentPlayer) then
				TriggerServerEvent('an_adminmenu:goback', password)
                -- if savedCoords ~= nil then
				-- 	SetEntityCoords(ped, savedCoords)
				-- 	Notify('Teleported back where you were before', 'success')
				-- 	savedCoords = nil
				-- else
				-- 	Notify('No where to go back', 'error')
				-- end
            end
            WarMenu.Display()
		------- END OF PLAYER MANAGEMENT SECTION
		elseif WarMenu.IsMenuOpened('spawnItems') then
			for k,v in pairs(svItems) do
				if WarMenu.Button(v.label) then
					TriggerServerEvent('an_adminmenu:giveItem', k, password)
				end
			end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('spawnWeapons') then
			for k,v in pairs(Config.Weapons) do
				if WarMenu.Button(v.label) then
					local ped = PlayerPedId()
					
					GiveWeaponToPed(ped, GetHashKey(v.name), 9999, false, true)
					Notify(string.upper(v.label)..' SPAWNED', 'success')
				end
			end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('weapAttachments') then
			local ped = PlayerPedId()
			local currWeap = GetSelectedPedWeapon(ped)
			for k,v in pairs(Config.Weapons) do
				local weapHash = GetHashKey(v.name)
				if weapHash == currWeap then
					if #v.components > 0 then
						for key,val in pairs(v.components) do
							if WarMenu.Button(val.label) then
								if HasPedGotWeaponComponent(ped, currWeap, val.hash) then
									RemoveWeaponComponentFromPed(ped, currWeap, val.hash)
									if val.label then
										Notify(val.label..' component removed from your weapon', 'error')
									end
								else
									GiveWeaponComponentToPed(ped, currWeap, val.hash)
									if val.label then
										Notify(val.label..' component added to your weapon', 'success')
									end
								end
							end
						end
					end
				end
			end
			
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('weapTints') then
			local ped = PlayerPedId()
			local currWeap = GetSelectedPedWeapon(ped)
			for i = 0, #Config.DefaultWeaponTints do
				if WarMenu.Button(Config.DefaultWeaponTints[i]) then
					SetPedWeaponTintIndex(ped, currWeap, i)
					Notify(Config.DefaultWeaponTints[i]..' tint applied to your weapon', 'success')
				end
			end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('spawnVehicles') then
			for k, v in pairs(vehicleCategories) do
                WarMenu.CreateSubMenu(v["category"], 'spawnVehicles', v["label"])
				if WarMenu.MenuButton(v["label"].." >>", v["category"]) then
					currentVehCategory = v["category"]
				end
            end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened(currentVehCategory) then
			-- print('opened')
			for k,v in pairs(vehicleList) do
				if v.category == currentVehCategory then
					if WarMenu.Button(v.name) then
						TriggerEvent('an_adminmenu:spawnVeh', v.model)
						Notify('Spawning '.. v.name ..'.', 'inform')
					end
				end
			end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('serverMan') then
			if Config.usevSync or Config.Framework == 'QBCORE' then
				WarMenu.MenuButton('Change Weather  >', 'weatherSet')
				WarMenu.MenuButton('Change Time  >', 'timeSet')
				if WarMenu.Button('Freeze Weather') then
					ExecuteCommand("freezeweather")
				end
				if WarMenu.Button('Freeze Time') then
					ExecuteCommand("freezetime")
				end
			end
			if Config.bringAllPlayers then
				if WarMenu.Button('⚠️ ~r~Bring all players to me') then
					TriggerServerEvent('an_adminmenu:bringAll', password)
				end
				if WarMenu.Button('⚠️ ~o~Bring all players back') then
					TriggerServerEvent('an_adminmenu:bringAllBack', password)
				end
			end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('weatherSet') then
			for i=1, #weathers do
				if WarMenu.Button(weathers[i]) then
					if usingESX then
						ExecuteCommand('weather '..weathers[i])
					else
						TriggerServerEvent('qb-weathersync:server:setWeather', weathers[i])
					end
				end
			end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('timeSet') then
			for i=1, #times do
				if WarMenu.Button(times[i]) then
					if usingESX then
						ExecuteCommand('time '..times[i])
					else
						ExecuteCommand('time '..times[i]) -- TO DO: USE EVENT INSTEAD
					end
				end
			end
			WarMenu.Display()
		end
	end
	
end)

-- MENU OPENER
RegisterNetEvent('an_adminmenu:openmenu')
AddEventHandler('an_adminmenu:openmenu', function(pw)
	password = pw
	TriggerServerEvent('an_adminmenu:requestUpdatePerm') -- used to update client side with player's group -- very handy!
	OpenAdminMenu()
end)

function OpenAdminMenu()
	WarMenu.OpenMenu('admin')
end

-- MENU ACCESS UPDATE
RegisterNetEvent('an_adminmenu:accessUpdated')
AddEventHandler('an_adminmenu:accessUpdated', function(permData)
	hasAccess = permData[1]
	hasGodGroup = permData[2]
end)

-- EVENTS
RegisterNetEvent('an_adminmenu:kill')
AddEventHandler('an_adminmenu:kill', function()
	SetEntityHealth(PlayerPedId(), 0)
end)

RegisterNetEvent('an_adminmenu:freezePlayerCL')
AddEventHandler('an_adminmenu:freezePlayerCL', function(toggle)
	isFrozen = toggle
	FreezeEntityPosition(PlayerPedId(), isFrozen)
end)

RegisterNetEvent('an_adminmenu:toggleNoClip')
AddEventHandler('an_adminmenu:toggleNoClip', function()
	isNOCLIP = not isNOCLIP
	if isNOCLIP then
		NoClipON()
	else
		NoClipOFF()
	end
end)

RegisterNetEvent('an_adminmenu:gfmCL')
AddEventHandler('an_adminmenu:gfmCL', function()
	GiveFaceMenu()
end)

RegisterNetEvent('an_adminmenu:gcmCL')
AddEventHandler('an_adminmenu:gcmCL', function()
	GiveClothingMenu()
end)

RegisterNetEvent('an_adminmenu:respawnCL')
AddEventHandler('an_adminmenu:respawnCL', function()
	spawnSelector()
end)

-------- SPECTATE
RegisterNetEvent('an_adminmenu:splyCLXD')
AddEventHandler('an_adminmenu:splyCLXD', function(playerid)
	spectate(playerid)
end)

function spectate(target)
	-- print(target)
	if not InSpectatorMode then
		LastSpecPosition = GetEntityCoords(PlayerPedId())
	end

	local playerPed = PlayerPedId()

	SetEntityCoords(PlayerPedId(), svPlayers[target].coords)
	SetEntityCollision(playerPed, false, false)
	SetEntityVisible(playerPed, false)

	Citizen.CreateThread(function()
		if not DoesCamExist(cam) then
			cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
		end

		SetCamActive(cam, true)
		RenderScriptCams(true, false, 0, true, true)
		-- print(svPlayers[target].coords)
		Wait(500)
		InSpectatorMode = true
		TargetSpectate  = target
	end)
end

Citizen.CreateThread(function()

  	while true do

		Wait(0)

		if InSpectatorMode then

			local targetPlayerId = GetPlayerFromServerId(TargetSpectate)
			-- print(targetPlayerId)
			local playerPed	  = PlayerPedId()
			local targetPed	  = GetPlayerPed(targetPlayerId)
			local coords	 = GetEntityCoords(targetPed)

			for i=0, 32, 1 do
				if i ~= PlayerId() then
					local otherPlayerPed = GetPlayerPed(i)
					SetEntityNoCollisionEntity(playerPed,  otherPlayerPed,  true)
				end
			end

			if IsControlPressed(2, 241) then
				specradius = specradius + 1.0
			end

			if IsControlPressed(2, 242) then
				specradius = specradius - 1.0
			end

			if specradius > -1.5 then
				specradius = -1.5
			end
			
			if specradius < -20 then
				specradius = -20
			end

			local xMagnitude = GetDisabledControlNormal(0, 1)
			local yMagnitude = GetDisabledControlNormal(0, 2)

			polarAngleDeg = polarAngleDeg + xMagnitude * 10

			if polarAngleDeg >= 360 then
				polarAngleDeg = 0
			end

			azimuthAngleDeg = azimuthAngleDeg + yMagnitude * 10

			if azimuthAngleDeg >= 360 then
				azimuthAngleDeg = 0
			end

			local nextCamLocation = polar3DToWorld3D(coords, specradius, polarAngleDeg, azimuthAngleDeg)

			SetCamCoord(cam,  nextCamLocation.x,  nextCamLocation.y,  nextCamLocation.z)
			PointCamAtEntity(cam,  targetPed)
			SetEntityCoords(playerPed,  coords.x, coords.y, coords.z + 3)
			
			if IsControlPressed(2, Config.QuitSpectateKey) then
				quitSpectateMode()
			end
			
			DrawTXT(0.55, 0.53, 1.0, 1.0, 0.42, '~w~Quit Spectate Mode: ~HUD_COLOUR_G9~'..Config.QuitSpectateKeyLabel, 255,255,255,255, true)
			DrawTXT(0.55, 0.55, 1.0, 1.0, 0.42, '~w~Zoom In: ~HUD_COLOUR_G9~Mouse Scroll Up', 255,255,255,255, true)
			DrawTXT(0.55, 0.57, 1.0, 1.0, 0.42, '~w~Zoom Out: ~HUD_COLOUR_G9~Mouse Scroll Down', 255,255,255,255, true)
			DrawTXT(0.55, 0.59, 1.0, 1.0, 0.42, '~w~Move Camera: ~HUD_COLOUR_G9~Mouse Movement', 255,255,255,255, true)

		end
	end
end)

function quitSpectateMode()
	InSpectatorMode = false
	TargetSpectate  = nil
	local playerPed = PlayerPedId()

	SetCamActive(cam, false)
	RenderScriptCams(false, false, 0, true, true)

	SetEntityCollision(playerPed, true, true)
	SetEntityVisible(playerPed, true)
	SetEntityCoords(playerPed, LastSpecPosition.x, LastSpecPosition.y, LastSpecPosition.z)
end

function polar3DToWorld3D(entityPosition, radius, polarAngleDeg, azimuthAngleDeg)
	-- convert degrees to radians
	local polarAngleRad   = polarAngleDeg   * math.pi / 180.0
	local azimuthAngleRad = azimuthAngleDeg * math.pi / 180.0

	local pos = {
		x = entityPosition.x + radius * (math.sin(azimuthAngleRad) * math.cos(polarAngleRad)),
		y = entityPosition.y - radius * (math.sin(azimuthAngleRad) * math.sin(polarAngleRad)),
		z = entityPosition.z - radius * math.cos(azimuthAngleRad)
	}

	return pos
end


-------- NOCLIP

-- NOCLIP variables
local curCoords = nil

-- NOCLIP functions
function NoClipON()
	local ped = PlayerPedId()
	local x, y, z = table.unpack( GetEntityCoords( ped, false ) )
    curCoords = { x = x, y = y, z = z }
end

function NoClipOFF()
	local ped = PlayerPedId()
    local insideVehicle = IsPedInAnyVehicle( ped, false )

    if insideVehicle then
        local veh = GetVehiclePedIsUsing( ped )
        SetEntityInvincible(veh, false )
    else
        ClearPedTasksImmediately( ped )
    end

    SetPlayerInvincible(PlayerId(), false)
    SetEntityInvincible(target, false)
end

-- Credits to @Oui (Lambda Menu)
function degToRadian(degree)
	return degree * 3.141592653589793238 / 180
end

-- NOCLIP HANDLER
Citizen.CreateThread(function()
	local moveUpKey = 44      		-- Q
    local moveDownKey = 46    		-- E
    local moveForwardKey = 32 		-- W
    local moveBackKey = 33    		-- S
    local speedChangeKeyUp = 21 	-- LSHIFT
    local speedChangeKeyDown = 210 	-- LCONTROL
	local speed = 0.5
	
	local speedNames = { 'VERY SLOW', 'SLOW', 'MEDIUM', 'MEDIUM +', 'IN A HURRY', 'IN A HURRY +', 'FAST BOI', 'VERY FAST BOI', 'SPEED OF LIGHT', 'FLASH', 'GOD-LIKE SPEED', 'WTF?' }
	local speeds = { 0.05, 0.2, 0.5, 0.7, 1.0, 1.8, 2.5, 3.6, 5.0, 10.0, 15.0, 50.0 }
	
	function movePlayer(xv,yv)
		if (IsControlPressed(1, moveUpKey) or IsDisabledControlPressed(1, moveUpKey)) then
            curCoords.z = curCoords.z + speed / 2
        elseif (IsControlPressed(1, moveDownKey) or IsDisabledControlPressed(1, moveDownKey)) then
            curCoords.z = curCoords.z - speed / 2
        end

        if (IsControlPressed( 1, moveForwardKey) or IsDisabledControlPressed(1, moveForwardKey)) then
            curCoords.x = curCoords.x + xv
            curCoords.y = curCoords.y + yv
        elseif ( IsControlPressed( 1, moveBackKey) or IsDisabledControlPressed(1, moveBackKey)) then
            curCoords.x = curCoords.x - xv
            curCoords.y = curCoords.y - yv
        end
		
		if (IsControlJustPressed(1, speedChangeKeyUp) or IsDisabledControlJustPressed(1, speedChangeKeyUp)) then
			baseNoClipSpeed = baseNoClipSpeed + 1
			if (baseNoClipSpeed > getTableLength(speeds)) then
                baseNoClipSpeed = 1
            end
			updateNoClipSpeed()
		elseif (IsControlJustPressed(1, speedChangeKeyDown) or IsDisabledControlJustPressed(1, speedChangeKeyDown)) then
			baseNoClipSpeed = baseNoClipSpeed - 1
			if (baseNoClipSpeed < 1) then
                baseNoClipSpeed = getTableLength(speeds)
            end
			updateNoClipSpeed()
		end
	end
	
	-- Update Speed
	function updateNoClipSpeed()
        speed = speeds[baseNoClipSpeed]
    end
	
	while true do
		if isNOCLIP then
			local ped = PlayerPedId()
			local pedcoords = GetEntityCoords(ped)
			if IsEntityDead(ped) then
				isNOCLIP = false
				NoClipOFF()
				Notify('NOCLIP DISABLED BECAUSE YOU DIED', 'error')
				Citizen.Wait(500)
			else
				target = ped
				
				local insideVehicle = IsPedInAnyVehicle( ped, true )
				
				if insideVehicle then
                    target = GetVehiclePedIsUsing( ped )
                end
				
				SetEntityVelocity(target, 0.0, 0.0, 0.0 )
                SetEntityRotation(target, 0, 0, 0, 0, false )
				
				SetPlayerInvincible(PlayerId(), true)
				SetEntityInvincible(target, true)
				
				local heading = GetGameplayCamRelativeHeading()
				
				local xv = speed * math.sin( degToRadian( heading ) ) * -1.0
                local yv = speed * math.cos( degToRadian( heading ) )
				
				movePlayer(xv, yv)
				
				SetEntityCoordsNoOffset(target, curCoords.x, curCoords.y, curCoords.z, true, true, true)
				SetEntityHeading(target, heading)
				
				DrawTXT(1.3, 1.33, 1.0, 1.0, 0.5, '~w~NoClip Speed: ~HUD_COLOUR_NET_PLAYER1~x'..speeds[baseNoClipSpeed]..'~w~ | ~HUD_COLOUR_G9~'..speedNames[baseNoClipSpeed], 255,255,255,255, true)
				DrawTXT(0.55, 0.53, 1.0, 1.0, 0.42, '~w~Ascend: ~HUD_COLOUR_G9~Q ~w~| Descend: ~HUD_COLOUR_G9~E', 255,255,255,255, true)
				DrawTXT(0.55, 0.55, 1.0, 1.0, 0.42, '~w~Increase Speed: ~HUD_COLOUR_G9~LEFT SHIFT', 255,255,255,255, true)
				DrawTXT(0.55, 0.57, 1.0, 1.0, 0.42, '~w~Decrease Speed: ~HUD_COLOUR_G9~LEFT CTRL', 255,255,255,255, true)
			end
		end
		Citizen.Wait(5)
	end
end)

-- Delete Lazer Thread
Citizen.CreateThread(function()
	local wait = 1000
	while true do
		Citizen.Wait(wait)

        if deleteLazer then
			wait = 0
            local color = {r = 100, g = 255, b = 100, a = 255}
            local position = GetEntityCoords(GetPlayerPed(-1))
            local hit, coords, entity = RayCastGamePlayCamera(10000.0)
            
            -- If entity is found then verifie entity
            if hit and (IsEntityAVehicle(entity) or IsEntityAPed(entity) or IsEntityAnObject(entity)) then
				local entityType = GetEntityType(entity)
				local entityType2
				if entityType == 1 then
					entityType2 = 'Ped'
				elseif entityType == 2 then
					entityType2 = 'Vehicle'
				elseif entityType == 3 then
					entityType2 = 'Object/Prop'
				else
					entityType2 = 'NULL'
				end
			
                local entityCoord = GetEntityCoords(entity)
                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
				DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6, 0.6, 0.6, color.r, color.g, color.b, 20, false, true, 2, nil, nil, false)
				local model = GetEntityModel(entity)
				if deleteLazerObjDetails then
					draw3DText(entityCoord.x, entityCoord.y, entityCoord.z + 0.35, "Entity: ~b~" .. entity .. "~w~\n Model: ~b~" .. model .. "~w~\n Entity Type: ~b~"..entityType2.."~w~\n[~o~H~w~] Go back")
				else
					draw3DText(entityCoord.x, entityCoord.y, entityCoord.z + 0.35, "[~o~H~w~] Show Details\n[~g~G~w~] Copy Model\n[~r~E~w~] Delete object!")
					if IsControlJustReleased(0, 38) then
						SetEntityAsMissionEntity(entity, true, true)
						NetworkRegisterEntityAsNetworked(entity)
						NetworkRequestControlOfEntity(entity)
						Notify('Deleting Entity..', 'inform')
						Wait(200)
						DeleteEntity(entity)
						Wait(50)
						if DoesEntityExist(entity) then
							Notify('Entity could not delete! Its networked existence is controlled by another player! Try again!', 'error')
							TriggerServerEvent('an_adminmenu:logClientShit', '**`[delete lazer]` '..GetPlayerName(PlayerId())..'** deleted an entity with the delete lazer\n[entity type: '..entityType2..']\n[entity model: '..model..']\n[entity hash: '..entity..']\n[entity coords: '.. entityCoord.x ..' '.. entityCoord.y .. ' ' .. entityCoord.z..']')
						else
							PlaySoundFrontend(-1, 'Delete_Placed_Prop', 'DLC_Dmod_Prop_Editor_Sounds', 1)
							Notify('Entity Deleted', 'success')
						end
					end
					if IsControlJustReleased(0, 47) then
						CopyToClipboard(model)
					end
				end
				
				if IsControlJustReleased(0, 304) then
					deleteLazerObjDetails = not deleteLazerObjDetails
				end
            elseif coords.x ~= 0.0 and coords.y ~= 0.0 then
                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, 90)
                DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, color.r, color.g, color.b, 90, false, true, 2, nil, nil, false)
            end
		else
			wait = 1000
        end
	end
end)

-- Raycast function for Delete Lazer
function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination = 
	{ 
		x = cameraCoord.x + direction.x * distance, 
		y = cameraCoord.y + direction.y * distance, 
		z = cameraCoord.z + direction.z * distance 
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

-- Embedding direction in rotation vector
function RotationToDirection(rotation)
	local adjustedRotation = 
	{ 
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = 
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

-- God Mode
Citizen.CreateThread(function()
	while true do
		if isGod then
			local ped = PlayerPedId()
			SetPlayerInvincible(ped, true)
			ClearPedBloodDamage(ped)
			ResetPedVisibleDamage(ped)
			ClearPedLastWeaponDamage(ped)
		else
			Citizen.Wait(500)
		end
		Citizen.Wait(0)
	end
end)

-- Infinite Ammo
Citizen.CreateThread(function()
	while true do
		if infAmmo then -- known bug: it makes other players see you shooting empty
			local ped = PlayerPedId()
			local weap = GetSelectedPedWeapon(ped)
			local _, maxAmmo = GetMaxAmmo(ped, weap)
			if GetAmmoInPedWeapon(ped, weap) < maxAmmo then
				SetPedAmmo(ped, weap, maxAmmo)
			end
			RefillAmmoInstantly(ped)
		else
			Citizen.Wait(1000)
		end
		Citizen.Wait(100)
	end
end)

-- Super Run
Citizen.CreateThread(function()
	while true do
		if superRun then
			local ped = PlayerPedId()
			SetPedMoveRateOverride(ped, 3.0)
		end
		Citizen.Wait(0)
	end
end)

-- Super Jump
Citizen.CreateThread(function()
	while true do
		if superJump then
			SetSuperJumpThisFrame(PlayerId())
		end
		Citizen.Wait(0)
	end
end)

-- Show Names and IDs above Players
Citizen.CreateThread(function()
    while true do

        if showNames then
            for _, player in pairs(GetPlayersFromCoords(GetEntityCoords(GetPlayerPed(-1)), Config.distanceForNames)) do
                local PlayerId = player["serverid"]
                local PlayerPed = player["ped"]
                local PlayerName = player["name"]
                local PlayerCoords = GetEntityCoords(PlayerPed)

                draw3DText(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z + 1.05, '[~r~'..PlayerId..'~s~] '..PlayerName)
            end
        else
            Citizen.Wait(1000)
        end

        Citizen.Wait(3)
    end
end)

GetPlayersFromCoords = function(coords, distance)
    local players = svPlayers
    local closePlayers = {}

    if coords == nil then
		coords = GetEntityCoords(GetPlayerPed(-1))
    end
    if distance == nil then
        distance = 5.0
    end
    for _, player in pairs(players) do
		local target = player["ped"]
		local targetCoords = GetEntityCoords(target)
		local targetdistance = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)
		if targetdistance <= distance then
			table.insert(closePlayers, player)
		end
    end
    
    return closePlayers
end

-- Update Player Blips in Map
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		if showBlips then
			TriggerServerEvent('an_adminmenu:getPlayers')
		end
	end
end)

RegisterNetEvent('an_adminmenu:showBlips', function(players)
	for k, v in pairs(players) do
		if v.ID ~= GetPlayerServerId(PlayerId()) then
			local player = GetPlayerFromServerId(v.ID)
			local ped = GetPlayerPed(player)
			local blip = GetBlipFromEntity(ped)
			-- print(v.ID..' = ped: '..ped..' | blip: '..tostring(blip)..' coords: '..v.coords)
			if showBlips then
				if not DoesBlipExist(blip) then
					-- print('adding blip for: '..v.ID)
					blip = AddBlipForEntity(ped)
					-- print('Blip added: '..blip)
					SetBlipSprite(blip, 1)
					ShowHeadingIndicatorOnBlip(blip, true)
					SetBlipColour(blip, 36)
					SetBlipScale(blip, 0.8)
					SetBlipAsShortRange(blip, true)
				else
					if Config.showPlayerVehicles then
						local veh = GetVehiclePedIsIn(ped, false)
						if veh ~= 0 then
							local veh = GetVehiclePedIsIn(ped, false)
							local class = GetVehicleClass(veh)
							if class == 5 or class == 7 then
								blipSprite = 523
							elseif class == 12 or class == 20 or class == 10 or class == 11 then
								blipSprite = 477
							elseif class == 19 then
								blipSprite = 421
							elseif class == 16 then
								blipSprite = 423
							elseif class == 15 then
								blipSprite = 43
							elseif class == 18 then
								blipSprite = 56
							elseif class == 14 then
								blipSprite = 410
							elseif class == 13 or class == 8 then
								blipSprite = 348
							else 
								blipSprite = 225
							end
						else
							blipSprite = 1
						end
					end
					if not GetEntityHealth(ped) then
						blipSprite = 274
						ShowHeadingIndicatorOnBlip(blip, false)
					else
						ShowHeadingIndicatorOnBlip(blip, true)
					end
					SetBlipSprite(blip, blipSprite)
					SetBlipColour(blip, 36)
					SetBlipRotation(blip, GetEntityHeading(ped))
					SetBlipNameToPlayerName(blip, player)
					SetBlipScale(blip, 0.8)
				end
			else
				RemoveBlip(blip)
			end
		end
	end
end)

-- Vehicle Spawner
RegisterNetEvent("an_adminmenu:spawnVeh", function(model, adminToPlayer)
	if not adminToPlayer then
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			deleteVeh()
		end
	end
	local heading = GetEntityHeading(PlayerPedId())
	local coords = GetEntityCoords(PlayerPedId())
	if usingESX then
		ESX.Game.SpawnVehicle(model, coords, heading, function(vehicle)
			TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
			SetEntityAsMissionEntity(vehicle, true, true)
			local plate = GetVehicleNumberPlateText(vehicle)
			GiveKeysForThisCar(plate)
			if adminToPlayer then
				Notify("An admin gave you this car", "success")
			end
		end)
	else
		QBCore.Functions.SpawnVehicle(model, function(veh)
			TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
			SetEntityAsMissionEntity(veh, true, true)
			SetEntityHeading(veh, heading)
			GiveKeysForThisCar(plate)
			TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
			if adminToPlayer then
				Notify("An admin gave you this car", "success")
			end
		end, coords, false)
	end
end)

function deleteVeh()
	if usingESX then
		TriggerEvent('esx:deleteVehicle', 3.0)
	else
		TriggerEvent("QBCore:Command:DeleteVehicle")
	end
end

-- Notification System
RegisterNetEvent('an_adminmenu:notify')
AddEventHandler('an_adminmenu:notify', function(msg,type)
	Notify(msg, type)
end)

function Notify(msg, type)
	if Config.useMythic then
		exports['mythic_notify']:SendAlert(type, msg, 12000)
	elseif Config.useESXnotif then
		ESX.ShowNotification(msg)
	elseif Config.useQBnotif then
		if type == 'inform' then type = 'primary' end
		QBCore.Functions.Notify(msg, type, 12000)
	elseif Config.useCustomNotif then
		CustomNotif(msg, type)
	end
	if type == "error" then
		PlaySoundFrontend(-1, 'ERROR', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
	end
end


-- Key Control
Citizen.CreateThread(function()
	while true do
		if hasAccess then
			if IsControlJustReleased(0, Config.KeyOpenMenu) or IsDisabledControlJustReleased(0, Config.KeyOpenMenu) then
				ExecuteCommand(Config.commandName)
			end
			if Config.useNoClipShortcutKey then
				if IsControlJustReleased(0, Config.NoClipKey) or IsDisabledControlJustReleased(0, Config.NoClipKey) then
					if isNOCLIP then
						NoClipOFF()
						Notify('NOCLIP DISABLED', 'inform')
						if Config.logNoClipActions then TriggerServerEvent('an_adminmenu:logClientShit', '**`[noclip]` '..GetPlayerName(PlayerId())..'** has exited NOCLIP mode using the shortcut key') end
						isNOCLIP = false
					else
						NoClipON()
						Notify('NOCLIP ENABLED', 'success')
						if Config.logNoClipActions then TriggerServerEvent('an_adminmenu:logClientShit', '**`[noclip]` '..GetPlayerName(PlayerId())..'** has entered NOCLIP mode using the shortcut key') end
						isNOCLIP = true
					end
				end
			end
		end
		Citizen.Wait(0)
	end
end)

-- Anti Cheat | Injection Detection onClientResourceStart
RegisterNetEvent("onClientResourceStart")
AddEventHandler("onClientResourceStart",function(l)
	local m=tostring(l)
	local n=string.len(l)
	local o=string.sub(l,1,1)
	if n >= 18 and o == "_" then
		TriggerServerEvent('discord:tageveryone', 'anticheat', '[RESOURCE INJECTION DETECTED]')
		logDatShit('**`[Anti Cheat]`** Injection detected \n**'..l..'**\n[onClientResourceStart]', GetPlayerServerId(PlayerId())) -- discord log
	end
	local p=m:match("rE_")
	if p ~= nil and p ~= false then
		TriggerServerEvent('discord:tageveryone', 'anticheat', '[RedENGINE INJECTION DETECTED]')
		logDatShit('**`[Anti Cheat]`** RedENGINE INJECTION triggered \n**'..l..'**\n[onClientResourceStart]', GetPlayerServerId(PlayerId())) -- discord log
	end
end)

-- Clipboard
function CopyToClipboard(str)
	SendNUIMessage({
		action = 'copy',
		clipboard = str
	})
	if Config.useMythic then
		Notify('<span style="font-weight: bold;">'..str..'</span> copied to clipboard.', 'success')
	else
		Notify(str..' copied to clipboard.')
	end
end

-- PED CHANGE NUI SUCCESS FUNCTION
function onEnterPedModel(text)
	local model = text
	if model ~= nil then
		if IsModelInCdimage(model) and IsModelValid(model) then
			Notify('MODEL: '..model..' is Valid.', 'success')
			RequestModel(model)
			while not HasModelLoaded(model) do
				RequestModel(model)
				Wait(100)
			end
			SetPlayerModel(PlayerId(), model)
			SetModelAsNoLongerNeeded(model)
			Notify('Your ped has successfully changed!', 'success')
			TriggerServerEvent('an_adminmenu:logClientShit', '**`[change ped]` '..GetPlayerName(PlayerId())..'** changed  his ped model\n[model: **'..model..'**]\n[model hash: **'..GetHashKey(model)..'**]')
		else
			Notify('MODEL: '..model..' is not valid.', 'error')
		end
	end
end

function onEnterNewAccAmount(text)
	if accType ~= nil then
		local num = tonumber(text)
		if num and num >= 0 then
			TriggerServerEvent("an_adminmenu:setAcc", accType, math.floor(num), currentPlayer, password)
			-- print("new acc amount: "..math.floor(num))
		else
			print("Invalid amount")
		end
	else
		Notify('Unknown error, please try again!', 'error')
	end
	accType = nil
end

-- MAKE ANNOUNCEMENT NUI SUCCESS FUNCTION
function onAnnouncementMade(text)
	TriggerServerEvent("an_adminmenu:makeannouncement", text, password)
end

-- GIVE CAR TO PLAYER NUI SUCCESS FUNCTION
function onGiveCarToPlayer(model)
	if IsModelInCdimage(model) and IsModelValid(model) then
		Notify('Spawning a '..model..' for '.. svPlayers[currentPlayer].name..' - ID: '..currentPlayer, 'inform')
		TriggerServerEvent('an_adminmenu:giveCar', currentPlayer, model, password)
	else
		Notify('MODEL: '..model..' is not valid.', 'error')
	end
end

-- Warn Player NUI SUCCESS FUNCTION
function onWarnPlayer(text)
	if text == '' then
		text = 'No reason specified'
	end
	TriggerServerEvent("an_adminmenu:warnPlayer", currentPlayer, text, password)
end

-- DM Player NUI SUCCESS FUNCTION
function onTextPlayer(text)
	if text == '' then
		text = 'N/A'
	end
	TriggerServerEvent("an_adminmenu:msgPlayer", currentPlayer, text, password)
end

-- Kick Player NUI SUCCESS FUNCTION
function onKickPlayer(text)
	if text == '' then
		text = 'No reason specified'
	end
	TriggerServerEvent("an_adminmenu:kickPlayer", currentPlayer, text, password)
end

local cachedBanReason = ''
-- Ban Player Reason NUI SUCCESS FUNCTION
function onBanPlayer(text)
	if text == '' then
		cachedBanReason = 'No reason specified'
	end
	exports['an_dialogBox']:showDialog('adminmenu_ban2_'..currentPlayer, 'Ban Length:', '', 'Specify the ban duration (in days) for <b>'..svPlayers[currentPlayer].name..'</b> - ID: <b>'..currentPlayer..'</b> | This action is irreversible!', _onBanPlayer)			
end

-- Ban Player Duration NUI SUCCESS FUNCTION
function _onBanPlayer(text)
	local length = -1
	if tonumber(text) ~= nil then
		length = tonumber(text)
	end
	if length >= 0 then
		cachedBanReason = ''
		TriggerServerEvent("an_adminmenu:banPlayer", currentPlayer, cachedBanReason, length, password)
	else
		cachedBanReason = ''
		Notify('INVALID BAN DURATION', 'error')
	end
end

-- clear peds event
RegisterNetEvent("an_adminmenu:clearareaofpeds")
AddEventHandler("an_adminmenu:clearareaofpeds", function()
	local ped = GetPlayerPed(-1)
	local coords = GetEntityCoords(ped)
	ClearAreaOfPeds(coords.x, coords.y, coords.z, Config.ClearAreaFromPedsRadius + 0.0, 1)
	Notify('Area cleared of peds ( '..Config.ClearAreaFromPedsRadius..'-meter radius )', 'success')
end)

-- clear vehs event
RegisterNetEvent("an_adminmenu:clearareaofvehs")
AddEventHandler("an_adminmenu:clearareaofvehs", function()
	local ped = PlayerPedId()
	local veh = GetVehiclePedIsUsing(ped)
    if veh ~= 0 then
        SetEntityAsMissionEntity(veh, true, true)
        DeleteVehicle(veh)
    else
        local pcoords = GetEntityCoords(ped)
        local vehicles = GetGamePool('CVehicle')
        for _, v in pairs(vehicles) do
            if #(pcoords - GetEntityCoords(v)) <= Config.ClearAreaFromVehsRadius + 0.0 then
                SetEntityAsMissionEntity(v, true, true)
                DeleteVehicle(v)
            end
        end
    end
	Notify('Area cleared of vehicles ( '..Config.ClearAreaFromVehsRadius..'-meter radius )', 'success')
end)

-- TPM
RegisterNetEvent("an_adminmenu:tpm")
AddEventHandler("an_adminmenu:tpm", function()
    local WaypointHandle = GetFirstBlipInfoId(8)
    if DoesBlipExist(WaypointHandle) then
        local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

        for height = 1, 1000 do
            SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

            local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

            if foundGround then
                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

                break
            end

            Citizen.Wait(5)
        end
        Notify('Teleported to waypoint!', 'success')
    else
        Notify('Set a waypoint on the map first.', 'error')
    end
end)

-- Base Functions
function getTableLength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function draw3DText(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
	SetTextDropShadow()
	SetTextOutline()
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function DrawTXT(x,y,width,height,scale, text, r,g,b,a, outline)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
	SetTextColour( 0,0,0, 255 )
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
	SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
	ClearDrawOrigin()
end

function getAllPlayers()
    local players = {}
	if usingESX then
		ESX.TriggerServerCallback("an_adminmenu:getAllPlayers", function(pls)
			for k,v in pairs(pls) do
				players[v.ID] = { ped = v.sources, name = v.name, id = v.ID, serverid = v.ID, coords = v.coords }
			end
			table.sort(players, function(a, b)
				return a.serverid < b.serverid
			end)
			svPlayers = players
		end)
	else
		QBCore.Functions.TriggerCallback('an_adminmenu:getAllPlayers', function(pls)
			for k,v in pairs(pls) do
				-- local player = GetPlayerFromServerId(v.ID)
				-- print(v.sources)
				-- print(v.name)
				-- print(v.coords)
				-- print(player)
				-- print(NetworkGetEntityOwner(v.sources))
				-- print(v.ID)
				-- print("--------------------")
				players[v.ID] = { ped = v.sources, name = v.name, id = v.ID, serverid = v.ID, coords = v.coords }
			end
			table.sort(players, function(a, b)
				return a.serverid < b.serverid
			end)
			svPlayers = players
		end)
	end
end

----- Bought from https://a-n.tebex.io/
----- For Support, Join my Discord: https://discord.gg/f2Nbv9Ebf5
----- For custom services or help, check my Fiverr: https://www.fiverr.com/aymannajim