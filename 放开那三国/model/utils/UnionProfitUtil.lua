-- Filename：	UnionProfitUtil.lua
-- Author：		Zhang Zihang
-- Date：		2014-11-5
-- Purpose：		羁绊公用方法

module ("UnionProfitUtil", package.seeall)

 --     __            __
 --  __|  |__________|  |__
 -- |                      |
 -- |          __          |
 -- |    ___        ___    |
 -- |     |          |     |
 -- |          ~~          |
 -- |                      |
 -- |_____            _____|
 --       |          |
 --       |          |
 --       |          |  神兽保佑
 --       |          |  永无BUG
 --       |          |
 --       |          |___________
 --       |                      |__
 --       |                       __|
 --       |__       _____       __|
 --          |  |  |     |  |  |
 --          |__|__|     |__|__|

require "script/model/DataCache"
require "script/model/utils/HeroUtil"
require "script/model/hero/HeroModel"
require "script/utils/LevelUpUtil"
require "script/ui/formation/LittleFriendData"
require "script/ui/formation/FormationUtil"
require "script/ui/formation/secondfriend/SecondFriendData"
require "script/ui/hero/HeroPublicLua"
require "script/ui/item/ItemUtil"
require "db/DB_Union_profit"

--武将羁绊信息
--结构
--[[	_formationUnionInfo
		(	
			onFormation 		在阵上武将信息
			(
				武将hid
				(
					[tabel下标] = 已激活的连携技能id
				)
			)
			
			littleFriend 		小伙伴信息
			(
				结构同onFormation
			)
			secondfriend        第二套小伙伴信息
			(
				结构同onFormation
			)
		)
--]]
local _formationUnionInfo = {} 			

--神兵羁绊信息
--结构
--[[	_godUnionInfo
		(	
			武将hid
			(
				[数组下标] = 已激活的连携技能id
			)
		)
--]]
local _godUnionInfo = {}

--被激活的羁绊信息
--结构
--[[
		_activedUnionInfo
		(
			[羁绊id] = true
		)
--]]
--以羁绊id为key是为了哈希查找
local _activedUnionInfo = {}

--新被激活的羁绊id的table
--结构
--[[
		_addUnionTable
		(
			[table下标] = 羁绊id
		)
--]]
local _addUnionTable = {}

--与羁绊id相关的武将hid
--这么做也是为了方便哈希查找
--结构
--[[
		_unionIndexTable
		(
			被激活的羁绊id
			(
				[table下标] = 相关的武将hid
			)
		)
--]]
local _unionIndexTable = {}

--结构是
--[[
		_onFormationHid
		(
			[武将hid] = true
		)
--]]
--目的是为了哈希查找该武将是否在阵上
local _onFormationHid = nil

--结构同_onFormationHid
--目的是哈希查找武将是否是小伙伴
local _onLittleFriendHid = nil

--结构同_onFormationHid
--目的是哈希查找武将是否是第二套小伙伴
local _onSecondFriendHid = nil

