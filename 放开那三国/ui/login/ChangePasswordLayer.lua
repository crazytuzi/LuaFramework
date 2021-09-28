-- Filename: ChangePasswordLayer.lua
-- Author: hechao
-- Date: 2013-12-18
-- Purpose: appstore 修改密码

module ("ChangePasswordLayer", package.seeall)

require "script/ui/tip/AlertTip"

local renewpassUrl = Platform.getConfig().getChangePasswordUrl()

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
	end
end

function showRenewLayer( ... )
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
	mainBg:setPreferredSize(CCSizeMake(640,496))
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
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1750"), g_sFontPangWa,35,2,ccc3(0x0,0x00,0x0),type_stroke)
	labelTitle:setSourceAndTargetColor(ccc3( 0xff, 0xf0, 0x49), ccc3( 0xff, 0xa2, 0x00));
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5+2 ))
	labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)

	--内块
	local rect = CCRectMake(0,0,61,47)
	local insert = CCRectMake(18,18,1,1)
	_tableViewSp = CCScale9Sprite:create("images/copy/fort/textbg.png",rect,insert)
	_tableViewSp:setPreferredSize(CCSizeMake(554,310))
	_tableViewSp:setPosition(ccp(mainBg:getContentSize().width*0.5 - _tableViewSp:getContentSize().width*0.5,130))
	mainBg:addChild(_tableViewSp)

	local username = CCLabelTTF:create(GetLocalizeStringBy("key_2981"), g_sFontName, 21)
	username:setPosition(ccp(95, 33+76*3))
	username:setColor(ccc3(100, 25, 4))
	-- username:setAnchorPoint(ccp(0,0))
	_tableViewSp:addChild(username)

	local oldPassword = CCLabelTTF:create(GetLocalizeStringBy("key_3296"), g_sFontName, 21)
	oldPassword:setPosition(ccp(95, 33+76*2))
	oldPassword:setColor(ccc3(100, 25, 4))
	-- oldPassword:setAnchorPoint(ccp(0,0))
	_tableViewSp:addChild(oldPassword)

	local password = CCLabelTTF:create(GetLocalizeStringBy("key_2961"), g_sFontName, 21)
	password:setPosition(ccp(95, 33+76*1))
	password:setColor(ccc3(100, 25, 4))
	-- password:setAnchorPoint(ccp(0,0))
	_tableViewSp:addChild(password)

	local conformPassword = CCLabelTTF:create(GetLocalizeStringBy("key_2694"), g_sFontName, 21)
	conformPassword:setPosition(ccp(52, 33))
	conformPassword:setColor(ccc3(100, 25, 4))
	-- conformPassword:setAnchorPoint(ccp(0,0))
	_tableViewSp:addChild(conformPassword)


	text_username = CCEditBox:create (CCSizeMake(278,45), CCScale9Sprite:create("images/login/login_text_bg.png"))
	text_username:setPosition(ccp(169, 43+76*3))
	text_username:setAnchorPoint(ccp(0, 0.5))
	text_username:setPlaceHolder(GetLocalizeStringBy("key_2621"))
	text_username:setPlaceholderFontColor(ccc3(177, 177, 177))
	-- text_username:setPlaceholderFontSize(17)
	text_username:setFont(g_sFontName,24)
	text_username:setFontColor(ccc3( 100, 100, 100))
	text_username:setMaxLength(24)
	text_username:setReturnType(kKeyboardReturnTypeDone)
	text_username:setInputFlag (kEditBoxInputFlagInitialCapsWord)
	text_username:setTouchPriority(-129)
	text_username:setText(CCUserDefault:sharedUserDefault():getStringForKey("username"))
	text_username:setEnabled(false)
	_tableViewSp:addChild(text_username)

	text_passwordOld = CCEditBox:create (CCSizeMake(278,45), CCScale9Sprite:create("images/login/login_text_bg.png"))
	text_passwordOld:setPosition(ccp(169, 43+76*2))
	text_passwordOld:setAnchorPoint(ccp(0, 0.5))
	text_passwordOld:setPlaceHolder(GetLocalizeStringBy("key_3151"))
	text_passwordOld:setPlaceholderFontColor(ccc3(177, 177, 177))
	-- text_passwordOld:setPlaceholderFontSize(17)
	text_passwordOld:setFont(g_sFontName,24)
	text_passwordOld:setFontColor(ccc3( 0x78, 0x25, 0x00))
	text_passwordOld:setMaxLength(24)
	text_passwordOld:setReturnType(kKeyboardReturnTypeDone)
	text_passwordOld:setInputFlag (kEditBoxInputFlagPassword)
	text_passwordOld:setTouchPriority(-129)
	_tableViewSp:addChild(text_passwordOld)

	text_password = CCEditBox:create (CCSizeMake(278,45), CCScale9Sprite:create("images/login/login_text_bg.png"))
	text_password:setPosition(ccp(169, 43+76))
	text_password:setAnchorPoint(ccp(0, 0.5))
	text_password:setPlaceHolder(GetLocalizeStringBy("key_3289"))
	text_password:setPlaceholderFontColor(ccc3(177, 177, 177))
	-- text_password:setPlaceholderFontSize(17)
	text_password:setFont(g_sFontName,24)
	text_password:setFontColor(ccc3( 0x78, 0x25, 0x00))
	text_password:setMaxLength(24)
	text_password:setReturnType(kKeyboardReturnTypeDone)
	text_password:setInputFlag (kEditBoxInputFlagPassword)
	text_password:setTouchPriority(-129)
	_tableViewSp:addChild(text_password)


	text_confrom_password = CCEditBox:create (CCSizeMake(278,45), CCScale9Sprite:create("images/login/login_text_bg.png"))
	text_confrom_password:setPosition(ccp(169, 43))
	text_confrom_password:setAnchorPoint(ccp(0, 0.5))
	text_confrom_password:setPlaceHolder(GetLocalizeStringBy("key_2388"))
	text_confrom_password:setPlaceholderFontColor(ccc3(177, 177, 177))
	-- text_confrom_password:setPlaceholderFontSize(17)
	text_confrom_password:setFont(g_sFontName,24)
	text_confrom_password:setFontColor(ccc3( 0x78, 0x25, 0x00))
	text_confrom_password:setMaxLength(24)
	text_confrom_password:setReturnType(kKeyboardReturnTypeDone)
	text_confrom_password:setInputFlag (kEditBoxInputFlagPassword)
	text_confrom_password:setTouchPriority(-129)
	_tableViewSp:addChild(text_confrom_password)

	-- 关闭按钮
	local menu =CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(-551)
	mainBg:addChild(menu,1000)
	_cancelBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	_cancelBtn:setAnchorPoint(ccp(1, 1))
	_cancelBtn:setPosition(ccp(mainBg:getContentSize().width+1, mainBg:getContentSize().height+14))
	_cancelBtn:registerScriptTapHandler(layerCloseCallback)
	menu:addChild(_cancelBtn)

	--注册按钮
	require "script/libs/LuaCC"
	local btn_register = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,73),GetLocalizeStringBy("key_1750"),ccc3(255,222,0))
    btn_register:setAnchorPoint(ccp(0.5, 0.5))
    btn_register:setPosition(mainBg:getContentSize().width*0.5, 74)
	menu:addChild(btn_register)
	btn_register:registerScriptTapHandler(gotoRegister)

