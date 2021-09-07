DisCountShopWindowHalloween = DisCountShopWindowHalloween or BaseClass(BaseWindow)

function DisCountShopWindowHalloween:__init(model)
    self.model = model
    self.holdTime = 10
    -- self.cacheMode = CacheMode.Visible
    self.windowId = WindowConfig.WinID.discountshopwindow2

    self.resList = {
        {file = AssetConfig.christmasshopwindow, type = AssetType.Main}
        --,{file = AssetConfig.witch_girl,type = AssetType.Dep}
        ,{file = AssetConfig.beginautum,type = AssetType.Dep}
        ,{file = AssetConfig.campaign_title_res, type = AssetType.Dep}
        --,{file = AssetConfig.christmas_top_bg, type = AssetType.Main}
        ,{file = AssetConfig.Newyeardiscount_top_bg, type = AssetType.Main}
        ,{file = AssetConfig.christmas_ghost, type = AssetType.Main}
        ,{file = AssetConfig.christmas_tree, type = AssetType.Main}
        ,{file = AssetConfig.textures_campaign, type = AssetType.Dep}
        --,{file = AssetConfig.halloween_icon, type = AssetType.Dep}
        ,{file = AssetConfig.halloween_textures, type = AssetType.Dep}
        ,{file = AssetConfig.worldlevgiftitem1,type = AssetType.Dep}
        ,{file = AssetConfig.christmas_textures,type = AssetType.Dep}
        ,{file = AssetConfig.christmas_icon, type = AssetType.Dep}
    }

    self.leftNumList = {}

    self.campId = nil

    self.hallowmaxListener = function() self:OnHallowmaxChange() end
    self.updateListener = function() self:UpdateDataList() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.itemList = {}
    self.extra = {inbag = false, nobutton = true}
end

function DisCountShopWindowHalloween:__delete()
    self.OnHideEvent:Fire()

    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if self.luaGrid ~= nil then
        self.luaGrid:DeleteMe()
        self.luaGrid = nil
    end

    if self.hallowmaxLoader ~= nil then
        self.hallowmaxLoader:DeleteMe()
        self.hallowmaxLoader = nil
    end

    if self.itemList ~= nil then
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

            if v.btnExt ~= nil then
                v.btnExt:DeleteMe()
            end
            if v.effect ~= nil then
                v.effect.sprite = nil
                v.effect = nil
            end

        end
        self.itemList = nil
    end
end

