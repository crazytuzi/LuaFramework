--[[
	仙缘洞府
	2015年1月8日, PM 04:38:03
	wangyanwei
]]

_G.UIXianYuanCave = BaseUI:new("UIXianYuanCave");

UIXianYuanCave.RewardIconTable = '200130007,0,1#200130008,0,1#200130009,0,1#200130010,0,1';
UIXianYuanCave.RewardIconTable2 = '151100042,0,1#151100052,0,1#151100062,0,1#151803001,0,1#151900001,0,1#150700001,0,1#152100001,0,1#150100011,0,1#13,0,1#10,0,1#14,0,1';
UIXianYuanCave.layerId=nil;
function UIXianYuanCave:Create()
	self:AddSWF("xianYuanCave.swf",true,"center");
end

function UIXianYuanCave:OnLoaded(objSwf,name)
	objSwf.btn_tip.rollOver = function () TipsManager:ShowBtnTips(StrConfig['cave001'],TipsConsts.Dir_RightDown); end
	objSwf.btn_tip.rollOut = function () TipsManager:Hide(); end
	
	objSwf.btn_sub.click = function () self:OnCaveClickHandler(); end
	objSwf.btn_Close.click = function () self:Hide(); end
	objSwf.txt_1.htmlText = string.format(UIStrConfig['cave20'],t_funcOpen[FuncConsts.DaBaoMiJing].open_prama);
	objSwf.txt_2.htmlText = UIStrConfig['cave21'];
	objSwf.txt_3.text = UIStrConfig['cave600'];
	objSwf.txt_downInfo.htmlText = UIStrConfig['cave200'];
	
	objSwf.rewardList.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function() TipsManager:Hide(); end
	objSwf.rewardList2.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList2.itemRollOut = function() TipsManager:Hide(); end
	objSwf.bg.hitTestDisable = true;
	objSwf.btn_tips._visible = false
	objSwf.btn_tips.rollOver = function () TipsManager:ShowBtnTips(StrConfig['cave500'],TipsConsts.Dir_RightDown); end
	objSwf.btn_tips.rollOut = function () TipsManager:Hide(); end

	objSwf.BtnIntegral.click = function() self:ShowIntegralShop();end
end

function UIXianYuanCave:OnShow()
    
   
	-- ActivityController:SendActivityOnLineTime(ActivityConsts.XianYuan);
	ActivityController:SendActivityOnLineTime(ActivityConsts.T_DaBaoMiJing);
	self:OnShowRewardIcon();
	self:OnShowPiLao();
	 self:ShowTrialScore()
end
function UIXianYuanCave:ShowTrialScore()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local playScore=MainPlayerModel.humanDetailInfo.eaTrialScore
	objSwf.Integralhtml.htmlText=playScore;
end
function UIXianYuanCave:OpenPanel(layerid)
	self.layerId=layerid;
	if self:IsShow() then
		self:OnShowInfo();
	else
		self:Show();
	end
end

function UIXianYuanCave:ShowIntegralShop()
	UIShopCarryOn:OpenShopByType(ShopConsts.T_Babel)

	if UIRankRewardView:IsShow() then
		UIRankRewardView:Hide();
	end;
end;
--show界面奖励
function UIXianYuanCave:OnShowRewardIcon()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local lv = MainPlayerModel.humanDetailInfo.eaLevel
	for i, v in ipairs(t_xianyuancave) do
		if v.level <= lv then
			self.RewardIconTable = v.monsterReward
		else
			break
		end
	end
	local rewardList = RewardManager:Parse(self.RewardIconTable);
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(rewardList));
	objSwf.rewardList:invalidateData();
	
	local rewardList2 = RewardManager:Parse(self.RewardIconTable2);
	objSwf.rewardList2.dataProvider:cleanUp();
	objSwf.rewardList2.dataProvider:push(unpack(rewardList2));
	objSwf.rewardList2:invalidateData();
	
end

--show疲劳值
function UIXianYuanCave:OnShowPiLao()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local num = MainPlayerModel.humanDetailInfo.eaPiLao;
	local caveCons	= t_consts[62];
	objSwf.txt_pilao.htmlText = "" --string.format(StrConfig['cave201'],MainPlayerModel.humanDetailInfo.eaPiLao,caveCons.val1);
