-- Filename: LoginScene.lua
-- Author: fang
-- Date: 2013-05-28
-- Purpose: 该文件用于登录模块

require "script/network/Network"
require "script/utils/BaseUI"
require "script/utils/LuaUtil"
require "script/ui/login/CheckVerionLogic"
require "script/localized/LocalizedUtil"
require "script/utils/SupportUtil"
require "script/ui/login/LoginUtil"
require "db/DB_Heroes"
require "script/GlobalVars"
-- 登录模块
module ("LoginScene", package.seeall)

local _username

local _server_ip = nil
local _server_port = nil

local _bReconnStatus=false

local _tPlatformUserTable

local _tVersionInfo
local _cmiEnterGame
-- 输入框CC控件
local _ccEditBox = nil

-- 进入游戏的index
_nIndexOfEnterGame=10001
-- 重新连接的index
_nIndexOfReconn=10002

local _curLoginStatus = nil

local _tagOfSelectServer=20001

local _NoticeOpenStatus
local _NoticeOpenDesc

local _bLoginStatus
_bLoginInServerStatus = false
-- 记录游戏战斗状态
local _bBattleStatus = false

local _bAccountIsBanned = false


local _observersForNetBroken={}

_isLoginAgain = false

function getFeignRoleId( ... )
	if(_tPlatformUserTable)then
		return _tPlatformUserTable.feignRoleId

	end
	return nil
end

-- 为网络断开时增加观察者接口
function addObserverForNetBroken(pKey, pFn)
	if pKey == nil or _observersForNetBroken[pKey] then
		print("Error. ", pKey, " observer exists for net broken.")
		return
	end

	_observersForNetBroken[pKey] = pFn
end

function removeObserverForNetBroken(pKey)
	_observersForNetBroken[pKey] = nil
end

function notifyNetBrokenObservers( ... )
	for k, fn in pairs(_observersForNetBroken) do
		fn(1)
	end
end

-- 为网络连通时增加观察者回调接口
local _observersForNetConnected={}
-- 
function addObserverForNetConnected(pKey, pFn)
	if pKey == nil or _observersForNetConnected[pKey] then
		print("Error. ", pKey, " observer exists for net broken.")
		return
	end

	_observersForNetConnected[pKey] = pFn
end

function removeObserverForNetConnected(pKey)
	_observersForNetConnected[pKey] = nil
end

function notifyNetConnectedObservers( ... )
	for k, fn in pairs(_observersForNetConnected) do
		fn(1)
	end
end

--重新连接接口回调
local _reconnectObservers = {} --开始重新连接回调
function addObserverForReconnect(pKey, pFn)
	_reconnectObservers[pKey] = pFn
end

function removeObserverForReconnect(pKey)
	_reconnectObservers[pKey] = nil
end


local function getLoginNetworkArgs( ... )
	local args
	if not Platform.isPlatform() then
		args = CCArray:createWithObject(CCInteger:create(tonumber(_username)));
	else
		local userDic = CCDictionary:create()
		for k,v in pairs(_tPlatformUserTable) do
			userDic:setObject(CCString:create(tostring(v)),k)
		end
		args = CCArray:create()
		args:addObject(userDic)
	end
	local sKeyValue = "publish=" .. g_publish_version .. ", script=" .. g_game_version .. ", pl="..Platform.getPlatformFlag() .. ", fixversion=2"
	if(NSBundleInfo)then
		sKeyValue = sKeyValue .. ", sysName=" .. string.urlEncode(NSBundleInfo:getSysName()) .. ", sysVersion=" .. string.urlEncode(NSBundleInfo:getSysVersion()) .. ", deviceModel=" .. string.urlEncode(NSBundleInfo:getDeviceModel())
		if( string.checkScriptVersion(g_publish_version, "3.0.0") >= 0 and Platform.getPlatformFlag() == "appstore" )then
			sKeyValue = sKeyValue .. ", netstatus=" .. NSBundleInfo:getNetworkStatus()
		end
	end
	args:addObject(CCString:create(sKeyValue))

	return args
end

-- 版本号比较方法
function fnVersionCmp(pTv, pSv)
	require "script/utils/LuaUtil"
	local sv = string.splitByChar(pSv, ".")
	local sv1 = tonumber(sv[1])
	local sv2 = tonumber(sv[2])
	local sv3 = tonumber(sv[3])

	local tv = string.splitByChar(pTv, ".")
	local tv1 = tonumber(tv[1])
	local tv2 = tonumber(tv[2])
	local tv3 = tonumber(tv[3])

	local bIsLarger = false
	if tv1 > sv1 then
		bIsLarger = true
	elseif tv2 > sv2 and tv1 >= sv1 then
		bIsLarger = true
	elseif tv3 > sv3 and tv1 >= sv1 and tv2 >= sv2 then
		bIsLarger = true
	end

	return bIsLarger
end

local function gotoDownloadUI( ... )

	require "script/ui/login/UpdateResUI"
	UpdateResUI.showUI(_tVersionInfo.script, _curLoginStatus, _tVersionInfo.static_url)
end

