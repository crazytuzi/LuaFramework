RegressionLoginChestboxNoticeItem = RegressionLoginChestboxNoticeItem or BaseClass()

function RegressionLoginChestboxNoticeItem:__init(gameObject, endCallback)
	self.gameObject = gameObject
	self.endCallback = endCallback
	self.transform = self.gameObject.transform
	self.content = MsgItemExt.New(self.gameObject:GetComponent(Text), 2048, 17)
	self.rect = self.gameObject:GetComponent(RectTransform)
	self.index = 1
	self.tweenCall = function() self:Reset() end
	self.timeCall = function() self:End() end
end

function RegressionLoginChestboxNoticeItem:__delete()
	self:Stop()
	if self.content ~= nil then
		self.content:DeleteMe()
		self.content = nil
	end
end

function RegressionLoginChestboxNoticeItem:Reset()
	self.rect.anchoredPosition = Vector2(465, 0)
	self:Stop()
end

function RegressionLoginChestboxNoticeItem:Stop()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
	if self.tweenId ~= nil then
		Tween.Instance:Cancel(self.tweenId)
		self.tweenId = nil
	end
end

function RegressionLoginChestboxNoticeItem:Run()
	self:Reset()
	self.index = RegressionManager.Instance.model:GetRollNoticeIndex()
	self.msg = RegressionManager.Instance.model.rainbow_notice_list[self.index]
	if self.msg == nil then
		self:End()
	else
		self.content:SetData(self.msg.msg)
		local target = self.content.selfWidth
		local time = math.ceil((target + 400) / 60)
		self.tweenId = Tween.Instance:MoveLocalX(self.gameObject, -target - 250, time, self.timeCall, LeanTweenType.linear).id
	end
end

function RegressionLoginChestboxNoticeItem:End()
	if self.endCallback ~= nil then
		self.endCallback()
	end
	self:Reset()
end