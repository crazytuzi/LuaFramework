GuildNpcExchangeWindow  =  GuildNpcExchangeWindow or BaseClass(BasePanel)

function GuildNpcExchangeWindow:__init(model)
    self.name  =  "GuildNpcExchangeWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.guild_npc_exchange_win, type  =  AssetType.Main}
        , {file = AssetConfig.guild_dep_res, type = AssetType.Dep}
    }

    self.windowId = WindowConfig.WinID.guild_npc_exchange_win

    self.restoreFrozen_btn1 = nil
    self.restoreFrozen_btn2 = nil
    self.restoreFrozen_btn3 = nil


    return self
end


function GuildNpcExchangeWindow:__delete()
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


function GuildNpcExchangeWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_npc_exchange_win))
    self.gameObject.name  =  "GuildNpcExchangeWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseGuildNpcExchangeUI() end)


    self.MainCon = self.transform:FindChild("MainCon")
    self.TxtTitle_temp = self.MainCon:FindChild("TxtTitle"):GetComponent(Text)
    self.TxtTitle = MsgItemExt.New(self.TxtTitle_temp, 283, 16, 23)

    self.BottomCon = self.MainCon:FindChild("BottomCon")
    self.BtnSpeedup1 = self.BottomCon:FindChild("BtnSpeedup1"):GetComponent(Button)
    self.TxtVal_1 = self.BtnSpeedup1.transform:FindChild("TxtVal"):GetComponent(Text)
    self.TxtDesc_1 = self.BtnSpeedup1.transform:FindChild("TxtDesc"):GetComponent(Text)

    self.BtnSpeedup2 = self.BottomCon:FindChild("BtnSpeedup2"):GetComponent(Button)
    self.TxtVal_2 = self.BtnSpeedup2.transform:FindChild("TxtVal"):GetComponent(Text)
    self.TxtDesc_2 = self.BtnSpeedup2.transform:FindChild("TxtDesc"):GetComponent(Text)

    self.BtnSpeedup3 = self.BottomCon:FindChild("BtnSpeedup3"):GetComponent(Button)
    self.TxtVal_3 = self.BtnSpeedup3.transform:FindChild("TxtVal"):GetComponent(Text)
    self.TxtDesc_3 = self.BtnSpeedup3.transform:FindChild("TxtDesc"):GetComponent(Text)

    self.img_blue = self.BtnSpeedup2.image.sprite
    self.img_grey = self.BtnSpeedup1.image.sprite
    self.BtnSpeedup1.image.sprite = self.img_blue

    self.restoreFrozen_btn1 = FrozenButton.New(self.BtnSpeedup1)
    self.restoreFrozen_btn2 = FrozenButton.New(self.BtnSpeedup2)
    self.restoreFrozen_btn3 = FrozenButton.New(self.BtnSpeedup3)


    self.BtnSpeedup1.onClick:AddListener(function()
        local data = DataGuild.data_get_gx_exchange[1]
        if data.donation > self.model.npc_exchange_left_num then
            NoticeManager.Instance:FloatTipsByString(TI18N("本周可兑换的贡献不足"))
            return
        end
        GuildManager.Instance:request11174(1)
    end)
    self.BtnSpeedup2.onClick:AddListener(function()
        local data = DataGuild.data_get_gx_exchange[2]
        if data.donation > self.model.npc_exchange_left_num then
            NoticeManager.Instance:FloatTipsByString(TI18N("本周可兑换的贡献不足"))
            return
        end
        GuildManager.Instance:request11174(2)
    end)
    self.BtnSpeedup3.onClick:AddListener(function()
        local data = DataGuild.data_get_gx_exchange[3]
        if data.donation > self.model.npc_exchange_left_num then
            NoticeManager.Instance:FloatTipsByString(TI18N("本周可兑换的贡献不足"))
            return
        end
        GuildManager.Instance:request11174(3)
    end)

    GuildManager.Instance:request11175()
end


function GuildNpcExchangeWindow:update_left_num()
    self.TxtTitle:SetData(string.format("%s<color='#2fc823'>%s</color>{assets_2, 90011}", TI18N("本周还可兑换公会贡献"), self.model.npc_exchange_left_num))
    self:update_info()
end

function GuildNpcExchangeWindow:update_info()

    local data_1 = DataGuild.data_get_gx_exchange[1]
    local data_2 = DataGuild.data_get_gx_exchange[2]
    local data_3 = DataGuild.data_get_gx_exchange[3]

    self.TxtVal_1.text = tostring(data_1.loss_num)
    self.TxtDesc_1.text = tostring(data_1.donation)
    if data_1.donation > self.model.npc_exchange_left_num then
        self.BtnSpeedup1.image.sprite = self.img_grey
    end

    self.TxtVal_2.text = tostring(data_2.loss_num)
    self.TxtDesc_2.text = tostring(data_2.donation)
    if data_2.donation > self.model.npc_exchange_left_num then
        self.BtnSpeedup2.image.sprite = self.img_grey
    end

    self.TxtVal_3.text = tostring(data_3.loss_num)
    self.TxtDesc_3.text = tostring(data_3.donation)
    if data_3.donation > self.model.npc_exchange_left_num then
        self.BtnSpeedup3.image.sprite = self.img_grey
    end
end