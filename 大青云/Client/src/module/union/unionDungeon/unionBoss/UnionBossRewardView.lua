--[[
	activity unionBoss
	wangshuai
	19001
]]

_G.UIUnionBossReward = BaseUI:new("UIUnionBossReward")

UIUnionBossReward.allTimer = 30;

function UIUnionBossReward:Create()
 	self:AddSWF("unionBossRewardPanel.swf",true,"center")
end

function UIUnionBossReward:OnLoaded(objSwf)
	objSwf.out_btn.click = function() self:OnOutActivity()end;

	RewardManager:RegisterListTips(objSwf.winpanel_mc.ranklist);
	RewardManager:RegisterListTips(objSwf.winpanel_mc.succlist);
	RewardManager:RegisterListTips(objSwf.winpanel_mc.canyulist);
	RewardManager:RegisterListTips(objSwf.failpanel_mc.ranklist);
end;

function UIUnionBossReward:OnShow()
	self.allTimer = 30;
	local objSwf = self.objSwf;
	objSwf.outTime_txt.htmlText = string.format(StrConfig["unionBoss012"],self.allTimer);
	self:RegTimer();
	--UnionbossModel:SetBossInfo(10,500000,700000,10000000,1,50)
	self:OnShowUiInfo();
	if UIUnionBossWindow:IsShow() then 
		UIUnionBossWindow:Hide();
	end;
	if UIUnionAcitvity:IsShow() then 
		if UIUnionAcitvity.curid == 4 then 
			UIUnionAcitvity:Hide();
		end;
	end;
end;

function UIUnionBossReward:OnHide()
	UnionBossController:OutUnionBoss()
	UnionBossController:OutAct()
end;

function UIUnionBossReward:RegTimer()
	-- 注册TimerEvent
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function()self:Ontimer()end,1000,30);
end;

function UIUnionBossReward:Ontimer()
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	self.allTimer = self.allTimer - 1;
	objSwf.outTime_txt.htmlText = string.format(StrConfig["unionBoss012"],self.allTimer);
	if self.allTimer <= 0 then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self:Hide();
	end;
end;

function UIUnionBossReward:OnOutActivity()
	self:Hide();
end;

function UIUnionBossReward:OnShowUiInfo()
	local objSwf = self.objSwf;
	local result = UnionbossModel:GetActivityResult()
	objSwf.winpanel_mc._visible = result;
	objSwf.failpanel_mc._visible = not result;
	
	local myinfo = UnionbossModel:GetBossInfo()

	local myrank = UnionbossModel:GetMyRankInfo().rank or 6
	--local cfg = t_guildBoss[myinfo.curid]

	local roleLvl = MainPlayerModel.humanDetailInfo.eaLevel;
	local cfgid = roleLvl * 100 + myinfo.curid;
	local cfg = t_guildBosslevel[cfgid]


	if myrank >= 6 then 
		myrank = 6
	end;
	-- adder:houxudong date:2016/9/14 14:37:25
	if not cfg then 
		print("ERROR : myrank,or id,or cfgid:",myinfo.curid,myrank,cfgid)
		return 
	end

	if result then 
		local str = cfg["rewardsh"..myrank];
		if not str  then 
			print("ERROR : myrank,or id",myinfo.curid,myrank)
			return 
		end;
		local rankReward = AttrParseUtil:ParseAttrToMap(str)
		local list = {};
		for i,info in pairs(rankReward) do 
			local itemvo = RewardSlotVO:new();
			itemvo.id = tonumber(i);
			itemvo.count =tonumber(info);
			table.push(list,itemvo:GetUIData());
		end
		objSwf.winpanel_mc.ranklist.dataProvider:cleanUp();
		objSwf.winpanel_mc.ranklist.dataProvider:push(unpack(list));
		objSwf.winpanel_mc.ranklist:invalidateData();

		local suclist = {};
		local str2 = cfg.rewardall;
		local succeed = AttrParseUtil:ParseAttrToMap(str2)
		for i,info in pairs(succeed) do 
			local itemvo2 = RewardSlotVO:new();
			itemvo2.id = tonumber(i);
			itemvo2.count = tonumber(info)
			table.push(suclist,itemvo2:GetUIData())
		end;

		objSwf.winpanel_mc.succlist.dataProvider:cleanUp();
		objSwf.winpanel_mc.succlist.dataProvider:push(unpack(suclist));
		objSwf.winpanel_mc.succlist:invalidateData();


		local cyulist = {};
		local str3 = cfg.rewardcy;
		local canyu = AttrParseUtil:ParseAttrToMap(str3)
		for i,info in pairs(canyu) do 
			local itemvo3 = RewardSlotVO:new();
			itemvo3.id = tonumber(i);
			itemvo3.count = tonumber(info)
			table.push(cyulist,itemvo3:GetUIData())
		end;

		objSwf.winpanel_mc.canyulist.dataProvider:cleanUp();
		objSwf.winpanel_mc.canyulist.dataProvider:push(unpack(cyulist));
		objSwf.winpanel_mc.canyulist:invalidateData();
	else
		local str = cfg["rewardsh"..myrank];
		if not str  then 
			print("ERROR : myrank,or id",myinfo.curid,myrank)
			return 
		end;
		local rankReward = AttrParseUtil:ParseAttrToMap(str)
		local list = {};
		for i,info in pairs(rankReward) do 
			local itemvo = RewardSlotVO:new();
			itemvo.id = tonumber(i);
			itemvo.count =tonumber(info);
			table.push(list,itemvo:GetUIData());
		end
		objSwf.failpanel_mc.ranklist.dataProvider:cleanUp();
		objSwf.failpanel_mc.ranklist.dataProvider:push(unpack(list));
		objSwf.failpanel_mc.ranklist:invalidateData();
	end;	
end;

