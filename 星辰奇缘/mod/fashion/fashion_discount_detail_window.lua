-- @author pwj
-- @date 2018年1月6日,星期六

FashionDiscountDetailWindow = FashionDiscountDetailWindow or BaseClass(BaseWindow)

function FashionDiscountDetailWindow:__init(model)
    self.model = model
    self.name = "FashionDiscountDetailWindow"
    self.windowId = WindowConfig.WinID.fashion_discount_detail_window
    self.cacheMode = CacheMode.Visible
    self.resList = {
         {file = AssetConfig.fashion_discount_detail_window, type = AssetType.Main}
         ,{file = AssetConfig.fashion_discount_detail_bg, type = AssetType.Main}
         ,{file = AssetConfig.fashion_discount_detail_title, type = AssetType.Main}
         ,{file = AssetConfig.fashion_discount_texture, type = AssetType.Dep}
         ,{file = AssetConfig.fashion_selection_show_big1, type = AssetType.Dep}
         ,{file = AssetConfig.fashion_selection_show_big2, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.pirceItemList = { }
    self.slot = { }
    self.currIndex = 1
    self.data_list_group = { }         --一套时装的三种折扣配置方案
    self.sexId = 0
    self.fashionId = 1

    self.setting = {
        --nobutton = true, 
        inbag = false,
    }
end

function FashionDiscountDetailWindow:__delete()
    self.OnHideEvent:Fire()

    if self.topbg ~= nil then
        BaseUtils.ReleaseImage(self.topbg)
    end

    if self.bottombg ~= nil then
        BaseUtils.ReleaseImage(self.bottombg)
    end
    if self.pirceItemList ~= nil then
        for i,v in ipairs(self.pirceItemList) do
            v:GetComponent(Image).sprite = nil
        end
    end

    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.slot1 ~= nil then
        self.slot1:DeleteMe()
        self.slot1 = nil
    end

    if self.slot ~= nil then
        for _,v in pairs(self.slot) do
            v:DeleteMe()
            v = nil
        end
        self.slot = nil
    end
    
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function FashionDiscountDetailWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_discount_detail_window))
    self.gameObject.name = "FashionDiscountDetailWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClose() end)

    local bg = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_discount_detail_bg))
    UIUtils.AddBigbg(self.transform:Find("Main/Bg"), bg)

    self.bigtitle = self.transform:Find("Main/Title")
    --self.bigtitle.anchoredPosition = Vector2(124,100)
    local titlePrefab = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_discount_detail_title))
    UIUtils.AddBigbg(self.bigtitle, titlePrefab)
    
 
    self.fashionItem = self.transform:Find("Main/Fashionshow")

    self.topbg = self.fashionItem:Find("TopBg"):GetComponent(Image)
    self.topbg.sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_show_big1, "FashionSelectionTop")
    
    self.bottombg = self.fashionItem:Find("BottomBg"):GetComponent(Image)
    self.bottombg.sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_show_big2, "FashionSelectionBottom")
    self.fashionItem:Find("BottomBg").gameObject:SetActive(true)

    self.titleTxt = self.fashionItem:Find("TitleBg/Text"):GetComponent(Text)
    self.previewParent = self.fashionItem:Find("FashionPreview")
    
    self.slotContainer = self.fashionItem:Find("Solt")
    self.slotContainer.gameObject:SetActive(false)

    self.buybutton = self.transform:Find("Main/BuyButton"):GetComponent(Button)
    self.buybutton.onClick:AddListener(function() self:ApplyBuyButton() end)

    self.PirceItemContainer = self.transform:Find("Main/rightItem")

    self.tabLayout = LuaBoxLayout.New(self.slotContainer.gameObject, {axis = BoxLayoutAxis.Y,  cspacing = 0,border = 5})

end

function FashionDiscountDetailWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function FashionDiscountDetailWindow:OnOpen()
    self:AddListeners()
    self.openAr = self.openArgs or self.openAr
    self:SetData()
end

function FashionDiscountDetailWindow:OnHide()
    self:RemoveListeners()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end

function FashionDiscountDetailWindow:AddListeners()
    self:RemoveListeners()
end

function FashionDiscountDetailWindow:RemoveListeners()
end

function FashionDiscountDetailWindow:OnClose()   
    if self.model.mainWin ~= nil then
        self.model:CloseDetailWindow()
    else
        WindowManager.Instance:OpenWindowById(WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_uniwin, {1235}))
    end
    
end

