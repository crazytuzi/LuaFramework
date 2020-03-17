

_G.InterSerSceneController = setmetatable( {}, {__index = IController} );
InterSerSceneController.name = "InterSerSceneController"

function InterSerSceneController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_InterServiceSceneinfo,			self, self.OnScenePanelInfo);
	MsgManager:RegisterCallBack( MsgType.WC_EnterInterServiceScene,		self, self.OnEnterScene);
	MsgManager:RegisterCallBack( MsgType.SC_InterSSQuestBossInfo,    	self, self.OnBossInfo);

	MsgManager:RegisterCallBack( MsgType.SC_InterSSQuesRankInfo,	self, self.OnRankinfo);

	MsgManager:RegisterCallBack( MsgType.SC_InterSSQuestMyInfo,		self, self.OnQuestMyInfo);
	MsgManager:RegisterCallBack( MsgType.SC_InterSSQuestUpdata,	self, self.OnQuestUpdata);
	MsgManager:RegisterCallBack( MsgType.SC_InterSSQuestRemove,	self, self.OnQuestRemove);	
	MsgManager:RegisterCallBack( MsgType.SC_InterSSQuestInfo,	self, self.OnQuestInfo);	
	MsgManager:RegisterCallBack( MsgType.SC_InterSSQuestGet,	self, self.OnQuestGet);	 
	MsgManager:RegisterCallBack( MsgType.SC_InterSSQuestDiscard,	self, self.OnQuestDiscard);	
	MsgManager:RegisterCallBack( MsgType.SC_InterSSQuestGetReward,	self, self.OnQuestQuestInfo);	

	MsgManager:RegisterCallBack( MsgType.SC_InterServiceSceneMyTeam,	self, self.OnMyTeam);	
	MsgManager:RegisterCallBack( MsgType.SC_InterSSTeamNearbyTeam,	self, self.OnTeamNearbyTeam);	
	MsgManager:RegisterCallBack( MsgType.SC_InterSSTeamNearbyRole,	self, self.OnTeamNeardyRole);	
	MsgManager:RegisterCallBack( MsgType.SC_InterSSInterSSTeamOut,	self, self.OnTeamOut);	
	MsgManager:RegisterCallBack( MsgType.SC_InterSSInterSSTeamCreate,	self, self.OnTeamCreate);	
	MsgManager:RegisterCallBack( MsgType.SC_InterSSInterSSTeamjoin,	self, self.OnTeamJoin);	

	MsgManager:RegisterCallBack( MsgType.SC_InterSSTeamkick,	self, self.OnTeamkick);	
	MsgManager:RegisterCallBack( MsgType.SC_InterSSTeamRequest,	self, self.OnTeamRequest);	


	MsgManager:RegisterCallBack( MsgType.SC_InterSSTeamInviteRole,	self, self.OnTeamInviteRole);	
	MsgManager:RegisterCallBack( MsgType.SC_InterSSTeamInviteRoleResult,	self, self.OnTeamInviteRoleResult);	


	MsgManager:RegisterCallBack( MsgType.SC_InterSSTeamApproveRole,	self, self.OnInterSSTeamApproveRole);	

	-- 退出
	MsgManager:RegisterCallBack( MsgType.SC_OutInterServiceScene,	self, self.OnOutActivaty);	
	-- 积分变化
	MsgManager:RegisterCallBack( MsgType.SC_InterServiceSceneScore,	self, self.OnChangeScore);	




	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function()self:Ontimer() end,1000,0);
end

function InterSerSceneController:OnChangeScore(msg)
	InterSerSceneModel:SetSSSCoreNum(msg.num)
	if UIInterSSRight:IsShow() then 
		UIInterSSRight:SetssNum();
	end;
end;

function InterSerSceneController:OnOutActivaty(msg)
	if msg.result == 0 then 
		if UIInterSSRight:IsShow() then 
			UIInterSSRight:Hide()
		end;
	end;
end;

