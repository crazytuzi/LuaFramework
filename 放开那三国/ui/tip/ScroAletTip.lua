-- Filename：	ScroAletTip.lua
-- Author：		zhz
-- Date：		2014-6-3
-- Purpose：		提示警告，需要用户选择的,带一个CCScrollView ,文字支持滑动

module("ScroAletTip", package.seeall)

require "script/ui/common/LuaMenuItem"
require "script/ui/main/MainScene"
require "script/localized/LocalizedUtil"


local _cormfirmCBFunc = nil 
local _closeCallbackFunc = nil
local _argsCB = nil

local _alertLayer
local _bgHeight
local _alertBgSize
local _alertBg
local _titleTxt

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
    else
      
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_alertLayer:registerScriptTouchHandler(onTouchesHandler, false, -5600, true)
		_alertLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_alertLayer:unregisterScriptTouchHandler()
        _alertLayer = nil
       
	end
end



function closeAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_alertLayer) then
		_alertLayer:removeFromParentAndCleanup(true)
		_alertLayer = nil
	end
	if(_closeCallbackFunc )then
		_closeCallbackFunc()
	end
end

-- 按钮响应
function menuAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_alertLayer) then
		_alertLayer:removeFromParentAndCleanup(true)
		_alertLayer = nil
	end
	print ("tag==", tag)
	local isConfirm = false
	if(tag == 10001) then
		isConfirm = true
	elseif (tag == 10002) then
		isConfirm = false
	end

	-- 回调
	if (_cormfirmCBFunc) then
		_cormfirmCBFunc(isConfirm, _argsCB)
	end
	
end




--[[
	@desc	alertView
	@para 	tipText, 		 显示文字 string
			bgHeight         背景的高度,默认是820
			titleTxt         标题的文字，默认是“说明”      
			confirmCBFunc,   回调 func
			isNeedCancel,	 是否需要取消按钮 bool
	 		argsCB,			 回调传参  
	@return void
--]]
function showAlert( tParaTxt , bgHeight , titleTxt,confirmCBFunc, isNeedCancel, argsCB, confirmTitle, cancelTitle, closeCallbackFunc,isNeedKuoChong)
	_cormfirmCBFunc = confirmCBFunc
	_argsCB = argsCB
	_closeCallbackFunc = closeCallbackFunc
	_bgHeight = bgHeight or 820
	_titleTxt = titleTxt or GetLocalizeStringBy("key_3223")
	_tParaTxt = tParaTxt 


	confirmTitle = confirmTitle or GetLocalizeStringBy("key_2864")
	cancelTitle = cancelTitle or GetLocalizeStringBy("key_2326")
	if(_alertLayer) then
		_alertLayer:removeFromParentAndCleanup(true)
		_alertLayer = nil
	end

	-- layer
	_alertLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_alertLayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_alertLayer, 2000)

	-- 背景
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	_alertBg = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	_alertBg:setPreferredSize(CCSizeMake(520, _bgHeight ))
	_alertBg:setAnchorPoint(ccp(0.5, 0.5))
	_alertBg:setPosition(ccp(_alertLayer:getContentSize().width*0.5, _alertLayer:getContentSize().height*0.5))
	_alertLayer:addChild(_alertBg)
	_alertBg:setScale(g_fScaleX)	

	_alertBgSize = _alertBg:getContentSize()

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	_alertBg:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-5601)
	-- 关闭按钮
	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeBtn:registerScriptTapHandler(closeAction)
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(_alertBg:getContentSize().width*0.95, _alertBg:getContentSize().height - 10 ))
	closeMenuBar:addChild(closeBtn)

	-- 标题
	local titleLabel = CCRenderLabel:create( _titleTxt , g_sFontPangWa, 35, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    titleLabel:setColor(ccc3(0x78, 0x25, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5, 1))
    titleLabel:setPosition(ccp(_alertBgSize.width*0.5, _alertBgSize.height- 30 ))
    _alertBg:addChild(titleLabel)

	-- -- 描述
	-- local descLabel = CCLabelTTF:create(tipText, g_sFontName, 25, CCSizeMake(460, 120), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	-- descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	-- descLabel:setAnchorPoint(ccp(0.5, 0.5))
	-- descLabel:setPosition(ccp(alertBgSize.width * 0.5, alertBgSize.height*0.5))
	-- alertBg:addChild(descLabel)

	showSrcTipTxt()

	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-5601)
	_alertBg:addChild(menuBar)

	-- 确认
	require "script/libs/LuaCC"
	local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), confirmTitle,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	confirmBtn:setAnchorPoint(ccp(0.5, 0.5))

    confirmBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(confirmBtn, 1, 10001)
	
	-- 取消
	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), cancelTitle,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0.5, 0.5))
    cancelBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(cancelBtn, 1, 10002)

	if (isNeedCancel) then
		confirmBtn:setPosition(ccp(_alertBgSize.width*0.3, 68))
		cancelBtn:setPosition(ccp(_alertBgSize.width*0.7, 68))
	else
		confirmBtn:setPosition(ccp(_alertBgSize.width*0.5,68 ))
		cancelBtn:setVisible(false)
	end

	-- 背包去掉扩充用
	if(isNeedKuoChong == false)then
		cancelBtn:setPosition(ccp(_alertBgSize.width*0.5, 68))
		confirmBtn:setVisible(false)
	end
end


-- 显示scrowView 的内容
function showSrcTipTxt()

	local  txtWidth = 420

	local csvContent = CCScrollView:create()
    csvContent:setViewSize(CCSizeMake( txtWidth , _alertBgSize.height- 240 ))
    csvContent:setDirection(kCCScrollViewDirectionVertical)
    csvContent:setTouchPriority(-5703)
    csvContent:setBounceable(true)
    csvContent:setPosition(ccp( 60, 130))
    _alertBg:addChild(csvContent)

    local clContentContainer = CCLayer:create()
	csvContent:setContainer(clContentContainer)
	clContentContainer:setPosition(0,0)
	-- csvContent:setPosition(ccp(60, 186))
	

	local labelColor = ccc3(0x78, 0x25, 0x00)
	local vCellOffset = 10
	local x_pos = 0 -- _alertBgSize.width/2
	local y_pos = 0
	for i=#_tParaTxt , 1,-1 do 
		local sevenTalentTextInfo = {{content= _tParaTxt[i] , ntype="label", color=labelColor, tag=1001}}
		sevenTalentTextInfo.width = txtWidth
		local desLabel = LuaCCLabel.createRichText(sevenTalentTextInfo)
		local nHeight= desLabel:getContentSize().height
		desLabel:setPosition(ccp(x_pos, y_pos+nHeight))
		-- desLabel:setAnchorPoint(ccp(0.5,1))
	    clContentContainer:addChild(desLabel)
	    y_pos = y_pos + nHeight + vCellOffset
	end 
	csvContent:setContentSize(CCSizeMake( txtWidth,  y_pos) )
	clContentContainer:setContentSize(CCSizeMake(txtWidth, y_pos))
    -- clContentContainer:setPosition(ccp(0, 650-y_pos))
    csvContent:setContentOffset(ccp(0,csvContent:getViewSize().height-clContentContainer:getContentSize().height))

end

