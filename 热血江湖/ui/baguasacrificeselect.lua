
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_baguaSacrificeSelect = i3k_class("wnd_baguaSacrificeSelect",ui.wnd_base)

local LAYER_BAGUAJIPINT = "ui/widgets/baguajipint"

function wnd_baguaSacrificeSelect:ctor()
	self._costID = nil  --需要添加的祭品
end

function wnd_baguaSacrificeSelect:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)

	widgets.des:setText(i3k_get_string(17104))

	self.empty = widgets.empty
	self.scroll = widgets.scroll
	self.sureBtn = widgets.sureBtn
	self.sureBtn:onClick(self, self.onSureBtn)
end

function wnd_baguaSacrificeSelect:refresh(partID)
	self.scroll:removeAllChildren()
	local sacrifice = g_i3k_game_context:GetAllItemsForType(UseItemBaguaSacrifice)
	local items = g_i3k_db.i3k_db_sort_bag_items(sacrifice)

	for _, v in ipairs(items) do
		local cfg = g_i3k_db.i3k_db_get_common_item_cfg(v.id)
		if cfg and (cfg.args1 == partID or cfg.args1 == -1) then  --根据部位筛选可用祭品
			local ui = require(LAYER_BAGUAJIPINT)()
			ui.vars.id = v.id
			ui.vars.selectBtn:onClick(self, self.onSelectBtn, v.id)
			
			ui.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			ui.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
			ui.vars.name:setText(g_i3k_db.i3k_db_get_common_item_name(v.id))
			ui.vars.desc:setText(g_i3k_db.i3k_db_get_common_item_desc(v.id))
			ui.vars.count:setText("x" .. v.count)
			ui.vars.suo:setVisible(v.id > 0)
			ui.vars.selectImg:hide()
			self.scroll:addItem(ui)
		end
	end

	self.empty:setText(i3k_get_string(17103))
	self.empty:setVisible(table.nums(self.scroll:getAllChildren()) == 0)
end

function wnd_baguaSacrificeSelect:onSelectBtn(sender, id)
	for _, v in ipairs(self.scroll:getAllChildren()) do
		v.vars.selectImg:hide()
		if v.vars.id == id then
			v.vars.selectImg:show()
		end
	end
	self._costID = id
end

function wnd_baguaSacrificeSelect:onSureBtn(sender)
	if self._costID then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua,"choseSacrifice",self._costID)
		--传递祭品Id给八卦界面
		g_i3k_ui_mgr:CloseUI(eUIID_BaguaSacrificeSelect)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17083))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_baguaSacrificeSelect.new()
	wnd:create(layout, ...)
	return wnd;
end

