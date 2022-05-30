require("data.data_error_error")
local data_config_union_config_union = require("data.data_config_union_config_union")
local data_feature_switch_config = require("data.data_feature_switch_config")
local data_ui_ui = require("data.data_ui_ui")
local MAX_ZORDER = 101
local BUILD_LEVEL_FONT_SIZE = 20
local CHILD_TAG = 1

local GuildBaseScene = require("game.guild.utility.GuildBaseScene")
local GuildMainScene = class("GuildMainScene", GuildBaseScene)

--修改帮派公告
function GuildMainScene:modifyNote(text, node)
	if common:checkSensitiveWord(text) and ResMgr.checkSensitiveWord(textStr) == true then
		show_tip_label(data_error_error[2900041].prompt)
		return
	end
	RequestHelper.Guild.modify({
	text = text,
	type = 0,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
		elseif data.rtnObj.success == 0 then
			show_tip_label(data_error_error[2900043].prompt)
			self._rootnode.guild_note_lbl:setString(text)
			node:removeSelf()
			game.player:getGuildMgr():getGuildInfo().m_unionIndes = text
		end
	end
	})
end

function GuildMainScene:zijian(node)
	RequestHelper.Guild.zijian({
	leaderId = game.player:getGuildMgr():getGuildInfo().m_bossId,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
			node:setBtnEnabled(true)
		else
			local rtnObj = data.rtnObj
			game.player:getGuildMgr():setCoverVo(rtnObj)
			PostNotice(NoticeKey.GUILD_UPDATE_ZIJIAN)
			node:removeSelf()
			game.runningScene:addChild(require("game.guild.utility.GuildNormalMsgBox").new({
			title = common:getLanguageString("@Hint"),
			msg = data_ui_ui[6].content,
			isSingleBtn = true,
			confirmFunc = function(msgBox)
				msgBox:removeSelf()
			end
			}),
			MAX_ZORDER)
		end
	end,
	errback = function(data)
		node:removeSelf()
	end
	})
end

