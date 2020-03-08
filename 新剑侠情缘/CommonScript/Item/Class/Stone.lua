
local tbStone = Item:GetClass("Stone");

function tbStone:GetTip(pStone)
	return self:GetTipByTemplate(pStone.dwTemplateId)
end

function tbStone:GetTipByTemplate(nTemplateId, nFaction)
	local szTip = "";
	if StoneMgr:IsStone(nTemplateId) then
		local szName1, szValue1, szName2, szValue2  = StoneMgr:GetStoneMagicDesc(nTemplateId);
		if szName1 then
			szTip = szName1 .. "  " .. szValue1;
		end
		if szName2 then
			szTip = szTip .."\n".. szName2 .. "  " .. szValue2;
		end
	end
	return szTip;
end

function tbStone:OnUse(it)
	if StoneMgr:IsStoneDebris(it.dwTemplateId) then
		StoneMgr:OnCombine(me, it.dwTemplateId, 1)
	end
end

function tbStone:GetIntroBottom(nTemplateId)
	local _, szMoneyEmotion = Shop:GetMoneyName("Coin")
	local nCost = StoneMgr:GetCombineCost(nTemplateId)
	if nCost and nCost > 0 then
		return string.format("合成消耗 %s %d", szMoneyEmotion, nCost)
	end
	return ""
end

function tbStone:GetUseSetting(nTemplateId, nItemId)
	if StoneMgr:IsStoneDebris(nTemplateId) then
	    return {szFirstName = "合成", fnFirst = "UseItem"};
	end

	local tbBtnFuncs = {};
	if StoneMgr:GetNextLevelStone(nTemplateId) ~= 0 then
		table.insert(tbBtnFuncs,{"合成", "UseCombine" })
	end
	
	table.insert(tbBtnFuncs,{StoneMgr:IsCrystal(nTemplateId) and "强化" or "镶嵌", "UseInset" })

	if Shop:CanSellWare(me, nItemId, 1) then
		table.insert(tbBtnFuncs,{"出售", "SellItem" })
	end
	local tbUseSetting = {};
	local tbFuncName = {
		{"szFirstName", "fnFirst"};
		{"szSecondName", "fnSecond"};
		{"szThirdName", "fnThird"};
	}
	for i,v in ipairs(tbBtnFuncs) do
		local szKey1,szKey2 = unpack(tbFuncName[i])
		tbUseSetting[szKey1] = v[1]
		tbUseSetting[szKey2] = v[2]
	end

	return tbUseSetting;		
end

function tbStone:GetIntrol(nTemplateId)
	if StoneMgr:IsStoneDebris(nTemplateId) then
		return;
	end
	local tbInfo = KItem.GetItemBaseProp(nTemplateId)
	local szInsetPosDes = StoneMgr:GetCanInsetPosDes(nTemplateId)
	local szConbineTip
	local szLevelTip
	local szProperty
	local szUnique
	if szInsetPosDes then
		szLevelTip = string.format("[fff949]%d级[-]", tbInfo.nLevel)
		szConbineTip = string.format("[fff949]%s[-]", szInsetPosDes)
		szProperty = self:GetTipByTemplate(nTemplateId,me.nFaction)
		szUnique = StoneMgr:IsUnique(nTemplateId) and "(唯一，该魂石只能在装备上镶嵌1个)" or  ""
	end
	return szConbineTip,szLevelTip,szProperty,szUnique
end

function tbStone:CombineDes(nTemplateId)

	if StoneMgr:IsStoneDebris(nTemplateId) then
		return;
	end

	local tbInfo = KItem.GetItemBaseProp(nTemplateId)

	return tbInfo.szIntro
end