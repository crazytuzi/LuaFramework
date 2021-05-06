local CChatHistoryPage = class("CChatHistoryPage", CPageBase)

function CChatHistoryPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatHistoryPage.OnInitPage(self)
	self.m_FactoryScroll = self:NewUI(1, CFactoryPartScroll)
	self.m_PageLabel = self:NewUI(2, CLabel)
	self:InitContent()
end

function CChatHistoryPage.InitContent(self)
	local oPart = self.m_FactoryScroll
	oPart:SetPartSize(2, 4)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			oBox.m_Label = oBox:NewUI(1, CLabel)
			oBox.m_Label:SetText(LinkTools.GetPrintedText(dData))
			oBox:AddUIEvent("click", callback(self, "OnEmoji", dData))
			oBox:SetActive(true)
			return oBox
		end
	end
	oPart:SetFactoryFunc(factory)
	local function data()
		local t = {}
		for _, sMsg in ipairs(g_ChatCtrl:GetHistory()) do
			table.insert(t, sMsg)
		end
		return t
	end
	oPart:SetDataSource(data)
	oPart:SetRefreshDotCb(callback(self, "RefreshPage"))
	oPart:RefreshAll()
end

function CChatHistoryPage.RefreshPage(self, curpage, maxpage)
	local str = string.format("%d/%d", math.max(0, curpage), math.max(0, maxpage))
	self.m_PageLabel:SetText(str)
end


function CChatHistoryPage.OnEmoji(self, sMsg)
	self.m_ParentView:Send(sMsg)
end

return CChatHistoryPage