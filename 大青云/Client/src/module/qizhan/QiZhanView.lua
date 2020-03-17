--[[
骑战：主面板

]]

_G.UIQiZhan = BaseUI:new("UIQiZhan");

--技能列表
UIQiZhan.skilllist = {};
--主动技能列表
UIQiZhan.zhudongskilllist = {};
--当前显示的等阶
UIQiZhan.currentShowLevel = nil;

function UIQiZhan:Create()
	self:AddSWF("qizhanPanel.swf", true, nil)
	self:AddChild( UIQiZhanSkillLvlUp, "qizhanSkillLvlUp");
end
local isShowDes = false
function UIQiZhan:OnLoaded( objSwf )
	self:GetChild("qizhanSkillLvlUp"):SetContainer(objSwf.childPanelSkill);

	objSwf.loader.hitTestDisable = true;
	-- objSwf.btnLvlUp.rollOver         = function() self:OnBtnLvlUpRollOver(); end
	-- objSwf.btnLvlUp.rollOut          = function() self:OnBtnLvlUpRollOut(); end
	-- objSwf.btnLvlUp.click            = function() self:OnBtnLvlUpClick(); end
	objSwf.listSkill.itemRollOver    = function(e) self:OnSkillRollOver(e); end
	objSwf.listSkill.itemRollOut     = function() self:OnSkillRollOut(); end
	objSwf.listSkill.itemClick       = function(e) self:OnSkillClick(e); end
	objSwf.btnPre.click              = function() self:OnBtnPreClick(); end
	objSwf.btnNext.click             = function() self:OnBtnNextClick(); end
	objSwf.nameLoader.loaded         = function(e) self:OnNameLoaded(e); end
	objSwf.chkBoxUseModel.click      = function() self:OnChkBoxUseModelClick() end
	
	--主动技能
	objSwf.listSkillzhudong.itemRollOver    = function(e) self:OnSkillRollOver(e); end
	objSwf.listSkillzhudong.itemRollOut     = function() self:OnSkillRollOut(); end
	objSwf.listSkillzhudong.itemClick       = function(e) self:OnSkillClick(e); end
	objSwf.mcJinjie.btnLvlUp.rollOver = function(e) self:ShowNextLevel(); end
	objSwf.mcJinjie.btnAutoLvlUp.rollOver = function(e) self:ShowNextLevel(); end
	objSwf.mcJinjie.btnLvlUp.rollOut = function(e) self:HideNextLevel(); end
	objSwf.mcJinjie.btnAutoLvlUp.rollOut = function(e) self:HideNextLevel(); end
	
	--激活
	objSwf.activepanel.btnactive.click = function(e) self:OnBtnActiveClick(); end
	objSwf.activepanel.btnactiveinfo.rollOver = function(e) self:OnbtnActiveItemRollOver(); end
	objSwf.activepanel.btnactiveinfo.rollOut = function(e) TipsManager:Hide(); end
	
	objSwf.btnShuXingDan.click = function() self:OnBtnFeedSXDClick() end
	--属性丹tip
	objSwf.btnShuXingDan.rollOver = function() self:OnShuXingDanRollOver(); end
	objSwf.btnShuXingDan.rollOut  = function()  UIMountFeedTip:Hide();  end
	
	self:HideIncrement()
	UIQiZhanLvlUp:OnLoaded(objSwf.mcJinjie)
	
	objSwf.iconDes._alpha = 0
	objSwf.hit.rollOver = function()
		if isShowDes then return end
		local qizhanId = self.currentShowLevel
		if not qizhanId or qizhanId <= 0 then
			FPrint("要显示的骑战id不正确")
			return
		end
		local cfg = t_ridewar[qizhanId]
		if cfg and cfg.des_icon then
			objSwf.iconDes.desLoader.source = ResUtil:GetQiZhanIcon(cfg.des_icon)
		end
		Tween:To(objSwf.iconDes,5,{_alpha=100});
		isShowDes = true
	end

	objSwf.hit.rollOut = function()
		self.isMouseDrag = false
		
		if not isShowDes then return end
		
		Tween:To(objSwf.iconDes,1,{_alpha=0});
		isShowDes = false
	end
