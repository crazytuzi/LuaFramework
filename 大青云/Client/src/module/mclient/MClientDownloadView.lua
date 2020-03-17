--[[
微端下载
lizhuangzhuang
2015年6月17日22:42:06
]]

_G.UIMClientDownload = BaseUI:new("UIMClientDownload");

function UIMClientDownload:Create()
	if Version:IsLianYun() then
		self:AddSWF("mclientDownloadLianYun.swf",true,"top");
	else
		self:AddSWF("mclientDownload.swf",true,"top");
	end
end

function UIMClientDownload:OnLoaded(objSwf)
	objSwf.btnConfirm.label = StrConfig['mclient105'];
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
end

function UIMClientDownload:GetWidth()
	return 850;
end

function UIMClientDownload:GetHeight()
	return 420;
end

function UIMClientDownload:IsTween()
	return true;
end

function UIMClientDownload:IsShowSound()
	return true;
end

function UIMClientDownload:GetPanelType()
	return 1;
end

function UIMClientDownload:OnBtnConfirmClick()
	Version:DownloadMClient();
	self:Hide();
end

function UIMClientDownload:OnBtnCloseClick()
	self:Hide();
end