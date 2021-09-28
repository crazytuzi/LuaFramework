-- FileName: GuildChangeName.lua 
-- Author: licong 
-- Date: 15/5/28 
-- Purpose: 军团改名


module("GuildChangeName", package.seeall)

require "script/ui/guild/GuildService"
require "script/ui/guild/GuildDataCache"

local _bgLayer                  		= nil
local _bgSprite 						= nil
local _nameEditBox 						= nil

local _costNum 							= nil

local _layer_priority 					= nil -- 界面优先级
local _zOrder 							= nil -- 界面z轴

--[[
    @des    :init
--]]
function init( ... )
	_bgLayer                    		= nil
	_bgSprite 							= nil
	_nameEditBox 						= nil

	_costNum 							= nil

	_layer_priority 					= nil
	_zOrder 							= nil 
end

--  汉字的utf8 转换，
function getStringLength( str)
    local strLen = 0
    local i =1
    while i<= #str do
        if(string.byte(str,i) > 127) then
            -- 汉字
            strLen = strLen + 2
            i= i+ 3
        else
            i =i+1
            strLen = strLen + 1
        end
    end
    return strLen
end

-------------------------------------------------------- 按钮事件 ---------------------------------------------------------
--[[
	@des 	:touch事件处理
--]]
function layerTouch(eventType, x, y)
    return true
end

--[[
    @des    :回调onEnter和onExit事件
--]]
function onNodeEvent( event )
    if (event == "enter") then
        _bgLayer:registerScriptTouchHandler(layerTouch,false,_layer_priority,true)
        _bgLayer:setTouchEnabled(true)
    elseif (event == "exit") then
    end
end

