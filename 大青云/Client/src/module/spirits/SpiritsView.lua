--[[神兽
liyuan
2014年9月28日10:33:06
]]

_G.UISpirits = BaseUI:new("UISpirits") 

UISpirits.checkBox = {} 
UISpirits.showType = SpiritsConsts.ShowType_All  --显示类型
UISpirits.hunzhuNum = 5
UISpirits.starthunzhuX = 482
UISpirits.starthunzhuY = 443
UISpirits.hunzhuGap = 63
UISpirits.isShowConfirm = false

UISpirits.selid = 0;
UISpirits.roleRender = nil
UISpirits.roleVO = nil
UISpirits.isShowAni = true
local last3dId = 0
function UISpirits:Create()
	self:AddSWF("spiritsPanel.swf", true, nil)
end

local uispiritsisShowDes = false
local uispiritsmouseMoveX = 0
function UISpirits:OnLoaded(objSwf,name)
	self.roleRender = RoleDrawRender:New(objSwf.roleLoader, 'UISpirits',true)
	objSwf.btnqiyong.click = function() self:OnBtnQiYOngClick() end
	objSwf.btnnoqiyong.click = function() self:OnBtnNoQiYOngClick() end
	objSwf.yishiyongeffect.complete = function()
									objSwf.imgqiyong._visible = true;
									objSwf.btnnoqiyong.visible = true;
								end
	objSwf.tileListWuhun.itemClick1 = function(e) self:OnListItemClick(e); end
	
	--checkBox
	self.checkBox[SpiritsConsts.ShowType_All] = objSwf.checkAll 
	self.checkBox[SpiritsConsts.ShowType_ZHANDOU] = objSwf.check1 
	self.checkBox[SpiritsConsts.ShowType_FUZHU] = objSwf.check2 
	self.checkBox[SpiritsConsts.ShowType_BIANYI] = objSwf.check3 
	
	for k,cBox in pairs(self.checkBox) do
		cBox.click = function() self:OnCBoxClick(k)  end
	end
	
	--战斗力值居中
	self.numFightx = objSwf.numLoaderFight._x
	objSwf.numLoaderFight.loadComplete = function()
									objSwf.numLoaderFight._x = self.numFightx - objSwf.numLoaderFight.width / 2
								end
	
	--objSwf.getpanel.btnJihuotiaojian.rollOver = function() self:ShowJihuotiaojian() end
	--objSwf.getpanel.btnJihuotiaojian.rollOut = function() self:HideJihuotiaojian() end
	
	objSwf.tileListzhudong.itemRollOver = function(e) self:OnSkillItemOver(e); end
	objSwf.tileListzhudong.itemRollOut = function(e) self:OnSkillItemOut(e); end
	objSwf.tileListbeidong.itemRollOver = function(e) self:OnSkillItemOver(e); end
	objSwf.tileListbeidong.itemRollOut = function(e) self:OnSkillItemOut(e); end
	
	self:HideAllHunZhunEffect(objSwf)
	
	objSwf.getpanel.btnactiveinfo.rollOver = function() self:OnActiveInfoRollOver(); end
	objSwf.getpanel.btnactiveinfo.rollOut  = function()  TipsManager:Hide(); end
	
	-- objSwf.labPower.text = UIStrConfig['wuhun19']
	-- objSwf.labAddPro.text = UIStrConfig['wuhun5']
	-- objSwf.labWuhunJinjie.text = UIStrConfig['wuhun7']
	
	for i=1,7 do
		objSwf['mcUpArrow'..i]._visible = false;
	end
	objSwf.incrementFight._visible = false;
	
	-- objSwf.txtUpZhanDouLi._visible = false
	-- objSwf.mcUpArrowZhanDouLi._visible = false
	-- objSwf.fight.numFight.loadComplete = function()	
										-- objSwf.fight.numFight.x = 580 + (230 - objSwf.fight.numFight.width)/2
										-- objSwf.mcUpArrowZhanDouLi._x = objSwf.fight.numFight.x + objSwf.fight.numFight.width + 25;
										-- objSwf.txtUpZhanDouLi._x = objSwf.mcUpArrowZhanDouLi._x + 5
								   -- end
	objSwf.imgName.loaded = function()
		-- objSwf.imgName._x = 159 + (432 - objSwf.imgName.content._width)/2
		-- objSwf.imgLevel._x = objSwf.imgName._x + objSwf.imgName.content._width + 5;
	end
	
	objSwf.btnRadioLinshou.click = function() 
		local wuhunCfg = t_wuhunachieve[self.selid]
		if not wuhunCfg then
			return
		end
		
		local cfg = t_lingshouui[wuhunCfg.ui_id];
		if not cfg then
			Error("Cannot find config of t_lingshouui. level:"..level);
			return;
		end
		--objSwf.roleLoader._visible = false
		if self.roleRender then 
			self.roleRender:OnHide()
		end
		if self.objUIDraw then
			local dataArr = split(cfg.ui_node,"#");
			for k,v in pairs (dataArr) do
				self.objUIDraw:NodeVisible(v,true)
			end
		end
	end
	objSwf.btnRadioShenshou.click = function() 
		local wuhunCfg = t_wuhunachieve[self.selid]
		if not wuhunCfg then
			return
		end
		
		local cfg = t_lingshouui[wuhunCfg.ui_id];
		if not cfg then
			Error("Cannot find config of t_lingshouui. level:"..level);
			return;
		end
		--objSwf.roleLoader._visible = true
		self:SetRoleRender(self.selid)
		if self.objUIDraw then
			local dataArr = split(cfg.ui_node,"#");
			for k,v in pairs (dataArr) do
				self.objUIDraw:NodeVisible(v,false)
			end
		end
	end
	
	objSwf.iconDes._alpha = 0
	objSwf.btnDesShow.rollOver = function()
		if uispiritsisShowDes then return end
		local wuhunId = self.selid
		if not wuhunId or wuhunId <= 0 then
			return
		end
		local wuhunCfg = t_wuhunachieve[wuhunId]
		if not wuhunCfg then
			return
		end
		
		local cfg = t_lingshouui[wuhunCfg.ui_id];
		if not cfg then
			Error("Cannot find config of t_lingshouui. level:"..level);
			return;
		end
		if cfg and cfg.des_icon then
			objSwf.iconDes.desLoader.source = ResUtil:GetWuhunDesIcon(cfg.des_icon)
		end
		Tween:To(objSwf.iconDes,5,{_alpha=100});
		uispiritsisShowDes = true
	end

	objSwf.btnDesShow.rollOut = function()
		self.isMouseDrag = false
		if self.objUIDraw then
		
			self.objUIDraw:OnBtnRoleRightStateChange("out"); 				
		end
		if self.roleRender then
			self.roleRender:OnBtnRoleRightStateChange("out");
		end
		if not uispiritsisShowDes then return end
		
		Tween:To(objSwf.iconDes,1,{_alpha=0});
		uispiritsisShowDes = false
	end
	
	objSwf.btnDesShow.press = function() 		
		local monsePosX = _sys:getRelativeMouse().x;--获取鼠标位置		
		uispiritsmouseMoveX = monsePosX;   		       
		self.isMouseDrag = true
	end

	objSwf.btnDesShow.release = function()
		self.isMouseDrag = false
		if self.objUIDraw then
			self.objUIDraw:OnBtnRoleRightStateChange("release"); 				
		end
		if self.roleRender then
			self.roleRender:OnBtnRoleRightStateChange("release");
		end
	end
