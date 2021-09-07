-- 作者:jie
-- 3/27/2018
-- 功能:时装礼包展示界面

BackPackSelectSuitPanel = BackPackSelectSuitPanel or BaseClass(BasePanel)
function BackPackSelectSuitPanel:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.backpackselectsuitpanel, type = AssetType.Main}
        ,{file = AssetConfig.suitselectgift_texture, type = AssetType.Dep}
        ,{file = AssetConfig.suitselectbigbg, type = AssetType.Main}
        ,{file = AssetConfig.suitselecttitle, type = AssetType.Main}
        ,{file = AssetConfig.suitselecttitle2, type = AssetType.Main}
        ,{file = AssetConfig.suitselecttoptitle, type = AssetType.Main}
        ,{file = AssetConfig.suitselecttoptitle2, type = AssetType.Main}
    }
    self.RewardItems = { }
    self.setting = {
        axis = BoxLayoutAxis.X
        ,cspacing = 21
        ,border = 24
    }
    self.SelectTab = 0
    self.UseNum = 1

    self.isSure = false
    self.OnOpenEvent:Add( function() self:OnOpen() end)
    self.hasInit = false

    self.IsShow = nil

    self.GiftType = 1
end

function BackPackSelectSuitPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackPackSelectSuitPanel:__delete()
    --EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.ItemChangeHandler)
    if self.RewardItems ~= nil then
        for _, item in pairs(self.RewardItems) do
            item:DeleteMe()
            item = nil
        end
        self.RewardItems = nil
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end


    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end


function BackPackSelectSuitPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backpackselectsuitpanel))
    self.gameObject.name = "BackPackSelectSuitPanel"

    self.transform = self.gameObject.transform
    --self.transform:SetParent(self.parent.transform)

    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)

    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.bg = self.transform:Find("Main/bg")
    UIUtils.AddBigbg(self.bg, GameObject.Instantiate(self:GetPrefab(AssetConfig.suitselectbigbg)))

    self.topTitle = self.transform:Find("Main/TopTitle")
    --UIUtils.AddBigbg(self.topTitle, GameObject.Instantiate(self:GetPrefab(AssetConfig.suitselecttoptitle)))

    self.descTitle = self.transform:Find("Main/DescImg")

    self.BtnPanel = self.transform:Find("Panel"):GetComponent(Button)
    self.BtnPanel.onClick:AddListener(function() self:OnClose() end)

    self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() self:OnClose() end)

    self.previewParent = self.transform:Find("Main/SuitPreview/FashionPreview")

    self.sureBtnImg = self.transform:Find("Main/BtnSure/Image"):GetComponent(Image)
    self.TxtDesc = self.transform:Find("Main/TxtDesc"):GetComponent(Text)

    self.Container = self.transform:Find("Main/IconScroll/Container").gameObject
    self.BaseItem = self.transform:Find("Main/IconScroll/Container/Item").gameObject
    self.BaseItem:SetActive(false)

    self.BtnSure = self.transform:Find("Main/BtnSure"):GetComponent(Button)
    self.BtnSure.onClick:AddListener(function() self:OnSureHandler() end)

end

function BackPackSelectSuitPanel:OnOpen()
    --EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.ItemChangeHandler)
    --EventMgr.Instance:AddListener(event_name.backpack_item_change, self.ItemChangeHandler)
    self.sureBtnImg.sprite = self.assetWrapper:GetSprite(AssetConfig.suitselectgift_texture, "PleaseSelect")
    self.sureBtnImg.transform.sizeDelta = Vector2(93, 37)
    self.sureBtnImg.transform.anchoredPosition = Vector2(-0.5, 1.15)
    if self.openArgs ~= nil then
        local baseID = self.openArgs.baseid
        self.IsShow = self.openArgs.isshow
        self.GiftType = self.openArgs.type or 1
        self:UpdateData(baseID)
    end
    if self.IsShow == false then
        UIUtils.AddBigbg(self.descTitle, GameObject.Instantiate(self:GetPrefab(AssetConfig.suitselecttitle)))
    else
        UIUtils.AddBigbg(self.descTitle, GameObject.Instantiate(self:GetPrefab(AssetConfig.suitselecttitle2)))
    end

    if self.GiftType == 1 then
        UIUtils.AddBigbg(self.topTitle, GameObject.Instantiate(self:GetPrefab(AssetConfig.suitselecttoptitle)))
        self.topTitle.anchoredPosition = Vector2(-222,161)
    else
        self.topTitle.anchoredPosition = Vector2(-177,161)
        UIUtils.AddBigbg(self.topTitle, GameObject.Instantiate(self:GetPrefab(AssetConfig.suitselecttoptitle2)))
    end


    self:UpdateLooks({})
