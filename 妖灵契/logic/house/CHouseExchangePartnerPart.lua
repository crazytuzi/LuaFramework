local CHouseExchangePartnerPart = class("CHouseExchangePartnerPart", CBox)

function CHouseExchangePartnerPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_InfoPart = self:NewUI(1, CBox)
	self.m_TaskPart = self:NewUI(2, CBox)
	self.m_VoicePart = self:NewUI(3, CBox)
	self.m_TaskBtn = self:NewUI(4, CBox)
	self.m_DataBtn = self:NewUI(5, CBox)
	self.m_VoiceBtn = self:NewUI(6, CBox)
	self.m_RewardPart = self:NewUI(7, CHouseExchangeTaskRewardPart)
	self:InitContent()
end

function CHouseExchangePartnerPart.InitContent(self)
	self.m_DataKey = {
		{key = "birth", title = "生日"},
		{key = "height", title = "身高"},
		{key = "star", title = "星座"},
		{key = "weight", title = "体重"},
		{key = "blood", title = "血型"},
		{key = "bwh", title = "三围"},
		-- {key = "like", title = "喜欢"},
		-- {key = "hate", title = "讨厌"},
		-- {key = "family", title = "家族"},
		-- {key = "secret", title = "秘密"},
	}
	self:InitInfoPart()
	self:InitTaskPart()
	self:InitBtn(self.m_TaskBtn)
	-- self:InitBtn(self.m_VoiceBtn)
	self:InitBtn(self.m_DataBtn)
	self.m_RewardPart:SetActive(false)
end

function CHouseExchangePartnerPart.InitInfoPart(self)
	local oInfoPart = self.m_InfoPart
	oInfoPart.m_AvatarSprite = oInfoPart:NewUI(1, CSprite)
	oInfoPart.m_NameLabel = oInfoPart:NewUI(2, CLabel)
	oInfoPart.m_InfoGrid = oInfoPart:NewUI(3, CGrid)
	oInfoPart.m_InfoBox = oInfoPart:NewUI(4, CBox)
	oInfoPart.m_TitleLabel = oInfoPart:NewUI(5, CLabel)
	oInfoPart.m_DescLabel = oInfoPart:NewUI(6, CLabel)
	oInfoPart.m_ParentView = self
	oInfoPart.m_InfoBox:SetActive(false)

	oInfoPart.m_InfoBoxArr = {}
	function oInfoPart.CreateInfoBox(self)
		local oInfoBox = oInfoPart.m_InfoBox:Clone()
		oInfoBox.m_TitleLabel = oInfoBox:NewUI(1, CLabel)
		oInfoBox.m_ContentLabel = oInfoBox:NewUI(2, CLabel)
		return oInfoBox
	end

	function oInfoPart.SetData(self)
		local dData = data.housedata.HousePartner[oInfoPart.m_ParentView.m_CurType]
		for i,v in ipairs(oInfoPart.m_ParentView.m_DataKey) do
			if oInfoPart.m_InfoBoxArr[i] == nil then
				oInfoPart.m_InfoBoxArr[i] = oInfoPart:CreateInfoBox()
				oInfoPart.m_InfoGrid:AddChild(oInfoPart.m_InfoBoxArr[i])
			end
			oInfoPart.m_InfoBoxArr[i]:SetActive(true)
			oInfoPart.m_InfoBoxArr[i].m_TitleLabel:SetText(v.title)
			oInfoPart.m_InfoBoxArr[i].m_ContentLabel:SetText(dData[v.key])
		end

		oInfoPart.m_AvatarSprite:SpriteHouseAvatar(dData.shape)
		oInfoPart.m_NameLabel:SetText(dData.name)
		oInfoPart.m_TitleLabel:SetText(dData.title)
		oInfoPart.m_DescLabel:SetText(dData.desc)
	end
end

