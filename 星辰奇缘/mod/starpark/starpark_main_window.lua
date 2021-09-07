--星辰乐园主界面
--2017/3/1
--zzl

StarParkMainWindow  =  StarParkMainWindow or BaseClass(BaseWindow)

function StarParkMainWindow:__init(model)
    self.name  =  "StarParkMainWindow"
    self.model  =  model
    self.resList  =  {
        {file = AssetConfig.starpark_main_window, type = AssetType.Main}
        ,{file = AssetConfig.starpark_texture, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20112), type = AssetType.Main}
    }
    self.windowId = WindowConfig.WinID.starpark

    self.hasInit = false
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.leftBtnItemList = nil
    self.lastSelectedId = 0
    self.lastSelectedItem = nil
    self.panelList = {}
    self.lastPanel = nil
    return self
end

function StarParkMainWindow:OnShow()
    self:UpdateLeftList()
    self:UpdateRedPoint()
end

function StarParkMainWindow:OnHide()

end

function StarParkMainWindow:__delete()
    for k, v in pairs(self.panelList) do
        v:DeleteMe()
    end

    self.lastSelectedId = 0
    self.leftBtnItemList = nil
    if self.subFirst ~= nil then
        self.subFirst:DeleteMe()
        self.subFirst = nil
    end
    self.hasInit = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function StarParkMainWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.starpark_main_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "StarParkMainWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("MainCon")
    self.mainObj = self.MainCon.gameObject
    local CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseStarParkMainUI() end)

    self.LeftCon = self.MainCon:FindChild("LeftCon")
    self.MaskCon = self.LeftCon:FindChild("MaskCon")
    self.ScrollLayer = self.MaskCon:FindChild("ScrollLayer")
    self.Container = self.ScrollLayer:FindChild("Container")
    self.ItemBtn = self.Container:FindChild("ItemBtn").gameObject
    self.ItemBtn:SetActive(false)

    self.RightCon = self.MainCon:FindChild("RightCon")

    self:UpdateLeftList()
end

function StarParkMainWindow:UpdateRedPoint()

end

function StarParkMainWindow:UpdateLeftList()
    local listBtnList = self.model.leftBtnList
    if self.leftBtnItemList == nil then
        self.leftBtnItemList = {}
    else
        for i = 1, #self.leftBtnItemList do
            local item = self.leftBtnItemList[i]
            item.gameObject:SetActive(false)
        end
    end

    local len = #listBtnList+1
    local newHeight = len*80  --1 更多活动
    self.Container:GetComponent(RectTransform).sizeDelta = Vector2(214, newHeight)

    local selectId = 1
    if self.openArgs ~= nil and #self.openArgs > 0 then
        selectId = self.openArgs[1]
    elseif self.lastSelectedId ~= 0 then
        selectId = self.lastSelectedId
    end

    for i = 1, len do
        local data = listBtnList[i]
        local item = self.leftBtnItemList[i]
        if item == nil then
            item = self:CreateItem()
            table.insert(self.leftBtnItemList, item)
        end
        self:SetItem(item, data, i)
        if data ~= nil then
            if data.id == selectId then
                self:UpdateRight(item)
            end
        else
            --最后一条，更多活动
        end
        item.gameObject:SetActive(true)
    end



end

function StarParkMainWindow:CreateItem()
    local item = {}
    item.gameObject = GameObject.Instantiate(self.ItemBtn)
    item.transform = item.gameObject.transform
    item.transform:SetParent(self.ItemBtn.transform.parent)
    item.transform.localScale = Vector3.one
    item.ImgBg = item.transform:FindChild("ImgBg"):GetComponent(Image)
    item.ImgTxt = item.transform:FindChild("ImgTxt"):GetComponent(Image)
    item.ImgSelected = item.transform:FindChild("ImgSelected").gameObject
    item.ImgTodayOpen = item.transform:FindChild("ImgTodayOpen").gameObject
    item.ImgMore = item.transform:FindChild("ImgMore").gameObject

    local effect = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20112)))
    local effectTransform = effect.transform
    Utils.ChangeLayersRecursively(effectTransform, "UI")
    effectTransform:SetParent(item.transform)
    effectTransform.localPosition = Vector3(0, -68, 0)
    effectTransform.localScale = Vector3(1.5, 1.2, 1)
    item.Effect = effect

    item.transform:GetComponent(Button).onClick:AddListener(function()
        self:UpdateRight(item)
    end)
    item.ImgSelected:SetActive(false)
    item.Effect:SetActive(false)
    return item
end

function StarParkMainWindow:SetItem(item, data, index)
    item.index = index
    item.data = data
    local newY = (index - 1)*-80
    item.gameObject.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, newY)

    if data ~= nil then
        item.gameObject:GetComponent(Image).enabled = false
        item.ImgBg.sprite = self.assetWrapper:GetSprite(AssetConfig.starpark_texture, string.format("BtnImg%s", data.icon))
        item.ImgTxt.sprite = self.assetWrapper:GetSprite(AssetConfig.starpark_texture, string.format("I18NStarParkBtnTxt%s", data.icon))
        item.ImgBg.gameObject:SetActive(true)
        item.ImgTxt.gameObject:SetActive(true)
        item.ImgMore:SetActive(false)

        local todayOpen = false
        for key, value in ipairs(AgendaManager.Instance.day_list) do
            if value.id == data.agendaId then
                todayOpen = true
                break
            end
        end
        item.ImgTodayOpen.gameObject:SetActive(todayOpen)

        local agenda_list = AgendaManager.Instance.agenda_list
        local agenda_data = nil
        for i=1, #agenda_list do
            if agenda_list[i].id == data.agendaId then
                agenda_data = agenda_list[i]
                break
            end
        end
        if agenda_data ~= nil and agenda_data.max_try > agenda_data.engaged and self.model:GetActivityState(data.agendaId) then
            item.Effect:SetActive(true)
        else
            item.Effect:SetActive(false)
        end
    else
        item.gameObject:GetComponent(Image).enabled = true
        item.ImgBg.gameObject:SetActive(false)
        item.ImgTxt.gameObject:SetActive(false)
        item.ImgMore:SetActive(true)
        item.Effect:SetActive(false)
    end
end


function StarParkMainWindow:UpdateRight(item)
    if item.data == nil then
        --更多活动
        NoticeManager.Instance:FloatTipsByString(TI18N("更多趣味玩法正在陆续加入，敬请期待{face_1,1}"))
        return
    end

    self.lastSelectedId = item.data.id
    if self.lastSelectedItem ~= nil then
        self.lastSelectedItem.ImgSelected:SetActive(false)
    end
    self.lastSelectedItem = item
    item.ImgSelected:SetActive(true)

    if self.panelList == nil then
        self.panelList = {}
    end
    local panel = self.panelList[self.lastSelectedId]
    if panel == nil then
        -- if self.lastSelectedId == 1 then
        --     panel = StarParkPumpkinPanel.New(self, item.data.bgPath)
        -- elseif self.lastSelectedId == 2 then
        --     panel = StarParkPumpkinPanel.New(self, item.data.bgPath)
        -- elseif self.lastSelectedId == 3 then
        --     panel = StarParkPumpkinPanel.New(self, item.data.bgPath)
        -- elseif self.lastSelectedId == 4 then
        panel = StarParkPumpkinPanel.New(self, item.data.bgPath)
        -- end
        self.panelList[self.lastSelectedId] = panel
    end

    if self.lastPanel ~= nil then
        self.lastPanel:Hiden()
    end

    if panel ~= nil then
        panel:Show()
    end
    self.lastPanel = panel
end
