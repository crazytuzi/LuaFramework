--[[
灵兽魂魄 view
2016年1月14日15:22:35
haohu
]]

_G.UIShouHun = BaseUI:new("UIShouHun")

UIShouHun.P_NextLevel = 1
UIShouHun.P_NextStar = 2
UIShouHun.attrIncrementPolicy = nil

function UIShouHun:Create()
	self:AddSWF("shouhun.swf", true, "center")
end

function UIShouHun:OnLoaded( objSwf )
	objSwf.btnActive.click        = function() self:OnBtnLvlUpClick(); end
	objSwf.btnLvlUp.click        = function() self:OnBtnLvlUpClick(); end
	objSwf.btnLvlUp.rollOver     = function() self:OnBtnLvlUpRollOver(); end
	objSwf.btnLvlUp.rollOut      = function() self:OnBtnLvlUpRollOut(); end
	objSwf.starIndicator.rollOver = function() self:OnStarRollOver(); end
	objSwf.starIndicator.rollOut = function() self:OnStarRollOut(); end
	objSwf.btnAutoLvlUp.click    = function() self:OnBtnAutoLvlUpClick(); end
	objSwf.btnAutoLvlUp.rollOver = function() self:OnBtnLvlUpRollOver(); end
	objSwf.btnAutoLvlUp.rollOut  = function() self:OnBtnLvlUpRollOut(); end
	objSwf.btnCancelAuto.click   = function() self:OnBtnCancelAutoClick(); end
	objSwf.list.itemRollOver = function(e) self:OnLunPanRollOver(e) end
	objSwf.list.itemRollOut = function() TipsManager:Hide() end
	objSwf.list.change = function() self:OnListChange() end
	objSwf.btnLink.rollOver = function() self:OnBtnLinkRollOver() end
	objSwf.btnLink.rollOut = function() TipsManager:Hide() end
	objSwf.btnConsume.rollOver = function() self:OnBtnConsumeRollOver() end
	objSwf.btnConsume.rollOut = function() TipsManager:Hide() end
	objSwf.starIndicator.maximum = ShouHunConsts:GetMaxStar()
	objSwf.txtName.autoSize   = "center"
	objSwf.txtAttrUp.autoSize   = "center"
	objSwf.lblConsume.autoSize   = "left"
	objSwf.lblConsume.htmlText   = StrConfig['shouhun8']
	objSwf.btnConsume.autoSize   = true
	objSwf.btnActive.label = StrConfig['shouhun12']
	objSwf.txtAttrPrompt.htmlText = StrConfig['shouhun23']
	objSwf.list.selectedIndex    = 0
	self:HideIncrement()
end

function UIShouHun:OnShow()
	self:ShowLevel()
	self:ShowAttr()
	self:ShowCurrentShouHun()
	self:ShowAutoState()
end

function UIShouHun:OnHide()
	self:HideIncrement()
	ShouHunController:StopAutoLevelUp()
end

function UIShouHun:ShowCurrentShouHun()
	self:ShowName()
	self:ShowAttrTimes()
	self:ShowStar()
	self:ShowConsume()
	self:ShowBtnState()
	self:ShowBtnEffect()
	self:ShouMaxLevel()
end

function UIShouHun:ShowName()
	local objSwf = self.objSwf
	if not objSwf then return end
	local shouHun = self:GetSelectedShouHun()
	if shouHun then
		objSwf.txtName.htmlText = string.format( "<font color='#FAC41E'>%s</font> <font color='#00FF00'>LV.%s</font>", shouHun:GetName(), shouHun:GetLevel() )
	end
end

function UIShouHun:ShowAttrTimes()
	local objSwf = self.objSwf
	if not objSwf then return end
	local shouHun = self:GetSelectedShouHun()
	if shouHun then
		local attr = shouHun:GetBaseAttr()
		local attrName = _G.enAttrTypeName[attr.type]
		objSwf.txtAttrUp.htmlText = string.format( StrConfig['shouhun9'], attrName, shouHun:GetAttrTimes() * 100 )
	end
end

function UIShouHun:ShowStar(boom)
	local objSwf = self.objSwf
	if not objSwf then return end
	local shouHun = self:GetSelectedShouHun()
	local star = shouHun:GetStar()
	if shouHun then
		objSwf.starIndicator.value = star
		objSwf.starIndicator._visible = not shouHun:IsFull() and shouHun:IsActive()
	end
	if boom then
		local starEffect = objSwf["starEffect"..star]
		if starEffect then
			starEffect:playEffect(1)
		end
	end
