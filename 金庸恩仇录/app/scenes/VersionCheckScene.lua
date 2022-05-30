--require("utility.CCBReaderLoad")
require("network.NetworkHelper")
require("utility.Func")
require("data.data_url")
require("constant.ZipLoader")
require("data.data_channelid")
require("utility.richtext.richText")
require("game.GameConst")

local VersionCheckScene = class("VersionCheckScene", function()
	return display.newScene("VersionCheckScene")
end)

local initVersion = false

function VersionCheckScene:ctor()
	self:showUI()
	initVersion = false
end

function VersionCheckScene:gotoLoginScene()
	dump("gotoLoginScene")
	local layer = require("game.login.LoginScene").new({
	chn_flag = self._chn_flag,
	versionInfo = self._versionInfo
	})
	display.replaceScene(layer)
end


function VersionCheckScene:request()
	local versionUrl = NewServerInfo.VERSION_URL
	if VERSION_CHECK_DEBUG == true then
		versionUrl = NewServerInfo.DEV_VERSION_URL
	end
	local function request()
		NetworkHelper.request(		
		versionUrl,		
		{
		ac = "dwurl",
		channel = "",
		package = CSDKShell.GetBoundleID(),
		version = getlocalversion(),
		buildFlag = 100,
		packType = PackType,
		packetTag = PacketTag,
		os = device.platform,		
		bit64 = BIT_64 or 0
		},
		--{ac = "dwurl", channel = "", package = "com.fy.jh.gysy", version = VERSION, buildFlag = 100, packType = PackType, packetTag = PacketTag, os = "andriod"},
		function(data)
			self._versionInfo = data
			self:checkforupdate(data)
		end,
		"GET")
	end
	request()
end

function VersionCheckScene:checkforupdate(data)
	dump("checkforupdate")
	dump(data)
	if data and data.verify then
		if data.verify == "" then
			SHEN_BUILD = false
		else
			local verify = "," .. data.verify .. ","
			if string.find(verify, "," .. tostring(VERSION) .. ",") ~= nil then
				SHEN_BUILD = true
			else
				SHEN_BUILD = false
			end
		end
	end
	SHEN_BUILD = false
	if data and data.vn_dis and #data.vn_dis > 0 and data.vn_dis ~= "1.1.0" and SHEN_BUILD == false then
		DISPLAY_VERSION = data.vn_dis
	end
	if data and data.st == 1 and 0 < #data.url and SHEN_BUILD == false then
		local layer = require("app.scenes.DownloadTipLayer").new({
		size = data.pkgsize,
		listener = function()
			local url = data.url
			local scene = require("update.UpdatingScene").new(data.vn, url)
			display.replaceScene(scene)
		end
		})
		display.getRunningScene():addChild(layer, 10)
	elseif data and data.st == 6 and 0 < #data.url then
		local rootNode = {}
		local node = LoadUI("public/update_tip.ccbi", rootNode)
		node:setPosition(display.cx, display.cy)
		self:addChild(node, 100)
		
		dump(device.platform)		
		--[[
		node:getChildByTag(10000):setEnabled(false)
		local function close()
			if _cancelListener then
				_cancelListener()
			end
			CSDKShell.exit()
			node:setVisible(false)
			node:removeSelf()
		end
		rootNode.cancelBtn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
		]]
		rootNode.cancelBtn:setVisible(false)
		local width = rootNode.tag_bg:getContentSize().width
		rootNode.confirmBtn:setPositionX(width / 2)
		rootNode.confirmBtn:addHandleOfControlEvent(function()
			if #data.url > 0 then
				device.openURL(data.url)
			end
			--self:getChildByTag(10000):setEnabled(true)
			if device.platform == "windows" or device.platform == "mac" then
				self:gotoLoginScene()
			end
		end,
		CCControlEventTouchUpInside)
	else
		
		if BIT_64 == 1 then
			ziploader("src/data64.zip")
			ziploader("src/game64.zip")
		else
			ziploader("src/data.zip")
			ziploader("src/game.zip")
		end
		
		common = require("game.common")
		data_error_error = require("data.data_error_error")
		data_msg_push_msg_push = require("data.data_msg_push_msg_push")
		initVersion = true
		if data ~= nil and data.noticelist and 0 < #data.noticelist then
			local noteLayer = require("app.scenes.GameNote").new({
			data = data.noticelist
			})
			self._chn_flag = data.chn_flag
			local function callBack()
				--self:gotoLoginScene()
			end
			noteLayer:setCallBackFun(callBack)
			self:addChild(noteLayer, 1000)
		else
			--self:gotoLoginScene() --九  零 一起 玩   w w w .9 0 175.com
		end
	end
