local CTimeLimitRankCellBox = class("CTimeLimitRankCellBox", CBox)

function CTimeLimitRankCellBox.ctor(self, ob)
	CBox.ctor(self, ob)
	self:InitContent()
end

function CTimeLimitRankCellBox.InitContent(self)
	self.m_AvatarSprite = self:NewUI(1, CSprite)
	self.m_ContentLabel = self:NewUI(2, CLabel)
	self.m_InfoBtn = self:NewUI(3, CSprite)
	self.m_NameLabel = self:NewUI(4, CLabel)
	self.m_RewardGrid = self:NewUI(5, CGrid)
	self.m_ItemTipsBox = self:NewUI(6, CItemTipsBox)
	self.m_NoRewardTips = self:NewUI(7, CLabel)
	self.m_PartnerBox = self:NewUI(8, CBox)
	self.m_TitleSprite = self:NewUI(9, CSprite)
	self.m_FlagBgSprite = self:NewUI(10, CSprite)
	self.m_RankLabel = self:NewUI(11, CLabel)
	self.m_RankBgSprite = self:NewUI(12, CSprite)
	self.m_ShowPart = self:NewUI(13, CBox)
	self.m_NoInfoTips = self:NewUI(14, CLabel)
	self.m_OrgMarkSprite = self:NewUI(15, CSprite)
	self.m_SelfMark = self:NewUI(16, CBox)

	self:SetActive(true)
	self.m_OrgMarkSprite:SetActive(false)
	self.m_CurrentRankId = nil
	self.m_RewardBoxArr = {}
	self:InitPartnerBox()
end

function CTimeLimitRankCellBox.InitPartnerBox(self)
	local oPartnerBox = self.m_PartnerBox
	oPartnerBox.m_ShapeSprite = oPartnerBox:NewUI(1, CSprite)
	oPartnerBox.m_GradeLabel = oPartnerBox:NewUI(2, CLabel)
	oPartnerBox.m_ShapeBgSprite = oPartnerBox:NewUI(3, CSprite)
	oPartnerBox.m_StarGrid = oPartnerBox:NewUI(4, CGrid)
	oPartnerBox.m_AwakeSprite = oPartnerBox:NewUI(5, CSprite)
	oPartnerBox.m_StarBoxArr = {}

	oPartnerBox.m_StarGrid:InitChild(function (starBox, idx)
		local oStarBox = CBox.New(starBox)
		oStarBox.m_BgSprite = oStarBox:NewUI(1, CSprite)
		oStarBox.m_StarSprite = oStarBox:NewUI(2, CSprite)
		oStarBox.m_StarSprite:SetActive(false)
		oPartnerBox.m_StarBoxArr[idx] = oStarBox
		return oStarBox
	end)
	function oPartnerBox.SetData(self, oData, oPartnerData)
		if oData then
			oPartnerBox:SetActive(true)
			oPartnerBox.m_ShapeSprite:SpriteAvatar(oPartnerData.shape)
			oPartnerBox.m_GradeLabel:SetText(oData.pargrade)
			g_PartnerCtrl:ChangeRareBorder(oPartnerBox.m_ShapeBgSprite, oPartnerData.rare)
			for i,v in ipairs(oPartnerBox.m_StarBoxArr) do
				v.m_StarSprite:SetActive(i <= oData.star)
			end
			oPartnerBox.m_AwakeSprite:SetActive(oData.awake == 1)
		else
			oPartnerBox:SetActive(false)
		end
		oPartnerBox.m_StarGrid:Reposition()
	end

	return oPartnerBox
end

