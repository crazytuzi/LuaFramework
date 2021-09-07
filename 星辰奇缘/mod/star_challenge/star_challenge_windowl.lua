-- 星辰挑战资格赛窗口
-- ljh 20170704

StarChallengeWindow = StarChallengeWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function StarChallengeWindow:__init(model)
    self.model = model

    self.windowId = WindowConfig.WinID.starchallengewindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.starchallengewindow, type = AssetType.Main},
        {file = AssetConfig.starchallenge_textures, type = AssetType.Dep},
        {file = AssetConfig.talisman_textures, type = AssetType.Dep},
        {file = AssetConfig.halloween_textures, type = AssetType.Dep},
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
        {file = AssetConfig.rank_textures, type = AssetType.Dep},
        {file = AssetConfig.agenda_textures, type = AssetType.Dep},
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------

    ------------------------------------------------
    self.itemList = {}

    self.itemHeight = 100
    self.itemHalfHeight = 50

    self.starList = {}

    self.teamItemList = {}
	self.teamHeadSlotList = {}

	self.rewardItemList = {}
	self.rewardItemSlotList = {}

	self.index = 0
	self.tabIndex = 1

    self.rankItemList = {}
    self.rankHeadSlotList = {}

    ------------------------------------------------
    self._Update = function() self:Update() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function StarChallengeWindow:__delete()
    self:OnHide()

    for i=1, #self.teamHeadSlotList do
    	self.teamHeadSlotList[i]:DeleteMe()
    	self.teamHeadSlotList[i] = nil
    end

    for i=1, #self.rewardItemSlotList do
    	for j=1, #self.rewardItemSlotList[i] do
	    	self.rewardItemSlotList[i][j]:DeleteMe()
	    	self.rewardItemSlotList[i][j] = nil
	    end
    end

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    if self.rankItemSolt ~= nil then
        self.rankItemSolt:DeleteMe()
        self.rankItemSolt = nil
    end

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.mainTabGroup ~= nil then
        self.mainTabGroup:DeleteMe()
        self.mainTabGroup = nil
    end

    if self.tipsPanelItemSolt1 ~= nil then
        self.tipsPanelItemSolt1:DeleteMe()
        self.tipsPanelItemSolt1 = nil
    end

    if self.tipsPanelItemSolt2 ~= nil then
        self.tipsPanelItemSolt2:DeleteMe()
        self.tipsPanelItemSolt2 = nil
    end

    if self.tipsPanelItemSolt3 ~= nil then
        self.tipsPanelItemSolt3:DeleteMe()
        self.tipsPanelItemSolt3 = nil
    end

    for i=1, #self.rankHeadSlotList do
        self.rankHeadSlotList[i]:DeleteMe()
        self.rankHeadSlotList[i] = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function StarChallengeWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.starchallengewindow))
    self.gameObject.name = "StarChallengeWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.titleText = self.mainTransform:FindChild("Title/Text"):GetComponent(Text)

    local left = self.mainTransform:Find("Left")
    self.container = left:Find("Scroll/Container")
    self.cloner = left:Find("Scroll/Cloner").gameObject
    self.scroll = left:Find("Scroll"):GetComponent(ScrollRect)
    self.scroll.onValueChanged:AddListener(function() self:UpdatePos() end)
    self.pageController  = self.scroll.gameObject:AddComponent(PageTabbedController)

    self.pageController.onUpEvent:AddListener(function() self:OnUp() end)
    self.pageController.onEndDragEvent:AddListener(function() self:OnUp() end)

    -- self.selectImage = left:Find("Select/Select")
    left:Find("Select/Select").gameObject:SetActive(false)

    local layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0})
    for i=1,5 do
        self.itemList[i] = StarChallengeWindowItem.New(self.model, GameObject.Instantiate(self.cloner), self)
        self.itemList[i].assetWrapper = self.assetWrapper
        layout:AddCell(self.itemList[i].gameObject)
        self.itemList[i].clickCallback = function(index) self:TweenTo(index - 2) end
    end
    self.cloner:SetActive(false)
    layout:DeleteMe()

    self.descPanelTitle = self.mainTransform:Find("DescPanel/Title/Text"):GetComponent(Text)
    self.descPanelStarPanel = self.mainTransform:Find("DescPanel/StarPanel")
    self.descPanelStarPanelDescText = self.mainTransform:Find("DescPanel/StarPanel/DescText"):GetComponent(Text)
    for i=1, 5 do
	    local starObj = self.descPanelStarPanel:Find(string.format("Star%s", i)).gameObject
	    table.insert(self.starList, starObj)
	end
    self.descPanelDescText = self.mainTransform:Find("DescPanel/DescText"):GetComponent(Text)
    self.descPanelButton = self.mainTransform:Find("DescPanel/Button"):GetComponent(Button)
    self.descPanelButton.onClick:AddListener(function() self:ShowDescPanelTips() end)

    self.infoPanel = self.mainTransform:Find("InfoPanel")
    self.infoPanelTitle = self.infoPanel:FindChild("Title").gameObject

    self.teamMask = self.infoPanel:FindChild("TeamMask").gameObject
    self.teamMaskContainer = self.teamMask.transform:FindChild("Container")
    self.teamMaskCloner = self.teamMask.transform:FindChild("Container/Item").gameObject
    self.teamMaskCloner:SetActive(false)
    self.teamMaskNoTips = self.teamMask.transform:FindChild("NoTips").gameObject
    self.teamMaskRewardTips = self.teamMask.transform:FindChild("RewardTips").gameObject
    self.teamMaskRewardTips:GetComponent(Button).onClick:AddListener(function() self:ShowRewardTips() end)

    self.rewardMask = self.infoPanel:FindChild("RewardMask").gameObject
    self.rewardMaskContainer = self.rewardMask.transform:FindChild("Container")
    self.rewardMaskCloner = self.rewardMask.transform:FindChild("Container/Item").gameObject
    self.rewardMaskCloner:SetActive(false)

    self.text1 = self.mainTransform:Find("Text1"):GetComponent(Text)
    self.text2 = self.mainTransform:Find("Text2"):GetComponent(Text)
    self.rewardButton = self.mainTransform:Find("RewardButton"):GetComponent(Button)
    self.rewardButton.onClick:AddListener(function() self:OnRewardButtonClick() end)
    self.okButton = self.mainTransform:Find("OkButton"):GetComponent(Button)
    self.okButton.onClick:AddListener(function() self:OnOkButtonClick() end)

    self.greyButton = self.mainTransform:Find("GreyButton"):GetComponent(Button)
    self.greyButton.onClick:AddListener(function() self:OnOkButtonClick() end)
    self.greyButton.gameObject:SetActive(false)

    self.tabGroupObj = self.infoPanel:FindChild("TabButtonGroup").gameObject
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, { notAutoSelect = true })

    self:ShowButtonEffect(true)

    ----------------------------

    self.rankTransform = self.transform:FindChild("RankPanel")

    self.closeBtn = self.rankTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.titleText = self.rankTransform:FindChild("Title/Text"):GetComponent(Text)

    self.rankItemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.rankTransform:FindChild("RewardPanel/Item").gameObject, self.rankItemSolt.gameObject)

    self.rankDescText = self.rankTransform:FindChild("RewardPanel/DescText"):GetComponent(Text)

    self.rankModelTitleText = self.rankTransform:FindChild("ModelPanel/Title/Text"):GetComponent(Text)
    self.rankTransform:FindChild("ModelPanel/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.preview = self.rankTransform:FindChild("ModelPanel/Preview")

    self.rankNothing = self.rankTransform:FindChild("Panel/Nothing").gameObject
    self.rankContainer = self.rankTransform:FindChild("Panel/Container")
    self.rankContainerCloner = self.rankTransform:FindChild("Panel/Container/Cloner").gameObject
    self.rankContainerCloner:SetActive(false)

    self.toggle = self.rankTransform:FindChild("Toggle"):GetComponent(Toggle)
    self.toggle.onValueChanged:AddListener(function(on) self:onToggleChange(on) end)

    ----------------------------

    self.tipsPanel = self.transform:FindChild("TipsPanel").gameObject
    self.tipsPanel:SetActive(false)
    self.tipsPanel:GetComponent(Button).onClick:AddListener(function() self.tipsPanel:SetActive(false) end)

    self.tipsPanelText = self.tipsPanel.transform:FindChild("Panel/Text"):GetComponent(Text)
    self.tipsPanelItemSolt1 = ItemSlot.New()
    UIUtils.AddUIChild(self.tipsPanel.transform:FindChild("Panel/Item1").gameObject, self.tipsPanelItemSolt1.gameObject)
    self.tipsPanelItemSolt2 = ItemSlot.New()
    UIUtils.AddUIChild(self.tipsPanel.transform:FindChild("Panel/Item2").gameObject, self.tipsPanelItemSolt2.gameObject)
    self.tipsPanelItemSolt3 = ItemSlot.New()
    UIUtils.AddUIChild(self.tipsPanel.transform:FindChild("Panel/Item3").gameObject, self.tipsPanelItemSolt3.gameObject)

    ----------------------------

    self.mainTabGroupObj = self.transform:FindChild("TabButtonGroup")
    self.mainTabGroup = TabGroup.New(self.mainTabGroupObj, function(index) self:ChangeMainTab(index) end, false)
    local rect = self.mainTabGroupObj:GetComponent(RectTransform)
    rect.anchorMax = Vector2(0.5, 0.5)
    rect.anchorMin = Vector2(0.5, 0.5)
    rect.anchoredPosition = Vector2(339.66, 186.2)

    self.mainTransform.gameObject:SetActive(true)
    self.rankTransform.gameObject:SetActive(false)

    ----------------------------

    self.OnOpenEvent:Fire()
    self:ClearMainAsset()
end

function StarChallengeWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function StarChallengeWindow:OnShow()
    self:Update()
    -- BaseUtils.dump(self.openArgs)

    if self.openArgs ~= nil then
        if self.openArgs[1] ~= nil then
            if self.openArgs[1] == 1 then
            	if self.openArgs[2] ~= nil then
            		if self.openArgs[3] ~= nil then
            			self.tabIndex = self.openArgs[3]

                        if self.tabIndex == 1 then
                            if #self.model.spirit_treasure_unit[self.openArgs[1]+2].offer_teams == 0 then
                                self.tabIndex = 2
                            end
                        end
            		end
            		self:TweenTo(self.openArgs[2])
            	end
            elseif self.openArgs[1] == 2 then
                if self.openArgs[2] ~= nil then
                    self.rankFriendOnlyMark = self.openArgs[2]
                    self.toggle.isOn = self.rankFriendOnlyMark
                end
            end
        end
        self.mainTabGroup:ChangeTab(self.openArgs[1])
    end

    -- self:TweenTo(1)
    StarChallengeManager.Instance:Send20205()
    StarChallengeManager.Instance:Send20209()
    StarChallengeManager.Instance.OnUpdateList:AddListener(self._Update)
end

function StarChallengeWindow:OnHide()
	StarChallengeManager.Instance.OnUpdateList:RemoveListener(self._Update)
end

function StarChallengeWindow:Update()
    if self.mainIndex == 1 then
        for i=1, #self.itemList do
            if self.model.spirit_treasure_unit[i] then
                self.itemList[i]:update_my_self(self.model.spirit_treasure_unit[i], i)
            end
        end

        self:UpdatePos()
    else
        self:UpdateRankPanel()
    end
end

function StarChallengeWindow:UpdateInfo(y)
	local index = BaseUtils.Round(y / self.itemHeight) + 2
	if self.index ~= index then
		self.index = index
		self.currUnitData = self.model.spirit_treasure_unit[index]
		self.currUnitConfigData = self.model:GetUnitData(self.currUnitData.base_id, self.currUnitData.difficulty)
		if index == 1 then
			self:UpdateBossInfo()
		else
			self:UpdateCommonMonsterInfo()
		end
	end
end

function StarChallengeWindow:UpdateBossInfo()
	self.titleText.text = TI18N("龙王挑战")
	self.descPanelTitle.text = DataUnit.data_unit[self.currUnitConfigData.index].name

	self.descPanelStarPanel.gameObject:SetActive(false)
    self.descPanelDescText.text = TI18N("\n组队挑战，每周日24点前完成战斗可获得奖励(超过24点后,<color='#00ff00'>奖励按照24点时的完成波数计算</color>)，奖励在周一通过邮件发放！")
	--self.descPanelDescText.text = TI18N("\n获得资格的玩家可以<color='#00ff00'>组队挑战龙王</color>，龙王战斗分为5个阶段，挑战的<color='#00ff00'>阶段越多奖励越丰厚</color>，每周日24点前完成战斗可获得奖励，奖励在<color='#00ff00'>周一</color>通过邮件发放(超过24点后完成挑战不能获得奖励)！")
	self.descPanelDescText.transform.localPosition = Vector2(-6, -10)
	self.descPanelButton.transform.localPosition = Vector2(222, -5)

	self.infoPanelTitle:SetActive(false)
	self.tabGroupObj:SetActive(true)
	-- self:ChangeTab(self.tabIndex)
	self.tabGroup.noCheckRepeat = true
	self.tabGroup:ChangeTab(self.tabIndex)
	self.tabGroup.noCheckRepeat = false

    if self.model.max_wave == 0 then
    	self.text1.text = TI18N("挑战记录:未通过")
    else
        self.text1.text = string.format(TI18N("挑战记录:第%s阶段"), BaseUtils.NumToChn(self.model.max_wave))
    end

	if self.model.myRank == 0 then
		self.text2.text = TI18N("未获得资格")
	else
		self.text2.text = string.format(TI18N("已获资格:<color=#00ff00>%s</color><color=#ffff00>(%s)</color>"), self.model.myRankFormUnitConfigData.name, self.model.myRank)
	end
    self.rewardButton.gameObject:SetActive(false)

	self.greyButton.gameObject:SetActive(false)
	self.okButton.gameObject:SetActive(true)
end

function StarChallengeWindow:UpdateCommonMonsterInfo()
	self.titleText.text = TI18N("资格挑战")
	self.descPanelTitle.text = DataUnit.data_unit[self.currUnitConfigData.index].name

    self.descPanelStarPanel.gameObject:SetActive(true)
    --星数
    local miniStar = self.currUnitData.now_star
	for i=1, 5 do
	    if i > miniStar then
	    	self.starList[i]:SetActive(false)
	    else
	    	self.starList[i]:SetActive(true)
	    end
    end
    --

    local addDesc = self.model:GetUnitAttrAdd(self.currUnitData.base_id, self.currUnitData.difficulty, self.currUnitData.kill_times)
    local addNum_1 = string.match(addDesc,"提升%d+")
    local addNum_2 = string.gsub(addNum_1,"提升","")
    local increNum = addNum_2 + self.currUnitData.diff_num/10
    self.descPanelStarPanelDescText.text = string.format(TI18N("怪物能力<color='#ffff00'>提升%d%%</color>"),increNum)


	self.descPanelDescText.text = TI18N("1.每次<color='#00ff00'>挑战成功</color>提升怪物能力，<color='#00ff00'>每天0点</color>提升怪物能力\n2.截止到<color='#00ff00'>周五12点</color>排行前8的队伍可以晋级")
	self.descPanelDescText.transform.localPosition = Vector2(-6, -47)
	self.descPanelButton.transform.localPosition = Vector2(222, -28)

	self.infoPanelTitle:SetActive(true)
	self.tabGroupObj:SetActive(false)
	self.teamMask:SetActive(true)
	self.rewardMask:SetActive(false)
	self:UpdateTeamMask()

	self.text1.text = string.format(TI18N("发放资格:<color=#ffff00>%s/%s</color>"), #self.currUnitData.offer_teams, self.currUnitConfigData.offer)
	if self.model.myRank == 0 then
		self.text2.text = TI18N("成功挑战奖励：")
        self.rewardButton.gameObject:SetActive(true)
	else
		self.text2.text = string.format(TI18N("已获资格:<color=#00ff00>%s</color><color=#ffff00>(%s)</color>"), self.model.myRankFormUnitConfigData.name, self.model.myRank)
        self.rewardButton.gameObject:SetActive(false)
	end

	if self.model.status == 2 then
		self.greyButton.gameObject:SetActive(false)
		self.okButton.gameObject:SetActive(true)
	elseif self.model.status == 3 then
		self.greyButton.gameObject:SetActive(true)
		self.okButton.gameObject:SetActive(false)
	end
end

function StarChallengeWindow:UpdateTeamMask()
	local datalist = self.currUnitData.offer_teams
	for i=1, #datalist do
	    local data = datalist[i]
	    local item = self.teamItemList[i]
	    local headSlot = self.teamHeadSlotList[i]
	    if item == nil then
	        item = GameObject.Instantiate(self.teamMaskCloner)
	        item.transform:SetParent(self.teamMaskContainer)
	        item.transform.localScale = Vector3(1, 1, 1)
	        item:SetActive(true)
	        self.teamItemList[i] = item

	        headSlot = HeadSlot.New()
	        UIUtils.AddUIChild(item.transform:Find("LeaderHead"), headSlot.gameObject)
	        self.teamHeadSlotList[i] = headSlot

            item:AddComponent(Button)
	    end
		item:SetActive(true)

		local btn = item.transform:Find("Button"):GetComponent(Button)
		btn.onClick:RemoveAllListeners()
		btn.onClick:AddListener(function()
				-- print("CombatManager.Instance:Send10753")
				CombatManager.Instance:Send10753(data.type, data.rec_id, data.rec_platform, data.rec_zone_id)
                self:OnClickClose()
			end)
        btn = item:GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function()
                self.model:OpenStarChallengeTeamPanel({ self.index, data })
            end)

		item.transform:Find("Lable").gameObject:SetActive(data.isMyTeam == true)

		for i = 1, 5 do
            if data.team_mates[i] ~= nil then
                item.transform:Find(string.format("MemberClasses%s", i)):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, string.format("ClassesIcon_%s", data.team_mates[i].classes))
                item.transform:Find(string.format("MemberClasses%s", i)).gameObject:SetActive(true)
            else
                item.transform:Find(string.format("MemberClasses%s", i)).gameObject:SetActive(false)
            end
		end

		local leaderData = data.team_mates[1]
		local dat = {id = leaderData.rid, platform = leaderData.platform, zone_id = leaderData.zone_id, classes = leaderData.classes, sex = leaderData.sex}
		-- local dat = RoleManager.Instance.RoleData
     	headSlot:SetAll(dat, {isSmall = true})

     	item.transform:Find("NameText"):GetComponent(Text).text = leaderData.name
	end

    for i=#datalist+1, #self.teamItemList do
        self.teamItemList[i]:SetActive(false)
    end

	-- if #datalist > 0 then
	-- 	self.teamMaskNoTips:SetActive(false)
 --        self.teamMaskRewardTips:SetActive(false)
	-- 	self.teamMaskContainer.gameObject:SetActive(true)
	-- else
 --        if self.currUnitData.base_id == 32004 then
 --    		self.teamMaskNoTips:SetActive(true)
 --            self.teamMaskRewardTips:SetActive(false)
 --        else
 --            self.teamMaskNoTips:SetActive(false)
 --            self.teamMaskRewardTips:SetActive(true)
 --        end
	-- 	self.teamMaskContainer.gameObject:SetActive(false)
	-- end
    if #datalist > 0 then
        self.teamMaskNoTips:SetActive(false)
        self.teamMaskContainer.gameObject:SetActive(true)
    else
        self.teamMaskNoTips:SetActive(true)
        self.teamMaskContainer.gameObject:SetActive(false)
    end
