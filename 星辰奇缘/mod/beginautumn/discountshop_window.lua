DisCountShopWindow = DisCountShopWindow or BaseClass(BaseWindow)

function DisCountShopWindow:__init(model)
    self.model = model
    self.cacheMode = CacheMode.Visible
    self.windowId = WindowConfig.WinID.discountshopwindow

    self.resList = {
        {file = AssetConfig.discountshop_window, type = AssetType.Main}
        ,{file = AssetConfig.witch_girl,type = AssetType.Dep}
        ,{file = AssetConfig.beginautum,type = AssetType.Dep}
        ,{file = AssetConfig.christmas_top_bg, type = AssetType.Main}
        ,{file = AssetConfig.suitselectgift_texture, type = AssetType.Dep}
    }

    self.subPanelList = {}
    self.title = TI18N("开服联欢")

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)

    self.onUpdateShopData = function() self:UpdateDataList() end

    self.onUpdateItemStatus = function() self:UpdateDateStatus() end
    self.onUpdateShowRedPoint = function () self:ShowRedPoint() end

    self.itemList = {}
    self.extra = {inbag = false, nobutton = true, noqualitybg = true, noselect = true}

    self.campId = nil

    self.rotateId = { }
end

function DisCountShopWindow:__delete()
    self.OnHideEvent:Fire()

    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if self.luaGrid ~= nil then
        self.luaGrid:DeleteMe()
        self.luaGrid = nil
    end

    for k,v in pairs(self.itemList) do
        if v.imgLoader ~= nil then
            v.imgLoader:DeleteMe()
            v.imgLoader = nil
        end

         if v.imgLoader2 ~= nil then
            v.imgLoader2:DeleteMe()
            v.imgLoader2 = nil
        end
         if v.itemSlot ~= nil then
            v.itemSlot:DeleteMe()
            v.itemSlot = nil
        end

        if v.tipsPanel ~= nil then
            v.tipsPanel:DeleteMe()
            v.tipsPanel = nil
        end
    end

    if self.rotateId ~= nil then
        for i,v in pairs(self.rotateId) do
            LuaTimer.Delete(v)
            v = nil
        end
        self.rotateId = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DisCountShopWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.discountshop_window))
    self.gameObject.name = "DisCountShopWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

    self.transform = self.gameObject.transform
    self.mainPanel = self.transform:Find("MainCon")

    UIUtils.AddBigbg(self.transform:Find("MainCon/Bg/TopTitle"), GameObject.Instantiate(self:GetPrefab(AssetConfig.christmas_top_bg)))

    self.closeBtn = self.mainPanel:Find("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClose() end)

    self.cloner =  self.mainPanel:Find("Cloner")
    self.cloner.gameObject:SetActive(false)
    self.container = self.mainPanel:Find("Container")

    self.refreshBtn = self.mainPanel:Find("RefreshButton"):GetComponent(Button)
    self.refreshBtn.onClick:AddListener(function() self:RefreshButton() end)

    self.refreshRedPoint = self.mainPanel:Find("RefreshButton/Notify")

    self.timeText = self.mainPanel:Find("NoticeText/Time"):GetComponent(Text)

    self.dataText = self.mainPanel:Find("Bg/TmeBg/Text"):GetComponent(Text)

    self.grildBg = self.mainPanel:Find("Grild"):GetComponent(Image)
    self.grildBg.sprite = self.assetWrapper:GetSprite(AssetConfig.witch_girl,"Witch")
    self.grildBg.gameObject:AddComponent(GraphicRaycaster).ignoreReversedGraphics = true

    --倒计时
    --self.NoticeText = self.mainPanel:Find("NoticeText"):GetComponent(Text)


    --self.lastText = self.mainPanel:Find("Right2Text"):GetComponent(Text)
    --self.lastText.transform.anchoredPosition = Vector2(206,-207)

    --self.rightText = self.mainPanel:Find("RightText"):GetComponent(Text)
    --self.rightText.text = string.format("消耗<color='#00ff00'>%s</color>",1)

    --剩余刷新提示
    --self.MidleText = self.mainPanel:Find("MidleText"):GetComponent(Text)

    self.lossDescText = self.mainPanel:Find("LossDescText"):GetComponent(Text)
    self.lossDescText.text = TI18N("手动刷新消耗 <color='#00ff00'>1</color> ")
    self.lossItemBg = self.mainPanel:Find("LossDescText/Image"):GetComponent(Image)
    self.imgLoader = SingleIconLoader.New(self.lossItemBg.gameObject)
    self.imgLoader:SetSprite(SingleIconType.Item,20770)

    -- self.itemImage = self.mainPanel:Find("Item"):GetComponent(Image)
    -- self.imgLoader = SingleIconLoader.New(self.itemImage.gameObject)
    -- self.imgLoader:SetSprite(SingleIconType.Item,20770)



    self.setting = {
            column = 4
            ,cspacing = 10       --左右间距
            ,rspacing = 6       --上下间距
            ,cellSizeX = 129
            ,cellSizeY = 166
            ,bordertop = 15      --与top的距离
            ,borderleft = 27     --与left的距离
        }
    self.luaGrid = LuaGridLayout.New(self.container,self.setting)


    self.OnOpenEvent:Fire()
end

function DisCountShopWindow:OnOpen()
    self:AddListeners()
    BeginAutumnManager.Instance:send17871()
    BeginAutumnManager.Instance.isOpeningShop = true
    BeginAutumnManager.Instance.isInitShop = true
    --BeginAutumnManager.Instance.redPointDic[CampaignEumn.BeginAutumn.TimeShop] = false
    --BeginAutumnManager.Instance.redPointDic[CampaignEumn.BeginAutumn.TimeShop] = CampaignRedPointManager.Instance:TimeShop2()
    BeginAutumnManager.Instance:CheckRedPoint()

    self.openAr = self.openArgs or self.openAr
    self.campId = self.openAr.campId or 989

    self.dataText.text = string.format("开业时间：%s月%s日-%s月%s日",DataCampaign.data_list[self.campId].cli_start_time[1][2],DataCampaign.data_list[self.campId].cli_start_time[1][3],DataCampaign.data_list[self.campId].cli_end_time[1][2],DataCampaign.data_list[self.campId].cli_end_time[1][3])

    local loss_items = DataCampaign.data_list[self.campId].loss_items
    if not (loss_items[1] or {})[1] then 
        Log.Error(string.format( "活动配置表活动id:%s,需要扣除物品未配置", self.campId))
    end
    self.refreshItemId = loss_items[1][1]
end

function DisCountShopWindow:ShowRedPoint()
    local t = CampaignRedPointManager.Instance:TimeShop2()
    self.refreshRedPoint.gameObject:SetActive(t)
end


function DisCountShopWindow:OnHide()
    BeginAutumnManager.Instance.isOpeningShop = false
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

end

function DisCountShopWindow:RemoveListeners()
    BeginAutumnManager.Instance.OnUpdateShop:RemoveListener(self.onUpdateShopData)
    BeginAutumnManager.Instance.OnUpdateShopStatus:RemoveListener(self.onUpdateItemStatus)
    BeginAutumnManager.Instance.OnUpdateShopRed:RemoveListener(self.onUpdateShowRedPoint)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change,self.onUpdateShowRedPoint)
