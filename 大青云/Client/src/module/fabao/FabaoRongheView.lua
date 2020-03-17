_G.UIFabaoRonghe = BaseUI:new("UIFabaoRonghe");
UIFabaoRonghe.leftSelect = nil;
UIFabaoRonghe.rightSelect = nil;
UIFabaoRonghe.created = nil;

function UIFabaoRonghe:Create()
	self:AddSWF("fabaoFusionPanel.swf",true,bottom);
end

function UIFabaoRonghe:OnLoaded(objSwf)
	
	for i=1,5 do 
		local proAttr = objSwf["proLAttr"..tostring(i)];
		proAttr.rollOver = function () self : OnAttrTipShow(i,proAttr) end;
		proAttr.rollOut = function () TipsManager:Hide(); end
		proAttr = objSwf["proRAttr"..tostring(i)];
		proAttr.rollOver = function () self : OnAttrTipShow(i,proAttr) end;
		proAttr.rollOut = function () TipsManager:Hide(); end
	end
	
	objSwf.zhu._visible = false;
	objSwf.tfRName.text = ' ';
	objSwf.tfLName.text = ' ';
	objSwf.lvR._visible = false;	
	objSwf.lvL._visible = false;	
	objSwf.listL.itemRollOver = function(e) self:OnItemOver(e); end
	objSwf.listL.itemRollOut = function(e) TipsManager:Hide(); end
	objSwf.listR.itemRollOver = function(e) self:OnItemOver(e); end
	objSwf.listR.itemRollOut = function(e) TipsManager:Hide(); end
	
	objSwf.btnLAdd.rollOver = function(e) self:OnFabaoOver(e,0) end
	objSwf.btnLAdd.rollOut = function(e) TipsManager:Hide(); end
	objSwf.btnLAdd.click = function() self:OnAddClick(0); end		--0表示左边按钮 1表示右边按钮
	objSwf.btnRAdd.rollOver = function(e) self:OnFabaoOver(e,1) end
	objSwf.btnRAdd.rollOut = function(e) TipsManager:Hide(); end
	objSwf.btnRAdd.click = function() self:OnAddClick(1); end		--0表示左边按钮 1表示右边按钮
	objSwf.btnFusion.click = function() self:OnFusionClick(); end
	objSwf.iconPreview.rollOver = function(e) self:OnFabaoPreview(e) end
	objSwf.iconPreview.rollOut = function(e) TipsManager:Hide(); end
	objSwf.btnFusion.disabled = true;
	-- objSwf.btnFabao1._visible = false;
	
end

function UIFabaoRonghe:HandleNotification(name,body)
	if name == NotifyConsts.FabaoDevourResult then
		self.rightSelect = nil;
		self.leftSelect = nil;
		self:ClearView('R');
		self:ClearView('L');
		-- self:ClearView('L');
		-- self.leftSelect = self.created
		-- self:RefreshView(self.leftSelect,'L');
		self:RefreshPreview();
		-- self.objSwf.btnFabao1._visible = true;
	elseif name == NotifyConsts.FabaoPick then
		if not body then
			return;
		end
		
		if body.args[1] == FabaoModel.PickFabao then
			if body.args[2] == 0 then 
				self.leftSelect = body.selected;
				if self.leftSelect == self.rightSelect then
					self:ClearView('R');
					self.rightSelect = nil;
				end
				self.objSwf.btnLAdd:setData(UIData.encode(self.leftSelect.view));
				self:RefreshView(self.leftSelect,'L');
			else
				self.rightSelect = body.selected;
				if self.rightSelect == self.leftSelect then
					self:ClearView('L');
					self.leftSelect = nil;
				end
				self.objSwf.btnRAdd:setData(UIData.encode(self.rightSelect.view));
				self:RefreshView(self.rightSelect,'R');			
			end
			
			self:RefreshPreview();
			
		end
	end
end

function UIFabaoRonghe:OnAttrTipShow(i,target)
	
end

function UIFabaoRonghe:OnItemOver(e)
	if e.item then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=e.item.modelId},TipsConsts.ShowType_Normal,TipsConsts.Dir_RightUp);
	end
end

function UIFabaoRonghe:OnFabaoOver(e,part)
	local fabao = self.leftSelect;
	if part == 1 then
		fabao = self.rightSelect;
	end
	if not fabao then
		return;
	end
	
	TipsManager:ShowFabaoTips(fabao);
end

