-------------------------------------------------------
module(..., package.seeall)

local require = require;
--require("ui/ui_funcs")
local ui = require("ui/dialogue_base");

-------------------------------------------------------
wnd_dialogue4 = i3k_class("wnd_dialogue4", ui.wnd_dialogue_base)

function wnd_dialogue4:ctor()
	self._list_desc = {}
	self._callBack = nil
	self._is_enough = true
	self._root = {}
	self.petID = nil
	self.taskID = nil
	self.arg1 = nil
	self.arg2 = nil
end

function wnd_dialogue4:configure(...)
	self._dialogue = self._layout.vars.dialogue
	local ensure_btn = self._layout.vars.ensure_btn
	ensure_btn:onClick(self,self.onFinishTask)

	self.taskTips = self._layout.vars.taskTips
	self.taskTips:hide()

	for i=1,4 do
		local tmp_root = string.format("item%sRoot",i)
		local itemRoot = self._layout.vars[tmp_root]
		local tmp_icon = string.format("item%s_icon",i)
		local item_icon = self._layout.vars[tmp_icon]
		local tmp_count = string.format("item%s_count",i)
		local item_count = self._layout.vars[tmp_count]
		local suo = self._layout.vars[string.format("suo%s",i)]
		itemRoot:hide()
		self._root[i] = {itemRoot = itemRoot,item_icon = item_icon,item_count = item_count, suo = suo}
	end
end

function wnd_dialogue4:refresh(list_desc,fun,is_enough,items,moduleId, petID, taskID, arg1, arg2, category)
	self._callBack = fun
	self._is_enough = is_enough
	self.petID = petID
	self.taskID = taskID
	self.arg1 = arg1
	self.arg2 = arg2
	if not self._is_enough then
		self.taskTips:show()
	end
	self:updateDesc(list_desc,items)
	if moduleId then
		self:updateModule(moduleId)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_SnapShot)
	g_i3k_ui_mgr:CloseUI(eUIID_Task)
end

function wnd_dialogue4:onFinishTask(sender)
	i3k_game_set_click_pos()
	if not self._is_enough then
		g_i3k_ui_mgr:PopupTipMessage("背包已满无法完成任务")
	end
	if self._is_enough and self._callBack then
		if self.taskID then
			local cfg = g_i3k_db.i3k_db_get_main_task_cfg(self.taskID)
			if cfg.finishTaskNpcBubbleID then
				local world = i3k_game_get_world()
				local npc = world:GetNPCEntityByID(cfg.finishTaskNpcID)
				if npc then
					g_i3k_ui_mgr:PopTextBubble(true, npc, i3k_db_dialogue[cfg.finishTaskNpcBubbleID][1].txt)
				end
			end
		end
		self._callBack(TASK_CATEGORY_LIFE, self.arg1, self.arg2, self.taskID, self.petID)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_Dialogue4)
end

function wnd_dialogue4:joyTodoMainTask()
	self._layout.vars.ensure_btn:sendClick()
end

function wnd_dialogue4:onShow()
	i3k_onJoy_ChangeTaskUIID(self.__uiid)
	g_i3k_logic:ShowBattleUI(false)
end

function wnd_dialogue4:onHide()
	i3k_onJoy_ChangeTaskUIID(eUIID_BattleTask)
	g_i3k_logic:ShowBattleUI(true)
end

function wnd_create(layout, ...)
	local wnd = wnd_dialogue4.new();
		wnd:create(layout, ...);
	return wnd;
end
