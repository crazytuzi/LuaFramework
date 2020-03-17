--[[
	2015年11月1日17:04:14
	wangyanwei
]]

_G.UIPersonalResult = BaseUI:new('UIPersonalResult');

function UIPersonalResult:Create()
	self:AddSWF('personalbossResultPanel.swf',true,'center');
end

function UIPersonalResult:OnLoaded(objSwf)
	objSwf.btn_quit.click = function () DropItemController:PickUpItemAll(); PersonalBossController:SendQuitPersonalBoss(); end
	objSwf.winReward.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.winReward.rewardList.itemRollOut = function () TipsManager:Hide(); end
end

function UIPersonalResult:OnShow()
	self:ShowResult();
	self:TimeChange();
end

function UIPersonalResult:TimeChange()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local timeNum = 30;
	local func = function()
		timeNum = timeNum - 1;
		if timeNum < 1 then
			PersonalBossController:SendQuitPersonalBoss();
		end
		if timeNum < 0 then timeNum = 0 end
		objSwf.txt_time.htmlText = string.format(StrConfig['personalboss12'],timeNum);
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

UIPersonalResult.winState = nil;
UIPersonalResult.isFirst = nil;
function UIPersonalResult:Open(result,isFirst)
	if not result then return end
	if self:IsShow() then return end
	self.winState = result ;
	self.isFirst = isFirst ;
	self:Show();
end

function UIPersonalResult:ShowResult()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local winState = self.winState == 0 and true or false;	--0胜利
	
	objSwf.lose._visible = not winState;
	objSwf.win._visible = winState;
	
	local personalbossID = PersonalBossModel:OnGetPersonalBossID();
	if not personalbossID then return end
	
	local cfg = t_personalboss[personalbossID];
	if not cfg then return end
	
	objSwf.winReward._visible = winState;
	
	if not winState then return end
	local isFirst = false --self.isFirst == 0 and true or false;	--0胜利
	if not isFirst then objSwf.winReward._visible = false; return end
	local randomList = RewardManager:Parse( cfg.firstReward );
	objSwf.winReward.rewardList.dataProvider:cleanUp();
	objSwf.winReward.rewardList.dataProvider:push(unpack(randomList));
	objSwf.winReward.rewardList:invalidateData();
end

function UIPersonalResult:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

function UIPersonalResult:GetWidth()
	return 789
end

function UIPersonalResult:GetHeight()
	return 269
end