local tbUi = Ui:CreateClass("TerritorialWarAchievementPanel")

function tbUi:OnOpen()
	self:UpdateRank()
end

function tbUi:UpdateRank( )
	local tbAllRole = LingTuZhan:GetKinAllRoleRank()
	local tbAllRank = {}
	
	for k,v in pairs(tbAllRole) do
		v.dwID = k;
		table.insert(tbAllRank, v)
	end
	table.sort( tbAllRank, function (a ,b)
		return a.nScore > b.nScore
	end )
	local nMyRank;
	for i,v in ipairs(tbAllRank) do
		if v.dwID == me.dwID then
			nMyRank = i;
			break;
		end
	end
	for i=1,10 do
		local tbInfo = tbAllRank[i]
		if tbInfo then
			self.pPanel:SetActive("RankItem" .. i, true)
			self.pPanel:Label_SetText("RoleName" .. i, tbInfo.szName)
			self.pPanel:Label_SetText("Integral" .. i, tbInfo.nScore)
			self.pPanel:Label_SetText("KillNumber" .. i, tbInfo.nKillCount or 0)
			self.pPanel:SetActive("Assist" .. i, false)
		else
			self.pPanel:SetActive("RankItem" .. i, false)
		end
	end
	if nMyRank and nMyRank > 10  then
		local i = 11
		self.pPanel:SetActive("RankItem" .. i, true)
		local tbInfo = tbAllRank[nMyRank]
		self.pPanel:Label_SetText("RoleName" .. i, tbInfo.szName)
		self.pPanel:Label_SetText("Integral" .. i, tbInfo.nScore)
		self.pPanel:Label_SetText("KillNumber" .. i, tbInfo.nKillCount or 0)
		self.pPanel:SetActive("Assist" .. i, false)
	else
		self.pPanel:SetActive("RankItem" .. 11, false)
	end
end

function tbUi:OnSynData( szDataType )
	if szDataType == "KinAllRoleRank" then
		self:UpdateRank()
	end
end

function tbUi:RegisterEvent()
    return 
    {
        { UiNotify.emNOTIFY_LTZ_SYN_DATA, self.OnSynData, self },
    };
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnClose(  )
	Ui:CloseWindow(self.UI_NAME)
end