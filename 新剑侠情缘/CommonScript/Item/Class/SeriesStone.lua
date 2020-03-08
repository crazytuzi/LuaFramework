Require("CommonScript/Item/Class/Equip.lua")

local tbSeriesStone = Item:GetClass("SeriesStone");
local tbEquip = Item:GetClass("equip");


function tbSeriesStone:OnCreate(pEquip)
	Item.tbSeriesStone:OnGenerate(pEquip);
end

function tbSeriesStone:OnInit(pEquip)
	local nValue = pEquip.nOrgValue;
	local nFightPower = pEquip.nBaseFightPower;
	local nRefinePower, nRefineValue, nMaxQuality = Item.tbSeriesStone:InitEquip(pEquip);
	pEquip.nFightPower = nFightPower + nRefinePower;
	pEquip.SetSingleValue(nValue + nRefineValue)
end

function tbSeriesStone:AfterUseEquip( pPlayer, pEquip)
	Item.tbSeriesStone:AfterUseEquip( pPlayer, pEquip)
end

function tbSeriesStone:AfterUnuseEquip( pPlayer, pEquip, nPos  )
	Item.tbSeriesStone:AfterUnuseEquip( pPlayer, pEquip)
end

function tbSeriesStone:GetRandomAttrib( pEquip, pPlayer )
	local tbAttribGroups, tbActiveDark, nSeries = Item.tbSeriesStone:GetRandomAttrib(pEquip);
	local tbTipGroup = { {},{} };
	local nEquipLevel = pEquip.nLevel

	local nItemType = pEquip.nItemType
	for i, tbAttribs in ipairs(tbAttribGroups) do
		for _, tbAttrib in ipairs(tbAttribs) do
			local vOne, nQuality = tbEquip:GetTipOneAttrib(pEquip.nDetailType, nItemType, nEquipLevel, tbAttrib)
			if vOne then
				table.insert(tbTipGroup[i], vOne);	
			end
		end	
	end

	return tbTipGroup, tbActiveDark, nSeries;
end

function tbSeriesStone:GetRandomAttribByTable( tbSaveAttrib, nEquipLevel, nItemType, nDetailType)
	local tbAttribGroups, tbActiveDark, nSeries = Item.tbSeriesStone:GetRandomAttribByTable(tbSaveAttrib);-- body
	local tbTipGroup = { {},{} };
	for i, tbAttribs in ipairs(tbAttribGroups) do
		for _, tbAttrib in ipairs(tbAttribs) do
			local vOne, nQuality = tbEquip:GetTipOneAttrib(nDetailType, nItemType, nEquipLevel, tbAttrib)
			if vOne then
				table.insert(tbTipGroup[i], vOne);	
			end
		end	
	end

	return tbTipGroup, tbActiveDark, nSeries;

end

function tbSeriesStone:GetTip(pEquip, pPlayer, bIsCompare)            -- 获取普通道具Tip
	local tbRandomAttribGroup, tbActiveDark, nSeries = self:GetRandomAttrib(pEquip, pPlayer)
	local nQuality = pEquip.nQuality
	local tbReturn = self:FormatTips(tbRandomAttribGroup, tbActiveDark, pEquip.nLevel, pEquip.nEquipPos, nSeries)

	return tbReturn, nQuality;
end

function tbSeriesStone:GetTipByTemplate(nTemplateId, tbSaveRandomAttrib)
	local tbRandomAttribGroup = {};
	local tbActiveDark = {}
	local nSeries = 0
	
	local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId);
	local nQuality = tbBaseInfo.nQuality;
	if tbSaveRandomAttrib then
		tbRandomAttribGroup, tbActiveDark, nSeries = self:GetRandomAttribByTable(tbSaveRandomAttrib, tbBaseInfo.nLevel, tbBaseInfo.nItemType, tbBaseInfo.nDetailType)
	end
	local nEquipPos = KItem.GetEquipPos(nTemplateId)
	local tbReturn = self:FormatTips(tbRandomAttribGroup, tbActiveDark, tbBaseInfo.nLevel, nEquipPos, nSeries)

	return tbReturn, nQuality;
end

function tbSeriesStone:FormatTips(tbRandomAttribGroup, tbActiveDark, nEquipLevel, nEquipPos, nSeries)
	local tbAttribs = { {"",1} };
	table.insert(tbAttribs, {string.format("五行：[%s]%s[-]", Npc.SeriesColor[nSeries], Npc.Series[nSeries]), 1 });
	table.insert(tbAttribs, {string.format("镶嵌位置：%s", Item.EQUIPPOS_NAME[nEquipPos]) , 1 });
	table.insert(tbAttribs, {"基础属性"});

	for i,v in ipairs(tbRandomAttribGroup[1]) do
		table.insert(tbAttribs, v)
	end
	table.insert(tbAttribs, {string.format("五行激活") });	

	local szActviePosName = Item.tbSeriesStone:GetBackActiveEquipPosName(nEquipPos , nSeries, {}) --道具自己上面的tip都不显示激活
	table.insert(tbAttribs, { szActviePosName  , 1});	
	for i,v in ipairs(tbRandomAttribGroup[2]) do
		table.insert(tbAttribs, v)
	end
	return tbAttribs
end