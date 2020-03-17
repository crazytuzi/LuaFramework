--[[
玉佩：主面板
2015年1月28日10:40:38
haohu
]]

_G.UIMingYu = BaseSlotPanel:new("UIMingYu");

--技能列表
UIMingYu.skilllist = {}
--当前显示的等阶
UIMingYu.currentShowLevel = nil
--玉佩主技能名字
UIMingYu.skillName = nil
--清空二次确认提示
UIMingYu.confirmUID = 0;
UIMingYu.isShowClearConfirm = true;
UIMingYu.slotTotalNum = 4;--UI上格子总数
UIMingYu.list = {};--当前格子

function UIMingYu:Create()
	self:AddSWF("mingYuPanel.swf", true, nil);
	self:AddChild( UIMingYuSkillLvlUp, "mingYuSkillLvlUp");
	self:AddChild( UIMingYuBagShortcut, "mingYuBagShortcut");
end

function UIMingYu:OnLoaded( objSwf )
	self:GetChild("mingYuSkillLvlUp"):SetContainer(objSwf.childPanelSkill);
	self:GetChild("mingYuBagShortcut"):SetContainer(objSwf.childPanelBag);

	objSwf.loader.hitTestDisable = true;
	objSwf.siProficiencyLvl.maximum     = MingYuConsts.MaxLvlProficiency;
	objSwf.siProficiencyLvl.rollOver    = function() self:OnSiPrfcncyRollOver(); end
	objSwf.siProficiencyLvl.rollOut     = function() self:OnSiPrfcncyRollOut(); end
	objSwf.proficiencyTipsArea.rollOver = function() self:OnSiPrfcncyRollOver(); end
	objSwf.proficiencyTipsArea.rollOut  = function() self:OnSiPrfcncyRollOut(); end
	objSwf.listSkill.itemRollOver       = function(e) self:OnSkillRollOver(e); end
	objSwf.listSkill.itemRollOut        = function() self:OnSkillRollOut(); end
	objSwf.listSkill.itemClick          = function(e) self:OnSkillClick(e); end
	objSwf.btnPre.click                 = function() self:OnBtnPreClick(); end
	objSwf.btnNext.click                = function() self:OnBtnNextClick(); end
	objSwf.proLoader.loadComplete       = function() self:OnNumLoadComplete(); end
	objSwf.chkBoxUseModel.click         = function() self:OnChkBoxUseModelClick() end
	objSwf.siPro.tweenComplete          = function() self:OnSiProTweenComplete() end -- 熟练度进度条缓动完成
	objSwf.siBlessing.tweenComplete     = function() self:OnSiBlessingTweenComplete() end -- 祝福值进度条缓动完成

	objSwf.txtConsume.text       = StrConfig['mingYu010'];
	objSwf.txtMoneyName.text     = StrConfig['mingYu011'];
	objSwf.btnConsume.autoSize   = true;
	objSwf.btnConsume.rollOver = function(e) self:ConsumeTips(e)end;
	objSwf.btnConsume.rollOut = function() TipsManager:Hide() end;
	objSwf.txtMoney.rollOver = function() self:ConsumeMoneyTips()end;
	objSwf.txtMoney.rollOut = function() TipsManager:Hide() end;
	objSwf.desLoader._alpha      = 0
	objSwf.txtMoney.autoSize     = "left";
	objSwf.txtConsume.autoSize   = "left";
	objSwf.txtMoneyName.autoSize = "left";
	objSwf.tipsArea.rollOver = function() self:OnTipsAreaRollOver(); end
	objSwf.tipsArea.rollOut  = function() self:OnTipsAreaRollOut(); end
	
	objSwf.btnShuXingDan.click = function() self:OnBtnFeedSXDClick() end
	--属性丹tip
	objSwf.btnShuXingDan.rollOver = function() self:OnShuXingDanRollOver(); end
	objSwf.btnShuXingDan.rollOut  = function()  UIMountFeedTip:Hide();  end

	objSwf.btnZZD.click = function() self:OnBtnZZDClick() end
	objSwf.btnZZD.rollOver = function() self:OnZZDRollOver(); end
	objSwf.btnZZD.rollOut  = function()  UIMountFeedTip:Hide();  end

	objSwf.btnLvlUpB.click             = function(e) self:OnBtnLvlUpBClick(e); end
	objSwf.btnLvlUpB.rollOver		   = function() self:OnBtnLvlUpRollOver(); end
	objSwf.btnLvlUpB.rollOut		   = function() self:OnBtnLvlUpRollOut(); end
	objSwf.btnLvlUp.click              = function() self:OnBtnLvlUpClick(); end
	objSwf.btnLvlUp.rollOver           = function() self:OnBtnLvlUpRollOver(); end
	objSwf.btnLvlUp.rollOut            = function() self:OnBtnLvlUpRollOut(); end
	objSwf.btnAutoLvlUp.click          = function() self:OnBtnAutoLvlUpClick(); end
	objSwf.btnAutoLvlUp.rollOver       = function() self:OnBtnLvlUpRollOver(); end
	objSwf.btnAutoLvlUp.rollOut        = function() self:OnBtnLvlUpRollOut(); end
	objSwf.btnCancelAuto.click         = function() self:OnBtnCancelAutoClick(); end
	objSwf.btnConsume.rollOver         = function(e) self:OnBtnConsumeRollOver(e); end
	objSwf.btnConsume.rollOut          = function() self:OnBtnConsumeRollOut(); end
	objSwf.cbAutoBuy.select            = function(e) self:OnCBAutoBuySelect(e) end
	objSwf.proLoaderValue.loadComplete = function(e) self:OnNumValueLoadComplete(e); end
	objSwf.proLoaderMax.loadComplete   = function(e) self:OnNumMaxLoadComplete(e); end
	objSwf.btnShowDes.rollOver         = function() self:OnBtnShowDesRollOver() end
	objSwf.btnShowDes.rollOut          = function() self:OnBtnShowDesRollOut() end
	
	objSwf.btnVipLvUp.rollOver = function(e) self:OnBtnVipLvUpRollOver() end
	objSwf.btnVipLvUp.rollOut = function(e) self:OnBtnVipLvUpRollOut() end
	objSwf.btnVipLvUp.click = function(e) UIVip:Show() end	
	objSwf.btnVipLvUp._visible = false;

	self:HideIncrement()