end

function UIShouHun:ShowConsume()
	local objSwf = self.objSwf
	if not objSwf then return end
	local shouHun = self:GetSelectedShouHun()
	if shouHun and not shouHun:IsFull() then
		local vo = shouHun:GetNeedItem()
		local itemCfg = t_item[vo.id]
		local itemName = tostring( itemCfg and itemCfg.name )
		local color = shouHun:IsItemEnough() and "#00FF00" or "#FF0000"
		objSwf.btnConsume.htmlLabel = string.format( StrConfig['shouhun10'], color, itemName, vo.num )
		objSwf.btnConsume._visible = true
		objSwf.lblConsume._visible = true
		return
	end
	objSwf.btnConsume._visible = false
	objSwf.lblConsume._visible = false
end

function UIShouHun:ShowLevel()
	local objSwf = self.objSwf
	if not objSwf then return end
	for tid, shouHun in pairs(ShouHunModel:GetAllShouHun()) do
		local textField = objSwf['txtLvl'..tid]
		if textField then
			textField.htmlText = string.format( "LV.%s", shouHun:GetLevel() )
		end
		local renderer = objSwf['itemShouHun'..tid]
		if renderer then
			renderer.mcLock._visible = not shouHun:IsActive()
			renderer.effect._visible = shouHun:IsActive()
		end
	end
end

function UIShouHun:ShowAttr()
	local objSwf = self.objSwf
	if not objSwf then return end
	for tid, _ in ipairs( ShouHunConsts.config ) do
		local shouHun = ShouHunModel:GetShouHun(tid)
		local textField = objSwf["txtAttr"..tid]
		if textField then
			textField.htmlText = shouHun and shouHun:GetShowAttr()
		end
	end
	objSwf.numLoaderFight.num = ShouHunModel:GetFight()
end

function UIShouHun:ShowAutoState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local isAuto = ShouHunModel:GetAutoLevelUpFunc() ~= nil
	objSwf.btnCancelAuto._visible = isAuto
	if isAuto then
		self:ShowIncrement( UIShouHun.P_NextLevel )
	else
		self:HideIncrement()
	end
end

function UIShouHun:ShowBtnState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local shouHun = self:GetSelectedShouHun()
	if not shouHun then return end
	local isActive = shouHun:IsActive()
	local isFull = shouHun:IsFull()
	objSwf.btnActive._visible = not isActive
	objSwf.btnLvlUp._visible = not isFull and isActive
	objSwf.btnAutoLvlUp._visible = not isFull and isActive
end

function UIShouHun:ShowBtnEffect()
	local objSwf = self.objSwf
	if not objSwf then return end
	local shouHun = self:GetSelectedShouHun()
	if not shouHun then return end
	local isActive = shouHun:IsActive()
	local itemEnough = shouHun:IsItemEnough()
	local isFull = shouHun:IsFull()
	objSwf.btnActiveEff._visible  = not isActive and itemEnough
	objSwf.btnLvlUpEff._visible = not isFull and isActive and itemEnough
	objSwf.btnAutoEff._visible  = not isFull and isActive and itemEnough
end

function UIShouHun:ShouMaxLevel()
	local objSwf = self.objSwf
	if not objSwf then return end
	local shouHun = self:GetSelectedShouHun()
	if not shouHun then return end
	objSwf.mcMaxLevel._visible = shouHun:IsFull()
end

function UIShouHun:OnBtnLvlUpClick()
	ShouHunController:StopAutoLevelUp()
	--
	local shouHun = self:GetSelectedShouHun()
	if not shouHun then return end
	shouHun:LevelUp()
end

function UIShouHun:OnStarRollOver()
	self:ShowIncrement( UIShouHun.P_NextStar )
end

function UIShouHun:OnBtnLvlUpRollOver()
	self:ShowIncrement( UIShouHun.P_NextLevel )
end

function UIShouHun:OnBtnLvlUpRollOut()
	self:HideIncrement()
end

function UIShouHun:OnStarRollOut()
	self:HideIncrement()
end

function UIShouHun:OnBtnAutoLvlUpClick()
	local shouHun = self:GetSelectedShouHun()
	if shouHun then
		ShouHunController:StartAutoLevelUp(shouHun:GetTid())
	end
end

