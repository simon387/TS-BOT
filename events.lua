-- Author: simon387@hotmail.it
-- global variables (I/O EXCEPTIONS NOT HANDLED!!! like in all the script)
-- linux versione, last update: 20160325
	print("OK")
	print("OK")
	print("OK")
	files = {conf = "config", a_list = "admin_list", w_list = "white_list", stop = "stop.mp3", on = "on.mp3", off = "off.mp3", text = "text"}
	PLUGIN_path = ts3.getAppPath() .. "plugins/lua_plugin/TauntBot/"
	TAUNT_path = PLUGIN_path .. "Taunt/"
	fUI = "" fID = "" sCHID = "" msg = "" tM = 0 muteFlag = false modFLag = false
-- -----------------------------------------------------------------------
	fileHandle = io.open(PLUGIN_path .. files.conf, "r")
	fileHandle:read()

-- parameters read from files.conf
	WINAMP_path = string.sub(fileHandle:read(), 3)
	print("WINAMP_path=" .. WINAMP_path)
	CHROME_path = string.sub(fileHandle:read(), 3)
	print("CHROME_path=" .. CHROME_path)
	MAX_STRING_LEN = tonumber(string.sub(fileHandle:read(), 3))
	print("MAX_STRING_LEN=" .. MAX_STRING_LEN)
	CHROME_WAIT_TIME = tonumber(string.sub(fileHandle:read(), 3))
	print("CHROME_WAIT_TIME=" .. CHROME_WAIT_TIME)
	fileHandle:close()

-- parameters read from files.text
	s = {}
	fileHandle = io.open(PLUGIN_path .. files.text, "r")
	for line in fileHandle:lines() do
		table.insert(s, line)
	end
	fileHandle:close()

-- taunt-tabby filler
	tempFile = os.tmpname()
   print("tempFile=" .. tempFile)
	--	os.execute('dir /b /l "' .. TAUNT_path .. '" >' .. tempFile)
	os.execute('ls "' .. TAUNT_path .. '" >' .. tempFile)
	fileHandle = io.open(tempFile, "r")
	TAUNT_TABBY = {}
	for line in fileHandle:lines() do
		table.insert(TAUNT_TABBY, string.sub(line, 0, (string.len(line) - 4)))
		print("inserito record")
	end
	fileHandle:close()
	os.remove(tempFile)
	fileHandle = nil
	tempFile = nil

-- main function
function onTextMessageEvent(serverConnectionHandlerID, targetMode, toID, fromID, fromName, fromUniqueIdentifier, message, ffIgnored)
	sCHID = serverConnectionHandlerID tM = targetMode fID = fromID fUI = fromUniqueIdentifier msg = message
	if     string.sub(msg, 0, 6) == "!addw " then add_on_list(files.w_list)
	elseif string.sub(msg, 0, 6) == "!adda " then add_on_list(files.a_list)
	elseif string.sub(msg, 0, 6) == "!rmvw " then rmv_on_list(files.w_list)
	elseif string.sub(msg, 0, 6) == "!rmva " then rmv_on_list(files.a_list)
	elseif msg == "!mod"  then modMode()
	elseif msg == "!mute" then muteMode()
	elseif msg == "!help" then help()--and tM == 1
	elseif msg == "!list" then list()--and tM == 1
	elseif msg == "test" and tM == 1 then test() -- test
	elseif muteFlag then if ts3.getClientSelfVariableAsString(sCHID, 0) ~= fUI then ts3.requestSendPrivateTextMsg(sCHID, s[2], fID) end
	elseif msg == "!stop" and tM == 1 then stop()
	elseif string.sub(msg, 0, 5) == "[URL]" and tM == 1 then urlPlay()
	elseif msg == "!random" and tM == 1 then randomPlay()
	elseif tM == 1 then tauntPlay()
	end
	return 0
end

-- test function
function test()
	ts3.requestSendPrivateTextMsg(sCHID,"asd", fID)
end

-- adds an ID to a list
function add_on_list(list)
	if string.len(msg) == 34 then
		if is_on_list(fUI, files.a_list) or ts3.getClientSelfVariableAsString(sCHID, 0) == fUI then
			if not is_on_list(string.sub(msg, - (string.len(msg) - 6)), list) then
				local fileHandle = io.open(PLUGIN_path .. list, "a")
				fileHandle:write(string.sub(msg, - (string.len(msg) - 6)) .. "\n")
				fileHandle:close()
				ts3.requestSendPrivateTextMsg(sCHID, s[4], fID)
			else
				ts3.requestSendPrivateTextMsg(sCHID, s[5], fID)
			end
		else
			ts3.requestSendPrivateTextMsg(sCHID, s[3], fID)
		end
	else
		ts3.requestSendPrivateTextMsg(sCHID, s[7], fID)
	end
end

-- remove an ID from a list
function rmv_on_list(list)
	if string.len(msg) == 34 then
		if is_on_list(fUI, files.a_list) or ts3.getClientSelfVariableAsString(sCHID, 0) == fUI then
			if is_on_list(string.sub(msg, -(string.len(msg) - 6)), list) then
				local fileHandle = io.open(PLUGIN_path .. list, "r")
				local tabby = {}
				for line in fileHandle:lines() do
					if line ~= string.sub(msg, -(string.len(msg) - 6)) then table.insert(tabby, line) end
				end
				fileHandle:close()
				fileHandle = io.open(PLUGIN_path .. list, "w")
				for c, ID in pairs(tabby) do
					fileHandle:write(ID .. "\n")
				end
				fileHandle:close()
				ts3.requestSendPrivateTextMsg(sCHID, s[6], fID)
			else
				ts3.requestSendPrivateTextMsg(sCHID, s[8], fID)
			end
		else
			ts3.requestSendPrivateTextMsg(sCHID, s[3], fID)
		end
	else
		ts3.requestSendPrivateTextMsg(sCHID, s[7], fID)
	end