-- 检查版本信息的回调
function checkVersionDelegate( statusCode, versionInfos )

	print_t(versionInfos)
	if(statusCode == CheckVerionLogic.Code_Update_Base)then
		-- 更新底包
		require "script/ui/tip/AlertTip"

		local function tipFunc(isConfirm)
			if(isConfirm == true)then
				local downloadUrl = "https://itunes.apple.com/cn/app/fang-kai-na-san-guo/id680465449?mt=8"
				if(versionInfos.base.package.packageUrl)then
					downloadUrl = versionInfos.base.package.packageUrl
				end
				print("downloadUrl == ",downloadUrl)
				Platform.openUrl(downloadUrl)
				_bLoginStatus = false
			else
				require "script/ui/tip/AnimationTip"
				if(not table.isEmpty(versionInfos.script) )then
					-- 检查脚本更新
					_tVersionInfo = versionInfos
					handleAfterCheckVersion(true)
				else
					handleAfterCheckVersion(false)
				end
			end
		end 
		
		function closeCallbackFunc()
			_bLoginStatus = false
		end
		local tipText = versionInfos.base.package.tip or GetLocalizeStringBy("key_1223")
		if(versionInfos.base.package.isforce and tonumber(versionInfos.base.package.isforce) == 0)then
			-- 非强制底包更新

			AlertTip.showAlert(tipText,tipFunc, true, true, GetLocalizeStringBy("key_1663"), GetLocalizeStringBy("cl_1022"), closeCallbackFunc )
			
		else
			AlertTip.showAlert(tipText,tipFunc, false, nil, GetLocalizeStringBy("key_1663"), nil, closeCallbackFunc)
		end
		
		return
	elseif(statusCode == CheckVerionLogic.Code_Update_Script)then
		-- 更新脚本
		_tVersionInfo = versionInfos
		handleAfterCheckVersion(true)
		
	elseif(statusCode == CheckVerionLogic.Code_Update_None)then
		-- 不更新
		handleAfterCheckVersion(false)
		
	else
		-- 出错脚本
		print("error: 请求出错或者 Web端出错，返回参数格式不对 error_id==", statusCode)
		local function tipFunc()
			fnCheckGameVersion(_curLoginStatus)
		end 
		require "script/ui/tip/AlertTip"
		AlertTip.showAlert(GetLocalizeStringBy("key_1376"),tipFunc, false, nil, GetLocalizeStringBy("key_1465"))
	end
end

-- https://itunes.apple.com/cn/app/fang-kai-na-san-guo/id680465449?mt=8
function fnCheckGameVersion( login_status)
	_curLoginStatus = login_status
	if(g_debug_mode == true)then
		if(NSBundleInfo:getAppVersion() == "4.3.0" or NSBundleInfo:getAppVersion() == "5.0.4")then
			-- 检查版本信息  改为策划服实时刷服用
			CheckVerionLogic.startCheckVersion(checkVersionDelegate)
		else
			-- 不更新
			handleAfterCheckVersion(false)
		end
	else
		-- 检查版本信息
		CheckVerionLogic.startCheckVersion(checkVersionDelegate)
		--handleAfterCheckVersion(false)
	end

end

local function handlerOfEnterGame( ... )
	-- if _bLoginStatus then
	-- 	return
	-- end
	-- selectServerInfo.status = -1
	print("handlerOfEnterGame begin:",_bLoginStatus)
	if _bLoginStatus==true then
		return
	end
	_bAccountIsBanned = false
	_bLoginStatus = true

	if _ccEditBox then
		_username = _ccEditBox:getText()
		Platform.setPid(tonumber(_username))
	end
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")


	fnCheckGameVersion(_nIndexOfEnterGame)

end

function handleAfterCheckVersion(pStatus)
	Network.re_rpc(netWorkFailed, "failed")	
	if pStatus then
		if _bReconnStatus then
			local curScene = CCDirector:sharedDirector():getRunningScene()
	    	curScene:removeAllChildrenWithCleanup(true) -- 删除当前场景的所有子节点
	    	CCTextureCache:sharedTextureCache():removeUnusedTextures() -- 清除所有不用的纹理资源
		end
		_bReconnStatus = false
		gotoDownloadUI()
	else
		if _bReconnStatus then
			if(Platform.getOS() ~= "wp")then
				BTEventDispatcher:getInstance():removeAll() -- 重置事件派发队列
				PackageHandler:setToken("0") -- 重置网络连接的 token
			end

			if g_debug_mode then
				if(Network.connectMainSocket == nil)then
					-- 兼容处理
					Network.connectMainSocket = Network.connect
				end
				if Network.connectMainSocket(_server_ip, _server_port) then
			       require "script/network/user/UserHandler"
			       local args = getLoginNetworkArgs()
			       Network.rpc (UserHandler.login, "user.login", "user.login", args, true)
				else
			    	local tArgs = {}
					tArgs.text = GetLocalizeStringBy("key_1359")
					tArgs.callback = loginAgain
					AlertTip.showNoticeDialog(tArgs)    
				end
			else
				loginLogicServer()
			end
		else
			loginGame()
		end
	end
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local tmpNode = CCNode:create()
	tmpNode:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(function ( ... )
		--设置登录状态
	_bLoginStatus = false
	end)))
	runningScene:addChild(tmpNode)
end

function loginAgain(pIndex)
	_G["g_network_status"] = g_network_connecting
	_bReconnStatus = false
	if pIndex == 1 then
	    require "script/ui/main/BulletinLayer"
	    BulletinLayer.release()
	    require "script/ui/main/MenuLayer"
	    MenuLayer.release()
	    require "script/ui/main/MainScene"
	    MainScene.release()
	    require "script/ui/main/MainBaseLayer"
	    MainBaseLayer.exit()
	    --（先）注销账号，pid置空
	    Platform.loginOut()
	    Platform.setPid(nil)

	    _bLoginInServerStatus = false
	    enter() --（后）创建新登录页面，拉取服务器列表
	elseif pIndex == 2 then
		--回调处理
		for k,v in pairs(_reconnectObservers) do
			if type(v) == "function" then
				v()
			end
		end

		_bReconnStatus = true
		_isLoginAgain = true
		require "script/audio/AudioUtil"
		AudioUtil.initAudioInfo()
		fnCheckGameVersion(_nIndexOfReconn)
	end
    
    SimpleAudioEngine:sharedEngine():pauseAllEffects()
    SimpleAudioEngine:sharedEngine():resumeAllEffects()
