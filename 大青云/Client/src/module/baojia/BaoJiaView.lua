--[[
宝甲：主面板
2015年4月28日17:12:38
zhangshuhui
]]

_G.UIBaoJia = BaseUI:new("UIBaoJia");

--技能列表
UIBaoJia.skilllist = {};
--当前显示的等阶
UIBaoJia.currentShowLevel = nil;

function UIBaoJia:Create()
	self:AddSWF("baoJiaPanel.swf", true, "center");
	self:AddChild( UIBaoJiaLvlUp, "baoJiaLvlUp");
	self:AddChild( UIBaoJiaSkillLvlUp, "baoJiaSkillLvlUp");
end

function UIBaoJia:OnLoaded( objSwf )
	self:GetChild("baoJiaLvlUp"):SetContainer(objSwf.childPanel);
	self:GetChild("baoJiaSkillLvlUp"):SetContainer(objSwf.childPanelSkill);

	objSwf.loader.hitTestDisable = true;
	objSwf.btnLvlUp.rollOver         = function() self:OnBtnLvlUpRollOver(); end
	objSwf.btnLvlUp.rollOut          = function() self:OnBtnLvlUpRollOut(); end
	objSwf.btnLvlUp.click            = function() self:OnBtnLvlUpClick(); end
	objSwf.listSkill.itemRollOver    = function(e) self:OnSkillRollOver(e); end
	objSwf.listSkill.itemRollOut     = function() self:OnSkillRollOut(); end
	objSwf.listSkill.itemClick       = function(e) self:OnSkillClick(e); end
	objSwf.btnClose.click            = function() self:OnBtnCloseClick(); end
	objSwf.btnPre.click              = function() self:OnBtnPreClick(); end
	objSwf.btnNext.click             = function() self:OnBtnNextClick(); end

	self:HideIncrement()
end

function UIBaoJia:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIBaoJia:OnShow()
	self:UpdateShow();
end

function UIBaoJia:GetWidth()
	return 795;
end

function UIBaoJia:GetHeight()
	return 682;
end

function UIBaoJia:IsTween()
	return true;
end

function UIBaoJia:GetPanelType()
	return 1;
end

function UIBaoJia:IsShowSound()
	return true;
end

function UIBaoJia:IsShowLoading()
	return true;
end

function UIBaoJia:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

function UIBaoJia:OnBtnLvlUpRollOver()
	self:ShowIncrement();
end

function UIBaoJia:OnBtnLvlUpRollOut()
	self:HideIncrement();
end

function UIBaoJia:OnBtnLvlUpClick()
	local level = BaoJiaModel:GetLevel();
	if level >= BaoJiaConsts.MaxLvl then
		FloatManager:AddNormal( StrConfig['baoJia003'] );
		return;
	end
	local showLvlUp = not UIBaoJiaLvlUp:IsShow()
	self:ShowLvlUpPanel(showLvlUp);
end

function UIBaoJia:ShowLvlUpPanel(show)
	if not self:IsShow() then return end
	if show == nil then show = true; end
	if show then
		self:ShowChild("baoJiaLvlUp");
	else
		UIBaoJiaLvlUp:Hide();
	end
end

-- 显示正常的tips
function UIBaoJia:OnSkillRollOver(e)
	local skillInfo = e.item or e.target.data;
	if not skillInfo then return; end
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	local tipsInfo = { skillId = skillInfo.skillId, condition = true, get = skillInfo.lvl > 0 };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

function UIBaoJia:OnSkillRollOut()
	TipsManager:Hide();
end

function UIBaoJia:OnSkillClick(e)
	local skillInfo = e.item;
	UIBaoJiaSkillLvlUp:Open(skillInfo.skillId, skillInfo.lvl);
end

function UIBaoJia:OnBtnCloseClick()
	self:Hide();
end

function UIBaoJia:OnBtnPreClick()
	self:ShowBaoJia( self.currentShowLevel - 1 );
end

function UIBaoJia:OnBtnNextClick()
	self:ShowBaoJia( self.currentShowLevel + 1 );
end

-- @param showActive: 是否显示模型激活(开启新等阶时候需要显示)
function UIBaoJia:UpdateShow()
	self:ShowBaoJia();
	self:ShowBaoJiaSkill();
	self:ShowBaoJiaFight();
	self:ShowBaoJiaAttr();
