function JueXue:OnUseDuanpian(nPos, nSuitId, nExternGroup, nLevel)
	if not nPos or nSuitId <= 0 then
		return
	end
	me.tbDuanpianEquipPos[nPos] = nSuitId

	if not me.tbDuanpianCurSkillLv[nSuitId] or me.tbDuanpianCurSkillLv[nSuitId] < nLevel then
		me.tbDuanpianCurSkillLv[nSuitId] = nLevel
		me.ApplyExternAttrib(nExternGroup, nLevel)
	end
end

function JueXue:OnUnuseDuanpian(nPos, nSuitId, nExternGroup, nLevel)
	me.tbDuanpianEquipPos[nPos] = nil
	if not nSuitId then
		return
	end

	me.tbDuanpianCurSkillLv[nSuitId] = nLevel
	if nLevel > 0 then
		me.ApplyExternAttrib(nExternGroup, nLevel)
	else
		me.RemoveExternAttrib(nExternGroup)
	end
end

function JueXue:CheckShowEvolve(nTemplateId)
	local _1, _2, nAreaId = self:GetBookActivateArea(nTemplateId)
	if not nAreaId then
		return
	end
	if self:IsAreaActivate(me, nAreaId) then
		return
	end
	local szTimeFrame = self.Def.tbAreaInfo[nAreaId].szTimeFrame
	if not Lib:IsEmptyStr(szTimeFrame) and GetTimeFrameState(szTimeFrame) ~= 1 then
		return
	end
	return true
end

function JueXue:TryActivateArea(pItem)
	local bRet, szMsg, nAreaId = self:CheckCanActivateArea(me, pItem)
	if not bRet then
		me.CenterMsg(szMsg or "")
		return
	end

	local tbInfo = KItem.GetItemBaseProp(self.Def.nActivateTemplateId)
	me.MsgBox(string.format("确定花费%d个%s解锁第%d个绝学装备位置？", self.Def.nActivateConsume, tbInfo.szName, nAreaId), {{"确定", function ()
		RemoteServer.JueXueOnClientCall("ActivateArea", pItem.dwId)
	end}, {"取消"}})
end

function JueXue:TryXiuLian(pItem)
	local nAreaId = pItem.nCurEquipAreaId
	if not nAreaId then
		return
	end
	local bRet, szMsg = self:CheckCanXiuLian(me, nAreaId)
	if not bRet then
		me.CenterMsg(szMsg or "")
		return
	end

	RemoteServer.JueXueOnClientCall("XiuLian", nAreaId)
end

function JueXue:GetItemXiuLianLv(pItem)
	if pItem and pItem.nPos ~= Item.emITEMPOS_BAG then
		local nAreaId = self:GetJuexueAreaId(pItem.nPos)
		if nAreaId then
			return JueXue:GetCurXiuLianLv(me, nAreaId)
		end
	end
end

function JueXue:CheckShowTab()
	for nAreaId, tbInfo in ipairs(self.Def.tbAreaInfo) do
		if not Lib:IsEmptyStr(tbInfo.szTimeFrame) and GetTimeFrameState(tbInfo.szTimeFrame) == 1 then
			return true
		end
	end
	return false
end

function JueXue:GetAllJuexueSkill()
	local tbList = {}
	for nAreaId, _ in ipairs(self.Def.tbAreaInfo) do
		if self:IsAreaActivate(me, nAreaId) then
			local nPos   = Item.EQUIPPOS_JUEXUE_BEGIN + (nAreaId - 1) * self.Def.nAreaEquipPos
			local pEquip = me.GetEquipByPos(nPos)
			if pEquip then
				local tbBase = self.tbJuexue[pEquip.dwTemplateId]
				if tbBase then
					local nSkillLv       = pEquip.GetIntValue(self.Def.tbJuexueItemData.nSkillLv)
					local nSkillMaxLevel = self:GetXiuLianSkillMaxLv()
					local tbSubInfo      = FightSkill:GetSkillShowTipInfo(tbBase.SkillID, nSkillLv, nSkillMaxLevel)
					if tbSubInfo then
					    table.insert(tbList, tbSubInfo)
					end
				end
			end
		end
	end
	return tbList
