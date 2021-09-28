TipsSpiritExpBuyBuffView = TipsSpiritExpBuyBuffView or BaseClass(BaseView)

function TipsSpiritExpBuyBuffView:__init()
	self.ui_config = {"uis/views/tips/spirithometip_prefab","SpiritBuffBuyTips"}
	self.view_layer = UiLayer.Pop
	self.str = ""
	self.early_close_state = false


end

function TipsSpiritExpBuyBuffView:__delete()
end

function TipsSpiritExpBuyBuffView:ReleaseCallBack()
    self.money_text = nil
    self.buy_str = nil
    self.buy_tip = nil
    self.buy_limlit = nil
end

function TipsSpiritExpBuyBuffView:OpenCallBack()
    self:Flush()
end

function TipsSpiritExpBuyBuffView:CloseCallBack()

end

function TipsSpiritExpBuyBuffView:LoadCallBack()
    self.money_text = self:FindVariable("money_text")
    self.buy_str = self:FindVariable("BuyStr")
    self.buy_tip = self:FindVariable("BuyTip")
    self.buy_limlit = self:FindVariable("BuyLimlit")

    self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
    self:ListenEvent("IsBuy", BindTool.Bind(self.OnClickBuy, self))
end

function TipsSpiritExpBuyBuffView:CloseView() 
    self:Close()
end

function TipsSpiritExpBuyBuffView:OnClickBuy()
    local buy_count = SpiritData.Instance:GetExploreBuyBuffCount()
    local limlit_count = SpiritData.Instance:GetSpiritOtherCfgByName("explore_buff_max_count") or 0
    if buy_count >= limlit_count then
        SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritexpNoCanBuyBuff)
        return
    end

    SpiritCtrl.Instance:SendJingLingExploreOperReq(JL_EXPLORE_OPER_TYPE.JL_EXPLORE_OPER_TYPE_BUY_BUFF)
end

function TipsSpiritExpBuyBuffView:OnFlush()
    local buy_count = SpiritData.Instance:GetExploreBuyBuffCount()
    local up_value = SpiritData.Instance:GetSpiritOtherCfgByName("explore_buff_add_per") or 0
    local limlit_count = SpiritData.Instance:GetSpiritOtherCfgByName("explore_buff_max_count") or 0
    local buy_consume = SpiritData.Instance:GetSpiritOtherCfgByName("explore_buff_buy_gold") or 0

    if self.buy_str ~= nil then
        self.buy_str:SetValue(string.format(Language.JingLing.SpiritExpBuyStr, up_value))
    end

    if self.buy_tip ~= nil then
        self.buy_tip:SetValue(string.format(Language.JingLing.SpiritExpBuffLimlit, limlit_count))
    end

    if self.buy_limlit ~= nil then
        self.buy_limlit:SetValue(string.format(Language.JingLing.SpiritexpBuffUp, buy_count, limlit_count))
    end

    if self.money_text ~= nil then
        self.money_text:SetValue(buy_consume)
    end
end