--	objSwf.skillTitile._visible = false;

	--初始化格子
	for i=1,self.slotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end
	objSwf.btnGotWay.htmlLabel = StrConfig["common002"];
	objSwf.btnGotWay.click = function(e)
		local itemID = MingYuUtils:GetConsumeItem(MingYuModel:GetLevel());
		UIQuickBuyConfirm:Open(self,itemID);
	end
end

function UIMingYu:ConsumeTips(e)
	local itemInfo = e.target.data;
	local itemId = itemInfo.itemId;
	if not itemId then return; end
	local count = itemInfo.count;
	TipsManager:ShowItemTips( itemId, count );
end;

-- function UIMingYu:ConsumeTips()
-- 	local objSwf = self.objSwf;
-- 	if not objSwf then return end;
-- 	local level = MingYuModel:GetLevel()
-- 	local itemId, itemNum = MingYuUtils:GetConsumeItem(level)
-- 	TipsManager:ShowItemTips(itemId);
-- end;

function UIMingYu:ConsumeMoneyTips()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	TipsManager:ShowBtnTips(StrConfig['tips50'],TipsConsts.Dir_RightDown);
end;

function UIMingYu:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIMingYu:OnShow()
	self:UpdateShow(true)
	self:InitVip()
	self:InitData();
	--装备
	self:ShowEquip()
end

function UIMingYu:InitData()
	self.isShowClearConfirm = true;
end

function UIMingYu:InitVip()
	local objSwf = self.objSwf
	if not objSwf then return end
	-- VIP权限	
	-- objSwf.btnVipLvUp.disabled = VipController:GetShengbingLvUp() <= 0		
end

function UIMingYu:OnBtnVipLvUpRollOver()
	local attMap = self:GetAttMap()
	VipController:ShowAttrTips( attMap, UIVipAttrTips.sb ,VipConsts.TYPE_DIAMOND)
end

function UIMingYu:OnBtnVipLvUpRollOut()
	VipController:HideAttrTips()
end

function UIMingYu:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	MingYuController:SetAutoLevelUp(false);
	if self.confirmUID > 0 then
		UIConfirm:Close(self.confirmUID);
		self.confirmUID = 0;
	end
	if self.objSwf then
		self.objSwf.btnLvlUp:clearEffect();
		self.objSwf.btnAutoLvlUp:clearEffect();
	end
	self:RemoveAllSlotItem();
end

function UIMingYu:OnSiPrfcncyRollOver()
	local level = MingYuModel:GetLevel();
	local lvlPrfcncy = MingYuModel:GetLvlProficiency();
	local tipsStr;
	if lvlPrfcncy == MingYuConsts.MaxLvlProficiency then
		tipsStr = StrConfig['mingYu009'];
	elseif lvlPrfcncy < MingYuConsts.MaxLvlProficiency then
		local cfg = t_mingyu[level];
		if not cfg then return; end
		local attrList = AttrParseUtil:Parse(cfg.att1)
		local attrStrTable = {}
		for _, attr in pairs( attrList ) do
			local attrName = _G.enAttrTypeName[attr.type]
			table.push( attrStrTable, string.format( '<font color="#d5b772">%s</font>    <font color="#00ff00">+%s</font>', attrName, attr.val ) )
		end
		tipsStr = table.concat( attrStrTable, '\n' )
	end
	local skillName = self.skillName or StrConfig['mingYu028']
	tipsStr = string.format( StrConfig['mingYu002'], lvlPrfcncy, tipsStr, skillName );
	TipsManager:ShowBtnTips(tipsStr);
end

function UIMingYu:OnSiPrfcncyRollOut()
	TipsManager:Hide();
end

-- 技能tips
function UIMingYu:OnSkillRollOver(e)
	local skillInfo = e.item or e.target.data;
	if not skillInfo then return; end
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	local tipsInfo = { skillId = skillInfo.skillId, condition = true, get = skillInfo.lvl > 0 };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

function UIMingYu:OnSkillRollOut()
	TipsManager:Hide();
end

function UIMingYu:OnSkillClick(e)
	local skillInfo = e.item;
	UIMingYuSkillLvlUp:Open(skillInfo.skillId, skillInfo.lvl);
end

function UIMingYu:OnBtnPreClick()
	self:ShowMagicWeapon( self.currentShowLevel - 1 );
end

function UIMingYu:OnBtnNextClick()
	self:ShowMagicWeapon( self.currentShowLevel + 1 );
end

function UIMingYu:OnNumLoadComplete()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local numLoader = objSwf.proLoader;
	local bg = objSwf.posSign;
	numLoader._x = bg._x - numLoader._width * 0.5;
	numLoader._y = bg._y - numLoader._height * 0.5;
end

function UIMingYu:OnChkBoxUseModelClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	local currentShowLevel = self.currentShowLevel
	if not currentShowLevel then return end
	local useThisModel = objSwf.chkBoxUseModel.selected
	local currentLevel = MingYuModel:GetLevel()
	if currentLevel == currentShowLevel and useThisModel == false then
		-- objSwf.chkBoxUseModel.selected = true
		return
	end
	local modelLevel = useThisModel and currentShowLevel or currentLevel
	MingYuController:ReqUseModel( modelLevel )
end

function UIMingYu:OnSiProTweenComplete()
	--[[
	local objSwf = self.objSwf
	if not objSwf then return end
	local panelState = self:GetState()
	local proficiencyState = panelState == 1
	if proficiencyState then
		objSwf.shineEffect1:playEffect(2)
	end
	--]]
end

function UIMingYu:OnSiBlessingTweenComplete()
	--[[
	local objSwf = self.objSwf
	if not objSwf then return end
	local panelState = self:GetState()
	local lvlUpState = panelState == 2
	if lvlUpState then
		objSwf.shineEffect2:playEffect(2)
	end
	--]]
end

