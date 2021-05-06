local CSprite = class("CSprite", CWidget)

function CSprite.ctor(self, obj)
	CWidget.ctor(self, obj)
	self.m_UISpriteAnimation = nil
	self.m_SpriteName = self.m_UIWidget.spriteName

	self.m_LastLoatAtlasPath = ""
	self.m_LastLoadSprName = ""
end

function CSprite.SetSpriteName(self, sName)
	sName = sName or ""
	if self.m_SpriteName ~= sName then
		self.m_SpriteName = sName
		self.m_UIWidget.spriteName = sName
	end
end

function CSprite.GetSpriteName(self)
	return self.m_SpriteName
end

function CSprite.SetFillAmount(self, iFillAmount)
	self.m_UIWidget.fillAmount = iFillAmount 
end

function CSprite.SetAtlas(self, oAtlas)
	self.m_UIWidget.atlas = oAtlas
end

function CSprite.GetAtlas(self)
	return self.m_UIWidget.atlas
end

function CSprite.GetAltasName(self)
	if self.m_UIWidget.atlas then
		if self.m_UIWidget.atlas.replacement then
			return self.m_UIWidget.atlas.replacement.name
		else
			return self.m_UIWidget.atlas.name
		end
	end
end

function CSprite.SetFlip(self, iFlip)
	self.m_UIWidget.flip = iFlip
end

function CSprite.SetGradientColor(self, color)
	if not self.m_UISprite then
		self.m_UISprite = self:GetMissingComponent(classtype.UISprite)
	end
	self.m_UISprite.gradientTop = color
	self.m_UISprite.gradientBottom = color
end

function CSprite.SpriteHouseAvatar(self, iShape)
	self:DynamicSprite("HouseAvatar", iShape)
end

function CSprite.SpriteHouseBuff(self, iShape)
	self:DynamicSprite("HouseBuff", iShape)
end

function CSprite.SpriteHouseSmallAvatar(self, iShape)
	self:DynamicSprite("HouseSmallAvatar", iShape)
end

function CSprite.SpriteAvatar(self, iShape)
	self:DynamicSprite("Avatar", iShape)
end

function CSprite.SpriteAvatarCircle(self, iShape)
	self:DynamicSprite("AvatarCircle", iShape)
end

function CSprite.SpriteSkinText(self, iTextIcon)
	self:DynamicSprite("SkinText", iTextIcon)
end

function CSprite.SpriteWarAvatar(self, iShape)
	self:DynamicSprite("WarAvatar", iShape)
end

function CSprite.SpriteAvatarBig(self, iShape)
	self:DynamicSprite("AvatarBig", iShape)
end

function CSprite.SpriteBossAvatar(self, iShape)
	self:DynamicSprite("BossAvatar", iShape)
end

function CSprite.SpriteMainMenuAvatarBig(self, iShape)
	local t = {110, 113, 120, 123, 130, 133, 140, 143, 150, 153, 160, 163}
	if table.index(t, iShape) ~= nil then
		self:DynamicSprite("AvatarBig", string.format("main_menu_%d", iShape))
	else
		self:SpriteAvatarBig(iShape)
	end	
end

function CSprite.SpriteMainMenuTeamAvatarBig(self, iShape)
	local t = {110, 113, 120, 123, 130, 133, 140, 143, 150, 153, 160, 163}
	if table.index(t, iShape) ~= nil then
		self:DynamicSprite("AvatarBig", string.format("main_menu_team_%d", iShape))
	else
		self:SpriteAvatarBig(iShape)
	end	
end

function CSprite.SpriteItemShape(self, iItemShape)
	self:DynamicSprite("Item", iItemShape)
end

function CSprite.SpriteTitle(self, iTitle)
	self:DynamicSprite("Title", iTitle)
end

function CSprite.SpriteSchool(self, iShool)
	self:DynamicSprite("School", iShool)
end

function CSprite.SpriteSchoolBig(self, iShool)
	self:DynamicSprite("School", "big_"..tostring(iShool))
end

function CSprite.SpriteSkill(self, iSkill)
	self:DynamicSprite("Skill", iSkill)
end

function CSprite.SpriteMagic(self, iMagic)
	local dMagic = data.magicdata.DATA[iMagic]
	if dMagic and dMagic.skill_icon then
		self:DynamicSprite("Skill", dMagic.skill_icon)
	else
		self:DynamicSprite("Magic", iMagic)
	end
end

function CSprite.SpriteBuff(self, iBuff)
	local dData = data.buffdata.DATA[iBuff]
	if dData and dData.icon then
		self:DynamicSprite("Buff", dData.icon)
	else
		self:DynamicSprite("Buff", iBuff)
	end
end

function CSprite.DynamicSprite(self, sType, iKey)
	local dAtlasMap = data.dynamicatlasdata.DATA[sType]
	if not dAtlasMap then
		print("DynamicSprite dAtlasMap", sType, iKey)
		self:DefalutSprite()
		return
	end
	local dSprInfo = dAtlasMap[iKey]
	if not dSprInfo then
		print("DynamicSprite dSprInfo", sType, iKey)
		self:DefalutSprite()
		return
	end
	local curName = self:GetAltasName()
	self.m_LastLoatAtlasPath = string.format('Atlas/DynamicAtlas/%s/%s.prefab', dSprInfo.atlas, dSprInfo.atlas)
	self.m_LastLoadSprName = dSprInfo.sprite
	
	if curName and curName == dSprInfo.atlas then
		self:SetSpriteName(dSprInfo.sprite)
	else
		g_ResCtrl:Load(self.m_LastLoatAtlasPath, callback(self, "AtlasLoadDone", dSprInfo.sprite, nil))
	end
