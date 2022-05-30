local SettingLayer = class("SettingLayer", function()
	return require("utility.ShadeLayer").new()
end)

function SettingLayer:ctor()
	self._rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("mainmenu/setting_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	--标题
	self._rootnode.titleLabel:setString(common:getLanguageString("@shezhi"))
	--关闭
	self._rootnode.tag_close:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	self:updateUI()
end

function SettingLayer:updateUI()
	local tableNode = {}
	local MAXNUM = 6
	for i = 1, MAXNUM do
		self._rootnode["baseNode" .. i]:setVisible(false)
		if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
			if i == 2 or i == 3 then
			else
				self._rootnode["baseNode" .. i]:setVisible(true)
				table.insert(tableNode, self._rootnode["baseNode" .. i])
			end
		elseif i == 3 then
		else
			self._rootnode["baseNode" .. i]:setVisible(true)
			table.insert(tableNode, self._rootnode["baseNode" .. i])
		end
	end
	local height = 510
	local offset = math.floor(height / #tableNode)
	for i, v in ipairs(tableNode) do
		v:setPositionY(30 + (i - 1) * offset)
	end
	
	--cdkey
	local function initTuiGuang()
		local cdkeyBtn = self._rootnode.cdkeyBtn
		local btnText = common:getLanguageString("@tuiguang")
		cdkeyBtn:setTitleForState(btnText, CCControlStateNormal)
		cdkeyBtn:setTitleForState(btnText, CCControlStateSelected)
		cdkeyBtn:setTitleForState(btnText, CCControlStateHighlighted)
		cdkeyBtn:addHandleOfControlEvent(function(sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			local tg_url = NewServerInfo.TUIGUANG_URL .."?s="..game.player.m_serverID.."&r="..game.player:getPlayerID()
			device.openURL(tg_url)
			dump(tg_url)
			--[[
			local cdkeyRewardLayer = require("game.Huodong.CDKeyReward.CDKeyRewardLayer").new({
			endFunc = function()
				cdkeyBtn:setEnabled(true)
			end
			})
			game.runningScene:addChild(cdkeyRewardLayer, self:getZOrder() + 1)
			]]
		end,
		CCControlEventTouchUpInside)
	end
	
	initTuiGuang()
	
	local enable = CCUserDefault:sharedUserDefault():getBoolForKey(GAME_SETTING.ENABLE_MUSIC)
	if enable then
		self._rootnode.music_bg_close_btn:setVisible(false)
		self._rootnode.music_bg_open_btn:setVisible(true)
	else
		self._rootnode.music_bg_close_btn:setVisible(true)
		self._rootnode.music_bg_open_btn:setVisible(false)
	end
	
	--背景音乐:开
	self._rootnode.music_bg_open_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameAudio.setSoundEnable(false)
		GameAudio.stopMusic()
		self._rootnode.music_bg_close_btn:setVisible(true)
		self._rootnode.music_bg_open_btn:setVisible(false)
	end,
	CCControlEventTouchUpInside)
	
	--背景音乐:关
	self._rootnode.music_bg_close_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameAudio.setSoundEnable(true)
		GameAudio.playMainmenuMusic(true)
		PostNotice(NoticeKey.MainMenuScene_Music)
		self._rootnode.music_bg_open_btn:setVisible(true)
		self._rootnode.music_bg_close_btn:setVisible(false)
	end,
	CCControlEventTouchUpInside)
	
	--
	local sfxEnable = CCUserDefault:sharedUserDefault():getBoolForKey(GAME_SETTING.ENABLE_SFX)
	if sfxEnable then
		self._rootnode.music_sfx_close_btn:setVisible(false)
		self._rootnode.music_sfx_open_btn:setVisible(true)
	else
		self._rootnode.music_sfx_close_btn:setVisible(true)
		self._rootnode.music_sfx_open_btn:setVisible(false)
	end
	
	--音乐效果:开
	self._rootnode.music_sfx_open_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameAudio.setSfxEnable(false)
		self._rootnode.music_sfx_close_btn:setVisible(true)
		self._rootnode.music_sfx_open_btn:setVisible(false)
	end,
	CCControlEventTouchUpInside)
	
	--音乐效果:关
	self._rootnode.music_sfx_close_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameAudio.setSfxEnable(true)
		GameAudio.playMainmenuMusic(true)
		self._rootnode.music_sfx_open_btn:setVisible(true)
		self._rootnode.music_sfx_close_btn:setVisible(false)
	end,
	CCControlEventTouchUpInside)
	
	local dubEnable = CCUserDefault:sharedUserDefault():getBoolForKey(GAME_SETTING.ENABLE_DUB, true)
	if dubEnable then
		self._rootnode.dubbing_bg_close_btn:setVisible(false)
		self._rootnode.dubbing_bg_open_btn:setVisible(true)
	else
		self._rootnode.dubbing_bg_close_btn:setVisible(true)
		self._rootnode.dubbing_bg_open_btn:setVisible(false)
	end
	
	--侠客配音:开
	self._rootnode.dubbing_bg_open_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameAudio.setDubEnable(false)
		self._rootnode.dubbing_bg_close_btn:setVisible(true)
		self._rootnode.dubbing_bg_open_btn:setVisible(false)
	end,
	CCControlEventTouchUpInside)
	
	--侠客配音:关
	self._rootnode.dubbing_bg_close_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameAudio.setDubEnable(true)
		GameAudio.playMainmenuMusic(true)
		self._rootnode.dubbing_bg_open_btn:setVisible(true)
		self._rootnode.dubbing_bg_close_btn:setVisible(false)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.jiedai_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local jiedaiBaoBox = require("game.Setting.JiedaiBaoBox").new()
		game.runningScene:addChild(jiedaiBaoBox, 1000)
	end,
	CCControlEventTouchUpInside)
	
	local function sdkCenter()
		local btnText = common:getLanguageString("@Back")
		if CSDKShell.getYAChannelID() == CHANNELID.IOS_91 then
			btnText = common:getLanguageString("@jiuzx")
		elseif CSDKShell.getYAChannelID() == CHANNELID.IOS_PP then
			btnText = common:getLanguageString("@pizx")
		elseif CSDKShell.getYAChannelID() == CHANNELID.IOS_TB then
			btnText = common:getLanguageString("@tongbutui")
		elseif CSDKShell.getYAChannelID() == CHANNELID.IOS_ITOOLS then
			btnText = common:getLanguageString("@aitusi")
		elseif CSDKShell.getYAChannelID() == CHANNELID.IOS_XY then
			btnText = common:getLanguageString("@chawai")
		elseif CSDKShell.getYAChannelID() == CHANNELID.IOS_AS then
			btnText = common:getLanguageString("@aisi")
		elseif CSDKShell.getYAChannelID() == CHANNELID.IOS_IA then
			btnText = common:getLanguageString("@aipingguo")
		end
		if device.platform == "android" then
			btnText = common:getLanguageString("@Back")
		end
		if CSDKShell.getYAChannelID() == CHANNELID.ANDROID_GOOGLE_TW then
			btnText = common:getLanguageString("@yonghuzx")
		end
		self._rootnode.returnLoginBtn:setVisible(true)
		self._rootnode.returnLoginBtn:setTitleForState(btnText, CCControlStateNormal)
		self._rootnode.returnLoginBtn:setTitleForState(btnText, CCControlStateSelected)
		self._rootnode.returnLoginBtn:setTitleForState(btnText, CCControlStateHighlighted)
	end
	sdkCenter()
	
	--返回登录
	self._rootnode.returnLoginBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_VERSIONCHECK)
		--CSDKShell.onLogout()
	end,
	CCControlEventTouchUpInside)
	
end

return SettingLayer