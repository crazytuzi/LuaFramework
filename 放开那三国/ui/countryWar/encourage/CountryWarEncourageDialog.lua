-- FileName : CountryWarEncourageDialog.lua
-- Author   : YangRui
-- Date     : 2015-11-19
-- Purpose  : 

module("CountryWarEncourageDialog", package.seeall)

require "script/libs/LuaCCLabel"

local _bgLayer                 = nil
local _bgSp                    = nil
local _autoRecoveryBloodBtn    = nil    -- 自动回满血怒勾选框
local _autoBattle              = nil    -- 当前自动战斗勾选框状态
local _autoRecoveryBlood       = nil    -- 当前自动回满血怒到指定的数值勾选框状态
local _autoRecoveryBloodNum    = 0      -- 当前自动回满血怒到指定的数值

local kSubTenTag               = 10001
local kAddTenTag               = 10002

local _touchPriority           = nil
local _zOrder                  = nil

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
    _bgLayer              = nil
    _bgSp                 = nil
    _autoRecoveryBloodBtn = nil    -- 自动回满血怒勾选框
    _autoBattle           = nil    -- 当前自动战斗勾选框状态
    _autoRecoveryBlood    = nil    -- 当前自动回满血怒到指定的数值勾选框状态
    _autoRecoveryBloodNum = 0      -- 当前自动回满血怒到指定的数值
    
    _touchPriority        = nil
    _zOrder               = nil
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
	@des 	: 回调onEnter和onExit事件
	@param 	: 
	@return : 
--]]
function onNodeEvent( pEvent )
    if pEvent == "enter" then
    	_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
    elseif pEvent == "exit" then
    	_bgLayer:unregisterScriptTouchHandler()
    end
end

--[[
    @des    : 关闭自己
    @para   : 
    @return : 
--]]
function closeSelfCallback( ... )
    if _bgLayer ~= nil then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end
end

--[[
    @des    : 设置自动回血限度的方法
    @param  : 
    @return : 
--]]
function setAutoRecoverBloodNumFunc( ... )
    -- 确定时，保存设置的状态
    CountryWarPlaceData.setAutoRecoverPoint(_autoRecoveryBloodNum*100)
    -- 3000表示30%
    CountryWarEncourageController.setRecoverPara(_autoRecoveryBloodNum*100)
end

--[[
    @des    : 按钮回调
    @param  :
    @return :
--]]
function confirmBtnCallback( ... )
    -- 音效
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- 原始状态
    local oriAutoBattle           = CountryWarEncourageData.getAutoBattleState()
    local oriAutoRecoveryBlood    = CountryWarPlaceData.getAutoRecoverState()  -- 1 2
    -- 自动参战 前端模拟
    if _autoBattle ~= oriAutoBattle then
        print("===|_autoBattle changed|===",_autoBattle)
        -- 确定时，保存设置的状态
        CountryWarEncourageData.setAutoBattleState(_autoBattle)
        if _autoBattle == true then
            -- 自动参战
            CountryWarPlaceLayer.checkAutoJoin()
        end
    end
    -- 有更改
    if _autoRecoveryBlood ~= oriAutoRecoveryBlood then
        -- 有更改
        print("===|_autoRecoveryBlood changed|===",_autoRecoveryBlood)
        -- 当前是打开状态
        CountryWarEncourageController.turnAutoRecover(_autoRecoveryBlood,function ( ... )
            setAutoRecoverBloodNumFunc()
        end)
    else
        -- 无更改
        -- 判断是不是已经打开
        -- 若打开的状态下   改变了设定的值
        if _autoRecoveryBlood == 1 then
            setAutoRecoverBloodNumFunc()
        end
    end
    closeSelfCallback()
end

--[[
    @des    : 取消按钮回调
    @param  : 
    @return : 
--]]
function cancelBtnCallback( ... )
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    closeSelfCallback()
end

--[[
	@des 	: 自动参战勾选框回调
	@param 	: 
	@return : 
--]]
function autoBattleBtnCallback( ... )
	if _autoBattle then
		_autoBattle = false
	else
		_autoBattle = true
	end