function UIMingYu:OnTipsAreaRollOver()
	local level = MingYuModel:GetLevel();
	local cfg = t_mingyu[level];
	if not cfg then return; end
	local blessing = MingYuModel:GetBlessing();
	local isWishclear = cfg.is_wishclear
	local tipStr = StrConfig["wuhun26"]
	if isWishclear then
		tipStr = StrConfig["wuhun27"]
	end

	TipsManager:ShowBtnTips( string.format(StrConfig["wuhun25"],blessing, tipStr));
end

function UIMingYu:OnTipsAreaRollOut()
	TipsManager:Hide();
end

function UIMingYu:OnBtnLvlUpBClick(e)
	if not UIMingYuBagShortcut:ToggleShow() then
		FloatManager:AddNormal( StrConfig['mingYu033'], e.target )
	end
end

function UIMingYu:OnBtnFeedSXDClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local shenbingcfg = t_mingyu[MingYuModel:GetLevel()];
	if not shenbingcfg then
		return;
	end
	
	if shenbingcfg.shenbingdan <= 0 then
		FloatManager:AddNormal( StrConfig["mount18"], objSwf.btnShuXingDan);
		return;
	end
	
	--属性丹上限
	local sXDCount = 0
	for k,cfg in pairs(t_mingyu) do
		if cfg.id == MingYuModel:GetLevel() then
			sXDCount = cfg.shenbingdan
			break
		end
	end
	
	--已达到上限
	if MingYuModel:GetPillNum() >= sXDCount then
		FloatManager:AddNormal( StrConfig["mount7"], objSwf.btnShuXingDan);
		return
	end
	
	--材料不足
	if MountUtil:GetJieJieItemNum(12) <= 0 then
		FloatManager:AddNormal( StrConfig["mount6"], objSwf.btnShuXingDan);
		return
	end
	
	MountController:FeedShuXingDan(12)
end

--属性丹tip
function UIMingYu:OnShuXingDanRollOver()
	UIMountFeedTip:OpenPanel(13);
end

UIMingYu.lastSendTime = 0;
function UIMingYu:OnBtnLvlUpClick()
	if GetCurTime() - self.lastSendTime < 200 then
		return;
	end
	self.lastSendTime = GetCurTime();
	
	local autoBuy = MingYuModel.autoBuy
	if not autoBuy and not MingYuController:CheckLvlUpItemEnough() then
		FloatManager:AddNormal( StrConfig['mingYu034'] )
		local itemID = MingYuUtils:GetConsumeItem(MingYuModel:GetLevel());
		UIQuickBuyConfirm:Open(self,itemID);
		return
	end
	if not MingYuController:CheckLvlUpMoneyEnough() then
		FloatManager:AddNormal( StrConfig['mingYu035'] )
		return
	end
	
	--清空二次确认提示
	if self.isShowClearConfirm == true then
		local level = MingYuModel:GetLevel();
		local cfg = t_mingyu[level];
		if cfg then
			local isWishclear = cfg.is_wishclear
			if isWishclear then
				local confirmFunc = function()
					MingYuController:SetAutoLevelUp(false);
					MingYuController:ReqMingYuWeaponLevelUp();
					self.isShowClearConfirm = false;
				end
				self.confirmUID = UIConfirm:Open( StrConfig["realm48"], confirmFunc );
				return;
			end
		end
	end

	MingYuController:SetAutoLevelUp(false);
	MingYuController:ReqMingYuWeaponLevelUp();
end

function UIMingYu:OnBtnAutoLvlUpClick()
	local autoBuy = MingYuModel.autoBuy
	if not autoBuy and not MingYuController:CheckLvlUpItemEnough() then
		FloatManager:AddNormal( StrConfig['mingYu034'] )
		local itemID = MingYuUtils:GetConsumeItem(MingYuModel:GetLevel());
		UIQuickBuyConfirm:Open(self,itemID);
		return
	end
	if not MingYuController:CheckLvlUpMoneyEnough() then
		FloatManager:AddNormal( StrConfig['mingYu035'] )
		return
	end
	
	--清空二次确认提示
	if self.isShowClearConfirm == true then
		local level = MingYuModel:GetLevel();
		local cfg = t_mingyu[level];
		if cfg then
			local isWishclear = cfg.is_wishclear
			if isWishclear then
				local confirmFunc = function()
					MingYuController:SetAutoLevelUp(true);
					MingYuController:ReqMingYuWeaponLevelUp();
					self.isShowClearConfirm = false;
				end
				self.confirmUID = UIConfirm:Open( StrConfig["realm48"], confirmFunc );
				return;
			end
		end
	end
	
	MingYuController:SetAutoLevelUp(true);
	MingYuController:ReqMingYuWeaponLevelUp();
end

function UIMingYu:OnBtnLvlUpRollOver()
	self:ShowNextLevel()
end

function UIMingYu:OnBtnLvlUpRollOut()
	self:ShowLastLevel()
end

local lastLevel
function UIMingYu:ShowNextLevel()
	local currentLevel = MingYuModel:GetLevel()
	local level = math.min( currentLevel + 1, MingYuConsts:GetMaxLevel() );
	lastLevel = self.currentShowLevel
	self:ShowMagicWeapon( level )
end

function UIMingYu:ShowLastLevel()
	self:ShowMagicWeapon( lastLevel )
end

function UIMingYu:OnBtnCancelAutoClick()
	MingYuController:SetAutoLevelUp(false);
end

function UIMingYu:OnBtnConsumeRollOver(e)
	local itemInfo = e.target.data;
	if not itemInfo then return end
	local itemId = itemInfo.itemId;
	if not itemId then return; end
	local count = itemInfo.count;
	TipsManager:ShowItemTips( itemId, count );
end

function UIMingYu:OnBtnConsumeRollOut()
	TipsManager:Hide();
end

function UIMingYu:OnCBAutoBuySelect(e)
	MingYuModel.autoBuy = e.selected;
end

