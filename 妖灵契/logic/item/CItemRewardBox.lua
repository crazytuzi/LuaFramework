--兼用多种奖励道具
local CItemRewardBox = class("CItemRewardBox", CBox)

CItemRewardBox.TYPE = {
	Item = 1,
	Partner = 2,
	PartnerEquip = 3,
	PartnerChip = 4,
	HeroEquip = 5,
	HousePartner = 6,
	PartnerSkin = 7,
	RoleSkin = 8,
	Title = 9,
}

--[[
dData = {
	type = nil,
	id = nil
	sid = nil,
	parId = nil,
	count = nil,
	houseparId = houseparId,
	roleSkin = nil,
	titleID = nil,
	itemdata_quality = nil, --quality只对应itemdata
}
config = {
	side = enum.UIAnchor.Side.Center, --位置默认中间
	isLocal = false, --是否使用导表的quality显示品质(默认使用itemlevel)
	buyfun = nil, --道具提示框是否需要显示购买按钮
	virtual = nil, --虚拟道具id
}
]]

function CItemRewardBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Container = self:NewUI(1, CObject, false)
	self.m_ItemBox = self:NewUI(2, CBox, false)
	self.m_PartnerBox = self:NewUI(3, CBox, false)
	self.m_PartnerEquipBox = self:NewUI(4, CBox, false)
	self.m_HousePartnerBox = self:NewUI(5, CBox, false)

	self:Clear()
end

function CItemRewardBox.UseBoxByKey(self, key)
	local oBox
	if key == "item" then
		oBox = self.m_ItemBox
		if not oBox.m_Init then
			oBox.m_IconSprite = oBox:NewUI(1, CSprite)
			oBox.m_CountLabel = oBox:NewUI(2, CLabel)
			oBox.m_QualitySprite = oBox:NewUI(3, CSprite)
			oBox.m_Init = true
		end
	elseif key == "partner" then
		oBox = self.m_PartnerBox
		if not oBox.m_Init then
			oBox.m_IconSprite = oBox:NewUI(1, CSprite)
			oBox.m_CountLabel = oBox:NewUI(2, CLabel)
			oBox.m_BorderSpr = oBox:NewUI(3, CSprite) --伙伴背景
			oBox.m_ChipSpr = oBox:NewUI(4, CSprite) --伙伴碎片
			oBox.m_ChipSpr:SetActive(false)
			oBox.m_Init = true
		end	
	elseif key == "partnerequip" then
		oBox = self.m_PartnerEquipBox
		if not oBox.m_Init then
			oBox.m_IconSprite = oBox:NewUI(1, CSprite)
			oBox.m_CountLabel = oBox:NewUI(2, CLabel)
			oBox.m_PEBg = oBox:NewUI(3, CSprite)
			oBox.m_StarGird = oBox:NewUI(4, CGrid)
			oBox.m_StarSpr = oBox:NewUI(5, CSprite)
			oBox.m_StarSpr:SetActive(false)
			oBox.m_Init = true
		end	
	elseif key == "housepartner" then
		oBox = self.m_HousePartnerBox
		if not oBox.m_Init then
			oBox.m_IconSprite = oBox:NewUI(1, CSprite)
			oBox.m_BorderSpr = oBox:NewUI(3, CSprite)
			oBox.m_Init = true
		end	
	end
	return oBox
end

function CItemRewardBox.SetBehindStrike(self, bValue)
	self.m_BehindStrike = bValue
end

function CItemRewardBox.Clear(self)
	self.m_Data = nil
	self.m_args = nil
	self.m_Name = nil
	self.m_BehindStrike = false
	if self.m_ItemBox then
		self.m_ItemBox:SetActive(false)
	end
	if self.m_PartnerBox then
		self.m_PartnerBox:SetActive(false)
	end
	if self.m_PartnerEquipBox then
		self.m_PartnerEquipBox:SetActive(false)
	end
	if self.m_HousePartnerBox then
		self.m_HousePartnerBox:SetActive(false)
	end
end

