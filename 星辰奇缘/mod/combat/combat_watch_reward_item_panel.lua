-- 战斗UI 观战奖励
WatchRewardItemPanel = WatchRewardItemPanel or BaseClass()

function WatchRewardItemPanel:__init(gameObject, iconObject)
    self.gameObject = gameObject
    self.iconObject = iconObject
    self.isShow = false
    self:InitPanel()

    self.itemList = {}
    self.effect = nil

    -- 漂浮的初始方向
    self.vectorList = { Vector2(0.2, 0.4), Vector2(0.4, 0.2), Vector2(-0.2, 0.4), Vector2(-0.4, 0.2), Vector2(0.2, -0.4), Vector2(0.4, -0.2), Vector2(-0.2, -0.4), Vector2(-0.4, -0.2)
    					,Vector2(0.15, 0.45), Vector2(0.45, 0.15), Vector2(-0.15, 0.45), Vector2(-0.45, 0.15), Vector2(0.15, -0.45), Vector2(0.45, -0.15), Vector2(-0.15, -0.45), Vector2(-0.45, -0.15) }
    -- 用过的方向
    self.usedVectorList = {}

    -- 漂浮的初始方向（向上飘）
    self.vectorList_Up = { Vector2(0.2, 0.4), Vector2(0.4, 0.2), Vector2(-0.2, 0.4), Vector2(-0.4, 0.2), Vector2(0.15, 0.45), Vector2(0.45, 0.15), Vector2(-0.15, 0.45), Vector2(-0.45, 0.15) }
    -- 用过的方向（向上飘）
    self.usedVectorList_Up = {}

    -- 漂浮的初始方向（向下飘）
    self.vectorList_Down = { Vector2(0.2, -0.4), Vector2(0.4, -0.2), Vector2(-0.2, -0.4), Vector2(-0.4, -0.2), Vector2(0.15, -0.45), Vector2(0.45, -0.15), Vector2(-0.15, -0.45), Vector2(-0.45, -0.15) }
    -- 用过的方向（向下飘）
    self.usedVectorList_Down = {}

    self.end_time = 0
end

function WatchRewardItemPanel:InitPanel()
	self.transform = self.gameObject.transform
	self.cloneItem = self.transform:Find("CloneItem").gameObject
	self.cloneItem:SetActive(false)

	self.timeText = self.iconObject.transform:Find("cd"):GetComponent(Text)
	self.iconLoader = SingleIconLoader.New(self.iconObject)
	self.iconLoader:SetSprite(SingleIconType.Item, 23255)

	self.iconObject:GetComponent(Button).onClick:AddListener(function() self:OnClickIcon() end)
end

function WatchRewardItemPanel:__delete()
	self:Hide()

	if self.itemList ~= nil then
		for i,v in ipairs(self.itemList) do
			v:DeleteMe()
		end
		self.itemList = nil
	end

	if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end

	if self.effect ~= nil then
    	self.effect:DeleteMe()
    end
end

function WatchRewardItemPanel:Show()
	self.isShow = true
	self.gameObject:SetActive(true)

	-- if self.itemList ~= nil then
	-- 	for i,v in ipairs(self.itemList) do
	-- 		v:Hide()
	-- 	end
	-- end

	self:SetCD(CombatManager.Instance.WatchLogmodel.watchRewardTime)

	if self.timer ~= nil then
		LuaTimer.Delete(self.timer)
	end
	self.timer = LuaTimer.Add(0, 10, function() self:Update() end)
end

function WatchRewardItemPanel:Hide()
	self.isShow = false
	self.gameObject:SetActive(false)

	if self.timer ~= nil then
		LuaTimer.Delete(self.timer)
	end

	if self.itemList ~= nil then
		for i,v in ipairs(self.itemList) do
			v:Hide()
		end
	end

	for i,v in ipairs(self.usedVectorList) do
		table.insert(self.vectorList, v)
	end
	self.usedVectorList = {}
end