function UIMingYu:OnNumValueLoadComplete(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	-- objSwf.proLoaderValue._x = objSwf.bar._x - objSwf.proLoaderValue.width - 5
	objSwf.proLoaderValue._x = objSwf.bar._x + objSwf.bar._width / 2 - objSwf.proLoaderValue._width / 2;
end

function UIMingYu:OnNumMaxLoadComplete(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.proLoaderMax._x = objSwf.bar._x + objSwf.bar._width
end

function UIMingYu:OnBtnShowDesRollOver()
	local objSwf = self.objSwf
	if not objSwf then return end
	Tween:To( objSwf.desLoader, 1, { _alpha = 100 } )
end

function UIMingYu:OnBtnShowDesRollOut()
	local objSwf = self.objSwf
	if not objSwf then return end
	Tween:To( objSwf.desLoader, 1, { _alpha = 0 } )
end

function UIMingYu:UpdateShow(noTween)
	self:ShowMagicWeapon();
	self:ShowMagicWeaponSkill();
	self:ShowMagicWeaponFight();
	self:ShowMagicWeaponAttr();
	self:ShowMagicWeaponAdvance(noTween);
	self:UpdatePanelMode();
	self:ShowBlessing(false, noTween);
	self:ShowConsume();
	self:ShowUseModelState()
	self:SwitchAutoLvlUpState( MingYuController.isAutoLvlUp );
	self:ShowQingLingInfo();
end

-- 显示等级为level的玉佩,如不传,则显示当前等级的玉佩
-- showActive: 是否播放激活动作(开启新等阶时候需要显示)
function UIMingYu:ShowMagicWeapon( level, showActive )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local currentLevel = MingYuModel:GetLevel();
	if not level then
		level = currentLevel --self.currentShowLevel or ;
	end
	local cfg = t_mingyu[level];
	if not cfg then return; end
	objSwf.nameLoader.source = ResUtil:GetMingYuNameImg(level);
	objSwf.lvlLoader.source = ResUtil:GetMingYuLvlImg(level);
	self:Show3DWeapon(level, showActive);
--	self:ShowWeaponDes(level)
	objSwf.btnPre.disabled = level <= 1;
	objSwf.btnNext.disabled = (level == MingYuConsts:GetMaxLevel()) or (level >= currentLevel + 1);
	local isMaxLvl = currentLevel >= MingYuConsts:GetMaxLevel();
	objSwf.maxLvlMc._visible = isMaxLvl;
	if level == currentLevel + 1 then
		self:ShowIncrement()
		objSwf.notGainMC._visible = true
	else
		self:HideIncrement()
		objSwf.notGainMC._visible = false
	end
	self.currentShowLevel = level;
	self:ShowUseModelState()
end

function UIMingYu:ShowWeaponDes( level )
	local objSwf = self.objSwf
	if not objSwf then return end
	local url = ResUtil:GetMingYuDesImg(level)
	if objSwf.desLoader.source ~= url then
		objSwf.desLoader.source = url
	end
end

-- 显示等级为level的3d玉佩模型
-- showActive: 是否播放激活动作
local viewPort;
function UIMingYu:Show3DWeapon( level, showActive )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not level then
		level = MingYuModel:GetLevel();
	end
	local cfg = t_mingyu[level];
	if not cfg then
		Error("Cannot find config of shenbing. level:"..level);
		return;
	end
	local modelCfg = t_mingyumodel[cfg.model];
	if not modelCfg then
		Error("Cannot find config of shenbingModel. id:"..cfg.model);
		return;
	end
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1278, 689); end
		self.objUIDraw = UISceneDraw:new( "MingYuUI", objSwf.loader, viewPort );
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

function UIMingYu:ShowMagicWeaponSkill()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = SkillUtil:GetPassiveSkillListShowDzz( SkillConsts.ShowType_MingYu );
	local listSkill = objSwf.listSkill;
	listSkill.dataProvider:cleanUp();
	for i, vo in ipairs(list) do
		local listVO = MingYuUtils:GetSkillListVO(vo.skillId, vo.lvl);
		-- if self.skillName == nil and i == #list then -- 取一次玉佩主技能名称并缓存,用于tips显示
		if self.skillName == nil and i == 1 then -- 取一次玉佩主技能名称并缓存,用于tips显示
			self.skillName = listVO.name
		end
		table.push( self.skilllist, listVO );
		listSkill.dataProvider:push( UIData.encode(listVO) );
	end
	listSkill:invalidateData();
end

function UIMingYu:ShowMagicWeaponFight()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = MingYuModel:GetLevel();
	local lvlPrfcncy = MingYuModel:GetLvlProficiency();
	local fight = MingYuUtils:GetFight(level,lvlPrfcncy);
	objSwf.numLoaderFight.num = fight;
end

function UIMingYu:GetVIPFightAdd(level,lvlPrfcncy)
	if not level then
		level = MingYuModel:GetLevel();
	end
	if not lvlPrfcncy then
		lvlPrfcncy = MingYuModel:GetLvlProficiency();
	end
	local attrMap = MingYuUtils:GetMagicWeaponAttrMap(level, lvlPrfcncy);
	if not attrMap then return 0; end
	local vipUPRate = VipController:GetShengbingLvUp()/100
	if vipUPRate <= 0 then
		vipUPRate = VipController:GetShengbingLvUp(VipConsts:GetMaxVipLevel())/100
	end
	local attrlist = {};
	for _,attrName in pairs(MingYuConsts.Attrs) do
		local vo = {};
		vo.type = AttrParseUtil.AttMap[attrName];
		vo.val = attrMap[attrName]*vipUPRate;
		table.push(attrlist,vo);
	end
--	return EquipUtil:GetFight(attrlist);
	return PublicUtil:GetFigthValue(attrlist);
end

function UIMingYu:GetAttMap()
	local level = MingYuModel:GetLevel();
	local lvlPrfcncy = MingYuModel:GetLvlProficiency();
	local attrMap = MingYuUtils:GetMagicWeaponAttrMap(level, lvlPrfcncy);
	if not attrMap then return nil end
	local attrTotal = {};
	for _, attrName in pairs(MingYuConsts.Attrs) do
		table.push(attrTotal,{proKey = attrName, proValue = attrMap[attrName]})
	end
	return attrTotal
end

function UIMingYu:ShowMagicWeaponAttr()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = MingYuModel:GetLevel();
	local lvlPrfcncy = MingYuModel:GetLvlProficiency();
	local attrMap = MingYuUtils:GetMagicWeaponAttrMap(level, lvlPrfcncy);
	if not attrMap then return; end
	local attrTotal = {};
	--基础属性
	for _, attrName in pairs(MingYuConsts.Attrs) do
		attrTotal[attrName] = attrMap[attrName];
		--百分比加成,VIP加成
		local attrType = AttrParseUtil.AttMap[attrName];
		local addP = 0;
		if Attr_AttrPMap[attrType] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[attrType]];
		end
