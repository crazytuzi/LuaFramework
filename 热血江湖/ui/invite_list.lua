------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_invite_list = i3k_class("wnd_invite_list",ui.wnd_base)

local TAG_ALL = 1
local TAG_FRIEND = 2
local TAG_TEAM = 3
local TAG_FACTION = 4
local TAG_OTHER = 5

local ITEM = "ui/widgets/yaoqingxxt"

function wnd_invite_list:ctor()
	self._curTag = TAG_ALL
end

function wnd_invite_list:configure()
	local widget = self._layout.vars
	self.tagMap = {
		[TAG_ALL] = {btn = widget.allBtn, include = {g_INVITE_TYPE_FRIEND, g_INVITE_TYPE_TEAM, g_INVITE_TYPE_FACTION, g_INVITE_TYPE_SOLO, g_INVITE_TYPE_FACTION_HELP}},
		[TAG_FRIEND] = {btn = widget.friendBtn, include = {g_INVITE_TYPE_FRIEND}},
		[TAG_TEAM] = {btn = widget.teamBtn, include = {g_INVITE_TYPE_TEAM}},
		[TAG_FACTION] = {btn = widget.factionBtn, include = {g_INVITE_TYPE_FACTION, g_INVITE_TYPE_FACTION_HELP}},
		[TAG_OTHER] = {btn = widget.otherBtn, include = {g_INVITE_TYPE_SOLO}},
	}
	widget.close:onClick(self,self.onCloseUI)
	for k,v in pairs(self.tagMap) do
		v.btn:onClick(self, self.onTagClick, k)
	end
	widget.clear:onClick(self, self.onClearAll)
	widget.setting:onClick(self, self.onSettingClick)
end

function wnd_invite_list:refresh(inviteTag)
	local scroll = self._layout.vars.scroll
	self.curScrollProcess = scroll:getListPercent()
	if inviteTag == nil then
		self:onTagClick(nil, self._curTag)
	else
		local have, tag = false
		for i,v in ipairs(self.tagMap[self._curTag].include) do
			if v == inviteTag then
				have = true
				tag = i
				break
			end
		end
		if have then
			self:onTagClick(nil, self._curTag)
		end
	end
	scroll:jumpToListPercent(self.curScrollProcess)
end

function wnd_invite_list:onTagClick(sender, tag)
	self._curTag = tag
	for k,v in pairs(self.tagMap) do
		v.btn[k == tag and "stateToPressed" or "stateToNormal"](v.btn, false, true)
	end
	local data
	if self._curTag == TAG_ALL then
		data = g_i3k_game_context:getInviteList()
	else
		data = {}
		for i,v in ipairs(self.tagMap[self._curTag].include) do
			for ii,vv in ipairs(g_i3k_game_context:getInviteList(v)) do
				table.insert(data, vv)
			end
		end
		table.sort(data, function(a,b) return a.time > b.time end)
	end
	self:setScroll(data)
end

function wnd_invite_list:setScroll(list)
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	for i,v in ipairs(list) do
		local ui = require(ITEM)()
		local vars = ui.vars
		vars.desc:setText(v.desc)
		vars.yesTxt:setText(v.yesName)
		vars.noTxt:setText(v.noName)
		vars.yesBtn:onClick(nil, v.acceptFunc)
		vars.noBtn:onClick(nil, v.refuseFunc)
		vars.bg:setVisible(i % 2 == 0)
		scroll:addItem(ui)
	end
end

function wnd_invite_list:onClearAll(sender)
	for i,v in ipairs(self.tagMap[self._curTag].include) do
		g_i3k_game_context:clearInvites(v)
	end
	local list = g_i3k_game_context:getInviteList()
	if #list == 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_InviteEntrance)
		g_i3k_ui_mgr:CloseUI(eUIID_InviteList)
	else
		g_i3k_ui_mgr:RefreshUI(eUIID_InviteList)
	end
end

function wnd_invite_list:onSettingClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_InviteSetting)
	g_i3k_ui_mgr:RefreshUI(eUIID_InviteSetting)
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_invite_list.new()
	wnd:create(layout,...)
	return wnd
end