InterSerSceneController.timerKey = nil;
-- 计时器！
function InterSerSceneController:Ontimer() 
	--活动倒计时
	local lastTime = InterSerSceneModel:GetLastTime();	
	if lastTime > 0 then 
		if UIInterSSRight:IsShow() then 
			InterSerSceneModel.PanelInfo.lastTime = InterSerSceneModel.PanelInfo.lastTime - 1;
			UIInterSSRight:SetLastTime();
		end;
	end;
	-- --任务倒计时刷新
	-- local questTime = InterSerSceneModel:GetQuestUpdataTime();
	-- if questTime > 0 then 
	-- 	InterSerSceneModel.curQuestInfo.lastTime = InterSerSceneModel.curQuestInfo.lastTime - 1;
	-- end;

	--boss倒计时
	local list = InterSerSceneModel:GetBossMonsterInfo();
	for i,info in pairs(list) do 
		if info.state == 2 and info.upTime > 0 then 
			InterSerSceneModel:SetBossMonsterState(info.monsterId,info.state,info.upTime - 1)
			if UIInterSSRight:IsShow() then 
				UIInterSSRight:UpdataBossList();
			end;
		end;
	end;

		
end;

--跨服界面消息，
function InterSerSceneController:OnScenePanelInfo(msg)
	--print("_-------界面消息")
	--trace(msg)
	InterSerSceneModel:SetPanelInfo(msg.lastTime,msg.rewardState,msg.list)
	if UIInterServerScene:IsShow() then 
		UIInterServerScene:UpdataShow()
	end;
	if UIInterSSQuestReward:IsShow() then 
		UIInterSSQuestReward:ShowUiList();
	end;
end;

-- 进入返回
function InterSerSceneController:OnEnterScene(msg)
	--print("------------进入结果")
	--trace(msg)

	if msg.result == 0 then 
		if not UIInterSSRight:IsShow() then 
			UIInterSSRight:Show();
		end;
		InterSerSceneModel:SetSceneIsIng(true)
	elseif msg.result == -1 then 
		--时间不足
		FloatManager:AddNormal(StrConfig["interServiceDungeon451"]);
	elseif msg.result == -2 then 
		--无资格
		FloatManager:AddNormal(StrConfig["interServiceDungeon418"]);
	elseif msg.result == -3 then 
		--不在活动时间
		FloatManager:AddNormal(StrConfig["interServiceDungeon419"]);
	elseif msg.result == -4 then 
		--活动场景人数已满
		FloatManager:AddNormal(StrConfig["interServiceDungeon420"]);
	elseif msg.result == -5 then 
		--功能未开启
		FloatManager:AddNormal(StrConfig["interServiceDungeon442"]);
	elseif msg.result == -6 then 
		--时间不足
		FloatManager:AddNormal(StrConfig['interServiceDungeon417']);
	elseif msg.result == -7 then 
		--组队无法进入
		FloatManager:AddNormal(StrConfig['interServiceDungeon450']);
	end;
end;

-- 怪物状态
function InterSerSceneController:OnBossInfo(msg)
	--print("---------怪物状态更新")
	--trace(msg)
	for i,info in ipairs(msg.list) do 
		InterSerSceneModel:SetBossMonsterState(info.monsterId,info.state,info.upTime)
	end;
	if UIInterSSRight:IsShow() then 
		UIInterSSRight:UpdataBossList();
	end;
end;

-- 排行信息
function InterSerSceneController:OnRankinfo(msg)
	--print("------------排行信息")
	--trace(msg)

	if msg.type == 1 then 
		InterSerSceneModel:SetSkillRanklist(msg.list)
	elseif msg.type == 2 then 
		InterSerSceneModel:SetBeSkillRanklist(msg.list)
	end
	if UIInteSSRanklist:IsShow() then 
		UIInteSSRanklist:UpdataList()
	end;
end;

-- 任务------------------
-- 我的任务信息
function InterSerSceneController:OnQuestMyInfo(msg)
	--print("-------------我的任务信息")
	--trace(msg)
	InterSerSceneModel:SetQuestMyinfo(msg.list)
	if UIInterSSRight:IsShow() then 
		UIInterSSRight:UpdataQuestList();
	end;
	if UIInterSSQuest:IsShow() then 
		UIInterSSQuest:ShowUiList();
	end;
	if UIInterSSQuestTwo:IsShow() then 
		UIInterSSQuestTwo:ShowUiList();
	end
