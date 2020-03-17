_G.UIFabaoHecheng = BaseUI:new("UIFabaoHecheng");
UIFabaoHecheng.currSelect = nil;
UIFabaoHecheng.tfAttrs = nil;
UIFabaoHecheng.abilities = nil;
function UIFabaoHecheng:Create()
	self:AddSWF("fabaoCompoundPanel.swf",true,nil);
end

function UIFabaoHecheng:OnLoaded(objSwf)
	-- objSwf.iconPreview.rollOver = function(e) self:OnFabaoOver(e) end
	-- objSwf.iconPreview.rollOut = function(e) TipsManager:Hide(); end
	objSwf.list.itemRollOver = function(e) self:OnItemOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	objSwf.iconNeedMaterial.rollOver = function(e) self:OnNeedItemOver(e) end
	objSwf.iconNeedMaterial.rollOut = function(e) TipsManager:Hide(); end
	objSwf.btnCompound.click = function() self:OnBtnCompound(); end
	objSwf.iconNSkill.rollOver = function(e) self:OnSkillOver(e) end
	objSwf.iconNSkill.rollOut = function(e) TipsManager:Hide(); end
	objSwf.iconSSkill.rollOver = function(e) self:OnSkillOver(e) end
	objSwf.iconSSkill.rollOut = function(e) TipsManager:Hide(); end
	self.tfAttrs = {};
	for i=1,5 do 
		local tfAttr = objSwf.attrPanel["tfAttr"..tostring(i)];
		table.push(self.tfAttrs,tfAttr);
	end
	objSwf.fabaoSelect._visible = true;
	
	objSwf.list1.click1 = function (e)
		self:ItemClick(e);
	end

end

function UIFabaoHecheng:ItemClick(e)
	if not e.item.id then 
		return
	end
	local objSwf = self.objSwf;
	local list = nil;
	list = FabaoModel:GetDefaults();
	for id,vo in pairs(list) do
		if vo.modelId==e.item.id then
			objSwf.fabaoSelect._visible = false;
			objSwf.list1:selectedState(e.item.id);
			self:SetSelect(vo);
			return;
		end
	end
	
end


function UIFabaoHecheng:OnChangeListData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local index = self.bogeySelectIndex;
	
	local bogeylist = {};
	local treeData = FabaoModel:GetBoegeyPillList(bogeylist);
	-- trace(treeData)
	-- debug.debug();
	UIData.cleanTreeData( objSwf.list1.dataProvider.rootNode);
	UIData.copyDataToTree(treeData,objSwf.list1.dataProvider.rootNode);
	objSwf.list1.dataProvider:preProcessRoot();
	objSwf.list1:invalidateData();
end

function UIFabaoHecheng:OnItemOver(e)
	if e.item then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=e.item.modelId},TipsConsts.ShowType_Normal,TipsConsts.Dir_RightUp);
	end
end
function UIFabaoHecheng:setMaterial()
	local bagItemNum = BagModel:GetItemNumInBag(self.currSelect.feedItem.id)
	self.objSwf.tfMaterialCondition.text = self.currSelect.feedItem.showCount..'/'..bagItemNum;
	
	if self.currSelect.feedItem.showCount>BagModel:GetItemNumInBag(self.currSelect.feedItem.id) then 
		self.objSwf.btnCompound.disabled = true;
	else
		self.objSwf.btnCompound.disabled = false;
	end;
end
function UIFabaoHecheng:OnFabaoOver(e)
	--TipsManager:ShowFabaoTips(self.currSelect);
	--TipsManager:ShowFabaoHechengTips(self.currSelect);
end

function UIFabaoHecheng:OnNeedItemOver(e)
	 if e.target and e.target.data then
		TipsManager:ShowItemTips(e.target.data.id);
	 end
end

function UIFabaoHecheng:OnSkillOver(e)
	if e.target and e.target.data then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=e.target.data.modelId},TipsConsts.ShowType_Normal,TipsConsts.Dir_RightUp);
	 end
end

function UIFabaoHecheng:OnBtnCompound()
	if not self.currSelect then
		return;
	end
	FabaoController:SendFabaoCombine(self.currSelect.modelId);
	-- local bagItemNum = BagModel:GetItemNumInBag(self.currSelect.feedItem.id)
	-- self.objSwf.tfMaterialCondition.text = self.currSelect.feedItem.showCount..'/'..bagItemNum;
end

function UIFabaoHecheng:ListNotificationInterests()
	return {};
end

function UIFabaoHecheng:HandleNotification(name,body)
	
end

