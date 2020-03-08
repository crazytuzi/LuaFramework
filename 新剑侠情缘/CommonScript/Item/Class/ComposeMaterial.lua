local tbItem = Item:GetClass("ComposeMeterial");

local UI_MAX_MATERIAL = 5
function tbItem:GetTip(it)
	if not it.dwId then
		return "";
	end
	local nMaterialCount = Compose.EntityCompose:GetMaterialCount(it.dwTemplateId)
	if nMaterialCount > UI_MAX_MATERIAL then
		return
	end
	return Compose.EntityCompose:GetMaterialList(it.dwTemplateId);
end

function tbItem:GetIntroBottom(nTemplateId)
	if Compose.EntityCompose:IsNeedConsume(nTemplateId) then
		local szConsumeType,nConsumeCount = Compose.EntityCompose:GetConsumeInfo(nTemplateId);
		local _, szMoneyEmotion = Shop:GetMoneyName(szConsumeType)
		return string.format("合成消耗 %s %d", szMoneyEmotion, nConsumeCount);
	end
end

function tbItem:GetIntrol(nTemplateId, nItemId)
	local nSumPrice, szMoneyType = Shop:GetSellSumPrice(me, nTemplateId, 1)
	local tbItemBase = KItem.GetItemBaseProp(nTemplateId)
	if nSumPrice then
		local _, szMoneyEmotion = Shop:GetMoneyName(szMoneyType)
		return  string.format("%s\n\n\n[73cbd5]出售可获得：%s%d[-]", tbItemBase.szIntro, szMoneyEmotion, nSumPrice)
	end
	local nMaterialCount = Compose.EntityCompose:GetMaterialCount(nTemplateId)
	if nMaterialCount > UI_MAX_MATERIAL then
		local szList = Compose.EntityCompose:GetMaterialList(nTemplateId, true)
		return string.format("%s\n\n[FFFFFF]%s", szList, tbItemBase.szIntro)
	end
	return tbItemBase.szIntro
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local nTargetTemplate = Compose.EntityCompose:GetTargetIdByChild(nTemplateId)
	local tbItemBase = KItem.GetItemBaseProp(nTargetTemplate);
	if not Compose.EntityCompose:CheckIsCanCompose(me, nTemplateId) then--and tbItemBase.szClass == "horse_equip" then
		local fnPreview = function ()
			local tbInfo = {};
			tbInfo.nTemplate = nTargetTemplate
			tbInfo.nFaction = me.nFaction;
			Item:ShowItemDetail(tbInfo);
		end
		if Shop:CanSellWare(me, nItemId, 1) then
			return {szFirstName = "出售", fnFirst = "SellItem", szSecondName = "预览", fnSecond = fnPreview};
		end
		return {szFirstName = "预览", fnFirst = fnPreview};
	else
		if Shop:CanSellWare(me, nItemId, 1) then
			return {szFirstName = "出售", fnFirst = "SellItem", szSecondName = "合成", fnSecond = "ComposeEntityItem"};
		end
		return {szFirstName = "合成", fnFirst = "ComposeEntityItem"};
	end
end

local EquipMeterial = Item:NewClass("EquipMeterial", "ComposeMeterial");	-- 派生，一定要放在最后

function EquipMeterial:GetIntrol(nTemplateId, nItemId)
	local nSumPrice, szMoneyType = Shop:GetSellSumPrice(me, nTemplateId, 1)
	local tbItemBase = KItem.GetItemBaseProp(nTemplateId)
	local szSellIntro = "";
	if nSumPrice then
		local _, szMoneyEmotion = Shop:GetMoneyName(szMoneyType)
		szSellIntro = string.format("\n\n\n[73cbd5]出售可获得：%s%d[-]", szMoneyEmotion, nSumPrice)
	end
	return string.format("%s%s", tbItemBase.szIntro, szSellIntro) 
end

local NormalMeterial = Item:NewClass("NormalMeterial", "ComposeMeterial");	-- 派生，一定要放在最后