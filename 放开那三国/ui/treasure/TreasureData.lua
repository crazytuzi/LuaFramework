-- Filename: TreasureData...lua
-- Author: lichenyang
-- Date: 2013-11-2
-- Purpose: 宝物数据处理层

module("TreasureData", package.seeall)

require "script/ui/bag/RuneData"

seizerInfoData = nil

function clean( ... )
	dataCache = nil
end

--[[
	@des   	:得到碎片总数
	@param  :fragment_type  碎片类型。--1：名马 --2：名书 --3：名兵(暂无，预留) --4：珍宝(暂无，预留)
	@return	:碎片数量
]]
function getFragmentCount( fragment_type )
	require "db/DB_Item_treasure_fragment"
	if(seizerInfoData.frag == nil) then
		print("fragment server info is nil")
		return 0
	end
	local fragmentCount = 0
	for k,v in pairs(seizerInfoData.frag) do
		local fragmentInfo = DB_Item_treasure_fragment.getDataById(v.frag_id)
		if(tonumber(fragmentInfo.type) == tonumber(fragment_type)) then
			fragmentCount = fragmentCount + tonumber(v.frag_num)
		end
	end
	return fragmentCount
end

--[[
	@des   	:得到碎片数量
	@param  :fragment_tid  碎片模板id
	@return	:碎片数量
]]
function getFragmentNum( fragment_tid )
	if( table.isEmpty(seizerInfoData) or seizerInfoData.frag == nil) then
		print("fragment server info is nil")
		return 0
	end
	for k,v in pairs(seizerInfoData.frag) do
		if(tonumber(v.frag_id ) == tonumber(fragment_tid)) then
			return tonumber(v.frag_num)
		end
	end
	print("don't find " .. " zhis fragment in cache data");
	return 0
end

--[[
	@des   	:得到碎片详情
	@param  :fragment_tid  碎片模板id
	@return	:
	fragmentInfo:{	
		tid，
		desc,
		name,
		num
	}
]]
function getFragmentInfo( fragment_tid )
	require "db/DB_Item_treasure_fragment"
	local fragmentInfo = {}

	local tableInfo = DB_Item_treasure_fragment.getDataById(fragment_tid)
	fragmentInfo.tid 		= fragment_tid
	fragmentInfo.desc		= tableInfo.info
	fragmentInfo.name		= tableInfo.name
	fragmentInfo.quality	= tableInfo.quality
	fragmentInfo.num		= getFragmentNum(fragment_tid)
	return fragmentInfo
end

--[[
	@des   	:得到碎片数量
	@param  :treasure_type 宝物类型 --1：名马 --2：名书 --3：名兵(暂无，预留) --4：珍宝(暂无，预留)
	@return	:table{treasureId, ...} 
]]
function getTreasureList(treasure_type)
	require "db/DB_Loot"
	require "db/DB_Item_treasure"
	local lootInfo = DB_Loot.getDataById(1)
	local treasureInfos = {}
	--基本宝物，没有碎片也要现实
	local baseTreasures = lua_string_split(lootInfo.baseTreasures,",")
	for k,v in pairs(baseTreasures) do
		local treasureInfo = DB_Item_treasure.getDataById(v)
		if(tonumber(treasureInfo.type) == tonumber(treasure_type)) then
			table.insert(treasureInfos, tonumber(v))
		end
	end
	--碎片对应的宝物
	require "db/DB_Item_treasure_fragment"
	for k,v in pairs(seizerInfoData.frag) do
		if(tonumber(v.frag_num) >  0) then
			local fragmentInfo = DB_Item_treasure_fragment.getDataById(v.frag_id)
			local isHave = false
			for i=1,#treasureInfos do
				if(tonumber(treasureInfos[i]) == tonumber(fragmentInfo.treasureId)) then
					isHave = true
				end
			end
			if(isHave == false) then
				local fragmentInfo = DB_Item_treasure_fragment.getDataById(v.frag_id)
				print("fragmentInfo.type", 	fragmentInfo.type)
				print("treasure_type", treasure_type)
				if(tonumber(fragmentInfo.type) == tonumber(treasure_type)) then
					table.insert(treasureInfos, tonumber(fragmentInfo.treasureId))
				end
			end
		end
	end
	return treasureInfos
end

