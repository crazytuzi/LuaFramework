local CChapterFuBenMainView = class("CChapterFuBenMainView", CViewBase)

function CChapterFuBenMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/ChapterFuBen/ChapterFuBenMainView.prefab", cb)
	self.m_ExtendClose = "Shelter"
	self.m_GroupName = "main"
	self.m_StopHeroWalk = true
end

function CChapterFuBenMainView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_ChapterFuBenSelectPart = self:NewUI(3, CChapterFuBenSelectPart)
	self.m_LastChapterBox = self:NewUI(4, CBox)
	self.m_LastChapterBox.m_Btn = self.m_LastChapterBox:NewUI(1, CButton)
	self.m_LastChapterBox.m_Label = self.m_LastChapterBox:NewUI(2, CLabel)
	self.m_LastChapterBox.m_RedDotSpr = self.m_LastChapterBox:NewUI(3, CSprite)
	self.m_NextChapterBox = self:NewUI(5, CBox)
	self.m_NextChapterBox.m_Btn = self.m_NextChapterBox:NewUI(1, CButton)
	self.m_NextChapterBox.m_Label = self.m_NextChapterBox:NewUI(2, CLabel)
	self.m_NextChapterBox.m_RedDotSpr = self.m_NextChapterBox:NewUI(3, CSprite)
	self.m_ChapterBox = self:NewUI(6, CChapterBox)
	self.m_RewardGrid = self:NewUI(7, CGrid)
	self.m_StarLabel = self:NewUI(8, CLabel)
	self.m_ChapterWealthInfoPart = self:NewUI(9, CChapterWealthInfoPart)
	self.m_BackBtn = self:NewUI(12, CButton)

	self.m_RewardList = {}
	self.m_SubViewList = {}
	self.m_ChapterID = nil
	self.m_ChapterType = nil
	self:InitContent()
end

function CChapterFuBenMainView.SetActive(self, bAct)
	CViewBase.SetActive(self, bAct)
	if bAct then
		local oView = self.m_SubViewList["CChapterFuBenSweepView"]
		if oView then
			oView:SetActive(true)
			g_ViewCtrl:TopView(oView)
			self.m_SubViewList["CChapterFuBenSweepView"]=nil
		end
	else
		local oView = CChapterFuBenSweepView:GetView()
		if oView then
			self.m_SubViewList["CChapterFuBenSweepView"] = oView
			oView:SetActive(false)
		end
	end
end

function CChapterFuBenMainView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_LastChapterBox.m_Btn:AddUIEvent("click", callback(self, "OnLastChapterBox"))
	self.m_NextChapterBox.m_Btn:AddUIEvent("click", callback(self, "OnNextChapterBox"))
	self.m_ChapterFuBenSelectPart:SetParentView(self)
	self.m_ChapterBox:SetParentView(self)
	g_ChapterFuBenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChapterFuBenEvent"))

	self:InitRewardGrid()
	g_GuideCtrl:TriggerJQFBGuide()
end

function CChapterFuBenMainView.OnClose(self, obj)
	if self.m_ChapterBox.m_ChapterFuBenLavelPart:GetActive() then
		self.m_ChapterBox.m_ChapterFuBenLavelPart:OnHide()
	else
		g_ChapterFuBenCtrl.m_WarAfterReshow = false
		self.m_ChapterBox:EnableAnimator(true)
		CViewBase.OnClose(self)
	end
end

function CChapterFuBenMainView.OnChapterFuBenEvent(self, oCtrl)
	if oCtrl.m_EventID == define.ChapterFuBen.Event.OnUpdateChapterTotalStar then
		self:RefreshRewardGrid()
	end
end