end

-- 显示等级为level的宝甲,如不传,则显示当前等级的神兵
-- showActive: 是否播放激活动作
function UIBaoJia:ShowBaoJia( level, showActive )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local currentLevel = BaoJiaModel:GetLevel();
	if not level then
		level = currentLevel;
	end
	local cfg = t_baojia[level];
	if not cfg then return; end
	objSwf.nameLoader.source = ResUtil:GetBaoJiaNameImg(level);
	local lvlStr = tostring(level);
	if level == 10 then lvlStr = "a" end;
	objSwf.lvlLoader:drawStr( lvlStr );
	self:Show3DBaoJia(level, showActive);
	objSwf.btnPre.disabled = level <= 1;
	objSwf.btnNext.disabled = level >= currentLevel;
	local isMaxLvl = currentLevel >= BaoJiaConsts.MaxLvl;
	objSwf.btnLvlUp._visible = not isMaxLvl;
	objSwf.maxLvlMc._visible = isMaxLvl;
	self.currentShowLevel = level;
end

-- 显示等级为level的3d宝甲模型
-- showActive: 是否播放激活动作
local viewPort;
function UIBaoJia:Show3DBaoJia( level, showActive )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not level then
		level = BaoJiaModel:GetLevel();
	end
	local cfg = t_baojia[level];
	if not cfg then
		Error("Cannot find config of baojia. level:"..level);
		return;
	end
	local modelCfg = t_shenbingmodel[cfg.model];
	if not modelCfg then
		Error("Cannot find config of BaoJiaModel. id:"..cfg.model);
		return;
	end
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(836, 578); end
		self.objUIDraw = UISceneDraw:new( "BaoJiaUI", objSwf.loader, viewPort );
	end
	self.objUIDraw:SetUILoader(objSwf.loader);
	
	-- local setUIPfxFunc = function()
		-- if modelCfg.effect and modelCfg.effect ~= ""then
			-- self.objUIDraw:PlayNodePfx( cfg.ui_node, modelCfg.effect);
		-- end
	-- end
	
	if showActive then
		self.objUIDraw:SetScene( cfg.ui_sen, function()
			local aniName = modelCfg.active_move;
			if aniName == "" then return end
			self.objUIDraw:NodeAnimation( cfg.ui_node, aniName );
			-- setUIPfxFunc()
		end );
	else
		self.objUIDraw:SetScene( cfg.ui_sen, nil );
	end
	self.objUIDraw:SetDraw( true );
end

function UIBaoJia:ShowBaoJiaSkill()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = SkillUtil:GetPassiveSkillListByShow( SkillConsts.ShowType_BaoJia );
	local listSkill = objSwf.listSkill;
	listSkill.dataProvider:cleanUp();
	for i, vo in ipairs(list) do
		local listVO = BaoJiaUtils:GetSkillListVO(vo.skillId, vo.lvl);
		table.push( self.skilllist, listVO );
		listSkill.dataProvider:push( UIData.encode(listVO) );
	end
	listSkill:invalidateData();
end

function UIBaoJia:ShowBaoJiaFight()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = BaoJiaModel:GetLevel();
	local fight = BaoJiaUtils:GetFight( level ) or 0;
	local shenbinglingFight = self:GetShenbinglingFight() or 0;
	objSwf.numLoaderFight.num = fight + shenbinglingFight;
end

function UIBaoJia:ShowBaoJiaAttr()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = BaoJiaModel:GetLevel();
	local attrMap = BaoJiaUtils:GetBaoJiaAttrMap(level);
	if not attrMap then return; end
	local skillAttrMap = self:GetSkillAttrMap();
	local attrTotal = {};
	for _, attrName in pairs(BaoJiaConsts.Attrs) do
		attrTotal[attrName] = attrMap[attrName] + skillAttrMap[attrName];
	end
	objSwf.txtAtt.htmlText      = string.format( StrConfig['baojia004'], attrTotal["att"] );
	objSwf.txtDef.htmlText      = string.format( StrConfig['baojia005'], attrTotal["def"] );
	objSwf.txtDefcri.htmlText      = string.format( StrConfig['baojia006'], attrTotal["defcri"] );
	objSwf.txtHp.htmlText       = string.format( StrConfig['baojia007'], attrTotal["hp"] );
	objSwf.txtSubcri.htmlText = string.format( StrConfig['baojia008'], getAtrrShowVal( enAttrType.eaBaoJiHurt, attrTotal["subcri"] ) );
