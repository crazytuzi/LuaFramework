-- Filename: AlertConsumeLayer.lua
-- Author: yangrui
-- Date: 2015-10-10
-- Purpose: 警示玩家是否消耗金币购买刷新

module("AlertConsumeLayer", package.seeall)

local _bgLayer          --触摸屏蔽层

--[[
    @des    : 初始化
    @para   : 
    @return : 
 --]]
function init( ... )
    _bgLayer = nil
end

--[[
    @des    : 处理touches事件
    @para   : 
    @return : 
 --]]
function onTouchesHandler( eventType, x, y )
    return true
end

--[[
    @des    : 回调onEnter和onExit
    @para   : 
    @return : 
 --]]
function onNodeEvent( event )
    if ( event == "enter" ) then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler,false,-431,true)
        _bgLayer:setTouchEnabled(true)
    elseif ( event == "exit" ) then
        _bgLayer:unregisterScriptTouchHandler()
    end
end

--[[
    @des    : 关闭自己
    @para   : 
    @return : 
--]]
function closeAction( ... )
    print("closeAction===")
    if _bgLayer ~= nil then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end
end 

--[[
    @des    : 按钮回调
    @param  :
    @return :
--]]
function btnFunc( tag )
    if ( tag == 1 ) then
        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
        print("===|刷新对手|===")
        -- 网络请求
        KuafuController.refreshRival()
    elseif ( tag == 2 ) then
        AudioUtil.playEffect("audio/effect/guanbi.mp3")
    elseif ( tag == 3 ) then
        AudioUtil.playEffect("audio/effect/guanbi.mp3")
    end
    closeAction()
end

--[[
    @des    : 创建UI
    @param  :
    @return :
--]]
function createUI( ... )
    _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(_bgLayer,1000)
    -- bg
    local bgSp = CCScale9Sprite:create("images/common/viewbg1.png")
    bgSp:setContentSize(CCSizeMake(520,300))
    bgSp:setAnchorPoint(ccp(0.5,0.5))
    bgSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    bgSp:setScale(g_fScaleX)
    _bgLayer:addChild(bgSp)
    -- 提示Label
    local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3158"),g_sFontPangWa,35)
    tipLabel:setColor(ccc3(0x78,0x25,0x00))
    tipLabel:setAnchorPoint(ccp(0.5,0))
    tipLabel:setPosition(ccp(bgSp:getContentSize().width*0.5,220))
    bgSp:addChild(tipLabel)
    -- 消耗说明
    -- 金币数
    local goldCostNum = KuafuData.getRefreshCost()
    local richInfo = {
        width = bgSp:getContentSize().width, -- 宽度
        linespace = 2,  -- 行间距
        alignment = 2,  -- 对齐方式  1 左对齐，2 居中， 3右对齐
        lineAlignment = 2,  -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
        labelDefaultFont = g_sFontPangWa,  -- 默认字体
        labelDefaultColor = ccc3(0x78,0x25,0x00),  -- 默认字体颜色
        labelDefaultSize = 30,  -- 默认字体大小
        defaultType = "CCLabelTTF",
        elements = {
            {
                type = "CCLabelTTF", 
                newLine = false,
                text = GetLocalizeStringBy("key_8224"),  -- 是否消耗
            },
            {
                type = "CCSprite",
                newLine = false,
                image = "images/common/gold.png",
            },
            {
                type = "CCRenderLabel", 
                newLine = false,
                text = goldCostNum,
                color = ccc3(0xfe,0xdb,0x1c),
            },
            {
                type = "CCLabelTTF", 
                newLine = false,
                text = GetLocalizeStringBy("key_2366"),  -- 刷新对手
            },
        },
    }
    local tipDesc = LuaCCLabel.createRichLabel(richInfo)
    tipDesc:setAnchorPoint(ccp(0.5,0.5))
    tipDesc:setPosition(ccp(bgSp:getContentSize().width*0.5,tipLabel:getPositionY()-60))
    bgSp:addChild(tipDesc)
    --背景按钮层
    local btnMenuBar = CCMenu:create()
    btnMenuBar:setPosition(ccp(0,0))
    btnMenuBar:setTouchPriority(-550)
    bgSp:addChild(btnMenuBar)
    --确定按钮
    local confirmMenuItem =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(180, 73),GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    confirmMenuItem:setPosition(ccp(bgSp:getContentSize().width*0.45,bgSp:getContentSize().height*0.15))
    confirmMenuItem:setAnchorPoint(ccp(1, 0))
    confirmMenuItem:registerScriptTapHandler(btnFunc)
    btnMenuBar:addChild(confirmMenuItem)
    confirmMenuItem:setTag(1)
    --取消按钮
    local closeMenuItem =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(180, 73),GetLocalizeStringBy("key_2326"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    closeMenuItem:setPosition(ccp(bgSp:getContentSize().width*0.55,bgSp:getContentSize().height*0.15))
    closeMenuItem:setAnchorPoint(ccp(0,0))
    closeMenuItem:registerScriptTapHandler(btnFunc)
    btnMenuBar:addChild(closeMenuItem)
    closeMenuItem:setTag(2)
    -- 关闭按钮
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(bgSp:getContentSize().width*0.97,bgSp:getContentSize().height*0.98))
    closeBtn:setAnchorPoint(ccp(0.5,0.5))
    closeBtn:registerScriptTapHandler(btnFunc)
    btnMenuBar:addChild(closeBtn)
    closeBtn:setTag(3)
end

--[[
    @des    : 创建是否购买提示Layer
    @para   : 
    @return : 
--]]
function showAlertLayer( ... )
    -- 初始化
    init()
    --创建背景UI
    createUI()
end