end

function StarChallengeWindow:UpdateRewardMask()
	local datalist = DataSpiritTreasure.data_wave
	for i=1, #datalist do
	    local data = datalist[i]
	    local item = self.rewardItemList[i]
	    local itemSlotList = self.rewardItemSlotList[i]
	    if item == nil then
	        item = GameObject.Instantiate(self.rewardMaskCloner)
	        item.transform:SetParent(self.rewardMaskContainer)
	        item.transform.localScale = Vector3(1, 1, 1)
	        item:SetActive(true)
	        self.rewardItemList[i] = item

	        itemSlotList = {}
	        self.rewardItemSlotList[i] = itemSlotList
	    end

	    item.transform:Find("Text"):GetComponent(Text).text = string.format(TI18N("通过第%s阶段\n概率获得"), BaseUtils.NumToChn(i))

        item.transform:Find("Mask"):GetComponent(ScrollRect).enabled = false
	    local container = item.transform:Find("Mask/Container").gameObject
	    for j=1, #data.show_reward do
	    	local itemSlot = itemSlotList[j]
	    	if itemSlot == nil then
		        itemSlot =  ItemSlot.New()
    			UIUtils.AddUIChild(container, itemSlot.gameObject)
		        itemSlotList[j] = itemSlot
		    end

		    local itemData = ItemData.New()
		    local itemBase = BackpackManager.Instance:GetItemBase(data.show_reward[j][1])
		    itemData:SetBase(itemBase)
		    itemData.quantity = data.show_reward[j][2]
		    itemSlot:SetAll(itemData, {inbag = false, nobutton = true})
	    end

        if i > self.model.max_wave then
            item.transform:Find("Finish").gameObject:SetActive(false)
            item.transform:Find("NoFinishText").gameObject:SetActive(true)
            item.transform:Find("NoFinishText/Text"):GetComponent(Text).text = string.format(TI18N("已有%s%%人通过"), self.model:GetBossWaveNum(i))
        else
            item.transform:Find("Finish").gameObject:SetActive(true)
            item.transform:Find("NoFinishText").gameObject:SetActive(false)
        end
	end
