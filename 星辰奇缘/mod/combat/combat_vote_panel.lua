-- 战斗UI 支持率
CombatVotePanel = CombatVotePanel or BaseClass()

function CombatVotePanel:__init(gameObject)
    self.gameObject = gameObject
    self.isShow = false

    self.boss_id = 0

    self.iconId1 = 0
    self.iconX1 = 0
    self.iconId2 = 0
    self.iconX2 = 0

    self.barWidth = 245
    self.barHeight = 16

    self.effectList = {}

    self._Update = function() self:Update() end

    self:InitPanel()
end

function CombatVotePanel:InitPanel()
	self.transform = self.gameObject.transform
	
	self.bar = self.transform:Find("BarBg/Bar"):GetComponent(RectTransform)

	self.barLength = self.transform:Find("BarBg/BarLength"):GetComponent(RectTransform).sizeDelta.x

	self.icon1 = self.transform:Find("BarBg/BarLength/Icon1")
	self.icon2 = self.transform:Find("BarBg/BarLength/Icon2")

	self.nameText = self.transform:Find("NameText"):GetComponent(Text)
	self.numText = self.transform:Find("NumText"):GetComponent(Text)

	self.headIconLoader = SingleIconLoader.New(self.transform:Find("Head").gameObject)
	self.icon1Loader = SingleIconLoader.New(self.icon1:Find("Image").gameObject)
	self.icon2Loader = SingleIconLoader.New(self.icon2:Find("Image").gameObject)

	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:OpenTips() end)
	self.icon1:GetComponent(Button).onClick:AddListener(function() self:OnClickIcon() end)
	self.icon2:GetComponent(Button).onClick:AddListener(function() self:OnClickIcon() end)

	self:ShowEffect(20496, true, self.bar.transform:Find("Effect"), nil, Vector3(4, 6, -300))
end

function CombatVotePanel:__delete()
	self:Hide()

	if self.headIconLoader ~= nil then
		self.headIconLoader:DeleteMe()
		self.headIconLoader = nil
	end

	if self.icon1Loader ~= nil then
		self.icon1Loader:DeleteMe()
		self.icon1Loader = nil
	end

	if self.icon2Loader ~= nil then
		self.icon2Loader:DeleteMe()
		self.icon2Loader = nil
	end
end

function CombatVotePanel:Show()
	self.isShow = true
	self.gameObject:SetActive(true)

	EventMgr.Instance:AddListener(event_name.combat_watch_vote, self._Update)
	self:Update()
end

function CombatVotePanel:Hide()
	self.isShow = false
	self.gameObject:SetActive(false)

	EventMgr.Instance:RemoveListener(event_name.combat_watch_vote, self._Update)
end

function CombatVotePanel:SetActive(active)
	if active then
		self:Show()
	else
		self:Hide()
	end
end

function CombatVotePanel:Update()
	local data = CombatManager.Instance.voteData
	
	if data == nil then
		return
	end

	self.numText.text = tostring(data.observer_num)

	self.bar.sizeDelta = Vector2(data.boss_hp_percent / 1000 * self.barWidth, self.barHeight)

	if self.boss_id ~= data.boss_id then
		self.boss_id = data.boss_id
		local data_combat_vote = DataCombatUtil.data_combat_vote[self.boss_id]
		if data_combat_vote ~= nil then
			self.headIconLoader:SetSprite(SingleIconType.Other, data_combat_vote.boss_head_id)
			self.nameText.text = data_combat_vote.name

			self.icon1.localPosition = Vector3(self.barLength * data_combat_vote.wave1 / 100, 0, 0)
			self.icon2.localPosition = Vector3(self.barLength * data_combat_vote.wave2 / 100, 0, 0)

			self.icon1Loader:SetSprite(SingleIconType.Item, data_combat_vote.wave1_icon)
			self.icon2Loader:SetSprite(SingleIconType.Item, data_combat_vote.wave2_icon)
		end
	end
end

function CombatVotePanel:OpenTips()
	CombatManager.Instance.WatchLogmodel:OpenCombatWatchVoteTips(self.boss_id)
end

function CombatVotePanel:OnClickIcon()
	NoticeManager.Instance:FloatTipsByString(TI18N("Boss血条降到此处时将触发特殊事件"))
end

function CombatVotePanel:ShowEffect(effectId, show, transform, scale, position)
	local effect = self.effectList[effectId]

	if show then
		if effect == nil then
			effect = BaseUtils.ShowEffect(effectId, transform, scale, position)
			self.effectList[effectId] = effect
		else
			effect:SetActive(false)
			effect:SetActive(true)
		end
	else
		if effect ~= nil then
			effect:SetActive(false)
		end
	end
end