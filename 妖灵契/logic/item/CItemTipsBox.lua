
--点击可现实简单信息的道具模板
local CItemTipsBox = class("CItemTipsBox", CBox)

CItemTipsBox.ShowType = 
{
	None = 1,			--默认
	NormalItem = 2, 	--普通道具
	PartnerChip = 3,	--伙伴碎片
	Partner = 4,		--伙伴
	PartnerEquip = 5,	--伙伴符文
	HeroSkin = 6, 		--英雄皮肤
	Equip = 7, 			--装备
	ParSoul = 8,		--伙伴御灵
}

function CItemTipsBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_IconSprite = self:NewUI(1, CSprite)	 
	self.m_QualitySprite = self:NewUI(2, CSprite)	  
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_CountLabel = self:NewUI(4, CLabel)
	self.m_TitleID = nil
	self.m_Id = nil
	self.m_Sid = nil
	self.m_Count = nil
	self.m_Quality = 0
	self.m_PartnerEquip = nil
	self.m_PartnerID = nil
	self.m_Config = nil
	self.m_ShowTip = true
	self.m_HousePartnerID = nil
	self.m_BehindStrike = true
	self.m_IsEquip = false
	self.m_IsTitle = false
	self.m_UIType = 0
	self.m_Effect = nil
	self.m_UIShowType = CItemTipsBox.ShowType.None
	self:AddUIEvent("click", callback(self, "OnClickTipsBox"))
end

function CItemTipsBox.SetShowTips(self, bValue)
	self.m_ShowTip = bValue
end

function CItemTipsBox.SetBehindStrike(self, bValue)
	self.m_BehindStrike = bValue
end

function CItemTipsBox.OnClickTipsBox(self)
	if not self.m_ShowTip then
		return
	end
	if self.m_IsTitle then
		g_WindowTipCtrl:SetTitleSimpleInfoTips(self.m_TitleID, {widget = self,})
	elseif self.m_ParSoul then
		--如果是伙伴装备，暂时点击没反应 
		if self.m_Id then
			local oItem = g_ItemCtrl:GetItem(self.m_Id)
			if oItem then
				g_WindowTipCtrl:SetWindowItemTipsPartnerSoulInfo(oItem, {isLink = true, widget = self, side = self.m_Config.side, openView = self.m_Config.openView})
			end			
		else
			local oItem = CItem.NewBySid(self.m_Sid)
			oItem.m_SData["partner_equip_info"] = {}
			g_WindowTipCtrl:SetWindowItemTipsPartnerSoulInfo(oItem, {isLink = true, widget = self, side = self.m_Config.side, openView = self.m_Config.openView})
		end
	elseif self.m_HousePartnerID then
		--如果是宅邸伙伴
		g_WindowTipCtrl:SetWindowHousePartnerInfo(self.m_HousePartnerID, {widget = self, openView = self.m_Config.openView})
	elseif self.m_PartnerID then
		--如果是伙伴
		g_WindowTipCtrl:SetWindowPartnerInfo(self.m_PartnerID, {widget = self, openView = self.m_Config.openView})
	elseif self.m_IsEquip and self.m_Id then
		--如果是装备
		local oItem = g_ItemCtrl:GetItem(self.m_Id)
		if oItem then
			g_WindowTipCtrl:SetWindowItemTipsEquipItemInfo(oItem, {isLink = true, openView = self.m_Config.openView})
		end		
	elseif self.m_ItemType == 9 then    --伙伴皮肤
		g_WindowTipCtrl:SetWindowPartnerSkinInfo(self.m_Sid, {widget = self, openView = self.m_Config.openView})
	
	elseif self.m_HeroSkinType then
		g_WindowTipCtrl:SetWindowRoleSkinInfo(self.m_HeroSkinType, {widget = self, openView = self.m_Config.openView})
		
	elseif self.m_Sid then
		if self.m_Sid == 13281 then
			CItemPartnertSelectPackageView:ShowView(function (oView)
				oView:SetData(self.m_Sid, true, self.m_Id)
			end)
		else
			local config = {
				quality = self.m_Quality,
				buy = self.m_Config.buy,
				buyfun = self.m_Config.buyfun
			}
			g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(self.m_Sid, {widget = self, openView = self.m_Config.openView, behindStrike = self.m_BehindStrike,}, nil, config)
		end
		
	end	