--[[
	@des 	:设置羁绊信息
	@param 	:
	@return :
--]]
function setUnionProfitInfo()
	--将_formationUnionInfo的旧数据清空
	_formationUnionInfo = {}
	_formationUnionInfo.onFormation = {}
	_formationUnionInfo.littleFriend = {}
	_formationUnionInfo.secondFriend = {}
	--重置神兵羁绊
	_godUnionInfo = {}

	--获得阵上信息
	local formationInfo = DataCache.getFormationInfo() or {}

	_onFormationHid = {}

	--在获得在阵上的武将hid
	local onFormationHeroes = {}
	for k,v in pairs(formationInfo) do
		local hid = tonumber(v)
		--如果在这个位置上有武将
		if hid > 0 then
			table.insert(onFormationHeroes,hid)
			_onFormationHid[tonumber(hid)] = true
			_formationUnionInfo.onFormation[hid] = {}
			_godUnionInfo[hid] = {}
		end
	end

	--获得小伙伴信息
	local littleFriendInfo = LittleFriendData.getLittleFriendeData() or {}

	_onLittleFriendHid = {}

	--获得在小伙伴上武将的hid
	for k,v in pairs(littleFriendInfo) do
		local hid = tonumber(v)
		--如果在这个位置上有武将
		if hid > 0 then
			table.insert(onFormationHeroes,hid)
			_onLittleFriendHid[tonumber(hid)] = true
			_formationUnionInfo.littleFriend[hid] = {}
		end
	end

	--获得第二套小伙伴数据
	local secFriendInfo = SecondFriendData.getSecondFriendInfo()
	
	_onSecondFriendHid = {}

	for k,v in pairs(secFriendInfo) do
		local hid = tonumber(v)
		if hid > 0 then
			table.insert(onFormationHeroes,hid)
			_onSecondFriendHid[tonumber(hid)] = true
			_formationUnionInfo.secondFriend[hid] = {}
		end
	end

	--用于更新_activedUnionInfo而创建的table
	--内部结构同_activedUnionInfo
	local tempUnionInfo = {}

	--遍历阵上武将和小伙伴
	for i = 1,#onFormationHeroes do
		dealWithUnionData(onFormationHeroes[i],tempUnionInfo)
		dealWithGodUnion(onFormationHeroes[i])
	end
	_activedUnionInfo = tempUnionInfo
end

--[[
	@des 	:处理神兵羁绊
	@param  :武将hid
--]]
function dealWithGodUnion(p_hid)
	--当前武将信息
	local heroData = HeroUtil.getHeroInfoByHid(p_hid)
	--DB表上有羁绊的神兵模板id
	local unionId = heroData.localInfo.godarm_link
	if unionId == nil then
		return
	end
	print("dealWithGodUnion==",unionId)
	local uidTab = string.split(unionId,",")
	for i=1,#uidTab do
		addGodUnionToTable(p_hid,tonumber(uidTab[i]))
	end
end

--[[
	@des 	:将满足羁绊条件的神兵羁绊加入table中
	@param  :武将hid
	@param  :羁绊id
--]]
function addGodUnionToTable(p_hid,p_uid)
	--如果羁绊开了
	if isHeroParticularUnionOpen(p_uid,p_hid) then
		table.insert(_godUnionInfo[p_hid],p_uid)
	end
end

--[[
	@des 	:处理羁绊数据
	@param  :武将hid
	@param  :当前武将身上羁绊的临时数据
	@param  :临时table
--]]
function dealWithUnionData(p_hid,p_tempUnionInfo)
	--当前武将信息
	local heroData = HeroUtil.getHeroInfoByHid(p_hid)
	--DB表上该武将所有可以激活的羁绊id
	local linkString = heroData.localInfo.link_group1
	--如果DB表中该武将存在羁绊
	if linkString == nil then
		return
	end
	--unionIdTable中是所有羁绊的id
	local unionIdTable = string.split(linkString,",")

	for j = 1,#unionIdTable do
		local unionId = tonumber(unionIdTable[j])
		addUnionInfoToTable(p_tempUnionInfo,p_hid,unionId)
	end
end

--[[
	@des 	:将羁绊信息加入诸多table中
	@param  :临时羁绊table
	@param  :武将hid
	@param  :羁绊id
	@param  :临时table
--]]
function addUnionInfoToTable(p_tempUnionInfo,p_hid,p_uid)
	local unionProfitInfo = DB_Union_profit.getDataById(p_uid)

	--如果这个羁绊没有被遍历过
	if p_tempUnionInfo[p_uid] == nil then
		--如果该羁绊id存在，且有羁绊
		if (not table.isEmpty(unionProfitInfo)) and unionProfitInfo.union_arribute_name then
			--如果羁绊被激活了
			if isHeroParticularUnionOpen(p_uid,p_hid) then
				p_tempUnionInfo[p_uid] = true
				--对于新的羁绊，初始化相应的羁绊下标table
				_unionIndexTable[p_uid] = {}
				table.insert(_unionIndexTable[p_uid],p_hid)
				insertTableTool(p_hid,p_uid)
				--如果原来没有这个羁绊，则这个是新添加的
				if _activedUnionInfo[p_uid] ~= true then
					table.insert(_addUnionTable,p_uid)
				end
			--如果该羁绊没有被激活，记录下来，再次遍历就不判断该羁绊了
			else
				p_tempUnionInfo[p_uid] = false
			end
		end
	--如果这个羁绊被遍历过，且已经被开启
	elseif p_tempUnionInfo[p_uid] == true then
		insertTableTool(p_hid,p_uid)
		table.insert(_unionIndexTable[p_uid],p_hid)
	end