function CChapterFuBenMainView.InitRewardGrid(self)
	self.m_RewardGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_StarLabel = oBox:NewUI(2, CLabel)
		oBox.m_IconSprite = oBox:NewUI(3, CSprite)
		oBox.m_RedDotSpr = oBox:NewUI(4, CSprite)
		oBox.m_TweenRotation = oBox.m_IconSprite:GetComponent(classtype.TweenRotation)
		oBox.m_TweenRotation.enabled = false
		oBox.m_RedDotSpr:SetActive(false)
		oBox.m_Idx = idx

		oBox.m_SpriteStr1 = "pic_baoxiang_"..(idx+2) 
		oBox.m_SpriteStr2 = "pic_baoxiang_"..(idx+2).."_h"
		oBox:AddUIEvent("click", callback(self,"OnReward"))
		if idx == 1 then
			g_GuideCtrl:AddGuideUI("chapter_fuben_reward_btn_1", oBox.m_IconSprite)	
		end
		table.insert(self.m_RewardList, oBox)
	end)
end

function CChapterFuBenMainView.OnReward(self, oBox)
	self.m_ChapterBox:DelGuideLevel()
	if oBox.m_CanGet then
		nethuodong.C2GSGetStarReward(self.m_ChapterID, oBox.m_Idx, self.m_ChapterType)
	else
		CChapterFuBenRewardView:ShowView(function (oView)
			oView:SetChapterData(oBox.m_Data)
		end)
	end
end

function CChapterFuBenMainView.RefreshLastNextBtn(self)
	local dData = DataTools.GetChapterInfo(self.m_ChapterType)
	local len = g_ChapterFuBenCtrl:GetMaxOpenChapter(self.m_ChapterType) - 1
	local bLast = self.m_ChapterID ~= 1
	local bNext = self.m_ChapterID ~= len + 1
	self.m_LastChapterBox:SetActive(bLast)
	self.m_NextChapterBox:SetActive(bNext)

	local dInfo = dData[self.m_ChapterID-1]
	if dInfo then
		self.m_LastChapterBox.m_Label:SetText(dInfo.chapternum)
		local bAct = false
		for i=self.m_ChapterID-1, 1, -1 do
			bAct = g_ChapterFuBenCtrl:HasRedDotByChapter(self.m_ChapterType, i)
			if bAct then
				break
			end
		end
		self.m_LastChapterBox.m_RedDotSpr:SetActive(bAct)
	else
		self.m_LastChapterBox:SetActive(false)
	end
	dInfo = dData[self.m_ChapterID+1]
	if dInfo then
		self.m_NextChapterBox.m_Label:SetText(dInfo.chapternum)
		local bAct = false
		for i=self.m_ChapterID+1, len+1, 1 do
			bAct = g_ChapterFuBenCtrl:HasRedDotByChapter(self.m_ChapterType, i)
			if bAct then
				break
			end
		end
		self.m_NextChapterBox.m_RedDotSpr:SetActive(bAct)
	else
		self.m_NextChapterBox:SetActive(false)
	end
	self.m_ChapterBox:DelGuideLevel()
end

function CChapterFuBenMainView.OnLastChapterBox(self, obj)
	local id = self.m_ChapterID - 1
	self.m_ChapterID = math.max(id, 1)
	self:RefreshLastNextBtn()
	self:RefreshChapterInfo()
end

function CChapterFuBenMainView.OnNextChapterBox(self, obj)
	local id = self.m_ChapterID + 1
	local chapter, level = g_ChapterFuBenCtrl:GetFinalChapterLevel(self.m_ChapterType)
	self.m_ChapterID = id
	self:RefreshLastNextBtn()
	self:RefreshChapterInfo()
end

function CChapterFuBenMainView.DefaultChapterInfo(self, type)
	type = type or define.ChapterFuBen.Type.Simple
	self.m_CurMaxChapter = g_ChapterFuBenCtrl:GetCurMaxChapter(type)
	self.m_ChapterID = self.m_CurMaxChapter
	self.m_ChapterType = type
	self:RefreshChapterInfo()
	self:RefreshLastNextBtn()
end