function UIFabaoRonghe:OnAddClick(dir)
	if dir==0 then
		if self.leftSelect then
			self:ClearView('L');
			self.leftSelect = nil;
			self.objSwf.btnLAdd:setData();
			self.created = nil;
			self.objSwf.iconPreview:setData();
			return;
		end
	end
	if dir==1 then
		if self.rightSelect then
			self:ClearView('R');
			self.rightSelect = nil;
			self.objSwf.btnRAdd:setData();
			self.created = nil;
			self.objSwf.iconPreview:setData();
			return;
		end
	end
	UIFabaoPick:Show(FabaoModel.PickFabao,dir);
end

function UIFabaoRonghe:OnFusionClick()
	if not self.leftSelect or not self.rightSelect then
		return;
	end
	local func = function ()
		FabaoController:SendDevourFabao(self.leftSelect.id,self.rightSelect.id);
	end
	self.ronghePanel = UIConfirm:Open(StrConfig['fabao15'],func);
	
end

function UIFabaoRonghe:OnFabaoPreview(e)
	if not self.created then
		return;
	end
	
	TipsManager:ShowFabaoReviewTips(self.created,self.rightSelect);
	
end

function UIFabaoRonghe:SetSelect(fabao)
	if not self.leftSelect then
		self.leftSelect = fabao;
		self:RefreshView(fabao,'L');
	else
		if fabao == self.leftSelect then
			return;
		end
		if not self.rightSelect then
			self.rightSelect = fabao;
			self:RefreshView(fabao,'R');
		else
			self.leftSelect = fabao;
			self:RefreshView(fabao,'L');
		end
	end	
	self:RefreshPreview();
	
end

function UIFabaoRonghe:RefreshView(fabao,part)
	local swf = self.objSwf;
	if not swf or not fabao then
		return;
	end
	if part=='L' then
		swf.zhu._visible = true;
	end
	swf['tf'..part..'Name'].text = fabao.name;
	-- swf['tf'..part..'Level'].text = fabao.level..'';
	swf['lv'..part]._visible = true;
	swf['lvLoader'..part]._visible = true;
	swf['lvLoader'..part].num = fabao.level
	for i = 1,#fabao.attrList do
		local proAttr = swf['pro'..part..'Attr'..i];
		proAttr.maximum = fabao.ability;
		proAttr.value = fabao.abilityList[i];
	end
	local list = swf['list'..part];
	list.dataProvider:cleanUp();
	for id,skill in pairs(fabao.skills) do
		list.dataProvider:push(UIData.encode(skill));
	end
	list:invalidateData();
	list:scrollToIndex(0);
	swf['btn'..part..'Add']:setData(UIData.encode(fabao.view));
end

function UIFabaoRonghe:RefreshPreview()
	if not self.objSwf then
		return;
	end
	if not self.leftSelect or not self.rightSelect then
		self.objSwf.btnFusion.disabled = true;
		-- self.created = nil;
		self.objSwf.iconPreview:setData(UIData.encode({hasSkill=false}));
		return;
	end
	
	self.objSwf.btnFusion.disabled = false;
	self.created = FabaoModel:GetDevourFabao(self.leftSelect,self.rightSelect);
	if not self.created then
		self.objSwf.iconPreview:setData(UIData.encode({hasSkill=false}));
	else
		self.objSwf.iconPreview:setData(UIData.encode(self.created.view));
	end
	
end

function UIFabaoRonghe:ClearView(part)
	local swf = self.objSwf;
	if not swf then
		return;
	end
	if part=='L' then
		swf.zhu._visible = false;
	end
	swf['tf'..part..'Name'].text = '';
	swf['lv'..part]._visible = false;
	swf['lvLoader'..part]._visible = false;
	for i = 1,5 do
		local proAttr = swf['pro'..part..'Attr'..i];
		proAttr.maximum = 10;
		proAttr.value = 0;
	end
	local list = swf['list'..part];
	list.dataProvider:cleanUp();
	list:invalidateData();
	list:scrollToIndex(0);
	swf['btn'..part..'Add']:setData(UIData.encode({hasSkill=false}));
	-- objSwf.btnFabao1._visible = false;
end

function UIFabaoRonghe:ListNotificationInterests()
	return {NotifyConsts.FabaoDevourResult,NotifyConsts.FabaoPick};
end


function UIFabaoRonghe:OnShow()
	self:RefreshView(self.leftSelect,'L');
	self:RefreshView(self.rightSelect,'R');
end

function UIFabaoRonghe:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then 
	   return; 
	end
	
	self.leftSelect = nil;
	self.rightSelect = nil;
	self.created = nil;
	self:ClearView('L');
	self:ClearView('R');
	UIFabaoPick:Hide();
end