--[[
	@des   	:通过宝物id得到宝物对应的碎片
	@param  :void
	@return	:
]]
function getTreasureFragments( treasure_id )
	require "db/DB_Item_treasure"
	local treasureInfo = DB_Item_treasure.getDataById(treasure_id)
	local fragmentIds  = lua_string_split(treasureInfo.fragment_ids,",")
	return fragmentIds
end

--[[
	@des   	:修改当前拥有碎片的数量
	@param  :fragment_id 碎片id,num 碎片的变化量 正数增加 负数减少
	@return	:
]]
function addFragment( fragment_id, num )
	local fragmentNum = getFragmentNum(fragment_id)
	if(fragmentNum == 0) then
		local t = {}
		t.frag_id = fragment_id
		t.frag_num = num
	else
		for k,v in pairs(seizerInfoData.frag) do
			if(tonumber(v.frag_id) == tonumber(fragment_id)) then
				seizerInfoData.frag[k].frag_num = tonumber(v.frag_num) + num
			end
		end
	end
end

--[[
	@des: 得到可以合成宝物的个数
--]]
function getCanFuseNum( p_treasureId )
	local fragIds = getTreasureFragments(p_treasureId)
	local retNum = 9999999
	for k,v in pairs(fragIds) do
		local fragNum = getFragmentNum(v)
		if(fragNum < retNum) then
			retNum = fragNum
		end
	end
	if retNum == 9999999 then
		retNum = 0
	end
	return retNum
end


robberInfo = nil 
--[[
	@des   	:获取可抢夺用户信息
	@param  :
	@return	: 
	table :{	
	        (
            [level] => 等级
            [htid] => 1
            [uid] => 玩家的uid
            [percent] =>概率
            [utid] => 1
            [uname] => 名字
            [npc] => npc 类型
            [frag_num] => 碎片数量
            [squad] => Table  阵容
                (
                    [1] => 20002
                )
            [ratioDesc] => 极高概率
	        ),
	        ...
		}
	@author :zhz
]]
function getRobberList( )
	require "script/ui/treasure/TreasureUtil"
	local robberData= {}
	if(robberInfo == nil) then
		print(" Robberinfo is nil")
		return 0
	end
	for k,v in pairs(robberInfo) do
		-- 处理npc 的状态
		if(tonumber(v.npc)== 1) then
			local npcData = {}
			npcData = getNpcData(v.uid)
			npcData.ratioDesc= TreasureUtil.getFragmentPercentDesc(v.percent)
			npcData.npc= v.npc
			npcData.uid = v.uid
			npcData.vip=0
			table.insert(robberData,npcData)
			print("====  -------    npcData  is : ")
			print_t(npcData)
		else
			v.ratioDesc = TreasureUtil.getFragmentPercentDesc(v.percent)
			table.insert(robberData, v)
		end
	end
	local function keySort ( robberData_1, robberData_2 )
		if(NewGuide.guideClass == ksGuideRobTreasure) then
			return tonumber(robberData_1.npc ) > tonumber(robberData_2.npc)
		else
	   		return tonumber(robberData_1.npc ) < tonumber(robberData_2.npc)
		end
	end
	table.sort( robberData, keySort)

	return robberData
end

-- 获取npc的数据，将npc数据添加到 robberInfo中
function getNpcData( uid )
	require "db/DB_Army"
	require "db/DB_Team"
	require "db/DB_Monsters_tmpl"
	require "db/DB_Monsters"
	require "script/model/user/UserModel"
	local npcData = {}
	math.randomseed(os.time()) 
	repeat
		npcData.level = UserModel.getHeroLevel() + math.random(-1,1)  -- DB_Army.getDataById(uid).display_lv
	until npcData.level <= UserModel.getUserMaxLevel()
	npcData.uname = DB_Army.getDataById(uid).display_name

	-- 获得阵容
	local monster_group= DB_Army.getDataById(uid).monster_group
	local monsterID = DB_Team.getDataById(monster_group).monsterID
	local monsterTable = lua_string_split(monsterID,",")
	local monsteRealTable = {}
	-- 
	for k,v in pairs(monsterTable) do
		if(tonumber(v)~= 0) then
			table.insert(monsteRealTable, v)
		end
	end
	-- 查找DB_Monsters表，找到对应的htid
	local monsterHtidTable = {}
	for i=1,#monsteRealTable do
		local htid = DB_Monsters.getDataById(monsteRealTable[i]).htid
		table.insert(monsterHtidTable, htid)
	end
	-- table.insert(npcData,monsterHtidTable)
	npcData.squad = monsterHtidTable

	return npcData
