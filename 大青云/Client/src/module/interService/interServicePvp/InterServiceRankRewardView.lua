--[[
排行奖励界面
]]

_G.UIInterServiceRankReward = BaseUI:new("UIInterServiceRankReward");


UIInterServiceRankReward.list = {};
UIInterServiceRankReward.isGetReward = 0;
UIInterServiceRankReward.timerKey = nil;
function UIInterServiceRankReward : Create()
	self:AddSWF("interServiceRankRewardPnel.swf", true, "top");
end;
function UIInterServiceRankReward : OnLoaded(objSwf)
	objSwf.Closebtn.click = function () self:CloseClick()end;

	objSwf.scrollbar.scroll = function () self:OnScrollBar()end;
	for i=1,5 do
		local item = objSwf["item"..i];
		RewardManager:RegisterListTips(item.list);
	end

	RewardManager:RegisterListTips(objSwf.myItemList);
	objSwf.Getitem.click = function () self:GoRewardfun()end;

end;
function UIInterServiceRankReward : OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self:init();
	self.list = InterServicePvpModel:GetAllReward();
	objSwf.scrollbar:setScrollProperties(5,0,#self.list-5);
	objSwf.scrollbar.trackScrollPageSize = 5;
	self:ShowList(1);
	self:ShowMyList();

	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function() 
			self:Ontimer()
		end,1000,0);
	self:Ontimer();
end;
function UIInterServiceRankReward : Ontimer()
	local objSwf = self.objSwf;
	if not objSwf then return end

	local time = GetDayTime();  -- 今天过了多少秒
	local refreshTime = 22*3600
	local tc = 0
	if refreshTime >= time then
		tc = 22*3600-time;
	else
		tc = 46*3600-time;
	end
	-- if tc == 0 then
		-- local myinfo =InterServicePvpModel : GetMyroleInfo()
		-- myinfo.rewardflag = 1
		-- objSwf.Getitem.disabled = false;
	-- end
	
	local t,s,m = ArenaModel : GetCurtime(nil,tc)--CTimeFormat:sec2format(tc)
	objSwf.texTime.text = string.format(StrConfig["arena137"],t,s,m);
end;

function UIInterServiceRankReward : OnHide()
	TimerManager:UnRegisterTimer(self.timerKey);
	self.timerKey = nil;
end;
function UIInterServiceRankReward : init()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local myinfo =InterServicePvpModel : GetMyroleInfo()
	objSwf.scrollbar.position = 0;
	if myinfo.rewardflag == 0 then 
		self.objSwf.Getitem.disabled = true;
	else
		self.objSwf.Getitem.disabled = false;
	end;
	local duanwei = MainPlayerModel.humanDetailInfo.eaCrossDuanwei or 5; --段位
	objSwf.textranks.text = InterServicePvpModel:GetMyDuanwei(duanwei)
	objSwf.mcDuanwei:gotoAndStop(duanwei)
	objSwf.txtreward.htmlText = UIStrConfig["interServiceDungeon111"]
end;
function UIInterServiceRankReward : GoRewardfun()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local startPos = UIManager:PosLtoG(objSwf.myItemList,0,0);
	-- local rewardStr = InterServicePvpModel:GetMyReward()
	-- if not rewardStr or rewardStr == '' then return end;
	-- local rewardList = RewardManager:ParseToVO(enAttrType.eaExp,enAttrType.eaUnBindGold,enAttrType.eaZhenQi,"51");
	-- RewardManager:FlyIcon(rewardStr,startPos,6,true,60);
	self.objSwf.Getitem.disabled = true;
	InterServicePvpController:ReqGetPvpDayReward()
	-- FloatManager:AddNormal(StrConfig['arena134']);
	InterServicePvpModel.myRoleInfo.rewardflag = 0;
	UIInterServicePvpView:UpdateEffect()
	-- SoundManager:PlaySfx(2041);
	-- if UIArena:IsShow() then 
		-- UIArena:ShowRankRewardBtnFpx()
	-- end;
end;
function UIInterServiceRankReward : ShowMyList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local rewardStr = InterServicePvpModel:GetMyReward()
	if not rewardStr or rewardStr == '' then return end;
	local rewardList = RewardManager:Parse(rewardStr);
	objSwf.myItemList.dataProvider:cleanUp();
	objSwf.myItemList.dataProvider:push(unpack(rewardList));
	objSwf.myItemList:invalidateData();
end;
function UIInterServiceRankReward : OnScrollBar()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local value = objSwf.scrollbar.position;
	--print(self:IsShow(),"_______________--------")
	--debug.debug();
	self:ShowList(value+1);
end;
--123
function UIInterServiceRankReward : ShowList(value)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local index = 1;
	-- FPrint('...........'..value)
	
	index = value + 4

	local  curlist = {}
	if value == 0 then  value = 1 end;
	for i = value,index do 
		local cvo = {};
		local vo = self.list[i]
		if not vo then return end;
		cvo.duanwei = self.list[i].duanwei
		cvo.ranking = self.list[i].ranking;
		table.push(curlist,cvo)
	end;

	for i,info in ipairs(curlist) do 
		local item = objSwf["item"..i];
		-- item.textrank.text = ""
		-- if tonumber(info.maxRank) > 99999 then 
			-- item.textrank.text = string.format(StrConfig["arena124"],info.miniRank);
		-- end;
		if item then 
			local vo = info;			
			local rewardList = RewardManager:Parse(vo.ranking);
			item.list.dataProvider:cleanUp();
			item.list.dataProvider:push(unpack(rewardList));
			item.list:invalidateData();
		end;
	end;

end;
function UIInterServiceRankReward : CloseClick()
	self:Hide();
end;

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterServiceRankReward:ListNotificationInterests()
	return {
		NotifyConsts.KuafuPvpInfoUpdate,
	};
end

--处理消息
function UIInterServiceRankReward:HandleNotification(name, body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	if name == NotifyConsts.KuafuPvpInfoUpdate then	
		local myinfo =InterServicePvpModel : GetMyroleInfo()
		if myinfo.rewardflag == 0 then 
			objSwf.Getitem.disabled = true;
		else
			objSwf.Getitem.disabled = false;
		end;
	end
end