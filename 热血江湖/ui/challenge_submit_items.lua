-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_challenge_submit_items = i3k_class("wnd_challenge_submit_items", ui.wnd_base)

local itemWidget = "ui/widgets/rchtjwpt"

function wnd_challenge_submit_items:ctor()
	self.groupId = 0
	self.index = 0
end

function wnd_challenge_submit_items:configure()
	self._layout.vars.submitBtn:onClick(self, self.onSubmitBtn)
	self._layout.vars.cancelBtn:onClick(self, self.onCloseUI)
end

function wnd_challenge_submit_items:refresh(groupId, index)
	self.groupId = groupId
	self.index = index
	self:setSubmitItemScroll()
end

function wnd_challenge_submit_items:setSubmitItemScroll()
	local cfg = i3k_db_challengeTask[self.groupId][self.index]
	if cfg then
		self._layout.vars.scroll:removeAllChildren()
		for k, v in ipairs(cfg.param2) do
			local node = require(itemWidget)()
			local id = v.id
			local count = v.count
			node.vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
			node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
			node.vars.bt:onClick(self, self.onItemTips, id)
			node.vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
			node.vars.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
			node.vars.item_count:setText(string.format("%s/%s", g_i3k_game_context:GetCommonItemCanUseCount(id), count))
			node.vars.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(id) >= count))
			self._layout.vars.scroll:addItem(node)
		end
	end
end

function wnd_challenge_submit_items:onSubmitBtn(sender)
	local cfg = i3k_db_challengeTask[self.groupId][self.index]
	for k, v in ipairs(cfg.param2) do
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(50098))
		end
	end
	i3k_sbean.chtask_give_items(self.groupId, self.index)
end

function wnd_challenge_submit_items:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_challenge_submit_items.new()
	wnd:create(layout)
	return wnd
end