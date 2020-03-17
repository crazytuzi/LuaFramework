--[[
	2015年8月18日, PM 11:02:53
	wangyanwei
	功能tip
]]

_G.DominateRouteFuncTip = BaseUI:new('DominateRouteFuncTip');

function DominateRouteFuncTip:Create()
	self:AddSWF('dominateRouteFuncTip.swf',true,'bottomFloat');
end

function DominateRouteFuncTip:OnLoaded(objSwf)
	-- objSwf.btn_close.click = function () self:Hide(); end
	-- objSwf.btn_open.click = function () FuncManager:OpenFunc(FuncConsts.DominateRoute); self:Hide(); end
end

function DominateRouteFuncTip:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local func = FuncManager:GetFunc(FuncConsts.DominateRoute);
	if not func then return end
	local posCfg = func:GetBtnGlobalPos();
	objSwf._x = posCfg.x;
	objSwf._y = posCfg.y;
	self:playEffect();
end

function DominateRouteFuncTip:playEffect( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.mcGirl._visible = true;
	objSwf.mcGirl:gotoAndPlay(1);
end

function DominateRouteFuncTip:OnResize()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(function ()
		local func = FuncManager:GetFunc(FuncConsts.DominateRoute);
		if not func then return end
		local posCfg = func:GetBtnGlobalPos();
		objSwf._x = posCfg.x;
		objSwf._y = posCfg.y;
		self.timeKey = nil;
	end,200,1);
end

function DominateRouteFuncTip:Update( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	local func = FuncManager:GetFunc(FuncConsts.DominateRoute);
	if not func then return end
	local posCfg = func:GetBtnGlobalPos()
	if not posCfg then return end
	local pos = -10000
	if objSwf._x ~= posCfg.x then
		objSwf._x = posCfg.x or pos
	end
	if objSwf._y ~= posCfg.y then
		objSwf._y = posCfg.y or pos
	end
end

function DominateRouteFuncTip:Open()
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	if level <= 800 then   --暂时屏蔽功能提示
		return
	end
	-- if level < 40 or level > 100 then
	-- 	return
	-- end
	local isShow = DominateRouteModel:CheckFirstRewardState()
	if not isShow then return end
	-- local enterNum = DominateRouteModel:OnGetEnterNum();
	-- if enterNum < 1 then return end
	-- local maxIndex,roadIndex = DominateRouteModel:OnGetMaxDominateData();
	-- local id = maxIndex * DominateRouteModel.StageConstsNum + roadIndex;
	-- local cfg = t_zhuzairoad[id];
	-- if not cfg then return end
	-- local num = MainPlayerModel.humanDetailInfo.eaDominJingLi;  --精力
	-- if num < cfg.level_energy then return end
	-- print("--------+_+_+_+_+-",isShow)
	-- debug.debug()
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function DominateRouteFuncTip:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.mcGirl._visible = false;
	objSwf.mcGirl:gotoAndStop(1);
end