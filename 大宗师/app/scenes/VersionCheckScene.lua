--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-8-12
-- Time: 上午11:33
-- To change this template use File | Settings | File Templates.
--
require("game.GameConst")

require("network.NetworkHelper")
require("utility.Func")
require("data.data_serverurl_serverurl")
require("constant.ZipLoader")
require("data.data_sdkinfo")
local VersionCheckScene = class("VersionCheckScene", function()
    return display.newScene("VersionCheckScene")
end)

function VersionCheckScene:ctor()
    self:showUI()
    addbackevent(self)
end

--根据是否有更新切换不同的场景
local function checkforupdate(data)
    if data and data.vn_dis and #data.vn_dis > 0 then
        DISPLAY_VERSION = data.vn_dis
    end

    if data and data.st == 1 and #data.url > 0 then
        local layer = require("app.scenes.DownloadTipLayer").new({
            size = data.pkgsize,
            listener = function()
                local url = data.url
                local scene = require("update.UpdatingScene").new(data.vn, url)
                display.replaceScene(scene)
            end
        })
        display.getRunningScene():addChild(layer, 10)
    else  --没有可以更新的自己，直接进入游戏
        if data.st == 6 then
            show_tip_label("有最新版本，请前往下载")
        end
        ziploader("game/game.zip")
        ziploader("game/data.zip")


        display.replaceScene(require("game.login.LoginScene").new())
    end
end

function VersionCheckScene:showUI()
    display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
    local bgSprite = display.newSprite("ui/jpg_bg/gamelogo.jpg")

    if (display.widthInPixels / display.heightInPixels) == 0.75 then
        bgSprite:setPosition(display.cx, display.height*0.55)
        bgSprite:setScale(0.9)
    elseif(display.widthInPixels == 640 and display.heightInPixels == 960) then
        bgSprite:setPosition(display.cx, display.height*0.55)
    else
        bgSprite:setPosition(display.cx, display.cy)
    end
    self:addChild(bgSprite)

    if CSDKShell.GetSDKTYPE() == SDKType.ANDROID_TENCENT or
            CSDKShell.GetSDKTYPE() == SDKType.ANDROID_TENCENT_RXQZ then
        self:performWithDelay(function()
            self:showQQUI()
        end, 2.5)
    else
        self:showOtherUI()
    end
end

local QQLOGIN = 1
local WXLOGIN = 2
local AUTOLOGIN = 3
function VersionCheckScene:showQQUI()

    local btnSprite = display.newScale9Sprite("#com_btn_qq.png")
    local qqLoginBtn = CCControlButton:create()
    qqLoginBtn:setBackgroundSpriteForState(btnSprite, CCControlStateNormal)
    qqLoginBtn:setPosition(display.cx * 0.5, 80)
    qqLoginBtn:setPreferredSize(CCSizeMake(275, 90))
    self:addChild(qqLoginBtn)

    qqLoginBtn:addHandleOfControlEvent(function()
        if(CSDKShell.isLogined()) then
            if self._versionInfo then
                checkforupdate(self._versionInfo)
            end
        else
            CSDKShell.Login(QQLOGIN)
        end
    end, CCControlEventTouchDown)

    btnSprite = display.newScale9Sprite("#com_btn_wx.png")
    local wxLoginBtn = CCControlButton:create()
    wxLoginBtn:setBackgroundSpriteForState(btnSprite, CCControlStateNormal)
    wxLoginBtn:setPosition(display.cx * 1.5, 80)
    wxLoginBtn:setPreferredSize(CCSizeMake(275, 90))
    self:addChild(wxLoginBtn)

    wxLoginBtn:addHandleOfControlEvent(function()
        if(CSDKShell.isLogined()) then
            if self._versionInfo then
                checkforupdate(self._versionInfo)
            end
        else
            CSDKShell.Login(WXLOGIN)
        end
    end, CCControlEventTouchDown)
end

