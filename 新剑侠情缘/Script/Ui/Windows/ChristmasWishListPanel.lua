local tbUi = Ui:CreateClass("ChristmasWishListPanel")

tbUi.tbWishList = {
    "希望能够早日遇见那尚未谋面的一世情缘",   
    "希望我等生死相交的弟兄，此情不改", 
    "望能执子之手，与子偕老",  
    "心中无他求，惟愿君安好",  
    "希望我心上之人，一世平安快乐",   
    "希望家族能够蒸蒸日上，越来越好", 
    "家族称霸武林，指日可待",  
    "希望这个江湖能越来越热闹，越来越鼎盛",   
    "希望族中的弟兄越来越帅，姐妹越来越美",   
    "日照香炉生紫烟，紫烟先不说，香炉在哪？", 
    "江湖纷乱，谁拔了剑，成了侠，动了情，结了缘？",   
    "愿我掌中青锋，斩尽天下恶徒！",   
    "愿我手中双锤，扫尽天下狂徒！",   
    "愿我掌中冷锋，正我雪峰之名！",
    "愿我手中长剑，渡化愚昧宵小！",   
    "愿我掌中机簧，捍我世家之名！",   
    "愿我手握长枪，伴我傲笑红尘！",   
    "愿我掌中铜棍，伏尽天下邪魔！",   
    "愿我背上长弓，尽诛不义之徒！",   
}

tbUi.tbOnClick = 
{
    BtnClose = function(self)
        Ui:CloseWindow(self.UI_NAME)
    end,

    BtnWish = function(self)
        local szLabel
        if self.nSelectedIdx==0 then
            szLabel = self.pPanel:Input_GetText("WishTxt")
        else
            szLabel = self.tbWishList[self.nSelectedIdx]
        end
        if Activity.NewYearChris:AddWish(szLabel) then
            Ui:CloseWindow(self.UI_NAME)
        end
    end,

    WishTxt = function(self)
        self.nSelectedIdx = 0
    end,
}

tbUi.tbUiInputOnChange = {
    WishTxt = function(self)
        self.nSelectedIdx = 0
    end,
}

function tbUi:OnOpenEnd()
    self.ScrollView:Update(#self.tbWishList, function(pGrid, nIdx)
        pGrid.pPanel:Label_SetText("WishTxt", self.tbWishList[nIdx])
        pGrid.pPanel:Toggle_SetChecked("Main", false)
        pGrid.pPanel.OnTouchEvent = function()
            self.nSelectedIdx = nIdx
        end
    end)

    local nLeft = me.GetUserValue(Activity.NewYearChris.nWishGiftSaveGrp, Activity.NewYearChris.nWishesLeft) or 0
    self.pPanel:Label_SetText("Desc", string.format("剩余祈福次数：%d", nLeft))
end