end

--[[
	@des 	:将武将羁绊插入table中
	@param  :武将hid
	@param  :羁绊id
--]]
function insertTableTool(p_hid,p_uid)
	if _onLittleFriendHid[p_hid] ~= nil then
		table.insert(_formationUnionInfo.littleFriend[p_hid],p_uid)
	elseif _onFormationHid[p_hid] ~= nil then
		table.insert(_formationUnionInfo.onFormation[p_hid],p_uid)
	else
		table.insert(_formationUnionInfo.secondFriend[p_hid],p_uid)
	end
end

--[[
	@des 	:得到武将羁绊信息
	@return :武将羁绊信息
--]]
function getUnionProfitInfo()
	return _formationUnionInfo
end

--[[
	@des 	:得到阵上武将羁绊
	@return :武将羁绊信息
--]]
function getOnFormationHeroUnion()
	return _formationUnionInfo.onFormation
end

--[[
	@des 	:得到神兵羁绊信息
	@return :神兵羁绊信息
--]]
function getGodUnionInfo()
	return _godUnionInfo
end

--[[
	@des 	:得到第二套小伙伴羁绊
	@return :第二套小伙伴羁绊
--]]
function getOnSecondFriendUnion()
	return _formationUnionInfo.secondFriend
end

--[[
	@des 	:得到小伙伴羁绊
	@return :小伙伴羁绊
--]]
function getOnLittleFriendUnion()
	return _formationUnionInfo.littleFriend
end

--[[
	@des 	:得到新增的羁绊id信息
	@return :新增羁绊id信息
--]]
function getAddUnionProfit()
	return _addUnionTable
end

--[[
	@des 	:通过当前激活的羁绊id得到相关联的武将的hid信息
	@param 	:羁绊id
	@return :相关联的武将hid信息
--]]
function getLinkHeroesByUnionId(p_unionId)
	return _unionIndexTable[tonumber(p_unionId)]
end

--[[
	@des 	:刷新武将羁绊信息
--]]
function refreshUnionProfitInfo()
	_addUnionTable = {}
	_unionIndexTable = {}

	setUnionProfitInfo()
end

--[[
	@des 	:为羁绊飘文字做准备
	@param 	:$p_callBack 		:回调函数
	@param  :$p_isReturn 		:是否要返回
	@return :
--]]
function prepardUnionFly(p_callBack,p_isReturn)
	--刷新羁绊信息
	refreshUnionProfitInfo()

	--如果没有新增加的羁绊
	if table.isEmpty(_addUnionTable) then
		if p_callBack ~= nil then
			p_callBack()
		elseif p_isReturn ~= nil then
			return {}
		end
	else
		local flyInfoTable = {}
		for i = 1,#_addUnionTable do
			local curUnionId = _addUnionTable[i]
			local curHidTable = _unionIndexTable[curUnionId]
			for j = 1,#curHidTable do
				--如果该武将不是小伙伴也不是第二套小伙伴
				local curHid = curHidTable[j]
				if _onLittleFriendHid[curHid] == nil and _onSecondFriendHid[curHid] == nil then
					local paramTable = {}
					paramTable.hid = curHidTable[j]
					paramTable.uid = curUnionId

					table.insert(flyInfoTable,paramTable)
				end
			end
		end

		if p_isReturn ~= nil then
			return flyInfoTable
		end

		LevelUpUtil.showUnionFlyTip(flyInfoTable,p_callBack)
	end
