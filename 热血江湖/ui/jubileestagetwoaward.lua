--[[
        @Date    : 2019-02-19
        @Author  : zhangbing
        @layout  : zhounianqingjl2
    	@UIID	 : eUIID_JubileeStageTwoAward
--]]
module(..., package.seeall)

local require = require;

local ui = require("ui/jubileeBase");
---------------------------------------------------------------

wnd_jubileeStageTwoAward = i3k_class("wnd_jubileeStageTwoAward", ui.jubileeBase)

function wnd_jubileeStageTwoAward:ctor()
	self._taskGroup = 0 --当前选中的任务idx
end

function wnd_jubileeStageTwoAward:configure()
	local widgets = self._layout.vars
	self._widgets = {}
	widgets.receiveTaskBtn:onClick(self, self.onReceiveTask)
	widgets.receiveAwardBtn:onClick(self, self.onReceiveAward)
	self:initTaskWidgets(widgets)
	widgets.condition:setText(i3k_get_string(17931))
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_jubileeStageTwoAward:initTaskWidgets(widgets)
	self._widgets.taskWidgets = {}
	local taskNamesCfg = i3k_db_jubilee_base.stage2.taskNames
	for i = 1, 3 do
		local btn = widgets["task"..i.."Btn"]
		local icon = widgets["selectIcon"..i]
		icon:hide()
		widgets["taksName"..i]:setText(i3k_get_string(taskNamesCfg[i]))
		table.insert(self._widgets.taskWidgets, {btn = btn, icon = icon})
	end

	for i, e in ipairs(self._widgets.taskWidgets) do
		e.btn:onClick(self, self.onSelectChange, i)
	end
end

function wnd_jubileeStageTwoAward:onSelectChange(sender, idx)
	if self._taskGroup ~= idx then
		self._taskGroup = idx
		for i, e in ipairs(self._widgets.taskWidgets) do
			e.icon:setVisible(self._taskGroup == i)
		end
	end
end

function wnd_jubileeStageTwoAward:refresh()
	local stageState = g_i3k_db.i3k_db_get_jubilee_stage()
	if g_i3k_game_context:GetJubileeStep2TaskID() ~= 0 or stageState ~= g_JUBILEE_STAGE2 then --已领取任务 领取按钮灰化
		self._layout.vars.receiveTaskBtn:disableWithChildren()
	end
	local condition = g_i3k_game_context:GetJubileeStep2TaskRedPoint()
	if not condition then
		self._layout.vars.receiveAwardBtn:disableWithChildren()
	end
	local cfg = i3k_db_jubilee_base.stage2.taskAwards
	self:loadAwardScroll(cfg[g_JUBILEE_TASK_FINISH])	
end

function wnd_jubileeStageTwoAward:onReceiveTask(sender)
	if self._taskGroup == 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17929))
	end
	local group = self._taskGroup
	local function callBack(ok)
		if ok then
			i3k_sbean.jubilee_activity_step2_group_choose(group)
		end
	end  
   	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17930), callBack)
end

function wnd_jubileeStageTwoAward:onReceiveAward(sender)
	local awardsCfg = i3k_db_jubilee_base.stage2.taskAwards
	local items = g_i3k_db.i3k_db_cfg_items_to_BagEnougMap(awardsCfg[g_JUBILEE_TASK_FINISH])
	if not g_i3k_game_context:IsBagEnough(items) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1481))
	end
   i3k_sbean.jubilee_activity_step2_reward(g_JUBILEE_TASK_FINISH)
end

function wnd_create(layout)
	local wnd = wnd_jubileeStageTwoAward.new()
	wnd:create(layout)
	return wnd
end