--		local vipUPRate = VipController:GetShengbingLvUp()/100
		local vipUPRate = 0
		attrTotal[attrName] = attrTotal[attrName] * (1+addP+vipUPRate);
	end
	objSwf.txtAtt.htmlText      = string.format( PublicStyle:GetAttrNameStr(StrConfig['mingYu004']), PublicStyle:GetAttrValStr(toint( attrTotal["att"], 0.5 )) );
	objSwf.txtDef.htmlText      = string.format( PublicStyle:GetAttrNameStr(StrConfig['mingYu005']), PublicStyle:GetAttrValStr(toint( attrTotal["def"], 0.5 )) );
--	objSwf.txtCri.htmlText      = string.format( PublicStyle:GetAttrNameStr(StrConfig['mingYu006']), PublicStyle:GetAttrValStr(toint( attrTotal["cri"], 0.5 )) );
	objSwf.txtHp.htmlText       = string.format( PublicStyle:GetAttrNameStr(StrConfig['mingYu007']), PublicStyle:GetAttrValStr(toint( attrTotal["hp"], 0.5 )) );
--	objSwf.txtCrivalue.htmlText = string.format( PublicStyle:GetAttrNameStr(StrConfig['mingYu008']), PublicStyle:GetAttrValStr(getAtrrShowVal( enAttrType.eaBaoJiHurt, attrTotal["crivalue"] )) );
	objSwf.txtHit.htmlText       = string.format( PublicStyle:GetAttrNameStr(StrConfig['mingYuplus009']), PublicStyle:GetAttrValStr(toint( attrTotal["hit"], 0.5 )) );
	objSwf.txtDodge.htmlText       = string.format( PublicStyle:GetAttrNameStr(StrConfig['mingYuplus010']), PublicStyle:GetAttrValStr(toint( attrTotal["dodge"], 0.5 )) );
	objSwf.txtHpx.htmlText = string.format( PublicStyle:GetAttrNameStr(StrConfig['mingYuplus011']), PublicStyle:GetAttrValStr(getAtrrShowVal( enAttrType.eaHpX, attrTotal["hpx"] )) );
end

function UIMingYu:ShowMagicWeaponAdvance(noTween)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local lvlPrfcncy = MingYuModel:GetLvlProficiency();
	local oldLvlPrfcncy = objSwf.siProficiencyLvl.value
	local flipOver = math.max( 0, lvlPrfcncy - oldLvlPrfcncy );
	objSwf.siProficiencyLvl.value = lvlPrfcncy;
	local lvl = MingYuModel:GetLevel();
	local ceilingPrfcncy = MingYuUtils:GetProficiencyCeiling(lvl, lvlPrfcncy);
	if not ceilingPrfcncy then return end
	local prfcncy = MingYuModel:GetProficiency() or ceilingPrfcncy;
	local proStr = string.format( "%sp%s", prfcncy, ceilingPrfcncy );
	objSwf.proLoader:drawStr( proStr );
	if noTween then
		objSwf.siPro:setProgress( prfcncy, ceilingPrfcncy )
	else
		objSwf.siPro:tweenProgress( prfcncy, ceilingPrfcncy, flipOver )
	end
end

function UIMingYu:ShowIncrement()
	local level = MingYuModel:GetLevel()
	if level >= MingYuConsts:GetMaxLevel() then return end
	local nextLevel = level + 1
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.incrementFight._visible    = true;
	objSwf.incrementAtt._visible      = true;
	objSwf.incrementDef._visible      = true;
--	objSwf.incrementCri._visible      = true;
	objSwf.incrementHp._visible       = true;
--	objSwf.incrementCrivalue._visible = true;
	objSwf.incrementHit._visible       = true;
	objSwf.incrementDodge._visible = true;
	objSwf.incrementHpx._visible = true;
--	objSwf.tfVIPFightAdd._visible	  = true;
	objSwf.tfVIPFightAdd._visible	  = false;
	local maxFight = MingYuUtils:GetFight( level, MingYuConsts.MaxLvlProficiency ) or 0;
	local nextFight = MingYuUtils:GetFight( nextLevel ) or 0;
	objSwf.incrementFight.label = nextFight - maxFight;
	local incrementMap = MingYuUtils:GetAttrIncrementMap(level);
	if not incrementMap then return; end
	objSwf.incrementAtt.htmlLabel      = PublicStyle:GetAttrValStr(toint(incrementMap.att,0.5));
	objSwf.incrementDef.htmlLabel      = PublicStyle:GetAttrValStr(toint(incrementMap.def,0.5));
--	objSwf.incrementCri.htmlLabel      = PublicStyle:GetAttrValStr(toint(incrementMap.cri,0.5));
	objSwf.incrementHp.htmlLabel       = PublicStyle:GetAttrValStr(toint(incrementMap.hp,0.5));
--	objSwf.incrementCrivalue.htmlLabel = PublicStyle:GetAttrValStr(getAtrrShowVal( enAttrType.eaBaoJiHurt, incrementMap.crivalue ));
	objSwf.incrementHit.htmlLabel       = PublicStyle:GetAttrValStr(toint(incrementMap.hit,0.5));
	objSwf.incrementDodge.htmlLabel       = PublicStyle:GetAttrValStr(toint(incrementMap.dodge,0.5));
	objSwf.incrementHpx.htmlLabel = PublicStyle:GetAttrValStr(getAtrrShowVal( enAttrType.eaHpX, incrementMap.hpx ));
	local maxVIPFight = self:GetVIPFightAdd(level, MingYuConsts.MaxLvlProficiency );
	local nextVIPFight = self:GetVIPFightAdd(nextLevel,0);
	objSwf.tfVIPFightAdd.htmlText = string.format(StrConfig['vip100'],nextVIPFight-maxVIPFight);