function CItemRewardBox.GetCurShowBox(self)
	local dData = self.m_Data
	local oBox
	if dData.type == CItemRewardBox.TYPE.Item then
		oBox = self.m_ItemBox
	elseif dData.type == CItemRewardBox.TYPE.Partner then
		oBox = self.m_PartnerBox
	elseif dData.type == CItemRewardBox.TYPE.PartnerEquip then
		oBox = self.m_PartnerEquipBox
	elseif dData.type == CItemRewardBox.TYPE.PartnerChip then
		oBox = self.m_PartnerBox
	elseif dData.type == CItemRewardBox.TYPE.HeroEquip then
		oBox = self.m_ItemBox
	elseif dData.type == CItemRewardBox.TYPE.HousePartner then
		oBox = self.m_HousePartnerBox
	end
	return oBox
end

function CItemRewardBox.GetItemDataQuality(self)
	return self.m_Data and self.m_Data.itemdata_quality or 0
end

function CItemRewardBox.GetName(self)
	return self.m_Name or ""
end

function CItemRewardBox.SetItemBySid(self, sid, count, config)
	if not sid then
		return
	end
	self:Clear()
	sid = tostring(sid) --方便处理
	config = config or {}
	self.m_Config = {}
	self.m_Config.id = config.id
	self.m_Config.side = config.side or enum.UIAnchor.Side.Center
	local dData
	if string.find(sid, "value") then --虚拟道具金币水晶彩晶等。
		local sid, value = g_ItemCtrl:SplitSidAndValue(sid)
		dData = {
			type = CItemRewardBox.TYPE.Item,
			sid = sid,
			count = value,
			itemdata_quality = data.itemdata.VIRTUAL[sid].quality,
		}
	elseif string.find(sid, "house_partner") or config.virtual == 1025 then --宅邸伙伴
		local sid, houseparId = g_ItemCtrl:SplitSidToHousePartner(sid)
		dData = {
			type = CItemRewardBox.TYPE.HousePartner,
			houseparId = houseparId,
			itemdata_quality = data.itemdata.VIRTUAL[1025].quality,
		}
	elseif string.find(sid, "partner") or config.virtual == 1010 then --伙伴
		local sid, parId = g_ItemCtrl:SplitSidToPartner(sid)
		dData = {
			type = CItemRewardBox.TYPE.Partner,
			parId = parId,
			count = count,
			itemdata_quality = data.itemdata.VIRTUAL[1010].quality,
		}
	elseif string.find(sid, "shape") or config.virtual == 1027 then --主角皮肤
		local sid, roleSkin = g_ItemCtrl:SplitSidToRoleSkin(sid)
		dData = {
			type = CItemRewardBox.TYPE.RoleSkin,
			roleSkin = roleSkin,
			count = count,
			itemdata_quality = data.itemdata.VIRTUAL[1027].quality,
		}		
	else
		sid = tonumber(sid)
		if data.itemdata.PARTNER_CHIP[sid] or config.virtual == 10018 then --伙伴碎片
			dData = {
				type = CItemRewardBox.TYPE.PartnerChip,
				sid = sid,
				count = count,
				itemdata_quality = data.itemdata.PARTNER_CHIP[sid].quality,
			}
		elseif data.itemdata.PAR_EQUIP[sid] or config.virtual == 1016 then --伙伴装备
			dData = {
				type = CItemRewardBox.TYPE.PartnerEquip,
				id = self.m_Config.id,
				sid = sid,
				count = count,
				itemdata_quality = data.itemdata.PAR_EQUIP[sid].quality,
			}
		elseif data.itemdata.EQUIPSTONE[sid] or config.virtual == 1012 then --人物装备
			dData = {
				type = CItemRewardBox.TYPE.HeroEquip,
				id = self.m_Config.id,
				sid = sid,
				count = count,
				itemdata_quality = data.itemdata.EQUIPSTONE[sid].quality,
			}
		elseif data.itemdata.PARTNER_SKIN[sid] then --伙伴皮肤
			dData = {
				type = CItemRewardBox.TYPE.PartnerSkin,
				id = self.m_Config.id,
				sid = sid,
				count = count,	
				itemdata_quality = data.itemdata.PARTNER_SKIN[sid].quality,	
			}
		else	
			dData = {
				type = CItemRewardBox.TYPE.Item,
				id = self.m_Config.id,
				sid = sid,
				count = count,
			}
			local oItem = CItem.NewBySid(sid)
			dData.itemdata_quality = oItem:GetValue("quality")
		end
	end
	if dData then
		self:SetBoxData(dData)
	end
