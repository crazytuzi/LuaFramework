local CBroadcastBox = class("CBroadcastBox", CBox)

CBroadcastBox.SCROLL_SPEED = 200
CBroadcastBox.BROADCAST_COUNT = 2

function CBroadcastBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_MsgLabel = self:NewUI(1, CLabel)
	self.m_ScrollView = self:NewUI(2, CScrollView)

	self.m_BroadcastList = {}

	self.m_NextBroadTime = 0
	self.m_delta = 0.1
	self.m_ScrollArea = 0

	self.m_Front = 1
	self.m_Index = 1

	self:InitContent()
end

function CBroadcastBox.InitContent(self)
	self.m_ScrollArea = self:GetSize()

	local pos = self.m_MsgLabel:GetPos()
	pos.x = self.m_ScrollArea/2
	self.m_MsgLabel:SetPos(pos)
	--Test
	-- self:AddBroadcast("[0000ff]温馨提示：[-]合理安排游戏时间，享受健康生活")
	-- self:AddBroadcast("测试2：啊士大夫艰苦拉萨觉得刷卡积分的雷克萨")
	-- self:AddBroadcast("测试3：[00ff00]手卡机[-]vljdsafj老牛舐犊")

	 Utils.AddTimer(callback(self, "Update"), self.m_delta, 0)
end

function CBroadcastBox.AddBroadcast(self, broadcast)
	self.m_BroadcastList[self.m_Index] = broadcast
	self.m_Index = self.m_Index + 1
	self:SetActive(true)
end

function CBroadcastBox.GetFrontBroadcast(self)
	local msg = self.m_BroadcastList[self.m_Front]
	if msg then
		self.m_Front = self.m_Front + 1
	end
	return msg
end

function CBroadcastBox.IsEmpty(self)
	return next(self.m_BroadcastList)
end

function CBroadcastBox.Update(self)
	if self.m_NextBroadTime <= 0 then
		local broadcast = self:GetFrontBroadcast()
		if broadcast then
			self:ShowBroadcast(broadcast)
		else
			self:SetActive(false)
		end
	end
	self.m_NextBroadTime = self.m_NextBroadTime - self.m_delta
	return true
end

function CBroadcastBox.ShowBroadcast(self, msg)
	self.m_MsgLabel:SetText(msg)

	local iWidth = self.m_MsgLabel:GetSize()
	local iScrollLen = iWidth + self.m_ScrollArea + 80
	local iUseTime = iScrollLen/CBroadcastBox.SCROLL_SPEED
	self.m_NextBroadTime = (iUseTime)*CBroadcastBox.BROADCAST_COUNT
	local tweenPos = self.m_MsgLabel:GetComponent(classtype.TweenPosition)

	tweenPos.enabled = false
	tweenPos:ResetToBeginning()

	local from = tweenPos.from
	local to = tweenPos.to
	to.x = from.x - iScrollLen
	tweenPos.to = to
	tweenPos.duration = iUseTime
	tweenPos.enabled = true
end

function CBroadcastBox.Hide(self)
	
end
return CBroadcastBox