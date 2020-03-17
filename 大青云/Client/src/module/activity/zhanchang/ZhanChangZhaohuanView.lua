--[[
wangshuai
战场召唤
]]

_G.UIZhchZhaoHuan = BaseUI:new("UIZhchZhaoHuan")

function UIZhchZhaoHuan:Create()
	self:AddSWF("zhanchangZhaohuan.swf",true,"center")
end;

function UIZhchZhaoHuan:OnLoaded(objSwf)
	objSwf.close.click = function() self:OnClosePanel()end;
	objSwf.btnEnter.click = function() self:OnEnterActivity()end
	objSwf.btnOut.click = function() self:OnClosePanel()end
end

function UIZhchZhaoHuan:OnShow()

end;
--UIConfirm:Open(StrConfig["zhanchang118"],okfun,nofun);

UIZhchZhaoHuan.okfun = function()end;
UIZhchZhaoHuan.nofun = function()end;
function UIZhchZhaoHuan:Open(okfun,nofun)
	if okfun then
		self.okfun = okfun;
	end;
	if nofun then 
		self.nofun = nofun
	end
	self:Show();
end;	

function UIZhchZhaoHuan:OnHide()
	self.nofun();
end;

function UIZhchZhaoHuan:OnClosePanel()
	self:Hide()
end;

function UIZhchZhaoHuan:OnEnterActivity()
	self.okfun();
	self:Hide();
end