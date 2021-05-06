local CChatAttrCardPage = class("CChatAttrCardPage", CPageBase)

function CChatAttrCardPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatAttrCardPage.OnInitPage(self)
	self.m_FactoryScroll = self:NewUI(1, CFactoryPartScroll)
	self:InitContent()
end

function CChatAttrCardPage:InitContent()
	local oPart = self.m_FactoryScroll
	oPart:SetPartSize(2, 3)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			oBox.item = oBox:NewUI(1, CBox)
            oBox.item:NewUI(1,CSprite):SetSpriteName(tostring(dData.shape))
			oBox.item:AddUIEvent("click", callback(self, "OnEmoji", dData))
		    oBox.item:NewUI(3,CLabel):SetText(dData.grade)
            oBox.item:NewUI(4,CLabel):SetText(dData.name)
			oBox:SetActive(true)
			return oBox
		end
	end
	oPart:SetFactoryFunc(factory)
	local function data()
		local t = {}
		local g_AttrCtrl = g_AttrCtrl
		table.insert(t, {pid = g_AttrCtrl.pid,
						 shape = g_AttrCtrl.model_info.shape,
						 grade = g_AttrCtrl.grade,
                         name = g_AttrCtrl.name,
						 })
        local cardData = g_FriendCtrl:GetMyFriend()
		for k, v in ipairs(cardData) do
			v = g_FriendCtrl:GetFriend(v)
			local data = {
				pid = v.pid,
				shape = v.shape,
				grade = v.grade,
                name = v.name,
			}
			table.insert(t, data)
	    end
		return t
	end
	oPart:SetDataSource(data)
	oPart:RefreshAll()
end

function CChatAttrCardPage.OnEmoji(self, dData)
	self.m_ParentView:Send(LinkTools.GenerateAttrCardLink("名片-"..dData.name, dData.pid))
end

return CChatAttrCardPage