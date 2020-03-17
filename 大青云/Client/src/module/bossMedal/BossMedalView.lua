--[[
boss 勋章 view
haohu
2015-11-19 17:35:00
]]

_G.UIBossMedal = BaseUI:new("UIBossMedal")

UIBossMedal.attrIncrementPolicy = nil
UIBossMedal.P_NextLevel = "nextLevel"
UIBossMedal.P_NextStar  = "nextStar"

function UIBossMedal:Create()
	self:AddSWF( "bossMedal.swf", true, "center" )
end

function UIBossMedal:OnLoaded( objSwf )
	objSwf.btnClose.click      = function() self:OnBtnCloseClick() end
	objSwf.btnLevelUp.click    = function() self:OnBtnLevelUpClick() end
	objSwf.siStar.maximum      = BossMedalConsts.MaxStar
	objSwf.siStar.rollOver     = function() self:OnSiStarRollOver() end
	objSwf.siStar.rollOut      = function() self:OnSiStarRollOut() end
	objSwf.btnConsume.rollOver = function() self:OnBtnConsumeRollOver() end
	objSwf.btnConsume.rollOut  = function() self:OnBtnConsumeRollOut() end

	objSwf.btn_add.rollOver     = function() self:OnBtnLevelUpRollOver() end
	objSwf.btn_autoAdd.rollOver = function() self:OnBtnLevelUpRollOver() end

	objSwf.btn_add.rollOut     = function() self:OnBtnLevelUpRollOut() end
	objSwf.btn_autoAdd.rollOut = function() self:OnBtnLevelUpRollOut() end
	
	objSwf.proLoaderValue.loadComplete = function(e) self:OnNumValueLoadComplete(e); end
	objSwf.proLoaderMax.loadComplete   = function(e) self:OnNumMaxLoadComplete(e); end
	-- objSwf.loader.loaded   = function(e) self:OnNameLoadComplete(e) end
	objSwf.mcBossMedal.hitTestDisable = true

	objSwf.txtCurrentPoints.autoSize = "left"
	self:ShowPrompt()
	
	objSwf.btn_add.click = function () self:OnBtnLevelUpClick() end
	objSwf.btn_autoAdd.click = function () self:OnBtnAutoLevelUpClick() end
end

function UIBossMedal:ReqLevelUp(auto)
	BossMedalController:ReqLevelUp(auto)
end

function UIBossMedal:OnHide()
	BossMedalController:StopAutoLevelUp()
end

function UIBossMedal:UpdateBtnLabel()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.btn_autoAdd.label = BossMedalModel:GetAutoLvUp() and UIStrConfig['bossshuizhang3'] or UIStrConfig['bossshuizhang2']
end

