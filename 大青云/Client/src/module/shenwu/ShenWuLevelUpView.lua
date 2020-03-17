--[[
神武 升阶view
haohu
2015年12月25日16:36:03
]]

_G.UIShenWuLevelUp = {}

UIShenWuLevelUp.objSwf = nil

UIShenWuLevelUp.bShowState = nil
UIShenWuLevelUp.objSwf = nil

function UIShenWuLevelUp:OnLoaded( objSwf )
	self.objSwf = objSwf
	objSwf.btnLevelUp.click = function() self:OnBtnLevelUpClick() end
	objSwf.btnLevelUp.rollOver = function() self:ShowLevelUpAttr(); end
	objSwf.btnLevelUp.rollOut = function() self:UnShowLevelUpAttr(); end
	objSwf.itemConsume.rollOver = function(e) self:OnItemRollOver(e) end
	objSwf.itemConsume.rollOut = function(e) TipsManager:Hide() end
	objSwf.btnMaterial.rollOver = function(e) self:OnItemRollOver(e) end
	objSwf.btnMaterial.rollOut = function(e) TipsManager:Hide() end
	objSwf.txtDamage.autoSize = "left"
	objSwf.btnMaterial.autoSize = true
	objSwf.starIndicator.maxmium = ShenWuConsts:GetMaxStar()
	self:Hide()
end

function UIShenWuLevelUp:OnDelete()
	self.bShowState = nil
	self.objSwf = nil
end

function UIShenWuLevelUp:Show()
	if self.bShowState == true then return end
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf._visible = true
	objSwf.hitTestDisable = false
	self.bShowState = true
	self:UpdateShow()
	self:UnShowLevelUpAttr();
end

function UIShenWuLevelUp:Hide()
	if self.bShowState == false then return end
	local objSwf = self.objSwf
	if not objSwf then return end
	self:CloseLevelUpConfirm()
	objSwf._visible = false
	objSwf.hitTestDisable = true
	self.bShowState = false
end

function UIShenWuLevelUp:OnItemRollOver(e)
	local data = e.target.data
	local id = data and data.id
	if not id then return end
	TipsManager:ShowItemTips( id )
end

function UIShenWuLevelUp:OnBtnLevelUpClick()
	self:LevelUp()
end

UIShenWuLevelUp.levelUpConfirm = nil
UIShenWuLevelUp.levelUpNeedConfirm = true
function UIShenWuLevelUp:LevelUp()
	if ShenWuModel:IsLevelUp() then
		if not ShenWuController:CheckLevelUpCondition() then
			return
		end
		if self.levelUpNeedConfirm then
			self:OpenLevelUpConfirm()
			return
		end
		ShenWuController:ReqShenWuLevelUp()
	elseif ShenWuModel:IsStarUp() then
		ShenWuController:ReqShenWuStarUp()
	end
end

function UIShenWuLevelUp:OpenLevelUpConfirm()
	local content = StrConfig['shenwu25']
	local confirmFunc = function(selected)
		ShenWuController:ReqShenWuLevelUp()
		self:CloseLevelUpConfirm()
		self.levelUpNeedConfirm = not selected
	end
	local cancelFunc = function()
		self:CloseLevelUpConfirm()
	end
	self.levelUpConfirm = UIConfirmWithNoTip:Open( content, confirmFunc, cancelFunc )
end

function UIShenWuLevelUp:CloseLevelUpConfirm()
	if self.levelUpConfirm then
		UIConfirmWithNoTip:Close( self.levelUpConfirm )
		self.levelUpConfirm = nil
	end
end

function UIShenWuLevelUp:UpdateShow(boom)
	if self.bShowState == false then return end
	self:ShowWeapon()
	self:ShowAttr()
	self:ShowLevel()
	self:ShowStar(boom)
	self:ShowRate()
	self:ShowMaterial()
	self:ShowState() -- 满级/非满级
	self:ShowLvlUpState() -- 突破/非突破
end

function UIShenWuLevelUp:ShowWeapon()
	local objSwf = self.objSwf
	if not objSwf then return end
	local vo = EquipUtil:GetEquipUIVO( BagConsts.Equip_WuQi, false )
	if not vo.hasItem then
		ShenWuUtils:GetDataToShenWuUIVO(vo)
	end
	local itemUIData = UIData.encode(vo)
	if not ShenWuModel:IsFull() then
		vo.groupBsUrl = ResUtil:GetShenWuSlotIcon(ShenWuModel:GetLevel() + 1, 0)
		local itemUIData2 = UIData.encode(vo)
	end
end

