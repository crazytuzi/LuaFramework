local CBroadcastPage = class("CBroadcastPage", CPageBase)

CBroadcastPage.SCROLL_SPEED = 300

function CBroadcastPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CBroadcastPage.OnInitPage(self)
	self.m_CloneLabel = self:NewUI(1, CLabel)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_BroadcastList = {}

	-- Utils:AddTimer()
end

function CBroadcastPage.AddBroadcast(self, broadcast)
	table.insert(self.m_BroadcastList, broadcast)
end

function CBroadcastPage.IsEmpty(self)
	return next(self.m_BroadcastList)
end

function CBroadcastPage.Update(self)
	-- body
end

function CBroadcastPage.ShowBroadcast(self, broadcast)
	-- body
end

function CBroadcastPage.Hide(self)
	
end
return CBroadcastPage