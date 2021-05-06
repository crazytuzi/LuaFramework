local CPartnerBookBox = class("CPartnerBookBox", CBox)

function CPartnerBookBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_ConditionGrid = self:NewUI(2, CGrid)
	self.m_ConditionLabel = self:NewUI(3, CLabel)
	self.m_LockSpr = self:NewUI(4, CSprite)
	self.m_GreySpr = self:NewUI(5, CSprite)
	self.m_RepairBtn = self:NewUI(6, CButton)
	self.m_RedSpr = self:NewUI(7, CSprite)
	self.m_Slider = self:NewUI(8, CSlider)
	self.m_ProgressLabel = self:NewUI(9, CLabel)
	self.m_PartnerTexture = self:NewUI(10, CTexture)
	self.m_PressTipObj = self:NewUI(11, CWidget)
	self.m_PartnerTaskAcceptBtn = self:NewUI(12, CButton)
	self.m_PartnerTaskDoingBtn = self:NewUI(13, CButton)
	self.m_PartnerTaskBox = self:NewUI(14, CBox)
	self.m_PartnerTaskMaskBtn = self:NewUI(15, CButton)
	self:InitContent()
end

function CPartnerBookBox.InitContent(self)
	self.m_PressTipObj:AddUIEvent("longpress", function (a, bPress)
		if bPress then
			g_NotifyCtrl:FloatMsg("章节阅读数量")
		end
	end)
	self.m_PartnerTaskAcceptBtn:AddUIEvent("click", callback(self, "OnClickPartnerTask"))
	self.m_PartnerTaskDoingBtn:AddUIEvent("click", callback(self, "OnClickPartnerTask"))
	self.m_PartnerTaskMaskBtn:AddUIEvent("click", callback(self, "OnClickPartnerMask"))
	self.m_ConditionLabel:SetActive(false)
	self.m_PartnerTaskBox:SetActive(false)
end

function CPartnerBookBox.RefreshData(self, oData)
	self.m_Data = oData
	self.m_ID = oData.id
	self:RefreshName()
	self:RefreshCondition()
	self:RefreshIcon()
	self:RefreshRepair()
	self:RefreshProgress()
	self:RefreshRedSpr()
	self:RefreshShow()
	self:RefreshPartnerBox()	--刷新伙伴支线，会改变上面的UI显示和隐藏
end

function CPartnerBookBox.RefreshName(self)
	local oData = self.m_Data
	self.m_NameLabel:SetText(oData.name)
	self.m_NameLabel:SetActive(oData.entry_name ~= 0)
	if oData.unlock == 0 then
		self.m_NameLabel:SetActive(false)
	end
end

function CPartnerBookBox.RefreshCondition(self)
	local oData = self.m_Data
	self.m_ConditionGrid:SetActive(true)
	self.m_ConditionGrid:Clear()
	local conditiondata = data.mapbookdata.CONDITION
	for i, iCondition in ipairs(oData.condition_list) do
		if conditiondata[iCondition] and conditiondata[iCondition]["sub_type"] ~= 3 then
			local label = self.m_ConditionLabel:Clone()
			label:SetActive(true)
			label:SetText(conditiondata[iCondition]["desc"])
			self.m_ConditionGrid:AddChild(label)
		end
	end
	self.m_ConditionGrid:Reposition()
end

function CPartnerBookBox.RefreshIcon(self)
	local oData = self.m_Data
end

function CPartnerBookBox.RefreshShow(self)
	local iPartnerID = self.m_Data.target_id
	local pdata = data.partnerdata.DATA[iPartnerID]
	self.m_PartnerTexture:SetActive(false)
	if pdata then
		self.m_PartnerTexture:LoadCardPhoto(pdata["shape"], function()
			self.m_PartnerTexture:SetActive(true)
		end)
	end
	if self.m_Data.unlock == 0 then
		self.m_GreySpr:SetActive(true)
		self.m_PressTipObj:SetActive(false)
		self.m_PartnerTexture:SetColor(Utils.HexToColor("090707ff"))
	else
		self.m_PartnerTexture:SetColor(Utils.HexToColor("ffffffff"))
		self.m_GreySpr:SetActive(false)
		self.m_PressTipObj:SetActive(true)
	end
end

function CPartnerBookBox.RefreshRepair(self)
	if self.m_Data.show ~= 0 and self.m_Data.repair == 0 then
		self.m_RepairBtn:SetActive(true)
	else
		self.m_RepairBtn:SetActive(false)
	end
end

function CPartnerBookBox.RefreshProgress(self)
	local amount, total = self:GetProgress(self.m_Data)
	self.m_Slider:SetValue(amount / total)
	self.m_ProgressLabel:SetText(string.format("章节：%d/%d", amount, total))
	self.m_Slider:SetActive(self.m_Data.unlock == 1)
	local bNewChapter = false
	for _, oChapter in ipairs(self.m_Data.chapter) do
		local scondition = oChapter.condition or {}
		local cdata = data.mapbookdata.CHAPTER[oChapter.id]
		if oChapter.unlock == 1 and #cdata.condition == #scondition and oChapter.read == 0 then
			bNewChapter = true
			break
		end
	end

	if amount == total and bNewChapter == false then
		self.m_Slider:SetActive(false)
	end
end

function CPartnerBookBox.GetProgress(cls, oData)
	local total = #oData.chapter_list
	local amount = 0
	for _, oChapter in ipairs(oData.chapter) do
		if oChapter.unlock == 1 then
			amount = amount + 1
		end
	end
	return amount, total
end

function CPartnerBookBox.RefreshRedSpr(self)
	if self.m_Data.red_point and self.m_Data.red_point >= 1 then
		self.m_RedSpr:SetActive(true)
	else
		self.m_RedSpr:SetActive(false)
	end
	if self.m_Data.unlock == 0 then
		self.m_RedSpr:SetActive(false)
	end
end

function CPartnerBookBox.OnClickPartnerTask(self)
	if self.m_Data then	
		CTaskPartTipsView:ShowView(function (oView)
			oView:SetData(self.m_Data.target_id)
		end)
	end
end

function CPartnerBookBox.RefreshPartnerBox(self)
	self.m_PartnerTaskBox:SetActive(false)
	if self.m_Data then
		local d = g_TaskCtrl:GetPartnerTaskProgressData(self.m_Data.target_id)
		if d then
			self.m_PartnerTaskBox:SetActive(d.status == 1 or d.status == 2)
			self.m_PartnerTaskAcceptBtn:SetActive(d.status == 1)
			self.m_PartnerTaskDoingBtn:SetActive(d.status == 2)
			if d.status == 1 or d.status == 2 then
				self.m_ConditionGrid:SetActive(false)
				self.m_RepairBtn:SetActive(false)
				self.m_ProgressLabel:SetText("")
				self.m_Slider:SetActive(false)				
				self.m_RedSpr:SetActive(false)
				self.m_GreySpr:SetActive(false)
			end
		end	
	end
end

function CPartnerBookBox.OnClickPartnerMask(self)
	g_NotifyCtrl:FloatMsg("任务未完成，无法取阅该资料")
end

return CPartnerBookBox