--[[
法宝：主面板
2015年1月28日10:40:38
haohu
]]

_G.UILingQi = BaseSlotPanel:new("UILingQi");

--技能列表
UILingQi.skilllist = {}
--当前显示的等阶
UILingQi.currentShowLevel = nil
--法宝主技能名字
UILingQi.skillName = nil
--清空二次确认提示
UILingQi.confirmUID = 0;
UILingQi.isShowClearConfirm = true;
UILingQi.slotTotalNum = 4;--UI上格子总数
UILingQi.list = {};--当前格子

function UILingQi:Create()
	self:AddSWF("lingQiPanel.swf", true, nil);
	self:AddChild(UILingQiSkillLvlUp, "lingQiSkillLvlUp");
	self:AddChild(UILingQiBagShortcut, "lingQiBagShortcut");
end

function UILingQi:OnLoaded(objSwf)
	self:GetChild("lingQiSkillLvlUp"):SetContainer(objSwf.childPanelSkill);
	self:GetChild("lingQiBagShortcut"):SetContainer(objSwf.childPanelBag);

	objSwf.loader.hitTestDisable = true;
	objSwf.siProficiencyLvl.maximum = LingQiConsts.MaxLvlProficiency;
	objSwf.siProficiencyLvl.rollOver = function() self:OnSiPrfcncyRollOver(); end
	objSwf.siProficiencyLvl.rollOut = function() self:OnSiPrfcncyRollOut(); end
	objSwf.proficiencyTipsArea.rollOver = function() self:OnSiPrfcncyRollOver(); end
	objSwf.proficiencyTipsArea.rollOut = function() self:OnSiPrfcncyRollOut(); end
	objSwf.listSkill.itemRollOver = function(e) self:OnSkillRollOver(e); end
	objSwf.listSkill.itemRollOut = function() self:OnSkillRollOut(); end
	objSwf.listSkill.itemClick = function(e) self:OnSkillClick(e); end
	objSwf.btnPre.click = function() self:OnBtnPreClick(); end
	objSwf.btnNext.click = function() self:OnBtnNextClick(); end
	objSwf.proLoader.loadComplete = function() self:OnNumLoadComplete(); end
	objSwf.chkBoxUseModel.click = function() self:OnChkBoxUseModelClick() end
	objSwf.siPro.tweenComplete = function() self:OnSiProTweenComplete() end -- 熟练度进度条缓动完成
	objSwf.siBlessing.tweenComplete = function() self:OnSiBlessingTweenComplete() end -- 祝福值进度条缓动完成

	objSwf.txtConsume.text = StrConfig['lingQi010'];
	objSwf.txtMoneyName.text = StrConfig['lingQi011'];
	objSwf.btnConsume.autoSize = true;
	objSwf.btnConsume.rollOver = function(e) self:ConsumeTips(e) end;
	objSwf.btnConsume.rollOut = function() TipsManager:Hide() end;
	objSwf.txtMoney.rollOver = function() self:ConsumeMoneyTips() end;
	objSwf.txtMoney.rollOut = function() TipsManager:Hide() end;
	objSwf.desLoader._alpha = 0
	objSwf.txtMoney.autoSize = "left";
	objSwf.txtConsume.autoSize = "left";
	objSwf.txtMoneyName.autoSize = "left";
	objSwf.tipsArea.rollOver = function() self:OnTipsAreaRollOver(); end
	objSwf.tipsArea.rollOut = function() self:OnTipsAreaRollOut(); end

	objSwf.btnShuXingDan.click = function() self:OnBtnFeedSXDClick() end
	--属性丹tip
	objSwf.btnShuXingDan.rollOver = function() self:OnShuXingDanRollOver(); end
	objSwf.btnShuXingDan.rollOut = function() UIMountFeedTip:Hide(); end

	objSwf.btnZZD.click = function() self:OnBtnZZDClick() end
	objSwf.btnZZD.rollOver = function() self:OnZZDRollOver(); end
	objSwf.btnZZD.rollOut  = function()  UIMountFeedTip:Hide();  end

	objSwf.btnLvlUpB.click = function(e) self:OnBtnLvlUpBClick(e); end
	objSwf.btnLvlUpB.rollOver = function() self:OnBtnLvlUpRollOver(); end
	objSwf.btnLvlUpB.rollOut = function() self:OnBtnLvlUpRollOut(); end
	objSwf.btnLvlUp.click = function() self:OnBtnLvlUpClick(); end
	objSwf.btnLvlUp.rollOver = function() self:OnBtnLvlUpRollOver(); end
	objSwf.btnLvlUp.rollOut = function() self:OnBtnLvlUpRollOut(); end
	objSwf.btnAutoLvlUp.click = function() self:OnBtnAutoLvlUpClick(); end
	objSwf.btnAutoLvlUp.rollOver = function() self:OnBtnLvlUpRollOver(); end
	objSwf.btnAutoLvlUp.rollOut = function() self:OnBtnLvlUpRollOut(); end
	objSwf.btnCancelAuto.click = function() self:OnBtnCancelAutoClick(); end
	objSwf.btnConsume.rollOver = function(e) self:OnBtnConsumeRollOver(e); end
	objSwf.btnConsume.rollOut = function() self:OnBtnConsumeRollOut(); end
	objSwf.cbAutoBuy.select = function(e) self:OnCBAutoBuySelect(e) end
	objSwf.proLoaderValue.loadComplete = function(e) self:OnNumValueLoadComplete(e); end
	objSwf.proLoaderMax.loadComplete = function(e) self:OnNumMaxLoadComplete(e); end
	objSwf.btnShowDes.rollOver = function() self:OnBtnShowDesRollOver() end
	objSwf.btnShowDes.rollOut = function() self:OnBtnShowDesRollOut() end

	objSwf.btnVipLvUp.rollOver = function(e) self:OnBtnVipLvUpRollOver() end
	objSwf.btnVipLvUp.rollOut = function(e) self:OnBtnVipLvUpRollOut() end
	objSwf.btnVipLvUp.click = function(e) UIVip:Show() end
