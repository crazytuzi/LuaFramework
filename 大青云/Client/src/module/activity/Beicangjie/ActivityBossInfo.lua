--[[
	2015年4月9日, PM 04:36:29
	第二关的BOSS信息面板
	wangyanwei
]]

_G.UIBeicangjieBossInfo = BaseUI:new('UIBeicangjieBossInfo');

function UIBeicangjieBossInfo:Create()
	self:AddSWF('beicangjieBossInfo.swf',true,'top');
end

function UIBeicangjieBossInfo:OnLoaded(objSwf)
	objSwf.smallPanel.btn_out.click = function () self:OnQuitClick(); end
end

function UIBeicangjieBossInfo:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local func = function(count)
		objSwf.smallPanel.txt_time.text = self:OnBackNowLeaveTime(300 - count);
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000,300);
end

function UIBeicangjieBossInfo:GetWidth()
	return 236
end

function UIBeicangjieBossInfo:GetHeight()
	return 304
end

function UIBeicangjieBossInfo:OnBackNowLeaveTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if hour < 10 then hour = '0' .. hour; end
	if min < 10 then min = '0' .. min; end
	if sec < 10 then sec = '0' .. sec; end
	return hour .. ':' .. min .. ":" .. sec
end

function UIBeicangjieBossInfo:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

--退出活动
function UIBeicangjieBossInfo:OnQuitClick()
	local func = function ()
		ActivityBeicangjie:OnGetRewardQuit();
	end
	UIConfirm:Open(StrConfig['cave002'],func);
end