end

-- 显示重新连接对话框
local function showReconnectDialog( message )
	if g_network_status ~= g_network_disconnected then
		return
	end

	require "script/ui/network/LoadingUI"
    LoadingUI.stopLoadingUI()
	--清理聊天特效
    require "script/ui/main/MainBaseLayer"
    MainBaseLayer.showChatAnimation(false)  
    local tArgs = {}
    tArgs.text = GetLocalizeStringBy("key_1359")
    if message ~= nil then
        tArgs.title = message
    end
    tArgs.callback = loginAgain
    require "script/ui/tip/AlertTip"
    AlertTip.showNoticeDialog(tArgs)
    
    SimpleAudioEngine:sharedEngine():pauseAllEffects()
    SimpleAudioEngine:sharedEngine():resumeAllEffects()
end

-- local _count = 0

function netWorkFailed(cbName, dictData, bRet)
	_G["g_network_status"] = g_network_disconnected
	if(table.isEmpty(dictData)==false and dictData.socketKey~=Network.getMainSocketKey() and Network.getMainSocketKey()~=true )then
		-- 如果不是main socket
		print("Warning: soket is closed!!! socketKey is:" , dictData.socketKey , "!!! Colsed info:",dictData.NetWork )
		
		-- 如果不是main socket
		if(dictData.socketKey == Network.getCountrySocketKey())then
			-- 将国战socket置成nil 目前除了 主业务mainSocket 就是 国战的countrySocket
			Network.setCountrySocketKey(nil)
			Network.contryDisconnected()
		end
		return
	end
	if _bAccountIsBanned then
		-- BTEventDispatcher:getInstance():removeAll() -- 重置事件派发队列
		-- PackageHandler:setToken("0") -- 重置网络连接的 token
	else
		notifyNetBrokenObservers()
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		local tmpNode = CCNode:create()

		tmpNode:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.03), CCCallFunc:create(function ( ... )
			if(Platform.getOS() ~= "wp")then
				BTEventDispatcher:getInstance():removeAll() -- 重置事件派发队列
				PackageHandler:setToken("0") -- 重置网络连接的 token
			end
		end)))
		runningScene:addChild(tmpNode)
		
	    if _bBattleStatus == false then
	    	showReconnectDialog(message)
	   	end
	end
end

local function createBgLayer( ... )
	local bg_layer = CCLayer:create()
	-- if(g_winSize.height == 2048 )then
	-- 	local bg = CCSprite:create("images/login/retina_bg.jpg")
	-- 	bg:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	-- 	bg:setAnchorPoint(ccp(0.5, 0.5))
	-- 	bg_layer:addChild(bg)
		-- setAllScreenNode(bg)

		local bg2 = CCSprite:create("images/login/deslogin.png")
		bg2:setPosition(ccps(0.5, 0.5))
		bg2:setAnchorPoint(ccp(0.5, 0.5))
		bg_layer:addChild(bg2,1)
		bg2:setScale(g_fScaleY)
	-- else
		local bg = CCSprite:create("images/login/bg.jpg")
		bg:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
		bg:setAnchorPoint(ccp(0.5, 0.5))
		bg_layer:addChild(bg)
		bg:setScale(g_fBgScaleRatio)

		local logoSprite = CCSprite:create("images/login/logo.png")
		logoSprite:setAnchorPoint(ccp(0.5, 0.5))
		logoSprite:setPosition(ccp(bg_layer:getContentSize().width/2, bg_layer:getContentSize().height*0.8))
		logoSprite:setScale(g_fElementScaleRatio)
		bg_layer:addChild(logoSprite,6)

		local effectSprite = XMLSprite:create("images/login/denglujiemian_zhulin_luoye/denglujiemian_zhulin_luoye")
		effectSprite:setScale(g_fElementScaleRatio)
    	effectSprite:setPosition(ccp(bg_layer:getContentSize().width*0.5,bg_layer:getContentSize().height*0.5))
    	effectSprite:setAnchorPoint(ccp(0.5,0.5))
    	bg_layer:addChild(effectSprite,5)

    	local effectSprite2 = XMLSprite:create("images/login/denglujiemian_zhulin/denglujiemian_zhulin")
		-- effectSprite2:setScale(g_fElementScaleRatio)
    	effectSprite2:setPosition(ccp(bg:getContentSize().width*0.5,bg:getContentSize().height*0.5))
    	effectSprite2:setAnchorPoint(ccp(0.5,0.5))
    	bg:addChild(effectSprite2,5)

    	local effectSprite3 = XMLSprite:create("images/login/denglujiemian_3nian_tubiao/denglujiemian_3nian_tubiao")
		effectSprite3:setScale(g_fElementScaleRatio)
    	effectSprite3:setPosition(ccp(bg_layer:getContentSize().width*0.5,bg_layer:getContentSize().height*0.8))
    	effectSprite3:setAnchorPoint(ccp(0.5,0.5))
    	bg_layer:addChild(effectSprite3,7)

		-- local bg2 = CCSprite:create("images/login/bg2.png")
		-- bg2:setPosition(ccps(0.5, 0.5))
		-- bg2:setAnchorPoint(ccp(0.5, 0.5))
		-- bg_layer:addChild(bg2)
		-- setAdaptNode(bg2)
	-- end

	return bg_layer