end

--[[
	@des 	: 回满血怒勾选框回调
	@param 	: 
	@return : 
--]]
function autoRecoveryBloodBtnCallback( ... )
	if _autoRecoveryBlood == 1 then
		_autoRecoveryBlood = 2
	else
		_autoRecoveryBlood = 1
	end
end

--[[
	@des 	: 改变血怒的回调
	@param 	: 
	@return : 
--]]
function changeNumAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if ( tag == kSubTenTag ) then
		-- -10
		_autoRecoveryBloodNum = _autoRecoveryBloodNum-10
	elseif ( tag == kAddTenTag ) then
		-- +10
		_autoRecoveryBloodNum = _autoRecoveryBloodNum+10
	end
	-- 下限
    local lower,upper = CountryWarEncourageData.getAutoRecoveryBloodRange()
	if ( _autoRecoveryBloodNum < lower ) then
		_autoRecoveryBloodNum = lower
	end
	-- 上限
	if ( _autoRecoveryBloodNum >= upper ) then
		_autoRecoveryBloodNum = upper
	end
	_autoRecoveryBloodNumLabel:setString(GetLocalizeStringBy("yr_5000",_autoRecoveryBloodNum))
end

--[[
	@des 	: 创建内部内容
	@param 	: 
	@return : 
--]]
function createInnerContent( ... )
	-- 二级背景
	local innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerBgSp:setContentSize(CCSizeMake(520,300))
	innerBgSp:setAnchorPoint(ccp(0.5,0))
	innerBgSp:setPosition(ccp(_bgSp:getContentSize().width*0.5,110))
	_bgSp:addChild(innerBgSp)
	-- 设置
	-- 富文本
	local richInfo = {
        createMenu = function()
            return CCMenu:create()
        end,
        touchPriority = _touchPriority-20,   -- menu的优先级
        width = 540, -- 宽度
        linespace = 20, -- 行间距
        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
        labelDefaultFont = g_sFontPangWa,      -- 默认字体
        labelDefaultColor = ccc3(0xff,0xff,0xff), -- 默认字体颜色
        labelDefaultSize = 25,         -- 默认字体大小
        defaultType = "CCRenderLabel",
        defaultRenderType = 1,
        defaultStrokeSize = 1,
        defaultStrokeColor = ccc3(0x0,0x0,0x0),
        elements = {
            {
                type = "CCMenuItem",
                newLine = false,
                create = function()
					-- 设置勾选框资源
					local checkBg  = CCMenuItemImage:create("images/common/check_bg.png","images/common/check_bg.png")
					local checkBtn = CCMenuItemImage:create("images/common/check_selected.png","images/common/check_selected.png")
					checkBg:setAnchorPoint(ccp(0.5,0.5))
					checkBtn:setAnchorPoint(ccp(0.5,0.5))
                	local autoBattleBtn = CCMenuItemToggle:create(checkBg)
					autoBattleBtn:addSubItem(checkBtn)
					autoBattleBtn:setAnchorPoint(ccp(0.5,0.5))
					autoBattleBtn:setPosition(ccpsprite(0.1,0.8,innerBgSp))
					autoBattleBtn:registerScriptTapHandler(autoBattleBtnCallback)
					if _autoBattle then
						autoBattleBtn:setSelectedIndex(1)
					else
						autoBattleBtn:setSelectedIndex(0)
					end

                    return autoBattleBtn
                end 
            },
            {
                newLine = false,
                text = GetLocalizeStringBy("yr_5001"),  -- 自动参战
                renderType = 1,  -- 1 描边  2 投影
            },
            {
                type = "CCMenuItem",
                newLine = true,
                create = function()
					-- 设置勾选框资源
					local checkBg  = CCMenuItemImage:create("images/common/check_bg.png","images/common/check_bg.png")
					local checkBtn = CCMenuItemImage:create("images/common/check_selected.png","images/common/check_selected.png")
					checkBg:setAnchorPoint(ccp(0.5,0.5))
					checkBtn:setAnchorPoint(ccp(0.5,0.5))
                    _autoRecoveryBloodBtn = CCMenuItemToggle:create(checkBg)
					_autoRecoveryBloodBtn:addSubItem(checkBtn)
					_autoRecoveryBloodBtn:setAnchorPoint(ccp(0.5,0.5))
					_autoRecoveryBloodBtn:setPosition(ccpsprite(0.1,0.8,innerBgSp))
					_autoRecoveryBloodBtn:registerScriptTapHandler(autoRecoveryBloodBtnCallback)
					if _autoRecoveryBlood == 1 then
						_autoRecoveryBloodBtn:setSelectedIndex(1)
					else
						_autoRecoveryBloodBtn:setSelectedIndex(0)
					end

                    return _autoRecoveryBloodBtn
                end 
            },
            {
                newLine = false,
                text = GetLocalizeStringBy("yr_5002"),  -- 血量低于
                renderType = 1,  -- 1 描边  2 投影
            },
            {
                type = "CCNode",
                newLine = false,
                create = function()
                    local node = CCNode:create()
                    node:setContentSize(CCSizeMake(450,0))
					node:setAnchorPoint(ccp(0.5,0))
					node:setScale(0.5)
                    -- 加减的按钮
					local changeNumBar = CCMenu:create()
					changeNumBar:setAnchorPoint(ccp(0.5,0.5))
					changeNumBar:setPosition(ccp(0,0))
					changeNumBar:setTouchPriority(_touchPriority-30)
					node:addChild(changeNumBar)
					-- -10
                    local tSprite = {normal="images/common/btn/anniu_red_btn_n.png",selected="images/common/btn/anniu_red_btn_h.png"}
                    local tLabel = {text="-10",fontsize=40,color=ccc3(0xff,0xf6,0x00)}
					local reduce10Btn = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite,tLabel)
					reduce10Btn:setAnchorPoint(ccp(0,0.5))
					reduce10Btn:setPosition(ccp(4,node:getContentSize().height/2))
					reduce10Btn:registerScriptTapHandler(changeNumAction)
					changeNumBar:addChild(reduce10Btn,1,kSubTenTag)
					-- 数量背景
					local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
					numberBg:setContentSize(CCSizeMake(170,65))
					numberBg:setAnchorPoint(ccp(0,0.5))
					numberBg:setPosition(ccp(reduce10Btn:getPositionX()+reduce10Btn:getContentSize().width+10,node:getContentSize().height/2))
					node:addChild(numberBg)
					-- 数量数字
					_autoRecoveryBloodNumLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_5000",_autoRecoveryBloodNum),g_sFontPangWa,36,1,ccc3(0x49,0x00,0x00),type_stroke)
				    _autoRecoveryBloodNumLabel:setColor(ccc3(0xff,0xf6,0x00))
					_autoRecoveryBloodNumLabel:setAnchorPoint(ccp(0.5,0.5))
				    _autoRecoveryBloodNumLabel:setPosition(ccp(numberBg:getContentSize().width/2,numberBg:getContentSize().height/2))
				    numberBg:addChild(_autoRecoveryBloodNumLabel)
					-- +10
                    local tSprite = {normal="images/common/btn/anniu_red_btn_n.png",selected="images/common/btn/anniu_red_btn_h.png"}
                    local tLabel = {text="+10",fontsize=40,color=ccc3(0xff,0xf6,0x00)}
					local addition10Btn = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite,tLabel)
					addition10Btn:setAnchorPoint(ccp(0,0.5))
					addition10Btn:setPosition(ccp(numberBg:getPositionX()+numberBg:getContentSize().width+10,node:getContentSize().height/2))
					addition10Btn:registerScriptTapHandler(changeNumAction)
					changeNumBar:addChild(addition10Btn,1,kAddTenTag)

                    return node
                end
            },
            {
                newLine = false,
                text = GetLocalizeStringBy("yr_5003"),  -- 时，
                renderType = 1,  -- 1 描边  2 投影
            },
            {
                type = "CCNode",
                newLine = true,
                create = function()
                    local node = CCLayerColor:create(ccc4(255,255,255,0))
                    node:setContentSize(CCSizeMake(50,25))
                    return node
                end
            },
            {
                newLine = false,
                text = GetLocalizeStringBy("yr_5004"),  -- 自动使用
                renderType = 1,  -- 1 描边  2 投影
            },
            {
                newLine = false,
                text = CountryWarEncourageData.getRecoveryBloodCost(),  -- 国战币
                color = ccc3(0xff,0xf6,0x00),
                renderType = 1,  -- 1 描边  2 投影
            },
            {
                type = "CCSprite",
                newLine = false,
                image = "images/common/countrycoin.png",  -- 文件路径
            },
            {
                newLine = false,
                text = GetLocalizeStringBy("yr_5005"),  -- 回满血怒。
                renderType = 1,  -- 1 描边  2 投影
            },
        }
    }
    local settingLayer = LuaCCLabel.createRichLabel(richInfo)
    settingLayer:setAnchorPoint(ccp(0,0))
    settingLayer:setPosition(ccp(40,60))
    innerBgSp:addChild(settingLayer)
