--commonFunc.lua
--公共函数写到这里
--------------------------------------------------------------------------------
debug = require "debug"
--[[
oldfunPrint_oldfunPrint_old = _G["print"];

--输出日志带上文件名和行号
function printlog_printlog(...)
	local info = debug.getinfo(2,"nSl");
	if info then
		local filename = "";
		local nIndex = string.find(info.short_src,".lua",1,true);
		local nIndexString = string.find(info.short_src,"string",1,true)
		if nIndex and nIndexString and nIndex > 1 and nIndexString > 1 then
			filename = string.sub(info.short_src,nIndexString + 6,nIndex);
			filename = string.gsub(filename,"%A","",20);
			filename = filename .. ".lua";
		end
		oldfunPrint_oldfunPrint_old(string.format("%s:%d",filename or "unknown",info.currentline or -1)..'/',...);
	else
		oldfunPrint_oldfunPrint_old(...);	
	end
end

_G["print"] = printlog_printlog;
--]]
function isMoneyEnough(player, moneyValue)
	if player and moneyValue and player:getMoney() >= moneyValue then
		return true
	end

	matNotEnough(player, 1, 0)
	return false
end

function costMoney(player, moneyValue, logType)
	if player and moneyValue and isMoneyEnough(player, moneyValue) then
		player:setMoney(player:getMoney() - moneyValue)
		g_logManager:writeMoneyChange(player:getSerialID(), '0', 1, logType, player:getMoney(), moneyValue, 2)
		return true
	end
	return false
end

function isIngotEnough(player, ingotValue)
	if player and ingotValue and player:getIngot() >= ingotValue then
		return true
	end

	matNotEnough(player, 2, 0)
	return false
end

function costIngot(player, ingotValue, logType)
	if player and ingotValue and isIngotEnough(player, ingotValue) then
		player:setIngot(player:getIngot() - ingotValue)
		g_logManager:writeMoneyChange(player:getSerialID(), '0', 3, logType, player:getIngot(), ingotValue, 2)
		return true
	end
	return false
end

function isMatEnough(player, matID, matNum)
	if not player or not matNum then
		return false
	end

	local itemMgr = player:getItemMgr()

	if not itemMgr then
		return false
	end

	if itemMgr:getItemCount(matID) >= matNum then
		return true
	end

	matNotEnough(player, 4, matID)
	return false
end

function costMat(player, matID, matNum, logType, isBind)
	if player and matID and matNum and isMatEnough(player, matID, matNum) then
		local itemMgr = player:getItemMgr()
		local errId = 0
		itemMgr:destoryItem(matID, matNum, errId)
		g_logManager:writePropChange(player:getSerialID(), 2 ,logType, matID, 0, matNum, isBind or 0)
		return true
	end
	return false
end

function matNotEnough(player, matType, matID)
	if not player then
		return
	end

	local ret = {}
	ret.matType = matType
	ret.matID = matID or 0
	fireProtoMessage(player:getID(), 5034, 'ItemNotEnoughProtocol', ret)
end

--解析特殊字符串如  "1093_40_61004_139_95"
function StrSplit(str, split)
	local strTab={}
	local sp=split or "&"
	local tb = {}
	while type(str)=="string" and string.len(str)>0 do
		local f=string.find(str,sp)
		local ele
		if f then
			ele=string.sub(str,1,f-1)
			str=string.sub(str,f+1)
		else
			ele=str
		end
		table.insert(tb, ele)
		if not f then break	end
	end
	return tb
end

--time1与time2间隔的天数，"2014-11-20 00:00:00"与"2014-11-19 23:59:59"间隔1天
function dayBetween(time1, time2, period)
	period = period or 0
	time1, time2 = time1 - period, time2 - period
	local date1, date2 = os.date("*t", time1), os.date("*t", time2)
	local day1, day2 = date1.yday, date2.yday
	if date1.year ~= date2.year then
		day1 = math.floor((time1 - period) / DAY_SECENDS)
		day2 = math.floor((time2 - period) / DAY_SECENDS)
	end
	return math.abs(day1 - day2)
end

function dropString(school, sex, dropID, timeLimit)
	local retStr = g_entityMgr:getDropString(school, sex, dropID)
	return unserialize(retStr)
