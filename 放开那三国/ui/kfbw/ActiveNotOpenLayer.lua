-- Filename：	ActiveNotOpenLayer.lua
-- Author：		yangrui
-- Date：		2015-10-15
-- Purpose：		分组期显示倒计时

module ("ActiveNotOpenLayer", package.seeall)

require "script/libs/LuaCCSprite"

local _bgLayer = nil

--[[
    @des    : 初始化
    @param  : 
    @return : 
--]]
function init( ... )
    _bgLayer = nil
end

--[[
    @des    : touch事件处理
    @para   : 
    @return : 
--]]
function onTouchesHandler(event)
    return true
end

--[[
    @des    : 回调onEnter和onExit事件
    @param  : 
    @return : 
--]]
function onNodeEvent(event)
    if ( event == "enter" ) then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,-600,true)
        _bgLayer:setTouchEnabled(true)
	elseif ( event == "exit" ) then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--[[
    @des    : 返回按钮回调
    @param  : 
    @return : 
--]]
function closeFunc( ... )
    -- 
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
    KuafuLayer.closeKuafuLayerAction()
end

--[[
    @des    : 创建UI
    @param  : 
    @return : 
--]]
function createUI( ... )
    -- menuBar
    local mainMenuBar = CCMenu:create()
    mainMenuBar:setAnchorPoint(ccp(1,1))
    mainMenuBar:setPosition(ccp(0,0))
    mainMenuBar:setTouchPriority(-601)
    _bgLayer:addChild(mainMenuBar)
    -- 返回按钮
    local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    closeMenuItem:setAnchorPoint(ccp(0,1))
    closeMenuItem:setPosition(ccp(_bgLayer:getContentSize().width-closeMenuItem:getContentSize().width*g_fScaleX-10*g_fScaleX,_bgLayer:getContentSize().height-KuafuLayer.getBoardHeight()*g_fScaleX-20*g_fScaleX))
    closeMenuItem:setScale(g_fScaleX)
    closeMenuItem:registerScriptTapHandler(closeFunc)
    mainMenuBar:addChild(closeMenuItem)
    -- 跨服比武商店按钮
    local kfbwShopButton = CCMenuItemImage:create("images/kfbw/kfbwshop/kfbwshop_n.png","images/kfbw/kfbwshop/kfbwshop_h.png")
    kfbwShopButton:setAnchorPoint(ccp(0,1))
    local posX = _bgLayer:getContentSize().width-closeMenuItem:getContentSize().width*g_fScaleX-474*g_fScaleX
    local posY = _bgLayer:getContentSize().height-KuafuLayer.getBoardHeight()*g_fScaleX-11*g_fScaleX
    kfbwShopButton:setPosition(ccp(posX,posY))
    kfbwShopButton:registerScriptTapHandler(KuafuLayer.kfbwShopBtnCallFunc)
    kfbwShopButton:setScale(g_fScaleX)
    mainMenuBar:addChild(kfbwShopButton)
    -- 剩余时间
    require "script/utils/TimeUtil"
    local countDownTime = CCRenderLabel:create(GetLocalizeStringBy("yr_2019"),g_sFontPangWa,33,1,ccc3(0x00,0x00,0x00),type_shadow)
    countDownTime:setAnchorPoint(ccp(0.5,0))
    countDownTime:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    countDownTime:setScale(MainScene.elementScale)
    _bgLayer:addChild(countDownTime)
    -- 剩余时间
    local leftTime = KuafuData.getPeriedEndTime()-TimeUtil.getSvrTimeByOffset()
    local leftTimeLabel = TimeUtil.getTimeString(leftTime)
    local countDownTimeLabel = CCRenderLabel:create(leftTimeLabel,g_sFontPangWa,33,1,ccc3(0x00,0x00,0x00),type_stroke)
    countDownTimeLabel:setAnchorPoint(ccp(0.5,1))
    countDownTimeLabel:setPosition(ccp(_bgLayer:getContentSize().width*0.5,countDownTime:getPositionY()))
    countDownTimeLabel:setScale(MainScene.elementScale)
    _bgLayer:addChild(countDownTimeLabel)

    schedule(_bgLayer,function( ... )
        local leftTime = KuafuData.getPeriedEndTime()-TimeUtil.getSvrTimeByOffset()
        local leftTimeLabel = TimeUtil.getTimeString(leftTime)
        countDownTimeLabel:setString(leftTimeLabel)
        if tonumber(leftTime) < 0 then
            -- 进入比武
            KuafuService.getWorldCompeteInfo(function( ... )
                print("===|||===  not open  to battle")
                local kuafuInfo = KuafuData.getWorldCompeteInfo()
                if kuafuInfo.ret == "ok" then
                    _isOpenKuafuShop = true
                    -- 创建比武UI
                    KuafuLayer.createBattleLayer()
                end
            end)
        end
    end,1)

    return _bgLayer
end

--[[
    @des    : createNotOpenLayer
    @param  : 
    @return : 
--]]
function createNotOpenLayer( ... )
    -- init
    init()
    _bgLayer = CCLayerColor:create(ccc4(0,0,0,100))
    _bgLayer:registerScriptHandler(onNodeEvent)

    createUI()

    return _bgLayer
end
