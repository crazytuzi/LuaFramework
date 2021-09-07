ExchangeWindow = ExchangeWindow or BaseClass(BaseWindow)

function ExchangeWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.exchange_window
    self.name = "ExchangeWindow"
    -- self.cacheMode = CacheMode.Visible
    self.winLinkType = WinLinkType.Single
    self.currpage = nil
    self.exchangeMgr = ExchangeManager.Instance
    self.resList = {
        {file = AssetConfig.exchange_window, type = AssetType.Main},
        {file = AssetConfig.exchange_textures, type = AssetType.Dep},
        {file = AssetConfig.shop_textures, type = AssetType.Dep}
    }
    self.selectid = nil
    self.lastSendTime = 0

    self.goldTab = {}
    self.sliverTab = {}
end

function ExchangeWindow:__delete()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.goldTab ~= nil then
        for _,v in pairs(self.goldTab) do
            if v ~= nil then
                v.imageLoader:DeleteMe()
            end
        end
        self.goldTab = nil
    end

    if self.sliverTab ~= nil then
        for _,v in pairs(self.sliverTab) do
            if v ~= nil then
                v.imageLoader:DeleteMe()
            end
        end
    end

    self:ClearDepAsset()
end



function ExchangeWindow:InitPanel()
    if self.openArgs == nil then
        print("没参数")
    else
        if type(self.openArgs) == "table" then
            self.openArgs = self.openArgs[1]
        end
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exchange_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseWindow() end)
    self.sliverCon = self.transform:Find("MainCon/SliverCon")
    self.goldCon = self.transform:Find("MainCon/GoldCon")

    local func = function(container, tab)
        for i=1,6 do
            local ta = {}
            ta.transform = container:GetChild(i - 1)
            ta.gameObject = ta.transform.gameObject
            ta.button = ta.gameObject:GetComponent(Button)
            ta.image = ta.transform:Find("Image")
            ta.getText = ta.transform:Find("GetText"):GetComponent(Text)
            ta.needText = ta.transform:Find("NeedText"):GetComponent(Text)
            ta.imageLoader = SingleIconLoader.New(ta.transform:Find("NeedAss").gameObject)
            if ta.transform:Find("Tokes") ~= nil then
                ta.tokes = ta.transform:Find("Tokes")
                ta.tokesImage = ta.transform:Find("Tokes"):GetComponent(Image)
                ta.tokesValue = ta.transform:Find("Tokes/Value"):GetComponent(Text)
            end
            tab[i] = ta
        end
    end

    func(self.sliverCon, self.sliverTab)
    func(self.goldCon, self.goldTab)


    self:InitBtnGroup()
    self.OnOpenEvent:AddListener(function() self:OnShow() end)

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 20, function() self:FloatItems() end)
    end
end

function ExchangeWindow:OnShow()
    -- ShouhuManager.Instance:request10901()
    if self.openArgs == nil then
        print("没参数")
    else
        if type(self.openArgs) == "table" then
            self.openArgs = self.openArgs[1]
        end
    end
    self.goldCon.gameObject:SetActive(self.openArgs == 1)
    self.sliverCon.gameObject:SetActive(self.openArgs == 2)
end

function ExchangeWindow:InitBtnGroup()
    for i,v in ipairs(DataExchange.data_list) do
        local item
        if v.type == "gold_bind" then
            item = self.goldTab[(i-1)%6+1]
        else
            item = self.sliverTab[(i-1)%6+1]
        end
        item.getText.text = tostring(v.val)
        item.needText.text = tostring(v.gold_val)

        item.imageLoader:SetSprite(SingleIconType.Item,29255)


        item.imageLoader.gameObject.transform.sizeDelta = Vector2(36, 36)
        item.button.onClick:RemoveAllListeners()
        item.button.onClick:AddListener(function() self:OnclickItem(i, v) end)

        local extraData = nil
        for ii = RoleManager.Instance.world_lev, 1, -1 do
            local extraKey = string.format("%s_%s", tostring(i), tostring(ii))
            if DataExchange.data_extra[extraKey] ~= nil then
                extraData = DataExchange.data_extra[extraKey]
                break
            end
        end
        if item.tokes ~= nil and extraData ~= nil then
            item.tokesImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "Tokes")
            item.tokes.gameObject:SetActive(true)
            local val = extraData.gift_ratio/1000*v.val
            if val >= 1000000 then
                val = val /10000
                val = tostring(val).. TI18N("万")
            end
            item.tokesValue.text = tostring(val)
        end
    end
    self.goldCon.gameObject:SetActive(self.openArgs == 1)
    self.sliverCon.gameObject:SetActive(self.openArgs == 2)

end

function ExchangeWindow:OnclickItem(id,data)
    -- if data.gold_val > RoleManager.Instance.RoleData.gold + RoleManager.Instance.RoleData.star_gold then
    --      NoticeManager.Instance:FloatTipsByString(TI18N("你的{assets_2, 29255}不足"))
    --      self.selectid = 0
    --      return
    -- end
    if self.exchangeMgr.require9909Lock and Time.time - self.lastSendTime < 5 then
        NoticeManager.Instance:FloatTipsByString(TI18N("正在努力兑换，请稍候{face_1,123}"))
        return
    end

    if self.selectid == id and Time.time - self.lastTime < 5 then
        self.lastSendTime = Time.time
        self.exchangeMgr:Require9909(id)
    else
        self.selectid = id
        self.lastTime = Time.time
        self.lastSendTime = 0
         NoticeManager.Instance:FloatTipsByString(TI18N("再次点击确认购买"))
    end
end

function ExchangeWindow:FloatItems()
    self.counter = (self.counter or 0) + 5
    for i=6,6 do
        self.sliverTab[i].image.anchoredPosition = Vector2(0, 5 * math.sin(self.counter * math.pi / 180))
        self.goldTab[i].image.anchoredPosition = Vector2(0, 5 * math.sin(self.counter * math.pi / 180))
    end
end

