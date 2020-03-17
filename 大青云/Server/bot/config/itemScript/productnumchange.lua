--[[
升品
wangshuai
]]


ItemNumCScriptCfg:Add(
{
	name = "productnumchange",
	execute = function(bag,pos,tid)

		local mylvl = MainPlayerModel.humanDetailInfo.eaLevel;
		if mylvl < 20 then return end;
		local bagVorole = BagModel:GetBag(BagConsts.BagType_Role)
		if not bagVorole then return end;
		local isPass = -1;
		local list = {};
		for i,pos in ipairs(EquipConsts.EquipStrenType) do
			local item = bagVorole:GetItemByPos(pos);
			if not item then return end;
			local cfg = t_equip[item:GetTid()];
			if not cfg then return end;
			if cfg.quality < BagConsts.Quality_Lilac then 
				isPass = true;
				break
			end;
		end
		if isPass == -1 then 
			return 
		end;


		local bagVo = BagModel:GetBag(BagConsts.BagType_Bag);
		local listvo = bagVo:GetItemListByShowType(BagConsts.ShowType_Equip)
		local equipNum = 0;
		for i,info in ipairs(listvo) do
			local cfg = t_equip[info:GetTid()];
			if cfg.proid ~= 0 then 
				equipNum = equipNum + 1;
			end;
		end;

		local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
		local roleEquip = bagVO:GetItemListByShowType(BagConsts.ShowType_Equip);
		local minipos = -1;
		if #roleEquip == 0 then return end; -- 身上没有装备的时候，不提醒
		for ba,eq in ipairs(roleEquip) do
			local cfg = t_equip[eq:GetTid()];
			if cfg.quality < BagConsts.Quality_Lilac then --当前有装备品质小于浅紫
				minipos = eq.pos;
				break;
			end;
		end;
		if minipos == -1 then return end;
		if equipNum >= 3 then 
			UIItemGuide:Open(4);
		end;
	end
}
)