--[[
坐骑升阶石数量变化
需求:检测背包内坐骑升阶石达到5后
zhangshuhui
2015年5月5日22:04:36
]]


ItemNumCScriptCfg:Add(
{
	name = "mountchange",
	execute = function(bag,pos,tid)
		if MountUtil:GetMountUpToolNum() > 0 then
			if BagModel:GetItemNumInBag(tid) >= MountUtil:GetMountUpToolNum() then
				UIItemGuide:Open(8);
			end
		end
	end
}
);