function CHouseExchangePartnerPart.InitTaskPart(self)
	local oTaskPart = self.m_TaskPart
	oTaskPart.m_TaskGrid = oTaskPart:NewUI(1, CGrid)
	oTaskPart.m_TaskBox = oTaskPart:NewUI(2, CBox)
	oTaskPart.m_TaskBoxDic = {}
	oTaskPart.m_DataBoxArr = {}
	oTaskPart.m_ParentView = self
	oTaskPart.m_TaskBox:SetActive(false)
	function oTaskPart.SetData(self)
		local dData = g_HouseCtrl:GetTaskList(oTaskPart.m_ParentView.m_CurType)
		for i, v in ipairs(dData) do
			if v.task_title ~= "" then
				if oTaskPart.m_TaskBoxDic[v.level] == nil then
					oTaskPart.m_TaskBoxDic[v.level] = oTaskPart:CreateTaskBox()
				end
				oTaskPart.m_TaskBoxDic[v.level]:SetData(v)
				oTaskPart.m_TaskBoxDic[v.level]:SetActive(true)
			end
		end
		oTaskPart:RefreshTaskBoxs()
	end

	function oTaskPart.CreateTaskBox(self)
		local oBox = self.m_TaskBox:Clone()
		oBox.m_TitleLabel = oBox:NewUI(1, CLabel)
		oBox.m_ContentLabel = oBox:NewUI(2, CLabel)
		oBox.m_IconSpr = oBox:NewUI(3, CButton)
		oBox.m_LockSpr = oBox:NewUI(4, CSprite)
		oBox.m_LockLabel = oBox:NewUI(5, CLabel)
		oBox.m_GotMark = oBox:NewUI(6, CSprite)
		oBox.m_UnLockBox = oBox:NewUI(7, CBox)

		oBox.m_IconSpr:AddUIEvent("click", callback(oTaskPart.m_ParentView, "OnShowAward", oBox))
		oBox:AddUIEvent("click", callback(oTaskPart.m_ParentView, "OnPlayTask", oBox))
		oTaskPart.m_TaskGrid:AddChild(oBox)

		function oBox.SetData(self, dInfo)
			oBox.m_Data = dInfo
			oBox:SetActive(true)
			oBox.m_TitleLabel:SetText(dInfo.task_title)
			oBox.m_ContentLabel:SetText(dInfo.task_content)
			oBox.m_LockLabel:SetText(string.format("%s级解锁", dInfo.level))
			-- oBox.m_IconSpr:SpriteItemShape(DataTools.GetItemData(dInfo.item[1].sid).icon)
		end

		function oBox.SetStatus(self, status)
			oBox.m_Status = status
			if status == define.House.TaskStatus.Lock then
				oBox.m_LockSpr:SetActive(true)
				-- oBox.m_UnLockBox:SetActive(false)
			else
				oBox.m_LockSpr:SetActive(false)
				-- oBox.m_UnLockBox:SetActive(true)
			end
			oBox.m_GotMark:SetActive(status == define.House.TaskStatus.Got)
		end
		return oBox
	end

	function oTaskPart.RefreshTaskBoxs(self)
		for k,v in pairs(oTaskPart.m_TaskBoxDic) do
			v:SetActive(true)
		end
		for k,v in pairs(oTaskPart.m_DataBoxArr) do
			v:SetActive(false)
		end
		local dInfo = g_HouseCtrl:GetPartnerInfo(oTaskPart.m_ParentView.m_CurType)
		local taskList = g_HouseCtrl:GetTaskList(oTaskPart.m_ParentView.m_CurType)
		for i,v in ipairs(taskList) do
			if oTaskPart.m_TaskBoxDic[v.level] ~= nil then
				if dInfo.love_level < v.level then
					oTaskPart.m_TaskBoxDic[v.level]:SetStatus(define.House.TaskStatus.Lock)
				else
					oTaskPart.m_TaskBoxDic[v.level]:SetStatus(define.House.TaskStatus.Done)
				end
				oTaskPart.m_TaskBoxDic[v.level]:SetAsLastSibling()
			end
		end
		if dInfo.unchain_level ~= nil then
			local sortlist = {}
			for k,v in pairs(dInfo.unchain_level) do
				table.insert(sortlist, v)
			end
			local function sortFunc(v1, v2)
				return v1 < v2
			end
			table.sort(sortlist, sortFunc)
			for i = 1, #sortlist do
				oTaskPart.m_TaskBoxDic[sortlist[i]]:SetStatus(define.House.TaskStatus.Got)
				oTaskPart.m_TaskBoxDic[sortlist[i]]:SetAsLastSibling()
			end
		end
		oTaskPart.m_TaskGrid:Reposition()
	end
end

function CHouseExchangePartnerPart.InitBtn(self, oBtn)
	oBtn.m_OnSelect = oBtn:NewUI(1, CBox)
	oBtn.m_Button = oBtn:NewUI(2, CButton)
	oBtn.m_Button:AddUIEvent("click", callback(self, "OnSelectBtn", oBtn))
	oBtn.m_Button:SetActive(true)
	oBtn.m_OnSelect:SetActive(false)
end


function CHouseExchangePartnerPart.ShowTask(self)
	self:OnSelectBtn(self.m_TaskBtn)
end

function CHouseExchangePartnerPart.OnSelectBtn(self, oBtn)
	if self.m_CurrentSelectBtn ~= nil then
		self.m_CurrentSelectBtn.m_Button:SetActive(true)
		self.m_CurrentSelectBtn.m_OnSelect:SetActive(false)
	end
	self.m_CurrentSelectBtn = oBtn
	oBtn.m_Button:SetActive(false)
	oBtn.m_OnSelect:SetActive(true)
	self.m_TaskPart:SetActive(false)
	self.m_InfoPart:SetActive(false)
	if oBtn == self.m_TaskBtn then
		self.m_TaskPart:SetActive(true)
		self.m_TaskPart:SetData()
	elseif oBtn == self.m_VoiceBtn then

	elseif oBtn == self.m_DataBtn then
		self.m_InfoPart:SetActive(true)
		self.m_InfoPart:SetData()
	end
end

