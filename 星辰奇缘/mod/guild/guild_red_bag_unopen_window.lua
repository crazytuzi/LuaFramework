GuildRedBagUnOpenWindow  =  GuildRedBagUnOpenWindow or BaseClass(BasePanel)

function GuildRedBagUnOpenWindow:__init(model)
    self.name  =  "GuildRedBagUnOpenWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.guild_red_bag_unopen_win, type  =  AssetType.Main}
        , {file = AssetConfig.guild_dep_res, type = AssetType.Dep}
    }

    self.windowId = WindowConfig.WinID.guild_red_bag_unopen_win

    self.MainCon=nil
    self.img = nil
    self.TxtName = nil
    self.ImgGift = nil
    self.TxtGift = nil
    self.BtnOpen = nil

    self.is_open = false

    return self
end

function GuildRedBagUnOpenWindow:__delete()
    self.bg2.sprite = nil
    self.img.sprite = nil
    self.BtnOpen.image.sprite = nil
    self.MainCon=nil
    self.img = nil
    self.TxtName = nil
    self.ImgGift = nil
    self.TxtGift = nil
    self.BtnOpen = nil

    self.is_open = false

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function GuildRedBagUnOpenWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_red_bag_unopen_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "GuildRedBagUnOpenWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseUnRedBagUI() end)

    self.MainCon = self.transform:FindChild("MainCon")

    self.bg2 = self.transform:FindChild("MainCon"):FindChild("bg2"):GetComponent(Image)
    local close_btn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function() self.model:CloseUnRedBagUI() end)

    self.img = self.MainCon:FindChild("ImgHead"):FindChild("Img"):GetComponent(Image)
    self.TxtName = self.MainCon:FindChild("TxtName"):GetComponent(Text)
    self.TxtGift = self.MainCon:FindChild("TxtGift"):GetComponent(Text)
    self.TxtGift2 = self.MainCon:FindChild("TxtGift2"):GetComponent(Text)
    self.BtnOpen = self.MainCon:FindChild("BtnOpen"):GetComponent(Button)

    self.TxtGift.color = Color(141/255, 69/255, 31/255)
    self.TxtGift2.color = Color(141/255, 69/255, 31/255)
    
    self.BtnOpen.onClick:AddListener(function() self:on_click_btn() end)

    self:update_view()

    self.is_open = true
end


function GuildRedBagUnOpenWindow:update_view()
    self.TxtName.text = self.model.current_red_bag.name
    self.TxtGift.text = TI18N("发了一个红包，金额随机")
    self.TxtGift2.text = self.model.current_red_bag.title
    --
    self.img.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(self.model.current_red_bag.classes),tostring(self.model.current_red_bag.sex)))
end

function GuildRedBagUnOpenWindow:on_click_btn(g)
    self.model:CloseUnRedBagUI()
    GuildManager.Instance:request11133( self.model.current_red_bag.rid, self.model.current_red_bag.platform, self.model.current_red_bag.zone_id)
end