function DisCountShopWindowHalloween:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.christmasshopwindow))
    self.gameObject.name = "DisCountShopWindowHalloween"
    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)


    self.transform = self.gameObject.transform
    self.mainPanel = self.transform:Find("MainCon")

    UIUtils.AddBigbg(self.transform:Find("MainCon/Bg/BigTopBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.Newyeardiscount_top_bg)))
    -- UIUtils.AddBigbg(self.transform:Find("MainCon/Ghost"), GameObject.Instantiate(self:GetPrefab(AssetConfig.christmas_ghost)))
    -- UIUtils.AddBigbg(self.transform:Find("MainCon/ChristmasTree"), GameObject.Instantiate(self:GetPrefab(AssetConfig.christmas_tree)))

    self.closeBtn = self.mainPanel:Find("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClose() end)
    --self.changeBtnImg.sprite = self.assetWrapper:GetSprite(AssetConfig.christmas_textures,self.btnImg[self.index])


    -- self.titlebg = self.mainPanel:Find("Bg/TitleBg"):GetComponent(Image)
    -- self.titlebg.sprite = self.assetWrapper:GetSprite(AssetConfig.christmas_textures,"TitleTop2")

    self.title = self.mainPanel:Find("Bg/TitleI18N"):GetComponent(Image)
    self.title.sprite = self.assetWrapper:GetSprite(AssetConfig.christmas_textures,"NewyeartitleI18N")

    self.cloner =  self.mainPanel:Find("Cloner")
    self.cloner.gameObject:SetActive(false)
    self.container = self.mainPanel:Find("Container")

    self.dataText = self.mainPanel:Find("Bg/TmeBg/Text"):GetComponent(Text)

    -- self.grildBg = self.mainPanel:Find("Grild"):GetComponent(Image)
    -- self.grildBg.sprite = self.assetWrapper:GetSprite(AssetConfig.witch_girl,"Witch")
    -- self.grildBg.gameObject:SetActive(true)
    -- self.grildBg.gameObject:AddComponent(GraphicRaycaster).ignoreReversedGraphics = true

    self.assetsText = self.mainPanel:Find("Asset/Text"):GetComponent(Text)
    self.hallowmaxLoader = SingleIconLoader.New(self.mainPanel:Find("Asset/Image").gameObject)
    self.hallowmaxLoader:SetSprite(SingleIconType.Item, DataItem.data_get[KvData.assets.lucky_knot].icon)

    self.setting = {
        column = 3
        ,cspacing = 0
        ,rspacing = 0
        ,cellSizeX = 167
        ,cellSizeY = 203
    }
    self.luaGrid = LuaGridLayout.New(self.container,self.setting)

    self.assetWayBtn = self.mainPanel:Find("Asset/Way"):GetComponent(Button)
    self.assetWayBtn.onClick:AddListener(function() self:ShowHallowmasWay() end)

    self.ghost = self.mainPanel:Find("Ghost").gameObject
    self.tree = self.mainPanel:Find("ChristmasTree").gameObject

    --self.OnOpenEvent:Fire()
end

function DisCountShopWindowHalloween:ShowHallowmasWay()
    TipsManager.Instance:ShowItem({gameObject = self.assetWayBtn.gameObject, itemData = DataItem.data_get[KvData.assets.lucky_knot]})
end

function DisCountShopWindowHalloween:OnInitCompleted()
    self.OnOpenEvent:Fire()
    CampaignManager.Instance.DiscountShop_show = false
    CampaignManager.Instance.model:CheckActiveRed(self.campId)
end

function DisCountShopWindowHalloween:OnOpen()
    self:AddListeners()
    BeginAutumnManager.Instance:CheckRedPoint()
    self.campId = self.openArgs[1]

    self.dataText.text = DataCampaign.data_list[self.campId].timestr
    --string.format("活动时间：%s月%s日-%s月%s日",DataCampaign.data_list[self.campId].cli_start_time[1][2],DataCampaign.data_list[self.campId].cli_start_time[1][3],DataCampaign.data_list[self.campId].cli_end_time[1][2],DataCampaign.data_list[self.campId].cli_end_time[1][3])

    if self.campId == 833 or self.campId == 835 then
        self.ghost:SetActive(false)
        self.tree:SetActive(false)
    elseif self.campId == 827 then
        self.ghost:SetActive(true)
        self.tree:SetActive(true)
    end

    self:OnHallowmaxChange()
    self:UpdateDataList()

    if self.timerId == nil then
        local temp = 0
        self.timerId = LuaTimer.Add(0, 22, function() self:Float(temp) temp = temp + 1  end)
    end
end


function DisCountShopWindowHalloween:OnHide()
    BeginAutumnManager.Instance.isOpeningShop = false
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

end

function DisCountShopWindowHalloween:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.hallowmaxListener)
    ShopManager.Instance.onUpdateBuyPanel:RemoveListener(self.updateListener)
end

function DisCountShopWindowHalloween:AddListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.hallowmaxListener)
    ShopManager.Instance.onUpdateBuyPanel:AddListener(self.updateListener)
end

function DisCountShopWindowHalloween:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function DisCountShopWindowHalloween:UpdateDataList()
    self.luaGrid:ReSet()
    --BaseUtils.dump(ShopManager.Instance.model.datalist[2][31],"kokokokkookkokok")
    for i,v in ipairs(ShopManager.Instance.model.datalist[2][31] or {}) do
        local item = self.itemList[i]
        if item == nil then
            item = {}
            item.gameObject = GameObject.Instantiate(self.cloner.gameObject)
            item.transform = item.gameObject.transform
            local t = item.gameObject.transform

            -- item.itemSlot = ItemSlot.New()
            item.button = t:Find("Button"):GetComponent(Button)
            item.buttonImage = t:Find("Button"):GetComponent(Image)
            item.btnExt = MsgItemExt.New(t:Find("Button/Text"):GetComponent(Text), 100, 18, 21)
            item.nameText = t:Find("Name"):GetComponent(Text)
            item.got = t:Find("Got").gameObject
            item.effect = t:Find("Effect"):GetComponent(Image)
            item.effect.sprite = self.assetWrapper:GetSprite(AssetConfig.worldlevgiftitem1, "worldlevitemlight1")

            item.imgLoader = SingleIconLoader.New(t:Find("Item").gameObject)
            --item.EffectImgLoader = SingleIconLoader.New(t:Find("Effect").gameObject)

            t:Find("Item"):GetComponent(Button).onClick:AddListener(function() if item.base_id ~= nil then TipsManager.Instance:ShowItem({gameObject = item.imgLoader.gameObject.gameObject, itemData = DataItem.data_get[item.base_id]}) end end)

            self.itemList[i] = item

            item.button.onClick:AddListener(function() self:Buy(item.data, 1) end)
        end
        self.luaGrid:AddCell(item.gameObject)

        item.base_id = v.base_id
        item.data = v

        local sprite = self.assetWrapper:GetSprite(AssetConfig.christmas_icon, tostring(i))
        if sprite == nil then
            sprite = self.assetWrapper:GetSprite(AssetConfig.christmas_icon, string.format("%s_%s", i, RoleManager.Instance.RoleData.sex))
        end
        if sprite ~= nil then
            item.imgLoader:SetOtherSprite(sprite)
        end
        item.nameText.text = DataItem.data_get[v.base_id].name


        if i < 3 then
            if i == 1 then
                item.imgLoader.gameObject.transform.sizeDelta = Vector2(110, 110)
            else
                item.imgLoader.gameObject.transform.sizeDelta = Vector2(90, 90)
            end
        else
            item.imgLoader.gameObject.transform.sizeDelta = Vector2(80, 80)
        end

        item.button.gameObject:SetActive(true)
        item.got.gameObject:SetActive(false)

        -- 可售数目
        local privilegeNum = 0
        local buyLimit = 0
        if v ~= nil and v.privilege_lev ~= nil and (PrivilegeManager.Instance.lev or 0) >= v.privilege_lev then
            local privilege_lev = PrivilegeManager.Instance.lev
            for i,v in ipairs(v.privilege_role) do
                if v.p_lev == privilege_lev then
                    privilegeNum = v.p_num
                end
            end
        end
        if v.limit_role ~= nil and v.limit_role ~= -1 then
            buyLimit = v.limit_role + privilegeNum
        end

        if ShopManager.Instance.model.hasBuyList ~= nil and ShopManager.Instance.model.hasBuyList[v.id] ~= nil and ShopManager.Instance.model.hasBuyList[v.id] >= buyLimit then
            self.leftNumList[v.id] = 0
            item.btnExt:SetData(TI18N("已兑换"))
            item.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            item.btnExt.contentTxt.color = ColorHelper.DefaultButton4
        else
            self.leftNumList[v.id] = 1
            item.btnExt:SetData(string.format("%s{assets_2,%s}", math.ceil(v.price * v.discount / 1000), KvData.assets[v.assets_type]))
            item.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            item.btnExt.contentTxt.color = ColorHelper.DefaultButton3
        end

        local size = item.btnExt.contentTrans.sizeDelta
        item.btnExt.contentTrans.anchoredPosition = Vector2(-size.x / 2, size.y / 2)

        if (self.campId == 917) and i == 1 then
            local t = item.gameObject.transform
            local tt = t:Find("Button/Text")
            tt:GetComponent(RectTransform).anchoredPosition = Vector2(-32, 10)
            tt:GetComponent(RectTransform).sizeDelta = Vector2(80, 20)

            t:Find("Button/Text/Image").gameObject:SetActive(false)
            item.nameText.text = TI18N("梦幻物语坐骑")
            t:Find("Item"):GetComponent(Button).onClick:RemoveAllListeners()
            t:Find("Item"):GetComponent(Button).onClick:AddListener(function ()
                TipsManager.Instance:ShowItem({gameObject = item.imgLoader.gameObject.gameObject, itemData = DataItem.data_get[20359]})
            end)
            t:Find("Item"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.christmas_icon, "ride")
            t:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
            if #RideManager.Instance.model.myRideData.mount_list == 0 or (#RideManager.Instance.model.myRideData.mount_list == 1 and RideManager.Instance.model.myRideData.mount_list[1].live_status ~= 3) or (#RideManager.Instance.model.myRideData.mount_list == 2 and RideManager.Instance.model.myRideData.mount_list[1].live_status ~= 3 and RideManager.Instance.model.myRideData.mount_list[2].live_status ~= 3)
            then
                tt:GetComponent(Text).text = TI18N("获取途径")
                t:Find("Button"):GetComponent(Button).onClick:AddListener(function ()
                    local base_data = DataItem.data_get[29971]
                    local info = { itemData = base_data, gameObject = t:Find("Button").gameObject }
                    TipsManager.Instance:ShowItem(info)
                    NoticeManager.Instance:FloatTipsByString(TI18N("拥有坐骑后可进行幻化{face_1,3}"))
                end)
            else
                tt:GetComponent(Text).text = TI18N("查看详情")
                t:Find("Button"):GetComponent(Button).onClick:AddListener(function()
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow,{5,2038,2038})
                end)
            end
        end

        -- if v.isbuy == 0 then
        --     item.got:SetActive(false)
        --     item.button.gameObject:SetActive(true)
        -- else
        --     item.got:SetActive(true)
        --     item.button.gameObject:SetActive(false)
        -- end
    end

    -- self:CalculateTime()
