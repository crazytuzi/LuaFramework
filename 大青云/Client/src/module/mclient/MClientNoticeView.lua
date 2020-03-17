--[[
微端提醒
lizhuangzhuang
2015年6月17日22:17:44
]]

_G.UIMClientNotice = BaseUI:new("UIMClientNotice");

function UIMClientNotice:Create()
	if Version:IsLianYun() then
		self:AddSWF("mclientNoticeLianYun.swf",true,"float");
	else
		self:AddSWF("mclientNotice.swf",true,"float");
	end
end

function UIMClientNotice:OnLoaded(objSwf)
	--objSwf.btnConfirm.label = StrConfig['mclient105'];
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
end

function UIMClientNotice:OnBtnConfirmClick()
	Version:DownloadMClient();
	self:Hide();
end

function UIMClientNotice:OnBtnCloseClick()
	self:Hide();
end