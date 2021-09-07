-- @author 黄耀聪
-- @date 2016年7月22日

AuctionPanel = AuctionPanel or BaseClass(BasePanel)

function AuctionPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "AuctionPanel"

    self.resList = {
        {file = AssetConfig.auction_panel, type = AssetType.Main},
        {file = AssetConfig.auction_textures, type = AssetType.Dep},
        {file = AssetConfig.shop_textures, type = AssetType.Dep},
        {file  =  AssetConfig.wingsbookbg, type  =  AssetType.Dep},
    }

    self.tabData = {
        {name = TI18N("竞拍商品"), icon = "All"},
        {name = TI18N("我的竞价"), icon = "My"},
    }
    self.panelObjList = {}
    self.panelList = {}

    self.assetListener = function() self:AssetListener() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function AuctionPanel:__delete()
    self.OnHideEvent:Fire()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = nil
        self.panelObjList  = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function AuctionPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.auction_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.tabCloner = t:Find("Button").gameObject
    -- self.tabCloner:GetComponent(RectTransform).pivot = Vector2(0.5, 0.5)
    self.tabContainer = t:Find("TopTabButtonGroup")
    self.panelObjList[1] = t:Find("GoodsPanel").gameObject
    self.panelObjList[2] = t:Find("MyAuction").gameObject

    self.girl = t:Find("InfoArea/GoodsTips/GirlGuide").gameObject
    self.goods = t:Find("InfoArea/GoodsTips/GoodsInfo").gameObject
    self.fashion = t:Find("InfoArea/GoodsTips/FashionShow").gameObject
    self.fashion.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")

    self.nameText = t:Find("InfoArea/GoodsTips/GoodsInfo/Name"):GetComponent(Text)
    self.descText = t:Find("InfoArea/GoodsTips/GoodsInfo/Describe"):GetComponent(Text)
    self.descExt = MsgItemExt.New(self.descText, 218, 16, 20)

    self.ownText = t:Find("InfoArea/BuyArea/OwnAsset/AssetBg/Asset"):GetComponent(Text)
    self.buyText = t:Find("InfoArea/BuyArea/BuyPrice/PriceBg/Price"):GetComponent(Text)

    self.timeText = t:Find("Text"):GetComponent(Text)
    self.timeRect = t:Find("Text"):GetComponent(RectTransform)

    self.auctionBtn = t:Find("InfoArea/BuyArea/BtnArea/Button"):GetComponent(Button)

    for i,v in ipairs(self.tabData) do
        local obj = GameObject.Instantiate(self.tabCloner)
        obj.name = tostring(i)
        obj.transform:SetParent(self.tabContainer)
        obj.transform.localScale = Vector3.one
        if v.icon ~= nil then
            obj.transform:Find("CenterText").gameObject:SetActive(false)
            obj.transform:Find("Text").gameObject:SetActive(true)
            obj.transform:Find("Icon").gameObject:SetActive(true)
            obj.transform:Find("Text"):GetComponent(Text).text = v.name
            obj.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.auction_textures, v.icon)
        else
            obj.transform:Find("Text").gameObject:SetActive(false)
            obj.transform:Find("CenterText").gameObject:SetActive(true)
            obj.transform:Find("Icon").gameObject:SetActive(false)
            obj.transform:Find("CenterText"):GetComponent(Text).text = v.name
        end
    end

    self.tabCloner:SetActive(false)

    self.setting = {
        noCheckRepeat = true,
        notAutoSelect = true,
        perWidth = 122,
        perHeight = 38,
        isVertical = false
    }
    self.tabGroup = TabGroup.New(self.tabContainer, function(index) self:ChangeTab(index) end, self.setting)
    self.tabGroup:Layout()

    for _,v in pairs(self.panelObjList) do
        v:SetActive(false)
    end

    self.auctionBtn.onClick:AddListener(function() if self.model.selectIdx ~= nil then self.model:OpenOperation() end end)
end

function AuctionPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function AuctionPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.assetListener)
    self.timerId = LuaTimer.Add(0, 10 * 1000, function() self:CalculateTime() end)

    self.openArgs = self.openArgs or {1}

    self.tabGroup:ChangeTab(self.openArgs[1])
    self:AssetListener()
end

