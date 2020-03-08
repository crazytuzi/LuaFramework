local tbUi = Ui:CreateClass("MagicBowlPanel")

function tbUi:OnOpen(nId, nOwner)
	self.nOwner = nOwner or House.dwOwnerId
	self.nId = nId
	self.pPanel:SetActive("ShengJi_texiao", false)
	House:UpdateMagicBowlData(self.nOwner)
	self:Refresh()

	self:StartTimer()
end

function tbUi:OnUpgrade(nId)
	self.nId = nId
	self.pPanel:SetActive("ShengJi_texiao", false)
	self.pPanel:SetActive("ShengJi_texiao", true)
end

function tbUi:StartTimer()
	self:StopTimer()
	self.nTimer = Timer:Register(Env.GAME_FPS, function()
		self:UpdateInscription(true)
		self:UpdatePrayTime()
		return true
	end)
end

function tbUi:UpdatePrayTime()
	local szLeftTime = "即将重置"
	local tbData = House:GetMagicBowlData(self.nOwner)
	if tbData then
		if tbData.tbPray.nLastPray and tbData.tbPray.nLastPray<0 then
			szLeftTime = "已重置"
		else
			local nTimeLeft = Furniture.MagicBowl.Def.nPrayDuration-(GetTime()-(tbData.tbPray.nLastPray or 0))
			if nTimeLeft>0 then
				szLeftTime = Lib:TimeDesc3(nTimeLeft)
			end
		end
	end
	self.pPanel:Label_SetText("Time", string.format("当前运势持续时间：%s", szLeftTime))
	if not tbData or not next(tbData.tbNewAttrs or {}) then
		self.pPanel:Label_SetText("Time", "")
	end
end

function tbUi:StopTimer()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil
	end
end

function tbUi:OnClose()
	self:StopTimer()
end

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnPray = function(self)
		if not self:IsOwnMagicBowl() then
			me.CenterMsg("这不是你的聚宝盆")
			return
		end
		House:MagicBowlPray()
	end,

	BtnLevel = function(self)
		if not self:IsOwnMagicBowl() then
			me.CenterMsg("这不是你的聚宝盆")
			return
		end
		if not self.nId or self.nId<=0 then
			me.CenterMsg("请点击家园中的聚宝盆打开此界面进行升级操作")
			return
		end
		Ui:OpenWindow("MagicBowlSelectMaterialPanel", false, self.nId)
	end,

	BtnForging = function(self)
		if not self:IsOwnMagicBowl() then
			me.CenterMsg("这不是你的聚宝盆")
			return
		end
		local tbData = House:GetMagicBowlData(self.nOwner)
		if not tbData then
			return
		end
		local szState = Furniture.MagicBowl:GetInscriptionState(tbData.nLevel, tbData.tbInscription.nStage, tbData.tbInscription.nDeadline)
		if szState=="finished" then
			return House:MagicBowlInsHarvest()
		elseif szState=="rest" then
			Ui:OpenWindow("MagicBowlSelectMaterialPanel", true)
			return
		elseif szState=="running" then
			me.CenterMsg("当前阶段尚未完成")
			return
		else
			Log("[x] MagicBowlPanel, unknown state", tbData.tbInscription.nStage, tbData.tbInscription.nDeadline, szState)
			return
		end
	end,
}

function tbUi:RegisterEvent()
	return {
		{UiNotify.emNOTIFY_SYNC_MAGICBOWL, self.OnSyncMagicBowl, self};
	}
end

function tbUi:OnSyncMagicBowl()
	self:Refresh()
end

function tbUi:UpdateAttr()
	local tbData = House:GetMagicBowlData(self.nOwner)
	if not tbData then
		return
	end

	local nMaxAttrCount = Furniture.MagicBowl:GetMaxAttrCount(self.nOwner)
	for i=1, 8 do
		local bValid = i<=nMaxAttrCount
		if bValid then
			local szKey1, szKey2 = string.format("Attribute%d1", i), string.format("Attribute%d2", i)
			local szValue1, szValue2 = "<无>", ""
			local nAttribLevel = 0
			local nPrayQuility = 1
			if tbData.tbNewAttrs then
				local nAttrData = tbData.tbNewAttrs[i]
				if nAttrData then
					szValue1, nAttribLevel = House:MagicBowlGetAttrDesc(nAttrData)
					szValue2, nPrayQuility = self:GetPrayDesc(nAttrData, tbData.tbPray.tbIdxs[i])
				end
			end
			self.pPanel:Label_SetText(szKey1, szValue1)

			local nColor = 1
			if nAttribLevel and nAttribLevel>0 then
				nColor = Furniture.MagicBowl:GetAttribColor(tbData.nLevel, nAttribLevel)
			end
			local szColor  = Item:GetQualityColor(nColor)
			self.pPanel:Label_SetColorByName(szKey1, szColor or "White")

			self.pPanel:Label_SetText(szKey2, szValue2)
			local szPrayColor  = Item:GetQualityColor(nPrayQuility)
			self.pPanel:Label_SetColorByName(szKey2, szPrayColor or "White")
		end
		self.pPanel:SetActive("Attribute"..i, bValid)
	end

	local bNewDay = Lib:IsDiffDay(Furniture.MagicBowl.Def.nNewDayTime, GetTime(), tbData.tbPray.nLastUpdate)
	local nNextTimes = (bNewDay and 0 or tbData.tbPray.nTimes)+1
	local nNextCost = Furniture.MagicBowl:GetPrayCost(nNextTimes)
	local szNextCost = "免费"
	if nNextCost>0 then
		szNextCost = string.format("%d%s", nNextCost, Shop:GetMoneyName(Furniture.MagicBowl.Def.szPrayCostType))
	end
	self.pPanel:Label_SetText("PrayConsume", string.format("本次祈福消耗：%s", szNextCost))
