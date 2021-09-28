-- FileName: PocketBagCell.lua
-- Author: licong
-- Date: 15/8/3
-- Purpose: 锦囊背包cell


module("PocketBagCell", package.seeall)

require "script/ui/item/ItemUtil"
require "script/model/utils/HeroUtil"
require "script/ui/hero/HeroPublicLua"
require "script/libs/LuaCC"

local _callBack  			= nil -- 回调事件
local _pocketData 			= nil
--[[
	@des 	:初始化变量
	@param 	:
	@return :
--]]
function init( ... )
	_callBack  			= nil
end
--------------------------------------------------------------- 按钮事件 ----------------------------------------------------------------------------------


--[[
	@des 	:强化按钮回调
	@param 	:
	@return :
--]]
function enhanceBtnCallBack( tag, itemBtn )

	local callBack = function ( ... )
	    local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_pocket)
	    MainScene.changeLayer(bagLayer, "bagLayer")
	end

	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/pocket/PocketUpgradeLayer"
	local layer = PocketUpgradeLayer.createPocketLayer(tag,callBack)
	MainScene.changeLayer(layer,"PocketUpgradeLayer")
	
	require "script/ui/bag/BagLayer"
	BagLayer.setMarkPocketItemIdItemId(tag)
end

--[[
	@des 	:加锁解锁按钮回调
	@param 	:
	@return :
--]]
function lockBtnCallBack( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	local itemInfo = ItemUtil.getItemInfoByItemId(tag)
	local isOnHero = false
	if(itemInfo == nil)then
		itemInfo = ItemUtil.getPocketInfoFromHeroByItemId(tag)
		isOnHero = true
	end

	local nextCallFun = function ()
		-- 改数据
		if(isOnHero)then
			HeroModel.changeHeroPocketLockStatus(itemInfo.equip_hid,itemInfo.pos)
		else
			DataCache.changePocketLockInBag(tag)
		end
		
		-- 默认cell关闭状态
		BagLayer.setOpenIndex(nil)

		if( _callBack )then
			_callBack()
		end

		-- 新信息
		local newItemInfo = ItemUtil.getItemInfoByItemId(tag)
		if(newItemInfo == nil)then
			newItemInfo = ItemUtil.getPocketInfoFromHeroByItemId(tag)
		end
		local str = nil
		if(newItemInfo.va_item_text.lock and tonumber(newItemInfo.va_item_text.lock) ==1) then
			str = GetLocalizeStringBy("lic_1731")
		else
			str = GetLocalizeStringBy("lic_1732")
		end
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(str)
	end

	require "script/ui/pocket/PocketService"
	if(itemInfo.va_item_text.lock and tonumber(itemInfo.va_item_text.lock) ==1) then
		PocketService.unlockPocket(tostring(tag),nextCallFun)
	else
		PocketService.lockPocket( tostring(tag),nextCallFun)
	end

	require "script/ui/bag/BagLayer"
	BagLayer.setMarkPocketItemIdItemId(tag)
end

--------------------------------------------------------------- 创建cell ----------------------------------------------------------------------------------
--[[
	@des 	:创建cell
	@param 	:p_pocketData:神兵数据, p_callBack:回调函数, p_isForMaterial:是否作为选择列表, p_selectList:选择的列表数据,p_isIconTouch:图标是否可以点击
			 p_isNoBtn:为true时则没有按钮
	@return :
--]]
function createCell( p_pocketData, p_callBack, p_isIconTouch, p_isNoBtn, p_menuTouchPriority, pIsBag, pIndex )
	init()
	_pocketData = p_pocketData
	_callBack = p_callBack

	local menuTouchPriority = p_menuTouchPriority or -128

	local tCell = CCTableViewCell:create()
	-- 背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local cellBg = CCScale9Sprite:create("images/common/bg/bg_1.png",fullRect, insetRect)
    cellBg:setContentSize(CCSizeMake(640,225))
    cellBg:setAnchorPoint(ccp(0.5,0))
    cellBg:setPosition(320,0)
	tCell:addChild(cellBg,1,1)
	local cellBgSize = cellBg:getContentSize()

	-- icon
	local iconSprite = nil
	if(p_isIconTouch == false)then
		iconSprite = ItemSprite.getItemSpriteByItemId( tonumber(p_pocketData.item_template_id),nil,nil, tonumber(p_pocketData.item_id))
	else
		iconSprite = ItemSprite.getItemSpriteById( tonumber(p_pocketData.item_template_id), tonumber(p_pocketData.item_id), nil,nil,nil,nil,nil,nil,nil,nil,true,nil,_callBack )
	end
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.49))
	cellBg:addChild(iconSprite)

	-- 加锁
	if(p_pocketData.va_item_text.lock and tonumber(p_pocketData.va_item_text.lock) ==1) then
		local lockSp= CCSprite:create("images/hero/lock.png")
		lockSp:setAnchorPoint(ccp(0.5,0.5))
		lockSp:setPosition(ccp(iconSprite:getContentSize().width, iconSprite:getContentSize().height))
		iconSprite:addChild(lockSp)
	end

	-- 等级背景
	local fullRect = CCRectMake(0,0,46,23)
    local insetRect = CCRectMake(20,8,5,1)
	local lvBg = CCScale9Sprite:create("images/common/bg/name_1.png",fullRect, insetRect)
	lvBg:setContentSize(CCSizeMake(92,26))
	lvBg:setAnchorPoint(ccp(0,0))
	lvBg:setPosition(ccp(20,35))
	cellBg:addChild(lvBg)

	-- 等级
    local lvSp = CCSprite:create("images/common/lv.png")
    lvSp:setAnchorPoint(ccp(0,0.5))
    lvSp:setPosition(ccp(8,lvBg:getContentSize().height*0.5))
    lvBg:addChild(lvSp)
	-- 等级
	local levelLabel = CCRenderLabel:create(p_pocketData.va_item_text.pocketLevel, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    levelLabel:setAnchorPoint(ccp(0,0.5))
    levelLabel:setPosition(ccp(lvSp:getPositionX()+lvSp:getContentSize().width+2, lvBg:getContentSize().height*0.5))
    lvBg:addChild(levelLabel)

	-- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(p_pocketData.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 1))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height-15))
    cellBg:addChild(sealSprite)

	-- 名称
	local quality = p_pocketData.itemDesc.quality
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local nameLabel = CCRenderLabel:create(p_pocketData.itemDesc.name, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0,1))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 0.5, cellBgSize.height-15))
    cellBg:addChild(nameLabel)

    -- 品质
    local potentialLabel = CCRenderLabel:create(quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setAnchorPoint(ccp(0,1))
    potentialLabel:setPosition(cellBgSize.width*390/640, cellBgSize.height-15)
    cellBg:addChild(potentialLabel)

	-- 星
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0, 1))
    starSp:setPosition(ccp(potentialLabel:getPositionX()+potentialLabel:getContentSize().width + 5, potentialLabel:getPositionY()))
    cellBg:addChild(starSp)

    -- 小背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local attrBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    attrBg:setContentSize(CCSizeMake(350,150))
    attrBg:setAnchorPoint(ccp(0,0))
    attrBg:setPosition(ccp(120,20))
    cellBg:addChild(attrBg)

    -- 属性
    local posX = {0.05,0.05,0.5,0.5}
	local posY = {0.7,0.3,0.7,0.3}
    if( tonumber(_pocketData.itemDesc.is_exp) == 1 )then
    	-- 经验锦囊
    	-- 提供经验的数值
		local add_exp = tonumber(p_pocketData.itemDesc.baseExp)
		if( p_pocketData.va_item_text and p_pocketData.va_item_text.pocketExp )then
			add_exp = add_exp + tonumber(p_pocketData.va_item_text.pocketExp)
		end
		local add_exp_label = CCLabelTTF:create(GetLocalizeStringBy("key_2531") .. "+" .. add_exp, g_sFontName, 23)
		add_exp_label:setColor(ccc3(0x78, 0x25, 0x00))
		add_exp_label:setAnchorPoint(ccp(0, 0.5))
		add_exp_label:setPosition(ccp(attrBg:getContentSize().width*posX[1],attrBg:getContentSize().height*posY[1]))
		attrBg:addChild(add_exp_label)
    else
	    require "script/ui/pocket/PocketData"
	 	-- local attrTab = PocketData.getPocketAttrByItemInfo( p_pocketData )
		-- if(not table.isEmpty(attrTab) )then
		-- 	local i = 0
		-- 	for k_id,v_num in pairs(attrTab) do
		-- 		i = i + 1
		-- 		local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(k_id, v_num)
		-- 		local attrLabel = CCLabelTTF:create(affixDesc.sigleName .. "+" .. displayNum ,g_sFontName,23)
		-- 		attrLabel:setColor(ccc3(0x78, 0x25, 0x00))
		-- 		attrLabel:setAnchorPoint(ccp(0, 0.5))
		-- 		attrLabel:setPosition(ccp(attrBg:getContentSize().width*posX[i],attrBg:getContentSize().height*posY[i]))
		-- 		attrBg:addChild(attrLabel)
		-- 	end
		-- end

		-- 显示效果
		local data = PocketData.getPocketAbilityBDByItemInfo(p_pocketData)
		local desLabel = CCLabelTTF:create( data.des, g_sFontName, 23, CCSizeMake(attrBg:getContentSize().width-15,attrBg:getContentSize().height-15), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
		desLabel:setColor(ccc3(0x78, 0x25, 0x00))
		desLabel:setAnchorPoint(ccp(0.5, 0.5))
		desLabel:setPosition(ccp(attrBg:getContentSize().width*0.5,attrBg:getContentSize().height*0.5))
		attrBg:addChild(desLabel)
	end

	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar,1, 9898)
	menuBar:setTouchPriority(menuTouchPriority)

    -- 按钮
   	if( p_isNoBtn ~= true )then
   		if( not(BagUtil.isSupportBagCell() and pIsBag) )then
			-- 强化
			local enhanceBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png", "images/common/btn/green01_h.png",CCSizeMake(134, 64), GetLocalizeStringBy("lic_1422"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			enhanceBtn:setAnchorPoint(ccp(0.5, 0.5))
		    enhanceBtn:setPosition(ccp(cellBgSize.width*0.85, cellBgSize.height*0.6))
			menuBar:addChild(enhanceBtn, 1, tonumber(p_pocketData.item_id))
			enhanceBtn:registerScriptTapHandler(enhanceBtnCallBack)

			-- 加锁
			local str = nil
			if(p_pocketData.va_item_text.lock and tonumber(p_pocketData.va_item_text.lock) ==1) then
				str = GetLocalizeStringBy("lic_1728")
			else
				str = GetLocalizeStringBy("lic_1727") 
			end
			local lockBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png",CCSizeMake(134, 64), str,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			lockBtn:setAnchorPoint(ccp(0.5, 0.5))
		    lockBtn:setPosition(ccp(cellBgSize.width*0.85, cellBgSize.height*0.3))
			menuBar:addChild(lockBtn, 1, tonumber(p_pocketData.item_id))
			lockBtn:registerScriptTapHandler(lockBtnCallBack)

			-- 经验锦囊没有强化
			if( tonumber(_pocketData.itemDesc.is_exp) == 1 )then
				enhanceBtn:setVisible(false)
				lockBtn:setVisible(false)
			end
		end
	end

	if(p_pocketData.equip_hid and tonumber(p_pocketData.equip_hid) > 0)then
		local localHero = HeroUtil.getHeroInfoByHid(p_pocketData.equip_hid)
		local heroName = localHero.localInfo.name
		if(HeroModel.isNecessaryHeroByHid(p_pocketData.equip_hid)) then
			heroName = UserModel.getUserName()
		end
		local onFormationText =  CCRenderLabel:create(GetLocalizeStringBy("key_1381") .. heroName, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	    onFormationText:setColor(ccc3(0x8a, 0xff, 0x00))
	    onFormationText:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.9))
	    cellBg:addChild(onFormationText)
	end


	-- 展开逻辑
	local isExp = false
	if(tonumber(_pocketData.itemDesc.is_exp) == 1)then
		isExp = true
	end
	if(isExp == false and BagUtil.isSupportBagCell() and pIsBag)then
		-- 隐藏原来的按钮
		menuBar:setVisible(false)
		-- 展开背景高度
		local openBgHeight = 138
		local addHeight = openBgHeight-10
		-- 展开按钮
		local menu = CCMenu:create()
		menu:setPosition(ccp(0,0))
		cellBg:addChild(menu)
		local normal = CCMenuItemImage:create("images/common/down_btn_n.png", "images/common/down_btn_h.png")
		local hight  = CCMenuItemImage:create("images/common/up_btn_n.png", "images/common/up_btn_h.png")
		hight:setAnchorPoint(ccp(0.5, 0.5))
		normal:setAnchorPoint(ccp(0.5, 0.5))
		local openMenuItem = CCMenuItemToggle:create(normal)
		openMenuItem:setAnchorPoint(ccp(0.5, 0.5))
		openMenuItem:addSubItem(hight)
		menu:addChild(openMenuItem)
		openMenuItem:setPosition(ccp(cellBg:getContentSize().width*0.8,cellBg:getContentSize().height*0.45))
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
			enhanceMenuItem:registerScriptTapHandler(enhanceBtnCallBack)
			buttnMenu:addChild(enhanceMenuItem, 1, tonumber(p_pocketData.item_id))
			table.insert(btnArr,enhanceMenuItem)

			-- 加锁 解锁
			local str = ""
			if(p_pocketData.va_item_text.lock and tonumber(p_pocketData.va_item_text.lock) ==1) then
				str = GetLocalizeStringBy("lic_1728")
			else
				str = GetLocalizeStringBy("lic_1727") 
			end
			local normalFile = "images/common/btn/btn_s_n.png"
			local selectFile = "images/common/btn/btn_s_h.png"
			local fontColor = ccc3(0xff, 0xf2, 0x5d)
		    local lockMenuItem = LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76),str,fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			lockMenuItem:setAnchorPoint(ccp(0.5, 0.5))
			lockMenuItem:registerScriptTapHandler(lockBtnCallBack)
			buttnMenu:addChild(lockMenuItem, 1, tonumber(p_pocketData.item_id))
			table.insert(btnArr,1,lockMenuItem)
			
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

















