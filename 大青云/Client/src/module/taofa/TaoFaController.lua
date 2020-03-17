--[[
    Created by IntelliJ IDEA.
    讨伐controller
    User: Hongbin Yang
    Date: 2016/10/6
    Time: 15:17
   ]]


_G.TaoFaController = setmetatable({}, { __index = IController });
TaoFaController.name = "TaoFaController"
-- 换场景后回调函数
DungeonController.afterSceneChange = nil
TaoFaController.isAuto = false;
function TaoFaController:Create()
	-- MsgManager:RegisterCallBack(MsgType.SC_GetTaoFaTaskResult, self, self.OnGetTaoFaResultResponse);
	MsgManager:RegisterCallBack(MsgType.SC_TaoFaTaskInfo, self, self.OnTaoFaTaskInfoResponse);
	MsgManager:RegisterCallBack(MsgType.SC_QuickFinshTaoFaTaskResult, self, self.OnQuickFinshTaoFaTaskResponse); --返回：进入讨伐副本
	MsgManager:RegisterCallBack(MsgType.SC_EnterTaoFaDungeonResult, self, self.OnEnterTaoFaDungeonResultResponse);
	MsgManager:RegisterCallBack(MsgType.SC_TaoFaDungeonUpdate, self, self.UpdateTaoFaDungeon); --更新Boss信息
	MsgManager:RegisterCallBack(MsgType.SC_TaoFaBossAndMonNum, self, self.BackTaoFaBossAndMonNum); --返回Boss的总信息
	MsgManager:RegisterCallBack(MsgType.SC_ExitTaoFaDungeonResult, self, self.ExitTaoFaDungeonResult); --返回退出副本
	MsgManager:RegisterCallBack(MsgType.SC_TaoFaDungeonSuccess, self, self.TaoFaDungeonSuccess); --返回讨伐副本通关
end

function TaoFaController:OnEnterGame()
end

-- 切换场景完成后的回调
function TaoFaController:OnChangeSceneMap()
	if self.afterSceneChange then
		self.afterSceneChange()
		self.afterSceneChange = nil
	end
	-- 切换场景后关闭倒计时界面
	if UITimeTopSec:IsShow() then
		UITimeTopSec:Hide();
	end
end

function TaoFaController:OnGetTaoFaResultResponse(msg)
end

function TaoFaController:OnTaoFaTaskInfoResponse(msg)
	--[[TaoFaModel:SetTaskID(msg.taskId); -- 任务id
	TaoFaModel.curFinishedTimes = msg.count; -- 当日已完成次数
	if TaoFaModel.curFinishedTimes < TaoFaUtil:GetDayMaxCount() then
		--添加任务显示
		if not QuestModel:GetTaoFaQuest() then
			QuestModel:AddTaoFaQuest();
		else
			QuestModel:UpdateTaoFaQuest();
			TimerManager:RegisterTimer(function()
				--继续做讨伐
				local questVO = QuestModel:GetTrunkQuest();
				if questVO and questVO:GetState() == QuestConsts.State_CannotAccept then
					QuestGuideManager:DoTaoFaGuide();
				else
					QuestGuideManager:DoTrunkGuide();
				end
			end,5000,1);
		end
	else
		--移除任务显示
		QuestModel:RemoveTaoFaQuest();
	end]]
end

function TaoFaController:ReqQuickFinishTaoFaTask()
	local msg = ReqQuickFinshTaoFaTaskMsg:new();
	MsgManager:Send(msg);
	QuestModel:UpdateTaoFaQuest();
end

function TaoFaController:OnQuickFinshTaoFaTaskResponse(msg)
end

--------------------------------------------------------
--------------------------------------------------------
-- 请求进入讨伐副本
function TaoFaController:ReqEnterTaoFaDungeon()
	local msg = ReqEnterTaoFaDungeonMsg:new();
	MsgManager:Send(msg);
end

-- 返回进入讨伐副本
function TaoFaController:OnEnterTaoFaDungeonResultResponse(msg)
	local result = msg.result
	if result == 0 then
		MainMenuController:HideRight()
		UITaoFaView:Hide()
		UITaoFaInfo:Show() --显示讨伐副本信息栏
		self.afterSceneChange = function()
			AutoBattleController:OpenAutoBattle() --自动挂机
		end
	end
end

-- 请求退出副本
function TaoFaController:ReqQuitDungeon()
	local msg = ReqExitTaoFaDungeonMsg:new();
	MsgManager:Send(msg);
end

-- 返回退出副本
function TaoFaController:ExitTaoFaDungeonResult(msg)
	local result = msg.result
	if result == 0 then
		self:OnLevelDungeon()
	end
end

-- 返回讨伐副本通关
function TaoFaController:TaoFaDungeonSuccess(msg)
	UITaoFaInfo:Hide()
	local callBackOne = function()
		TaoFaDungeonResult:Show()
		-- TaoFaController:ReqQuitDungeon()  --时间到直接退出副本
	end
	DungeonUtils:OnDealyTime(callBackOne)
	QuestModel:UpdateTaoFaQuest();
end

function TaoFaController:OnLevelDungeon()
	UITaoFaInfo:Hide()
	MainMenuController:UnhideRight()
	if TaoFaDungeonResult:IsShow() then
		TaoFaDungeonResult:Hide()
	end
end

-- 进入副本返回boss基本信息（包括id，总数量）
function TaoFaController:BackTaoFaBossAndMonNum(msg)
	TaoFaModel:SetDungeonInfo(msg)
	UITaoFaInfo:InitInfo(0, 0)
end

-- 副本中及时更新boss的基本信息(包括boss和monster的类型和数量)
function TaoFaController:UpdateTaoFaDungeon(msg)
	local monsterType = msg.type
	local number = msg.number
	UITaoFaInfo:UpdateInfo(monsterType, number)
end