end

function BackPackSelectSuitPanel:OnClose()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    self.model:CloseSelectSuitPanel()
end

function BackPackSelectSuitPanel:OnSureHandler()
    if self.SelectTab <= 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择以上心仪的时装{face_1,3}"))
        return
    end
    if self.ItemData ~= nil then
        --print(self.ItemData.id.."self.ItemData.id")
        --print(self.SelectTab.."self.SelectTab")
        --print(self.UseNum.."self.UseNum")
        BackpackManager.Instance:SendSelectGift(self.ItemData.id, self.SelectTab, self.UseNum)
        self.isSure = true
        self.timerId = LuaTimer.Add(500,function()
            self:OnClose()
        end)
    end
end

function BackPackSelectSuitPanel:OnClickShow(tabID, itemId)
    --print(itemId.."_____"..DataItem.data_get[itemId].icon)
    if self.IsShow == false then
       self.SelectTab = tabID
       if self.SelectTab > 0 then
           self.sureBtnImg.sprite = self.assetWrapper:GetSprite(AssetConfig.suitselectgift_texture, "SureSelect")
           self.sureBtnImg.transform.sizeDelta = Vector2(122, 42)
           self.sureBtnImg.transform.anchoredPosition = Vector2(-0.5, 2.7)
       end
    end

    for key, item in pairs(self.RewardItems) do
        item:DoSelect(key == tabID)
        item:StopEffect()

        if key == tabID then
            item:OnlyShowEffect()
        end
    end
    local datalist = { }
    if self.GiftType == 1 then
        --if DataFashion.data_base[DataItem.data_get[itemId].icon].type == 3 then
        local tempId = DataItem.data_get[itemId].icon
        local iconId = DataItem.data_get[tempId].icon
        if DataFashion.data_base[iconId].type == 3 then
            local suitList = DataFashion.data_suit[iconId].include
            for i,v in pairs(suitList) do
                local myData = DataFashion.data_base[v.fashion_id]
                table.insert(datalist, myData)
            end
        else
            local myData = DataFashion.data_base[iconId]
            table.insert(datalist, myData)
        end
    elseif self.GiftType == 2 then
        --BaseUtils.dump(RoleManager.Instance.RoleData,"RoleInfo")
        local WingId = DataItem.data_get[itemId].effect[1].val[1]
        local myData = {}
        -- local WingId = nil
        -- for i,v in pairs(DataWing.data_base) do
        --     if v.item_id == itemId then
        --         WingId = i
        --         break
        --     end
        -- end
        myData = {model_id = WingId, texture_id = 0, type = SceneConstData.looktype_wing}
        table.insert(datalist, myData)
    end

    self:UpdateLooks(datalist)

end