function GuildMainScene:ctor(buildType)
	game.runningScene = self
	local bottomFile = "guild/guild_bottom_frame_main_normal.ccbi"
	local jopType = game.player:getGuildMgr():getGuildInfo().m_jopType
	if jopType ~= GUILD_JOB_TYPE.normal then
		bottomFile = "guild/guild_bottom_frame_main.ccbi"
	end
	GuildMainScene.super.ctor(self, {
	contentFile = "guild/guild_main_scene.ccbi",
	topFile = "guild/guild_top_frame_main.ccbi",
	bottomFile = bottomFile,
	isOther = true
	})
	
	if data_feature_switch_config[1].ENABLE_GUILD_FUBEN == true then
		self._rootnode.tag_fuben:setVisible(true)
	else
		self._rootnode.tag_fuben:setVisible(false)
	end
	local guildMgr = game.player:getGuildMgr()
	local guildInfo = guildMgr:getGuildInfo()
	self._jopType = guildInfo.m_jopType
	local centerH = self:getCenterHeight()
	local scrollView = self._rootnode.tag_scrollView
	local msgNodeH = self._rootnode.bottom_msg_node:getContentSize().height - self._rootnode.top_msg_node:getContentSize().height
	scrollView:setBounceable(false)
	local scrollNodeH = self._rootnode.tag_scroll_bg:getContentSize().height
	if centerH >= scrollNodeH then
		scrollView:setTouchEnabled(false)
	end
	scrollView:setContentOffset(cc.p(0, -self._rootnode.bottom_msg_node:getContentSize().height), false)
	if guildInfo.m_unionIndes ~= nil then
		self._rootnode.guild_note_lbl:setString(tostring(guildInfo.m_unionIndes))
	else
		self._rootnode.guild_note_lbl:setString(data_config_union_config_union[1].guild_note_msg)
	end
	self:updateMsgDataLbl()
	self._rootnode.guild_name_lbl:setString(tostring(guildInfo.m_name))
	self._rootnode.guild_level_lbl:setString(tostring(guildInfo.m_level))
	self._rootnode.guild_num_lbl_1:setString(tostring(guildInfo.m_nowRoleNum))
	self._rootnode.guild_num_lbl_2:setString("/" .. tostring(guildInfo.m_roleMaxNum))
	self._rootnode.guild_power_lbl:setString(tostring(guildInfo.m_sumAttack))
	if self._jopType == GUILD_JOB_TYPE.normal then
		self._rootnode.modify_btn:setVisible(false)
	else
		self._rootnode.modify_btn:setVisible(true)
	end
	
	--查看帮派列表
	self._rootnode.check_guildList_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_GUILDLIST)
	end,
	CCControlEventTouchUpInside)
	
	--改名
	self._rootnode.change_name_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if true then
			show_tip_label(common:getLanguageString("@HintPause"))
		else
			self:addChild(require("game.guild.GuildCreateMsgBox").new({
			type = 2,
			nameLbl = self._rootnode.guild_name_lbl
			}), MAX_ZORDER)
		end
	end,
	CCControlEventTouchUpInside)
	
	if game.player:getGuildMgr():getGuildInfo().m_jopType ~= GUILD_JOB_TYPE.leader then
		self._rootnode.change_name_btn:setVisible(false)
	end
	
	--修改公会
	local modifyBtn = self._rootnode.modify_btn
	modifyBtn:addHandleOfControlEvent(function(sender, eventName)
		modifyBtn:setEnabled(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:addChild(require("game.guild.GuildModifyMsgBox").new({
		title = common:getLanguageString("@GuildBroader"),
		text = game.player:getGuildMgr():getGuildInfo().m_unionIndes,
		msgMaxLen = data_config_union_config_union[1].guild_note_max_length,
		confirmFunc = function(text, node)
			modifyBtn:setEnabled(true)
			self:modifyNote(text, node)
		end,
		cancelFunc = function()
			modifyBtn:setEnabled(true)
		end
		}), MAX_ZORDER)
	end,
	CCControlEventTouchUpInside)
	
	--自荐帮主
	local zijianBtn = self._rootnode.zijian_btn
	zijianBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		game.runningScene:addChild(require("game.guild.utility.GuildNormalMsgBox").new({
		title = common:getLanguageString("@Hint"),
		msg = data_ui_ui[5].content,
		isSingleBtn = false,
		confirmFunc = function(node)
			self:zijian(node)
		end
		}), MAX_ZORDER)
	end,
	CCControlEventTouchUpInside)
	
	self:initBuildLevel()
	self:initBuildBtnFunc()
	self._scheduler = require("framework.scheduler")
	if buildType ~= nil then
		self:toBuild(buildType)
	end
	if game.player:getAppOpenData().gvg_battle == APPOPEN_STATE.close then
		self._rootnode.tag_baihu_btn:setVisible(false)
	end
	
end

function GuildMainScene:initBuildLevel()
	local color = cc.c3b(255, 216, 0)
	local shadowColor = cc.c3b(10, 10, 10)
	local guildInfo = game.player:getGuildMgr():getGuildInfo()
	local function createTTF(text, node)
		local lbl = ui.newTTFLabelWithOutline({
		text = "LV." .. text,
		size = BUILD_LEVEL_FONT_SIZE,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT,
		color = color,
		outlineColor = shadowColor,
		})
		ResMgr.replaceKeyLable(lbl, node, 0, 0)
		lbl:align(display.CENTER)
		node:setVisible(false)
		return lbl
	end
	
	self._dadianLvLbl = createTTF(tostring(guildInfo.m_level), self._rootnode.tag_dadian_lv_lbl)
	self._zuofangLvLbl = createTTF(tostring(guildInfo.m_workshoplevel), self._rootnode.tag_zuofang_lv_lbl)
	if data_feature_switch_config[1].ENABLE_GUILD_SHOP == true then
		self._shopLvLbl = createTTF(tostring(guildInfo.m_shoplevel), self._rootnode.tag_shop_lv_lbl)
	end
	if data_feature_switch_config[1].ENABLE_QINGLONGTANG == true then
		self._qinglongLvLbl = createTTF(tostring(guildInfo.m_greenDragonTempleLevel), self._rootnode.tag_qinglong_lv_lbl)
	end
	if data_feature_switch_config[1].ENABLE_GUILD_FUBEN == true then
		self._fubenLvLbl = createTTF(tostring(guildInfo.m_fubenLevel), self._rootnode.tag_fuben_lv_lbl)
	end
end

