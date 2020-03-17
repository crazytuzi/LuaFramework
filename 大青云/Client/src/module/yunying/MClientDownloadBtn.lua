--[[
微端下载按钮
lizhuangzhuang
2015年6月18日11:01:56
]]

_G.MClientDownloadBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_MClientD,MClientDownloadBtn);

function MClientDownloadBtn:GetStageBtnName()
	return "MClientDownload";
end

function MClientDownloadBtn:IsShow()
	if Version:IsHideMClient() then
		return false;
	end
	if _G.ismclient then
		return false;
	end
	if MClientModel.hasGetReward then
		return true;
	else
		return false;
	end
end

function MClientDownloadBtn:OnBtnClick()
	self:DoShowUI("UIMClientDownload");
end