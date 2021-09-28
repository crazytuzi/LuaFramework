-------------------------------------------------------
module(..., package.seeall)

local require = require;
--require("ui/ui_funcs")
local ui = require("ui/dialogue_base");

-------------------------------------------------------
wnd_dialogue1 = i3k_class("wnd_dialogue1", ui.wnd_dialogue_base)
local Call_Back = nil

function wnd_dialogue1:ctor()
	self._list_desc = {}
	--self._callBack = nil
	self._actionList = nil
	self._task_type = 0
	self.petID = nil
	self.taskID = nil
	self.arg1 = nil
	self.arg2 = nil
end
function wnd_dialogue1:configure()
	self._layout.vars.close_btn:onClick(self,self.onClose)
	self.dialogue = self._layout.vars.dialogue
end

function wnd_dialogue1:refresh(list_desc,motable,fun,task_type, petID, taskID, arg1, arg2, actionList)
	self._list_desc = list_desc
	self._moduleTab = motable
	self._actionList = actionList
	Call_Back = fun
	self.petID = petID
	self.taskID = taskID
	self.arg1 = arg1
	self.arg2 = arg2
	self._index = 1
	self._task_type = task_type or 0
	self:updateDesc1(self._index)
	self.leftModule = self._moduleTab[self._index]
	self:updateModule1(self._moduleTab[self._index])
	g_i3k_ui_mgr:CloseUI(eUIID_SnapShot)
	g_i3k_ui_mgr:CloseUI(eUIID_Task)
end

function wnd_dialogue1:playerLead(desc, id)
    self._index = 1
    self.dialogue:setText(desc)
	self._playerLeadID = id
end

function wnd_dialogue1:updateDesc1(index)
	self.dialogue:setText(self._list_desc[index].txt)
end

--初始化模型
function wnd_dialogue1:updateModule1(id)
	local npcmodule = self._layout.vars.leftModule
	-- if self._index%2 == 0 then
	-- 	self._layout.vars.rightModule:show()
	-- 	self._layout.vars.leftModule:hide()
	-- 	npcmodule = self._layout.vars.rightModule
	-- else
	-- 	self._layout.vars.rightModule:hide()
	-- 	self._layout.vars.leftModule:show()
	-- 	npcmodule = self._layout.vars.leftModule
	-- end
	if self.leftModule == self._moduleTab[self._index] then
		self._layout.vars.rightModule:hide()
		self._layout.vars.leftModule:show()
	else
		self._layout.vars.rightModule:show()
		self._layout.vars.leftModule:hide()
		npcmodule = self._layout.vars.rightModule
	end
	self:updateModule(id,npcmodule)
	if self._actionList then
		npcmodule:pushActionList(self._actionList[self._index], 1)
		npcmodule:pushActionList("stand", -1)
	end
end

function wnd_dialogue1:onClose(sender)
	if self._task_type == TASK_CATEGORY_SECT then
		if self._index + 1 > #self._list_desc then
			g_i3k_ui_mgr:CloseUI(eUIID_Dialogue1)
			if Call_Back then
				Call_Back(TASK_CATEGORY_LIFE, self.taskID, self.petID)
			end
		else
			self._index = self._index + 1
			self:updateDesc1(self._index)
			self:updateModule1(self._moduleTab[self._index])
		end
	else
		if self._index + 1 >= #self._list_desc then
            if g_i3k_game_context:isOnSprog() then
                i3k_game_resume()
                g_i3k_game_handler:ResumeAllEntities()
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_PlayerLead, "closeDialogue1Callback", self._playerLeadID)
            end
			g_i3k_ui_mgr:CloseUI(eUIID_Dialogue1)
			if Call_Back then
				Call_Back(TASK_CATEGORY_LIFE, self.arg1, self.arg2, self.taskID, self.petID)
			end
		else
			self._index = self._index + 1
			self:updateDesc1(self._index)
			self:updateModule1(self._moduleTab[self._index])
		end
	end

end

function wnd_dialogue1:joyTodoMainTask()
	self._layout.vars.close_btn:sendClick()
end

function wnd_dialogue1:onShow()
	i3k_onJoy_ChangeTaskUIID(self.__uiid)
	Call_Back = nil
	g_i3k_logic:ShowBattleUI(false)
end

function wnd_dialogue1:onHide()
	i3k_onJoy_ChangeTaskUIID(eUIID_BattleTask)
	g_i3k_logic:ShowBattleUI(true)
end

function wnd_create(layout, ...)
	local wnd = wnd_dialogue1.new();
		wnd:create(layout, ...);
	return wnd;
end