end

function DisCountShopWindow:AddListeners()
    BeginAutumnManager.Instance.OnUpdateShop:AddListener(self.onUpdateShopData)
    BeginAutumnManager.Instance.OnUpdateShopStatus:AddListener(self.onUpdateItemStatus)
    BeginAutumnManager.Instance.OnUpdateShopRed:AddListener(self.onUpdateShowRedPoint)
    EventMgr.Instance:AddListener(event_name.backpack_item_change,self.onUpdateShowRedPoint)

end

function DisCountShopWindow:OnClose()
    self.model:CloaseDisCountShopWindow()
end


function DisCountShopWindow:UpdateDataList()
    --BaseUtils.dump(BeginAutumnManager.Instance.shopDataList.shop_list,"1212")

    for i,v in ipairs(BeginAutumnManager.Instance.shopDataList.shop_list) do
        if self.itemList[i] == nil then
            local item = {}
            local go = GameObject.Instantiate(self.cloner.gameObject)
            local t = go.transform
            self.luaGrid:UpdateCellIndex(go,i)
            item.itemSlot = ItemSlot.New()
            UIUtils.AddUIChild(t:Find("ItemBg"), item.itemSlot.gameObject)
            item.button = t:Find("Btn"):GetComponent(Button)
            item.title = t:Find("TitleBg/TileText"):GetComponent(Text)
            item.zuanShiImg = t:Find("ZuanShiText/Image"):GetComponent(Image)
            item.zuanShi = t:Find("ZuanShiText")
            item.got = t:Find("Got")
            item.itemImg = t:Find("ItemBg"):GetComponent(Image)
            item.itemButton = t:Find("ItemBg"):GetComponent(Button)
            item.priceText =t:Find("ZuanShiText/MddleText"):GetComponent(Text)
            item.discountImg = t:Find("DiscountBg/Num"):GetComponent(Image)

            item.discountBg = t:Find("DiscountBg"):GetComponent(Image)
            item.flashBg = t:Find("CircleBg/FlashBg"):GetComponent(Image)

            item.imgLoader = SingleIconLoader.New(item.zuanShiImg.gameObject)
            item.ItemLoader = SingleIconLoader.New(item.itemImg.gameObject)
            table.insert(self.itemList,item)
        end
        local itemData = ItemData.New()
        local baseData = DataItem.data_get[v.item_list[1].item_id]
        itemData:SetBase(baseData)
        self.itemList[i].itemSlot:SetAll(itemData,self.extra)
        self.itemList[i].itemSlot:SetNum(v.item_list[1].num)
        self.itemList[i].itemSlot.bgImg.enabled = false
        self.itemList[i].itemSlot.itemImgRect.sizeDelta = Vector2.one * 68
        --self.itemList[i].itemSlot.
        --self.itemList[i].text = ColorHelper.color_item_name(baseData.quality, baseData.name)

        local Data = DataItem.data_get[v.item_list[1].item_id]
        self.itemList[i].button.onClick:RemoveAllListeners()
        self.itemList[i].button.onClick:AddListener(function() self:ItemButton(v.id,index,v) end)
        self.itemList[i].title.text = Data.name
        self.itemList[i].imgLoader:SetSprite(SingleIconType.Item,v.cost2[1].item_id)
        --self.itemList[i].ItemLoader:SetSprite(SingleIconType.Item, Data.icon)
        if v.show_effect == 1 then
            if self.rotateId[i] ~= nil then
                LuaTimer.Delete(self.rotateId[i])
                self.rotateId[i] = nil
            end
            self.rotateId[i] = LuaTimer.Add(0, 10, function() self.itemList[i].flashBg.transform:Rotate(Vector3(0, 0, 0.5)) end)
        end
        if #v.show_item > 0 then
            self.itemList[i].itemSlot.button.onClick:RemoveAllListeners()
            self.itemList[i].itemSlot.button.onClick:AddListener(function()
                if self.itemList[i].tipsPanel == nil then
                    self.itemList[i].tipsPanel = SevenLoginTipsPanel.New(self)
                end
                if v.show_type == 3 then
                    self.itemList[i].tipsPanel:Show({v.show_item,5,{nil,nil,116,nil},"打开可获得以下全部道具："})
                elseif v.show_type == 2 then
                    self.itemList[i].tipsPanel:Show({v.show_item,5,{nil,nil,160,nil},"打开可随机获得以下道具中的一种："})
                end
            end)
        else
            --没有展示物品时
            self.itemList[i].itemSlot.button.onClick:RemoveAllListeners()
            self.itemList[i].itemSlot.button.onClick:AddListener(function()
                self.itemList[i].itemSlot:ClickSelf()
            end)
        end
        --剩余数量
        -- if v.limit_zone_num == 0 then
        --     self.itemList[i].countText.gameObject:SetActive(false)
        -- else
        --     self.itemList[i].countText.gameObject:SetActive(true)
        -- end
        -- self.itemList[i].countText.text = string.format("剩余数量:%s",v.limit_zone_num - v.num)
        --self.itemList[i].buttonText.text = tostring(v.cost2[1].num)
        --self.itemList[i].notNeedText.text= "原价： " .. v.cost1
        self.itemList[i].priceText.text = v.cost2[1].num
        local saleNum = math.floor(v.cost2[1].num/v.cost1 * 10)  --折数
        if saleNum >= 6 then
            self.itemList[i].discountBg.sprite = self.assetWrapper:GetSprite(AssetConfig.suitselectgift_texture,"discountbg2")
            self.itemList[i].discountImg.sprite = self.assetWrapper:GetSprite(AssetConfig.suitselectgift_texture,"zhe2_"..saleNum)
        else
            self.itemList[i].discountBg.sprite = self.assetWrapper:GetSprite(AssetConfig.suitselectgift_texture,"discountbg")
            self.itemList[i].discountImg.sprite = self.assetWrapper:GetSprite(AssetConfig.suitselectgift_texture,"zhe_"..saleNum)
        end

        --是否已购买
        if v.isbuy == 0 then
            self.itemList[i].button.gameObject:SetActive(true)
            self.itemList[i].got.gameObject:SetActive(false)
        else
            self.itemList[i].button.gameObject:SetActive(false)
            self.itemList[i].got.gameObject:SetActive(true)
        end
    end
    self:CalculateTime()
