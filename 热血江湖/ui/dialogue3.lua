-------------------------------------------------------
module(..., package.seeall)

local require = require;
--require("ui/ui_funcs")
local ui = require("ui/dialogue_base");

-------------------------------------------------------
wnd_dialogue3 = i3k_class("wnd_dialogue3", ui.wnd_dialogue_base)

function wnd_dialogue3:ctor()
	self._root = {}
end

function wnd_dialogue3:configure()
	local ensure_btn = self._layout.vars.ensure_btn
	ensure_btn:onClick(self,self.onEnsureTask)
--[[	local ensure_lable = self._layout.vars.ensure_lable
	ensure_lable:setText("接取任务")--]]
	self.dialogue = self._layout.vars.dialogue
	self.taskDesc = self._layout.vars.taskDesc
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

function wnd_dialogue3:refresh(list_desc,items,tagDesc,moduleId,func, category, taskID)
	self._callBack = func
	self.taskID = taskID
	if moduleId then
		self:updateModule(moduleId)
	end
	self.taskDesc:setText(tagDesc)
	self:updateDesc(list_desc,items)
	g_i3k_ui_mgr:CloseUI(eUIID_SnapShot)
end

function wnd_dialogue3:onEnsureTask(sender,eventType)
	i3k_game_set_click_pos()
	if self.taskID then
		local cfg = g_i3k_db.i3k_db_get_main_task_cfg(self.taskID)
		if cfg.finishTaskNpcBubbleID then
			local world = i3k_game_get_world()
			local npc = world:GetNPCEntityByID(cfg.getTaskNpcID)
			if npc then
				g_i3k_ui_mgr:PopTextBubble(true, npc, i3k_db_dialogue[cfg.getTaskNpcBubbleID][1].txt)
			end
		end
	end
	if self._callBack then
		self._callBack()
	end
	g_i3k_ui_mgr:CloseUI(eUIID_Dialogue3)
end

function wnd_dialogue3:joyTodoMainTask()
	self._layout.vars.ensure_btn:sendClick()
end

function wnd_dialogue3:onShow()
	i3k_onJoy_ChangeTaskUIID(self.__uiid)
	g_i3k_logic:ShowBattleUI(false)
end

function wnd_dialogue3:onHide()
	i3k_onJoy_ChangeTaskUIID(eUIID_BattleTask)
	g_i3k_logic:ShowBattleUI(true)
end

function wnd_create(layout, ...)
	local wnd = wnd_dialogue3.new();
		wnd:create(layout, ...);

	return wnd;
end
