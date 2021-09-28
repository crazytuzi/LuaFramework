-- Filename: IllustratUtil.lua
-- Author: zhz.
-- Date: 2013-1-21
-- Purpose: 该文件用于图鉴数据

module ("IllustratUtil", package.seeall)

-- require "script/ui/menu/IllustrateLayer"
require "db/DB_Show"
require "db/DB_Heroes"
require "script/ui/item/ItemUtil"
require "script/ui/item/ItemSprite"

_heroBookHtid = {}			-- 已有的武将的htid
_equiptBookTid= {}			-- 已有装备的htid
_treasBookTid= {}			-- 已有装备的htid

_heroNumTable = {}

-- 设置
function setHeroBook( heroBookHtid )
	_heroBookHtid = heroBookHtid
end

function getHeroBook( ... )
	return _heroBookHtid
end

function setEquiptBook(equiptBookTid )
	_equiptBookTid= equiptBookTid
end

function setTreasBookTid( treasBookTid)
	_treasBookTid= treasBookTid
end

function calHeroNumTableBy( )
	-- 计算魏国的hero
	local wei = 0
	local heroData = getHeroDataByIndex(1)
		if(not table.isEmpty(_heroBookHtid)) then
		for i =1, #heroData do
			for j =1 ,#_heroBookHtid do
				if( heroData[i] == _heroBookHtid[j]) then
					wei = wei+1
				end
			end
		end
	end
	_heroNumTable.wei = wei
	-- 蜀国
	local shu = 0
	local heroData = getHeroDataByIndex(2)
		if(not table.isEmpty(_heroBookHtid)) then
		for i =1, #heroData do
			for j =1 ,#_heroBookHtid do
				if( heroData[i] == _heroBookHtid[j]) then
					shu = shu+1
				end
			end
		end
	end
	_heroNumTable.shu = shu
	-- 吴国
	local wu = 0
	local heroData = getHeroDataByIndex(3)
		if(not table.isEmpty(_heroBookHtid)) then
		for i =1, #heroData do
			for j =1 ,#_heroBookHtid do
				if( heroData[i] == _heroBookHtid[j]) then
					wu = wu+1
				end
			end
		end
	end
	_heroNumTable.wu = wu
	-- 群
	local qun = 0
	local heroData = getHeroDataByIndex(4)
		if(not table.isEmpty(_heroBookHtid)) then
		for i =1, #heroData do
			for j =1 ,#_heroBookHtid do
				if( heroData[i] == _heroBookHtid[j]) then
					qun = qun+1
				end
			end
		end
	end
	_heroNumTable.qun = qun
end

-- 获得已经有的武将的数目
-- 1,魏国， 2 ：蜀国，3：吴国，4：群雄
function getHasHeroNumByIndex( index)
	local heroData = getHeroDataByIndex(index)
	local heroNum = 0
	if(not table.isEmpty(_heroBookHtid)) then
		for i =1, #heroData do
			for j =1 ,#_heroBookHtid do
				if( heroData[i] == _heroBookHtid[j]) then
					heroNum = heroNum+1
				end
			end
		end
	end
	return heroNum
end

-- 获得对应国家，对应星级的的武将数量
-- index : 1,魏国， 2 ：蜀国，3：吴国，4：群雄
-- starLv : 武将的星级
function getHasStarHeroNum( index, starLv )
	local heroData = getHeroDataByIndex(index)

	local heroNum = 0
	if(not table.isEmpty(_heroBookHtid)) then
		for i =1, #heroData do
			for j =1 ,#_heroBookHtid do
				if( heroData[i] == _heroBookHtid[j] and tonumber(DB_Heroes.getDataById(heroData[i]).star_lv)== tonumber(starLv)) then
					heroNum = heroNum+1
				end
			end
		end
	end
	return heroNum
end

-- 通过 index 获得所有武将的htid
-- 1,魏国， 2 ：蜀国，3：吴国，4：群雄
function getHeroDataByIndex( index )
	print("index is : ", index)
	local heroData = DB_Show.getDataById(index).item_array
	local heroData = string.gsub(heroData, " ", "")
	heroData = lua_string_split(heroData, ",")
	return heroData
end

-- 通过 index 和 starLv 获得所有武将的信息
-- index:1,魏国， 2 ：蜀国，3：吴国，4：群雄
-- starLv: 3星， 4 星， 5，星
function getStarHeroData(index, starLv )
	local heroData = getHeroDataByIndex(index)
	local heroTable= {}
	
	for i=1, #heroData do
	local heroInfo = DB_Heroes.getDataById(heroData[i]) 
		if(tonumber(heroInfo.star_lv) == tonumber(starLv) ) then
			table.insert(heroTable,heroInfo.id )
		end
	end
	return heroTable
end