end

function JueXue:SetDuanpianIcon(pPanel, nSuitId)
	if nSuitId <= 0 then
		return
	end
	local tbInfo = self.tbSuitAttrib[nSuitId]
	if not tbInfo then
		return
	end
	pPanel:Sprite_SetSprite("ItemLayer", tbInfo.szIcon, tbInfo.szAtlas)
end

function JueXue:InitTips(tbUi)

tbUi.Option =
{
	Default = {},
	ItemBox =
	{
		{"穿上", "UseEquip"},
		{"出售", "Sell"},
	},
	JuexueEquip =
	{
		{"卸下", "UnuseEquip"},
	},
}

--断篇，秘本必须要有属性才能打开ui，否则里面没有可以显示的内容
function tbUi:OnOpen(nTemplateId, nItemId, tbIntValue)
	if not nItemId and not tbIntValue then
		return 0
	end
end

function tbUi:OnOpenEnd(nTemplateId, nItemId, tbIntValue, szOption, nEquipPos)
	local pItem, nValue, bEquiped
	local szName, nIcon, nView, nQuality, nFightPower, nValue
	if nItemId then
		pItem = KItem.GetItemObj(nItemId)
		if not pItem then
			return
		end
		nTemplateId = pItem.dwTemplateId
		szName, nIcon, nView = Item:GetDBItemShowInfo(pItem)
		nQuality = pItem.nQuality
		nFightPower = pItem.nFightPower

		if pItem.nPos ~= Item.emITEMPOS_BAG then
			local pCurEquip = me.GetEquipByPos(pItem.nPos)
			if pCurEquip and pCurEquip.dwId == nItemId then
				bEquiped = true
			end
		end
	else
		szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(nTemplateId)
		nFightPower = KItem.GetEquipBaseFightPower(nTemplateId)
	end
	self.pPanel:SetActive("Equipped", bEquiped or false)

	local tbInfo = KItem.GetItemBaseProp(nTemplateId)
	if not tbInfo then
		return
	end
	nValue = pItem and pItem.nValue or tbInfo.nValue

	if szName then
		self.pPanel:Label_SetText("TxtTitle", szName)
		local szNameColor = Item:GetQualityColor(nQuality) or "White"
		self.pPanel:Label_SetColorByName("TxtTitle", szNameColor)
	end
	self.pPanel:Label_SetText("TxtFightPower", "战力：".. nFightPower)

	self.pPanel:Label_SetText("TxtLevelLimit", string.format("%d级", tbInfo.nRequireLevel))
	self.pPanel:Label_SetText("Rank", string.format("%d阶", tbInfo.nLevel))
	self.pPanel:Label_SetText("TxtEquipType", self.szTypeName)

	if nView and nView ~= 0 then
		local szIconAtlas, szIconSprite = Item:GetIcon(nView)
		self.pPanel:SetActive("ItemLayer", true)
		self.pPanel:Sprite_SetSprite("ItemLayer", szIconSprite, szIconAtlas)
	else
		self.pPanel:SetActive("ItemLayer", false)
	end

	local _, szFrameColor = Item:GetQualityColor(nQuality or 0)
	self.pPanel:Sprite_SetSprite("Color", szFrameColor)

	self.szOption = szOption or "Default"
	if not self.Option[self.szOption] then
		self.szOption = "Default"
	end

	for i = 1, 3 do
		local tbBtnInfo = self.Option[self.szOption][i]
		self.pPanel:SetActive("Btn" .. i, tbBtnInfo or false)
		if tbBtnInfo then
			self.pPanel:Button_SetText("Btn" .. i, tbBtnInfo[1])
		end
	end

	self.pPanel:Sprite_SetSprite("Ylicon", "SkillExpSmall")
	self.pPanel:Label_SetText("TxtCoin", tbInfo.nPrice)

	self.nItemId     = nItemId
	self.nTemplateId = nTemplateId
	self.nEquipPos   = nEquipPos

	self:UpdateAttribs(pItem, tbIntValue)
