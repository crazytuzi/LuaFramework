--[[
boss 勋章 tips
haohu
2015年11月23日12:03:45
]]

_G.UIBossMedalTips = BaseUI:new("UIBossMedalTips")

function UIBossMedalTips:Create()
	self:AddSWF("bossMedalTips.swf", true, "center")
end

function UIBossMedalTips:OnLoaded()
	self:ShowPrompt()
end

function UIBossMedalTips:OnShow()
	if not BossMedalModel:IsActive() then
		Error(" bosshuizhang is not ACTIVE !!")
		self:Hide()
		return
	end
	self:ShowLevel()
	self:ShowAttr()
	self:UpdatePos()
end

function UIBossMedalTips:ShowPrompt()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.txtAttrTitle.text = StrConfig["bosshuizhang027"]
	objSwf.txtPrompt.htmlText = StrConfig["bosshuizhang028"]
end

function UIBossMedalTips:ShowLevel()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.txtTitle.htmlText = string.format( StrConfig["bosshuizhang029"], BossMedalModel:GetLevel() )
end

function UIBossMedalTips:ShowAttr()
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = BossMedalModel:GetLevel()
	local star = BossMedalModel:GetStar()
	local attrMap = BossMedalUtils:GetAttrMap(level, star)
	local str = ""
	for i, att in ipairs( BossMedalConsts.Attrs ) do
		local attrType = AttrParseUtil.AttMap[att]
		if attrType ~= enAttrType.eaAdddamagebossx and attrType ~= enAttrType.eaAdddamagemonx then
			local attrName = _G.enAttrTypeName[attrType]
			str = string.format( "%s<font color='#D5B772'>%s</font>    %s<br/>", str, attrName, _G.getAtrrShowVal(attrType, attrMap[att]) )
		end
	end
	objSwf.txtAttr.htmlText = str
	objSwf.txtBoss.text = _G.getAtrrShowVal( enAttrType.eaAdddamagebossx, attrMap["adddamagebossx"] )
	objSwf.txtMonster.text  = _G.getAtrrShowVal( enAttrType.eaAdddamagemonx, attrMap["adddamagemonx"] )
end

function UIBossMedalTips:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local tipsDir = TipsConsts.Dir_RightDown;
	local tipsX, tipsY = TipsUtils:GetTipsPos( self:GetWidth(), self:GetHeight(), tipsDir );
	objSwf._x = tipsX;
	objSwf._y = tipsY;
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIBossMedalTips:ListNotificationInterests()
	return {
		NotifyConsts.StageMove,
		NotifyConsts.BossMedalLevel,
		NotifyConsts.BossMedalStar
	}
end

--处理消息
function UIBossMedalTips:HandleNotification(name, body)
	if name == NotifyConsts.StageMove then
		self:UpdatePos()
	elseif name == NotifyConsts.BossMedalLevel then
		self:ShowLevel()
		self:ShowAttr()
	elseif name == NotifyConsts.BossMedalStar then
		self:ShowAttr()
	end
end