end

function UIMingYu:HideIncrement()
	local objSwf = self.objSwf
	if not objSwf then return end
	if self.isAutoLvlUp then return end
	objSwf.incrementFight._visible    = false
	objSwf.incrementAtt._visible      = false
	objSwf.incrementDef._visible      = false
--	objSwf.incrementCri._visible      = false
	objSwf.incrementHp._visible       = false
--	objSwf.incrementCrivalue._visible = false
	objSwf.incrementHit._visible       = false;
	objSwf.incrementDodge._visible = false;
	objSwf.incrementHpx._visible = false;
	objSwf.tfVIPFightAdd._visible     = false
end

-- 更新面板模式: (1)熟练度积攒模式 / (2)升阶模式
function UIMingYu:UpdatePanelMode()
	local objSwf = self.objSwf
	if not objSwf then return end
	local panelState = self:GetState()
	local proficiencyState = panelState == 1
	local lvlUpState = panelState == 2
	local level = MingYuModel:GetLevel()
	local cfg = t_lingqi[level];
	if not cfg then return; end
	-- 玉佩熟练度等级不满，或者满阶时，显示熟练度模式
	objSwf.titleAdvance._visible     = proficiencyState
	objSwf.siProficiencyLvl._visible = proficiencyState
	objSwf.proficiencyTipsArea._visible = proficiencyState
	objSwf.posSign._visible          = proficiencyState
	objSwf.proLoader._visible        = proficiencyState
	objSwf.siPro._visible            = proficiencyState
	objSwf.btnLvlUpB._visible        = proficiencyState and ( level ~= MingYuConsts:GetMaxLevel() )
	-- 玉佩熟练度满级，且玉佩非满阶时，显示升阶模式
	objSwf.titleLvlUp._visible     = lvlUpState
	objSwf.btnLvlUp._visible       = lvlUpState
	objSwf.btnAutoLvlUp._visible   = lvlUpState
	objSwf.cbAutoBuy._visible      = lvlUpState
--	objSwf.cbAutoBuy._visible      = false
	objSwf.btnGotWay._visible	   = lvlUpState
	objSwf.tfcleardata._visible    = lvlUpState and cfg.is_wishclear
	objSwf.littleTipTxt._visible = lvlUpState and not cfg.is_wishclear
	objSwf.txtConsume._visible     = lvlUpState
	objSwf.btnConsume._visible     = lvlUpState
--	objSwf.txtMoneyName._visible   = lvlUpState
--	objSwf.txtMoney._visible       = lvlUpState
	objSwf.txtMoneyName._visible   = false
	objSwf.txtMoney._visible       = false
	objSwf.txtConsumeNum._visible = lvlUpState;
--	objSwf.proLoaderValue._visible = lvlUpState
--	objSwf.proLoaderMax._visible   = lvlUpState
	objSwf.proLoaderValue._visible = false
	objSwf.proLoaderMax._visible   = false
	objSwf.bar._visible            = false--lvlUpState
	objSwf.tipsArea._visible       = lvlUpState
	objSwf.siBlessing._visible     = lvlUpState
	self:UpdateBtnEffect()
end

function UIMingYu:UpdateBtnEffect()
	local objSwf = self.objSwf
	if not objSwf then return end
	local panelState = self:GetState()
	local lvlUpState = panelState == 2
	local lvlUpConditionEnough = MingYuController:CheckLvlUpItemEnough() and MingYuController:CheckLvlUpMoneyEnough()
	if lvlUpState and lvlUpConditionEnough then
		objSwf.btnLvlUp:showEffect(ResUtil:GetButtonEffect10());
		objSwf.btnAutoLvlUp:showEffect(ResUtil:GetButtonEffect10());
	else
		objSwf.btnLvlUp:clearEffect();
		objSwf.btnAutoLvlUp:clearEffect();
	end
	objSwf.btnLvlUpEff._visible = false
	objSwf.btnAutoEff._visible  = false
	--	objSwf.btnLvlUpEff._visible = lvlUpState and lvlUpConditionEnough
	--	objSwf.btnAutoEff._visible  = lvlUpState and lvlUpConditionEnough
end

-- (1)熟练度积攒状态 / (2)升阶状态
function UIMingYu:GetState()
	--[[local level = MingYuModel:GetLevel()
	if level == MingYuConsts:GetMaxLevel() then
		return 1
	else
		local lvlProficiency = MingYuModel:GetLvlProficiency()
		if lvlProficiency == MingYuConsts.MaxLvlProficiency then
			return 2
		else
			return 1
		end
	end]]
	return 2;
end

local lastMYBlessing;
function UIMingYu:ShowBlessing(showGain, noTween)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local blessing = MingYuModel:GetBlessing();
	local level = MingYuModel:GetLevel();
	local cfg = t_mingyu[level];
	if not cfg then return; end
	local maxBlessing = cfg.wish_max;
	objSwf.proLoaderValue.num = blessing
	-- objSwf.proLoaderMax.num   = maxBlessing
	objSwf.txtProLoader.text = string.format(StrConfig["mingYu060"], blessing, maxBlessing);
	if noTween then
		objSwf.siBlessing:setProgress( blessing, maxBlessing );
	else
		objSwf.siBlessing:tweenProgress( blessing, maxBlessing, 0 );
	end
	if showGain then
		if lastMYBlessing then
			local blessingGain = blessing - lastMYBlessing;
			if blessingGain > 0 then
				FloatManager:AddNormal( string.format(StrConfig['wuhun38'], blessingGain ), objSwf.tipsArea );
			end
		end
	end
	lastMYBlessing = blessing;
end

function UIMingYu:ShowConsume()
	self:ShowConsumeItem();
	self:ShowConsumeMoney();
end