function CTimeLimitRankCellBox.SetData(self, oData, index, iSub)
	local sub = iSub or 0
	self.m_ShowPart:SetActive(true)
	self.m_NoInfoTips:SetActive(false)
	self.m_SelfMark:SetActive(false)
	if index == nil then
		self.m_InfoBtn:SetSpriteName("")
	end

	if oData == nil then
		self:SetActive(false)
		-- printc("index nil oData: " .. index)
		return false
	end
	self:SetActive(true)
	self.m_Data = oData
	if self.m_CurrentRankId ~= self.m_ParentView.m_CurrentRankId then
		self.m_AvatarSprite:SetActive(false)
		self.m_FlagBgSprite:SetActive(false)
		self.m_PartnerBox:SetActive(false)
		self.m_RankInfo = self.m_ParentView.m_RankInfo
	end
	self.m_CurrentRankId = self.m_ParentView.m_CurrentRankId
	
	if self.m_CurrentRankId == define.Rank.RankId.Partner then
		sub = oData.partype or 0
	end
	if self.m_CurrentRankId == define.Rank.RankId.Partner and iSub == 0 or iSub == nil then
		self.m_NoInfoTips:SetText("")
	else
		self.m_NoInfoTips:SetText("未上榜")
	end
	--前三特殊处理
	self.m_RankLabel:SetActive(false)
	self.m_RankBgSprite:SetActive(false)
	self.m_TitleSprite:SetActive(false)
	local rewardData = nil
	if data.rankdata.RushReward[self.m_CurrentRankId] and data.rankdata.RushReward[self.m_CurrentRankId][sub] then
		rewardData = data.rankdata.RushReward[self.m_CurrentRankId][sub][oData.rank]
	end
	local titleData = nil
	self.m_NoRewardTips:SetActive(true)
	self.m_RewardGrid:SetActive(rewardData ~= nil)
	if rewardData then
		titleData = data.titledata.DATA[rewardData.title]
		--会长奖励
		local count = 1
		for i,v in ipairs(rewardData.org_leader_reward) do
			local oRewardBox = self:GetRewardBox(count)
			self:CheckOrgMark(oRewardBox)
			oRewardBox:SetSid(v.sid, v.amount, {isLocal = true, uiType = 1})
			oRewardBox:SetActive(true)
			count = count + 1
		end
		--会长称谓
		if rewardData.org_leader_title ~= 0 then
			local oRewardBox = self:GetRewardBox(count)
			self:CheckOrgMark(oRewardBox)
			oRewardBox:SetTitle(rewardData.org_leader_title)
			oRewardBox:SetActive(true)
			count = count + 1
		end
		--正常奖励
		local rewardList = {}
		for i,v in ipairs(rewardData.reward) do
			table.insert(rewardList, v)
		end
		if rewardData.org_cash ~= 0 then
			local orgCase = {
				sid = string.format("1015(value=%s)", rewardData.org_cash),
				amount = 1,
			}
			table.insert(rewardList, orgCase)
		end
		for i,v in ipairs(rewardList) do
			local oRewardBox = self:GetRewardBox(count)
			if oRewardBox.m_OrgMarkSprite then
				oRewardBox.m_OrgMarkSprite:SetActive(false)
			end
			oRewardBox:SetSid(v.sid, v.amount, {isLocal = true, uiType = 1})
			oRewardBox:SetActive(true)
			count = count + 1
		end
		self.m_NoRewardTips:SetActive(count <= 1)
		for i=count, #self.m_RewardBoxArr do
			self.m_RewardBoxArr[i]:SetActive(false)
		end
	end

	if rewardData and titleData then
		if titleData.icon and titleData.icon ~= "" then
			self.m_TitleSprite:SetActive(true)
			self.m_TitleSprite:SpriteTitle(titleData.icon)
			self.m_TitleSprite:MakePixelPerfect()
			local w,h = self.m_TitleSprite:GetSize()
			if w > 164 then
				self.m_TitleSprite:SetSize(164, h * 164 / w)
			end
		else
			self.m_RankLabel:SetActive(true)
			self.m_RankLabel:SetText(titleData.name)
		end
	elseif oData.rank == 1 or oData.rank == 2 or oData.rank == 3 then
		self.m_RankBgSprite:SetActive(true)
		if oData.rank == 1 then
			self.m_RankBgSprite:SetSpriteName("pic_rank_01")
		elseif oData.rank == 2 then
			self.m_RankBgSprite:SetSpriteName("pic_rank_02")
		elseif oData.rank == 3 then
			self.m_RankBgSprite:SetSpriteName("pic_rank_03")
		end
	else
		self.m_RankLabel:SetActive(true)
		self.m_RankLabel:SetText(oData.rank)
	end

	if self.m_CurrentRankId == define.Rank.RankId.Pata then
		self.m_NameLabel:SetText(oData.name)
		self.m_ContentLabel:SetText(string.format("(层数:%s)", oData.level))
		self.m_AvatarSprite:SetActive(true)
		self.m_AvatarSprite:SetSpriteName(tostring(oData.shape))
	elseif self.m_CurrentRankId == define.Rank.RankId.Arena then
		self.m_NameLabel:SetText(oData.name)
		self.m_ContentLabel:SetText(string.format("(%s-%s积分)", g_ArenaCtrl:GetGradeDataByPoint(oData.point).rank_name, oData.point))
		self.m_AvatarSprite:SetActive(true)
		self.m_AvatarSprite:SetSpriteName(tostring(oData.shape))
	elseif self.m_CurrentRankId == define.Rank.RankId.OrgPrestige then
		self.m_NameLabel:SetText(oData.org_name)
		self.m_ContentLabel:SetText(string.format("(公会声望:%s)", oData.prestige))
		self.m_FlagBgSprite:SetActive(true)
		self.m_FlagBgSprite:SetSpriteName(g_OrgCtrl:GetFlagIcon(oData.flagbgid))
	elseif self.m_CurrentRankId == define.Rank.RankId.Partner then
		if oData then
			local partnerData = data.partnerdata.DATA[oData.partype]
			if partnerData then
				self.m_PartnerBox:SetData(oData, partnerData)
				self.m_NameLabel:SetText(oData.name)
				self.m_PartnerBox:SetActive(true)
				self.m_ContentLabel:SetText(string.format("%s\n(战力:%s)", oData.parname, oData.power))
			else
				self.m_ShowPart:SetActive(false)
				self.m_NoInfoTips:SetActive(true)
			end
			if oData.pid == g_AttrCtrl.pid then
				self.m_SelfMark:SetActive(true)
			end
		end
	elseif self.m_CurrentRankId == define.Rank.RankId.Consume then
		self.m_NameLabel:SetText(oData.name)
		self.m_ContentLabel:SetText(string.format("#w2%s", oData.consume))
		self.m_AvatarSprite:SetActive(true)
		self.m_AvatarSprite:SetSpriteName(tostring(oData.shape))
	end

	return true
end

function CTimeLimitRankCellBox.CheckOrgMark(self, oBox)
	if oBox.m_OrgMarkSprite == nil then
		local oOrgMark = self.m_OrgMarkSprite:Clone()
		oOrgMark:SetActive(true)
		oOrgMark:SetParent(oBox.m_Transform)
		oOrgMark:SetLocalScale(Vector3.one)
		oOrgMark:SetLocalPos(Vector3.New(23, 23, 0))
		oBox.m_OrgMarkSprite = oOrgMark
	else
		oBox.m_OrgMarkSprite:SetActive(true)
	end
end

function CTimeLimitRankCellBox.GetRewardBox(self, iCount)
	if self.m_RewardBoxArr[iCount] == nil then
		self.m_RewardBoxArr[iCount] = self.m_ItemTipsBox:Clone()
		self.m_RewardGrid:AddChild(self.m_RewardBoxArr[iCount])
	end
	return self.m_RewardBoxArr[iCount]
end

return CTimeLimitRankCellBox
