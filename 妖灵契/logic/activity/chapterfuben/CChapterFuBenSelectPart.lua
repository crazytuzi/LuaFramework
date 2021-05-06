local CChapterFuBenSelectPart = class("CChapterFuBenSelectPart", CBox)

function CChapterFuBenSelectPart.ctor(self, obj, parentView)
	CBox.ctor(self, obj)
	self.m_ChapterNameLabel = self:NewUI(1, CLabel)
	self.m_XiaLaBtn = self:NewUI(2, CButton)
	self.m_ShangLaBtn = self:NewUI(3, CButton)
	self.m_ScrollView = self:NewUI(4, CScrollView)
	self.m_WrapContent = self:NewUI(5, CWrapContent)
	self.m_ChildBox = self:NewUI(6, CBox)
	self.m_ScrollDrag = self:NewUI(7, CSprite)
	self.m_Container = self:NewUI(8, CWidget)
	self.m_BgMask = self:NewUI(9, CSprite)
	self.m_ChapterTypeSpr = self:NewUI(10, CSprite)
	self.m_ChapterTypeLabel = self:NewUI(11, CLabel)
	self.m_SwitchBtn = self:NewUI(12, CButton)
	self.m_SwitchSpr = self:NewUI(13, CSprite)
	self.m_NewTipsSpr = self:NewUI(14, CSprite)
	self.m_RedDotSpr = self:NewUI(15, CSprite)
	self.m_SwitchSpr.m_TweenAlpha = self.m_SwitchSpr:GetComponent(classtype.TweenAlpha)
	self:InitContent()
end

function CChapterFuBenSelectPart.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_ParentView = nil
	self.m_ChapterType = nil
	self.m_ChapterID = nil
	self.m_SwitchSpr.m_TweenAlpha.enabled = false
	self.m_NewTipsSpr:SetActive(false)
	self.m_ChildBox:SetActive(false)
	self.m_ChapterNameLabel:AddUIEvent("click", callback(self, "OnChapterNameLabel"))
	self.m_XiaLaBtn:AddUIEvent("click", callback(self, "OnShowScrollView", true))
	self.m_ShangLaBtn:AddUIEvent("click", callback(self, "OnShowScrollView", false))
	self.m_BgMask:AddUIEvent("click", callback(self, "OnShowScrollView", false))
	self.m_SwitchBtn:AddUIEvent("click", callback(self, "OnSwitchBtn"))

	g_GuideCtrl:AddGuideUI("chaterfb_switch_btn", self.m_SwitchBtn)
	local guide_ui = {"chaterfb_switch_btn"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)

	self.m_WrapContent:SetCloneChild(self.m_ChildBox, 
		function(oChild)
			oChild.m_NameLabel = oChild:NewUI(1, CLabel)
			oChild.m_LockSpr = oChild:NewUI(2, CSprite)
			oChild.m_LockLabel = oChild:NewUI(3, CLabel)
			return oChild
		end)

	self:OnShowScrollView(false)
end

function CChapterFuBenSelectPart.SetParentView(self, oView)
	self.m_ParentView = oView
end

function CChapterFuBenSelectPart.RefreshWrapContent(self)
	local maxchapter = g_ChapterFuBenCtrl:GetCurMaxChapter(self.m_ChapterType)
	if self.m_ChapterType == define.ChapterFuBen.Type.Simple then
		self.m_WrapContent:SetRefreshFunc(function(oChild, dData)
			if dData then
				oChild:SetActive(true)
				if dData.chapterid > maxchapter then
					oChild.m_NameLabel:SetText("")
					oChild.m_LockSpr:SetActive(true)
					oChild.m_LockLabel:SetText(string.format("通关第%s章后开启", dData.chapterid - 1))
				else
					oChild.m_NameLabel:SetText(dData.chaptername)
					oChild.m_LockSpr:SetActive(false)
				end
				oChild:AddUIEvent("click", callback(self, "OnChildBox", dData.type, dData.chapterid))
			else	
				oChild:SetActive(false)
			end
		end)
	elseif self.m_ChapterType == define.ChapterFuBen.Type.Difficult then
		self.m_WrapContent:SetRefreshFunc(function(oChild, dData)
			if dData then
				oChild:SetActive(true)
				if dData.chapterid > maxchapter then
					oChild.m_NameLabel:SetText("")
					oChild.m_LockSpr:SetActive(true)
					local dConfig = DataTools.GetChapterConfig(self.m_ChapterType, dData.chapterid, 1)
					local grade = 0
					for i,v in ipairs(dConfig.open_condition) do
						if string.find(v, "等级=") then
							for out in string.gmatch(v, "(%w+)") do
								grade = tonumber(out)
								break
							end
						end
					end
					oChild.m_LockLabel:SetText(string.format("%s级并通关对应普通章节", grade))
				else
					oChild.m_NameLabel:SetText(dData.chaptername)
					oChild.m_LockSpr:SetActive(false)
				end
				oChild:AddUIEvent("click", callback(self, "OnChildBox", dData.type, dData.chapterid))
			else	
				oChild:SetActive(false)
			end
		end)
	end
	local dChapterInfo = DataTools.GetChapterInfo(self.m_ChapterType)
	local list = {}
	local len = g_ChapterFuBenCtrl:GetMaxOpenChapter(self.m_ChapterType)
	for i=1,len do
		table.insert(list, dChapterInfo[i])
	end
	self.m_WrapContent:SetData(list, true)