end

function VersionCheckScene:showUI()
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	local bgSprite = display.newSprite("ui/jpg_bg/gamelogo.jpg")
	if display.widthInPixels / display.heightInPixels == 0.75 then
		bgSprite:setPosition(display.cx, display.height * 0.55)
		bgSprite:setScale(0.9)
	elseif display.widthInPixels == 640 and display.heightInPixels == 960 then
		bgSprite:setPosition(display.cx, display.height * 0.55)
	else
		bgSprite:setPosition(display.cx, display.cy)
	end
	self:addChild(bgSprite)
	self:showOtherUI()
end

--[[
local QQLOGIN = 1
local WXLOGIN = 2
local AUTOLOGIN = 3
function VersionCheckScene:showOtherUI()
	local btnSprite = display.newScale9Sprite("#com_btn_dark_blue.png")
	local btn = CCControlButton:create(common:getLanguageString("@Login"), "fonts/FZCuYuan-M03S.ttf", 30)
	btn:setBackgroundSpriteForState(btnSprite, CCControlStateNormal)
	btn:setPosition(display.cx, 80)
	btn:setTag(10000)
	btn:setPreferredSize(cc.size(157, 69))
	self:addChild(btn)
	btn:addHandleOfControlEvent(function()
		if initVersion == true then
			self:gotoLoginScene()
		elseif self._versionInfo then
			self:checkforupdate(self._versionInfo)
		else
			self:request()
		end
	end,
	CCControlEventTouchUpInside)
end
]]

function VersionCheckScene:onEnter()
	
end

function VersionCheckScene:onEnterTransitionFinish()
	self:request()
end

local btnRes = {
normal   =  "#com_btn_dark_blue.png",
pressed  =  "#com_btn_dark_blue.png",
disabled =  "#com_btn_dark_blue.png"
}

function VersionCheckScene:showOtherUI()
	--注册
	local showRegisterBtn = function ()
		local registerBtn = cc.ui.UIPushButton.new(btnRes, {scale9 = true})
		registerBtn:align(display.CENTER, display.cx - 157 / 2 - 20, 80)
		registerBtn:setButtonSize(157, 69)
		registerBtn:addTo(self)
		registerBtn:setButtonLabel("normal", ui.newTTFLabel({
		text  = common:getLanguageString("@Register"),
		size  = 30,
		font  = FONTS_NAME.font_fzcy,
		}))
		
		registerBtn:onButtonPressed(function(params)
			registerBtn:setScale(1.1)
		end)
		
		registerBtn:onButtonClicked(function(params)
			registerBtn:setScale(1.0)
			--[[
			if(CSDKShell.isLogined()) then
			if self._versionInfo then
				checkforupdate(self._versionInfo)
			end
		else
			]]
			self:showUserNamePassWordEdit(function(username, password)
				self:RegisterOrLoginReq("register", username, password, function(data)
					if data.errCode == 0 then
						CSDKShell.Login()
					end
				end)
			end)
			--end
		end)
	end
	
	--登录
	local showLoginBtn = function ()
		local loginBtn = cc.ui.UIPushButton.new(btnRes, {scale9 = true})
		loginBtn:align(display.CENTER, display.cx + 157 / 2 + 20, 80)
		loginBtn:setButtonSize(157, 69)
		loginBtn:addTo(self)
		
		loginBtn:setButtonLabel("normal", ui.newTTFLabel({
		text  = common:getLanguageString("@Login"),
		size  = 30,
		font  = FONTS_NAME.font_fzcy,
		}))
		
		loginBtn:onButtonPressed(function(params)
			loginBtn:setScale(1.1)
		end)
		
		loginBtn:onButtonClicked(function(params)
			loginBtn:setScale(1.0)
			--[[
			if(CSDKShell.isLogined()) then
			if self._versionInfo then
				checkforupdate(self._versionInfo)
			end
		else
			]]
			self:showUserNamePassWordEdit(function(username, password)
				CSDKShell.Login()
				self:RegisterOrLoginReq("login", username, password, function(data)
					if data.errCode == 0 then
					end
				end)
			end)
			--end
		end)
	end
	
	showRegisterBtn()
	showLoginBtn()
	