function UIShenWuLevelUp:ShowAttr()
	local objSwf = self.objSwf
	if not objSwf then return end
	for i = 1, 5 do
		local textField1 = objSwf['txtAttr'..i]
		if textField1 then
			textField1._visible = false
		end
	end
	objSwf.txtDamage._visible = false
	objSwf.mcDamage._visible = false
	--
	local level = ShenWuModel:GetLevel()
	local star = ShenWuModel:IsFull() and 0 or ShenWuModel:GetStar()
	local attrMap1 = ShenWuUtils:GetAttrMap(level, star)
	local nameFormat, value
	for i, att in ipairs( ShenWuConsts.Attrs ) do
		local textField = objSwf['txtAttr'..i]
		if textField then
			local attrType = AttrParseUtil.AttMap[att]
			nameFormat = ShenWuConsts.AttrNames[att]
			value = getAtrrShowVal( attrType, attrMap1[att] )
			textField.htmlText = string.format(nameFormat, value)
			textField._visible = true
		end
	end
	local cfg = ShenWuUtils:GetStarCfg(level, star)
	objSwf.txtDamage.text = cfg and string.format( "+%0.2f%%", cfg.promote * 0.01 ) or "+0.00%"
	objSwf.txtDamage._visible = true
	objSwf.mcDamage._visible = true
end

function UIShenWuLevelUp:ShowLevelUpAttr()
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = ShenWuModel:GetLevel()
	local star = ShenWuModel:IsFull() and 0 or ShenWuModel:GetStar()
	local attrMap1 = ShenWuUtils:GetAttrMap(level, star)
	local attrMap2 = nil;
	local cfg = ShenWuUtils:GetStarCfg(level, star)
	local newCfg = nil;
	if ShenWuModel:IsFull() then
		attrMap2 = ShenWuUtils:GetAttrMap(level+1,0)
		newCfg = ShenWuUtils:GetStarCfg(level + 1, 0)
	else
		attrMap2 = ShenWuUtils:GetAttrMap(level,star+1)
		newCfg = ShenWuUtils:GetStarCfg(level,star+1)
	end
	if not attrMap2 then return; end
	if not newCfg then return; end
	for i, att in ipairs( ShenWuConsts.Attrs ) do
		objSwf["attrArrow"..i]._visible = true;
		local attrType = AttrParseUtil.AttMap[att]
		local value = getAtrrShowVal( attrType, attrMap2[att]-attrMap1[att])
		objSwf['txtAddAttr'..i]._visible = true;
		objSwf['txtAddAttr'..i].htmlText = "+"..value;
	end
	objSwf.arrowDamage._visible = true;
	objSwf.txtAddDamage._visible = true;
	objSwf.txtAddDamage.htmlText = string.format( "+%0.2f%%", (newCfg.promote-cfg.promote) * 0.01 )
end

function UIShenWuLevelUp:UnShowLevelUpAttr()
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=1, 5 do
		objSwf["attrArrow"..i]._visible = false;
		objSwf['txtAddAttr'..i]._visible = false;
	end
	objSwf.arrowDamage._visible = false;
	objSwf.txtAddDamage._visible = false;
end

function UIShenWuLevelUp:ShowSkill()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not ShenWuModel:IsLevelUp() then
		return
	end

	local level = ShenWuModel:GetLevel()
	local skills1 = ShenWuUtils:GetSkill( level )
	local showSkill1 = skills1[1]
	if showSkill1 then
		local skillInfo1 = ShenWuUtils:GetSkillVO(showSkill1)
	end

	if not ShenWuModel:IsFull() then
		local skills2 = ShenWuUtils:GetSkill( level + 1 )
		local showSkill2 = skills2[1]
		if showSkill2 then
			local skillInfo2 = ShenWuUtils:GetSkillVO(showSkill2)
		end
	end
end

function UIShenWuLevelUp:ShowLevel()
	local objSwf = self.objSwf
	if not objSwf then return end
end

UIShenWuLevelUp.lastStar = 0
function UIShenWuLevelUp:ShowStar(boom)
	local objSwf = self.objSwf
	if not objSwf then return end
	local star = ShenWuModel:GetStar()
	objSwf.starIndicator.value = star
	if boom and star > self.lastStar then
		local starEffect = objSwf["starEffect"..star]
		if starEffect then
			starEffect:playEffect(1)
		end
	end
	self.lastStar = star
end

function UIShenWuLevelUp:ShowRate()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.rateLoader._visible = false
	objSwf.rateLoader2._visible = false
	local isLevelUp = ShenWuModel:IsLevelUp()
	local isFull = ShenWuModel:IsFull()
	if not ShenWuModel:IsFull() then
		local rate = ShenWuUtils:GetCurrentRate()
		objSwf.rateLoader.num = string.format( "%dp", rate * 0.01 )
		objSwf.rateLoader2.num = string.format( "%dp", rate * 0.01 )
		objSwf.rateLoader._visible   = not isLevelUp and not isFull
		objSwf.rateLoader2._visible   = isLevelUp
	end