end

-----------------------------------------------------------大一统的羁绊方法----------------------------------------------------------
--[[
	@des 	:判断英雄的某个羁绊是否开启
	@param  :羁绊id
	@param 	:武将hid
	@return :是否开启
--]]
function isHeroParticularUnionOpen(p_uid,p_hid)
	--先检查聚义厅是否开启此羁绊
	require "script/ui/star/loyalty/LoyaltyData"
	if LoyaltyData.getIfUnionOpen(p_uid) then
		return true, true
	end
	
	--羁绊的db信息
	local unionDBInfo = DB_Union_profit.getDataById(p_uid)
	--人物信息
	local heroInfo = HeroUtil.getHeroInfoByHid(p_hid)
	--羁绊开启条件
	local conditionsTable = string.split(unionDBInfo.union_card_ids, ",")
	--是否开启
	local isOpen = false
	--遍历开启条件
	for k,v in pairs(conditionsTable) do
		--羁绊具体开启条件
		local detailTable = string.split(v,"|")
		--羁绊类型
		local unionType = tonumber(detailTable[1])
		--羁绊需要的条件
		local unionCondition = tonumber(detailTable[2])
		--如果是武将羁绊
		if unionType == 1 then
			isOpen = isHeroUnionOpen(unionCondition)
			--如果其中一个条件不满足，则退出循环
			if not isOpen then
				break
			end
		--如果是装备羁绊（包括武器、宝物、神兵）
		elseif unionType == 2 then
			isOpen = isArsenalUnionOpen(unionCondition,heroInfo)
		--装备满足品质限制的宝马羁绊
		elseif unionType == 3 then
			isOpen = isHorseUnionOpen(unionCondition,p_hid)
		--装备满足品质限制的宝书羁绊
		elseif unionType == 4 then
			isOpen = isBookUnionOpen(unionCondition,p_hid)
		--装备任意橙色套装的羁绊
		elseif unionType == 5 then
			isOpen = isOrangeWeaponOpen(unionCondition,heroInfo)
			--满足其中一个就可以
			if isOpen then
				break
			end
		end
	end

	return isOpen
end

function getUnionProfitActiveCountByHid(hid)
	local unionProfitCount = 0
	local unionInfo = UnionProfitUtil.getHeroUnionIfoByHid(hid)
	for i = 1, #unionInfo do
		local data = unionInfo[i]
		if data.isOpen then
			unionProfitCount = unionProfitCount + 1
		end
	end
	return unionProfitCount
end

function getUnionProfitActiveCount( ... )
	local unionProfitCount = 0
	local formationInfo = DataCache.getFormationInfo() or {}
	for k,v in pairs(formationInfo) do
		local hid = tonumber(v)
		if hid > 0 then
			local heroUnionProfitCount = getUnionProfitActiveCountByHid(hid)
			unionProfitCount = unionProfitCount + heroUnionProfitCount
		end
	end
	return unionProfitCount
end


--[[
	@des 	:判断和英雄的羁绊是否开启
	@param 	:需要的英雄模板id
	@return :是否开启
--]]
function isHeroUnionOpen(p_htid)
	--如果是和主角的羁绊
	if p_htid == 0 then
		return FormationUtil.isMainHeroOnFormation()
	--和武将的羁绊
	else
		--是否该武将在阵上或小伙伴里
		return HeroPublicLua.isBusyWithHtid(p_htid) or HeroPublicLua.isOnLittleFriendBy(p_htid) or SecondFriendData.isHadSameTemplateOnSecondFriendByHtid(p_htid)
	end
end

