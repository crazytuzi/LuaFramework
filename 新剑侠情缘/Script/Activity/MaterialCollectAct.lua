local tbAct = Activity.MaterialCollectAct
tbAct.tbMaterialData = tbAct.tbMaterialData or {}
function tbAct:OnSynMaterialData(tbData)
	self.tbMaterialData = tbData
	UiNotify.OnNotify(UiNotify.emNOTIFY_ON_SYN_MATERIAL_COLLECT_DATA)
end

function tbAct:OnFindEnterNpc(nNpcTID)
	Ui:CloseWindow("ItemBox")
	Ui:CloseWindow("ItemTips")
	AutoPath:AutoPathToNpc(nNpcTID, self.nEnterNpcMapTID, self.nEnterNpcPosX, self.nEnterNpcPosY)
end

function tbAct:OnLeaveMap()
	for _, szUiName in ipairs(self.tbLeaveMapCloseUi) do
		Ui:CloseWindow(szUiName)
	end
end