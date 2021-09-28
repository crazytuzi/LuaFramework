-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_powerReputationTask = i3k_class("wnd_powerReputationTask", ui.wnd_base)

function wnd_powerReputationTask:ctor()

end

function wnd_powerReputationTask:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_powerReputationTask:onShow()

end

function wnd_powerReputationTask:refresh(npcID)
	self._npcID = npcID
	local taskCfg = g_i3k_db.i3k_db_power_rep_get_taskCfg_by_npcid(npcID)
	self._taskCfg = taskCfg -- 存一下
	self:setUI(taskCfg)
	self:setScroll(taskCfg)
end


function wnd_powerReputationTask:setUI(taskCfg)
	local widgets = self._layout.vars
	widgets.taskName:setText(taskCfg.taskName)
	widgets.taskDesc:setText(taskCfg.desc)
	local info = g_i3k_game_context:getPowerRep()
	local taskGroupID = g_i3k_db.i3k_db_power_rep_get_task_groupID(self._npcID)
	local curValue = info.tasks[taskGroupID].value  -- 杀怪数量
	local desc = g_i3k_db.i3k_db_get_task_desc(taskCfg.taskConditionType, taskCfg.args[1], taskCfg.args[2], curValue, curValue >= taskCfg.args[2])
	widgets.taskKill:setText(desc)

	widgets.go_btn:onClick(self, self.onAcceptBtn)
	widgets.abandonBtn:onClick(self, self.onGiveUpBtn)
	widgets.transBtn:onClick(self, self.onTransBtn)
	widgets.help:setText(i3k_get_string(17283))

end

function wnd_powerReputationTask:setScroll(taskCfg)
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	local list =  {}
	for k, v in ipairs(taskCfg.rewards) do
		table.insert(list, v)
	end
	table.insert(list, {id = 1000, count = taskCfg.exp})

	local itemID = g_i3k_db.i3k_db_power_rep_get_itemID(taskCfg.powerSide)
	table.insert(list, {id = itemID, count = taskCfg.rewardRep})
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/shengwangrwt")()
		local itemID = v.id
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
		ui.vars.count:setText("x"..v.count)
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID))
		ui.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		-- ui.vars.lock:setVisible(itemID > 0)
		ui.vars.btn:onClick(self, self.onItemTip, itemID)
		scroll:addItem(ui)
	end
end

function wnd_powerReputationTask:onAcceptBtn(sender)
	i3k_sbean.takePowerReqTask(self._npcID)
end


function wnd_powerReputationTask:onItemTip(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_powerReputationTask:onGiveUpBtn(sender)
	self:onCloseUI()
	-- local message = "确定放弃任务吗？"
	-- local callback = function(ok)
	-- 	if ok then
	-- 		i3k_sbean.quitPowerReqTask(self._npcID)
	-- 	end
	-- end
	-- g_i3k_ui_mgr:ShowMessageBox2(message, callback)
end

function wnd_powerReputationTask:onTransBtn(sender)
	-- g_i3k_ui_mgr:PopupTipMessage("传送按钮")
end

function wnd_create(layout, ...)
	local wnd = wnd_powerReputationTask.new()
	wnd:create(layout, ...)
	return wnd;
end