-- 处理奖励列表
function WatchRewardItemPanel:SetInfo(data)
	self:CleanVector(#data)

	local id = 0
	for i,v in ipairs(data) do
		if not self:CheckItemExists(v) then
			id = v.id
			self:UpdateItem(v)
		end
	end

	if id ~= 0 then
		self:ShowEffect(id)
		print("-----------------")
	end
end

-- 判断奖励是否已创建
function WatchRewardItemPanel:CheckItemExists(data)
	for i,v in ipairs(self.itemList) do
		if v.isShow and v.reward_id == data.reward_id then
			return true
		end
	end

	return false
end

-- 创建或更新单个奖励
function WatchRewardItemPanel:UpdateItem(data)
	local item = nil
	for i,v in ipairs(self.itemList) do
		if v.isShow == false then
			item = v
			break
		end
	end
	if item == nil then
		item = WatchRewardItem.New(GameObject.Instantiate(self.cloneItem), self)
		item.transform:SetParent(self.transform)
		item.transform.localScale = Vector3.one
		item.transform.localPosition = Vector3.zero
		table.insert(self.itemList, item)
	end

	local vector2 = self:GetVector(data.id)
	print(vector2)
	-- item:SetInfo(60520, BaseUtils.BASE_TIME + 20, 1, vector2)
	local targetTransform = self:GetRewardTarget(data.id)
	item:SetInfo(data.type, data.end_time, targetTransform, data.reward_id, vector2)
	item:Show()
end

function WatchRewardItemPanel:GetVector(id)
	local vectorList = self.vectorList
	local usedVectorList = self.usedVectorList

	if id == 1 then
		vectorList = self.vectorList_Up
		usedVectorList = self.usedVectorList_Up
	elseif id == 2 or id == 3 then
		vectorList = self.vectorList_Down
		usedVectorList = self.usedVectorList_Down
	end

	-- 如果全部方向都用过了，重置一次
	if #vectorList == 0 then
		vectorList = usedVectorList
		usedVectorList = {}
	end
	-- 随机到的方向取出来放到已经用过的列表里面，下次不会随机到
	local index = math.random(#vectorList)
	local vector2 = table.remove(vectorList, index)
	table.insert(usedVectorList, vector2)

	return vector2
end

function WatchRewardItemPanel:CleanVector(num)
	-- 如果剩余可用方向不足，重置一次
	if #self.vectorList < num then
		self.vectorList = self.usedVectorList
		self.usedVectorList = {}
	end
	if #self.vectorList_Up < num then
		self.vectorList_Up = self.usedVectorList_Up
		self.usedVectorList_Up = {}
	end
	if #self.vectorList_Down < num then
		self.vectorList_Down = self.usedVectorList_Down
		self.usedVectorList_Down = {}
	end
end

function WatchRewardItemPanel:Update()
	local count = 0
	for i,v in ipairs(self.itemList) do
		if v.isShow then
			v:Update()
			count = count + 1
		end
	end
	
	if self.end_time > 0 then
		self:UpdateTime()
	end

	if count == 0 and self.end_time <= 0 then
		self:Hide()
	end
end

function WatchRewardItemPanel:SetCD(end_time)
	if end_time ~= nil then
		self.end_time = end_time
	end
end

function WatchRewardItemPanel:UpdateTime()
	local time = self.end_time - BaseUtils.BASE_TIME
	if time < 0 then
		self.timeText.text = "00:00"
		self.end_time = time
	else
		self.timeText.text = BaseUtils.formate_time_gap(time, ":", 0, BaseUtils.time_formate.MIN)
	end
end

function WatchRewardItemPanel:OnClickIcon()
	NoticeManager.Instance:FloatTipsByString(TI18N("倒计时为0时，诸神将会发出奖励"))
end

function WatchRewardItemPanel:GetRewardTarget(id)
	local target = self.transform
	if id == 1 then
		target = self.iconObject.transform
	elseif id == 2 then
		target = CombatManager.Instance.controller.mainPanel.mixPanel.combatVotePanel.icon2
	elseif id == 3 then
		target = CombatManager.Instance.controller.mainPanel.mixPanel.combatVotePanel.icon1
	end

	return target
end

function WatchRewardItemPanel:ShowEffect(id)
	local effectParent = self:GetRewardTarget(id)
    if self.effect == nil or BaseUtils.is_null(self.effect.gameObject) then
        local fun = function(effectView)
            if BaseUtils.is_null(self.gameObject) then
                GameObject.Destroy(effectView.gameObject)
                return
            end
            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(effectParent)
            effectObject.transform.localScale = Vector3.one
            effectObject.transform.localPosition = Vector3(0, 0, -400)
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            effectObject:SetActive(true)
        end
        self.effect = BaseEffectView.New({effectId = 20502, time = 2600, callback = fun})
    else
    	self.effect:SetActive(false)
        self.effect:SetActive(true)
    end
end