--[[
	@des 	:判断和装备的羁绊是否开启
	@param 	:需要的装备的模板id
	@param 	:武将信息
	@return :是否开启
--]]
function isArsenalUnionOpen(p_modelId,p_heroInfo)
	local isOpen = false
	--如果是装备
	if (p_modelId >= 100001) and (p_modelId <= 200000) then
		--遍历身上的装备
		for k,v in pairs(p_heroInfo.equip.arming) do
			isOpen = isSatifyEquipCondition(p_modelId,v)
			if isOpen then
				break
			end
		end
	--如果是宝物
	elseif (p_modelId >= 500001) and (p_modelId <= 600000) then
		for k,v in pairs(p_heroInfo.equip.treasure) do
			isOpen = isSatifyTreasureCondition(p_modelId,v)
			if isOpen then
				break
			end
		end
	--如果是神兵
	elseif (p_modelId >= 600001) and (p_modelId <= 700000) then
		for k,v in pairs(p_heroInfo.equip.godWeapon) do
			isOpen = isSatifyGodCondition(p_modelId,v)
			if isOpen then
				break
			end
		end
	end

	return isOpen
end

--[[
	@des 	:判断主角橙装羁绊是否开启
	@param 	:需要的橙装的模板id
	@param 	:武将信息
	@return :是否开启
--]]
function isOrangeWeaponOpen(p_modelId,p_heroInfo)
	local isOpen = false
	for k,v in pairs(p_heroInfo.equip.arming) do
		isOpen = isSatifyEquipCondition(p_modelId,v)
		if isOpen then
			break
		end
	end

	return isOpen
end

--[[
	@des 	:是否满足装备的羁绊条件
	@param 	:需要的装备模板id
	@param  :装备信息
	@return :是否开启
--]]
function isSatifyEquipCondition(p_modelId,p_itemInfo)
	if table.isEmpty(p_itemInfo) then
		return false
	else
		return p_modelId == tonumber(p_itemInfo.item_template_id)
	end
end

--[[
	@des 	:是否满足宝物的羁绊条件
	@param 	:需要的装备模板id
	@param  :宝物信息
	@return :是否开启
--]]
function isSatifyTreasureCondition(p_modelId,p_itemInfo)
	if table.isEmpty(p_itemInfo) then
		return false
	else
		return p_modelId == tonumber(p_itemInfo.item_template_id)
	end
end

--[[
	@des 	:是否满足神兵的羁绊条件
	@param 	:需要的装备模板id
	@param  :神兵信息
	@return :是否开启
--]]
function isSatifyGodCondition(p_modelId,p_itemInfo)
	if table.isEmpty(p_itemInfo) then
		return false
	else
		local itemDBInfo = ItemUtil.getItemById(p_itemInfo.item_template_id)
		--进阶等级要满足
		local isEvolveNumOK = (tonumber(p_itemInfo.va_item_text.evolveNum) >= tonumber(itemDBInfo.friend_open))
		return (p_modelId == tonumber(p_itemInfo.item_template_id)) and isEvolveNumOK
	end
end

--[[
	@des 	:特定品质以上战马羁绊是否开启
	@param 	:所需品质
	@param  :武将hid
	@return :是否开启
--]]
function isHorseUnionOpen(p_needQuality,p_hid)
	return tonumber(HeroModel.getHorseQuality(p_hid)) == p_needQuality
end

--[[
	@des 	:特定品质以上兵书羁绊是否开启
	@param 	:所需品质
	@param  :武将hid
	@return :是否开启
--]]
function isBookUnionOpen(p_needQuality,p_hid)
	return tonumber(HeroModel.getBookQuality(p_hid)) == p_needQuality
end