end

function CItemTipsBox.SetSid(self, sSid, iNum, config)
	if string.find(sSid, "value") then
		local sid, value = g_ItemCtrl:SplitSidAndValue(sSid)
		self:SetItemData(sid, value, nil, config)
	elseif string.find(sSid, "partner") then
		local sid, parId = g_ItemCtrl:SplitSidAndValue(sSid)
		self:SetItemData(sid, iNum, parId, config)
	elseif string.find(sSid, "gain_way") then
		local sid, gain_way = g_ItemCtrl:SplitSidAndValue(sSid)
		config["gain_way"] = gain_way
		self:SetItemData(sid, iNum, nil, config)
	else
		self:SetItemData(tonumber(sSid), iNum, nil, config)
	end
end

function CItemTipsBox.SetTitle(self, titleID)
	self:InitStatue()
	self.m_TitleID = titleID
	self.m_IsTitle = true
	self.m_CountLabel:SetActive(false)
	self.m_NameLabel:SetActive(false)
	self.m_IconSprite:SpriteItemShape(data.titledata.DATA[titleID].item_icon)
	self.m_IconSprite:SetSize(100, 100)
	self.m_QualitySprite:SetSize(80, 80)
	self.m_QualitySprite:SetActive(true)
	self.m_QualitySprite:SetSpriteName("pic_tongyong_diwen_zuixin")
end

--sid 道具的id
--count  显示数量
--partid   伙伴头像id，为nil表示是道具
--config  配置参数
function CItemTipsBox.SetItemData(self, sid, count, partid, config)
	self.m_IsTitle = false
	if sid then		
		self:InitStatue()	
		self.m_Config = config or {}
		self.m_Config.isLocal = self.m_Config.isLocal or false  --是否使用导表的quality显示品质(默认使用itemlevel)
		self.m_Config.side = self.m_Config.side or enum.UIAnchor.Side.Right
		self.m_UIType = self.m_Config.uiType or 0
		self.m_RefreshSize = self.m_Config.refreshSize 
		sid = tonumber(sid)
		self.m_Count = count
		local d = data.itemdata.PAR_SOUL[sid]
		--如果是伙伴御灵
		if d then
			self:SetParSoul(sid, d)
			self.m_UIShowType = CItemTipsBox.ShowType.ParSoul
		elseif data.itemdata.PAR_EQUIP[sid] then
			self:SetParEquip(sid, data.itemdata.PAR_EQUIP[sid])
			self.m_UIShowType = CItemTipsBox.ShowType.PartnerEquip
		else
			sid = tonumber(sid)
			local oItem = self.m_Config.oItem or CItem.NewBySid(sid)
			self.m_ItemType = nil
			if oItem then
				self.m_Sid = sid
				self.m_ItemType = oItem:GetValue("type")
				self.m_Quality = oItem:GetValue("itemlevel")
				if partid then
					self:SetPartner(partid)
					self.m_UIShowType = CItemTipsBox.ShowType.Partner

				elseif self.m_ItemType == 9 then
					self:SetPartnerSkin(oItem)
					self.m_UIShowType = CItemTipsBox.ShowType.HeroSkin

				elseif sid == 1027 then
					self:SetHeroSkin(oItem, config["gain_way"])

				elseif data.itemdata.PARTNER_CHIP[sid] then
					self:SetPartnerChip(oItem)
					self.m_UIShowType = CItemTipsBox.ShowType.PartnerChip
				else
					self.m_IconSprite:SpriteItemShape(oItem:GetValue("icon"))
					self.m_UIShowType = CItemTipsBox.ShowType.NormalItem
				end
				
				if self.m_Config.isLocal == true then
					local quality = oItem:GetValue("quality")
					if quality ~= nil then
						self.m_QualitySprite:SetItemQuality(oItem:GetValue("quality"))
						self.m_Quality = oItem:GetValue("quality")
					else
						self.m_QualitySprite:SetItemQuality(oItem:GetValue("itemlevel"))
					end				
				else
					self.m_QualitySprite:SetItemQuality(oItem:GetValue("itemlevel"))
				end			
				self.m_NameLabel:SetText(oItem:GetValue("name"))
				if count and count > 1 then
					self.m_Count = count
					self.m_CountLabel:SetActive(true)
					self.m_CountLabel:SetNumberString(tonumber(count))
				else
					self.m_CountLabel:SetActive(false)
				end
				--是否是人物装备
				if self.m_Config.id then
					local tItem = g_ItemCtrl:GetItem(self.m_Config.id)
					if tItem and (tItem:GetValue("type") == define.Item.ItemType.EquipStone or tItem:GetValue("type") == define.Item.ItemType.Equip ) then
						self.m_IsEquip = true
						self.m_Id = self.m_Config.id
					end
				end
				if self.m_UIType ~= 0 and self.m_UIType ~= 3 then
					self.m_QualitySprite:SetLocalPos(Vector3.zero)
					if partid or self.m_ItemType == 9 or data.itemdata.PARTNER_CHIP[sid] or self.m_HeroSkinType then
						self.m_IconSprite:MakePixelPerfect()
					else
						self.m_IconSprite:SetSize(100, 100)
						if self.m_UIType == 1 then
							self.m_QualitySprite:SetSize(80, 80)
							self.m_QualitySprite:SetSpriteName("pic_tongyong_diwen_zuixin")
						elseif self.m_UIType == 2 then
							self.m_QualitySprite:SetSize(106, 52)
							self.m_QualitySprite:SetSpriteName("pic_tongyong_wupindi")
							self.m_QualitySprite:SetLocalPos(Vector3.New(0, -32, 0))
						end
					end
				end
			else
				printc("不存在此道具 >>>> id: ", sid)
			end
		end
		if self.m_UIType == 3 then
			self.m_QualitySprite:SetSpriteName("")
			if self.m_Effect then
				self.m_Effect:SetActive(true)
			else
				local oEffect = CEffect.New("Effect/UI/ui_eff_1160/Prefabs/ui_eff_1160_shan.prefab", self:GetLayer(), false, callback(self, "SetItemEffect"))
				oEffect:SetParent(self.m_Transform)
				oEffect:SetLocalPos(Vector3.zero)
				self.m_Effect = oEffect
			end
		end
	end

	--通用刷新大小
	self:RefreshSize()