end

-- function that switchs the modFlag
function modMode()
	if is_on_list(fUI, files.w_list) or is_on_list(fUI, files.a_list) or ts3.getClientSelfVariableAsString(sCHID, 0) == fUI then
		if modFLag then
			ts3.requestSendChannelTextMsg(sCHID, s[22], ts3.getChannelOfClient(sCHID, ts3.getClientID(sCHID)))
			modFLag = false
		else
			ts3.requestSendChannelTextMsg(sCHID, s[21], ts3.getChannelOfClient(sCHID, ts3.getClientID(sCHID)))
			modFLag = true
		end
	else
		ts3.requestSendPrivateTextMsg(sCHID, s[3], fID)
	end
end

-- mute / unmute the bot's sounds
function muteMode()
	if is_on_list(fUI, files.a_list) or ts3.getClientSelfVariableAsString(sCHID, 0) == fUI then
		if muteFlag then
			muteFlag = false
			io.popen(WINAMP_path .. ' "' .. PLUGIN_path .. files.on)
		else
			muteFlag = true
			io.popen("taskkill /IM chrome.exe*")
			io.popen(WINAMP_path .. ' "' .. PLUGIN_path .. files.off)
		end
	else
		ts3.requestSendPrivateTextMsg(sCHID, s[3], fID)
	end
end

-- prints the help message
function help()
	ts3.requestSendPrivateTextMsg(sCHID, s[9] .. '\n' .. s[10] .. '\n' .. s[11] .. '\n' .. s[12] .. '\n' .. s[24] .. '\n' .. s[14] .. '\n' .. s[15] .. '\n' ..  s[16] .. '\n' .. s[17] .. '\n' .. s[18] .. '\n' .. s[19] .. '\n' .. s[20] .. '\n' .. s[13] .. '\n' .. s[1], fID)
end

-- prints the list of taunts
function list()
	local text = ""
	for c, line in pairs(TAUNT_TABBY) do
		text = text .. " " .. line
		if string.len(text) > MAX_STRING_LEN then
			ts3.requestSendPrivateTextMsg(sCHID, text, fID)
			text = ""
			t1 = os.time() t2 = os.time()
			while os.difftime(t2, t1) < 1 do
				t2 = os.time()
			end
		end
	end
	--if not text == "" then
		ts3.requestSendPrivateTextMsg(sCHID, text, fID)
		text = ""
	--end
end

-- stops all sounds
function stop()
	if is_on_list(fUI, files.w_list) or is_on_list(fUI, files.a_list) or not modFLag then
		io.popen("taskkill /IM chrome.exe*")
		io.popen(WINAMP_path .. ' "' .. PLUGIN_path .. files.stop)
	else
		ts3.requestSendPrivateTextMsg(sCHID, s[3], fID)
	end
end

-- plays the web page
function urlPlay()
	if is_on_list(fUI, files.w_list) or is_on_list(fUI, files.a_list) or not modFLag then
		io.popen("taskkill /IM chrome.exe*")
		t1 = os.time() t2 = os.time()
		while os.difftime(t2, t1) < CHROME_WAIT_TIME do
			t2 = os.time()
		end
		io.popen('"' .. CHROME_path .. '" ' .. string.sub(string.sub(msg, -(string.len(msg) - 5)), 0, (string.len(msg) - 11)))
	else
		ts3.requestSendPrivateTextMsg(sCHID, s[3], fID)
	end
end

-- plays a random taunt
function randomPlay()
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
	msg = TAUNT_TABBY[math.random(0, table.maxn(TAUNT_TABBY))]
	ts3.requestSendPrivateTextMsg(sCHID, s[25] .. msg, fID)
	tauntPlay()
end

-- plays the taunt
function tauntPlay()
	local fileHandle = io.open(TAUNT_path .. msg .. ".mp3", "r")
	if fileHandle ~= nil then
		io.close(fileHandle)	
		if is_on_list(fUI, files.w_list) or is_on_list(fUI, files.a_list) or ts3.getClientSelfVariableAsString(sCHID, 0) == fUI or not modFLag then
			io.popen(WINAMP_path .. ' "' .. TAUNT_path .. msg .. '.mp3"')
		else
			ts3.requestSendPrivateTextMsg(sCHID, s[3], fID)
		end
	else
		if ts3.getClientSelfVariableAsString(sCHID, 0) ~= fUI then ts3.requestSendPrivateTextMsg(sCHID, s[23], fID) end
	end
end

-- checks if an ID is on a list (lines in a file)
function is_on_list(UniqueIdentifier, list)
	local fileHandle = io.open(PLUGIN_path .. list, "r")
	for line in fileHandle:lines() do
		if UniqueIdentifier == line then
			fileHandle:close()
			return true
		end
	end
	fileHandle:close()
	return false
end

-- events
--testmodule_events = {onTextmsgEvent = onTextmsgEvent}


testmodule_events = {
	MenuIDs = MenuIDs,
	moduleMenuItemID = moduleMenuItemID,
	onConnectStatusChangeEvent = onConnectStatusChangeEvent,
	onNewChannelEvent = onNewChannelEvent,
	onTalkStatusChangeEvent = onTalkStatusChangeEvent,
	onTextMessageEvent = onTextMessageEvent,
	onPluginCommandEvent = onPluginCommandEvent,
	onMenuItemEvent = onMenuItemEvent
}