end

function dropTable(retStr)
	--print(retStr)
	local item = {}
	local data = StrSplit(retStr, ";")
	item.count = #data
	item.list = {}
	local ingot = 0
	local bindIngot = 0
	for i = 1, item.count do
		local tab = StrSplit(data[i], " ")
		local tmp = {}
		tmp.itemID = tonumber(tab[1])
		if tmp.itemID == 222222 then
			ingot = 1
		end
		if tmp.itemID == 888888 then
			bindIngot = 1
		end
		tmp.count = tonumber(tab[2])
		tmp.bind = tonumber(tab[3])
		tmp.strength = tonumber(tab[4])
		tmp.slot = tonumber(tab[5])
		item.list[i] = tmp
	end
	item.value = ingot + bindIngot
	--print(toString(item))
	return item
end

--时间格式的结束时间
function endTime(str)
	local t = os.time()
	if onSall(str, t) then
		
	else
		return 0
	end
end

--商店上下架时间格式
function onSall(str, t)
	function tCheck(str, t)
		function tMatchBlank(str, t)
			function tMatchSlash(str, t)
				local l = 0
				local r = 0
				local tar = 0
				if string.find(t, ":") == nil then
					-- 1997-2015
					if string.find(str, "-") == nil then
						l = tonumber(str)
						r = l
					else
						local data = StrSplit(str, "-")
						l = tonumber(data[1])
						r = tonumber(data[2])
					end
					tar = tonumber(t)
				else
					local data = StrSplit(t, ":")
					tar = tonumber(data[1]) * 3600 + tonumber(data[2]) * 60 + tonumber(data[3])
					if string.find(str, "-") == nil then
						data = StrSplit(str, ":")
						l = tonumber(data[1]) * 3600 + tonumber(data[2]) * 60 + tonumber(data[3])
						r = l
					else
						local slash = StrSplit(str, "-")
						data = StrSplit(slash[1], ":")
						l = tonumber(data[1]) * 3600 + tonumber(data[2]) * 60 + tonumber(data[3])
						data = StrSplit(slash[2], ":")
						r = tonumber(data[1]) * 3600 + tonumber(data[2]) * 60 + tonumber(data[3])
					end
				end
				--print(tar)
				--print(l)
				--print(r)
				if tar >= l and tar <= r then
					return true
				else
					return false
				end
			end

			if str == "*" then
				return true
			end
			local data = StrSplit(str, " ")
			if not str then
				print("时间配置错误", debug.traceback())
				return false
			end
			if string.find(str, " ") == nil then
				data[1] = str
			end
			local index = 1;
			while (data[index]) do
				if tMatchSlash(data[index], t) == true then
					return true
				end
				index = index + 1
			end
			return false
		end

		local data = StrSplit(str, ",")
		if tMatchBlank(data[1], os.date("%Y", t)) == false then
			return false
		end
		if tMatchBlank(data[2], os.date("%m", t)) == false then
			return false
		end
		if tMatchBlank(data[3], os.date("%d", t)) == false then
			return false
		end
		if tMatchBlank(data[4], os.date("%w", t)) == false then
			return false
		elseif data[6] then
			--开服天数值必须大于data[6]
			if dayBetween(os.time(), g_frame:getStartTick()) + 1 <= tonumber(data[6]) then
				return false
			end
		end
		if tMatchBlank(data[5], os.date("%X", t)) == false then
			return false
		end
		return true
	end

	if str == "A" then
		return false
	end
	
	if str == "B" then
		return true
	end
	
	local data = StrSplit(str, ";")
	if string.find(str, ";") == nil then
		data[1] = str
	end
	local index = 1
	while (data[index]) do
		if tCheck(data[index], t) == true then
			return true
		end
		index = index + 1
	end
	return false
end

function table.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, _copy(getmetatable(object)))
    end
    return _copy(object)
end

