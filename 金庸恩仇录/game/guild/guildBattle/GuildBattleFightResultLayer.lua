local GuildBattleFightResultLayer
require("game.GameConst")
local GuildBattleFightResultLayer = class("GuildBattleFightResultLayer", function(data)
	return require("utility.ShadeLayer").new()
end)
function GuildBattleFightResultLayer:initWin(data)
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
	local zhenrongBtn = self._rootnode.zhenrongBtn
	zhenrongBtn:setVisible(false)
	self._rootnode.zhanbaoBtn:addHandleOfControlEvent(function(eventName, sender)
		show_tip_label(common:getLanguageString("@OpenSoon"))
	end,
	CCControlEventTouchUpInside)
	
end

function GuildBattleFightResultLayer:initLost()
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("huodong/yabiao_lost.ccbi", proxy, self._rootnode)
	node:setPosition(display.width / 2, display.height / 2)
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

function GuildBattleFightResultLayer:normalFightResult(data)
	local result = data.data["1"][1]
	local battleInfo = data.battleInfo
	battleInfo.isPassed = true
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
		self:confirmFunc()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.replayBtn:addHandleOfControlEvent(function(eventName, sender)
		self._rootnode.confirmBtn:setEnabled(false)
		self._rootnode.replayBtn:setEnabled(false)
		local scene = require("game.guild.guildBattle.GuildBattleFightScene").new(battleInfo)
		display.replaceScene(scene)
	end,
	CCControlEventTouchUpInside)
	
	if result == 1 then
		local tips = common:getLanguageString("@ReceiveReward")
		dump(data.data["3"])
		local data_item_item = require("data.data_item_item")
		for key, v in pairs(data.data["3"]) do
			local resType = ResMgr.getResType(v.t)
			local name = ResMgr.getItemNameByType(v.id, resType)
			tips = tips .. name .. "X" .. v.n .. "  "
		end
		local rewardLabel = ui.newTTFLabelWithShadow({
		text = tips,
		font = FONTS_NAME.font_fzcy,
		size = 20,
		color = cc.c3b(0, 228, 62),
		align = ui.TEXT_ALIGN_CENTER,
		shadowColor = FONT_COLOR.BLACK
		})
		self._rootnode.zhenrongBtn:getParent():addChild(rewardLabel)
		rewardLabel:setPosition(self._rootnode.zhenrongBtn:getPosition())
	end
end

function GuildBattleFightResultLayer:bossFightResult(data)
	local rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("guild/guild_battle_boss_result_layer.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local result = data.data
	rootnode.hurt_lbl:setString(tostring(result["5"]))
	for i, v in ipairs(result["3"]) do
		if v.id == 18 then
			rootnode.gongxun_lbl:setString(tostring(v.n))
		end
	end
	local kill_lbl = "@GuildBattleBossAlive"
	if result["1"][1] == 1 then
		kill_lbl = "@GuildBattleBossDeaded"
	end
	rootnode.state_lbl:setString(common:getLanguageString("@GuildBattleBossTitle") .. common:getLanguageString(kill_lbl))
	rootnode.confirmBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:confirmFunc()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.closeBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:confirmFunc()
	end,
	CCControlEventTouchUpInside)
	
	alignNodesOneByAllCenterX(rootnode.sprite_1:getParent(), {
	rootnode.sprite_0,
	rootnode.sprite_1,
	rootnode.sprite_2
	}, 4)
	alignNodesOneByAllCenterX(rootnode.hurt_lbl_1:getParent(), {
	rootnode.hurt_lbl_1,
	rootnode.hurt_lbl
	}, 4)
	alignNodesOneByAllCenterX(rootnode.label_2:getParent(), {
	rootnode.label_2,
	rootnode.shengwang,
	rootnode.gongxun_lbl
	}, 4)
end

function GuildBattleFightResultLayer:ctor(data)
	dump(data)
	self._rootnode = {}
	if data.fightType == 1 then
		self:normalFightResult(data)
	else
		self:bossFightResult(data)
	end
end

function GuildBattleFightResultLayer:confirmFunc()
	pop_scene()
end

function GuildBattleFightResultLayer:onExit(...)
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	display.removeSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
end

return GuildBattleFightResultLayer