end

-- 更新位置，使轨迹像圆
function StarChallengeWindow:UpdatePos()
    local y = nil
    local res = nil

    -- 这个算法。。。看不懂也别问我
    -- 运动轨迹是椭圆，设坐标原点是左上角，然后标准方程是(x + 123)^2 / 250^2 + (y + 210)^2 / 296.5^2 = 1
    -- 然后就有下面的算法
    for i,v in ipairs(self.itemList) do
        y = v.transform.anchoredPosition.y + self.container.anchoredPosition.y - v.transform.sizeDelta.y / 2

        res = 1 - ((y + 210)*(y + 210) / (296.5*296.5))
        if res >= 0 then
            v.item.anchoredPosition = Vector2(math.sqrt(res) * 250 - 123 - 138.25 - 11, 0)
            -- v:SetScale(1 - (y + 150) * (y + 150) * (1 - 0.6)/44100)
            v:SetScale(1 - math.abs(y + 150) * (1 - 0.6)/200)
        end
    end

    self:UpdateInfo(self.container.anchoredPosition.y)

    self:SetAlpha()
end

-- 转到
function StarChallengeWindow:TweenTo(index)
	if index + 2 == 1 and self.model.status == 2 then
		NoticeManager.Instance:FloatTipsByString("获得资格的玩家在周五12点才能挑战龙王{face_1,1}")
		return
	end

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end
    self.tweenId = Tween.Instance:ValueChange(self.container.anchoredPosition.y, self.itemHeight * index, 0.5, function() self.tweenId = nil end, LeanTweenType.easeOutQuart,
        function(value)
            if self.container ~= nil then
                self.container.anchoredPosition = Vector2(0, value)
            end
            -- self.scroll.onValueChanged:Invoke({0, 1 - value / self.container.sizeDelta.y})
        end).id

    if self.selectImage ~= nil then
    	self.selectImage:GetComponent(Image).color = Color(1, 1, 1, 0)
    end
    self.selectImage = self.itemList[index+2].transform:Find("Item/Select")
    self.selectImage:GetComponent(Image).color = Color(1, 1, 1, 0)
    self:SetAlpha()

    if self.selectText ~= nil then
        self.selectText.color = ColorHelper.DefaultButton1
    end
    self.selectText = self.itemList[index+2].titleText
    self.selectText.color = Color.yellow
