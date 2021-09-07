TalismanSelectWindow  =  TalismanSelectWindow or BaseClass(BasePanel)

function TalismanSelectWindow:__init(model)
    self.name  =  "TalismanSelectPanel"
    self.model  =  model


    self.resList  =  {
        {file  =  AssetConfig.talisman_select_window, type  =  AssetType.Main}
        ,{file = AssetConfig.talisman_textures, type = AssetType.Dep}
        ,{file = AssetConfig.talisman_set, type = AssetType.Dep}
    }

    self.lastPos = nil

    self.itemData = {}
    self.itemList = {}

    self.returnData = nil

end

function TalismanSelectWindow:__delete()
    self.OnHideEvent:Fire()

    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end


    if self.itemList ~= nil then
        for _,v in ipairs(self.itemList) do
            if v.iconLoader ~= nil then v.iconLoader:DeleteMe() end
            if v.setImage ~= nil then BaseUtils.ReleaseImage(v.setImage) end
            if v.iconBgImg ~= nil then BaseUtils.ReleaseImage(v.iconBgImg) end
        end
        self.itemList = nil
    end


    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function TalismanSelectWindow:InitPanel()
    -- self.is_open = true

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.talisman_select_window))
    self.gameObject.name = "TalismanSelectWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("MainCon")

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)

    self.closeBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:Hiden() end)

    self.RightCon = self.MainCon:FindChild("RightCon")

    self.ScrollLayer = self.RightCon:FindChild("ScrollLayer")
    self.LayoutLayer = self.ScrollLayer:FindChild("LayoutLayer")
    self.itemCloner = self.ScrollLayer:FindChild("Item").gameObject
    self.itemCloner:SetActive(false)

    self.txtUn = self.RightCon:Find("TxtUn").gameObject

    self.BtnPutMateria = self.RightCon:FindChild("BtnPutMateria"):GetComponent(Button)
    self.BtnPutMateria.onClick:AddListener(function() self:on_click_put_ma() end)

    self.layout = LuaBoxLayout.New(self.LayoutLayer, {axis = BoxLayoutAxis.Y, cspacing = 0})

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

end

function TalismanSelectWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function TalismanSelectWindow:OnOpen()
    self:RemoveListeners()
    -- BaseUtils.dump(self.openArgs,"OpenArgs")
    if self.openArgs == nil then return end

    self.returnData = nil   --每次打开重置，保证为nil
    self:ReloadMaterials()
end


function TalismanSelectWindow:OnHide()
    self:RemoveListeners()

    if self.lastPos ~= nil then
        self.itemList[self.lastPos].transform:Find("ImgTick").gameObject:SetActive(false)
    end

    if self.itemData ~= nil then
        self.itemData = nil
    end

end

function TalismanSelectWindow:RemoveListeners()
end


--更新右边材料列表
function TalismanSelectWindow:ReloadMaterials()
    --重置
    self.itemData = {}
    -- self.layout:ReSet()


    local itemDic = self.model.itemDic
    -- BaseUtils.dump(itemDic,"筛选前的宝物数据")

    -- BaseUtils.dump(self.model.planList,"方案")
    local tmpList = {}

    if next(itemDic) ~= nil then
        for _,v in pairs (itemDic) do
            for __,value in ipairs (self.openArgs[1]) do
                if value[1] == v.base_id  then
                    --筛选装备中的宝物
                    local planData = nil
                    if v.id ~= nil and v.id > 0 then
                        planData = self.model.itemDic[(self.model.planList[self.model.use_plan or 1][TalismanEumn.TypeProto[DataTalisman.data_get[v.base_id].type]] or {}).id or 0]
                    end
                    if planData == nil or planData.id ~= v.id then
                        table.insert(tmpList,v)
                    end
                end
            end
        end
    end





    -- BaseUtils.dump(tmpList,"筛选中的宝物数据")
    -- BaseUtils.dump(self.model.selectedData,"已选中列表")
    for _,v in ipairs (tmpList) do
        if next(self.model.selectedData) ~= nil then
            local mark = true
            for __,value in pairs(self.model.selectedData) do
                if v.id == value.id then
                    mark = false
                end
            end
            if mark then
                table.insert(self.itemData, v)
            end
        else
            table.insert(self.itemData, v)
        end
    end

    -- BaseUtils.dump(self.itemData,"筛选后的宝物数据")

    local indexPos = 0
    for i,v in ipairs(self.itemData) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.itemCloner)
            tab.transform = tab.gameObject.transform
            tab.setImage = tab.transform:Find("Bg/Set"):GetComponent(Image)
            tab.iconBgImg = tab.transform:Find("Bg"):GetComponent(Image)
            tab.icon = tab.transform:Find("Bg/Icon")
            tab.nameText = tab.transform:Find("TxtName"):GetComponent(Text)
            tab.iconLoader = SingleIconLoader.New(tab.icon.gameObject)
            tab.bgBtn = tab.transform:Find("Bg"):GetComponent(Button)
            tab.btn = tab.transform:GetComponent(Button)
            self.layout:AddCell(tab.transform.gameObject)
            self.itemList[i] = tab
        end
        tab.gameObject:SetActive(true)

        -- 初始化信息
        local cfgData = DataTalisman.data_get[v.base_id]

        tab.setImage.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(cfgData.set_id))
        tab.iconBgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level" .. cfgData.quality)
        tab.iconLoader:SetSprite(SingleIconType.Item, cfgData.icon)
        tab.nameText.text = ColorHelper.color_item_name(cfgData.quality, TalismanEumn.FormatQualifyName(cfgData.quality, cfgData.name))
        tab.bgBtn.onClick:AddListener(function() TipsManager.Instance:ShowTalisman({itemData = v , extra = {nobutton = true}}) end)
        tab.btn.onClick:AddListener(function()  self:SelectedData(i) end)

        indexPos = i
    end

    -- print(indexPos)
    self.LayoutLayer.sizeDelta = Vector2(232,indexPos * self.itemCloner.transform.sizeDelta.y)
    for i,v in ipairs(self.itemList) do
        if i > indexPos then
            v.gameObject:SetActive(false)
        end
    end


    if #self.itemData == 0 then
        self.txtUn:SetActive(true)
        return
    end
    self.txtUn:SetActive(false)
end

----------------------------------------按钮点击事件
--点击放入材料按钮
function TalismanSelectWindow:on_click_put_ma()
    if self.returnData ~= nil then
        if self.returnData.index ~= nil  then
            self.model.selectedData[self.returnData.index] = self.returnData
        end
    end

    local data = self.returnData
    TalismanManager.Instance.onUpdateNeddItemEvent:Fire(data)
    self:Hiden()
end


function TalismanSelectWindow:SelectedData(i)
    -- print(i)
    -- self.returnData = nil   --重置，保证为nil

    if self.lastPos ~= nil then
        self.itemList[self.lastPos].transform:Find("ImgTick").gameObject:SetActive(false)
    end
    self.itemList[i].transform:Find("ImgTick").gameObject:SetActive(true)

    self.returnData = {}
    self.returnData.index = self.openArgs[2]
    self.returnData.id = self.itemData[i].id
    self.returnData.base_id = self.itemData[i].base_id

    self.lastPos = i
end