--	objSwf.btnVipLvUp._visible = false;

	self:HideIncrement()
	--初始化格子
	for i=1,self.slotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end

	--主动技能
	objSwf.skill1.rollOver = function(e) self:OnSkillItemOver(); end
	objSwf.skill1.rollOut  = function() self:OnSkillItemOut(); end
	objSwf.btnGotWay.htmlLabel = StrConfig["common002"];
	objSwf.btnGotWay.click = function(e)
		local itemID = LingQiUtils:GetConsumeItem(LingQiModel:GetLevel());
		UIQuickBuyConfirm:Open(self,itemID);
	end
end

function UILingQi:ConsumeTips(e)
	local itemInfo = e.target.data;
	local itemId = itemInfo.itemId;
	if not itemId then return; end
	local count = itemInfo.count;
	TipsManager:ShowItemTips(itemId, count);
end

;

-- function UILingQi:ConsumeTips()
-- 	local objSwf = self.objSwf;
-- 	if not objSwf then return end;
-- 	local level = LingQiModel:GetLevel()
-- 	local itemId, itemNum = LingQiUtils:GetConsumeItem(level)
-- 	TipsManager:ShowItemTips(itemId);
-- end;

function UILingQi:ConsumeMoneyTips()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	TipsManager:ShowBtnTips(StrConfig['tips50'], TipsConsts.Dir_RightDown);
end

;

function UILingQi:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UILingQi:OnShow()
	self:UpdateShow(true)
	self:InitVip()
	self:InitData();
	--装备
	self:ShowEquip()
end

function UILingQi:InitData()
	self.isShowClearConfirm = true;
end

function UILingQi:InitVip()
	local objSwf = self.objSwf
	if not objSwf then return end
	-- VIP权限	
--	objSwf.btnVipLvUp.disabled = VipController:GetLingQiLvUp() <= 0
end

function UILingQi:OnBtnVipLvUpRollOver()
	local attMap = self:GetAttMap()
	VipController:ShowAttrTips(attMap, UIVipAttrTips.lq,VipConsts.TYPE_DIAMOND)
end

function UILingQi:OnBtnVipLvUpRollOut()
	VipController:HideAttrTips()
end

function UILingQi:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	LingQiController:SetAutoLevelUp(false);
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

function UILingQi:OnSiPrfcncyRollOver()
	local level = LingQiModel:GetLevel();
	local lvlPrfcncy = LingQiModel:GetLvlProficiency();
	local tipsStr;
	if lvlPrfcncy == LingQiConsts.MaxLvlProficiency then
		tipsStr = StrConfig['lingQi009'];
	elseif lvlPrfcncy < LingQiConsts.MaxLvlProficiency then
		local cfg = t_lingqi[level];
		if not cfg then return; end
		local attrList = AttrParseUtil:Parse(cfg.att1)
		local attrStrTable = {}
		for _, attr in pairs(attrList) do
			local attrName = _G.enAttrTypeName[attr.type]
			table.push(attrStrTable, string.format('<font color="#d5b772">%s</font>    <font color="#00ff00">+%s</font>', attrName, attr.val))
		end
		tipsStr = table.concat(attrStrTable, '\n')
	end
	local skillName = self.skillName or StrConfig['lingQi028']
	tipsStr = string.format(StrConfig['lingQi002'], lvlPrfcncy, tipsStr, skillName);
	TipsManager:ShowBtnTips(tipsStr);
end

function UILingQi:OnSiPrfcncyRollOut()
	TipsManager:Hide();
end

-- 技能tips
function UILingQi:OnSkillRollOver(e)
	local skillInfo = e.item or e.target.data;
	if not skillInfo then return; end
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	local tipsInfo = { skillId = skillInfo.skillId, condition = true, get = skillInfo.lvl > 0 };
	TipsManager:ShowTips(tipsType, tipsInfo, tipsShowType, tipsDir);
end

function UILingQi:OnSkillRollOut()
	TipsManager:Hide();
end

function UILingQi:OnSkillClick(e)
	local skillInfo = e.item;
	UILingQiSkillLvlUp:Open(skillInfo.skillId, skillInfo.lvl);
end

function UILingQi:OnBtnPreClick()
	self:ShowMagicWeapon(self.currentShowLevel - 1);
end

function UILingQi:OnBtnNextClick()
	self:ShowMagicWeapon(self.currentShowLevel + 1);
end

function UILingQi:OnNumLoadComplete()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local numLoader = objSwf.proLoader;
	local bg = objSwf.posSign;
	numLoader._x = bg._x - numLoader._width * 0.5;
	numLoader._y = bg._y - numLoader._height * 0.5;
end

function UILingQi:OnChkBoxUseModelClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	local currentShowLevel = self.currentShowLevel
	if not currentShowLevel then return end
	local useThisModel = objSwf.chkBoxUseModel.selected
	local currentLevel = LingQiModel:GetLevel()
	if currentLevel == currentShowLevel and useThisModel == false then
		-- objSwf.chkBoxUseModel.selected = true
		return
	end
	local modelLevel = useThisModel and currentShowLevel or currentLevel
	LingQiController:ReqUseModel(modelLevel)
end

function UILingQi:OnSiProTweenComplete()
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

function UILingQi:OnSiBlessingTweenComplete()
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

function UILingQi:OnTipsAreaRollOver()
	local level = LingQiModel:GetLevel();
	local cfg = t_lingqi[level];
	if not cfg then return; end
	local blessing = LingQiModel:GetBlessing();
	local isWishclear = cfg.is_wishclear
	local tipStr = StrConfig["wuhun26"]
	if isWishclear then
		tipStr = StrConfig["wuhun27"]
	end

	TipsManager:ShowBtnTips(string.format(StrConfig["wuhun25"], blessing, tipStr));