end

--[[
	@des   	:获取夺宝的耐力消耗
	@param  :
	@return	: int
]]
function getEndurance( )
	require "db/DB_Loot"
	local lootData = DB_Loot.getDataById(1)
	local endurance = lootData.costEndurance
	return endurance
end

--[[
	@des 	:得到宝物名称
]]
function getTreasureName( treasure_id )
	local treasureInfo 	= DB_Item_treasure.getDataById(treasure_id)
	return treasureInfo.name
end

----------------------------------------------------[[免战功能接口]]---------------------------------------------------------------------------

--[[
	@des:		得到免战消耗物品以及数量
	@return 	{
		{itemTid,num}
		...
	}
]]
function getShieldItemInfo( ... )
	local itemTable = {}

	require "db/DB_Loot"
	require "db/DB_Item_treasure"
	local lootInfo 		= DB_Loot.getDataById(1)
	local itemIdInfo 	= lua_string_split(lootInfo.shieldSpentItemId, ",")
	
	for k,v in pairs(itemIdInfo) do
		local itemInfo = lua_string_split(v,"|")
		local item = {}
		item.itemTid = 	itemInfo[1]
		item.num 	 =  itemInfo[2]
		table.insert(itemTable, item)
	end
	return itemTable
end


--[[
	@des:	得到金币免战话费数量
	@return number
]]
function getGlodByShieldTime( ... )
	require "db/DB_Loot"
	require "db/DB_Item_treasure"
	local lootInfo 		= DB_Loot.getDataById(1)
	return  tonumber(lootInfo.shieldSpentGold)
end

--[[
	@des:		得到单次免战时间
	@return:	返回hh:mm:ss这样的时间
]]
function getShieldTime( ... )
	require "db/DB_Loot"
	require "db/DB_Item_treasure"
	local lootInfo 		= DB_Loot.getDataById(1)
	require "script/utils/TimeUtil"
	return TimeUtil.getTimeDesByInterval(tonumber(lootInfo.shieldTime)) 
end

--[[
	@des:		得到全局免战时间戳
	@param:		void
	@return 	bTime 全局免战开启时间, eTime 全局免战结束时间
]]
function getGlobalShieldTime( ... )
	require "db/DB_Loot"
	require "db/DB_Item_treasure"
	local lootInfo 			= DB_Loot.getDataById(1)
	local globalShieldTime  = lua_string_split(lootInfo.allShieldTime, "|")
	local bOtime, eOtime	= TimeUtil.getIntervalByTimeSegment(globalShieldTime[1]),TimeUtil.getIntervalByTimeSegment(globalShieldTime[2])

	local serverTime 		= BTUtil:getSvrTimeInterval()
	local oh,om,os   		= os.date("%H",serverTime), os.date("%M",serverTime), os.date("%S",serverTime)
	local serverOriginTime 	= serverTime - tonumber(oh)*3600 - tonumber(om)*60 - tonumber(os)

	local bTime = serverOriginTime + bOtime
	local eTime = serverOriginTime + eOtime
	return bTime,eTime
end

--[[
	@des:		是否处于全局免战状态
	@return:	bool
]]
function isGlobalShieldState( ... )
	local nowTime 		= BTUtil:getSvrTimeInterval()
	local gBtime,gEtime = getGlobalShieldTime()
	if(nowTime > gBtime and nowTime < gEtime) then
		return true
	else
		return false
	end
end

--[[
	@des: 		是否处于手动免战状态
	@return		bool
]]
function isShieldState( ... )
	local nowTime 		= BTUtil:getSvrTimeInterval()
	print("nowTime = ", nowTime)
	print("white_end_time =", tonumber(seizerInfoData.white_end_time))
	if(nowTime < tonumber(seizerInfoData.white_end_time)) then
		return true
	else
		return false
	end
end


--[[
	@des:		得到免战剩余时间
	@return:	time interval
]]
function getHaveShieldTime( ... )
	local endShieldTime = tonumber(seizerInfoData.white_end_time)
	if(endShieldTime == 0) then
		return 0
	else
		local havaTime = endShieldTime - BTUtil:getSvrTimeInterval()
		if(havaTime > 0) then
			return havaTime
		else
			return 0
		end
	end