end

function UIQiZhan:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	
	UIQiZhanLvlUp:OnDelete()
end

function UIQiZhan:OnShow()
	self:UpdateShow();
	self:UpdateMask()
	self:UpdateCloseButton()
	UIQiZhanLvlUp:OnShow()
end

function UIQiZhan:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
end

function UIQiZhan:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	
	UIQiZhanLvlUp:OnHide()
end

function UIQiZhan:ShowLvlUpPanel(show)
	if not self:IsShow() then return end
	if show == nil then show = true; end
	if show then
		self:ShowChild("qizhanLvlUp");
	else
		UIQiZhanLvlUp:Hide();
	end
end

-- 显示正常的tips
function UIQiZhan:OnSkillRollOver(e)
	local skillInfo = e.item or e.target.data;
	if not skillInfo then return; end
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	--有一个被动技能不需要升级，激活就学习了
	local qizhancfg = t_ridewar[QiZhanConsts.Downid+1];
	if qizhancfg then
		if skillInfo.skillId == qizhancfg.skill_passive then
			local tipsInfo = { skillId = skillInfo.skillId, condition = true, get = QiZhanModel:GetLevel() > 0 ,unShowLvlUpPrompt = true};
			TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
			return;
		end
	end
	local tipsInfo = { skillId = skillInfo.skillId, condition = true, get = skillInfo.lvl > 0 };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

function UIQiZhan:OnSkillRollOut()
	TipsManager:Hide();
end

function UIQiZhan:OnSkillClick(e)
	local skillInfo = e.item or e.target.data;
	if not skillInfo then return; end
	--有一个被动技能不需要升级，激活就学习了
	local qizhancfg = t_ridewar[QiZhanConsts.Downid+1];
	if qizhancfg then
		if skillInfo.skillId == qizhancfg.skill_passive then
			return;
		end
	end
	-- FPrint('显示正常的tips'..skillInfo.skillId..skillInfo.lvl)
	UIQiZhanSkillLvlUp:Open(skillInfo.skillId, skillInfo.lvl);
end

function UIQiZhan:OnbtnActiveItemRollOver()
	if t_consts[147] and t_consts[147].param then
		local desTable = split(t_consts[147].param, ",")
		local itemid = tonumber(desTable[1]);
		if t_item[itemid] then
			TipsManager:ShowItemTips(itemid);
		end
	end
end

function UIQiZhan:OnBtnCloseClick()
	self:Hide();
end

function UIQiZhan:OnBtnPreClick()
	self:ShowQiZhan( self.currentShowLevel - 1, true );
end

function UIQiZhan:OnBtnNextClick()
	self:ShowQiZhan( self.currentShowLevel + 1, true );
end

function UIQiZhan:OnBtnActiveClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local currentLevel = QiZhanModel:GetLevel();
	if currentLevel == 0 then
		if t_consts[147] and t_consts[147].param then
			local desTable = split(t_consts[147].param, ",")
			local itemid = tonumber(desTable[1]);
			local NbNum = BagModel:GetItemNumInBag(itemid);
			if NbNum < tonumber(desTable[2]) then
				FloatManager:AddNormal( StrConfig["qizhan5"], objSwf.activepanel.btnactive);
				return;
			end
		end
		local auto = 1;
		-- if objSwf.activepanel.checkZiDong.selected == true then
			-- auto = 0;
		-- end
		QiZhanController:ReqActiveQiZhan(auto);
	end
end

function UIQiZhan:OnBtnFeedSXDClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local qizhancfg = t_ridewar[QiZhanModel:GetLevel()];
	if not qizhancfg then
		FloatManager:AddNormal( StrConfig["mount18"], objSwf.btnShuXingDan);
		return;
	end
	
	if qizhancfg.attr_dan <= 0 then
		FloatManager:AddNormal( StrConfig["mount18"], objSwf.btnShuXingDan);
		return;
	end
	
	--属性丹上限
	local sXDCount = 0
	for k,cfg in pairs(t_ridewar) do
		if cfg.id == QiZhanModel:GetLevel() then
			sXDCount = cfg.attr_dan
			break
		end
	end
	
	--已达到上限
	if QiZhanModel:GetPillNum() >= sXDCount then
		FloatManager:AddNormal( StrConfig["mount7"], objSwf.btnShuXingDan);
		return
	end
	
	--材料不足
	if MountUtil:GetJieJieItemNum(5) <= 0 then
		FloatManager:AddNormal( StrConfig["mount6"], objSwf.btnShuXingDan);
		return
	end
	
	MountController:FeedShuXingDan(5)