end

function UILingQi:OnTipsAreaRollOut()
	TipsManager:Hide();
end

function UILingQi:OnBtnLvlUpBClick(e)
	if not UILingQiBagShortcut:ToggleShow() then
		FloatManager:AddNormal(StrConfig['lingQi033'], e.target)
	end
end

function UILingQi:OnBtnFeedSXDClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local shenbingcfg = t_lingqi[LingQiModel:GetLevel()];
	if not shenbingcfg then
		return;
	end

	if shenbingcfg.shenbingdan <= 0 then
		FloatManager:AddNormal(StrConfig["mount18"], objSwf.btnShuXingDan);
		return;
	end

	--属性丹上限
	local sXDCount = 0
	for k, cfg in pairs(t_lingqi) do
		if cfg.id == LingQiModel:GetLevel() then
			sXDCount = cfg.shenbingdan
			break
		end
	end

	--已达到上限
	if LingQiModel:GetPillNum() >= sXDCount then
		FloatManager:AddNormal(StrConfig["mount7"], objSwf.btnShuXingDan);
		return
	end

	--材料不足
	if MountUtil:GetJieJieItemNum(11) <= 0 then
		FloatManager:AddNormal(StrConfig["mount6"], objSwf.btnShuXingDan);
		return
	end

	MountController:FeedShuXingDan(11)
end

--属性丹tip
function UILingQi:OnShuXingDanRollOver()
	UIMountFeedTip:OpenPanel(12);
end

UILingQi.lastSendTime = 0;
function UILingQi:OnBtnLvlUpClick()
	if GetCurTime() - self.lastSendTime < 200 then
		return;
	end
	self.lastSendTime = GetCurTime();

	local autoBuy = LingQiModel.autoBuy
	if not autoBuy and not LingQiController:CheckLvlUpItemEnough() then
		FloatManager:AddNormal(StrConfig['lingQi034'])
		local itemID = LingQiUtils:GetConsumeItem(LingQiModel:GetLevel());
		UIQuickBuyConfirm:Open(self, itemID);
		return
	end
	if not LingQiController:CheckLvlUpMoneyEnough() then
		FloatManager:AddNormal(StrConfig['lingQi035'])
		return
	end

	--清空二次确认提示
	if self.isShowClearConfirm == true then
		local level = LingQiModel:GetLevel();
		local cfg = t_lingqi[level];
		if cfg then
			local isWishclear = cfg.is_wishclear
			if isWishclear then
				local confirmFunc = function()
					LingQiController:SetAutoLevelUp(false);
					LingQiController:ReqLingQiWeaponLevelUp();
					self.isShowClearConfirm = false;
				end
				self.confirmUID = UIConfirm:Open(StrConfig["realm48"], confirmFunc);
				return;
			end
		end
	end

	LingQiController:SetAutoLevelUp(false);
	LingQiController:ReqLingQiWeaponLevelUp();
end

function UILingQi:OnBtnAutoLvlUpClick()
	local autoBuy = LingQiModel.autoBuy
	if not autoBuy and not LingQiController:CheckLvlUpItemEnough() then
		FloatManager:AddNormal(StrConfig['lingQi034'])
		local itemID = LingQiUtils:GetConsumeItem(LingQiModel:GetLevel());
		UIQuickBuyConfirm:Open(self,itemID);
		return
	end
	if not LingQiController:CheckLvlUpMoneyEnough() then
		FloatManager:AddNormal(StrConfig['lingQi035'])
		return
	end

	--清空二次确认提示
	if self.isShowClearConfirm == true then
		local level = LingQiModel:GetLevel();
		local cfg = t_lingqi[level];
		if cfg then
			local isWishclear = cfg.is_wishclear
			if isWishclear then
				local confirmFunc = function()
					LingQiController:SetAutoLevelUp(true);
					LingQiController:ReqLingQiWeaponLevelUp();
					self.isShowClearConfirm = false;
				end
				self.confirmUID = UIConfirm:Open(StrConfig["realm48"], confirmFunc);
				return;
			end
		end
	end

	LingQiController:SetAutoLevelUp(true);
	LingQiController:ReqLingQiWeaponLevelUp();
end

function UILingQi:OnBtnLvlUpRollOver()
	self:ShowNextLevel()
end

function UILingQi:OnBtnLvlUpRollOut()
	self:ShowLastLevel()
end

local lastLevel
function UILingQi:ShowNextLevel()
	local currentLevel = LingQiModel:GetLevel()
	local level = math.min(currentLevel + 1, LingQiConsts:GetMaxLevel());
	lastLevel = self.currentShowLevel
	self:ShowMagicWeapon(level)
end

function UILingQi:ShowLastLevel()
	self:ShowMagicWeapon(lastLevel)
end

function UILingQi:OnBtnCancelAutoClick()
	LingQiController:SetAutoLevelUp(false);
end

function UILingQi:OnBtnConsumeRollOver(e)
	local itemInfo = e.target.data;
	if not itemInfo then return end
	local itemId = itemInfo.itemId;
	if not itemId then return; end
	local count = itemInfo.count;
	TipsManager:ShowItemTips(itemId, count);
end

function UILingQi:OnBtnConsumeRollOut()
	TipsManager:Hide();
end

function UILingQi:OnCBAutoBuySelect(e)
	LingQiModel.autoBuy = e.selected;
end

