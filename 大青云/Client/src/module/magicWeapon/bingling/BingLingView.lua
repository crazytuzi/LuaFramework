--[[
兵灵：主面板

]]

_G.UIBingLing = BaseUI:new("UIBingLing");

--技能列表
UIBingLing.skilllist = {};
--主动技能列表
UIBingLing.zhudongskilllist = {};
--当前显示的等阶
UIBingLing.currentShowLevel = nil;
--当前显示的id
UIBingLing.currentid = 5;

function UIBingLing:Create()
	self:AddSWF("binglingPanel.swf", true, nil);
end
local isShowDes = false
function UIBingLing:OnLoaded( objSwf )

	--objSwf.loader.hitTestDisable = true;
	-- objSwf.btnLvlUp.rollOver         = function() self:OnBtnLvlUpRollOver(); end
	-- objSwf.btnLvlUp.rollOut          = function() self:OnBtnLvlUpRollOut(); end
	-- objSwf.btnLvlUp.click            = function() self:OnBtnLvlUpClick(); end
	objSwf.nameLoader.loaded         = function(e) self:OnNameLoaded(e); end
	
	--主动技能
	objSwf.listSkillbeidong.itemRollOver    = function(e) self:OnSkillRollOver(e); end
	objSwf.listSkillbeidong.itemRollOut     = function() self:OnSkillRollOut(); end
	objSwf.mcJinjie.btnLvlUp.rollOver = function(e) self:ShowNextLevel(); end
	objSwf.mcJinjie.btnAutoLvlUp.rollOver = function(e) self:ShowNextLevel(); end
	objSwf.mcJinjie.btnLvlUp.rollOut = function(e) self:HideNextLevel(); end
	objSwf.mcJinjie.btnAutoLvlUp.rollOut = function(e) self:HideNextLevel(); end
	
	--激活
	objSwf.activepanel.btnactive.click = function(e) self:OnBtnActiveClick(); end
	objSwf.activepanel.btnactiveinfo.rollOver = function(e) self:OnbtnActiveItemRollOver(); end
	objSwf.activepanel.btnactiveinfo.rollOut = function(e) TipsManager:Hide(); end
	
	for i=1,5 do
		objSwf["bingling"..i].click = function(e) self:OnBtnBingLingClick(i); end
		objSwf["binglingjiesuoeffect"..i].complete = function() self:PlayHaveEffect(i); end
	end
	objSwf.btnallAttr.rollOver = function(e) self:OnBtnAllAttrRollOver(); end
	objSwf.btnallAttr.rollOut = function(e) TipsManager:Hide(); end
	
	--规则
	objSwf.rulesBtn.rollOver = function() self:OnRulesBtnRollOver(); end
	objSwf.rulesBtn.rollOut = function() TipsManager:Hide(); end
	
	self:HideIncrement()
	UIBingLingLvlUp:OnLoaded(objSwf.mcJinjie)
end

function UIBingLing:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	
	UIBingLingLvlUp:OnDelete()
end

function UIBingLing:OnShow()
	self:InitData();
	self:InitUI();
	self:UpdateShow();
	self:ShowJieSuoEffect();
	UIBingLingLvlUp:OnShow()
end

function UIBingLing:InitData()
	self.currentid = 1;
end

function UIBingLing:InitUI()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=1,5 do
		objSwf["bingling"..i].selected = false;
	end
	objSwf.bingling1.selected = true;
end

function UIBingLing:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	
	UIBingLingLvlUp:OnHide()
end

function UIBingLing:ShowLvlUpPanel(show)
	if not self:IsShow() then return end
	if show == nil then show = true; end
	if show then
		self:ShowChild("binglingLvlUp");
	else
		UIBingLingLvlUp:Hide();
	end
end

-- 显示正常的tips
function UIBingLing:OnSkillRollOver(e)
	local skillInfo = e.item or e.target.data;
	if not skillInfo then return; end
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	local skillId = 0;
	local skilllvl = 0;
	local level = BingLingUtils:GetLevelByid(self.currentid);
	local tipsInfo = { skillId = skillInfo.skillId, condition = true, get = (level~=0) ,unShowLvlUpPrompt = true};
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

function UIBingLing:OnSkillRollOut()
	TipsManager:Hide();
end

function UIBingLing:OnSkillClick(e)
end

