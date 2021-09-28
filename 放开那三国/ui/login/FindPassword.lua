-- Filename: VisitorLayer.lua
-- Author: lichenyang
-- Date: 2015-04-24
-- Purpose: 找回密码

module ("FindPassword", package.seeall)

require "script/ui/tip/AlertTip"

local _username = nil
local _password = nil
local _uid = nil

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
	end
end

function showLayer( username, password, uid )
	ininlize()
	_username = username
	_password = password
	_uid = uid
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	_mainLayer = CCLayerColor:create(ccc4(11,11,11,166))
	runningScene:addChild(_mainLayer,999)

	_mainLayer:registerScriptTouchHandler(onTouchesHandler, false, -128, true)
	_mainLayer:setTouchEnabled(true)
 
	local size_more_w = 15

	-- 九宫格图片
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
	mainBg= CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	require "script/ui/rewardCenter/AdaptTool"
	mainBg:setPreferredSize(CCSizeMake(640,496))
	mainBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height/2))
	mainBg:setAnchorPoint(ccp(0.5,0.5))
	AdaptTool.setAdaptNode(mainBg)
	_mainLayer:addChild(mainBg)


	local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(mainBg:getContentSize().width*0.5,mainBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	mainBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("lcyx_9043"), g_sFontPangWa,35,2,ccc3(0x0,0x00,0x0),type_stroke)
	labelTitle:setSourceAndTargetColor(ccc3( 0xff, 0xf0, 0x49), ccc3( 0xff, 0xa2, 0x00));
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5+2 ))
	labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)

	--内块
	local rect = CCRectMake(0,0,61,47)
	local insert = CCRectMake(18,18,1,1)
	_tableViewSp = CCScale9Sprite:create("images/copy/fort/textbg.png",rect,insert)
	_tableViewSp:setPreferredSize(CCSizeMake(554,135))
	_tableViewSp:setPosition(ccp(mainBg:getContentSize().width*0.5 - _tableViewSp:getContentSize().width*0.5,290))
	mainBg:addChild(_tableViewSp)

	--提示
	local size_infoLabel = CCSizeMake(mainBg:getContentSize().width,50)
	-- local infoLabel1 = CCLabelTTF:create(GetLocalizeStringBy("bx_1013"), g_sFontName, 26,size_infoLabel,kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	-- infoLabel1:setPosition(ccp(mainBg:getContentSize().width*0.5, 243-10))
	-- infoLabel1:setColor(ccc3(100, 25, 4))
	-- infoLabel1:setAnchorPoint(ccp(0.5,0.5))
	-- mainBg:addChild(infoLabel1)
	local infoLabel2 = CCLabelTTF:create(GetLocalizeStringBy("lcyx_9044"), g_sFontName, 28,size_infoLabel,kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	infoLabel2:setPosition(ccp(mainBg:getContentSize().width*0.5, 243-55))
	infoLabel2:setColor(ccc3(230, 0, 20))
	infoLabel2:setAnchorPoint(ccp(0.5,0.5))
	mainBg:addChild(infoLabel2)

	--用户名
	local accountLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2981"), g_sFontName, 24)
	accountLabel:setPosition(ccp(100, 75))
	accountLabel:setColor(ccc3(100, 25, 4))
	_tableViewSp:addChild(accountLabel)

	local accountNameLabel = CCLabelTTF:create(_username, g_sFontName, 24)
	accountNameLabel:setPosition(ccp(200, 74))
	accountNameLabel:setColor(ccc3(76, 160, 224))
	_tableViewSp:addChild(accountNameLabel)

	--密码
	local passwordLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1493"), g_sFontName, 24)
	passwordLabel:setPosition(ccp(100, 30))
	passwordLabel:setColor(ccc3(100, 25, 4))
	_tableViewSp:addChild(passwordLabel)

	local passwordNumberLabel = CCLabelTTF:create(_password, g_sFontName, 24)
	passwordNumberLabel:setPosition(ccp(200, 29))
	passwordNumberLabel:setColor(ccc3(76, 160, 224))
	_tableViewSp:addChild(passwordNumberLabel)

	-- 关闭按钮
	local menu =CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(-551)
	mainBg:addChild(menu,1000)
	_cancelBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	_cancelBtn:setAnchorPoint(ccp(1, 1))
	_cancelBtn:setPosition(ccp(mainBg:getContentSize().width+1, mainBg:getContentSize().height+24))
	_cancelBtn:registerScriptTapHandler(closeTip)
	menu:addChild(_cancelBtn)


	--保存图片
	require "script/libs/LuaCC"
	local btn_binding = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(270,73),GetLocalizeStringBy("bx_1012"),ccc3(255,222,0))
    btn_binding:setAnchorPoint(ccp(0.5, 0.5))
    btn_binding:setPosition(mainBg:getContentSize().width*0.5, 165-65)
	menu:addChild(btn_binding)
	btn_binding:registerScriptTapHandler(gotoSaveAccount)

	--进入游戏
	-- local btn_enter = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(250,73),GetLocalizeStringBy("key_2281"),ccc3(255,222,0))
 --    btn_enter:setAnchorPoint(ccp(0.5, 0.5))
 --    btn_enter:setPosition(mainBg:getContentSize().width*0.5, 75)
	-- menu:addChild(btn_enter)
	-- btn_enter:registerScriptTapHandler(enterGame)

