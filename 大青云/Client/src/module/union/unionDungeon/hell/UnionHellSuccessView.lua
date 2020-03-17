--[[
帮派副本-地宫炼狱挑战成功提示界面
2015年1月9日15:38:48
haohu
]]

_G.UIUnionHellSuccess = BaseUI:new("UIUnionHellSuccess");

function UIUnionHellSuccess:Create()
	self:AddSWF("unionHellSuccessPanel.swf", true, "center");
end

function UIUnionHellSuccess:OnLoaded(objSwf)
	objSwf.btnQuit.click = function() self:OnBtnQuitClick(); end
	objSwf.btnContinue.click = function() self:OnBtnContinueClick(); end
	objSwf.btnClose.click = function() self:OnBtnQuitClick(); end
	RewardManager:RegisterListTips(objSwf.list);
end

function UIUnionHellSuccess:OnShow()
	self:InitShow();
	self:StartTimer();
end

function UIUnionHellSuccess:InitShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtMyTime.htmlText = string.format( StrConfig['unionhell039'], SitUtils:ParseTime(self.usedTime) );
	objSwf.txtBestTime.htmlText = string.format( StrConfig['unionhell042'], SitUtils:ParseTime(self.bestTime) );
	local list = objSwf.list;
	list.dataProvider:cleanUp();
	local rewardList = UnionDungeonHellUtils:GetRewardProvider( UIUnionHellScene.stratumId );
	for i = 1, #rewardList do
		list.dataProvider:push( rewardList[i] );
	end
	list:invalidateData();
end

function UIUnionHellSuccess:OnHide()
	self:StopTimer();
end

function UIUnionHellSuccess:OnBtnQuitClick()
	self:Quit();
end

function UIUnionHellSuccess:OnBtnContinueClick()
	self:Continue()
end

function UIUnionHellSuccess:Continue()
	UnionDungeonHellController:Continue();
end

function UIUnionHellSuccess:Quit()
	UnionDungeonHellController:Quit();
end

local timerKey;
local time;
function UIUnionHellSuccess:StartTimer()
	time = UnionHellConsts.ResultPanelTime;
	local cb = function(count)
		self:OnTimer(count);
	end
	timerKey = TimerManager:RegisterTimer( cb, 1000, 0 );
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtCountDown.htmlText = string.format( StrConfig['babel001'], time );
end

function UIUnionHellSuccess:OnTimer(count)
	time = time - 1;
	if time == 0 then
		self:OnTimeUp();
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtCountDown.htmlText = string.format( StrConfig['babel001'], time );
end

function UIUnionHellSuccess:OnTimeUp()
	self:StopTimer();
	self:Continue();
end

function UIUnionHellSuccess:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer(timerKey);
		timerKey = nil;
	end
end


---------------------------------------------------
-- @param usedTime:本次用时
-- @param bestTime:最佳用时
function UIUnionHellSuccess:Open( usedTime, bestTime )
	self.usedTime = usedTime;
	self.bestTime = bestTime;
	if self:IsShow() then
		self:InitShow();
	else
		self:Show();
	end
end