end

local function init( ... )
	_bLoginStatus = false
	_bReconnStatus = false
	_G.g_network_status = g_network_disconnected
	_bAccountIsBanned = false
end


-- 进入模块
function enter( ... )
	init()

	require "script/ui/main/GameNotice02"
	GameNotice02.deleteWebView()
	local scene = CCDirector:sharedDirector():getRunningScene()
    if scene then
    	scene:removeAllChildrenWithCleanup(true)	-- 删除当前场景的所有子节点
    	CCTextureCache:sharedTextureCache():removeUnusedTextures()	-- 清除所有不用的纹理资源
    else
    	scene = CCScene:create()
    	CCDirector:sharedDirector():runWithScene(scene)
    end
	require "script/ui/login/UpdateResUI"
	UpdateResUI.fnReleaseLogicMods()
	if(Platform.getOS() ~= "wp")then
		BTEventDispatcher:getInstance():removeAll() -- 重置事件派发队列
		PackageHandler:setToken("0") -- 重置网络连接的 token
	end
	BTUtil:setGuideState(false)
	require "script/guide/NewGuide"
	NewGuide.guideClass = ksGuideClose

    local login_layer = CCLayer:create()
    if not Platform.isPlatform() then
    	_ccEditBox = CCEditBox:create (CCSizeMake(400*g_fElementScaleRatio,60*g_fElementScaleRatio), CCScale9Sprite:create("images/test/green_edit.png"))
		_ccEditBox:setPosition(ccp(g_winSize.width/2, 370*g_fScaleY))
		_ccEditBox:setAnchorPoint(ccp(0.5, 0.5))
		_ccEditBox:setPlaceHolder(GetLocalizeStringBy("key_2621"))
		_ccEditBox:setPlaceholderFontColor(ccc3(0xdd, 0xdd, 0xdd))
		_ccEditBox:setMaxLength(13)
		_ccEditBox:setReturnType(kKeyboardReturnTypeDone)
		_ccEditBox:setInputFlag (kEditBoxInputFlagInitialCapsWord)
		_ccEditBox:setText(CCUserDefault:sharedUserDefault():getStringForKey("uid"))
		login_layer:addChild(_ccEditBox)
	else
		require "script/ui/login/ServerList"
	end

    local menu = CCMenu:create()
    menu:setPosition(0,0)
    login_layer:addChild(menu)

    -- 进入游戏按钮
    _cmiEnterGame=CCMenuItemImage:create("images/login/enter_n.png", "images/login/enter_h.png")
    _cmiEnterGame:setScale(g_fElementScaleRatio)
    _cmiEnterGame:setPosition(ccps(0.5, 0.1))
    _cmiEnterGame:setAnchorPoint(ccp(0.5, 0.5))
    _cmiEnterGame:registerScriptTapHandler(handlerOfEnterGame)
    menu:addChild(_cmiEnterGame)
    local bg = createBgLayer()

    scene:addChild(bg)
    scene:addChild(login_layer)

    --增加返回键监听
    local backClickLayer = CCLayer:create()
	scene:addChild(backClickLayer)
    local function KeypadHandler(strEvent)
        if "backClicked" == strEvent then
            Platform.exitSDK()
           	--CCDirector:sharedDirector():endToLua()
        elseif "menuClicked" == strEvent then
--            Platform.exit()
--            CCDirector:sharedDirector():endToLua()
        end
    end
    backClickLayer:setKeypadEnabled(true)
    backClickLayer:registerScriptKeypadHandler(KeypadHandler)
    
    --增加背景音乐
    require "script/audio/AudioUtil"
 	AudioUtil.playBgm("audio/main.mp3")

    bg:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.03), CCCallFunc:create(Platform.getServerList)))

    if(true or Platform.isAppStore() == true or Platform.isZYXSdk() == true)then
    	-- if not g_debug_mode then
    	-- 	_G.g_dev_udid = UDID:getUDID()
    	-- end
    	createAppLoginButton(scene)
    end
    -- if(Platform.isZuiyouxi() == true)then
    -- 	createAppLoginButton(scene)
    -- 	print("最游戏平台-----创建注册按钮")
    -- end
    --拉去服务器列表
end