end

function UISpirits:OnDelete()
	for k,_ in pairs(self.checkBox) do
		self.checkBox[k] = nil;
	end
	if self.roleRender then
		self.roleRender:OnDelete()
		self.roleRender = nil;
	end
	
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UISpirits:Update()
	local objSwf = self:GetSWF("UISpirits")
	if not objSwf then return end
	if not self.bShowState then return end
	
	if objSwf.btnRadioShenshou.selected then
		if self.roleRender then 
			self.roleRender:Update() 
		end
	end
	
	
	if self.isMouseDrag then
		local monsePosX = _sys:getRelativeMouse().x;--获取鼠标位置		
		if uispiritsmouseMoveX<monsePosX then
			local speed = monsePosX - uispiritsmouseMoveX
			if objSwf.btnRadioLinshou.selected and self.objUIDraw then
				self.objUIDraw:OnBtnRoleRightStateChange("down",speed); 
			end
			if objSwf.btnRadioShenshou.selected and self.roleRender then 
				self.roleRender:OnBtnRoleRightStateChange("down",speed); 
			end
		elseif uispiritsmouseMoveX>monsePosX then 
			local speed = uispiritsmouseMoveX - monsePosX
			if objSwf.btnRadioLinshou.selected and self.objUIDraw then
				self.objUIDraw:OnBtnRoleLeftStateChange("down",speed);
			end
			if objSwf.btnRadioShenshou.selected and self.roleRender then 
				self.roleRender:OnBtnRoleLeftStateChange("down",speed); 
			end
		end
		uispiritsmouseMoveX = monsePosX;
	end
	
	
	local wuhunCfg = t_wuhunachieve[self.selid]
	if not wuhunCfg then
		return
	end
	
	local cfg = t_lingshouui[wuhunCfg.ui_id];
	if not cfg then
		Error("Cannot find config of t_lingshouui. level:"..level);
		return;
	end
	
	local ui_node =  MountUtil:GetMountSen(cfg.ui_node,MainPlayerModel.humanDetailInfo.eaProf);
	
	if objSwf.btnRadioLinshou.selected then
		if self.objUIDraw then
			self.objUIDraw:Update(ui_node);
		end
	end