end


function DisCountShopWindow:ItemButton(id,index,myData)
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(TI18N("是否花费<color='#00ff00'>%s</color>{assets_2,%s}购买<color='#00ff00'>%s</color>？"),myData.cost2[1].num,myData.cost2[1].item_id,DataItem.data_get[myData.item_list[1].item_id].name)
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function ()
        self.index = index
        BeginAutumnManager.Instance:send17872(id)
    end
    NoticeManager.Instance:ConfirmTips(data)

end

function DisCountShopWindow:RefreshButton()
    if BackpackManager.Instance:GetItemCount(self.refreshItemId) < 1 then
        local myItemData = ItemData.New()
        local baseData = DataItem.data_get[self.refreshItemId]
        myItemData:SetBase(baseData)
        TipsManager.Instance:ShowItem({gameObject = self.refreshBtn.gameObject,itemData = myItemData})
    else
        --if 5 - BeginAutumnManager.Instance.shopDataList.ref_num > 0 then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = string.format(TI18N("是否使用<color='#00ff00'>%s</color>个<color='#00ff00'>%s</color>刷新商店？"),1,DataItem.data_get[self.refreshItemId].name)
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function ()
                BeginAutumnManager.Instance:send17873()
            end
            NoticeManager.Instance:ConfirmTips(data)
        --else
            --BeginAutumnManager.Instance:send17873()
        --end
    end