-- 获得英雄的头像
function getHeroButton( htid)

	-- 判断是否获得过武将
	local boolExsit = false
	if(not table.isEmpty(_heroBookHtid)) then
		for i=1 ,#_heroBookHtid do
			if(tonumber(htid)== tonumber(_heroBookHtid[i]) ) then
				boolExsit = true
			end
		end
	end

	local headSprite =  HeroPublicCC.getCMISHeadIconFullByHtid(htid,(not boolExsit))
	-- 图鉴可查看未获得的武将 20160509 by lgx
	-- headSprite:setEnabled(boolExsit)

	-- if(boolExsit== false) then
	-- 	return getEnableIcon()
	-- end
	-- 名字背景
	-- local nameBgSprite = CCScale9Sprite:create("images/common/bg/name.png")
	-- nameBgSprite:setAnchorPoint(ccp(0.5, 1))
	-- nameBgSprite:setScale(0.8)
	-- nameBgSprite:setPosition(ccp(headSprite:getContentSize().width*0.5, -headSprite:getContentSize().height*0.01))
	-- headSprite:addChild(nameBgSprite)
	
	-- 名字
	local heroData = DB_Heroes.getDataById(htid)

	local nameColor --=  HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	if(boolExsit == true ) then
		nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	else
		nameColor = ccc3(0x64,0x64,0x64)
	end

	local nameLabel = CCRenderLabel:create("" .. heroData.name, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0.5, 1))
    nameLabel:setPosition(ccp(headSprite:getContentSize().width*0.5, -1))
    headSprite:addChild(nameLabel)

   	-- 兼容越南
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		nameLabel:setVisible(false)
	else
		nameLabel:setVisible(true)
	end
	
    return headSprite
end

-- 
--[[
	@des   	:通过index 获得装备的htid 的table ， 这里面策划偷懒，不愿修改表的内容，因此，DB_show也同样用在了装备和宝物
	@param  :index: 101 武器， 102 护甲， 103 头盔， 104 项链， 201 马， 202 书
	@return	: 对应index 的所有的htid
]]
function getItemByIndex( index)
	print("index is : ", index)
	local equipt = DB_Show.getDataById(index).item_array
	local equptData = string.gsub(equipt, " ", "")
	equptData = lua_string_split(equptData, ",")
	return equptData
end

-- 通过 index 和 starLv 获得所有装备信息
-- index:index: 101 武器， 102 护甲， 103 头盔， 104 项链， 201 马， 202 书
-- starLv: 3星， 4 星， 5，星
function getStarItemData( index, starLv)
	local equipt = getItemByIndex(index)

	local equiptTable= {}
	for i=1, #equipt do
		local itemInfo = ItemUtil.getItemById(equipt[i]) --DB_Heroes.getDataById(equipt[i]) 
		if(tonumber(itemInfo.quality) == tonumber(starLv) ) then
			table.insert(equiptTable,itemInfo.id )
		end
	end
	return equiptTable
end

-- 获得已有的物品数量
-- 101 武器， 102 护甲， 103 头盔， 104 项链， 201 马， 202 书
-- curPicIndex：当前是在显示页：1：武将，2：装备，3：宝物 
function getHasItemNumByIndex( index , curPicIndex)
	local itemData = getItemByIndex(index)
	local itemNum = 0
	print("curPicIndex is : ", curPicIndex)
	if(not table.isEmpty(_equiptBookTid) and curPicIndex== 2) then
		for i =1, #itemData do
			for j =1 ,#_equiptBookTid do
				if( itemData[i] == _equiptBookTid[j]) then
					itemNum = itemNum+1
					print("itemNum is : ", itemNum)
				end
			end
		end
	end

	if(not table.isEmpty(_treasBookTid) and curPicIndex== 3) then
		for i =1, #itemData do
			for j =1 ,#_treasBookTid do
				if( itemData[i] == _treasBookTid[j]) then
					itemNum = itemNum+1
				end
			end
		end
	end
	return itemNum
end


-- 获得对应国家，对应星级的的item 数量
-- index : 101 武器， 102 护甲， 103 头盔， 104 项链， 201 马， 202 书
-- starLv : 武将的星级
-- curPicIndex：当前是在显示页：1：武将，2：装备，3：宝物 
function getHasStarItemNum( index, starLv , curPicIndex )
	local itemData = getItemByIndex(index)
	local itemNum = 0
	if(not table.isEmpty(_equiptBookTid) and curPicIndex== 2) then
		for i =1, #itemData do
			for j =1 ,#_equiptBookTid do
				local quality = ItemUtil.getItemById(_equiptBookTid[j]).quality
				if( itemData[i] == _equiptBookTid[j] and starLv == tonumber(quality) ) then
					itemNum = itemNum+1
				end
			end
		end
	end

	if(not table.isEmpty(_treasBookTid) and curPicIndex== 3) then
		for i =1, #itemData do
			for j =1 ,#_treasBookTid do
				local quality = ItemUtil.getItemById(_treasBookTid[j]).quality
				if( itemData[i] == _treasBookTid[j] and starLv == quality) then
					itemNum = itemNum+1
				end
			end
		end
	end
	return itemNum
end