end

local password = nil
local username = nil


function gotoRegister( ... )
	username 		  = text_username:getText()
	local passwordOld     = text_passwordOld:getText()
	password 		      = text_password:getText()
	local conformPassword = text_confrom_password:getText()

	if(string.len(username) > 20 and string.len(username) < 3) then
		AlertTip.showAlert(GetLocalizeStringBy("key_2929"), nil)
		return
	end
	if(string.len(password) < 6 or string.len(passwordOld) < 6) then
		AlertTip.showAlert(GetLocalizeStringBy("key_3115"))
		return
	end

	if(password ~= conformPassword) then
		AlertTip.showAlert(GetLocalizeStringBy("key_1330"))
		return
	end

	if(string.isBaseChar(username) == false or string.isBaseChar(password) ==false )then
		AlertTip.showAlert(GetLocalizeStringBy("cl_1017"))
		return
	end
	
	-- if(Platform.getPid() == nil)then
	-- 	AlertTip.showAlert(GetLocalizeStringBy("key_3005"))
	-- 	return
	-- end
	username 	= string.replacePlusToSpace(username)
	passwordOld = string.replacePlusToSpace(passwordOld)
	password 	= string.replacePlusToSpace(password)
	
	local url = renewpassUrl ..  "&username=" .. string.urlEncode(username)
	local t_hash_url = renewpassUrl ..  "&username=" .. username

	url 	  	= url .. "&passwordOld=" .. string.urlEncode(passwordOld)
	t_hash_url 	= t_hash_url .. "&passwordOld=" .. passwordOld

	url 	  = url .. "&passwordNew=" .. string.urlEncode(password)
	t_hash_url 	  = t_hash_url .. "&passwordNew=" .. password

	url 	  = url .. "&bind=" .. g_dev_udid
	t_hash_url 	  = t_hash_url .. "&bind=" .. g_dev_udid

	url 	  = url .. "&pid="
	t_hash_url 	  = t_hash_url .. "&pid="
	

	require "script/utils/TimeUtil"
	local timeTemp = TimeUtil.getSvrTimeByOffset()
	url 	  = url .. "&time=" .. timeTemp
	t_hash_url 	  = t_hash_url .. "&time=" .. timeTemp
	
	local hashTemp = string.sortUrlParams(t_hash_url) .. "platform_ZuiGame"
	url       = url .. "&hash=" .. BTUtil:getMd5SumByString( hashTemp )
	
	print("ChangePasswor url", url)
	httpClent = CCHttpRequest:open(url, kHttpGet)
	httpClent:sendWithHandler(registerRequestCallback)
	LoadingUI.addLoadingUI()