end

--[[显示账号编辑输入框]]
function VersionCheckScene:showUserNamePassWordEdit(callback)
	display.addSpriteFramesWithFile("ui/ui_login.plist", "ui/ui_login.png")
	local bgnode = display.newScale9Sprite("#login_server_bg.png")
	bgnode:setContentSize(cc.size(display.width * 0.8, self:getContentSize().height / 3.6))
	bgnode:align(display.BOTTOM_CENTER, display.cx, 40)
	local node = tolua.cast(bgnode,"cc.Node")
	node:setTouchEnabled(true)
	self:addChild(bgnode, 100)
	local topPos = bgnode:getContentSize().height - 10
	local usernameLabel = ui.newTTFLabel({
	text = common:getLanguageString("@Account"),
	size = 26,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER,
	x = 60,
	y = topPos - 40,
	})
	usernameLabel:setAnchorPoint(0, 1)
	bgnode:addChild(usernameLabel)
	local passWordLabel = ui.newTTFLabel({
	text = common:getLanguageString("@Password"),
	align = ui.TEXT_ALIGN_CENTER,
	x = 60,
	y = topPos - 80 - usernameLabel:getContentSize().height,
	size = 26,
	font = FONTS_NAME.font_fzcy,
	})
	
	passWordLabel:setAnchorPoint(0, 1)
	bgnode:addChild(passWordLabel)
	
	local cntSize = bgnode:getContentSize()
	local nameX,nameY = usernameLabel:getPosition()
	local passX,passY = passWordLabel:getPosition()
	local lblSize = usernameLabel:getContentSize()
	local username_str = CCUserDefault:sharedUserDefault():getStringForKey("username")
	local username_editBox = ui.newEditBox({
	image = "#login_input_bg.png",
	size = cc.size(cntSize.width - lblSize.width - 160, lblSize.height + 20),
	x = lblSize.width + nameX + 40,
	y = nameY + 10,
	listener = function(event, editbox)   --监听事件
		if event == "began" then          --点击editBox时触发（触发顺序1） 
			dump("began")
		elseif event == "ended" then        --输入结束时触发 （触发顺序3） 
			dump("ended")
		elseif event == "return" then        --输入结束时触发（触发顺序4） 
			dump("return")
		elseif event == "changed" then       --输入结束时触发（触发顺序2） 
			dump("changed")
			self._isSystemName = false
		else
			
		end
	end
	})
	username_editBox:setFont(FONTS_NAME.font_fzcy, 32)
	username_editBox:setMaxLength(9)
	username_editBox:setPlaceholderFont(FONTS_NAME.font_fzcy, 32)
	username_editBox:setPlaceHolder("账号(4-9个字符)")
	username_editBox:setPlaceholderFontColor(FONT_COLOR.GRAY)
	username_editBox:setReturnType(1)
	username_editBox:setInputMode(0)
	username_editBox:setAnchorPoint(0, 1)
	username_editBox:setText(username_str)
	bgnode:addChild(username_editBox)
	
	local password_str = CCUserDefault:sharedUserDefault():getStringForKey("password")
	local password_editBox = ui.newEditBox({
	image = "#login_input_bg.png",
	size = cc.size(cntSize.width - lblSize.width - 160, lblSize.height + 20),
	x = lblSize.width + passX + 40,
	y = passY + 10,
	listener = function(event, editbox)   --监听事件
		if event == "began" then          --点击editBox时触发（触发顺序1） 
			dump("began")
		elseif event == "ended" then        --输入结束时触发 （触发顺序3） 
			dump("ended")
		elseif event == "return" then        --输入结束时触发（触发顺序4） 
			dump("return")
		elseif event == "changed" then       --输入结束时触发（触发顺序2） 
			dump("changed")
			self._isSystemName = false
		else
			
		end
	end
	})
	
	password_editBox:setFont(FONTS_NAME.font_fzcy, 32)
	password_editBox:setMaxLength(9)
	password_editBox:setPlaceholderFont(FONTS_NAME.font_fzcy, 32)
	password_editBox:setPlaceHolder("密码(1-9个字符)")
	password_editBox:setPlaceholderFontColor(FONT_COLOR.GRAY)
	password_editBox:setReturnType(1)
	password_editBox:setInputMode(0)
	password_editBox:setAnchorPoint(0, 1)
	password_editBox:setInputFlag(0)
	password_editBox:setText(password_str)
	bgnode:addChild(password_editBox)
	
	local okBtn = cc.ui.UIPushButton.new(btnRes, {scale9 = true})
	okBtn:align(display.CENTER, cntSize.width / 2 - 157 / 2 - 20, 60)
	okBtn:setButtonSize(157 * 0.8, 69 * 0.8)
	okBtn:addTo(bgnode)
	okBtn:setButtonLabel("normal", ui.newTTFLabel({
	text  = common:getLanguageString("@Confirm"),
	size  = 25,
	font  = FONTS_NAME.font_fzcy,
	}))
	
	local function okClicked()
		local username = username_editBox:getText()
		local usernamelen = string.utf8len(username)
		local password = password_editBox:getText()
		local passwordlen = string.utf8len(password)
		if usernamelen < 4 or usernamelen > 9 then
			show_tip_label("账号长度须为4~9个字符")
		elseif passwordlen < 1 or passwordlen > 9 then
			show_tip_label("密码长度须为1~9个字符")
		else
			bgnode:removeSelf()
			CCUserDefault:sharedUserDefault():setStringForKey("username", username)
			CCUserDefault:sharedUserDefault():setStringForKey("password", password)
			if callback ~= nil then
				callback(username, password)
			end
		end
	end
	
	okBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			okBtn:setScale(1.1)
			return true
		elseif event.name == "ended" then
			okBtn:setScale(1.0)
			okClicked()
		end
	end)
	
	local cancelBtn = cc.ui.UIPushButton.new(btnRes, {scale9 = true})
	cancelBtn:align(display.CENTER, cntSize.width / 2 + 157 / 2 + 20, 60)
	cancelBtn:setButtonSize(157 * 0.8, 69 * 0.8)
	cancelBtn:addTo(bgnode)
	cancelBtn:setButtonLabel("normal", ui.newTTFLabel({
	text  = common:getLanguageString("@NO"),
	size  = 25,
	font  = FONTS_NAME.font_fzcy,
	}))
	
	local function cancelClicked()
		bgnode:removeSelf()
	end
	
	cancelBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			cancelBtn:setScale(1.1)
			return true
		elseif event.name == "ended" then
			cancelBtn:setScale(1)
			cancelClicked()
		end
	end)
	
end

function VersionCheckScene:RegisterOrLoginReq(reqtype, username, password, callback)
	local loginUrl = NewServerInfo.DEV_LOGIN_SERVER
	dump(loginUrl)
	local function request()
		NetworkHelper.request(
		loginUrl,
		{
		reqtype = reqtype,
		username = username,
		password = password,
		platformID = checkint(CSDKShell.getChannelID()),
		deviceinfo = CSDKShell.GetDeviceInfo()
		},
		function(data)
			if data.errCode ~= 0 then
				if data.err ~= nil then
					show_tip_label(data.err)
				else
					show_tip_label(data_error_error[data.errCode].prompt)
				end
			else
				--CSDKShell.Login()
				CSDKShell.isLoginedOK = true
				CSDKShell.userInfoData.sessionId = data.sessionid
				CSDKShell.userInfoData.uin = data.uin
				CCUserDefault:sharedUserDefault():setStringForKey("accid", username)
				self:gotoLoginScene()
			end
		end,
		"POST")
	end
	request()
end

return VersionCheckScene