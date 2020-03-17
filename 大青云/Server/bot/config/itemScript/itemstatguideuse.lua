--[[
加属性类道具推荐使用
lizhuangzhuang
2015年7月28日17:41:57
]]

ItemNumCScriptCfg:Add(
{
	name = "itemstatguideuse",
	execute = function(bag,pos,tid)
		local bagVO = BagModel:GetBag(bag);
		if not bagVO then return; end
		local item = bagVO:GetItemByPos(pos);
		if not item then return; end
		--如果达到每日上限,不提醒
		if BagModel:GetItemCanUseNum(tid) == 0 then
			return;
		end
		
		local cfg = t_item[tid];
		if not cfg then return; end
		local func = function(num)
			local str = "预计获得:%s%s";
			local name = enAttrTypeName[cfg.use_param_1];
			local v = cfg.use_param_2*num;
			return string.format(str,getNumShow(v),name);
		end
		
		UIItemGuideUse:Open(item:GetId(),func);
	end
}
);