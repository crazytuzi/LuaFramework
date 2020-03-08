local tbUi = Ui:CreateClass("LoginActNpcPanel")
function tbUi:OnOpenEnd(nResID, szContent)
    self.pPanel:NpcView_Open("PartnerView")
    self.pPanel:NpcView_ShowNpc("PartnerView", nResID)
    local tbPos = Npc.tbTaskDialogModelPos[nResID] or Npc.tbTaskDialogModelPos[0]
    self.pPanel:NpcView_SetModePos("PartnerView", unpack(tbPos))
    self.pPanel:NpcView_SetWeaponState("PartnerView", 0)
    self.pPanel:Label_SetText("Content", szContent)
end

function tbUi:OnClose()
    self.pPanel:NpcView_Close("PartnerView")
end

tbUi.tbOnClick = {}
tbUi.tbOnClick.BtnClose = function (self)
    Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnDrag = 
{
    PartnerView = function (self, szWnd, nX, nY)
        self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
    end,
}

tbUi.tbOnDragEnd = {
    PartnerView = function (self, szWnd, nX, nY)
    end,
}