end;

-- 更新任务状态
function InterSerSceneController:OnQuestUpdata(msg)
	--print("-------------更新某一个任务信息")
	--trace(msg)
	InterSerSceneModel:UpdataMyQuestInfo(msg.questId,msg.questUId,msg.questState,msg.condition)
	if UIInterSSRight:IsShow() then 
		UIInterSSRight:UpdataQuestList();
	end;
	if UIInterSSQuest:IsShow() then 
		UIInterSSQuest:ShowUiList();
	end;
	if UIInterSSQuestTwo:IsShow() then 
		UIInterSSQuestTwo:ShowUiList();
	end
end;

-- 删除一个任务
function InterSerSceneController:OnQuestRemove(msg)
	--print("----------删除一个任务")
	--trace(msg)
	InterSerSceneModel:RemoveAQuestInfo(msg.questUId) 
	if UIInterSSRight:IsShow() then 
		UIInterSSRight:UpdataQuestList();
	end;
	if UIInterSSQuest:IsShow() then 
		UIInterSSQuest:ShowUiList();
	end;
	if UIInterSSQuestTwo:IsShow() then 
		UIInterSSQuestTwo:ShowUiList();
	end
end;

-- 任务总列表
function InterSerSceneController:OnQuestInfo(msg)
	--print("-----------任务总列表")
	--trace(msg)
	InterSerSceneModel:SetCurQuestInfo(msg.dayNum,msg.updataNum,msg.list)
	Notifier:sendNotification(NotifyConsts.InterSerSceneQuestUpdata);
end;

-- 接取一个任务  结果
function InterSerSceneController:OnQuestGet(msg)
	--print("-----------接取一个任务 结果")
	--trace(msg)
	if msg.result == 1 then 
		--成功
		FloatManager:AddNormal(StrConfig['interServiceDungeon421'])
	elseif msg.result == -1 then -- 失败
		FloatManager:AddNormal(StrConfig['interServiceDungeon438'])
	elseif msg.result == -2 then -- 等级不足
		FloatManager:AddNormal(StrConfig['interServiceDungeon439'])
	elseif msg.result == -3 then --  次数不足
		FloatManager:AddNormal(StrConfig['interServiceDungeon440'])
	elseif msg.result == -4 then --  不能接去
		FloatManager:AddNormal(StrConfig['interServiceDungeon441'])
	elseif msg.result == -5 then --  任务做完
		FloatManager:AddNormal(StrConfig['interServiceDungeon455'])
	elseif msg.result == -6 then --  不在任务时间
		FloatManager:AddNormal(StrConfig['interServiceDungeon463'])
	end;
end;

-- 放弃任务
function InterSerSceneController:OnQuestDiscard(msg)
	--print("----------放弃任务")
	--trace(msg)
	if msg.result == 0 then 
		FloatManager:AddNormal(StrConfig["interServiceDungeon422"])
	elseif msg.result == -1 then --已完成，不可放弃
		FloatManager:AddNormal(StrConfig["interServiceDungeon448"])
	elseif msg.result == -2 then  --任务不存在
		FloatManager:AddNormal(StrConfig["interServiceDungeon449"])
	end;
end;

-- 任务领取结果
function InterSerSceneController:OnQuestQuestInfo(msg)
	--print("------------任务领取结果")
	--trace(msg)
	if msg.result == 0 then 

		--请求面板信息
		InterSerSceneController:ReqInterServiceSceneinfo()

		-- 领奖成功
		FloatManager:AddNormal(StrConfig["interServiceDungeon423"])
		InterSerSceneModel:SetRewardState(2)
		--如果主界面显示，就刷新
		if UIInterServerScene:IsShow() then 
			UIInterServerScene:UpdataShow()
		end;
		if UIInterSSQuestReward:IsShow() then 
			UIInterSSQuestReward:SetRewardBtnState();
		end;
	end; 
end;

-- ////////////////////////////////组队
-- 组队信息--------------
function InterSerSceneController:OnMyTeam(msg)
	--print("-------------组队信息我的")
	--trace(msg)
	InterSerSceneModel:SetMyTeamInfo(msg.teamList)
	Notifier:sendNotification(NotifyConsts.InterSerSceneTeamUpdata);
