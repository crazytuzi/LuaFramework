local tbUi = Ui:CreateClass("KinDefendApplyPanel")
tbUi.tbOnClick =
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
}

function tbUi:OnOpen(tbPlayers)
	self:UpdatePlayers(tbPlayers)
end

function tbUi:Refresh()
	self.ScrollView:Update(#self.tbPlayers, function(pGrid, nIdx)
		local tbItemData = self.tbPlayers[nIdx]

		pGrid.pPanel:Label_SetText("Name", tbItemData.szName)
		pGrid.pPanel:SetActive("Title", tbItemData.nHonorLevel > 0)
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbItemData.nHonorLevel)
		pGrid.pPanel:Sprite_Animation("Title", ImgPrefix, Atlas)
		pGrid.pPanel:SetActive("Apply", tbItemData.bApplied)
		pGrid.pPanel:SetActive("Agree", tbItemData.bConfirmed)

		pGrid.pPanel.OnTouchEvent = function ()
			if not tbItemData.bConfirmed then
				local szMsg = string.format("是否允许%s挑战完颜宗翰分身？", tbItemData.szName)
			    me.MsgBox(szMsg, {{"确定", function()
			        Fuben.KinDefendMgr:ConfirmApply(tbItemData.nId)
			    end}, {"取消"}})
			else
				local szMsg = string.format("是否取消[FFFE0D]%s[-]的挑战权限？", tbItemData.szName)
			    me.MsgBox(szMsg, {{"确定", function()
			        Fuben.KinDefendMgr:CancelConfirmApply(tbItemData.nId)
			    end}, {"取消"}})
			end
	    end
	end)
end

function tbUi:UpdatePlayers(tbPlayers)
	self.tbPlayers = tbPlayers
	self:Refresh()
end