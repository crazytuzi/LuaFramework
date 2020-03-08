local tbItem = Item:GetClass("JuexueBook")
local tbDef  = JueXue.Def

function tbItem:CheckUsable(pEquip)
	local nItemTID = pEquip.dwTemplateId
	if not JueXue.tbJuexue[nItemTID] then
		return
	end
	local nFaction = JueXue.tbJuexue[nItemTID].Faction
	if nFaction == 0 or nFaction == me.nFaction then
		return 1
	end
	return 0
end

function tbItem:CheckUseEquip(pPlayer, pEquip, nEquipPos)
	local nAreaId = JueXue:GetJuexueAreaId(nEquipPos)
	if not nAreaId then
		return false, "不能装备到该位置"
	end

	if not JueXue:IsAreaActivate(pPlayer, nAreaId) then
		return false, "该区域尚未激活"
	end

	if not JueXue:CheckFaction(pEquip.dwTemplateId, pPlayer.nFaction) then
		return false, "不能装备该门派的绝学"
	end

	if not JueXue:CheckSoleTag(pPlayer, pEquip.dwTemplateId) then
		return false, "已装备同类型的绝学"
	end

	return true
end

function tbItem:OnClientUse(pEquip)
	local nType, nPos = JueXue:GetPanelCurPos()
	if nType ~= 1 or not nPos then
		nPos = JueXue:FindEmptyJuexuePos(me)
	end
	if not nPos then
		local szMsg = "您尚未激活绝学区域"
		if JueXue:GetActivateAreaCount() ~= 0 then
			szMsg = "绝学栏位已满"
		end 
		me.CenterMsg(szMsg)
	else
		local bRet, szMsg = self:CheckUseEquip(me, pEquip, nPos)
		if bRet then
			RemoteServer.UseEquip(pEquip.dwId, nPos)
			Ui:OpenWindow("SkillPanel", "LostKnowledgePanel", nPos)
		else
			me.CenterMsg(szMsg or "")
		end
	end
	Ui:CloseWindow("EquipTips")
	Ui:CloseWindow("CompareTips")
	return 1
end

function tbItem:BeforeUseEquip(pPlayer, pEquip, nEquipPos)
	local nAreaId = JueXue:GetJuexueAreaId(nEquipPos)
	if not nAreaId then
		return
	end

	JueXue:RefreshJuexueAttrib(pPlayer, pEquip, nAreaId)
end

function tbItem:OnInit(pEquip)
	JueXue:OnInitJuexue(pEquip)
end

function tbItem:OpenTips(tbPos, nItemTID, nItemID, tbInfo)
	local nFaction = tbInfo.nFaction or me.nFaction
	local nSex = Player:Faction2Sex(nFaction, tbInfo.nSex or me.nSex)
	tbPos = tbPos or {x = -84, y = 234}
	if nItemID then
		Ui:OpenWindowAtPos("EquipTips", tbPos.x, tbPos.y, nItemID, nil, nFaction, tbInfo.szItemOpt, nil, tbInfo.pAsyncRole or 1, nSex)
	else
		Ui:OpenWindowAtPos("EquipTips", tbPos.x, tbPos.y, false, nItemTID, nFaction, tbInfo.szItemOpt, {}, nil, nSex)
	end
end

function tbItem:GetTip(pEquip)
	local tbIntvalue = {}
	if pEquip.nPos >= Item.EQUIPPOS_JUEXUE_BEGIN and pEquip.nPos <= Item.EQUIPPOS_JUEXUE_END then
		for _, nValue in pairs(tbDef.tbJuexueItemData) do
			local nEquipValue = pEquip.GetIntValue(nValue)
			tbIntvalue[nValue] = nEquipValue
		end
	end
	return self:GetTipByTemplate(pEquip.dwTemplateId, tbIntvalue)
end

function tbItem:GetTipByTemplate(nItemTID, tbValue)
	local tbAttribs = self:GetAttribs(nItemTID, tbValue)
	local nQuality  = Item:GetQuality(nItemTID)
	return tbAttribs, nQuality
end

