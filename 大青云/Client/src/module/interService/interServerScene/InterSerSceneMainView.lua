--[[
跨服场景界面
]]

_G.UIInterServerScene = BaseUI:new("UIInterServerScene");


function UIInterServerScene:Create()
	self:AddSWF("interSerSceneMainPanel.swf", true, nil);
end;
function UIInterServerScene:OnLoaded(objSwf)
	objSwf.questReward_btn.click = function() self:QuestrewardClick() end;
	objSwf.questReward_btn.rollOver = function() self:OnQuestReward() end;
	objSwf.questReward_btn.rollOut  = function() TipsManager:Hide(); end;

	objSwf.duihuan_btn.click = function() self:DuiHuanShopClick() end;
	objSwf.duihuan_btn.rollOver = function() self:OnDuihuanOver() end;
	objSwf.duihuan_btn.rollOut  = function() TipsManager:Hide()end;

	RewardManager:RegisterListTips(objSwf.rewardlist);

	objSwf.enter_btn.click = function() self:EnterClick()end;

	objSwf.openQuest_btn.click = function() self:OnQuestClick()end;
	objSwf.openQuest_btn.rollOver = function() self:OnQuestOver() end;
	objSwf.openQuest_btn.rollOut = function() TipsManager:Hide() end

	
	objSwf.rullBtn.rollOver = function() self:OnRullOver() end;
	objSwf.rullBtn.rollOut  = function() TipsManager:Hide() end;
end;



function UIInterServerScene:OnRullOver()
	TipsManager:ShowBtnTips(StrConfig["interServiceDungeon405"],TipsConsts.Dir_RightDown);
end;

function UIInterServerScene:OnQuestReward()
	TipsManager:ShowBtnTips(StrConfig['interServiceDungeon456'])
end;

function UIInterServerScene:OnDuihuanOver()
	TipsManager:ShowBtnTips(StrConfig['interServiceDungeon457'])
end;

function UIInterServerScene:OnQuestOver()
	TipsManager:ShowBtnTips(StrConfig['interServiceDungeon458'])
end;


function UIInterServerScene:OnShow()
	InterSerSceneController:ReqInterServiceSceneinfo()
	self:UpdataShow();
end;

function UIInterServerScene:UpdataShow()
	self:ShowRewardItem();
	self:SetShowTime();
	self:SetLastTime();
end;

function UIInterServerScene:OnHide()
	if UIInterSSQuestReward:IsShow() then 
		UIInterSSQuestReward:Hide();
	end;
	if UIInterSSQuest:IsShow() then 
		UIInterSSQuest:Hide();
	end;
	if UIInterSerSceneShop:IsShow() then 
		UIInterSerSceneShop:Hide();
	end;
end;

function UIInterServerScene:EnterClick()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local mapId = CPlayerMap:GetCurMapID();
	local mapCfg = t_map[mapId];
	if not (mapCfg.type==1 or mapCfg.type==2) then
		FloatManager:AddCenter(StrConfig['interServiceDungeon452']);
		return;
	end
	local cfg = t_consts[300]
	if not cfg then return end;
	if MainPlayerModel.humanDetailInfo.eaLevel < cfg.val3 then 
		FloatManager:AddCenter(StrConfig['interServiceDungeon439']);
		return 
	end;

	InterSerSceneController:ReqEnterInterServiceScene()
end;

function UIInterServerScene:SetLastTime()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local time = InterSerSceneModel:GetLastTime() / 60
	objSwf.lastTime_txt.htmlText = toint(time)..StrConfig["interServiceDungeon401"]
end;

function UIInterServerScene:SetShowTime()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local cfg = t_consts[300]
	if not cfg then return end;
	local time = split(cfg.param,'#')

	objSwf.openTime_txt.htmlText = string.format(StrConfig['interServiceDungeon402'],time[1],time[2]);

	objSwf.openCondition_txt.htmlText = string.format(StrConfig["interServiceDungeon403"],cfg.val3)
	objSwf.desc.htmlText = StrConfig["interServiceDungeon404"]
end;

function UIInterServerScene:QuestrewardClick()
	if not UIInterSSQuestReward:IsShow() then 
		UIInterSSQuestReward:Show();
	else
		UIInterSSQuestReward:Hide();
		UIInterSSQuestReward:Show();
	end;
end

function UIInterServerScene:OnQuestClick()
	local cfg = t_consts[300]
	if not cfg then return end;
	if MainPlayerModel.humanDetailInfo.eaLevel < cfg.val3 then 
		FloatManager:AddCenter(StrConfig['interServiceDungeon439']);
		return 
	end;

	if not UIInterSSQuest:IsShow() then
		UIInterSSQuest:Show();
	else
		UIInterSSQuest:Hide()
		UIInterSSQuest:Show();
	end;
end;

function UIInterServerScene:DuiHuanShopClick()
	-- do
	-- 	--测试版本暂不开放
	-- 	FloatManager:AddNormal(StrConfig["interServiceDungeon464"])
	-- 	return 
	-- end;
	if not UIInterSerSceneShop:IsShow() then 
		UIInterSerSceneShop:Show();
	end;
end;
--
function UIInterServerScene:ShowRewardItem()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local cfg = t_consts[302]
	if not cfg then return end;

	local rankReward = RewardManager:Parse(cfg.param)
	objSwf.rewardlist.dataProvider:cleanUp();
	objSwf.rewardlist.dataProvider:push(unpack(rankReward));
	objSwf.rewardlist:invalidateData();
end;