function UIFabaoHecheng:SetSelect(fabao)
	self.currSelect = fabao;
	
	if not self.objSwf or not self.currSelect then
		return;
	end
	local bagItemNum = BagModel:GetItemNumInBag(self.currSelect.feedItem.id)
	self.objSwf.tfMaterialCondition.text = self.currSelect.feedItem.showCount..'/'..bagItemNum;
	self:DrawDummy();
	--self.objSwf.tfQianli.text = string.format(StrConfig.fabao10,self.currSelect.potential..'');
	self.objSwf.qilitLoader.num = self.currSelect.potential
	self.objSwf.tfName.text = self.currSelect.name;
	self.objSwf.iconStep.source = self.currSelect.view.feedUrl;
	-- self.objSwf.iconPreview:setData(UIData.encode(self.currSelect.view));
	self.objSwf.iconNSkill:setData(UIData.encode(self.currSelect.nskill));
	self.objSwf.iconSSkill:setData(UIData.encode(self.currSelect.sskill));
	self.objSwf.iconNeedMaterial:setData(UIData.encode(self.currSelect.feedItem));
	local bagItemNum = BagModel:GetItemNumInBag(self.currSelect.feedItem.id)
	self.objSwf.tfMaterialCondition.text = self.currSelect.feedItem.showCount..'/'..bagItemNum;
	
	local attrCfg = t_fabaoshuxing[self.currSelect.modelId];
	local value = (attrCfg.ability*attrCfg.hp_ability[1])/10000;
	local value1 = (attrCfg.ability*attrCfg.hp_ability[2])/10000;
	self.tfAttrs[1].text = string.format(StrConfig['fabao01'],value,value1);
	
	value = (attrCfg.ability*attrCfg.atk_ability[1])/10000;
	value1 = (attrCfg.ability*attrCfg.atk_ability[2])/10000;
	self.tfAttrs[2].text = string.format(StrConfig['fabao01'],value,value1);
	
	value = (attrCfg.ability*attrCfg.defend_ability[1])/10000;
	value1 = (attrCfg.ability*attrCfg.defend_ability[2])/10000;
	self.tfAttrs[3].text = string.format(StrConfig['fabao01'],value,value1);
	
	value = (attrCfg.ability*attrCfg.hit_ability[1])/10000;
	value1 = (attrCfg.ability*attrCfg.hit_ability[2])/10000;
	self.tfAttrs[4].text = string.format(StrConfig['fabao01'],value,value1);
	
	value = (attrCfg.ability*attrCfg.critical_ability[1])/10000;
	value1 = (attrCfg.ability*attrCfg.critical_ability[2])/10000;
	self.tfAttrs[5].text = string.format(StrConfig['fabao01'],value,value1);
	
	
	self.objSwf.list.dataProvider:cleanUp();
	for id,skill in pairs(self.currSelect.skills) do
		self.objSwf.list.dataProvider:push(UIData.encode(skill));
	end
	self.objSwf.list:invalidateData();
	self.objSwf.list:scrollToIndex(0);
	
	if self.currSelect.feedItem.showCount>BagModel:GetItemNumInBag(self.currSelect.feedItem.id) then 
		self.objSwf.btnCompound.disabled = true;
	else
		self.objSwf.btnCompound.disabled = false;
	end;
end

function UIFabaoHecheng:OnShow()
	self.currSelect = nil;
	local list = nil;
	list = FabaoModel:GetDefaults();
	for id,vo in pairs(list) do
		if vo.modelId==1001 then
			self:SetSelect(vo);
		end
	end
	local objSwf = self.objSwf;
	if not objSwf then 
	   return; 
	end
	objSwf.fabaoSelect._visible = true;
	self:OnChangeListData();
end

function UIFabaoHecheng:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then 
	   return; 
	end
	
	self:DisposeDummy();
	self.currSelect = nil;
end

function UIFabaoHecheng:DrawDummy()
	self:DisposeDummy();
	if not self.currSelect then
		return;
	end
	if not self.objUIDraw then
		local viewPort = _Vector2.new(700, 500);
		self.objUIDraw = UISceneDraw:new( "UIFabaoHechengView", self.objSwf.avatarLoader, viewPort );
	end
	self.objUIDraw:SetUILoader( self.objSwf.avatarLoader );
	self.objUIDraw:SetScene( t_fabao[self.currSelect.modelId].ui_show );
	self.objUIDraw:SetDraw( true );
end

function UIFabaoHecheng:DisposeDummy()
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	   self.objUIDraw:SetUILoader(nil);
	end
	
	if self.objAvatar then
	   self.objAvatar:ExitMap();
	   self.objAvatar = nil;
	end
end
