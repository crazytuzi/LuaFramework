-- FileName: ChariotEnforceLayer.lua
-- Author: lgx 
-- Date: 16-06-27
-- Purpose: 战车强化界面

module("ChariotEnforceLayer", package.seeall)

require "script/ui/chariot/ChariotMainController"
require "script/ui/chariot/ChariotMainData"
require "script/ui/item/ItemUtil"
require "script/ui/chariot/ChariotUtil"
require "script/ui/chariot/ChariotDef"
require "script/utils/BaseUI"

local _touchPriority 	= nil -- 触摸优先级
local _zOrder 		 	= nil -- 显示层级
local _bgLayer 		 	= nil -- 背景层
local _bgSprite			= nil -- 背景
local _chariotProBg		= nil -- 战车属性背景
local _costrBg 			= nil -- 消耗信息背景
local _chariotPos 		= nil -- 战车装备的位置
local _itemId 			= nil -- 战车物品id
local _isShowWithBag 	= nil -- 是否是从背包进入的
local _haveItemNum 		= nil -- 拥有精铁数量

--[[
	@desc	: 初始化方法
	@param 	: 
    @return	: 
--]]
local function init()
	_touchPriority		= nil
	_zOrder				= nil
	_bgLayer			= nil
	_bgSprite			= nil
	_chariotProBg		= nil
	_costrBg			= nil
	_chariotPos 		= nil
	_itemId 			= nil
	_isShowWithBag		= nil
	_haveItemNum		= nil
end

--[[
	@desc 	: 背景层触摸回调
	@param 	: eventType 事件类型 x,y 触摸点
	@return : 
--]]
local function layerToucCallback( eventType, x, y )
	return true
end

