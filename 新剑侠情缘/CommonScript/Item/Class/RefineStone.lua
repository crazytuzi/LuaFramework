local tbRefineStone = Item:GetClass("RefineStone");
local tbEquip = Item:GetClass("equip");

function tbRefineStone:OnCreate(pEquip)
	Item.tbRefinementStone:OnGenerate(pEquip);
end

function tbRefineStone:OnInit(pEquip)
	local tbRefinementStone = Item.tbRefinementStone
	local nMaxQuality = tbRefinementStone:InitEquip(pEquip);
	pEquip.nQuality = math.max(1, nMaxQuality);
end

function tbRefineStone:GetTip(pEquip, pPlayer, bIsCompare)			-- 获取普通道具Tip	
	-- 随机属性
	local tbRandomAttrib, nMaxQuality = self:GetRandomAttrib(pEquip, pPlayer)
	local tbReturn = self:FormatTips(tbRandomAttrib)
	return tbReturn, nMaxQuality;
end

function tbRefineStone:GetTipByTemplate(nTemplateId, tbSaveRandomAttrib)
	local tbRandomAttrib = {};
	local nMaxQuality = 1;

	if tbSaveRandomAttrib then
		local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId);
		local nEquipType = KItem.GetItemExtParam(nTemplateId, Item.tbRefinementStone.REFINE_STONE_PARAM_TYPE)	
		tbRandomAttrib, nMaxQuality = tbEquip:GetRandomAttribByTable(tbSaveRandomAttrib, tbBaseInfo.nLevel, nEquipType);
	end
	local tbReturn = self:FormatTips(tbRandomAttrib)

	return tbReturn, nMaxQuality;
end

function tbRefineStone:GetRandomAttrib(pEquip, pPlayer)
	local tbAttribs = Item.tbRefinement:GetRandomAttrib(pEquip);
	local tbTip = {};
	local nMaxQulity = 1;
	local nEquipLevel = pEquip.nLevel
	local nItemType = KItem.GetItemExtParam(pEquip.dwTemplateId, Item.tbRefinementStone.REFINE_STONE_PARAM_TYPE)
	for _, tbAttrib in ipairs(tbAttribs) do
		local vOne, nQuality = tbEquip:GetTipOneAttrib(pEquip.nDetailType, nItemType, nEquipLevel, tbAttrib)
		if vOne then
			table.insert(tbTip, vOne);	
		end
		if nQuality > nMaxQulity then
			nMaxQulity = nQuality;
		end
	end

	return (tbTip or {}), nMaxQulity;
end

function tbRefineStone:FormatTips(tbRandomAttrib)
	local tbAttribs = {};
	table.insert(tbAttribs, {"", 1});
	if next(tbRandomAttrib) then
		table.insert(tbAttribs, {"附加属性"});
		for i, v in ipairs(tbRandomAttrib) do
			table.insert(tbAttribs, v);
		end
	end
	return tbAttribs
end