--[[
	JiaYuan 
	WangShaui
]]

_G.HomesteadController = setmetatable({},{__index=IController})

HomesteadController.name = "HomesteadController";

function HomesteadController:Create()

	-- 建筑物操作
	-- 	家园建筑信息
	MsgManager:RegisterCallBack(MsgType.WC_HomesBuildInfo,self,		self.OnBuildInfo); 
		-- 家园建筑升级
	MsgManager:RegisterCallBack(MsgType.WC_HomesBuildUplvlresult,	self,self.OnBuildUplvlResult);

	-- 弟子操作
		-- 我的宗门弟子信息
	MsgManager:RegisterCallBack(MsgType.WC_HomesZongminfo,self,		self.OnZongmPupilinfo);
		-- 寻仙台弟子刷新
	MsgManager:RegisterCallBack(MsgType.WC_HomesXunxian,self,		self.OnXunxianPupil);
		-- 弟子招募
	MsgManager:RegisterCallBack(MsgType.WC_HomesPupilEnlist,self,	self.OnPupilEnlist);
		-- 弟子销毁
	MsgManager:RegisterCallBack(MsgType.WC_HomesPupildestory,self,	self.OnPupilDestory);
		-- 弟子经验使用
	MsgManager:RegisterCallBack(MsgType.WC_HomesUsePupilExp,self,	self.OnPupilAddExp);

	-- 任务操作
		-- 我的任务信息
	MsgManager:RegisterCallBack(MsgType.WC_HomesMyQuestInfo,self,	self.OnMyQuestInfo);
		-- 领取任务结果
	MsgManager:RegisterCallBack(MsgType.WC_HomesGetMyQuestReward,self,self.QuestReward)
		-- 任务殿信息
	MsgManager:RegisterCallBack(MsgType.WC_HomesQuestInfo,self,		self.OnQuestInfo);
		-- 接取任务
	MsgManager:RegisterCallBack(MsgType.WC_HomesGetQuest,self,		self.OnGetQuestInfo);
		-- 任务抢夺1
	MsgManager:RegisterCallBack(MsgType.WC_HomesRodQuest,self,		self.OnRodQuest);
		-- 任务抢夺2
	MsgManager:RegisterCallBack(MsgType.WC_HomesRodQuestTwo,self,	self.OnRodQuestTwo);
		-- 任务抢夺结果
	MsgManager:RegisterCallBack(MsgType.WC_HomesGoRodQuest,self,	self.OnGoRodRestlt);
		-- 任务抢夺次数
	MsgManager:RegisterCallBack(MsgType.WC_HomesRodQuestNum,self,	self.OnRodQuestNum);
	--HomesteadModel:testinfo()

	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function()self:Ontimer() end,1000,0);
end

function HomesteadController:OnEnterGame()
	self:MyQuestInfo()
	self:BuildInfo();
end;


-- 计时器！
function HomesteadController:Ontimer() 
	self:PupilUpdata()
	self:QuestUpdata();
	self:UpdataUI()
	Notifier:sendNotification(NotifyConsts.HomesteadUpdatTime);
end;


function HomesteadController:UpdataUI()
	--任务刷新ui
	if UIHomesQuestList:IsShow() then 
		UIHomesQuestList:SetQuestUpdataTime();
	end;
	--我的任务刷
	if UIHomesQuestIng:IsShow() then 
		UIHomesQuestIng:UpdataQuestProgress()
	end;
end;

function HomesteadController:PupilUpdata()
	-- 弟子刷新
	local pupitime = HomesteadModel:GetXunXianTime()
	if pupitime >= 0 then 
		pupitime = pupitime - 1;
		HomesteadModel:SetXunXianTime(pupitime)
	end;
	if pupitime <= 0 then 
		--计时到了，请求刷新
		if UIHomesXunxian:IsShow() then 
			HomesteadController:XunxianPupil(0)
			HomesteadModel:SetPupiUpdata(true)
		end;
	end;
end;