end

function UISpirits:GetWidth(szName)
	return 870 
end

function UISpirits:GetHeight(szName)
	return 732
end

function UISpirits:OnShow(name)
	local objSwf = self:GetSWF("UISpirits")
	if not objSwf then return end
	self:InitData();
	self:ShowWuhunList()
	self:ShowWuhunInfo(self.selid);
	self:SetZhanshouAndLingshou()
end

function UISpirits:InitData()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	self.selid = 1001;
	self.isShowAni = true
	
	self.openlist = {};
	local vo1 = {};
	vo1.label1 = 1;
	table.push(self.openlist, vo1);
	local vo2 = {};
	vo2.label1 = 1;
	vo2.label2 = 1001;
	table.push(self.openlist, vo2);
end

function UISpirits:SetZhanshouAndLingshou()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local wuhunCfg = t_wuhunachieve[self.selid]
	if not wuhunCfg then
		return
	end
	
	local cfg = t_lingshouui[wuhunCfg.ui_id];
	if not cfg then
		Error("Cannot find config of t_lingshouui. level:"..level);
		return;
	end
	
	if objSwf.btnRadioLinshou.selected then
		--objSwf.roleLoader._visible = false
		if self.roleRender then 
			self.roleRender:OnHide()
		end
		if self.objUIDraw then
			local dataArr = split(cfg.ui_node,"#");
			for k,v in pairs (dataArr) do
				self.objUIDraw:NodeVisible(v,true)
			end
		end
	else
		--objSwf.roleLoader._visible = true
		self:SetRoleRender(self.selid)
		if self.objUIDraw then
			local dataArr = split(cfg.ui_node,"#");
			for k,v in pairs (dataArr) do
				self.objUIDraw:NodeVisible(v,false)
			end
		end
	end
end

function UISpirits:OnActiveInfoRollOver()
	local itemid = tonumber(t_wuhunachieve[self.selid].active_if);
	local itmevo = t_item[itemid];
	if itmevo then
		TipsManager:ShowItemTips(itemid);
	end
end

function UISpirits:OnFullShow()
	local objSwf = self:GetSWF("UISpirits")
	if not objSwf then return end
	self.firstOpenState = false
	
	if not self.selid or self.selid == 0 then return end
	
	self:SetRoleRender(self.selid)
end

--点击关闭按钮
function UISpirits:OnBtnCloseClick()
	self:Hide() 
end

function UISpirits:OnHide()
	last3dId = 0
	self.firstOpenState = true
	UIConfirm:Close(self.confirmUID);
	self.isShowConfirm = false
	if self.roleRender then 
		self.roleRender:OnHide()
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

---------------------------------ui事件处理------------------------------------

--切换checkBox
function UISpirits:OnCBoxClick(name)
	self.showType = name 
	if name == SpiritsConsts.ShowType_All then
		for k,cBox in pairs(self.checkBox) do
			cBox.selected = true
		end
	else
		self.checkBox[SpiritsConsts.ShowType_All].selected = false 
	end
	
	local checkNum = 0
	for k,cBox in pairs(self.checkBox) do
		if k ~= SpiritsConsts.ShowType_All and cBox.selected == true then
			checkNum = checkNum + 1 
		end
	end
	
	if checkNum == 0 then
		self.checkBox[name].selected = true
	elseif checkNum == 3 then
		self.checkBox[SpiritsConsts.ShowType_All].selected = true
	end
	-- self:ShowList() 
end

-- 激活按钮的响应
function UISpirits:OnBtnActiveClick()
	if not self.selid or self.selid == 0 then return end
	local ret = LinshouUtil:isActiveConditionReached(self.selid);
	if ret == true then
		--SpiritsController:ActiveWuhun(self.selid);
	else
		
	end