function getItemButton(item_temple_id )
	
	-- 判断是否获得过item
	local boolExsit = false
	if(not table.isEmpty(_equiptBookTid)) then
		for i=1 ,#_equiptBookTid do
			if(tonumber(item_temple_id)== tonumber(_equiptBookTid[i]) ) then
				boolExsit = true
			end
		end
	end

	if(not table.isEmpty(_treasBookTid)) then
		for i=1 ,#_treasBookTid do
			if(tonumber(item_temple_id)== tonumber(_treasBookTid[i]) ) then
				boolExsit = true
			end
		end
	end

	-- print(" boolExsit  is : ", boolExsit)

	local headSprite = nil
	if boolExsit then
	 	headSprite = ItemSprite.getItemSpriteById(item_temple_id,nil,itemDelegateAction) --HeroPublicCC.getCMISHeadIconFullByHtid(item_temple_id)
	else
		headSprite = ItemSprite.getItemGraySpriteByItemId(item_temple_id,nil,true)
	end

	-- 名字背景
	-- local nameBgSprite = CCScale9Sprite:create("images/common/bg/name.png")
	-- nameBgSprite:setAnchorPoint(ccp(0.5, 1))
	-- nameBgSprite:setScale(0.8)
	-- nameBgSprite:setPosition(ccp(headSprite:getContentSize().width*0.5, -headSprite:getContentSize().height*0.01))
	-- headSprite:addChild(nameBgSprite)
	
	-- 名字
	local itemData =  ItemUtil.getItemById(item_temple_id) 

	local nameColor --=  HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	if(boolExsit == true ) then
		nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
	else
		nameColor = ccc3(0x64,0x64,0x64)
	end

	local nameLabel = CCRenderLabel:create("" .. itemData.name, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0.5, 1))
    nameLabel:setPosition(ccp(headSprite:getContentSize().width*0.5, -1))
    headSprite:addChild(nameLabel)

    -- 兼容越南
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		nameLabel:setVisible(false)
	else
		nameLabel:setVisible(true)
	end

    return headSprite
end

function itemDelegateAction(  )
	MainScene.setMainSceneViewsVisible(true, false, true)
end


-- 得到灰色的按钮
function getEnableIcon( )

	local potentialSprite = CCMenuItemImage:create("images/base/potential/props_1.png","images/base/potential/props_1.png") --CCSprite:create("images/base/potential/props_1.png")
	local headSprite  = CCSprite:create("images/common/ask.png")
	potentialSprite:setEnabled(false)
	headSprite:setAnchorPoint(ccp(0.5, 0.5))
	headSprite:setPosition(ccp(potentialSprite:getContentSize().width*0.5, potentialSprite:getContentSize().height*0.5))
	potentialSprite:addChild(headSprite)

	-- -- 名字的背景
	-- local nameBgSprite = CCScale9Sprite:create("images/common/bg/name.png")
	-- nameBgSprite:setAnchorPoint(ccp(0.5, 1))
	-- nameBgSprite:setScale(0.9)
	-- nameBgSprite:setPosition(ccp(potentialSprite:getContentSize().width*0.5, -potentialSprite:getContentSize().height*0.01))
	-- potentialSprite:addChild(nameBgSprite)

	-- 小问号
	local alertContent = {}
	alertContent[1] = CCSprite:create("images/common/ask.png")
	alertContent[1]:setScale(0.3)
	alertContent[2] = CCSprite:create("images/common/ask.png")
	alertContent[2]:setScale(0.3)
	alertContent[3]= CCSprite:create("images/common/ask.png")
	alertContent[3]:setScale(0.26)
	local nameNode = BaseUI.createHorizontalNode(alertContent)
	nameNode:setAnchorPoint(ccp(0.5,1))
	nameNode:setPosition(ccp(potentialSprite:getContentSize().width/2, -1))
	--nameNode:setContentSize(CCSizeMake(nameBgSprite:getContentSize().width,nameBgSprite:getContentSize().height))
	potentialSprite:addChild(nameNode)

	return potentialSprite
end

--[[
	@desc	: 根据 index 获得所有未开放的武将的htid
	@param	: pIndex 武将是哪国的 1魏，2蜀，3吴，4群
	@return	: table {htid,...}
--]]
function getNotOpenHeroDataByIndex( pIndex )
	local heroArr = nil
	if (DB_Show.getDataById(pIndex).not_open ~= nil) then
		heroArr = DB_Show.getDataById(pIndex).not_open
		heroArr = string.gsub(heroArr, " ", "")
		heroArr = lua_string_split(heroArr, ",")
	end
	return heroArr
end

--[[
	@desc	: 判断是否是未开放的武将
	@param	: pIndex 武将是哪国的 1魏，2蜀，3吴，4群
	@param	: pHtid 武将模板ID
	@return	: bool 是否未开放
--]]
function isNotOpenHero( pIndex, pHtid )
	local isNotOpen = false
	if (pIndex == 0 or pHtid == 0) then
		isNotOpen = false
	else
		local notOpenHeros = getNotOpenHeroDataByIndex(pIndex)
		if (not table.isEmpty(notOpenHeros)) then
			for i,v in ipairs(notOpenHeros) do
				if (pHtid == tonumber(v)) then
					isNotOpen = true
					break
				end
			end
		end
	end
	return isNotOpen
end