function RegisterOrLoginReq(reqtype, username, password, callback)
	local network = require ("utility.GameHTTPNetWork").new()
	local channelID = checkint(CSDKShell.getChannelID())
	local deviceinfo = CSDKShell.GetDeviceInfo()
	local msg = {}
	msg.reqtype = reqtype
	msg.username = username
	msg.password = password
	msg.platformID = channelID
	msg.deviceinfo = deviceinfo
	
	dump(msg)
	
	local function cb( data )
		print("LOGIN: CB----------------------------->>>>>>")
		if(data.errorCode == 101) then
				device.showAlert("提示", "sdk异常，请重新登录！","好的",function ( ... )                     
					-- CSDKShell.Login()        
					game.player.m_logout = true
					display.replaceScene(require("app.scenes.VersionCheckScene").new())
					CSDKShell.onLogout()
				end)
		end
		dump(data)
		if(data.errCode ~= 0) then
			dump(data)
			if data.errmsg ~= nil then
				show_tip_label(data.errmsg)
			else
				show_tip_label(data_error_error[data.errCode].prompt)
			end
			return
		end
		if callback ~= nil then
			callback(data)
		end
	end
	local _loginUrl = data_serverurl_serverurl[channelID].loginUrl
	if(DEV_BUILD == true) then
		_loginUrl = data_serverurl_serverurl[channelID].loginUrldev                
	end
	network:SendRequest(1,msg, cb, nil, _loginUrl)
end