end;

-- 附近队伍
function InterSerSceneController:OnTeamNearbyTeam(msg)
	--print("---------------附近队伍列表")
	--trace(msg)
	InterSerSceneModel:SetNearbyTeamInfo(msg.teamList)
	if UIInterSSTeam:IsShow() then 
		UIInterSSTeam:UpdataShow();
	end;
end;

--附近玩家
function InterSerSceneController:OnTeamNeardyRole(msg)
	--print("--------------------附近玩家")
	--trace(msg)
	InterSerSceneModel:SetNearbyRole(msg.roleList)
	if UIInterSSTeam:IsShow() then 
		UIInterSSTeam:UpdataShow();
	end;
end;

-- 退出队伍结果
function InterSerSceneController:OnTeamOut(msg)
	--print("-----------------退出队伍结果")
	--trace(msg)
	if msg.result == 1 then 
		-- 退队成功
		FloatManager:AddNormal(StrConfig["interServiceDungeon424"])
	end;
	--  TZback
end;

-- 创建队伍
function InterSerSceneController:OnTeamCreate(msg)
	--print("---------------创建队伍")
	--trace(msg)
	--  TZback	
	if msg.result == 0 then 
		-- 创建队伍成功
		FloatManager:AddNormal(StrConfig["interServiceDungeon425"])
	elseif msg.result == -1 then 
		--失败
		FloatManager:AddNormal(StrConfig['interServiceDungeon443'])
	elseif msg.result == -2 then 
		--已有队伍
		FloatManager:AddNormal(StrConfig['interServiceDungeon444'])
	end;
end;

-- -- 请求加入队伍
function InterSerSceneController:OnTeamJoin(msg)
	--print("--------------请求加入队伍")
	--trace(msg)
	--  tz back
	if msg.result == 1 then  
		-- 成功
		FloatManager:AddNormal(StrConfig['interServiceDungeon426']);
	elseif msg.result == -1 then 
		--队伍已满
		FloatManager:AddNormal(StrConfig['interServiceDungeon427']);
	elseif msg.result == -2 then 
		--  队伍不存在
		FloatManager:AddNormal(StrConfig['interServiceDungeon428']);
	elseif msg.result == -3 then 
		--队伍已满
		FloatManager:AddNormal(StrConfig['interServiceDungeon427']);
	elseif msg.result == -4 then 
		--已有队伍
		FloatManager:AddNormal(StrConfig['interServiceDungeon444']);
	end;
end

-- 踢人结果
function InterSerSceneController:OnTeamkick(msg)
	--print("---------------踢人结果")
	--trace(msg)
	--  tz back
	if msg.result == 0 then 
		FloatManager:AddNormal(StrConfig["interServiceDungeon429"])
	elseif msg.result == -1 then 
		--失败
		FloatManager:AddNormal(StrConfig['interServiceDungeon443']);
	elseif msg.result == -2 then 
		-- 没有队伍
		FloatManager:AddNormal(StrConfig['interServiceDungeon445']);
	elseif msg.result == -3 then 
		--不是队长
		FloatManager:AddNormal(StrConfig['interServiceDungeon446']);
	elseif msg.result == -4 then 
		--成员不在
		FloatManager:AddNormal(StrConfig['interServiceDungeon447']);
	end;
end;

--收到入队请求
function InterSerSceneController:OnTeamRequest(msg)
	--print("-----------收到入队请求")
	--trace(msg)
	local okfun = function() 
		InterSerSceneController:ReqInterSSTeamApprove(msg.roleID,1)
	end;
	local nofun= function() 
		InterSerSceneController:ReqInterSSTeamApprove(msg.roleID,0)
	end;
	UIConfirm:Open(string.format(StrConfig['interServiceDungeon415'],msg.roleName),okfun,nofun);
end;

