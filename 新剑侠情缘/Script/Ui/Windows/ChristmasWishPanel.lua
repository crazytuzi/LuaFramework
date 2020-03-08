local tbUi = Ui:CreateClass("ChristmasWishPanel")

tbUi.tbOnClick = 
{
    BtnClose = function(self)
        Ui:CloseWindow(self.UI_NAME)
    end,

    BtnWish1 = function(self)
        Activity.NewYearChris:MakeWish()
    end,

    BtnWish2 = function(self)
        self:TryOpenAddWishPanel()
    end,
}

function tbUi:RegisterEvent()
    local tbRegEvent = {
        {UiNotify.emNOTIFY_NYC_WISHLIST_CHANGE, self.Refresh},
    }
    return tbRegEvent
end

function tbUi:OnOpen()
    self:Refresh()
    Activity.NewYearChris:UpdateWishList()
end

function tbUi:Refresh()
    local tbList = Activity.NewYearChris.tbWishList or {}
    self.ScrollView:Update(#tbList, function(pGrid, nIdx)
        local tbData = tbList[nIdx]
        local szName, nFaction, nPortrait, nLevel, szText = unpack(tbData)
        pGrid.pPanel:Label_SetText("WishTxt", string.format("%s：%s", szName, szText))

        pGrid.pPanel:Sprite_SetSprite("SpFaction",  Faction:GetIcon(nFaction))
        pGrid.pPanel:Label_SetText("lbLevel", nLevel)

        local szIcon, szAtlas = PlayerPortrait:GetPortraitIcon(nPortrait)
        pGrid.pPanel:Sprite_SetSprite("SpRoleHead", szIcon, szAtlas)
    end)
end

function tbUi:TryOpenAddWishPanel()
    local nLeft = me.GetUserValue(Activity.NewYearChris.nWishGiftSaveGrp, Activity.NewYearChris.nWishesLeft) or 0
    if nLeft>0 then
        Ui:OpenWindow("ChristmasWishListPanel")
        return
    end
    me.CenterMsg("剩余祈福次数不足")
end