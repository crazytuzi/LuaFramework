--[[
排行奖励界面
wangshuai

]]

_G.UIRankRewardView = BaseUI:new("UIRankRewardView");


UIRankRewardView.list = {};
UIRankRewardView.isGetReward = 0;
UIRankRewardView.timerKey = nil;
function UIRankRewardView : Create()
	self:AddSWF("arenaRankRewardPnel.swf", true, nil);
end;
function UIRankRewardView : OnLoaded(objSwf)
	objSwf.Closebtn.click = function () self:CloseClick()end;

	objSwf.scrollbar.scroll = function () self:OnScrollBar()end;
	for i=1,4 do
		local item = objSwf["item"..i];
		RewardManager:RegisterListTips(item.list);
	end

	RewardManager:RegisterListTips(objSwf.myItemList);
	objSwf.Getitem.click = function () self:GoRewardfun()end;

end;
function UIRankRewardView : OnShow()
	self:init();
	local objSwf = self.objSwf
	self.list = ArenaModel:GetAllReward();
	objSwf.scrollbar:setScrollProperties(5,0,#self.list-5);
	objSwf.scrollbar.trackScrollPageSize = 5;
	self:ShowList(1);
	self:ShowMyList();

	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.Ontimer,1000,0);
	self:Ontimer();
end;
function UIRankRewardView : Ontimer()
	local time = GetDayTime();  -- 今天过了多少秒
	local tc = 24*3600-time;
	local t,s,m = ArenaModel : GetCurtime(nil,tc)--CTimeFormat:sec2format(tc)
	UIRankRewardView.objSwf.texTime.text = string.format(StrConfig["arena137"],t,s,m);
end;

function UIRankRewardView : OnHide()
	TimerManager:UnRegisterTimer(self.timerKey);
	self.timerKey = nil;
end;
function UIRankRewardView : init()
	local objSwf = self.objSwf;
	local myinfo = ArenaModel : GetMyroleInfo()
	local myrew = ArenaModel : GetMyReward();
	objSwf.scrollbar.position = 0;
	if myinfo.isResults == 1 then 
		--self.objSwf.Getitem:showEffect(ResUtil:GetButtonEffect10())
		self.objSwf.Getitem.disabled = true;
	else
		self.objSwf.Getitem.disabled = false;
	--	self.objSwf.Getitem:clearEffect();
	end;
	objSwf.textranks.text = myinfo.rank;

	objSwf.textadmoney.text = myinfo.admoney
	objSwf.textadhonor.text = myinfo.adhonor
	objSwf.txtreward.htmlText = string.format(StrConfig["arena109"],myrew.txt);
end;
function UIRankRewardView : GoRewardfun()
	local objSwf = self.objSwf;
	local startPos = UIManager:PosLtoG(objSwf.myItemList,0,0);
	local rewardList = RewardManager:ParseToVO(enAttrType.eaUnBindGold,"51");
	RewardManager:FlyIcon(rewardList,startPos,6,true,60);
	self.objSwf.Getitem.disabled = true;
    --self.objSwf.Getitem:clearEffect();
	ArenaController:ReqGetReward()
	FloatManager:AddNormal(StrConfig['arena134']);
	ArenaModel.myRoleInfo.isResults = 1;
	SoundManager:PlaySfx(2041);
	if UIArena:IsShow() then 
		UIArena:ShowRankRewardBtnFpx()
	end;
	--尝试去设置按钮特效
	local func = FuncManager:GetFunc(FuncConsts.Arena);
	if not func then return; end
	func:SetEffectState();
end;

function UIRankRewardView : OnScrollBar()
	local objSwf = self.objSwf;
	local value = objSwf.scrollbar.position;
	self:ShowList(value+1);
end;
function UIRankRewardView:GetPanelType()
	return 0;
end

function UIRankRewardView:ESCHide()
	return true;
end
function UIRankRewardView : ShowMyList()
	local objSwf = self.objSwf;
	local vo = ArenaModel:GetMyReward()
	if not vo.exp then return end;
	if not vo.exp then 
		print(debug.traceback(trace(vo)))
		return ;
	end; 
	local rewardList = RewardManager:Parse(enAttrType.eaUnBindGold..","..vo.gold,"51,"..vo.honor);
	objSwf.myItemList.dataProvider:cleanUp();
	objSwf.myItemList.dataProvider:push(unpack(rewardList));
	objSwf.myItemList:invalidateData();
end;

--123
function UIRankRewardView : ShowList(value)
	local objSwf = self.objSwf
	local index = 1;
	index = value + 4
	local  curlist = {}
	if value == 0 then  value = 1 end;
	for i = value,index do 
		local cvo = {};
		local vo = self.list[i]
		if not vo then return end;
		cvo.miniRank = self.list[i].miniRank;
		cvo.maxRank = self.list[i].maxRank;
		cvo.honor = self.list[i].honor;
		cvo.gold = self.list[i].gold;
		cvo.zhenqi = self.list[i].zhenqi;
		cvo.exp = self.list[i].exp;
		table.push(curlist,cvo)
	end;

	for i,info in ipairs(curlist) do 
		local item = objSwf["item"..i];
		item.textrank.text = string.format(StrConfig["arena123"],info.miniRank,info.maxRank);
		if tonumber(info.maxRank) > 99999 then 
			item.textrank.text = string.format(StrConfig["arena124"],info.miniRank);
		end;
		if item then 
			local vo = info;
				local rewardList = RewardManager:Parse(enAttrType.eaUnBindGold..","..vo.gold,"51,"..vo.honor);
				item.list.dataProvider:cleanUp();
				item.list.dataProvider:push(unpack(rewardList));
				item.list:invalidateData();
		end;
	end;

end;
function UIRankRewardView : CloseClick()
	self:Hide();
end;