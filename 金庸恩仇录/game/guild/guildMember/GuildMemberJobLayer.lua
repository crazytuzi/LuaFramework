require("data.data_error_error")
local data_ui_ui = require("data.data_ui_ui")
local MAX_ZORDER = 100
local kParentScene
local FRIEND_TYPE = {
friend = 0,
notApply = 1,
hasApply = 2
}

local GuildMemberJobLayer = class("GuildMemberJobLayer", function()
	return require("utility.ShadeLayer").new()
end)

local exitUnion = function(msgBox)
	RequestHelper.Guild.exitUnion({
	uid = game.player:getGuildMgr():getGuildInfo().m_id,
	errback = function(data)
		msgBox:setBtnEnabled(true)
	end,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
			msgBox:setBtnEnabled(true)
		else
			local rtnObj = data.rtnObj
			if rtnObj.success == 0 then
				GameStateManager:ChangeState(GAME_STATE.STATE_GUILD)
			else
				msgBox:setBtnEnabled(true)
			end
		end
	end
	})
end

local function kickRole(roleId, msgBox)
	RequestHelper.Guild.kcikRole({
	appRoleId = roleId,
	errback = function(data)
		msgBox:setBtnEnabled(true)
	end,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
			msgBox:setBtnEnabled(true)
		else
			local rtnObj = data.rtnObj
			if rtnObj.success == 0 then
				if kParentScene ~= nil then
					local index = kParentScene:removeItemFromNormalList(roleId)
					kParentScene:forceReloadNormalListView(index - 1)
					msgBox:removeFromParentAndCleanup(true)
				end
			else
				msgBox:setBtnEnabled(true)
			end
		end
	end
	})
end

function GuildMemberJobLayer:setPosition(roleId, jopType)
	RequestHelper.Guild.setPosition({
	appRoleId = roleId,
	jopType = jopType,
	errback = function(data)
		self:setBtnEnabled(true)
	end,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
			self:setBtnEnabled(true)
		else
			local rtnObj = data.rtnObj
			if rtnObj.success == 0 then
				self._itemData.jopType = jopType
				if kParentScene ~= nil then
					kParentScene:forceReloadNormalListView(0)
					self:removeFromParentAndCleanup(true)
				end
			else
				self:setBtnEnabled(true)
			end
		end
	end
	})
end

function GuildMemberJobLayer:reqAddFriend(param)
	local box = param.box
	RequestHelper.friend.applyFriend({
	content = param.content,
	account = param.roleAcc,
	errback = function()
		self:setBtnEnabled(true)
	end,
	callback = function(data)
		self:setBtnEnabled(true)
		box:removeFromParentAndCleanup()
		local result = data.rtnObj.result
		if result == 1 then
			ResMgr.showErr(3200115)
			self._itemData.isFriend = FRIEND_TYPE.hasApply
		elseif result == 2 then
			ResMgr.showErr(2900018)
			self._itemData.isFriend = FRIEND_TYPE.hasApply
		end
	end
	})
end

