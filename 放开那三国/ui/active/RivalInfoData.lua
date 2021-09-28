--RivalInfoData.lua
-- Filename：	RivalInfoData.lua
-- Author：		zhz
-- Date：		2013-2-17
-- Purpose：		组队的数据层 

module ("RivalInfoData", package.seeall)

require "script/model/user/UserModel"
require "script/ui/guild/GuildDataCache"
require "db/DB_Heroes"
require "db/DB_Pet"


local _allFormationInfo	= {}			-- 所有的阵容信息
local _formationInfo ={}				-- 经过处理阵容信息
local _friendInfo	 ={}				-- 小伙伴信息， 可以为空
local _petInfo 		 ={}				-- 宠物信息	，可以为空
local _isNpc          = false
local _curIndex
local _isPocketOpen = nil               --锦囊是否开启
-- added by bzx
local _warcraftDataMap					-- 所有的阵法信息
local _usedWarcraftData					-- 当前使用阵法
local _formationInfoMap
local _attrExtraLevelMap = nil          -- 助战位等级映射 key:助战位位置;value:助战位等级，-1表示未开启，0表示已开启，其他数值表示助战位等级
local _heroIDAndInfoMap = nil           -- 武将ID和武将一些信息的Map(时装和兵符)

-- 设置所有的信息
function setAllFormationInfo( allFormationInfo )
	_allFormationInfo = allFormationInfo
end

function getAllFormationInfo(  )
	return _allFormationInfo
end

function handleInfo(  )

	_formationInfo = {}	
	_heroIDAndInfoMap = {}
	for i=1,#_allFormationInfo.squad do
		for k,v in pairs (_allFormationInfo.arrHero) do
			if( _allFormationInfo.squad[i] == v.hid) then
				_heroIDAndInfoMap[v.hid] = {["equipInfo"] = v.equipInfo,["htid"] = v.htid,["turned_id"] = v.turned_id}
				if HeroModel.isNecessaryHero(v.htid) then
					v.name = _allFormationInfo.uname
				end
				table.insert(_formationInfo, v)
			end
		end
	end

	-- added by bzx 阵法
    _warcraftDataMap = {}
    _usedWarcraftData = nil
    _formationInfoMap = {}
    if _allFormationInfo.craft_info ~= nil then
	    if _allFormationInfo.craft_info.warcraft ~= nil then
		    for k, v in pairs(_allFormationInfo.craft_info.warcraft) do
		    	local warcraftData = {}
		    	warcraftData.id = tonumber(k)
		    	warcraftData.level = tonumber(v.level)
		    	_warcraftDataMap[warcraftData.id] = warcraftData
		    end
	    end
	    if _allFormationInfo.craft_info.craft_id ~= nil and _allFormationInfo.craft_info.craft_id ~= "0" then
	    	if table.isEmpty(_allFormationInfo.craft_info.warcraft) then
	    		_usedWarcraftData = {}
	    		_usedWarcraftData.id = tonumber(_allFormationInfo.craft_info.craft_id)
	    		_usedWarcraftData.level = 1
	    	else
	    		_usedWarcraftData = _warcraftDataMap[tonumber(_allFormationInfo.craft_info.craft_id)]
			end
		end
	end
	
	for i=1,#_allFormationInfo.squad do
		for k,v in pairs (_allFormationInfo.arrHero) do
			if( _allFormationInfo.squad[i] == v.hid) then
				_formationInfoMap[k] = v
			end
		end
	end

	_attrExtraLevelMap = _allFormationInfo.attrExtraLevel
	
	_curIndex =1
	
end

-- added by bzx 
function getUsedWarcraftData( ... )
	return _usedWarcraftData
end

function shouldShowWarcraft( ... )
	if _isNpc == false and _usedWarcraftData ~= nil then
		return true
	end
	return false
end

function getFormationInfoMap( ... )
	return _formationInfoMap
end
--[[
	@des 	:获取武将id组
	@param  :
	@return :
--]]
-- squad : 
--   array[ 
--       (0):"45172712"
--       (1):"45185316"
--       (2):"45185315"
--       (3):"45185317"
--       (4):"45185313"
--       (5):"45185311"
--   ]
function getHeroSquad( ... )
	local formationInfo = {}
	for pos,hero_hid in pairs(_allFormationInfo.squad) do
		formationInfo[tostring(pos)] = tostring(hero_hid)
	end
	return formationInfo
end
--[[
	@des 	:根据武将ID获取时装数据
	@param  :
	@return :
--]]
function getHeroDressByHid( pHid )
	-- body
	return _heroIDAndInfoMap[pHid].equipInfo.dress
end
--[[
	@des 	:根据武将ID和兵符的位置获取兵符数据
	@param  :
	@return :
--]]
function getHeroTallyByHidAndPos( pHid,pPos )
	local heroData = _heroIDAndInfoMap[pHid]
	if(not table.isEmpty(heroData)) then
		return heroData.equipInfo.tally[tostring(pPos)]
	end
end

--[[
	@des 	:根据武将ID和兵符的位置获取兵符数据
	@param  :
	@return :
--]]
function getHeroTallyByHid( pHid )
	local heroData = _heroIDAndInfoMap[pHid]
	if(not table.isEmpty(heroData)) then
		heroData.equip = {}
		heroData.equip = heroData.equipInfo
		return heroData
	end
end
--[[
	@des 	:根据武将ID和兵符的位置判断是否装备了兵符
	@param  :
	@return :
--]]
function isTallyEmptyByHidAndPos( pHid,pPos )
	local bRet = false
	local heroData = _heroIDAndInfoMap[pHid]
	if(not table.isEmpty(heroData)) then
		if heroData.equipInfo.tally[tostring(pPos)] ~= nil then
			bRet = true
		end
	end
	return bRet
end
--[[
	@des 	:根据武将ID获取武将的htid
	@param  :
	@return :
--]]
function getHeroHtidByHid( pHid )
	local heroData = _heroIDAndInfoMap[pHid]
	local heroHtid = 0;
	if(not table.isEmpty(heroData)) then
		heroHtid = heroData.htid
	end
	return heroHtid
end
--[[
	@des 	:根据位置获取武将ID
	@param  :
	@return :
--]]
function getHeroIDByPos( pPos )
	local pPos = tostring(pPos)
	local squad = getHeroSquad()
	return squad[pPos]
end

function setNpc( npc )
	_isNpc = npc
end

-- 得到上阵的信息
function getFormationHeroInfo( ... )
	return _formationInfo
end

--[[
	@des 	:处理npc数据，uid为army表里的id

	@param 	:uid为army表的id
	@retrun : npc的数据
]]
function getNpcDataById( uid )

	require "db/DB_Army"
	require "db/DB_Team"
	require "db/DB_Monsters_tmpl"
	require "db/DB_Monsters"
	require "script/model/user/UserModel"
	local npcData = {}

	math.randomseed(os.time()) 
	
	npcData.level = UserModel.getHeroLevel()-- + math.random(-1,1)
	npcData.uname = DB_Army.getDataById(uid).display_name
	local  _tname = _tname or  DB_Army.getDataById(uid).display_name

	local monster_group= DB_Army.getDataById(uid).monster_group
	local monsterID = DB_Team.getDataById(monster_group).monsterID
	local monsterTable = lua_string_split(monsterID,",")
	local monsteRealTable = {}

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

	-- 通过DB_Heroes表(  DB_Monsters_tmpl 里面没有对应的战斗力和血量生命的属性 )得到arrHero 里的所有英雄的数据
	local arrHero = {}
	for i=1,#monsterHtidTable do
		local heroTable= {}
		local tParam= {htid = monsterHtidTable[i], level = UserModel.getHeroLevel()  }
		local heroData = HeroFightSimple.getAllForceValues(tParam)
		heroTable.level =  UserModel.getHeroLevel()
		-- print("		=======  heroData  heroData    heroData    ")
		-- print_t(heroData)
		heroTable.physical_def= heroData.physicalDefend
		heroTable.magical_def = heroData.magicDefend
		heroTable.max_hp = heroData.life
		heroTable.evolve_level = 0
		heroTable.general_atk = heroData.generalAttack
		heroTable.fight_force = heroData.fightForce
		heroTable.equipInfo ={ arming ={},
								treasure = {},
								 skillBook= {},
								}
		heroTable.htid = monsterHtidTable[i]
		table.insert(arrHero, heroTable)
		_curIndex = 1

	end

	_formationInfo = arrHero
	return arrHero
	--_formationInfo = arrHero

