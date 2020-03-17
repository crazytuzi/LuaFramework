--[[连杀界面面板
liyuan
2014年10月11日10:33:06
]]

_G.UIMultiCutEffect = BaseUI:new("UIMultiCutEffect") 
UIMultiCutEffect.killNum = 0
UIMultiCutEffect.timerID = nil;
UIMultiCutEffect.DelaytimerID = nil;
UIMultiCutEffect.playEffectTime = 5000
UIMultiCutEffect.playTimeCfg = {}
UIMultiCutEffect.alphaChange = 0

function UIMultiCutEffect:Create()
	self:AddSWF("miltiCutEffect.swf", true, "scene")
	self:InitPlayTimeCfg()
end

function UIMultiCutEffect:InitPlayTimeCfg()
	local timeList = {}
	local playTimeArr = {}
	timeList = split(t_consts[2].param, '#')
	for index, timeStr in pairs(timeList) do
		playTimeArr = split(timeStr, ',')
		self.playTimeCfg[toint(playTimeArr[1])] = toint(playTimeArr[2])
	end
end

function UIMultiCutEffect:OnLoaded(objSwf,name)
	-- objSwf.hitTestDisable = true;
	-- objSwf.effectXuetiao.hitTestDisable = true;
	-- objSwf.mc_num.hitTestDisable = true;
	objSwf.btntips.rollOver = function() self:OnTipsOver()end;
	objSwf.btntips.rollOut = function() TipsManager:Hide(); end;
end
function UIMultiCutEffect:OnTipsOver()

	local curnum =toint(50*(math.floor(self.killNum/50)+1)-self.killNum)
	local time = (0.1*(self.killNum/50)+2.9);
	time = string.format("%.1f", time) 
	TipsManager:ShowBtnTips(string.format(StrConfig["shayizhitips001"],self.killNum,curnum,time));
end;
function UIMultiCutEffect:OnHide()
	self.killNum = 0
	self.alphaChange = 0
	
	if self.timerID then
		TimerManager:UnRegisterTimer(self.timerID);
	end
	
	if self.DelaytimerID then
		TimerManager:UnRegisterTimer(self.DelaytimerID);
	end
end

function UIMultiCutEffect:OnShow(name)
	self.objSwf._alpha = 100
	self.alphaChange = 0
	self:UpdateEffect()
end

function UIMultiCutEffect:UpdateEffect()
	
	if self.timerID then
		TimerManager:UnRegisterTimer(self.timerID);
	end
	
	if self.DelaytimerID then
		TimerManager:UnRegisterTimer(self.DelaytimerID);
	end
	
	if self.killNum > 0 then
		-- SpiritsUtil:Print(self.killNum)
		local objSwf = self.objSwf
	
		local playTime = self:GetEffectTime(self.killNum)
		if not playTime then
			playTime = UIMultiCutEffect.playEffectTime
		end
		if self.xuetiaoTimeId then
			TimerManager:UnRegisterTimer(self.xuetiaoTimeId);
		end
		objSwf.effectXuetiao:setTotalTime(playTime)
		
		-- objSwf.effectZi:playEffect(1)
		-- objSwf.effectXuetiao:gotoAndStopEffect(29)
		
		-- objSwf.mcCutNum.num = self.killNum
		
		-- for j=1, 3 do
			-- objSwf.mc_num['ta_'..j].txtNum.htmlText = ''
		-- end
		objSwf.mc_num:playEffect()
		local s = tostring(math.min(self.killNum,999))
		objSwf.mc_num.killNums.num = s

		
		-- local slen = string.len(s)
		-- if slen == 1 then
			-- objSwf.mc_num['ta_'..3].txtNum.htmlText = "<img src='img://resfile/num/nu"..string.sub(s, 1, 1)..".png'/>"
		-- elseif slen == 2 then
			-- objSwf.mc_num['ta_'..2].txtNum.htmlText = "<img src='img://resfile/num/nu"..string.sub(s, 1, 1)..".png'/>"
			-- objSwf.mc_num['ta_'..3].txtNum.htmlText = "<img src='img://resfile/num/nu"..string.sub(s, 2, 2)..".png'/>"
		-- elseif slen == 3 then
			-- for j=1, string.len(s) do 
				-- objSwf.mc_num['ta_'..j].txtNum.htmlText = "<img src='img://resfile/num/nu"..string.sub(s, j, j)..".png'/>"
			-- end
		-- end
		objSwf.mcCutEffect:playEffect(1)
		self.xuetiaoTimeId = TimerManager:RegisterTimer(function()
			self:PlayerXuetiaoAni()
		end,250,1)
		--objSwf.effectXuetiao:playEffect(1)
		self.timerID = TimerManager:RegisterTimer(function()
			self:RemoveHideAnim()
		end,playTime,1)
		
		-- self.DelaytimerID = TimerManager:RegisterTimer(function()
			-- self:StartAni()
		-- end,2000,1)
	end
end

function UIMultiCutEffect:PlayerXuetiaoAni()
	if not self.objSwf then return end
	if self.xuetiaoTimeId then
		TimerManager:UnRegisterTimer(self.xuetiaoTimeId);
	end
	self.objSwf.effectXuetiao:playEffect(1)
end	

function UIMultiCutEffect:GetEffectTime(cutNum)
	local cutTime = 0
	if cutNum <= 100 then
		cutTime = self:GetTimeByCfgNum(100)
	elseif cutNum <= 200 then
		cutTime = self:GetTimeByCfgNum(200)
	elseif cutNum <= 300 then
		cutTime = self:GetTimeByCfgNum(300)
	elseif cutNum <= 400 then
		cutTime = self:GetTimeByCfgNum(400)
	elseif cutNum <= 500 then
		cutTime = self:GetTimeByCfgNum(500)
	elseif cutNum <= 600 then
		cutTime = self:GetTimeByCfgNum(600)
	elseif cutNum <= 700 then
		cutTime = self:GetTimeByCfgNum(700)
	elseif cutNum <= 800 then
		cutTime = self:GetTimeByCfgNum(800)
	elseif cutNum <= 900 then
		cutTime = self:GetTimeByCfgNum(900)
	else
		cutTime = self:GetTimeByCfgNum(1000)
	end
	
	-- SpiritsUtil:Print('连斩的播放时间:'..cutTime)
	return cutTime
end
function UIMultiCutEffect:GetTimeByCfgNum(cutCfgNum)
	return self.playTimeCfg[cutCfgNum]
end

function UIMultiCutEffect:RemoveHideAnim()
	-- self:Hide()
	if not self.objSwf then return end
	self.alphaChange = -2
end

function UIMultiCutEffect:Update()
	if not self.bShowState then return end
	if not self.objSwf then return end
	if self.alphaChange == 0 then return end
	self.objSwf._alpha = self.objSwf._alpha + self.alphaChange
	if self.objSwf._alpha <= 0 then self:Hide() end
end

function UIMultiCutEffect:GetWidth(szName)
	return 380 
end

function UIMultiCutEffect:GetHeight(szName)
	return 160
end

function UIMultiCutEffect:NeverDeleteWhenHide()
	return true;
end
