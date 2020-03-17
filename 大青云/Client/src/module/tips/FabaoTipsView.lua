_G.UIFabaoTips = BaseUI:new("UIFabaoTips");

UIFabaoTips.tipsDir = nil;
UIFabaoTips.fabao = nil;
UIFabaoTips.fabao1 = nil;
UIFabaoTips.proAttrs = nil;
UIFabaoTips.tfAttrs = nil;
UIFabaoTips.tfAttrs1 = nil;
UIFabaoTips.preview = nil;
--UIFabaoTips.heCheng = nil;
UIFabaoTips.barDefaultPoint = nil;

function UIFabaoTips:Create()
	self:AddSWF("fabaoTips.swf",true,"float");
end

function UIFabaoTips:OnLoaded(objSwf)
	objSwf.hitTestDisable = true
	
	self.proAttrs = {};
	self.tfAttrs = {};
	self.tfAttrs1 = {};
	for i=1,5 do 
		local proAttr = objSwf.barPanel["proAttr"..tostring(i)];
		table.push(self.proAttrs,proAttr);
		local tfAttr = objSwf.attrPanel["tfAttr"..tostring(i)];
		table.push(self.tfAttrs,tfAttr);
		local tfAttr1 = objSwf.attrPanel1["tfAttr"..tostring(i)];
		table.push(self.tfAttrs1,tfAttr1);
	end
	
	self.barDefaultPoint = _Vector2.new(objSwf.barPanel._x,objSwf.barPanel._y);
	
	-- objSwf.tfFight.text = '';
end

function UIFabaoTips:Update()
end

function UIFabaoTips:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then
		return; 
	end
	if not self.fabao then
		return;
	end
	self:DrawDummy();
	self.objSwf.tfName.text = self.fabao.name;
	self.objSwf.iconFabao:setData(UIData.encode(self.fabao.view));
	 self.objSwf.ji.iconNSkill:setData(UIData.encode(self.fabao.nskill));
	self.objSwf.ji.iconSSkill:setData(UIData.encode(self.fabao.sskill));
	self.objSwf.iconStep.source = self.fabao.view.feedUrl;
	
	self.objSwf.list.dataProvider:cleanUp();
	for id,skill in pairs(self.fabao.skills) do
		self.objSwf.list.dataProvider:push(UIData.encode(skill));
	end
	self.objSwf.list:invalidateData();
	self.objSwf.list:scrollToIndex(0);
	
	if self.preview then--融合预览tips
		
		self.objSwf.fightLoader._visible = false;
		self.objSwf.fight._visible = false;
		self.objSwf.lbJineng._visible = true;
		self.objSwf.lbZizhi._visible = true;
		self.objSwf.qianli._y = self.objSwf.lbZizhi._y-43;
		self.objSwf.ji._y = self.objSwf.lbJineng._y-62;
		if not self.fabao.level then
			self.objSwf.tfLevel.text = '';
		else
			if self.fabao.level < self.fabao1.level then
			self.objSwf.tfLevel.text = self.fabao.level..'-'..self.fabao1.level;
			else
			self.objSwf.tfLevel.text = self.fabao1.level..'-'..self.fabao.level;
			end
		end
		
		self.objSwf.barPanel._visible = false;
		self.objSwf.attrPanel._visible = false;
		self.objSwf.attrPanel1._visible = true;
		-- self.objSwf.tfFight._visible = true;
		for i = 1,5 do
			--local proAttr = self.proAttrs[i];
			-- proAttr.maximum = self.fabao.ability;
			-- proAttr.value = proAttr.maximum;
			--proAttr.txt.text = self.fabao.abilityList[i];
			local tfAttr = self.tfAttrs1[i];
			--tfAttr.text = string.format(StrConfig['fabao00'..i],self.fabao.abilityList[i]);
			tfAttr.text = self.fabao.abilityList[i];
		end
		-- self.objSwf.barPanel._x = self.objSwf.attrPanel._x;
		-- self.objSwf.barPanel._y = self.objSwf.attrPanel._y;
		-- print('---------------------------------------preview')
	-- elseif self.heCheng then--合成预览tips
		-- self.objSwf.tfLevel._visible = false;
		-- self.objSwf.barPanel._visible = false;
		-- self.objSwf.tfFight._visible = true;
		-- for i = 1,5 do
			-- local tfAttr = self.tfAttrs[i];
			-- local attrCfg = t_fabaoshuxing[self.fabao.modelId];
			-- local value = (attrCfg.ability*attrCfg.hp_ability[1])/10000;
			-- local value1 = (attrCfg.ability*attrCfg.hp_ability[2])/10000;
			-- print('---------------------------------------self.heCheng'..value1)
			-- tfAttr.text = string.format(StrConfig['fabao0'..i],value,value1);
		-- end
		-- print('---------------------------------------self.heCheng')
	else
		self.objSwf.ji._y = self.objSwf.lbJineng._y-45;
		self.objSwf.qianli._y = self.objSwf.fight._y+55;
		self.objSwf.fight._visible = true;
		self.objSwf.barPanel._visible = true;
		self.objSwf.attrPanel1._visible = false;
		self.objSwf.lbJineng._visible = false;
		self.objSwf.lbZizhi._visible = false;
		if not self.fabao.level then
			self.objSwf.tfLevel.text = '';
		else
			self.objSwf.tfLevel.text = self.fabao.level..'';
		end		
		self.objSwf.attrPanel._visible = true;
		self.objSwf.barPanel._x = self.barDefaultPoint.x;
		self.objSwf.barPanel._y = self.barDefaultPoint.y;

		--objSwf.tfFight._visible = true;
		self.objSwf.fightLoader._visible = true;
		self.objSwf.fightLoader.num = self.fabao.fight
		for i = 1,5 do
			local proAttr = self.proAttrs[i];
			proAttr.maximum = self.fabao.ability;
			proAttr.value = self.fabao.abilityList[i];
			local tfAttr = self.tfAttrs[i];
			local index = i+3;
			tfAttr.text = string.format(StrConfig['fabao'..index],math.ceil(self.fabao.attrList[i]));
		end
		-- print('---------------------------------------self.else')
	end
	
	-- self.objSwf.tfNSkillName.text = self.fabao.nskill.name;
	-- self.objSwf.tfSSkillName.text = self.fabao.sskill.name;
	-- self.objSwf.tfQianli.text = string.format(StrConfig.fabao10,self.fabao.potential..'');
	self.objSwf.qianli.qilitLoader.num = self.fabao.potential
	-- self:DrawDummy();
	
	self.width = self.objSwf._width;
	self.height = self.objSwf._height;
	
	local tipsX,tipsY = TipsUtils:GetTipsPos(self.width,self.height,self.tipsDir);
	objSwf._x = tipsX;
	objSwf._y = tipsY;
	
