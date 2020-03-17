--[[
联运:602
lizhuangzhuang
2015年12月22日15:04:56
]]

_G.L620Version = LianYunVersion:new(VersionConsts["620"]);

L620Version.RT_602_KEY = "ImV5SmxlSFFpT2lKc1lqRWlmUT09Ig==";--{"ext":"lb1"}base64两次后的值

function L620Version:OnEnterGame()
	local exts = _sys:getGlobal("exts");
	if not exts then return; end
	if exts == L620Version.RT_602_KEY then
		if not YunYingController:HasGetReward(YunYingConsts.RT_602) then
			YunYingController:GetReward(YunYingConsts.RT_602);
		end
	end
end
