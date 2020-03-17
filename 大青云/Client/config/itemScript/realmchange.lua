--[[
境界道具数量变化
需求:检测背包内境界灌注道具达到灌注两次的条件
zhangshuhui
2015年6月2日12:04:36
]]


ItemNumCScriptCfg:Add(
{
	name = "realmchange",
	execute = function(bag,pos,tid)
		if RealmUtil:GetIsFloodToolNum() == true then
			UIItemGuide:Open(9);
		end
	end
}
);