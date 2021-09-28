module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_quickWeaponTaskConfirm = i3k_class("wnd_quickWeaponTaskConfirm", ui.wnd_base)
function wnd_quickWeaponTaskConfirm:ctor()

end

function wnd_quickWeaponTaskConfirm:configure()
	local vars = self._layout.vars
	vars.close:onClick(self, self.onCloseUI)
	vars.ok:onClick(self, self.onOkBtn)
	vars.go:onClick(self, self.onGoBtn)
	local cfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_SHENBING)
	self.cfg = cfg
	local txt = cfg.needItemCount.."个"..g_i3k_db.i3k_db_get_common_item_name(cfg.needItemId)
	vars.desc:setText(i3k_get_string(17499, cfg.needActivity, txt))
	vars.item:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.needItemId))
	vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(cfg.needItemId))
	vars.count:setText('x'..cfg.needItemCount)
end

function wnd_quickWeaponTaskConfirm:refresh(taskID, callback, taskType)
	self.taskID = taskID
	self.callback = callback
	self.taskType = taskType
end

function wnd_quickWeaponTaskConfirm:onOkBtn(sender)
	if self.taskType == g_QUICK_FINISH_FIVE_UNIQUE then
		local taskCfg = g_i3k_db.i3k_db_get_five_unique_task_cfg(self.taskID)
		local quickCfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_FIVE_UNIQUE)
		local isEnoughTable = {}
		local gifts = {}
		for i,v in ipairs(taskCfg.rewards) do
			if v.id ~= 0 then
				isEnoughTable[v.id] = v.count
				table.insert(gifts, v)
			end
		end
		local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
		if isEnough and g_i3k_game_context:GetCommonItemCanUseCount(quickCfg.needItemId) >= quickCfg.needItemCount then
			i3k_sbean.quick_finish_secrettask(self.taskID, gifts)
		elseif isEnough then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15072))
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1481))
		end
	else
	i3k_sbean.quick_finish_weapon_task(self.taskID)
	end
	self:onCloseUI()
end

function wnd_quickWeaponTaskConfirm:onGoBtn(sender)
	self.callback()
	self:onCloseUI()
end
----------------------------------------
function wnd_create(layout)
	local wnd = wnd_quickWeaponTaskConfirm.new();
		wnd:create(layout);
	return wnd;
end