end

function tbUi:UseEquip()
	if not self.nItemId then
		return
	end

	local pItem = KItem.GetItemObj(self.nItemId)
	if not pItem then
		return false
	end

	if pItem.nUseLevel > me.nLevel then
		me.CenterMsg("等级不足，无法装备")
		return false
	end

	local nPos = self.nEquipPos or self:FindEmptyPos(me)
	if not nPos then
		local nActivateCount = JueXue:GetActivateAreaCount()
		me.CenterMsg(nActivateCount == 0 and "您尚未激活绝学区域" or "该位置已装备其他绝学道具")
		return false
	end

	RemoteServer.UseEquip(self.nItemId, nPos)
	Ui:CloseWindow(self.UI_NAME)
	if not Ui:WindowVisible("SkillPanel") then
		Ui:OpenWindow("SkillPanel", "LostKnowledgePanel", nPos)
	end
end

function tbUi:UnuseEquip()
	if not self.nItemId then
		return
	end

	local pItem = KItem.GetItemObj(self.nItemId)
	if not pItem then
		return false
	end

	Player:ClientUnUseEquip( pItem.nPos )
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:Sell()
	if not self.nItemId then
		return
	end

	Ui:CloseWindow(self.UI_NAME)
	Shop:ConfirmSell(self.nItemId)
end

function tbUi:OnBtnClick(nIdx)
	local tbBtnInfo = self.Option[self.szOption][nIdx]
	if not tbBtnInfo then
		return
	end

	local szFunc = tbBtnInfo[2]
	self[szFunc](self)
end

function tbUi:OnScreenClick(szClickUi)
	if szClickUi ~= self.szCompare and szClickUi ~= self.szNormal then
		Ui:CloseWindow(self.UI_NAME)
	end
end

function tbUi:OnTipsClose(szWnd)
	if szWnd == self.szCompare or szWnd == self.szNormal or szWnd == "ItemTips" then
		Ui:CloseWindow(self.UI_NAME)
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{UiNotify.emNOTIFY_WND_CLOSED, self.OnTipsClose}
	}

	return tbRegEvent
end

tbUi.tbOnClick = {}
for i = 1, 3 do
	tbUi.tbOnClick["Btn" .. i] = function (self)
		self:OnBtnClick(i)
	end
end

end

local tbDef = JueXue.Def
function JueXue:GetAllAttrib(tbEquips)
	local tbAllAttrib = {tbSkill = {}, tbSuit = {}, tbAttrib = {}}
	local tbSuitInfo  = {}
	local nLastSuitId = 0
	local fnBreak = function ()
		if tbSuitInfo[nLastSuitId] then
			tbSuitInfo[nLastSuitId].nCurLen = 0
			nLastSuitId = 0
		end
	end
	for nPos = Item.EQUIPPOS_JUEXUE_BEGIN, Item.EQUIPPOS_JUEXUE_END do
		local nItemId = tbEquips[nPos]
		if nItemId then
			local pItem = KItem.GetItemObj(nItemId)
			if pItem then
				local nType = self:GetPosType(nPos)
				if nType == Item.EQUIP_JUEXUE_BOOK then
					self:GetJuexueBookDesc(pItem, tbAllAttrib)
					fnBreak()
				elseif nType == Item.EQUIP_MIBEN_BOOK then
					self:GetMibenBookDesc(pItem, tbAllAttrib)
					fnBreak()
				else
					self:GetDuanpianBookDesc(pItem, tbAllAttrib)
					local nSuitId = pItem.GetIntValue(tbDef.tbDuanpianItemData.nSuitSkillId)
					if nSuitId > 0 then
						tbSuitInfo[nSuitId] = tbSuitInfo[nSuitId] or {nCurLen = 0, nMaxLen = 0}
						tbSuitInfo[nSuitId].nCurLen = tbSuitInfo[nSuitId].nCurLen + 1
						tbSuitInfo[nSuitId].nMaxLen = math.max(tbSuitInfo[nSuitId].nMaxLen, tbSuitInfo[nSuitId].nCurLen)
					end
					if nLastSuitId ~= nSuitId then
						fnBreak()
					end
					nLastSuitId = nSuitId
				end
			end
		end
	end
	local szDesc = ""
	local tbDesc = {}
	for szType, tbValue in pairs(tbAllAttrib.tbAttrib) do
		local szInfo, nRow = FightSkill:GetMagicDesc(szType, tbValue)
		if nRow and nRow > 0 then
			szInfo = string.gsub(szInfo, "%+%-", "%+")
			local nSort = FightSkill.tbAllMagicDesc[szType].nRow
			table.insert(tbDesc, {nSort, szInfo})
		end
	end
	table.sort(tbDesc, function (a, b) return a[1] < b[1] end)
	for _, tbInfo in ipairs(tbDesc) do
		szDesc = szDesc .. tbInfo[2] .. "\n"
	end
	tbAllAttrib.tbAttrib = nil
	tbAllAttrib.szAttrib = szDesc

	for nSuitId, tbInfo in pairs(tbSuitInfo) do
		table.insert(tbAllAttrib.tbSuit, {nSuitId, tbInfo.nMaxLen})
	end

	return tbAllAttrib
