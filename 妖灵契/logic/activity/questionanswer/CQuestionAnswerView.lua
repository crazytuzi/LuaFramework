local CQuestionAnswerView = class("CQuestionAnswerView", CViewBase)

function CQuestionAnswerView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/QuestionAnswer/AnswerMainView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
end

function CQuestionAnswerView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_QuestionLabel = self:NewUI(2, CLabel)
	self.m_AnswerGrid = self:NewUI(3, CGrid)
	self.m_AnswerItem = self:NewUI(4, CBox)
	self.m_TimeLabel = self:NewUI(5, CLabel)
	self.m_Container = self:NewUI(6, CWidget)
	self.m_RightLabel = self:NewUI(7, CLabel)
	self:InitContent()
end

function CQuestionAnswerView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_AnswerItem:SetActive(false)
	self.m_RightLabel:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	local QACtrl = g_ActivityCtrl:GetQuesionAnswerCtrl()
	QACtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnActivityEvent"))
end

function CQuestionAnswerView.OnActivityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Activity.Event.QAAdd then
		self:RefreshData(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Activity.Event.QAResult then
		self:RefreshAnswer(oCtrl.m_EventData)
	end
end

function CQuestionAnswerView.RefreshData(self, data)
	self.m_QuestionLabel:SetText(data["desc"])
	self.m_Data = data
	self.m_AnswerGrid:Clear()
	self.m_AnswerGrid:SetActive(true)
	self.m_RightLabel:SetActive(false)
	for i, sAnswer in ipairs(data["answer_list"]) do
		local itemobj = self:CreateItem()
		itemobj.m_Label:SetText(string.char(string.byte("A")+i-1) ..".".. sAnswer)
		self.m_AnswerGrid:AddChild(itemobj)
		itemobj.m_Answer = i
		itemobj:AddUIEvent("click", callback(self, "OnAnswer", i))
	end
	self.m_AnswerGrid:Reposition()
	self.m_LeftTime = data["end_time"] - g_TimeCtrl:GetTimeS()
	self:CreateTimer()
	self:RefreshLastAnswer()
end

function CQuestionAnswerView.RefreshAnswer(self, data)
	if data["id"] == self.m_Data["id"] then
		if data["result"] == 1 then
			self:OnClose()
		elseif data["result"] == 0 then
			for _, itemobj in ipairs(self.m_AnswerGrid:GetChildList()) do
				if itemobj.m_Answer == data["answer"] then
					itemobj.m_ErrorSpr:SetActive(true)
				else
					itemobj.m_ErrorSpr:SetActive(false)
				end
			end
		end
	end
end

function CQuestionAnswerView.CreateTimer(self)
	local function updatetime()
		if Utils.IsNil(self) then
			return
		end
		self.m_LeftTime = self.m_LeftTime - 1
		if self.m_LeftTime < 0 then
			local str = self:GetLeftTime(0)
			self.m_TimeLabel:SetText(str)
			self:OnClose()
		else
			local str = self:GetLeftTime(self.m_LeftTime)
			self.m_TimeLabel:SetText(str)
			return true
		end
	end
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
	end
	self.m_Timer = Utils.AddTimer(updatetime, 1, 0)
end

function CQuestionAnswerView.GetLeftTime(self, iSec)
	local s = g_TimeCtrl:GetLeftTime(iSec)
	return s
end
function CQuestionAnswerView.CreateItem(self)
	local itemobj = self.m_AnswerItem:Clone()
	itemobj:SetActive(true)
	itemobj.m_Label = itemobj:NewUI(1, CLabel)
	itemobj.m_ErrorSpr = itemobj:NewUI(2, CSprite)
	itemobj.m_ErrorSpr:SetActive(false)
	return itemobj
end

function CQuestionAnswerView.OnAnswer(self, idx)
	nethuodong.C2GSAnswerQuestion(self.m_Data["id"], self.m_Data["type"], idx)
end

function CQuestionAnswerView.RefreshLastAnswer(self)
	local result = g_ActivityCtrl:GetQuesionAnswerCtrl():GetMyAnswerResult()
	if result and result["type"] == 1 and result["id"] == self.m_Data["id"] and result["result"] == 1 then
		self.m_AnswerGrid:SetActive(false)
		self.m_RightLabel:SetActive(true)
	end
end


return CQuestionAnswerView
