local FriendPKResultLayer
require("game.GameConst")

local FriendPKResultLayer = class("FriendPKResultLayer", function(data)
	return require("utility.ShadeLayer").new()
end)

function FriendPKResultLayer:initWin(data)
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("friend/friend_win.ccbi", proxy, self._rootnode)
	node:setPosition(display.width / 2, display.height / 2)
	self:addChild(node)
	local effWin = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "zhandoushengli",
	isRetain = true
	})
	effWin:setPosition(self._rootnode.tag_title_anim:getContentSize().width / 2, self._rootnode.tag_title_anim:getContentSize().height)
	self._rootnode.tag_title_anim:addChild(effWin)
	local effTextWin = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "zhandoushengli_zi",
	isRetain = true
	})
	effTextWin:setPosition(self._rootnode.tag_title_anim:getContentSize().width / 2, self._rootnode.tag_title_anim:getContentSize().height)
	self._rootnode.tag_title_anim:addChild(effTextWin)
	
	self._rootnode.zhenrongBtn:addHandleOfControlEvent(function(eventName, sender)
		local layer = require("game.form.EnemyFormLayer").new(1, self.acc)
		layer:setPosition(0, 0)
		game.runningScene:addChild(layer, 10000)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.zhanbaoBtn:addHandleOfControlEvent(function(eventName, sender)
		show_tip_label(common:getLanguageString("@OpenSoon"))
	end,
	CCControlEventTouchUpInside)
	
end

function FriendPKResultLayer:initLost()
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("huodong/yabiao_lost.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local zhenrongBtn = self._rootnode.zhenrongBtn
	zhenrongBtn:setVisible(false)
	
	self._rootnode.wujiangBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_XIAKE)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.zhuangbeiBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_EQUIPMENT)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.goZhenrongBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_ZHENRONG)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.heroRewardBtn:addHandleOfControlEvent(function(eventName, sender)
		GameStateManager:ChangeState(GAME_STATE.STATE_JIANGHULU)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.zhenqiBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_JINGYUAN)
	end,
	CCControlEventTouchUpInside)
end

function FriendPKResultLayer:ctor(data)
	dump(data)
	self._rootnode = {}
	local result = data.data["1"][1]
	local battleInfo = data.battleInfo
	self.acc = battleInfo.id
	if result == 1 then
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengli))
		self:initWin()
	else
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shibai))
		self:initLost()
	end
	self._rootnode.battle_value_left:setString(tostring(data.attack1))
	self._rootnode.battle_value_right:setString(tostring(data.attack2))
	self._rootnode.player_name_left:setString(data.name1)
	self._rootnode.player_name_right:setString(data.name2)
	self._rootnode.confirmBtn:addHandleOfControlEvent(function(eventName, sender)
		self._rootnode.confirmBtn:setEnabled(false)
		self._rootnode.replayBtn:setEnabled(false)
		if self._rootnode.zhenrongBtn then
			self._rootnode.zhenrongBtn:setEnabled(false)
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_FRIENDS)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.replayBtn:addHandleOfControlEvent(function(eventName, sender)
		self._rootnode.confirmBtn:setEnabled(false)
		self._rootnode.replayBtn:setEnabled(false)
		if self._rootnode.zhenrongBtn then
			self._rootnode.zhenrongBtn:setEnabled(false)
		end
		local scene = require("game.Friend.FriendBattleScene").new(battleInfo)
		display.replaceScene(scene)
	end,
	CCControlEventTouchUpInside)
	
end

function FriendPKResultLayer:onExit(...)
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	display.removeSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
end

return FriendPKResultLayer