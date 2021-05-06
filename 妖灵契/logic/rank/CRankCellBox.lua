local CRankCellBox = class("CRankCellBox", CBox)

function CRankCellBox.ctor(self, ob)
	CBox.ctor(self, ob)
	self:InitContent()
end

function CRankCellBox.InitContent(self)
	self.m_AvatarSprite = self:NewUI(1, CSprite)
	self.m_ContentLabel = self:NewUI(2, CLabel)
	self.m_InfoBtn = self:NewUI(3, CSprite)
	self.m_NameLabel = self:NewUI(4, CLabel)
	self.m_LikePart = self:NewUI(5, CBox)
	self.m_AwardPart = self:NewUI(6, CGrid)
	self.m_JoinUnionBtn = self:NewUI(7, CButton)
	self.m_ReplayBtn = self:NewUI(8, CButton)
	self.m_FlagLabel = self:NewUI(9, CLabel)
	self.m_FlagBgSprite = self:NewUI(10, CSprite)
	self.m_RankLabel = self:NewUI(11, CLabel)
	self.m_RankBgSprite = self:NewUI(12, CSprite)
	self.m_DetailBtn = self:NewUI(13, CButton)
	self.m_Top3Sprite = self:NewUI(14, CSprite)
	self.m_PartnerBox = self:NewUI(15, CBox)
	self.m_ShowPart = self:NewUI(16, CBox)
	self.m_NoInfoTips = self:NewUI(17, CLabel)
	self.m_PartnerDetailBtn = self:NewUI(18, CBox)
	self.m_SelfMark = self:NewUI(19, CBox)

	self:SetActive(true)
	self.m_LabelParent = self.m_ContentLabel:GetParent()
	self.m_CurrentRankId = nil
	self.m_LabelArr = {}
	self.m_LabelArr[1] = self.m_ContentLabel
	self:InitLikePart()
	self:InitAward()
	self:InitPartnerBox()
	self.m_IsPlayerBox = true
	self.m_JoinUnionBtn:AddUIEvent("click", callback(self, "OnClickJoin"))
	self.m_ReplayBtn:AddUIEvent("click", callback(self, "OnClickReplay"))
	self.m_InfoBtn:AddUIEvent("click", callback(self, "OnClickInfo"))
	self.m_DetailBtn:AddUIEvent("click", callback(self, "OnClickDetailBtn"))
	self.m_PartnerDetailBtn:AddUIEvent("click", callback(self, "OnClickPartnerDetailBtn"))
end


function CRankCellBox.InitPartnerBox(self)
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

function CRankCellBox.OnClickInfo(self)
	if self.m_IsPlayerBox and self.m_Data.pid ~= g_AttrCtrl.pid then
		g_AttrCtrl:GetPlayerInfo(self.m_Data.pid, define.PlayerInfo.Style.WithoutPK)
	end
end

function CRankCellBox.OnClickPartnerDetailBtn(self)
	-- printc(string.format("OnClickPartnerDetailBtn %s %s %s", self.m_CurrentRankId, self.m_Data.parid, self.m_Data.pid))
	netrank.C2GSGetRankParInfo(self.m_CurrentRankId, self.m_Data.partype, self.m_Data.pid)
end

function CRankCellBox.InitAward(self)
	self.m_AwardPart:InitChild(function(obj, idx)
		local oBtn = CBox.New(obj, false)
		oBtn.m_IconSprite = oBtn:NewUI(1, CSprite)
		oBtn.m_QualitySprite = oBtn:NewUI(2, CSprite)
		oBtn.m_CountLabel = oBtn:NewUI(3, CLabel)
		oBtn:SetGroup(self:GetInstanceID())
		return oBtn
	end)
end

function CRankCellBox.OnClickDetailBtn(self)
	-- printc("OnClickDetailBtn")
	netplayer.C2GSPlayerTop4Partner(self.m_Data.pid)
end

function CRankCellBox.OnClickJoin(self)
	-- printc("OnClickJoin")
end