function UIMingYu:ShowConsumeItem()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = MingYuModel:GetLevel()
	local itemId, itemNum, isEnough = MingYuUtils:GetConsumeItem(level)
	local itemCfg = t_item[itemId];
	local itemName = itemCfg and itemCfg.name or "something magic";
	objSwf.btnConsume.data = {itemId = itemId, count = itemNum};
	local labelItemColor = isEnough and "#00FF00" or "#FF0000";
	objSwf.btnConsume.htmlLabel = string.format( StrConfig['mingYu012'], labelItemColor, itemName, itemNum );
	local hasNum = BagModel:GetItemNumInBag(itemId);
	objSwf.txtConsumeNum.text = string.format(StrConfig["mingYu059"], hasNum);
end

-- function UIMingYu:ShowConsumeItem()
-- 	local objSwf = self.objSwf;
-- 	if not objSwf then return; end
-- 	local level = MingYuModel:GetLevel()
-- 	local itemId, itemNum = MingYuUtils:GetConsumeItem(level)
-- 	local itemCfg = t_item[itemId];
-- 	local itemName = itemCfg and itemCfg.name or "something magic";
-- 	objSwf.btnConsume.data = {itemId = itemId, count = itemNum};
-- 	local labelItemColor = BagModel:GetItemNumInBag( itemId ) >= itemNum and "#2fe00d" or "#cc0000";
-- 	objSwf.btnConsume.htmlLabel = string.format( StrConfig['mingYu012'], labelItemColor, itemName, itemNum );
-- end

function UIMingYu:ShowConsumeMoney()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = MingYuModel:GetLevel()
	local moneyConsume = MingYuUtils:GetConsumeMoney(level)
	local playerInfo = MainPlayerModel.humanDetailInfo;
	local playerMoney = playerInfo.eaBindGold + playerInfo.eaUnBindGold;
	local moneyEnough = playerMoney >= moneyConsume;
	local labelMoneyColor = moneyEnough and "#2fe00d" or "#cc0000";
	objSwf.txtMoney.htmlLabel = string.format( "<u><font color='%s'>%s</font></u>", labelMoneyColor, moneyConsume );
	objSwf.cbAutoBuy.selected = MingYuModel.autoBuy;
end

function UIMingYu:ShowUseModelState()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.chkBoxUseModel.selected = MingYuModel:GetModelLevel() == self.currentShowLevel
	objSwf.chkBoxUseModel.disabled = self.currentShowLevel > MingYuModel:GetLevel()
end

function UIMingYu:SwitchAutoLvlUpState(isAutoLvlUp)
	local objSwf = self.objSwf
	if not objSwf then return end
	self.isAutoLvlUp = isAutoLvlUp
	objSwf.btnCancelAuto._visible = isAutoLvlUp
	if isAutoLvlUp then
		self:ShowIncrement()
	else
		self:HideIncrement()
	end
end

function UIMingYu:ShowQingLingInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfcleardata.htmlText = "";
	local level = MingYuModel:GetLevel();
	local cfg = t_mingyu[level];
	if not cfg then return; end
	if cfg.is_wishclear == true then
		objSwf.tfcleardata.htmlText = StrConfig["realm45"];
	end
end

---------------------------以下是装备处理--------------------------------------
--显示装备
function UIMingYu:ShowEquip()
	local objSwf = self:GetSWF("UIMingYu");
	if not objSwf then return; end
	self.list = BagUtil:GetBagItemList(BagConsts.BagType_MingYu,BagConsts.ShowType_All);
	objSwf.list.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.list) do
		objSwf.list.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.list:invalidateData();
end

--获取指定位置的Item,飞图标用
function UIMingYu:GetItemAtPos(pos)
	if not self.isFullShow then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local uiSlot = objSwf.list:getRendererAt(pos);
	return uiSlot;
end

--添加Item
function UIMingYu:DoAddItem(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_MingYu);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end;
	local objSwf = self.objSwf
	if not objSwf then return; end
	local bagSlotVO = self.list[pos+1];
	bagSlotVO.hasItem = true;
	bagSlotVO.id = item:GetId();
	bagSlotVO.tid = item:GetTid();
	bagSlotVO.count = item:GetCount();
	bagSlotVO.bindState = item:GetBindState();
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

--移除Item
function UIMingYu:DoRemoveItem(pos)
	local objSwf = self.objSwf;
	if not objSwf then return; end;
	local bagSlotVO = self.list[pos+1];
	bagSlotVO.hasItem = false;
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

--更新Item
function UIMingYu:DoUpdateItem(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_MingYu);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagSlotVO = self.list[pos+1];
	bagSlotVO.id = item:GetId();
	bagSlotVO.tid = item:GetTid();
	bagSlotVO.count = item:GetCount();
	bagSlotVO.bindState = item:GetBindState();
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

function UIMingYu:OnItemRollOver(item)
	local data = item:GetData();
	if not data.hasItem then
		TipsManager:ShowBtnTips(BagConsts:GetMingYuEquipNameByPos(data.pos));
		return;
	end
	TipsManager:ShowBagTips(BagConsts.BagType_MingYu,data.pos);
end

function UIMingYu:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIMingYu:OnItemDragBegin(item)
	TipsManager:Hide();
end

function UIMingYu:OnItemDragIn(fromData,toData)
	--来自背包的
	if fromData.bagType == BagConsts.BagType_Bag then
		--判断是否是装备
		if BagUtil:GetItemShowType(fromData.tid) ~= BagConsts.ShowType_Equip then
			return;
		end
		--判断装备位是否相同
		if BagUtil:GetEquipType(fromData.tid) ~= BagUtil:GetEquipAtBagPos(BagConsts.BagType_MingYu,toData.pos) then
			return;
		end
		--判断是否可穿戴
		if BagUtil:GetEquipCanUse(fromData.tid) < 0 then
			return;
		end
		BagController:SwapItem(fromData.bagType,fromData.pos,toData.bagType,toData.pos);
		return;
	end
end