end

function CSprite.DefalutSprite(self)
	self:SetStaticSprite("Common", "pic_missing")
end

function CSprite.SetStaticSprite(self, sAtlas, sName, cb)
	local sAtlas = string.format("%sAtlas", sAtlas)
	local curName = self:GetAltasName()
	self.m_LastLoatAtlasPath = string.format("Atlas/Ref%s.prefab", sAtlas)
	self.m_LastLoadSprName = sName
	if curName and curName == sAtlas then
		self:SetSpriteName(sName)
	else
		g_ResCtrl:Load(self.m_LastLoatAtlasPath, callback(self, "AtlasLoadDone", sName, cb))
	end
end

function CSprite.AtlasLoadDone(self, sName, cb, asset, path)
	if asset then
		local oAtlas = asset:GetComponent(classtype.UIAtlas)
		if self.m_LastLoatAtlasPath == path then
			self:SetAtlas(oAtlas)
		end
		if self.m_LastLoadSprName == sName then
			self:SetSpriteName(sName)
		end
		if cb then
			cb(oAtlas)
		end
	end
end

function CSprite.InitSpriteAnimation(self)
	if not self.m_UISpriteAnimation then
		self.m_UISpriteAnimation = self:GetMissingComponent(classtype.UISpriteAnimation)
	end
end

function CSprite.SetNamePrefix(self, s)
	self:InitSpriteAnimation()
	self.m_UISpriteAnimation.namePrefix = s
end

function CSprite.GetNamePrefix(self)
	self:InitSpriteAnimation()
	return self.m_UISpriteAnimation.namePrefix
end

function CSprite.SetFramesPerSecond(self, i)
	self:InitSpriteAnimation()
	self.m_UISpriteAnimation.framesPerSecond = i
end

function CSprite.GetFramesPerSecond(self)
	self:InitSpriteAnimation()
	return self.m_UISpriteAnimation.framesPerSecond
end

function CSprite.PauseSpriteAnimation(self)
	self:InitSpriteAnimation()
	self.m_UISpriteAnimation:Pause()
end

function CSprite.StartSpriteAnimation(self)
	self:InitSpriteAnimation()
	self.m_UISpriteAnimation:Play()
end

function CSprite.SetCardBorder(self, iRare)
	local sColor = define.Partner.CardColor[iRare]
	if sColor then
		local sSprName = "pic_kapaibiankuang_"..sColor
		self:SetSpriteName(sSprName)
	else
		print("SetCardBorder err", iRare)
	end
end

function CSprite.SetCardHuaWen(self, iRare)
	local sColor = define.Partner.CardColor[iRare]
	if sColor then
		local sSprName = "pic_kapaihuawen_"..sColor
		self:SetSpriteName(sSprName)
	else
		print("SetCardBorder err", iRare)
	end
end

function CSprite.SetItemQuality(self, iQuality)
	if not iQuality then
		return
	end
	local tName = {
		[0] = "pic_ditu_daoju_dikaung_bai",
		[1] = "pic_ditu_daoju_dikaung_bai",
		[2] = "pic_ditu_daoju_dikaung_lan",
		[3] = "pic_ditu_daoju_dikaung_zi",
		[4] = "pic_ditu_daoju_dikaung_jin",
		[5] = "pic_ditu_daoju_dikaung_lv",
		[6] = "pic_ditu_daoju_dikaung_lv",
	}
	self:SetSpriteName(tName[iQuality])
end

function CSprite.SetItemSecondQuality(self, iQuality)
	if not iQuality then
		return
	end
	local tName = {
		[0] = "pic_bai",
		[1] = "pic_bai",
		[2] = "pic_lan",
		[3] = "pic_zi",
		[4] = "pic_cheng",
		[5] = "pic_lv",
		[6] = "pic_lv",
	}
	self:SetSpriteName(tName[iQuality])
end

function CSprite.SetItemColorQuality(self, iQuality)
	if not iQuality then
		return
	end
	local color = {
		[0] = Color.white,
		[1] = Color.green,
		[2] = Color.blue,
		[3] = Color.yellow,
		[4] = Color.red,
		[5] = Color.yellow,
		[6] = Color.white,
	}
	self:SetColor(color[iQuality])
end

function CSprite.SetBagNameBgQuality(self, iQuality)
	if not iQuality then
		return
	end
	local tName = {
		[0] = "pic_mingzi_di_bai",
		[1] = "pic_mingzi_di_bai",
		[2] = "pic_mingzi_di_lan",
		[3] = "pic_mingzi_di_zi",
		[4] = "pic_mingzi_di_cheng",
		[5] = "pic_mingzi_di_lv",
		[6] = "pic_mingzi_di_lv",
	}
	self:SetSpriteName(tName[iQuality])
end

function CSprite.SetTitleQuality(self, iQuality, idx)
	if not iQuality then
		return
	end
	idx = idx or 1
	local tName = {
		[0] = "bai",
		[1] = "bai",
		[2] = "lan",
		[3] = "zi",
		[4] = "cheng",
		[5] = "lv",
		[6] = "lv",
	}
	self:SetSpriteName(string.format("pic_tips_kuang_%s_%d", tName[iQuality], idx))
end

return CSprite