end

--属性丹tip
function UIQiZhan:OnShuXingDanRollOver()
	UIMountFeedTip:OpenPanel(5);
end

function UIQiZhan:OnNameLoaded(e)
	-- local img = e.target.content;
	-- if not img then return end
	-- img._x = img._width * -1;
end

function UIQiZhan:OnChkBoxUseModelClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	local currentShowLevel = self.currentShowLevel
	if not currentShowLevel then return end
	local useThisModel = objSwf.chkBoxUseModel.selected
	local currentLevel = QiZhanModel:GetLevel()
	if currentLevel == currentShowLevel and useThisModel == false then
		-- objSwf.chkBoxUseModel.selected = true
		return
	end
	local modelLevel = useThisModel and currentShowLevel or currentLevel
	QiZhanController:ReqChangeQiZhanModel( modelLevel )
end

-- @param showActive: 是否显示模型激活(开启新等阶时候需要显示)
function UIQiZhan:UpdateShow()
	self:ShowQiZhan(nil, true);
	self:ShowQiZhanSkill();
	self:ShowQiZhanFight();
	self:ShowQiZhanAttr();
	self:ShowUseModelState();
end

local timerKey
function UIQiZhan:OnQiZhanLvlUp()
	self:ShowQiZhan( nil ,true )
	-- if timerKey then
		-- TimerManager:UnRegisterTimer( timerKey )
		-- timerKey = nil
	-- end
	-- timerKey = TimerManager:RegisterTimer( function()
		QiZhanMainUI:Hide()
		UIQiZhanShowView:Show()
		-- timerKey = nil
	-- end, 1000, 1 )
end

function UIQiZhan:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
	self:UpdateCloseButton()
end

function UIQiZhan:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
end

-- 显示等级为level的骑战,如不传,则显示当前等级的骑战
-- showActive: 是否播放激活动作
function UIQiZhan:ShowQiZhan( level, showActive )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local currentLevel = QiZhanModel:GetLevel();
	if not level then
		level = currentLevel;
	end
	if level == 0 then
		level = QiZhanConsts.Downid + 1;
	end
	local cfg = t_ridewar[level];
	if not cfg then return; end
	local isMaxLvl = currentLevel >= QiZhanModel:GetMaxLevel()
	objSwf.nameLoader.source = ResUtil:GetQiZhanIcon(cfg.name_icon);
	objSwf.lvlLoader.source = ResUtil:GetFeedUpLvlImg(level-QiZhanConsts.Downid);
	self:Show3DWeapon(level, showActive);
	objSwf.btnPre.disabled = level <= QiZhanConsts.Downid + 1;
	-- objSwf.btnNext.disabled = (level >= currentLevel + 1) and (not isMaxLvl);
	if level == QiZhanModel:GetMaxLevel() or level >= currentLevel + 1 then
		objSwf.btnNext.disabled = true
	else
		objSwf.btnNext.disabled = false
	end
	self.currentShowLevel = level;
	if currentLevel == 0 then
		objSwf.notGainMC._visible = false
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
			objSwf.notGainMC._visible = true
		else
			self:HideIncrement()
			objSwf.notGainMC._visible = false
		end
	end
	self:ShowUseModelState();
end