function VersionCheckScene:showOtherUI()
	local showUserNamePassWordEdit = function (callback)
		display.addSpriteFramesWithFile("ui/ui_login.plist", "ui/ui_login.png")
		local bg2 = display.newScale9Sprite("#login_server_bg.png")
		bg2:setAnchorPoint(0.5, 0)
		bg2:setContentSize(CCSizeMake(display.width * 0.8, self:getContentSize().height / 3.6))
		bg2:setPosition(display.width / 2, 40)
		self:addChild(bg2, 1000)
		local topPos = bg2:getContentSize().height - 10
		
		local usernameLabel = ui.newTTFLabel({
			text = "帐号",
			align = ui.TEXT_ALIGN_CENTER,
			x = 60,
			y = topPos - 40,
			size = 26,
			font = "fonts/FZCuYuan-M03S.ttf"
		})
		usernameLabel:setAnchorPoint(0, 1)
		bg2:addChild(usernameLabel)
		local passWordLabel = ui.newTTFLabel({
			text = "密码",
			align = ui.TEXT_ALIGN_CENTER,
			x = 60,
			y = topPos - 80 - usernameLabel:getContentSize().height,
			size = 26,
			font = "fonts/FZCuYuan-M03S.ttf"
		})
		passWordLabel:setAnchorPoint(0, 1)
		bg2:addChild(passWordLabel)
		
		local cntSize = bg2:getContentSize()
		local nameX,nameY = usernameLabel:getPosition()
		local passX,passY = passWordLabel:getPosition()
		local lblSize = usernameLabel:getContentSize()
		
		local username_str = CCUserDefault:sharedUserDefault():getStringForKey("username")
		local username_editBox = ui.newEditBox({
				image = "#login_input_bg.png",
				size = CCSizeMake(cntSize.width - lblSize.width - 160, lblSize.height + 20),
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
						-- printf("EditBox event %s", tostring(event))  
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
		bg2:addChild(username_editBox)
		
		local password_str = CCUserDefault:sharedUserDefault():getStringForKey("password")
		local password_editBox = ui.newEditBox({
				image = "#login_input_bg.png",
				size = CCSizeMake(cntSize.width - lblSize.width - 160, lblSize.height + 20),
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
						-- printf("EditBox event %s", tostring(event))  
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
		bg2:addChild(password_editBox)
		
		local btnSprite = display.newScale9Sprite("#com_btn_dark_blue.png")
		local btn = CCControlButton:create("确定", "fonts/FZCuYuan-M03S.ttf", 30)
		btn:setBackgroundSpriteForState(btnSprite, CCControlStateNormal)
		btn:setPosition(cntSize.width / 2 - 157 / 2 - 20, 60)
		btn:setPreferredSize(CCSizeMake(157 * 0.8, 69 * 0.8))
		bg2:addChild(btn)
		btn:addHandleOfControlEvent(function()
			local username = username_editBox:getText()
			local usernamelen = string.utf8len(username)
			local password = password_editBox:getText()
			local passwordlen = string.utf8len(password)
			if usernamelen < 4 or usernamelen > 9 then
				show_tip_label("账号长度须为4~9个字符")
			elseif passwordlen < 1 or passwordlen > 9 then
				show_tip_label("密码长度须为1~9个字符")
			else
				CCUserDefault:sharedUserDefault():setStringForKey("username", username)
				CCUserDefault:sharedUserDefault():setStringForKey("password", password)
				if callback ~= nil then
					callback(username, password)
				end
			end
		end, CCControlEventTouchDown)
		
		local btnSprite = display.newScale9Sprite("#com_btn_dark_blue.png")
		local btn = CCControlButton:create("取消", "fonts/FZCuYuan-M03S.ttf", 30)
		btn:setBackgroundSpriteForState(btnSprite, CCControlStateNormal)
		btn:setPosition(cntSize.width / 2 + 157 / 2 + 20, 60)
		btn:setPreferredSize(CCSizeMake(157 * 0.8, 69 * 0.8))
		bg2:addChild(btn)
		btn:addHandleOfControlEvent(function()
			bg2:removeSelf()
		end, CCControlEventTouchDown)
		--login_server_name_bg
	end
	local showLoginBtn = function ()
		local btnSprite = display.newScale9Sprite("#com_btn_dark_blue.png")
		local btn = CCControlButton:create("登录", "fonts/FZCuYuan-M03S.ttf", 30)
		btn:setBackgroundSpriteForState(btnSprite, CCControlStateNormal)
		btn:setPosition(display.cx + 157 / 2 + 20, 80)
		btn:setPreferredSize(CCSizeMake(157, 69))
		self:addChild(btn)
	
		btn:addHandleOfControlEvent(function()
			--CSDKShell.isLoginedOK = true
			if(CSDKShell.isLogined()) then
				if self._versionInfo then
					checkforupdate(self._versionInfo)
				end
			else
				showUserNamePassWordEdit(function(username, password)
					CSDKShell.Login()
					RegisterOrLoginReq("login", username, password, function(data)
						if data.errCode == 0 then
							CSDKShell.isLoginedOK = true
							CSDKShell.userInfoData.sessionId = data.sessionid
							CSDKShell.userInfoData.uin = data.uin
						end
					end)
				end)
			end
		end, CCControlEventTouchDown)
	end
	local showRegisterBtn = function ()
		local btnSprite = display.newScale9Sprite("#com_btn_dark_blue.png")
		local btn = CCControlButton:create("注册", "fonts/FZCuYuan-M03S.ttf", 30)
		btn:setBackgroundSpriteForState(btnSprite, CCControlStateNormal)
		btn:setPosition(display.cx - 157 / 2 - 20, 80)
		btn:setPreferredSize(CCSizeMake(157, 69))
		self:addChild(btn)
	
		btn:addHandleOfControlEvent(function()
			if(CSDKShell.isLogined()) then
				if self._versionInfo then
					checkforupdate(self._versionInfo)
				end
			else
				showUserNamePassWordEdit(function(username, password)
					RegisterOrLoginReq("register", username, password, function(data)
						if data.errCode == 0 then
							CSDKShell.Login()
							CSDKShell.isLoginedOK = true
							CSDKShell.userInfoData.sessionId = data.sessionid
							CSDKShell.userInfoData.uin = data.uin
						end
					end)
				end)
			end
		end, CCControlEventTouchDown)
	end
	showLoginBtn()
	showRegisterBtn()
end

function VersionCheckScene:request()
    local function request()
        local channelID = checkint(CSDKShell.getChannelID())
        NetworkHelper.request(data_serverurl_serverurl[channelID].versionUrl, {
            ac = "dwurl",
            channel = CSDKShell.getChannelID(),
            version = getlocalversion(),
            buildFlag = CSDKShell.getBuildFlag()
        }, function(data)
            dump(data)
            self._versionInfo = data

            checkforupdate(data)
        end, "GET")
    end
    request()
end

function VersionCheckScene:onEnter()

end

function VersionCheckScene:onEnterTransitionFinish()
    if(CSDKShell.isLogined()) then
        self:request()
    else
        if CSDKShell.GetSDKTYPE() ~= SDKType.ANDROID_TENCENT or
                CSDKShell.GetSDKTYPE() == SDKType.ANDROID_TENCENT_RXQZ then
            CSDKShell.Login(AUTOLOGIN)
        end

        local scheduler = require("framework.scheduler")
        local loginSche
        loginSche = scheduler.scheduleGlobal(function()
            if(CSDKShell.isLogined()) then
                scheduler.unscheduleGlobal(loginSche)
                self:request()
            end
        end, 0.5)
    end
end

return VersionCheckScene