function GuildMainScene:toBuild(tag)
	if tag ~= nil then
		if tag == GUILD_BUILD_TYPE.dadian then
			GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_DADIAN)
		elseif tag == GUILD_BUILD_TYPE.zuofang then
			local function toLayer(data)
				local layer = require("game.guild.guildZuofang.GuildZuofangLayer").new(data)
				game.runningScene:addChild(layer, MAX_ZORDER, CHILD_TAG)
			end
			if self:getChildByTag(CHILD_TAG) == nil then
				game.player:getGuildMgr():RequestEnterWorkShop(toLayer)
			end
		elseif tag == GUILD_BUILD_TYPE.qinglong then
			if data_feature_switch_config[1].ENABLE_QINGLONGTANG == true then
				local function toLayer(data)
					local rtnObj = data.rtnObj
					if rtnObj.state == GUILD_QL_CHALLENGE_STATE.hasOpen then
						GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_QL_BOSS, true)
					elseif rtnObj.state == GUILD_QL_CHALLENGE_STATE.notOpen or rtnObj.state == GUILD_QL_CHALLENGE_STATE.hasEnd then
						local layer = require("game.guild.guildQinglong.GuildQinglongLayer").new(data)
						game.runningScene:addChild(layer, MAX_ZORDER, CHILD_TAG)
					end
				end
				if self:getChildByTag(CHILD_TAG) == nil then
					game.player:getGuildMgr():RequestBossHistory(toLayer)
				end
			else
				show_tip_label(common:getLanguageString("@OpenSoon"))
			end
		elseif tag == GUILD_BUILD_TYPE.shop then
			if data_feature_switch_config[1].ENABLE_GUILD_SHOP == true then
				GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_SHOP, GUILD_SHOP_TYPE.all)
			else
				show_tip_label(common:getLanguageString("@OpenSoon"))
			end
		elseif tag == GUILD_BUILD_TYPE.houshandidong then
			show_tip_label(data_error_error[2800001].prompt)
		elseif tag == GUILD_BUILD_TYPE.baihu then
			GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_BATTLE)
		elseif tag == GUILD_BUILD_TYPE.fuben then
			if data_feature_switch_config[1].ENABLE_GUILD_FUBEN == true then
				GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_FUBEN, GUILD_FUBEN_TYPE.none)
			else
				show_tip_label(common:getLanguageString("@OpenSoon"))
			end
		end
	end
end

function GuildMainScene:initBuildBtnFunc()
	local btnNames = {
	"tag_dadian_btn",
	"tag_zuofang_btn",
	"tag_shop_btn",
	"tag_qinglong_btn",
	"tag_baihu_btn",
	"tag_houshan_btn",
	"tag_fuben_btn"
	}
	for i, v in ipairs(btnNames) do
		if self._rootnode[v] ~= nil then
			self._rootnode[v]:addHandleOfControlEvent(function(sender, eventName)
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
				local tag = sender:getTag()
				self:toBuild(tag)
			end,
			CCControlEventTouchUpInside)
		end
	end
end