function UILingQi:OnNumValueLoadComplete(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	-- objSwf.proLoaderValue._x = objSwf.bar._x - objSwf.proLoaderValue.width - 5
	objSwf.proLoaderValue._x = objSwf.bar._x + objSwf.bar._width / 2 - objSwf.proLoaderValue._width / 2;
end

function UILingQi:OnNumMaxLoadComplete(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.proLoaderMax._x = objSwf.bar._x + objSwf.bar._width
end

function UILingQi:OnBtnShowDesRollOver()
	local objSwf = self.objSwf
	if not objSwf then return end
	Tween:To(objSwf.desLoader, 1, { _alpha = 100 })
end

function UILingQi:OnBtnShowDesRollOut()
	local objSwf = self.objSwf
	if not objSwf then return end
	Tween:To(objSwf.desLoader, 1, { _alpha = 0 })
end

function UILingQi:UpdateShow(noTween)
	self:ShowMagicWeapon();
	self:ShowMagicWeaponSkill();
	self:ShowMagicWeaponFight();
	self:ShowMagicWeaponAttr();
	self:ShowMagicWeaponAdvance(noTween);
	self:UpdatePanelMode();
	self:ShowBlessing(false, noTween);
	self:ShowConsume();
	self:ShowUseModelState()
	self:SwitchAutoLvlUpState(LingQiController.isAutoLvlUp);
	self:ShowQingLingInfo();
end

-- 显示等级为level的法宝,如不传,则显示当前等级的法宝
-- showActive: 是否播放激活动作(开启新等阶时候需要显示)
function UILingQi:ShowMagicWeapon(level, showActive)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local currentLevel = LingQiModel:GetLevel();
	if not level then
		level = currentLevel --self.currentShowLevel or ;
	end

	local cfg = t_lingqi[level];
	if not cfg then return; end
	objSwf.nameLoader.source = ResUtil:GetLingQiNameImg(level);
	objSwf.lvlLoader.source = ResUtil:GetLingQiLvlImg(level);
	self:Show3DWeapon(level, showActive);
--	self:ShowWeaponDes(level)
	objSwf.btnPre.disabled = level <= 1;
	objSwf.btnNext.disabled = (level == LingQiConsts:GetMaxLevel()) or (level >= currentLevel + 1);
	local isMaxLvl = currentLevel >= LingQiConsts:GetMaxLevel();
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

function UILingQi:ShowWeaponDes(level)
	local objSwf = self.objSwf
	if not objSwf then return end
	local url = ResUtil:GetLingQiDesImg(level)
	if objSwf.desLoader.source ~= url then
		objSwf.desLoader.source = url
	end
end

-- 显示等级为level的3d法宝模型
-- showActive: 是否播放激活动作
local viewPort;
function UILingQi:Show3DWeapon(level, showActive)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not level then
		level = LingQiModel:GetLevel();
	end
	if not showActive then
		showActive = true;
	end
	local cfg = t_lingqi[level];
	if not cfg then
		Error("Cannot find config of shenbing. level:" .. level);
		return;
	end
	local modelCfg = t_lingqimodel[cfg.model];
	if not modelCfg then
		Error("Cannot find config of shenbingModel. id:" .. cfg.model);
		return;
	end
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1278, 689); end
		self.objUIDraw = UISceneDraw:new("LingQiUI", objSwf.loader, viewPort);
	end
	self.objUIDraw:SetUILoader(objSwf.loader);

	-- local setUIPfxFunc = function()
	-- if modelCfg.effect and modelCfg.effect ~= ""then
	-- self.objUIDraw:PlayNodePfx( cfg.ui_node, modelCfg.effect);
	-- end
	-- end

	if showActive then

		self.objUIDraw:SetScene(cfg.ui_sen, function()
			local aniName = modelCfg.san_idle;
			if aniName == "" then return end
			self.objUIDraw:NodeAnimation(cfg.ui_node, aniName);
			-- setUIPfxFunc()
		end);
	else
		self.objUIDraw:SetScene(cfg.ui_sen, nil);
	end
	self.objUIDraw:SetDraw(true);
end

function UILingQi:ShowMagicWeaponSkill()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = SkillUtil:GetPassiveSkillListShowDzz(SkillConsts.ShowType_LingQi);
	local listSkill = objSwf.listSkill;
	listSkill.dataProvider:cleanUp();
	for i, vo in ipairs(list) do
		local listVO = LingQiUtils:GetSkillListVO(vo.skillId, vo.lvl);
		-- if self.skillName == nil and i == #list then -- 取一次法宝主技能名称并缓存,用于tips显示
		if self.skillName == nil and i == 1 then -- 取一次法宝主技能名称并缓存,用于tips显示
		self.skillName = listVO.name
		end
		table.push(self.skilllist, listVO);
		listSkill.dataProvider:push(UIData.encode(listVO));
	end
	listSkill:invalidateData();

	-- 主动技能
	local skillZhudong = LingQiUtils:GetSkillZhudong()
	if skillZhudong then
		objSwf.skill1.visible = true
		objSwf.skill1.btnPlus.visible = false
		objSwf.skill1.btnskill.visible = true
		objSwf.skill1.iconLoader.visible = true
		if objSwf.skill1.iconLoader.source ~= skillZhudong.iconUrl then
			objSwf.skill1.iconLoader.source = skillZhudong.iconUrl
		end
	end
end

function UILingQi:ShowMagicWeaponFight()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = LingQiModel:GetLevel();
	local lvlPrfcncy = LingQiModel:GetLvlProficiency();
	local fight = LingQiUtils:GetFight(level, lvlPrfcncy);
	objSwf.numLoaderFight.num = fight;
end

function UILingQi:GetVIPFightAdd(level, lvlPrfcncy)
	if not level then
		level = LingQiModel:GetLevel();
	end
	if not lvlPrfcncy then
		lvlPrfcncy = LingQiModel:GetLvlProficiency();
	end
	local attrMap = LingQiUtils:GetMagicWeaponAttrMap(level, lvlPrfcncy);
	if not attrMap then return 0; end
	local vipUPRate = VipController:GetLingQiLvUp() / 100
	if vipUPRate <= 0 then
		vipUPRate = VipController:GetLingQiLvUp(1) / 100
	end
	local attrlist = {};
	for _, attrName in pairs(LingQiConsts.Attrs) do
		local vo = {};
		vo.type = AttrParseUtil.AttMap[attrName];
		vo.val = attrMap[attrName] * vipUPRate;
		table.push(attrlist, vo);
	end
--	return EquipUtil:GetFight(attrlist);
	return PublicUtil:GetFigthValue(attrlist);
end

function UILingQi:GetAttMap()
	local level = LingQiModel:GetLevel();
	local lvlPrfcncy = LingQiModel:GetLvlProficiency();
	local attrMap = LingQiUtils:GetMagicWeaponAttrMap(level, lvlPrfcncy);
	if not attrMap then return nil end
	local attrTotal = {};
	for _, attrName in pairs(LingQiConsts.Attrs) do
		table.push(attrTotal, { proKey = attrName, proValue = attrMap[attrName] })
	end
	return attrTotal
end

function UILingQi:ShowMagicWeaponAttr()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = LingQiModel:GetLevel();
	local lvlPrfcncy = LingQiModel:GetLvlProficiency();
	local attrMap = LingQiUtils:GetMagicWeaponAttrMap(level, lvlPrfcncy);
	if not attrMap then return; end
	local attrTotal = {};
	--基础属性
	for _, attrName in pairs(LingQiConsts.Attrs) do
		attrTotal[attrName] = attrMap[attrName];
		--百分比加成,VIP加成
		local attrType = AttrParseUtil.AttMap[attrName];
		local addP = 0;
		if Attr_AttrPMap[attrType] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[attrType]];
		end
		local vipUPRate = VipController:GetLingQiLvUp() / 100
		attrTotal[attrName] = attrTotal[attrName] * (1 + addP + vipUPRate);
	end
	objSwf.txtAtt.htmlText      = string.format( PublicStyle:GetAttrNameStr(StrConfig['lingQi004']), PublicStyle:GetAttrValStr(toint( attrTotal["att"], 0.5 )) );
	objSwf.txtDef.htmlText      = string.format( PublicStyle:GetAttrNameStr(StrConfig['lingQi005']), PublicStyle:GetAttrValStr(toint( attrTotal["def"], 0.5 )) );
	objSwf.txtHp.htmlText       = string.format( PublicStyle:GetAttrNameStr(StrConfig['lingQi007']), PublicStyle:GetAttrValStr(toint( attrTotal["hp"], 0.5 )) );
	objSwf.txtHit.htmlText      = string.format( PublicStyle:GetAttrNameStr(StrConfig['lingQiplus008']), PublicStyle:GetAttrValStr(toint( attrTotal["hit"], 0.5 )) );
	objSwf.txtDodge.htmlText      = string.format( PublicStyle:GetAttrNameStr(StrConfig['lingQiplus009']), PublicStyle:GetAttrValStr(toint( attrTotal["dodge"], 0.5 )) );
	objSwf.txtAbsatt.htmlText      = string.format( PublicStyle:GetAttrNameStr(StrConfig['lingQiplus010']), PublicStyle:GetAttrValStr(toint( attrTotal["absatt"], 0.5 )) );