function CHouseExchangePartnerPart.SetPartnerType(self, iPartnerType)
	self.m_CurType = iPartnerType
	if self.m_CurrentSelectBtn ~= nil then
		self:OnSelectBtn(self.m_CurrentSelectBtn)
	else
		self:OnSelectBtn(self.m_TaskBtn)
	end
end


-----------------------------------------------------------------------





function CHouseExchangePartnerPart.BoxExpAnim(self, oLevelLabel, oSlider)
	-- if not oBox.m_LeftAddExp then
	-- 	return false
	-- end
	-- if oBox.m_LeftAddExp <= oBox.m_Step then
	-- 	oBox.m_Step = oBox.m_LeftAddExp
	-- 	oBox.m_LeftAddExp = nil
	-- else
	-- 	oBox.m_LeftAddExp = oBox.m_LeftAddExp - oBox.m_Step
	-- end
	-- oBox.m_AddExp = oBox.m_AddExp + oBox.m_Step
	-- oBox.m_CurExp = oBox.m_CurExp + oBox.m_Step
	-- if oBox.m_MaxExp == nil then
	-- 	oBox.m_MaxExp = oBox.m_MaxExpFunc(oBox.m_CurGrade)
	-- end
	-- if oBox.m_CurExp >= oBox.m_MaxExp and oBox.m_CurGrade < oBox.m_LimitGrade  then
	-- 	oBox.m_CurGrade = oBox.m_CurGrade + 1
	-- 	oBox.m_LvLabel:SetText(string.format("lv.%d#G(升级)#n", oBox.m_CurGrade))
	-- 	oBox.m_MaxExp = nil
	-- 	oBox.m_Slider:SetValue(0)
	-- 	oBox.m_CurExp = 0
	-- else
	-- 	oBox.m_Slider:SetValue(oBox.m_CurExp/oBox.m_MaxExp)
	-- end
	-- oBox.m_ExpLabel:SetText(string.format("EXP +%d", oBox.m_AddExp))
	-- return true
end

function CHouseExchangePartnerPart.RefreshVoice(self)
	--tzq屏蔽未完成功能
	g_NotifyCtrl:FloatMsg("该功能尚未开放")

	-- self.m_ScrollView:ResetPosition()
	-- self.m_Table:Clear()
	-- local dData = data.housedata.HousePartner[self.m_CurType]
	-- for i, dInfo in ipairs(dData.voice) do
	-- 	local oBox = self.m_VoiceBox:Clone()
	-- 	oBox:SetActive(true)
	-- 	oBox.m_TitleLabel = oBox:NewUI(1, CLabel)
	-- 	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	-- 	oBox.m_SelectBtn = oBox:NewUI(3, CButton)
	-- 	oBox.m_SelectBtn:SetGroup(self.m_Table:GetInstanceID())
	-- 	oBox.m_SelectBtn:AddUIEvent("click", callback(self, "OnSelectVoiceType"))
	-- 	oBox:AddUIEvent("click", callback(self, "OnPlayVoice"))
	-- 	oBox.m_VoiceList = dInfo.voice_list
	-- 	oBox.m_Idx = 1
	-- 	oBox.m_TitleLabel:SetText(dInfo.title)
	-- 	oBox.m_NameLabel:SetText(dInfo.name)
	-- 	self.m_Table:AddChild(oBox)
	-- end
end

function CHouseExchangePartnerPart.OnPlayVoice(self, oBox)
	if oBox.m_Idx > #oBox.m_VoiceList then
		oBox.m_Idx = 1
	end
	local path = oBox.m_VoiceList[oBox.m_Idx]
	if path then
		local path = "Audio/Sound/House/"..path..".mp3"
		g_AudioCtrl:SoloPath(path, 0.05)
	end
	oBox.m_Idx = oBox.m_Idx + 1
end

function CHouseExchangePartnerPart.OnShowAward(self, oBox)
	self.m_RewardPart:SetData(oBox, self.m_CurType)
end

function CHouseExchangePartnerPart.OnPlayTask(self, oBox)
	if oBox.m_Status == define.House.TaskStatus.Lock then
		self:OnShowAward(oBox)
	else
		local oData = data.taskdata.TASK.HOUSE.DIALOG[oBox.m_Data.dialog_id]
		local parnterData = data.housedata.HousePartner[self.m_CurType]
		local dialogData = {
			dialog = oData,
			npc_name = parnterData.name,
			shape = parnterData.shape,
		}

		CDialogueMainView:ShowView(function (oView)
			oView:SetShowBtn(true, false, false)
			oView:SetContent(dialogData)
			g_DialogueCtrl:OnEvent(define.Dialogue.Event.Dialogue, dialogData)
		end)

		if oBox.m_Status == define.House.TaskStatus.Done then
			CDialogueMainView:SetHideCB(function ()
				nethouse.C2GSUnChainPartnerReward(self.m_CurType, oBox.m_Data.level)
				CDialogueMainView:SetHideCB(nil)
			end)
		end
	end
end

function CHouseExchangePartnerPart.OnSelectVoiceType(self, oBtn)
	-- oBtn:SetSelected(true)
end





return CHouseExchangePartnerPart