end

function StarChallengeWindow:StopAt(index)
    self.scroll.onValueChanged:Invoke({0, 0})
    self.container.anchoredPosition = Vector2(0, self.itemHeight * index)
    self.scroll.onValueChanged:Invoke({0, 1 - self.itemHeight * index / self.container.sizeDelta.y})
end

function StarChallengeWindow:OnUp()
    local y = self.container.anchoredPosition.y
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end
    self.tweenId = Tween.Instance:ValueChange(y, self.itemHeight * math.ceil(math.floor(y * 2 / self.itemHeight) / 2), 0.5, function() self.tweenId = nil end, LeanTweenType.easeOutQuart,
        function(value)
            if self.container ~= nil then
                self.container.anchoredPosition = Vector2(0, value)
            end
            -- self.scroll.onValueChanged:Invoke({0, 1 - value / self.container.sizeDelta.y})
        end).id
end

-- 设置选中框的透明度
function StarChallengeWindow:SetAlpha()
    local y = self.container.anchoredPosition.y
    -- local alpha = 1 - math.abs(y - self.itemHeight * math.floor((y + self.itemHalfHeight) / self.itemHeight)) / self.itemHalfHeight
    local alpha = 1 - math.abs(y - self.itemHeight * math.floor((y + self.itemHalfHeight) / self.itemHeight)) / self.itemHalfHeight

    if self.selectImage then
	    self.selectImage:GetComponent(Image).color = Color(1, 1, 1, alpha)
	end
