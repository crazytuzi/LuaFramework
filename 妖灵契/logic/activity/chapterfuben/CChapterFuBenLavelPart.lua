local CChapterFuBenLavelPart = class("CChapterFuBenLavelPart", CBox)

function CChapterFuBenLavelPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self:InitBox()
end

function CChapterFuBenLavelPart.InitBox(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_BgMask = self:NewUI(2, CSprite)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_ItemGrid = self:NewUI(6, CGrid)
	self.m_ItemBox = self:NewUI(7, CItemRewardBox)
	self.m_StarGrid = self:NewUI(8, CGrid)
	self.m_LineUpBtn = self:NewUI(9, CButton)
	self.m_SweepBtn = self:NewUI(10, CButton)
	self.m_FightBtn = self:NewUI(11, CButton)
	self.m_ChallengeLabel = self:NewUI(12, CLabel)
	self.m_EnergyLabel = self:NewUI(13, CLabel)
	self.m_ConditionLabel = self:NewUI(14, CLabel)
	self.m_LockPartnerBtn = self:NewUI(15, CButton)
	self.m_PowerLabel = self:NewUI(16, CLabel)
	self.m_TweenPosition = self.m_Container:GetComponent(classtype.TweenPosition)
	self.m_IsOpenAni = true
	self.m_HideCallBack = nil
	self.m_LockPartner = nil
	self:InitContent()
end

function CChapterFuBenLavelPart.InitContent(self)
	self.m_ItemBox:SetActive(false)
	self.m_BgMask:AddUIEvent("click", callback(self, "OnHide"))
	self.m_LineUpBtn:AddUIEvent("click", callback(self, "OnLineUpBtn"))
	self.m_SweepBtn:AddUIEvent("click", callback(self, "OnSweepBtn"))
	self.m_FightBtn:AddUIEvent("click", callback(self, "OnFightBtn"))
	self.m_LockPartnerBtn:AddUIEvent("click", callback(self, "OnLockPartnerBtn"))
	g_GuideCtrl:AddGuideUI("chapter_fuben_fight_btn", self.m_FightBtn)		
	g_ChapterFuBenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChapterFuBenEvent"))
	self:InitLockPartner()

	self:SetActive(false)
end

function CChapterFuBenLavelPart.InitLockPartner(self)
	local lock = IOTools.GetRoleData("chapter_fuben_lockpartner")
	if lock == nil then
		lock = true
		IOTools.SetRoleData("chapter_fuben_lockpartner", lock)
	end
	self.m_LockPartner = lock
	self.m_LockPartnerBtn:SetSelected(self.m_LockPartner)
	g_WarCtrl:SetLockPreparePartner(define.War.Type.ChapterFuBen, self.m_LockPartner)
end

function CChapterFuBenLavelPart.OnHide(self, obj)
	self:SetActive(false)
end

function CChapterFuBenLavelPart.SetHideCallBack(self, cb)
	self.m_HideCallBack = cb
end

function CChapterFuBenLavelPart.SetLineUpCallBack(self, cb)
	self.m_LineUpCallBack = cb
end

function CChapterFuBenLavelPart.SetActive(self, bAct)
	self.m_TweenPosition.enabled = bAct
	if not bAct then
		self.m_TweenPosition:ResetToBeginning()
		self.m_Container:SetLocalPos(Vector3.New(0, -750, 0))
		if self.m_HideCallBack then
			self.m_HideCallBack()
		end
	end
	CBox.SetActive(self, bAct)
end

function CChapterFuBenLavelPart.OnChapterFuBenEvent(self, oCtrl)
	if oCtrl.m_EventID == define.ChapterFuBen.Event.OnUpdateUpdateChapter then
		self:RefreshLevelData()
	end
end

function CChapterFuBenLavelPart.OnLineUpBtn(self, obj)
	CPartnerMainView:ShowView(function (oView)
		oView:ShowLineupPage()
		if self.m_LineUpCallBack then
			self.m_LineUpCallBack()
		end
	end)
end

function CChapterFuBenLavelPart.OnSweepBtn(self, obj)
	local dData = self.m_CData
	local dLevelInfo = g_ChapterFuBenCtrl:GetChapterLevelInfo(dData.type, dData.chapterid, dData.level)
	if dLevelInfo and dLevelInfo.star and dLevelInfo.star < 3 then
		g_NotifyCtrl:FloatMsg("3星通关开启扫荡")
	elseif g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.chapterfuben_sweep.open_grade then
		g_NotifyCtrl:FloatMsg(string.format("%s级开启扫荡", data.globalcontroldata.GLOBAL_CONTROL.chapterfuben_sweep.open_grade))
	else
		if not self:CheckEnergyAndFightTime() then
			return
		end
		CChapterFuBenSweepView:ShowView(function (oView)
			oView:SetChapterLevel(dData.chapterid, dData.level, dData.type)
		end)	
	end
end

function CChapterFuBenLavelPart.OnFightBtn(self, obj)
	if not self:CheckEnergyAndFightTime() then
		return
	end

	local dData = self.m_CData
	if g_ChapterFuBenCtrl.m_WarAfterReshow then
		g_WarCtrl:SetWarEndAfterCallback(function ()		
			g_ChapterFuBenCtrl:ForceChapterLevel(dData.type, dData.chapterid, dData.level)
		end)
	end	
	printc(dData.type, dData.chapterid, dData.level,"---------------------")
	nethuodong.C2GSFightChapterFb(dData.chapterid, dData.level, dData.type)
end

--检测体力和挑战次数
function CChapterFuBenLavelPart.CheckEnergyAndFightTime(self, chapterid, level)
	local dData = self.m_CData
	--体力检测
	if g_AttrCtrl.energy < dData.energy_cost then
		g_NotifyCtrl:FloatMsg("体力不足")
		if g_WelfareCtrl:IsFreeEnergyRedDot() then
			local windowConfirmInfo = {
				msg = "有未领取的体力，是否前往领取？",
				title = "提示",
				okCallback = function () 
					g_WelfareCtrl:ForceSelect(define.Welfare.ID.FreeEnergy)
				end,
				cancelCallback = function ()
					g_NpcShopCtrl:ShowGold2EnergyView()
				end,
				okStr = "确定",
				cancelStr = "取消",
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		else
			g_NpcShopCtrl:ShowGold2EnergyView()
		end
		return false
	end
	--次数检测
	local dLevelInfo = g_ChapterFuBenCtrl:GetChapterLevelInfo(dData.type, dData.chapterid, dData.level)
	if dLevelInfo and dLevelInfo.fight_time == dData.fight_time then
		g_NotifyCtrl:FloatMsg("今日挑战次数已达上限")
		return false
	end
	return true
end

function CChapterFuBenLavelPart.OnLockPartnerBtn(self, obj)
	if self.m_LockPartner == true then
		self.m_LockPartner = false
	else
		self.m_LockPartner = true
	end
	self.m_LockPartnerBtn:SetSelected(self.m_LockPartner)
	IOTools.SetRoleData("chapter_fuben_lockpartner", self.m_LockPartner)
	g_WarCtrl:SetLockPreparePartner(define.War.Type.ChapterFuBen, self.m_LockPartner)
end

function CChapterFuBenLavelPart.SetChapterLevel(self, type, chapterid, level)
	self.m_CData = DataTools.GetChapterConfig(type, chapterid, level)
	self.m_LockPartnerBtn:SetActive(chapterid > 2)
	self:SetLevelData(self.m_CData)
	self:RefreshLevelData()
	if chapterid == 1 and level == 2 then
		local guide_ui = {"chapter_fuben_fight_btn"}
		g_GuideCtrl:LoadTipsGuideEffect(guide_ui)	
	end	
	self.m_IsOpenAni = true
	local cb = function ()
		if Utils.IsNil(self) then
			return
		end
		self.m_IsOpenAni = false
		g_GuideCtrl:TriggerAll()
	end
	Utils.AddTimer(cb, 0, 0.7)	
end

function CChapterFuBenLavelPart.SetLevelData(self, dData)
	self.m_NameLabel:SetText(dData.name)
	self.m_EnergyLabel:SetText(string.format(" %d", dData.energy_cost))
	self.m_PowerLabel:SetText(dData.power) 
	--通关奖励
	self.m_ItemGrid:Clear()
	for i,v in ipairs(dData.ui_reward) do
		local box = self.m_ItemBox:Clone()
		box:SetActive(true)
		box:SetItemBySid(v.sid, v.num)
		self.m_ItemGrid:AddChild(box)
	end
	self.m_ItemGrid:Reposition()
	self.m_StarGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_Idx = idx
		oBox.m_StarSpr = oBox:NewUI(1, CSprite)
		oBox.m_StarLabel = oBox:NewUI(2, CLabel)
		return oBox
	end)
	self.m_SweepBtn:SetActive(dData.issweep == 1)
end

function CChapterFuBenLavelPart.RefreshLevelData(self)
	local dData = self.m_CData
	local dLevelInfo = g_ChapterFuBenCtrl:GetChapterLevelInfo(dData.type, dData.chapterid, dData.level)
	table.print(dLevelInfo,"-刷新关卡信息")
	if dLevelInfo then
		self.m_ChallengeLabel:SetText(string.format("已挑战次数:%d/%d", dLevelInfo.fight_time, dData.fight_time))
	end
	if dLevelInfo and dLevelInfo.star_condition and #dLevelInfo.star_condition > 0 then
		for i,v in ipairs(dLevelInfo.star_condition) do
			local oBox = self.m_StarGrid:GetChild(i)
			if v.reach == 1 then
				oBox.m_StarSpr:SetActive(true)
			else
				oBox.m_StarSpr:SetActive(false)
			end
			oBox.m_StarLabel:SetText(v.condition)
		end
	else
		for i,oBox in ipairs(self.m_StarGrid:GetChildList()) do
			oBox.m_StarSpr:SetActive(false)
			oBox.m_StarLabel:SetText(dData.star_condition[i])			
		end
	end
	self.m_SweepBtn:SetActive(dData.issweep == 1)
	if dLevelInfo and dLevelInfo.star and dLevelInfo.star < 3 then
		self.m_ConditionLabel:SetText("3星开启")
		self.m_SweepBtn:SetGrey(true)
	elseif g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.chapterfuben_sweep.open_grade then
		self.m_ConditionLabel:SetText(string.format("%d级开启", data.globalcontroldata.GLOBAL_CONTROL.chapterfuben_sweep.open_grade))
		self.m_SweepBtn:SetGrey(true)
	else
		self.m_ConditionLabel:SetText("")
		self.m_SweepBtn:SetGrey(false)
	end
end

return CChapterFuBenLavelPart