function HomesteadController:QuestUpdata()
	-- 任务刷新
	local questtime = HomesteadModel:GetQuestTime()
	if questtime >= 0 then 
		questtime = questtime - 1;
		HomesteadModel:SetQusetTime(questtime)
	end;
	if questtime <= 0 then 
		--计时到了，请求刷新
		if UIHomesQuestList:IsShow() then 
			HomesteadController:Questinfo(0)
		end;
	end;

	-- 我的任务计时
	local list = HomesteadModel:GetMyQuestInfo();
	for i,info in ipairs(list) do 
		if info.lastTime >= 0 then 
			info.lastTime = info.lastTime - 1;
			if info.lastTime == 0 then 
				if UIHomesQuestIng:IsShow() then 
					UIHomesQuestIng:ShowQuestIngList();
				end;
			end;
		end;
	end;


	--掠夺任务计时
	local cdTime = HomesteadModel.rodQuestVO.rodCD or -1;
	if cdTime > 0 then 
		HomesteadModel.rodQuestVO.rodCD = HomesteadModel.rodQuestVO.rodCD - 1;
	end;

	--完成任务，弹窗提醒
	
	local qstate = HomesteadUtil:GetQuestState()
	if qstate == 1 then 
		if GetCurTime() - self.lastSendTime < 3600000 then
			return;
		end
		self.lastSendTime = GetCurTime();
		UIItemGuide:Open(17);
	end;
end;

HomesteadController.lastSendTime = 0;

function HomesteadController:OnBuildInfo(msg)
	HomesteadModel:SetBuildInfo(msg.list)
	-- trace(msg)
	-- print("返回建筑物信息")
end;

function HomesteadController:OnBuildUplvlResult(msg)
	--trace(msg)
	--print("返回建筑物升级信息")
	if msg.result == 0 then 
		HomesteadModel:SetABuildInfoLvl(msg.buildType,msg.lvl)
		FloatManager:AddNormal(StrConfig["homestead019"])
		if UIHomesBuildLvlUp:IsShow() then 
			UIHomesBuildLvlUp:Hide();
		end;
		Notifier:sendNotification(NotifyConsts.HomesteadBuildInfo);
	elseif msg.result == -1 then 
		FloatManager:AddNormal(StrConfig["homestead023"])
	
	elseif msg.result == -2 then 
		FloatManager:AddNormal(StrConfig["homestead024"])
	elseif msg.result == -3 then 
		--FloatManager:AddNormal(StrConfig[""])
		--print("ERROR config have issue")
	
	elseif msg.result == -4 then 
		FloatManager:AddNormal(StrConfig["homestead025"])
	end;
end;

function HomesteadController:OnZongmPupilinfo(msg)
	--trace(msg)
	--print("返回我弟子信息")
	HomesteadModel:SetMyPupilInfo(msg.list,msg.type)
	Notifier:sendNotification(NotifyConsts.HomesteadMyPupilList)
end;

function HomesteadController:OnXunxianPupil(msg)
	--trace(msg)
	--print("返回寻仙台弟子信息")
	if msg.result == 0 then 
		HomesteadModel:SetXunXianPupilInfo(msg.list);
		HomesteadModel:SetXunXianTime(msg.lasttime)
		HomesteadModel:SetXunXianUpdataNum(msg.cnt)
		HomesteadModel:SetXunXianUpdataRescruit(msg.recruit)
		--trace(msg)
		--print("返回寻仙台弟子信息")
		Notifier:sendNotification(NotifyConsts.HomesteadPupilList);
	end;

end;

function HomesteadController:OnPupilEnlist(msg)
	--trace(msg)
	--print("返回弟子招募结果")
	if msg.result == 0 then 
		FloatManager:AddNormal( StrConfig['homestead026']);
	elseif msg.result == -1 then 
		FloatManager:AddNormal( StrConfig['homestead027']);
	elseif msg.result == -2 then 
		FloatManager:AddNormal( StrConfig['homestead028']);
	elseif msg.result == -3 then 
		FloatManager:AddNormal( StrConfig['homestead029']);
	end;

end;

function HomesteadController:OnPupilDestory(msg)
	--trace(msg)
	--print("返回弟子销毁结果")
	if msg.result == 0 then 
		FloatManager:AddNormal( StrConfig['homestead020']);
		HomesteadModel:DeleteAMyPupil(msg.guid)
		Notifier:sendNotification(NotifyConsts.HomesteadMyPupilList)
	elseif msg.result == -2 then 
		FloatManager:AddNormal( StrConfig['homestead021']);
	elseif msg.result == -3 then 
		FloatManager:AddNormal( StrConfig['homestead022']);
	end;
end;

function HomesteadController:OnPupilAddExp(msg)
	--trace(msg)
	--print("弟子经验增加结果")
	if msg.result == 0 then 
		FloatManager:AddNormal( StrConfig['homestead030']);
	elseif msg.result == -1 then 
		FloatManager:AddNormal( StrConfig['homestead031']);
	end;
