local CChatEmojiPage = class("CChatEmojiPage", CPageBase)

function CChatEmojiPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatEmojiPage.OnInitPage(self)
	self.m_FactoryScroll = self:NewUI(1, CFactoryPartScroll)
	self.m_PageLabel = self:NewUI(2, CLabel)
	self:InitContent()
end

function CChatEmojiPage.InitContent(self)
	local oPart = self.m_FactoryScroll
	oPart:SetPartSize(7, 3)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			oBox.m_Sprtite = oBox:NewUI(1, CSprite)
			local sPrefix = string.format("#%d_", dData.idx)
			oBox.m_Sprtite:SetSpriteName(sPrefix.."00")
			oBox.m_Sprtite:SetNamePrefix(sPrefix)
			oBox.m_Sprtite:SetFramesPerSecond(4)
			oBox.m_Sprtite:AddUIEvent("click", callback(self, "OnEmoji", dData.idx))
			oBox:SetActive(true)
			return oBox
		end
	end
	oPart:SetFactoryFunc(factory)
	local function data()
		local t = {}
		for i= 1, 100 do
			table.insert(t, {idx = i})
		end
		return t
	end
	oPart:SetDataSource(data)
	oPart:SetRefreshDotCb(callback(self, "RefreshPage"))
	oPart:RefreshAll()
end

function CChatEmojiPage.RefreshPage(self, curpage, maxpage)
	local str = string.format("%d/%d", math.max(0, curpage), math.max(0, maxpage))
	self.m_PageLabel:SetText(str)
end


function CChatEmojiPage.OnEmoji(self, idx)
	self.m_ParentView:Send("#"..tostring(idx))
end

return CChatEmojiPage