local CPartnerCommentItem = class("CPartnerCommentItem", CBox)

function CPartnerCommentItem.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ContentLabel = self:NewUI(1, CLabel)
	self.m_NameLable = self:NewUI(2, CLabel)
	self.m_LikeBtn = self:NewUI(3, CButton)
	self.m_LikeAmount = self:NewUI(4, CLabel)
	self.m_BestSpr = self:NewUI(5, CLabel)
	self.m_GreyLikeBtn = self:NewUI(6, CButton)
	self.m_BGSpr = self:NewUI(7, CSprite)
	self.m_GreyLikeBtn:SetActive(false)
	self.m_NameLable:AddUIEvent("click", callback(self, "OnPlayer"))
	self.m_LikeBtn:AddUIEvent("click", callback(self, "OnLike"))
end

function CPartnerCommentItem.SetData(self, data, partnertype, itype)
	self.m_PartnerType = partnertype
	self.m_Type = itype
	self.m_ID = data["id"]
	self.m_PID = data["pid"]
	self.m_NameLable:SetText(data["name"])
	self.m_ContentLabel:SetText(data["msg"])
	self.m_Amount = #data["vote_list"]
	self.m_LikeAmount:SetText(tostring(self.m_Amount))
	self.m_GreyLikeBtn:SetActive(false)
	for _, pid in ipairs(data["vote_list"]) do
		if pid == g_AttrCtrl.pid then
			self.m_GreyLikeBtn:SetActive(true)
			break
		end
	end
	self.m_BestSpr:SetActive(itype == 1)
	self.m_Content = data["msg"]
end

function CPartnerCommentItem.GetID(self)
	return self.m_ID
end

function CPartnerCommentItem.GetContent(self)
	return self.m_Content
end

function CPartnerCommentItem.SetBGColor(self, isblack)
	if isblack then
		self.m_BGSpr:SetSpriteName("bg_ciji_di")
	else
		self.m_BGSpr:SetSpriteName("bg_fenge") 
	end
end
function CPartnerCommentItem.OnLike(self)
	netpartner.C2GSUpVotePartnerComment(self.m_PartnerType, self.m_ID, self.m_Type)
end

function CPartnerCommentItem.OnPlayer(self)
	g_AttrCtrl:GetPlayerInfo(self.m_PID, define.PlayerInfo.Style.Default)
end

return CPartnerCommentItem