end

--[[
	@des:增加免战时间
]]
function addShieldTime()
	require "db/DB_Loot"
	local lootInfo 		= DB_Loot.getDataById(1)
	local addTime = tonumber(lootInfo.shieldTime)
	if(tonumber(seizerInfoData.white_end_time) <= 0 or isShieldState() == false) then
		seizerInfoData.white_end_time = BTUtil:getSvrTimeInterval()
	else
		if(getHaveShieldTime() +  tonumber(lootInfo.shieldTime) > tonumber(lootInfo.shieldTimeLimit)) then
			addTime = tonumber(lootInfo.shieldTimeLimit) - getHaveShieldTime()
		end
	end
	
	seizerInfoData.white_end_time = tonumber(seizerInfoData.white_end_time) + addTime
	print("seizerInfoData.white_end_time = ", seizerInfoData.white_end_time)
end


--[[
	@des:获得全局免战的起止时间
	return: 开始时间 和结束时间 如：00:00 10:00
]]
function getShieldStartAndEndTime( ... )
	require "db/DB_Loot"
	local lootInfo 			= DB_Loot.getDataById(1)
	local globalShieldTime  = lua_string_split(lootInfo.allShieldTime, "|")

	local startTime = lua_string_split(globalShieldTime[1], ":")
	local endTime = lua_string_split(globalShieldTime[2],":")
	return startTime[1]..":"..startTime[2], endTime[1]..":"..endTime[2] 
end

--[[
	@des: 清除免战状态
]]
function clearShieldTime( ... )
	seizerInfoData.white_end_time  = 0
end


--[[
	@des:	计算使用免战后增加的时间
]]
function getUsingShieldAddTime( ... )
	require "db/DB_Loot"
	require "db/DB_Item_treasure"
	local lootInfo 		= DB_Loot.getDataById(1)

	local addTime = tonumber(lootInfo.shieldTime)
	if(getHaveShieldTime() +  tonumber(lootInfo.shieldTime) > tonumber(lootInfo.shieldTimeLimit)) then
		addTime = tonumber(lootInfo.shieldTimeLimit) - getHaveShieldTime()
	end
	require "script/utils/TimeUtil"
	return TimeUtil.getTimeDesByInterval(addTime) 
end


-- 得到一键合成是否开启
function getIsOpenOneKeyFuse( ... )
	require "db/DB_Vip"
	-- 需要的vip
	local needVip = 0
	local needLeve = 0
	local i = 1
	for k,v in pairs(DB_Vip.Vip) do
        local vInfo = DB_Vip.getDataById(tostring(i))
        local strArr = string.split(vInfo.AllCompose, "|")
        -- 1是开启0是未开启
        if(tonumber(strArr[1]) == 1)then
        	needVip = tonumber(vInfo.level)
        	needLeve = tonumber(strArr[2])
            break
        end
        i = i+1
    end

    -- 是否开启
    local isOpen = false
    if(UserModel.getVipLevel() >= needVip or  UserModel.getHeroLevel() >= needLeve )then
    	isOpen = true
    else
    	isOpen = false
    end

	return isOpen, needLeve, needVip
end


-- 一键合成是否显示
function isShowOneKeyButton( ... )
	local isShow = false
	local a,b,needVip = getIsOpenOneKeyFuse()
	print("a,b,needVip",a,b,needVip)
	-- 显示规则：大于50级或者vip达到开启条件
	if(UserModel.getVipLevel() >= needVip or  UserModel.getHeroLevel() >= 50)then
		isShow = true
	end
	return isShow
end

----------------------------------------------------------------- 宝物镶嵌数据 -----------------------------------------------------------------

