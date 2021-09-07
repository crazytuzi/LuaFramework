GuildNpcExchangeFundWindow  =  GuildNpcExchangeFundWindow or BaseClass(BasePanel)

function GuildNpcExchangeFundWindow:__init(model)
    self.name  =  "GuildNpcExchangeFundWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.guild_npc_exchange_fund_win, type  =  AssetType.Main}
        , {file = AssetConfig.guild_dep_res, type = AssetType.Dep}
    }

    self.windowId = WindowConfig.WinID.guild_npc_exchange_fund_win

    self.restoreFrozen_btn1 = nil
    self.restoreFrozen_btn2 = nil
    self.restoreFrozen_btn3 = nil
    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.updateInfoStart = function() self:update_left_num() end
    self.singleList = {}

    return self
end


function GuildNpcExchangeFundWindow:__delete()
    self:RemoveListeners()
    if self.singleList ~= nil then
        for i,v in ipairs(self.singleList) do
            v:DeleteMe()
        end
        self.singleList = {}
    end

    if self.restoreFrozen_btn1 ~= nil then
        self.restoreFrozen_btn1:DeleteMe()
    end
    if self.restoreFrozen_btn2 ~= nil then
        self.restoreFrozen_btn2:DeleteMe()
    end
    if self.restoreFrozen_btn3 ~= nil then
        self.restoreFrozen_btn3:DeleteMe()
    end

    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildNpcExchangeFundWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_npc_exchange_fund_win))
    self.gameObject.name  =  "GuildNpcExchangeFundWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloaseGuildNpcFundExchangeUI() end)


    self.MainCon = self.transform:FindChild("MainCon")
    self.TxtTitle_temp = self.MainCon:FindChild("TxtTitle"):GetComponent(Text)
    self.TxtTitle = MsgItemExt.New(self.TxtTitle_temp, 283, 16, 23)

    self.BottomCon = self.MainCon:FindChild("BottomCon")
    self.BtnSpeedup1 = self.BottomCon:FindChild("BtnSpeedup1"):GetComponent(Button)
    self.TxtVal_1 = self.BtnSpeedup1.transform:FindChild("TxtVal"):GetComponent(Text)
    self.TxtDesc_1 = self.BtnSpeedup1.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.TxtNext_1 = self.BtnSpeedup1.transform:FindChild("Text"):GetComponent(Text)
    self.ImgCoin1 = self.BtnSpeedup1.transform:FindChild("ImgCoin").gameObject
    self.singleList[1] = SingleIconLoader.New(self.ImgCoin1)
    self.singleList[1]:SetSprite(SingleIconType.Item,90002)

    self.BtnSpeedup2 = self.BottomCon:FindChild("BtnSpeedup2"):GetComponent(Button)
    self.TxtVal_2 = self.BtnSpeedup2.transform:FindChild("TxtVal"):GetComponent(Text)
    self.TxtDesc_2 = self.BtnSpeedup2.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.TxtNext_2 = self.BtnSpeedup2.transform:FindChild("Text"):GetComponent(Text)
    self.ImgCoin2 = self.BtnSpeedup2.transform:FindChild("ImgCoin").gameObject
    self.singleList[2] = SingleIconLoader.New(self.ImgCoin2)
    self.singleList[2]:SetSprite(SingleIconType.Item,90002)

    self.BtnSpeedup3 = self.BottomCon:FindChild("BtnSpeedup3"):GetComponent(Button)
    self.TxtVal_3 = self.BtnSpeedup3.transform:FindChild("TxtVal"):GetComponent(Text)
    self.TxtDesc_3 = self.BtnSpeedup3.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.TxtNext_3 = self.BtnSpeedup3.transform:FindChild("Text"):GetComponent(Text)
    self.ImgCoin3 = self.BtnSpeedup3.transform:FindChild("ImgCoin").gameObject
    self.singleList[3] = SingleIconLoader.New(self.ImgCoin3)
    self.singleList[3]:SetSprite(SingleIconType.Item,90002)

    self.img_blue = self.BtnSpeedup2.image.sprite
    self.img_grey = self.BtnSpeedup1.image.sprite
    self.BtnSpeedup1.image.sprite = self.img_blue

    self.restoreFrozen_btn1 = FrozenButton.New(self.BtnSpeedup1)
    self.restoreFrozen_btn2 = FrozenButton.New(self.BtnSpeedup2)
    self.restoreFrozen_btn3 = FrozenButton.New(self.BtnSpeedup3)


    self.BtnSpeedup1.onClick:AddListener(function()
        local data = DataGuild.data_guild_fund[1]
        if data.loss_num > RoleManager.Instance.RoleData.gold then
            NoticeManager.Instance:FloatTipsByString(TI18N("钻石不足,无法购买"))
            return
        end
        GuildManager.Instance:request11195(1)
    end)
    self.BtnSpeedup2.onClick:AddListener(function()
        local data = DataGuild.data_guild_fund[2]
        if data.loss_num > RoleManager.Instance.RoleData.gold then
            NoticeManager.Instance:FloatTipsByString(TI18N("钻石不足,无法购买"))
            return
        end
        GuildManager.Instance:request11195(2)
    end)
    self.BtnSpeedup3.onClick:AddListener(function()
        local data = DataGuild.data_guild_fund[3]
        if data.loss_num > RoleManager.Instance.RoleData.gold then
            NoticeManager.Instance:FloatTipsByString(TI18N("钻石不足,无法购买"))
            return
        end
        GuildManager.Instance:request11195(3)
    end)

    self:OnOpen()
end

function GuildNpcExchangeFundWindow:OnOpen()
    self:AddListeners()
    GuildManager.Instance:request11196()
end

function GuildNpcExchangeFundWindow:AddListeners()
    GuildManager.Instance.OnUpdateFundStart:AddListener(self.updateInfoStart)
end

function GuildNpcExchangeFundWindow:RemoveListeners()
    GuildManager.Instance.OnUpdateFundStart:RemoveListener(self.updateInfoStart)
end

function GuildNpcExchangeFundWindow:OnHide()
    self:RemoveListeners()
end

function GuildNpcExchangeFundWindow:update_left_num()
    self.TxtTitle:SetData(string.format("%s<color='#2fc823'>%s</color>", TI18N("本周还可兑换公会资金"), GuildManager.Instance.fundNum))
    self:update_info()
end

function GuildNpcExchangeFundWindow:update_info()

    local data_1 = DataGuild.data_guild_fund[1]
    local data_2 = DataGuild.data_guild_fund[2]
    local data_3 = DataGuild.data_guild_fund[3]

    self.TxtVal_1.text = tostring(data_1.loss_num)
    self.TxtDesc_1.text = tostring(data_1.assets)
    self.TxtNext_1.text = string.format("同时可获得<color='#13F460'>%s</color>",tostring(data_1.donation))


    self.TxtVal_2.text = tostring(data_2.loss_num)
    self.TxtDesc_2.text = tostring(data_2.assets)
    self.TxtNext_2.text = string.format("同时可获得<color='#13F460'>%s</color>",tostring(data_2.donation))


    self.TxtVal_3.text = tostring(data_3.loss_num)
    self.TxtDesc_3.text = tostring(data_3.assets)
    self.TxtNext_3.text = string.format("同时可获得<color='#13F460'>%s</color>",tostring(data_3.donation))

end