end

function tbUi:UpdateMainInfo()
	local tbData = House:GetMagicBowlData(self.nOwner)
	if not tbData then
		return
	end

	self.pPanel:Label_SetText("CornucopiaLevel", string.format("%d级", tbData.nLevel))
end

function tbUi:UpdateInscription(bTimer)
	local tbData = House:GetMagicBowlData(self.nOwner)
	if not tbData then
		return
	end

	local szState = Furniture.MagicBowl:GetInscriptionState(tbData.nLevel, tbData.tbInscription.nStage, tbData.tbInscription.nDeadline)
	if bTimer and szState~="running" and self.szOldState==szState then
		return
	end
	self.szOldState = szState

	local tbSetting = Furniture.MagicBowl:GetInscriptionMakeSetting(tbData.nLevel)
	self.Item:SetItemByTemplate(tbSetting.nItemId, 1)
	self.Item.fnClick = self.Item.DefaultClick

	self.pPanel:SetActive("CurrentInscription", false)
	self.pPanel:Label_SetColorByName("CurrentInscription", "White")
	self.pPanel:SetActive("BtnForging", false)
	self.pPanel:SetActive("Bar", false)

	if szState=="running" then
		self.pPanel:SetActive("Bar", true)
		local nTimeLeft = math.max(tbData.tbInscription.nDeadline-GetTime(), 0)
		self.pPanel:Label_SetText("InscriptionTxt1", string.format("锻造中......（剩余：%s）", Lib:TimeDesc3(nTimeLeft)))
		local nTotalTime = tbSetting["nTime"..tbData.tbInscription.nStage]
		local nPercent = math.max(0, (nTotalTime-nTimeLeft)/nTotalTime)
		self.pPanel:ProgressBar_SetValue("Bar", nPercent)
		self.pPanel:Label_SetText("BarTxt", string.format("%d%%", nPercent*100))
	elseif szState=="finished" then
		self.pPanel:SetActive("BtnForging", true)
		self.pPanel:Button_SetText("BtnForging", "收取铭文")

		local szName = Item:GetItemTemplateShowInfo(tbSetting.nItemId, me.nFaction, me.nSex)
		self.pPanel:Label_SetText("CurrentInscription", string.format("%s已锻造完成！", szName))
		self.pPanel:Label_SetColorByName("CurrentInscription", "Green")
		self.pPanel:SetActive("CurrentInscription", true)
	elseif szState=="rest" then
		self.pPanel:SetActive("BtnForging", true)
		self.pPanel:Button_SetText("BtnForging", "投入材料")

		local szName = Item:GetItemTemplateShowInfo(tbSetting.nItemId, me.nFaction, me.nSex)
		self.pPanel:Label_SetText("CurrentInscription", string.format("当前可锻造：%s", szName))
		self.pPanel:SetActive("CurrentInscription", true)
	else
		return
	end

	if not self:IsOwnMagicBowl() then
		self.pPanel:SetActive("BtnForging", false)
	end
end

function tbUi:IsOwnMagicBowl()
	return self.nOwner==me.dwID
end

function tbUi:Refresh()
	self.pPanel:Label_SetText("Time", "")
	local tbData = House:GetMagicBowlData(self.nOwner)
	if not tbData then
		return
	end

	local bOwner = self:IsOwnMagicBowl()
	self.pPanel:SetActive("BtnForging", bOwner)
	self.pPanel:SetActive("BtnLevel", bOwner)
	self.pPanel:SetActive("BtnPray", bOwner)

	self:UpdateMainInfo()
	self:UpdateAttr()
	self:UpdateInscription()
end

local tbUseMa2Types = {
	ignore_metal_resist_v = true,
	ignore_wood_resist_v = true,
	ignore_water_resist_v = true,
	ignore_fire_resist_v = true,
	ignore_earth_resist_v = true,
	ignore_all_resist_v = true,
	ignore_all_resist = true,
}
local tbUsePercentTypes = {
	lifemax_p = true,
	lifecurmax_p = true,
	lifereplenish_p = true,
	physics_potentialdamage_p = true,
	all_series_resist_p = true,
	ignore_all_resist = true,
	attackrate_p = true,
	defense_p = true,
	ignore_defense_p = true,
	ignore_defense_vp = true,
	ignore_all_resist_vp = true,
	ignore_deadlystrike_vp = true,
	deadlystrike_p = true,
	deadlystrike_damage_p = true,
	weaken_deadlystrike_damage_p = true,
	steallife_p = true,
	steallife_resist_p = true,
	meleedamagereturn_p = true,
	rangedamagereturn_p = true,
	enhance_final_damage_p = true,
	reduce_final_damage_p = true,
	melee_dmg_p = true,
	remote_dmg_p = true,
	damage4npc_p = true,
	damage4player_p = true,
	playerdmg_npc_p = true,
}
function tbUi:GetPrayDesc(nSaveData, nIdx)
	local _, szDesc, nQuility = unpack(Furniture.MagicBowl.Def.tbPrayPercentDesc[nIdx])
	local nGrpId, nLvl = Furniture.MagicBowl:GetPrayValue(nSaveData, nIdx)
	local tbAttr = KItem.GetExternAttrib(nGrpId, nLvl)[1]
	local szType = tbAttr.szAttribName
	local nValue = tbUseMa2Types[szType] and tbAttr.tbValue[2] or tbAttr.tbValue[1]
	local szPostfix = tbUsePercentTypes[szType] and "%" or ""
	return string.format("+%d%s（%s）", nValue, szPostfix, szDesc), nQuility
end