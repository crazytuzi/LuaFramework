--[[
神武 view
haohu
2015年12月25日16:36:03
]]

_G.UIShenWu = BaseUI:new("UIShenWu")

function UIShenWu:Create()
	self:AddSWF("shenwu.swf", true, "center")
	self:AddChild( UIShenWuSkillLvlUp, "shenWuSkillLvlUp");
end

function UIShenWu:OnLoaded( objSwf )
	self:GetChild("shenWuSkillLvlUp"):SetContainer(objSwf.childPanelSkill);
	objSwf.btnClose.click = function() self:Hide() end
	objSwf.currentWeapon.rollOver = function() self:OnWeaponIconRollOver() end
	objSwf.currentWeapon.rollOut = function() TipsManager:Hide() end
	objSwf.btnRule.rollOver = function() self:OnBtnRuleOver() end
	objSwf.btnRule.rollOut = function() TipsManager:Hide() end
	objSwf.listSkill.itemRollOver = function(e) self:OnSkillRollOver(e); end
	objSwf.listSkill.itemRollOut  = function() self:OnSkillRollOut(); end
	objSwf.listSkill.itemClick    = function(e) self:OnSkillClick(e); end
	UIShenWuActive:OnLoaded( objSwf.activePanel )
	UIShenWuLevelUp:OnLoaded( objSwf.levelUpPanel )
	objSwf.btnShenWu.htmlLabel = StrConfig['shenwu29'];
end

function UIShenWu:IsTween()
	return true;
end

function UIShenWu:GetPanelType()
	return 1;
end

function UIShenWu:IsShowSound()
	return true;
end

function UIShenWu:GetWidth()
	return 1489
end

function UIShenWu:GetHeight()
	return 744
end

function UIShenWu:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil)
	end
	UIShenWuActive:OnDelete()
	UIShenWuLevelUp:OnDelete()
end

function UIShenWu:OnShow()
	self:ShowCurrentWeapon()
	self:ShowSkill()
	self:ShowRightPanel()
	UIShenWuActive:UpdateShow()
	UIShenWuLevelUp:UpdateShow()
	self:UpdateMask()
	self:UpdateCloseButton()
end

function UIShenWu:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.btnClose._x = math.min( math.max( wWidth - 50, 1280 ), 1380 )
end

function UIShenWu:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
	self:UpdateCloseButton()
end

function UIShenWu:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 10
	objSwf.mcMask._height = wHeight + 10
end

function UIShenWu:OnHide()
	if self.objAvatar then
		self.objAvatar:Destroy()
		self.objAvatar = nil
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false)
	end
	UIShenWuActive:Hide()
	UIShenWuLevelUp:Hide()
end

function UIShenWu:OnBtnRuleOver()
	TipsManager:ShowBtnTips( StrConfig["shenwu14"], TipsConsts.Dir_RightDown )
end

-- 技能tips
function UIShenWu:OnSkillRollOver(e)
	local skillInfo = e.item or e.target.data
	if not skillInfo then return end
	local tipsInfo = {
		skillId = skillInfo.skillId,
		condition = true,
		get = skillInfo.lvl > 0
	}
	TipsManager:ShowTips( TipsConsts.Type_Skill, tipsInfo, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown )
end

function UIShenWu:OnSkillRollOut()
	TipsManager:Hide();
end

function UIShenWu:OnSkillClick(e)
	local skillInfo = e.item
	if not skillInfo then return end
	if not ShenWuUtils:IsFreeShenWuSkill(skillInfo.skillId) then
		UIShenWuSkillLvlUp:Open(skillInfo.skillId, skillInfo.lvl)
	else
		FloatManager:AddNormal( StrConfig["shenwu22"] )
	end
	TipsManager:Hide();
end

function UIShenWu:OnWeaponIconRollOver()
	ShenWuUtils:ShowShenWuTips(ShenWuModel:GetLevel(), ShenWuModel:GetStar())
end