function tbItem:GetAttribs(nItemTID, tbValue)
	local tbAttribs = {}
	table.insert(tbAttribs, {"绝学属性"})

	local _, _, _, nQuality = Item:GetItemTemplateShowInfo(nItemTID)
	local tbBase = JueXue.tbJuexue[nItemTID]
	if not tbBase then
		return tbAttribs, nQuality
	end

	local nCurAttribLv = tbValue[tbDef.tbJuexueItemData.nAttribLv] or 1
	nCurAttribLv = math.max(nCurAttribLv, 1)
	for i, tbInfo in ipairs(tbBase.tbAttrib) do
		local nValue = tbInfo.InitValue + (nCurAttribLv - 1) * tbInfo.GrowValue
		nValue = math.floor(nValue/tbDef.nAttribScale)
		local szDesc = FightSkill:GetMagicDesc(tbInfo.AttribType, {nValue, 0, 0})
		table.insert(tbAttribs, {szDesc, 0})
	end

	local nSkillLevel = tbValue[tbDef.tbJuexueItemData.nSkillLv] or 1
	nSkillLevel = math.max(nSkillLevel, 1)
	table.insert(tbAttribs, {"技能效果"})
	
	local nSkillMaxLevel = JueXue:GetXiuLianSkillMaxLv()
	if tbValue[tbDef.tbJuexueItemData.nAttribLv] then
		nSkillMaxLevel   = math.max(1, math.floor(tbValue[tbDef.tbJuexueItemData.nAttribLv]/tbDef.nXiuLian4SkilllLv))
	end
	
	local szLevelDesc         = string.format("等级：%d/%d", nSkillLevel, nSkillMaxLevel)
	local nSkillID            = tbBase.SkillID
	local tbIcon, szSkillName = FightSkill:GetSkillShowInfo(nSkillID)
	table.insert(tbAttribs, {szSkillName, szLevelDesc, tbIcon.szIconSprite, tbIcon.szIconAtlas })

	local tbSkillSetting = FightSkill:GetSkillSetting(nSkillID, nSkillLevel)
	local szMagicDesc = FightSkill:GetSkillMagicDesc(nSkillID, nSkillLevel)
	table.insert(tbAttribs, {string.format("%s\n\n%s", tbSkillSetting.Desc, szMagicDesc)})


	return tbAttribs, nQuality
end

function tbItem:GetCustomIntrol(pEquip)
	if not pEquip then
		return ""
	end

	local tbValue = {}
	if pEquip.nPos >= Item.EQUIPPOS_JUEXUE_BEGIN and pEquip.nPos <= Item.EQUIPPOS_JUEXUE_END then
		for _, nValue in pairs(tbDef.tbJuexueItemData) do
			tbValue[nValue] = pEquip.GetIntValue(nValue)
		end
	end

	local nSkillLevel    = tbValue[tbDef.tbJuexueItemData.nSkillLv] or 1
	local nSkillMaxLevel = JueXue:GetXiuLianSkillMaxLv()
	if nSkillLevel >= nSkillMaxLevel then
		return "<已满级>"
	else
		local nAreaId = JueXue:GetJuexueAreaId(pEquip.nPos)
		if nAreaId then
			local nXL = JueXue:GetXiuLianSkillLv(me, nAreaId)
			if nSkillLevel < nXL then
				local nNeedXW = 0
				for _, tbInfo in ipairs(JueXue.tbXiuWei2SkillLv) do
					if nSkillLevel < tbInfo[2] then
						nNeedXW = tbInfo[1]
						break
					end
				end
				return string.format("<下一级需要绝学修为达到%d重>", nNeedXW)
			else
				local nNeedXL = (nSkillLevel + 1) * tbDef.nXiuLian4SkilllLv
				return string.format("<下一级技能等级上限需要绝学修炼到%d级>", nNeedXL)
			end
		end
	end
	return ""
end

function tbItem:GetEquipTypeDesc()
	return "门派需求："
end

function tbItem:GetRankDesc(nTemplateId)
	local tbInfo = JueXue.tbJuexue[nTemplateId]
	if tbInfo and tbInfo.Faction ~= 0 then
		return Faction:GetName(tbInfo.Faction)
	end
	return "全门派"
end