function FashionDiscountDetailWindow:SetData()   

    self.data_list_group = {}

    self.sexId = self.openAr[1]            --性别id 0 1 
    self.fashionId = self.openAr[2]        --区分哪一套时装 1 2 3
    
    local sexIndex = 1
    if self.sexId == RoleManager.Instance.RoleData.sex then
        sexIndex = 1
    else
        sexIndex = 2
    end
    --print("index = "..sexIndex.."----self.fashionId = "..self.fashionId)
    if self.sexId ~= nil and self.fashionId ~= nil then
        for i,v in pairs(self.model.fashionList[sexIndex][self.fashionId]) do
            table.insert(self.data_list_group, v)
        end
        table.sort(self.data_list_group,function(a,b)
            if a.origin_price ~= b.origin_price then
                return a.origin_price < b.origin_price
            else
                return false
            end
        end)
    end
    --BaseUtils.dump(self.data_list_group,"self.data_list_group")

    for i = 1,3 do
        if self.pirceItemList[i] == nil then
           local go = self.PirceItemContainer:Find("DiscountItem"..i)
           go:GetComponent(Button).onClick:AddListener(function() self:ClickPriceItem(i) end)
           go:Find("OriginalCostNum"):GetComponent(Text).text = self.data_list_group[i].origin_price   --原价
           go:Find("DiscountCostNum"):GetComponent(Text).text = self.data_list_group[i].new_price   --折扣价
           local typePrice = go:Find("ItemTitle"):GetComponent(Text)
           typePrice.text = TI18N(self.data_list_group[i].plan_name)
           self.pirceItemList[i] = go

           local shopName = self.data_list_group[i].fashion_name  --根据id取得对应时装数据
           self.titleTxt.text = TI18N(shopName)
        else
          local go = self.pirceItemList[i]
          go:Find("OriginalCostNum"):GetComponent(Text).text = self.data_list_group[i].origin_price   --原价
          go:Find("DiscountCostNum"):GetComponent(Text).text = self.data_list_group[i].new_price   --折扣价
          local typePrice = go:Find("ItemTitle"):GetComponent(Text)
          typePrice.text = TI18N(self.data_list_group[i].plan_name)

          local shopName = self.data_list_group[i].fashion_name  --根据id取得对应时装数据
           self.titleTxt.text = TI18N(shopName)
       end
    end


    self:ClickPriceItem(1)

    
end

function FashionDiscountDetailWindow:SetBaseData()             --更新模型接口

    local data_list = {}
    if self.data_list_group[self.currIndex].fashion ~= nil then
        for k,v in pairs(self.data_list_group[self.currIndex].fashion) do
            local myData = DataFashion.data_base[v.value]
            table.insert(data_list, myData)
        end
    end

    self:UpdateLooks(data_list)
end

function FashionDiscountDetailWindow:UpdateLooks(data_list)

    local myData = SceneManager.Instance:MyData()   --当前模型数据
    local unitData = BaseUtils.copytab(myData)

    self.kvLooks = {}
    for k2,v2 in pairs(unitData.looks) do
        self.kvLooks[v2.looks_type] = v2
    end
    --BaseUtils.dump(data_list,"data_list##############")
    for k,v in pairs(data_list) do
        self.kvLooks[v.type] = {looks_str = "", looks_val = v.model_id, looks_mode = v.texture_id, looks_type = v.type}
    end

    self:SetPreviewComp(self.kvLooks)
end

function FashionDiscountDetailWindow:SetPreviewComp(myLooks)
    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = self.sexId, looks = myLooks}

    if modelData ~= nil then
        local callback = function(composite)
            self:SetRawImage(composite)
        end
        if self.previewComp == nil then
            local setting = {
                name = "previewComp"
                ,orthographicSize = 1
                ,width = 450
                ,height = 450
                ,offsetY = 0
            }
            self.previewComp = PreviewComposite.New(callback, setting, modelData)
        else
            self.previewComp:Reload(modelData, callback)
        end
        self.previewComp:Show()
    end
end

function FashionDiscountDetailWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.previewParent.transform)
    rawImage.transform.localPosition = Vector3(15, -109, 0)
    rawImage.transform.localScale = Vector3(1.3, 1.3, 1.3)
    self.previewParent.gameObject:SetActive(true)
end

