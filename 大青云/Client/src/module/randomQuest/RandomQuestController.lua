--[[
奇遇任务 Controller
2015年7月29日16:48:04
haohu
]]
--------------------------------------------------------------

_G.RandomQuestController = setmetatable( {}, {__index = IController} )
RandomQuestController.name = "RandomQuestController"

function RandomQuestController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_RandomQuestAdd, self, self.OnRandomQuestAdd )
	MsgManager:RegisterCallBack( MsgType.SC_RandomQuestUpdate, self, self.OnRandomQuestUpdate )
	MsgManager:RegisterCallBack( MsgType.SC_RandomQuestRemove, self, self.OnRandomQuestRemove )
	MsgManager:RegisterCallBack( MsgType.SC_RandomDungeonEnter, self, self.OnRandomDungeonEnter )
	MsgManager:RegisterCallBack( MsgType.SC_RandomDungeonExitResult, self, self.OnRandomDungeonExitResult )
	MsgManager:RegisterCallBack( MsgType.SC_RandomDungeonStepResult, self, self.OnRandomDungeonStepResult )
	MsgManager:RegisterCallBack( MsgType.SC_RandomDungeonStepContentIssue, self, self.OnRandomDungeonStepContentIssue )
	MsgManager:RegisterCallBack( MsgType.SC_RandomDungeonStepProgress, self, self.OnRandomDungeonStepProgress )
	MsgManager:RegisterCallBack( MsgType.SC_RandomDungeonComplete, self, self.OnRandomDungeonComplete )
end

-----------------------------resp---------------------------------

function RandomQuestController:OnRandomQuestAdd(msg)
	QuestController:TestTrace("服务器返回:增加奇遇任务")
	QuestController:TestTrace(msg)
	RandomQuestModel:AddQuest( msg.id, msg.state, msg.round )
	UIRamdomQuestProGress:SetQuestID(msg.id)
	
	--翻牌后自动执行奇遇任务
	if RandomQuestModel:GetIsRandomReward() then
		if t_consts[90].val2 then
			local playerinfo = MainPlayerModel.humanDetailInfo;
			if playerinfo.eaLevel >= t_consts[90].val2 then
				RandomQuestController:DoRandomQuest();
				RandomQuestModel:SetIsRandomReward(false);
			end
		end
	end
end

function RandomQuestController:OnRandomQuestUpdate(msg)
	QuestController:TestTrace("服务器返回:更新奇遇任务")
	QuestController:TestTrace(msg)
	RandomQuestModel:UpdateQuest( msg.id, msg.state, msg.count )
end

function RandomQuestController:OnRandomQuestRemove(msg)
	QuestController:TestTrace("服务器返回:删除奇遇任务")
	QuestController:TestTrace(msg)
	RandomQuestModel:RemoveQuest( msg.id )
	Notifier:sendNotification( NotifyConsts.RandomDungeonReward,{id = msg.id});
end

function RandomQuestController:OnRandomDungeonEnter(msg)
	QuestController:TestTrace("服务器返回:进入奇遇副本")
	QuestController:TestTrace(msg)
	local dungeon = RandomDungeonFactory:CreateDungeon( msg.id )
	RandomQuestModel:SetDungeon( dungeon )
	
	if self:GetIsaotuExit(msg.id) then
		self:ReqRandomDungeonExit();
	end
end

function RandomQuestController:GetIsaotuExit(tid)
	local cfg = _G.t_qiyu[tid]
	if not cfg then
		Error( string.format( "wrong random dungeon id:%s", tid ) ) 
		return false;
	end
	if t_consts[90].val2 then
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaLevel < t_consts[90].val2 then
			return false;
		end
	end
	local dType = cfg.type
	--采集宝箱特殊处理
	if dType == RandomDungeonConsts.Type_Collect and cfg.param1 == 1 then
		return false;
	end
	if dType == RandomDungeonConsts.Type_Answer or dType == RandomDungeonConsts.Type_Clue or dType == RandomDungeonConsts.Type_Collect then
		return true;
	end
	return false;
end

function RandomQuestController:OnRandomDungeonExitResult(msg)
	QuestController:TestTrace("服务器返回:退出奇遇副本结果")
	QuestController:TestTrace(msg)
	if msg.result == 0 then
		RandomQuestModel:SetDungeon( nil )
		UIRandomDungeonNpc:Hide()
		UIRamdomQuestProGress:Hide();
	end
end

function RandomQuestController:OnRandomDungeonStepResult(msg)
	QuestController:TestTrace("服务器返回:奇遇副本步骤完成结果")
	QuestController:TestTrace(msg)
	if msg.result == 0 then
		RandomQuestModel:SetDungeonStep( msg.step + 1 ) -- 完成副本内一个步骤,开始下一步
	end
