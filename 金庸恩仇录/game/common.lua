require("data.data_langinfo")
local common = {}
local crypto = require(cc.PACKAGE_NAME .. ".crypto")
local json = require(cc.PACKAGE_NAME .. ".json")

function common:trim(s)
	return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

function common:fill(s, ...)
	local o = tostring(s)
	for i = 1, select("#", ...) do
		o = o:gsub("#v" .. i .. "#", tostring(select(i, ...)))
	end
	return o
end

function common:yuan3(condition, param1, param2)
	if condition == true then
		return param1
	else
		return param2
	end
end

function common:getLanguageString(key, ...)
	local k = key:gsub("@", "")
	if Language[k] then
		return self:fill(Language[k], ...)
	else
		return key
	end
end

function common:getLanguageChineseType()
	if TargetPlatForm == PLATFORMS.VN then
		return false
	else
		return true
	end
end

function common:getLanguageCoin(coin)
	local tag_Money = common:getLanguageString("@MoneySign", coin)
	if TargetPlatForm and TargetPlatForm == PLATFORMS.VN and (CurrentPayWay ~= nil and CurrentPayWay ~= "" and CurrentPayWay == "appstore_nv" or VERSION_CHECK_DEBUG == false and SHEN_BUILD == true) then
		tag_Money = common:getLanguageString("@MoneyDollar", coin - 0.01)
	end
	return tag_Money
end

function common:getServerInfoByIdx(serverlist, idx)
	for i, v in ipairs(serverlist) do
		if v.idx == idx then
			v.index = i
			return v
		end
	end
end

function common:getLoginUrl()
	local _loginUrl = NewServerInfo.ANDROID_LOGIN_SERVER
	if device.platform == "ios" and (CSDKShell.getYAChannelID() == CHANNELID.IOS_APP_HANS or CSDKShell.getYAChannelID() == CHANNELID.IOS_EW_APP_HANS) then
		_loginUrl = NewServerInfo.IOS_LOGIN_SERVER
	end
	if SHEN_BUILD == true then
		if device.platform == "ios" and (CSDKShell.getYAChannelID() == CHANNELID.IOS_APP_HANS or CSDKShell.getYAChannelID() == CHANNELID.IOS_EW_APP_HANS) then
			_loginUrl = NewServerInfo.IOS_SHEN_SERVER
		else
			_loginUrl = NewServerInfo.ANDROID_SHEN_SERVER
		end
	end
	if DEV_BUILD == true then
		_loginUrl = NewServerInfo.DEV_LOGIN_SERVER
	elseif YUN_BUILD == true then
		_loginUrl = NewServerInfo.YUN_LOGIN_SERVER
	end
	local bIndex, _ = string.find(_loginUrl, "/", 8)
	if bIndex then
		_loginUrl = string.sub(_loginUrl, 1, bIndex - 1)
	end
	dump(_loginUrl)
	return _loginUrl
end

function common:isEncodedContents(contents)
	return string.sub(contents, 1, string.len(ENCODESIGN)) == ENCODESIGN
end

function common:decode(fileContents, secretKey)
	local contents = string.sub(fileContents, string.len(ENCODESIGN) + 1)
	local j = json.decode(contents)
	if type(j) ~= "table" then
		printError("GameState.decode_() - invalid contents")
		return {
		errorCode = GameState.ERROR_INVALID_FILE_CONTENTS
		}
	end
	local hash, s = j.h, j.s
	local testHash = crypto.md5(s .. secretKey)
	if testHash ~= hash then
		printError("GameState.decode_() - hash miss match")
		return {
		errorCode = GameState.ERROR_HASH_MISS_MATCH
		}
	end
	local values = json.decode(s)
	if type(values) ~= "table" then
		printError("GameState.decode_() - invalid state data")
		return {
		errorCode = GameState.ERROR_INVALID_FILE_CONTENTS
		}
	end
	return {values = values}
end

function common:muzzleChat(m_msg)
	local versionUrl = NewServerInfo.BI_URL
	if VERSION_CHECK_DEBUG == true then
		versionUrl = NewServerInfo.DEV_BI_URL
	end
	local adminchatUrl = versionUrl .. "/user.php"
	local function request()
		NetworkHelper.request(adminchatUrl, {
		ac = "jfaddclient",
		chnid = game.player.m_zoneID,
		serid = tostring(game.player.m_serverID),
		role_name = game.player.m_name,
		content = m_msg
		}, function (data)
			dump(data)
		end,
		"GET")
	end
	if SHEN_BUILD == false then
		request()
	end
end

function common:checkSensitiveWord(msg)
	local filename = string.gsub(device.writablePath, "[\\\\/]+$", "") .. device.directorySeparator .. "chatPingbi.json"
	if io.exists(filename) then
		local contents = io.readfile(filename)
		if SECRETKEY and common:isEncodedContents(contents) then
			local d = common:decode(contents, SECRETKEY)
			if d.errorCode then
				return false
			end
			values = d.values
		else
			values = json.decode(contents)
			if type(values) ~= "table" then
				printError("GameState.load() - invalid data")
				return false
			end
		end
		for i, v in ipairs(values) do
			local itemArray = string.split(v.content, "\r\n")
			for _, var in ipairs(itemArray) do
				if var ~= "" then
					dump(msg .. "=====" .. var .. "===")
					local contian = string.find(msg, var)
					if contian ~= nil then
						dump("不等于nil")
						return true
					end
				end
			end
		end
	end
	return false
end

function common:insertOrder(orderItem)
	local orderList = game.player.m_orderList or {}
	table.insert(orderList, orderItem)
end

function common:reSetButtonState(node, value)
	local btnState = {
	CCControlStateNormal,
	CCControlStateHighlighted,
	CCControlStateDisabled,
	CCControlStateSelected
	}
	for k, state in pairs(btnState) do
		if node ~= nil and node:getParent() ~= nil then
			node:setTitleForState(value, state)
		end
	end
end

function common:getIntPart(x)
	if x <= 0 then
		return math.ceil(x)
	end
	if math.ceil(x) == x then
		x = math.ceil(x)
	else
		x = math.ceil(x) - 1
	end
	return x
end

return common