local tbItem = Item:GetClass("InscriptionItem")
local tbEquip = Item:GetClass("equip");	

function tbItem:OnCreate(pEquip)
	local nRealLevel = KItem.GetItemExtParam(pEquip.dwTemplateId, 1)
	self:OnGenerate(pEquip, nRealLevel);
end

function tbItem:OnGenerate(pEquip, nRealLevel)
	local tbSaveAttribs = {};

	local tbCustomAttri = Item.tbRefinement:GetCustomAttri(pEquip.dwTemplateId)
	if tbCustomAttri  then -- 定制装备没有随机属性
		tbSaveAttribs = tbCustomAttri
	else
		local tbForbid = {};
		local nCustomCount = 0;
		local nEquipType = pEquip.nItemType;
		if not nRealLevel or nRealLevel<=0 then
			nRealLevel = pEquip.nLevel
		end
		local szEquipType = Item.EQUIPTYPE_EN_NAME[nEquipType];
		if Item.tbRefinement.tbExtAttrib[nRealLevel] and Item.tbRefinement.tbExtAttrib[nRealLevel] > 0 then -- 稀有装备，额外多一条属性定制属性的等级。
			local nFixLevel = Item.tbRefinement.tbExtAttrib[nRealLevel]
			local szAttrib = Item.tbRefinement:RandomAttribType(szEquipType, tbForbid);
			local nAttribId = Item.tbRefinement:AttribCharToId(szAttrib);
			local nSave = Item.tbRefinement:AttribToSaveData(nAttribId, nFixLevel);
			if #tbSaveAttribs == 0 then -- 稀有属性为第一条属性
				table.insert(tbSaveAttribs, nSave);
			else
				local tbTemp = {};
				table.insert(tbTemp, nSave);
				for i,v in ipairs(tbSaveAttribs) do
					table.insert(tbTemp, v);
				end
				tbSaveAttribs = tbTemp;
			end
		end
		local nCreateCount = Item.tbRefinement:RandomCount(nRealLevel) - nCustomCount;
		for i = 1, nCreateCount do

			local szAttrib = Item.tbRefinement:RandomAttribType(szEquipType, tbForbid);
			local nLevel = Item.tbRefinement:RandomAttribLevel(nRealLevel);
			local nAttribId = Item.tbRefinement:AttribCharToId(szAttrib);	-- XXX
			local nSave = Item.tbRefinement:AttribToSaveData(nAttribId, nLevel);		-- 左移16位，ID为高16位，等级为低16位
			table.insert(tbSaveAttribs, nSave);
		end
	end

	for nPos, nSave in pairs(tbSaveAttribs) do
		Item.tbRefinement:ChangeRandomAttrib(pEquip, nPos, nSave);
	end
end

function tbItem:OnInit(pEquip)
	local nValue = pEquip.nOrgValue;
	local nFightPower = pEquip.nBaseFightPower;
	local nRefinePower, nRefineValue, nMaxQuality = Item.tbRefinement:InitEquip(pEquip);
	pEquip.nFightPower = nFightPower + nRefinePower;
	pEquip.SetSingleValue(nValue + nRefineValue)
	pEquip.nQuality = math.max(1, nMaxQuality);
end

function tbItem:OnUse(pItem)
	local nPlayerId = me.dwID
	local tbMagicBowl = Furniture.MagicBowl:GetData(nPlayerId)
    if not tbMagicBowl then
        me.CenterMsg("你没有聚宝盆")
        return
    end

    me.CallClientScript("Ui:CloseWindow", "ItemTips")
    me.CallClientScript("Ui:OpenWindow", "MagicBowlRefinementPanel", pItem.dwId)
end

function tbItem:FormatTips(tbRandomAttrib)
	local tbAttribs = {};
	table.insert(tbAttribs, {"", 1});

	if next(tbRandomAttrib) then
		table.insert(tbAttribs, {"附加属性"});
		for i, v in ipairs(tbRandomAttrib) do
			table.insert(tbAttribs, v);
		end
	end

	return tbAttribs;
end

function tbItem:GetTip(pEquip, pPlayer)
	-- 随机属性
	local tbRandomAttrib, nMaxQuality = self:GetRandomAttrib(pEquip, pPlayer)

	local tbReturn = self:FormatTips(tbRandomAttrib)

	return tbReturn, nMaxQuality;
end

function tbItem:GetTipByTemplate(nTemplateId, tbSaveRandomAttrib)
	local tbRandomAttrib = {};
	local nMaxQuality = 0;

	if tbSaveRandomAttrib then
		local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId);
		tbRandomAttrib, nMaxQuality = tbEquip:GetRandomAttribByTable(tbSaveRandomAttrib, tbBaseInfo.nLevel, tbBaseInfo.nItemType, tbBaseInfo.nDetailType);
	end

	local tbReturn = self:FormatTips(tbRandomAttrib)
	return tbReturn, nMaxQuality
end

function tbItem:GetRandomAttrib(pEquip, pPlayer)
	local tbAttribs = Item.tbRefinement:GetRandomAttrib(pEquip);
	local tbTip = {};
	local nMaxQulity = 0;
	local nEquipLevel = pEquip.nLevel
	for _, tbAttrib in ipairs(tbAttribs) do
		local vOne, nQuality = self:GetTipOneAttrib(pEquip.nDetailType, pEquip.nItemType, nEquipLevel, tbAttrib)
		if vOne then
			table.insert(tbTip, vOne);	
		end
		if nQuality > nMaxQulity then
			nMaxQulity = nQuality;
		end
	end

	return (tbTip or {}), nMaxQulity;
end

function tbItem:GetTipOneAttrib(nDetailType, nItemType, nEquipLevel, tbAttrib)
	local nQuality = Item.tbRefinement:GetAttribColor(nEquipLevel, tbAttrib.nAttribLevel, nItemType);
	local tbMA, szDesc = Item.tbRefinement:GetAttribMA(tbAttrib, nItemType);
	if  Lib:IsEmptyStr(szDesc) then 
		szDesc = self:GetMagicAttribDesc(tbAttrib.szAttrib, tbMA);
	end
	if Lib:IsEmptyStr(szDesc) then
		return nil, nQuality
	end
	return {szDesc, nQuality}, nQuality
end

function tbItem:GetMagicAttribDesc(szName, tbValue, nActiveReq)
	if szName == "" then
		return	"";
	end

	if not tbValue then
		return ""
	end
	local szAttribMsg = FightSkill:GetMagicDesc(szName, tbValue);
	local szReq = Item:GetActiveReqDesc(nActiveReq);
	if szReq then
		szAttribMsg = szAttribMsg..string.format(" (%s)", szReq);
	end

	return szAttribMsg;
end
