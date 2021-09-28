
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_baguaStoneSelect = i3k_class("wnd_baguaStoneSelect",ui.wnd_base)

local LAYER_BAGUAYUANSHIT = "ui/widgets/baguayuanshit"

function wnd_baguaStoneSelect:ctor()
	self._costID = nil  --需要打开的原石
	self._poolId = 0  --属性池id
end

function wnd_baguaStoneSelect:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.des:setText(i3k_get_string(17067))

	self.empty = widgets.empty
	self.scroll = widgets.scroll
	self.sureBtn = widgets.sureBtn
	self.sureBtn:onClick(self, self.onSureBtn)
end

function wnd_baguaStoneSelect:refresh(poolId)
	self._poolId = poolId

	self.scroll:removeAllChildren()
	local stone = g_i3k_game_context:GetAllItemsForType(UseItemBaguaStone)
	local items = g_i3k_db.i3k_db_sort_bag_items(stone)
	
	local myItems = {}
	for _, v in ipairs(items) do
		local id = v.id > 0 and v.id or -v.id
		myItems[id] = (myItems[id] or 0) + v.count
	end
	local result = {}
	for k, v in pairs(myItems) do
		table.insert(result, {id = k, count = v})
	end
	table.sort(result, function(a, b)
		local sortA = g_i3k_db.i3k_db_get_bag_item_order(a.id)
		local sortB = g_i3k_db.i3k_db_get_bag_item_order(b.id)
		return sortA < sortB
	end)

	self.empty:setText(i3k_get_string(17105))
	self.empty:setVisible(table.nums(result) == 0)

	for _, v in ipairs(result) do
		local ui = require(LAYER_BAGUAYUANSHIT)()
		ui.vars.id = v.id
		ui.vars.btn:onClick(self, function()
			g_i3k_ui_mgr:ShowCommonItemInfo(v.id)
		end)
		ui.vars.selectBtn:onClick(self, self.onSelectBtn, v.id)
		
		ui.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
		ui.vars.name:setText(g_i3k_db.i3k_db_get_common_item_name(v.id))
		ui.vars.name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.id)))
		ui.vars.desc:setText(i3k_db_bagua_stone[v.id].desc)
		ui.vars.count:setText("x" .. v.count)
		--ui.vars.suo:setVisible(v.id > 0)
		ui.vars.selectImg:hide()
		self.scroll:addItem(ui)
	end
end

function wnd_baguaStoneSelect:onSelectBtn(sender, id)
	for _, v in ipairs(self.scroll:getAllChildren()) do
		v.vars.selectImg:hide()
		if v.vars.id == id then
			v.vars.selectImg:show()
		end
	end
	self._costID = id
end

function wnd_baguaStoneSelect:onSureBtn(sender)
	if self._costID then
		i3k_sbean.request_eightdiagram_use_stonebag_req(self._poolId, self._costID)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17084))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_baguaStoneSelect.new()
	wnd:create(layout, ...)
	return wnd;
end

