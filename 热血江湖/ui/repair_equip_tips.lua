-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_repair_equip_tips = i3k_class("wnd_repair_equip_tips", ui.wnd_base)


local LegendsTab = {i3k_db_equips_legends_1, i3k_db_equips_legends_2, i3k_db_equips_legends_3}
function wnd_repair_equip_tips:ctor()
	self._partID = nil
	self._count = nil
end

function wnd_repair_equip_tips:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	--self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	widgets.repair_btn:onClick(self, self.onRepairBtn)
	widgets.findNpcBtn:onClick(self, self.onFindNpcBtn)
	self.cancel_lable = widgets.cancel_lable
	self.count = widgets.count
	self.now_value = widgets.now_value
	self._layout.vars.icon1:hide()
	self._layout.vars.icon2:hide()
	self._layout.vars.icon3:hide()
end

function wnd_repair_equip_tips:refresh(partId, legends)
	local tab = {}
	for i,e in ipairs(legends) do
		if e~=0 then
			table.insert(tab, {i = i, e = e})
		end
	end
	for i,e in ipairs(tab) do
		local cfg = LegendsTab[e.i]
		local nCfg
		if e.i == 3 then
			nCfg = cfg[partId][e.e]
		else
			nCfg = cfg[e.e]
		end
		self._layout.vars["icon"..i]:show()
		self._layout.vars["icon"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(nCfg.icon))
		self._layout.vars["lab"..i]:setText(nCfg.tips)
	end
	self._partID = partId
	self._count = #tab
	local monty, naijiu, MaxVlaue = g_i3k_game_context:GetEquipRepairNeedMoney(partId, #tab)
	self.count:setText(monty)
	self.now_value:setText("当前耐久度："..math.modf(naijiu/1000).."/"..math.modf(MaxVlaue/1000))
	if math.modf(naijiu/1000) == math.modf(MaxVlaue/1000) then
		self._layout.vars.repair_btn:disableWithChildren()
	else
		self._layout.vars.repair_btn:enableWithChildren()
	end
	self.cancel_lable:setText(i3k_get_string(1836))
end

--[[function wnd_repair_equip_tips:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RepairEquipTips)
end--]]

function wnd_repair_equip_tips:onRepairBtn(sender)
	if g_i3k_game_context:GetMoneyCanUse(true) >= g_i3k_game_context:GetEquipRepairNeedMoney(self._partID, self._count) then
		i3k_sbean.equip_repair(self._partID)
		g_i3k_ui_mgr:CloseUI(eUIID_RepairEquipTips)
	else
		g_i3k_ui_mgr:PopupTipMessage("铜钱不足，无法修理")
	end
end

function wnd_repair_equip_tips:onFindNpcBtn(sender)
	local callback = function (isOk)
		if isOk then
			local npcs = g_i3k_db.i3k_db_get_npcs_id_by_funcId(TASK_FUNCTION_LEGEND)
			g_i3k_game_context:GotoNpc(npcs[1])
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_RepairEquipTips, "onCloseUI")
		end
	end
	g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(1836), i3k_get_string(18056), i3k_get_string(1829), callback)
end
function wnd_create(layout)
	local wnd = wnd_repair_equip_tips.new()
		wnd:create(layout)
	return wnd
end

