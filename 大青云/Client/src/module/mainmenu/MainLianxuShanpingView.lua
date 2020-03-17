--[[
	连续技能全屏特效
	wwangshuai 
]]


_G.UILianxuSpPfx = BaseUI:new("UILianxuSpPfx");

UILianxuSpPfx.curspeed = 10
UILianxuSpPfx.width = 0;
UILianxuSpPfx.height =0;

function UILianxuSpPfx:Create()
	self:AddSWF("lianXuShanPingPanel.swf",true,"scene")
end

function UILianxuSpPfx:OnLoaded(objSwf)
	objSwf.hitTestDisable = true;
end

function UILianxuSpPfx : OnShow()
	self:StartPlay(); 
end;
function UILianxuSpPfx : OnStatec()
	if self:IsShow() == true then 
		self:Hide();
		self:Show();
	else
		self:Show();
	end;
end;
function UILianxuSpPfx : StartPlay()
	self.curWidth,self.curheight = UIManager:GetWinSize();
	self.objSwf.Animation:setstate(self.curWidth,self.curheight,self.curspeed);
end;
function UILianxuSpPfx : Update()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if objSwf.Animation._alpha <= 0 then 
		self:Hide();
	end;
end;
function UILianxuSpPfx : OnHide()

end;