end

-- 得到玩家总得战斗力
function getHeroFightForce( )
	
	local fightForce=0

	if(_isNpc == true) then
		fightForce = 0
		return fightForce
	end	

	for i=1, #_formationInfo do
		fightForce= fightForce +_formationInfo[i].fight_force
	end

	return fightForce
end


function setCurIndex(index )
	_curIndex = index
end



-- 计算武将的连携
-- p_heroIndex 这个参数  add by DJN 2015/4/10  原因：在计算羁绊的时候，部分函数依赖于_curindex ,_curindex在武将信息界面固然是对的，但是在查看小伙伴的
-- 界面的时候 _curindex 就不是对的了 导致一些羁绊本来已经开启 但是因为通过在小伙伴界面的index在formationInfo中找到的信息是错误的 羁绊判断函数结果不准确
-- 例(hasTreasure函数就是这种情况 )所以在小伙伴界面，手动算出要计算的武将羁绊的武将信息在formationInfo中的index并传参过来 （详见 RivalFriendLayer.createContainerLayer()）
function parseHeroUnionProfit( cur_Htid, link_group ,p_heroIndex)
	require "db/DB_Heroes"
	local heroBaseHtid = cur_Htid
    local heroIndex = p_heroIndex
	require "db/DB_Union_profit"
	local s_link_arr = string.split(link_group, ",")
	local t_link_infos = {}
	for k, link_id in pairs(s_link_arr) do
		local t_union_profit = DB_Union_profit.getDataById(link_id)
		local link_info = {}
		link_info.dbInfo = t_union_profit
		link_info.isActive = IsjudgeUnion( link_id, heroBaseHtid ,nil,heroIndex)

		table.insert(t_link_infos, link_info)
	end

	return t_link_infos
end

-- 判断羁绊书否开启
function IsjudgeUnion( u_id, htid, p_hid ,p_index)
	local isActive = true
	if(_isNpc == true) then
		isActive = false
	end	
	---------------------------------------------------------------------------------------------------------
	--新增聚义厅功能 在聚义厅功能中会激活一些羁绊 这些羁绊放在uiion.union字段中 对所有武将通用
	-- print("IsjudgeUnion _allFormationInfo")
	-- print_t(_allFormationInfo)
	if(not table.isEmpty(_allFormationInfo) and not table.isEmpty(_allFormationInfo.union) and not table.isEmpty(_allFormationInfo.union.union))then
		local uId = tonumber(u_id)
		for k,v in pairs(_allFormationInfo.union.union) do
			if(tonumber(v) == uId)then
				return true
			end
		end
	end
	---------------------------------------------------------------------------------------------------------
   -- print("传进来的三个参数",u_id, htid, p_hid)
	local t_union_profit = DB_Union_profit.getDataById(u_id)
	local heroData= DB_Heroes.getDataById(htid)

	local card_ids = string.split(t_union_profit.union_card_ids, ",")
    -- print("card_ids")
    -- print_t(card_ids)
	for k,type_card in pairs(card_ids) do
		local type_card_arr = string.split(type_card, "|")
		-- print("type_card_arr")
		-- print_t(type_card_arr)
		if(tonumber(type_card_arr[1]) == 1)then
			if(tonumber(type_card_arr[2]) == 0)then
				print("1111111111")
				-- if( not isMainHeroOnFormation() ) then
				isActive = false
				-- 	break
				-- end
				-- return false
			else
				print("22222222222")
				if(isHeroOnFormation(tonumber(type_card_arr[2])) == false and isLittleFriendOn(tonumber(type_card_arr[2]))== false) and isSecFriendOn(tonumber(type_card_arr[2])) == false then
					isActive = false
					break
				end

			end
		-- 装备 宝物 神兵
		elseif(tonumber(type_card_arr[1]) == 2) then
            
			isActive = false
			if(hasTreasure(tonumber(type_card_arr[2]),p_index) == true) then
				print("333333333")
				isActive = true
				break
			end
			if(isActive == false) then
				if(hasEquipt(tonumber(type_card_arr[2]))== true ) then
					print("444444444444")
					isActive= true
					break
				end
			end
		--战马类型
		elseif tonumber(type_card_arr[1]) == 3 then
			--书
			if p_hid then
				local heroHorseQuality = RivalInfoData.getHorseQuality(p_hid)
				if(tonumber(heroHorseQuality) ~= tonumber(type_card_arr[2])) then
					print("5555555555555")
					isActive = false
				end
			end
		--兵书类型
		elseif tonumber(type_card_arr[1]) == 4 then
			--马		
			if p_hid then
				local heroHorseQuality = RivalInfoData.getBookQuality(p_hid)

				if(tonumber(heroHorseQuality) ~= tonumber(type_card_arr[2])) then
					print("6666666666")
					isActive = false
				end
			end
		--主角橙装羁绊
		elseif tonumber(type_card_arr[1]) == 5 then
			isActive = false
			if(hasEquipt(tonumber(type_card_arr[2])) == true) then
				print("777777777777")
				isActive = true
				break
			end
		end
	end
	--print("最后的羁绊开启结果",isActive)
	return isActive
end

-- --判断当前武将是否在场上
-- function isHeroOnFormation( htid)
-- 	local isOn= false
-- 	for k,formation in pairs(_formationInfo) do
-- 		if(tonumber(formation.htid) == tonumber(htid)  ) then
-- 			isOn = true
-- 			break
-- 		end
-- 	end
-- 	return isOn
-- end
--判断当前武将是否在场上
function isHeroOnFormation( htid)
	local isOn= false
	for k,formation in pairs(_formationInfo) do
		local modelId = DB_Heroes.getDataById(tonumber(formation.htid)).model_id
		if(tonumber(modelId) == tonumber(htid)  ) then
			isOn = true
			break
		end
	end
	return isOn
end

-- -- addBy chengliang
-- -- 通过htid判断小伙伴中是否存在某一类武将
-- function isLittleFriendOn( htid )
-- 	local isOn= false
-- 	local littleFriendInfo = _allFormationInfo.littleFriend

-- 	if( table.isEmpty(littleFriendInfo) ) then
-- 		return false
-- 	end

-- 	for i=1, #littleFriendInfo do
-- 		if( tonumber(littleFriendInfo[i].htid) == tonumber(htid)) then
-- 			isOn = true
-- 			break
-- 		end
-- 	end

-- 	return isOn