function AuctionPanel:OnHide()
    self:RemoveListeners()
end

function AuctionPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetListener)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function AuctionPanel:ChangeTab(index)
    local model = self.model
    if self.lastIndex ~= nil then
        if self.panelList[self.lastIndex] ~= nil then
            self.panelList[self.lastIndex]:Hiden()
        end
    end

    local panel = self.panelList[index]

    if panel == nil then
        if index == 1 then  -- 拍卖界面
            panel = AuctionListPanel.New(model,self.panelObjList[index], function(idx) self:OnSelect(idx) end)
        elseif index == 2 then  -- 我的竞拍（我的关注）
            panel = AuctionMyPanel.New(model,self.panelObjList[index], function(idx) self:OnSelectMy(idx) end)
        end
        self.panelList[index] = panel
    end

    self.lastIndex = index
    if panel ~= nil then
        panel:Show(self.openArgs)
    end
end

function AuctionPanel:OnSelect(idx)
    if idx == nil then
        self.girl:SetActive(true)
        self.fashion:SetActive(false)
        self.goods:SetActive(false)
        self.buyText.text = "0"
        return
    end

    local model = self.model
    local protoData = model.datalist[idx]
    local basedata = DataItem.data_get[protoData.item_id]
    if model.selectIdx ~= nil and model.datalist[model.selectIdx].item ~= nil then
        model.datalist[model.selectIdx].item:Select(false)
    end
    model.selectIdx = idx

    self.girl:SetActive(false)
    self.fashion:SetActive(false)
    self.goods:SetActive(true)
    self.buyText.text = tostring(model.datalist[model.selectIdx].gold)
    self.nameText.text = basedata.name
    self.descExt:SetData(basedata.desc)
    model.datalist[model.selectIdx].item:Select(true)
end

function AuctionPanel:AssetListener()
    self.ownText.text = tostring(RoleManager.Instance.RoleData.gold)
end

function AuctionPanel:OnSelectMy(idx)
    if idx == nil then
        self.girl:SetActive(true)
        self.fashion:SetActive(false)
        self.goods:SetActive(false)
        self.buyText.text = "0"
        return
    end

    local model = self.model
    local protoData = model.mylist[idx]
    local basedata = DataItem.data_get[protoData.item_id]
    model.selectIdx = idx

    self.girl:SetActive(false)
    self.fashion:SetActive(false)
    self.goods:SetActive(true)
    self.buyText.text = tostring(model.mylist[model.selectIdx].gold)

    self.nameText.text = basedata.name
    self.descExt:SetData(basedata.desc)
    -- model.mylist[model.selectIdx].item:Select(true)
end

function AuctionPanel:CalculateTime()
    local model = self.model

    if model.timeList == nil or #model.timeList == 0 then
        self.timeText.text = ""
        return
    end

    local format1 = TI18N("%s月%s~%s日每日%s点开拍")
    local format2 = TI18N("%s月%s日~%s月%s日每日%s点开拍")
    local format3 = TI18N("%s年%s月%s日~%s年%s月%s日每日%s点开拍")

    local y1 = tonumber(os.date("%Y", model.timeList[1].start_time))
    local m1 = tonumber(os.date("%m", model.timeList[1].start_time))
    local d1 = tonumber(os.date("%d", model.timeList[1].start_time))
    local y2 = tonumber(os.date("%Y", model.timeList[#model.timeList].start_time))
    local m2 = tonumber(os.date("%m", model.timeList[#model.timeList].start_time))
    local d2 = tonumber(os.date("%d", model.timeList[#model.timeList].start_time))

    local h = tonumber(os.date("%H", model.timeList[1].start_time))

    if y1 == y2 then
        if m1 == m2 then
            self.timeText.text = string.format(format1, tostring(m1), tostring(d1), tostring(d2), tostring(h))
        else
            self.timeText.text = string.format(format2, tostring(m1), tostring(d1), tostring(m2), tostring(d2), tostring(h))
        end
    else
        self.timeText.text = string.format(format3, tostring(y1), tostring(m1), tostring(d1), tostring(y2), tostring(m2), tostring(d2), tostring(h))
    end

    local height = self.timeRect.sizeDelta.y
    self.timeRect.sizeDelta = Vector2(math.ceil(self.timeText.preferredWidth), height)
end
