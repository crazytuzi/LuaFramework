-- 战斗UI 观战奖励
WatchRewardItem = WatchRewardItem or BaseClass()

function WatchRewardItem:__init(gameObject)
    self.gameObject = gameObject
    self.isShow = false
    self.canMove = false
    self.hideTimeCountMax = 28
    self.hideTimeCount = 0
    self.reward_id = 0

    self.scaleTween = nil
    self.speedTween = nil

    self:InitPanel()
end

function WatchRewardItem:InitPanel()
	self.transform = self.gameObject.transform

	self.itemBg = self.transform:Find("ItemBg").gameObject
	self.iconLoader = SingleIconLoader.New(self.transform:Find("ItemBg/Icon").gameObject)

	self.itemBg:GetComponent(Button).onClick:AddListener(function() self:OnButtonClick() end)
end

function WatchRewardItem:__delete()
	self:Hide()

    if self.skillIconLoader ~= nil then
        self.skillIconLoader:DeleteMe()
    end
end

function WatchRewardItem:Show()
	self.isShow = true
	self.gameObject:SetActive(true)

	self.canMove = false
	self.itemBg:SetActive(false)
	self.hideTimeCount = 0
end

function WatchRewardItem:Hide()
	self.isShow = false
	self.gameObject:SetActive(false)

	self.canMove = false
	self.itemBg:SetActive(false)

	if self.scaleTween ~= nil then
		Tween.Instance:Cancel(self.scaleTween)
		self.scaleTween = nil
	end
	if self.speedTween ~= nil then
		Tween.Instance:Cancel(self.speedTween)
		self.speedTween = nil
	end
end

function WatchRewardItem:SetInfo(type, time, targetTransform, reward_id, Vector)
	self.reward_id = reward_id

	local itemId = 22534
	if type == 1 then
		itemId = 22534
	elseif type == 2 then
		itemId = 22534
	elseif type == 3 then
		itemId = 22533
	end
	self.iconLoader:SetSprite(SingleIconType.Item, itemId)

	self.time = time

	self.speed = 5
	self.Vector = Vector
	self.transform.anchoredPosition = Vector2(0, 0)

	local parentRect = self.transform.parent:GetComponent(RectTransform).rect
	local rect = self.transform:GetComponent(RectTransform).rect
	self.outSideX = (parentRect.width - rect.width) / 2
	self.outSideY = (parentRect.height - rect.height) / 2
	-- self.outSideX = (parentRect.width) / 2
	-- self.outSideY = (parentRect.height) / 2

	if CombatManager.Instance.controller ~= nil and CombatManager.Instance.controller.brocastCtx ~= nil and CombatManager.Instance.controller.combatCamera ~= nil then
		if targetTransform ~= nil then
			local pos = targetTransform.position
	    	-- local wpos = CombatUtil.WorldToUIPoint(CombatManager.Instance.controller.combatCamera, pos)
	    	-- self.transform.localPosition = wpos
	    	self.transform.position = pos
	    end
   	end

   	-- 移动速度tween
   	self.speed = 18
   	if self.speedTween ~= nil then
		Tween.Instance:Cancel(self.speedTween)
		self.speedTween = nil
	end
   	self.speedTween = Tween.Instance:ValueChange(18, 5, 5, function()
   			if self.speedTween ~= nil then
				Tween.Instance:Cancel(self.speedTween)
				self.speedTween = nil
			end
        end, LeanTweenType.easeOutCubic, function(value)
            self.speed = value
        end).id

   	-- 缩放tween
   	self.transform.localScale = Vector3.zero
	if self.scaleTween ~= nil then
		Tween.Instance:Cancel(self.scaleTween)
		self.scaleTween = nil
	end
   	self.scaleTween = Tween.Instance:Scale(self.transform, Vector3.one, 3, function()
            if self.scaleTween ~= nil then
				Tween.Instance:Cancel(self.scaleTween)
				self.scaleTween = nil
			end
        end, LeanTweenType.linear).id
end

function WatchRewardItem:Update()
	if not self.isShow then
		return
	end

	if not self.canMove then
		self.hideTimeCount = self.hideTimeCount + 1
		if self.hideTimeCount > self.hideTimeCountMax then
			self.canMove = true
			self.itemBg:SetActive(true)
		end
		return
	end

	local pos = self.transform.anchoredPosition
	local vector = self.Vector * self.speed
	local newPosition = Vector2(pos.x + vector.x, pos.y + vector.y)

	if newPosition.x > self.outSideX or newPosition.x < self.outSideX * -1 then
		self.Vector = Vector2(self.Vector.x * -1, self.Vector.y)
		vector = self.Vector * self.speed
		newPosition = Vector2(pos.x + vector.x, pos.y + vector.y)
	end

	if newPosition.y > self.outSideY or newPosition.y < self.outSideY * -1 then
		self.Vector = Vector2(self.Vector.x, self.Vector.y * -1)
		vector = self.Vector * self.speed
		newPosition = Vector2(pos.x + vector.x, pos.y + vector.y)
	end

	self.transform.anchoredPosition = newPosition

	if self.time < BaseUtils.BASE_TIME then
		self:Hide()
	end
end

function WatchRewardItem:OnButtonClick()
	self:Hide()
	CombatManager.Instance:Send10779(CombatManager.Instance.combatType, self.reward_id)
end