local tbUi = Ui:CreateClass("BuyLevelUp")

tbUi.szLevelUpText = [[武林公告：    
    武林急需人才，老朽得万老板相助，以罕见灵药制成丹药，我虽不小气，但丹药极少，得之有两种方法：
1、家财万贯
      若侠士财富过人，可以6000元宝购买，[FFFE0D]限购一枚[-]。[FFFE0D]剑侠尊享6[-]以上的侠士可[FFFE0D]免费领取[-]。
2、义薄云天
      若侠士交游广阔，可找[FFFE0D]剑侠尊享6[-]及以上且[FFFE0D]亲密度达到15级[-]侠士赠送，赠送与接受均[FFFE0D]只有一次机会[-]，需慎重。      
]]

tbUi.szSendText = [[武林公告：    
    武林急需人才，老朽得万老板相助，以罕见灵药制成丹药，江湖纷乱，还望借助诸位之手分发此丹；
    如今有一批侠士重回江湖，急需此丹助长实力，均为侠士亲密度达15级以上的好友，侠士可从中[FFFE0D]挑选一人[-]进行赠送，助其快速升级，早日重回武林！    
]]

function tbUi:OnOpen()
    Ui:ClearRedPointNotify("Activity_BuyLevelUp")
    local nCanBuyID = DirectLevelUp:GetCanBuyItem()
    if not nCanBuyID then
        return
    end

    self.nBuyTID = nCanBuyID
    self.itemframe:SetGenericItem({"Item", self.nBuyTID, 1})
    self.itemframe.fnClick = self.itemframe.DefaultClick

    self.bCanBuy, self.szBuyFailMsg = DirectLevelUp:CheckCanBuy(me, self.nBuyTID)
    self.bFreeGet = me.GetVipLevel() >= DirectLevelUp.nFreeVipLevel
    self:CheckCanSend()

    self.pPanel:SetActive("BtnBuy", self.bCanBuy or self.bCanSend)
    self.pPanel:SetActive("BtnInvite", self.bCanBuy and not self.bFreeGet)
    self.pPanel:SetActive("BuyLevelUpHelp", not self.bCanSend)
    self.pPanel:SetActive("Text", not self.bCanSend)
    self.pPanel:Label_SetText("LevelUpText", self.bCanSend and self.szSendText or self.szLevelUpText)
    self.BtnBuy.pPanel:Label_SetText("Buy7Txt", self.bCanSend and "赠送" or (self.bFreeGet and "免费领取" or "购买"))
end

function tbUi:CheckCanSend()
    local bCanHelp = DirectLevelUp:CheckCanHelp(me)
    local tbList   = DirectLevelUp:GetAsk4HelpList() or {}
    self.bCanSend  = bCanHelp and next(tbList)
end

tbUi.tbOnClick = {
    BtnBuy = function (self)
        if self.bCanSend then
            Ui:OpenWindow("SendGiftPanel", "HelpFriend")
            return
        end

        if not self.bCanBuy then
            if self.szBuyFailMsg then
                me.CenterMsg(self.szBuyFailMsg)
            end
            return
        end

        if self.bFreeGet then
            RemoteServer.TryCallDirectLevelUpFunc("TryBuyItem", self.nBuyTID)
            return
        end

        local nExtPrice = Item:GetClass("AddPlayerLevel").nExtPrice
        local nPrice    = KItem.GetItemExtParam(self.nBuyTID, nExtPrice)
        local fnGotoRecharge = function ()
            Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
        end

        local fnBuy = function ()
            if me.GetMoney("Gold") < nPrice then
                me.CenterMsg("元宝不足，请先充值")
                fnGotoRecharge()
                return
            end
            
            RemoteServer.TryCallDirectLevelUpFunc("TryBuyItem", self.nBuyTID)
        end

        local fnTryBuy = function ()
            local szName = Item:GetItemTemplateShowInfo(self.nBuyTID, me.nFaction, me.nSex)
            me.MsgBox(string.format("是否要花费[FFFE0D]%d[-]元宝购买[FFFE0D]%s[-]？", nPrice, szName), {{"购买", fnBuy}, {"取消"}})
        end

        me.MsgBox(string.format("尊敬的侠士，该丹提升到[FFFE0D]剑侠V%d[-]以上可免费获得，是要去充值还是直接花费[FFFE0D]6000元宝[-]购买？", RegressionPrivilege.LvUp_VipLv), {{"前往充值", fnGotoRecharge}, {"直接购买", fnTryBuy}})
    end,
    BtnInvite = function (self)
        Ui:OpenWindow("SendGiftPanel", "Ask4Help")
    end,
}