end;

function HomesteadController:OnMyQuestInfo(msg)
	--trace(msg)
	--print("我的任务信息")
	HomesteadModel:SetMyQuestInfo(msg.list)
	Notifier:sendNotification(NotifyConsts.HomesteadMyQuestUpdata)
end;

function HomesteadController:QuestReward(msg)
	--trace(msg)
	--print("任务领取结果")
	if msg.result == 0 then 
		HomesteadModel:DeleteMyAIngQuest(msg.guid)
		FloatManager:AddNormal( StrConfig['homestead032']);
		Notifier:sendNotification(NotifyConsts.HomesteadMyQuestUpdata)
	elseif msg.result == 1 then 
		FloatManager:AddNormal( StrConfig['homestead033']);
		HomesteadModel:DeleteMyAIngQuest(msg.guid)
		Notifier:sendNotification(NotifyConsts.HomesteadMyQuestUpdata)
	elseif msg.result == -1 then 
		FloatManager:AddNormal( StrConfig['homestead034']);
	end;
end;

function HomesteadController:OnQuestInfo(msg)
	--trace(msg)
	--print("任务殿信息")
	if msg.result == 0 then 
		HomesteadModel:SetQuestInfo(msg.list)
		HomesteadModel:SetQusetTime(msg.lasttime)
		HomesteadModel:SetQuestUpdataNum(msg.cnt)

		Notifier:sendNotification(NotifyConsts.HomesteadQuestlistUpdata)
	end;
end;

function HomesteadController:OnGetQuestInfo(msg)
	--trace(msg)
	--print("接去任务")
	if msg.result == 0 then 
		FloatManager:AddNormal( StrConfig['homestead035']);
		if UIHomesAQuestVo:IsShow() then 
			UIHomesAQuestVo:Hide();
		end;
	elseif msg.result == -1 then 
		FloatManager:AddNormal(StrConfig['homestead036'])
	elseif msg.result == -2 then 
		FloatManager:AddNormal(StrConfig['homestead037'])
	end;
end;

function HomesteadController:OnRodQuest(msg)
	--trace(msg)
	--print("抢夺任务")
	HomesteadModel:SetRodQuestInfo(msg.list)
	Notifier:sendNotification(NotifyConsts.HomesteadUpdatRodList)
end;

function HomesteadController:OnRodQuestTwo(msg)
	-- trace(msg)
	-- print("抢夺任务记录")
	HomesteadModel:SetRodQuestNum(msg.rodNum,msg.rodCD)
	HomesteadModel:SetRodQuestInfoTwo(msg.listdesc)
	Notifier:sendNotification(NotifyConsts.HomesteadUpdatRodList)
end;

function HomesteadController:OnGoRodRestlt(msg)
	if msg.result == 0 then 
		FloatManager:AddNormal( StrConfig['homestead009']); 
		HomesteadModel:SetARodQuestRodNum(msg.guid)
		Notifier:sendNotification(NotifyConsts.HomesteadUpdatRodList);
		if UIHomesQuestRod:IsShow() then 
			UIHomesQuestRod:ShowAnimation(1,true)
		end;
	elseif msg.result == 1 then 
		if UIHomesQuestRod:IsShow() then 
			UIHomesQuestRod:ShowAnimation(2,true)
		end;
		FloatManager:AddNormal( StrConfig['homestead010']); 
	elseif  msg.result == -1 then
		FloatManager:AddNormal( StrConfig['homestead038']); 
	elseif  msg.result == -2 then
		FloatManager:AddNormal( StrConfig['homestead039']); 
	elseif  msg.result == -3 then
		FloatManager:AddNormal( StrConfig['homestead040']); 
	elseif  msg.result == -4 then
		FloatManager:AddNormal( StrConfig['homestead041']); 
	end;
end;

function HomesteadController:OnRodQuestNum(msg)
	--trace(msg)
	--print("任务抢夺次数")
	if msg.result == 0 then 
		FloatManager:AddNormal( StrConfig['homestead042']); 
	elseif msg.result == 1 then 
		FloatManager:AddNormal( StrConfig['homestead043']); 
	end;
end;




-- ----------------------------------c to s

