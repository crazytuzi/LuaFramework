---------------------------------------------------------------
--物品简单信息展示窗口


---------------------------------------------------------------

local CItemTipsSimpleInfoPage = class("CItemTipsSimpleInfoPage", CPageBase)

function CItemTipsSimpleInfoPage.ctor(self, obj)
	self.m_ItemInfo = nil
	CPageBase.ctor(self, obj)
end

function CItemTipsSimpleInfoPage.OnInitPage(self)
	self.m_PageWidget = self:NewUI(1, CWidget)
	self.m_IconSprite = self:NewUI(2, CSprite)
	self.m_QualitySprite = self:NewUI(3, CSprite)
	self.m_NameLabel = self:NewUI(4, CLabel)
	self.m_TypeLabel = self:NewUI(5, CLabel)
	self.m_UseforLabel = self:NewUI(6, CLabel)
	self.m_DesLabel = self:NewUI(7, CLabel)
	self.m_BgSprite = self:NewUI(8, CSprite)
	self.m_ItemBG = self:NewUI(9, CSprite)
	self.m_DebrisBox = self:NewUI(10, CBox)

	self:InitContent()
end

function CItemTipsSimpleInfoPage.InitContent(self, type)
	self.m_DebrisBox:SetActive(false)
end

function CItemTipsSimpleInfoPage.ShowPage(self, sid, parId, config)
	CPageBase.ShowPage(self)
	self:SetInitBox(sid, parId, config)
end

function CItemTipsSimpleInfoPage.SetInitBox( self, sid, parId, config)
	local tItem	= CItem.NewBySid(sid) 
	if not tItem then
		return		
	end
	self.m_ItemInfo = tItem
	self:RefreshBaeInfo(sid, parId, config)
end

function CItemTipsSimpleInfoPage.RefreshBaeInfo(self, sid, parId, config)
	local oItem = self.m_ItemInfo
	local shape = oItem:GetValue("icon") or 0
	local quality = nil
	if config and config.quality then
		quality = config.quality
	else
		quality = oItem:GetValue("itemlevel") or 0
	end	
	local name = oItem:GetValue("name") or ""
	local iType = oItem:GetValue("type")
	local usefor = oItem:GetValue("introduction")
	local key = oItem:GetValue("key")
	local bing =  oItem:IsBingdingItem()
	local limit = oItem:IsLimitItem()
	local des = oItem:GetValue("description")
	local count = oItem:GetValue("amount")	

	local gPartId = tonumber(data.globaldata.GLOBAL.partner_reward_itemid.value)
	if gPartId == sid then
		self.m_IconSprite:SpriteAvatar(parId)
	elseif oItem:GetValue("partner_type") then
		self.m_ItemBG:SetActive(false)
		self.m_DebrisBox:SetActive(true)
		local oBox=self.m_DebrisBox
		oBox.m_AvatarSpr = oBox:NewUI(1, CSprite)
		oBox.m_BorderSpr = oBox:NewUI(2, CSprite)
		oBox.m_ChipSpr = oBox:NewUI(3, CSprite)
		oBox.m_AvatarSpr:SpriteAvatar(oItem:GetValue("icon"))
		g_PartnerCtrl:ChangeRareBorder(oBox.m_BorderSpr, oItem:GetValue("rare"))
		local filename = define.Partner.CardColor[oItem:GetValue("rare")] or "hui"
		oBox.m_ChipSpr:SetSpriteName("pic_suipian_"..filename.."se")
	else
		self.m_IconSprite:SpriteItemShape(shape)
	end

	self.m_QualitySprite:SetItemQuality(quality)
	self.m_NameLabel:SetText(name)
	local  typeAndUseforStr = ""
	if iType ~= nil then
		typeAndUseforStr = typeAndUseforStr .. "类型: "..define.Item.ItemTypeString[iType] .. "\n"
	end			
	if des ~= nil and des ~= "" then
		typeAndUseforStr = typeAndUseforStr .. des
	end
	self.m_TypeLabel:SetText(typeAndUseforStr)
	self.m_DesLabel:SetText(usefor)
	self:ResetBg()
end

function CItemTipsSimpleInfoPage.ResetBg(self)
	local h1 = self.m_TypeLabel:GetHeight()
	local h2 = self.m_DesLabel:GetHeight()
	local h3 = self.m_BgSprite:GetHeight()
	local h = h1 + h2 + h3 
	if h < 200 then
		h = 200
	end
	self.m_BgSprite:SetHeight(h)
end

return CItemTipsSimpleInfoPage