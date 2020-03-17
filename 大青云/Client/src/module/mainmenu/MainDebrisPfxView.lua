--[[
	人物受到攻击时,碎屏效果
	wwangshuai 
]]


_G.UIDebrisPfx = BaseUI:new("UIDebrisPfx");

UIDebrisPfx.curx = 0;
UIDebrisPfx.cury = 0;
function UIDebrisPfx:Create() 
	self:AddSWF("debrisPfxPanel.swf",true,"top")
end

function UIDebrisPfx:NeverDeleteWhenHide()
	return true;
end

function UIDebrisPfx : OnShow()
	self.objSwf.eff:gotoAndPlay(1)
	_rd.camera:shake(1, 3, 500)
end

function UIDebrisPfx : Update()
	if not self.bShowState then return; end
	--if not a then return end;
	local objSwf = self.objSwf;
	self.curx,self.cury = UIManager:GetWinSize();
	local vx = self.curx/2;
	local vy = self.cury/2;
	objSwf.eff._ScaleX = 1.5;
	objSwf.eff._ScaleY = 1.5;
	objSwf._x = vx;
	objSwf._y = vy;
	if not objSwf then return end;
	if objSwf.eff._currentframe >= objSwf.eff._totalframes-2 then
		self:Hide();
	end;
end