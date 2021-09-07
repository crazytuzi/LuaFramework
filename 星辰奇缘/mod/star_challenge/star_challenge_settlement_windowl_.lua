-- 龙王 
-- ljh 20170725
StarChallengeSettlementWindow = StarChallengeSettlementWindow or BaseClass(BasePanel)

function StarChallengeSettlementWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.starchallengesettlementwindow

    self.resList = {
        {file = AssetConfig.starchallengesettlementwindow, type = AssetType.Main}
        ,{file = AssetConfig.starchallenge_textures, type = AssetType.Dep}
        ,{file = AssetConfig.levelbreakeffect1, type = AssetType.Dep}
        ,{file = AssetConfig.levelbreakeffect2, type = AssetType.Dep}
    }

    -----------------------------------------------------------
    
    self.itemSlotList = {}
    self.itemSlotList2 = {}

    -----------------------------------------------------------
    
    StarChallengeManager.Instance:Send20209()

    -----------------------------------------------------------

    self.updateListener = function() self:UpdateItem() end

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function StarChallengeSettlementWindow:__delete()
    self.OnHideEvent:Fire()

    if self.rotateId ~= nil then
        LuaTimer.Delete(self.rotateId)
    end

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    for i=1, #self.itemSlotList do
		self.itemSlotList[i]:DeleteMe()
		self.itemSlotList[i] = nil
    end

    for i=1, #self.itemSlotList2 do
	    self.itemSlotList2[i]:DeleteMe()
	    self.itemSlotList2[i] = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function StarChallengeSettlementWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.starchallengesettlementwindow))
    self.gameObject.name = "StarChallengeSettlementWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    	
    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)
    self.transform:FindChild("Main"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.mainTransform = self.transform:FindChild("Main")

    self.RoleBg1 = self.mainTransform:Find("RoleBg1")
    self.RoleBg2 = self.mainTransform:Find("RoleBg2")
    for i=1,2 do
        self.RoleBg1:FindChild("Image"..i):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.levelbreakeffect1, "LevelBreakEffect1")
    end

    for i=1,4 do
        self.RoleBg2:FindChild("Image"..i):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.levelbreakeffect2, "LevelBreakEffect2")
    end

    local setting = {
        name = "PetView"
        ,orthographicSize = 0.7
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }

    self.previewComposite = PreviewComposite.New(nil, setting, {})
    self.previewComposite:BuildCamera(true)
    self.rawImage = self.previewComposite.rawImage
    self.rawImage.transform:SetParent(self.mainTransform)
    self.rawImage.gameObject:SetActive(false)
    self.modelPreview = self.mainTransform:FindChild("Preview")

    self.myRankText = self.mainTransform:Find("MyRankText"):GetComponent(Text)
    self.myRankInFirendText = self.mainTransform:Find("MyRankInFirendText"):GetComponent(Text)
    self.maxWaveText = self.mainTransform:Find("MaxWaveText"):GetComponent(Text)
    self.friendText = self.mainTransform:Find("FriendText"):GetComponent(Text)
    self.text2 = self.mainTransform:Find("Text2"):GetComponent(Text)
    self.text3 = self.mainTransform:Find("Text3"):GetComponent(Text)

    self.itemPanel = self.mainTransform:Find("ItemPanel")
    self.itemPanel2 = self.mainTransform:Find("ItemPanel2")
    self.noWaveText = self.mainTransform:Find("NoWaveText")
    self.allCleanText = self.mainTransform:Find("AllCleanText")

    self.itemSlotList = {}
    for i=1, 3 do
	    local itemSlot = ItemSlot.New()
	    UIUtils.AddUIChild(self.itemPanel:GetChild(i-1).gameObject, itemSlot.gameObject)
	    table.insert(self.itemSlotList, itemSlot)
	end

    self.itemSlotList2 = {}
    for i=1, 3 do
	    local itemSlot = ItemSlot.New()
	    UIUtils.AddUIChild(self.itemPanel2:GetChild(i-1).gameObject, itemSlot.gameObject)
	    table.insert(self.itemSlotList2, itemSlot)
	end

    self.moreTextTransform = self.mainTransform:FindChild("MoreText")
    self.moreTextTransform:GetComponent(Button).onClick:AddListener(function() self:OpenRank() end)
end

function StarChallengeSettlementWindow:OnClickClose()
    -- WindowManager.Instance:CloseWindow(self)
    self.model:CloseStarChallengeSettlementWindow()
end

function StarChallengeSettlementWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function StarChallengeSettlementWindow:OnOpen()
    self:Update()

    StarChallengeManager.Instance.OnUpdateList:RemoveListener(self.updateListener)
    StarChallengeManager.Instance.OnUpdateList:AddListener(self.updateListener)
end

function StarChallengeSettlementWindow:OnHide()
    StarChallengeManager.Instance.OnUpdateList:RemoveListener(self.updateListener)
end

function StarChallengeSettlementWindow:Update()
	self:UpdateModel()
    self:UpdateItem()

    self:showBgAni()
end

function StarChallengeSettlementWindow:UpdateModel()
    local llooks = {}
    local mySceneData = SceneManager.Instance:MyData()
    if mySceneData ~= nil then
        llooks = mySceneData.looks
    end
	local roledata = RoleManager.Instance.RoleData
    local data = {type = PreViewType.Role, classes = roledata.classes, sex = roledata.sex, looks = llooks}
    if self.modelData ~= nil and BaseUtils.sametab(data, self.modelData) then
        return
    end

    self.previewComposite:Reload(data, function(composite) self:PreviewLoaded(composite) end)
    self.modelData = data