function BackPackSelectSuitPanel:UpdateData(baseID)
    self.SelectTab = 0
    self.UseNum = 1
    if self.Layout ~= nil then
        self.Layout:DeleteMe()
    end
    local items = BackpackManager.Instance:GetItemByBaseid(baseID)
    --BaseUtils.dump(items,"454545")
    self.GiftList = { }
    --if items ~= nil and #items > 0 then
    self.ItemData = items[1]
    --BaseUtils.dump(self.ItemData,"4444444444")
    local gift_list = DataItemGift.data_select_gift_list[baseID]
    --BaseUtils.dump(gift_list,"7777777777777777777777")
    self.GiftList = self:FilterTmps(gift_list)
    local len = #self.GiftList
    if len > 0 then
        local soreFun =
        function(a, b)
            return a.tab_id < b.tab_id
        end
        table.sort(self.GiftList, soreFun)
        local cspacing = 0   --第一个的坐标
        if len <= 4 then
            cspacing = 21 + (4 - len) * 56
        end
        self.setting.cspacing = cspacing
        self.Layout = LuaBoxLayout.New(self.Container, self.setting)
        local nowIndex = 0
        for _, giftTmp in pairs(self.GiftList) do
            nowIndex = nowIndex + 1
            local item = self.RewardItems[giftTmp.tab_id]
            if BaseUtils.is_null(item) then
                item = BackpackSelectSuitItem.New(self.BaseItem)
                item.nowIndex = nowIndex
                item.length = len
                item.tab_id = giftTmp.tab_id
                self.RewardItems[giftTmp.tab_id] = item
            end
            item:SetData(giftTmp.item_id)
            item.gameObject:SetActive(true)
            item.Btn.onClick:AddListener(function() self:OnClickShow(item.tab_id, giftTmp.item_id) end)


            self.Layout:AddCell(item.gameObject)
        end
    end
    -- if #self.GiftList < #self.RewardItems then
    --     for index = #self.GiftList + 1, #self.RewardItems do
    --         for k,v in pairs(self.RewardItems) do
    --             if v.nowIndex == index then
    --                 local item = self.RewardItems[k]
    --                 item:DeleteMe()
    --                 item = nil
    --             end
    --         end
    --     end
    -- end
    --展示用的 不能打开
    if self.IsShow == true then
        self.BtnSure.gameObject:SetActive(false)
        --换标题
    end
end

--根据性别 等级 职业 筛选礼包
function BackPackSelectSuitPanel:FilterTmps(tmplist)
    if tmplist == nil or #tmplist == 0 then
        return tmplist
    end
    local recList = { }
    local roleData = RoleManager.Instance.RoleData
    for _, tmpdata in pairs(tmplist) do
        if (tmpdata.sex == roleData.sex or tmpdata.sex == 2)
            and(tmpdata.classes == roleData.classes or tmpdata.classes == 0)
            and(tmpdata.lev_low <= roleData.lev or tmpdata.lev_low == 0)
            and(tmpdata.lev_high >= roleData.lev or tmpdata.lev_high == 0) then
            table.insert(recList, tmpdata)
        end
    end
    return recList
end


function BackPackSelectSuitPanel:UpdateLooks(data_list)

    local myData = SceneManager.Instance:MyData()   --当前模型数据
    local unitData = BaseUtils.copytab(myData)

    self.kvLooks = {}
    for k2,v2 in pairs(unitData.looks) do
        self.kvLooks[v2.looks_type] = v2
    end
    --BaseUtils.dump(data_list,"data_list##############")

    if next(data_list) ~= nil then
        for k,v in pairs(data_list) do
            self.kvLooks[v.type] = {looks_str = "", looks_val = v.model_id, looks_mode = v.texture_id, looks_type = v.type}
        end
    end
    self:SetPreviewComp(self.kvLooks)
end

function BackPackSelectSuitPanel:SetPreviewComp(myLooks)
    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = myLooks}

    if modelData ~= nil then
        local callback = function(composite)
            self:SetRawImage(composite)
        end
        if self.previewComp == nil then
            local setting = {
                name = "previewComp"
                ,orthographicSize = 0.55
                ,width = 250
                ,height =250
                ,offsetY = -0.4
            }
            self.previewComp = PreviewComposite.New(callback, setting, modelData)
        else
            self.previewComp:Reload(modelData, callback)
        end
        self.previewComp:Show()
    end
end

function BackPackSelectSuitPanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.previewParent)
    rawImage.transform.localPosition = Vector3(9, -11.5, 0)
    rawImage.transform.localScale = Vector3(1.3, 1.3, 1.3)
    self.previewParent.gameObject:SetActive(true)
end
