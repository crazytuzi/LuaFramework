--[[
美女直播按钮
lizhuangzhuang
2015年12月22日13:48:32
]]

_G.GirlTVBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_GirlTV,GirlTVBtn);

function GirlTVBtn:GetStageBtnName()
	return "ButtonGirlShow";
end

function GirlTVBtn:IsShow()
	if not Version:IsShowGirlTV() then
		return false;
	end
	return YunYingController.isShowGirlTV;
end

function GirlTVBtn:OnBtnClick()
	Version:GirlTVBrowse();
end