function UIShenWu:ShowCurrentWeapon()
	local objSwf = self.objSwf
	if not objSwf then return end
	-- 格子
	local vo = EquipUtil:GetEquipUIVO( BagConsts.Equip_WuQi, false )
	if not vo.hasItem then
		ShenWuUtils:GetDataToShenWuUIVO(vo)
	end
	local itemUIData = UIData.encode(vo)
	objSwf.currentWeapon:setData( itemUIData ) 
	-- 模型
	self:Show3dWeapon()
end

function UIShenWu:ShowSkill()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = SkillUtil:GetPassiveSkillListByShow( SkillConsts.ShowType_ShenWuPassive )
	local listSkill = objSwf.listSkill
	listSkill.dataProvider:cleanUp()
	for i, vo in ipairs(list) do
		local listVO = ShenWuUtils:GetSkillListVO(vo.skillId, vo.lvl)
		listSkill.dataProvider:push( UIData.encode(listVO) )
	end
	listSkill:invalidateData()
end

local viewPort
function UIShenWu:Show3dWeapon(level)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not level then
		level = ShenWuModel:GetLevel();
	end
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1479, 732) end
		self.objUIDraw = UISceneDraw:new( "UIShenWu", objSwf.loader, viewPort );
	end
	objSwf.nameLoader.source = ResUtil:GetShenWuUINameImg(level>0 and level or 1);
	objSwf.lvlLoader.num = level>0 and level or 1;
	local func = function()
		local equipId = ShenWuUtils:GetCurrentWuQiId()
		local skn, skl, san = ShenWuUtils:GetModelInfo(equipId)
		self.objAvatar = ShenWuAvatar:new(skn, skl, san)
		local list = self.objUIDraw:GetMarkers()
		local marker
		for _, mkr in pairs(list) do
			marker = mkr
			break
		end
		if not marker then return end
		self.objAvatar:EnterUIScene( self.objUIDraw.objScene, marker.pos, marker.dir, marker.scale, enEntType.eEntType_ShenWu)
		local bone, pfx = ShenWuUtils:GetUIPfxInfo(level)
		if bone and pfx then
			self.objAvatar:PlayPfxOnBone(bone, pfx, pfx)
		end
		self.objAvatar:ExecIdleAction()
	end

	self.objUIDraw:SetUILoader(objSwf.loader)
	self.objUIDraw:SetScene( ShenWuUtils:GetUIScene(), func )
	self.objUIDraw:SetDraw( true )
end

function UIShenWu:ShowRightPanel()
	if ShenWuModel:IsActive() then
		UIShenWuActive:Hide()
		UIShenWuLevelUp:Show()
	else
		UIShenWuActive:Show()
		UIShenWuLevelUp:Hide()
	end
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIShenWu:ListNotificationInterests()
	return {
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		--
		NotifyConsts.BagItemNumChange,
		NotifyConsts.ShenWuLevel,
		NotifyConsts.ShenWuStar,
		NotifyConsts.ShenWuStone,
		NotifyConsts.ShenWuStarRate,
		NotifyConsts.SkillLearn,
		NotifyConsts.SkillLvlUp,
	}
end

--处理消息
function UIShenWu:HandleNotification(name, body)
	if name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove then
		if body.type == BagConsts.BagType_Role then
			self:ShowCurrentWeapon()
		end
	elseif name == NotifyConsts.ShenWuLevel then
		self:ShowCurrentWeapon()
		self:ShowRightPanel()
		self:ShowSkill()
	elseif name == NotifyConsts.ShenWuStar then
		self:ShowCurrentWeapon()
		self:ShowRightPanel()
	elseif name == NotifyConsts.SkillLearn or name == NotifyConsts.SkillLvlUp then
		self:ShowSkill()
	elseif name == NotifyConsts.BagItemNumChange then
		self:ShowSkill()
	end
	UIShenWuActive:HandleNotification(name, body)
	UIShenWuLevelUp:HandleNotification(name, body)
end