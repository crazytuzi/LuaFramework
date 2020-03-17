_G.UIFabaoChongsheng = BaseUI:new("UIFabaoChongsheng");
UIFabaoChongsheng.currSelect = nil;

function UIFabaoChongsheng:Create()
	self:AddSWF("fabaoRebirthPanel.swf",true,nil);
end

function UIFabaoChongsheng:OnLoaded(objSwf)
	
	objSwf.list.itemRollOver = function(e) self:OnItemOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	objSwf.iconNSkill.rollOver = function(e) self:OnSkillOver(e) end
	objSwf.iconNSkill.rollOut = function(e) TipsManager:Hide(); end
	objSwf.iconSSkill.rollOver = function(e) self:OnSkillOver(e) end
	objSwf.iconSSkill.rollOut = function(e) TipsManager:Hide(); end
	objSwf.iconRebirthMaterial.rollOver = function(e) self:OnNeedItemOver(e) end
	objSwf.iconRebirthMaterial.rollOut = function(e) TipsManager:Hide(); end
	objSwf.btnRebirth.click = function() self:OnBtnRebirth(); end
	self.objSwf.tfQianli.text = string.format(StrConfig.fabao10,self.currSelect.potential..'');
	
	if BagModel:GetItemNumInBag(self.currSelect.feedItem.id)>0 then 
		objSwf.btnRebirth.disabled = true;
	else
		objSwf.btnRebirth.disabled = false;
	end;
end

function UIFabaoChongsheng:OnItemOver(e)
	if e.item.modelId then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=e.item.modelId},TipsConsts.ShowType_Normal,TipsConsts.Dir_RightUp);
	end
end

function UIFabaoChongsheng:OnSkillOver(e)
	if e.target.data and e.target.data.modelId then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=e.target.data.modelId},TipsConsts.ShowType_Normal,TipsConsts.Dir_RightUp);
	end
end

function UIFabaoChongsheng:OnNeedItemOver(e)
	if e.target and e.target.data then
		TipsManager:ShowItemTips(e.target.data.id);
	end
end

function UIFabaoChongsheng:OnBtnRebirth()
	if not self.currSelect then
		return;
	end
	local func = function ()
		FabaoController:SendRebornFabao(self.currSelect.id);
	end
	self.rebirthPanel = UIConfirm:Open(StrConfig['fabao16'],func);
end

function UIFabaoChongsheng:ListNotificationInterests()
	return {NotifyConsts.FabaoRebornResult};
end

function UIFabaoChongsheng:HandleNotification(name,body)
	if name == NotifyConsts.FabaoRebornResult then
		
	end
end

function UIFabaoChongsheng:SetSelect(fabao)
	self.currSelect = fabao;
	
	
	if not self.objSwf or not self.currSelect then
		return;
	end
	
	if BagModel:GetItemNumInBag(self.currSelect.feedItem.id)>0 then 
		self.objSwf.btnRebirth.disabled = false;
	else
		self.objSwf.btnRebirth.disabled = true;
	end;
	self:DrawDummy();
	
	self.objSwf.iconNSkill:setData(UIData.encode(self.currSelect.nskill));
	self.objSwf.iconSSkill:setData(UIData.encode(self.currSelect.sskill));
	self.objSwf.iconRebirthMaterial:setData(UIData.encode(self.currSelect.rebornItem));
	self.objSwf.tfMaterialCondition.text = self.currSelect.rebornItem.name;
	self.objSwf.tfName.text = self.currSelect.name;
	self.objSwf.tfLevel.text = self.currSelect.level..'';
	-- self.objSwf.tfQianli.text = self.currSelect.potential..'';
	self.objSwf.tfFight.text = string.format(StrConfig.fabao2,self.currSelect.fight..'');
	self.objSwf.iconStep.source = self.currSelect.view.feedUrl;
	
	self.objSwf.list.dataProvider:cleanUp();
	for id,skill in pairs(fabao.skills) do
		self.objSwf.list.dataProvider:push(UIData.encode(skill));
	end
	self.objSwf.list:invalidateData();
	self.objSwf.list:scrollToIndex(0);

	for i = 1,#self.currSelect.attrList do
		local proAttr = self.objSwf['proAttr'..i];
		proAttr.maximum = self.currSelect.ability;
		proAttr.value = self.currSelect.abilityList[i];
		local tfAttr = self.objSwf['tfAttr'..i];
		local index = i+3;
		tfAttr.text = string.format(StrConfig['fabao'..index],self.currSelect.attrList[i]);
	end
	
end

function UIFabaoChongsheng:OnShow()
	self:SetSelect(self.currSelect);
end

function UIFabaoChongsheng:DrawDummy()
	self:DisposeDummy();
	if not self.currSelect then
		return;
	end
	if not self.objUIDraw then
		local viewPort = _Vector2.new(700, 500);
		self.objUIDraw = UISceneDraw:new( "UIFabaoChongshengView", self.objSwf.avatarLoader, viewPort );
	end
	self.objUIDraw:SetUILoader( self.objSwf.avatarLoader );
	self.objUIDraw:SetScene( t_fabao[self.currSelect.modelId].ui_show );
	self.objUIDraw:SetDraw( true );
end

function UIFabaoChongsheng:DisposeDummy()
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	   self.objUIDraw:SetUILoader(nil);
	end
	
	if self.objAvatar then
	   self.objAvatar:ExitMap();
	   self.objAvatar = nil;
	end
end

function UIFabaoChongsheng:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then 
	   return; 
	end
	
	self:DisposeDummy();
	self.currSelect = nil;
end
