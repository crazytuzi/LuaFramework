local tbUi = Ui:CreateClass("SelectScrollView");

function tbUi:OnOpen(tbDatas, fnSelCallBack)
    self.fnSelCallBack = fnSelCallBack

    local fnClickItem = function (itemObj)
        local index = itemObj.index
        fnSelCallBack(index)
        Ui:CloseWindow(self.UI_NAME)
    end

    local fnSetItem = function (itemObj, index)
        local szName = tbDatas[index]
        itemObj.pPanel:Label_SetText("Label", szName)
        itemObj.index = index
        itemObj.pPanel.OnTouchEvent = fnClickItem
    end
    
    self.ScrollView:Update(#tbDatas, fnSetItem)
end

function tbUi:OnClose()
    self.fnSelCallBack = nil;
end

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME)
end