function GuildMainScene:checkCover()
	local guildMgr = game.player:getGuildMgr()
	if guildMgr:getIsChangeCover() == true then
		self._rootnode.top_msg_node:setVisible(true)
		do
			local coverInfo = guildMgr:getCoverVo()
			if coverInfo.state == GUILD_ZIJIAN_STATE.enabled then
				self._rootnode.zijian_btn:setVisible(true)
			else
				self._rootnode.zijian_btn:setVisible(false)
			end
			if #coverInfo.names <= 0 then
				self._rootnode.tag_top_noMsg:setVisible(true)
				self._rootnode.tag_top_hasMsg:setVisible(false)
			else
				self._rootnode.tag_top_noMsg:setVisible(false)
				self._rootnode.tag_top_hasMsg:setVisible(true)
				local nameStr = ""
				for i = 1, #coverInfo.names do
					if i > 1 then
						nameStr = nameStr .. ","
					end
					if i > 3 then
						nameStr = nameStr .. "... "
					else
						nameStr = nameStr .. tostring(coverInfo.names[i])
					end
				end
				self._rootnode.top_msg_1:setString(nameStr)
				arrangeTTFByPosX({
				self._rootnode.top_msg_1,
				self._rootnode.top_msg_2
				})
				self._rootnode.left_time_lbl:setString(format_time(coverInfo.time))
				local function checkTime()
					if coverInfo.time > 0 then
						coverInfo.time = coverInfo.time - 1
						self._rootnode.left_time_lbl:setString(format_time(coverInfo.time))
					end
					if coverInfo.time <= 0 then
						if self._checkSchedule ~= nil then
							self._scheduler.unscheduleGlobal(self._checkSchedule)
							self._checkSchedule = nil
						end
						RequestHelper.Guild.updateUnionLeader({
						callback = function(data)
							dump(data)
							if data.err ~= "" then
								dump(data.err)
							else
								local rtnObj = data.rtnObj
								if rtnObj.time ~= nil then
									coverInfo.time = rtnObj.time
									self._rootnode.left_time_lbl:setString(format_time(coverInfo.time))
									PostNotice(NoticeKey.GUILD_UPDATE_ZIJIAN)
								else
									guildMgr:setIsChangeCover(false)
									PostNotice(NoticeKey.GUILD_UPDATE_ZIJIAN)
								end
							end
						end
						})
					end
				end
				if self._checkSchedule ~= nil then
					self._scheduler.unscheduleGlobal(self._checkSchedule)
					self._checkSchedule = nil
				end
				self._checkSchedule = self._scheduler.scheduleGlobal(checkTime, 1, false)
			end
		end
	else
		self._rootnode.top_msg_node:setVisible(false)
		if self._checkSchedule ~= nil then
			self._scheduler.unscheduleGlobal(self._checkSchedule)
			self._checkSchedule = nil
		end
	end
end

function GuildMainScene:updateMsgDataLbl()
	local guildInfo = game.player:getGuildInfo()
	self._rootnode.guild_gold_lbl:setString(tostring(guildInfo.m_currentUnionMoney))
	self._rootnode.guild_contribute_lbl:setString(tostring(guildInfo.m_selfMoney))
end

function GuildMainScene:updateBuildLevel()
	local guildInfo = game.player:getGuildMgr():getGuildInfo()
	self._dadianLvLbl:setString("LV." .. tostring(guildInfo.m_level))
	self._zuofangLvLbl:setString("LV." .. tostring(guildInfo.m_workshoplevel))
	if data_feature_switch_config[1].ENABLE_GUILD_SHOP == true then
		self._shopLvLbl:setString("LV." .. tostring(guildInfo.m_shoplevel))
	end
	if data_feature_switch_config[1].ENABLE_QINGLONGTANG == true then
		self._qinglongLvLbl:setString("LV." .. tostring(guildInfo.m_greenDragonTempleLevel))
	end
	if data_feature_switch_config[1].ENABLE_GUILD_FUBEN == true then
		self._fubenLvLbl:setString("LV." .. tostring(guildInfo.m_fubenLevel))
	end
end

function GuildMainScene:regSelfNotice()
	RegNotice(self, function()
		self:checkCover()
	end,
	NoticeKey.GUILD_UPDATE_ZIJIAN)
	
	RegNotice(self, function()
		self:updateMsgDataLbl()
	end,
	NoticeKey.UPDATE_GUILD_MAINSCENE_MSG_DATA)
	
	RegNotice(self, function()
		self:updateBuildLevel()
	end,
	NoticeKey.UPDATE_GUILD_MAINSCENE_BUILD_LEVEL)
end

function GuildMainScene:unregSelfNotice()
	UnRegNotice(self, NoticeKey.GUILD_UPDATE_ZIJIAN)
	UnRegNotice(self, NoticeKey.UPDATE_GUILD_MAINSCENE_MSG_DATA)
	UnRegNotice(self, NoticeKey.UPDATE_GUILD_MAINSCENE_BUILD_LEVEL)
end

function GuildMainScene:onEnter()
	GuildMainScene.super.onEnter(self)
	game.runningScene = self
	GameAudio.playMainmenuMusic(true)
	self:regSelfNotice()
	PostNotice(NoticeKey.GUILD_UPDATE_ZIJIAN)
end

function GuildMainScene:onExit()
	GuildMainScene.super.onExit(self)
	self:unregSelfNotice()
	if self._checkSchedule ~= nil then
		self._scheduler.unscheduleGlobal(self._checkSchedule)
		self._checkSchedule = nil
	end
	display.removeSpriteFramesWithFile("ui/ui_weijiao_yishou.plist", "ui/ui_weijiao_yishou.png")
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return GuildMainScene