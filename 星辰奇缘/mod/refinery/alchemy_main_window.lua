AlchemyMainWindow  =  AlchemyMainWindow or BaseClass(BaseWindow)

function AlchemyMainWindow:__init(model)
    self.name  =  "AlchemyMainWindow"
    self.model  =  model

    -- 缓存
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList  =  {
        {file  =  AssetConfig.alchemy_window, type  =  AssetType.Main}
        ,{file  =  AssetConfig.stongbg, type  =  AssetType.Dep}
    }

    self.windowId = WindowConfig.WinID.alchemy_window

    self.has_init = false

    self.on_asset_change = function()
        self:on_asset_update()
    end

    self.type = 1

    self.imgLoader = nil
    self.item_list = {}
    
    return self
end

function AlchemyMainWindow:__delete()
    if self.item_list ~= nil then
        for i=1,#self.item_list do
            local item = self.item_list[i]
            if item ~= nil then
                item:DeleteMe()
            end
        end
    end

    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
 
    self.has_init = false

    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.on_asset_change)

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function AlchemyMainWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.alchemy_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "AlchemyMainWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.transform:GetComponent(RectTransform).localPosition = Vector3(0, 0, -305)

    self.mainCon = self.gameObject.transform:Find("MainCon")
    local closeBtn = self.gameObject.transform:Find("MainCon/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseMainUI()
    end)


    self.ItemCon = self.mainCon:FindChild("ItemCon")
    self.MaskCon = self.ItemCon:FindChild("MaskCon")
    self.ScrollLayer = self.MaskCon:FindChild("ScrollLayer")
    self.Container = self.ScrollLayer:FindChild("Container")
    self.Cloner = self.Container:FindChild("Cloner").gameObject
    -- self.Cloner:SetActive(false)

    self.CostCon = self.mainCon:FindChild("CostCon")
    self.TxtVal = self.CostCon:FindChild("TxtVal"):GetComponent(Text)
    self.ImgMoli = self.CostCon:FindChild("ImgMoli"):GetComponent(Image)
    self.prog = self.CostCon:FindChild("ImgProg")
    self.prog_bar = self.prog:FindChild("ImgProgBar"):GetComponent(RectTransform)
    self.prog_txt = self.prog:FindChild("TxtProgBar"):GetComponent(Text)
    self.BtnPlus = self.CostCon:FindChild("BtnPlus"):GetComponent(Button)
    self.OnePressButton = self.mainCon:FindChild("OnePressButton"):GetComponent(Button)
    self.BtnOneKey = self.mainCon:FindChild("BtnOneKey"):GetComponent(Button)
    self.BtnOneKeyLian = self.mainCon:FindChild("BtnOneKeyLian"):GetComponent(Button)
    self.BtnOneKey_txt = self.BtnOneKey.transform:FindChild("Text"):GetComponent(Text)

    self.blue_img = self.BtnOneKey.image.sprite
    self.green_img = self.BtnOneKeyLian.image.sprite
    self.BtnOneKeyLian.image.sprite = self.blue_img

    self.CostCon:GetComponent(Button).onClick:AddListener(function()
        self.model:InitLianhuUI()
    end)
    self.BtnPlus.onClick:AddListener(function()
        self.model:InitLianhuUI()
    end)
    self.BtnOneKey.onClick:AddListener(function()
        -- if self.type == 2 then
            AlchemyManager.Instance:request14906()
        -- elseif self.type == 1 then
        --     --判断能量够不够放满所有已打开未放的格子
        --     if self.model:CheckValueEnough() then
        --         AlchemyManager.Instance:request14907()
        --     else
        --         NoticeManager.Instance:FloatTipsByString(TI18N("能量不足，请炼化道具"))
        --         self.model:InitLianhuUI()
        --     end
        -- end
    end)


    self.BtnOneKeyLian.onClick:AddListener(function()
        --判断能量够不够放满所有已打开未放的格子
        local need = 0
        local has = RoleManager.Instance.RoleData.alchemy
        for k, v in pairs(self.item_list)  do
            if v.toggle.isOn then
                for i=1,#self.model.data_list do
                    local dat = self.model.data_list[i]
                    if dat.id == v.data.id then
                        local cfg_data = DataAlchemy.data_base[dat.id]
                        need = need + (dat.volume - #dat.products)*cfg_data.cost[1][2]
                    end
                end
            end
        end

        -- if self.model:CheckValueEnough() then
        if has >= need then
            AlchemyManager.Instance:request14907()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("能量不足，请炼化道具"))
            self.model:InitLianhuUI()
        end
    end)

    self.OnePressButton.onClick:AddListener(function()
        AlchemyManager.Instance:request14905(1)
    end)

    self.has_init = true

    if self.imgLoader == nil then
        local go = self.ImgMoli.gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, 90017)

    EventMgr.Instance:AddListener(event_name.role_asset_change, self.on_asset_change)
    AlchemyManager.Instance:request14900()
end

--更新魔力值
function AlchemyMainWindow:on_asset_update()
    self.TxtVal.text = tostring(RoleManager.Instance.RoleData.alchemy)

    local percent = RoleManager.Instance.RoleData.alchemy/20

    percent = percent >= 1 and 1 or percent
    local new_width = percent*170

    self.prog_bar.sizeDelta = Vector2(new_width, self.prog_bar.rect.height)
    self.prog_txt.text = tostring(RoleManager.Instance.RoleData.alchemy)
end

--更新界面内容
function AlchemyMainWindow:update_info()
    self:on_asset_update()

    if self.item_list == nil then
        self.item_list = {}
    end

    self.type = 1

    local has_product = false
    for i=1,#self.model.data_list do
        local data = self.model.data_list[i]
        local item = self.item_list[i]
        if item == nil then
           item = AlchemyMainItem.New(self, self.Cloner, i)
           table.insert(self.item_list, item)
        end
        item:SetData(data)

        for j=1, #data.products do
            local left_time = data.products[j].time + data.need_time - BaseUtils.BASE_TIME
            if left_time <= 0 then
                self.type = 2
                has_product = true
                break
            end
        end
    end

    -- self:update_btn_state(self.type)

    if self.model:CheckHasEmptyPos() and RoleManager.Instance.RoleData.alchemy >= 25 then
        --有空格有≥25能量时绿色，否则为蓝色
        self.BtnOneKeyLian.image.sprite = self.green_img
    else
        self.BtnOneKeyLian.image.sprite = self.blue_img
    end

    if has_product then
        --有可收获时绿色，否则为蓝色
        self.BtnOneKey.image.sprite = self.green_img
    else
        self.BtnOneKey.image.sprite = self.blue_img
    end
end

--更新按钮状态
function AlchemyMainWindow:update_btn_state(_type)
    self.type = _type
    if self.type == 1 then
        self.BtnOneKey_txt.text = TI18N("一键炼制")
        self.BtnOneKey.image.sprite = self.blue_img
    elseif self.type == 2 then
        self.BtnOneKey_txt.text = TI18N("一键收获")
        self.BtnOneKey.image.sprite = self.green_img
    end
end