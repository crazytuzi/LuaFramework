--[[
多玩 ，百服盛典
wangshuai
2015年12月7日21:16:03
]]

_G.DuoWanBaifuAct = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_DuowanBaifuAct,DuoWanBaifuAct);

function DuoWanBaifuAct:GetStageBtnName()
	return "ButtonDuowanYYbaifu";
end

function DuoWanBaifuAct:IsShow()
	return Version:DuowanisShowBaifuAct()
end


function DuoWanBaifuAct:OnBtnClick()
	Version:DuoWanBaifuAct()
end