function UIBingLing:OnbtnActiveItemRollOver()
	local desTable = BingLingUtils:GetBingLingToolByid(self.currentid);
	local itemid = tonumber(desTable[1]);
	if t_item[itemid] then
		TipsManager:ShowItemTips(itemid);
	end
end

function UIBingLing:OnBtnActiveClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local currentLevel = BingLingUtils:GetLevelByid(self.currentid);
	if currentLevel == 0 then
		--得到当前激活上限
		if BingLingUtils:GetIsCurActiveMax() then
			FloatManager:AddNormal( StrConfig["magicWeapon052"], objSwf.activepanel.btnactive);
			return;
		end
		local desTable = BingLingUtils:GetBingLingToolByid(self.currentid);
		local itemid = tonumber(desTable[1]);
		local NbNum = BagModel:GetItemNumInBag(itemid);
		if NbNum < tonumber(desTable[2]) then
			FloatManager:AddNormal( StrConfig["qizhan5"], objSwf.activepanel.btnactive);
			return;
		end
		local auto = 1;
		-- if objSwf.activepanel.checkZiDong.selected == true then
			-- auto = 0;
		-- end
		currentLevel = self.currentid * 1000;
		BingLingController:ReqBingLingLevelUp(currentLevel);
	end
end

function UIBingLing:OnBtnBingLingClick(num)
	self.currentid = num;
	self:UpdateShow();
	UIBingLingLvlUp:OnShow()
	BingLingController:SetAutoLevelUp(false);
end

function UIBingLing:OnBtnAllAttrRollOver()
	local str = "";
	local attrMap = BingLingUtils:GetAllAttrMap();
	local index = 0;
	
	for attrType, attrValue in pairs(attrMap) do
		local type = AttrParseUtil.AttMap[attrType];
		local attrName = _G.enAttrTypeName[type]
		if index == 0 then
			str = string.format( StrConfig['magicWeapon051'], attrName, attrValue);
		else
			local val = attrValue;
			if attrType == "crivalue" then
				val = getAtrrShowVal( enAttrType.eaBaoJiHurt, attrValue );
			end
			str = str .. "<br/>" .. string.format( StrConfig['magicWeapon051'], attrName, val);
		end
		index = index + 1;
	end
	local strAttr =  string.format( StrConfig['magicWeapon050'], str);
	TipsManager:ShowBtnTips(strAttr,TipsConsts.Dir_RightDown);
end

function UIBingLing:OnRulesBtnRollOver()
	local str = "";
	local index = 0;
	for i=1,99 do
		local shenbingcfg = t_shenbing[i];
		if shenbingcfg then
			if shenbingcfg.bingling_num == 1 then
				index = shenbingcfg.bingling_num + 1;
				str = string.format( StrConfig['magicWeapon058'], i, shenbingcfg.bingling_num);
			elseif shenbingcfg.bingling_num > 1 and shenbingcfg.bingling_num == index then
				index = shenbingcfg.bingling_num + 1;
				str = str .. "<br/>" .. string.format( StrConfig['magicWeapon058'], i, shenbingcfg.bingling_num);
			end
		else
			break;
		end
	end
	local strinfo = string.format( StrConfig['magicWeapon054'], str);
	TipsManager:ShowBtnTips(strinfo,TipsConsts.Dir_RightDown)
end

function UIBingLing:OnNameLoaded(e)
	-- local img = e.target.content;
	-- if not img then return end
	-- img._x = img._width * -1;
end

-- @param showActive: 是否显示模型激活(开启新等阶时候需要显示)
function UIBingLing:UpdateShow()
	self:ShowBingLing(nil, true);
	self:ShowBingLingSkill();
	self:ShowBingLingFight();
	self:ShowBingLingAttr(self.currentid);
end

local timerKey
function UIBingLing:OnBingLingLvlUp()
	self:ShowBingLing( nil ,true )
	-- if timerKey then
		-- TimerManager:UnRegisterTimer( timerKey )
		-- timerKey = nil
	-- end
	-- timerKey = TimerManager:RegisterTimer( function()
		--self:Hide()
		---UIBingLingShowView:Show()
		-- timerKey = nil
	-- end, 1000, 1 )
end