--[[
	@des 	: 得到镶嵌位置是否开启
	@param 	: $p_item_templ_id 		:模板id
	@param 	: $p_item_id 			:物品id
	@param  : $p_itemInfo 			:物品详细信息
	@param  : $p_index 				:镶嵌位置
	@return : true or false,需要进化次数num(第一个位置需要主角等级，此处返回需要等级), isUseLv 标记是否用等级判断
--]]
function getRunePosIsOpen(p_item_templ_id,p_item_id,p_itemInfo,p_index)
	local isOpen = false
	local needNum,isUseLv = getRunePosOpenNum(p_item_templ_id,p_index)
	if(isUseLv == true)then
		-- 取主角等级
		local heroLv = UserModel.getHeroLevel()
		if(heroLv >= needNum)then
			isOpen = true
		end
	else
		-- 取进化次数
		local itemInfo = nil
		if p_itemInfo ~= nil then
			itemInfo = p_itemInfo
		else
			itemInfo = RuneData.getRuneInfoByItemId(p_item_id)
		end
		if(itemInfo ~= nil)then
			if(itemInfo.va_item_text and itemInfo.va_item_text.treasureDevelop )then
				if( tonumber(itemInfo.va_item_text.treasureDevelop) >= needNum)then
					isOpen = true
				end
			end
		end
	end
	return isOpen, needNum, isUseLv
end


--[[
	@des 	: 得到镶嵌位置开启条件
	@param 	: $p_item_templ_id 		:模板id
	@param  : $p_index 				:镶嵌位置
	@return : 需要进化次数num(第一个位置需要主角等级，此处返回需要等级)
--]]
function getRunePosOpenNum(p_item_templ_id,p_index)
	local retNum = 0
	local itemData = ItemUtil.getItemById( p_item_templ_id )
	-- 取主角等级限制开启
	local isUseLv = false
	require "db/DB_Normal_config"
	local lvStr = DB_Normal_config.getDataById(1).treasure_inlay
	local lvTab = string.split(lvStr,",")
	if(p_index <= table.count(lvTab) )then
		-- 取主角等级限制开启
		retNum = tonumber(lvTab[p_index])
		isUseLv = true
	else
		local needStrTab = string.split(itemData.place_open_limit,",")
		for i=1,#needStrTab do
			local needTab = string.split(needStrTab[i],"|")
			if(tonumber(needTab[2]) == tonumber(p_index))then
				retNum = tonumber(needTab[1])
				break
			end
		end
	end
	return retNum,isUseLv
end

--[[
	@des 	: 得到可以镶嵌的符印
	@param 	: $p_curItemId :宝物itemid
	@param 	: $p_curIndex :要镶嵌的位置
	@return : 
--]]
function getChooseRuneData( p_curItemId, p_curIndex )
	local retTab = {}
	local itemInfo = ItemUtil.getItemByItemId(p_curItemId)
	if(itemInfo == nil)then
		itemInfo = ItemUtil.getTreasInfoFromHeroByItemId(p_curItemId)
	end
	if( table.isEmpty(itemInfo.itemDesc) )then
		itemInfo.itemDesc = ItemUtil.getItemById(itemInfo.item_template_id)
	end

	local allRune = RuneData.getAllRune()
	if(itemInfo.va_item_text == nil or itemInfo.va_item_text.treasureInlay == nil or table.isEmpty(itemInfo.va_item_text.treasureInlay) )then
		for k,v in pairs(allRune) do
			if(tonumber(v.itemDesc.type) == tonumber(itemInfo.itemDesc.type))then
				table.insert(retTab,v)
			end
		end
		table.sort( retTab, BagUtil.runeSortForBag )
		print("getChooseRuneData 1")
		print_t(retTab)
		return retTab
	end
	-- print("p_curIndex",p_curIndex)
	-- print_t(itemInfo)
	for k,v in pairs(allRune) do
		print_t(v)
		if(tonumber(v.itemDesc.type) == tonumber(itemInfo.itemDesc.type))then
			-- 过滤当前的符印
			if(  itemInfo.va_item_text.treasureInlay[tostring(p_curIndex)] == nil or tonumber(itemInfo.va_item_text.treasureInlay[tostring(p_curIndex)].item_id) ~= tonumber(v.item_id) )then
				local isCan = true
				for pos,v_runeInfo in pairs(itemInfo.va_item_text.treasureInlay) do
					if(tonumber(pos) ~= tonumber(p_curIndex))then
						-- 过滤其他类型
						local haveType = tonumber(v_runeInfo.itemDesc.affix_type)
						if( tonumber(v.itemDesc.affix_type) == haveType)then
							isCan = false
						end
					end
				end
				if(isCan)then
					table.insert(retTab,v)
				end
			end
		end
	end

	table.sort( retTab, BagUtil.runeSortForBag )
	print("getChooseRuneData 2")
	print_t(retTab)
	return retTab
end


















