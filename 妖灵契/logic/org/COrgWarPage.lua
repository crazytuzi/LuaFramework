local COrgWarPage = class("COrgWarPage", CPageBase)

function COrgWarPage.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function COrgWarPage.OnInitPage(self)
	self.m_GoBtn = self:NewUI(1, CButton)
	-- self.m_DescLabel = self:NewUI(2, CLabel)
	self.m_TipsBtn = self:NewUI(3, CButton)
	self.m_MapTexture = self:NewUI(4, CTexture)
	self.m_Btn1 = self:NewUI(5, CButton)
	self.m_Btn2 = self:NewUI(6, CButton)
	self:InitContent()
end

function COrgWarPage.InitContent(self)
	self.m_TipsBtn:AddUIEvent("click", callback(self, "ShowHelp"))
	self.m_GoBtn:AddUIEvent("click", callback(self, "OnGoBtn"))
	self:InitMiniMapView(2050)
end

function COrgWarPage.InitMiniMapView(self, resid)
	local resid = resid or g_MapCtrl:GetResID() or 1010 
	local pathName = string.format("Map2d/%s/minimap_%s.png", resid, resid)
	local function finishLoadMiniMap(textureRes, errcode)
		if Utils.IsNil(self) then
			return
		end
		if textureRes then
			self.m_MapTexture:SetMainTexture(textureRes)
		else
			return
		end
	end
	g_ResCtrl:LoadAsync(pathName, finishLoadMiniMap)
end

function COrgWarPage.OnGoBtn(self)
	g_OrgWarCtrl:WalkToOrgWar()
end

function COrgWarPage.ShowHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp("org_war")
	end)
end

return COrgWarPage