end

--(服务器唯一id)
function CItemRewardBox.SetItemById(self, id, count, config)
	local oItem = g_ItemCtrl:GetBagItemById(id)
	local sid = oItem:GetValue("sid")
	local count = count
	config = config or {}
	config.id = id
	self:SetItemBySid(sid, count, config)
end

function CItemRewardBox.SetTitleByID(self, titleID)
	self:Clear()
	local dData = {
			type = CItemRewardBox.TYPE.Title,
			titleID = titleID,
		}
	self:SetBoxData(dData)
end

function CItemRewardBox.SetBoxData(self, dData)
	self.m_Data = dData
	if dData.type == CItemRewardBox.TYPE.Item then
		self:ShowItem()
	elseif dData.type == CItemRewardBox.TYPE.Partner then
		self:ShowPartner()
	elseif dData.type == CItemRewardBox.TYPE.PartnerEquip then
		self:ShowPartnerEquip()
	elseif dData.type == CItemRewardBox.TYPE.PartnerChip then
		self:ShowPartnerChip()
	elseif dData.type == CItemRewardBox.TYPE.HeroEquip then
		self:ShowItem()
	elseif dData.type == CItemRewardBox.TYPE.HousePartner then
		self:ShowHousePartner()
	elseif dData.type == CItemRewardBox.TYPE.PartnerSkin then
		self:ShowPartnerSkin()
	elseif dData.type == CItemRewardBox.TYPE.RoleSkin then
		self:ShowRoleSkin()
	elseif dData.type == CItemRewardBox.TYPE.Title then
		self:ShowTitle()
	end
end

function CItemRewardBox.ShowItem(self)
	local dData = self.m_Data
	local oBox = self:UseBoxByKey("item")
	oBox:SetActive(true)

	local oItem = CItem.NewBySid(dData.sid)
	self.m_Name = oItem:GetValue("name")
	--icon
	oBox.m_IconSprite:SpriteItemShape(oItem:GetValue("icon"))
	--count
	local count = dData.count
	if count and count > 1 then
		oBox.m_CountLabel:SetActive(true)
		oBox.m_CountLabel:SetNumberString(tonumber(count))
	else
		oBox.m_CountLabel:SetActive(false)
	end
	--quality
	local isLocal = self.m_Config.isLocal
	if isLocal then
		local quality = oItem:GetValue("quality")
		if quality ~= nil then
			oBox.m_QualitySprite:SetItemQuality(quality)
		else
			oBox.m_QualitySprite:SetItemQuality(oItem:GetValue("itemlevel"))
		end				
	else
		oBox.m_QualitySprite:SetItemQuality(oItem:GetValue("itemlevel"))
	end
	self:AddUIEvent("click", callback(self, "OnClickTipsBox"))
end

function CItemRewardBox.ShowPartner(self)
	local dData = self.m_Data
	local oBox = self:UseBoxByKey("partner")
	oBox:SetActive(true)

	local parId = dData.parId
	local parData = data.partnerdata.DATA[parId]
	self.m_Name = parData.name
	oBox.m_IconSprite:SpriteAvatar(parData.icon)
	oBox.m_BorderSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(parData.rare))
	oBox.m_ChipSpr:SetActive(false)
	local count = dData.count
	if count and count > 1 then
		oBox.m_CountLabel:SetActive(true)
		oBox.m_CountLabel:SetNumberString(tonumber(count))
	else
		oBox.m_CountLabel:SetActive(false)
	end
	self:AddUIEvent("click", callback(self, "OnClickTipsBox"))
end