end

function DisCountShopWindowHalloween:ItemButton(id,index,myData)
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


 function DisCountShopWindowHalloween:CalculateTime()
    local baseTime = BaseUtils.BASE_TIME
        self.lastText.text = string.format("当天剩余次数:<color='#00ff00'>%s/%s</color>",5 - BeginAutumnManager.Instance.shopDataList.ref_num,5)
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

function DisCountShopWindowHalloween:TimeLoop()
    if self.timestamp > 0 then
        local h = math.floor(self.timestamp / 3600)
        local mm = math.floor((self.timestamp - (h * 3600)) / 60 )
        local ss = math.floor(self.timestamp - (h * 3600) - (mm * 60))
        self.timeText.text = string.format("<color='#00ff00'>%s时%s分%s秒后自动刷新</color>",h,mm,ss)
        self.timestamp = self.timestamp - 1
    else
        self:EndTime()
    end
end

function DisCountShopWindowHalloween:EndTime()
  if self.timerId ~= nil then
      LuaTimer.Delete(self.timerId)
      self.timerId = nil
  end

  BeginAutumnManager.Instance:send17871()
end

function DisCountShopWindowHalloween:OnHallowmaxChange()
    self.assetsText.text = BackpackManager.Instance:GetItemCount(KvData.assets.lucky_knot)
