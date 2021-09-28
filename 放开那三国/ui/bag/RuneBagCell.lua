-- FileName: RuneBagCell.lua 
-- Author: licong 
-- Date: 15/4/27 
-- Purpose: 符印背包cell


module("RuneBagCell", package.seeall)

require "script/ui/common/CheckBoxItem"
require "script/ui/item/ItemUtil"
require "script/model/utils/HeroUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/item/GodWeaponItemUtil"
require "script/libs/LuaCC"
require "script/ui/bag/RuneData"

local _callBack  			= nil -- 回调事件
local _selectList		 	= nil -- 选择的材料列表

--[[
	@des 	:初始化变量
	@param 	:
	@return :
--]]
function init( ... )
	_callBack  			= nil
	_selectList		 	= nil 
end
--------------------------------------------------------------- 按钮事件 ----------------------------------------------------------------------------------

--[[
	@des 	:检查被选择的材料
	@param 	:
	@return :
--]]
function handleSelectedCheckedBtn( checkedBtn )
	if(_selectList == nil)then
		return
	end
	if ( table.isEmpty(_selectList) ) then
		checkedBtn:unselected()
	else
		local isIn = false
		for k,item_id in pairs(_selectList) do
			if ( tonumber(item_id) == tonumber(checkedBtn:getTag()) ) then
				isIn = true
				break
			end
		end
		if (isIn) then
			checkedBtn:selected()
		else
			checkedBtn:unselected()
		end
	end
end
--------------------------------------------------------------- 创建cell ----------------------------------------------------------------------------------
--[[
	@des 	:创建cell
	@param 	:p_runeData:神兵数据, p_callBack:回调函数, p_isForMaterial:是否作为选择列表, p_isShowNum:是否显示分解数值, p_selectList:选择的列表数据,p_isIconTouch:图标是否可以点击
			 p_isNoBtn:为true时则没有按钮
	@return :
--]]
function createCell( p_runeData, p_callBack, p_isForMaterial, p_isShowNum, p_selectList, p_isIconTouch, p_isNoBtn  )
	init()

	_callBack = p_callBack
	_selectList = p_selectList

	local tCell = CCTableViewCell:create()
	-- 背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local cellBg = CCScale9Sprite:create("images/common/bg/bg_1.png",fullRect, insetRect)
    cellBg:setContentSize(CCSizeMake(635,170))
    cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,1)
	local cellBgSize = cellBg:getContentSize()

	-- icon 
	local iconSprite = nil
	if(p_isIconTouch == false)then
		iconSprite = ItemSprite.getItemSpriteByItemId( tonumber(p_runeData.item_template_id),nil,nil, tonumber(p_runeData.item_id))
	else
		iconSprite = ItemSprite.getItemSpriteById( tonumber(p_runeData.item_template_id), tonumber(p_runeData.item_id), nil,nil,nil,nil,nil,nil,nil,nil,true,nil,_callBack )
	end
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

	-- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(p_runeData.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)

	-- 名称
	local quality = p_runeData.itemDesc.quality
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local nameLabel = CCRenderLabel:create(p_runeData.itemDesc.name, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 0.5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

    -- 小背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local attrBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    attrBg:setContentSize(CCSizeMake(280,92))
    attrBg:setAnchorPoint(ccp(0,0))
    attrBg:setPosition(ccp(120,20))
    cellBg:addChild(attrBg)

    -- 分割线
    local line = CCScale9Sprite:create("images/common/line02.png")
    line:setContentSize(CCSizeMake(90,4))
    line:setAnchorPoint(ccp(0.5,0.5))
    line:setPosition(ccp(160,attrBg:getContentSize().height*0.5))
    attrBg:addChild(line)
    line:setRotation(90)

    -- 属性
    local attrTab = RuneData.getRuneAbilityByItemId(p_runeData.item_id)
	local posX = {0.05,0.05,0.05,0.05}
	local posY = {0.75,0.5,0.25,0}
	if(not table.isEmpty(attrTab) )then
		for k,v in pairs(attrTab) do
			local attrLabel = CCLabelTTF:create(v.name .. "+" .. v.showNum ,g_sFontName,23)
			attrLabel:setColor(ccc3(0x78, 0x25, 0x00))
			attrLabel:setAnchorPoint(ccp(0, 0.5))
			attrLabel:setPosition(ccp(attrBg:getContentSize().width*posX[k],attrBg:getContentSize().height*posY[k]))
			attrBg:addChild(attrLabel)
		end
	end

	-- 品级
    local starSp = CCSprite:create("images/god_weapon/pin.png")
    starSp:setAnchorPoint(ccp(0.5, 1))
    starSp:setPosition(ccp(220, attrBg:getContentSize().height))
    attrBg:addChild(starSp)

	-- 品级值
    local potentialLabel = CCRenderLabel:create(p_runeData.itemDesc.score, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setAnchorPoint(ccp(0.5,0.5))
    potentialLabel:setPosition(starSp:getPositionX(), 25)
    attrBg:addChild(potentialLabel)

    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar,1, 9898)
	
	if( p_isNoBtn ~= true )then
		if( p_isForMaterial )then 
			if( p_isShowNum )then
				-- -- 经验
				-- local expSprite = CCSprite:create("images/common/exp.png")
				-- expSprite:setAnchorPoint(ccp(0, 0.5))
				-- expSprite:setPosition(ccp(attrBg:getPositionX()+attrBg:getContentSize().width+10, cellBg:getContentSize().height*0.5))
				-- cellBg:addChild(expSprite)

				-- -- 提供的基础经验
				-- local baseExp = tonumber(p_runeData.itemDesc.giveexp)
				-- local expNumLabel = CCRenderLabel:create(baseExp+tonumber(p_runeData.va_item_text.reinForceExp), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
			 --    expNumLabel:setColor(ccc3(0x8a, 0xff, 0x00))
			 --    expNumLabel:setAnchorPoint(ccp(0,0.5))
			 --    expNumLabel:setPosition(ccp(expSprite:getPositionX()+expSprite:getContentSize().width+2, expSprite:getPositionY()))
			 --    cellBg:addChild(expNumLabel)
			end
	 
			-- 复选框
			local checkedBtn = CheckBoxItem.create()
			checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
		    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
			menuBar:addChild(checkedBtn, 1, tonumber(p_runeData.item_id) )
			-- 检查是否被选择
			handleSelectedCheckedBtn(checkedBtn)
		else
		
		end
	end

	-- 镶嵌于哪个宝物
	if( p_runeData.treasureItemId ~= nil )then
		local treasureItemId = p_runeData.treasureItemId
		local treasureData = ItemUtil.getItemByItemId(treasureItemId)
		local hid = nil
		if(treasureData == nil)then
			treasureData = ItemUtil.getTreasInfoFromHeroByItemId(treasureItemId)
			hid = treasureData.hid
		end
		if( table.isEmpty(treasureData.itemDesc) )then
			treasureData.itemDesc = ItemUtil.getItemById(treasureData.item_template_id)
		end
		local onFormationText =  CCRenderLabel:create(GetLocalizeStringBy("lic_1548") .. treasureData.itemDesc.name, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	    onFormationText:setColor(ccc3(0x8a, 0xff, 0x00))
	    onFormationText:setPosition(ccp(cellBgSize.width*0.6, cellBgSize.height*0.9))
	    cellBg:addChild(onFormationText)
	end

	return tCell
end