end

function StarChallengeSettlementWindow:PreviewLoaded(composite) 
    local rawImage = composite.rawImage
    rawImage.gameObject:SetActive(true)
    rawImage.transform:SetParent(self.modelPreview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.identity
    -- composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
end

function StarChallengeSettlementWindow:UpdateItem()
    local rank_list = self.model.rank_list
    -- if #rank_list == 0 then
    -- 	return
    -- end
    local friendOnlyRankList = self.model:GetFriendOnlyRankList(self.model.rank_list)

    -- 排名
    local num = 0
    local roleData = RoleManager.Instance.RoleData
    for i=1, #rank_list do
        local data = rank_list[i]
        if data.rid == roleData.id and data.platform == roleData.platform and data.zone_id == roleData.zone_id then
        	num = i
        end
    end
    if num == 0 then
    	self.myRankText.text = TI18N("未上榜")
    else
	    self.myRankText.text = string.format(TI18N("第%s名"), BaseUtils.NumToChn(num))
	end

	-- 好友排名
	num = 0
	for i=1, #friendOnlyRankList do
        local data = friendOnlyRankList[i]
        if data.rid == roleData.id and data.platform == roleData.platform and data.zone_id == roleData.zone_id then
        	num = i
        end
    end
    if num == 0 then
    	self.myRankInFirendText.text = TI18N("第一名")
    else
	    self.myRankInFirendText.text = string.format(TI18N("第%s名"), BaseUtils.NumToChn(num))
	end

	-- 处理当前阶段奖励
	if self.model.max_wave == 0 then
		self.maxWaveText.text = TI18N("暂未有挑战记录")

		self.noWaveText.gameObject:SetActive(true)
		self.text2.gameObject:SetActive(false)
		self.itemPanel.gameObject:SetActive(false)
	else
		self.maxWaveText.text = string.format(TI18N("第%s阶段（通过人数<color='#13fc60'>%s%%</color>）"), BaseUtils.NumToChn(self.model.max_wave), self.model:GetBossWaveNum(self.model.max_wave))

		local reward_data = DataSpiritTreasure.data_wave[self.model.max_wave].show_reward
		for i=1, #self.itemSlotList do
		    if reward_data[i] ~= nil then
		        local itemData = ItemData.New()
		        local itemBase = BackpackManager.Instance:GetItemBase(reward_data[i][1])
		        itemData:SetBase(itemBase)
		        itemData.quantity = reward_data[i][2]
		        self.itemSlotList[i]:SetAll(itemData)
		        self.itemSlotList[i].gameObject:SetActive(true)
		    else
		        self.itemSlotList[i].gameObject:SetActive(false)
		    end
		end
	end

	-- 处理下阶段奖励
	if #DataSpiritTreasure.data_wave == self.model.max_wave then
		self.text3.gameObject:SetActive(false)
		self.itemPanel2.gameObject:SetActive(false)
		self.allCleanText.gameObject:SetActive(true)
	else
		self.text3.text = string.format(TI18N("下阶段奖励：\n（达成人数<color='#13fc60'>%s%%</color>）"), self.model:GetBossWaveNum(self.model.max_wave+1))

		local reward_data = DataSpiritTreasure.data_wave[self.model.max_wave+1].show_reward
		for i=1, #self.itemSlotList2 do
	        if reward_data[i] ~= nil then
	            local itemData = ItemData.New()
	            local itemBase = BackpackManager.Instance:GetItemBase(reward_data[i][1])
	            itemData:SetBase(itemBase)
	            itemData.quantity = reward_data[i][2]
	            self.itemSlotList2[i]:SetAll(itemData)
	            self.itemSlotList2[i].gameObject:SetActive(true)
	        else
	            self.itemSlotList2[i].gameObject:SetActive(false)
	        end
	    end
	end

	-- 显示好友名字
	local friendNum = 0
	local friendString = ""
	for i=1, #friendOnlyRankList do
        local data = friendOnlyRankList[i]
        if data.wave > self.model.max_wave and friendNum <= 3 and not (data.rid == roleData.id and data.platform == roleData.platform and data.zone_id == roleData.zone_id) then
	        if i == 1 then
	        	friendString = data.name
	        else
	        	friendString = string.format("%s、%s", friendString, data.name)
	        end
	        friendNum = friendNum + 1
	    end
    end

    if #friendOnlyRankList == 0 then
    	friendString = TI18N("暂无好友上榜")
    elseif friendNum == 0 then
    	friendString = TI18N("暂无好友达到下阶段")
	end	
	self.friendText.text = friendString

	local moreTextPos = self.moreTextTransform.localPosition	
	self.moreTextTransform.localPosition = Vector2(self.friendText.transform.localPosition.x + self.friendText.preferredWidth + 20, moreTextPos.y)
end

function StarChallengeSettlementWindow:OpenRank()
	self:OnClickClose()
	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.starchallengewindow, {2, true})
end

function StarChallengeSettlementWindow:showBgAni()
	if self.rotateId ~= nil then
        LuaTimer.Delete(self.rotateId)
    end
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function StarChallengeSettlementWindow:Rotate()
    self.RoleBg1.transform:Rotate(Vector3(0, 0, 0.3))
    self.RoleBg2.transform:Rotate(Vector3(0, 0, -0.5))
end