-- 显示等级为level的3d骑战模型
-- showActive: 是否播放激活动作
local viewPort;
function UIQiZhan:Show3DWeapon( level, showActive )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not level then
		level = QiZhanModel:GetLevel();
	end
	local cfg = t_ridewar[level];
	if not cfg then
		Error("Cannot find config of QiZhan. level:"..level);
		return;
	end
	-- local modelCfg = t_QiZhanmodel[cfg.model];
	-- if not modelCfg then
		-- Error("Cannot find config of QiZhanModel. id:"..cfg.model);
		-- return;
	-- end
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1333, 732); end
		self.objUIDraw = UISceneDraw:new( "QiZhanUI", objSwf.loader, viewPort );
	end
	self.objUIDraw:SetUILoader(objSwf.loader);
	
	-- local setUIPfxFunc = function()
		-- if modelCfg.effect and modelCfg.effect ~= ""then
			-- self.objUIDraw:PlayNodePfx( cfg.ui_node, modelCfg.effect);
		-- end
	-- end
	
	-- if showActive then
		-- self.objUIDraw:SetScene( cfg.model1, function()
			-- local aniName = cfg.ui_show_action;
			-- if not aniName then return end
			-- if aniName == "" then return end
			-- self.objUIDraw:NodeAnimation( cfg.ui_node, aniName );
			-- -- setUIPfxFunc()
		-- end );
	-- else
		local prof = MainPlayerModel.humanDetailInfo.eaProf
		self.objUIDraw:SetScene(cfg["model"..prof], function()
			local meshFileString = cfg["vmesh" .. prof]
			local meshFileTable = split(meshFileString, "#")
			local meshFile = meshFileTable[1]
			local nodeName = cfg["nodename"]
			local skn = self.objUIDraw:GetNodeMesh(nodeName)
			local skl = self.objUIDraw:GetNodeSkl(nodeName)
			if meshFile and skn then
				local skl = skn.skeleton
				local mesh = _Mesh.new(meshFile)
				local bone_name = "rwh_" .. profString[prof]
				mesh:attachSkeleton(skl, bone_name, mesh.graData:getMarker("rwh"))
				skn:addSubMesh(mesh)

				for i, v in next, mesh:getSubMeshs() do
					v.isPaint = true
				end
				mesh.isPaint = true
				mesh:enumMesh('', true, function(submesh, name)
					local i = submesh:getTexture(0)
					if i and i.resname ~= '' then
						local spemap = i.resname:gsub('.dds$', '_h.dds')
						if spemap 
							and spemap:find('dds')
							and spemap:find('_h')
							and _sys:fileExist(spemap, true) then
							submesh:setSpecularMap(_Image.new(spemap))
						end
																		
					end
				end)

				local pfxListString = cfg["pfxname" .. prof]
				if pfxListString and pfxListString ~= "" then
					local pfxList = GetPoundTable(pfxListString)
					local pfxName = nil
					local boneName = nil
					if #pfxList == 2 then
						pfxName = pfxList[2] .. ".pfx"
						boneName = bone_name
					elseif #pfxList == 1 then
						pfxName = pfxList[1] .. ".pfx"
						boneName = bone_name
					end
					if pfxName and boneName then
						local pfx = skl.pfxPlayer:play(pfxName, pfxName)
				        local BindMat  = skl:getBone(boneName)
				        if BindMat then
				            pfx.transform = BindMat
				        end
				    end
			    end
			end

		end);
	--end
	self.objUIDraw:SetDraw( true );
end

function UIQiZhan:ShowQiZhanSkill()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = SkillUtil:GetPassiveSkillListByShow( SkillConsts.ShowType_QiZhanPassive );
	local listSkill = objSwf.listSkill;
	listSkill.dataProvider:cleanUp();
	for i, vo in ipairs(list) do
		local listVO = QiZhanUtils:GetSkillListVO(vo.skillId, vo.lvl);
		table.push( self.skilllist, listVO );
		listSkill.dataProvider:push( UIData.encode(listVO) );
	end
	listSkill:invalidateData();
	
	--主动技能
	local listzhudong = SkillUtil:GetSkillListByShow( SkillConsts.ShowType_QiZhan );
	local listSkillzhudong = objSwf.listSkillzhudong;
	listSkillzhudong.dataProvider:cleanUp();
	for i, vo in ipairs(listzhudong) do
		local listVO = QiZhanUtils:GetSkillListVO(vo.skillId, vo.lvl);
		table.push( self.zhudongskilllist, listVO );
		listSkillzhudong.dataProvider:push( UIData.encode(listVO) );
	end
	listSkillzhudong:invalidateData();
