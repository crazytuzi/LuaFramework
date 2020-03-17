--[[
字体安装
lizhuangzhuang
2015年4月18日20:14:10
]]

_G.UIFontInst = BaseUI:new("UIFontInst");

function UIFontInst:Create()
	self:AddSWF("fontInst.swf",true,"top");
end

function UIFontInst:GetWidth()
	return 325;
end

function UIFontInst:GetHeight()
	return 149;
end

function UIFontInst:OnResize(wWith,wHeight)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.mcMask._width = wWith;
	objSwf.mcMask._height = wHeight;
end


function UIFontInst:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local wWith,wHeight = UIManager:GetWinSize();
	objSwf.mcMask._width = wWith;
	objSwf.mcMask._height = wHeight;
end


function UIFontInst:ShowProgress(p)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local percent = toint(p*100,0.5);
	objSwf.mcProgress:gotoAndStop(percent);
end