function CRankCellBox.OnClickReplay(self)
	-- printc("OnClickReplay: " .. self.m_Data.pid)
	if g_ActivityCtrl:ActivityBlockContrl("watchreplay") then
		netarena.C2GSArenaReplayByPlayerId(self.m_Data.pid, 1)
	end
end

function CRankCellBox.InitLikePart(self)
	self.m_LikePart.m_Btn = self.m_LikePart:NewUI(1, CButton)
	self.m_LikePart.m_Label = self.m_LikePart:NewUI(2, CLabel)
	self.m_LikePart.m_Mark = self.m_LikePart:NewUI(3, CLabel)
	self.m_LikePart.m_Btn:AddUIEvent("click", callback(self, "OnClickLike"))
	self.m_LikePartPos = self.m_LikePart:GetLocalPos()
	g_RankCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnLikeResult"))
end

function CRankCellBox.OnLikeResult(self, oCtrl)
	if oCtrl.m_EventID == define.Rank.Event.LikeSuccess and self.m_Data ~= nil and oCtrl.m_EventData == self.m_Data.pid then
		self.m_LikePart.m_Mark:SetActive(true)
		self.m_LikePart.m_Btn:SetActive(false)
		local oData = self.m_ParentView.m_ExtraData[self.m_Data.pid]
		if oData then
			self.m_LikePart.m_Label:SetText(tostring(oData.count))
		else
			self.m_LikePart.m_Label:SetText(tostring(tonumber(self.m_LikePart.m_Label:GetText()) + 1))
		end
	end
end

function CRankCellBox.OnClickLike(self)
	netplayer.C2GSUpvotePlayer(self.m_Data.pid)
end

function CRankCellBox.SetLabel(self, xposlist)
	for i=1,#xposlist do
		if self.m_LabelArr[i] == nil then
			self.m_LabelArr[i] = self.m_ContentLabel:Clone()
			self.m_LabelArr[i]:SetParent(self.m_LabelParent)
		end
		self.m_LabelArr[i]:SetLocalPos(Vector3.New(xposlist[i], 0, 0))
		self.m_LabelArr[i]:SetActive(true)
	end
	for i=#xposlist+1,#self.m_LabelArr do
		self.m_LabelArr[i]:SetActive(false)
	end
end