--[[
	@desc 	: 回调onEnter和onExit事件
	@param 	: event 事件名
	@return : 
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerToucCallback,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end

--[[
	@desc 	: 显示界面方法
	@param 	: pItemId 战车物品id
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showLayer( pItemId, pTouchPriority, pZorder )
	local layer = createLayer(pItemId,pTouchPriority,pZorder)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,_zOrder)
end

--[[
	@desc 	: 显示界面方法 背包通过MainSence.changeLayer进入
	@param 	: pItemId 战车物品id
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showWithChangeLayer( pItemId, pTouchPriority, pZorder )
	-- 使用MainSence.changeLayer进入
	MainScene.setMainSceneViewsVisible(false,false,false)
	local chariotEnforceLayer = createLayer(pItemId, pTouchPriority, pZorder)
	MainScene.changeLayer(chariotEnforceLayer, "ChariotEnforceLayer")

	-- 记录从背包进入
	_isShowWithBag = true
end

--[[
	@desc 	: 创建Layer及UI
	@param 	: pItemId 战车物品id
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : CCLayer 背景层
--]]
function createLayer( pItemId, pTouchPriority, pZorder )
	-- 初始化
	init()

	_chariotPos = ChariotMainData.getChariotPosByItemId(pItemId) or 0
	_itemId = pItemId or 0
	_touchPriority = pTouchPriority or -750
	_zOrder = pZorder or 750

	-- 背景层
	_bgLayer = CCLayer:create()
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setAnchorPoint(ccp(0, 0))

	-- 背景图
	_bgSprite = CCSprite:create("images/chariot/main_bg.png")
	_bgSprite:setAnchorPoint(ccp(0.5,0.5))
	_bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	_bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(_bgSprite)

	-- 标题
	local titleSprite = CCSprite:create("images/chariot/enforce_title.png")
    titleSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-titleSprite:getContentSize().height/2-25*g_fElementScaleRatio))
    titleSprite:setAnchorPoint(ccp(0.5,0.5))
    titleSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(titleSprite)

    -- 黑烟特效
    local effectSprite = XMLSprite:create("images/chariot/effect/bgzhanche/bgzhanche")
    effectSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.6))
    effectSprite:setAnchorPoint(ccp(0.5,0.5))
    effectSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(effectSprite,5)

	-- 返回按钮Menu
	local backMenu = CCMenu:create()
    backMenu:setPosition(ccp(0, 0))
    backMenu:setTouchPriority(_touchPriority-30)
    _bgLayer:addChild(backMenu, 10)

    -- 返回按钮
    local backItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    backItem:setScale(g_fElementScaleRatio)
    backItem:setAnchorPoint(ccp(1,0.5))
    backItem:setPosition(ccp(_bgLayer:getContentSize().width-20,_bgLayer:getContentSize().height-60*g_fElementScaleRatio))
    backItem:registerScriptTapHandler(backItemCallback)
    backMenu:addChild(backItem,1)

	-- 图鉴按钮
   	local illustrateItem = CCMenuItemImage:create("images/chariot/btn_chariot_illustrate_n.png","images/chariot/btn_chariot_illustrate_h.png")
    illustrateItem:setScale(g_fElementScaleRatio)
    illustrateItem:setAnchorPoint(ccp(0,0.5))
    illustrateItem:setPosition(ccp(20,_bgLayer:getContentSize().height-60*g_fElementScaleRatio))
    illustrateItem:registerScriptTapHandler(illustrateItemCallback)
    backMenu:addChild(illustrateItem,1)

    -- 关闭按钮
    local closeItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_10014"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	closeItem:setScale(g_fElementScaleRatio)
	closeItem:setAnchorPoint(ccp(0.5, 0.5))
	closeItem:setPosition(ccp(_bgLayer:getContentSize().width*0.25,40*g_fElementScaleRatio))
    closeItem:registerScriptTapHandler(backItemCallback)
	backMenu:addChild(closeItem)

    -- 强化按钮
	local enforceItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_1269"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	enforceItem:setScale(g_fElementScaleRatio)
	enforceItem:setAnchorPoint(ccp(0.5, 0.5))
	enforceItem:setPosition(ccp(_bgLayer:getContentSize().width*0.75,40*g_fElementScaleRatio))
    enforceItem:registerScriptTapHandler(enforceItemCallback)
	backMenu:addChild(enforceItem)

	-- 创建战车信息
	createChariotUI()

    return _bgLayer
end

--[[
	@desc 	: 创建战车形象和信息
	@param	: 
	@return : 
--]]
function createChariotUI()
	-- 获取战车数据
	local chariotInfo = nil
	if (_chariotPos > 0) then
		-- 装备中
		chariotInfo = ChariotMainData.getEquipChariotInfoByPos(_chariotPos)
	elseif (_itemId > 0) then
		-- 背包里
		chariotInfo = ItemUtil.getItemByItemId(_itemId)
	else
		-- 其他 参数错误
		print("ChariotEnforceLayer createLayer pPos and pItemId can't nil at the same time!")
		return
	end

	-- 创建UI
	local bgSize = _bgLayer:getContentSize()
	local chariotTid = chariotInfo.item_template_id
	local chariotDB = chariotInfo.itemDesc
	local curLv = tonumber(chariotInfo.va_item_text.chariotEnforce)

	-- 战车形象
	local chariotItem = ChariotUtil.createChariotBigItemByTid(chariotTid,false,chariotItemCallback,_chariotPos,_touchPriority-5)
	chariotItem:setAnchorPoint(ccp(0.5,0.5))
	chariotItem:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.55+60*g_fElementScaleRatio))
	chariotItem:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(chariotItem,15)

	-- 战车底座
	local shadowSprite = CCSprite:create("images/chariot/chariot_shadow.png")
	_bgLayer:addChild(shadowSprite,14)
	shadowSprite:setAnchorPoint(ccp(0.5, 0.5))
	shadowSprite:setScale(g_fElementScaleRatio)
	shadowSprite:setPosition(ccp(chariotItem:getPositionX(),chariotItem:getPositionY()-chariotItem:getContentSize().height*g_fElementScaleRatio*0.35))

	-- 战车名称
	local nameBg = ChariotUtil.createChariotNameLabByNameAndLv(""..chariotDB.name,CCSizeMake(250, 40),chariotDB.quality,nil)
	nameBg:setAnchorPoint(ccp(0.5, 0))
	nameBg:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.55+(chariotItem:getContentSize().height*0.5+90)*g_fElementScaleRatio))
	nameBg:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(nameBg,15)

	-- 战车等级属性
	createAttrUIWithInfo(chariotInfo)

	-- 弹出动画 策划说直接显示和装备界面，变化不明显，加个缩放动画明显一点
	ChariotUtil.runShowAction(_chariotProBg,g_fScaleX)
	
	-- 消耗材料
	createCostInfoUIWithTidAndLv(chariotTid,curLv)