end

function DisCountShopWindowHalloween:Buy(data, num)
    if self.leftNumList[data.id] == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("此商品已被兑换完了，可以兑换其他商品哟~{face_1,9}"))
    else
        if BackpackManager.Instance:GetItemCount(KvData.assets.lucky_knot) >= math.ceil(data.price * data.discount / 1000) then
            local noticeData = NoticeConfirmData.New()
            noticeData.content = string.format(TI18N("是否确认花费%s{assets_2, %s}兑换<color='#ffff00'>%s</color>？"), math.ceil(data.price * data.discount / 1000), KvData.assets.lucky_knot, DataItem.data_get[data.base_id].name)
            noticeData.sureCallback = function() ShopManager.Instance:send11303(data.id, num or 1) end
            noticeData.sureLabel = TI18N("确 定")
            NoticeManager.Instance:ConfirmTips(noticeData)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("道具不足无法进行兑换，快去参与活动获得吉祥如意结吧！"))
            ExchangeManager.Instance:On9908({enum = KvData.assets.lucky_knot})
        end
    end
end

function DisCountShopWindowHalloween:Float(stemp)
    stemp = stemp or 0
    for _,item in pairs(self.itemList) do
        item.imgLoader.gameObject.transform.anchoredPosition = Vector2(0, 10 + 8 * math.sin(stemp * math.pi / 70, 0))
    end
end
