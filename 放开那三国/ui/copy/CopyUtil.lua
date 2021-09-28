-- Filename：	CopyUtil.lua
-- Author：		Cheng Liang
-- Date：		2013-7-10
-- Purpose：		副本工具类

module("CopyUtil", package.seeall)

require "script/model/DataCache"
require "script/utils/LuaUtil"
require "script/utils/TimeUtil"

isFirstPassCopy_1 = false 				-- 新手引导用


-- 最大副本id
function getMaxCopyId()
	require "db/DB_Copy"
	return table.count(DB_Copy.Copy)
end

-- 最大列传副本id
function getMaxHeroCopyId()
	require "db/DB_Hero_copy"
	print("table.count(DB_Hero_copy.Hero_copy)"..table.count(DB_Hero_copy.Hero_copy))
	return table.count(DB_Hero_copy.Hero_copy)
end

-- 获取普通副本的所有信息
function getNormalFortsInfoBy( copy_id )
	copy_id = tonumber(copy_id)
	local copys_info = DataCache.getNormalCopyData()
	local m_copy_info = nil
	for k,temp_info in pairs(copys_info) do
		if ( tonumber(temp_info.copy_id) == copy_id) then
			m_copy_info = temp_info
			break
		end
	end
	return m_copy_info
end

-- 获取普通副本的所有信息
function getHeroFortsInfoBy( copy_id )
	copy_id = tonumber(copy_id)
	local copys_info = DataCache.getHeroCopyData()
	local m_copy_info = nil
	-- for k,temp_info in pairs(copys_info) do
	-- 	if ( tonumber(temp_info.copy_id) == copy_id) then
			m_copy_info = copys_info[1]
	-- 		break
	-- 	end
	-- end
	return m_copy_info
end


-- 处理战斗后的副本更新
function hanleNewCopyData( allCopyData )
	if (allCopyData == nil) then
		return
	end

	if( allCopyData.normal ) then 
		local remoteNCopy = DataCache.getReomteNormalCopyData()
		for n_copyid, n_copydata in pairs(allCopyData.normal) do
			if(remoteNCopy[n_copyid] == nil) then
				-- require "script/ui/copy/ShowNewCopyLayer"
				-- ShowNewCopyLayer.showNewCopy( tonumber(n_copyid) )
				-- 将新的副本ID放在缓存中
				DataCache.setNewNormalCopyId(n_copyid)
			end
			
			-- 第一个副本通关
			if( tonumber(n_copyid) == 1 and n_copydata.va_copy_info and  n_copydata.va_copy_info.progress and n_copydata.va_copy_info.progress["1006"] and tonumber(n_copydata.va_copy_info.progress["1006"]) >=2 )  then
				local temp_copy = remoteNCopy["1"]
				if( temp_copy.va_copy_info and  temp_copy.va_copy_info.progress and temp_copy.va_copy_info.progress["1006"] and tonumber(temp_copy.va_copy_info.progress["1006"]) <2 )then

					isFirstPassCopy_1 = true
				end
			end
			remoteNCopy[n_copyid] = n_copydata
		end
		
		--副本星数有变化，更新天命可用星数
	    --added by Zhang Zihang
	    require "script/ui/destiny/DestinyData"
	    require "script/model/DataCache"
	    --通知天命星数改变
	    if DataCache.getSwitchNodeState(ksSwitchDestiny,false) then
	    	DestinyData.refreshStarNum(DataCache.getSumCopyStar())
	    end

		DataCache.setNormalCopyList(remoteNCopy)
	end
	if( allCopyData.elite ) then 
		DataCache.setEliteCopyData(allCopyData.elite)
	end
	if( allCopyData.activity ) then 
		DataCache.setActiveCopyData(allCopyData.activity)
	end
end