end

--[[
	@des 	: 创建UI
	@param 	: 
	@return : 
--]]
function createUI( ... )
    -- bg
    _bgSp = CCScale9Sprite:create("images/common/viewbg1.png")
    _bgSp:setContentSize(CCSizeMake(580,480))
    _bgSp:setAnchorPoint(ccp(0.5,0.5))
    _bgSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgSp:setScale(g_fScaleX)
    _bgLayer:addChild(_bgSp)
	-- title bg
	local titleSp = CCSprite:create("images/common/viewtitle1.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(_bgSp:getContentSize().width/2,_bgSp:getContentSize().height*0.986))
	_bgSp:addChild(titleSp)
	-- title  设置
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_5006"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2,titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)
    --背景按钮层
    local btnMenuBar = CCMenu:create()
    btnMenuBar:setPosition(ccp(0,0))
    btnMenuBar:setTouchPriority(_touchPriority-10)
    _bgSp:addChild(btnMenuBar)
    --确定按钮
    local confirmMenuItem =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(180,73),GetLocalizeStringBy("key_1465"),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
    confirmMenuItem:setAnchorPoint(ccp(1,0))
    confirmMenuItem:setPosition(ccp(_bgSp:getContentSize().width*0.45,30))
    confirmMenuItem:registerScriptTapHandler(confirmBtnCallback)
    btnMenuBar:addChild(confirmMenuItem)
    --取消按钮
    local closeMenuItem =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(180,73),GetLocalizeStringBy("key_2326"),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
    closeMenuItem:setAnchorPoint(ccp(0,0))
    closeMenuItem:setPosition(ccp(_bgSp:getContentSize().width*0.55,30))
    closeMenuItem:registerScriptTapHandler(cancelBtnCallback)
    btnMenuBar:addChild(closeMenuItem)
    -- 关闭按钮
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(_bgSp:getContentSize().width*0.97,_bgSp:getContentSize().height*0.98))
    closeBtn:setAnchorPoint(ccp(0.5,0.5))
    closeBtn:registerScriptTapHandler(cancelBtnCallback)
    btnMenuBar:addChild(closeBtn)
    -- 创建二级内容
    createInnerContent()
end

--[[
	@des 	: 创建Dialog
	@param 	: 
	@return : 
--]]
function createLayer( pTouchPriority, pZorder )
    -- init
    init()
    _touchPriority = pTouchPriority or -620
    _zOrder = pZorder or 1000
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
	-- 进入界面时获取之前的状态
    _autoBattle           = CountryWarEncourageData.getAutoBattleState()
    _autoRecoveryBlood    = CountryWarPlaceData.getAutoRecoverState()  -- 1 2
    _autoRecoveryBloodNum = CountryWarPlaceData.getAutoRecoverPoint()
	-- createUI
	createUI()

    return _bgLayer
end

--[[
    @des    : show Dialog
    @param  : 
    @return : 
--]]
function showLayer( pTouchPriority, pZorder )
    local layer = createLayer(pTouchPriority,pZorder)
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(layer,_zOrder)
end