function loginGame( ... )
	--记忆上次登录的服务器
	CCUserDefault:sharedUserDefault():setStringForKey("lastLoginGroup",selectServerInfo.group)
	CCUserDefault:sharedUserDefault():flush()
	-- print(GetLocalizeStringBy("key_2496"),selectServerInfo.group)\
	print_t(selectServerInfo)
	ServerList.addRecentServerGroup(selectServerInfo.group)

	require "script/ui/main/GameNotice02"
	GameNotice02.setServerKey(selectServerInfo.group)
	if( ZYWebView == nil )then
		-- 如果不支持 ZYWebView， 就用旧的通知
		GameNotice02.fetchNotice02FromServer(selectServerInfo.group)
	end

	require "script/GlobalVars"
	_G["g_network_status"] = g_network_connecting
	--设置为最近登录的服务器
	if not Platform.isPlatform() then
		if (#_username == 0) then
			return
		end
		CCUserDefault:sharedUserDefault():setStringForKey("uid", tostring(_username))
		CCUserDefault:sharedUserDefault():flush()

		_server_ip 	= selectServerInfo["host"]
		_server_port = selectServerInfo["port"]

		local server_id = selectServerInfo.group
		require "script/network/Network"
		print("_server_ip: ", _server_ip, ", _server_port: ", _server_port)
		if(Network.connectMainSocket == nil)then
			-- 兼容处理
			Network.connectMainSocket = Network.connect
		end
		if Network.connectMainSocket(_server_ip, _server_port) then
	    	require "script/network/user/UserHandler"

 	    	
 	    	local dict = CCDictionary:create()
 	    	dict:setObject(CCString:create(tostring(_username)),"pid")
 	    	dict:setObject(CCString:create(server_id),"serverID")
 	    	local args = CCArray:createWithObject(dict);
 	    	
 	    	local sKeyValue = "publish=" .. g_publish_version .. ", script=" .. g_game_version .. ", pl="..Platform.getPlatformFlag() .. ", fixversion=2"
 	    	sKeyValue = sKeyValue .. ", sysName=" .. string.urlEncode(NSBundleInfo:getSysName()) .. ", sysVersion=" .. string.urlEncode(NSBundleInfo:getSysVersion()) .. ", deviceModel=" .. string.urlEncode(NSBundleInfo:getDeviceModel())
			sKeyValue = sKeyValue .. ", netstatus=" .. NSBundleInfo:getNetworkStatus()
			
			args:addObject(CCString:create(sKeyValue))

	    	Network.rpc (UserHandler.login, "user.login", "user.login", args, true)
	    else
	    	require "script/ui/tip/AlertTip"
	    	AlertTip.showAlert(GetLocalizeStringBy("key_2847"), function ( ... )
	   			Platform.quit()
			end)
	    end
	else			
		local pid = Platform.getPid()
		print("pid=",pid)
		if(pid == nil)then
			Platform.login(loginGame)
			return
		end

		if not g_debug_mode then
	        LoginScene.loginLogicServer(pid)
	    else
			-- local serverInfo = ServerList.getSelectServerInfo()
			-- serverInfo.pid=pid
			LoginScene.loginLogicServer(pid)
			-- LoginScene.loginInServer(serverInfo)
		end
	end
end

function setReconnStatus(pStatus)
	_bReconnStatus = pStatus
end

function createUser()
	-- 1/2, man/female
	local args = CCArray:createWithObject(CCString:create("2"))
	args:addObject (CCString:create(tostring(_username)))
	print(_username)
	require "script/network/user/UserHandler"
	-- 调用“创建英雄”接口
	Network.rpc(UserHandler.createUser,"user.createUser", "user.createUser", args, true)
end

function setUserInfo(userInfo)

    -- 在取得功能节点之后获得武将战斗力信息
    local function fnAfterGetSwitchInfo( ... )
        require "script/network/RequestCenter"
        RequestCenter.hero_getAllHeroes(function ( cbFlag, dictData, bRet )
        	-- 处理获取所有英雄回调
		    if (bRet == true and cbFlag == "hero.getAllHeroes") then
		        require "script/model/hero/HeroModel"
		        HeroModel.setAllHeroes(dictData.ret)
			    enterGame()
		    end
        end)
    end
    ---------- 开始拉数据 -------
    require "script/network/PreRequest"
    PreRequest.startPreRequest(fnAfterGetSwitchInfo)

end

local _bNotOvertureStatus = false
function enterGame( ... )
	_G["g_network_status"] = g_network_connected
	notifyNetConnectedObservers()
	-- added by zhz
    require "script/model/user/UserModel"
    require "script/ui/upgrade_tip/UpgradeLayer"
    UserModel.addObserverForLevelUp("UpgradeLayer", UpgradeLayer.createLayer)

	local runningScene = CCDirector:sharedDirector():getRunningScene()

	require "script/model/user/UserModel"
    if(UserHandler.isNewUser == true and not _bNotOvertureStatus) then
    	
--	if UserHandler.isNewUser then
    	function enterBattle( ... )
    		--通知Platfrorm层用户 跳过剧情,进入首个副本
    		Platform.sendInformationToPlatform(Platform.kOutOfStoryLine)

    		runningScene:removeAllChildrenWithCleanup(true)
	    	local battleCallback = function ( ... )
	    		
	    		require "script/ui/main/MainScene"
	    		print(GetLocalizeStringBy("key_2747"))

				MainScene.enter()
	   	 	end
	   	 	require "script/battle/BattleLayer"
	    	BattleLayer.enterBattle(1, 1001, 0, battleCallback ,1)
    	end
    	runningScene:removeAllChildrenWithCleanup(true)

    	require "script/ui/create_user/SelectUserLayer"
    	local sexNumber = SelectUserLayer.getUserSex()
    	local sexBool   = true
    	if(tonumber(sexNumber) == 1) then
    		sexBool = false
    	elseif(sexNumber == 2) then
    		sexBool = true
    	end
    	print("enter overture layer")
    	require "script/guide/overture/BattleLayerLee"
    	BattleLayerLee.enterBattle(nil,1,0,function ( ... )
    		enterBattle()
    	end,1)
    	_bNotOvertureStatus = true
    else
    	if _bReconnStatus == false then
    		-- add by licong 2013.10.23
    		-- 判断是否通关第一个据点
    		require "script/guide/NewGuide"
    		NewGuide.getOneCopyStatus()
		else
			require "script/network/RequestCenter"
			RequestCenter.ncopy_getAtkInfoOnEnterGame(function ( ... )
				-- body
			end, nil)
		end
    end
end

function setNotice(pOpen, pDesc)
	_NoticeOpenStatus = pOpen
	_NoticeOpenDesc = pDesc
end

local function showNotice( ... )
	if _NoticeOpenDesc and _NoticeOpenStatus and tonumber(_NoticeOpenStatus) > 0 then
		require "script/ui/tip/AlertTip"
		AlertTip.showAlert(_NoticeOpenDesc, function ()
		            
	    end)
	end
end

local serverListPanel = nil
function createSelectServer( ... )

	require "script/ui/rewardCenter/AdaptTool"
	if(serverListPanel == nil) then
		-- 显示运营公告
		showNotice()
		local serverBg = CCScale9Sprite:create("images/login/ng_button_n.png")
		serverBg:setContentSize(CCSizeMake(368,50))
		serverBg:setAnchorPoint(ccp(0.5, 0.5))
		serverBg:setPosition(g_winSize.width/2, g_winSize.height * 0.2)
		AdaptTool.setAdaptNode(serverBg)

		serverBg:registerScriptHandler(function ( eventType )
			if(eventType == "exit") then
				serverListPanel = nil
			end
		end)

		serverListPanel = CCNode:create()
		serverListPanel:setContentSize(CCSizeMake(serverBg:getContentSize().width, serverBg:getContentSize().height))
		serverListPanel:setPosition(serverBg:getContentSize().width/2, serverBg:getContentSize().height/2)
		serverListPanel:setAnchorPoint(ccp(0.5, 0.5))
		serverBg:addChild(serverListPanel)

		local curScene = CCDirector:sharedDirector():getRunningScene()
		curScene:addChild(serverBg, 0, _tagOfSelectServer)
	end
	serverListPanel:removeAllChildrenWithCleanup(true)
	if(selectServerInfo == nil) then
		selectServerInfo = ServerList.getSelectServerInfo()
	end

	local serverNameLabel = CCLabelTTF:create(selectServerInfo.name, g_sFontName, 24)
	serverNameLabel:setAnchorPoint(ccp(0, 0.5))
	serverNameLabel:setPosition(10, serverListPanel:getContentSize().height * 0.5)
	serverListPanel:addChild(serverNameLabel)

	if(tonumber(selectServerInfo.hot) == 1) then
		local hotSprite = CCSprite:create("images/login/hot.png")
		hotSprite:setAnchorPoint(ccp(0, 1))
		hotSprite:setPosition(18 + serverNameLabel:getContentSize().width, serverListPanel:getContentSize().height )
		serverListPanel:addChild(hotSprite)	
	end

	if(tonumber(selectServerInfo.new) == 1) then
		local newSprite = CCSprite:create("images/login/new.png")
		newSprite:setAnchorPoint(ccp(0, 1))
		newSprite:setPosition(18+ serverNameLabel:getContentSize().width, serverListPanel:getContentSize().height )
		serverListPanel:addChild(newSprite)
	end
	if(tonumber(selectServerInfo.status) ~= 1) then
		local newSprite = CCSprite:create("images/login/stop.png")
		newSprite:setAnchorPoint(ccp(0, 1))
		newSprite:setPosition(18+ serverNameLabel:getContentSize().width, serverListPanel:getContentSize().height )
		serverListPanel:addChild(newSprite)
	end	

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	serverListPanel:addChild(menu)

	local buttonLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1320"), g_sFontName, 24)
	buttonLabel:setColor(ccc3(0xff, 0x95, 0x23))
	local selectServerButton = CCMenuItemLabel:create(buttonLabel)
	selectServerButton:setPosition(ccp(serverListPanel:getContentSize().width * 0.95, serverListPanel:getContentSize().height * 0.5))
	selectServerButton:setAnchorPoint(ccp(1,0.5))
	menu:addChild(selectServerButton)
	selectServerButton:registerScriptTapHandler(selectServerButtonCallback)

end

function setSelectInfo(server_info)
	selectServerInfo = server_info
	-- serverNameLabel:setString(selectServerInfo.name) 
	createSelectServer()

end

function selectServerButtonCallback( tag,sender )
	local curScene = CCDirector:sharedDirector():getRunningScene()
	local serverLayer = ServerList.create()
	curScene:addChild(serverLayer, 500)
end


-- 网络参数 CCArray类型
function loginInServer( user_table )
	--记忆上次登录的服务器
	CCUserDefault:sharedUserDefault():setStringForKey("lastLoginGroup",selectServerInfo.group)
	CCUserDefault:sharedUserDefault():flush()
	print("设置为最近登录的服务器:",selectServerInfo.group)
	ServerList.addRecentServerGroup(selectServerInfo.group)
		
	_tPlatformUserTable = user_table

	print("user_table.host:", user_table.host)
	print("user_table.port:", user_table.port)
	_server_ip = user_table.host
	_server_port = user_table.port
	require "script/network/Network"
	if(Network.connectMainSocket == nil)then
		-- 兼容处理
		Network.connectMainSocket = Network.connect
	end
	if Network.connectMainSocket(_server_ip, _server_port) then
		_bLoginInServerStatus = true
		local args = getLoginNetworkArgs()
		require "script/network/user/UserHandler"
		Network.rpc (UserHandler.login, "user.login", "user.login", args, true)
	else
		require "script/ui/tip/AlertTip"
		AlertTip.showAlert(GetLocalizeStringBy("key_1047"))
	end
	Platform.sendInformationToPlatform(Platform.kEnterGameServer)
    Platform.initPlGroup()
    -- 记录当前登录的Pid
    CCUserDefault:sharedUserDefault():setStringForKey("user_pid", Platform.getPid())
    CCUserDefault:sharedUserDefault():flush()
end


function getHashURL(pid, checkCode)
	print("getHashURL")
	-- 从服务器拉去登录数据
	pid = pid or Platform.getPid()
	local url = ""
	if Platform.getHashUrl ~= nil then
		url = Platform.getHashUrl() .. "?group_id=" .. selectServerInfo["group"] .. "&pid=" .. pid
	else
		url = "http://mapifknsg.zuiyouxi.com/phone/getHash/?&group_id=" .. selectServerInfo["group"] .. "&pid=" .. pid
		if SupportUtil.isSupportHttps() then
			url = "https://mapifknsg.zuiyouxi.com/phone/getHash/?&group_id=" .. selectServerInfo["group"] .. "&pid=" .. pid
		end
	end

	-- 如果是Debug模式
	if(g_debug_mode == true)then
		url = "http://124.205.151.82/phone/getHash?&group_id=" .. selectServerInfo["group"] .. "&pid=" .. pid
	end
	if(checkCode)then
		url = url .. "&checkcode=" .. checkCode
	end
	if(Platform.getPlatformUrlName() == "Android_zyx")then	
		local uuid = Platform.getSdk():callStringFuncWithParam("getUuid",nil)
	 	if(uuid ~= nil)then
	 	   url = url  .. "&uuid=" .. uuid
	    end
	end
	if(Platform.isAppStore() == true)then
		url = url .. "&bind=" .. LoginUtil.getDeviceBindId() --string.format()
	end
	require "script/utils/TimeUtil"
	local timeTemp = TimeUtil.getSvrTimeByOffset()
	url = url .. "&time=" .. timeTemp
	url = url .. Platform.getUrlParam()

	local temp_hash = string.sortUrlParams(url) .. "sgGetHasH@"
	print("temp_hash:", temp_hash)

	url = url .. "&hash=" .. BTUtil:getMd5SumByString(temp_hash)
	print("getHash request url:" .. url)

	return url
end

local temp_index = 0
--登录逻辑服务器
function loginLogicServer( pid, checkCode )
	print("loginLogicServer")
	local serverInfo = ServerList.getSelectServerInfo()
	serverInfo.pid=pid
	loginInServer(serverInfo)
	
	--[[ 注释掉 GetHash 功能
	local url = getHashURL(pid, checkCode)
	LoadingUI.addLoadingUI()
	local httpClent = CCHttpRequest:open(url, kHttpGet)
	httpClent:sendWithHandler(function(res, hnd)
		require "script/ui/network/LoadingUI"
		require "script/ui/tip/AlertTip"
		LoadingUI.reduceLoadingUI()
		if(res:getResponseCode()~=200)then
        	AlertTip.showAlert( GetLocalizeStringBy("key_1810"), nil, false, nil)
        	return
    	end

		local loginJsonString = res:getResponseData()
		
		print("loginJsonString:" .. loginJsonString)
		local cjson = require "cjson"
        local loginInfo = cjson.decode(loginJsonString)
        if( loginInfo == nil or table.isEmpty( loginInfo ) == true )then
	    	AlertTip.showAlert(GetLocalizeStringBy("cl_1001"), nil)
			return
		end

		-- 正常状态是errnu=1
		if(loginInfo.errnu == 1)then
			if(Platform.isAppStore() == true)then
				LoginUtil.saveDeviceBindId(loginInfo.bind)
			end
			--检查是否可以创建角色
			if tonumber(loginInfo.canCreateUser) == 0 then
				_G["g_createuser_enabled"] = false
			end
			--检查是否可以充值
			if tonumber(loginInfo.canPay) == 0 then
				 _G["g_recharge_enabled"] = false
			end
	        print_t(loginInfo)
			loginInServer( loginInfo )
		else
			if( loginInfo.errnu ~= 1)then
				if(loginInfo.errnu == 10 or loginInfo.errnu == 11)then
					-- 输入验证码
					if(loginInfo.errnu == 11)then
			            --验证码不正确
					end
					local confirStr = loginInfo.checkcode
			    	print("confirStr:", confirStr)
			    	local tempPath = CCFileUtils:sharedFileUtils():getWritablePath() .. "hash_check_" .. temp_index .. ".xml"
			    	if g_system_type == kBT_PLATFORM_IOS or g_system_type == kBT_PLATFORM_ANDROID then
						confirStr = Base64.decode(confirStr)
					else
						confirStr = CCCrypto:decodeBase64(confirStr)
					end
			    	temp_index = temp_index + 1
			    	
					print(tempPath)
					local fileImg = io.open(tempPath, "wb")
					if(fileImg)then
						fileImg:write(confirStr)
						fileImg:close()
						require "script/ui/login/CheckCodeTip"
						CheckCodeTip.showTip(pid, tempPath)
					end
					
				elseif(loginInfo.errnu == 12)then
					-- 系统维护中
					AlertTip.showAlert(GetLocalizeStringBy("cl_1001"), nil)
				else
					-- 10  输入验证码 11 验证码不正确 12 系统维护中 13 请求超时 14  md5校验码错误
					AlertTip.showAlert(loginInfo.errmsg, nil)
				end
			end
		end
	end)
	--]]
end

-- 设置游戏战斗状态
function setBattleStatus(pStatus)
	_bBattleStatus = pStatus
	if _bBattleStatus == false then
		showReconnectDialog()
	end
end

local function fnHanlderOfServer( ... )
	enter()
end

-- 服务器与平台链接无效了
function fnServerIsTimeout( ... )
	require "script/ui/tip/AlertTip"
	AlertTip.showAlert(GetLocalizeStringBy("key_3137"), fnHanlderOfServer, false)
end
-- 服务器已满
function fnServerIsFull( ... )
	require "script/ui/tip/AlertTip"
	AlertTip.showAlert(GetLocalizeStringBy("key_2944"), fnHanlderOfServer, false)
end

--appstore 登录注册按钮
function createAppLoginButton( curScene )

	local menu =CCMenu:create()
	menu:setPosition(ccp(0,0))
	-- menu:setTouchPriority(-551)
	curScene:addChild(menu)

	local text = ""
	-- config = require "script/config/config_apple"
	print ("Platform.getConfig().getLoginState() ",Platform.getConfig().getLoginState() )
	if(Platform.getConfig().getLoginState() == Platform.getConfig().kLoginsStateNotLogin)then
		text = GetLocalizeStringBy("bx_1039")
	elseif(Platform.getConfig().getLoginState() == Platform.getConfig().kLoginsStateUDIDLogin)then
		text = GetLocalizeStringBy("key_2439")
	elseif(Platform.getConfig().getLoginState() == Platform.getConfig().kLoginsStateZYXLogin)then
		-- require "script/ui/login/AppLoginLayer"
  --       local username = CCUserDefault:sharedUserDefault():getStringForKey("username")
  --       local password = CCUserDefault:sharedUserDefault():getStringForKey("password")
  --       AppLoginLayer.loginWithUserNameInfo(username, password, false);

		text = CCUserDefault:sharedUserDefault():getStringForKey("username")

	end

	local norSprite = CCScale9Sprite:create("images/login/ng_button_n.png")
	norSprite:setContentSize(CCSizeMake(368,50))
	local higSprite = CCScale9Sprite:create("images/login/ng_button_h.png")
	higSprite:setContentSize(CCSizeMake(368,50))

	loginCenterItem = CCMenuItemSprite:create(norSprite,higSprite)
	loginCenterItem:setEnabled(false)
    loginCenterItem:setAnchorPoint(ccp(0.5, 0.5))
    loginCenterItem:setPosition(g_winSize.width*0.5, 76*2)
	menu:addChild(loginCenterItem)
	loginCenterItem:registerScriptTapHandler(gotoUserCenter)
	loginCenterItem:setPosition(g_winSize.width/2, g_winSize.height * 0.3)

	userNameLabel = CCLabelTTF:create(text, g_sFontName, 24)
	userNameLabel:setAnchorPoint(ccp(0, 0.5))
	userNameLabel:setPosition(norSprite:getContentSize().width*0.05, norSprite:getContentSize().height * 0.5)
	loginCenterItem:addChild(userNameLabel)
	loginCenterItem:setScale(g_fElementScaleRatio)

	local buttonLabelText = GetLocalizeStringBy("key_2204")
	if(Platform.getConfig().getLoginState() == Platform.getConfig().kLoginsStateNotLogin)then
		buttonLabelText = GetLocalizeStringBy("bx_1040")
	end
	buttonLabel = CCLabelTTF:create(buttonLabelText, g_sFontName, 24)
	buttonLabel:setColor(ccc3(0xff, 0x95, 0x23))
	local loginButton = CCMenuItemLabel:create(buttonLabel)
	local btn_width = loginCenterItem:getContentSize().width*g_fElementScaleRatio
	loginButton:setAnchorPoint(ccp(1,0.5))
	loginButton:setPosition(ccp((g_winSize.width-btn_width)/2+btn_width*0.95, g_winSize.height * 0.3))
	menu:addChild(loginButton)
	loginButton:setScale(g_fElementScaleRatio)
	loginButton:registerScriptTapHandler(gotoUserCenter)
end

function changeUserName( text )
	userNameLabel:setString(text)
	local buttonLabelText = GetLocalizeStringBy("key_2204")
	if(Platform.getConfig().getLoginState() == Platform.getConfig().kLoginsStateNotLogin)then
		buttonLabelText = GetLocalizeStringBy("bx_1040")
	end
	buttonLabel:setString(buttonLabelText)
end

function gotoUserCenter( )
	if (Platform.getConfig().getVisitorLoginUrl ~= nil) then
	    require "script/ui/login/AppLoginLayerVisitor"
	    AppLoginLayerVisitor.createLoginLayer(Platform.getConfig().getLoginState())
	else
		require "script/ui/login/AppLoginLayer"
	    AppLoginLayer.createLoginLayer(Platform.getConfig().getLoginState())
	end

	-- if(Platform.getConfig().getLoginState() == Platform.getConfig().kLoginsStateNotLogin)then
	-- 	-- local udid = UDID:getUDID()
	-- 	require "script/ui/login/AppLoginLayer"
 --    	AppLoginLayer.createLoginLayer();
	-- elseif(Platform.getConfig().getLoginState() == Platform.getConfig().kLoginsStateUDIDLogin)then
	-- 	require "script/ui/login/AppLoginLayer"
 --    	AppLoginLayer.createLoginLayer();
	-- elseif(Platform.getConfig().getLoginState() == Platform.getConfig().kLoginsStateZYXLogin)then
	-- 	require "script/ui/login/AppLoginLayer"
 --    	AppLoginLayer.createLoginLayer();
	-- end
end

function fnIsBanned(pBanInfo)
	print("fnIsBannedfnIsBannedfnIsBanned")
	_bAccountIsBanned = true
	if pBanInfo and pBanInfo.msg then
		require "script/ui/network/LoadingUI"
		require "script/utils/TimeUtil"
		LoadingUI.stopLoadingUI()
		local time_tip =  GetLocalizeStringBy("cl_1000", TimeUtil.getTimeFormatChnYMDHM(pBanInfo.time))
		print("time_tip==", time_tip)
		require "script/ui/tip/AlertTip"
		AlertTip.showAlert(pBanInfo.msg .. "\n" .. time_tip, fnHanlderOfServer, false)
	end
end