end

function closeTip( ... )
	require "script/ui/tip/AlertTip"
    AlertTip.showAlert( GetLocalizeStringBy("bx_1036"), nil, false, nil)
end

function enterGame( ... )
	if isSaved then

		if (Platform.getConfig().getVisitorLoginUrl ~= nil) then
		    require "script/ui/login/AppLoginLayerVisitor"
		    AppLoginLayerVisitor.loginWithUserNameInfo(_username, _password)
		else
		  	require "script/ui/login/AppLoginLayer"
		    AppLoginLayer.loginWithUserNameInfo(_username, _password)
		end

		layerCloseCallback()
	else
		require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("bx_1036"), nil, false, nil)
		return
	end
end

function gotoSaveAccount( ... )
	--截图
    Platform.getSdk():registerScriptHandlers("saveImageToPhotosCallBack",function( param )
      require "script/utils/LuaUtil"
      local saveState = tonumber(param.code)
  	  require "script/ui/network/LoadingUI"
   	  LoadingUI.reduceLoadingUI()
      if(saveState == 0) then
      	isSaved = true
		-- if(_isShowUi == true)then
		-- 	layerCloseCallback()
		-- end
		require "script/ui/tip/AlertTip"
        AlertTip.showAlert(GetLocalizeStringBy("bx_1035")..GetLocalizeStringBy("bx_1030"), function (isConfirm)
        	-- body
	        	if isConfirm then
	        		isSaved = true
	        		enterGame()
	        	end
        	end, 
          false, nil, GetLocalizeStringBy("bx_1032"), nil,function ( ... )
          	-- body
          	enterGame()
          end , nil)
      else
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert(GetLocalizeStringBy("bx_1034")..GetLocalizeStringBy("bx_1033"), function (isConfirm)
	        	if isConfirm then
	        		isSaved = true
	        		enterGame()
	        	end
        	end, 
          true, nil, GetLocalizeStringBy("bx_1032"), GetLocalizeStringBy("bx_1031"))
        return
      end
    end)


	require "script/utils/BaseUI"
    local shareImagePath = BaseUI.getScreenshots()
    print("shareImagePath:",shareImagePath)
    if shareImagePath ~= nil then
    	local dict = CCDictionary:create()
	    dict:setObject(CCString:create("otherInfo"),"otherInfo")
	    dict:setObject(CCString:create(shareImagePath),"imagePath")
	  	Platform.getSdk():callOCFunctionWithName_oneParam_noBack("saveImageToPhotos",dict)
	   	require "script/ui/network/LoadingUI"
		LoadingUI.addLoadingUI()
	end
	-- layerCloseCallback()
end


-- 初始化
function ininlize()

	_tableView = nil
	_tableViewSp = nil
	_cancelBtn = nil
	_mainLayer = nil
	mainBg = nil
	isSaved = false
end


function layerCloseCallback( ... )
	_mainLayer:removeFromParentAndCleanup(true)
end