end

function UIShenWuLevelUp:ShowMaterial()
	self:ShowMaterial1()
	self:ShowMaterial2()
end

function UIShenWuLevelUp:ShowMaterial1()
	local objSwf = self.objSwf
	if not objSwf then return end
	if ShenWuModel:IsLevelUp() then return end
	if not ShenWuModel:IsFull() then
		local material = ShenWuUtils:GetCurrentMaterial()
		local vo = material and material[1]
		if vo then
			local slotVO = RewardSlotVO:new()
			local id = vo.id
			slotVO.id = id
			slotVO.count = 0
			objSwf.itemConsume:setData( slotVO:GetUIData() )
			local playerHasNum = BagModel:GetItemNumInBag(id)
			local color = playerHasNum < vo.num and "#FF0000" or "#00FF00"
			objSwf.txtNeed.htmlText = string.format( "<font color='%s'>(%s/%s)</font>", color, playerHasNum, vo.num )
		end
	end
end

function UIShenWuLevelUp:ShowMaterial2()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not ShenWuModel:IsLevelUp() then return end
	if not ShenWuModel:IsFull() then
		local material = ShenWuUtils:GetCurrentMaterial()
		local vo = material and material[1]
		if vo then
			local id = vo.id
			local num = vo.num
			local playerHasNum = BagModel:GetItemNumInBag(id)
			local cfg = t_item[id]
			local name = cfg and cfg.name or "misssing"
			local color = playerHasNum < vo.num and "#FF0000" or "#00FF00"
			objSwf.btnMaterial.data = vo
			objSwf.btnMaterial.htmlLabel = string.format( "<u><font color='%s'>%s×%s</font></u>", color, name, vo.num )
		end
	end
end

-- 是否突破状态
function UIShenWuLevelUp:ShowLvlUpState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local isLevelUp = ShenWuModel:IsLevelUp()
	local isFull = ShenWuModel:IsFull()
	objSwf.btnLevelUp.label       = isLevelUp and StrConfig['shenwu13'] or StrConfig['shenwu1']
	objSwf.btnEff._visible        = isLevelUp
	objSwf.starIndicator._visible = not isLevelUp and not isFull
	objSwf.lblNeed._visible       = not isLevelUp and not isFull
	objSwf.lblNeed2._visible      = isLevelUp
	objSwf.lblRate._visible       = not isLevelUp and not isFull
	objSwf.lblRate2._visible      = isLevelUp
	objSwf.rateLoader._visible   = not isLevelUp and not isFull
	objSwf.rateLoader2._visible   = isLevelUp
	objSwf.imgUpJianTou._visible   = false
	objSwf.itemConsume._visible   = not isLevelUp and not isFull
	objSwf.txtNeed._visible       = not isLevelUp and not isFull
	objSwf.btnMaterial._visible   = isLevelUp
	self:ShowSkill()
end

-- 是否满级状态
function UIShenWuLevelUp:ShowState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local isFull = ShenWuModel:IsFull()
	objSwf.itemConsume._visible = not isFull
	objSwf.txtNeed._visible     = not isFull
	objSwf.lblNeed._visible     = not isFull
	objSwf.lblRate._visible     = not isFull
	objSwf.btnLevelUp._visible  = not isFull
	objSwf.mcFull._visible      = isFull
end

--处理消息
function UIShenWuLevelUp:HandleNotification(name, body)
	if not self.bShowState then return end
	if name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove then
		if body.type == BagConsts.BagType_Role then
			self:UpdateShow()
		end
	elseif name == NotifyConsts.BagItemNumChange then
		self:ShowMaterial()
	elseif name == NotifyConsts.ShenWuLevel then
		self:UpdateShow()
		self:UnShowLevelUpAttr();
	elseif name == NotifyConsts.ShenWuStar then
		self:UpdateShow(true)
		self:ShowLevelUpAttr();
	elseif name == NotifyConsts.ShenWuStone then
		self:ShowRate()
	elseif name == NotifyConsts.ShenWuStarRate then
		self:ShowRate()
	end
end


-- NotifyConsts.BagAdd,
-- NotifyConsts.BagRemove,
-- --
-- NotifyConsts.BagItemNumChange,
-- NotifyConsts.ShenWuLevel,
-- NotifyConsts.ShenWuStar,
-- NotifyConsts.ShenWuStone,
-- NotifyConsts.ShenWuStarRate,