

--这里保存的是需要长期存储在用户设备中的数据

local GameConf = {
	["SmartEatHP"] = true,
	["SmartEatHPPercent"] = 60,
	["SmartEatMP"] = true,
	["SmartEatMPPercent"] = 60,
	["SmartLowHP"] = false,
	["SmartLowHPPercent"] = 10,
	["SmartLowHPItem"] = 32010002,
	["AutoPickEquip"] = true,
	["AutoPickEquipLevel"] = 10,--10-90等级，100-180转生等级(zslv*10+90)
	["AutoPickDrug"] = true,
	["AutoPickStaff"] = true,
	["AutoPickOther"] = true,
	["AutoPickCoin"] = true,
	["AutoRetrieve"] = false,

	["AutoBanyue"] = true,
	["AutoLiehuo"] = true,
	["AutoCiSha"] = true,
	["AutoShield"] = true,
	["AutoRoar"] = true,
	["AutoCall"] = true,
	["AutoLock"] = true,
	["AutoFightBack"] = false,
	["AutoHuoqiang"] = false,

	["VoiceInTime"] = false,
	["VoiceInTimeChannel"] = "",

	["ShieldEffect"] = false,
	["ShieldGuild"] = false,
	["ShieldPet"] = false,
	["ShieldMonster"] = false,
	["ShieldAllPlayer"] =false,
	["ShieldGSM"] = false,
	["ShieldGoHome"] = false,
	["SwitchMusic"] = false,
	["CloseTrade"] = false,
	["ShieldWing"] = false,
	["ShieldTitle"] = false,
	["SwitchEffect"] = false,
	["PerformanceModel"] = false,
	["ShieldAddFriend"] = false,
	["ShieldShadow"] = false,
	["GUIConfirm"] ={},
	["ChatRecord"] ={},

	["VoiceModel"]	=	"",
	["MicOnOrOff"]	= 	false,
	["SpkOnOrOff"]	= 	false,
	["VoiceAuthority"]	= 1,--1:"leader",2:freedom,

	["LastChrName"]	=	"",
	["SaveEnergy"] = false,
	["OpenRocker"] = true,
	["AutoHuiShou"] = 1,

	--技能设置保存
	["Skill1"] = false,
	["Skill2"] = false,
	["Skill3"] = false,
	["Skill4"] = false,
	["Skill5"] = false,
	["Skill6"] = false,
	["Skill7"] = false,
	["Skill8"] = false,

	["Medicine1"] = false,
	["Medicine2"] = false,
	["Medicine3"] = false,
	["Medicine4"] = false,

	--组队模式 1:自动组队 2:手动组队 3:拒绝组队
	["GroupType"] = 2,
	["ShieldRedWaring"] = false,

	["VoiceChannelNear"] = false,
	["VoiceChannelWorld"] = false,
	["VoiceChannelGroup"] = false,
	["VoiceChannelGuild"] = false,
}

local GameSetting = {}

GameSetting.Data=nil
GameSetting.LotteryList=nil
GameSetting.FriendList=nil
GameSetting.EnemyList=nil
GameSetting.BlackList=nil
GameSetting.DieRecords = nil
GameSetting.GongXunOpenAward=nil--功勋开箱子获得记录
local storeInfos = {
	["Data"]		= "userconf",
	["LotteryList"]	= "LotteryList",
	["FriendList"] = "FriendList",
	["EnemyList"] = "EnemyList",
	["BlackList"] = "BlackList",
	["DieRecords"] = "DieRecords",
	["GongXunOpenAward"] = "GongXunOpenAward",
}

function GameSetting.loadConfig()

	for k,v in pairs(storeInfos) do
		local content=cc.UserDefault:getInstance():getStringForKey(v, "")
		if content then
			if content and content ~= "" then
				local tempjson
				if k == "Data"then
					tempjson = cc.DataBase64:DecodeData(content)
				else
					tempjson = content
				end
				GameSetting[k]=GameUtilBase.decode(tempjson)
			end
		end
	end

	if not GameSetting.Data then
		GameSetting.Data = clone(GameConf)
	end
	print(GameSetting.Data)
	for k,v in pairs(GameSetting.Data) do
		-- if GameSetting.Data[k]==nil then
		-- 	GameSetting.Data[k]=GameConf[k]
		-- end

		-- local value
		-- if type(GameSetting.Data[k]) == "number" then
		-- 	value = GameSetting.Data[k]
		-- elseif GameSetting.Data[k] == false or GameSetting.Data[k] == nil then--false
		-- 	value = 0
		-- else--true
		-- 	value = 1
		-- end
		-- _G["G_"..k] = value

		GameSetting.setConf(k,v,true)
	end

	GameSetting.Data["GUIConfirm"] = {}
	-- GameSetting.Data["ChatRecord"] = {}
	GameSetting.save()
