-- @author 黄耀聪
-- @date 2016年6月13日

MergeDoubleGiftPanel = MergeDoubleGiftPanel or BaseClass(BasePanel)

function MergeDoubleGiftPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "MergeDoubleGiftPanel"

    self.resList = {
		{file = AssetConfig.mergeserver_double_panel, type = AssetType.Main},
        {file = AssetConfig.dailyicon, type = AssetType.Dep},
        {file = AssetConfig.mergeserver_bg, type = AssetType.Dep},
    }

	self.rotationCount = 0
	self.itemList = {}
	self.timeString = TI18N("活动时间:<color='#13fc60'>%s-%s</color>")
    self.dateFormatString = TI18N("%s年%s月%s日")

	self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MergeDoubleGiftPanel:__delete()
    self.OnHideEvent:Fire()
	if self.layout ~= nil then
		self.layout:DeleteMe()
		self.layout = nil
	end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MergeDoubleGiftPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mergeserver_double_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.titleText = t:Find("TitleArea/Title/Text"):GetComponent(Text)
    self.titleImage = t:Find("TitleArea/Title/Icon"):GetComponent(Image)
	self.timeText = t:Find("TitleArea/Time"):GetComponent(Text)
	self.descText = t:Find("TitleArea/Desc"):GetComponent(Text)

	local scrollTrans = t:Find("ActiveArea/ScrollLayer")
	self.scrollRect = scrollTrans:GetComponent(ScrollRect)
	self.container = scrollTrans:Find("Container")
	self.cloner = scrollTrans:Find("Cloner").gameObject

    t:Find("TitleArea"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.mergeserver_bg, "MergeServerBg")
end

function MergeDoubleGiftPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MergeDoubleGiftPanel:OnOpen()
    self:RemoveListeners()

	self:InitUI()
end

function MergeDoubleGiftPanel:InitUI()
	if self.layout == nil then
		self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 5, border = 11})
	end

    self.titleImage.sprite = self.sprite
	local datalist = self.campaignIds
	self.layout:ReSet()
	for i,v in ipairs(datalist) do
		if self.itemList[i] == nil then
			local tab = {obj = nil, transform = nil, iconBox = nil, descText = nil, btn = nil, clickCallback = nil}
			tab.obj = GameObject.Instantiate(self.cloner)
			tab.obj.name = tostring(i)
			tab.trans = tab.obj.transform
			tab.iconImage = tab.trans:Find("Bg/Image"):GetComponent(Image)
			tab.descText = tab.trans:Find("Desc"):GetComponent(Text)
			tab.btn = tab.trans:Find("BtnArea/Button"):GetComponent(Button)
			tab.lightRect = tab.trans:Find("IconLight"):GetComponent(RectTransform)
			self.itemList[i] = tab
		end
		self:SetData(self.itemList[i], v, i)
		self.layout:AddCell(self.itemList[i].obj)
	end

	for i=#datalist + 1, #self.itemList do
		self.itemList[i].obj:SetActive(false)
	end
	self.cloner:SetActive(false)
	self.layout.panelRect.anchoredPosition = Vector2.zero

	if #datalist < 4 then
		self.scrollRect.movementType = 3
	else
		self.scrollRect.movementType = 1
	end

	local campaignData = DataCampaign.data_list[self.campaignIds[1].id]
	self.titleText.text = campaignData.name
	self.descText.text = TI18N("<color=#7EB9F7>活动内容:</color>")..campaignData.content

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
                            tostring(endDay)
                        ))

	-- self.timeText.text = string.format(self.timeString,
 --            string.format(self.dateFormatString, tostring(campaignData.cli_start_time[1][1]),tostring(campaignData.cli_start_time[1][2]),tostring(campaignData.cli_start_time[1][3])),
 --            string.format(self.dateFormatString, tostring(campaignData.cli_end_time[1][1]),tostring(campaignData.cli_end_time[1][2]),tostring(campaignData.cli_end_time[1][3])))

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

function MergeDoubleGiftPanel:OnHide()
    self:RemoveListeners()
    if self.rotationTimerId ~= nil then
        LuaTimer.Delete(self.rotationTimerId)
        self.rotationTimerId = nil
    end
end

function MergeDoubleGiftPanel:RemoveListeners()
end

function MergeDoubleGiftPanel:SetData(tab, data, index)
	if tab == nil then
		return
	end

	local id = data.id
	local campaignData = DataCampaign.data_list[id]

	tab.descText.text = campaignData.cond_desc
	tab.iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, campaignData.camp_cond_client)

	local splitRes = StringHelper.Split(campaignData.cond_rew, ":")
	local type = splitRes[1]
	splitRes = StringHelper.Split(splitRes[2], ",")

	if tab.clickCallback == nil then
		if type == "1" then
			local args = {}
			for i,v in pairs(splitRes) do
				if i ~= 1 then
					table.insert(args, tonumber(v))
				end
			end
			tab.clickCallback = function() WindowManager.Instance:OpenWindowById(tonumber(splitRes[1]), args) end
		elseif type == "2" then
			local tar = splitRes[1].."_"..splitRes[2]
			tab.clickCallback = function() self.model:CloseWindow() QuestManager.Instance.model:FindNpc(tar) end
		end
	end
	tab.btn.onClick:RemoveAllListeners()
	tab.btn.onClick:AddListener(tab.clickCallback)

	tab.obj:SetActive(true)
end



