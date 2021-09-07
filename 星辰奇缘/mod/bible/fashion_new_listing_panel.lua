-- @author 黄耀聪
-- @date 2017年3月10日

FashionNewListingPanel = FashionNewListingPanel or BaseClass(BasePanel)

function FashionNewListingPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "FashionNewListingPanel"

    self.resList = {
        {file = AssetConfig.fashion_new_listing, type = AssetType.Main},
        {file = AssetConfig.newFashionBg, type = AssetType.Main},
        {file = AssetConfig.rolebg, type = AssetType.Dep},
        {file = AssetConfig.fashionres, type = AssetType.Dep},
    }

    self.itemList = {}

    self.updateListener = function() if self.currentIndex ~= nil then self:OnClick(self.currentIndex) end end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.fationDatalist = {}
    self.leftItemList = {}
    self.leftEffectList = {}
    self.initFirst = false
    self.composite = nil
end

function FashionNewListingPanel:__delete()
    self.OnHideEvent:Fire()

    if self.leftEffectList ~= nil then
        for k,v in pairs(self.leftEffectList) do
            v:DeleteMe()
        end
        self.leftEffectList = nil
    end
    if self.itemList ~= nil then
        for _,item in pairs(self.itemList) do
            if item ~= nil then
                item.imageLoader:DeleteMe()
            end
        end
    end
    if self.fashionLayout ~= nil then
        self.fashionLayout:DeleteMe()
        self.fashionLayout = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    self:AssetClearAll()
end

function FashionNewListingPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_new_listing))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local img = t:Find("Bg"):GetComponent(Image)
    if img == nil then
        img = t:Find("Bg").gameObject:AddComponent(Image)
    end
    t:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.newFashionBg, "i18nnewfashion")
    -- t:Find("Bottom"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebg, "RoleBg")
    self.nameText = t:Find("NameBg/Text"):GetComponent(Text)
    self.descExt = MsgItemExt.New(t:Find("Desc"):GetComponent(Text), 300, 18, 20.8421)

    self.previewContainer = t:Find("RoleShow")

    self.attrArea = t:Find("Attr")
    local title = self.attrArea:Find("Title")
    self.fashionText = t:Find("Attr/Text"):GetComponent(Text)
    self.fashionLayout = LuaBoxLayout.New(t:Find("SelectArea/Scroll/Container"), {axis = BoxLayoutAxis.X, cspacing = 5, border = 10})
    t:Find("SelectArea/Scroll"):GetComponent(ScrollRect).movementType = ScrollRect.MovementType.Clamped
    self.cloner = t:Find("SelectArea/Scroll/Cloner").gameObject
    self.leftContainerTr = t:Find("LeftContainer"):GetComponent(RectTransform)
    self.leftContainerTr.anchoredPosition = Vector2(-233,-50)
    self.leftLayout = LuaBoxLayout.New(t:Find("LeftContainer"), {axis = BoxLayoutAxis.Y, cspacing = 5, border = 10})
    self.cloner:SetActive(false)
    self.rightButton = t:Find("SelectArea/Button"):GetComponent(Button)
    self.rightButton.onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {1, 4})
        -- if (self.currentIndex or 0) <= #self.itemList[i] then
        -- end
    end)

    self.rightButtonText = t:Find("SelectArea/Button/Text"):GetComponent(Text)

    title.anchorMax = Vector2(0.5,1)
    title.anchorMin = Vector2(0.5,1)
    title.anchoredPosition = Vector2(-55,-15)
end

function FashionNewListingPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function FashionNewListingPanel:OnOpen()

    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.self_loaded, self.updateListener)

    self:Reload()
    if #self.itemList > 0 then
        self.initFirst = false
        self:OnClick(1)
    end
end

function FashionNewListingPanel:OnHide()
    self:RemoveListeners()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end

function FashionNewListingPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.self_loaded, self.updateListener)
end

function FashionNewListingPanel:Reload()
    self.fationDatalist = {}
    self:InitFationDataList()
    for i,v in ipairs(self.fationDatalist) do
        if self.itemList[i] == nil then
            local tab = {}
            tab.gameObject = GameObject.Instantiate(self.cloner)
            tab.transform = tab.gameObject.transform
            tab.imageLoader = SingleIconLoader.New(tab.transform:Find("Icon").gameObject)
            tab.select = tab.transform:Find("Select").gameObject
            tab.labelImg  = tab.transform:Find("Label"):GetComponent(Image)
            tab.btn = tab.gameObject:GetComponent(Button)

            local j = i
            tab.btn.onClick:AddListener(function() self:OnClick(j)  end)
            tab.select:SetActive(false)
            self.fashionLayout:AddCell(tab.gameObject)
            self.itemList[i] = tab
        end


        self.itemList[i].shopData = v
        if v.label ~= 0 then
            self.itemList[i].labelImg.sprite = self.assetWrapper:GetSprite(AssetConfig.fashionres,"TI18NLabel" .. v.label)
            self.itemList[i].labelImg.gameObject:SetActive(true)
        else
            self.itemList[i].labelImg.gameObject:SetActive(false)
        end
        self.itemList[i].gameObject:SetActive(true)
        self.itemList[i].imageLoader:SetSprite(SingleIconType.Item, DataItem.data_get[v.showId].icon)
    end


    if #self.itemList> #self.fationDatalist then
        for i=#self.fationDatalist + 1,#self.itemList do
            self.itemList[i].gameObject:SetActive(false)
        end
    end