end

function UISpirits:OnBtnQiYOngClick()
	if LinshouUtil:GetLinshouTime(self.selid) ~= 0 then
		--当前使用的是灵兽
		if not LinshouModel:getWuhuVO(SpiritsModel.selectedWuhunId) then
			SpiritsController:AhjunctionWuhun(self.selid, SpiritsModel:GetWuhunState());
		else
			SpiritsController:AhjunctionWuhun(self.selid, LinshouModel:getWuhuVO(SpiritsModel.selectedWuhunId).wuhunState);
		end
	end
end

function UISpirits:OnBtnNoQiYOngClick()
	if LinshouUtil:GetLinshouTime(self.selid) ~= 0 then
		SpiritsController:AhjunctionWuhun(SpiritsModel.currentWuhun.wuhunId, LinshouModel:getWuhuVO(self.selid).wuhunState);
	end
end

-- 附身按钮的响应
function UISpirits:AhjunctionWuhun()
	if not LinshouModel.selectedWuhunId or LinshouModel.selectedWuhunId == 0 then return end
	if LinshouModel:GetWuhunState(LinshouModel.selectedWuhunId) == 1 then
		SpiritsController:AhjunctionWuhunshenshou(LinshouModel.selectedWuhunId, 1)
	elseif LinshouModel:GetWuhunState(LinshouModel.selectedWuhunId) == 2 then
		SpiritsController:AhjunctionWuhunshenshou(LinshouModel.selectedWuhunId, 0)
	end
end

--技能鼠标移上
function UISpirits:OnSkillItemOver(e)
	if not e.item.skillId then return; end
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=tonumber(e.item.skillId)},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightUp);
end

--技能鼠标移出
function UISpirits:OnSkillItemOut(e)
	TipsManager:Hide();
end

--激活道具鼠标移上
function UISpirits:ShowJihuotiaojian(e)
	-- LinshouUtil:Print("ssssssss")
	if not LinshouModel.selectedWuhunId or LinshouModel.selectedWuhunId == 0 then return end
	local objSwf = self:GetSWF("UISpirits")
	local itemId = LinshouUtil:GetActiveItemId(LinshouModel.selectedWuhunId)
	if itemId > 0 then
		TipsManager:ShowItemTips(itemId)
	end
end

--激活道具鼠标移出
function UISpirits:HideJihuotiaojian(e)
	TipsManager:Hide();
end

function UISpirits:GetAttributeUpValueStr(att, def, hp, hit, dodge, critical, defcri)
	local tipStr = ''
	if att > 0 then
		tipStr = tipStr .. '<br/>' .. StrConfig['wuhun39'] ..'  '.. att
	end
	if def > 0 then
		tipStr = tipStr .. '<br/>' .. StrConfig['wuhun40'] ..'  '..  def
	end
	if hp > 0 then
		tipStr = tipStr .. '<br/>' .. StrConfig['wuhun41'] ..'  '..  hp
	end
	if hit > 0 then
		tipStr = tipStr .. '<br/>' .. StrConfig['wuhun44'] ..'  '..  hit
	end
	if dodge > 0 then
		tipStr = tipStr .. '<br/>' .. StrConfig['wuhun43'] ..'  '..  dodge
	end
	if critical > 0 then
		tipStr = tipStr .. '<br/>' .. StrConfig['wuhun42'] ..'  '..  critical
	end
	if defcri > 0 then
		tipStr = tipStr .. '<br/>' .. StrConfig['wuhun42'] ..'  '..  defcri
	end
	
	return tipStr
end

---------------------------------消息处理------------------------------------

--监听消息
function UISpirits:ListNotificationInterests()
	return {
		NotifyConsts.WuhunListUpdate, 
		-- NotifyConsts.WuhunUpdateFeed,
		NotifyConsts.BagItemNumChange,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.PlayerModelChange,
		NotifyConsts.WuhunFushenChanged,
		-- NotifyConsts.WuhunLevelUpUpdate,
	} 
end

