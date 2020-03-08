local tbUi = Ui:CreateClass("WeddingHeadPointPanel");
function tbUi:OnOpen(tbRoleData, nWeddingLevel)
	tbRoleData = tbRoleData or {}
	local szManName = tbRoleData[1] and tbRoleData[1].szName or ""
	local szWomanName = tbRoleData[2] and tbRoleData[2].szName or ""
	local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nWeddingLevel]
	local tbPath = tbMapSetting and tbMapSetting.tbMarryCeremonyRolePath or {}
	local szManPath = tbPath.Man
	local szWomanPath = tbPath.Woman
	local szLoliPath = tbPath.Loli

	self.pPanel:SetActive("Name1", false)
	self.pPanel:SetActive("Name2", false)
	self.pPanel:SetActive("Name3", false)

	self.pPanel:Label_SetText("Name1", string.format("[ff578c]%s[-]", szManName))     			-- 男主
	self.pPanel:SetActive("Name1", true)
	self.pPanel:SceneObj_SetFollow("Follow1", szManPath)
	
	self.pPanel:Label_SetText("Name2", string.format("[ff578c]%s[-]", szWomanName)) 			-- 标女
	self.pPanel:SetActive("Name2", true)
	self.pPanel:SceneObj_SetFollow("Follow2", szWomanPath)

	-- self.pPanel:Label_SetText("Name3", string.format("[FF4040]%s[-]", szWomanName)) 			-- loli
	-- self.pPanel:SetActive("Name3", true)
	-- self.pPanel:SceneObj_SetFollow("Follow3", szLoliPath)
	
end