-- @author 黄耀聪
-- @date 2016年6月13日

MergeGiftPanel = MergeGiftPanel or BaseClass(BasePanel)

function MergeGiftPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "MergeGiftPanel"

    self.resList = {
		{file = AssetConfig.mergeserver_gift_panel, type = AssetConfig.Main},
		{file = AssetConfig.dailyicon, type = AssetType.Dep},
        {file = AssetConfig.mergeserver_bg, type = AssetType.Dep},
    }
    self.setting = {
        notAutoSelect = true,
        openLevel = {0, 0},
        perWidth = 175,
        perHeight = 242,
        isVertical = false,
        spacing = 0
    }
    self.rotationCount = 0
	self.itemList = {}

	self.timeString = TI18N("活动时间:<color=#00FF00>%s~%s</color>")
    self.dateFormatString = TI18N("%s年%s月%s日")
    self.isMoving = false

    self.assetUpdateListener = function() self:UpdateAsset() end
    self.updateListener = function() self:InitUI() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MergeGiftPanel:__delete()
	local model = self.model

    self.OnHideEvent:Fire()
	model.selectObj = nil
	model.selectId = nil

    if self.rotationTimerId ~= nil then
        LuaTimer.Delete(self.rotationTimerId)
        self.rotationTimerId = nil
    end
	if self.layout ~= nil then
		self.layout:DeleteMe()
		self.layout = nil
	end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MergeGiftPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mergeserver_gift_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    t:Find("TitleArea"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.mergeserver_bg, "MergeServerBg")
    t:Find("TitleArea").gameObject:SetActive(true)

    self.titleText = t:Find("TitleArea/Title/Text"):GetComponent(Text)
    self.titleImage = t:Find("TitleArea/Title/Icon"):GetComponent(Image)
    self.descText = t:Find("TitleArea/Desc"):GetComponent(Text)
    self.timeText = t:Find("TitleArea/Time"):GetComponent(Text)

	local scroll = t:Find("ItemArea/ScrollLayer")
	self.container = scroll:Find("Container")
	self.cloner = scroll:Find("Cloner").gameObject

	local wealthArea = t:Find("WealthArea")
	self.assetValueText = wealthArea:Find("WealthBg/Value"):GetComponent(Text)
	self.assetImage = wealthArea:Find("WealthBg/Currency"):GetComponent(Image)
	self.assetDescText = wealthArea:Find("WealthBg/Desc"):GetComponent(Text)
	self.buyBtn = wealthArea:Find("Buy"):GetComponent(Button)

    self.prePageEnable = t:Find("ItemArea/PrePageBtn/Enable").gameObject
    self.prePageDisable = t:Find("ItemArea/PrePageBtn/Disable").gameObject
    self.nextPageEnable = t:Find("ItemArea/NextPageBtn/Enable").gameObject
    self.nextPageDisable = t:Find("ItemArea/NextPageBtn/Disable").gameObject

    self.buyBtn.onClick:AddListener(function() self:OnBuy() end)
    self.prePageBtn = t:Find("ItemArea/PrePageBtn"):GetComponent(Button)
    self.prePageBtn.onClick:AddListener(function()
    end)
    self.nextPageBtn = t:Find("ItemArea/NextPageBtn"):GetComponent(Button)
    self.nextPageBtn.onClick:AddListener(function()
    end)

    self.prePageBtn.gameObject:SetActive(false)
    self.nextPageBtn.gameObject:SetActive(false)
end

function MergeGiftPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MergeGiftPanel:OnBuy()
    local model = self.model
    if model.selectId ~= nil then
        CampaignManager.Instance:Send14001(model.selectId)
    end
end

function MergeGiftPanel:OnOpen()
    self:RemoveListeners()
	EventMgr.Instance:AddListener(event_name.role_asset_change, self.assetUpdateListener)
    EventMgr.Instance:AddListener(event_name.campaign_change, self.updateListener)

	self:UpdateAsset()
	self:InitUI()
end