function UIBossMedal:OnNumValueLoadComplete(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.proLoaderValue._x = objSwf.posSign._x - objSwf.proLoaderValue.width
end

function UIBossMedal:OnNumMaxLoadComplete(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.proLoaderMax._x = objSwf.posSign._x + objSwf.posSign._width
end

-- function UIBossMedal:OnNameLoadComplete(e)
-- 	local loader = e.target
-- 	local mc = loader.content
-- 	mc._x = mc._width * -0.5
-- 	mc._y = mc._height * -0.5
-- end

function UIBossMedal:OnShow()
	-- 点数
	self:ShowCurrentPoints()
	-- boss击杀数
	self:ShowBossNum()
	-- 等级
	self:ShowLevel()
	-- 消耗
	self:ShowConsume()
	-- 成长值
	self:ShowGrowValue(true)
	-- 属性
	self:ShowAttr()
	--
	self:UpdateBtnLabel()
	-- 
	self:HideIncrement()
end

function UIBossMedal:IsTween()
	return true
end

function UIBossMedal:GetPanelType()
	return 1
end

function UIBossMedal:IsShowSound()
	return true
end

function UIBossMedal:IsShowLoading()
	return true
end

function UIBossMedal:ShowPrompt()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.pointLabel1.htmlText = StrConfig['bosshuizhang001']
	objSwf.pointLabel2.htmlText = StrConfig['bosshuizhang002']
	objSwf.pointLabel3.htmlText = StrConfig['bosshuizhang003']
	objSwf.pointLabel4.htmlText = StrConfig['bosshuizhang004']
end

function UIBossMedal:ShowCurrentPoints()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.txtCurrentPoints.text = BossMedalModel:GetCurrentPoints()
end

function UIBossMedal:ShowBossNum()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.txtPoints0.htmlText = string.format( StrConfig['bosshuizhang005'], BossMedalModel:GetTotalBossNum() )
	objSwf.txtPoints1.htmlText = string.format( StrConfig['bosshuizhang006'], BossMedalModel:GetBossNum(BossMedalConsts.Type_World) )
	objSwf.txtPoints2.htmlText = string.format( StrConfig['bosshuizhang007'], BossMedalModel:GetBossNum(BossMedalConsts.Type_Person) )
	objSwf.txtPoints3.htmlText = string.format( StrConfig['bosshuizhang008'], BossMedalModel:GetBossNum(BossMedalConsts.Type_Digong) )
	objSwf.txtPoints4.htmlText = string.format( StrConfig['bosshuizhang009'], BossMedalModel:GetBossNum(BossMedalConsts.Type_Yewai) )
end

function UIBossMedal:ShowLevel()
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = BossMedalModel:GetLevel()
	local showLevel = math.max( level, 1 )
	objSwf.mcBossMedal:gotoAndStop(showLevel)
	objSwf.mcName:gotoAndStop(showLevel)
	objSwf.txtLevel.text = string.format("LV.%s", showLevel)
	local isFull = BossMedalModel:IsFull()
	local isActive = BossMedalModel:IsActive()
	objSwf.mcNoActive._visible     = not isFull and not isActive
	objSwf.siGrowValue._visible    = not isFull and isActive
	objSwf.proLoaderValue._visible = not isFull and isActive
	objSwf.proLoaderMax._visible   = not isFull and isActive
	objSwf.posSign._visible        = not isFull and isActive
	objSwf.siStar._visible         = not isFull and isActive
	objSwf.titleShengji._visible   = not isFull and isActive
	objSwf.btnConsume._visible     = not isFull
	objSwf.btnLevelUp._visible     = not isActive
	objSwf.mcFullLevel._visible    = isFull
	objSwf.btnLevelUp.label = isActive and StrConfig['bosshuizhang010'] or StrConfig['bosshuizhang011']
	
	objSwf.btn_add.visible = not isFull and isActive
	objSwf.btn_autoAdd.visible = not isFull and isActive
end

function UIBossMedal:ShowConsume()
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = BossMedalModel:GetLevel()
	local isActive = BossMedalModel:IsActive()
	local txtFormat = StrConfig['bosshuizhang012']
	local txt = isActive and StrConfig['bosshuizhang013'] or StrConfig['bosshuizhang014']
	local cfg = t_bosshuizhang[level]
	local levelUpConsume = cfg and cfg.consum
	local consume = isActive and levelUpConsume or BossMedalConsts:GetActiveConsume()
	local currentPoints = BossMedalModel:GetCurrentPoints()
	if isActive then
		local color = (currentPoints >= consume) and "#00FF00" or "#FF0000"
		
		objSwf.btnConsume.htmlLabel = string.format( txtFormat, txt, color, consume )
		objSwf.levelUpEff._visible = false;
	else
		local itemID,num = BossMedalConsts:GetActiveItem();
		if not itemID then return end
		local itemNum = t_item[itemID].name;
		local bgNum = BagModel:GetItemNumInBag(itemID);
		local color = ( bgNum >= num ) and "#00FF00" or "#FF0000"
		objSwf.btnConsume.htmlLabel = string.format(StrConfig['bosshuizhang022'], color , itemNum .. num .. '个' )
		objSwf.levelUpEff._visible = not isActive and (bgNum >= num)
	end
	local isFull = BossMedalModel:IsFull()
	objSwf.addEff._visible = not isFull and isActive and (currentPoints >= consume)
	objSwf.autoAddEff._visible = not isFull and isActive and (currentPoints >= consume)
end

local lastStar = 0
function UIBossMedal:ShowStar(boom)
	local objSwf = self.objSwf
	if not objSwf then return end
	local star = BossMedalModel:GetStar()
	objSwf.siStar.value = star
	if boom and star > lastStar then
		local starEffect = objSwf["starEffect"..star]
		if starEffect then
			starEffect:playEffect(1)
		end
	end
	lastStar = star
end

local lastGrowValue
function UIBossMedal:ShowGrowValue(noTween, showGain)
	if BossMedalModel:IsFull() or not BossMedalModel:IsActive() then
		return
	end
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = BossMedalModel:GetLevel()
	local growValue = BossMedalModel:GetGrowValue()
	local star = BossMedalModel:GetStar()
	local starGrowValue = BossMedalUtils:GetStarGrowValue(level)
	local oldStar = objSwf.siStar.value
	if star ~= oldStar then
		noTween = true
	end
	if noTween then
		objSwf.siGrowValue:setProgress( growValue, starGrowValue )
	else
		objSwf.siGrowValue:tweenProgress( growValue, starGrowValue )
	end	
	objSwf.proLoaderValue.num = growValue
	objSwf.proLoaderMax.num   = starGrowValue
	if showGain then
		if lastGrowValue then
			local growValueGain = growValue - lastGrowValue;
			if growValueGain > 0 then
				FloatManager:AddNormal( string.format(StrConfig['bosshuizhang021'], growValueGain ), objSwf.posFloat )
			end
		end
	end
	lastGrowValue = growValue
	self:ShowStar(star > oldStar)
end

function UIBossMedal:ShowAttr()
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = math.max( BossMedalModel:GetLevel(), 1 )
	local star = BossMedalModel:GetStar()
	local attrMap = BossMedalUtils:GetAttrMap(level, star)
	local nameFormat, value
	for i, att in ipairs( BossMedalConsts.Attrs ) do
		local textField = objSwf['txtAttr'..i]
		if textField then
			local attrType = AttrParseUtil.AttMap[att]
			nameFormat = BossMedalConsts.AttrNames[att]
			value = getAtrrShowVal( attrType, attrMap[att] )
			textField.htmlText = string.format(nameFormat, value)
		end
	end
end

function UIBossMedal:OnBtnCloseClick()
	self:Hide()
end

function UIBossMedal:OnBtnAutoLevelUpClick()
	if not BossMedalModel:GetAutoLvUp() then
		BossMedalController:ReqLevelUp(true)
	else
		BossMedalController:StopAutoLevelUp()
	end
end

function UIBossMedal:OnBtnLevelUpClick()
	BossMedalController:ReqLevelUp()
end

function UIBossMedal:OnBtnLevelUpRollOver()
	local level = BossMedalModel:GetLevel()
	local isActive = BossMedalModel:IsActive()
	local cfg = t_bosshuizhang[level]
	local levelUpConsume = cfg and cfg.consum
	local consume = isActive and levelUpConsume or BossMedalConsts:GetActiveConsume()
	local txtFormat = isActive and StrConfig['bosshuizhang015'] or StrConfig['bosshuizhang016']
	TipsManager:ShowBtnTips( string.format( txtFormat, consume ), TipsConsts.Dir_RightDown )
	self:ShowIncrement( UIBossMedal.P_NextLevel )
end

function UIBossMedal:OnBtnLevelUpRollOut()
	TipsManager:Hide()
	self:HideIncrement()
end

function UIBossMedal:OnSiStarRollOver()
	TipsManager:ShowBtnTips( string.format( StrConfig['bosshuizhang017'], BossMedalConsts.MaxStar ), TipsConsts.Dir_RightDown )
	self:ShowIncrement( UIBossMedal.P_NextStar )
end

function UIBossMedal:OnSiStarRollOut()
	TipsManager:Hide()
	self:HideIncrement()
end

function UIBossMedal:OnBtnConsumeRollOver()
	local isActive = BossMedalModel:IsActive();
	if isActive then
		TipsManager:ShowBtnTips( StrConfig['bosshuizhang020'], TipsConsts.Dir_RightDown )
	else
		local itemID,num = BossMedalConsts:GetActiveItem();
		if not itemID then return end
		TipsManager:ShowItemTips(itemID);
	end
end

function UIBossMedal:OnBtnConsumeRollOut()
	TipsManager:Hide()
end

function UIBossMedal:ShowIncrement(policy)
	if not policy then
		Error("UIBossMedal:ShowIncrement(policy) :: args missing !!!")
		return
	end
	local objSwf = self.objSwf
	if not objSwf then return end
	local currentlevel = BossMedalModel:GetLevel()
	if currentlevel <= 0 then
		return
	end
	local currentStar = BossMedalModel:GetStar()
	local level, star, suffix
	if policy == UIBossMedal.P_NextLevel then
		if currentlevel == BossMedalConsts:GetMaxLevel() then
			return
		end
		level = currentlevel + 1
		star = 0
		suffix = string.format( StrConfig['bosshuizhang018'], BossMedalConsts.MaxStar - currentStar )
	elseif policy == UIBossMedal.P_NextStar then
		if currentStar == (BossMedalConsts.MaxStar - 1) then
			self:ShowIncrement( UIBossMedal.P_NextLevel )
			return
		end
		level = currentlevel
		star = currentStar + 1
		suffix = StrConfig['bosshuizhang019']
	end
	local incrementAttrMap = BossMedalUtils:GetAttrIncrementMap( level, star )
	for i, att in ipairs( BossMedalConsts.Attrs ) do
		local btn = objSwf['increment'..i]
		local attrType = AttrParseUtil.AttMap[att]
		btn.label = string.format( "%s(%s)", getAtrrShowVal( attrType, incrementAttrMap[att] ), suffix )
		btn._visible = true
	end
	self.attrIncrementPolicy = policy
end

function UIBossMedal:HideIncrement()
	self.attrIncrementPolicy = nil
	local objSwf = self.objSwf
	if not objSwf then return end
	for i, att in ipairs( BossMedalConsts.Attrs ) do
		local btn = objSwf['increment'..i]
		btn._visible = false
	end
end

function UIBossMedal:UpdateAttrIncrement(policy)
	if not self.attrIncrementPolicy then return end
	self:ShowIncrement(self.attrIncrementPolicy)
end

--升级特效
function UIBossMedal:PlayLevelUpEffect()
	local objSwf = self.objSwf
	if not objSwf then return end
	if BossMedalModel:GetLevel() <= 1 then return end
	self.autoAddState = false;
	objSwf.btn_autoAdd.label = UIStrConfig['bossshuizhang2'];
	objSwf.effect_levelup:stopEffect();
	objSwf.effect_levelup:playEffect(1);
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIBossMedal:ListNotificationInterests()
	return {
		NotifyConsts.BossMedalBossNum,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.BossMedalLevel,
		NotifyConsts.BossMedalStar,
		NotifyConsts.BossMedalGrowValue,
		NotifyConsts.BossMedalAutoLvUp,
	}
end

--处理消息
function UIBossMedal:HandleNotification(name, body)
	if name == NotifyConsts.BossMedalBossNum then
		self:ShowBossNum()
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaBossPoints then
			self:ShowCurrentPoints()
			self:ShowConsume()
		end
	elseif name == NotifyConsts.BossMedalLevel then
		self:ShowLevel()
		self:ShowAttr()
		self:ShowConsume()
		self:ShowGrowValue(true)
		self:UpdateAttrIncrement( UIBossMedal.P_NextLevel )
		self:PlayLevelUpEffect();
	elseif name == NotifyConsts.BossMedalStar then
		self:ShowAttr()
		self:UpdateAttrIncrement( UIBossMedal.P_NextStar )
	elseif name == NotifyConsts.BossMedalGrowValue then
		self:ShowGrowValue(false, true)
	elseif name == NotifyConsts.BossMedalAutoLvUp then
		self:UpdateBtnLabel()
	end
end