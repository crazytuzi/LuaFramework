local tbUi = Ui:CreateClass("FiveElements2")
tbUi.tbSeriesInfo = {
	{"GoldMark", 	{191,160,32}},
	{"WoodMark", 	{73,161,121}},
	{"WaterMark", 	{73,128,161}},
	{"FireMark", 	{176,69,69}},
	{"EarthMark", 	{124,130,149}},
}

function tbUi:OnOpenEnd(nRestrainType)
	local nMySeries  = KPlayer.GetPlayerInitInfo(me.nFaction, me.nSex).nSeries
	local tbRelation = Npc.tbSeriesRelation[nMySeries]
	local tbSeries   = {}
	if nRestrainType == 2 then
		table.insert(tbSeries, Npc.tbSeriesRelation[nMySeries][2])
		table.insert(tbSeries, nMySeries)
	else
		table.insert(tbSeries, nMySeries)
		table.insert(tbSeries, Npc.tbSeriesRelation[nMySeries][1])
	end
	for i, nSeries in ipairs(tbSeries) do
		self.pPanel:Sprite_SetSprite("FiveElements" .. i, self.tbSeriesInfo[nSeries][1])
		self.pPanel:Sprite_SetColor("Colour" .. i, unpack(self.tbSeriesInfo[nSeries][2]))
		local tbFaction = Faction:GetSeriesFaction(nSeries)
		for j = 1, 5 do
			local nFaction = tbFaction[j]
			self.pPanel:SetActive("Faction" .. i .. j, nFaction or false)
			if nFaction then
				self.pPanel:Sprite_SetSprite("Faction" .. i .. j, Faction:GetSmallIcon(nFaction))
				self.pPanel:Label_SetText("FactionName" .. i .. j, Faction:GetName(nFaction))
			end
		end
	end
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end
}