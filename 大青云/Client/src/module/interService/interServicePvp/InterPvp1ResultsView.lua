--[[
结束面板
]]

_G.UIInterPvp1Result = BaseUI:new("UIInterPvp1Result")
	
UIInterPvp1Result.fun = nil;


UIInterPvp1Result.timerKey = nil;
UIInterPvp1Result.time = 30;


function UIInterPvp1Result:Create()
	self:AddSWF("interPvp1Resultspanel.swf",true,"interserver")
end;

function UIInterPvp1Result:OnLoaded(objSwf)
	objSwf.out_btn.click = function () self:OutBtnClick()end;
	objSwf.victory.victorynoRank._visible = false;
	objSwf.victory.rankup._visible =false;
	objSwf.victory.ChalNum._visible = false;
end;

function UIInterPvp1Result:Ontimer()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if not self.bShowState then return; end
	self.time = self.time - 1;
	
	objSwf.lastTimer.htmlText = string.format(StrConfig["arena140"],self.time)
	if self.time <= 0 then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
		self:Hide();
	end;
end;

function UIInterPvp1Result:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.time = 30;
	objSwf.lastTimer.htmlText = string.format(StrConfig["arena140"],self.time)
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function()self:Ontimer() end,1000,self.time);
	self:SetData()
end;
function UIInterPvp1Result:SetData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local result = self.pvpResult
	local rolelvl = MainPlayerModel.humanDetailInfo.eaLevel
	
	local duanwei = MainPlayerModel.humanDetailInfo.eaCrossDuanwei or 5; --段位
	local T_Name = "t_kuafudan"..Version:GetName();
	local KuaFuDanT = nil;
	if _G[T_Name] then
		KuaFuDanT = _G[T_Name];
	else
		KuaFuDanT = t_kuafudanyouxi;
		print("Error:cannot find t_kuafudan cfg by current version.")
	end
	local cfg = KuaFuDanT[duanwei]
	local myInfo = InterServicePvpModel:GetMyroleInfo()
	local remainTime = myInfo.remaintimes or 0
	local num = t_consts[105].val1 - remainTime
	
	
	if result == 0  then 
		-- 成功
		if num < t_consts[105].val2 then
			objSwf.exp.htmlText = string.format(StrConfig["interServiceDungeon4"],"#29cc00",cfg.base*2); 
		else
			objSwf.exp.htmlText = string.format(StrConfig["interServiceDungeon4"],"#29cc00",cfg.base); 
		end
		
		
		objSwf.honor.htmlText = string.format(StrConfig["interServiceDungeon5"],"#29cc00",cfg.winExploit); 
		objSwf.victory._visible = true;
		objSwf.failure._visible = false;
		SoundManager:PlaySfx(2019);
	else
		-- 失败
		if num < t_consts[105].val2 then
			objSwf.exp.htmlText = string.format(StrConfig["interServiceDungeon4"],"#646464",cfg.lowest*2); 
		else		
			objSwf.exp.htmlText = string.format(StrConfig["interServiceDungeon4"],"#646464",cfg.lowest);
		end
		
		objSwf.honor.htmlText = string.format(StrConfig["interServiceDungeon5"],"#646464",cfg.loseExploit); 
		objSwf.failure._visible = true;
		objSwf.victory._visible = false;
		SoundManager:PlaySfx(2020);
	end;
end;
-- 退出按钮
function UIInterPvp1Result:OutBtnClick()	
	self:Hide();
end;
function UIInterPvp1Result:OnHide()
	self.fun();
end;
function UIInterPvp1Result:setShow(pvpResult, fun)
	self.pvpResult = pvpResult
	self.fun = fun;
	self:Show();
end;