end


function registerRequestCallback( res, hnd )
	LoadingUI.reduceLoadingUI()

 	if(res:getResponseCode()~=200)then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_1810"), nil, false, nil)
    end

	print("ChangePasswor date:", res:getResponseData())

	local xml = require "script/utils/LuaXml"
    local xmlTable = LuaXML.eval(res:getResponseData())
    --保存登录数据
    
    if(xmlTable == nil) then
      Platform.loginOut()
      -- AlertTip.showAlert(GetLocalizeStringBy("key_1889"), loginAgain)
      require "script/ui/tip/AlertTip"
      AlertTip.showAlert(GetLocalizeStringBy("key_3224"), nil)
      CCLuaLog("xmlTable == nil")
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
    Platform.setPid(uid)
    if(errornu == "0") then
      --登录逻辑服务器
      require "script/ui/tip/AlertTip"
      AlertTip.showAlert(GetLocalizeStringBy("key_1267"), nil)

	  if (Platform.getConfig().getVisitorLoginUrl ~= nil) then
	    require "script/ui/login/AppLoginLayerVisitor"
		AppLoginLayerVisitor.saveAndLogin( uid, username, password)
	  else
      	require "script/ui/login/AppLoginLayer"
		AppLoginLayer.saveAndLogin( uid, username, password)
	  end

      layerCloseCallback()
      return
    elseif(errornu == "3") then
      require "script/ui/tip/AlertTip"
      AlertTip.showAlert(GetLocalizeStringBy("key_1411"), nil)
      return
      
    else
      -- SDK91Share:shareSDK91():loginOut()
      require "script/ui/tip/AlertTip"
      AlertTip.showAlert(xmlTable:find("errordesc")[1], nil)
      return
    end
end


-- 初始化
function ininlize()

	_tableView = nil
	_tableViewSp = nil
	_cancelBtn = nil
	_mainLayer = nil
	mainBg = nil
end


function layerCloseCallback( ... )
	_mainLayer:removeFromParentAndCleanup(true)
end
