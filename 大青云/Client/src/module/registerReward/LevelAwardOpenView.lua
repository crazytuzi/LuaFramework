--[[
登陆奖励面板：等级奖励提示框
zhangshuhui
2015年7月14日14:15:00
]]

_G.UILevelAwardOpen = BaseUI:new("UILevelAwardOpen");

--升级前的
UILevelAwardOpen.giftLvl = 0;

UILevelAwardOpen.showLvlMax = 90;

UILevelAwardOpen.timerKey = nil;
UILevelAwardOpen.lasttimer = nil;
UILevelAwardOpen.isreq = false;

function UILevelAwardOpen:Create()
	if Version:IsLianYun() then
		-- self:AddSWF("levelRewardOpenPanelLianYun.swf",true,"bottom");
		self:AddSWF("levelRewardOpenPanel.swf",true,"bottom");
	else
		self:AddSWF("levelRewardOpenPanel.swf",true,"bottom");
	end
end

function UILevelAwardOpen:OnLoaded(objSwf)
	objSwf.btnopen.click            = function() self:OnBtnOpenClick(); end
	objSwf.numLevel1.loadComplete = function() self:OnLevelLoaded() end
	objSwf.btnClose.click           = function() self:OnBtnCloseClick(); end
	--TIP
	RewardManager:RegisterListTips(objSwf.rewardList);
end

function UILevelAwardOpen:OnLevelLoaded()
	local objSwf = self.objSwf
	if not objSwf then return end
	local numLoader = objSwf.numLevel1
	-- objSwf.imglevel._x = numLoader._x + numLoader._width
end

function UILevelAwardOpen:IsShowLoading()
	return false;
end

function UILevelAwardOpen:GetPanelType()
	return 0;
end

function UILevelAwardOpen:IsShowSound()
	return true;
end


function UILevelAwardOpen:OnShow()
	self:ShowLevelAwardInfo();
end

--点击关闭按钮
function UILevelAwardOpen:OnBtnCloseClick()
	self:Hide();
end

--获取礼包
function UILevelAwardOpen:OnBtnOpenClick()
	if UILevelAwardOpen.isreq then return; end
	--是否已领奖
	if RegisterAwardUtil:GetIsRewarded(self.giftLvl) then
		self:Hide();
		return;
	end
	RegisterAwardController:ReqGetLvlAward(self.giftLvl);
	UILevelAwardOpen.isreq = true;
end

function UILevelAwardOpen:GetWidth()
	return 800;
end

function UILevelAwardOpen:GetHeight()
	return 245;
end

function UILevelAwardOpen:OnHide()
	self:DelTimerKey();
end

---------------------------------消息处理------------------------------------
function UILevelAwardOpen:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.LevelAwardChange then
		self:UpdateLevelState(body);
		self:Hide();
	end
end

function UILevelAwardOpen:ListNotificationInterests()
	return {NotifyConsts.LevelAwardChange};
end

--显示礼包信息
function UILevelAwardOpen:ShowLevelAwardInfo()
	
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	
	objSwf.numLevel1.num = playerinfo.eaLevel;
	-- objSwf.txtLevelInfo.htmlText = string.format( StrConfig['registerReward14'], self.giftLvl);
	
	--奖励
	if not t_lvreward[self.giftLvl] then
		return
	end
	local rl = RewardManager:Parse(t_lvreward[self.giftLvl].itemreward);
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(rl));
	objSwf.rewardList:invalidateData();
	local itemList = {};
	itemList[1] = objSwf.item1;
	itemList[2] = objSwf.item2;
	itemList[3] = objSwf.item3;
	itemList[4] = objSwf.item4;
	itemList[5] = objSwf.item5;
	itemList[6] = objSwf.item6;	
    UIDisplayUtil:HCenterLayout(#rl, itemList, 64, 610, 220);
	itemList = nil;		
	self:StartTimer();
end

--显示礼包信息
function UILevelAwardOpen:OpenPanel(oldVal)
	if oldVal >= self.showLvlMax then
		return;
	end
	local giftlevel = RegisterAwardUtil:GetIsOpenLevelRewardGift(oldVal);
	if giftlevel == 0 then
		return;
	end
	if giftlevel > self.showLvlMax then
		giftlevel = self.showLvlMax;
	end
	self.giftLvl = giftlevel;
	self.lasttimer = 20;
	self.isreq = false;
	
	
	if self:IsShow() then
		self:ShowLevelAwardInfo();
	else
		self:Show();
	end
end

--更新状态
function UILevelAwardOpen:UpdateLevelState(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if UILevelAward:IsShow() then
		return;
	end
	
	--奖励
	local rewardList = RewardManager:ParseToVO(t_lvreward[self.giftLvl].itemreward);
	local startPos = UIManager:PosLtoG(objSwf.rewardList,0,0);
	RewardManager:FlyIcon(rewardList,startPos,5,true,60);
end

--wqn增加的自动关闭倒计时，到此一游
local autoCloseTime = 10;
function UILevelAwardOpen:StartTimer()
	-- if self.timerKey then 
		-- TimerManager:UnRegisterTimer(self.timerKey);
		-- self.timerKey = nil;
	-- end;
	-- self.timerKey = TimerManager:RegisterTimer(self.OnTimer,1000,0);
	
	self.objSwf.timetext.htmlText = string.format(StrConfig["bag63"], autoCloseTime);
	self.timerKey = TimerManager:RegisterTimer(function(curTimes)
		if self.objSwf then
			self.objSwf.timetext.htmlText = string.format(StrConfig["bag63"], autoCloseTime - curTimes);
		end
		if curTimes >= autoCloseTime then
			--这里关闭代码 
			self.timerKey = nil;
			self:OnBtnOpenClick();
		end
	end,1000,autoCloseTime);
end

function UILevelAwardOpen:DelTimerKey()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end

--计时器
function UILevelAwardOpen:OnTimer()
	UILevelAwardOpen.lasttimer = UILevelAwardOpen.lasttimer - 1;
	
	if UILevelAwardOpen.isreq == false then
		if UILevelAwardOpen.lasttimer <= 0 then
			--是否已领奖
			if RegisterAwardUtil:GetIsRewarded(UILevelAwardOpen.giftLvl) then
				UILevelAwardOpen:Hide();
				return;
			end
	
			RegisterAwardController:ReqGetLvlAward(UILevelAwardOpen.giftLvl);
			UILevelAwardOpen.isreq = true;
		end
	end
end