--[[
	@des 	:返回按钮回调
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    if( _bgLayer ~= nil )then
    	_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer=nil
    end
end

--[[
	@des 	:返回按钮回调
	'used'					名称已经使用
	'blank'					名称存在空格
	'harmony'				名称存在敏感词
	'forbidden_guildwar'	报名跨服赛
--]]
function yesCallBackFun( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    local cheangName = _nameEditBox:getText()
    print("cheangName=>",cheangName)
    -- 与自己名字相同
    if(cheangName == GuildDataCache.getGuildName()) then
    	AnimationTip.showTip(GetLocalizeStringBy("lic_1580"))
	 	return
    end
    -- 空字符
    if(cheangName== "") then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1581") )
		return
	end
	-- 字符长度
	if (getStringLength(cheangName)>10) then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1582"))
 		return
	end
	
    -- 金币不足
	if( UserModel.getGoldNumber() < _costNum ) then  
		require "script/ui/tip/LackGoldTip"    
		LackGoldTip.showTip()
		return
	end

    local nextCallFun = function ( retData )
    	if(retData == "ok")then
    		-- 修改成功
    		-- 关闭
    		closeButtonCallback()
    		AnimationTip.showTip(GetLocalizeStringBy("lic_1579"))
            -- 扣除金币
            UserModel.addGoldNumber(-_costNum)
    		-- 修改缓存
    		GuildDataCache.setGuildName( cheangName )
    		-- 刷新界面
    		GuildMainLayer.refreshGuildAttr()
    	elseif(retData == "used")then
    		AnimationTip.showTip(GetLocalizeStringBy("lic_1575"))
    	elseif(retData == "blank")then
    		AnimationTip.showTip(GetLocalizeStringBy("lic_1576"))
    	elseif(retData == "harmony")then
    		AnimationTip.showTip(GetLocalizeStringBy("lic_1577"))
    	elseif(retData == "forbidden_guildwar")then
    		AnimationTip.showTip(GetLocalizeStringBy("lic_1578"))
    	else
    		AnimationTip.showTip(GetLocalizeStringBy("lic_1583"))
    	end
    end
    -- 发请求
    GuildService.modifyName( cheangName, nextCallFun)
end



--[[
	@des 	: 创建UI
--]]
function createUI()

	-- 创建背景
	_bgSprite = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _bgSprite:setContentSize(CCSizeMake(490,378))
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    -- 适配
    setAdaptNode(_bgSprite)

	-- 按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_layer_priority-2)
    _bgSprite:addChild(menuBar)

	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_bgSprite:getContentSize().width * 0.955, _bgSprite:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menuBar:addChild(closeButton)

	-- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_bgSprite:getContentSize().width/2, _bgSprite:getContentSize().height-6.6 ))
	_bgSprite:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1571"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 提示
	local inputLabel= CCRenderLabel:create(GetLocalizeStringBy("lic_1573"), g_sFontPangWa,25,1,ccc3(0xff,0xff,0xff),type_shadow)
	inputLabel:setColor(ccc3(0x78,0x25,0x00))
	inputLabel:setPosition(_bgSprite:getContentSize().width*0.5,283)
	inputLabel:setAnchorPoint(ccp(0.5,0))
	_bgSprite:addChild(inputLabel)

	-- 编辑框
	_nameEditBox = CCEditBox:create(CCSizeMake(284,60), CCScale9Sprite:create("images/common/bg/search_bg.png"))
	_nameEditBox:setPosition(ccp(100 ,217))
	_nameEditBox:setTouchPriority(_layer_priority-2)
	_nameEditBox:setAnchorPoint(ccp(0,0))
	_nameEditBox:setPlaceHolder(GetLocalizeStringBy("lic_1572"))
	_nameEditBox:setFont(g_sFontName,24)
	_bgSprite:addChild(_nameEditBox)

	-- 消耗金币
	_costNum = GuildDataCache.getGuildNameCost()
	local richInfo = {}
    richInfo.defaultType = "CCLabelTTF"
    richInfo.labelDefaultColor = ccc3(0x00, 0x00, 0x00)
   	richInfo.labelDefaultSize = 23
   	richInfo.labelDefaultFont = g_sFontName
    richInfo.elements = {
    	{
    		type = "CCSprite",
            image = "images/common/gold.png"
    	},
    	{
        	text = tostring(_costNum),
    	}
	}
	local tipFont2 = GetLocalizeLabelSpriteBy_2("lic_1574", richInfo)
	tipFont2:setAnchorPoint(ccp(0.5, 0.5))
	tipFont2:setPosition(ccp(_bgSprite:getContentSize().width*0.5,180))
	_bgSprite:addChild(tipFont2)

	-- 按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_layer_priority-2)
    _bgSprite:addChild(menuBar)

    -- 确定
	local sureBtn= LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(158, 64),GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	sureBtn:setPosition(_bgSprite:getContentSize().width*0.25, 57)
	sureBtn:registerScriptTapHandler(yesCallBackFun)
	sureBtn:setAnchorPoint(ccp(0.5,0))
	menuBar:addChild(sureBtn)

	-- 取消
	local cancelBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(158, 64),GetLocalizeStringBy("key_2326"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setPosition(_bgSprite:getContentSize().width*0.75, 57)
	cancelBtn:registerScriptTapHandler(closeButtonCallback)
	cancelBtn:setAnchorPoint(ccp(0.5,0))
	menuBar:addChild(cancelBtn)
	
end

--[[
	@des 	: 修改军团名字
	@param 	: p_layer_priority:界面优先级, p_zOrder:界面Z轴
	@return :
--]]
function showLayer( p_layer_priority, p_zOrder )
	print("p_layer_priority",p_layer_priority, "p_zOrder",p_zOrder)
	-- 初始化
	init()

	-- 接收参数
	_layer_priority = p_layer_priority or -600
	_zOrder = p_zOrder or 1000

	-- 创建ui
	_bgLayer = CCLayerColor:create(ccc4(8,8,8,150))
    _bgLayer:registerScriptHandler(onNodeEvent) 
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder,1)

    -- 创建ui
    createUI()
end

























