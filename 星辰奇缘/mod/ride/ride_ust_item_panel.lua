-- -------------------------------------
-- 坐骑使用道具补充精力值界面
-- hosr
-- -------------------------------------

RideUseItemPanel = RideUseItemPanel or BaseClass(BaseWindow)

function RideUseItemPanel:__init()
    self.windowId = WindowConfig.WinID.ridefeedwindow
    self.name = "RideUseItemPanel"
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.winLinkType = WinLinkType.Link
	self.model = RideManager.Instance.model
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
	self.resList = {
		{file = AssetConfig.rideuseitem, type = AssetType.Main},
        {file = AssetConfig.headride, type = AssetType.Dep}
	}
    self.update_ride_info = function()
        self:UpdateCurrData()
    end
    self.listener = function() self:SetData() end
end

function RideUseItemPanel:__delete()
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end

    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    RideManager.Instance.OnUpdateRide:Remove(self.update_ride_info)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.listener)
	self.valIcon.sprite = nil
	if self.buyBtn ~= nil then
		self.buyBtn:DeleteMe()
		self.buyBtn = nil
	end
end

function RideUseItemPanel:OnShow()
	self:SetData()
    self:UpdateCurrData()
end

function RideUseItemPanel:OnHide()
end

function RideUseItemPanel:Close()
    self.model:CloseRideFeedPanel()
end

function RideUseItemPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rideuseitem))
    self.gameObject.name = "RideUseItemPanel"
    -- UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    local main = self.transform:Find("Main")
    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.desc0 = main:Find("Desc0"):GetComponent(Text)
    self.desc1 = main:Find("Desc1"):GetComponent(Text)
    -- self.desc1.text = TI18N("精力值<color='#fffa76'>低于100点</color>时坐骑技能失效，<color='#fffa76'>低于10点</color>时坐骑属性失效")
    self.desc2 = main:Find("Desc2"):GetComponent(Text)
    self.name = main:Find("Name"):GetComponent(Text)

    self.head = main:Find("Head/Head")
    main:Find("Head"):GetComponent(Button).onClick:AddListener(function() self.model:InitRideSelectUI({function(data) self:ChangeRideButton(data) end}) end)

    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(main:Find("Slot").gameObject, self.slot.gameObject)

    main:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:ClickButton() end)
    self.btnTxt = main:Find("Button/Text").gameObject
    self.valTxt = main:Find("Button/Text1"):GetComponent(Text)
    self.valIcon = main:Find("Button/Text1/Icon"):GetComponent(Image)

    self.buyBtn = BuyButton.New(main:Find("BuyButton").gameObject, TI18N("补充精力"), false)
    self.buyBtn.key = "RideUseItem"
    self.buyBtn.protoId = 17003
    self.buyBtn:Show()

    self:OnShow()
    RideManager.Instance.OnUpdateRide:Add(self.update_ride_info)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.listener)
end

function RideUseItemPanel:SetData()
    if self.imgLoader == nil then
        local go = self.transform:Find("Main"):Find("Icon").gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, 90021)

	local baseId = 23555
	local has = BackpackManager.Instance:GetItemCount(baseId)
	local itemData = ItemData.New()
  	itemData:SetBase(BaseUtils.copytab(DataItem.data_get[baseId]))
    self.slot:SetAll(itemData)
    self.slot:SetNum(has, 1)
    self.name.text = ColorHelper.color_item_name(itemData.quality, itemData.name)
    self.enough = (has > 0)

    self.valTxt.gameObject:SetActive(false)
    self.btnTxt:SetActive(true)
    self.buyBtn:Layout({[23555] = {need = 1}}, function() self:ClickButton() end, function(price) self:UpdatePrice(price) end)
end

function RideUseItemPanel:ClickButton()
	if self.model.cur_ridedata.spirit >= 480 then
		NoticeManager.Instance:FloatTipsByString(TI18N("坐骑已经吃饱啦，再吃就跑不动了{face_1, 22}"))
		return
	end

	RideManager.Instance:Send17003(self.model.cur_ridedata.index)
	-- self:Close()
end

function RideUseItemPanel:UpdatePrice(price)
	if self.enough then
		return
	end

	local val = price[23555].allprice
	local assets = price[23555].assets
	self.valTxt.text = tostring(math.abs(val))
	self.valIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("Assets%s", assets))

    if self.enough then
	    self.valTxt.gameObject:SetActive(false)
	    self.btnTxt:SetActive(true)
    else
	    self.valTxt.gameObject:SetActive(true)
	    self.btnTxt:SetActive(false)
    end
end

function RideUseItemPanel:UpdateCurrData()
    BaseUtils.dump(self.model.cur_ridedata)
    self.head:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.headride, self.model.cur_ridedata.base.head_id)
    self.head:GetComponent(Image).rectTransform.sizeDelta = Vector2(54, 54)
    self.desc0.text = string.format(TI18N("<color='#ffff00'>(当前精力值%s/%s)</color>"), self.model.cur_ridedata.spirit, 500)
end

function RideUseItemPanel:ChangeRideButton(data)
    self.model.cur_ridedata = data
    self:UpdateCurrData()
end