end

function FashionNewListingPanel:InitLeftFashion(data,index)
    self.leftLayout:ReSet()
    for i,v in ipairs(data.fashion_parts) do
        if self.leftItemList[i] == nil then
            local itemSlot = ItemSlot.New()
            itemSlot.qualityBg.transform:GetComponent(RectTransform).sizeDelta = Vector2(50,50)
            itemSlot.transform:GetComponent(RectTransform).sizeDelta  = Vector2(50,50)
            self.leftItemList[i] = itemSlot
            self.leftLayout:AddCell(self.leftItemList[i].gameObject)
        end
        local data = DataItem.data_get[v[2]]
        self.leftItemList[i]:SetAll(data)
        self.leftItemList[i].itemImgRect.sizeDelta = Vector2(46,46)
        self.leftItemList[i].gameObject:SetActive(true)

        if v[3] == 1 then
            if self.leftEffectList[i] == nil then
                self.leftEffectList[i] = BibleRewardPanel.ShowEffect(20223,self.leftItemList[i].gameObject.transform, Vector3(0.8,0.8,1), Vector3(0,-24,-400))
            end
            self.leftEffectList[i]:SetActive(true)
        else
            if self.leftEffectList[i] ~= nil then
                self.leftEffectList[i]:SetActive(false)
            end
        end

        if v[1] == 4 then
            self.leftItemList[i].button.onClick:RemoveAllListeners()
            self.leftItemList[i].button.onClick:AddListener(function() self.leftItemList[i]:ClickSelf()
                if self.composite ~= nil then
                    self.composite.tpose.transform.localRotation = Quaternion.Euler(0,SceneConstData.UnitFaceTo.Backward,0)
                end
            end)
        end
    end

    if #self.leftItemList > #data.fashion_parts then
        for i=#data.fashion_parts + 1,#self.leftItemList do
            self.leftItemList[i].gameObject:SetActive(false)
        end
    end

    if #data.fashion_parts == 2 then
        self.leftContainerTr.anchoredPosition = Vector2(-233,-109)
    else
        self.leftContainerTr.anchoredPosition = Vector2(-233,-50)
    end
end