end

function UIQiZhan:ShowQiZhanFight()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = QiZhanModel:GetLevel();
	local fight = QiZhanUtils:GetFight( level ) or 0;
	objSwf.numLoaderFight.num = fight ;
end

--ly
function UIQiZhan:ShowQiZhanAttr()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = QiZhanModel:GetLevel();
	if level == 0 then
		level = QiZhanConsts.Downid + 1;
	end
	local attrMap = QiZhanUtils:GetQiZhanAttrMap(level);
	if not attrMap then return; end
	local sxdAttrMap = QiZhanUtils:GetQiZhanSXDAttrMap();
	local attrTotal = {};
	for _, attrName in pairs(QiZhanConsts.Attrs) do
		attrTotal[attrName] = attrMap[attrName] + sxdAttrMap[attrName];
		--百分比属性加成
		local attrType = AttrParseUtil.AttMap[attrName];
		local addP = 0;
		if Attr_AttrPMap[attrType] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[attrType]];
		end
		attrTotal[attrName] = toint(attrTotal[attrName] * (1+addP));
	end
	
	local att, def, hp, cri, defcri, dodge, hit = attrTotal["att"],attrTotal["def"],attrTotal["hp"],attrTotal["cri"],attrTotal["defcri"],attrTotal["dodge"],attrTotal["hit"]
	local str = ""
	str = str .. "<textformat leading='16'><p>"
	local addPro = 0
	addPro = att
	if addPro and addPro ~= 0 then
		str = str .. StrConfig["qizhan1001"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = def
	if addPro and addPro ~= 0 then
		str = str .. StrConfig["qizhan1002"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = hp
	if addPro and addPro ~= 0 then
		str = str .. StrConfig["qizhan1003"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = cri
	if addPro and addPro ~= 0 then
		str = str .. StrConfig["qizhan1004"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = defcri
	if addPro and addPro ~= 0 then
		str = str .. StrConfig["qizhan1005"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = dodge
	if addPro and addPro ~= 0 then
		str = str .. StrConfig["qizhan1006"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = hit
	if addPro and addPro ~= 0 then
		str = str .. StrConfig["qizhan1007"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	str = str .. "</p></textformat>"
	objSwf.labProShow.htmlText = str
end

function UIQiZhan:ShowUseModelState()
	local objSwf = self.objSwf
	if not objSwf then return end
	trace(self.currentShowLevel)
	trace(QiZhanModel:GetLevel())
	objSwf.chkBoxUseModel.selected = QiZhanModel:GetSelectLevel() == self.currentShowLevel
	objSwf.chkBoxUseModel.disabled = self.currentShowLevel > QiZhanModel:GetLevel()
end

-- 下阶预览
function UIQiZhan:ShowNextLevel()
	local level = QiZhanModel:GetLevel();
	if level >= QiZhanModel:GetMaxLevel() then return; end
	local nextLevel = level + 1;

	self:ShowQiZhan(nextLevel)
end

-- 隐藏下阶预览
function UIQiZhan:HideNextLevel()
	local level = QiZhanModel:GetLevel();
	self:ShowQiZhan(level)
end
--ly
function UIQiZhan:ShowIncrement()
	local level = QiZhanModel:GetLevel();
	if level >= QiZhanModel:GetMaxLevel() then return; end
	local nextLevel = level + 1;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- objSwf.mcIncrement._visible      = true;
	objSwf.incrementFight._visible    = true;
	-- self:ShowQiZhan(nextLevel);
	local maxFight = QiZhanUtils:GetFight( level ) or 0;
	local nextFight = QiZhanUtils:GetFight( nextLevel ) or 0;
	objSwf.incrementFight.label = nextFight - maxFight;
	local incrementMap = QiZhanUtils:GetAttrIncrementMap(level);
	-- FTrace(incrementMap,'999999999')
	if not incrementMap then return; end
	for i=1,7 do
		objSwf['mcUpArrow'..i]._visible = false
	end
	local upNum = 0
	local totalatt, totaldef, totalhp, totalcri, totaldefcri, totaldodge, totalhit = incrementMap["att"],incrementMap["def"],incrementMap["hp"],incrementMap["cri"],incrementMap["defcri"],incrementMap["dodge"],incrementMap["hit"]
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
			str = str .. '</font><font color = "#2FE00D"> '..addPro ..' </font><br/>'
			
		else
			str = str .. '<br/>'
		end
	end
	addPro = totaldefcri
	if addPro and addPro ~= 0 then
		if addPro ~= 0 then
			upNum = upNum + 1
			str = str .. '</font><font color = "#2FE00D"> '..addPro ..' </font><br/>'
			
		else
			str = str .. '<br/>'
		end
	end
	addPro = totaldodge
	if addPro and addPro ~= 0 then
		if addPro ~= 0 then
			upNum = upNum + 1
			str = str .. '</font><font color = "#2FE00D"> '..addPro ..' </font><br/>'
			
		else
			str = str .. '<br/>'
		end
	end
	addPro = totalhit
	if addPro and addPro ~= 0 then
		if addPro ~= 0 then
			upNum = upNum + 1
			str = str .. '</font><font color = "#2FE00D"> '..addPro ..' </font><br/>'
			
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
function UIQiZhan:HideIncrement()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if QiZhanController.isAutoLvlUp then
		return
	end
	-- objSwf.mcIncrement._visible      = false;
	objSwf.incrementFight._visible    = false;
	
	for i=1,7 do
		objSwf['mcUpArrow'..i]._visible = false
	end
	objSwf.labProUpShow.htmlText = ''
	
	local level = QiZhanModel:GetLevel();
	-- self:ShowQiZhan(level);
end

function UIQiZhan:ShowActiveInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.activepanel._visible = false;
	local currentLevel = QiZhanModel:GetLevel();
	if currentLevel == 0 then
		objSwf.activepanel._visible = true;
		objSwf.activepanel.checkZiDong._visible = false;
		objSwf.activepanel.btnactiveinfo.htmlText = "";
		if t_consts[147] and t_consts[147].param then
			local desTable = split(t_consts[147].param, ",")
			local itemid = tonumber(desTable[1]);
			local NbNum = BagModel:GetItemNumInBag(itemid);
			local stritem = t_item[itemid].name..desTable[2]
			if NbNum >= tonumber(desTable[2]) then
				objSwf.activepanel.btnactiveinfo.htmlLabel = string.format(StrConfig["qizhan3"], stritem);
			else
				objSwf.activepanel.btnactiveinfo.htmlLabel = string.format(StrConfig["qizhan4"], stritem);
			end;
		end
	end
end

--技能鼠标移出
function UIQiZhan:OnSkillItemOut(e)
	TipsManager:Hide();
end


---------------------------消息处理---------------------------------
--监听消息列表
function UIQiZhan:ListNotificationInterests()
	return {
		NotifyConsts.QiZhanUpdate,
		NotifyConsts.QiZhanLevelUp,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.QiZhanBlessing,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.BagItemNumChange,
		NotifyConsts.QiZhanSXDChanged,
		NotifyConsts.SkillLearn,
		NotifyConsts.SkillLvlUp
	};
end

--处理消息
function UIQiZhan:HandleNotification(name, body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return; end
	UIQiZhanLvlUp:HandleNotification(name, body)
	if name == NotifyConsts.QiZhanUpdate then
		self:UpdateShow();
	elseif name == NotifyConsts.QiZhanLevelUp then
		self:OnQiZhanLvlUp();
		self:ShowUseModelState();
	elseif name == NotifyConsts.BagItemNumChange then
		self:ShowActiveInfo();
	elseif name == NotifyConsts.QiZhanSXDChanged then
		self:ShowQiZhanFight();
		self:ShowQiZhanAttr();
	elseif name == NotifyConsts.SkillLearn then
		self:ShowQiZhanSkill();
	elseif name == NotifyConsts.SkillLvlUp then
		self:ShowQiZhanSkill();
	elseif name == NotifyConsts.ChangeQiZhanModel then
		self:ShowUseModelState();
	end
end
function UIQiZhan:IsShowSound()
	return true;
end

function UIQiZhan:IsShowLoading()
	return true;
end