end

local fnInsertAttrib = function (tbList, tbAttrib)
	local AttribType = tbAttrib[1]
	tbList[AttribType] = tbList[AttribType] or {0, 0, 0}
	for i = 1, 3 do
		tbList[AttribType][i] = math.floor(tbList[AttribType][i] + tbAttrib[2][i])
	end
end

function JueXue:GetJuexueBookDesc(pEquip, tbAllAttrib)
	local tbBase = self.tbJuexue[pEquip.dwTemplateId]
	if not tbBase then
		return
	end

	local nSkillLv = pEquip.GetIntValue(tbDef.tbJuexueItemData.nSkillLv)
	local nSkillId = tbBase.SkillID
	local tbAttrib = {}
	local nCurAttribLv = pEquip.GetIntValue(tbDef.tbJuexueItemData.nAttribLv)
	for i, tbInfo in ipairs(tbBase.tbAttrib) do
		local nValue = tbInfo.InitValue + (nCurAttribLv - 1) * tbInfo.GrowValue
		nValue = math.floor(nValue/tbDef.nAttribScale)
		fnInsertAttrib(tbAllAttrib.tbAttrib, {tbInfo.AttribType, {nValue, 0, 0}})
	end
	if nSkillLv > 0 then
		tbAllAttrib.tbSkill[nSkillId] = nSkillLv
	end
end

function JueXue:GetMibenBookDesc(pEquip, tbAllAttrib)
	local nLevel = pEquip.nLevel
	for i = 1, tbDef.nMibenAttNum do
		local nIdx      = pEquip.GetIntValue(tbDef.tbMibenItemData.nAttribIdxBegin + (i - 1) * 2)
		local nValueIdx = pEquip.GetIntValue(tbDef.tbMibenItemData.nAttribValvePBegin + (i - 1) * 2)
		local tbInfo    = (self.tbAttrib[nIdx] or {})[nLevel]
		if tbInfo then
			local tbValue = {}
			for i = 1, 3 do
				local nValueMin   = tbInfo.tbValue[i][1]
				local nValueRange = tbInfo.tbValue[i][2]
				local nPercent    = (tbDef.tbDpAttribPercent[nValueIdx] or {}).nPercent or 0
				local nValue      = nValueMin + (nPercent / 100) * nValueRange
				table.insert(tbValue, nValue)
			end
			fnInsertAttrib(tbAllAttrib.tbAttrib, {tbInfo.AttribType, tbValue})
		end
	end
end

