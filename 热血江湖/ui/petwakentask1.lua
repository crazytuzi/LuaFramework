-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_petWakenTask1 = i3k_class("wnd_petWakenTask1",ui.wnd_base)
local BtnType1 = 1;
local BtnType2 = 2;
function wnd_petWakenTask1:ctor()
	self._task = nil;
	self._id = 0;
	self._topDes = {}
end

function wnd_petWakenTask1:configure(...)
	local widgets	= self._layout.vars
	self.name		= widgets.name;
	self.icon		= widgets.icon;
	self.iconBg		= widgets.iconBg;
	self.topDes		= widgets.topDes;
	self.des		= widgets.des;
	self.targetDes	= widgets.targetDes;
	self.stepBtn	= widgets.stepBtn;
	self.achieveTxt	= widgets.achieveTxt
	self.achieveBtn	= widgets.achieveBtn
	self.cancelBtn	= widgets.cancelBtn
	for i = 1,3 do
		self._topDes[i]		= widgets["topDes"..i];
	end

	widgets.closeBtn:onClick(self, self.onCloseUI)	
	widgets.resetBtn:onClick(self, self.onResetBtnBtn)
	widgets.cancelBtn:onClick(self, self.onCancelBtn)
end

function wnd_petWakenTask1:refresh(id)
	self:updateDate(id)
end

function wnd_petWakenTask1:onAchieveBtn(sender, btnType)
	if btnType == BtnType1 and self._task then
		local cfg = {arg1 = self._task.taskArg.Arg1, effectIdList = self._task.triggerId};
		local isNormal, monsterID = true, 0
		local point, mapId, isNormal, monsterID, pointID = g_i3k_db.i3k_db_checkMainTaskKillTarget(cfg);
		if isNormal then
			g_i3k_game_context:GotoMonsterPos(monsterID)
		else
			g_i3k_game_context:GotoTaskTriggerMonsterPos(mapId, point, pointID)
		end
		
		g_i3k_ui_mgr:CloseUI(eUIID_SuicongWakenTask1)
		g_i3k_logic:OpenBattleUI()
	elseif btnType == BtnType2 and self._id > 0 then
		i3k_sbean.awakeTaskFinish(self._id, g_TaskType1)
	end
end	

function wnd_petWakenTask1:onCancelBtn(sender)
	if self._id > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenGiveUp)
		g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenGiveUp, g_TaskType1)
	end
end	

function wnd_petWakenTask1:onResetBtnBtn(sender)
	if self._id > 0 then
		i3k_sbean.awakeTaskReset(self._id)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16850))
	end
end	

function wnd_petWakenTask1:onStepBtn(sender)
	
	g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenStep)
	g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenStep)
end	

function wnd_petWakenTask1:updateDate(id)
	local cfg_data = g_i3k_db.i3k_db_get_pet_cfg(id);
	local task = g_i3k_game_context:getPetWakenTask(id)
	if cfg_data and task then
		self._id = id;
		self._task = task;
		self.topDes:setText("第一步："..task.taskName);
		for i,e in ipairs(i3k_db_mercenariea_waken_task[id]) do
			self._topDes[i]:setText(e.taskName);
		end
		self.des:setText(task.teskDes1);
		self.name:setText(cfg_data.name)
		self.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(cfg_data.icon, true))
		self.iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[id].rank))
		self:updateKillCount()
	end
end

function wnd_petWakenTask1:updateKillCount()
	if self._task then
		local monsterName = i3k_db_monsters[self._task.taskArg.Arg1].name;
		local count = g_i3k_game_context:getWakenKillCount();
		local state = g_i3k_game_context:getPetWakenTaskState(self._id);
		local targetDesc = ""
		if state == g_TaskState2 then
			self.achieveTxt:setText("完成");
			self.achieveBtn:onClick(self, self.onAchieveBtn, BtnType2)
			local color = g_i3k_get_task_cond_color(true)
			targetDesc = g_i3k_make_color_string(string.format("%s：%s/%s", monsterName, self._task.taskArg.Arg2, self._task.taskArg.Arg2), color,true)
		else
			self.achieveTxt:setText("前往");
			self.achieveBtn:onClick(self, self.onAchieveBtn, BtnType1)	
			local color = g_i3k_get_task_cond_color(false)
			targetDesc = g_i3k_make_color_string(string.format("%s：%s/%s", monsterName, count, self._task.taskArg.Arg2), color,true)
		end	
		self.targetDes:setText(self._task.teskDes2.."击败"..targetDesc);
	end
end

function wnd_create(layout)
	local wnd = wnd_petWakenTask1.new()
	wnd:create(layout)
	return wnd
end
