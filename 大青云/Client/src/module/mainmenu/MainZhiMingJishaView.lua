--[[
	文本致命击杀 
	wangshuai
	特效
]]


_G.UIZhimingjishaPfx = BaseUI:new("UIZhimingjishaPfx");

UIZhimingjishaPfx.sk = 0;
UIZhimingjishaPfx.exp = 0;
UIZhimingjishaPfx.isShowBo = false;
function UIZhimingjishaPfx:Create() 
	self:AddSWF("zhiMingJiShaTextpanel.swf",true,"scene")
end
function UIZhimingjishaPfx:OnLoaded(objSwf)
	objSwf.hitTestDisable = true;
end;

function UIZhimingjishaPfx:SetInfo(sk,exp)
	self.sk = sk;
	self.exp = exp;
	if sk == 0 or exp == 0 then 
		return ;
	end;
	self:Show();
end;
function UIZhimingjishaPfx:OnShow()
	local objSwf = self.objSwf;
	local Namenum = 0;
	if self.sk >= 1 and self.sk <= 5 then 
		-- 势如破竹
		Namenum = 1;
	elseif self.sk >= 6 and self.sk <= 10 then 
		--  杀人如麻
		Namenum = 2;
	elseif self.sk >= 11 and self.sk <= 15 then 
		-- 无人能挡
		Namenum = 3;
	elseif self.sk >= 16 and self.sk <= 20 then 
		-- 天下无双
		Namenum = 4;
	elseif self.sk >= 21 then 
		-- 尽屠神魔
		Namenum = 5;
	end;
	if Namenum <= 0 then
		self:Hide();
		return;
	end;

	local strurl = ResUtil:GetShaYiZhiNameURL(Namenum)

	objSwf.shayiName.source = strurl;
	objSwf.num.text = self.sk
	objSwf.exp.text = self.exp
		TimerManager:RegisterTimer(function()
		self.isShowBo = true;
		--self:Hide();
	end,2000,1);
end;
function UIZhimingjishaPfx:Update()
	if not self.bShowState then return end;
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	-- local vx,vy = UIManager:GetWinSize();
	-- local vvx = vx/2 - 200;
	-- local vvy = vy/2 + 200;
	-- objSwf._x = vvx;
	-- objSwf._y = vvy;

	-- 渐出
	if self.isShowBo == true then 
		objSwf._alpha = objSwf._alpha - 1;
		if objSwf._alpha <= 0 then 
			self.isShowBo = false;
			self:Hide();
			objSwf._alpha = 100;
		end;
	end;
end;