function JueXue:GetDuanpianBookDesc(pEquip, tbAllAttrib)
	local nLevel    = pEquip.nLevel
	local nMibenAdd = pEquip.GetIntValue(tbDef.tbDuanpianItemData.nMibenAdd)
	for i = 1, tbDef.nDuanpianAttNum do
		local nIdx      = pEquip.GetIntValue(tbDef.tbDuanpianItemData.nAttribIdxBegin + (i - 1) * 2)
		local nValueIdx = pEquip.GetIntValue(tbDef.tbDuanpianItemData.nAttribValvePBegin + (i - 1) * 2)
		local tbInfo    = (self.tbAttrib[nIdx] or {})[nLevel]
		if tbInfo then
			local tbValue = {}
			for j = 1, 3 do
				local nValueMin   = tbInfo.tbValue[j][1]
				local nValueRange = tbInfo.tbValue[j][2]
				local nPercent    = (tbDef.tbDpAttribPercent[nValueIdx] or {}).nPercent or 0
				local nValue      = nValueMin + ((nPercent + nMibenAdd) / 100) * nValueRange
				table.insert(tbValue, nValue)
			end
			fnInsertAttrib(tbAllAttrib.tbAttrib, {tbInfo.AttribType, tbValue})
		end
	end
end

function JueXue:UpdateRedPoint()
	for nPos, nAreaId in pairs(tbDef.tbJuexuePos) do
		local szRedPoint = "JueXueBookRP" .. nAreaId
		local bSetRP     = false
		local pEquip     = me.GetEquipByPos(Item.EQUIPPOS_JUEXUE_BEGIN + nPos - 1)
		if pEquip then
			bSetRP = self:CheckCanXiuLian(me, nAreaId, true)
		end
		local bState = Ui:GetRedPointState(szRedPoint)
		if bSetRP then
			if not bState then
				Ui:SetRedPointNotify(szRedPoint)
			end
		else
			if bState then
				Ui:ClearRedPointNotify(szRedPoint)
			end
		end
	end
end

function JueXue:GetItemCount(pPlayer)
	local nCount = 0
	local tbItemList = pPlayer.GetItemListInBag()
	for _, pItem in ipairs(tbItemList) do
		if pItem.szClass == "JuexueBook" or pItem.szClass == "MibenBook" or pItem.szClass == "DuanpianBook" then
			nCount = nCount + pItem.nCount
		end
	end
	return nCount
end

function JueXue:GetActivateAreaCount()
	local nActivateCount = 0
	for nAreaId, tbInfo in ipairs(tbDef.tbAreaInfo) do
		if self:IsAreaActivate(me, nAreaId) then
			nActivateCount = nActivateCount + 1
		end
	end
	return nActivateCount
end

JueXue.tbRedPointKey = {
	["JuexueBook"]   = "Skill_JueXue_Item_JX",
	["MibenBook"]    = "Skill_JueXue_Item_MB",
	["DuanpianBook"] = "Skill_JueXue_Item_DP",
}
function JueXue:InitNewItemTable()
	JueXue.tbNewItem = {}
	for szClass, szRedPoint in pairs(JueXue.tbRedPointKey) do
		JueXue.tbNewItem[szClass] = {}
		Ui:ClearRedPointNotify(szRedPoint)
	end
end

function JueXue:OnLogout()
	self.tbNewItem = nil
end

function JueXue:OnSyncItem(nItemId, bNew, nCount)
	if bNew == 0 or not self.tbNewItem or nCount <= 0 then
		return
	end
	local pItem = KItem.GetItemObj(nItemId)
	if not pItem or not self.tbRedPointKey[pItem.szClass] or not self.tbNewItem[pItem.szClass] then
		return
	end

	self.tbNewItem[pItem.szClass][nItemId] = true
	Ui:SetRedPointNotify(self.tbRedPointKey[pItem.szClass])
end

function JueXue:OnClickItem(nItemId)
	local pItem = KItem.GetItemObj(nItemId)
	if not pItem or not self.tbNewItem[pItem.szClass] then
		return
	end
	local szClass = pItem.szClass
	if not self.tbNewItem[szClass][nItemId] then
		return
	end
	self.tbNewItem[szClass][nItemId] = nil
	if next(self.tbNewItem[szClass]) then
		Ui:SetRedPointNotify(self.tbRedPointKey[szClass])
	else
		Ui:ClearRedPointNotify(self.tbRedPointKey[szClass])
	end
end

UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_ITEM, JueXue.OnSyncItem, JueXue)