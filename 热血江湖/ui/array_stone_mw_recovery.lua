------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/array_stone_mw_info')
------------------------------------------------------
wnd_array_stone_mw_recovery = i3k_class("wnd_array_stone_mw_recovery",ui.wnd_array_stone_mw_info)

local ITEM = "ui/widgets/zfsmwhst"

function wnd_array_stone_mw_recovery:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.ok:onClick(self, self.onOk)
	widgets.ok2:onClick(self, self.onConfirm)
	widgets.jian:onClick(self, self.onCalculate, -1)
	widgets.jia:onClick(self, self.onCalculate, 1)
	widgets.ten:onClick(self, self.onCalculate, 10)
	widgets.max:onClick(self, self.onCalculate, math.huge)
	widgets.cancel:onClick(self, self.onCloseUI)
end

function wnd_array_stone_mw_recovery:refresh(id)
	self.id = id
	self.cfg = i3k_db_array_stone_cfg[id]
	local cfg = self.cfg
	local widgets = self._layout.vars
	widgets.low:setVisible(cfg.level == 1)
	widgets.high:setVisible(cfg.level ~= 1)
	widgets.num:setVisible(cfg.level == 1)
	self:setMiWenInfo()
	if cfg.level == 1 then
		self.have = g_i3k_game_context:getBagArrayStone()[self.id] or 0
		self.curNum = 1
		widgets.num:setText(i3k_get_string(18444, self.have))
		self:onCalculate(nil, 0)
	end
	self:updatetGetItems()
end

function wnd_array_stone_mw_recovery:updatetGetItems()
	local widgets = self._layout.vars
	widgets.scroll:removeAllChildren()
	if self.cfg.recycleEnergy ~= 0 then
		local energy = require(ITEM)()
		energy.vars.itemCount:setText("x"..self.cfg.recycleEnergy * (self.curNum or 1))
		local energyCfg = g_i3k_db.i3k_db_get_base_item_cfg(g_BASE_ITEM_STONE_ENERGY)
		local vars = energy.vars
		vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(g_BASE_ITEM_STONE_ENERGY))
		vars.itemIcon:setImage(g_i3k_db.i3k_db_get_icon_path(energyCfg.icon))
		vars.itemBtn:onClick(self, self.onItemTips, g_BASE_ITEM_STONE_ENERGY)
		vars.itemName:setText(g_i3k_db.i3k_db_get_base_item_cfg(g_BASE_ITEM_STONE_ENERGY).name)
		widgets.scroll:addItem(energy)
	end
	if self.cfg.recycleStoneId ~= 0 then
		local miwen = require(ITEM)()
		local vars = miwen.vars
		local id = self.cfg.recycleStoneId
		local stoneCfg = i3k_db_array_stone_cfg[id]
		vars.gradeIcon:setImage(g_i3k_db.g_i3k_get_icon_frame_path_by_rank(stoneCfg.rank))
		vars.itemCount:setText("x"..self.cfg.recycleStoneCount)
		vars.itemIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_array_stone_cfg[id].stoneIcon))
		vars.itemName:setText(self.cfg.name)
		widgets.scroll:addItem(miwen)
	end
end

function wnd_array_stone_mw_recovery:onOk(sender)
	if self.curNum ~= 0 then
		i3k_sbean.array_stone_ciphertext_destroy({[self.id] = self.curNum})
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18445))
	end
end

function wnd_array_stone_mw_recovery:onConfirm(sender)
	if self.cfg.level < i3k_db_array_stone_common.recoveryConfirmMinLvl then
		i3k_sbean.array_stone_ciphertext_destroy({[self.id] = 1})
	else
		g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneMWRecoveryConfirm)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneMWRecoveryConfirm, function()
			i3k_sbean.array_stone_ciphertext_destroy({[self.id] = 1})
		end)
	end
end

function wnd_array_stone_mw_recovery:onCalculate(sender, num)
	self.curNum = math.max(math.min(self.curNum + num, self.have), 0)
	self._layout.vars.curNum:setText(self.curNum)
	self:updatetGetItems()
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_array_stone_mw_recovery.new()
	wnd:create(layout,...)
	return wnd
end