--组队申请邀请玩家结果
function InterSerSceneController:OnTeamInviteRole(msg)
	--print("-------组队申请邀请玩家结果")
	--trace(msg)
	---这是条通知返回
	if msg.result == 0 then 
		--邀请成功
		FloatManager:AddNormal(StrConfig["interServiceDungeon430"]);
	elseif msg.result == -1 then 
		--失败
		FloatManager:AddNormal(StrConfig["interServiceDungeon438"]);
	elseif msg.result == -2 then 
		--没有队伍
		FloatManager:AddNormal(StrConfig["interServiceDungeon445"]);
	elseif msg.result == -3 then 
		--不是队长
		FloatManager:AddNormal(StrConfig["interServiceDungeon446"]);
	elseif msg.result == -4 then 
		--玩家不存在
		FloatManager:AddNormal(StrConfig["interServiceDungeon432"]);
	elseif msg.result == -5 then 
		--玩家已有队伍
		FloatManager:AddNormal(StrConfig["interServiceDungeon433"]);
	elseif msg.result == -6 then 
		--队伍已满，无法发送邀请
		FloatManager:AddNormal(StrConfig["interServiceDungeon462"]);
	end;
end;

--组队邀请玩家返回结果
function InterSerSceneController:OnTeamInviteRoleResult(msg)
	--print("---------组队邀请玩家返回结果")
	--trace(msg)
	-- 这是玩家收到邀请
	local okfun = function() 
		InterSerSceneController:ReqInterSSTeamInviteRoleResult(msg.TeamId,1)
	end;
	local nofun= function() 
		InterSerSceneController:ReqInterSSTeamInviteRoleResult(msg.TeamId,0)
	end;
	UIConfirm:Open(string.format(StrConfig['interServiceDungeon416'],msg.roleName),okfun,nofun);
end;

-- 返回玩家入队申请结果
function InterSerSceneController:OnInterSSTeamApproveRole(msg)
	--trace(msg)
	--print("------------返回玩家入队申请结果")
	if msg.result == 0 then  
		-- 成功
		FloatManager:AddNormal(StrConfig['interServiceDungeon434']);
	elseif msg.result == -1 then 
		--队伍已满
		FloatManager:AddNormal(StrConfig['interServiceDungeon427']);
	elseif msg.result == -2 then 
		--  队伍不存在
		FloatManager:AddNormal(StrConfig['interServiceDungeon428']);
	elseif msg.result == -3 then 
		--队伍已满
		FloatManager:AddNormal(StrConfig['interServiceDungeon427']);
	elseif msg.result == -4 then 
		--已有队伍
		FloatManager:AddNormal(StrConfig['interServiceDungeon444']);
	end;
end;

----///////////////////////        c

-- 请求面板信息
function InterSerSceneController:ReqInterServiceSceneinfo()
	local msg = ReqInterServiceSceneinfoMsg:new();
	MsgManager:Send(msg)
	--print("--------请求面板信息")
end;

-- 请求进入活动
function InterSerSceneController:ReqEnterInterServiceScene()
	local msg = ReqEnterInterServiceSceneMsg:new();
	MsgManager:Send(msg);
	--print("--------请求进入活动")
end;

-- 请求退出活动
function InterSerSceneController:ReqOutInterServiceScene()
	local msg = ReqOutInterServiceSceneMsg:new();
	MsgManager:Send(msg)
	InterSerSceneModel:SetSceneIsIng(false)
	--print("-------------退出活动")
end;

--请求排行榜信息
function InterSerSceneController:ReqInterSSQuesRankInfo(type)
	local msg = ReqInterSSQuesRankInfoMsg:new();
	msg.type = type
	MsgManager:Send(msg)
	--print("---------请求排行榜信息，",type)
end;

--//////////////任务
-- 我的任务信息
function InterSerSceneController:ReqInterSSQuestMyInfo()
	local msg = ReqInterSSQuestMyInfoMsg:new();
	MsgManager:Send(msg)
	--print("------------请求我的任务信息")
end;

--请求任务信息
function InterSerSceneController:ReqInterSSQuestInfo(type)
	local msg = ReqInterSSQuestInfoMsg:new();
	msg.type = type;
	MsgManager:Send(msg)
	--print("-------------请求任务信息or刷新",type);
end;

--接取任务
function InterSerSceneController:ReqInterSSQuestGet(questUId)
	local msg = ReqInterSSQuestGetMsg:new();
	msg.questUId = questUId
	MsgManager:Send(msg)
	--print("-------------请求接去任务，",questUId)