function tbItem:GetCustomDescInTips(nItemId)
	if not nItemId then
		return
	end
	local pEquip = KItem.GetItemObj(nItemId)
	if pEquip and pEquip.nPos ~= Item.emITEMPOS_BAG then
		local nAreaId = JueXue:GetJuexueAreaId(pEquip.nPos)
		if nAreaId then
			return string.format("绝学修为：%d重", JueXue:GetAreaXiuWei(me, nAreaId))
		end
	end
end

function tbItem:GetOtherFightpower(pPlayer, pEquip)
	local nAreaId = JueXue:GetJuexueAreaId(pEquip.nPos)
	if not nAreaId then
		return 0
	end
	local nXiuLianLv = JueXue:GetXiuLianLv(pPlayer, nAreaId)
	return JueXue:GetXiulianFightPower(nXiuLianLv)
end




function JueXue:GetSoleTag(nItemTID)
	local tbInfo = self.tbJuexue[nItemTID] or {}
	return tbInfo.SoleTag
end

function JueXue:FindEmptyJuexuePos(pPlayer)
	for nAreaId, _ in ipairs(tbDef.tbAreaInfo) do
		local nPos = Item.EQUIPPOS_JUEXUE_BEGIN + (nAreaId - 1) * tbDef.nAreaEquipPos
		if self:IsAreaActivate(pPlayer, nAreaId) and not pPlayer.GetEquipByPos(nPos) then
			return nPos
		end
	end
end

function JueXue:GetXiuLianLv(pPlayer, nAreaId)
	if not self:IsAreaActivate(pPlayer, nAreaId) then
		return 0
	end
	local nDataBegin = self:GetAreaDataBegin(nAreaId)
	local nLevel = pPlayer.GetUserValue(tbDef.nDataGroup, nDataBegin + tbDef.nXiuLianLv)
	nLevel = math.max(nLevel, 1)
	return math.min(nLevel, self.nXiuLianMaxLv)
end

function JueXue:GetAreaXiuWei(pPlayer, nAreaId)
	local nXiuWei = 0
	if not self:IsAreaActivate(pPlayer, nAreaId) then
		return nXiuWei
	end
	local nPosBegin = Item.EQUIPPOS_JUEXUE_BEGIN + (nAreaId - 1) * tbDef.nAreaEquipPos - 1
	for nPos = nPosBegin + tbDef.nMibenEquipPos, nPosBegin + tbDef.nAreaEquipPos do
		local pItem = pPlayer.GetEquipByPos(nPos)
		if pItem then
			nXiuWei = nXiuWei + KItem.GetItemExtParam(pItem.dwTemplateId, tbDef.nItemExtAddXiuwei)
		end
	end
	local tbChildArea = tbDef.tbAreaInfo[nAreaId].tbChildArea
	if tbChildArea then
		for _, nChildArea in ipairs(tbChildArea) do
			local nPosBegin = Item.EQUIPPOS_JUEXUE_BEGIN + (nChildArea - 1) * tbDef.nAreaEquipPos - 1 + tbDef.nMibenEquipPos
			local pItem = pPlayer.GetEquipByPos(nPosBegin)
			if pItem then
				nXiuWei = nXiuWei + KItem.GetItemExtParam(pItem.dwTemplateId, tbDef.nItemExtAddXiuwei)
			end
		end
	end
	return nXiuWei

end

function JueXue:GetXiuwei2SkillLv(nXiuWei)
	local nLevel = 1
	for _, tbInfo in ipairs(self.tbXiuWei2SkillLv) do
		if nXiuWei < tbInfo[1] then
			break
		end
		nLevel = tbInfo[2]
	end
	return nLevel
end

function JueXue:GetXiuLianSkillLv(pPlayer, nAreaId)
	local nXiuLianLv = self:GetXiuLianLv(pPlayer, nAreaId)
	local nSkillLv   = math.floor(nXiuLianLv/tbDef.nXiuLian4SkilllLv)
	return math.max(1, nSkillLv)
end

function JueXue:GetXiuLianSkillMaxLv()
	return math.floor(self.nXiuLianMaxLv/tbDef.nXiuLian4SkilllLv)
end

