-- @author 林嘉豪
-- @date 2017年7月14日, 星期一

StarChallengeFightRewardPanel = StarChallengeFightRewardPanel or BaseClass(BasePanel)

function StarChallengeFightRewardPanel:__init(model)
    self.model = model
    self.name = "StarChallengeFightRewardPanel"

    self.resList = {
        {file = AssetConfig.starchallengefightrewardpanel, type = AssetType},
    }

    self.index = 1
    self.itemSlotList = {}

    self.updateListener = function(data) self:Update(data) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function StarChallengeFightRewardPanel:__delete()
    self.OnHideEvent:Fire()

    for i=1, #self.itemSlotList do
		self.itemSlotList[i]:DeleteMe()
		self.itemSlotList[i] = nil
    end

    self:AssetClearAll()
end

function StarChallengeFightRewardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.starchallengefightrewardpanel))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(CombatManager.Instance.combatCanvas, self.gameObject)

    self.transform:Find("Icon"):GetComponent(Button).onClick:AddListener(function() self:ShowTipsPanel() end)
    
    self.tipsPanel = self.transform:Find("TipsPanel")
    self.tipsPanel:GetComponent(Button).onClick:AddListener(function() self.tipsPanel.gameObject:SetActive(false) end)
    self.descText = self.transform:Find("TipsPanel/Panel/Text"):GetComponent(Text)

    self.nextButton = self.transform:Find("TipsPanel/Panel/NextButton"):GetComponent(Button)
    self.nextButton:GetComponent(Button).onClick:AddListener(function() self:NextWaveReward() end)
    self.preButton = self.transform:Find("TipsPanel/Panel/PreButton"):GetComponent(Button)
    self.preButton:GetComponent(Button).onClick:AddListener(function() self:PreWaveReward() end)

    for i=1, 3 do
	    local itemSlot = ItemSlot.New()
	    UIUtils.AddUIChild(self.transform:Find("TipsPanel/Panel/Item"..i).gameObject, itemSlot.gameObject)
	    table.insert(self.itemSlotList, itemSlot)
	end
end

function StarChallengeFightRewardPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function StarChallengeFightRewardPanel:OnOpen()
    self:RemoveListeners()
    -- StarChallengeManager.Instance.OnUpdateBossWave:AddListener(self.updateListener)

    self:Update()
end

function StarChallengeFightRewardPanel:OnHide()
    self:RemoveListeners()
end

function StarChallengeFightRewardPanel:RemoveListeners()
    -- StarChallengeManager.Instance.OnUpdateBossWave:RemoveListener(self.updateListener)
end

function StarChallengeFightRewardPanel:Update()
	if self.index == 0 then
		return
	end

	self.descText.text = string.format(TI18N("通关第%s阶段有几率获得："), BaseUtils.NumToChn(self.index))

	local reward_data = DataSpiritTreasure.data_wave[self.index].show_reward
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

	local maxWave = #DataSpiritTreasure.data_wave
	if self.index == 1 then
		self.nextButton.gameObject:SetActive(true)
		self.preButton.gameObject:SetActive(false)
	elseif self.index == maxWave then
		self.nextButton.gameObject:SetActive(false)
		self.preButton.gameObject:SetActive(true)
	else
		self.nextButton.gameObject:SetActive(true)
		self.preButton.gameObject:SetActive(true)
	end
end

function StarChallengeFightRewardPanel:ShowTipsPanel()
	self.tipsPanel.gameObject:SetActive(true)
	self.index = StarChallengeManager.Instance.model.wave
	self:Update()
end

function StarChallengeFightRewardPanel:NextWaveReward()
	local maxWave = #DataSpiritTreasure.data_wave
	if self.index < maxWave then
		self.index = self.index + 1
		self:Update()
	end
end

function StarChallengeFightRewardPanel:PreWaveReward()
	if self.index > 1 then
		self.index = self.index - 1
		self:Update()
	end
end