end

function UILingQi:ShowMagicWeaponAdvance(noTween)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local lvlPrfcncy = LingQiModel:GetLvlProficiency();
	local oldLvlPrfcncy = objSwf.siProficiencyLvl.value
	local flipOver = math.max(0, lvlPrfcncy - oldLvlPrfcncy);
	objSwf.siProficiencyLvl.value = lvlPrfcncy;
	local lvl = LingQiModel:GetLevel();
	local ceilingPrfcncy = LingQiUtils:GetProficiencyCeiling(lvl, lvlPrfcncy);
	if not ceilingPrfcncy then return end
	local prfcncy = LingQiModel:GetProficiency() or ceilingPrfcncy;
	local proStr = string.format("%sp%s", prfcncy, ceilingPrfcncy);
	objSwf.proLoader:drawStr(proStr);
	if noTween then
		objSwf.siPro:setProgress(prfcncy, ceilingPrfcncy)
	else
		objSwf.siPro:tweenProgress(prfcncy, ceilingPrfcncy, flipOver)
	end
end

function UILingQi:ShowIncrement()
	local level = LingQiModel:GetLevel()
	if level >= LingQiConsts:GetMaxLevel() then return end
	local nextLevel = level + 1
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.incrementFight._visible = true;
	objSwf.incrementAtt._visible = true;
	objSwf.incrementDef._visible = true;
	objSwf.incrementHp._visible = true;
	objSwf.incrementHit._visible = true;
	objSwf.incrementDodge._visible = true;
	objSwf.incrementAbsatt._visible = true;
	objSwf.tfVIPFightAdd._visible = true;
--	objSwf.tfVIPFightAdd._visible = false;
	local maxFight = LingQiUtils:GetFight(level, LingQiConsts.MaxLvlProficiency) or 0;
	local nextFight = LingQiUtils:GetFight(nextLevel) or 0;
	objSwf.incrementFight.label = nextFight - maxFight;
	local incrementMap = LingQiUtils:GetAttrIncrementMap(level);
	if not incrementMap then return; end
	objSwf.incrementAtt.htmlLabel = PublicStyle:GetAttrValStr(toint(incrementMap.att, 0.5));
	objSwf.incrementDef.htmlLabel = PublicStyle:GetAttrValStr(toint(incrementMap.def, 0.5));
	objSwf.incrementHp.htmlLabel = PublicStyle:GetAttrValStr(toint(incrementMap.hp, 0.5));
	objSwf.incrementHit.htmlLabel = PublicStyle:GetAttrValStr(toint(incrementMap.hit, 0.5));
	objSwf.incrementDodge.htmlLabel = PublicStyle:GetAttrValStr(toint(incrementMap.dodge, 0.5));
	objSwf.incrementAbsatt.htmlLabel = PublicStyle:GetAttrValStr(toint(incrementMap.absatt, 0.5));
	local maxVIPFight = self:GetVIPFightAdd(level, LingQiConsts.MaxLvlProficiency);
	local nextVIPFight = self:GetVIPFightAdd(nextLevel, 0);
	objSwf.tfVIPFightAdd.htmlText = string.format(StrConfig['vip100'], nextVIPFight - maxVIPFight);
