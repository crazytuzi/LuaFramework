-- Filename: AppLoginLayer.lua
-- Author: hechao
-- Date: 2013-12-28
-- Purpose: appstore 登录

module ("AppLoginLayer", package.seeall)


local _isShowUi = false
local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
	end
end

function createLoginLayer( ... )
	ininlize()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	_mainLayer = CCLayerColor:create(ccc4(11,11,11,166))
	runningScene:addChild(_mainLayer,999)

	_mainLayer:registerScriptTouchHandler(onTouchesHandler, false, -128, true)
	_mainLayer:setTouchEnabled(true)
 
	-- 九宫格图片
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
	mainBg= CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	require "script/ui/rewardCenter/AdaptTool"
	mainBg:setPreferredSize(CCSizeMake(640,500))
	mainBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height/2))
	mainBg:setAnchorPoint(ccp(0.5,0.5))
	AdaptTool.setAdaptNode(mainBg)
	_mainLayer:addChild(mainBg)

	--createBgAction(mainBg)

	local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(mainBg:getContentSize().width*0.5,mainBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	mainBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_2945"), g_sFontPangWa,35,2,ccc3(0x0,0x00,0x0),type_stroke)
	labelTitle:setSourceAndTargetColor(ccc3( 0xff, 0xf0, 0x49), ccc3( 0xff, 0xa2, 0x00));
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5+2 ))
	labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)

	local infoLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3193"), g_sFontName, 24)
	infoLabel:setPosition(ccp(48, mainBg:getContentSize().height-66))
	infoLabel:setColor(ccc3(100, 25, 4))
	infoLabel:setAnchorPoint(ccp(0,0.5))
	mainBg:addChild(infoLabel)

	--内块
	local rect = CCRectMake(0,0,61,47)
	local insert = CCRectMake(18,18,1,1)
	_tableViewSp = CCScale9Sprite:create("images/copy/fort/textbg.png",rect,insert)
	_tableViewSp:setPreferredSize(CCSizeMake(554,210))
	_tableViewSp:setPosition(ccp(mainBg:getContentSize().width*0.5 - _tableViewSp:getContentSize().width*0.5,200))
	mainBg:addChild(_tableViewSp)

	local usernameLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2981"), g_sFontName, 24)
	usernameLabel:setPosition(ccp(95, 135))
	usernameLabel:setColor(ccc3(100, 25, 4))
	-- usernameLabel:setAnchorPoint(ccp(0,0))
	_tableViewSp:addChild(usernameLabel)

	local passwordLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1493"), g_sFontName, 24)
	passwordLabel:setPosition(ccp(95, 59))
	passwordLabel:setColor(ccc3(100, 25, 4))
	-- passwordLabel:setAnchorPoint(ccp(0,0))
	_tableViewSp:addChild(passwordLabel)

	text_username = CCEditBox:create (CCSizeMake(278,45), CCScale9Sprite:create("images/login/login_text_bg.png"))
	text_username:setPosition(ccp(169, 149))
	text_username:setAnchorPoint(ccp(0, 0.5))
	text_username:setPlaceHolder(GetLocalizeStringBy("key_2621"))
	text_username:setPlaceholderFontColor(ccc3(177, 177, 177))
	-- text_username:setPlaceholderFontSize(17)
	text_username:setFont(g_sFontName,24)
	text_username:setFontColor(ccc3( 0x78, 0x25, 0x00))
	text_username:setMaxLength(24)
	text_username:setReturnType(kKeyboardReturnTypeDone)
	text_username:setInputFlag (kEditBoxInputFlagInitialCapsWord)
	text_username:setText(CCUserDefault:sharedUserDefault():getStringForKey("username"))
	text_username:setTouchPriority(-129)
	text_username:setInputFlag(kEditBoxInputFlagSensitive)
	_tableViewSp:addChild(text_username)

	text_password = CCEditBox:create (CCSizeMake(278,45), CCScale9Sprite:create("images/login/login_text_bg.png"))
	text_password:setPosition(ccp(169, 73))
	text_password:setAnchorPoint(ccp(0, 0.5))
	text_password:setPlaceHolder(GetLocalizeStringBy("key_2413"))
	text_password:setPlaceholderFontColor(ccc3(177, 177, 177))
	-- text_password:setPlaceholderFontSize(17)
	text_password:setFont(g_sFontName,24)
	text_password:setFontColor(ccc3( 0x78, 0x25, 0x00))
	text_password:setMaxLength(24)
	text_password:setReturnType(kKeyboardReturnTypeDone)
	text_password:setInputFlag (kEditBoxInputFlagPassword)
	text_password:setText(CCUserDefault:sharedUserDefault():getStringForKey("password"))
	text_password:setTouchPriority(-129)
	_tableViewSp:addChild(text_password)

	-- 关闭按钮
	local menu =CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(-551)
	mainBg:addChild(menu,1000)
	_cancelBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	_cancelBtn:setAnchorPoint(ccp(1, 1))
	_cancelBtn:setPosition(ccp(mainBg:getContentSize().width+3, mainBg:getContentSize().height+20))
	_cancelBtn:registerScriptTapHandler(layerCloseCallback)
	menu:addChild(_cancelBtn)

	-- 清理box
	btn_delete = CCMenuItemImage:create("images/login/login_delete.png", "images/login/login_delete.png")
	btn_delete:setAnchorPoint(ccp(1, 1))
	btn_delete:setPosition(ccp(528, 296+73))
	btn_delete:registerScriptTapHandler(clearTextBox)
	menu:addChild(btn_delete)

	--修改密码
	require "script/libs/LuaCC"
	btn_renewPass = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,73),GetLocalizeStringBy("key_1750"),ccc3(255,222,0))
    btn_renewPass:setAnchorPoint(ccp(0.5, 0.5))
    btn_renewPass:setPosition(mainBg:getContentSize().width*0.5, 76*2)
	menu:addChild(btn_renewPass)
	btn_renewPass:registerScriptTapHandler(gotoRenewPass)

	--注册按钮
	-- require "script/libs/LuaCC"
	local btn_register = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,73),GetLocalizeStringBy("key_1132"),ccc3(255,222,0))
    btn_register:setAnchorPoint(ccp(0.5, 0.5))
    btn_register:setPosition(mainBg:getContentSize().width*0.30, 74)
	menu:addChild(btn_register)
	btn_register:registerScriptTapHandler(gotoRegister)

	--登录按钮
	local btn_login = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,73),GetLocalizeStringBy("key_2945"),ccc3(255,222,0))
    btn_login:setAnchorPoint(ccp(0.5, 0.5))
    btn_login:setPosition(mainBg:getContentSize().width*0.70, 74)
	menu:addChild(btn_login)
	btn_login:registerScriptTapHandler(doLogin)

	if(CCUserDefault:sharedUserDefault():getStringForKey("password") == "")then
		btn_delete:setVisible(false)
		btn_renewPass:setVisible(false)
	end
	_isShowUi = true