end

function StarChallengeWindow:ShowDescPanelTips()
	local tipsString = {
            TI18N("1.通过任一<color='#ffff00'>门徒</color>考验后可获得龙王<color='#ffff00'>挑战资格</color>")
            , TI18N("2.门徒被成功挑战或刷天后，能力都将<color='#ffff00'>得到提升</color>")
            , TI18N("3.每位门徒对应的<color='#ffff00'>龙王挑战资格</color>有限，只有<color='#ffff00'>最近通过挑战</color>的8支队伍才可获得")
        }
	if self.index > 1 then
		tipsString = {
            TI18N("1.通过任一<color='#ffff00'>门徒</color>考验后可获得龙王<color='#ffff00'>挑战资格</color>")
            , TI18N("2.门徒被成功挑战或刷天后，能力都将<color='#ffff00'>得到提升</color>")
            , TI18N("3.每位门徒对应的<color='#ffff00'>挑战资格</color>有限，只有<color='#ffff00'>最近通过挑战</color>的8支队伍可获得")
        }
	end

	TipsManager.Instance:ShowText({gameObject = self.descPanelButton.gameObject, itemData = tipsString})
end

function StarChallengeWindow:ChangeTab(index)
	self.tabIndex = index
	if index == 1 then
		self.teamMask:SetActive(true)
		self.rewardMask:SetActive(false)

		self:UpdateTeamMask()
	else
		self.teamMask:SetActive(false)
		self.rewardMask:SetActive(true)

		self:UpdateRewardMask()
	end
