--[[
	2015年9月8日, PM 10:14:40
	自动挂机提示
]]

_G.UIAutoBattleTip = BaseUI:new('UIAutoBattleTip');

UIAutoBattleTip.AutoBattleTimeNunConsts = 5000;--第一次进入自动战斗的倒计时

function UIAutoBattleTip:Create()
	self:AddSWF('autoBattleTip.swf',true,'bottom');
end

function UIAutoBattleTip:OnLoaded(objSwf)
	objSwf.btn_openAuto.click = function () self:OpenAutoClick(); end
end

function UIAutoBattleTip:OnShow()
	self:StartTimeAuto();
end

--@param func 回调方法
--@param isFirst 是否第一次进入副本  将开始计时自动战斗
UIAutoBattleTip.autoFunc = nil;
UIAutoBattleTip.isFirst = nil;
function UIAutoBattleTip:Open(func,isFirst)
	if not func then return end
	if self.autoFunc then self.autoFunc = nil end
	self.autoFunc = func;
	if not isFirst then
		self.isFirst = false;
	else
		self.isFirst = isFirst;
	end
	self:Show();
end

function UIAutoBattleTip:StartTimeAuto()
	if not self.isFirst then
		if self.timeKey then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
		return
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
	end
	self.timeKey = TimerManager:RegisterTimer(function()
		self.autoFunc();
		UIAutoBattleTxt:Hide();
		self:Hide();
	end,self.AutoBattleTimeNunConsts,1);
end

function UIAutoBattleTip:OnHide()
	if self.autoFunc then
		self.autoFunc = nil;
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

function UIAutoBattleTip:OpenAutoClick()
	if not self.autoFunc then
		return
	end
	UIAutoBattleTxt:Hide();
	self.autoFunc();
	self:Hide();
end