-- end
-- 通过htid判断小伙伴中是否存在某一类武将
function isLittleFriendOn( htid )
	local isOn= false
	local littleFriendInfo = _allFormationInfo.littleFriend

	if( table.isEmpty(littleFriendInfo) ) then
		return false
	end

	for i=1, #littleFriendInfo do
		local modelId = DB_Heroes.getDataById(tonumber(littleFriendInfo[i].htid)).model_id
		if( tonumber(modelId) == tonumber(htid)) then
			isOn = true
			break
		end
	end

	return isOn

end

function isSecFriendOn(p_htid)
	local isOn = false
	local secFriendInfo = _allFormationInfo.attrFriend

	if (table.isEmpty(secFriendInfo)) then
		return false
	end

	for i = 1,#secFriendInfo do
		local modelId = DB_Heroes.getDataById(tonumber(secFriendInfo[i].htid)).model_id
		if tonumber(modelId) == tonumber(p_htid) then
			isOn = true
			break
		end
	end

	return isOn
end

-- 获得ItemSprite，显示头像和等级 
function getItemSprite(armTable )
	local eQuality = ItemUtil.getEquipQualityByItemInfo( armTable )
	print("eQualityeQuality ",eQuality)
	--local ItemSprite = ItemSprite.getItemSpriteById(armTable.item_template_id,nil,itemDelegateAction, nil,-1011,19001)
	--local ItemSprite =  ItemSprite.getItemSpriteById(armTable.item_template_id, nil, itemDelegateAction, nil, -1011, 19001, nil, nil, nil, nil,nil,nil,nil,nil,armTable,eQuality)
	local ItemSprite =  ItemSprite.getItemSpriteById(armTable.item_template_id, nil, itemDelegateAction, nil, -1011, 19001, nil, nil, nil, nil, nil,nil,nil,nil,nil,armTable,eQuality)

	--local equipDesc = ItemUtil.getItemById(tonumber(armTable.item_template_id))
	--local nameColor = HeroPublicLua.getCCColorByStarLevel(equipDesc.quality)
	
	-- 强化等级
	local lvSprite = CCSprite:create("images/base/potential/lv_" .. eQuality .. ".png")
	lvSprite:setAnchorPoint(ccp(0,1))
	lvSprite:setPosition(ccp(-1, ItemSprite:getContentSize().height))
	ItemSprite:addChild(lvSprite)
	local armReinforceLevel =  tonumber(armTable.va_item_text.armReinforceLevel)   or 0
	local lvLabel =  CCRenderLabel:create("" .. armReinforceLevel , g_sFontName, 18, 1, ccc3( 0, 0, 0), type_stroke)
    lvLabel:setColor(ccc3(255,255,255))
    lvLabel:setAnchorPoint(ccp(0.5,0.5))
    lvLabel:setPosition(ccp( lvSprite:getContentSize().width*0.5, lvSprite:getContentSize().height*0.5))
    lvSprite:addChild(lvLabel)

    return ItemSprite
end