end

function UILingQi:HideIncrement()
	local objSwf = self.objSwf
	if not objSwf then return end
	if self.isAutoLvlUp then return end
	objSwf.incrementFight._visible = false
	objSwf.incrementAtt._visible = false
	objSwf.incrementDef._visible = false
	objSwf.incrementHp._visible = false
	objSwf.incrementHit._visible = false
	objSwf.incrementDodge._visible = false
	objSwf.incrementAbsatt._visible = false
	objSwf.tfVIPFightAdd._visible = false
end

-- 更新面板模式: (1)熟练度积攒模式 / (2)升阶模式
function UILingQi:UpdatePanelMode()
	local objSwf = self.objSwf
	if not objSwf then return end
	local panelState = self:GetState()
	local proficiencyState = panelState == 1
	local lvlUpState = panelState == 2
	local level = LingQiModel:GetLevel()
	local cfg = t_lingqi[level];
	if not cfg then return; end
	-- 法宝熟练度等级不满，或者满阶时，显示熟练度模式
	objSwf.titleAdvance._visible = proficiencyState
	objSwf.siProficiencyLvl._visible = proficiencyState
	objSwf.proficiencyTipsArea._visible = proficiencyState
	objSwf.posSign._visible = proficiencyState
	objSwf.proLoader._visible = proficiencyState
	objSwf.siPro._visible = proficiencyState
	objSwf.btnLvlUpB._visible = proficiencyState and (level ~= LingQiConsts:GetMaxLevel())
	-- 法宝熟练度满级，且法宝非满阶时，显示升阶模式
	objSwf.titleLvlUp._visible = lvlUpState
	objSwf.btnLvlUp._visible = lvlUpState
	objSwf.btnAutoLvlUp._visible = lvlUpState
	objSwf.cbAutoBuy._visible = lvlUpState
	objSwf.btnGotWay._visible	   = lvlUpState
	objSwf.tfcleardata._visible = lvlUpState and cfg.is_wishclear
	objSwf.littleTipTxt._visible = lvlUpState and not cfg.is_wishclear
	objSwf.txtConsume._visible = lvlUpState
	objSwf.btnConsume._visible = lvlUpState
--	objSwf.txtMoneyName._visible = lvlUpState
--	objSwf.txtMoney._visible = lvlUpState
	objSwf.txtMoneyName._visible = false
	objSwf.txtMoney._visible = false
	objSwf.txtConsumeNum._visible = lvlUpState;
--	objSwf.proLoaderValue._visible = lvlUpState
--	objSwf.proLoaderMax._visible = lvlUpState
	objSwf.proLoaderValue._visible = false
	objSwf.proLoaderMax._visible = false
	objSwf.bar._visible = false --lvlUpState
	objSwf.tipsArea._visible = lvlUpState
	objSwf.siBlessing._visible = lvlUpState
	self:UpdateBtnEffect()
end

function UILingQi:UpdateBtnEffect()
	local objSwf = self.objSwf
	if not objSwf then return end
	local panelState = self:GetState()
	local lvlUpState = panelState == 2
	local lvlUpConditionEnough = LingQiController:CheckLvlUpItemEnough() and LingQiController:CheckLvlUpMoneyEnough()
	if lvlUpState and lvlUpConditionEnough then
		objSwf.btnLvlUp:showEffect(ResUtil:GetButtonEffect10());
		objSwf.btnAutoLvlUp:showEffect(ResUtil:GetButtonEffect10());
	else
		objSwf.btnLvlUp:clearEffect();
		objSwf.btnAutoLvlUp:clearEffect();
	end
	objSwf.btnLvlUpEff._visible = false;
	objSwf.btnAutoEff._visible = false;
--	objSwf.btnLvlUpEff._visible = lvlUpState and lvlUpConditionEnough
--	objSwf.btnAutoEff._visible = lvlUpState and lvlUpConditionEnough
end

-- (1)熟练度积攒状态 / (2)升阶状态
function UILingQi:GetState()
	--[[local level = LingQiModel:GetLevel()
	if level == LingQiConsts:GetMaxLevel() then
		return 1
	else
		local lvlProficiency = LingQiModel:GetLvlProficiency()
		if lvlProficiency == LingQiConsts.MaxLvlProficiency then
			return 2
		else
			return 1
		end
	end]]
	return 2;
end

local lastBlessing;
function UILingQi:ShowBlessing(showGain, noTween)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local blessing = LingQiModel:GetBlessing();
	local level = LingQiModel:GetLevel();
	local cfg = t_lingqi[level];
	if not cfg then return; end
	local maxBlessing = cfg.wish_max;
	objSwf.proLoaderValue.num = blessing
	-- objSwf.proLoaderMax.num   = maxBlessing
	objSwf.txtProLoader.text = string.format(StrConfig["lingQi060"], blessing, maxBlessing);
	if noTween then
		objSwf.siBlessing:setProgress(blessing, maxBlessing);
	else
		objSwf.siBlessing:tweenProgress(blessing, maxBlessing, 0);
	end
	if showGain then
		if lastBlessing then
			local blessingGain = blessing - lastBlessing;
			if blessingGain > 0 then
				FloatManager:AddNormal(string.format(StrConfig['wuhun38'], blessingGain), objSwf.tipsArea);
			end
		end
	end
	lastBlessing = blessing;
