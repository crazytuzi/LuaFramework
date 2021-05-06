local CQARankView = class("CQARankView", CViewBase)

function CQARankView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/QuestionAnswer/QARankView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CQARankView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_MyRankItem = self:NewUI(2, CBox)
	self.m_ItemTipBox = self:NewUI(3, CItemTipsBox)
	self.m_ActorList = {}
	for i = 1, 3 do
		self.m_ActorList[i] = self:NewUI(3+i, CActorTexture)
	end
	self.m_ScrollView = self:NewUI(7, CScrollView)
	self.m_Gird = self:NewUI(8, CGrid)
	self.m_RankItem = self:NewUI(9, CBox)
	self.m_GetBtn = self:NewUI(10, CButton)
	self.m_UIEffect = self:NewUI(11, CUIEffect)
	self:InitContent()
end

function CQARankView.InitContent(self)
	self.m_MyRankLabel = self.m_MyRankItem:NewUI(1, CLabel)
	self.m_MyNameLabel = self.m_MyRankItem:NewUI(2, CLabel)
	self.m_MyItemGrid = self.m_MyRankItem:NewUI(3, CGrid)
	self.m_MyScoreLabel = self.m_MyRankItem:NewUI(4, CLabel)
	self.m_RankItem:SetActive(false)
	self.m_ItemTipBox:SetActive(false)
	self.m_GetBtn:SetActive(true)
	self.m_UIEffect:Above(self.m_CloseBtn)
	self.m_UIEffect:SetActive(true)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_GetBtn:AddUIEvent("click", callback(self, "OnClickAWard"))
	local QACtrl = g_ActivityCtrl:GetQuesionAnswerCtrl()
	QACtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnActivityEvent"))
	local function delay(obj)
		obj.m_UIEffect:Destroy()
	end
	Utils.AddTimer(objcall(self, delay), 0, 5)
end

function CQARankView.OnActivityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Activity.Event.SAReward then
		self:UpdateAward(oCtrl.m_EventData)
	end
end

function CQARankView.UpdateAward(self, status)
	-- if status == 2 then
	-- 	self:OnClose()
	-- end
end

function CQARankView.RefreshData(self, dRankData, isscene)
	if isscene then
		self.m_Type = 2
		self.m_GetBtn:SetActive(false)
	else
		self.m_Type = 1
		self.m_GetBtn:SetActive(false)
	end
	local myscore = nil
	local myrank = nil
	local dAwardData = self:GetAwardData()
	for i, score_info in ipairs(dRankData) do
		if i < 11 then
			local itemobj = self.m_RankItem:Clone()
			itemobj:SetActive(true)
			itemobj.m_FirstBG = itemobj:NewUI(1, CSprite)
			itemobj.m_RankSpr = itemobj:NewUI(2, CSprite)
			itemobj.m_RankLabel = itemobj:NewUI(3, CLabel)
			itemobj.m_NameLabel = itemobj:NewUI(4, CLabel)
			itemobj.m_ScoreLabel = itemobj:NewUI(5, CLabel)
			itemobj.m_ItemGrid = itemobj:NewUI(6, CGrid)
			itemobj.m_FirstBG:SetActive(i == 1)
			local bSpr = i < 4
			itemobj.m_RankSpr:SetActive(bSpr)
			itemobj.m_RankLabel:SetActive(not bSpr)
			if bSpr then
				itemobj.m_RankSpr:SetSpriteName("pic_rank_0" .. i)
			else
				itemobj.m_RankLabel:SetText(tostring(i))
			end
			itemobj.m_NameLabel:SetText(score_info["name"])
			itemobj.m_ScoreLabel:SetText(tostring(score_info["score"]))
			itemobj.m_ItemGrid:Clear()
			local awardData = dAwardData[i] or dAwardData[20]
			for _, v in ipairs(awardData.reward) do
				local itembox = self.m_ItemTipBox:Clone()
				itembox:SetActive(true)
				itembox:SetSid(v.sid, v.num, {isLocal = true, uiType = 1})
				itemobj.m_ItemGrid:AddChild(itembox)
			end
			itemobj.m_ItemGrid:Reposition()
			self.m_Gird:AddChild(itemobj)
		end
		if score_info["pid"] == g_AttrCtrl.pid then
			myscore = score_info
			myrank = i
		end
	end
	if myscore then
		self.m_MyNameLabel:SetText(g_AttrCtrl.name)
		self.m_MyRankLabel:SetText(tostring(myrank))
		self.m_MyScoreLabel:SetText(tostring(myscore["score"]))
		self.m_MyItemGrid:Clear()
		local awardData = dAwardData[myrank] or dAwardData[20]
		for _, v in ipairs(awardData.reward) do
			local itembox = self.m_ItemTipBox:Clone()
			itembox:SetActive(true)
			itembox:SetSid(v.sid, v.num, {isLocal = true, uiType = 1})
			self.m_MyItemGrid:AddChild(itembox)
		end
		self.m_MyItemGrid:Reposition()
	end
	for i, score_info in ipairs(dRankData) do
		if i < 4 then
			local shape = score_info.model_info.shape
			self.m_ActorList[i]:ChangeShape(shape, {})
			self.m_ActorList[i]:PlayAni("pose")
		end
	end
	self.m_Gird:Reposition()
end

function CQARankView.GetAwardData(self)
	local iType = self.m_Type
	local dAwardData = {}
	for k, v in ipairs(data.sceneexamdata.UIAward) do
		if iType == 1 and v.idx < 10000 then
			dAwardData[v.idx] = v
		elseif iType == 2 and v.idx > 10000 then
			dAwardData[v.idx - 10000] = v
		end
	end
	local dNewAwardData = {}
	local iLastIndex = 20
	for i = 20, 1, -1 do
		if dAwardData[i] then
			dNewAwardData[i] = dAwardData[i]
			iLastIndex = i
		else
			dNewAwardData[i] = dAwardData[iLastIndex]
		end
	end
	return dNewAwardData
end

function CQARankView.OnClickAWard(self)
	nethuodong.C2GSQuestionEndReward(1)
end


return CQARankView