-- 显示等级为level的兵灵,如不传,则显示当前等级的兵灵
-- showActive: 是否播放激活动作
function UIBingLing:ShowBingLing( level, showActive )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local currentLevel = BingLingUtils:GetLevelByid(self.currentid);
	if not level then
		level = currentLevel;
	end
	if level == 0 then
		level = self.currentid * 1000 + 1;
	end
	local cfg = t_shenbingbingling[level];
	if not cfg then return; end
	local isMaxLvl = currentLevel >= BingLingModel:GetMaxLevel(self.currentid)
	
	--objSwf.nameLoader.source = ResUtil:GetBingLingIcon(cfg.name_icon);
	--objSwf.lvlLoader.source = ResUtil:GetFeedUpLvlImg(level);
	self:Show3DWeapon(level, showActive);
	self:ShowBingLingInfo();
	self.currentShowLevel = level;
	if currentLevel == 0 then
		--objSwf.notGainMC._visible = false
		objSwf.maxLvlMc._visible = false;
		objSwf.mcJinjie._visible = false;
		objSwf.activepanel._visible = true;
		self:ShowActiveInfo();
	else
		objSwf.activepanel._visible = false;
		objSwf.maxLvlMc._visible = isMaxLvl;
		objSwf.mcJinjie._visible = not isMaxLvl;
		
		if level == currentLevel + 1 then
			self:ShowIncrement()
			--objSwf.notGainMC._visible = true
		else
			self:HideIncrement()
			--objSwf.notGainMC._visible = false
		end
	end
end

function UIBingLing:ShowBingLingInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=1,5 do
		local str = BingLingConsts:GetBingLingName(i);
		local level = BingLingUtils:GetLevelByid(i);
		if level == 0 then
			str = string.format(str, "#ff0000", StrConfig["magicWeapon049"]);
		else
			str = string.format(str, "#00ff00", "Lv."..level%1000);
		end
		objSwf["bingling"..i].tfbinglinginfo.htmlText = str;
		objSwf["BingLingName"..i]._visible = false;
	end
	objSwf["BingLingName"..self.currentid]._visible = true;
	objSwf.tfbinglinglevel.text = "";
	local level = BingLingUtils:GetLevelByid(self.currentid);
	if level > 0 then
		objSwf.tfbinglinglevel.text = "Lv."..level%1000;
	end
end

function UIBingLing:ShowJieSuoEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=1,5 do
		local level = BingLingUtils:GetLevelByid(i);
		objSwf["binglingnoeffect"..i]._visible = false;
		objSwf["binglingeffect"..i]._visible = false;
		objSwf["binglingjiesuoeffect"..i]._visible = false;
		if level == 0 then
			objSwf["binglingnoeffect"..i]._visible = true;
		else
			objSwf["binglingeffect"..i]._visible = true;
		end
	end
end

--播放解锁特效
function UIBingLing:PlayJieSuoEffect(body)
	if not body or not body.id then
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf["binglingnoeffect"..body.id]._visible = false;
	objSwf["binglingjiesuoeffect"..body.id]._visible = true;
	objSwf["binglingjiesuoeffect"..body.id]:playEffect(1);
end

function UIBingLing:PlayHaveEffect(index)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf["binglingeffect"..index]._visible = true;
end

-- 显示等级为level的3d兵灵模型
-- showActive: 是否播放激活动作m
local viewPort;
function UIBingLing:Show3DWeapon( level, showActive )
	
end

function UIBingLing:ShowBingLingSkill()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local listSkill = objSwf.listSkillbeidong;
	listSkill.dataProvider:cleanUp();
	local skillId = 0;
	local skilllvl = 0;
	local level = BingLingUtils:GetLevelByid(self.currentid);
	if level == 0 then
		local binglingcfg = t_shenbingbingling[self.currentid*1000 + 1];
		skillId = binglingcfg.skill;
		skilllvl = 0;
	else
		local binglingcfg = t_shenbingbingling[level];
		skillId = binglingcfg.skill;
		skilllvl = level % 1000;
	end
	local listVO = BingLingUtils:GetSkillListVO(skillId, skilllvl);
	listSkill.dataProvider:push( UIData.encode(listVO) );
	listSkill:invalidateData();
end

function UIBingLing:ShowBingLingFight()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = BingLingUtils:GetLevelByid(self.currentid);
	local fight = level > 0 and BingLingUtils:GetFight( level ) or 0;
	objSwf.numLoaderFight.num = fight ;
