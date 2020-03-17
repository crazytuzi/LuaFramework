--[[
戒指使用
wangyanwei
]]

ItemScriptCfg:Add(
{
	name = "ItemMarryRingUse",
	execute = function(bag,pos,str)
		local bagVO = BagModel:GetBag(bag);
		if not bagVO then return; end
		local item = bagVO:GetItemByPos(pos);
		if not item then return; end
		
		--等级
		local myLvl = MainPlayerModel.humanDetailInfo.eaLevel;
		local cfg = t_funcOpen[85];
		local openLvl = cfg.open_level;
		if myLvl < openLvl then 
			FloatManager:AddNormal(StrConfig["marriage105"]);
			return 
		end;
		--单身，离婚.
		local myState = MarriageModel:GetMyMarryState();--我的状态
		if myState == MarriageConsts.marrySingle or myState == MarriageConsts.marryLeave then 
			FloatManager:AddNormal(StrConfig['marriage020']);
			return 
		end
		local func = function()
			local type = 0;
			for i,info in ipairs(t_marryRing) do 
				if info.itemId == item:GetTid() then 
					type = info.id;
					break;
				end;
			end;
			MarriagController:ReqMarryRingChang(item:GetId(),type)
		end;
		UIConfirm:Open(StrConfig["marriage106"],func)
		return true
	end
}
);