end

function UIFabaoTips:OnHide()
	self.tipsDir = nil;
	
	self:DisposeDummy();
	self.fabao = nil;
	self.fabao1 = nil;
	self.preview = nil;
	--self.heCheng = nil;
end

function UIFabaoTips:DrawDummy()

	self:DisposeDummy();
	if not self.fabao then
		return;
	end
	
	local config = t_fabao[self.fabao.modelId];
	if not config then
		return;
	end
	
	local modelCfg = t_shenlingmodel[config.model];
	if not modelCfg then
		return;
	end
	self.objSwf.avatarLoader._x =modelCfg.position_x-720;
	self.objSwf.avatarLoader._y =modelCfg.position_y-40;
	
	self.objAvatar = LSAvatar:New(self.fabao.modelId,0,2);
	self.objAvatar:InitAvatar();
	
	self.objAvatar.objMesh.transform:mulScalingRight(modelCfg.scale,modelCfg.scale,modelCfg.scale);
	
	if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("FabaoTipsView",self.objAvatar,self.objSwf.avatarLoader,_Vector2.new(500,500),_Vector3.new(0,-40,25),_Vector3.new(1,0,20),0x00000000);
		self.objUIDraw:SetUILoader(self.objSwf.avatarLoader);
	else
		self.objUIDraw:SetMesh(self.objAvatar)
	end
	self.objUIDraw:SetDraw(true);

end

function UIFabaoTips:DisposeDummy()
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	end
end

function UIFabaoTips:ShowTips(fabao,tipsDir,preview,fabao1)
	if not fabao then
		return;
	end
	self.fabao = fabao;
	self.fabao1 = fabao1;
	self.preview = preview;
	--self.heCheng = heCheng;
	

	if self:IsShow() then
		self:OnHide();
	end
	self.tipsDir = tipsDir;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UIFabaoTips:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local tipsX,tipsY = TipsUtils:GetTipsPos(self.width,self.height,self.tipsDir);
		objSwf._x = tipsX;
		objSwf._y = tipsY;
	elseif name == NotifyConsts.StageClick then
		-- self:OnHide();
	end
end


function UIFabaoTips:ListNotificationInterests()
	return {NotifyConsts.StageMove,NotifyConsts.StageClick};
end

function UIFabaoTips:IsTween()
	return false;
end