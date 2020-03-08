local tbUi = Ui:CreateClass("NewInfo_DomainBattle")

function tbUi:OnOpen(tbData)
	local szNews, tbNewsCityInfo = unpack(tbData)
	self.pPanel:Label_SetText("Content2", string.format("\n      %s\n领地占据情况如下：\n", szNews))
	local nIndex = 0;
	for nLevel = 1, 3 do
		local nLevel2Maps = DomainBattle:GetLevelMaps(nLevel);
		local szMapLevel = DomainBattle.tbMapLevelDesc[nLevel]
		for i, nMapTempalteId in ipairs(nLevel2Maps) do
			nIndex = nIndex + 1
			local szMapName = Map:GetMapName(nMapTempalteId)
			local szKinName = tbNewsCityInfo[nMapTempalteId] or "-"
			self.pPanel:Label_SetText("TerritoryName" .. nIndex, szMapName)
			self.pPanel:Label_SetText("TerritoryType" .. nIndex, szMapLevel)
			self.pPanel:Label_SetText("FamliyName" .. nIndex, szKinName)
		end	
	end


	local tbTextSize = self.pPanel:Label_GetPrintSize("Content2");
	local tbSize = self.pPanel:Widget_GetSize("datagroup2");
	local tbCellSize = self.pPanel:Widget_GetSize("Info1");
	self.pPanel:Widget_SetSize("datagroup2", tbSize.x, 50 + tbTextSize.y + tbCellSize.y * 14);
    self.pPanel:DragScrollViewGoTop("datagroup2");
    self.pPanel:UpdateDragScrollView("datagroup2");
end