end

function CChapterFuBenSelectPart.OnChildBox(self, type, chapterid)
	if self.m_ParentView then
		self.m_ParentView:ForceChapterInfo(type, chapterid)
		self:OnShowScrollView(false)
	end
end

function CChapterFuBenSelectPart.OnShowScrollView(self, bShow)
	self.m_ScrollView:SetActive(bShow)
	self.m_XiaLaBtn:SetActive(not bShow)
	self.m_ShangLaBtn:SetActive(bShow)
	self.m_BgMask:SetActive(bShow)
end

function CChapterFuBenSelectPart.OnChapterNameLabel(self)
	local bAct = self.m_ScrollView:GetActive()
	self:OnShowScrollView(not bAct)
end

--chaptertype 模式：普通/困难，默认普通
function CChapterFuBenSelectPart.SetChapter(self, chapterid, chaptertype)
	local bRefresh = self.m_ChapterType ~= chaptertype
	self.m_ChapterType = chaptertype or 1
	self.m_ChapterID = chapterid
	local dChapterInfo = DataTools.GetChapterInfo(self.m_ChapterType, self.m_ChapterID)
	self.m_ChapterNameLabel:SetText(dChapterInfo.chaptername)
	if bRefresh then
		self:RefreshChaptertype()
		self:RefreshWrapContent()
	end
	if self.m_ChapterType == define.ChapterFuBen.Type.Simple then
		self.m_SimpleID = self.m_ChapterID
	elseif self.m_ChapterType == define.ChapterFuBen.Type.Difficult then
		self.m_DifficultID = self.m_ChapterID
	end
end

function CChapterFuBenSelectPart.RefreshChaptertype(self)
	if self.m_ChapterType == define.ChapterFuBen.Type.Simple then
		self.m_ChapterTypeSpr:SetSpriteName("pic_tubiao_putong")
		self.m_ChapterTypeLabel:SetText("普通")
		if g_ChapterFuBenCtrl:IsOpenChapterDifficult() then
			self.m_SwitchBtn:SetSpriteName("pic_qiehuan_kunnan")
		else
			self.m_SwitchBtn:SetSpriteName("pic_qiehuan_kunnan_jinzhi")
		end
		self.m_SwitchSpr:SetSpriteName("pic_jinruputongmoshi")
		self.m_SwitchSpr.m_TweenAlpha.enabled = true
		self.m_SwitchSpr.m_TweenAlpha:ResetToBeginning()
		self.m_NewTipsSpr:SetActive(IOTools.GetClientData("chapter_difficult_new") == true)
		self.m_RedDotSpr:SetActive(g_ChapterFuBenCtrl:HasRedDotDifficult())
	elseif self.m_ChapterType == define.ChapterFuBen.Type.Difficult then
		self.m_ChapterTypeSpr:SetSpriteName("pic_tubiao_kunnan")
		self.m_ChapterTypeLabel:SetText("困难")
		self.m_SwitchBtn:SetSpriteName("pic_qiehuan_putong")
		self.m_SwitchSpr:SetSpriteName("pic_jinrukunnanmoshi")
		self.m_SwitchSpr.m_TweenAlpha.enabled = true
		self.m_SwitchSpr.m_TweenAlpha:ResetToBeginning()
		IOTools.SetClientData("chapter_difficult_new", false)
		self.m_NewTipsSpr:SetActive(false)
		self.m_RedDotSpr:SetActive(g_ChapterFuBenCtrl:HasRedDotSimple())
	end
	self.m_ChapterTypeSpr:MakePixelPerfect()
end

function CChapterFuBenSelectPart.OnSwitchBtn(self, oBtn)
	if self.m_ChapterType == define.ChapterFuBen.Type.Simple then
		if g_ChapterFuBenCtrl:IsOpenChapterDifficult() then
			g_GuideCtrl:ReqTipsGuideFinish("chaterfb_switch_btn")
			if self.m_DifficultID then
				self.m_ParentView:ForceChapterInfo(define.ChapterFuBen.Type.Difficult, self.m_DifficultID)
			else
				self.m_ParentView:DefaultChapterInfo(define.ChapterFuBen.Type.Difficult)
			end
		else
			local dData = DataTools.GetChapterConfig(2,1,1)
			if dData then
				for i,v in ipairs(dData.open_condition) do
					if string.split(v, "通关") then
						local sArr = string.split(v, "=")
						g_NotifyCtrl:FloatMsg(string.format("通关战役%s", sArr[2]))
						return
					end
				end
			else
				g_NotifyCtrl:FloatMsg("困难模式未开启")
			end
		end
	elseif self.m_ChapterType == define.ChapterFuBen.Type.Difficult then
		if self.m_SimpleID then
			self.m_ParentView:ForceChapterInfo(define.ChapterFuBen.Type.Simple, self.m_SimpleID)
		else
			self.m_ParentView:DefaultChapterInfo(define.ChapterFuBen.Type.Simple)
		end
	end
end

return CChapterFuBenSelectPart