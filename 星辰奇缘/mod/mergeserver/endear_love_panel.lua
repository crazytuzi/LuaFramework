-- @author 黄耀聪
-- @date 2016年6月13日

EndearLovePanel = EndearLovePanel or BaseClass(BasePanel)

function EndearLovePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "EndearLovePanel"

    self.resList = {
		{file = AssetConfig.mergeserver_endear_panel, type = AssetType.Main},
		{file = AssetConfig.dailyicon, type = AssetType.Dep},
        {file = AssetConfig.witch_girl, type = AssetType.Main},
    }

	self.timeString = TI18N("活动时间:<color='#13fc60'>%s-%s</color>")
    self.dateFormatString = TI18N("%s月%s日")

	self.msgExt = {}
	self.updateListener = function() self:InitUI() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EndearLovePanel:__delete()
    self.OnHideEvent:Fire()
	if self.msgExt ~= nil then
		for _,v in pairs(self.msgExt) do
			if v ~= nil then
				v:DeleteMe()
			end
		end
		self.msgExt = nil
	end
    if self.descItem ~= nil then
        for _,v in pairs(self.descItem) do
            if v ~= nil and v.iconLoader ~= nil then
                v.iconLoader:DeleteMe()
            end
        end
    end
    self.witchImage.sprite = nil
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EndearLovePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mergeserver_endear_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.witchImage = t:Find("GirlArea"):GetComponent(Image)
    self.witchImage.sprite = self.assetWrapper:GetSprite(AssetConfig.witch_girl, "Witch")
	self.titleText = t:Find("TitleArea/Title/Text"):GetComponent(Text)
	self.timeText = t:Find("TitleArea/Time"):GetComponent(Text)
	self.descText = t:Find("TitleArea/Desc"):GetComponent(Text)

	local descContainer = t:Find("GiftArea/Desc")
	self.descItem = {nil, nil}
	for i=1,2 do
		local tab = {gameObject = nil, trans = nil, iconLoader = nil, descText = nil, numText = nil}
		tab.trans = descContainer:Find("Item"..i)
		tab.gameObject = tab.trans.gameObject
		tab.iconLoader = SingleIconLoader.New(tab.trans:Find("Bg/Icon").gameObject)
		tab.descText = tab.trans:Find("Desc"):GetComponent(Text)
        if tab.trans:Find("Bg/NumBg") ~= nil then
            tab.numText = tab.trans:Find("Bg/NumBg/Num"):GetComponent(Text)
        end
		self.descItem[i] = tab
	end

	self.goBuyRoseBtn = t:Find("GiftArea/Show/GoRose"):GetComponent(Button)
	self.goMerryBtn = t:Find("GiftArea/Show/GoMerry"):GetComponent(Button)

	self.goBuyRoseBtn.onClick:AddListener(function() self:OnBuy() end)
	self.goMerryBtn.onClick:AddListener(function() self.model:CloseWindow() QuestManager.Instance.model:FindNpc("44_1") end)
end

function EndearLovePanel:OnBuy()
	if self.campaignIds ~= nil and CampaignManager.Instance.campaignTab[self.campaignIds[2].id].reward_can > 0 then
    	local confirmData = NoticeConfirmData.New()
    	confirmData.content = TI18N("是否花费{assets_1, 90002, 299}购买一个<color='#ffff00'>999朵玫瑰</color>？")
    	confirmData.sureCallback = function() CampaignManager.Instance:Send14001(self.campaignIds[2].id) end
    	NoticeManager.Instance:ConfirmTips(confirmData)
	else
		NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>999朵玫瑰</color>已售罄，无法购买"))
	end
end

function EndearLovePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EndearLovePanel:OnOpen()
    self:RemoveListeners()
	EventMgr.Instance:AddListener(event_name.campaign_change, self.updateListener)

	self:InitUI()
end

function EndearLovePanel:OnHide()
    self:RemoveListeners()
end

function EndearLovePanel:RemoveListeners()
	EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateListener)
end

function EndearLovePanel:InitUI()
	local baseCampaignData = DataCampaign.data_list
	for i,v in ipairs(self.descItem) do
		local id = self.campaignIds[i].id
		if self.msgExt[i] == nil then
			self.msgExt[i] = MsgItemExt.New(v.descText, 175, 16, 18)
		end
		self.msgExt[i]:SetData(DataCampaign.data_list[id].cond_desc)
		if i == 1 then
			self.descItem[i].iconLoader:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.dailyicon, baseCampaignData[id].camp_cond_client))
		else
			self.descItem[i].iconLoader:SetSprite(SingleIconType.Item, tonumber(baseCampaignData[id].camp_cond_client))
		end
		if self.descItem[i].numText ~= nil then
			self.descItem[i].numText.text = tostring(CampaignManager.Instance.campaignTab[id].reward_can)
			if CampaignManager.Instance.campaignTab[id].reward_can == 0 then
				BaseUtils.SetGrey(self.goBuyRoseBtn.gameObject:GetComponent(Image), true)
			else
				BaseUtils.SetGrey(self.goBuyRoseBtn.gameObject:GetComponent(Image), false)
			end
		end
	end

	local campaignData = baseCampaignData[self.campaignIds[1].id]
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

    local startMonth = tonumber(os.date("%m", beginTime))
    local startDay = tonumber(os.date("%d", beginTime))
    local endMonth = tonumber(os.date("%m", endTime))
    local endDay = tonumber(os.date("%d", endTime))
	self.timeText.text = string.format(self.timeString,
            			string.format(self.dateFormatString,
							tostring(startMonth),
							tostring(startDay)),
            			string.format(self.dateFormatString,
							tostring(endMonth),
							tostring(endDay)
						))
end