end

function CItemTipsBox.SetItemEffect(self, oEffect)
	local oUIEffect = CUIEffect.New(oEffect.m_GameObject)
	oUIEffect:Above(self.m_IconSprite)
end

function CItemTipsBox.SetHousePartnerItemData(self, house_partner, count, config)
	if house_partner then
		self:InitStatue()	
		self.m_Config = config or {}
		self.m_Config.isLocal = self.m_Config.isLocal or false
		self.m_RefreshSize = self.m_Config.refreshSize 
		self.m_UIShowType = CItemTipsBox.ShowType.Partner
		self.m_HousePartnerID = house_partner
		local oHousePartner = data.housedata.HousePartner[self.m_HousePartnerID]
		local shape = tonumber(oHousePartner["shape"])
		--临时处理，转接伙伴设置(只是为了图标显示)
		--self:SetItemData(1010, count, tonumber(oHousePartner["shape"]), config)
		self.m_BorderSpr = self:NewUI(8, CSprite) --伙伴背景
		self.m_BorderSpr:SetActive(true)
		self.m_QualitySprite:SetActive(false)
		self.m_IconSprite:SpriteAvatar(shape)
		local parData = data.partnerdata.DATA[shape] or {}
		self.m_BorderSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(parData.rare))
		if count and count > 1 then
			self.m_Count = count
			self.m_CountLabel:SetActive(true)
			self.m_CountLabel:SetNumberString(tonumber(count))
		else
			self.m_CountLabel:SetActive(false)
		end
		self:RefreshSize()	
	end
end