--改变玩家属性
function changPlayerProp(player, proto, isAdd)
    if not proto then  
        return
    end

	local param = isAdd and 1 or -1

    if proto.q_attack_min then
	    player:setMinAT(player:getMinAT() + param * tonumber(proto.q_attack_min))
    end
    if proto.q_attack_max then
	    player:setMaxAT(player:getMaxAT() + param * tonumber(proto.q_attack_max))
    end
    if proto.q_magic_attack_min then
	    player:setMinMT(player:getMinMT() + param * tonumber(proto.q_magic_attack_min))
    end
    if proto.q_magic_attack_max then
	    player:setMaxMT(player:getMaxMT() + param * tonumber(proto.q_magic_attack_max))
    end
    if proto.q_sc_attack_min then
	    player:setMinDT(player:getMinDT() + param * tonumber(proto.q_sc_attack_min))
    end
    if proto.q_sc_attack_max then
	    player:setMaxDT(player:getMaxDT() + param * tonumber(proto.q_sc_attack_max))
    end
    if proto.q_defence_min then
	    player:setMinDF(player:getMinDF() + param * tonumber(proto.q_defence_min))
    end
    if proto.q_defence_max then
	    player:setMaxDF(player:getMaxDF() + param * tonumber(proto.q_defence_max))
    end
    if proto.q_magic_defence_min then
	    player:setMinMF(player:getMinMF() + param * tonumber(proto.q_magic_defence_min))
    end
    if proto.q_magic_defence_max then
	    player:setMaxMF(player:getMaxMF() + param * tonumber(proto.q_magic_defence_max))
    end
    if proto.q_hit then
	    player:setHit(player:getHit() + param * tonumber(proto.q_hit))
    end
    if proto.q_dodge then
	    player:setDodge(player:getDodge() + param * tonumber(proto.q_dodge))
    end
    if proto.q_crit then
	    player:setCrit(player:getCrit() + param * tonumber(proto.q_crit))
    end
    if proto.q_att_dodge then
	    player:setADodge(player:getADodge() + param * tonumber(proto.q_att_dodge))
    end
    if proto.q_mac_dodge then
	    player:setMDodge(player:getMDodge() + param * tonumber(proto.q_mac_dodge))
    end
    if proto.q_luck then
		player:setLuck(player:getLuck() + param * tonumber(proto.q_luck))
    end
    if proto.q_max_hp then
	    player:setMaxHP(player:getMaxHP() + param * tonumber(proto.q_max_hp))
    end
    if proto.q_max_mp then
	    player:setMaxMP(player:getMaxMP() + param * tonumber(proto.q_max_mp))
    end
    if proto.q_attack_speed then
	    player:setAtSpeed(player:getAtSpeed() + param * tonumber(proto.q_attack_speed))
    end
    if proto.q_propper then
	    player:setPropPercent(player:getPropPercent() + param * tonumber(proto.q_propper))
    end
end


COMMON_DATA_ID_TOLAL_ADORE_ZHONG = 1 		--膜拜中州王数据
LAST_WEEK_GLAMOUR_NO_ONE = 2 				--上周魅力排行榜第一名
COMMON_DATA_ID_TOLAL_ADORE_SHA = 3 			--膜拜沙巴克城主数据
COMMON_DATA_ID_MAX_ACTIVITY_ID = 4			--运营活动当前最大活动ID
MALL_ALL_LIMIT = 5 							--商城全服限购数据
COMMON_DATA_ID_FACTION_COPY = 6 			--行会副本数据
COMMON_DATA_ID_MANOR_REWARD = 7 			--领地战每日奖励数据
COMMON_DATA_ID_FACTION_STATUE_RD = 8 		--魔神雕像捐献记录
COMMON_DATA_ID_PVPRANK_FIRST = 10 			--竞技场排名第一的SID
COMMON_DATA_ID_WORLD_NO1	= 11			--天下第一数据
COMMON_DATA_ID_FACTION_COPY_SETOPEN = 12  	--行会副本定时开启
COMMON_DATA_ID_FUN_SWITCH = 13  			--系统开关数据
COMMON_DATA_ID_WORLDBOSS = 14 				--世界boss存活状况
COMMON_DATA_ID_PAOMADENG = 15 				--跑马灯数据
COMMON_DATA_ID_WINPOP = 16	 				--系统弹窗数据
COMMON_DATA_ID_OFFLINE_REMOVEFAC_BUFF = 17	--离线离会BUFF
COMMON_DATA_ID_DART_REWARD = 18             --镖车离线奖励
COMMON_DATA_ID_MASTER_TASK = 19				--师徒任务当天的任务
COMMON_DATA_ID_FACAREA_FIRE = 20			--行会篝火时间戳保存
COMMON_DATA_ID_MYSTSHOP = 21 				--神秘商店商品数据
COMMON_DATA_ID_OFFLINEGIFT = 22				--qq微信好友离线礼物
COMMON_DATA_ID_FACTION_EVENT = 23			--军机处数据
--更新公共数据
function updateCommonData(dataID, dataValue)
	dataValue= serialize(dataValue)
	--[[local params =
	{
		{
		wId = g_frame:getWorldId(),
		_dataID  = dataID,
		_dataValue  = dataValue,
		spName = "sp_UpdateCommonData",
		dataBase = 1,
		sort = "wId,_dataID,_dataValue",
		}
	}		
	local operationID = apiEntry.exeSP(params, true)]]
	g_entityDao:updateCommonData(dataID,dataValue,g_frame:getWorldId())
