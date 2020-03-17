--[[
生命之泉数量变化
需求:检测背包内生命之泉
zhangshuhui
2015年11月2日14:04:36
]]


ItemNumCScriptCfg:Add(
{
	name = "shengmingquanchange",
	execute = function(bag,pos,tid)
		if SkillUtil:GetIsChangeSCItem(tid) == true then
			if BagModel:GetItemNumInBag(tid) > 0 then
				SkillModel:SetShengMingQuanChangeTid(tid);
				UIItemGuide:Open(18);
			end
		end
	end
}
);