function getTreasureItem( treasureTable )
	--local ItemSprite = ItemSprite.getItemSpriteById(treasureTable.item_template_id,nil,itemDelegateAction, nil,-1011,19001)
	local ItemSprite = ItemSprite.getItemSpriteById( 
		treasureTable.item_template_id, nil , itemDelegateAction, nil, -1011, 19001, nil, nil, nil, nil, nil,nil,nil,treasureTable,true)
	local treasQuality = ItemUtil.getTreasureQualityByItemInfo( treasureTable )
	print("treasQualitytreasQualitytreasQuality",treasQuality)
	local equipDesc = ItemUtil.getItemById(tonumber(treasureTable.item_template_id))
	local nameColor = HeroPublicLua.getCCColorByStarLevel(treasQuality)

	-- 强化等级
	local lvSprite = CCSprite:create("images/base/potential/lv_" .. treasQuality .. ".png")
	lvSprite:setAnchorPoint(ccp(0,1))
	lvSprite:setPosition(ccp(-1, ItemSprite:getContentSize().height))
	ItemSprite:addChild(lvSprite)
	local armReinforceLevel =  tonumber(treasureTable.va_item_text.treasureLevel)  or 0
	local lvLabel =  CCRenderLabel:create("" .. armReinforceLevel , g_sFontName, 18, 1, ccc3( 0, 0, 0), type_stroke)
    lvLabel:setColor(ccc3(255,255,255))
    lvLabel:setAnchorPoint(ccp(0.5,0.5))
    lvLabel:setPosition(ccp( lvSprite:getContentSize().width*0.5, lvSprite:getContentSize().height*0.5))
    lvSprite:addChild(lvLabel)

    if(treasureTable.va_item_text.treasureEvolve) then
    	local evolve_level = math.ceil(treasureTable.va_item_text.treasureEvolve)
		local treasureEvolveLabel = CCRenderLabel:create(evolve_level,  g_sFontName , 21, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
		treasureEvolveLabel:setColor(ccc3(0x00, 0xff, 0x18))
		treasureEvolveLabel:setAnchorPoint(ccp(1, 0))
		treasureEvolveLabel:setPosition(ccp( ItemSprite:getContentSize().width*0.9, ItemSprite:getContentSize().height*0.05))
		ItemSprite:addChild(treasureEvolveLabel)

		-- 精炼等级
		local treasureEvolveSprite = CCSprite:create("images/common/gem.png")
		treasureEvolveSprite:setAnchorPoint(ccp(1, 0))
		treasureEvolveSprite:setPosition(ccp(ItemSprite:getContentSize().width*0.9 - treasureEvolveLabel:getContentSize().width, ItemSprite:getContentSize().height*0.05))
		ItemSprite:addChild(treasureEvolveSprite)
    end

    local targetSprite = CCSprite:create()--CCLayerColor:create(ccc4(12,12,12,255))
    targetSprite:setContentSize(ItemSprite:getContentSize())
    --targetSprite:setBgColor(ccc4(12,12,12,255))
    -- 按钮Bar
	local menuBar = BTSensitiveMenu:create()
	menuBar:ignoreAnchorPointForPosition(false)
	menuBar:setAnchorPoint(ccp(0,0))
	menuBar:setPosition(ccp(0, 0))
	menuBar:setTouchPriority(-1011)
	targetSprite:addChild(menuBar)

    local clickBtnAction = function ( ... )
		require "script/ui/item/TreasureInfoLayer"
		local treasInfoLayer = TreasureInfoLayer:createWithItemId(treasureTable.item_id,  TreasInfoType.OTHER_FORMATION_TYPE)
		treasInfoLayer:show(-1012, 19003)
    end
	-- 按钮
	local item_btn = CCMenuItemSprite:create(ItemSprite,ItemSprite)
	item_btn:registerScriptTapHandler(clickBtnAction)
	item_btn:setAnchorPoint(ccp(0.5, 0.5))
	item_btn:setPosition(ccp(targetSprite:getContentSize().width/2, targetSprite:getContentSize().height/2))
	menuBar:addChild(item_btn)

    return targetSprite
    --return ItemSprite
end


-- 得到战魂的按钮
function getFightSoulItem( fightSoul,p_pos)
	
	-- print("fightSoul is :++++++++++++++++++++++ ")
	-- print_t(fightSoul)

	     -- dictionary{
      --                                                         item_id : "64959332"
      --                                                         item_template_id : "70306"
      --                                                         item_time : "1399674695.000000"
      --                                                         va_item_text : 
      --                                                             dictionary{
      --                                                                 fsLevel : "35"
      --                                                                 fsExp : "239060"
      --                                                             }

	-- local ItemSprite= ItemSprite.getItemSpriteById(fightSoul.item_template_id, nil, itemDelegateAction, nil, -1011, 19001, nil, nil, false, nil, nil,nil,nil,nil,false)--fightSoul.item_template_id,nil,itemDelegateAction, nil,-1011,19001,-1020,nil,false)
	local ItemSprite = ItemSprite.getItemSpriteByItemId( fightSoul.item_template_id )
	local equipDesc = ItemUtil.getItemById(tonumber(fightSoul.item_template_id))
	local nameColor = HeroPublicLua.getCCColorByStarLevel(equipDesc.quality)
	local e_nameLabel =  CCRenderLabel:create(equipDesc.name , g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    e_nameLabel:setColor(nameColor)
    e_nameLabel:setAnchorPoint(ccp(0.5, 0))
    e_nameLabel:setPosition(ccp( ItemSprite:getContentSize().width/2, -ItemSprite:getContentSize().height*0.1))
    ItemSprite:addChild(e_nameLabel, 111)

    local lvSprite = CCSprite:create("images/common/f_level_bg.png")
	lvSprite:setAnchorPoint(ccp(0,0))
	lvSprite:setPosition(ccp(ItemSprite:getContentSize().width*0.5, ItemSprite:getContentSize().height*0))
	ItemSprite:addChild(lvSprite,11)
	-- 等级
	local lvLabel = CCRenderLabel:create( fightSoul.va_item_text.fsLevel ,  g_sFontName , 18, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	lvLabel:setColor(ccc3(0xff, 0xff, 0xff))
	lvLabel:setAnchorPoint(ccp(0.5, 0.5))
	lvLabel:setPosition(ccp( lvSprite:getContentSize().width*0.45, lvSprite:getContentSize().height*0.6))
	lvSprite:addChild(lvLabel)

	local retNode = CCNode:create()
	retNode:setContentSize(ItemSprite:getContentSize())

	local itemMenu = BTSensitiveMenu:create()
	--itemMenu:setScrollView(p_tableView)
	itemMenu:setContentSize(retNode:getContentSize())
	itemMenu:ignoreAnchorPointForPosition(false)
	itemMenu:setTouchPriority(-1011)
	itemMenu:setAnchorPoint(ccp(0,0))
	itemMenu:setPosition(ccp(0,0))
	retNode:addChild(itemMenu)

	local menuItem = CCMenuItemSprite:create(ItemSprite,ItemSprite)
	menuItem:setAnchorPoint(ccp(0,0))
	menuItem:setPosition(ccp(0,0))
	itemMenu:addChild(menuItem,1,p_pos)
	menuItem:registerScriptTapHandler(soulCb)

	return retNode
    --return ItemSprite
end
--点击战魂的回调
function soulCb( p_pos)

	local fightSoul= _formationInfo[_curIndex].equipInfo.fightSoul
	if( not table.isEmpty(fightSoul) and not table.isEmpty(fightSoul[""..p_pos])) then
		require "script/ui/huntSoul/SoulInfoLayer"
		print("fightSoul[..p_pos])")
		print_t(fightSoul[""..p_pos])
		SoulInfoLayer.showLayer(fightSoul[""..p_pos].item_template_id, nil, nil, nil, p_pos, -1020, 19001,fightSoul[""..p_pos],nil,_formationInfo[1].level)
	end
end

function hasTreasure( item_template_id,p_index)
	local isHas = false
	--print("p_index",p_index)
    local curIndex = p_index or _curIndex
    -- print("_curIndex",_curIndex)
    -- print("curIndex",curIndex)
	if( not table.isEmpty(_formationInfo[curIndex]) and not table.isEmpty(_formationInfo[curIndex].equipInfo) and not table.isEmpty(_formationInfo[curIndex].equipInfo.treasure) ) then
		for k, treasure in pairs(_formationInfo[curIndex].equipInfo.treasure) do
			-- print("treasure item_template_id is : ", treasure.item_template_id)
			if(tonumber( treasure.item_template_id) == tonumber(item_template_id)) then
				isHas = true
				break
			end
		end
	end
	return isHas
end

-- 判断当前的武将是否装备的该装备
function hasEquipt( item_template_id)
	local isHas = false

	if( not table.isEmpty(_formationInfo[_curIndex]) and not table.isEmpty(_formationInfo[_curIndex].equipInfo)  and  not table.isEmpty(_formationInfo[_curIndex].equipInfo.arming) ) then
		for k, equipt in pairs(_formationInfo[_curIndex].equipInfo.arming) do
			if(tonumber( equipt.item_template_id) == tonumber(item_template_id)) then
				isHas = true
				break
			end
		end
	end
	-- print("isHas  is : equipt  " ,isHas)
	-- print("item_template_id is : ", item_template_id)
	return isHas
end

-- 得到小伙伴的icon
function getFriendItem(  )

	local potentialBgName = "images/formation/potential/officer_11.png"
	local  headIconName = "images/formation/littlef_icon.png"

	local frame= CCSprite:create(potentialBgName)
	local headIcon= CCSprite:create(headIconName)
	headIcon:setPosition(ccp(frame:getContentSize().width/2, frame:getContentSize().height/2))
	headIcon:setAnchorPoint(ccp(0.5,0.5))
	frame:addChild(headIcon)

	local headItem= CCMenuItemSprite:create(frame, frame)

	return headItem

end


-- 得到宠物的icon
function getPetItem(  )

	local potentialBgName = "images/formation/potential/officer_11.png"
	local  headIconName = "images/pet/chongwu.png"

	local frame= CCSprite:create(potentialBgName)
	local headIcon= CCSprite:create(headIconName)
	headIcon:setPosition(ccp(frame:getContentSize().width/2, frame:getContentSize().height/2))
	headIcon:setAnchorPoint(ccp(0.5,0.5))
	frame:addChild(headIcon)

	local headItem= CCMenuItemSprite:create(frame, frame)

	return headItem

end

-- 得阵法的icon
function getWarcraftItem(  )

	local potentialBgName = "images/formation/potential/officer_11.png"
	local  headIconName = "images/warcraft/warcraft_icon.png"

	local frame= CCSprite:create(potentialBgName)
	local headIcon= CCSprite:create(headIconName)
	headIcon:setPosition(ccp(frame:getContentSize().width/2, frame:getContentSize().height/2))
	headIcon:setAnchorPoint(ccp(0.5,0.5))
	frame:addChild(headIcon)

	local headItem= CCMenuItemSprite:create(frame, frame)

	return headItem

end



-- 判断主角是否上阵
function isMainHeroOnFormation( )
	local isOn=false
	for k,formation in pairs(_formationInfo) do
		if(tonumber(formation.htid) == 20001 or tonumber(formation.htid) == 20002 ) then
			isOn= true
			return isOn
		end
	end
	return isOn
end


function getMainHeroInfo( )
	local mainHeroInfo = {}
	for i=1, #_formationInfo do
		if( HeroModel.isNecessaryHero(tonumber( _formationInfo[i].htid)) ) then
			mainHeroInfo= _formationInfo[i]
			break
		end
	end
	return mainHeroInfo
end

-- 判断是否有小伙伴
--策划要求修改小伙伴，因此，除了宠物一直都是true
function hasFriend( )
	local has= false

	if( _isNpc) then
		return false
	end

	if(  not table.isEmpty(_allFormationInfo) and not table.isEmpty(_allFormationInfo.littleFriend ) ) then
		has = true
	end
	return true
end


-- 得到小伙伴信息，
function getFreiendInfo( )

	return  _allFormationInfo.littleFriend
end



--[[
	@des 	:得到该位置上的hid  hid为0时改位置没有上阵武将
	@param 	:position:位置 从1开始 1-6
	@return :返回hid，   >0 是英雄hid，0是没有英雄，-1是未开启
--]]
function getHeroInfoFromPosition( position )
	local heroInfo= {} 
	heroInfo.hid = -1
	local data = _allFormationInfo.littleFriend --getLittleFriendeData()
	print("getHeroInfoFromPosition")
	print_t(_allFormationInfo.littleFriend)
	if(data == nil)then
		return heroInfo
	end
	for i=1, #data do

		if( tonumber(data[i].position)+1 == position) then
			heroInfo= data[i]
			heroInfo.localInfo= DB_Heroes.getDataById(tonumber(heroInfo.htid) )
		end
	end

	-- for k,v in pairs(data) do
	-- 	if(tonumber(k) == tonumber(position))then
	-- 		hid = tonumber(v)
	-- 	end
	-- end
	return heroInfo
end



--[[
	@des 	:得到该位置的开启等级
	@param 	:position:位置 从1开始 1-6
	@return :lv -1:配置中没有开放该位置
--]]
function getOpenLv( position )
	local lv = -1
	require "db/DB_Formation"
	local data = DB_Formation.getDataById(1)
	local tab = string.split(data.openFriendByLv,",")
	for k,v in pairs(tab) do
		local t_data = string.split(v,"|")
		-- print("position",position,"t_data[2]",t_data[2])
		if(tonumber(position) == tonumber(t_data[2]))then
			lv = tonumber(t_data[1])
			break
		end
	end
	-- print("lv",lv)
	return lv
end



--[[
	@des 	:得到该位置是否开启
	@param 	:position:位置 从1开始 1-6
	@return :开启ture，没开启false
--]]
function getIsOpenThisPosition( position )
	local mainHeroInfo= getMainHeroInfo()
	local heroLv = tonumber(mainHeroInfo.level) or UserModel.getHeroLevel()
	local openLv = getOpenLv(position)
	if(openLv == -1 or heroLv < openLv)then
		return false
	else
		return true
	end
end


-- 策划要求修改宠物，因此，除了宠物一直都是true
-- 
function hasPet( )
	local has= false

	if( _isNpc) then
		return false
	end

	if( not table.isEmpty(_allFormationInfo) and not table.isEmpty(_allFormationInfo.arrPet) ) then
		has= true
	end

	-- return has
	return true
end

--  得到上阵宠物的信息
function getPetInfo(  )


	local petInfo=  _allFormationInfo.arrPet[1]
	if(petInfo == nil) then
		return nil
	else
		petInfo.petDesc= DB_Pet.getDataById(petInfo.pet_tmpl)
	end
	return petInfo
end

-- 得到增加的宠物技能
function getAddSkillByTalent( )
	local addSkill= {addNormalSkillLevel = 0, addSpecialSkillLevel=0 }

	local skillTalent = _allFormationInfo.arrPet[1].arrSkill.skillTalent

	for k,v in pairs (skillTalent) do

        local petSkill= tonumber(v.id)
        local skillData= DB_Pet_skill.getDataById(petSkill)
        -- if(isSkillEffect(petSkill, tonumber(pet_tmpl) ))then
            if(skillData.addNormalSkillLevel ) then               
                addSkill.addNormalSkillLevel= addSkill.addNormalSkillLevel+ tonumber(skillData.addNormalSkillLevel)             
            end

            if(skillData.addSpecialSkillLevel ) then
                addSkill.addSpecialSkillLevel= addSkill.addSpecialSkillLevel+ tonumber(skillData.addSpecialSkillLevel)
            end
        -- end
    end
	return addSkill

end

--获得宠物的加成属性
function getPetValue( )


	local petProperty= {}

	if( table.isEmpty(_allFormationInfo.arrPet[1]) or _allFormationInfo.arrPet[1]== nil ) then
		return petProperty
	end

	local petInfo= _allFormationInfo.arrPet[1]
	
	local skillNormal = petInfo.arrSkill.skillNormal
	print("RivalInfoData petInfo")
	print_t(skillNormal)
	
	local addNormalSkillLevel = getAddSkillByTalent().addNormalSkillLevel
	 print("addNormalSkillLevel")
    print_t(addNormalSkillLevel)

    -- 宠物进阶的技能等级加成
    local evolveLv = tonumber(petInfo.evolveLevel) or 0
    local evolveAddSkillLv = PetData.getPetEvolveSkillLevel(petInfo,evolveLv)
    print("RivalInfoData getPetValue evolveAddSkillLv => ",evolveAddSkillLv)

	local retTable= {}
	local tInfo = {}
	

	for i=1, table.count(skillNormal) do
		local skillId, level = tonumber(skillNormal[i].id), tonumber(skillNormal[i].level)+addNormalSkillLevel+evolveAddSkillLv

		if(skillId >0) then	
			local skillProperty= PetUtil.getNormalSkill(skillId, level ) 
			table.insert(tInfo , skillProperty)
		end
	end
	print("tInfo")
    print_t(tInfo)
	for i=1,#tInfo do
		for j=1,#tInfo[i] do
			local v = tInfo[i][j]
			if(retTable[tostring(v.affixDesc[1])] == nil) then
				retTable[tostring(v.affixDesc[1])] = v
			else
				retTable[tostring(v.affixDesc[1])].realNum = retTable[tostring(v.affixDesc[1])].realNum + v.realNum
				retTable[tostring(v.affixDesc[1])].displayNum = retTable[tostring(v.affixDesc[1])].displayNum + v.displayNum
			end
			-- if(retTable[] )
			
		end
	end

	for k,v in pairs( retTable) do
		table.insert(petProperty, v)
	end
	 print("petProperty")
    print_t(petProperty)
	return petProperty
end

-- 得到宠物战斗力，前端显示用
function getPetFightForce( )

	local fightForceNumber = 0

	local petInfo= _allFormationInfo.arrPet[1]
	local skillNormal = petInfo.arrSkill.skillNormal
	local skillNormal = petInfo.arrSkill.skillNormal
	local skillTalent = petInfo.arrSkill.skillTalent
	local skillProduct= petInfo.arrSkill.skillProduct
	print("petInfoOther")
	print_t(petInfo)
	-- 进阶数值
	local evolveLevel = petInfo.evolveLevel
	if(evolveLevel)then
		evolveLevel = tonumber(evolveLevel)
	end
	-- 培养数值
	local confirmed = petInfo.confirmed
	local confirmedTotalValue = 0
	require "script/ui/pet/PetData"
	local limitValue = getAttrLimitValue(petInfo)
	-- print("limitValue1111",limitValue)
	if(not table.isEmpty(confirmed))then
		for k,affixValue in pairs(confirmed) do
			affixValue = tonumber(affixValue)
			-- 如果宠物属性值大于当前进阶等级所能培养的最大属性值
			if affixValue > limitValue then
				affixValue = limitValue
			end
			confirmedTotalValue = confirmedTotalValue + tonumber(affixValue)
		end
	end

	local addTable = getAddSkillByTalent()
	local addNormal = addTable.addNormalSkillLevel 
	local addSpecial = addTable.addSpecialSkillLevel 

	-- 宠物进阶的技能等级加成
    local evolveAddSkillLv = PetData.getPetEvolveSkillLevel(petInfo,evolveLevel or 0)
    print("RivalInfoData getPetFightForce evolveAddSkillLv => ",evolveAddSkillLv)


	-- 普通技能
	for i=1, table.count( skillNormal) do
		local skillId= tonumber(skillNormal[i].id)
		if( skillId ~= 0 and DB_Pet_skill.getDataById(skillId).fightForce) then
			local fightForce = DB_Pet_skill.getDataById(skillId).fightForce
			fightForce= fightForce* tonumber(skillNormal[i].level + addNormal + evolveAddSkillLv)
			fightForceNumber= fightForceNumber+ fightForce
		end
	end

	-- 特殊技能
	for i=1, table.count( skillProduct) do
		local skillId= tonumber(skillProduct[i].id)
		if( skillId ~= 0 and DB_Pet_skill.getDataById(skillId).fightForce) then
			local fightForce = DB_Pet_skill.getDataById(skillId).fightForce
			fightForce= fightForce* tonumber(skillProduct[i].level + addSpecial)
			fightForceNumber= fightForceNumber+ fightForce
		end
	end

	-- 天赋技能
	for i=1, table.count( skillTalent) do
		local skillId= tonumber(skillTalent[i].id)
		if( skillId ~= 0 and DB_Pet_skill.getDataById(skillId).fightForce) then
			local fightForce = DB_Pet_skill.getDataById(skillId).fightForce
			fightForce= fightForce* tonumber(skillTalent[i].level )
			fightForceNumber= fightForceNumber+ fightForce
		end
	end

	if(evolveLevel and evolveLevel >= 1)then	
		require "db/DB_Pet_cost"
	    local costTable = DB_Pet_cost.getDataById(1)
		local evolveFightForce = costTable.evolveFightForce
		evolveFightForce = string.split(evolveFightForce,"|")
		for i=1,evolveLevel do
			-- print("fightForceNumber + evolveFightForce[i]",evolveFightForce[i])
			fightForceNumber = fightForceNumber + evolveFightForce[i]
		end
	end
	-- print("confirmedTotalValue",confirmedTotalValue)
	if(confirmedTotalValue > 0)then
		require "db/DB_Pet_cost"
	    local costTable = DB_Pet_cost.getDataById(1)
		local potentialityFightForce = costTable.PotentialityFightForce
		fightForceNumber = fightForceNumber + math.floor(potentialityFightForce * confirmedTotalValue / 10)
	end

	return fightForceNumber

end

function getAttrLimitValue( pPetInfo )
	-- body
	local evolveLevel = tonumber(pPetInfo.evolveLevel) or 0
	local ValuePotentiality = pPetInfo.petDesc.ValuePotentiality
	local valueStrAry = string.split(ValuePotentiality,",")
	for i,valueStr in ipairs(valueStrAry) do
		local valueLimitAry = string.split(valueStr,"|")
		if evolveLevel <= tonumber(valueLimitAry[1]) then
			limitValue = tonumber(valueLimitAry[2])
			break
		end
	end
	return tonumber(limitValue)
end


--[[
	@des: 得到战马品质
--]]
function getHorseQuality( p_hid )
	require "db/DB_Item_treasure"
	local heroInfo = getNpcHeroByHid(p_hid)
	local treasureInfo = heroInfo.equipInfo.treasure
	local horseTid = nil
	if(treasureInfo["1"] ~= nil and treasureInfo["1"].item_template_id ~= nil) then
		horseTid = treasureInfo["1"].item_template_id
		if(tonumber(horseTid) == 501002) then
			return 0
		end
		local quality = ItemUtil.getTreasureQualityByItemInfo(treasureInfo["1"])
		return quality
	else
		return 0
	end
end

--[[
	@des: 得到兵书品质
--]]
function getBookQuality( p_hid )
	require "db/DB_Item_treasure"
	local heroInfo = getNpcHeroByHid(p_hid)
	local treasureInfo = heroInfo.equipInfo.treasure
	print("heroInfo.equipInfo.treasure")
	print_t(heroInfo.equipInfo.treasure)
	local bookTid = nil
	if(treasureInfo["2"] ~= nil and treasureInfo["2"].item_template_id ~= nil) then
		bookTid = treasureInfo["2"].item_template_id
		if(tonumber(bookTid) == 502002) then
			return 0
		end
		local quality = ItemUtil.getTreasureQualityByItemInfo(treasureInfo["2"])
		return quality
	else
		return 0
	end
end


function getNpcHeroByHid( p_hid )
	local npcHero = nil
	for k,v in pairs(_allFormationInfo.arrHero) do
		if tonumber(v.hid) == tonumber(p_hid) then
			npcHero =  v
		end
	end
	if npcHero == nil then
		printTable("_allFormationInfo.arrHero", _allFormationInfo.arrHero)
		error("don't find npcHero", p_hid)
	end
	return npcHero
end

----------------第二套小伙伴相关  add by DJN 2015/3/18 ----------------
-- 判断是否有第二套小伙伴
function hasAttrFriend()
   	local has= false

	if( _isNpc) then
		return false
	end

	if(  not table.isEmpty(_allFormationInfo) and not table.isEmpty(_allFormationInfo.attrFriend ) ) then
		has = true
	end
	--return has
	return true
end

-- 得到第二套小伙伴的icon
function getAttrFriendItem(  )

	local potentialBgName = "images/formation/potential/officer_11.png"
	local  headIconName = "images/formation/second_icon.png"

	local frame= CCSprite:create(potentialBgName)
	local headIcon= CCSprite:create(headIconName)
	headIcon:setPosition(ccp(frame:getContentSize().width/2, frame:getContentSize().height/2))
	headIcon:setAnchorPoint(ccp(0.5,0.5))
	frame:addChild(headIcon)

	local headItem= CCMenuItemSprite:create(frame, frame)

	return headItem

end

-- 得到第二套小伙伴信息，
function getAttrFriendInfo( )
 -- attrFriend : 
 --                          array[ 
 --                              (0):
 --                                  dictionary{
 --                                      hid : "45214465"
 --                                      htid : "60032"
 --                                      position : "0"
 --                                      level : "53"
 --                                      evolve_level : "0"
 --                                      talent : 
 --                                          array[ 
 --                                          ]
 --                                  }
 --                              (1):
 --                                  dictionary{
 --                                      hid : "45215514"
 --                                      htid : "60007"
 --                                      position : "1"
 --                                      level : "91"
 --                                      evolve_level : "4"
 --                                      talent : 
 --                                          array[ 
 --                                          ]
 --                                  }
 --                              (2):
 --                                  dictionary{
 --                                      hid : "15931138"
 --                                      htid : "60006"
 --                                      position : "2"
 --                                      level : "95"
 --                                      evolve_level : "5"
 --                                      talent : 
 --                                          dictionary{
 --                                              1 : "3602"
 --                                              2 : "3510"
 --                                          }
 --                                  }
 --                          ]

	return  _allFormationInfo.attrFriend
end

--[[
	@des 	:获得第二套小伙伴增加的属性数组
	@param 	:
	@return :table
--]]
function getSecFriendAddAttrTab()
	require "db/DB_Formation"
	local dbInfo = DB_Formation.getDataById(1)
	local retTab = string.split(dbInfo.secondFriendsGetAffix, ",")
	return retTab
end
--[[
	@des 	:获得第二套小伙伴总个数
	@param 	:
	@return :num
--]]
function getSecFriendAllNum()
	require "db/DB_Secondfriends"
	local retNum = table.count(DB_Secondfriends.Secondfriends)
	return retNum
end



-- DB_Secondfriends.attribute "1|51|1000" 
-- 公式: (好感，天赋，觉醒，进化，进阶，强化，羁绊，基础属性)[id1] * id3/100 增加到属性id2上

--[[
	@des :得到第二套小伙伴阵上所有武将增加的属性
	@parm:  
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getTotalAffix( p_hid )
	local retAffix = {}
	-- 第二套小伙伴属性
	local secondFriendInfo = _allFormationInfo.attrFriend
	for k_pos,v_hid in pairs(secondFriendInfo) do
	  
		if(tonumber(v_hid.hid) ~= nil and  tonumber(v_hid.hid) > 0)then
			--local curAddtab = getOfferAffixByHid( v_hid.hid )
			local curAddtab = v_hid.attr
			--printTable("curAddtab",curAddtab)
			for k_affxid,v_num in pairs(curAddtab) do
				k_affxid = tonumber(k_affxid)
				if( retAffix[k_affxid] ~= nil)then
					retAffix[k_affxid] =  retAffix[k_affxid] + v_num
				else
					retAffix[k_affxid] =  v_num
				end
			end
		end
	end
	-- 遍历6个助战位，获取解锁的属性值
	for position=1,6 do
		local attributeAry = getSecFriendAddAttrByPos(position)
		for i,attribute in ipairs(attributeAry) do
			-- 解锁的属性值
			local affxid = tonumber(attribute[2])
			local extraAffixValue = getExtraAffix(position,affxid)
			if( retAffix[affxid] ~= nil)then
				retAffix[affxid] =  retAffix[affxid] + extraAffixValue
			else
				retAffix[affxid] =  extraAffixValue
			end
		end
	end
	--printTable("retAffix",retAffix)
	return retAffix
end
-------------------------------------助战位强化信息----------------------------
--[[
	@des 	:根据助战位的位置计算百分比加成
	@param  :pPos:助战位位置
	@return :
--]]
function getStageUpAffixPercentageByPos( pPos )
	-- 助战位增加的属性
	local addAttrAry = getSecFriendAddAttrByPos(pPos)
	-- 如果助战位已开启，并且已经强化过了，就加上助战位提升的属性百分比
	-- 该位置的助战位的等级
	local stageLevel = tonumber(_attrExtraLevelMap[pPos])
	local upAffixPercentage = 0
	if stageLevel > 0 then
		local upAffixAry = getUpAffix(pPos)
		upAffixPercentage = tonumber(upAffixAry[1][3]) / 100 * stageLevel
	end
	local percentage = tonumber(addAttrAry[1][3]) / 100 + upAffixPercentage
	return percentage
end
--[[
	@des 	: 助战位提升属性  -- upAffix 4|54|100,5|55|100
	@param 	: 
	@return : 
--]]

function getUpAffix( pIndex )	
	local secFriendsData = DB_Secondfriends.getDataById(pIndex)
	local upAffixStrAry = string.split(secFriendsData.upAffix,",")
	local upAffixAry = {}
	for i,v in ipairs(upAffixStrAry) do
		local ary = string.split(v,"|")
		table.insert(upAffixAry,ary)
	end
	return upAffixAry
end
--[[
	@des 	: 助战位解锁属性  -- extraAffix 20|51|5000,40|51|10000,50|51|25000
	@param 	: 
	@return : 解锁属性的数值
--]]
function getExtraAffix( pIndex,pAffxid )
	local extraAffixValue = 0
	-- 该位置的助战位的等级
	local stageLevel = tonumber(_attrExtraLevelMap[pIndex])
	if (stageLevel > 0) then
		local secFriendsData = DB_Secondfriends.getDataById(pIndex)
		local extraAffixStrAry = string.split(secFriendsData.extraAffix,",")
		for i,v in ipairs(extraAffixStrAry) do
			local ary = string.split(v,"|")
			if (stageLevel >= tonumber(ary[1])) then
				if tonumber(ary[2]) == pAffxid then
					extraAffixValue = extraAffixValue + tonumber(ary[3])
				end
			else
				break
			end
		end
	end
	return extraAffixValue
end
--[[
	@des 	: 获取指定位置的助战位等级
	@param 	: 
	@return : 
--]]
function getAttrExtraLevelByPos( pPos )
	-- body
	return _attrExtraLevelMap[pPos]
end
-------------------------------------助战位强化信息----------------------------

--[[
	@des 	:获得第二套小伙伴该位置增加的属性
	@param 	:p_index
	@return :table
--]]
function getSecFriendAddAttrByPos( p_index )
	local dbInfo = getDBdataByIndex(p_index)
	local temp = string.split(dbInfo.attribute, ",")
	local retTab = {}
	for k,v in pairs(temp) do
		local tab = string.split(v, "|")
		table.insert(retTab,tab)
	end
	return retTab
end
--[[
	@des 	:获得该位置配置信息
	@param 	:p_index
	@return :table
--]]
function getDBdataByIndex(p_index)
	require "db/DB_Secondfriends"
	local retData = DB_Secondfriends.getDataById(p_index)
	return retData
end


--[[
	@des 	:获得该位置的是否开启
	@param 	:p_index
	@return :false未开，true开了
--]]
function getIsOpenByPos( p_index )
	local retData = false
	local hid = getSecondFriendHidByPos(p_index)
	if( hid > -1)then
		retData = true
	end
	return retData
end

--[[
	@des 	:获得该位置的hid 
	@param 	:p_index
	@return :-1未开，0开了，N武将id
--]]
function getSecondFriendHidByPos( p_index )
	local secondInfo = _allFormationInfo.attrFriend
	local retHid = -1
	if( not table.isEmpty(secondInfo) )then
		for k,v in pairs(secondInfo) do
			if((tonumber(v.position) + 1 ) == p_index )then		
		    	retHid = tonumber(v.hid)
			end
		end
	end
	return retHid
end
--[[
	@des 	:获得该位置的武将信息
	@param 	:p_index
	@return :
--]]
function getSecondFriendInfoByPos( p_index )
	local secondInfo = _allFormationInfo.attrFriend
	local retHid = nil
	if( not table.isEmpty(secondInfo) )then
		for k,v in pairs(secondInfo) do
			if((tonumber(v.position) + 1 ) == p_index )then		
		    	return v
			end
		end
	end
	return retHid
end

--[[
	@des 	:获得属性的信息
	@param 	:p_attrId:属性id
	@return :table
--]]
function getAffixAttrInfoById( p_attrId )
	require "db/DB_Affix"
	local attrInfo = DB_Affix.getDataById(p_attrId)
	return attrInfo
end


--[[
	@des 	:通过hid得到这个第二套小伙伴的羁绊信息
	@param  :hid
	@return :羁绊数据
--]]
function getAttrUnionInfo(p_hid,p_htid)
	local hid = tonumber(p_hid)
	local htid = tonumber(p_htid)
	local heroInfo = HeroUtil.getHeroLocalInfoByHtid(htid)
	
	local returnTable = {}

	--local indexTable = getUnionIndexTable(p_hid)

	--DB表上该武将所有可以激活的羁绊id
	local linkString = heroInfo.link_group1
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
		--判断羁绊是否开启
		if( IsjudgeUnion( unionId, htid, hid ) )then
			innerTable.isOpen = true
		else
			innerTable.isOpen = false
		end

		table.insert(returnTable,innerTable)
	end

	return returnTable
end

-- --------------------------------------------------------------------
--通过itemId获取宝物信息  注意不是模板ID哦
function getTreasureByItemId( p_itemId)
	local p_itemId = tonumber(p_itemId) 
	local resultTab = {}
	for k,v in pairs(_formationInfo) do
		if(not table.isEmpty(v.equipInfo) and not table.isEmpty(v.equipInfo.treasure))then
			for k_index,v_treasureInfo in pairs(v.equipInfo.treasure) do
				if(tonumber(v_treasureInfo.item_id) == p_itemId )then
					table.hcopy(v_treasureInfo,resultTab)
					resultTab.itemDesc = ItemUtil.getItemById(v_treasureInfo.item_template_id)
					return resultTab
				end
			end
		end
	end
	return resultTab
end
-------------------------------------锦囊相关----------------------------
--是否开启锦囊入口
function isPocketOpen()
	-- if(_isPocketOpen ~= nil)then
	-- 	print("_isPocketOpen ~= nil")
	-- 	return _isPocketOpen
	-- end
	-- body
	require "db/DB_Normal_config"
	_isPocketOpen = false
	local normal_config = DB_Normal_config.getDataById(1)
    local limitLevel = string.split(normal_config.pocket_limit,",")
   -- print("_formationInfo[1],tonumber(limitLevel[1])",_formationInfo[1].level,tonumber(limitLevel[1]))
	if(tonumber(_formationInfo[1].level) >= tonumber(limitLevel[1]))then
		_isPocketOpen = true
	end
	return _isPocketOpen
end
-----------------------------------锦囊相关结束--------------------------

-------------------------------------兵符相关----------------------------
--是否开启兵符入口
function isTallyOpen()
	require "db/DB_Normal_config"
	local isTallyOpen = false
	local normal_config = DB_Normal_config.getDataById(1)
	-- 取第一个兵符开启条件
    local limitLevelStrAry = string.split(normal_config.bingfu_limit,",")
    limitLevel = (string.split(limitLevelStrAry[1],"|"))[2]
	if(tonumber(_formationInfo[1].level) >= tonumber(limitLevel))then
		isTallyOpen = true
	end
	return isTallyOpen
end

----
function isDestinyOpen(pInfo,pAllInfo)
	require "db/DB_Normal_config"
	local isDestinyOpen = false
	local heroInfo = HeroUtil.getHeroLocalInfoByHtid(pInfo.htid)
	if tonumber(heroInfo.star_lv)==7 and tonumber(pInfo.hid)~=tonumber(pAllInfo[1].hid)then
		isDestinyOpen = true
	end
	return isDestinyOpen
end

----
---------------------------------兵符相关结束--------------------------
-- 获取主角觉醒信息
function getMasterTalent( ... )
	if(table.isEmpty(_allFormationInfo))then
		return nil
	end
	return _allFormationInfo.masterTalent
end

------------------------------ 战车相关 --------------------------------
--[[
	@desc 	: 战车是否开启
	@param 	:
	@return : 是否开启战车
--]]
function isChariotOpen()
	require "db/DB_Normal_config"
	local normalConfigDb = DB_Normal_config.getDataById(1)
	local isChariotOpen = false
	-- DB_Normal_config 新增字段处理 装备战车位置及等级  
	-- 1|1|62,2|2|80 位置|类型|级别
	local warcarLvTab = parseField(normalConfigDb.warcar_lv,2)
	-- local warcarLvTab = nil
	-- 如果是 1|1|62 只开一个位置
	-- if (table.isEmpty(warcarLvInfo[1])) then
	-- 	warcarLvTab = {}
	-- 	warcarLvTab[1] = warcarLvInfo
	-- else
	-- 	warcarLvTab = warcarLvInfo
	-- end
	local needLevel = 0
	local chariotPosInfo = warcarLvTab[1]
	if (chariotPosInfo ~= nil) then
		needLevel = chariotPosInfo[3]
	end
	if(tonumber(_formationInfo[1].level) >= tonumber(needLevel))then
		isChariotOpen = true
	end

	print("----------- RivalInfoData isChariotOpen ----------")
	print(isChariotOpen)
	print("----------- RivalInfoData isChariotOpen ----------")

	return isChariotOpen
end

--[[
	@desc 	: 获取对方阵容战车item
	@param 	:
	@return : CCMenuItemSprite 战车item
--]]
function getChariotItem()
	local potentialBgName = "images/formation/potential/officer_11.png"
	local headIconName = "images/chariot/chariot_icon.png"

	local frame = CCSprite:create(potentialBgName)
	local headIcon = CCSprite:create(headIconName)
	headIcon:setPosition(ccp(frame:getContentSize().width/2, frame:getContentSize().height/2))
	headIcon:setAnchorPoint(ccp(0.5,0.5))
	frame:addChild(headIcon)

	local headItem = CCMenuItemSprite:create(frame, frame)

	return headItem
end
 
--[[
	@desc 	: 获取上阵战车的信息
	@param 	:
	@return : 上阵战车的信息
	user.getBattleDataOfUsers 接口添加 chariot，在主角的装备信息中 equipInfo => chariot
	*         chariot=>array
	*         	[
	*         	     pos=>array	
	*         			[
	*         				item_id:int
	*         				item_template_id:int
	*         				va_item_text:array	
	*         								[
	*         									chariotEnforce=>1      //强化等级
	* 											chariotDevelop=>1       //进阶等级
	*         								]
	*         			]
	*         	]
	* ]
--]]
function getChariotInfo()
	-- 获取主角信息
	local mainHeroInfo = getMainHeroInfo()
	if(mainHeroInfo == nil) then
		return nil
	end

	-- 获取主角装备信息
	local equipInfo = mainHeroInfo.equipInfo
	if(equipInfo == nil) then
		return nil
	end

	-- 获取装备战车信息
	local arrChariotInfo = equipInfo.chariot
	if(arrChariotInfo == nil) then
		return nil
	else
		-- 初始化 本地配置信息
		arrChariotInfo = {}
		require "script/ui/chariot/ChariotMainData"
		for k,v in pairs(equipInfo.chariot) do
			if (not table.isEmpty(v)) then
				arrChariotInfo[tonumber(k)] = ChariotMainData.parseNetChariot(v)
			end
		end
	end

	print("----------- RivalInfoData getChariotInfo ----------")
	print_t(arrChariotInfo)
	print("----------- RivalInfoData getChariotInfo ----------")

	return arrChariotInfo
end

--[[
	@desc   : 根据位置获取战车信息
    @param  : pPos 位置
    @return : 
--]]
function getChariotInfoByPos( pPos )
	local arrChariotInfo = getChariotInfo()
	local retData = nil
	if (not table.isEmpty(arrChariotInfo)) then
		retData = arrChariotInfo[pPos] or arrChariotInfo[tostring(pPos)]
    end
	return retData
end

--[[
	@desc 	: 根据战车物品id获取战车位置
	@param  : pItemId 战车物品id
    @return : 战车位置 没有就返回 0 
--]]
function getChariotPosByItemId( pItemId )
	local chariotPos = 0
	if (pItemId and pItemId > 0) then
		local arrChariotInfo = getChariotInfo()
		if (not table.isEmpty(arrChariotInfo)) then
			for k,v in pairs(arrChariotInfo) do
				if (tonumber(v.item_id) == tonumber(pItemId) ) then
					chariotPos = tonumber(k)
					break
				end
			end
		end
	end
	return chariotPos
end

-- 新增幻化id, add by lgx 20160928
--[[
	@desc 	: 根据武将id,获取武将的幻化id
	@param  : pHid 武将id
	@return : number 武将幻化id
--]]
function getHeroTurnIdByHid( pHid )
	local heroData = _heroIDAndInfoMap[pHid]
	local turnedId = 0
	if(not table.isEmpty(heroData)) then
		turnedId = heroData.turned_id
	end
	print("------ getHeroTurnIdByHid ------")
	print_t(heroData)
	print("------ getHeroTurnIdByHid ------")
	return turnedId
end