end

--[[
	@desc 	: 创建战车属性信息
	@param 	: pChariotInfo 战车信息
	@return : 
--]]
function createAttrUIWithInfo( pChariotInfo )
	if (_chariotProBg ~= nil) then
		_chariotProBg:removeFromParentAndCleanup(true)
		_chariotProBg = nil
	end

	-- 战车属性
	local bgSize = _bgLayer:getContentSize()
	_chariotProBg = ChariotUtil.createProBgByTitleAndSize(GetLocalizeStringBy("key_1269"),CCSizeMake(636,218))
	_chariotProBg:setAnchorPoint(ccp(0.5,0.5))
    _chariotProBg:setPosition(bgSize.width*0.5, bgSize.height*0.55-240*g_fScaleY)
    _chariotProBg:setScale(g_fScaleX)
	_bgLayer:addChild(_chariotProBg,15)

	local chariotTid = pChariotInfo.item_template_id
	local curLv = tonumber(pChariotInfo.va_item_text.chariotEnforce)
	local nextLv = curLv+1

	-- 当前等级
	local curLvTab = {}
	curLvTab[1] = CCSprite:create("images/common/lv.png")
	curLvTab[2] = CCRenderLabel:create("  "..curLv, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	curLvTab[2]:setColor(ccc3(0xff,0xf6,0x00))

    local curLvLab = BaseUI.createHorizontalNode(curLvTab)
    curLvLab:setAnchorPoint(ccp(0,0.5))
	curLvLab:setPosition(ccp(_chariotProBg:getContentSize().width*0.15,_chariotProBg:getContentSize().height-40))
	_chariotProBg:addChild(curLvLab)

	-- 当前等级属性
	local curAttrInfo = ChariotMainData.getSortedChariotAttrInfoByTidAndLv(chariotTid,curLv)
	for i,v in ipairs(curAttrInfo) do
		local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(v.id,v.num)

		local attrTab = {}
		attrTab[1] = CCRenderLabel:create(""..affixDesc.sigleName..":", g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrTab[1]:setColor(ccc3(0xff,0xff,0xff))
		attrTab[2] = CCRenderLabel:create(" +"..displayNum, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrTab[2]:setColor(ccc3(0x00,0xff,0x18))

		local attrLab = BaseUI.createHorizontalNode(attrTab)
	    attrLab:setAnchorPoint(ccp(0,0.5))
		attrLab:setPosition(ccp(_chariotProBg:getContentSize().width*0.15,_chariotProBg:getContentSize().height-(50+i*35)))
		_chariotProBg:addChild(attrLab)
	end

	-- 强化到最大等级 则箭头和右边属性不显示
	local maxLv = ChariotMainData.getMaxLevelByTid(chariotTid)
	if (curLv < maxLv) then
		local arrowSp = CCSprite:create("images/item/equipinfo/reinforce/arrow.png")
		arrowSp:setAnchorPoint(ccp(0.5,0.5))
		arrowSp:setPosition(ccp(_chariotProBg:getContentSize().width*0.5,curLvLab:getPositionY()))
		_chariotProBg:addChild(arrowSp)

		-- 下一等级
		local nextLvTab = {}
		nextLvTab[1] = CCSprite:create("images/common/lv.png")
		nextLvTab[2] = CCRenderLabel:create("  "..nextLv, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		nextLvTab[2]:setColor(ccc3(0xff,0xf6,0x00))

	    local nextLvLab = BaseUI.createHorizontalNode(nextLvTab)
	    nextLvLab:setAnchorPoint(ccp(0,0.5))
		nextLvLab:setPosition(ccp(_chariotProBg:getContentSize().width*0.65,_chariotProBg:getContentSize().height-40))
		_chariotProBg:addChild(nextLvLab)

		-- 下一等级属性
		local nextAttrInfo = ChariotMainData.getSortedChariotAttrInfoByTidAndLv(chariotTid,nextLv)
		for i,v in ipairs(nextAttrInfo) do
			local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(v.id,v.num)

			local attrTab = {}
			attrTab[1] = CCRenderLabel:create(""..affixDesc.sigleName..":", g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			attrTab[1]:setColor(ccc3(0xff,0xff,0xff))
			attrTab[2] = CCRenderLabel:create(" +"..displayNum, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			attrTab[2]:setColor(ccc3(0x00,0xff,0x18))

			local attrLab = BaseUI.createHorizontalNode(attrTab)
		    attrLab:setAnchorPoint(ccp(0,0.5))
			attrLab:setPosition(ccp(_chariotProBg:getContentSize().width*0.65,_chariotProBg:getContentSize().height-(50+i*35)))
			_chariotProBg:addChild(attrLab)

			local arrowSp = CCSprite:create("images/item/equipinfo/reinforce/arrow.png")
			arrowSp:setAnchorPoint(ccp(0.5,0.5))
			arrowSp:setPosition(ccp(_chariotProBg:getContentSize().width*0.5,attrLab:getPositionY()))
			_chariotProBg:addChild(arrowSp)
		end
	end
end

--[[
	@desc 	: 创建强化消耗信息
	@param 	: pChariotTid 战车模板id
	@param 	: pCurLv 战车等级
	@return : 
--]]
function createCostInfoUIWithTidAndLv( pChariotTid, pCurLv )
	if (_costrBg ~= nil) then
		_costrBg:removeFromParentAndCleanup(true)
		_costrBg = nil
	end
	local bgSize = _bgLayer:getContentSize()
	local fullRect = CCRectMake(0,0,112,29)
	local insertRect = CCRectMake(10,5,92,19)
    _costrBg = CCScale9Sprite:create("images/recharge/feedback_active/time_bg.png",fullRect,insertRect)
    _costrBg:setPreferredSize(CCSizeMake(636,80))
 	_costrBg:setAnchorPoint(ccp(0.5,0.5))
 	_costrBg:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.12))
 	_costrBg:setScale(g_fScaleX)
 	_bgLayer:addChild(_costrBg)

 	-- 最大等级了
	local maxLv = ChariotMainData.getMaxLevelByTid(pChariotTid)
	local silverNum,needTid,needNum = 0,0,0
	if (pCurLv >= maxLv) then
		-- 已满级
		local maxStrLab = CCRenderLabel:create(GetLocalizeStringBy("lgx_1098"), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    maxStrLab:setColor(ccc3(0xff, 0xf6, 0x00))
	    maxStrLab:setAnchorPoint(ccp(0.5,0.5))
	    maxStrLab:setPosition(ccp(_costrBg:getContentSize().width*0.5,_costrBg:getContentSize().height*0.5))
	    _costrBg:addChild(maxStrLab,2)
	else
		silverNum,needTid,needNum = ChariotMainData.getEnforeCostByTidAndLv(pChariotTid,pCurLv)

		local userSilverNum = UserModel.getSilverNumber()
		local silverColor = (userSilverNum >= silverNum) and ccc3(0x00,0xff,0x18) or ccc3(0xff,0x00,0x00)
		_haveItemNum = (_haveItemNum ~= nil) and getHaveItemNum() or ItemUtil.getCacheItemNumBy(needTid) 
		local itemNumColor = (_haveItemNum >= needNum) and ccc3(0x00,0xff,0x18) or ccc3(0xff,0x00,0x00)
		
		local costStrLab = CCRenderLabel:create(GetLocalizeStringBy("key_2794").." ", g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    costStrLab:setColor(ccc3(0xff, 0xf6, 0x00))
	    costStrLab:setAnchorPoint(ccp(0,0.5))
	    costStrLab:setPosition(ccp(70,_costrBg:getContentSize().height*0.75))
	    _costrBg:addChild(costStrLab,2)

	    local silverIcon = CCSprite:create("images/common/coin.png")
	    local silverNumLab = CCRenderLabel:create(" "..userSilverNum.."/"..silverNum, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    silverNumLab:setColor(silverColor)
	    local silverLab = BaseUI.createHorizontalNode({silverIcon,silverNumLab})
	    silverLab:setAnchorPoint(ccp(0, 0.5))
	    silverLab:setPosition(ccp(costStrLab:getPositionX()+costStrLab:getContentSize().width+10,_costrBg:getContentSize().height*0.75))
	    _costrBg:addChild(silverLab,2)
	    
	    local itemData = ItemUtil.getItemById(needTid)
	    local itemIcon = CCSprite:create("images/base/props/"..itemData.icon_little)
	    local itemNumLab = CCRenderLabel:create(" ".._haveItemNum.."/"..needNum, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    itemNumLab:setColor(itemNumColor)
	    local itemLab = BaseUI.createHorizontalNode({itemIcon,itemNumLab})
	    itemLab:setAnchorPoint(ccp(0, 0.5))
	    itemLab:setPosition(ccp(silverLab:getPositionX(),_costrBg:getContentSize().height*0.25))
	    _costrBg:addChild(itemLab,2)
	end
end

--[[
	@desc 	: 刷新界面
	@param 	: 
	@return : 
--]]
function updateUI()
	-- 获取战车数据
	local chariotInfo = nil
	if (_chariotPos > 0) then
		-- 装备中
		chariotInfo = ChariotMainData.getEquipChariotInfoByPos(_chariotPos)
	elseif (_itemId > 0) then
		-- 背包里
		chariotInfo = ItemUtil.getItemByItemId(_itemId)
	else
		-- 其他 参数错误
		print("ChariotEnforceLayer createLayer pPos and pItemId can't nil at the same time!")
		return
	end
	-- 刷新战车属性
	createAttrUIWithInfo(chariotInfo)

	-- 刷新消耗材料
	local chariotTid = chariotInfo.item_template_id
	local curLv = tonumber(chariotInfo.va_item_text.chariotEnforce)
	createCostInfoUIWithTidAndLv(chariotTid,curLv)
end

--[[
	@desc	: 设置拥有精铁数量
    @param	: pItemNum 拥有精铁数量
    @return	: 
—]]
function setHaveItemNum( pItemNum )
	if (pItemNum) then
		_haveItemNum = pItemNum
	end
end

--[[
	@desc	: 获取拥有精铁数量
    @param	: 
    @return	: 拥有精铁数量
—]]
function getHaveItemNum()
	return _haveItemNum
end

--[[
	@desc 	: 点击战车回调
	@param 	: 
	@return : 
--]]
function chariotItemCallback()
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/chariot/ChariotInfoLayer"
	if (_chariotPos > 0 and not _isShowWithBag) then
    	ChariotInfoLayer.showLayer(ChariotDef.kChariotInfoTypeEquip, _itemId, nil, _touchPriority-100, _zOrder+1000)
    else
    	ChariotInfoLayer.showLayer(ChariotDef.kChariotInfoTypeBag, _itemId, nil, _touchPriority-100, _zOrder+1000)
    end
    -- 关闭强化界面
    closeSelfCallBack()
end

--[[
	@desc 	: 点击强化按钮回调
	@param 	: 
	@return : 
--]]
function enforceItemCallback()
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 强化战车
	require "script/ui/chariot/ChariotMainController"
	ChariotMainController.enforce(function()
		print("--------------- chariot enforce success --------------")
		-- 刷新界面UI
		updateUI()
	end,_chariotPos,_itemId)
end

--[[
	@desc 	: 点击图鉴按钮回调
	@param 	: 
	@return : 
--]]
function illustrateItemCallback()
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/chariot/illustrate/ChariotIllustrateController"
	ChariotIllustrateController.getChariotBook(function()
		require "script/ui/chariot/illustrate/ChariotIllustrateLayer"
		ChariotIllustrateLayer.showLayer(_touchPriority-100,_zOrder+10)
	end)
end

--[[
	@desc 	: 关闭界面
	@param 	: 
	@return : 
--]]
function closeSelfCallBack()
	if (_isShowWithBag) then
		-- 从背包来的，切回背包
  		require "script/ui/bag/BagLayer"
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Chariot)
		MainScene.changeLayer(bagLayer, "bagLayer")
	else
		-- 默认 移除界面
		if not tolua.isnull(_bgLayer) then
			_bgLayer:removeFromParentAndCleanup(true)
			_bgLayer = nil
		end
		require "script/ui/chariot/ChariotMainLayer"
		-- 更新战车主界面显示，为了展示属性框 动画效果
		ChariotMainLayer.updateCellByPos(_chariotPos)
	end
end

--[[
	@desc 	: 点击返回按钮回调
	@param 	: 
	@return : 
--]]
function backItemCallback()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	closeSelfCallBack()
end
