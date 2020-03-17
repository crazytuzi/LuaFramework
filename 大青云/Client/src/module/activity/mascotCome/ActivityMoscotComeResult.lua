--[[
	2015年10月21日22:31:58
	wangyanwei
	抢门结局
]]

_G.UIMoscotComeResult = BaseUI:new('UIMoscotComeResult');

function UIMoscotComeResult:Create()
	self:AddSWF('mascotComeResult.swf',true,'center');
end

function UIMoscotComeResult:OnLoaded(objSwf)
	objSwf.btn_quit.click = function ()
		ActivityController:QuitActivity(ActivityController:GetCurrId());
		ActivityMascotCome.currentChooseMascotComeActivityID = 0;
	end
end

function UIMoscotComeResult:OnShow()
	self:OnTimeChange();
	self:ShowResult();
end

function UIMoscotComeResult:ShowResult()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local resultState = ActivityMascotCome:GetResult();
	objSwf.win._visible = resultState == 0;
	objSwf.lose._visible = resultState ~= 0;
	if resultState == 0 then
		objSwf.txt_info.text = StrConfig['mascotCome0010'];
	else
		objSwf.txt_info.text = StrConfig['mascotCome0011'];
	end
end

function UIMoscotComeResult:OnTimeChange()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local timeNum = 30;
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local func = function()
		objSwf.txt_time.htmlText = string.format(StrConfig['mascotCome004'],timeNum);
		if timeNum <= 0 then
			-- ActivityController:QuitActivity(ActivityConsts.MascotCome);
			local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
			if not activity then return; end
			if activity:GetType() ~= ActivityConsts.T_MascotCome then return; end
			ActivityController:QuitActivity(activity:GetId());
			ActivityMascotCome.currentChooseMascotComeActivityID = 0;
			return
		end
		timeNum = timeNum - 1;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

function UIMoscotComeResult:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end