----- Bought from https://a-n.tebex.io/
----- For Support, Join my Discord: https://discord.gg/f2Nbv9Ebf5
----- For custom services or help, check my Fiverr: https://www.fiverr.com/aymannajim

local svConfig = {}

----------------------------------
----- Customizable Variables -----
----------------------------------

-- General Config


-- Discord Log Configuration
webhookSettings = {
	url = 'https://discord.com/api/webhooks/951426213568725042/qsp50j4rGEHq6jLvC65a2JUfbxO_VbU9afyXTtuNI7tRT6SSPM6HED0sa7c1KCH5ZygB', -- Channel Webhook URL ( How to create channel webhook: https://www.youtube.com/watch?v=DskhhYdfl7A )
	username = 'AN Admin Menu', -- Webhook Username
	color = '54122', -- Use this to choose a decimal color:  https://www.mathsisfun.com/hexadecimal-decimal-colors.html
	serverName = 'NoPixel 4.0', -- Use this to choose a decimal color:  https://www.mathsisfun.com/hexadecimal-decimal-colors.html
	serverLogo = 'https://i.imgur.com/fW6kEAe.png', -- Server Logo
	avatar = 'https://i.imgur.com/fW6kEAe.png', -- Avatar URL
}

----------------------------------
----- Customizable Functions -----
----------------------------------

-- Ban Function if Lua Injection is Detected
function BanCheater(src, reason)
	logDatShit('**`[AN AntiCheat]`** 🔴 **'..GetPlayerName(src)..'** was detected cheating! 🔴\nReason: **'..reason..'**', src) -- Do not to touch unless you know what you're doing!
	Ban(src, reason..' | AN-AntiCheat | If you think this is a mistake, contact us on Discord')
end

-- Ban Function /!\ Need your own ban implementation
function Ban(src, reason, duration)
	------- Add your own event here to ban the player -------
	-- YOUR OWN EVENT HERE
	
	------- Example for people using QBCore -------
	if Config.Framework == 'QBCORE' then
		TriggerEvent('qb-admin:server:ban', src, duration, reason)
	end

	------- Example for people using FiveM-BanSql ( https://github.com/RedAlex/FiveM-BanSql )-------
	-- TriggerEvent("BanSql:ICheat", duration, reason, src)
	
	DropPlayer(src, reason) -- KICKS THE PLAYER | REMOVE THIS WHEN YOU ADD YOUR OWN BAN IMPLEMENTATION
end

----- Bought from https://a-n.tebex.io/
----- For Support, Join my Discord: https://discord.gg/f2Nbv9Ebf5
----- For custom services or help, check my Fiverr: https://www.fiverr.com/aymannajim