end

--ly
function UIBingLing:ShowBingLingAttr(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local binglinglevel = BingLingUtils:GetLevelByid(id);
	if binglinglevel == 0 then
		binglinglevel = id * 1000 + 1;
	end
	
	local attrMap = BingLingUtils:GetBingLingAttrMap(binglinglevel);
	if not attrMap then return; end
	local attrTotal = {};
	local attrarray = BingLingConsts:GetAttrs(id);
	for _, attrName in pairs(attrarray) do
		attrTotal[attrName] = attrMap[attrName];
	end
	
	local att, def, hp, attr2 = attrTotal[attrarray[1]],attrTotal[attrarray[2]],attrTotal[attrarray[3]],attrTotal[attrarray[4]]
	local str = ""
	str = str .. "<textformat leading='16'><p>"
	local addPro = 0
	addPro = att
	if addPro and addPro ~= 0 then
		str = str .. BingLingConsts:GetAttrName(attrarray[1]) ..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = def
	if addPro and addPro ~= 0 then
		str = str .. BingLingConsts:GetAttrName(attrarray[2])..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = hp
	if addPro and addPro ~= 0 then
		str = str .. BingLingConsts:GetAttrName(attrarray[3])..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = attr2
	if addPro and addPro ~= 0 then
		if attrarray[4] == "crivalue" then
			str = str .. BingLingConsts:GetAttrName(attrarray[4])..':    <font color = "#FBBF78"> '.. getAtrrShowVal( enAttrType.eaBaoJiHurt, addPro ) ..' </font><br/>'
		else
			str = str .. BingLingConsts:GetAttrName(attrarray[4])..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
		end
	end
	str = str .. "</p></textformat>"
	objSwf.labProShow.htmlText = str
end

-- 下阶预览
function UIBingLing:ShowNextLevel()
	local level = BingLingUtils:GetLevelByid(self.currentid);
	if level >= BingLingModel:GetMaxLevel(self.currentid) then return; end
	local nextLevel = level + 1;
	self:ShowBingLing(nextLevel)
end

-- 隐藏下阶预览
function UIBingLing:HideNextLevel()
	local level = BingLingUtils:GetLevelByid(self.currentid);
	self:ShowBingLing(level)
end
--ly
function UIBingLing:ShowIncrement()
	local level = BingLingUtils:GetLevelByid(self.currentid);
	if level >= BingLingModel:GetMaxLevel(self.currentid) then return; end
	local nextLevel = level + 1;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- objSwf.mcIncrement._visible      = true;
	objSwf.incrementFight._visible    = true;
	-- self:ShowBingLing(nextLevel);
	local maxFight = BingLingUtils:GetFight( level ) or 0;
	local nextFight = BingLingUtils:GetFight( nextLevel ) or 0;
	objSwf.incrementFight.label = nextFight - maxFight;
	local incrementMap = BingLingUtils:GetAttrIncrementMap(level, self.currentid);
	-- FTrace(incrementMap,'999999999')
	if not incrementMap then return; end
	for i=1,4 do
		objSwf['mcUpArrow'..i]._visible = false
	end
	local upNum = 0
	local attrarray = BingLingConsts:GetAttrs(self.currentid);
	local totalatt, totaldef, totalhp, totalcri = incrementMap[attrarray[1]],incrementMap[attrarray[2]],incrementMap[attrarray[3]],incrementMap[attrarray[4]]
	local str = ""
	str = str .. "<textformat leading='16'><p>"
	local addPro = 0
	addPro = totalatt
	if addPro and addPro ~= 0 then
		if addPro ~= 0 then
			upNum = upNum + 1
			
			str = str .. '<font color = "#2FE00D"> '..addPro ..' </font><br/>'
		else
			str = str .. '<br/>'
		end
	end
	addPro = totaldef
	if addPro and addPro ~= 0 then
		if addPro ~= 0 then
			upNum = upNum + 1
			str = str .. '</font><font color = "#2FE00D"> '..addPro ..' </font><br/>'
			
		else
			str = str .. '<br/>'
		end
	end
	addPro = totalhp
	if addPro and addPro ~= 0 then
		if addPro ~= 0 then
			upNum = upNum + 1
			str = str .. '</font><font color = "#2FE00D"> '..addPro ..' </font><br/>'
			
		else
			str = str .. '<br/>'
		end
	end
	addPro = totalcri
	if addPro and addPro ~= 0 then
		if addPro ~= 0 then
			upNum = upNum + 1
			if attrarray[4] == "crivalue" then
				str = str .. '</font><font color = "#2FE00D"> '..getAtrrShowVal( enAttrType.eaBaoJiHurt, addPro ) ..' </font><br/>'
			else
				str = str .. '</font><font color = "#2FE00D"> '..addPro ..' </font><br/>'
			end
		else
			str = str .. '<br/>'
		end
	end
	
	str = str .. "</p></textformat>"
	objSwf.labProUpShow.htmlText = str
	if upNum > 0 then
		for i=1,upNum do
			if i <= 7 then
				objSwf['mcUpArrow'..i]._visible = true
			end
		end
	end
end
--ly
function UIBingLing:HideIncrement()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if BingLingController.isAutoLvlUp then
		return
	end
	-- objSwf.mcIncrement._visible      = false;
	objSwf.incrementFight._visible    = false;
	
	for i=1,4 do
		objSwf['mcUpArrow'..i]._visible = false
	end
	objSwf.labProUpShow.htmlText = ''
	
	local level = BingLingModel:GetLevel();
	-- self:ShowBingLing(level);
end

function UIBingLing:ShowActiveInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.activepanel._visible = false;
	local currentLevel = BingLingUtils:GetLevelByid(self.currentid);
	if currentLevel == 0 then
		objSwf.activepanel._visible = true;
		objSwf.activepanel.checkZiDong._visible = false;
		objSwf.activepanel.btnactiveinfo.htmlText = "";
		local desTable = BingLingUtils:GetBingLingToolByid(self.currentid);
		local itemid = tonumber(desTable[1]);
		local NbNum = BagModel:GetItemNumInBag(itemid);
		local stritem = t_item[itemid].name..desTable[2]
		if NbNum >= tonumber(desTable[2]) then
			objSwf.activepanel.btnactiveinfo.htmlLabel = string.format(StrConfig["qizhan3"], stritem);
		else
			objSwf.activepanel.btnactiveinfo.htmlLabel = string.format(StrConfig["qizhan4"], stritem);
		end;
		
		local state,level,num = BingLingUtils:GetActiveState();
		if state == 1 then
			objSwf.activepanel.tfactiveinfo.htmlText = string.format(StrConfig["magicWeapon055"], "#ff0000", level, num);
		elseif state == 2 then
			objSwf.activepanel.tfactiveinfo.htmlText = string.format(StrConfig["magicWeapon056"], "#00ff00", level, num);
		elseif state == 3 then
			objSwf.activepanel.tfactiveinfo.htmlText = string.format(StrConfig["magicWeapon057"], "#ff0000", level, num);
		end
	end
end

--技能鼠标移出
function UIBingLing:OnSkillItemOut(e)
	TipsManager:Hide();
end


---------------------------消息处理---------------------------------
--监听消息列表
function UIBingLing:ListNotificationInterests()
	return {
		NotifyConsts.BingLingUpdate,
		NotifyConsts.BingLingLevelUp,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.BingLingBlessing,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.BagItemNumChange,
		NotifyConsts.BingLingSXDChanged,
		NotifyConsts.SkillLearn,
		NotifyConsts.SkillLvlUp
	};
end

--处理消息
function UIBingLing:HandleNotification(name, body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return; end
	UIBingLingLvlUp:HandleNotification(name, body)
	if name == NotifyConsts.BingLingBlessing then
		self:UpdateShow();
		self:PlayJieSuoEffect(body)
	elseif name == NotifyConsts.BingLingLevelUp then
		self:OnBingLingLvlUp();
	elseif name == NotifyConsts.BagItemNumChange then
		self:ShowActiveInfo();
	elseif name == NotifyConsts.BingLingSXDChanged then
		self:ShowBingLingFight();
		self:ShowBingLingAttr(1);
	elseif name == NotifyConsts.SkillLearn then
		self:ShowBingLingSkill();
	elseif name == NotifyConsts.SkillLvlUp then
		self:ShowBingLingSkill();
	end
end
function UIBingLing:IsShowSound()
	return true;
end

function UIBingLing:IsShowLoading()
	return true;
end