end


 function DisCountShopWindow:CalculateTime()
    local baseTime = BaseUtils.BASE_TIME
    --self.MidleText.text = string.format("今日手动刷新次数:<color='#00ff00'>%s/%s</color>",5 - BeginAutumnManager.Instance.shopDataList.ref_num,5)
    local refreshTime = BeginAutumnManager.Instance.shopDataList.ref_time
    self.timestamp = 0
    if refreshTime > baseTime then
        self.timestamp = refreshTime - baseTime
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    self.timerId = LuaTimer.Add(0,1000,function() self:TimeLoop() end)
end

function DisCountShopWindow:TimeLoop()
    if self.timestamp > 0 then
        local h = math.floor(self.timestamp / 3600)
        local mm = math.floor((self.timestamp - (h * 3600)) / 60 )
        local ss = math.floor(self.timestamp - (h * 3600) - (mm * 60))
        self.timeText.text = string.format("<color='#00ff00'>%s时%s分%s秒</color>",h,mm,ss)
        self.timestamp = self.timestamp - 1
    else
        self:EndTime()
    end
end

function DisCountShopWindow:EndTime()
  if self.timerId ~= nil then
      LuaTimer.Delete(self.timerId)
      self.timerId = nil
  end

  BeginAutumnManager.Instance:send17871()
end

function DisCountShopWindow:UpdateDateStatus()
    if self.index ~= nil then
        self.itemList[self.index].got.gameObject:SetActive(true)
        self.itemList[self.index].button.gameObject:SetActive(false)
        -- self.itemList[i].zuanShi.gameObject:SetActive(false)
    end
end


