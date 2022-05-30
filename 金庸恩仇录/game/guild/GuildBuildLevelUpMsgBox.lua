require("data.data_error_error")

local GuildBuildLevelUpMsgBox = class("GuildBuildLevelUpMsgBox", function()
	return require("utility.ShadeLayer").new()
end)

function GuildBuildLevelUpMsgBox:ctor(param)
	local toLevel = param.toLevel
	local curLevel = param.curLevel
	local needCoin = param.needCoin
	local curCoin = param.curCoin
	local buildType = param.buildType
	local confirmFunc = param.confirmFunc
	local cancelFunc = param.cancelFunc
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/guild/guild_build_levelup_msgBox.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.titleLabel:setString(common:getLanguageString("@Hint"))
	rootnode.need_coin_lbl:setString(tostring(needCoin))
	rootnode.level_lbl:setString(tostring(toLevel))
	rootnode.msg_lbl:setString(GUILD_BUILD_NAME[buildType] .. common:getLanguageString("@Hint_Upgrade"))
	
	local function closeFunc()
		if cancelFunc ~= nil then
			cancelFunc()
		end
		self:removeSelf()
	end
	
	--关闭升级提示
	rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	--取消
	rootnode.cancelBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	--升级
	rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local guildMgr = game.player:getGuildMgr()
		dump(guildMgr:getGuildInfo().m_level)
		local requireStr = guildMgr:getRequireStr(buildType, curLevel)
		if curCoin < needCoin then
			show_tip_label(common:getLanguageString("@GuildGoldNotEnough") .. GUILD_BUILD_NAME[buildType])
		elseif guildMgr:checkIsReachMaxLevel(buildType, curLevel) == true then
			show_tip_label(data_error_error[2900021].prompt)
		elseif requireStr ~= nil then
			show_tip_label(requireStr)
		elseif confirmFunc ~= nil then
			self:setBtnEnabled(false)
			confirmFunc(self)
		end
	end,
	CCControlEventTouchUpInside)
	
	function self.setBtnEnabled(_, bEnabled)
		rootnode.confirmBtn:setEnabled(bEnabled)
		rootnode.cancelBtn:setEnabled(bEnabled)
		rootnode.tag_close:setEnabled(bEnabled)
	end
	
	alignNodesOneByAllCenterX(rootnode.GuildLabel_1:getParent(), {
	rootnode.GuildLabel_1,
	rootnode.need_coin_lbl,
	rootnode.name_lbl
	}, 2)
	alignNodesOneByAllCenterX(rootnode.msg_lbl:getParent(), {
	rootnode.msg_lbl,
	rootnode.level_lbl,
	rootnode.msg_lbl_2
	}, 2)
end

return GuildBuildLevelUpMsgBox