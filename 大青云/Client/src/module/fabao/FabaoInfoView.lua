_G.UIFabaoInfo = BaseUI:new("UIFabaoInfo");
UIFabaoInfo.currSelect = nil;
UIFabaoInfo.proAttrs = nil;
UIFabaoTips.tfAttrs = nil;

function UIFabaoInfo:Create()
	self:AddSWF("fabaoInfoPanel.swf",true,nil);
end

function UIFabaoInfo:OnLoaded(objSwf)

	objSwf.tfName.restrict = ChatConsts.Restrict;
	objSwf.btnDel.click = function() self:OnDelClick(); end
	objSwf.btnZhan.click = function() self:OnFightClick(); end
	objSwf.list.itemRollOver = function(e) self:OnItemOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	objSwf.proExp.rollOver = function(e) self:OnExpProOver(e); end
	objSwf.proExp.rollOut = function () TipsManager:Hide(); end;
	objSwf.itemNSkill.rollOver = function(e) self:OnSkillOver(e) end
	objSwf.itemNSkill.rollOut = function(e) TipsManager:Hide(); end
	objSwf.itemSSkill.rollOver = function(e) self:OnSkillOver(e) end
	objSwf.itemSSkill.rollOut = function(e) TipsManager:Hide(); end
	
	self.proAttrs = {};
	self.tfAttrs = {};
	for i=1,5 do 
		local proAttr = objSwf["proAttr"..tostring(i)];
		proAttr.rollOver = function () self : OnAttrTipShow(i,proAttr) end;
		proAttr.rollOut = function () TipsManager:Hide(); end
		table.push(self.proAttrs,proAttr);
		local tfAttr = objSwf["tfAttr"..tostring(i)];
		tfAttr.text = '';
		table.push(self.tfAttrs,tfAttr);
	end
		self.objSwf.tfFabao.text = FabaoModel:GetCount()..'/20';
end

function UIFabaoInfo:ListNotificationInterests()
	return {NotifyConsts.FabaoListChange,NotifyConsts.FabaoChange};
end

function UIFabaoInfo:HandleNotification(name,body)
	if name == NotifyConsts.FabaoChange then
		if body == self.currSelect then
			self:SetSelect(self.currSelect);
		end
	end
end

--名称输入变化---
function UIFabaoInfo:OnInputTextChange()
	
end

--丢弃--
function UIFabaoInfo:OnDelClick()
	if not self.currSelect then
		return;
	end
	local func = function ()
		FabaoController:SendCallFabao(self.currSelect.id,2);
	end
	self.xiuXiPanel = UIConfirm:Open(StrConfig['fabao14'],func);
end

--出战--
function UIFabaoInfo:OnFightClick()
	if not self.currSelect then
		return;
	end
	local zhanFabao = FabaoModel:GetFighting()
	if self.currSelect.fighting then
			if zhanFabao then 
				 if zhanFabao.id==self.currSelect.id then 
					 FabaoController:SendCallFabao(self.currSelect.id,0);
				 else
					 local fabao = FabaoModel:GetFabao(zhanFabao.id,zhanFabao.modelId);
					 if fabao then
					 FabaoController:SendCallFabao(fabao.id,0);
					 -- print('----------------法宝休息UIFabaoSwitch')
					 FabaoController:SendCallFabao(self.currSelect.id,0);
					 end
				 end
			else
				 FabaoController:SendCallFabao(self.currSelect.id,0);
				 -- print('----------------法宝休息UIFabaoInfo')
			end
	else
			if zhanFabao then 
				 if zhanFabao.id==self.currSelect.id then 
					 return;
				 else
					 local fabao = FabaoModel:GetFabao(zhanFabao.id,zhanFabao.modelId);
					 if fabao then
					 FabaoController:SendCallFabao(fabao.id,0);
					 -- print('----------------法宝出战UIFabaoSwitch')
					 FabaoController:SendCallFabao(self.currSelect.id,1);
					 end
				 end
			else
				 FabaoController:SendCallFabao(self.currSelect.id,1);
				 -- print('----------------法宝出战UIFabaoInfo')
			end

	end

end

--休息--
function UIFabaoInfo:OnRestClick()
	if not self.currSelect then
		return;
	end
	FabaoController:SendCallFabao(self.currSelect.id,0);
end

function UIFabaoInfo:OnItemOver(e)
	if e.item then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=e.item.modelId},TipsConsts.ShowType_Normal,TipsConsts.Dir_RightUp);
	end
end

function UIFabaoInfo:OnExpProOver(e)
	-- TipsManager:ShowBtnTips(string.format(StrConfig["shihun104"],i,name,val));