end

function StarChallengeWindow:OnOkButtonClick()
    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.StarChallenge then
        self.model:EnterScene()
    end

	if self.model.status == 2 then
       	if self.currUnitConfigData.index ~= 32004 then
       		local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
            for k,v in pairs(units) do
                if v.baseid == self.currUnitConfigData.unit_id then
                    SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(v.uniqueid)
                    self:OnClickClose()
                    return
                end
            end
       	else
       		NoticeManager.Instance:FloatTipsByString(TI18N("获得资格后可在周五15点后挑战龙王"))
       	end
    elseif self.model.status == 3 then
        if self.currUnitConfigData.index == 32004 then
       		local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
            for k,v in pairs(units) do
                if v.baseid == self.currUnitConfigData.unit_id then
                    SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(v.uniqueid)
                    self:OnClickClose()
                    return
                end
            end
       	end
    end
end

function StarChallengeWindow:ShowButtonEffect(show)
    if show then
        if self.effect == nil then
            local fun = function(effectView)
                if self.okButton ~= nil then
                    --特效加载完界面关了？？
                    local effectObject = effectView.gameObject
                    effectObject.transform:SetParent(self.okButton.transform)
                    effectObject.transform.localScale = Vector3(1.7, 0.6, 1)
                    effectObject.transform.localPosition = Vector3(-55, -13, -400)
                    effectObject.transform.localRotation = Quaternion.identity

                    Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                    effectObject:SetActive(true)
                end
            end
            self.effect = BaseEffectView.New({effectId = 20053, time = nil, callback = fun})
        else
            self.effect:SetActive(true)
        end
    else
        if self.effect ~= nil then
            self.effect:SetActive(true)
        end
    end