function FashionNewListingPanel:InitFationDataList()
    local baseTime = BaseUtils.BASE_TIME

    for k,v in pairs(DataShop.data_fashion) do
        local beginTime = nil
        local endTime = nil
        beginTime = tonumber(os.time{year = v.starttime[1][1], month = v.starttime[1][2], day = v.starttime[1][3], hour = v.starttime[1][4], min = v.starttime[1][5], sec = v.starttime[1][6]})
        endTime = tonumber(os.time{year = v.endtime[1][1], month = v.endtime[1][2], day = v.endtime[1][3], hour = v.endtime[1][4], min = v.endtime[1][5], sec = v.endtime[1][6]})
        if (v.sex == RoleManager.Instance.RoleData.sex or v.sex == 2) and (v.classes == RoleManager.Instance.RoleData.classes or v.classes == 0) and (baseTime >= beginTime and baseTime <= endTime) then
            if v.openTime == 0 or self:CheckOpenTime(v.openTime) then
                self.fationDatalist[#self.fationDatalist + 1] = {}
                self.fationDatalist[#self.fationDatalist].showId = v.fashion_show
                self.fationDatalist[#self.fationDatalist].fashion_list = v.fashion_list
                self.fationDatalist[#self.fationDatalist].fashion_parts = v.fashion_parts
                self.fationDatalist[#self.fationDatalist].activetime = v.activetime
                self.fationDatalist[#self.fationDatalist].title = v.title
                self.fationDatalist[#self.fationDatalist].label = v.label
                self.fationDatalist[#self.fationDatalist].openargs = v.openargs
                self.fationDatalist[#self.fationDatalist].button_name = v.button_name
                self.fationDatalist[#self.fationDatalist].property = v.property
                self.fationDatalist[#self.fationDatalist].isBack = v.isBack
            end
        end
    end

end

function FashionNewListingPanel:OnClick(index)
    if self.currentIndex ~= nil then
        self.itemList[self.currentIndex].select:SetActive(false)
    end
    self.currentIndex = index
    self.itemList[self.currentIndex].select:SetActive(true)
    self.nameText.text = self.itemList[self.currentIndex].shopData.title
    self:OnSelectFashion(self.itemList[self.currentIndex].shopData)
    self.rightButton.onClick:RemoveAllListeners()
    -- if self.itemList[self.currentIndex].shopData.label == 5 and self.initFirst == true then
    --     local myItemData = ItemData.New()
    --     myItemData:SetBase(DataItem.data_get[self.itemList[self.currentIndex].shopData.showId])
    --     TipsManager.Instance:ShowItem({gameObject = self.rightButton.gameObject,itemData = myItemData})
    -- end

    self.initFirst = true

    if self.itemList[self.currentIndex].shopData.openargs[1][1] == 1 then
        local args = {}
        for i=3,#self.itemList[self.currentIndex].shopData.openargs[1] do
            table.insert(args,self.itemList[self.currentIndex].shopData.openargs[1][i])
        end
        self.rightButton.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(self.itemList[self.currentIndex].shopData.openargs[1][2], args) end)

    elseif self.itemList[self.currentIndex].shopData.openargs[1][1] == 2 then
        self.rightButton.onClick:AddListener(function()
            local myItemData = ItemData.New()
            myItemData:SetBase(DataItem.data_get[self.itemList[self.currentIndex].shopData.openargs[1][2]])
            TipsManager.Instance:ShowItem({gameObject = self.rightButton.gameObject,itemData = myItemData})
        end)
    end
    self.rightButtonText.text = self.itemList[self.currentIndex].shopData.button_name

    self:InitLeftFashion(self.fationDatalist[index],index)
end

-- 换装试穿
function FashionNewListingPanel:OnSelectFashion(data)
    local baseData = DataItem.data_get[data.showId]
    local roledata = RoleManager.Instance.RoleData

    local callback = function(composite)
        self:SetRawImage(composite)
    end

    local str = ""
    local mystr = nil


    if data.property ~= "" then
        --print(data.property)
        mystr = StringHelper.Split(data.property, "|")
        for i,v in ipairs(mystr) do
            str = str .. v .. "\n"
        end
    end




    self.fashionText.text = str
    self.descExt:SetData("")

    local size = self.descExt.contentTrans.sizeDelta
    self.descExt.contentTrans.anchoredPosition = Vector2(-size.x / 2, -60)

    local setting = {
        name = "ShopFashionRole"
        ,orthographicSize = 0.55
        ,width = 341
        ,height = 300
        ,offsetY = -0.35
        ,offsetX = 0.005
    }

    local myData = SceneManager.Instance:MyData()
    local unitData = BaseUtils.copytab(myData)

    if unitData == nil then
        return
    end

    local kvLooks = {}
    local roledata = RoleManager.Instance.RoleData
    for _,v in pairs(unitData.looks) do
        kvLooks[v.looks_type] = v
    end

    self.has_belt = false
    if data.isBack == 1 then
        self.has_belt = true
    end

    for i,vt in ipairs(data.fashion_list) do
        if vt[1] ~= 5 then
            local fashionData = DataFashion.data_base[vt[2]]
            if (fashionData.classes == 0 or roledata.classes == fashionData.classes) and (fashionData.sex == 2 or roledata.sex == fashionData.sex) then
                kvLooks[fashionData.type] = {looks_str = "", looks_val = fashionData.model_id, looks_mode = fashionData.texture_id, looks_type = fashionData.type}
                if fashionData.type == SceneConstData.lookstype_belt then
                end
            end

        else
            local myBaseData = DataWing.data_base[vt[2]]
            kvLooks[SceneConstData.looktype_wing] = {looks_str = "", looks_val = (myBaseData or {}).wing_id or 30003, looks_mode = 0, looks_type = SceneConstData.looktype_wing}
        end
    end

    self.temp_looks = {}
    for k,v in pairs(kvLooks) do
        table.insert(self.temp_looks, v)
    end

    local roledata = RoleManager.Instance.RoleData
    local modelData = {type = PreViewType.Role, classes = roledata.classes, sex = roledata.sex, looks = self.temp_looks}

    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
        self.previewComp:Show()
    end
end

function FashionNewListingPanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.previewContainer)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    if self.has_belt == true then
        composite.tpose.transform.localRotation = Quaternion.Euler(0,SceneConstData.UnitFaceTo.Backward,0)
    else
        composite.tpose.transform.localRotation = Quaternion.identity
    end
    self.composite = composite
    self.previewContainer.gameObject:SetActive(true)
end


function FashionNewListingPanel:CheckOpenTime(days)
    local openTime = CampaignManager.Instance.open_srv_time
    local oy = tonumber(os.date("%Y", openTime))
    local om = tonumber(os.date("%m", openTime))
    local od = tonumber(os.date("%d", openTime))
    local beginTime = tonumber(os.time{year = oy, month = om, day = od, hour = 0, min = 00, sec = 0}) or 0

    if beginTime ~= 0 then
        local baseTime = BaseUtils.BASE_TIME
        local distanceTime = baseTime - beginTime
        local d = math.ceil(distanceTime / 86400)
        if d > days  then
            return true
        end
    end
    return false
end