function CItemRewardBox.ShowPartnerChip(self)
	local dData = self.m_Data
	local oBox = self:UseBoxByKey("partner")
	oBox:SetActive(true)

	local oItem = CItem.NewBySid(dData.sid)
	self.m_Name = oItem:GetValue("name")
	oBox.m_IconSprite:SpriteAvatar(oItem:GetValue("icon"))
	local rare = oItem:GetValue("rare")
	oBox.m_BorderSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(rare))
	oBox.m_ChipSpr:SetActive(true)
	oBox.m_ChipSpr:SetSpriteName(g_PartnerCtrl:GetChipMarkSpriteName(rare))	
	local count = dData.count
	if count and count > 1 then
		oBox.m_CountLabel:SetActive(true)
		oBox.m_CountLabel:SetNumberString(tonumber(count))
	else
		oBox.m_CountLabel:SetActive(false)
	end
	self:AddUIEvent("click", callback(self, "OnClickTipsBox"))
end

function CItemRewardBox.ShowPartnerEquip(self)
	local dData = self.m_Data
	local oBox = self:UseBoxByKey("partnerequip")
	oBox:SetActive(true)

	local dPE = data.itemdata.PAR_EQUIP[dData.sid]
	self.m_Name = dPE.name
	local star = dPE.equip_star
	local iRare = 1
	if star > 5 then
		iRare = 4
	elseif star > 4 then
		iRare = 3
	elseif star > 2 then
		iRare = 2
	end
	oBox.m_PEBg:SetSpriteName("pic_fuwen_xj" .. tonumber(iRare))
	local pos2angle = {90, 180, -90, 0}
	local v = Quaternion.Euler(0, 0, pos2angle[dPE.pos] or 0)
	oBox.m_PEBg:SetLocalRotation(v)
	oBox.m_StarGird:Clear()
	if dPE.equip_star > 0 then
		oBox.m_StarGird:SetActive(true)
		for i = 1, dPE.equip_star do
			local oSpr = oBox.m_StarSpr:Clone()
			oSpr:SetActive(true)
			oBox.m_StarGird:AddChild(oSpr)
		end
		oBox.m_StarGird:Reposition()
	end
	local count = dData.count
	if count and count > 1 then
		oBox.m_Count = count
		oBox.m_CountLabel:SetActive(true)
		oBox.m_CountLabel:SetNumberString(tonumber(count))
	else
		oBox.m_CountLabel:SetActive(false)
	end	
	oBox.m_IconSprite:SpriteItemShape(dPE.icon)
	self:AddUIEvent("click", callback(self, "OnClickTipsBox"))
end

function CItemRewardBox.ShowHousePartner(self)
	local dData = self.m_Data
	local oBox = self:UseBoxByKey("housepartner")
	oBox:SetActive(true)
	
	local oHousePartner = data.housedata.HousePartner[dData.houseparId]
	local shape = tonumber(oHousePartner["shape"])
	local parData = data.partnerdata.DATA[shape] or {}
	self.m_Name = parData.name
	oBox.m_IconSprite:SpriteHouseSmallAvatar(shape)
	oBox.m_BorderSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(parData.rare))
	self:AddUIEvent("click", callback(self, "OnClickTipsBox"))
end

function CItemRewardBox.ShowPartnerSkin(self)
	local dData = self.m_Data
	local oBox = self:UseBoxByKey("partner")
	oBox:SetActive(true)

	local oItem = CItem.NewBySid(dData.sid)
	self.m_Name = oItem:GetValue("name")
	oBox.m_IconSprite:SpriteAvatar(oItem:GetValue("icon"))
	local rare = oItem:GetValue("rare")
	oBox.m_BorderSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(rare))
	oBox.m_ChipSpr:SetSpriteName("pic_pifu_quan")
	local count = dData.count
	if count and count > 1 then
		oBox.m_CountLabel:SetActive(true)
		oBox.m_CountLabel:SetNumberString(tonumber(count))
	else
		oBox.m_CountLabel:SetActive(false)
	end
	self:AddUIEvent("click", callback(self, "OnClickTipsBox"))
end