function CRankCellBox.SetData(self, oData, index, iSub)
	self.m_ShowPart:SetActive(true)
	self.m_NoInfoTips:SetActive(false)
	self.m_SelfMark:SetActive(false)
	if index == nil then
		self.m_InfoBtn:SetSpriteName("")
	else
		if index % 2 == 1 then
			self.m_InfoBtn:SetSpriteName("bg_cijimian_diban_ecsd")
		else
			-- self.m_InfoBtn:SetSpriteName("pic_rank_di02")
			self.m_InfoBtn:SetSpriteName("")
		end
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
		self:SetLabel(self.m_RankInfo.content_xpos)
	end
	self.m_CurrentRankId = self.m_ParentView.m_CurrentRankId
	if self.m_CurrentRankId == define.Rank.RankId.Partner and iSub == 0 or iSub == nil then
		self.m_NoInfoTips:SetText("")
	else
		self.m_NoInfoTips:SetText("未上榜")
	end

	--前三特殊处理
	self.m_Top3Sprite:SetActive(false)
	if oData.rank == 1 or oData.rank == 2 or oData.rank == 3 then
		self.m_RankLabel:SetActive(false)
		self.m_RankBgSprite:SetActive(true)
		if oData.rank == 1 then
			self.m_Top3Sprite:SetActive(true)
			self.m_RankBgSprite:SetSpriteName("pic_rank_01")
		elseif oData.rank == 2 then
			self.m_RankBgSprite:SetSpriteName("pic_rank_02")
		elseif oData.rank == 3 then
			self.m_RankBgSprite:SetSpriteName("pic_rank_03")
		end
	else
		self.m_RankLabel:SetActive(true)
		self.m_RankBgSprite:SetActive(false)
	end

	local count = 0
	local attributeList = data.rankdata.DATA[self.m_CurrentRankId].attribute
	for i = 1, #attributeList do
		local attribute = data.rankdata.Attribute[attributeList[i]]
		if attribute.key == "name" and self.m_CurrentRankId ~= define.Rank.RankId.Partner then
			self.m_NameLabel:SetText(oData.name)
		elseif attribute.key == "rank" then
			self.m_RankLabel:SetText("" .. oData.rank)
		elseif attribute.key == "shape" then
			self.m_IsPlayerBox = true
			self.m_AvatarSprite:SetActive(true)
			self.m_AvatarSprite:SetSpriteName(tostring(oData.shape))
		elseif attribute.key == "flag" then
			self.m_FlagLabel:SetText(oData.flag)
		elseif attribute.key == "flagbgid" then
			self.m_IsPlayerBox = false
			self.m_FlagBgSprite:SetActive(true)
			self.m_FlagBgSprite:SetSpriteName(g_OrgCtrl:GetFlagIcon(oData.flagbgid))
		elseif attribute.key == "org_name" then
			self.m_NameLabel:SetText(oData.org_name)
		elseif attribute.key == "parname" then
			if oData then
				local partnerData = data.partnerdata.DATA[oData.partype]
				if partnerData then
					self.m_PartnerBox:SetData(oData, partnerData)
					self.m_NameLabel:SetText(oData.parname)
					self.m_PartnerBox:SetActive(true)
				else
					self.m_ShowPart:SetActive(false)
					self.m_NoInfoTips:SetActive(true)
				end
				if oData.pid == g_AttrCtrl.pid then
					self.m_SelfMark:SetActive(true)
				end
			end
		else
			count = count + 1
			if attribute.key == "segment" then
				self.m_LabelArr[count]:SetText(g_ArenaCtrl:GetGradeDataByPoint(oData.point).rank_name)
			elseif attribute.key == "school" then
				self.m_LabelArr[count]:SetText(data.schooldata.DATA[oData.school].name)
			else
				self.m_LabelArr[count]:SetText(oData[attribute.key])
			end
		end
	end

	self:ShowHandle(self.m_RankInfo.handle_id, index)
	return true
end

function CRankCellBox.ShowHandle(self, handleType, index)
	self.m_LikePart:SetActive(false)
	self.m_AwardPart:SetActive(false)
	self.m_JoinUnionBtn:SetActive(false)
	self.m_ReplayBtn:SetActive(false)
	self.m_DetailBtn:SetActive(false)
	self.m_PartnerDetailBtn:SetActive(false)
	if index == nil then
		return
	end

	if handleType == define.Rank.HandleType.Like or handleType == define.Rank.HandleType.ReplayAndLike 
	or handleType == define.Rank.HandleType.DetailAndLike then
		local extraData = self.m_ParentView.m_ExtraData[self.m_Data.pid]
		if extraData ~= nil then
			self.m_LikePart:SetActive(true)
			self.m_LikePart.m_Mark:SetActive(extraData.status == 1 and self.m_Data.pid ~= g_AttrCtrl.pid)
			self.m_LikePart.m_Btn:SetActive(extraData.status == 0 and self.m_Data.pid ~= g_AttrCtrl.pid)
			self.m_LikePart.m_Label:SetText(tostring(extraData.count))
		else
			
		end
	end
	if handleType == define.Rank.HandleType.Like then
		self.m_LikePart:SetLocalPos(Vector3.New(16, 0, self.m_LikePartPos.z))
	else
		self.m_LikePart:SetLocalPos(self.m_LikePartPos)
	end

	if handleType == define.Rank.HandleType.AwardList then
		self.m_AwardPart:SetActive(true)
	end
	if handleType == define.Rank.HandleType.ReplayAndLike then
		self.m_ReplayBtn:SetActive(true)
	end
	if handleType == define.Rank.HandleType.JoinUnion then
		self.JoinUnionPart:SetActive(true)
	end
	if handleType == define.Rank.HandleType.DetailAndLike then
		self.m_DetailBtn:SetActive(true)
	end
	if handleType == define.Rank.HandleType.PartnerDetail then
		self.m_PartnerDetailBtn:SetActive(true)
	end
end

return CRankCellBox
