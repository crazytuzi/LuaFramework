--[[
	任务集会所 新屠魔 新悬赏
	yanghongbin
]]


_G.AgoraController = setmetatable({}, { __index = IController });
AgoraController.name = "AgoraController";

function AgoraController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_Refresh_QuestAgora, self, self.OnRefreshQuestAgoraResp);
	MsgManager:RegisterCallBack(MsgType.SC_Update_QuestAgora_Notify, self, self.OnUpdateQuestAgoraResp);
	MsgManager:RegisterCallBack(MsgType.SC_Accept_QuestAgora, self, self.OnAcceptQuestAgoraResp);
	MsgManager:RegisterCallBack(MsgType.SC_Abandon_QuestAgora, self, self.OnAbandonQuestAgoraResp);

	Notifier:registerNotification( NotifyConsts.VipJihuoEffect, function( name, body )
		AgoraModel.firstAuto = false;
		AgoraModel:UpdateQuestUIShow()
	end)
end

function AgoraController:OnEnterGame()
end

function AgoraController:ReqRefreshQuestAgora()
	local msg = ReqRefreshQuestAgoraMsg:new();
	MsgManager:Send(msg)
end

function AgoraController:OnRefreshQuestAgoraResp(msg)
	AgoraModel:SetCurTimes(msg.finish_times);
	AgoraModel:SetAutoRefreshStamp(msg.next_fresh_time)
	AgoraModel:SetIsFreeRefresh(msg.free_refresh)
	AgoraModel:UpdateQuestList(msg.questList);
end

function AgoraController:OnUpdateQuestAgoraResp(msg)
	AgoraModel:SetIsFreeRefresh(msg.free_refresh)
	AgoraModel:UpdateQuest(msg.questList[1]);
end

function AgoraController:ReqAcceptQuestAgora(questIndex)
	local msg = ReqAcceptQuestAgoraMsg:new();
	msg.quest_idx = questIndex;
	MsgManager:Send(msg)
end

function AgoraController:OnAcceptQuestAgoraResp(msg)
	if msg.result == 0 then
	end
end

function AgoraController:ReqAbandonQuestAgora(questIndex)
	local msg = ReqAbandonQuestAgoraMsg:new();
	msg.quest_idx = questIndex;
	MsgManager:Send(msg)
end

function AgoraController:OnAbandonQuestAgoraResp(msg)
	if msg.result == 0 then
		AgoraModel:AbandonQuest()
	end
end

function AgoraController:DoNext()
	if not AgoraModel.auto then return; end
	if AgoraModel:GetDayLeftCount() <= 0 then return; end
	for k, v in pairs(AgoraModel.questList) do
		if v.state == QuestConsts.State_UnAccept then
			AgoraController:ReqAcceptQuestAgora(v.questIndex);
			return;
		end
	end
end