end

--放弃任务
function InterSerSceneController:ReqInterSSQuestDiscard(questUId)
	local msg = ReqInterSSQuestDiscardMsg:new();
	msg.questUId = questUId
	MsgManager:Send(msg)
	print("---------------请求放弃任务",questUId);
end;

--请求领取任务完成奖励
function InterSerSceneController:ReqInterSSQuestGetReward()
	local msg = ReqInterSSQuestGetRewardMsg:new();
	MsgManager:Send(msg)
	--print("------------请求领取任务完成奖励")
end;

--////////////////////队伍
--我的队伍信息
function InterSerSceneController:ReqInterServiceSceneMyTeam()
	local msg = ReqInterServiceSceneMyTeamMsg:new();
	MsgManager:Send(msg)
	--print("--------请求我的队伍信息")
end;

--附近队伍
function InterSerSceneController:ReqInterSSTeamNearbyTeam()
	local msg = ReqInterSSTeamNearbyTeamMsg:new();
	MsgManager:Send(msg)
	--print("------------附近队伍消息")
end;

-- 附近玩家
function InterSerSceneController:ReqInterSSTeamNearbyRole()
	local msg = ReqInterSSTeamNearbyRoleMsg:new();
	MsgManager:Send(msg)
	--print('-------------附近玩家消息')
end;

-- 退出队伍消息
function InterSerSceneController:ReqInterSSTeamOut()
	local msg = ReqInterSSTeamOutMsg:new();
	MsgManager:Send(msg)
	--print("--------------退出队伍消息")
end;

--创建队伍
function InterSerSceneController:ReqInterSSTeamCreate()
	local msg = ReqInterSSTeamCreateMsg:new();
	MsgManager:Send(msg)
	--print("-----------创建队伍")
end;

-- 加入队伍   ###########################无效协议
function InterSerSceneController:ReqInterSSTeamjoin(id)
	local msg = ReqInterSSTeamjoinMsg:new();
	msg.id = id;
	MsgManager:Send(msg)
	--print("----------请求加入一个队伍，",id)
end

-- 队长踢人
function InterSerSceneController:ReqInterSSTeamkick(roleID)
	local msg = ReqInterSSTeamkickMsg:new();
	msg.roleID = roleID;
	MsgManager:Send(msg)
	--print("------------队长踢人",roleID)
end

-- 队长入队审批
function InterSerSceneController:ReqInterSSTeamApprove(roleID,operate)
	local msg = ReqInterSSTeamApproveMsg:new();
	msg.targetRoleID = roleID;
	msg.operate = operate;
	MsgManager:Send(msg)
	--print("--------------队长审批结果",roleID,operate)
end;


-- 队伍邀请玩家
function InterSerSceneController:ReqInterSSTeamInviteRole(roleID)
	local msg = ReqInterSSTeamInviteRoleMsg:new();
	msg.RoleID = roleID;
	MsgManager:Send(msg)
	--print("--------------队伍邀请玩家",roleID)
end;

-- 队伍邀请玩家结果
function InterSerSceneController:ReqInterSSTeamInviteRoleResult(TeamId,operate)
	local msg = ReqInterSSTeamInviteRoleResultMsg:new();
	msg.TeamId = TeamId;
	msg.operate = operate;
	MsgManager:Send(msg)
	--print("--------------队伍邀请玩家结果",roleID,operate)
end;

-- 玩家申请入队
function InterSerSceneController:RespInterSSTeamApproveRole(teamId)
	local msg = ReqInterSSTeamApproveRoleMsg:new();
	msg.TaamRoleID = teamId;
	MsgManager:Send(msg);
	--print("--------------玩家申请入队",teamId)

end;
function InterSerSceneController:IsOpen()
	local openLevel=t_funcOpen[FuncConsts.KuaFuPVP].open_level;
    return MainPlayerModel.humanDetailInfo.eaLevel>=openLevel;
end
function InterSerSceneController:IsExist()
	 local isopenkuafu= t_consts[308].val1;
    if not isopenkuafu then return;end
	return MainPlayerModel.humanDetailInfo.eaLevel>=isopenkuafu;
end