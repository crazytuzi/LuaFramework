local CPersonBookBox = class("CPersonBookBox", CBox)

function CPersonBookBox.ctor(self, obj)
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
	self.m_AutoGotoBtn = self:NewUI(12, CButton)
	self:InitContent()
end

function CPersonBookBox.InitContent(self)
	self.m_PressTipObj:AddUIEvent("longpress", function (a, bPress) if bPress then g_NotifyCtrl:FloatMsg("已挑战次数/可挑战次数") end end)
	self.m_ConditionLabel:SetActive(false)
	self.m_AutoGotoBtn:AddUIEvent("click", callback(self, "OnAutoGoto"))
end

function CPersonBookBox.RefreshData(self, oData)
	self.m_Data = oData
	self.m_AutoGotoBtn:ClearEffect("Finger")
	if oData.name == "李铁蛋" then
		g_GuideCtrl:AddGuideUI("mapbook_person_1007_reward_btn", self.m_AutoGotoBtn)
	end

	self.m_ID = oData.id
	self:RefreshName()
	self:RefreshCondition()
	self:RefreshIcon()
	self:RefreshShow()
	self:RefreshRepair()
	self:RefreshProgress()
	self:RefreshRedSpr()
end

function CPersonBookBox.RefreshName(self)
	local oData = self.m_Data
	self.m_NameLabel:SetText(oData.name)
	self.m_NameLabel:SetActive(oData.entry_name ~= 0)
end

function CPersonBookBox.RefreshCondition(self)
	local oData = self.m_Data
	self.m_ConditionGrid:Clear()
	local conditiondata = data.mapbookdata.CONDITION
	for i, iCondition in ipairs(oData.condition_list) do
		if conditiondata[iCondition] then
			local label = self.m_ConditionLabel:Clone()
			label:SetActive(true)
			label:SetText(conditiondata[iCondition]["desc"])
			self.m_ConditionGrid:AddChild(label)
		end
	end
	self.m_ConditionGrid:Reposition()
end

function CPersonBookBox.RefreshIcon(self)
	local oData = self.m_Data
end

function CPersonBookBox.RefreshShow(self)
	local iPartnerID = self.m_Data.npc_type
	local pdata = data.npcdata.NPC.GLOBAL_NPC[iPartnerID]
	local shape = pdata["modelId"]
	-- if table.index(t, pdata["modelId"]) then
	-- 	shape = 301
	-- end
	if pdata then
		self.m_PartnerTexture:LoadCardPhoto(shape)
	end
	if self.m_Data.unlock == 0 then
		self.m_GreySpr:SetActive(true)
		self.m_Slider:SetActive(false)
		self.m_PressTipObj:SetActive(false)
		self.m_NameLabel:SetActive(false)
		self.m_PartnerTexture:SetColor(Utils.HexToColor("090707ff"))
	else
		self.m_PartnerTexture:SetColor(Utils.HexToColor("ffffffff"))
		self.m_Slider:SetActive(true)
		self.m_NameLabel:SetActive(true)
		self.m_GreySpr:SetActive(false)
		self.m_PressTipObj:SetActive(true)
	end
end

function CPersonBookBox.RefreshRepair(self)
	if self.m_Data.show ~= 0 and self.m_Data.repair == 0 then
		self.m_RepairBtn:SetActive(true)
	else
		self.m_RepairBtn:SetActive(false)
	end
end

function CPersonBookBox.RefreshProgress(self)
	local total = #self.m_Data.chapter_list
	local amount = self.m_Data.fight or 0
	local total =  self.m_Data.total or 0
	self.m_Slider:SetValue(amount / total)
	self.m_AutoGotoBtn:SetActive(amount < total)
	self.m_ProgressLabel:SetText(string.format("挑战：%d/%d", amount, total))
end

function CPersonBookBox.RefreshRedSpr(self)
	local bNewChapter = false
	for _, oChapter in ipairs(self.m_Data.chapter) do
		if oChapter.unlock == 1 and oChapter.read == 0 then
			bNewChapter = true
			break
		end
	end
	self.m_RedSpr:SetActive(bNewChapter)
end

function CPersonBookBox.OnAutoGoto(self)
	CPersonBookAwardView:ShowView(function (oView)
		oView:SetData(self.m_Data)
	end)
	g_GuideCtrl:ReqForwardTipsGuideFinish("mapbook_person_1007_reward_btn")
end

return CPersonBookBox