end

function UILingQi:ShowConsume()
	self:ShowConsumeItem();
	self:ShowConsumeMoney();
end

function UILingQi:ShowConsumeItem()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = LingQiModel:GetLevel()
	local itemId, itemNum, isEnough = LingQiUtils:GetConsumeItem(level)
	local itemCfg = t_item[itemId];
	local itemName = itemCfg and itemCfg.name or "something magic";
	objSwf.btnConsume.data = { itemId = itemId, count = itemNum };
	local labelItemColor = isEnough and "#00FF00" or "#FF0000";
	objSwf.btnConsume.htmlLabel = string.format(StrConfig['lingQi012'], labelItemColor, itemName, itemNum);
	local hasNum = BagModel:GetItemNumInBag(itemId);
	objSwf.txtConsumeNum.text = string.format(StrConfig["lingQi059"], hasNum);
end

-- function UILingQi:ShowConsumeItem()
-- 	local objSwf = self.objSwf;
-- 	if not objSwf then return; end
-- 	local level = LingQiModel:GetLevel()
-- 	local itemId, itemNum = LingQiUtils:GetConsumeItem(level)
-- 	local itemCfg = t_item[itemId];
-- 	local itemName = itemCfg and itemCfg.name or "something magic";
-- 	objSwf.btnConsume.data = {itemId = itemId, count = itemNum};
-- 	local labelItemColor = BagModel:GetItemNumInBag( itemId ) >= itemNum and "#2fe00d" or "#cc0000";
-- 	objSwf.btnConsume.htmlLabel = string.format( StrConfig['lingQi012'], labelItemColor, itemName, itemNum );
-- end

function UILingQi:ShowConsumeMoney()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = LingQiModel:GetLevel()
	local moneyConsume = LingQiUtils:GetConsumeMoney(level)
	local playerInfo = MainPlayerModel.humanDetailInfo;
	local playerMoney = playerInfo.eaBindGold + playerInfo.eaUnBindGold;
	local moneyEnough = playerMoney >= moneyConsume;
	local labelMoneyColor = moneyEnough and "#2fe00d" or "#cc0000";
	objSwf.txtMoney.htmlLabel = string.format("<u><font color='%s'>%s</font></u>", labelMoneyColor, moneyConsume);
	objSwf.cbAutoBuy.selected = LingQiModel.autoBuy;
end

function UILingQi:ShowUseModelState()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.chkBoxUseModel.selected = LingQiModel:GetModelLevel() == self.currentShowLevel
	objSwf.chkBoxUseModel.disabled = self.currentShowLevel > LingQiModel:GetLevel()
end

function UILingQi:SwitchAutoLvlUpState(isAutoLvlUp)
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

function UILingQi:ShowQingLingInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfcleardata.htmlText = "";
	local level = LingQiModel:GetLevel();
	local cfg = t_lingqi[level];
	if not cfg then return; end
	if cfg.is_wishclear == true then
		objSwf.tfcleardata.htmlText = StrConfig["realm45"];
	end
end
---------------------------以下是装备处理--------------------------------------
--显示装备
function UILingQi:ShowEquip()
	local objSwf = self:GetSWF("UILingQi");
	if not objSwf then return; end
	self.list = BagUtil:GetBagItemList(BagConsts.BagType_LingQi,BagConsts.ShowType_All);
	objSwf.list.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.list) do
		objSwf.list.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.list:invalidateData();
end

--获取指定位置的Item,飞图标用
function UILingQi:GetItemAtPos(pos)
	if not self.isFullShow then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local uiSlot = objSwf.list:getRendererAt(pos);
	return uiSlot;
end

--添加Item
function UILingQi:DoAddItem(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_LingQi);
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
function UILingQi:DoRemoveItem(pos)
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
function UILingQi:DoUpdateItem(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_LingQi);
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

function UILingQi:OnItemRollOver(item)
	local data = item:GetData();
	if not data.hasItem then
		TipsManager:ShowBtnTips(BagConsts:GetLingQiEquipNameByPos(data.pos));
		return;
	end
	TipsManager:ShowBagTips(BagConsts.BagType_LingQi,data.pos);
end

function UILingQi:OnItemRollOut(item)
	TipsManager:Hide();
end

function UILingQi:OnItemDragBegin(item)
	TipsManager:Hide();
end

function UILingQi:OnItemDragIn(fromData,toData)
	--来自背包的
	if fromData.bagType == BagConsts.BagType_Bag then
		--判断是否是装备
		if BagUtil:GetItemShowType(fromData.tid) ~= BagConsts.ShowType_Equip then
			return;
		end
		--判断装备位是否相同
		if BagUtil:GetEquipType(fromData.tid) ~= BagUtil:GetEquipAtBagPos(BagConsts.BagType_LingQi,toData.pos) then
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
function UILingQi:OnItemClick(item)
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
		UIBagQuickEquitView:Open(item.mc, BagConsts.BagType_LingQi, itemData.pos+BagConsts.Equip_LQ_0, itemData.pos+BagConsts.Equip_LQ_0);
		return;
	end
	if _sys:isKeyDown(_System.KeyCtrl) then
		ChatQuickSend:SendItem(BagConsts.BagType_LingQi,itemData.pos);
		return;
	end

	UIBagQuickEquitView:Open(item.mc, BagConsts.BagType_LingQi, itemData.pos+BagConsts.Equip_LQ_0, itemData.pos);
end

