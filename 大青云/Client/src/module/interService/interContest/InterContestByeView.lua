--[[
	2015年12月30日00:07:47
	wangyanwei
	轮空
]]
_G.UIInterConterBye = BaseUI:new('UIInterConterBye');

function UIInterConterBye:Create()
	self:AddSWF('interContestBye.swf',true,'center');
end

function UIInterConterBye:OnLoaded(objSwf)
	objSwf.btn_enter.click = function () self:Hide(); end
	objSwf.txtInfo.text = StrConfig['interServiceDungeon301'];
end

function UIInterConterBye:OnShow()
	self:OnTime();
end

function UIInterConterBye:OnTime()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cont = 30;
	local func = function ()
		cont = cont - 1;
		objSwf.txt_time.htmlText = string.format(StrConfig['interServiceDungeon302'],cont);
		if cont == 0 then
			self:Hide();
		end
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
	func();
end

function UIInterConterBye:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil
	end
end