function CItemTipsBox.SetParSoul(self, sid, dInfo)
	self.m_Id = self.m_Config.id
	local count = self.m_Count
	self.m_Sid = tonumber(sid)
	local d = dInfo
	self.m_ParSoul = d
	self.m_EquipBg = self:NewUI(5, CSprite)
	self.m_ChipSpr = self:NewUI(9, CSprite)
	
	self.m_QualitySprite:SetActive(false)
	self.m_EquipBg:SetActive(true)
	self.m_EquipBg:SetSize(95, 95)
	self.m_ChipSpr:SetActive(true)
	self.m_ChipSpr:SetSize(30, 30)
	self.m_EquipBg:SetSpriteName("pic_yuling_"..tostring(d.soul_quality))
	self.m_ChipSpr:SetSpriteName("pic_parattr_"..tostring(d.attr_type))
	self.m_ChipSpr:SetLocalPos(Vector3.New(30, -27, 0))
	if count and count > 1 then
		self.m_Count = count
		self.m_CountLabel:SetActive(true)
		self.m_CountLabel:SetNumberString(tonumber(count))
	else
		self.m_CountLabel:SetActive(false)
	end	
	self.m_IconSprite:SpriteItemShape(d.icon)
	if self.m_UIType then
		self.m_IconSprite:MakePixelPerfect()
	end
end

function CItemTipsBox.SetParEquip(self, sid, dInfo)
	self.m_Id = self.m_Config.id
	local count = self.m_Count
	self.m_Sid = tonumber(sid)
	local d = dInfo
	self.m_ParEquip = d
	self.m_StarGird = self:NewUI(6, CGrid)
	self.m_StarSpr = self:NewUI(7, CSprite)
	self.m_StarSpr:SetActive(false)
	self.m_QualitySprite:SetSpriteName("pic_huoban_zhuangbeikuang")
	self.m_QualitySprite:SetSize(112, 112)
	local iStar = d.star
	self.m_StarGird:SetActive(true)
	self.m_StarGird:Clear()
	for i = 1, 6 do
		local spr = self.m_StarSpr:Clone()
		spr:SetActive(true)
		if iStar >= i then
			spr:SetSpriteName("pic_chouka_dianliang")
		else
			spr:SetSpriteName("pic_chouka_weidianliang")
		end
		self.m_StarGird:AddChild(spr)
	end
	self.m_StarGird:Reposition()

	if count and count > 1 then
		self.m_Count = count
		self.m_CountLabel:SetActive(true)
		self.m_CountLabel:SetNumberString(tonumber(count))
	else
		self.m_CountLabel:SetActive(false)
	end
	local iShape = CParEquipItem:GetIcon(dInfo.pos, dInfo.stone_level or 1)
	self.m_IconSprite:SpriteItemShape(iShape)
	self.m_IconSprite:SetSize(95, 95)
end

function CItemTipsBox.SetPartner(self, partid)
	local count = self.m_Count
	self.m_PartnerID = partid
	self.m_BorderSpr = self:NewUI(8, CSprite) --伙伴背景
	self.m_BorderSpr:SetActive(true)
	self.m_QualitySprite:SetActive(false)
	self.m_IconSprite:SpriteAvatar(partid)
	local parData = data.partnerdata.DATA[partid] or {}
	self.m_BorderSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(parData.rare))
	if count and count > 1 then
		self.m_Count = count
		self.m_CountLabel:SetActive(true)
		self.m_CountLabel:SetNumberString(tonumber(count))
	else
		self.m_CountLabel:SetActive(false)
	end
end

function CItemTipsBox.SetPartnerSkin(self, oItem)
	local partid = oItem:GetValue("icon")
	local count = self.m_Count
	self.m_BorderSpr = self:NewUI(8, CSprite) --伙伴背景
	self.m_ChipSpr = self:NewUI(9, CSprite) --伙伴碎片
	self.m_BorderSpr:SetActive(true)
	self.m_QualitySprite:SetActive(false)
	self.m_ChipSpr:SetActive(false)
	self.m_IconSprite:SpriteAvatar(oItem:GetValue("icon"))
	self.m_IconSprite:MakePixelPerfect()
	local parData = data.partnerdata.DATA[oItem:GetValue("partner_type")] or {}
	self.m_BorderSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(parData.rare))
	if count and count > 1 then
		self.m_Count = count
		self.m_CountLabel:SetActive(true)
		self.m_CountLabel:SetNumberString(tonumber(count))
	else
		self.m_CountLabel:SetActive(false)
	end
end

