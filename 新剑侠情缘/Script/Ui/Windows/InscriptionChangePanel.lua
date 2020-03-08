local tbUi = Ui:CreateClass("InscriptionChangePanel");

function tbUi:OnOpen(nScrItemId)
    self.nScrItemId = nScrItemId
    local tbStoneList = RecordStone:GetCurStoneList(me)     
    if #tbStoneList ~= RecordStone.MAX_RECORD_STONE_NUM then
        me.CenterMsg("数据错误")
        return 0
    end
    for i=1,RecordStone.MAX_RECORD_STONE_NUM do
        self.pPanel:Toggle_SetChecked("Toggle" .. i, false)
        local nStoneId = tbStoneList[i];
        local tbInfo = RecordStone:GetStoneInfo(nStoneId)
        self.pPanel:Sprite_SetSprite("Item" .. i, tbInfo.Sprite, tbInfo.Atlas)
        self.pPanel:Label_SetText("Txt" .. i, string.format("%s：%d", tbInfo.Name, RecordStone:GetRecordCountByStoneId(me, nStoneId)) )
    end

end

function tbUi:GetSelIndex()
    for i=1,RecordStone.MAX_RECORD_STONE_NUM do
        local bChecked = self.pPanel:Toggle_GetChecked("Toggle" .. i)
        if bChecked then
            return i;
        end
    end
end

tbUi.tbOnClick = {};

for i = 1, RecordStone.MAX_RECORD_STONE_NUM do
    tbUi.tbOnClick["InscriptionItem" .. i] = function (self)
        self.pPanel:Toggle_SetChecked("Toggle" .. i, true)
    end
end

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnCancel()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnSure()
    local nInsetPos = self:GetSelIndex()
    if not nInsetPos then
        me.CenterMsg("未选中要替换的铭刻石头")
        return
    end
    RecordStone:DoRequestRecord(self.nScrItemId, nInsetPos)
end
