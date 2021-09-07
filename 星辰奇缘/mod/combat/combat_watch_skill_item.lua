-- 战斗UI 打气技能 天雷
WatchSkillItem = WatchSkillItem or BaseClass()

function WatchSkillItem:__init(gameObject)
    self.gameObject = gameObject
    self.isShow = false

    self.skill_id = 0
    self.countMax = 0
    self.count = 0
    self.round = 1

    self.effectList = {}

    self.barWidth = 24
    self.barHeight = 170

    self._Update = function(eventType)
    	if eventType == "Update" then
	    	self:Update()
	    elseif eventType == "SkillUseSuccess" then
	    	self:SkillUseSuccess()
	    end
	end

	self._BeginFightRound = function(round)
		self:BeginFightRound(round)
	end

	self:InitPanel()
end

function WatchSkillItem:InitPanel()
	self.transform = self.gameObject.transform
	self.transform:Find("SkillIcon"):GetComponent(Button).onClick:AddListener(function() self:OnButtonClick() end)
	self.text = self.transform:Find("SkillIcon/Text"):GetComponent(Text)
	self.bar = self.transform:Find("BarBg/Bar")
	self.barRect = self.bar:GetComponent(RectTransform)

	self.skillIconLoader = SingleIconLoader.New(self.transform:Find("SkillIcon").gameObject)

	self:ShowEffect(20497, true, self.transform:Find("BarBg"), nil, Vector3(0, 0, -300))
	self:ShowEffect(20500, true, self.bar:Find("Effect"), nil, Vector3(-4, -3, -300))
end

function WatchSkillItem:__delete()
	self:Hide()

    if self.skillIconLoader ~= nil then
        self.skillIconLoader:DeleteMe()
        self.skillIconLoader = nil
    end

    for k, v in pairs(self.effectList) do
    	v:DeleteMe()
    end
    self.effectList = nil
end

function WatchSkillItem:Show(watchSkillData)
	self.isShow = true
	self.gameObject:SetActive(true)

	self.watchSkillData = watchSkillData
	self.round = 1
	self:Update()
	EventMgr.Instance:AddListener(event_name.combat_watch_skill, self._Update)
	EventMgr.Instance:AddListener(event_name.begin_fight_round, self._BeginFightRound)
end

function WatchSkillItem:Hide()
	self.isShow = false
	self.gameObject:SetActive(false)
	EventMgr.Instance:RemoveListener(event_name.combat_watch_skill, self._Update)
	EventMgr.Instance:RemoveListener(event_name.begin_fight_round, self._BeginFightRound)
end

function WatchSkillItem:Update()
	if self.skill_id ~= self.watchSkillData.skill_id then
		self.skill_id = self.watchSkillData.skill_id
		local skillData = DataSkill.data_skill_other[self.skill_id]
		self.skillIconLoader:SetSprite(SingleIconType.SkillIcon, skillData.icon)
	end

	local combatHelpSkillData = CombatManager.Instance.combatHelpSkillData[self.watchSkillData.skill_id]
BaseUtils.dump(combatHelpSkillData, "WatchSkillItem:Update()")
	if combatHelpSkillData ~= nil then
		if combatHelpSkillData.skill_status == 3 then -- 如果状态是3.释放中的话，需要做个特殊处理，等下回合才更新协议数据，本次更新使用客户端自己构造的数据
			print("self.round, "..self.round)
			if combatHelpSkillData.round == self.round then
				local temp = combatHelpSkillData
				combatHelpSkillData = { skill_id = temp.skill_id, times = self.watchSkillData.count, skill_status = temp.skill_status, my_skill_status = temp.my_skill_status, round = temp.round }
			end
		end

		if self.countMax ~= self.watchSkillData.count or self.count ~= combatHelpSkillData.times then
			self.countMax = self.watchSkillData.count
			self.count = combatHelpSkillData.times
			if self.countMax == 0 then
				self.barRect.sizeDelta = Vector2(self.barWidth, 0)
				self.text.text = "0%"

				print("WatchSkillItem:Update() -------------1")
			else
				self.barRect.sizeDelta = Vector2(self.barWidth, self.count / self.countMax * self.barHeight)
				self.text.text = string.format("%.2f%%", self.count / self.countMax * 100)

				print("WatchSkillItem:Update() -------------2")
			end
		end

		BaseUtils.SetGrey(self.skillIconLoader.image, combatHelpSkillData.skill_status ~= 1 or combatHelpSkillData.my_skill_status ~= 1)
		if combatHelpSkillData.skill_status ~= 1 or combatHelpSkillData.my_skill_status ~= 1 then
			self:ShowEffect(20499, false)
		else
			self:ShowEffect(20499, true, self.transform:Find("BarBg"), nil, Vector3(0, -90, -300))
		end

		if self.countMax == self.count then
			self:ShowEffect(20503, true, self.transform:Find("BarBg"), nil, Vector3(0, -60, -300))
			self:ShowEffect(20497, false)
		else
			self:ShowEffect(20497, true, self.transform:Find("BarBg"), nil, Vector3(0, 0, -300))
			self:ShowEffect(20503, false)
		end
	else
		self.countMax = self.watchSkillData.count

		self.barRect.sizeDelta = Vector2(self.barWidth, 0)
		self.text.text = "0%"

		BaseUtils.SetGrey(self.skillIconLoader.image, true)

		print("WatchSkillItem:Update() -------------3")
	end

	print("CombatManager.Instance.controller.mainPanel.round, "..CombatManager.Instance.controller.mainPanel.round)
end

function WatchSkillItem:OnButtonClick()
	local combatHelpSkillData = CombatManager.Instance.combatHelpSkillData[self.watchSkillData.skill_id]
	if combatHelpSkillData ~= nil then
		if combatHelpSkillData.skill_status == 1 then
			if combatHelpSkillData.my_skill_status == 1 then
				CombatManager.Instance:Send10777(self.watchSkillData.skill_id)
			else
				NoticeManager.Instance:FloatTipsByString("天雷即将开启，您的力量也可以帮助挑战队伍哟{face_1,3}")
			end
		else
			NoticeManager.Instance:FloatTipsByString("天雷即将开启，您的力量也可以帮助挑战队伍哟{face_1,3}")
		end
	end
end

function WatchSkillItem:SkillUseSuccess()
	self:ShowEffect(20498, true, self.transform:Find("BarBg"), nil, Vector3(0, -80, -300))
end

function WatchSkillItem:ShowEffect(effectId, show, transform, scale, position)
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

function WatchSkillItem:BeginFightRound(round)
	self.round = round
	local combatHelpSkillData = CombatManager.Instance.combatHelpSkillData[self.watchSkillData.skill_id]
BaseUtils.dump(combatHelpSkillData, "WatchSkillItem:BeginFightRound(round)")
print(round)
	if combatHelpSkillData ~= nil then
		if combatHelpSkillData.skill_status == 3 and combatHelpSkillData.round ~= round then -- 如果状态是3.释放中的话，在回合处才更新协议数据
			combatHelpSkillData.skill_status = 2
			self:Update()
		end
	end
end