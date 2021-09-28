module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_mazeBattleBenifit = i3k_class("wnd_mazeBattleBenifit", ui.wnd_base)

local ACT_BENIFIT = 1
local EXTRA_BENIFIT = 2

local SY_WIDGETS = "ui/widgets/tianmomigongsyt"
local RowitemCount = 7

function wnd_mazeBattleBenifit:ctor()
end

function wnd_mazeBattleBenifit:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	end

function wnd_mazeBattleBenifit:refresh(items)
	self:refreshTies()
	self:onUpdateScroll(items)
end

function wnd_mazeBattleBenifit:refreshTies()
	local all = g_i3k_db.i3k_db_get_maze_can_defeat(g_i3k_game_context:GetWorldMapID())
	self._layout.vars.tipsTxt:setText(i3k_get_string(17758,  g_i3k_game_context:getBattleMazekillTimes(), all))
end

function wnd_mazeBattleBenifit:onUpdateScroll(items)
	local widgets = self._layout.vars
	widgets.scroll:removeAllChildren()
	local rewards = {}
	for k,v in pairs(items) do
		if g_i3k_db.i3k_db_get_common_item_type(k) ~= g_COMMON_ITEM_TYPE_BASE then
			table.insert(rewards, {id = k, count = v})
		end
	end
	
	local all_layer = widgets.scroll:addChildWithCount(SY_WIDGETS, RowitemCount, #rewards)
	
	for k, v in ipairs(rewards) do
		local widgets = all_layer[k].vars
		self:updateCell(widgets, v.id, v.count)
	end
end

function wnd_mazeBattleBenifit:updateCell(node, id , count)
	node.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	node.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	node.selectBtn:onClick(self, function()
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
	end)
	node.suo:setVisible(id > 0)
	node.count:setText("x" .. count)

end



function wnd_create(layout, ...)
	local wnd = wnd_mazeBattleBenifit.new()
	wnd:create(layout, ...)
	return wnd
end