end

--加载公共数据
function loadCommonData()
	--[[local params = {
		{
			wId  = g_frame:getWorldId(),
			spName = "sp_LoadCommonData",
			dataBase = 1,
			sort = "wId",
		}
	}
	LuaDBAccess.callDB(params, onloadCommonData)]]
	g_entityDao:loadCommonData(g_frame:getWorldId())
end

--加载公共数据回调
function onloadCommonData(dataid,dataValue)	
	--if data[1] then
	--	for _,v in pairs(data[1] or {}) do
	if dataid == COMMON_DATA_ID_TOLAL_ADORE_ZHONG then
		g_adoreMgr:onLoadZhongData(dataValue)
	elseif dataid == LAST_WEEK_GLAMOUR_NO_ONE then
		g_RankMgr:setLastWeekOnOne(dataValue)
	elseif dataid == COMMON_DATA_ID_TOLAL_ADORE_SHA then
		g_adoreMgr:onLoadShaData(dataValue)
	elseif dataid == COMMON_DATA_ID_MAX_ACTIVITY_ID then
		g_ActivityMgr:setMaxActiviytID(dataValue)
	elseif dataid == MALL_ALL_LIMIT then
		g_tradeMgr:setAllLimitData(dataValue)
	elseif dataid == COMMON_DATA_ID_FACTION_COPY then
		g_FactionCopyMgr:onLoadFactionCopyData(dataValue)
	elseif dataid == COMMON_DATA_ID_MANOR_REWARD then
		g_manorWarMgr:onLoadRewardData(dataValue)
	elseif dataid == COMMON_DATA_ID_FACTION_STATUE_RD then
		g_factionMgr:onLoadStatueRdData(dataValue)
	elseif dataid == COMMON_DATA_ID_PVPRANK_FIRST then
		--g_sinpvpMgr:setTopThreeRankInfo(dataValue)
	elseif dataid == COMMON_DATA_ID_WORLD_NO1 then
		g_RankMgr:onLoadWorldNO1(dataValue)
	elseif dataid == COMMON_DATA_ID_FACTION_COPY_SETOPEN then		--行会副本定时开启
		g_FactionCopyMgr:onLoadFactionCopyOpenData(dataValue)		
	elseif dataid == COMMON_DATA_ID_FUN_SWITCH then		--行会副本定时开启
		g_gameSwitchMgr:onLoadFunSwitchData(dataValue)		
	elseif dataid == COMMON_DATA_ID_WORLDBOSS then
		g_WorldBossMgr:onloadWorldBossRelive(dataValue)
	elseif dataid == COMMON_DATA_ID_PAOMADENG then
		g_dealLoopMsg:onloadLoopMsg(dataValue)
	elseif dataid == COMMON_DATA_ID_WINPOP then
		g_windowPop:onloadWindowPop(dataValue)
	elseif dataid == COMMON_DATA_ID_OFFLINE_REMOVEFAC_BUFF then
		g_factionMgr:onloadRemoveBuff(dataValue)
	elseif dataid == COMMON_DATA_ID_DART_REWARD then 
		g_commonMgr:onloadDartOffReward(dataValue)
	elseif dataid == COMMON_DATA_ID_MASTER_TASK then
		g_masterMgr:loadNowTaskID(dataValue)
	elseif dataid == COMMON_DATA_ID_FACAREA_FIRE then 
		g_factionAreaManager:loadAreaStamp(dataValue)
	elseif dataid == COMMON_DATA_ID_MYSTSHOP then
		g_mystShopMgr:onloadMystShopData(dataValue)
	elseif dataid == COMMON_DATA_ID_OFFLINEGIFT then
		g_relationMgr:onloadOfflineGift(dataValue)
	elseif dataid == COMMON_DATA_ID_FACTION_EVENT then
		g_factionMgr:onloadFactionEvent(dataValue)
	end
