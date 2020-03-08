local tbUi = Ui:CreateClass("QYHNewEntrance");

function tbUi:OnOpen()
	self:RefreshUi()
end

function tbUi:RefreshUi()
	self.pPanel:SetActive("Tips", false)
	self.pPanel:Label_SetText("Describetxt", string.format("1.群英会为双人实时匹配竞技玩法，所有侠士[FFFE0D]拥有相同的战力水平[-]，等级[FFFE0D]达到70级[-]的侠士，均可报名参加比赛\n\n2.侠士可[FFFE0D]单人报名[-]，也可[FFFE0D]双人组队[-]报名，单人报名的侠士将在对战时自动匹配队友。报名后可在[FFFE0D]随机的8个门派[-]中选择心仪门派参与竞技\n\n3.活动期间可随时入场，也可再次通过报名入口返回准备场继续匹配"));
	local fnSetItem = function(itemObj, nIdx)
		local tbInfo = QunYingHuiCross.tbShowAward[nIdx]
		local tbAward = tbInfo[1]
		local szDes = tbInfo[2] or ""
		itemObj["itemframe"]:SetGenericItem(tbAward)
		itemObj["itemframe"].fnClick = itemObj["itemframe"].DefaultClick;
		itemObj.pPanel:Label_SetText("Label", szDes)
	end
	self.ScrollView:Update(#QunYingHuiCross.tbShowAward, fnSetItem);
end

tbUi.tbOnClick = {
	BtnApplyList = function(self)
		RemoteServer.QYHCrossClientCall("TryJoin")
	end;
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
}