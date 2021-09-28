-- Filename: ChariotCell.lua
-- Author: zhangqiang
-- Date: 2016-06-30
-- Purpose: 战车背包cell

module("ChariotCell", package.seeall)

require "script/ui/common/CheckBoxItem"
require "script/ui/item/ItemUtil"
require "script/model/utils/HeroUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/item/GodWeaponItemUtil"
require "script/libs/LuaCC"

local _btnOpenMenu = true       --右边打开按钮条的按钮

--[[
	@des 	:初始化变量
	@param 	:
	@return :
--]]
function init( ... )
	_btnOpenMenu  			= nil
end

--是否显示右边打开按钮条的按钮
function setOpenMenuBtnVisible( pVisible )
	if _btnOpenMenu == nil then
		return
	end

	_btnOpenMenu:setVisible(pVisible or false)
end


--------------------------------------------------------------- 按钮事件 ----------------------------------------------------------------------------------
--[[
	@des 	:强化按钮回调
	@param 	:
	@return :
--]]
function tapEnhanceBtnCb( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/godweapon/GodWeaponReinforceLayer"
	local item_id = tag

	-- AnimationTip.showTip("New Module Developing")

	require "script/ui/chariot/ChariotEnforceLayer"
	ChariotEnforceLayer.showWithChangeLayer(item_id)

	-- 记忆神兵背包位置
	BagLayer.setMarkGodWeaponItemId(item_id)
end 

--------------------------------------------------------------- 创建cell ----------------------------------------------------------------------------------
--[[
	@des 	:创建cell
	@param 	:pCellData:战车数据(数据格式为背包中的战车数据格式)
	         pIndex:cell的索引(当cell不需要下拉菜单时传入值小于0即可，并调用setOpenMenuBtnVisible方法隐藏掉打开下拉菜单的按钮)
	         pIconTouchEnabled:左边图标是否可以点击
	         pMenuTouchPriority:cell按钮上的优先级
	@return :
--]]
function createCell( pCellData, pIndex, pIconTouchEnabled, pMenuTouchPriority)
	-- print("pCellData==>")
	-- print_t(pCellData)
	
	init()

	-- _fnTapIcon = pFnTapIcon
	-- _selectList = p_selectList


	local tCell = CCTableViewCell:create()
	-- 背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local cellBg = CCScale9Sprite:create("images/common/bg/bg_1.png",fullRect, insetRect)
    cellBg:setContentSize(CCSizeMake(640,190))
    cellBg:setAnchorPoint(ccp(0.5,0))
    cellBg:setPosition(320,0)
	tCell:addChild(cellBg,1,1)
	local cellBgSize = cellBg:getContentSize()

	-- icon 
	local iconSprite = nil
	if(pIconTouchEnabled == false)then
		iconSprite = ItemSprite.getItemSpriteByItemId( tonumber(pCellData.item_template_id),nil,nil, tonumber(pCellData.item_id))
		-- iconSprite = ItemSprite.getItemSpriteByItemId(640001,nil,nil, 1001424)
	else
		iconSprite = ItemSprite.getItemSpriteById( tonumber(pCellData.item_template_id), tonumber(pCellData.item_id), nil,nil,nil,nil,nil,nil,nil,nil,false,nil)
	end
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

	-- 等级背景
	local fullRect = CCRectMake(0,0,46,23)
    local insetRect = CCRectMake(20,8,5,1)
	local lvBg = CCScale9Sprite:create("images/common/bg/name_1.png",fullRect, insetRect)
	lvBg:setContentSize(CCSizeMake(92,26))
	lvBg:setAnchorPoint(ccp(0,0))
	lvBg:setPosition(ccp(20,25))
	cellBg:addChild(lvBg)

	-- 等级
    local lvSp = CCSprite:create("images/common/lv.png")
    lvSp:setAnchorPoint(ccp(0,0.5))
    lvSp:setPosition(ccp(8,lvBg:getContentSize().height*0.5))
    lvBg:addChild(lvSp)
	-- 等级
	local levelLabel = CCRenderLabel:create(pCellData.va_item_text.chariotEnforce, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    levelLabel:setAnchorPoint(ccp(0,0.5))
    levelLabel:setPosition(ccp(lvSp:getPositionX()+lvSp:getContentSize().width+2, lvBg:getContentSize().height*0.5))
    lvBg:addChild(levelLabel)

	-- 名称
	local nameColor = HeroPublicLua.getCCColorByStarLevel(pCellData.itemDesc.quality)
	local nameLabel = CCRenderLabel:create(pCellData.itemDesc.name, g_sFontPangWa, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

    --是否已装备
    local bEquiped = ChariotMainData.isEquipedChariotByItemId( pCellData.item_id )
    if bEquiped then
    	local lbEquiped = CCRenderLabel:create(GetLocalizeStringBy("zq_0020"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    lbEquiped:setColor(ccc3(50, 239, 0))
	    lbEquiped:setAnchorPoint(ccp(0,0.5))
	    lbEquiped:setPosition(cellBg:getContentSize().width-132, cellBg:getContentSize().height-42)
	    cellBg:addChild(lbEquiped)
    end

	-- -- 品级值
 --    local potentialLabel = CCRenderLabel:create(pCellData.itemDesc.godarmrank, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
 --    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
 --    potentialLabel:setAnchorPoint(ccp(0,0.5))
 --    potentialLabel:setPosition(cellBgSize.width*350.0/640, cellBgSize.height*0.79)
 --    cellBg:addChild(potentialLabel)

	-- -- 品级
 --    local starSp = CCSprite:create("images/god_weapon/pin.png")
 --    starSp:setAnchorPoint(ccp(0, 0.5))
 --    starSp:setPosition(ccp(potentialLabel:getPositionX()+potentialLabel:getContentSize().width + 5, potentialLabel:getPositionY()))
 --    cellBg:addChild(starSp)


    -- 小背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local attrBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    attrBg:setContentSize(CCSizeMake(350,92))
    attrBg:setAnchorPoint(ccp(0,0))
    attrBg:setPosition(ccp(120,40))
    cellBg:addChild(attrBg)

	--添加属性UI
	addAttrs(attrBg, pCellData)

 --    -- 描述
 --    local lbDesc = CCLabelTTF:create(pCellData.itemDesc.desc, g_sFontName,23)
 --    lbDesc:setHorizontalAlignment(kCCTextAlignmentLeft)
	-- lbDesc:setColor(ccc3(0x78, 0x25, 0x00))
	-- lbDesc:setAnchorPoint(ccp(0, 1))
	-- lbDesc:setDimensions(CCSizeMake(260, 72))
	-- lbDesc:setPosition(ccp(10,attrBg:getContentSize().height-10))
	-- attrBg:addChild(lbDesc)



	-- 展开逻辑
	if(BagUtil.isSupportBagCell())then
		-- 展开背景高度
		local openBgHeight = 138
		local addHeight = openBgHeight-10
		-- 展开按钮
		local menu = CCMenu:create()
		menu:setPosition(ccp(0,0))
		if pMenuTouchPriority ~= nil then
			menu:setTouchPriority(pMenuTouchPriority)
		end
		cellBg:addChild(menu)

		local normal = CCMenuItemImage:create("images/common/down_btn_n.png", "images/common/down_btn_h.png")
		local hight  = CCMenuItemImage:create("images/common/up_btn_n.png", "images/common/up_btn_h.png")
		hight:setAnchorPoint(ccp(0.5, 0.5))
		normal:setAnchorPoint(ccp(0.5, 0.5))
		local openMenuItem = CCMenuItemToggle:create(normal)
		openMenuItem:setAnchorPoint(ccp(0.5, 0.5))
		openMenuItem:addSubItem(hight)
		menu:addChild(openMenuItem)
		openMenuItem:setPosition(ccp(cellBg:getContentSize().width*0.85,cellBg:getContentSize().height*0.45))
		openMenuItem:registerScriptTapHandler(function ( ... )
			-- 展开事件
			local selectIndex = openMenuItem:getSelectedIndex()
			-- print("selectIndex",selectIndex)
			local offsetNum = 0
			if(selectIndex == 0) then
				BagLayer.setOpenIndex(nil)
				offsetNum = -addHeight
			else
				BagLayer.setOpenIndex(pIndex)
				offsetNum = addHeight
			end
			BagLayer.refreshBagTableView(offsetNum,pIndex)
		end)
		_btnOpenMenu = openMenuItem

		-- 展开按钮
		local curOpneIndex = BagLayer.getOpenIndex()
		-- print("cell curOpneIndex",curOpneIndex,pIndex)
		if(pIndex == curOpneIndex)then
			openMenuItem:setSelectedIndex(1)
			local openBg = CCScale9Sprite:create("images/common/bg/bg_9s_11.png")
			openBg:setContentSize(CCSizeMake(600,openBgHeight))
	        openBg:setAnchorPoint(ccp(0.5,0))
	        openBg:setPosition(320,10)
	        tCell:addChild(openBg)
	        cellBg:setAnchorPoint(ccp(0.5,0))
			cellBg:setPosition(openBg:getPositionX(),addHeight)

			-- 按钮
			local buttnMenu = CCMenu:create()
			buttnMenu:setPosition(ccp(0,0))
			openBg:addChild(buttnMenu)
			local btnArr = {}
			local btnPosXArr = {0.85,0.68,0.51,0.34}
			local allOpen = true
			
		    -- 强化
		    local enhanceMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_s_n.png", "images/common/btn/btn_s_h.png",CCSizeMake(81, 76), GetLocalizeStringBy("lic_1422"),ccc3(0xff, 0xf2, 0x5d),24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			enhanceMenuItem:setAnchorPoint(ccp(0.5, 0.5))
			enhanceMenuItem:registerScriptTapHandler(tapEnhanceBtnCb)
			buttnMenu:addChild(enhanceMenuItem, 1, tonumber(pCellData.item_id))
			table.insert(btnArr,enhanceMenuItem)
			
			for i=1,#btnArr do
				if(allOpen)then
					btnArr[i]:setPosition(ccp(openBg:getContentSize().width*btnPosXArr[i], openBg:getContentSize().height*0.47))
				else
					btnArr[i]:setPosition(ccp(openBg:getContentSize().width*btnPosXArr[i], openBg:getContentSize().height*0.5))
				end
			end
		else
			openMenuItem:setSelectedIndex(0)
		end
	end

	return tCell
end

--[[
	@desc : 获取属性数组
	@param: pAttrMap = {
		attrTid = {
			num,
			order,
		},
		...
	}
	@ret  :
--]]
function toAttrArray( pAttrMap )
	local arrAttr = {}
	if table.isEmpty(pAttrMap) then
		return arrAttr
	end

	for nTid, nAttr in pairs(pAttrMap) do
		local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(nTid, nAttr.num)
		local tbAttr = {}
		tbAttr.displayNum = displayNum
		tbAttr.num = tonumber(nAttr.num)
		tbAttr.tid = tonumber(nTid)
		tbAttr.desc = affixDesc
		tbAttr.order = tonumber(nAttr.order)

		table.insert(arrAttr, tbAttr)
	end
	-- 策划说 属性要按表里配的顺序 攻击 生命 物防 法防
	table.sort(arrAttr,function (v1,v2)
    	return v1.order < v2.order
	end)

	return arrAttr
end

--[[
	@desc : 显示属性
	@param: 
	@ret  :
--]]
function addAttrs( pParentSp, pCellData )
	if pParentSp == nil or pCellData == nil then
		print("ChariotCell addAttrs pParentSp: ", pParentSp, " pCellData: ", pCellData)
		return
	end

	require "script/ui/chariot/ChariotMainData"
	local tbAllAttr = ChariotMainData.getChariotAttrInfoByTidAndLv(tonumber(pCellData.item_template_id), tonumber(pCellData.va_item_text.chariotEnforce))
	local arrAllAttr = toAttrArray(tbAllAttr)
	-- printTable("addAttrs ======= arrAllAttr", arrAllAttr)

	local cpOrigin, nNumPerRow, nRowHeight, nWidth = ccp(10, pParentSp:getContentSize().height-10), 2, 32, 163
	local c3Attr = ccc3(0x78, 0x25, 0x00)
	local nAttrNum = table.count(arrAttr)
	for nIdx, tbAttr in ipairs(arrAllAttr) do
		local nPosX, nPosY = cpOrigin.x+((nIdx+1)%nNumPerRow*nWidth), cpOrigin.y-(math.ceil(nIdx/nNumPerRow)-1)*nRowHeight

		local lbAttrName = CCLabelTTF:create(tbAttr.desc.displayName .. ":", g_sFontName, 23)
		lbAttrName:setColor(c3Attr)
		lbAttrName:setAnchorPoint(ccp(0,1))
		lbAttrName:setPosition(nPosX, nPosY)
		pParentSp:addChild(lbAttrName,1)

		local lbAttrNum = CCLabelTTF:create(tbAttr.displayNum, g_sFontName, 23)
		lbAttrNum:setColor(c3Attr)
		lbAttrNum:setAnchorPoint(ccp(0, 1))
		lbAttrNum:setPosition(nPosX+lbAttrName:getContentSize().width+5, nPosY)
		pParentSp:addChild(lbAttrNum, 1)
	end
end