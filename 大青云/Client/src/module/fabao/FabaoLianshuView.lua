_G.UIFabaoLianshu = BaseUI:new("UIFabaoLianshu");
UIFabaoLianshu.currSelect = nil;
UIFabaoLianshu.selectBook = nil;

function UIFabaoLianshu:Create()
	self:AddSWF("fabaoBookPanel.swf",true,bottom);
end

function UIFabaoLianshu:OnLoaded(objSwf)

	objSwf.iconNSkill.rollOver = function(e) self:OnSkillOver(e) end
	objSwf.iconNSkill.rollOut = function(e) TipsManager:Hide(); end
	objSwf.iconSSkill.rollOver = function(e) self:OnSkillOver(e) end
	objSwf.iconSSkill.rollOut = function(e) TipsManager:Hide(); end
	objSwf.btnAdd.rollOver = function(e) self:OnFabaoBookOver(e) end
	objSwf.btnAdd.rollOut = function(e) TipsManager:Hide(); end
	objSwf.btnAdd.click = function() self:OnBtnAddClick(); end
	objSwf.btnStudy.click = function() self:OnBtnStudyClick(); end
	objSwf.list.itemRollOver = function(e) self:OnItemOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
end

function UIFabaoLianshu:OnSkillOver(e)
	if e.target.data and e.target.data.modelId then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=e.target.data.modelId},TipsConsts.ShowType_Normal,TipsConsts.Dir_RightUp);
	end
end

function UIFabaoLianshu:OnFabaoBookOver(e)
	if not self.selectBook then
		return;
	end
	
	TipsManager:ShowItemTips(self.selectBook.tid);
end

function UIFabaoLianshu:ListNotificationInterests()
	return {NotifyConsts.FabaoLearnResult,NotifyConsts.FabaoPick};
end

function UIFabaoLianshu:HandleNotification(name,body)
	if name == NotifyConsts.FabaoLearnResult then
		print('--------------------------------------------FabaoLearnResult')
		self.objSwf.btnAdd:setData();
		self.selectBook=nil;
		if not self.selectBook then
			self.objSwf.btnStudy.disabled = true;
		else
			self.objSwf.btnStudy.disabled = false;
		end
	elseif name == NotifyConsts.FabaoPick then
		print('-----------------------------------------------FabaoPick')
		if body.args[1] == FabaoModel.PickBook then
			self.selectBook = body.selected;
			self.objSwf.btnAdd:setData(body.selected:GetUIData());
			if not self.selectBook then
				self.objSwf.btnStudy.disabled = true;
			else
				self.objSwf.btnStudy.disabled = false;
			end
		end
	end
end

function UIFabaoLianshu:OnBtnAddClick()
	UIFabaoPick:Show(FabaoModel.PickBook);
end

function UIFabaoLianshu:OnBtnStudyClick()
	if not self.currSelect or not self.selectBook then
		return;
	end
	local func = function ()
		FabaoController:SendLearnFabao(self.currSelect.id,self.selectBook.tid);
	end
	self.learnPanel = UIConfirm:Open(StrConfig['fabao17'],func);
	-- print('---------------------------------self.selectBook.tid:'..self.selectBook.tid)
end

function UIFabaoLianshu:OnItemOver(e)
	if e.item.modelId then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=e.item.modelId},TipsConsts.ShowType_Normal,TipsConsts.Dir_RightUp);
	end
end

function UIFabaoLianshu:SetSelect(fabao)
	self.currSelect = fabao;
	
	if not self.objSwf or not self.currSelect then
		return;
	end
	
	self:DrawDummy();
	
	self.objSwf.iconNSkill:setData(UIData.encode(self.currSelect.nskill));
	self.objSwf.iconSSkill:setData(UIData.encode(self.currSelect.sskill));
	self.objSwf.tfNSkillName.text = self.currSelect.nskill.name;
	self.objSwf.tfSSkillName.text = self.currSelect.sskill.name;
	self.objSwf.tfName.text = self.currSelect.name;
	self.objSwf.tfLevel.text = self.currSelect.level..'';
	self.objSwf.tfFight.text = string.format(StrConfig.fabao2,self.currSelect.fight..'');
	self.objSwf.iconStep.source = self.currSelect.view.feedUrl;
	
	self.objSwf.list.dataProvider:cleanUp();
	for id,skill in pairs(fabao.skills) do
		self.objSwf.list.dataProvider:push(UIData.encode(skill));
	end
	self.objSwf.list:invalidateData();
	self.objSwf.list:scrollToIndex(0);
	
	if not self.selectBook then
		self.objSwf.btnStudy.disabled = true;
	else
		self.objSwf.btnStudy.disabled = false;
	end
end

function UIFabaoLianshu:OnShow()
	self:SetSelect(self.currSelect);
end

function UIFabaoLianshu:DrawDummy()
	self:DisposeDummy();
	if not self.currSelect then
		return;
	end
	if not self.objUIDraw then
		local viewPort = _Vector2.new(700, 500);
		self.objUIDraw = UISceneDraw:new( "FabaoLianshuView", self.objSwf.avatarLoader, viewPort );
	end
	self.objUIDraw:SetUILoader( self.objSwf.avatarLoader );
	self.objUIDraw:SetScene( t_fabao[self.currSelect.modelId].ui_show );
	self.objUIDraw:SetDraw( true );
end

function UIFabaoLianshu:DisposeDummy()
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	   self.objUIDraw:SetUILoader(nil);
	end
	
	if self.objAvatar then
	   self.objAvatar:ExitMap();
	   self.objAvatar = nil;
	end
end

function UIFabaoLianshu:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then 
	   return; 
	end
	
	self:DisposeDummy();
	self.currSelect = nil;
	UIFabaoPick:Hide();
end
