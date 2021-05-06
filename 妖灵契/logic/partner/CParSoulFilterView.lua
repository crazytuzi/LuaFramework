---------------------------------------------------------------
--御灵批量选中

---------------------------------------------------------------
local CParSoulFilterView = class("CParSoulFilterView", CViewBase)


function CParSoulFilterView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/ParSoulBatSelectView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CParSoulFilterView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox) 
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_SelectGrid = self:NewUI(3, CGrid)
	self.m_OkBtn = self:NewUI(4, CButton)
	self.m_SelectTable = 
	{
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
	}
	self.m_OkCallBack = nil	
	self:InitContent()
end

function CParSoulFilterView.InitContent(self)
	local t = 
	{
		[1] = "绿色",
		[2] = "蓝色",
		[3] = "紫色",
		[4] = "橙色",
		[5] = "红色",
	}
	local color = 
	{	
		[1] = "[007426]",
		[2] = "[0071d1]",
		[3] = "[c834ff]",
		[4] = "[ff5400]",
		[5] = "[ff0000]",
	}
	self.m_SelectGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
			oBox.m_QualityLabel = oBox:NewUI(1, CLabel)
			oBox.m_ToggleBtn = oBox:NewUI(2, CBox)
			oBox.m_QualityLabel:SetText(string.format("%s%s", color[idx], t[idx]))
			oBox.m_ToggleBtn:AddUIEvent("click", callback(self, "OnSelect", idx))
			if self.m_SelectTable[idx] == true then
				oBox.m_ToggleBtn:SetSelected(true)
			else
				oBox.m_ToggleBtn:SetSelected(false)
			end
		return oBox
	end)

	self.m_OkBtn:AddUIEvent("click", callback(self, "OnOk"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CParSoulFilterView.OnSelect(self, idx )
	self.m_SelectTable[idx] = not self.m_SelectTable[idx]
end

function CParSoulFilterView.OnOk(self)
	if self.m_OkCallBack then		
		self.m_OkCallBack(self.m_SelectTable)
	end
	self:CloseView()
end

function CParSoulFilterView.SetOkCallBack(self, cb)
	self.m_OkCallBack = cb
end

return CParSoulFilterView