end

--通知掉落ID给玩家奖励,emailID是邮件文案ID
function rewardByDropID(roleSID, dropID, emailID, source)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		local itemMgr = player:getItemMgr()
		if itemMgr then
			local ecode = 0
			local rewardData = itemMgr:addItemByDropList(Item_BagIndex_Bag, dropID, source, ecode)	--普通奖励
			--包裹不足就走邮件
			if rewardData == "-1" then
				g_copySystem:fireMessage(0, player:getID(), EVENT_COPY_SETS, 7, 0)
				rewardData = g_entityMgr:dropItemToEmail(roleSID, dropID, emailID, source, ecode)
				return false, rewardData
			end
			return true, rewardData
		end
	end
	return false, rewardData
end

--获取某个地图的随机位置
function getRandPosInMap(mapID)
	local scene = g_sceneMgr:getPublicScene(mapID)
	if not scene then
		return false
	end
	
	local sceneSize = scene:getSize()

	for i=1, 200 do
		local x = math.floor(math.rand(1,sceneSize.x))
		local y = math.floor(math.rand(1,sceneSize.y))
		if g_sceneMgr:posValidate(mapID, x, y) then
			return true, x, y
		end
	end
	
	return false
end

--获取地图某点的某个范围内的随机有效点
function getRandPosInCentre(mapID, posX, posY, radius)
	local scene = g_sceneMgr:getPublicScene(mapID)
	if not scene then
		return posX, posY
	end
	
	local sceneSize = scene:getSize()

	for i=1, 200 do
		local flag = -1
		local flagRand = math.rand(1,2)
		if flagRand == 2 then
			flag = 1
		end
		local x = posX + flag*math.random(1,radius)
		local y = posY + flag*math.random(1,radius)
		if g_sceneMgr:posValidate(mapID, x, y) then
			return x, y
		end
	end
	
	return posX, posY
end

--给玩家加经验
--Tlog[PlayerExpFlow] reason为 int
function addExpToPlayer(player,exp,reason,subReason)
	local beforelv = player:getLevel()
	player:setXP(player:getXP() + exp)	
	local afterlv = player:getLevel()
	if beforelv ~= afterlv then
		local nSubReason = subReason or 0
		g_tlogMgr:TlogPlayerExpFlow(player,exp,beforelv,afterlv,0,reason,nSubReason)
	end
	g_RankMgr:onExpChanged(player)
end

-- 是否是同一天
function isSameDay(time1, time2)
	local date1 = os.date("*t", time1)
	local date2 = os.date("*t", time2)

	if date1.year == date2.year and date1.yday == date2.yday then
		return true
	else
		return false
	end
end


--判断2个坐标点是否靠近,防外挂
function isNearPos(player, mapID, posX, posY)
	if not player then
		return false
	end

	local pos = player:getPosition()
	if mapID ~= player:getMapID() then
		return false
	end

	if math.abs(pos.x - posX) > 3 or math.abs(pos.y - posY) > 3 then
		return false
	end

	return true
end

function smelterRewardEquip(player, itemList)
	if not player or not itemList then return end
	local itemMgr = player:getItemMgr()
	if not itemMgr then return end

	local rewardEquip = SmelterRewardEquipInfo:new()
	for i,v in pairs(itemList or {}) do
		if v and v[1] and v[2] then
			if v[1] > 0 and v[2] > 0 then
				rewardEquip:addSmelterRewardEquip(v[1], v[2])
			end
		end
	end
	
	if rewardEquip:getSmelterRewardEquipNum() > 0 then
		itemMgr:equipSmelterByReward(rewardEquip)
	end
	rewardEquip:delete()
end