end

-- --showTips
-- function UIXianYuanCave:OnShowRewardTips(i)
-- 	local indexID = self.RewardIconTable[i];
-- 	if not indexID then return end
-- 	TipsManager:ShowItemTips(indexID);
-- end

--点击进入活动
function UIXianYuanCave:OnCaveClickHandler()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.layerId  then
        self:PalaceActivity()
        return 
	end
	if self.timeKey then
		return
	end
	local func = function ()
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,2000,1);
	
	local pilaoValue = MainPlayerModel.humanDetailInfo.eaPiLao;
	local caveCons	= t_consts[62];
	if pilaoValue >= caveCons.val1 then
		FloatManager:AddNormal( StrConfig["cave551"] );
		return
	end
	local id = 0
	local lv = MainPlayerModel.humanDetailInfo.eaLevel
	for i, v in ipairs(t_xianyuancave) do
		if v.level <= lv then
			id = i
		else
			break
		end
	end
	ActivityController:EnterActivity(ActivityConsts.T_DaBaoMiJing, {param1 = id});
end
function UIXianYuanCave:PalaceActivity()
	
	ActivityController:EnterActivity(ActivityConsts.T_DaBaoMiJing, {param1 = self.layerId});
end
function UIXianYuanCave:IsTween()
	return true;
end

function UIXianYuanCave:GetPanelType()
	return 1;
end

function UIXianYuanCave:IsShowSound()
	return true;
end

function UIXianYuanCave:IsShowLoading()
	return true;
end

function UIXianYuanCave:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.txt_downInfo.htmlText = UIStrConfig['cave200'];
    self.layerId=nil;
	--是否有组队提示,
	--ps : 调用的是活动面板的name,因为进入机制是由活动逻辑来执行的
	TeamUtils:UnRegisterNotice(UIActivity:GetName())
end

function UIXianYuanCave:OnChangeOnLineTxt(id)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local onLineData = self.onLineTimeData;
	if not onLineData or onLineData == {} then
		return 
	end
	local timeNum;
	if not id then
		timeNum = onLineData[ActivityConsts.T_DaBaoMiJing].timeNum;
	else
		if not onLineData[id] then
			return 
		end
		timeNum = onLineData[id].timeNum;
	end
	if not timeNum then return end
	local onLineMin = toint(timeNum/60);
	if onLineMin < 1 then
		objSwf.txt_time.htmlText = StrConfig['cave252'];
	else
		objSwf.txt_time.htmlText = string.format(StrConfig['cave251'],onLineMin);
	end
end

UIXianYuanCave.onLineTimeData = nil;
function UIXianYuanCave:SaveOnLineTime(id,timeNum)
	if not self.onLineTimeData then
		self.onLineTimeData = {};
	end
	if not self.onLineTimeData[id] then
		self.onLineTimeData[id] = {};
	end
	self.onLineTimeData[id].id = id;
	-- if id == ActivityConsts.XianYuan then
	-- 	self.onLineTimeData[id].timeNum = t_activity[ActivityConsts.XianYuan].enter2_time * 60 - timeNum;
	-- elseif id == ActivityConsts.T_DaBaoMiJing then
		self.onLineTimeData[id].timeNum = --[[t_activity[ActivityConsts.T_DaBaoMiJing].enter2_time * 60]] timeNum;
	-- end
	self:OnChangeOnLineTxt();
end

function UIXianYuanCave:HandleNotification(name,body)
	if name == NotifyConsts.CavePiLaoChange then
		self:OnShowPiLao();
	elseif name == NotifyConsts.ActivityOnLineTime then
		trace(body)
		self:SaveOnLineTime(body.id,body.timeNum);
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaTrialScore then
		   self:ShowTrialScore()
		end
	
	end
end
function UIXianYuanCave:ListNotificationInterests()
	return {
		NotifyConsts.CavePiLaoChange,
		NotifyConsts.ActivityOnLineTime,
	}
end