--弹出购买确认框
function FashionDiscountDetailWindow:ApplyBuyButton()
    local strData = ""
    if self.currIndex == 1 then
         strData = string.format("是否确认花费<color='#7fff00'>%s</color>钻石购买<color='#ffff00'>单件时装</color>？",self.data_list_group[1].new_price)
    elseif self.currIndex == 2 then
        strData = string.format("是否确认花费<color='#7fff00'>%s</color>钻石购买<color='#ffff00'>时装+头饰</color>？",self.data_list_group[2].new_price)
    elseif self.currIndex == 3 then
        strData = string.format("是否确认花费<color='#7fff00'>%s</color>钻石购买<color='#ffff00'>时装+头饰+背饰</color>？",self.data_list_group[3].new_price)
    end

    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.content = strData
    confirmData.sureLabel = TI18N("购买")
    confirmData.cancelLabel = TI18N("取消")
    confirmData.sureCallback = function()
        if BackpackManager.Instance:GetCurrentGirdNum() <= 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("背包已满，请整理后再来购买"))
            return
        else
            --确定按钮点击发协议
            local data = {plan_id = (self.fashionId - 1) * 3 + self.currIndex, num = 1, sex = self.sexId }
            FashionDiscountManager.Instance:send20417(data)
            --NoticeManager.Instance:FloatTipsByString(TI18N("购买完成"))
        end
    end
    NoticeManager.Instance:ConfirmTips(confirmData)
end


--点击右方价格条目按钮
function FashionDiscountDetailWindow:ClickPriceItem(index)
    for i,v in ipairs(self.pirceItemList) do
        v:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_discount_texture, "unselected2")
    end

    local go = nil
    if self.pirceItemList[index] ~= nil then
        go = self.pirceItemList[index]

        go:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_discount_texture, "selected2")
    end

    self.currIndex = index

    self:UpdateFashionShow()

end

function FashionDiscountDetailWindow:UpdateFashionShow()
    if self.currIndex == 1 then 
        --更新显示模型（如是否显示左侧道具框）
        --更新显示道具框
        self.slotContainer.gameObject:SetActive(false)

    elseif self.currIndex == 2 then
        local iconId = DataFashion.data_base[self.data_list_group[self.currIndex].fashion[3].value].loss[1].val[1][1]

        --local iconId = self.data_list_group[self.currIndex].fashion[3].value
        if iconId ~= nil then
            if self.slot1 == nil then
                self.slot1 = ItemSlot.New()
                UIUtils.AddUIChild(self.slotContainer, self.slot1.gameObject)
                local base = DataItem.data_get[iconId]
                local item = ItemData.New()
                item:SetBase(base)  
                self.slot1:SetAll(item, self.setting)
                self.slot1.transform.sizeDelta = Vector2(60, 60)
                self.tabLayout:AddCell(self.slot1.gameObject)
            else
                local base = DataItem.data_get[iconId]
                local item = ItemData.New()
                item:SetBase(base)  
                self.slot1:SetAll(item, self.setting)
                self.slot1.transform.anchoredPosition = Vector2(0, -65)
                self.slot1.gameObject:SetActive(true)
            end
        end

        for i = 1,2 do
            if self.slot[i] ~= nil then
                self.slot[i].gameObject:SetActive(false)
            end
        end
        self.slotContainer.gameObject:SetActive(true)

        
    elseif self.currIndex == 3 then
        local iconIds = { }
        iconIds[1] = DataFashion.data_base[self.data_list_group[self.currIndex].fashion[3].value].loss[1].val[1][1]
        iconIds[2] = DataFashion.data_base[self.data_list_group[self.currIndex].fashion[4].value].loss[1].val[1][1]
        --iconIds[1] = self.data_list_group[self.currIndex].fashion[3].value
        --iconIds[2] = self.data_list_group[self.currIndex].fashion[4].value
        if iconIds[1] ~= nil and iconIds[2] ~= nil then
            for i = 1,2 do
                if self.slot[i] == nil then
                   self.slot[i] = ItemSlot.New()
                   UIUtils.AddUIChild(self.slotContainer, self.slot[i].gameObject)
                   local base = DataItem.data_get[iconIds[i]]          --data.xxxx[i]
                   local item = ItemData.New()
                   item:SetBase(base)  
                   self.slot[i]:SetAll(item, self.setting)
                   self.slot[i].transform.sizeDelta = Vector2(60, 60)
                   self.tabLayout:AddCell(self.slot[i].gameObject)
                else
                   local base = DataItem.data_get[iconIds[i]]
                   local item = ItemData.New()
                   item:SetBase(base)
                   self.slot[i]:SetAll(item, self.setting)
                   self.slot[i].gameObject:SetActive(true)
                end
            end
        end
        if self.slot1 ~= nil then
            self.slot1.gameObject:SetActive(false)
        end
        
        self.slotContainer.gameObject:SetActive(true)
    end

    self:SetBaseData()
end



