--[[
	竞技场Controller
	wangshuai
]]


_G.ArenaController = setmetatable({},{__index=IController});
ArenaController.name = "ArenaController";

function ArenaController : Create()
	MsgManager:RegisterCallBack(MsgType.WC_ArenaInfo,self,self.ArenaMyInfo);
	MsgManager:RegisterCallBack(MsgType.WC_ArenaRolelist,self,self.ArenaFirstList);
	MsgManager:RegisterCallBack(MsgType.WC_ArenaResults,self,self.ArenaResults);
	MsgManager:RegisterCallBack(MsgType.WC_ArenaReward,self,self.ArenaReward);
	MsgManager:RegisterCallBack(MsgType.WC_ArenaSkInfo,self,self.ArenaSkInfo);
	MsgManager:RegisterCallBack(MsgType.SC_EnterArena,self,self.EnterArena);

	MsgManager:RegisterCallBack(MsgType.WC_BuyArenaTimes,self,self.BuyArenaTimerResult);
	MsgManager:RegisterCallBack(MsgType.WC_BuyArenaCD,self,self.BuyArenaCDResult);
end;

function ArenaController:OnEnterGame()
	ArenaController : GetMyroleAtb()
end;

function ArenaController:Update()
	 ArenaBattle:Update()
end
-- --------------------------s To c -----------------
--  Buy timer Result 
function ArenaController : BuyArenaTimerResult(msg)
	--print("timer Result")
	--trace(msg)
	if msg.result == 2 then 
		FloatManager:AddNormal(StrConfig['arena139']);
	end;
	ArenaModel:GetMyroleInfo().maxchall = msg.times
	Notifier:sendNotification(NotifyConsts.ArenaUpMyInfo);
end;
-- Buy CD Result 
function ArenaController : BuyArenaCDResult(msg)
	ArenaModel:GetMyroleInfo().lastTime = msg.cd;
	Notifier:sendNotification(NotifyConsts.ArenaUpMyInfo);
end;
-- My role attribute
function ArenaController : ArenaMyInfo(msg)
	--print(" 返回个人信息");
	--trace(msg)
	ArenaModel : SetMyroleInfo(msg.rank,msg.chal,msg.lastTime,msg.isResults,msg.ranks,msg.field,msg.admoney,msg.adhonor,msg.maxchallTime);
	Notifier:sendNotification(NotifyConsts.ArenaGetMyInfo);
end;
-- 挑战对象，or 123名
function ArenaController : ArenaFirstList(msg)
	if msg.type == 0 then 
		--123名
		ArenaModel : SetFrist(msg.ArenaList)
	elseif msg.type == 1 then 
		--挑战对象
		ArenaModel : SetChallenge(msg.ArenaList)
	end;
end;
-- 挑战结果
function ArenaController : ArenaResults(msg)
	ArenaModel:SaveFigInfo(msg)
end;
-- 领奖结果
function ArenaController : ArenaReward(msg)
	if msg.result == 0 then 
		-- 成功
	elseif msg.result == 1 then 
		-- 失败
	end;
end;
-- 竞技战报
function ArenaController : ArenaSkInfo(msg)
	--trace(msg.SkInfoList)
	ArenaModel : SkillInfo(msg.SkInfoList)
end;
--进入竞技场
function ArenaController:EnterArena(msg)
	ArenaBattle:EnterScene(msg)
end
------------------------------c To s ---------
-- req buy cd 
function ArenaController : ReqBuyCd()
	local msg = ReqBuyArenaCDMsg:new();
	MsgManager:Send(msg)
end;
-- req buy timer
function ArenaController : ReqBuyTimer()
	local msg = ReqBuyArenaTimesMsg:new()
	MsgManager:Send(msg)
end;
-- 请求我的人物属性
function ArenaController : GetMyroleAtb()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	if t_funcOpen[17].open_prama > myLevel then 
		return 
	end;
	local msg = ReqArenaMyroleAtbMsg:new();
	MsgManager:Send(msg);
end;
-- 请求挑战对象
function ArenaController : GetRolelist(num)
	local msg = ReqArenaBeChallengeRolelistMsg:new();
	msg.type = num;
	MsgManager:Send(msg);
end;
-- 请求挑战
function ArenaController : ReqChallenge(rank)
	--print(rank)
	--婚礼巡游中
	if HuncheController.followerGuid and HuncheController.followerGuid ~= "0_0" then
		FloatManager:AddNormal(StrConfig['marriage214'])
		return 
	end;

	ArenaModel:SetCurBeRole(rank)
	local msg = ReqArenaChallengeMsg:new();
	msg.rank = rank;
	MsgManager:Send(msg)
end;
-- 请求领取奖励
function ArenaController : ReqGetReward()
	local msg = ReqArenaGetRewardItemMsg:new();
	MsgManager:Send(msg);
end;
-- 请求战报
function ArenaController : ReqSkInfo()
	local msg = ReqArenaSkillInfoMsg:new()
	MsgManager:Send(msg)
end;
--请求退出
function ArenaController:ReqQuitArena()
	local msg = ReqQuitArenaMsg:new()
	MsgManager:Send(msg)
end

-- function ArenaController:OninteScene()

-- end;

function ArenaController:OnChangeSceneMap()
	if ArenaBattle.inArenaScene == 2 then
		ArenaBattle:ResetArenaBattle()
	end
end

