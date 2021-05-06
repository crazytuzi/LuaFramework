local CYJMainView = class("CYJMainView", CViewBase)

function CYJMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/YJFuben/YJFubenView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_SwitchSceneClose = true
end

function CYJMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TypeBtnList = {}
	for i = 1, 3 do
		local btn = self:NewUI(1+i, CSprite)
		self.m_TypeBtnList[i] = btn
		btn:SetGroup(self.m_TypeBtnList[1]:GetInstanceID())
		btn:AddUIEvent("click", callback(self, "OnChangeType"))
	end
	self.m_AddBtn = self:NewUI(5, CButton)
	self.m_ConfirmBtn = self:NewUI(6, CButton)
	self.m_LeftLabel = self:NewUI(7, CLabel)
	self.m_FightBtn = self:NewUI(8, CSprite)
	self.m_HelpTipBtn = self:NewUI(9, CButton)
	self.m_RankBtn = self:NewUI(10, CButton)
	self.m_AwardGrid = self:NewUI(11, CGrid)
	self.m_ItemBox = self:NewUI(12, CItemTipsBox)
	self.m_RandAwardBtn = self:NewUI(13, CButton)
	self.m_TeamBtn = self:NewUI(14, CButton)
	self.m_LevelLabel = self:NewUI(15, CLabel)
	self:InitContent()
end

function CYJMainView.InitContent(self)
	self.m_Type = 1
	self.m_TypeBtnList[1]:SetSelected(true)
	self.m_ItemBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AddBtn:AddUIEvent("click", callback(self, "OnAddFuben"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnEnterFuben"))
	self.m_FightBtn:AddUIEvent("click", callback(self, "OnOpenFightView"))
	self.m_HelpTipBtn:AddHelpTipClick("yjfuben")
	self.m_RankBtn:AddUIEvent("click", callback(self, "OnOpenRankView"))
	self.m_RandAwardBtn:AddUIEvent("click", callback(self, "OnOpenRankAward"))
	self.m_TeamBtn:AddUIEvent("click", callback(self, "OnMakeTeam"))
	self:OnChangeType()
end

function CYJMainView.RefreshData(self, iRemain, iBuy)
	self.m_RemainTime = iRemain
	self.m_BuyTime = iBuy
	self.m_LeftLabel:SetText(string.format("剩余挑战次数：%d", iRemain))
end

function CYJMainView.UpdateAward(self)
	local awardList = self:GetAwardList()
	self.m_AwardGrid:Clear()
	for _, oAward in ipairs(awardList) do
		local t = self:ParseReward(oAward)
		if t then
			local box = self.m_ItemBox:Clone()
			if t.key == "value" then
				box:SetItemData(t.itemid, t.value)
			else
				box:SetItemData(t.itemid, t.amount, t.value)
			end
			box:SetActive(true)
			self.m_AwardGrid:AddChild(box)
		end
	end
	self.m_AwardGrid:Reposition()
end

function CYJMainView.ParseReward(self, dData)
	local pat1 = "(%d+)%((%a+)=(%d+)%)"
	local pat2 = "(%d+)"
	local resultList = {}
	
	local amount = dData.amount
	local k1, k2, k3 = string.match(dData.sid, pat1)
	if k1 then
		local t = {
			itemid = tonumber(k1),
			key = tostring(k2),
			value = tonumber(k3),
			amount = amount,
		}
		return t
	else
		local k1, k2 = string.match(dData.sid, pat2)
		if k1 then
			local t = {
				itemid = tonumber(k1),
				amount = amount,
			}
			table.insert(resultList, t)
			return t
		end
	end
end

function CYJMainView.GetAwardList(self)
	local type2text = {"普通", "困难", "地狱"}
	local sType = type2text[self.m_Type] or "普通"
	local awardList = {}
	for _, tAward in ipairs(data.yjfubendata.REWARD) do
		if tAward.stype == sType then
			table.insert(awardList, tAward)
		end
	end
	return awardList
end

function CYJMainView.OnChangeType(self)
	local itype = 1
	for i, btn in ipairs(self.m_TypeBtnList) do
		if btn:GetSelected() then
			itype = i
		end
	end
	self.m_Type = itype
	local iTarget, _ = self:GetDefaultType()
	local tdata = data.teamdata.AUTO_TEAM[iTarget]
	if tdata then
		self.m_LevelLabel:SetText("挑战等级："..tostring(tdata["unlock_level"]))
	else
		self.m_LevelLabel:SetText("")
	end
	self:UpdateAward()
end

function CYJMainView.SetChangeType(self, iType)
	if self.m_Type == iType then
		return
	end

	for i, btn in ipairs(self.m_TypeBtnList) do
		if i == iType then
			btn:SetSelected(true)
		else
			btn:SetSelected(false)
		end
	end
	self:OnChangeType()
end

function CYJMainView.OnAddFuben(self)
	if self.m_BuyTime < 1 then
		g_NotifyCtrl:FloatMsg("你已经购买过了")
		return
	end
	CYJFbBuyView:ShowView(function (oView)
		oView:RefreshData(self.m_RemainTime, self.m_BuyTime)
	end
	)
end

function CYJMainView.OnEnterFuben(self)
	if g_TeamCtrl:IsInTeam() and not g_TeamCtrl:IsLeader() then
		g_NotifyCtrl:FloatMsg("只有队长才能进行此操作")
		return
	end
	if self.m_LastEnterTime and g_TimeCtrl:GetTimeS() - self.m_LastEnterTime < 2 then
		g_NotifyCtrl:FloatMsg("你的操作过于频繁")
	else
		self.m_LastEnterTime = g_TimeCtrl:GetTimeS()
		nethuodong.C2GSEnterYJFuben(self.m_Type)
	end
end

function CYJMainView.OnOpenFightView(self)
	nethuodong.C2GSYJFubenView(1001)
end

function CYJMainView.OnOpenRankView(self)
	g_RankCtrl:OpenRank(define.Rank.RankId.RJFb)
end

function CYJMainView.OnOpenRankAward(self)
	CYJRankAwardView:ShowView()
end

function CYJMainView.OnMakeTeam(self)
	local targetid = self:GetDefaultType()
	CTeamMainView:ShowView(function (oView)
		oView:OnSwitchPage(2, targetid)
		local min, max = g_TeamCtrl:GetTeamTargetDefaultLevel(targetid)
		oView.m_HandyBuildPage:SetLevelButtonText(min, max)		
		oView.m_HandyBuildPage:OnAutoMatch()
	end)
end

--获取当前组队目标
function CYJMainView.GetDefaultType(self)
	local target = 1161
	local maxgrade = g_AttrCtrl.server_grade
	if self.m_Type == 2 then
		target = 1162
	elseif self.m_Type == 3 then
		target = 1163
	end
	local targetInfo = {
		auto_target = target,
	}

	return target, targetInfo
end

return CYJMainView