--左键菜单
function UIMingYu:OnItemClick(item)
	TipsManager:Hide();

	if UIBagQuickEquitView:IsShow() then
		UIBagQuickEquitView:Hide();
		return;
	end

	local itemData = item:GetData();
	if not itemData.opened then
		return;
	end
	if not itemData.hasItem then
		UIBagQuickEquitView:Open(item.mc, BagConsts.BagType_MingYu, itemData.pos+BagConsts.Equip_MY_0, itemData.pos+BagConsts.Equip_MY_0);
		return;
	end
	if _sys:isKeyDown(_System.KeyCtrl) then
		ChatQuickSend:SendItem(BagConsts.BagType_MingYu,itemData.pos);
		return;
	end

	UIBagQuickEquitView:Open(item.mc, BagConsts.BagType_MingYu, itemData.pos+BagConsts.Equip_MY_0, itemData.pos);
end

--双击卸载
function UIMingYu:OnItemDoubleClick(item)
	TipsManager:Hide();
	local data = item:GetData();
	if not data.hasItem  then
		return;
	end
	BagController:UnEquipItem(BagConsts.BagType_MingYu,data.pos);
end

--右键卸载
function UIMingYu:OnItemRClick(item)
	TipsManager:Hide();
	local data = item:GetData();
	if not data.hasItem then
		return;
	end
	BagController:UnEquipItem(BagConsts.BagType_MingYu,data.pos);
end
---------------------------以上是装备处理--------------------------------------
function UIMingYu:OnBtnZZDClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local shenbingcfg = t_mingyu[MingYuModel:GetLevel()];
	if not shenbingcfg then
		return;
	end

	if shenbingcfg.zizhi_dan <= 0 then
		FloatManager:AddNormal( string.format(StrConfig["zizhi1"], ZiZhiUtil:GetOpenLvByCFG(t_mingyu)), objSwf.btnZZD);
		return;
	end

	--资质丹上限
	local zzdCount = 0
	for k,cfg in pairs(t_mingyu) do
		if cfg.id == MingYuModel:GetLevel() then
			zzdCount = cfg.zizhi_dan
			break
		end
	end

	--已达到上限
	if ZiZhiModel:GetZZNum(2) >= zzdCount then
		FloatManager:AddNormal( StrConfig["mount7"], objSwf.btnZZD);
		return
	end

	--材料不足
	if ZiZhiUtil:GetZZItemNum(2) <= 0 then
		FloatManager:AddNormal( StrConfig["mount6"], objSwf.btnZZD);
		return
	end

	ZiZhiController:FeedZZDan(2)
end

--属性丹tip
function UIMingYu:OnZZDRollOver()
	UIMountFeedTip:OpenPanel(103);
end
---------------------------以上是资质丹--------------------------------------


---------------------------消息处理---------------------------------
--监听消息列表
function UIMingYu:ListNotificationInterests()
	return {
		NotifyConsts.MingYuLevelUp,
		NotifyConsts.MingYuModelChange,
		NotifyConsts.MingYuPrfcncyLevelUp,
		NotifyConsts.MingYuProficiency,
		NotifyConsts.MingYuBlessing,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.SkillLearn,
		NotifyConsts.SkillLvlUp,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.VipPeriod,
		NotifyConsts.MingYuSXDChanged,
		NotifyConsts.MingYuZZChanged,
	};
end

--处理消息
function UIMingYu:HandleNotification(name, body)
	if name == NotifyConsts.MingYuModelChange then
		self:ShowUseModelState()
	elseif name == NotifyConsts.MingYuLevelUp then
		self:OnWeaponLvlUp()
		self:ShowUseModelState()
	elseif name == NotifyConsts.MingYuPrfcncyLevelUp then
		self:ShowMagicWeaponAttr()
		self:ShowMagicWeaponFight()
		self:UpdatePanelMode()
		self:ShowMagicWeaponAdvance()
		SoundManager:PlaySfx( MingYuConsts.SfxProficiencyLevelUp )
	elseif name == NotifyConsts.MingYuProficiency then
		self:ShowMagicWeaponAdvance()
		SoundManager:PlaySfx( MingYuConsts.SfxProficiencyAdd )
	elseif name == NotifyConsts.SkillLearn then
		self:ShowMagicWeaponSkill()
		self:ShowMagicWeaponAttr()
		self:ShowMagicWeaponFight()
	elseif name == NotifyConsts.SkillLvlUp then
		self:ShowMagicWeaponSkill()
		self:ShowMagicWeaponAttr()
		self:ShowMagicWeaponFight()
	elseif name == NotifyConsts.MingYuBlessing then
		self:ShowBlessing(true);
		SoundManager:PlaySfx( MingYuConsts.SfxLevelUp )
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaBindGold or body.type == enAttrType.eaUnBindGold then
			self:ShowConsumeMoney();
			self:UpdateBtnEffect()
		elseif body.type == enAttrType.eaVIPLevel then
			self:InitVip()
			self:ShowMagicWeaponAttr()
			self:ShowMagicWeaponFight()
		end
	elseif name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		if body.type == BagConsts.BagType_Bag then
			self:ShowConsumeItem();
			self:ShowMagicWeaponSkill();
			self:UpdateBtnEffect()
		end
		if name == NotifyConsts.BagAdd then
			if body.type ~= BagConsts.BagType_MingYu then return; end
			self:DoAddItem(body.pos);
			self:UpdateShow()
		elseif name == NotifyConsts.BagRemove then
			if body.type ~= BagConsts.BagType_MingYu then return; end
			self:DoRemoveItem(body.pos);
			self:UpdateShow()
		elseif name == NotifyConsts.BagUpdate then
			if body.type ~= BagConsts.BagType_MingYu then return; end
			self:DoUpdateItem(body.pos);
			self:UpdateShow()
		end

	elseif name == NotifyConsts.VipPeriod then
		self:InitVip()
		self:ShowMagicWeaponAttr()
		self:ShowMagicWeaponFight()
	elseif name == NotifyConsts.MingYuSXDChanged then
		self:ShowMagicWeaponAttr()
		self:ShowMagicWeaponFight()
	end
end

function UIMingYu:OnWeaponLvlUp()
	self:ShowMagicWeaponAdvance(true)
	self:UpdatePanelMode()
	self:ShowMagicWeapon( nil ,true )
	self:ShowMagicWeaponSkill()
	self:ShowMagicWeaponFight()
	self:ShowMagicWeaponAttr()
	self:UpdatePanelMode()
	self:ShowConsume()
	MingYuController:SetAutoLevelUp(false);
end