function UIShouHun:OnBtnCancelAutoClick()
	ShouHunController:StopAutoLevelUp()
end

function UIShouHun:OnLunPanRollOver(e)
	if type( e.index ) ~= "number" then return end
	local tid = e.index + 1
	local shouHun = ShouHunModel:GetShouHun(tid)
	if shouHun then
		shouHun:ShowTips()
	end
end

function UIShouHun:OnListChange()
	self:ShowCurrentShouHun()
	ShouHunController:StopAutoLevelUp()
end

function UIShouHun:OnBtnConsumeRollOver()
	local shouHun = self:GetSelectedShouHun()
	local item = shouHun and shouHun:GetNeedItem()
	if item then
		TipsManager:ShowItemTips(item.id)
	end
end

function UIShouHun:OnBtnLinkRollOver()
	local tips = ShouHunLinkTips:GetTips()
	TipsManager:ShowBtnTips( tips, TipsConsts.Dir_RightDown )
end

function UIShouHun:ShowIncrement(policy)
	if not policy then
		Error("UIShouHun:ShowIncrement(policy) :: args missing !!!")
		return
	end
	local objSwf = self.objSwf
	if not objSwf then return end
	local shouHun = self:GetSelectedShouHun()
	if not shouHun then return end
	if not shouHun:IsActive() then
		return
	end
	if shouHun:IsFull() then
		return
	end
	local currentlevel = shouHun:GetLevel()
	local currentStar = shouHun:GetStar()
	local level, star, suffix
	if policy == UIShouHun.P_NextLevel then
		level = currentlevel + 1
		star = 0
		suffix = string.format( StrConfig['shouhun16'], ShouHunConsts:GetMaxStar() - currentStar )
	elseif policy == UIShouHun.P_NextStar then
		if currentStar == (ShouHunConsts:GetMaxStar() - 1) then
			self:ShowIncrement( UIShouHun.P_NextLevel )
			return
		end
		level = currentlevel
		star = currentStar + 1
		suffix = StrConfig['shouhun15']
	end
	local incrementAttr = shouHun:GetAttrIncrement( level, star )
	local btn = objSwf['increment'..shouHun:GetTid()]
	btn.label = string.format( "%s(%s)", getAtrrShowVal( incrementAttr.type, toint(incrementAttr.val, 0.5) ), suffix )
	btn._visible = true
	self.attrIncrementPolicy = policy
end

function UIShouHun:UpdateAttrIncrement(policy)
	if not self.attrIncrementPolicy then return end
	if self.attrIncrementPolicy ~= policy then return end
	self:ShowIncrement(self.attrIncrementPolicy)
end

function UIShouHun:HideIncrement()
	local objSwf = self.objSwf
	if not objSwf then return end
	for tid, _ in pairs( ShouHunModel:GetAllShouHun() ) do
		local btn = objSwf['increment'..tid]
		btn._visible = false
	end
end

function UIShouHun:GetSelectedShouHun()
	local objSwf = self.objSwf
	if not objSwf then return end
	local tid = objSwf.list.selectedIndex + 1
	return tid > 0 and ShouHunModel:GetShouHun( tid ) or nil
end
---------------------------------消息处理------------------------------------
--监听消息列表
function UIShouHun:ListNotificationInterests()
	return {
		NotifyConsts.ShouHunLevel,
		NotifyConsts.ShouHunStar,
		NotifyConsts.WuhunLevelUpUpdate,
		NotifyConsts.ShouHunAutoLevelUp,
		NotifyConsts.BagItemNumChange,
	};
end

--处理消息
function UIShouHun:HandleNotification(name, body)
	if name == NotifyConsts.ShouHunLevel then
		self:ShowLevel()
		self:ShowAttr()
		self:ShowCurrentShouHun()
		self:UpdateAttrIncrement( UIShouHun.P_NextLevel )
	elseif name == NotifyConsts.ShouHunStar then
		self:ShowStar(true)
		self:ShowAttr()
		self:ShowCurrentShouHun()
		self:UpdateAttrIncrement( UIShouHun.P_NextStar )
	elseif name == NotifyConsts.WuhunLevelUpUpdate then
		self:ShowAttr()
	elseif name == NotifyConsts.ShouHunAutoLevelUp then
		self:ShowAutoState()
	elseif name == NotifyConsts.BagItemNumChange then
		self:ShowConsume()
		self:ShowBtnEffect()
	end
end