function MergeGiftPanel:OnHide()
	local model = self.model
    self:RemoveListeners()

	model.selectAssetId = nil
	model.selectObj = nil
	model.selectBaseId = nil

    if self.rotationTimerId ~= nil then
        LuaTimer.Delete(self.rotationTimerId)
        self.rotationTimerId = nil
    end
end

function MergeGiftPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetUpdateListener)
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateListener)
end

function MergeGiftPanel:InitUI()
	local model = self.model
    local datalist = self.campaignIds
    self.titleImage.sprite = self.sprite

	if self.layout == nil then
		self.layout = LuaBoxLayout.New(self.container, {cspacing = 5, border = 5, axis = BoxLayoutAxis.X})
	end
	self.layout:ReSet()

	self.cloner:SetActive(false)

	for i,v in ipairs(datalist) do
		if self.itemList[i] == nil then
			local obj = GameObject.Instantiate(self.cloner)
			self.itemList[i] = MergeServerGiftItem.New(model, obj)
		end
		self.itemList[i]:update_my_self(v, i)
		self.layout:AddCell(self.itemList[i].gameObject)
	end

	for i=#datalist + 1, #self.itemList do
		self.itemList[i]:SetActive(false)
	end

	-- self.layout.panelRect.anchoredPosition = Vector2.zero

	local campaignData = DataCampaign.data_list[self.campaignIds[1].id]
    local mergeTime = CampaignManager.Instance.merge_srv_time
    local hour = tonumber(os.date("%H",mergeTime))*3600
    hour = hour + tonumber(os.date("%M",mergeTime))*60
    hour = hour + tonumber(os.date("%S",mergeTime))
    local cli_start_time = campaignData.cli_start_time[1]
    local cli_end_time = campaignData.cli_end_time[1]
    local beginTime = mergeTime - hour + cli_start_time[2] * 86400 + cli_start_time[3]
    local endTime = mergeTime - hour + cli_end_time[2] * 86400 + cli_end_time[3]

    local startYear = tonumber(os.date("%Y", beginTime))
    local startMonth = tonumber(os.date("%m", beginTime))
    local startDay = tonumber(os.date("%d", beginTime))
    local endYear = tonumber(os.date("%Y", endTime))
    local endMonth = tonumber(os.date("%m", endTime))
    local endDay = tonumber(os.date("%d", endTime))
	self.timeText.text = string.format(self.timeString,
							string.format(self.dateFormatString,
                                tostring(startYear),
                                tostring(startMonth),
                                tostring(startDay)),
            				string.format(self.dateFormatString,
                                tostring(endYear),
                                tostring(endMonth),
                                tostring(endDay))
							)
	self.descText.text = TI18N("<color=#7EB9F7>活动内容:</color>")..campaignData.content
    self.titleText.text = campaignData.name

    if self.rotationTimerId == nil then
        self.rotationTimerId = LuaTimer.Add(0, 50, function()
                local total = 180
                self.rotationCount = (self.rotationCount + 1) % total
                for _,v in ipairs(self.itemList) do
                    v.lightRect.rotation = Quaternion.Euler(0, 0, 360 * self.rotationCount / total)
                end
            end)
    end
end

function MergeGiftPanel:UpdateAsset()
	local model = self.model
	if model.assetIdToString == nil then
		model.assetIdToString = {}
		for k,v in pairs(KvData.assets) do
			model.assetIdToString[v] = k
		end
	end
	model.selectAssetId = model.selectAssetId or 90002
	self.assetValueText.text = tostring(RoleManager.Instance.RoleData[model.assetIdToString[model.selectAssetId]])
	self.assetImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[model.selectAssetId])
end

function MergeGiftPanel:OnDragEnd(currentPage, direction)
    if currentPage < #self.campaignIds - 2 then
        self.nextPageEnable:SetActive(true)
        self.nextPageDisable:SetActive(false)
    else
        self.nextPageEnable:SetActive(false)
        self.nextPageDisable:SetActive(true)
    end
    if currentPage > 1 then
        self.prePageEnable:SetActive(true)
        self.prePageDisable:SetActive(false)
    else
        self.prePageEnable:SetActive(false)
        self.prePageDisable:SetActive(true)
    end

    self.isMoving = false
end



