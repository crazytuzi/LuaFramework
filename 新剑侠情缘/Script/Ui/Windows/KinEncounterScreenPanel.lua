local tbUi = Ui:CreateClass("KinEncounterScreenPanel")

tbUi.tbOnClick = {
	BtnOrdnance1 = function(self)
		if not self.bInA then
			return
		end
		Ui:OpenWindow("KinEncounterShopPanel")
	end,
	BtnOrdnance2 = function(self)
		if self.bInA then
			return
		end
		Ui:OpenWindow("KinEncounterShopPanel")
	end,
	BtnCheck1 = function(self)
		if not self.bInA then
			return
		end
		Ui:OpenWindow("KinEncounterRankPanel")
	end,
	BtnCheck2 = function(self)
		if self.bInA then
			return
		end
		Ui:OpenWindow("KinEncounterRankPanel")
	end,
}

function tbUi:OnOpen(tbData)
	self.tbKinA = tbData[1]
	self.tbKinB = tbData[2]
	self.tbKinIds = {self.tbKinA.nKinId, self.tbKinB.nKinId}
	self.bInA = me.dwKinId == self.tbKinA.nKinId

	self.pPanel:Label_SetText("Name1", self.tbKinA.szName)
	self.pPanel:Label_SetText("Name2", self.tbKinB.szName)

	self.pPanel:SetActive("BtnOrdnance1", self.bInA)
	self.pPanel:SetActive("BtnOrdnance2", not self.bInA)
	self.pPanel:SetActive("BtnCheck1", self.bInA)
	self.pPanel:SetActive("BtnCheck2", not self.bInA)

	self:Refresh()

	self:CloseTimer()
	self.nTimeTimer = Timer:Register(tbData.nTimeLeft * Env.GAME_FPS, self.OnTotalTime, self);
	self.nUpdateTimer = Timer:Register(Env.GAME_FPS, self.OnUpdateTime, self)
end

function tbUi:CloseTimer()
	if self.nTimeTimer then
		Timer:Close(self.nTimeTimer)
		self.nTimeTimer = nil
	end

	if self.nUpdateTimer then
		Timer:Close(self.nUpdateTimer)
		self.nUpdateTimer = nil
	end
end

function tbUi:OnTotalTime()
	self.nTimeTimer = nil
end

function tbUi:OnUpdateTime()
	self.nUpdateTimer = nil
	if not self.nTimeTimer then
		self.pPanel:Label_SetText("Time", "已结束")
		return
	end

	local nLastTime = math.floor(Timer:GetRestTime(self.nTimeTimer) / Env.GAME_FPS)
	if nLastTime <= 0 then
		self.pPanel:Label_SetText("Time", "已结束")
		return
	end

	self.pPanel:Label_SetText("Time", Lib:TimeDesc3(nLastTime))
	self.nUpdateTimer = Timer:Register(Env.GAME_FPS, self.OnUpdateTime, self)
end

function tbUi:Refresh()
	local tbScreenData = KinEncounter:GetScreenData()
	for i=1, 2 do
		local tbData = tbScreenData[self.tbKinIds[i]] or {}
		self.pPanel:Label_SetText("ScoreNum"..i, tbData.nScore or "-")
		self.pPanel:Label_SetText("WoodNum"..i, tbData.nWood or "-")
		self.pPanel:Label_SetText("GranaryNum"..i, tbData.nFood or "-")
		self.pPanel:Label_SetText("KillNum"..i, tbData.nKillRank or "-")
	end
end

function tbUi:RegisterEvent()
	return {
		{UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterMap},
	}
end

function tbUi:OnEnterMap(nTemplateMapId)
	if nTemplateMapId ~= KinEncounter.Def.nFightMapId then
		Ui:CloseWindow(self.UI_NAME)
	end
end

function tbUi:OnGameOver()
	self.nTimeTimer = nil
end