function CItemTipsBox.SetHeroSkin(self)
	local count = self.m_Count
	self.m_BorderSpr = self:NewUI(8, CSprite) --伙伴背景
	self.m_ChipSpr = self:NewUI(9, CSprite) --伙伴碎片
	self.m_BorderSpr:SetActive(true)
	self.m_QualitySprite:SetActive(false)
	self.m_ChipSpr:SetActive(false)
	
	local target = nil
	for k,v in pairs(data.roleskindata.DATA) do
		if v.school == g_AttrCtrl.school and v.sex == g_AttrCtrl.sex and v.gain_way == self.m_Config["gain_way"] then
			target = v
		end
	end
	local shape = g_AttrCtrl.model_info.shape
	if target then 
		shape = target.shape
	end
	self.m_HeroSkinType = shape
	self.m_IconSprite:SpriteAvatar(shape)
	self.m_IconSprite:MakePixelPerfect()
	self.m_BorderSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(4))
	--self.m_ChipSpr:SetSpriteName("pic_pifu_quan")
	if count and count > 1 then
		self.m_Count = count
		self.m_CountLabel:SetActive(true)
		self.m_CountLabel:SetNumberString(tonumber(count))
	else
		self.m_CountLabel:SetActive(false)
	end
end

function CItemTipsBox.SetPartnerChip(self, oItem)
	self.m_BorderSpr = self:NewUI(8, CSprite) --伙伴背景
	self.m_ChipSpr = self:NewUI(9, CSprite) --伙伴碎片
	self.m_BorderSpr:SetActive(true)
	self.m_ChipSpr:SetActive(true)
	self.m_QualitySprite:SetActive(false)
	self.m_IconSprite:SpriteAvatar(oItem:GetValue("icon"))
	if self.m_UIType ~= 0 and self.m_UIType ~= 3 then
		self.m_IconSprite:MakePixelPerfect()
	end
	local rare = oItem:GetValue("rare")
	self.m_BorderSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(rare))
	local w, h = self.m_IconSprite:GetSize()
	self.m_ChipSpr:SetSpriteName(g_PartnerCtrl:GetChipMarkSpriteName(rare))
	self.m_ChipSpr:SetSize(22, 22)
	self.m_ChipSpr:SetLocalPos(Vector3.New(-w/2+11, h/2-11, 0))
	if self.m_UIType == 1 then
		self.m_BorderSpr:SetSize(80, 80)
	end
end

--重置格子的状态
function CItemTipsBox.InitStatue(self)
	if self.m_StarGird then
		self.m_StarGird:SetActive(false)
		self.m_StarGird:Clear()
	end
	if self.m_QualitySprite then
		self.m_QualitySprite:SetActive(true)
	end

	if self.m_EquipBg then
		self.m_EquipBg:SetActive(false)
	end

	if self.m_BorderSpr then
		self.m_BorderSpr:SetActive(false)
	end

	if self.m_ChipSpr then
		self.m_ChipSpr:SetActive(false)
	end	
	self.m_IsTitle = false
	self.m_TitleID = nil
	self.m_Id = nil
	self.m_Sid = nil
	self.m_Count = nil
	self.m_Quality = 0
	self.m_PartnerEquip = nil
	self.m_ParSoul = nil
	self.m_PartnerID = nil
	self.m_HeroSkinType = nil
	self.m_Config = nil	
	self.m_HousePartnerID = nil		
	self.m_IsEquip = false
	if self.m_Effect then
		self.m_Effect:SetActive(false)
	end
end

function CItemTipsBox.RefreshSize(self)
	if not self.m_RefreshSize or self.m_UIShowType == CItemTipsBox.ShowType.None then
		return
	end
	local scale = self.m_RefreshSize / 100
	local function setSize(obj, w, h)
		if obj then
			obj:SetSize(w, h)
		end
	end
	
	if self.m_UIShowType == CItemTipsBox.ShowType.ParSoul then
		setSize(self.m_IconSprite , 100 * scale, 100 * scale)
		setSize(self.m_EquipBg, 100 * scale, 100 * scale)

	elseif self.m_UIShowType == CItemTipsBox.ShowType.Partner or 
		self.m_UIShowType == CItemTipsBox.ShowType.PartnerChip  then
		setSize(self.m_IconSprite, 80 * scale, 80 * scale)
		setSize(self.m_BorderSpr, 95 * scale, 95 * scale)

	elseif self.m_UIShowType == CItemTipsBox.ShowType.NormalItem then
		setSize(self.m_IconSprite , 100 * scale, 100 * scale)
	end
end

return CItemTipsBox