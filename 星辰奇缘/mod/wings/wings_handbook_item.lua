    -- @author 黄耀聪
-- @date 2017年5月18日

WingHandbookItem = WingHandbookItem or BaseClass()

function WingHandbookItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    local t = self.transform

    self.nameText = t:Find("Name"):GetComponent(Text)
    self.previewComp = nil
    self.normal = t:Find("Normal").gameObject
    self.select = t:Find("Select").gameObject
    self.wingMark = t:Find("WingMark").gameObject
    self.questionMark = t:Find("Mark").gameObject
    self.get = t:Find("Get").gameObject
    self.previewContainer = t:Find("Preview")
    self.iconLoader = SingleIconLoader.New(t:Find("Icon").gameObject)
    self.btn = gameObject:GetComponent(Button)

    self.btn.onClick:AddListener(function() self:OnClick() end)
    self.updateListener = function() self:Update() end

    self.clickCallback = nil
end

function WingHandbookItem:__delete()
    EventMgr.Instance:RemoveListener(event_name.role_wings_change, self.updateListener)
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end
    self.gameObject = nil
    self.model = nil
end

function WingHandbookItem:update_my_self(id, index)
    self.id = id

    local cfgData = DataWing.data_base[id]
    self.nameText.text = cfgData.name
    self:Update()
    -- BaseUtils.dump(data, tostring(index))
    -- if data ~= nil then
    --     local baseData = DataWing.data_base[data.ids[1]]

    --     self.iconLoader:SetSprite(SingleIconType.Item, DataItem.data_get[baseData.item_id].icon)

    --     if WingsManager.Instance.hasGetGrades[baseData.grade] ~= 1 and WingsManager.Instance.illusionTab[baseData.grade] == nil then
    --         self.nameText.color = Color(1, 0, 0)
    --     else
    --         self.nameText.color = ColorHelper.DefaultButton1
    --     end

    --     self.useObj:SetActive(baseData.wing_id == WingsManager.Instance.wing_id)
    --     if baseData.grade < 2000 then
    --         self.nameText.text = string.format(TI18N("%s阶"), BaseUtils.NumToChn(baseData.grade))
    --     else
    --         if not WingsManager.Instance:IllusionGroup(data.ids) then
    --             self.nameText.text = TI18N("幻化激活")
    --         else
    --             self.nameText.text = TI18N("<color='#00ff00'>已激活</color>")
    --         end
    --     end

    --     self.gameObject:SetActive(true)
    -- else
    --     self.gameObject:SetActive(false)
    -- end

    self:Select(false)
end

function WingHandbookItem:SetData(data)
    self:update_my_self(data)
end

function WingHandbookItem:OnClick()
    if self.clickCallback ~= nil then
        self.clickCallback(self.id)
    end
    self:Select(true)
end

function WingHandbookItem:ReloadGet()
    local bool = WingsManager.Instance.hasGetIds[self.id] ~= nil or WingsManager.Instance.illusionTab[self.id] ~= nil
    self:ShowPreview(false)
    if bool then
        self.iconLoader.gameObject:SetActive(true)
        self.iconLoader:SetSprite(SingleIconType.Item, DataItem.data_get[DataWing.data_base[self.id].item_id].icon)
    else
        self.iconLoader.gameObject:SetActive(false)
    end
    self.questionMark:SetActive(not bool)
    self.wingMark:SetActive(not bool)
end

function WingHandbookItem:Select(bool)
    self.select:SetActive(bool == true)
    self.normal:SetActive(bool ~= true)
end

function WingHandbookItem:ShowPreview(bool)
    if bool then
        if self.id ~= self.lastId then
            local modelData = {type = PreViewType.Wings, looks = {{looks_type = SceneConstData.looktype_wing, looks_val = self.id}}}

            self.previewCallback = self.previewCallback or function(composite) self:SetRawImage(composite) end
            self.setting = self.setting or {
                name = "wing"
                ,orthographicSize = 0.65
                ,width = 150
                ,height = 180
                ,offsetY = -0.1
                ,noDrag = true
                ,noMaterial = true
                ,noAnimator = true
            }
            if self.previewComp == nil then
                self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
            else
                self.previewComp:Reload(modelData, self.previewCallback)
                self.previewComp:Show()
            end
        end
    else
        self.previewContainer.gameObject:SetActive(false)
        if self.previewComp ~= nil then
            self.previewComp:Hide()
        end
    end
end

function WingHandbookItem:SetRawImage(composite)
    composite.rawImage.transform:SetParent(self.previewContainer)
    composite.rawImage.transform.localScale = Vector3.one
    composite.rawImage.transform.localPosition = Vector3.zero
    self.previewContainer.gameObject:SetActive(true)
end

function WingHandbookItem:SetActive(bool)
    self.previewContainer.gameObject:SetActive(bool)
    if bool and self.previewComp ~= nil then
        self.previewComp:Hide()
    end
    self.gameObject:SetActive(bool)
    EventMgr.Instance:RemoveListener(event_name.role_wings_change, self.updateListener)
    if bool then
        EventMgr.Instance:AddListener(event_name.role_wings_change, self.updateListener)
    end
end

function WingHandbookItem:Update()
    self.get:SetActive(WingsManager.Instance.hasGetIds[self.id] == 1 or WingsManager.Instance.illusionTab[self.id] ~= nil)
    self:ReloadGet()
end