end
function UIFabaoInfo:OnSkillOver(e)
	if e.target.data and e.target.data.modelId then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=e.target.data.modelId},TipsConsts.ShowType_Normal,TipsConsts.Dir_RightUp);
	 end
end

function UIFabaoInfo:OnAttrTipShow(i,target)
	
end

function UIFabaoInfo:SetSelect(fabao)
	self.currSelect = fabao;

	if not self.objSwf or not self.currSelect then
		return;
	end
	self.objSwf.tfFabao.text = FabaoModel:GetCount()..'/20';
	
	self:DrawDummy();
	
	self.objSwf.itemNSkill:setData(UIData.encode(self.currSelect.nskill));
	self.objSwf.itemSSkill:setData(UIData.encode(self.currSelect.sskill));
	self.objSwf.tfName.text = self.currSelect.name;
	--self.objSwf.tfLevel.text = self.currSelect.level..'';
	self.objSwf.lvLoader.num = self.currSelect.level
	-- self.objSwf.tfNSkillName.text = self.currSelect.nskill.name;
	-- self.objSwf.tfSSkillName.text = self.currSelect.sskill.name;
	--self.objSwf.tfQianli.text = string.format(StrConfig.fabao10,self.currSelect.potential..'');
	self.objSwf.qilitLoader.num = self.currSelect.potential
	-- self.objSwf.tfFight.text = string.format(StrConfig.fabao2,self.currSelect.fight..'');
	self.objSwf.iconStep.source = self.currSelect.view.feedUrl;
	if self.currSelect.fighting then
		self.objSwf.btnZhan.label = StrConfig['fabao11'];
		self.objSwf.iconZhan._visible = true;
	else	
		self.objSwf.btnZhan.label = StrConfig['fabao12'];
		self.objSwf.iconZhan._visible = false;
	end
	self.objSwf.proExp.maximum = fabao.maxExp;
	self.objSwf.proExp.value = fabao.exp;
	self.objSwf.list.dataProvider:cleanUp();
	for id,skill in pairs(fabao.skills) do
		self.objSwf.list.dataProvider:push(UIData.encode(skill));
	end
	self.objSwf.list:invalidateData();
	self.objSwf.list:scrollToIndex(0);

	for i = 1,#self.currSelect.attrList do
		local proAttr = self.proAttrs[i];
		proAttr.maximum = self.currSelect.ability;
		proAttr.value = self.currSelect.abilityList[i];
		local tfAttr = self.tfAttrs[i];
		local index = i+3;
		tfAttr.text = string.format(StrConfig['fabao'..index],self.currSelect.attrList[i]);
	end
	self.objSwf.fightLoader.num = self.currSelect.fight
end

function UIFabaoInfo:OnShow()
	self:SetSelect(self.currSelect);
end

function UIFabaoInfo:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then 
	   return; 
	end
	
	self:DisposeDummy();
	self.currSelect = nil;
	UIConfirm:Close(self.xiuXiPanel)
end

local viewPort = nil;
function UIFabaoInfo:DrawDummy()
	self:DisposeDummy();
	if not self.currSelect then
		return;
	end
	-- if not self.objUIDraw then
		-- local viewPort = _Vector2.new(1333, 732);
		-- self.objUIDraw = UISceneDraw:new( "UIFabaoInfoView", self.objSwf.avatarLoader, viewPort );
	-- end
	-- self.objUIDraw:SetUILoader( self.objSwf.avatarLoader );
	-- self.objUIDraw:SetScene( t_fabao[self.currSelect.modelId].ui_show );
	-- self.objUIDraw:SetDraw( true );
	
	
	
	local config = t_fabao[self.currSelect.modelId];
	if not config then
		return;
	end
	local modelCfg = t_shenlingmodel[config.model];
	if not modelCfg then
		return;
	end
	
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(700, 500); end
		self.objUIDraw = UISceneDraw:new( "ShenLingUI", self.objSwf.avatarLoader, viewPort );
	end
	self.objUIDraw:SetUILoader(self.objSwf.avatarLoader);
	self.objUIDraw:SetScene( config.ui_sen )--[[, function()
												local aniName = modelCfg.san_show;
												if not aniName then return end
												if aniName == "" then return end
												self.objUIDraw:NodeAnimation( config.ui_node, aniName );
											end 
							);--]]
	self.objUIDraw:SetDraw( true );
end

function UIFabaoInfo:DisposeDummy()
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	   self.objUIDraw:SetUILoader(nil);
	end
	
	if self.objAvatar then
	   self.objAvatar:ExitMap();
	   self.objAvatar = nil;
	end
end