end

function StarChallengeWindow:UpdateRankPanel()
    self.rankDescText.text = string.format(TI18N("排行前%s的玩家\n可获得龙王传承！"), 10)

    local itemData = ItemData.New()
    local itemBase = BackpackManager.Instance:GetItemBase(24052)
    itemData:SetBase(itemBase)
    self.rankItemSolt:SetAll(itemData)

    self.rankModelTitleText.text = TI18N("赤炎小龙")

    local data = {type = PreViewType.Pet, skinId = 30156, modelId = 30056, animationId = 3005602, scale = 1, effects = {{effect_id = 102130}}}

    local setting = {
        name = "PetView"
        ,orthographicSize = 0.3
        ,width = 200
        ,height = 200
        ,offsetY = -0.25
    }

    local fun = function(composite)
        if BaseUtils.is_null(self.gameObject) or BaseUtils.is_null(self.preview) then
            return
        end
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))

        -- if self.timeId_PlayIdleAction ~= nil then LuaTimer.Delete(self.timeId_PlayIdleAction) end
        -- self.timeId_PlayIdleAction = LuaTimer.Add(0, 15000, function() self:PlayIdleAction() end)
    end

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end
    self.previewComposite = PreviewComposite.New(fun, setting, data)
    self.previewComposite:BuildCamera(true)

    self:UpdateRank()
end