end

function clearTextBox( ... )
	text_username:setText("")
	text_password:setText("")
	btn_delete:setVisible(false)
end

function gotoRegister( ... )
	layerCloseCallback()
	require "script/ui/login/RegisterLayer"
	RegisterLayer.showLoginLayer()
end

function gotoRenewPass( ... )
	layerCloseCallback()
	require "script/ui/login/ChangePasswordLayer"
	ChangePasswordLayer.showRenewLayer()
end


function doLogin( ... )
	local username = text_username:getText()
	local password = text_password:getText()
	loginWithUserNameInfo( username, password)
end

local _isAutoEnterGame = false
_username = nil
_password = nil
function loginWithUserNameInfo( username, password, isAutoEnterGame)
	_isAutoEnterGame = isAutoEnterGame or false
	if(username == "" or password == "")then
		require "script/ui/tip/AlertTip"
    	AlertTip.showAlert(GetLocalizeStringBy("key_1901"), nil)
		return
	end

	_username = username
	_password = password
	username = string.replacePlusToSpace(username)
	password = string.replacePlusToSpace(password)
	if(_isShowUi == true)then
		btn_delete:setVisible(true)
	end

	require "script/utils/TimeUtil"

	local timeTemp = TimeUtil.getSvrTimeByOffset()
	config = Platform.getConfig()
	local url = nil
	local hash_url = nil
	if(Platform.isDebug())then
		hash_url = config.getLoginUrl_debug(username,password)
		url = config.getLoginUrl_debug(string.urlEncode(username),string.urlEncode(password))
	else
		hash_url = config.getLoginUrl(username,password)
		url = config.getLoginUrl(string.urlEncode(username),string.urlEncode(password))
	end
	url = url .. "&time=" .. timeTemp
	hash_url = hash_url .. "&time=" .. timeTemp
	local t_hash_str = string.sortUrlParams(hash_url)
	print("t_hash_str:", t_hash_str)
	local temp_hash = t_hash_str .. "platform_ZuiGame"
	url = url .. "&hash=" .. BTUtil:getMd5SumByString( temp_hash )
	httpClent = CCHttpRequest:open(url, kHttpGet)
    print("login url",url)
    require "script/ui/network/LoadingUI"
 	LoadingUI.addLoadingUI()
    httpClent:sendWithHandler(registerRequestCallback)
