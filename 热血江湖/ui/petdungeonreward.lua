module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_petDungeonReward = i3k_class("wnd_petDungeonReward", ui.wnd_base)
local REWARDITEM = "ui/widgets/chongwushiliansyt"

function wnd_petDungeonReward:ctor()

end

function wnd_petDungeonReward:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_petDungeonReward:refresh()
	local weight = self._layout.vars
	local scoll = weight.scroll
	local info = g_i3k_game_context:getPetDungeonInfo()
	local rewards = {}
	
	for k, v in pairs(info.dayReward) do
		if g_i3k_db.i3k_db_get_common_item_type(k) ~= g_COMMON_ITEM_TYPE_BASE then
			local cfg = g_i3k_db.i3k_db_get_common_item_cfg(k)
			local value = cfg.sortid
			cfg.sortid = value == nil and 0 or value
			cfg.id = k
			table.insert(rewards, cfg)
		end
	end
	
	table.sort(rewards, function (a,b)
		return a.sortid < b.sortid
	end)

	local items = scoll:addChildWithCount(REWARDITEM, 7, #rewards, true)
		
	for k, v in ipairs(items) do
		local node = v.vars
		local cfg = rewards[k]
		
		if cfg.id then
			node.selectBtn:onClick(self, self.onItemTip, cfg.id)			
			node.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(cfg.id))
			node.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.id, g_i3k_game_context:IsFemaleRole()))
			node.count:setText("x" .. info.dayReward[cfg.id])
			node.suo:setVisible(cfg.id > 0)
		end
	end
end

function wnd_petDungeonReward:onItemTip(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_create(layout)
	local wnd = wnd_petDungeonReward.new();
	wnd:create(layout);
	return wnd;
end
