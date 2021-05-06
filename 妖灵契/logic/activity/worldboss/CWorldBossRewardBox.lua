local CWorldBossRewardBox = class("CWorldBossRewardBox", CBox)

function CWorldBossRewardBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_BoxClone = self:NewUI(1, CBox)
	self.m_BaseGrid = self:NewUI(2, CGrid)
	self.m_ExtraGrid = self:NewUI(3, CGrid)
	self.m_DescLabel = self:NewUI(4, CLabel)
	self.m_BGSprite = self:NewUI(5, CSprite)
	self.m_DebrisBoxClone = self:NewUI(6, CBox)
	self.m_RewardSpr = self:NewUI(7, CSprite)
	self.m_BoxClone:SetActive(false)
	self.m_DebrisBoxClone:SetActive(false)
end

function CWorldBossRewardBox.SetRewardIdx(self, iRewardIdx, bigboss)
	local dData = data.worldbossdata.REWARD[iRewardIdx]
	if not dData then
		printerror("世界boss导表错误", iRewardIdx)
		return
	end
	if iRewardIdx == 0 then
		self.m_DescLabel:SetFontSize(26)
		self:SetBGSprite("pic_xinxiziji")
		self:SetRewardSpr("pic_xinxiziji")
	elseif iRewardIdx <=3 then
		self.m_DescLabel:SetFontSize(26)
		self:SetBGSprite("pic_paimingditeshu")
		self:SetRewardSpr("pic_paimingditeshu")
	else
		self.m_DescLabel:SetFontSize(26)
		self:SetBGSprite("pic_paimingdiputong")
		self:SetRewardSpr("pic_paimingdiputong")
	end
	self.m_DescLabel:SetText(dData.desc)
	if bigboss and bigboss == 1 then
		for i, dReward in ipairs(dData.boss_rank_reward) do
			local oBox = self:CreateBox(dReward)
			self.m_BaseGrid:AddChild(oBox)
		end

		for i, dReward in ipairs(dData.boss_extra_reward) do
			local oBox = self:CreateBox(dReward)
			self.m_ExtraGrid:AddChild(oBox)
		end
	else
		for i, dReward in ipairs(dData.rank_reward) do
			local oBox = self:CreateBox(dReward)
			self.m_BaseGrid:AddChild(oBox)
		end

		for i, dReward in ipairs(dData.extra_reward) do
			local oBox = self:CreateBox(dReward)
			self.m_ExtraGrid:AddChild(oBox)
		end
	end
end

function CWorldBossRewardBox.CreateBox(self, dReward)
	local oItem, oBox
	oItem = CItem.NewBySid(dReward.id)
	if oItem:GetValue("partner_type") then
		oBox=self.m_DebrisBoxClone:Clone()
		oBox.m_AvatarSpr = oBox:NewUI(1, CSprite)
		oBox.m_BorderSpr = oBox:NewUI(2, CSprite)
		oBox.m_ChipSpr = oBox:NewUI(3, CSprite)
		oBox.m_Label = oBox:NewUI(4, CLabel)
		oBox.m_AvatarSpr:SpriteAvatar(oItem:GetValue("icon"))
		oBox.m_Label:SetNumberString(dReward.num, 10000)
		g_PartnerCtrl:ChangeRareBorder(oBox.m_BorderSpr, oItem:GetValue("rare"))
		local filename = define.Partner.CardColor[oItem:GetValue("rare")] or "hui"
		oBox.m_ChipSpr:SetSpriteName("pic_suipian_"..filename.."se")
		oBox:AddUIEvent("click", callback(self, "OnDebrisBox", dReward.id))
	else
		oBox = self.m_BoxClone:Clone()
		oBox.m_Icon = oBox:NewUI(1, CSprite)
		oBox.m_Label = oBox:NewUI(2, CLabel)
		oBox.m_Icon:SpriteItemShape(oItem:GetValue("icon"))
		oBox.m_Label:SetNumberString(dReward.num, 10000)
		oBox:AddUIEvent("click", callback(self, "ShowItemTips", dReward.id))
	end
	oBox:SetActive(true)
	return oBox
end

function CWorldBossRewardBox.ShowItemTips(self, sid, oBox)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid, {widget =  oBox}, nil)
end

function CWorldBossRewardBox.OnDebrisBox(self, sid, oBox)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid, {widget = oBox}, nil)
end

function CWorldBossRewardBox.SetBGSprite(self, sSprite)
	self.m_BGSprite:SetSpriteName(sSprite)
end

function CWorldBossRewardBox.SetRewardSpr(self, sSprite)
	self.m_RewardSpr:SetSpriteName(sSprite)
end

return CWorldBossRewardBox