end

function UIBaoJia:GetSkillAttrMap()
	local map = {};
	for _, attrName in pairs(BaoJiaConsts.Attrs) do
		map[attrName] = 0;
	end
	local list = SkillUtil:GetPassiveSkillListByShow( SkillConsts.ShowType_BaoJia );
	local cfg, skillGroup, index, skillLevel, shenbingling, shenbinglingCfg, skillAttrStr, attrMap;
	for i, vo in ipairs(list) do
		cfg = vo.cfg;
		skillGroup = cfg.group_id;
		skillLevel = vo.lvl;
		shenbingling = skillGroup * 100 + skillLevel;
		shenbinglingCfg = t_jialing[shenbingling];
		if shenbinglingCfg then
			skillAttrStr = shenbinglingCfg.attr;
			attrMap = AttrParseUtil:ParseAttrToMap( skillAttrStr );
			for name, attrValue in pairs(attrMap) do
				if not map[name] then
					Debug( string.format('Requir attribute "%s" in BaoJiaConsts.Attrs.', name) );
				else
					map[name] = map[name] + attrValue;
				end
			end
		end
	end
	return map;
end

function UIBaoJia:GetShenbinglingFight()
	local skillAttrMap = self:GetSkillAttrMap();
	local attrList = {};
	for attrType, attrValue in pairs(skillAttrMap) do
		local vo = {};
		vo.type = AttrParseUtil.AttMap[attrType];
		vo.val = attrValue;
		table.push(attrList, vo);
	end
	return EquipUtil:GetFight( attrList );
end

function UIBaoJia:ShowIncrement()
	local level = BaoJiaModel:GetLevel();
	if level >= BaoJiaConsts.MaxLvl then return; end
	local nextLevel = level + 1;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtIncrement._visible      = true;
	objSwf.incrementFight._visible    = true;
	objSwf.incrementAtt._visible      = true;
	objSwf.incrementDef._visible      = true;
	objSwf.incrementDefcri._visible   = true;
	objSwf.incrementHp._visible       = true;
	objSwf.incrementSubcri._visible = true;
	self:ShowBaoJia(nextLevel);
	local maxFight = BaoJiaUtils:GetFight( level ) or 0;
	local nextFight = BaoJiaUtils:GetFight( nextLevel ) or 0;
	objSwf.incrementFight.label = nextFight - maxFight;
	local incrementMap = BaoJiaUtils:GetAttrIncrementMap(level);
	if not incrementMap then return; end
	objSwf.incrementAtt.label      = incrementMap.att;
	objSwf.incrementDef.label      = incrementMap.def;
	objSwf.incrementDefcri.label      = incrementMap.defcri;
	objSwf.incrementHp.label       = incrementMap.hp;
	objSwf.incrementSubcri.label = getAtrrShowVal( enAttrType.eaBaoJiHurt, incrementMap.subcri );
end

function UIBaoJia:HideIncrement()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtIncrement._visible      = false;
	objSwf.incrementFight._visible    = false;
	objSwf.incrementAtt._visible      = false;
	objSwf.incrementDef._visible      = false;
	objSwf.incrementDefcri._visible   = false;
	objSwf.incrementHp._visible       = false;
	objSwf.incrementSubcri._visible = false;
	local level = BaoJiaModel:GetLevel();
	self:ShowBaoJia(level);
end


---------------------------消息处理---------------------------------
--监听消息列表
function UIBaoJia:ListNotificationInterests()
	return {
		NotifyConsts.BaoJiaUpdate,
		NotifyConsts.BaoJiaLevelUp,
		NotifyConsts.SkillLearn,
		NotifyConsts.SkillLvlUp,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
	};
end

--处理消息
function UIBaoJia:HandleNotification(name, body)
	if name == NotifyConsts.BaoJiaUpdate then
		self:UpdateShow();
	elseif name == NotifyConsts.BaoJiaLevelUp then
		self:ShowBaoJia( nil ,true );
	elseif name == NotifyConsts.SkillLearn then
		self:ShowBaoJiaSkill();
	elseif name == NotifyConsts.SkillLvlUp then
		self:ShowBaoJiaSkill();
	elseif name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		self:ShowBaoJiaSkill();
	end
end