end

function registerRequestCallback( res, hnd )
	parseResponse( res, hnd,_username, _password)

end

function parseResponse( res, hnd, username, password)
	require "script/ui/network/LoadingUI"
	LoadingUI.reduceLoadingUI()

	if(res:getResponseCode()~=200)then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_1810"), nil, false, nil)
        return
    end

  	local xml = require "script/utils/LuaXml"
    local xmlTable = LuaXML.eval(res:getResponseData())
    --保存登录数据
    
    if(xmlTable == nil or xmlTable:find("uid") == nil) then
		Platform.loginOut()
		-- AlertTip.showAlert(GetLocalizeStringBy("key_1889"), loginAgain)
		require "script/ui/tip/AlertTip"
		AlertTip.showAlert(GetLocalizeStringBy("key_3194"), nil)
		CCLuaLog("swap user info error -> uid is nill")
		return
    end
    
    local uid = xmlTable:find("uid")[1]
    local errornu = xmlTable:find("errornu")[1]
    local errordesc = xmlTable:find("errordesc")[1]
    local newuser = xmlTable:find("errordesc")[1]
    print("uid = ",uid)
    print("errornu=",errornu)
    print("errordesc=",errordesc)
    print("newuser=",newuser)

    --广告需求
    if g_system_type ~= kBT_PLATFORM_ANDROID and g_system_type ~= kBT_PLATFORM_WP8 then
    local adurl
    if(Platform.isDebug())then
		adurl = config.getADUrl_debug(uid)
	else
		adurl = config.getADUrl(uid)
	end
		if(adurl ~= nil or adurl ~= "")then
	print("adurl",adurl)
	httpClent = CCHttpRequest:open(adurl, kHttpGet)
	httpClent:sendWithHandler(function()end)
		end
    end

    if(errornu == "0") then
    	print("saveAndLogin = " .. username .. "..." .. password)
      	saveAndLogin( uid, username,password)
        if(_isShowUi == true)then
		    layerCloseCallback()
		end
    elseif(errornu == "3") then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert(GetLocalizeStringBy("key_1411"), nil)
        return
      
    else
      	-- SDK91Share:shareSDK91():loginOut()
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert(errordesc, nil)
        return
    end
    
end

function saveAndLogin( uid, username,password)
	Platform.setPid(uid)
	--登录逻辑服务器
	CCUserDefault:sharedUserDefault():setStringForKey("username",username)
	CCUserDefault:sharedUserDefault():setStringForKey("password",password)
	CCUserDefault:sharedUserDefault():setStringForKey("loginState",Platform.getConfig().kLoginsStateZYXLogin)
	CCUserDefault:sharedUserDefault():flush()

	LoginScene.changeUserName(username)
	if(type(config.setLoginInfo) == "function")then
		config.setLoginInfo(xmlTable)
	end

	if(_isAutoEnterGame)then
		-- if(not Platform.isDebug())then
	        LoginScene.loginLogicServer(uid)
	    -- else
	    --     local serverInfo = ServerList.getSelectServerInfo()
	    --     serverInfo.pid = uid
	    --     print("login arg")
	    --     print_t(serverInfo)
	    --     LoginScene.loginInServer(serverInfo)
	    -- end
	end 
	if(type(Platform.setCrashInfo) == "function")then
		Platform.setCrashInfo()
	end
end

-- 初始化
function ininlize()
	_mainLayer = nil
	_isShowUi = false
end


function layerCloseCallback( ... )
	_isShowUi = false
	_mainLayer:removeFromParentAndCleanup(true)
end