function CItemRewardBox.ShowRoleSkin(self)
	local dData = self.m_Data
	local oBox = self:UseBoxByKey("partner")
	oBox:SetActive(true)

	local dRoleSkin = data.roleskindata.DATA[dData.roleSkin]
	self.m_Name = dRoleSkin.name
	oBox.m_IconSprite:SpriteAvatar(dRoleSkin.shape)
	oBox.m_BorderSpr:SetSpriteName("bg_haoyoukuang")
	oBox.m_ChipSpr:SetSpriteName("pic_pifu_quan")
	local count = dData.count
	if count and count > 1 then
		oBox.m_CountLabel:SetActive(true)
		oBox.m_CountLabel:SetNumberString(tonumber(count))
	else
		oBox.m_CountLabel:SetActive(false)
	end
	self:AddUIEvent("click", callback(self, "OnClickTipsBox"))
end

function CItemRewardBox.ShowTitle(self, config)
	config = config or {}
	self.m_Config = {}
	self.m_Config.id = config.id
	self.m_Config.side = config.side or enum.UIAnchor.Side.Center
	local dData = self.m_Data
	local oBox = self:UseBoxByKey("item")
	oBox:SetActive(true)
	oBox:SetActive(true)
	oBox.m_CountLabel:SetActive(false)
	oBox.m_IconSprite:SpriteItemShape(data.titledata.DATA[dData.titleID].item_icon)
	self.m_Name = data.titledata.DATA[dData.titleID].name
	oBox.m_QualitySprite:SetActive(true)
	oBox.m_QualitySprite:SetSpriteName("pic_tongyong_diwen_zuixin")
	self:AddUIEvent("click", callback(self, "OnClickTipsBox"))
end

--click

function CItemRewardBox.OnClickTipsBox(self, obj)
	local dData = self.m_Data
	local config = self.m_Config
	local openView = self.m_Config.openView
	local side = self.m_Config.side

	if dData.type == CItemRewardBox.TYPE.Item then
		g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(dData.sid, {widget = self, openView = openView, behindStrike = self.m_BehindStrike,}, nil, config)
	elseif dData.type == CItemRewardBox.TYPE.Partner then
		g_WindowTipCtrl:SetWindowPartnerInfo(dData.parId, {widget = self, openView = openView})
	elseif dData.type == CItemRewardBox.TYPE.PartnerEquip then
		if dData.id then
			local oItem = g_ItemCtrl:GetItem(dData.id)
			if oItem then
				g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(oItem, {isLink = true, widget = self, side = side, openView = self.m_Config.openView})
			end
		else
			local oItem = CItem.NewBySid(dData.sid)
			oItem.m_SData["partner_equip_info"] = {}
			g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(oItem, {isLink = true, widget = self, side = side, openView = self.m_Config.openView})
		end
	elseif dData.type == CItemRewardBox.TYPE.PartnerChip then
		g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(dData.sid, {widget = self, openView = openView, behindStrike = self.m_BehindStrike,}, nil, config)
	elseif dData.type == CItemRewardBox.TYPE.HeroEquip then
		if dData.id then
			local oItem = g_ItemCtrl:GetItem(dData.id)
			if oItem then
				g_WindowTipCtrl:SetWindowItemTipsEquipItemInfo(oItem, {isLink = true, openView})
			end	
		else
			g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(dData.sid, {widget = self, openView = openView, behindStrike = self.m_BehindStrike,}, nil, config)
		end
	elseif dData.type == CItemRewardBox.TYPE.HousePartner then
		g_WindowTipCtrl:SetWindowHousePartnerInfo(dData.houseparId, {widget = self, side = side})		
	elseif dData.type == CItemRewardBox.TYPE.PartnerSkin then
		g_WindowTipCtrl:SetWindowPartnerSkinInfo(dData.sid, {widget = self, side = side, openView = openView})		
	elseif dData.type == CItemRewardBox.TYPE.RoleSkin then
		g_WindowTipCtrl:SetWindowRoleSkinInfo(dData.roleSkin, {widget = self, side = side, openView = openView})				
	elseif dData.type == CItemRewardBox.TYPE.Title then
		g_WindowTipCtrl:SetTitleSimpleInfoTips(dData.titleID, {widget = self, side = side, openView = openView})
	end
end

return CItemRewardBox