end

function GameSetting.getInfos(key, storeType)
	GameSetting[storeType] = GameSetting[storeType] or {}
	return GameSetting[storeType][key]
end

function GameSetting.setInfos(key, value, storeType)
	GameSetting[storeType] = GameSetting[storeType] or {}
	-- if storeType == "Data" then
	-- 	if GameConf[key] then
	-- 		GameSetting[storeType][key]=value
	-- 	end
	-- else
		GameSetting[storeType][key]=value
	-- end
end

function GameSetting.getConf(key)
	return GameSetting.getInfos(key, "Data")
end

function GameSetting_ShieldPet(type,pghost)
	-- if G_ShieldPet==1 then
	-- 	pghost:setShowHide(false)
	-- else
	-- 	pghost:setShowHide(true)
	-- end
end

function GameSetting_ShieldGuild(type,pghost)
	-- local mianavatar=CCGhostManager:getMainAvatar()
	-- GameCharacter._mainAvatar = GameCharacter._mainAvatar or CCGhostManager:getMainAvatar()
	if GameCharacter._mainAvatar and type~=GameConst.GHOST_THIS then
		if pghost:NetAttr(GameConst.net_guild_name)~="" and pghost:NetAttr(GameConst.net_guild_name) == GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name) then
			if G_ShieldPet==1 then
				pghost:setShowHide(false)
			else
				pghost:setShowHide(true)
			end
		end
	end
end

function GameSetting.setConf(key,value,nosave)
	if not nosave then
		GameSetting.setInfos(key, value, "Data")
	end

	local tempValue
	if type(value) == "number" then
		tempValue = value
	elseif value == false or value == nil then
		tempValue = 0
	else--true
		tempValue = 1
	end
	_G["G_"..key] = tempValue
	
	if key == "ShieldPet" then
		-- CCGhostManager:foreachGhosts("GameSetting_ShieldPet",GameConst.GHOST_SLAVE)
		CCGhostManager:setHideSlave(value and true or false)
	elseif key == "ShieldGuild" then
		-- CCGhostManager:foreachGhosts("GameSetting_ShieldGuild",GameConst.GHOST_PLAYER)
		CCGhostManager:setHideGuildPlayer(value and true or false)
	elseif key == "ShieldAllPlayer" then
		CCGhostManager:setHideAllPlayer(value and true or false)
	elseif key == "ShieldMonster" then
		-- CCGhostManager:setHideMonster(value and true or false)
		CCGhostManager:foreachGhosts("handleMonsterVisible", GameConst.GHOST_MONSTER)
	elseif key == "ShieldWing" then
		CCGhostManager:setHideWing(value and true or false)
	elseif key == "ShieldTitle" then
		CCGhostManager:setHidePlayerTitle(value and true or false)
		CCGhostManager:updatePlayerName()
	elseif key == "ShieldShadow" then
		CCGhostManager:setHideShadow(value and true or false)
	elseif key == "ShieldRedWaring" then
		if GUIMain then
			GUIMain.handleHPMPChange(event)
		end
	elseif key == "ShieldEffect" then
		CCGhostManager:setHideEffect(value and true or false)
	elseif key == "OpenRocker" then
		if GUIMain and GUIMain.m_layerRocker then
			GUIMain.m_layerRocker:setVisible(value and true or false)
		end
	elseif key == "SaveEnergy" then
		--print("set_fps",value,value and 40 or 60)
		--set_fps(value and 40 or 60)
		set_fps(60)
	elseif key == "SwitchMusic" then
		if value == true then
			if GameMusic then
				GameMusic.stop("music")
			end
		end
	--"SwitchEffect" 对应 函数play_effect_sound  G_SwitchEffect
	-- elseif key == "SwitchEffect" then

	end
end

function GameSetting.save(storeType)
	if not storeType then
		storeType = "Data"
	end
	
	local tempjson=GameUtilBase.encode(GameSetting[storeType])
	if tempjson then
		local enjson
		if storeType == "Data" then
			enjson = cc.DataBase64:EncodeData(tempjson)
		else
			enjson = tempjson
		end
		cc.UserDefault:getInstance():setStringForKey(storeInfos[storeType],enjson)
		cc.UserDefault:getInstance():flush()
	end
end

GameSetting.loadConfig()

return GameSetting