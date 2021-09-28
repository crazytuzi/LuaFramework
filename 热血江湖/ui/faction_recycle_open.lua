-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_recycle_open = i3k_class("wnd_faction_recycle_open", ui.wnd_base)

local FUN_1_CONSUME = i3k_db_recycle_open_consume.fun_open_1
local FUN_2_CONSUME = i3k_db_recycle_open_consume.fun_open_2

local tb_img = {}
local tb_count = {}
local tb_suo = {}
local tb_icon = {}
local tb_btn = {}

local OPEN_FUN_1 = 1
local OPEN_FUN_2 = 2

function wnd_faction_recycle_open:ctor()
	
end

function wnd_faction_recycle_open:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)

	tb_img = {self._layout.vars.img_1, self._layout.vars.img_2, self._layout.vars.img_3, self._layout.vars.img_4}
	tb_count = {self._layout.vars.count_1, self._layout.vars.count_2, self._layout.vars.count_3, self._layout.vars.count_4}
	tb_suo = {self._layout.vars.suo_1, self._layout.vars.suo_2, self._layout.vars.suo_3, self._layout.vars.suo_4}
	tb_icon = {self._layout.vars.icon_1, self._layout.vars.icon_2, self._layout.vars.icon_3, self._layout.vars.icon_4}
	tb_btn = {self._layout.vars.btn_1, self._layout.vars.btn_2, self._layout.vars.btn_3, self._layout.vars.btn_4}

	for i = 1, 2 do
		if FUN_1_CONSUME[i] then
			local item = FUN_1_CONSUME[i]
			local img = g_i3k_db.i3k_db_get_common_item_icon_path(item.id,i3k_game_context:IsFemaleRole())
			tb_img[i]:setImage(img)
			tb_count[i]:setText(item.count)
			tb_count[i]:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(item.id) >= item.count))
			tb_suo[i]:setVisible(item.id > 0)
			tb_icon[i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.id))
			tb_icon[i]:setVisible(true)
			tb_btn[i]:onClick(self, self.showItemInfo, item.id)
		end
	end

	for i = 3, 4 do
		if FUN_2_CONSUME[i - 2] then
			local item = FUN_2_CONSUME[i - 2]
			local img = g_i3k_db.i3k_db_get_common_item_icon_path(item.id,i3k_game_context:IsFemaleRole())
			tb_img[i]:setImage(img)
			tb_count[i]:setText(item.count)
			tb_count[i]:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(item.id) >= item.count))
			tb_suo[i]:setVisible(item.id > 0)
			tb_icon[i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.id))
			tb_icon[i]:setVisible(true)
			tb_btn[i]:onClick(self, self.showItemInfo, item.id)
		end
	end
	self._layout.vars.open_btn_1:onClick(self, self.openRecycle, OPEN_FUN_1)
	self._layout.vars.open_btn_2:onClick(self, self.openRecycle, OPEN_FUN_2)

	self._layout.vars.content:setText(i3k_get_string(15511))
end

function wnd_faction_recycle_open:refresh()
	
end

function wnd_faction_recycle_open:openRecycle(sender, openType)
	if openType == OPEN_FUN_1 then
		i3k_sbean.produce_fusion_open(openType, FUN_1_CONSUME)
	elseif openType == OPEN_FUN_2 then
		i3k_sbean.produce_fusion_open(openType, FUN_2_CONSUME)
	end
end

function wnd_faction_recycle_open:showItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_faction_recycle_open:refreshItemCount()
	for i = 1, 2 do
		if FUN_1_CONSUME[i] then
			local item = FUN_1_CONSUME[i]
			tb_count[i]:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(item.id) >= item.count))
		end
	end
	for i = 3, 4 do
		if FUN_2_CONSUME[i - 2] then
			local item = FUN_2_CONSUME[i - 2]
			tb_count[i]:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(item.id) >= item.count))
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_faction_recycle_open.new();
	wnd:create(layout);
	return wnd;
end