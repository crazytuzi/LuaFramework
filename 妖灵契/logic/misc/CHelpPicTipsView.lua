local CHelpPicTipsView = class("CHelpPicTipsView", CViewBase)

function CHelpPicTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Misc/HelpPicTipsView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_DepthType = "Dialog"
end

function CHelpPicTipsView.OnCreateView(self)
	self.m_DesTexture = self:NewUI(1, CTexture)
	self.m_ScorllView = self:NewUI(2, CScrollView)
	self.m_PicGrid = self:NewUI(3, CGrid)
	self.m_PicCloneBox = self:NewUI(4, CBox)
	self.m_DesLabel = self:NewUI(5, CLabel)
	self.m_RightBtn = self:NewUI(6, CButton)
	self.m_LeftBtn = self:NewUI(7, CButton)
	self.m_Container = self:NewUI(8, CBox)
	self.m_Timer = nil
	self.m_LastTablePos = nil
	self.m_CurrentCenter = nil
	self.m_CurIdx = nil
	self.m_PicAarray = {}
	self.m_HelpData = {}
	self:InitContent()
	self:SetData()
end

function CHelpPicTipsView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_PicCloneBox:SetActive(false)
	self.m_LeftBtn:AddUIEvent("click", callback(self, "OnClickLeft"))
	self.m_RightBtn:AddUIEvent("click", callback(self, "OnClickRight"))
	self.m_DesLabel:SetText("")
end

function CHelpPicTipsView.SetData(self, helpData)
	if not helpData or #helpData == 0 then
		self:OnClose()
		return
	end
	self.m_PicAarray = {}
	self.m_HelpData = {}
	for i = 1, #helpData do
		local oBox = self.m_PicCloneBox:Clone()
		oBox:SetActive(true)
		oBox:SetName(tostring(i))
		oBox.m_BGTexture = oBox:NewUI(1, CTexture)
		oBox.m_BorderTexture = oBox:NewUI(2, CTexture)
		oBox.m_Label = oBox:NewUI(3, CLabel)
		oBox.m_DesTexture = oBox:NewUI(4, CTexture) 
		oBox.m_BgSpr = oBox:NewUI(5, CSprite)
		local list = string.split(helpData[i], ";")
		if list and #list == 2 then
			self.m_HelpData[i] = self.m_HelpData[i] or {}
			self.m_HelpData[i].pic = tostring(list[1])
			self.m_HelpData[i].msg = tostring(list[2])
		end
		oBox.m_Label:SetText(self.m_HelpData[i].msg)
		local path = string.format("Texture/Help/%s.png", self.m_HelpData[i].pic)
		oBox.m_BGTexture:LoadPath(path)
		table.insert(self.m_PicAarray, oBox)
		self.m_PicGrid:AddChild(oBox)
	end
	self:UpdateScale()
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	self.m_Timer = Utils.AddTimer(callback(self, "UpdateScale"), 0 , 0)

end

function CHelpPicTipsView.UpdateScale(self)
	if Utils.IsNil(self) then
		return false
	end
	if self:GetActive() == false then
		return true
	end

	local tablePos = self.m_ScorllView:GetLocalPos().x
	if self.m_LastTablePos == tablePos then
		local oChild = self.m_PicAarray[1]
		if oChild and oChild:GetLocalPos().y == 0 then
		else
			return true
		end
	end
	self.m_LastTablePos = tablePos
	local depthflag = false
	for i,v in ipairs(self.m_PicAarray) do
		local pos = v:GetLocalPos()
		local scaleValue = 1 - (math.abs(126 + pos.x + tablePos)) * 0.002
		if scaleValue < 0.8 then
			scaleValue = 0.8
		end
		v:SetLocalScale(Vector3.New(scaleValue, scaleValue, scaleValue))
		local w, h = v:GetSize()
		v:SetLocalPos(pos)
		if math.abs(scaleValue - 0.8) < 0.02 then
			depthflag = true
		end
	end
	if depthflag then
		for i,v in ipairs(self.m_PicAarray) do
			local scaleValue = v:GetLocalScale().x
			local offsetDepth = - i * 10
			if math.abs(scaleValue - 0.8) < 0.02 then
				v:SetDepth(191 + offsetDepth )
				v.m_BGTexture:SetDepth(193 + offsetDepth)				
				v.m_DesTexture:SetDepth(194 + offsetDepth)
				v.m_Label:SetDepth(195 + offsetDepth)
				v.m_BgSpr:SetDepth(192 + offsetDepth)
			else
				v:SetDepth(260)
				v.m_BGTexture:SetDepth(280)				
				v.m_DesTexture:SetDepth(290)
				v.m_Label:SetDepth(300)
				v.m_BgSpr:SetDepth(270)
			end
		end
	end
	self:OnCenter()
	return true
end

function CHelpPicTipsView.OnCenter(self, obj)
	local centerObj = obj or self.m_ScorllView:GetCenteredObject()
	if centerObj == nil or self.m_CurrentCenter == centerObj then
		return
	end
	self.m_CurrentCenter = centerObj

	self:OnSelectIdx(tonumber(centerObj.name))
end


function CHelpPicTipsView.OnSelectIdx(self, idx)
	self.m_CurIdx = idx
	local d = self.m_HelpData[idx]
	if d then
		self.m_DesLabel:SetText(d.msg)
	end
	self:UpdateDirButton()
end

function CHelpPicTipsView.UpdateDirButton(self)
	self.m_LeftBtn:SetActive(false)
	self.m_RightBtn:SetActive(false)
	if self.m_CurIdx and #self.m_PicAarray > 2 then
		if self.m_CurIdx < #self.m_PicAarray then
			self.m_LeftBtn:SetActive(true)
		end
		if self.m_CurIdx > 1 then
			self.m_RightBtn:SetActive(true)
		end
	end
end

function CHelpPicTipsView.OnClickLeft(self)
	if self.m_CurIdx and #self.m_PicAarray > 2 then
		if self.m_CurIdx ~= #self.m_PicAarray then
			self.m_CurIdx = self.m_CurIdx + 1
			local oBox = self.m_PicAarray[self.m_CurIdx]
			if oBox then
				self.m_ScorllView:CenterOn(oBox.m_Transform)
			end
		end
	end
end

function CHelpPicTipsView.OnClickRight(self)
	if self.m_CurIdx and #self.m_PicAarray > 2 then
		if self.m_CurIdx ~= 1 then
			self.m_CurIdx = self.m_CurIdx - 1
			local oBox = self.m_PicAarray[self.m_CurIdx]
			if oBox then
				self.m_ScorllView:CenterOn(oBox.m_Transform)
			end
		end
	end
end

function CHelpPicTipsView.Destroy(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	local oView = CHelpView:GetView()
	if oView then
		oView:SetActive(true)
	end
	CViewBase.Destroy(self)
end

return CHelpPicTipsView