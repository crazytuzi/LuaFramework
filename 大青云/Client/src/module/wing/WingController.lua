--[[
翅膀
lizhuangzhuang
2015年7月10日11:10:46
]]

_G.WingController = setmetatable({},{__index=IController})
WingController.name = "WingController";

--翅膀开启等级
WingController.wingOpenLevel = 0;

function WingController:Create()
	local func = FuncManager:GetFunc(FuncConsts.WingHeCheng);
	if func then
		self.wingOpenLevel = func:GetCfg().open_prama;
	end
	
	
	MsgManager:RegisterCallBack(MsgType.SC_WingStarData,self,self.OnWingStarData);  				--翅膀升星data
	MsgManager:RegisterCallBack(MsgType.SC_BackWingStrenResult,self,self.OnBackWingStrenResult);  	--返回强化结果
end
function WingController:OnAchievementChange()
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	local state = AchievementModel:GetState(800001)
	if state==0 and level>=self.wingOpenLevel then
		if not UIWingRightOpen:IsShow() then
			UIWingRightOpen:Show();
		end
	else
		if UIWingRightOpen:IsShow() then
			UIWingRightOpen:Hide();
		end
	end
end
function WingController:OnEnterGame()
	-- local level = MainPlayerModel.humanDetailInfo.eaLevel;
	-- if level>=40 and level<self.wingOpenLevel then
		-- if not UIWingRightOpen:IsShow() then
			-- UIWingRightOpen:Show();
		-- end
	-- end
end

function WingController:OnLevelUp(oldLevel,newLevel)
	WingController:OnAchievementChange()
	-- if oldLevel<40 and newLevel>=40 then
		-- if not UIWingRightOpen:IsShow() then
			-- UIWingRightOpen:Show();
		-- end
	-- end
	-- if oldLevel<self.wingOpenLevel and newLevel>=self.wingOpenLevel then
		-- if UIWingRightOpen:IsShow() then
			-- UIWingRightOpen:Hide();
		-- end
		-- QuestScriptManager:DoScript("wingGetguide");
	-- end
end

--送的翅膀的等级
WingController.WingGiveLevel = 2;

--获取玩家拥有的最大等阶翅膀
function WingController:GetWingMaxLevel()
	local level = 0;
	for _,bagVO in pairs(BagModel.baglist) do
		for i,bagItem in pairs(bagVO.itemlist) do
			if BagUtil:IsWing(bagItem:GetTid()) then
				local cfg = t_item[bagItem:GetTid()];
				local wingCfg = t_wing[cfg.link_param];
				if wingCfg and wingCfg.level>level then
					level = wingCfg.level;
				end
			end
		end
	end
	return level;
end

--翅膀升星data
function WingController:OnWingStarData(msg)
	local starLevel = msg.starLevel;
	local progress = msg.progress;
	WingStarUpModel:SetWingStarData(starLevel,progress);
end

--返回强化结果
function WingController:OnBackWingStrenResult(msg)
	local result = msg.result;
	local starLevel = msg.starLevel;
	local progress = msg.progress;
	trace(msg)
	if result == 0 then
		WingStarUpModel:SetWingStarData(starLevel,progress);
	else
		Notifier:sendNotification(NotifyConsts.WingStarUpData,{result = result});
		if result == 1 then
			FloatManager:AddNormal(StrConfig['wingstarup102']);
		elseif result == 2 then
			FloatManager:AddNormal(StrConfig['wingstarup100']);
		elseif result == 3 then
			FloatManager:AddNormal(StrConfig['wingstarup103']);
		elseif result == 4 then
			FloatManager:AddNormal(StrConfig['wingstarup101']);
		end
	end
end

--翅膀强化
function WingController:OnSendWingStarUp()
	local msg = ReqSendWingStrenMsg:new();
	MsgManager:Send(msg);
end