--处理消息
function UISpirits:HandleNotification(name, body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	if name == NotifyConsts.WuhunListUpdate then
		self:ShowWuhunList() 
		self:ShowQiYongInfo();
		self:PlayYiShiYongEffect(body);
	elseif name == NotifyConsts.WuhunUpdateFeed then
		-- self:UpdateFeed(body.isShowFeedEffect)
	elseif name == NotifyConsts.BagItemNumChange then
		for wuhunId,wuhunVO in pairs(LinshouModel.shenshouList) do
			local itemId = LinshouUtil:GetActiveItemId(wuhunId)
			if itemId > 0 then
				if itemId == body.id then
					local cfg = t_wuhunachieve[wuhunId]
					if not cfg then return end
					
					-- 激活条件
					if wuhunId == LinshouModel.selectedWuhunId then
						self:UpdateActiveCondition(wuhunId)
					end
					
					if wuhunVO.wuhunState == 0 then
						local isReach = LinshouUtil:isActiveConditionReached(wuhunId)
						if isReach then
							self:ShowWuhunList()
						end
					end
				end
			end
		end
		self:UpdateActiveCondition(self.selid);
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaLevel then
			for wuhunId,wuhunVO in pairs(LinshouModel.shenshouList) do
				local cfg = t_wuhunachieve[wuhunId]
				if not cfg then return end
				-- 激活条件
				if wuhunId == LinshouModel.selectedWuhunId then
					self:UpdateActiveCondition(wuhunId)
				end
				if wuhunVO.wuhunState == 0 then
					local isReach = LinshouUtil:isActiveConditionReached(wuhunId)
					if isReach then
						self:ShowWuhunList()
					end
				end
			end
		end
	elseif name == NotifyConsts.WuhunLevelUpUpdate then
		-- if body.isSucc then 
			-- local w,h = UIManager:GetWinSize()
			-- local pos = {w + 147,h + 167};
			-- UIEffectManager:PlayEffect(ResUtil:GetJinJieSuccess(),pos);
		-- end
	elseif name == NotifyConsts.PlayerModelChange then
		self:ShowWuhunInfo(LinshouModel.selectedWuhunId)
	elseif name == NotifyConsts.WuhunFushenChanged then
		self:ShowQiYongInfo();
	end
end

---------------------------------ui逻辑------------------------------------

-- 更新武魂列表
function UISpirits:ShowWuhunList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local treeData = LinshouUtil:GetLinshouSkinList(self.openlist);
	if not treeData then return; end
	UIData.cleanTreeData( objSwf.tileListWuhun.dataProvider.rootNode);
	UIData.copyDataToTree(treeData,objSwf.tileListWuhun.dataProvider.rootNode);
	objSwf.tileListWuhun.dataProvider:preProcessRoot();
	objSwf.tileListWuhun:invalidateData();
end

-- 显示武魂详细信息
function UISpirits:ShowWuhunInfo(wuhunId)
	local objSwf = self:GetSWF("UISpirits") 
	if not objSwf then return end
	
	if not wuhunId or wuhunId <= 0 then
		FPrint("要显示的武魂id不正确")
		return
	end
	
	local cfg = t_wuhunachieve[wuhunId]
	if not cfg then return end
	
	if not self.firstOpenState then
		self:SetRoleRender(wuhunId)
	end
	
	local uiCfg = t_lingshouui[cfg.ui_id]
	if uiCfg then
		if objSwf.imgName.source ~= ResUtil:GetWuhunIcon(uiCfg.name_icon) then
			objSwf.imgName.source = ResUtil:GetWuhunIcon(uiCfg.name_icon)
		end
	end
	
	local lvlStr = tostring(cfg.order);
	if cfg.order == 10 then lvlStr = "a" end;
	-- objSwf.imgLevel:drawStr( lvlStr );
	-- objSwf.imgLevel.source = ResUtil:GetWuhunLevelIconBig(cfg.order)
	
	-- 激活条件
	self:UpdateActiveCondition(wuhunId)	
	-- 附身按钮状态
	self:UpdateFushenState(wuhunId, objSwf, cfg)	
	-- 被动技能
	self:UpdateSkill(wuhunId, objSwf, cfg) 
	-- 魂珠更新
	self:HideAllHunZhunEffect(objSwf)
	-- 属性
	self:UpdateProperty(wuhunId, objSwf, cfg)
	self:Show3DWeapon(wuhunId, false);
	--是否启用
	self:ShowQiYongInfo();
end

-- 属性
function UISpirits:UpdateProperty(wuhunId, objSwf, cfg)
	local str = ""
	str = str .. "<textformat leading='16'><p>"
	local addPro = 0
	addPro = (cfg.prop_attack or 0)
	if addPro and addPro ~= 0 then
		str = str .. StrConfig["wuhun7"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = (cfg.prop_defend or 0)
	if addPro and addPro ~= 0 then
		str = str .. StrConfig["wuhun8"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = (cfg.prop_hp or 0)
	if addPro and addPro ~= 0 then
		str = str .. StrConfig["wuhun9"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = (cfg.prop_critical or 0)
	if addPro and addPro ~= 0 then
		str = str .. StrConfig["wuhun10"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = (cfg.prop_dodge or 0)
	if addPro and addPro ~= 0 then
		str = str .. StrConfig["wuhun11"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = (cfg.prop_hit or 0)
	if addPro and addPro ~= 0 then
		str = str .. StrConfig["wuhun12"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	
	addPro = (cfg.prop_defcri or 0)
	if addPro and addPro ~= 0 then
		str = str .. StrConfig["wuhun50"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	
	--特殊属性
	local strAttr = cfg.skin_attr;
	if strAttr then
		local formulaList = AttrParseUtil:Parse(strAttr)
		for i,attrcfg in pairs(formulaList) do
			local vo = {};
			addPro = attrcfg.val;
			if addPro and addPro ~= 0 then
				str = str .. enAttrTypeName[attrcfg.type]..':    <font color = "#FBBF78"> '..string.format("%.2f",addPro*100).."% </font><br/>"
			end
		end
	end
	str = str .. "</p></textformat>"
	
	str = str .. "123"
	objSwf.labProShow.htmlText = str
	-- 战斗力显示
	local list = {}
	
	if (cfg.prop_attack) ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaGongJi;
		vo.val = (cfg.prop_attack);
		table.push(list,vo);
	end
	
	if (cfg.prop_defend) ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaFangYu;
		vo.val = (cfg.prop_defend);
		table.push(list,vo);
	end
	
	if (cfg.prop_hp) ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaMaxHp;
		vo.val = (cfg.prop_hp);
		table.push(list,vo);
	end
	
	if (cfg.prop_hit) ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaMingZhong;
		vo.val = (cfg.prop_hit);
		table.push(list,vo);
	end
	
	if (cfg.prop_dodge) ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaShanBi;
		vo.val = (cfg.prop_dodge);
		table.push(list,vo);
	end
	
	if (cfg.prop_critical) ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaBaoJi;
		vo.val = (cfg.prop_critical);
		table.push(list,vo);
	end
	
	if (cfg.prop_defcri) ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaRenXing;
		vo.val = (cfg.prop_defcri);
		table.push(list,vo);
	end
	
	local strSkinAttr = cfg.skin_attr;
	if strSkinAttr then
		local formulaList = AttrParseUtil:Parse(strSkinAttr)
		for i,attrcfg in pairs(formulaList) do
			local vo = {};
			vo.type = attrcfg.type;
			vo.val = attrcfg.val;
			table.push(list,vo);
		end
	end
	
	-- SpiritsUtil:Trace(list)
	objSwf.numLoaderFight.num = EquipUtil:GetFight(list);
end

--是否启用
function UISpirits:ShowQiYongInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.btnqiyong.visible = false;
	objSwf.btnnoqiyong.visible = false;
	objSwf.imgqiyong._visible = false;
	objSwf.yishiyongeffect:stopEffect();
	objSwf.yishiyongeffect._visible = false;
	local list = LinshouModel:GetShenShouList();
	local vo = list[self.selid];
	if vo then
		if vo.time ~= 0 then
			if SpiritsModel.selectedWuhunId == self.selid then
				objSwf.imgqiyong._visible = true;
				objSwf.btnnoqiyong.visible = true;
			else
				objSwf.btnqiyong.visible = true;
			end
		end
	end
end

--更新信息
function UISpirits:PlayYiShiYongEffect(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.yishiyongeffect:stopEffect();
	objSwf.yishiyongeffect._visible = false;
	if body and body.ischange and body.ischange == true then
		if SpiritsModel.selectedWuhunId == self.selid then
			objSwf.yishiyongeffect._visible = true;
			objSwf.yishiyongeffect:playEffect(1);
			objSwf.btnqiyong.visible = false;
			objSwf.imgqiyong._visible = false;
		end
	end
end

-- 技能
function UISpirits:UpdateSkill(wuhunId, objSwf, cfg)
	-- 被动技能
	local skillBeidongs = LinshouUtil:GetWuhunSkillBeidong(wuhunId)
	if skillBeidongs then 
		objSwf.tileListbeidong.dataProvider:cleanUp() 
		for i, wuhun in pairs(skillBeidongs) do
			objSwf.tileListbeidong.dataProvider:push( UIData.encode(wuhun) )
		end
		objSwf.tileListbeidong:invalidateData() 
		local wuhunvo = t_wuhunachieve[wuhunId];
		if wuhunvo then
			local skillId = wuhunvo.active_skillpassive;
			objSwf.tfbeidongskillinfo.text = t_passiveskill[skillId].des;
		end
	end
	
	-- 主动技能
	local skillZhudongs = LinshouUtil:GetWuhunSkillZhudong(wuhunId)
	if skillZhudongs then
		objSwf.tileListzhudong.dataProvider:cleanUp() 
		for j, wuhun in pairs(skillZhudongs) do
			objSwf.tileListzhudong.dataProvider:push( UIData.encode(wuhun) )
		end
		objSwf.tileListzhudong:invalidateData()
		local wuhunvo = t_wuhunachieve[wuhunId];
		if wuhunvo then
			local tskill = wuhunvo.active_skill;
			objSwf.tfzhudongskillinfo.text = t_skill[tskill[2]].des;
		end
	end
end

-- 附身按钮状态
function UISpirits:UpdateFushenState(wuhunId, objSwf, cfg)
	-- objSwf.btnFusheng.disabled = false
	-- if LinshouModel:GetWuhunState(wuhunId) == 1 then
		-- objSwf.btnFusheng.label = UIStrConfig["wuhun4"]
	-- elseif LinshouModel:GetWuhunState(wuhunId) == 2 then
		-- objSwf.btnFusheng.label = StrConfig["wuhun23"]
	-- else
		-- objSwf.btnFusheng.label = UIStrConfig["wuhun4"]
		-- objSwf.btnFusheng.disabled = true
	-- end
end

-- 激活条件
function UISpirits:UpdateActiveCondition(wuhunId)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.imgnotget._visible = false;
	if LinshouModel:IsShenShouActive(wuhunId) == true then
		objSwf.getpanel._visible = false
		-- objSwf.nsFeedNum.disabled = false
	else
		objSwf.imgnotget._visible = true;
		objSwf.getpanel.btnactiveinfo.htmlLabel = "";
		local itemid = tonumber(t_wuhunachieve[wuhunId].active_if);
		if itemid and t_item[itemid] then
			local intemNum = BagModel:GetItemNumInBag(itemid);
			local stritem = "";
			if intemNum > 0 then
				stritem = "<font color='#00ff00'><u>"..t_item[itemid].name.."</u></font>";
			else
				stritem = "<font color='#cc0000'><u>"..t_item[itemid].name.."</u></font>";
			end
			objSwf.getpanel._visible = true
			objSwf.getpanel.btnactiveinfo.htmlLabel = string.format( StrConfig["mount34"], stritem)
		end
		
		-- objSwf.nsFeedNum.disabled = true
		-- objSwf.nsFeedNum.value = 0
	end
	
	
end

-- 魂珠更新
local lastHunzhu = nil
local showHunzhu = 0
local currentHunzhu = 0
local shangxian = 0 -- 喂养进度上限
local feedValue = 0
local feedNum = 0
function UISpirits:UpdateFeed(isShowFeedEffect)
	
end

function UISpirits:qiuFunc()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	--升满的播特效 正在升的图标 未升的灰色图标
	if not LinshouModel.selectedWuhunId or LinshouModel.selectedWuhunId == 0 then return end
	local wuhunId = LinshouModel.selectedWuhunId
	local cfg = t_wuhunachieve[wuhunId]
	
end

function UISpirits:qiu1Func()
	
end

function UISpirits:startQiuFunc()
	
end

function UISpirits:SetUILoaderUrl(ballUrl, ballLoader, isSwf)
	if ballUrl and ballUrl ~= "" then
		if isSwf then
			UILoaderManager:LoadList({ballUrl}, function()
				if ballLoader.source ~= ballUrl then
					ballLoader.source = ballUrl
				end
			end)	
		else
			if ballLoader.source ~= ballUrl then
				ballLoader.source = ballUrl
			end
		end
	else
		ballLoader:unload()
	end
end

function UISpirits:HideAllHunZhunEffect(objSwf)
end

function UISpirits:SetRoleRender(wuhunId)
	-- if self.roleVO and self.roleVO.wuhunId == wuhunId and not firstOpenState then
		-- return
	-- end

	--if not self.roleVO then
		self.roleVO = {}
		local info = MainPlayerModel.sMeShowInfo;
		self.roleVO.prof = MainPlayerModel.humanDetailInfo.eaProf
		self.roleVO.arms = info.dwArms
		self.roleVO.dress = info.dwDress
		self.roleVO.fashionsHead = info.dwFashionsHead
		self.roleVO.fashionsArms = info.dwFashionsArms
		self.roleVO.fashionsDress = info.dwFashionsDress
		self.roleVO.wing = info.dwWing
		self.roleVO.suitflag = info.suitflag
		self.roleVO.sex = info.dwSex
	--end
	self.roleVO.wuhunId = wuhunId
	self.roleRender:DrawRole(self.roleVO, true)
end

--获取Html文本
--@param text 显示的内容
--@param color 字体颜色
--@param size 字号
--@param withBr 是否换行,默认true
--@param bold 	是否加粗,默认false
function UISpirits:GetHtmlText(text,color,size,withBr,bold)
	if not color then color = TipsConsts.Default_Color; end
	if not size then size = TipsConsts.Default_Size; end
	if withBr==nil then withBr = true; end
	if bold==nil then bold = false; end
	local str = "<font color='" .. color .."' size='" .. size .. "'>";
	if bold then
		str = str .. "<b>" .. text .. "</b>";
	else
		str = str .. text;
	end
	str = str .. "</font>";
	if withBr then
		str = str .. "<br/>";
	end
	return str;
end

-- 显示灵兽模型
local viewUISpiritsPort;
function UISpirits:Show3DWeapon(wuhunId, showActive)
	if last3dId == wuhunId then return end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local wuhunCfg = t_wuhunachieve[wuhunId]
	if not wuhunCfg then
		return
	end
	
	local cfg = t_lingshouui[wuhunCfg.ui_id];
	if not cfg then
		Error("Cannot find config of t_lingshouui. level:"..level);
		return;
	end
	
	if not self.objUIDraw then
		if not viewUISpiritsPort then viewUISpiritsPort = _Vector2.new(1333, 762); end
		self.objUIDraw = UISceneDraw:new( "UISpiritsScene", objSwf.loader, viewUISpiritsPort );
	end
	self.objUIDraw:SetUILoader(objSwf.loader);
	
	
	
	if self.isShowAni then
		self.objUIDraw:SetScene( cfg.ui_sen, function()
			self:SetZhanshouAndLingshou()
			if not objSwf.btnRadioLinshou.selected then return end
			
			local modelCfg = t_lingshoumodel[cfg.model]
			if not modelCfg then return end
			
			local aniName = modelCfg.san_idle;
			if not aniName or aniName == "" then return end
			if not cfg.ui_node then return end
			local nodeName = split(cfg.ui_node, "#")
			if not nodeName or #nodeName < 1 then return end
			
			for k,v in pairs(nodeName) do
				self.objUIDraw:NodeAnimation( v, aniName );			
			end
			self.isShowAni = true
			if wuhunCfg.sound then
				SoundManager:PlaySfx(wuhunCfg.sound)
			end
		end );
	else
		self.objUIDraw:SetScene( cfg.ui_sen, function()
			self:SetZhanshouAndLingshou()
		end );
	end
	last3dId = wuhunId
	self.objUIDraw:SetDraw( true );
end

function UISpirits:OnListItemClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not e.item then return; end
	
	local lvl = e.item.lvl;
	if  lvl == 2 then
		self.selid = e.item.id;
		self:ShowWuhunInfo(self.selid)
	end
	
	self:UpdateOpenList(e.item);
	self:ShowWuhunList();
end

function UISpirits:UpdateOpenList(node)
	--如果是第2层，需要先删除其他的第2层显示item，在添加node
	local ischild = false;
	if node.lvl == 2 then
		ischild = true;
	end
	local isfind = false;
	for i,vo in pairs(self.openlist) do
		if vo then
			--是否有选中2层
			if ischild == true then
				if vo["label"..node.lvl] then
					isfind = false;
					self.openlist[i] = {};
					break;
				end
			end
		
			local ishave = true;
			for i=1,2 do
				if node["label"..i] and vo["label"..i] then
					if node["label"..i] ~= vo["label"..i] then
						ishave = false;
						break;
					end
				elseif (not node["label"..i] and vo["label"..i]) or (node["label"..i] and not vo["label"..i]) then
					ishave = false;
					break;
				end
			end
			
			if ishave == true then
				isfind = true;
				self.openlist[i] = {};
				break;
			end
		end
	end
	
	--添加
	if isfind == false then
		local vo = {};
		for i=1,2 do
			if node["label"..i] then
				vo["label"..i] = node["label"..i];
			end
		end
		table.push(self.openlist, vo);
	end
end