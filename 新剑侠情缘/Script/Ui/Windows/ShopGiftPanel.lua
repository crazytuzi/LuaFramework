local tbUi = Ui:CreateClass("ShopGiftPanel");
local emPLAYER_STATE_NORMAL = 2 --正常在线状态

function tbUi:OnOpen(tbSelectItem)
    if not tbSelectItem or not tbSelectItem.nTemplateId then
        return 0;
    end
    self.tbSelectItem = tbSelectItem


    local tbAllFriend = self:GetFriendList()
    self.tbAllFriend  = tbAllFriend

    local tbFriendGrid = Ui:GetClass("FriendGrid");
    self.nSelIndex = nil;
    self.dwRoleIdSend = nil

    local fnOnClick = function (itemObj)
        if self.nLockTimer then
            return
        end
        itemObj.pPanel:Toggle_SetChecked("Main", true)
        self.nSelIndex  = itemObj.index
    end

    local fnSetItem = function (itemObj, index)
        local tbRoleInfo = tbAllFriend[index]
        itemObj.index = index
        local szSprite = "BtnListFourthOwn"; 
        if self.nFactionLimit and self.nFactionLimit ~= tbRoleInfo.nFaction then
            szSprite = "BtnListFourthNormal"
        end
        itemObj.pPanel:Button_SetSprite("Main", szSprite, 1)

        local SpFaction = Faction:GetIcon(tbRoleInfo.nFaction)
        local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbRoleInfo.nPortrait)
        itemObj.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);
        if tbRoleInfo.nState == emPLAYER_STATE_NORMAL then
            itemObj.pPanel:Sprite_SetSprite("SpRoleHead",  szPortrait, szAltas);
            itemObj.pPanel:Sprite_SetGray("Main", false);
        else
            itemObj.pPanel:Sprite_SetSpriteGray("SpRoleHead",  szPortrait, szAltas);
            itemObj.pPanel:Sprite_SetGray("Main", true);
        end
        itemObj.pPanel:Label_SetText("lbLevel", tbRoleInfo.nLevel)

        local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbRoleInfo.nHonorLevel)
        if ImgPrefix then
            itemObj.pPanel:SetActive("PlayerTitle", true);
            itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
        else
            itemObj.pPanel:SetActive("PlayerTitle", false);
        end
        itemObj.pPanel:Label_SetText("RoleName", tbRoleInfo.szName)
        local nVipLevel = tbRoleInfo.nVipLevel
        if not nVipLevel or  nVipLevel == 0 then
            itemObj.pPanel:SetActive("VIP", false)
        else
            itemObj.pPanel:SetActive("VIP", true)
            itemObj.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
        end

        local szShape, szShapeName = ActionInteract:GetFactionShape(tbRoleInfo.nFaction, tbRoleInfo.nSex);
        itemObj.pPanel:Label_SetText("Type", szShapeName)
        tbFriendGrid.SetUiImity(itemObj, tbRoleInfo)

        itemObj.pPanel.OnTouchEvent = fnOnClick

    end

    self.ScrollView:Update(#tbAllFriend, fnSetItem)

end

function tbUi:GetFriendList()
    local nTemplateId = self.tbSelectItem.nTemplateId
    local nTargetId = Item.tbEquipExchange:GetTargetItem(nTemplateId)    
    local nFactionLimit;
    if nTargetId then
        local tbBaseTar = KItem.GetItemBaseProp(nTargetId)
        if tbBaseTar.nFactionLimit > 0 then
            nFactionLimit = tbBaseTar.nFactionLimit
        end
    end
    self.nFactionLimit = nFactionLimit

    local tbAllFriend = FriendShip:GetAllFriendData()
    local tbSortKey = {}
    for i,v in ipairs(tbAllFriend) do
        local nSort = v.nImity;
        if nFactionLimit and v.nFaction == nFactionLimit then
            nSort = nSort + 10000000
        end
        tbSortKey[v.dwID] = nSort
    end

    local fnSort = function (a, b)
       return tbSortKey[a.dwID] > tbSortKey[b.dwID] 
    end
    table.sort(tbAllFriend, fnSort)
    return tbAllFriend
end

function tbUi:OnClose()
    self:UnLockButton()   
end

function tbUi:OnBuyScuess( bSuccess, nGoodsId)
    if nGoodsId == self.tbSelectItem.nGoodsId then
        self:UnLockButton()
    end
    if not bSuccess then
        return
    end
    if not self.dwRoleIdSend then
        me.CenterMsg("未选中角色")
        return
    end
    if nGoodsId ~= self.tbSelectItem.nGoodsId then
        me.CenterMsg("商品已切换")
        return
    end
    local tbInfo = Gift:GetMailGiftItemInfo(self.tbSelectItem.nTemplateId)
    if not self.nSelIndex then
        me.CenterMsg("未选中")
        return
    end

    local tbRoleInfo = self.tbAllFriend[self.nSelIndex]
    RemoteServer.SendGift(Gift.GiftType.MailGift,tbRoleInfo.dwID,1,self.tbSelectItem.nTemplateId);
end

function tbUi:LockButton( )
   self:UnLockButton()
   self.nLockTimer = Timer:Register(Env.GAME_FPS * 2, function ( )
       self.nLockTimer = nil;
   end)
end

function tbUi:UnLockButton()
    if self.nLockTimer then
        Timer:Close(self.nLockTimer)
        self.nLockTimer = nil
    end
end

function tbUi:CloseWindow()
    if self.nLockTimer then
        me.CenterMsg("请稍候")
        return
    end
    Ui:CloseWindow(self.UI_NAME) 
end

tbUi.tbOnClick = {};

tbUi.tbOnClick.BtnClose = function (self)
    self:CloseWindow()
end

tbUi.tbOnClick.BtnCancel = function (self)
   self:CloseWindow()
end

tbUi.tbOnClick.BtnSure = function (self)
    if self.nLockTimer then
        me.CenterMsg("请稍候")
        return
    end
    if not self.nSelIndex then
        me.CenterMsg("未选中")
        return
    end

    local tbRoleInfo = self.tbAllFriend[self.nSelIndex]
    if not tbRoleInfo then
        me.CenterMsg("无效")
        return
    end

    local tbSelectItem = self.tbSelectItem
    local nSelectItemId = tbSelectItem.nTemplateId
    local tbGiftInfo = Gift:GetMailGiftItemInfo(nSelectItemId)
    if not tbGiftInfo then
        me.CenterMsg("该外装不可赠送")
        return
    end

    local fnYes = function ()
        --注册购买成功的回调
        self:LockButton()
        self.dwRoleIdSend = tbRoleInfo.dwID
        RemoteServer.OnShopRequest("Buy", "Dress", tbSelectItem.nGoodsId, 1, tbSelectItem.nPrice, Shop.nRequestIndex);

    end
    local szMoneyName = Shop:GetMoneyName(tbSelectItem.szMoneyType)
    local szItemName = Gift:GetItemShowName(nSelectItemId, me.nFaction, me.nSex, tbRoleInfo.nFaction, tbRoleInfo.nSex)
    local szSureTip = string.format("确认花费%d%s将[FFFE0D]%s[-]赠送给[FFFE0D]%s[-]吗？", tbSelectItem.nPrice, szMoneyName, szItemName, tbRoleInfo.szName)
    me.MsgBox(szSureTip,
    {
        {"确定", fnYes },
        {"取消"},
    })


end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SHOP_BUY_RESULT,              self.OnBuyScuess},
   
    };

    return tbRegEvent;
end