end

function RandomQuestController:OnRandomDungeonStepContentIssue(msg)
	QuestController:TestTrace("服务器返回:奇遇副本步骤内容发送(发题)")
	QuestController:TestTrace(msg)
	RandomQuestModel:SetStepSubject( msg.id )
end

function RandomQuestController:OnRandomDungeonStepProgress(msg)
	QuestController:TestTrace("服务器返回:奇遇副本步骤进度信息")
	QuestController:TestTrace(msg)
	RandomQuestModel:SetStepProgress( msg.count )
end

function RandomQuestController:OnRandomDungeonComplete(msg)
	QuestController:TestTrace("服务器返回:奇遇副本完成")
end

-----------------------------req---------------------------------

function RandomQuestController:ReqRandomQuestComplete( qiyuId )
	local canTeleport, failFlag = MainPlayerController:IsCanTeleport()
	if not canTeleport then
		local promptStr = PlayerConsts.CannotTeleportRemindDic[ failFlag ]
		if promptStr then
			FloatManager:AddNormal( promptStr )
		end
		return false
	end
	if TeamModel:IsInTeam() then
		FloatManager:AddNormal( StrConfig['randomQuest106'] )
		return false
	end
	MainPlayerController:ClearPlayerState()
	local msg = ReqRandomQuestCompleteMsg:new()
	msg.id = qiyuId
	MsgManager:Send(msg)
	QuestController:TestTrace("客户端请求:完成奇遇任务")
	QuestController:TestTrace(msg)
	return true
end

function RandomQuestController:ReqRandomQuestReward( qiyuId )
	local msg = ReqRandomQuestRewardMsg:new()
	msg.id = qiyuId
	MsgManager:Send(msg)
	QuestController:TestTrace("客户端请求:奇遇任务领奖")
	QuestController:TestTrace(msg)
end

function RandomQuestController:ReqRandomDungeonExit()
	local msg = ReqRandomDungeonExitMsg:new()
	MsgManager:Send(msg)
	QuestController:TestTrace("客户端请求:退出奇遇副本")
	QuestController:TestTrace(msg)
end

function RandomQuestController:ReqRandomDungeonStepComplete(step)
	local msg = ReqRandomDungeonStepMsg:new()
	msg.step = step
	MsgManager:Send(msg)
	QuestController:TestTrace("客户端请求:奇遇副本步骤完成")
	QuestController:TestTrace(msg)
end

function RandomQuestController:ReqRandomDungeonStepSubmit(replyIndex)
	local msg = ReqRandomDungeonStepSubmitMsg:new()
	msg.reply = replyIndex
	MsgManager:Send(msg)
	QuestController:TestTrace("客户端请求:奇遇副本步骤内容提交(答题)")
	QuestController:TestTrace(msg)
end


-----------------------------------------------------------------

-- 打坐副本打坐倍率
function RandomQuestController:GetZazenDungeonBonus()
	local currentDungeon = RandomQuestModel:GetDungeon()
	if currentDungeon and currentDungeon:GetType() == RandomDungeonConsts.Type_Zazen then
		return currentDungeon:GetZazenBonus()
	end
	return 0
end


-----------------------------------------------------------------

-- 做奇遇任务
function RandomQuestController:DoRandomQuest()
	local randomQuest = RandomQuestModel:GetQuest()
	if not randomQuest then return end
	randomQuest:Proceed()
end

-----------------------------------------------------------------

--自动进行奇遇任务
function RandomQuestController:OnChangeSceneMap()
	if RandomQuestModel:GetIsRandomQuest() then
		if t_consts[90].val2 then
			local playerinfo = MainPlayerModel.humanDetailInfo;
			if playerinfo.eaLevel >= t_consts[90].val2 then
				self:DoRandomQuest();
				RandomQuestModel:SetIsRandomQuest(false)
				
				--自动执行奇遇任务
				if RandomQuestModel:GetIsRandomReward() then
					--5s后自动设置成
					if self.AotutimeKey then
						TimerManager:UnRegisterTimer(self.AotutimeKey);
						self.AotutimeKey = nil;
					end
					local func = function ()
						if RandomQuestModel:GetIsRandomReward() then
							RandomQuestModel:SetIsRandomReward(false);
						end
						TimerManager:UnRegisterTimer(self.AotutimeKey);
						self.AotutimeKey = nil;
					end
					self.AotutimeKey = TimerManager:RegisterTimer(func,5000,1);
				end
			end
		end
	end
end