function CChapterFuBenMainView.ForceChapterInfo(self, type, chapterid)
	self.m_CurMaxChapter = g_ChapterFuBenCtrl:GetCurMaxChapter(type)
	self.m_ChapterType = type
	self.m_ChapterID = chapterid
	self:RefreshChapterInfo()
	self:RefreshLastNextBtn()
end

function CChapterFuBenMainView.SetGuideLevel(self, level)
	self.m_ChapterBox:SetGuideLevel(level)
end

function CChapterFuBenMainView.RefreshChapterInfo(self)
	self.m_ChapterBox:SetChapter(self.m_ChapterID, self.m_ChapterType)
	self.m_ChapterFuBenSelectPart:SetChapter(self.m_ChapterID, self.m_ChapterType)
	self:RefreshRewardGrid()
end

function CChapterFuBenMainView.RefreshRewardGrid(self)
	local rewardlist = DataTools.GetChapterStarReward(self.m_ChapterType, self.m_ChapterID) or {}
	local dChapterStar = g_ChapterFuBenCtrl:GetChapterTotalStar(self.m_ChapterType, self.m_ChapterID)
	for i,oBox in ipairs(self.m_RewardList) do
		local d = rewardlist[i]
		if d then
			oBox.m_Data = d
			oBox.m_StarLabel:SetText(d.star)
			oBox:SetActive(true)
			oBox.m_Get = dChapterStar.reward_status and MathBit.andOp(dChapterStar.reward_status, 2 ^ (oBox.m_Idx -1)) ~= 0

			if oBox.m_Get then
				oBox.m_IconSprite:SetSpriteName(oBox.m_SpriteStr1)
				oBox.m_RedDotSpr:SetActive(false)
				oBox.m_TweenRotation.enabled = false
				oBox:SetLocalRotation(Quaternion.Euler(0, 0, 0))
			else
				oBox.m_CanGet = dChapterStar.star >= d.star
				if oBox.m_CanGet then
					oBox.m_RedDotSpr:SetActive(true)
					oBox.m_TweenRotation.enabled = true
				else
					oBox.m_RedDotSpr:SetActive(false)
					oBox.m_TweenRotation.enabled = false
					oBox:SetLocalRotation(Quaternion.Euler(0, 0, 0))
				end
				oBox.m_IconSprite:SetSpriteName(oBox.m_SpriteStr2)
			end
		else
			oBox:SetActive(false)
		end
	end
	local dChapterInfo = DataTools.GetChapterInfo(self.m_ChapterType, self.m_ChapterID)
	local maxStar = dChapterInfo.star
	self.m_StarLabel:SetText(string.format("%d/%d", dChapterStar.star, maxStar))

	if self.m_ChapterID == 1 and g_AttrCtrl.grade >= 6 and g_ChapterFuBenCtrl:CheckChapterRewardStatusCanGet(self.m_ChapterType, 1, 1) 
		and not g_ChapterFuBenCtrl:CheckChapterRewardStatus(self.m_ChapterType, 1,1) then
		g_GuideCtrl:AddGuideUIEffect("chapter_fuben_reward_btn_1", "circle")
  	else
  		g_GuideCtrl:DelGuideUIEffect("chapter_fuben_reward_btn_1", "circle")
	end
end

--打开关卡详情要关闭部分
function CChapterFuBenMainView.ShowOther(self, bShow)
	self.m_ChapterFuBenSelectPart:SetActive(bShow)
	--self.m_ChapterWealthInfoPart:SetActive(bShow)
	self.m_LastChapterBox:SetActive(bShow)
	self.m_NextChapterBox:SetActive(bShow)
	self.m_RewardGrid:SetActive(bShow)
	self.m_StarLabel:SetActive(bShow)
	if bShow then
		self:RefreshLastNextBtn()
	end
end

function CChapterFuBenMainView.CloseView(self)
	CViewBase.CloseView(self)
end

return CChapterFuBenMainView