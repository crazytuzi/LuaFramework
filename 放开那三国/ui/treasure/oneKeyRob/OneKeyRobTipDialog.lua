-- FileName: OneKeyRobTipDialog.lua
-- Author: licong
-- Date: 14-10-11
-- Purpose: 一键夺宝提示框


module("OneKeyRobTipDialog", package.seeall)

local _bgLayer                  	= nil
local _backGround 					= nil
local _second_bg  					= nil

local _desItemTid 					= nil
local _isAutoUse					= nil --自动使用耐力丹
local _defalutSelectIndex           = nil
function init( ... )
    _bgLayer                    	= nil
    _backGround 					= nil
    _second_bg  					= nil
    _isAutoUse						= false --自动使用耐力丹
    _desItemTid 					= nil
    _oneKeyFuseNum 					= nil
end


--[[
	@des 	:touch事件处理
	@param 	:
	@return :
--]]
local function layerTouch(eventType, x, y)
    return true
end

--[[
	@des 	:创建提示框
	@param 	:
	@return :
--]]
function createTipLayer( ... )

    _bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerTouch,false,-650,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1000,1)

    -- 创建背景
    _backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(530, 403))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

    local full_rect = CCRectMake(0,0,75, 75)
    local inset_rect = CCRectMake(30,30,15,15)
    local table_view_bg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", full_rect, inset_rect)
    table_view_bg:setPreferredSize(CCSizeMake(478, 227))
    table_view_bg:setAnchorPoint(ccp(0.5, 0))
    table_view_bg:setPosition(ccp(_backGround:getContentSize().width * 0.5, 105))
    _backGround:addChild(table_view_bg, 1)

    -- 关闭按钮
    local menu = CCMenu:create()
    menu:setTouchPriority(-651)
    menu:setPosition(ccp(0, 0))
    menu:setAnchorPoint(ccp(0, 0))
    _backGround:addChild(menu,3)
    local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeButton:setAnchorPoint(ccp(0.5, 0.5))
    closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
    closeButton:registerScriptTapHandler(closeButtonCallback)
    menu:addChild(closeButton)

    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
    titlePanel:setAnchorPoint(ccp(0.5, 0.5))
    titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
    _backGround:addChild(titlePanel)
    local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1255"), g_sFontPangWa, 33)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
    titlePanel:addChild(titleLabel)

    local itemData = ItemUtil.getItemById(_desItemTid)
    local nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
    local contentInfo = {}
    contentInfo.labelDefaultColor = ccc3(0xff, 0xed, 0x00)
    contentInfo.labelDefaultSize = 25
    contentInfo.defaultType = "CCRenderLabel"
    contentInfo.lineAlignment = 1
    contentInfo.labelDefaultFont = g_sFontPangWa
    contentInfo.width = 440
    contentInfo.elements = {
        {
			text  = itemData.name,
			color = nameColor,
			font  = g_sFontPangWa,
            size  = 26,
        }
    }
    contentNode = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("lcyx_1979"), contentInfo)
    contentNode:setAnchorPoint(ccp(0.5,0.5))
    contentNode:setPosition(ccpsprite(0.5, 0.7, _backGround))
    _backGround:addChild(contentNode, 10)

    local audioMenu = CCMenu:create()
    audioMenu:ignoreAnchorPointForPosition(false)
    audioMenu:setTouchPriority(-652)

    local norItem = CCMenuItemImage:create("images/common/duigou_n.png", "images/common/duigou_n.png")
    norItem:setAnchorPoint(ccp(0.5, 0.5))
    local higItem = CCMenuItemImage:create("images/common/duigou_h.png", "images/common/duigou_h.png")
    higItem:setAnchorPoint(ccp(0.5, 0.5))
    local autoRadio = CCMenuItemToggle:create(norItem)
    autoRadio:addSubItem(higItem)
    autoRadio:registerScriptTapHandler(autoRadioCallback)
    audioMenu:addChild(autoRadio)
    audioMenu:setContentSize(autoRadio:getContentSize())
    if not _defalutSelectIndex then
        autoRadio:setSelectedIndex(0)
    else
        autoRadio:setSelectedIndex(_defalutSelectIndex)
        if _defalutSelectIndex > 0 then
            _isAutoUse = true
        else
            _isAutoUse = false
        end
    end

    local autoDes =  CCRenderLabel:create(GetLocalizeStringBy("lcyx_1980"), g_sFontName, 21,1,ccc3(0x00,0x00,0x00),type_stroke)
	autoDes:setColor(ccc3(0xff,0xff,0xff))

    local staminaIcon = CCSprite:create("images/common/stamina_small.png")
	
	local autotNode = BaseUI.createHorizontalNode({audioMenu, autoDes, staminaIcon})
	autotNode:setAnchorPoint(ccp(0.5, 0.5))
	autotNode:setPosition(ccpsprite(0.5, 0.4, _backGround))
	_backGround:addChild(autotNode, 10)	

    -- 确认
    require "script/libs/LuaCC"
    local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("lic_1097"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    confirmBtn:setAnchorPoint(ccp(0.5, 0))
    confirmBtn:setPosition(ccp(_backGround:getContentSize().width*0.3, 31))
    confirmBtn:registerScriptTapHandler(okButtonCallback)
    menu:addChild(confirmBtn)

    -- 取消
    local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("lic_1098"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    cancelBtn:setAnchorPoint(ccp(0.5, 0))
    cancelBtn:setPosition(ccp(_backGround:getContentSize().width*0.7, 31))
    cancelBtn:registerScriptTapHandler(closeButtonCallback)
    menu:addChild(cancelBtn)

end

--[[
	@des:自动使用耐力丹
--]]
function autoRadioCallback( pTag, pSender )
	local item = tolua.cast(pSender, "CCMenuItemToggle")
	local selectIndex = item:getSelectedIndex()
	if selectIndex > 0 then
		_isAutoUse = true
	else
		_isAutoUse = false
	end
    _defalutSelectIndex = selectIndex
end

--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if(_bgLayer)then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end
end

--[[
	@des 	:按钮回调
	@param 	:
	@return :
--]]
function okButtonCallback( tag, sender )
    -- 关闭
    closeButtonCallback()
    require "script/ui/treasure/oneKeyRob/OneKeyRobController"
    OneKeyRobController.oneKeySeize(_desItemTid, _isAutoUse)
end


--[[
	@des 	:一键合成获提示框
	@param 	:p_item 选择要合成的物品
	@return :
--]]
function show(p_itemTid)
    -- 初始化
    init()
    -- 要合成宝物tid
    _desItemTid = tonumber(p_itemTid)

    -- 一键合成的个数
    _oneKeyFuseNum = p_onekeyFuseNum

    -- 创建提示layer
    createTipLayer()
end