--[[
	@des 	:通过hid得到这个人的羁绊信息
	@param  :武将hid
	@return :羁绊数据
--]]
function getHeroUnionIfoByHid(p_hid)
	local hid = tonumber(p_hid)
	local heroInfo = HeroUtil.getHeroInfoByHid(hid)
	
	local returnTable = {}

	local indexTable = getUnionIndexTable(p_hid)

	--DB表上该武将所有可以激活的羁绊id
	local linkString = heroInfo.localInfo.link_group1
	--如果DB表中该武将存在羁绊
	if linkString == nil then
		return returnTable
	end
	--unionIdTable中是所有羁绊的id
	local unionIdTable = string.split(linkString,",")
	for i = 1,#unionIdTable do
		local innerTable = {}
		local unionId = tonumber(unionIdTable[i])
		innerTable.unionId = unionId
		if indexTable[unionId] == 1 then
			innerTable.isOpen = true
		elseif isHeroParticularUnionOpen(unionId,p_hid) then
			innerTable.isOpen = true
		else
			innerTable.isOpen = false
		end
		table.insert(returnTable,innerTable)
	end

	return returnTable
end

--[[
	@des 	:通过羁绊id得到羁绊的db信息
	@param  :羁绊id
	@return :羁绊数据
--]]
function getUnionDBInfoByUid(p_uid)
	return DB_Union_profit.getDataById(p_uid)
end

--[[
	@des 	:得到一个人的羁绊的哈希查找table
	@param  :武将hid
	@return :羁绊哈希数据
--]]
function getUnionIndexTable(p_hid)
	local hid = tonumber(p_hid)
	local unionInfo
	if getOnFormationHeroUnion()[hid] ~= nil then
		unionInfo = getOnFormationHeroUnion()
	elseif getOnLittleFriendUnion()[hid] ~= nil then
		unionInfo = getOnLittleFriendUnion()
	else
		unionInfo = getOnSecondFriendUnion()
	end
	local indexTable = {}
	if unionInfo[hid] == nil then
		return indexTable
	end

	local openInfo = unionInfo[hid]
	for i = 1,#openInfo do
		indexTable[tonumber(openInfo[i])] = 1
	end

	return indexTable
end



-- 
--[[
	@author :chengliang
	@des 	:给定一组 htid 返回相关的武将羁绊
	@param  :htid 数组{10001, 10002, ....}
	@return :htid 对应羁绊信息的 map
			{
				10001 => {
					heroinfo =>
					union_info =>{
						11 =>{
							is_acitive=>1,
							desc=>"asdfasdf",
						}
					}
				}
			}
--]]
function getHeroUniosByHtids( htid_arr )
	local union_map = {}
	if(table.isEmpty(htid_arr))then
		return union_map
	end
	local model_id_map = {}
	for _, htid in pairs(htid_arr) do
		local heroInfo = HeroUtil.getHeroLocalInfoByHtid(htid)
		model_id_map[tostring(heroInfo.model_id)] = 1
	end
	for _, htid in pairs(htid_arr) do
		local hero_unions = {}
		-- hero_unions.heroInfo = HeroUtil.getHeroLocalInfoByHtid(htid)
		local heroInfo = HeroUtil.getHeroLocalInfoByHtid(htid)
		hero_unions.union_infos = {}
		local union_str = heroInfo.link_group1
		if( string.isEmpty(union_str) == false )then
			local union_arr = string.split(union_str, ",")
			for _,union_id in pairs(union_arr) do
				local union_profit = DB_Union_profit.getDataById(union_id)
				local heroes_ids = string.split(union_profit.union_card_ids, ",")
				local u_type = 1  -- 羁绊类型
				local is_active = true
				for _,id_arr in pairs(heroes_ids) do
					local t_htid_arr = string.split(id_arr, "|")
					u_type = tonumber(t_htid_arr[1])
					if( u_type ~= 1 or model_id_map[t_htid_arr[2]] == nil)then
						is_active = false
						break
					end
				end
				if(u_type == 1)then
					hero_unions.union_infos[union_id] = {}
					hero_unions.union_infos[union_id].uniom_type	= u_type
					hero_unions.union_infos[union_id].union_desc 	= union_profit.union_arribute_desc
					hero_unions.union_infos[union_id].union_name 	= union_profit.union_arribute_name
					hero_unions.union_infos[union_id].is_active 	= is_active
				end
			end
			
		end
		union_map[htid] = hero_unions
	end

	return union_map
end

