--[[
竞技场结束面板
wangshuai
]]

_G.UIArenaResult = BaseUI:new("UIArenaResult")
	
UIArenaResult.fun = nil;


UIArenaResult.timerKey = nil;
UIArenaResult.time = 30;


function UIArenaResult:Create()
	self:AddSWF("arenaResultspanel.swf",true,"story")
end;

function UIArenaResult:OnLoaded(objSwf)
	objSwf.out_btn.click = function () self:OutBtnClick()end;
	
end;

function UIArenaResult:Ontimer()
	if not self.bShowState then return; end
	self.time = self.time - 1;
	local objSwf = self.objSwf;
	objSwf.lastTimer.htmlText = string.format(StrConfig["arena140"],self.time)
	if self.time <= 0 then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
		self:Hide();
	end;
end;

function UIArenaResult:OnShow()
	local objSwf = self.objSwf;
	self.time = 30;
	objSwf.lastTimer.htmlText = string.format(StrConfig["arena140"],self.time)
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function()self:Ontimer() end,1000,self.time);
	self:SetData()
end;
function UIArenaResult:SetData()
	local objSwf = self.objSwf;
	local result = ArenaBattle.winId
	local rolelvl = MainPlayerModel.humanDetailInfo.eaLevel

	if result == 1  then 
		-- 成功
		local cfg = t_jjcPrize[rolelvl].win;
		local list = split(cfg, "#");
		local list1 = split(list[1], ",")
		local list2 = split(list[2], ",")
		local info = ArenaModel:GetFigInfo().rank;
		objSwf.victory.ChalNum.htmlText = tostring(info)
		objSwf.exp.htmlText = string.format(StrConfig["arena132"],"#00ff00", t_item[toint(list1[1])].name, list1[2]); 
		objSwf.honor.htmlText = string.format(StrConfig["arena133"],"#00ff00", t_item[toint(list2[1])].name, list2[2]); 
		objSwf.victory._visible = true;
		objSwf.failure._visible = false;

		objSwf.victory.victorynoRank._visible = false;
		objSwf.victory.ChalNum._visible = true;
		objSwf.victory.rankup._visible =true;

		local rank = ArenaModel:GetCurBeRole();
		local myrank = ArenaModel:GetCurRank();
		if myrank < rank then 
			objSwf.victory.victorynoRank._visible = true;
			objSwf.victory.ChalNum._visible = false;
			objSwf.victory.rankup._visible =false;
		end;

		SoundManager:PlaySfx(2019);

	else
		-- 失败
		local cfg = t_jjcPrize[rolelvl].lose;
		local list = split(cfg, "#");
		local list1 = split(list[1], ",")
		local list2 = split(list[2], ",")
		objSwf.exp.htmlText = string.format(StrConfig["arena142"],"#C8C8C8",t_item[toint(list1[1])].name, list1[2]); 
		objSwf.honor.htmlText = string.format(StrConfig["arena143"],"#C8C8C8",t_item[toint(list2[1])].name, list2[2]); 
		objSwf.failure._visible = true;
		objSwf.victory._visible = false;
		SoundManager:PlaySfx(2020);
	end;

--[[

	local vo = ArenaModel:GetFigInfo();
	if vo.result == 1 then 
		--失败0
		objSwf.exp.htmlText = string.format(StrConfig["arena132"],"#646464",vo.exp); 
		objSwf.honor.htmlText = string.format(StrConfig["arena133"],"#646464",vo.honor); 
		objSwf.failure._visible = true;
		objSwf.victory._visible = false;
	elseif vo.result == 0 then 
		--成功
		local info = ArenaModel:GetFigInfo().rank;
		objSwf.victory.ChalNum.num = tostring(info)
		objSwf.exp.htmlText = string.format(StrConfig["arena132"],"#29cc00",vo.exp); 
		objSwf.honor.htmlText = string.format(StrConfig["arena133"],"#29cc00",vo.honor); 
		objSwf.victory._visible = true;
		objSwf.failure._visible = false;
	end;]]


end;
-- 退出按钮
function UIArenaResult:OutBtnClick()
	self:Hide();
end;
function UIArenaResult:OnHide()
	self.fun();
end;
function UIArenaResult:setShow(fun)
	self.fun = fun;
	self:Show();
end;