--双击卸载
function UILingQi:OnItemDoubleClick(item)
	TipsManager:Hide();
	local data = item:GetData();
	if not data.hasItem  then
		return;
	end
	BagController:UnEquipItem(BagConsts.BagType_LingQi,data.pos);
end

--右键卸载
function UILingQi:OnItemRClick(item)
	TipsManager:Hide();
	local data = item:GetData();
	if not data.hasItem then
		return;
	end
	BagController:UnEquipItem(BagConsts.BagType_LingQi,data.pos);
end
---------------------------以上是装备处理--------------------------------------
function UILingQi:OnBtnZZDClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local shenbingcfg = t_lingqi[LingQiModel:GetLevel()];
	if not shenbingcfg then
		return;
	end

	if shenbingcfg.zizhi_dan <= 0 then
		FloatManager:AddNormal( string.format(StrConfig["zizhi1"], ZiZhiUtil:GetOpenLvByCFG(t_lingqi)), objSwf.btnZZD);
		return;
	end

	--资质丹上限
	local zzdCount = 0
	for k,cfg in pairs(t_lingqi) do
		if cfg.id == LingQiModel:GetLevel() then
			zzdCount = cfg.zizhi_dan
			break
		end
	end

	--已达到上限
	if ZiZhiModel:GetZZNum(4) >= zzdCount then
		FloatManager:AddNormal( StrConfig["mount7"], objSwf.btnZZD);
		return
	end

	--材料不足
	if ZiZhiUtil:GetZZItemNum(4) <= 0 then
		FloatManager:AddNormal( StrConfig["mount6"], objSwf.btnZZD);
		return
	end

	ZiZhiController:FeedZZDan(4)
end

--属性丹tip
function UILingQi:OnZZDRollOver()
	UIMountFeedTip:OpenPanel(102);
end
---------------------------以上是资质丹--------------------------------------
--技能鼠标移上
function UILingQi:OnSkillItemOver()
	local skillZhudong = LingQiUtils:GetSkillZhudong()
	if not skillZhudong then return end
	-- FPrint('技能鼠标移上'..skillZhudong.skillId)
	-- TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=tonumber(skillZhudong.skillId)},TipsConsts.ShowType_Normal,
	-- TipsConsts.Dir_RightUp);


	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	local tipsInfo = { skillId = skillZhudong.skillId, condition = true,unShowLvlUpPrompt =true, get = true };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

--技能鼠标移出
function UILingQi:OnSkillItemOut(e)
	TipsManager:Hide();
end
--------------------------- 消息处理---------------------------------
-- 监听消息列表
function UILingQi:ListNotificationInterests()
	return {
		NotifyConsts.LingQiLevelUp,
		NotifyConsts.LingQiModelChange,
		NotifyConsts.LingQiPrfcncyLevelUp,
		NotifyConsts.LingQiProficiency,
		NotifyConsts.LingQiBlessing,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.SkillLearn,
		NotifyConsts.SkillLvlUp,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.VipPeriod,
		NotifyConsts.LingQiSXDChanged,
		NotifyConsts.LingQiZZChanged,
	};
end

--处理消息
function UILingQi:HandleNotification(name, body)
	if name == NotifyConsts.LingQiModelChange then
		self:ShowUseModelState()
	elseif name == NotifyConsts.LingQiLevelUp then
		self:OnWeaponLvlUp()
		self:ShowUseModelState()
	elseif name == NotifyConsts.LingQiPrfcncyLevelUp then
		self:ShowMagicWeaponAttr()
		self:ShowMagicWeaponFight()
		self:UpdatePanelMode()
		self:ShowMagicWeaponAdvance()
		SoundManager:PlaySfx(LingQiConsts.SfxProficiencyLevelUp)
	elseif name == NotifyConsts.LingQiProficiency then
		self:ShowMagicWeaponAdvance()
		SoundManager:PlaySfx(LingQiConsts.SfxProficiencyAdd)
	elseif name == NotifyConsts.SkillLearn then
		self:ShowMagicWeaponSkill()
		self:ShowMagicWeaponAttr()
		self:ShowMagicWeaponFight()
	elseif name == NotifyConsts.SkillLvlUp then
		self:ShowMagicWeaponSkill()
		self:ShowMagicWeaponAttr()
		self:ShowMagicWeaponFight()
	elseif name == NotifyConsts.LingQiBlessing then
		self:ShowBlessing(true);
		SoundManager:PlaySfx(LingQiConsts.SfxLevelUp)
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
			if body.type ~= BagConsts.BagType_LingQi then return; end
			self:DoAddItem(body.pos);
			self:UpdateShow()
		elseif name == NotifyConsts.BagRemove then
			if body.type ~= BagConsts.BagType_LingQi then return; end
			self:DoRemoveItem(body.pos);
			self:UpdateShow()
		elseif name == NotifyConsts.BagUpdate then
			if body.type ~= BagConsts.BagType_LingQi then return; end
			self:DoUpdateItem(body.pos);
			self:UpdateShow()
		end
	elseif name == NotifyConsts.VipPeriod then
		self:InitVip()
		self:ShowMagicWeaponAttr()
		self:ShowMagicWeaponFight()
	elseif name == NotifyConsts.LingQiSXDChanged then
		self:ShowMagicWeaponAttr()
		self:ShowMagicWeaponFight()
	elseif name == NotifyConsts.LingQiZZChange then
		self:ShowMagicWeaponAttr()
		self:ShowMagicWeaponFight()
	end
end

function UILingQi:OnWeaponLvlUp()
	self:ShowMagicWeaponAdvance(true)
	self:UpdatePanelMode()
	self:ShowMagicWeapon(nil, true)
	self:ShowMagicWeaponSkill()
	self:ShowMagicWeaponFight()
	self:ShowMagicWeaponAttr()
	self:UpdatePanelMode()
	self:ShowConsume()
	LingQiController:SetAutoLevelUp(false);
end