function GuildMemberJobLayer:ctor(param)
	local title = param.title
	self._itemData = param.itemData
	kParentScene = param.parentScene
	local guildMgr = game.player:getGuildMgr()
	local jopType = guildMgr:getGuildInfo().m_jopType
	local fileName
	if self._itemData.isSelf == true then
		fileName = "ccbi/guild/guild_job_self.ccbi"
	elseif jopType == GUILD_JOB_TYPE.leader then
		fileName = "ccbi/guild/guild_job_another_leader.ccbi"
	elseif jopType == GUILD_JOB_TYPE.assistant and self._itemData.jopType == GUILD_JOB_TYPE.normal then
		fileName = "ccbi/guild/guild_job_another_assistant.ccbi"
	else
		fileName = "ccbi/guild/guild_job_another_normal.ccbi"
	end
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad(fileName, proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.titleLabel:setString(title)
	
	local function closeFunc()
		self:removeSelf()
	end
	
	self._rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	if self._itemData.isSelf == false and jopType == GUILD_JOB_TYPE.leader then
		if self._itemData.jopType == GUILD_JOB_TYPE.assistant then
			self._rootnode.set_assistant_btn:setVisible(false)
			self._rootnode.cancel_assistant_btn:setVisible(true)
		end
		if self._itemData.jopType == GUILD_JOB_TYPE.elder then
			self._rootnode.set_elder_btn:setVisible(false)
			self._rootnode.cancel_elder_btn:setVisible(true)
		end
	end
	if self._itemData.isSelf == false then
		if self._itemData.isFriend == FRIEND_TYPE.friend then
			self._rootnode.hasAdded_icon:setVisible(true)
			self._rootnode.addFriend_btn:setVisible(false)
		else
			self._rootnode.hasAdded_icon:setVisible(false)
			self._rootnode.addFriend_btn:setVisible(true)
		end
	end
	self._btnTags = {
	"battle_btn",
	"chat_btn",
	"addFriend_btn",
	"set_assistant_btn",
	"cancel_assistant_btn",
	"set_elder_btn",
	"cancel_elder_btn",
	"kick_btn",
	"exit_btn"
	}
	if self._rootnode.battle_btn ~= nil then
		if game.player:getAppOpenData().b_qiecuo == APPOPEN_STATE.close then
			self._rootnode.battle_btn:setVisible(false)
		else
			self._rootnode.battle_btn:setVisible(true)
		end
	end
	if self._rootnode.chat_btn ~= nil then
		if game.player:getAppOpenData().b_siliao == APPOPEN_STATE.close then
			self._rootnode.chat_btn:setVisible(false)
		else
			self._rootnode.chat_btn:setVisible(true)
		end
	end
	self:registerBtnEvent()
end

function GuildMemberJobLayer:setBtnEnabled(bEnabled)
	for i, v in ipairs(self._btnTags) do
		if self._rootnode[v] ~= nil then
			self._rootnode[v]:setEnabled(bEnabled)
		end
	end
end

function GuildMemberJobLayer:registerBtnEvent()
	local function onTouchBtn(tag)
		self:setBtnEnabled(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if tag == self._btnTags[1] then
			show_tip_label(common:getLanguageString("@OpenSoon"))
			self:setBtnEnabled(true)
		elseif tag == self._btnTags[2] then
			show_tip_label(common:getLanguageString("@OpenSoon"))
			self:setBtnEnabled(true)
		elseif tag == self._btnTags[3] then
			if self._itemData.isFriend == FRIEND_TYPE.hasApply then
				ResMgr.showErr(2900018)
				self:setBtnEnabled(true)
			elseif self._itemData.isFriend ~= FRIEND_TYPE.friend then
				local applyBox = require("game.Friend.FriendApplyBox").new({
				confirmFunc = function(box, content)
					self:reqAddFriend({
					box = box,
					roleAcc = self._itemData.roleAcc,
					content = content
					})
				end,
				cancelFunc = function()
					self:setBtnEnabled(true)
				end
				})
				game.runningScene:addChild(applyBox, MAX_ZORDER)
			end
		elseif tag == self._btnTags[4] then
			self:setPosition(self._itemData.roleId, GUILD_JOB_TYPE.assistant)
		elseif tag == self._btnTags[5] then
			self:setPosition(self._itemData.roleId, GUILD_JOB_TYPE.normal)
		elseif tag == self._btnTags[6] then
			self:setPosition(self._itemData.roleId, GUILD_JOB_TYPE.elder)
		elseif tag == self._btnTags[7] then
			self:setPosition(self._itemData.roleId, GUILD_JOB_TYPE.normal)
		elseif tag == self._btnTags[8] then
			do
				local content = common:getLanguageString("@GuildKickout1") .. tostring(self._itemData.roleName) .. common:getLanguageString("@GuildKickout2")
				local roleId = self._itemData.roleId
				game.runningScene:addChild(require("game.guild.utility.GuildNormalMsgBox").new({
				title = common:getLanguageString("@Hint"),
				msg = content,
				isSingleBtn = false,
				confirmFunc = function(msgBox)
					kickRole(roleId, msgBox)
				end
				}), MAX_ZORDER)
				self:removeFromParentAndCleanup(true)
			end
		elseif tag == self._btnTags[9] then
			game.runningScene:addChild(require("game.guild.utility.GuildNormalMsgBox").new({
			title = common:getLanguageString("@Hint"),
			msg = data_ui_ui[7].content,
			isSingleBtn = false,
			confirmFunc = function(msgBox)
				exitUnion(msgBox)
			end
			}), MAX_ZORDER)
			self:removeSelf()
		end
	end
	for i, v in ipairs(self._btnTags) do
		if self._rootnode[v] ~= nil then
			self._rootnode[v]:addHandleOfControlEvent(function(sender, eventName)
				onTouchBtn(v)
			end,
			CCControlEventTouchUpInside)
		end
	end
end

return GuildMemberJobLayer