-- 家园建筑信息
function HomesteadController:BuildInfo()
	local msg = ReqHomesBuildInfoMsg:new();
	MsgManager:Send(msg)
	--trace(msg)
	--print("Reqmsg  家园建筑信息")
end;

-- 家园建筑升级
--boolean, 有不需要判断消耗的建筑物
function HomesteadController:BuildUplvl(id,boolean)
	--print(id,boolean,'--------------------')
	local sid = HomesteadConsts.CompareServerList[id]
	if not boolean then 
		-- 条件判断
		local booleanc = HomesteadUtil:GetUpBuildLvlBoolean(id)
		if not booleanc then 
			FloatManager:AddNormal( StrConfig['homestead073']);
			return 
		end;
	end;

	local msg =  ReqHomesBuildUplvlMsg:new();
	msg.buildType = sid;
	MsgManager:Send(msg)
	--trace(msg)
	--print("Reqmsg  家园建筑升级")
end;

-- 我的宗门弟子信息
function HomesteadController:ZongmengInfo()
	local msg = ReqHomesZongminfoMsg:new()
	MsgManager:Send(msg)
	--trace(msg)
	--print("Reqmsg  我弟子信息")
end;

--  弟子使用经验
function HomesteadController:PupilUseExp(uid,cid)
	local msg = ReqHomesUsePupilExpMsg:new();
	msg.pupilguid = uid;
	msg.cid = cid;
	MsgManager:Send(msg)
	--trace(msg)
	--print("Reqmsg  弟子使用经验")
end;

-- 寻仙台弟子刷新
function HomesteadController:XunxianPupil(type)
	local msg = ReqHomesXunxianMsg:new()
	msg.type = type;
	MsgManager:Send(msg)
	--trace(msg)
	--print("Reqmsg  寻仙台弟子刷新")
end;

-- 弟子招募
function HomesteadController:PupilAdd(id)
	local msg = ReqHomesPupilEnlistMsg:new();
	msg.guid = id;
	MsgManager:Send(msg);
	--trace(msg)
	--print("Reqmsg  弟子招募")
end;

-- 弟子销毁
function HomesteadController:PupilRemove(id)
	local msg = ReqHomesPupildestoryMsg:new();
	msg.guid = id;
	MsgManager:Send(msg);
	--trace(msg)
	--print("Reqmsg  弟子销毁")
end;

-- 我的任务信息
function HomesteadController:MyQuestInfo()
	local msg = ReqHomesMyQuestInfoMsg:new();
	MsgManager:Send(msg)
	--trace(msg)
	--print("Reqmsg  我的任务信息")
end;

-- 领取任务奖励
function HomesteadController:GetMyQuestReawrd(uid)
	local msg = ReqHomesGetMyQuestRewardMsg:new();
	msg.guid = uid;
	MsgManager:Send(msg)
	--trace(msg);
	--print("Reqmsg  领取我的任务奖励")
end;

-- 任务殿信息
function HomesteadController:Questinfo(type)
	local msg = ReqHomesQuestInfoMsg:new();
	msg.type = type;
	MsgManager:Send(msg)
	--trace(msg)
	--print("Reqmsg  任务殿信息")
end;

-- 接取任务
function HomesteadController:GetQuest(uid,pupil1,pupil2,pupil3)
	local msg = ReqHomesGetQuestMsg:new();
	msg.guid = uid;
	msg.pupil1 = pupil1 or 0 ;
	msg.pupil2 = pupil2 or 0 ;
	msg.pupil3 = pupil3 or 0 ;
	MsgManager:Send(msg);
	--trace(msg)
	--print("Reqmsg  接取任务")
end;

-- 任务掠夺
function HomesteadController:RodQuestInfo()
	local msg =  ReqHomesRodQuestMsg:new();
	MsgManager:Send(msg);
	--trace(msg)
	--print("Reqmsg  任务掠夺")
end;

-- 请求抢
function HomesteadController:GoRodQuest(uid)
	local msg = ReqHomesGoRodQuestMsg:new();
	msg.guid = uid;
	MsgManager:Send(msg)
	--trace(msg)
	--print("Reqmsg  卧槽，老子要当土匪了~~")
end;

-- 增加抢夺次数 or CD
function HomesteadController:AddRodQuestNum(type)
	local msg = ReqHomesRodQuestNumMsg:new();
	msg.type = type 
	MsgManager:Send(msg)
	--trace(msg)
	--print("Reqmsg 抢夺次数 or CD")
end;