function JueXue:GetJueXueSkillLv(pPlayer, nAreaId)
	local nXiuWei   = self:GetAreaXiuWei(pPlayer, nAreaId)
	local nXiuWeiLv = self:GetXiuwei2SkillLv(nXiuWei)
	local nSkillLv  = self:GetXiuLianSkillLv(pPlayer, nAreaId)
	nSkillLv = math.min(nXiuWeiLv, nSkillLv)
	return nSkillLv
end

function JueXue:RefreshJuexueAttrib(pPlayer, pEquip, nEquipPos)
	if not pPlayer then
		return
	end
	if not pEquip then
		return
	end
	if not nEquipPos then
		return
	end
	local nAreaId = JueXue:GetJuexueAreaId(nEquipPos)
	if not nAreaId then
		return
	end
	local nCurSkillLv  = pEquip.GetIntValue(tbDef.tbJuexueItemData.nSkillLv)
	local nSkillLv     = self:GetJueXueSkillLv(pPlayer, nAreaId)
	local nCurAttribLv = pEquip.GetIntValue(tbDef.tbJuexueItemData.nAttribLv)
	local nXiulianLv   = self:GetXiuLianLv(pPlayer, nAreaId)
	if (nCurAttribLv ~= nXiulianLv) or (nCurSkillLv ~= nSkillLv) then
		pEquip.SetIntValue(tbDef.tbJuexueItemData.nAttribLv, nXiulianLv)
		pEquip.SetIntValue(tbDef.tbJuexueItemData.nSkillLv, nSkillLv)
		pEquip.ReInit()
	end
end

function JueXue:OnInitJuexue(pEquip)
	local tbBase = self.tbJuexue[pEquip.dwTemplateId]
	if not tbBase then
		return
	end

	local nCurSkillLv = pEquip.GetIntValue(tbDef.tbJuexueItemData.nSkillLv)
	local nRandAttribIdx = 1
	pEquip.SetRandAttrib(nRandAttribIdx, "add_skill_level", tbBase.SkillID, nCurSkillLv, 1)
	local tbRelation = tbDef.tbRelationSkill[tbBase.SkillID]
	if tbRelation then
		for _, nRelationSkillId in pairs(tbRelation) do
			nRandAttribIdx = nRandAttribIdx + 1
			pEquip.SetRandAttrib(nRandAttribIdx, "add_skill_level", nRelationSkillId, nCurSkillLv, 1)
		end
	end
	local nCurAttribLv = pEquip.GetIntValue(tbDef.tbJuexueItemData.nAttribLv)
	for i, tbInfo in ipairs(tbBase.tbAttrib) do
		local nValue = tbInfo.InitValue + (nCurAttribLv - 1) * tbInfo.GrowValue
		nValue = math.floor(nValue/tbDef.nAttribScale)
		nRandAttribIdx = nRandAttribIdx + 1
		pEquip.SetRandAttrib(nRandAttribIdx, tbInfo.AttribType, nValue, 0, 0)
	end
end

function JueXue:GetJuexueAreaId(nEquipPos)
	nEquipPos = nEquipPos - Item.EQUIPPOS_JUEXUE_BEGIN + 1
	return self.Def.tbJuexuePos[nEquipPos]
end

function JueXue:CheckFaction(nItemTID, nFaction)
	local tbInfo = self.tbJuexue[nItemTID]
	if not tbInfo then
		return
	end
	return tbInfo.Faction == 0 or tbInfo.Faction == nFaction
end

function JueXue:CheckSoleTag(pPlayer, nItemTID)
	local nSoleTag = self:GetSoleTag(nItemTID)
	if not nSoleTag then
		return
	end
	if nSoleTag == 0 then
		return true
	end

	for nEquipPos, nAreaId in pairs(self.Def.tbJuexuePos) do
		if self:IsAreaActivate(pPlayer, nAreaId) then
			local pItem = pPlayer.GetEquipByPos(nEquipPos + Item.EQUIPPOS_JUEXUE_BEGIN - 1)
			if pItem then
				local nThisSoleTag = self:GetSoleTag(pItem.dwTemplateId)
				if nThisSoleTag == nSoleTag then
					return
				end
			end
		end
	end
	return true
end