function StarChallengeWindow:UpdateRank()
    local datalist = self.model.rank_list
    if self.rankFriendOnlyMark then
        datalist = self.model:GetFriendOnlyRankList(self.model.rank_list)
    end

    for i=1, #datalist do
        local data = datalist[i]
        local item = self.rankItemList[i]
        -- local headSlot = self.rankHeadSlotList[i]
        if item == nil then
            item = GameObject.Instantiate(self.rankContainerCloner)
            item.transform:SetParent(self.rankContainer)
            item.transform.localScale = Vector3(1, 1, 1)
            item:SetActive(true)
            self.rankItemList[i] = item

            -- headSlot = HeadSlot.New()
            -- UIUtils.AddUIChild(item.transform:Find("Character/Icon"), headSlot.gameObject)
            -- self.rankHeadSlotList[i] = headSlot
        end
        item:SetActive(true)

        -- local btn = item.transform:Find("Button"):GetComponent(Button)
        -- btn.onClick:RemoveAllListeners()
        -- btn.onClick:AddListener(function()
        --         -- print("CombatManager.Instance:Send10753")
        --         CombatManager.Instance:Send10753(data.type, data.rec_id, data.platform, data.zone_id)
        --         self:OnClickClose()
        --     end)

        if i % 2 == 1 then
            item.transform:Find("Bg"):GetComponent(Image).color = ColorHelper.ListItem1
        else
            item.transform:Find("Bg"):GetComponent(Image).color = ColorHelper.ListItem2
        end

        item.transform:Find("RankValue"):GetComponent(Text).text = string.format(ColorHelper.ListItemStr, tostring(i))
        if i < 4 then
            item.transform:Find("RankValue/RankImage").gameObject:SetActive(true)
            item.transform:Find("RankValue/RankImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_"..i)
        else
            item.transform:Find("RankValue/RankImage").gameObject:SetActive(false)
        end

        -- local dat = {id = data.rid, platform = data.platform, zone_id = data.zone_id, classes = data.classes, sex = data.sex}
        -- headSlot:SetAll(dat, {isSmall = true})
        item.transform:Find("Character/Icon/Image"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)

        item.transform:Find("Character/Name"):GetComponent(Text).text = data.name
        item.transform:Find("Classes"):GetComponent(Text).text = KvData.classes_name[data.classes]
        item.transform:Find("Step"):GetComponent(Text).text = string.format(TI18N("第%s阶段"), data.wave)
        if data.use_time < 3600 then
            item.transform:Find("Time"):GetComponent(Text).text = BaseUtils.formate_time_gap(data.use_time, ":", 0, BaseUtils.time_formate.MIN)
        else
            item.transform:Find("Time"):GetComponent(Text).text = BaseUtils.formate_time_gap(data.use_time, ":", 0, BaseUtils.time_formate.HOUR)
        end
    end

    for i=#datalist+1, #self.rankItemList do
        self.rankItemList[i]:SetActive(false)
    end

    if #datalist > 0 then
        self.rankNothing:SetActive(false)
        self.rankContainer.gameObject:SetActive(true)
    else
        self.rankNothing:SetActive(true)
        self.rankContainer.gameObject:SetActive(false)
    end
end

function StarChallengeWindow:onToggleChange(on)
    self.rankFriendOnlyMark = on

    self:UpdateRank()
end

function StarChallengeWindow:ChangeMainTab(index)
    self.mainIndex = index

    if self.mainIndex == 1 then
        self.mainTransform.gameObject:SetActive(true)
        self.rankTransform.gameObject:SetActive(false)
    else
        self.mainTransform.gameObject:SetActive(false)
        self.rankTransform.gameObject:SetActive(true)
    end

    self:Update()
end

function StarChallengeWindow:OnRewardButtonClick()
    self.tipsPanel:SetActive(true)
    self.tipsPanelText.text = TI18N("成功挑战极品奖励:")

    local reward_data = DataSpiritTreasure.data_reward[self.currUnitConfigData.index].base_reward

    for i=1, 3 do
        if reward_data[i] ~= nil then
            local itemData = ItemData.New()
            local itemBase = BackpackManager.Instance:GetItemBase(reward_data[i][1])
            itemData:SetBase(itemBase)
            itemData.quantity = reward_data[i][2]
            self["tipsPanelItemSolt"..i]:SetAll(itemData)
            self["tipsPanelItemSolt"..i].gameObject:SetActive(true)
        else
            self["tipsPanelItemSolt"..i].gameObject:SetActive(false)
        end
    end
end

function StarChallengeWindow:ShowRewardTips()
    self.tipsPanel:SetActive(true)
    self.tipsPanelText.text = TI18N("首杀极品奖励:")

    local reward_data = DataSpiritTreasure.data_reward[self.currUnitConfigData.index].frist_reward

    for i=1, 3 do
        if reward_data[i] ~= nil then
            local itemData = ItemData.New()
            local itemBase = BackpackManager.Instance:GetItemBase(reward_data[i][1])
            itemData:SetBase(itemBase)
            itemData.quantity = reward_data[i][2]
            self["tipsPanelItemSolt"..i]:SetAll(itemData)
            self["tipsPanelItemSolt"..i].gameObject:SetActive(true)
        else
            self["tipsPanelItemSolt"..i].gameObject:SetActive(false)
        end
    end
end