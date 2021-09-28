-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_homeLandCreate = i3k_class("wnd_homeLandCreate",ui.wnd_base)

function wnd_homeLandCreate:ctor()
	self._needItems = {}
	self._itemTable = {}
	self._nameLenLimit = i3k_db_common.inputlen.homelandNameLen or 0
end

function wnd_homeLandCreate:configure()
	local widgets = self._layout.vars

	self.input_label = widgets.input_label 
	self.input_label:setPlaceHolder(i3k_get_string(5150, 2, self._nameLenLimit))
	self.input_label:setMaxLength(self._nameLenLimit * 2)
	
	for i = 1, 2 do
		self._itemTable[i] = {
			root = widgets["itemRoot"..i],
			icon = widgets["itemIcon"..i],
			suo = widgets["suoIcon"..i],
			count = widgets["itemCount"..i],
			btn = widgets["createBtn"..i],
		}
		self._itemTable[i].btn:onClick(self, self["onItemCreate"..i])
	end


	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_homeLandCreate:refresh()
	self:laodNeedItems()
end

function wnd_homeLandCreate:laodNeedItems()
	local homeLandLvl = g_i3k_game_context:GetHomeLandLevel()
	local lvlCfg = i3k_db_home_land_lvl
	local needItems = lvlCfg[homeLandLvl + 1].needItems
	self._needItems = needItems
	for i, e in ipairs(needItems) do
		local id = needItems[i].itemID
		local count = needItems[i].itemCount
		local node = self._itemTable[i]
		node.root:setVisible(id ~= 0)
		node.btn:setVisible(id ~= 0)
		if id ~= 0 then
			node.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id))
			node.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(id))
			node.count:setText(count)
		end
	end
end

function wnd_homeLandCreate:onCreateCondition()
	local cfg = i3k_db_home_land_base.baseCfg
	if g_i3k_game_context:GetLevel() < cfg.openLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5072))
		return false
	end

	local name = self.input_label:getText()
	local error_code, desc = g_i3k_name_rule(name, self._nameLenLimit)
	if error_code ~= 1 then
		g_i3k_ui_mgr:PopupTipMessage(desc)
		return false
	end
	return true
end

-- 创建家园消耗非绑定铜钱 取家园登记表消耗道具第一个
function wnd_homeLandCreate:onItemCreate1(sender)
	if self:onCreateCondition() then
		local count = g_i3k_game_context:GetCommonItemCount(self._needItems[1].itemID)
		if g_i3k_game_context:GetCommonItemCount(self._needItems[1].itemID) < self._needItems[1].itemCount then
			return g_i3k_ui_mgr:PopupTipMessage("创建失败，铜钱不足")
		end
		local name = self.input_label:getText()
		i3k_sbean.homeland_create(name, self._needItems[1])
	end
end

-- 如果消耗第二个，二选一消耗元宝 取家园登记表消耗道具第二个
function wnd_homeLandCreate:onItemCreate2(sender)
	if self:onCreateCondition() then
		if g_i3k_game_context:GetCommonItemCount(self._needItems[2].itemID) < self._needItems[2].itemCount then
			return g_i3k_ui_mgr:PopupTipMessage("创建失败，元宝不足")
		end
		local name = self.input_label:getText()
		i3k_sbean.homeland_create(name, self._needItems[2])
	end
end

function wnd_create(layout)
	local wnd = wnd_homeLandCreate.new()
	wnd:create(layout)
	return wnd
end
