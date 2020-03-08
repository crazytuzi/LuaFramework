Require("CommonScript/Item/Class/Equip.lua")

local tbZhenYuan = Item:GetClass("ZhenYuan");
local tbEquip = Item:GetClass("equip");


function tbZhenYuan:OnCreate(pEquip)
	Item.tbZhenYuan:OnGenerate(pEquip);
end

function tbZhenYuan:OnInit(pEquip)
	local nValue = pEquip.nOrgValue;
	local nFightPower = pEquip.nBaseFightPower;
	local nRefinePower, nRefineValue, nMaxQuality = Item.tbZhenYuan:InitEquip(pEquip);
	pEquip.nFightPower = nFightPower + nRefinePower;
	pEquip.SetSingleValue(nValue + nRefineValue)
	pEquip.nQuality = math.max(1, nMaxQuality);
end


function tbZhenYuan:GetTip(pEquip, pPlayer, bIsCompare)            -- 获取普通道具Tip
    	-- 基础属性
	local tbBaseAttrib, nBaseQuality = tbEquip:GetBaseAttrib(pEquip.dwTemplateId, pEquip, pPlayer, bIsCompare)
		-- 随机属性
	local tbRandomAttrib, nMaxQuality = tbEquip:GetRandomAttrib(pEquip, pPlayer)
	nMaxQuality = math.max(nMaxQuality, nBaseQuality)

	--技能信息
	local tbSkillInfo = self:GetSkillAttribTip(pEquip)
	local tbReturn = self:FormatTips(tbBaseAttrib, tbRandomAttrib, tbSkillInfo, pEquip.nLevel, pEquip.dwTemplateId)

	return tbReturn, nMaxQuality;
end

function tbZhenYuan:GetTipByTemplate(nTemplateId, tbSaveRandomAttrib)
	local tbBaseAttrib, nBaseQuality = tbEquip:GetBaseAttrib(nTemplateId);
	local tbRandomAttrib = {};
	local nMaxQuality = 0;
	local tbSkillInfo;
	local nEquipLevel;

	if tbSaveRandomAttrib then
		local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId);
		tbRandomAttrib, nMaxQuality = tbEquip:GetRandomAttribByTable(tbSaveRandomAttrib, tbBaseInfo.nLevel, tbBaseInfo.nItemType, tbBaseInfo.nDetailType);
		--技能信息
		local nSaveSkillId = tbSaveRandomAttrib[Item.tbZhenYuan.nItemKeySKillInfo]
		if nSaveSkillId and nSaveSkillId ~= 0 then
			local nSkillId, nSkillLevel = Item.tbRefinement:SaveDataToAttrib(nSaveSkillId)
			tbSkillInfo = {nSkillId, nSkillLevel};
			nEquipLevel = tbBaseInfo.nLevel
		end
	end

	nMaxQuality = math.max(nMaxQuality, nBaseQuality)
	local tbReturn = self:FormatTips(tbBaseAttrib, tbRandomAttrib, tbSkillInfo, nEquipLevel, nTemplateId)

	return tbReturn, nMaxQuality
end

function tbZhenYuan:FormatTips(tbBaseAttrib, tbRandomAttrib, tbSkillInfo, nEquipLevel, nTemplateId)
	local tbAttribs = {};
	table.insert(tbAttribs, {"", 1});
	for i, v in ipairs(tbBaseAttrib) do
		local szText, nColor = unpack(v)
		if type(szText) == "table" then
			local tbV = Lib:CopyTB(v);
			table.insert(tbAttribs, tbV);
		else
			table.insert(tbAttribs, v);
		end
	end
	if next(tbRandomAttrib) then
		local nFullCount = Item.tbRefinement:GetAttribFullCount(nTemplateId)
		table.insert(tbAttribs, {string.format("附加属性 (%d/%d)", #tbRandomAttrib, nFullCount) });
		for i, v in ipairs(tbRandomAttrib) do
			table.insert(tbAttribs, v);
		end
	end
	if tbSkillInfo and next(tbSkillInfo) then
		table.insert(tbAttribs, {"技能效果"});
		local nSkillID,nSkillLevel = unpack(tbSkillInfo)
		local nSkillMaxLevel = Item.tbZhenYuan:GetEquipMaxSkillLevel(nEquipLevel)
		local szLevelDesc = string.format("等级：%d/%d", nSkillLevel, nSkillMaxLevel)
		local tbIcon, szSkillName = FightSkill:GetSkillShowInfo(nSkillID);
		table.insert(tbAttribs, {szSkillName, szLevelDesc, tbIcon.szIconSprite, tbIcon.szIconAtlas })

		local tbSkillSetting = FightSkill:GetSkillSetting(nSkillID, nSkillLevel);
		local szMagicDesc = FightSkill:GetSkillMagicDesc(nSkillID, nSkillLevel);
		table.insert(tbAttribs, {string.format("%s\n\n%s", tbSkillSetting.Desc, szMagicDesc)})
	end
	return tbAttribs
end

function tbZhenYuan:GetSkillAttribTip(pEquip)
	local nSaveSkillId  = pEquip.GetIntValue(Item.tbZhenYuan.nItemKeySKillInfo)
	if nSaveSkillId == 0 then
		return
	end
	local nSkillId, nSkillLevel = Item.tbRefinement:SaveDataToAttrib(nSaveSkillId)
	local nSkillMaxLevel = Item.tbZhenYuan:GetEquipMaxSkillLevel(pEquip.nLevel)

	return {nSkillId, nSkillLevel, nSkillMaxLevel}
end

function tbZhenYuan:GetZhenYuanSkillAttribTip(pPlayer)
	local pCurEquip = pPlayer.GetEquipByPos(Item.EQUIPPOS_ZHEN_YUAN)
	if not pCurEquip then
		return
	end
	return self:GetSkillAttribTip(pCurEquip)
end