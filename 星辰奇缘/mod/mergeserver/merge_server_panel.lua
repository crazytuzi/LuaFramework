-- @author 黄耀聪
-- @date 2016年6月13日

MergeServerPanel = MergeServerPanel or BaseClass(BasePanel)

function MergeServerPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "MergeServerPanel"

	self.mgr = MergeServerManager.Instance

    self.path = "prefabs/ui/springfestival/springfestivalpanel.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
		{file = AssetConfig.may_textures, type = AssetType.Dep},
		{file = AssetConfig.springfestival_texture, type = AssetType.Dep},
		{file = AssetConfig.mergeserver_textures, type = AssetType.Dep},
		{file = AssetConfig.newmoon_textures, type = AssetType.Dep},
    }

	self.panelList = {}
	self.panelIdList = {}

	self.checkRedListener = function() self:CheckRedPoint() end
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MergeServerPanel:__delete()
    self.OnHideEvent:Fire()
	if self.tree ~= nil then
		self.tree:DeleteMe()
		self.tree = nil
	end
	if self.panelIdList ~= nil then
		for k,v in pairs(self.panelIdList) do
			if v ~= nil then
				v:DeleteMe()
			end
		end
		self.panelIdList = nil
	end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MergeServerPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

	self.leftContainer = self.transform:Find("Main/Left/Container").gameObject
    self.baseItem = self.transform:Find("Main/Left/BaseItem").gameObject

    self.rightContainer = self.transform:Find("Main/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index) end)
    self.tree.canRepeat = false
end

function MergeServerPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MergeServerPanel:OnOpen()
    self:RemoveListeners()
	self.mgr.onUpdateRed:AddListener(self.checkRedListener)

	local type = self.model.currentSub

	self:InitTreeInfo()
	self.tree:SetData(self.treeInfo)
	local pos = {1, 1}
	if type ~= nil then
		pos = self.campaignIdToPos[type]
		if pos == nil then
			pos = {1, 1}
		end
	end

	BaseUtils.dump(CampaignManager.Instance.campaignTree)

	self.tree:ClickMain(pos[1], 1)
	self.mgr.onUpdateRed:Fire()
end

function MergeServerPanel:OnHide()
    self:RemoveListeners()
end

function MergeServerPanel:RemoveListeners()
	self.mgr.onUpdateRed:RemoveListener(self.checkRedListener)
end

function MergeServerPanel:InitTreeInfo()
	local baseCampaignData = DataCampaign.data_list
	local mergeserverData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.MergeServer]

	local infoTab = {}
	local c = 1
	if mergeserverData ~= nil then
		for index,v in pairs(mergeserverData) do
			if index ~= "count" then
				if infoTab[c] == nil then infoTab[c] = {height = 60, subs = {}, type = v.index, datalist = {}} c = c + 1 end
				local main = infoTab[c - 1]
				main.datalist = v.sub
				main.label = baseCampaignData[v.sub[1].id].name
				if v.index == CampaignEumn.MergeServerType.Double then
					main.sprite = self.assetWrapper:GetSprite(AssetConfig.mergeserver_textures, "I18N_Double")
				elseif v.index == CampaignEumn.MergeServerType.Endear then
					main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "WithYou")
				elseif v.index == CampaignEumn.MergeServerType.Gift then
					main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "QingmingIcon4")
				elseif v.index == CampaignEumn.MergeServerType.Login then
					main.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Clock")
				elseif v.index == CampaignEumn.MergeServerType.First then
					main.sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, "QingmingIcon4")
				elseif v.index == CampaignEumn.MergeServerType.Pub then
					main.sprite = self.assetWrapper:GetSprite(AssetConfig.newmoon_textures, "Icon2")
				end
			end
		end
	end

	self.treeInfo = infoTab
	self.campaignIdToPos = {}
	for index,v in pairs(infoTab) do
		for _,sub in pairs(v.datalist) do
			self.campaignIdToPos[sub.id] = index
		end
	end
end

function MergeServerPanel:CheckRedPoint()
	local campaignMgr = CampaignManager.Instance
	local mergeserverData = campaignMgr.campaignTree[CampaignEumn.Type.MergeServer]

	if mergeserverData ~= nil then
		for index,v in pairs(mergeserverData) do
			if index ~= "count" then
				local mainRed = false
				local posMain = nil
				for _,sub in pairs(v.sub) do
					local pos = self.campaignIdToPos[sub.id]
					posMain = pos
					mainRed = mainRed or (campaignMgr.redPointDic[sub.id] == true)
				end
				if posMain ~= nil then
					self.tree:RedMain(posMain, mainRed)
				end
			end
		end
	end
end

function MergeServerPanel:ChangeTab(index, subIndex)
	local model = self.model
	if self.lastIndex ~= nil and self.lastGroupIndex ~= nil then
		if self.panelList[self.lastIndex] ~= nil and self.panelList[self.lastIndex][self.lastGroupIndex] then
			self.panelList[self.lastIndex][self.lastGroupIndex]:Hiden()
		end
	end

	subIndex = subIndex or 1
	self.panelList[index] = self.panelList[index] or {}
	local panel = self.panelList[index][subIndex]
	local type = self.treeInfo[index].type
	local treeInfoId = self.treeInfo[index].datalist[subIndex]
	local panelId = self.panelIdList[treeInfoId.id]

	if panelId == nil then
		if type == CampaignEumn.MergeServerType.Double then					-- 双倍免费领
			panelId = MergeDoubleGiftPanel.New(model, self.rightContainer)
		elseif type == CampaignEumn.MergeServerType.Endear then				-- 亲密不打折
			panelId = EndearLovePanel.New(model, self.rightContainer)
		elseif type == CampaignEumn.MergeServerType.Gift then				-- 合服有好礼
			panelId = MergeGiftPanel.New(model, self.rightContainer)
		elseif type == CampaignEumn.MergeServerType.Login then				-- 登录送好礼
			panelId = MergeServerTotalLogin.New(model, self.rightContainer)
		elseif type == CampaignEumn.MergeServerType.First then				-- 欢乐首充
			panelId = MergeServerFirstCharge.New(model, self.rightContainer)
		elseif type == CampaignEumn.MergeServerType.Pub  then
			panelId = BigSummerPubPanel.New(self.model,self.rightContainer)
		end

		self.panelIdList[treeInfoId.id] = panelId
	end

	if panel == nil then
		panel = panelId
		self.panelList[index][subIndex] = panelId
	end

	self.lastIndex = index
	self.lastGroupIndex = subIndex

	if panel ~= nil then
		panel.campaignIds = self.treeInfo[index].datalist
		panel.sprite = self.treeInfo[index].sprite
		panel:Show()
	end
end