--[[
	@desc	副本宝箱字符串的解析
			类型|id|数量 （无id的填类型）

			0|2100002|555, 1|1|999, 2|2|888, 3|3|777, 4|910002|666

			多个物品或多个卡牌
			0|2100002|555, 0|2100003|444, 1|1|999, 2|2|888, 3|3|777, 4|910002|666, 4|910003|333
			0/1/2/3/4 物品/金币/银币/将魂/卡牌

	@para 	string
	@return table{ {type="", id="", num=""}, {...} }
--]]
local function parseBoxStringToTable(boxStr)
    local boxTable = {}
    require "script/utils/LuaUtil"
    local fTable = {}
    
    if(boxStr)then
    	--过滤空格
	    boxStr = string.gsub(boxStr, " ", "")
	    fTable = lua_string_split(boxStr, ",")
	end
    for k,t in pairs(fTable) do
        local sTable = lua_string_split(t, "|")
        if(#sTable == 3) then
            local tempT = {}
            tempT.type = tonumber(sTable[1])
            tempT.id = tonumber(sTable[2])
            tempT.num = tonumber(sTable[3])
            boxTable[#boxTable + 1] = tempT
        end
    end
    return boxTable
end

-- 处理副本奖励
function handleCopyRewardData( copyInfo )
	local stars_t 	= string.split(copyInfo.starlevel, ",")
	local copper_t 	= parseBoxStringToTable(copyInfo.ag_box)
	local silver_t 	= parseBoxStringToTable(copyInfo.au_box)
	local gold_t 	= parseBoxStringToTable(copyInfo.pt_box)
	

	return stars_t, copper_t, silver_t, gold_t
end

-- 0/1 未领取/领取 
function handleRewardStatus( prized_num )
	prized_num = tonumber(prized_num)
	local t_prized = {0, 0, 0}
	if (prized_num == 0) then
		t_prized = {0, 0, 0}
	elseif(prized_num == 1) then
		t_prized = {1, 0, 0}
	elseif(prized_num == 2) then
		t_prized = {0, 1, 0}
	elseif(prized_num == 3) then
		t_prized = {1, 1, 0}
	elseif(prized_num == 4) then
		t_prized = {0, 0, 1}
	elseif(prized_num == 5) then
		t_prized = {1, 0, 1}
	elseif(prized_num == 6) then
		t_prized = {0, 1, 1}
	elseif(prized_num == 7) then
		t_prized = {1, 1, 1}
	end
	return t_prized
end

function revertToPrizedNum( t_prized )
	local prized_num = 0
	if(t_prized[1] == 0 and t_prized[2] == 0 and t_prized[3] == 0) then
		prized_num = 0
	elseif(t_prized[1] == 1 and t_prized[2] == 0 and t_prized[3] == 0) then
		prized_num = 1
	elseif(t_prized[1] == 0 and t_prized[2] == 1 and t_prized[3] == 0) then
		prized_num = 2
	elseif(t_prized[1] == 1 and t_prized[2] == 1 and t_prized[3] == 0) then
		prized_num = 3
	elseif(t_prized[1] == 0 and t_prized[2] == 0 and t_prized[3] == 1) then
		prized_num = 4
	elseif(t_prized[1] == 1 and t_prized[2] == 0 and t_prized[3] == 1) then
		prized_num = 5
	elseif(t_prized[1] == 0 and t_prized[2] == 1 and t_prized[3] == 1) then
		prized_num = 6
	elseif(t_prized[1] == 1 and t_prized[2] == 1 and t_prized[3] == 1) then
		prized_num = 7
	end
	return prized_num
end

-- 
function handleBoxStatus(prized_num, curScore, stars_t)
	
	curScore = tonumber(curScore)
	
	local t_prized = handleRewardStatus( tonumber(prized_num) )
	local t_box = {0, 0, 0}
	if(t_prized[1] == 1) then
		t_box[1] = 3
	elseif(curScore >= tonumber(stars_t[1]))then
		t_box[1] = 2
	else
		t_box[1] = 1
	end

	if(stars_t[2])then
		if(t_prized[2] == 1) then
			t_box[2] = 3
		elseif(curScore >= tonumber(stars_t[2]))then
			t_box[2] = 2
		else
			t_box[2] = 1
		end
	end

	if(stars_t[3])then
		if(t_prized[3] == 1) then
			t_box[3] = 3
		elseif(curScore >= tonumber(stars_t[3]))then
			t_box[3] = 2
		else
			t_box[3] = 1
		end
	end
	return t_box
end

-- 某个副本是否通关 0可显示 1可攻击 2npc通关 3简单通关 4普通通关 5困难通关
function isCopyHadPassed( copyInfo )
	local passed = false
	
	-- print("copyInfo,afhdhfkahfkdfajkhjds")
	-- print_t(copyInfo)

	if( (not table.isEmpty(copyInfo)) and (not table.isEmpty(copyInfo.va_copy_info)) and (not table.isEmpty(copyInfo.va_copy_info.progress)) )then
		local p_count = 0
		for k,v in pairs(copyInfo.va_copy_info.progress) do
			--判断条件由1改为2
			--added by Zhang Zihang
			if(tonumber(v)>2)then
				p_count = p_count + 1
			end
		end
		if(p_count>=tonumber(copyInfo.copyInfo.base_sum))then
			passed = true
		end
	end

	return passed
end

-- 获得某个普通副本的信息
function getNormalInfoByCopyId( copy_id )
	copy_id = tonumber(copy_id)
	local copy_info = {}
	local normalCopy = DataCache.getReomteNormalCopyData()
	for k,v in pairs(normalCopy) do
		if( tonumber(v.copy_id) == copy_id )then
			copy_info = v
			if( table.isEmpty(copy_info.copyInfo) )then
				require "db/DB_Copy"
				copy_info.copyInfo = DB_Copy.getDataById(copy_id)
			end
			break
		end
	end
	return copy_info
end

-- 通过copyId 获得普通副本的表中信息
function getNormalCopyDBDataById( copy_id )
	local retData = nil
	require "db/DB_Copy"
	retData = DB_Copy.getDataById(copy_id)
	return retData
end

-- 某个副本是否通关
function isHadPassedByCopyId( copy_id )
	local copy_info = getNormalInfoByCopyId(copy_id)
	return isCopyHadPassed(copy_info)
end

-- 获得普通副本 最后一个通关副本的ID
function getLastPassedCopyId()
	local l_copyId = 0
	local normalCopy = DataCache.getReomteNormalCopyData()
	if( not table.isEmpty(normalCopy) )then
		local function keySort ( key_1, key_2 )
		   	return tonumber(key_1) > tonumber(key_2)
		end
		local allKeys = table.allKeys(normalCopy)
		table.sort( allKeys, keySort )
		for k, v_copyId in pairs(allKeys) do
			if(isHadPassedByCopyId(v_copyId))then
				l_copyId = v_copyId
				break
			end
		end
	end

	return l_copyId
end

-- 经验熊猫活动副本是否开启
function isHeroExpCopyOpen()

	local isOpen = false

	local h_copyId = 300004

	require "db/DB_Activitycopy"
	local h_copyInfo = DB_Activitycopy.getDataById(h_copyId)

	local start_time_arr = parseHeroTimeStr(h_copyInfo.start_time)
	local end_time_arr = parseHeroTimeStr(h_copyInfo.end_time)

	local cur_time = TimeUtil.getSvrTimeByOffset()
	local curDate = os.date("*t", cur_time)
	local wDay = tonumber(curDate.wday) -- 星期天为1
	for k,v in pairs(start_time_arr) do
		if(tonumber(k) == (wDay-1) )then
			local startStr = v
			local endStr = end_time_arr[k]
			local startTimeInterval = TimeUtil.getIntervalByTime(startStr)
			local endTimeInterval = TimeUtil.getIntervalByTime(endStr)
			if( cur_time>= startTimeInterval and  cur_time<=endTimeInterval)then
				isOpen = true
			else
				isOpen = false
			end

			break 
		end
	end

	return isOpen

end

-- 解析经验副本的时间
function parseHeroTimeStr( timeStr )
	local t_time_arr = string.split(timeStr, ",")
	local time_arr = {}
	for k,v in pairs(t_time_arr) do
		local t_arr = string.split(v, "|")
		time_arr[t_arr[1]] = t_arr[2]
	end

	return time_arr
end

-- 解析活动副本可使用物品攻打
function getCanDefeatItemTemplateIdBy( copy_id )
	copy_id = tonumber(copy_id)
	require "db/DB_Normal_config"
	local configInfo = DB_Normal_config.getDataById(1)
	local t_copy_arr = string.split(configInfo.moneyTreeAttack, ",")
	print_t(t_copy_arr)
	local item_tmpl_id = nil
	for k,v in pairs(t_copy_arr) do

		local t_arr = string.split(v, "|")
		print_t(t_arr)
		if( copy_id == tonumber(t_arr[1]) )then
			item_tmpl_id = tonumber(t_arr[2])
			break
		end
	end

	print("getCanDefeatItemTemplateIdBy...=", item_tmpl_id)

	return item_tmpl_id
end

-- 获得当前据点的进度
function getStrongholdProgress( copy_id, Stronghold_id )
	local normalCopy = DataCache.getReomteNormalCopyData()
	-- print("copy_id==", copy_id, " Stronghold_id==", Stronghold_id)
	-- print_table("normalCopy", normalCopy)
	return normalCopy["" .. copy_id].va_copy_info.progress["" .. Stronghold_id]
end

-- 某个精英副本的开启条件
function getOpenCondition( e_copy_id )
	local conditionName = ""

	require "db/DB_Elitecopy"
	local e_copyInfo_temp = DB_Elitecopy.getDataById(e_copy_id)
	if(isHadPassedByCopyId(e_copyInfo_temp.pre_copyid) )then
		local e_copyInfo = DB_Elitecopy.getArrDataByField("next_eliteid", e_copy_id)
		if(not table.isEmpty(e_copyInfo)) then
			local e_t = e_copyInfo[1]
			conditionName = e_t.name
		end
	else
		require "db/DB_Copy"
		local copyInfo = DB_Copy.getDataById(e_copyInfo_temp.pre_copyid)
		conditionName = copyInfo.name
	end
	return conditionName
end

function getOpenNCopyCondition(n_copyInfo)
	local condition_str = nil
	if( n_copyInfo.copyInfo.limit_level and n_copyInfo.copyInfo.limit_level>UserModel.getHeroLevel() )then
		condition_str = GetLocalizeStringBy("key_1130") .. n_copyInfo.copyInfo.limit_level .. GetLocalizeStringBy("key_2618")
	else
		require "db/DB_Copy"
		local copyDesc = DB_Copy.getDataById( tonumber(n_copyInfo.copy_id)-1 )
		condition_str = GetLocalizeStringBy("key_2561") .. copyDesc.name
	end
	return condition_str
end

-- 缓存副本和据点的对话信息
-- 副本
local dialog_copy_id_key = UserModel.getUserUid() .. "_copyDialogIds" 
-- 进入据点
local dialog_fort_id_key = UserModel.getUserUid() .. "_fortDialogIds"
-- 战斗胜利
local dialog_fort_vic_id_key = UserModel.getUserUid() .. "_fortVicDialogIds"
-- 战斗失败
local dialog_fort_fail_id_key = UserModel.getUserUid() .. "_fortFailDialogIds"

-- 副本的对话
function addHadDialogCopyId( copy_id )
	local dialog_copy_id_str = CCUserDefault:sharedUserDefault():getStringForKey(dialog_copy_id_key)
	if(dialog_copy_id_str == nil )then
		dialog_copy_id_str = "" .. copy_id
	else 
		dialog_copy_id_str = dialog_copy_id_str .. "," .. copy_id
	end
	CCUserDefault:sharedUserDefault():setStringForKey(dialog_copy_id_key, dialog_copy_id_str)
end

-- 该副本的对话是否展示过了
function isCopyIdHadDisplay( copy_id )
	copy_id = tonumber(copy_id)
	local isHad = false
	local dialog_copy_id_str = CCUserDefault:sharedUserDefault():getStringForKey(dialog_copy_id_key)
	if(dialog_copy_id_str)then
		local temp_arr = string.split(dialog_copy_id_str, ",")
		for k,v in pairs(temp_arr) do
			if(copy_id == tonumber(v)) then
				isHad = true
				break
			end
		end
	end
	
	return isHad
end

-- 据点的对话
function addHadDialogFortId( fort_id )
	local dialog_copy_id_str = CCUserDefault:sharedUserDefault():getStringForKey(dialog_fort_id_key)
	if(dialog_copy_id_str == nil )then
		dialog_copy_id_str = "" .. fort_id
	else 
		dialog_copy_id_str = dialog_copy_id_str .. "," .. fort_id
	end
	CCUserDefault:sharedUserDefault():setStringForKey(dialog_fort_id_key, dialog_copy_id_str)
end

-- 该据点的对话是否展示过了
function isFortIdHadDisplay( fort_id )
	fort_id = tonumber(fort_id)
	local isHad = false
	local dialog_copy_id_str = CCUserDefault:sharedUserDefault():getStringForKey(dialog_fort_id_key)
	if(dialog_copy_id_str)then
		local temp_arr = string.split(dialog_copy_id_str, ",")
		for k,v in pairs(temp_arr) do
			if(fort_id == tonumber(v)) then
				isHad = true
				break
			end
		end
	end
	
	return isHad
end

-- 据点的对话 -- 胜利
function addHadVicDialogFortId( fort_id )
	local dialog_copy_id_str = CCUserDefault:sharedUserDefault():getStringForKey(dialog_fort_vic_id_key)
	if(dialog_copy_id_str == nil )then
		dialog_copy_id_str = "" .. fort_id
	else 
		dialog_copy_id_str = dialog_copy_id_str .. "," .. fort_id
	end
	CCUserDefault:sharedUserDefault():setStringForKey(dialog_fort_vic_id_key, dialog_copy_id_str)
end

-- 该据点的对话是否展示过了 -- shengli
function isFortIdVicHadDisplay( fort_id )
	fort_id = tonumber(fort_id)
	local isHad = false
	local dialog_copy_id_str = CCUserDefault:sharedUserDefault():getStringForKey(dialog_fort_vic_id_key)
	if(dialog_copy_id_str and dialog_copy_id_str ~= "")then
		local temp_arr = string.split(dialog_copy_id_str, ",")
		for k,v in pairs(temp_arr) do
			if(fort_id == tonumber(v)) then
				isHad = true
				break
			end
		end
	end
	
	return isHad
end

-- 据点的对话 -- 失败
function addHadFailDialogFortId( fort_id )
	local dialog_copy_id_str = CCUserDefault:sharedUserDefault():getStringForKey(dialog_fort_fail_id_key)
	if(dialog_copy_id_str == nil )then
		dialog_copy_id_str = "" .. fort_id
	else 
		dialog_copy_id_str = dialog_copy_id_str .. "," .. fort_id
	end
	CCUserDefault:sharedUserDefault():setStringForKey(dialog_fort_fail_id_key, dialog_copy_id_str)
end

-- 该据点的对话是否展示过了 -- 失败
function isFortIdFailHadDisplay( fort_id )
	fort_id = tonumber(fort_id)
	local isHad = false
	local dialog_copy_id_str = CCUserDefault:sharedUserDefault():getStringForKey(dialog_fort_fail_id_key)
	if(dialog_copy_id_str)then
		local temp_arr = string.split(dialog_copy_id_str, ",")
		for k,v in pairs(temp_arr) do
			if(fort_id == tonumber(v)) then
				isHad = true
				break
			end
		end
	end
	
	return isHad
end

-- 副本新据点开起
-- 副本新据点开启的key
local fort_opened_id_key = UserModel.getUserUid() .. "_fort_opened_id_key"
-- 添加
function addOpenedFortId( fort_id )
	local dialog_copy_id_str = CCUserDefault:sharedUserDefault():getStringForKey(fort_opened_id_key)
	if(dialog_copy_id_str == nil )then
		dialog_copy_id_str = "" .. fort_id
	else 
		dialog_copy_id_str = dialog_copy_id_str .. "," .. fort_id
	end
	CCUserDefault:sharedUserDefault():setStringForKey(fort_opened_id_key, dialog_copy_id_str)
end

-- 该据点的对话是否展示过了 -- 开启
function isOpendHadDisplay( fort_id )
	fort_id = tonumber(fort_id)
	local isHad = false
	local dialog_copy_id_str = CCUserDefault:sharedUserDefault():getStringForKey(fort_opened_id_key)
	if(dialog_copy_id_str)then
		local temp_arr = string.split(dialog_copy_id_str, ",")
		for k,v in pairs(temp_arr) do
			if(fort_id == tonumber(v)) then
				isHad = true
				break
			end
		end
	end
	
	return isHad
end

--[[
	@desc	普通副本的回调
	@para 	void
	@return void
--]]
function getNormalCopyCallback( p_copy_data )
	DataCache.setNormalCopyData(p_copy_data)
end


-- 某个据点是否被击败
function isStrongHoldIsVict( stronghold_id )
	stronghold_id = tonumber(stronghold_id)
	local copyInfos = DataCache.getReomteNormalCopyData()
	local isVict = false
	if( not table.isEmpty(copyInfos))then
		for k,v in pairs(copyInfos) do
			local isFind = false
			if( not table.isEmpty(v.va_copy_info))then
				for k,v in pairs(v.va_copy_info.progress) do
					if(tonumber(k) == stronghold_id) then
						isFind = true
						if(tonumber(v)>=2)then
							isVict = true
						end
						break
					end
				end
			end
			if(isFind)then
				break
			end
		end
	end

	return isVict
end

-- 某个列传据点是否被击败
function isHeroStrongHoldIsVict( stronghold_id )
	stronghold_id = tonumber(stronghold_id)
	local copyInfos = DataCache.getReomteHeroCopyData()
	local isVict = false
	if( not table.isEmpty(copyInfos))then
		for k,v in pairs(copyInfos) do
			local isFind = false
			if( not table.isEmpty(v.va_copy_info))then
				for k,v in pairs(v.va_copy_info.progress) do
					if(tonumber(k) == stronghold_id) then
						isFind = true
						if(tonumber(v)>=2)then
							isVict = true
						end
						break
					end
				end
			end
			if(isFind)then
				break
			end
		end
	end

	return isVict
end

-- added by fang, for temp handling
local _bTmpStatus = false

local function getNormalCopyList( obj )
	require "script/battle/BattleLayer"
	if BattleLayer.isBattleOnGoing then
		return
	end
	if not _bTmpStatus then
		return
	end
	_bTmpStatus = false
	if obj ~= nil then
		obj:stopAllActions()
		obj:removeFromParentAndCleanup(true)
	end

	require "script/model/user/UserModel"
	local level = tonumber(UserModel.getAvatarLevel())
	local copyInfos = DataCache.getReomteNormalCopyData()
	if(table.isEmpty(copyInfos))then
		CopyService.ncopyGetCopyList(getNormalCopyCallback)
	else
		local maxCopyId = 0
		for k,t_info in pairs(copyInfos) do
			if(maxCopyId < tonumber(t_info.copy_id)) then
				maxCopyId = tonumber(t_info.copy_id)
			end
		end
		local hasNew = false
		require "db/DB_Copy"
		local copyDesc = DB_Copy.getDataById(maxCopyId)
		local allCopyData = getAllCopyInfo()
		local isNewOpen = false
		for k,v in pairs(allCopyData) do
			if( tonumber( v.id) > maxCopyId and v.limit_level and level<= tonumber(v.limit_level) ) then
				if(isStrongHoldIsVict(copyDesc.pre_baseid))then
					hasNew = true
					break
				end
			end
		end
		if(hasNew)then
			CopyService.ncopyGetCopyList(getNormalCopyCallback)
		end
	end
end

-- 升到某个等级处理新副本的开启
function handleNewCopyOpen( level )
	_bTmpStatus = true
	print("levellevellevellevellevellevel==", level)
	level = tonumber(level)
	require "script/battle/BattleLayer"
	if(BattleLayer.isBattleOnGoing)then
		-- 临时处理, added by fang.
		local tmpNode = CCNode:create()
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		if runningScene then
			local actions = CCArray:create()
			actions:addObject(CCDelayTime:create(0.3))
			actions:addObject(CCCallFuncN:create(getNormalCopyList))
			tmpNode:runAction(CCRepeatForever:create(CCSequence:create(actions)))
			runningScene:addChild(tmpNode)
		end
	else
		getNormalCopyList()
	end
end

-- 获取本地的数据
function getAllCopyInfo()
	require "db/DB_Copy"
	local tData = {}
	for k, v in pairs(DB_Copy.Copy) do
		table.insert(tData, v)
	end
	local allCopyData = {}
	for k,v in pairs(tData) do
		table.insert(allCopyData, DB_Copy.getDataById(v[1]))
	end
	tData = nil

	local function keySort ( goods_1, goods_2 )
	   	return tonumber(goods_1.id) > tonumber(goods_2.id)
	end
	table.sort( allCopyData, keySort )

	return allCopyData
end


-- 解析物品掉落
function parseItemDropString( dropString )
	print("dropString====", dropString)
    local boxTable = {}
	if(dropString) then
		dropString = string.gsub(dropString, " ", "")
    	local f_t = string.split(dropString, ",")
	    for k,t in pairs(f_t) do
	        local sTable = lua_string_split(t, "|")
	        if(#sTable >= 3) then
	            local tempT = {}
	            tempT[sTable[1]] = sTable[2]
	            if( tonumber(sTable[3])<= UserModel.getHeroLevel() )then
	            	boxTable[#boxTable + 1] = sTable[1]
	            end
	        else
	        	-- boxTable[#boxTable + 1] = tempT
	            boxTable[#boxTable + 1] = sTable[1]
	        end
	    end
	end
    return boxTable
end


-- 显示副本全局掉落
function showExtraReward( extra_reward )

	if(not table.isEmpty(extra_reward))then
		local showLayer = nil
		if( (not table.isEmpty(extra_reward.item)) and (not table.isEmpty(extra_reward.item)))then
			local item_num = 0
			local item_tmpl_id = 0
			for k,v in pairs(extra_reward.item) do
				item_tmpl_id = tonumber(k)
				item_num = tonumber(v)
				break
			end
			if(item_tmpl_id >= 100001 and item_tmpl_id <= 200000) then
				-- 装备
				require "db/DB_Item_arm"
				local equip_desc = DB_Item_arm.getDataById(template_id)
				if(equip_desc.jobLimit and equip_desc.jobLimit > 0)then
					-- 套装
					require "script/ui/item/SuitInfoLayer"
					showLayer = SuitInfoLayer.createLayer( item_tmpl_id,  nil, false, false, false, nil, nil, nil, -5001, 2)
				else
					-- 非套装
					require "script/ui/item/EquipInfoLayer"
					showLayer = EquipInfoLayer.createLayer( item_tmpl_id,  nil, false, false, false, nil, nil, nil, -5001, 2)
				end
				local runningScene = CCDirector:sharedDirector():getRunningScene()
				runningScene:addChild(showLayer, 10001)
			elseif(item_tmpl_id >= 400001 and item_tmpl_id <= 500000)then
				-- 武魂
				require "script/ui/copy/HeroFragInfoLayer"
				showLayer = HeroFragInfoLayer.createLayer(item_tmpl_id, item_num)
				local runningScene = CCDirector:sharedDirector():getRunningScene()
				runningScene:addChild(showLayer, 10001)
			elseif(item_tmpl_id >= 500001 and item_tmpl_id <= 600000) then
				require "script/ui/item/TreasureInfoLayer"
				local treasInfoLayer = TreasureInfoLayer:createWithTid(item_tmpl_id, TreasInfoType.BASE_TYPE)
				treasInfoLayer:show(-5001, 1010)
				treasInfoLayer:setTitleSprite("images/common/luck.png")
			else
				require "script/ui/bag/UseItemLayer"
				UseItemLayer.showDropResult(extra_reward, 5, nil, true)
			end
		else 
			require "script/ui/bag/UseItemLayer"
			UseItemLayer.showDropResult(extra_reward, 5, nil, true)
		end

		
	end
end


-- 据点得星条件
function getStarCondition( level, stronghold)
	local conditionInfo =  stronghold["star_condition_" .. level]
	local conditionStr = GetLocalizeStringBy("key_1089")
	if(conditionInfo)then
		local c_arr = string.split(conditionInfo, "|")
		if(not table.isEmpty(c_arr))then
			conditionStr = getStarConditionStr(c_arr[1], c_arr[2])
		end
	end


	return conditionStr
end
-- 文字显示
function getStarConditionStr( type, num )
	local t_str_arr = {}
	table.insert(t_str_arr, GetLocalizeStringBy("key_1581") .. num)
	table.insert(t_str_arr, GetLocalizeStringBy("key_3350") .. string.format("%.2f", num/10000)*100 .. "%")
	table.insert(t_str_arr, GetLocalizeStringBy("key_2240") .. num)
	table.insert(t_str_arr, GetLocalizeStringBy("key_1614") .. num)
	table.insert(t_str_arr, GetLocalizeStringBy("key_1230") .. num .. GetLocalizeStringBy("key_1920"))
	table.insert(t_str_arr, GetLocalizeStringBy("key_1230") .. num .. GetLocalizeStringBy("key_1083"))
	return t_str_arr[tonumber(type)]
end

-- 是否需要花费金币挑战摇钱树
function isFreeToAtkGoldTree( ... )
	---------------------------- 屏蔽金币攻打 ----------------------
	-- local retDat = true
	-- local goldAtkNum = DataCache.getAtkGoldTreeByUseGoldNum()
	-- local freeAtkNum = DataCache.getGoldTreeDefeatNum()
	-- if(goldAtkNum <= 0)then
	-- 	if(freeAtkNum <= 0)then
	-- 		return false
	-- 	else
	-- 		return true
	-- 	end
	-- else
	-- 	return false
	-- end
	--------------------------------------------------------------
	return true
end

-- 获取当前扫荡冷却时间所需的金币
function getGoldNumForSweepCd()
	require "db/DB_Normal_config"
	local data = DB_Normal_config.getDataById(1)
	local str = data.clearFightCdCost

	local data_arr = string.split(str, "|")

	local next_time = DataCache.getClearSweepNum() + 1

	local needGold = tonumber(data_arr[1]) + (next_time -1) * tonumber(data_arr[2])

	if(needGold>tonumber(data_arr[3]))then
		needGold = tonumber(data_arr[3])
	end

	return needGold
end

-- 根据Vip表获得自己能花金币挑战摇钱树的次数
function getMyselfAtkGoldTreeNum( ... )
	require "db/DB_Vip"
	local data = DB_Vip.getDataById(UserModel.getVipLevel()+1)
	print("---------- data:")
	print_t(data)
	print(data.moneyTreeCost)
	local costArr = string.split(data.moneyTreeCost, "|")
	print_t(costArr)
	local num = table.count(costArr)
	return num
end

-- 获得本次挑战需要花费的金币数量
function getAtkGoldTreeNeedByAtkNum( atkNum )
	require "db/DB_Vip"
	local data = DB_Vip.getDataById(UserModel.getVipLevel()+1)
	print("++++++ data:")
	print_t(data)
	print(data.moneyTreeCost)
	local costArr = string.split(data.moneyTreeCost, "|")
	print_t(costArr)
	local index = tonumber(atkNum) or 1
	local goldNum = tonumber(costArr[index])
	return goldNum
end

-- 某个据点的攻打次数
function isCopyFortCanDefeat( copy_id, fort_id )
	local copy_info = getNormalFortsInfoBy( copy_id )
	local isCan = false
	if(table.isEmpty(copy_info) == false )then
		for k,v in pairs(copy_info.va_copy_info.defeat_num) do
			if( tonumber(k) == tonumber(fort_id) )then
				if( tonumber(v) >0 )then
					isCan = true
				else
					isCan = false
				end
				break
			end
		end
	end

	return isCan
end

----------------------------------------- 副本特效 ----------------------------------------------------
--[[
	@des 	:得到当前副本的上层特效数组
	@param 	:p_copyId:副本id
	@return :table{ {effect_name,effect_posx,effect_posy} }
--]]
function getUpEffectByCopyId( p_copyId )
	local retData = {}
	require "db/DB_Copy"
	local copyData = DB_Copy.getDataById(p_copyId)
	if(copyData.effects_up == nil)then
		return retData
	end

	local effectArr = string.split(copyData.effects_up, ",")
	for i=1,#effectArr do
		local temp = string.split(effectArr[i], "|")
		local data = {}
		data.effect_name = temp[1]
		data.effect_posx = tonumber(temp[2])
		data.effect_posy = tonumber(temp[3])
		table.insert(retData,data)
	end
	return retData
end


--[[
	@des 	:得到当前副本的下层特效数组
	@param 	:p_copyId:副本id
	@return :table{ {effect_name,effect_posx,effect_posy} }
--]]
function getDownEffectByCopyId( p_copyId )
	local retData = {}
	require "db/DB_Copy"
	local copyData = DB_Copy.getDataById(p_copyId)
	if(copyData.effects_down == nil)then
		return retData
	end

	local effectArr = string.split(copyData.effects_down, ",")
	for i=1,#effectArr do
		local temp = string.split(effectArr[i], "|")
		local data = {}
		data.effect_name = temp[1]
		data.effect_posx = tonumber(temp[2])
		data.effect_posy = tonumber(temp[3])
		table.insert(retData,data)
	end
	return retData
end



