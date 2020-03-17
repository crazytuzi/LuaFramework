--[[
	2015年6月24日, PM 02:55:32
	结局面板
	wangyanwei
]]

_G.UIExtremitChallengeResult = BaseUI:new('UIExtremitChallengeResult');

function UIExtremitChallengeResult:Create()
	self:AddSWF('extremitChallengeInfoResult.swf',true,'center')
end

function UIExtremitChallengeResult:OnLoaded(objSwf)
	objSwf.btn_quit.click = function () ExtremitChallengeController:OnSendQuitExtremity(); end
end

function UIExtremitChallengeResult:OnShow()
	self:OnChangeTime();
	self:OnDrawPanel();
end

function UIExtremitChallengeResult:OnDrawPanel()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.bossTf._visible = self.state == 0;
	objSwf.monsterTf._visible = self.state == 1;
	if objSwf.bossTf._visible then
		objSwf.txt_num.text = getNumShow(self.num);
	else
		objSwf.txt_num.text = self.num;
	end
	objSwf.txt_rank.text = self.rankNum;
end

UIExtremitChallengeResult.state = nil;
UIExtremitChallengeResult.num = nil;
UIExtremitChallengeResult.rankNum = nil;
function UIExtremitChallengeResult:Open(state,num)
	self.state = state;
	self.num = num;
	self.rankNum = ExtremitChallengeModel:OnGetRankNum()
	self:Show();
end

UIExtremitChallengeResult.timeNum = 0;
function UIExtremitChallengeResult:OnChangeTime()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.timeNum = 30;
	local func = function ()
		self.timeNum = self.timeNum - 1;
		objSwf.txt_time.htmlText = string.format(StrConfig['extremitChalleng011'],self.timeNum);
		if self.timeNum == 0 then 
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			ExtremitChallengeController:OnSendQuitExtremity();
		end
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

function UIExtremitChallengeResult:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.timeKey then 
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	objSwf.txt_time.htmlText = string.format(StrConfig['extremitChalleng011'],30);
end