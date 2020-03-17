_G.UIFabao = BaseUI:new("UIFabao");
UIFabao.tabButton = {};
UIFabao.currSelect = nil;
UIFabao.selectPage = 0;
UIFabao.selectIndex = 1;

function UIFabao:Create()
	self:AddSWF("fabaoMainPanel.swf",true,"center");
	
	self:AddChild(UIFabaoInfo,FuncConsts.FabaoInfo); 				-- 法宝信息
	self:AddChild(UIFabaoHecheng,FuncConsts.FabaoHecheng); 			-- 法宝合成
	self:AddChild(UIFabaoRonghe,FuncConsts.FabaoRonghe); 			-- 法宝融合
	-- self:AddChild(UIFabaoChongsheng,FuncConsts.FabaoChongsheng); 	-- 法宝重生
	-- self:AddChild(UIFabaoLianshu,FuncConsts.FabaoLianshu); 			-- 法宝炼书
end

function UIFabao:OnLoaded(objSwf)
	---设置子面板----
	self:GetChild(FuncConsts.FabaoInfo):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.FabaoHecheng):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.FabaoRonghe):SetContainer(objSwf.childPanel);
	-- self:GetChild(FuncConsts.FabaoChongsheng):SetContainer(objSwf.childPanel);
	-- self:GetChild(FuncConsts.FabaoLianshu):SetContainer(objSwf.childPanel);
	
	---设置分页按钮----
	self.tabButton[FuncConsts.FabaoInfo] = objSwf.btnFabao;
	self.tabButton[FuncConsts.FabaoHecheng] = objSwf.btnHecheng;
	self.tabButton[FuncConsts.FabaoRonghe] = objSwf.btnRonghe;
	-- self.tabButton[FuncConsts.FabaoChongsheng] = objSwf.btnChongsheng;
	-- self.tabButton[FuncConsts.FabaoLianshu] = objSwf.btnLianshu;
	 objSwf.btnLianshu.disabled = true;
	 objSwf.btnChongsheng.disabled = true;
	
	---事件----
	objSwf.mianlist.list.itemClick = function(e) self:OnItemClick(e); end
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	for name,btn in pairs(self.tabButton) do
		btn.click = function() if name~=self.selectPage then self:OnTabButtonClick(name); end end
	end
end

function UIFabao:ListNotificationInterests()
	return {NotifyConsts.FabaoListChange,NotifyConsts.FabaoChange,NotifyConsts.FabaoCombineResult};
end

function UIFabao:HandleNotification(name,body)
	if name == NotifyConsts.FabaoListChange then
		-- self:OnShow();
		self:updateContent();
	end
	if name == NotifyConsts.FabaoChange then
		if body == self.currSelect then
		end
	end
	if name == NotifyConsts.FabaoCombineResult then
		UIFabaoHecheng:setMaterial()
	end
end

function UIFabao:OnItemOver(e)
	
	if not e.item then
		return;
	end
	local fabao = FabaoModel:GetFabao(e.item.id,e.item.modelId);
	TipsManager:ShowFabaoTips(fabao);
end

function UIFabao:OnItemClick(e)
	if not e.item then
		self.objSwf.mianlist["item" ..(e.index+ 1)].selected = false;
		self.objSwf.mianlist["item" ..self.selectIndex].selected = true;
		return;
	end
	self.objSwf.mianlist["item" ..self.selectIndex].selected = false;
	local fabao = FabaoModel:GetFabao(e.item.id,e.item.modelId);
	if fabao ~= self.currSelect then
		self:SetSelect(FabaoModel:GetFabao(e.item.id,e.item.modelId));
	end
	self.selectIndex = e.index+1;
	self.objSwf.mianlist["item" ..self.selectIndex].selected = true;
	self.tabButton[self.selectPage].selected = true;
end

function UIFabao:SetSelect(fabao)
	self.currSelect = fabao;
	local child = self:GetShowingChild();
	if child then
		child:SetSelect(self.currSelect);
	end

end

function UIFabao:OnShow()
	if FabaoModel:GetCount()>0 then
		self:OnTabButtonClick(FuncConsts.FabaoInfo);
		self.tabButton[FuncConsts.FabaoInfo].selected = true
		self.tabButton[FuncConsts.FabaoInfo].disabled = false;
		self.tabButton[FuncConsts.FabaoRonghe].disabled = false;
		-- self.tabButton[FuncConsts.FabaoChongsheng].disabled = false;
		-- self.tabButton[FuncConsts.FabaoLianshu].disabled = false;
	else
		self:OnTabButtonClick(FuncConsts.FabaoHecheng);
		self.tabButton[FuncConsts.FabaoHecheng].selected = true
		self.tabButton[FuncConsts.FabaoHecheng].disabled = false;
		self.tabButton[FuncConsts.FabaoInfo].disabled = true;
		self.tabButton[FuncConsts.FabaoRonghe].disabled = true;
		-- self.tabButton[FuncConsts.FabaoChongsheng].disabled = true;
		-- self.tabButton[FuncConsts.FabaoLianshu].disabled = true;
	end
	
end

function UIFabao:updateContent()
	if FabaoModel:GetCount()>0 then
		self.tabButton[FuncConsts.FabaoInfo].disabled = false;
		self.tabButton[FuncConsts.FabaoRonghe].disabled = false;
		-- self.tabButton[FuncConsts.FabaoChongsheng].disabled = false;
		-- self.tabButton[FuncConsts.FabaoLianshu].disabled = false;
		if self.selectPage ~= FuncConsts.FabaoHecheng then
			self:OnTabButtonClick(self.selectPage);
			self.tabButton[self.selectPage].selected = true;
		end
	else
		self:OnTabButtonClick(FuncConsts.FabaoHecheng);
		self.tabButton[FuncConsts.FabaoHecheng].selected = true;
		self.tabButton[FuncConsts.FabaoHecheng].disabled = false;
		self.tabButton[FuncConsts.FabaoInfo].disabled = true;
		self.tabButton[FuncConsts.FabaoRonghe].disabled = true;
		-- self.tabButton[FuncConsts.FabaoChongsheng].disabled = true;
		-- self.tabButton[FuncConsts.FabaoLianshu].disabled = true;
	end
end

function UIFabao:WithRes()
	return {"fabaoInfoPanel.swf","fabaoRebirthPanel.swf","fabaoCompoundPanel.swf","fabaoBookPanel.swf","fabaoFusionPanel.swf"};
end

function UIFabao:IsTween()
	return true;
end

function UIFabao:GetPanelType()
	return 1;
end

function UIFabao:IsShowSound()
	return true;
end

function UIFabao:GetWidth()
	return 1058;
end

function UIFabao:GetHeight()
	return 680;
end

function UIFabao:OnTabButtonClick(name)
	if not self.tabButton[name] then
		return;
	end
	local child = self:GetChild(name);
	if not child then
		return;
	end
	self.tabButton[name].selected = true;
	self:ShowChild(name);
	self.selectPage = name;
	
	if self.selectPage == FuncConsts.FabaoHecheng then
		self.objSwf.mianlist._visible = false;
		return;
	end
	self.objSwf.mianlist._visible = true;
	
	self.selectIndex = 1;
	UIFabao:UpdateList(name);
	if self.selectPage ~= FuncConsts.FabaoHecheng then
		self.objSwf.mianlist.list.itemRollOver = function(e) self:OnItemOver(e); end
		self.objSwf.mianlist.list.itemRollOut = function(e) TipsManager:Hide(); end
	else
		self.objSwf.mianlist.list.itemRollOver = function(e) TipsManager:Hide(); end
	end
end

function UIFabao:UpdateList(index)
	self.objSwf.mianlist.list.dataProvider:cleanUp();
	local list = nil;
	if index == FuncConsts.FabaoHecheng then
		list = FabaoModel:GetDefaults();
	elseif index == FuncConsts.FabaoRonghe then
		list = FabaoModel.list;
		local count = 0;
		if UIFabaoRonghe.created then
			for id,vo in pairs(list) do
				if UIFabaoRonghe.created.id == vo.id then
					count = -1*count; 
				else
					if count>=0 then
						count = count + 1;
					end
				end
				self.objSwf.mianlist.list.dataProvider:push(UIData.encode(vo.view));
			end
		else
			for id,vo in pairs(list) do
				self.objSwf.mianlist.list.dataProvider:push(UIData.encode(vo.view));
			end
			self.objSwf.mianlist.list:invalidateData();
			self.objSwf.mianlist.list:scrollToIndex(-1);
			self.objSwf.mianlist.list.selectedIndex = -1;
			self.currSelect = nil;
			return;
		end
		self.objSwf.mianlist.list:invalidateData();
		count = -1*count;
		count = math.max(count,0);
		self.objSwf.mianlist.list:scrollToIndex(count);

		self.objSwf.mianlist.list.selectedIndex = count;
		local item = self.objSwf.mianlist.list:getRendererAt(count);
		if item then
			self:SetSelect(FabaoModel:GetFabao(item.data.id,item.data.modelId));
		end
		UIFabaoRonghe.created = nil;
		UIFabaoRonghe:RefreshPreview()
		return;
	else
		list = FabaoModel.list;
	end
	-- for id,vo in pairs(list) do
		-- self.objSwf.list.dataProvider:push(UIData.encode(vo.view));
	-- end
	-- self.objSwf.list:invalidateData();
	-- self.objSwf.list:scrollToIndex(0);
	
	-- self.objSwf.list.selectedIndex = 0;
	-- local item = self.objSwf.list:getRendererAt(0);
	local count = 0;
	for id,vo in pairs(list) do
		if self.currSelect == vo then
			count = -1*count;
		else
			if count>=0 then
				count = count + 1;
			end
		end
		self.objSwf.mianlist.list.dataProvider:push(UIData.encode(vo.view));
	end
	self.objSwf.mianlist.list:invalidateData();
	count = -1*count;
	count = math.max(count,0);
	self.objSwf.mianlist.list:scrollToIndex(count);
	
	self.objSwf.mianlist.list.selectedIndex = count;
	local item = self.objSwf.mianlist.list:getRendererAt(count);
	if item then
		self:SetSelect(FabaoModel:GetFabao(item.data.id,item.data.modelId));
	end
	
end

function UIFabao:OnBtnCloseClick()
	self:Hide();
	self.selectPage = FuncConsts.FabaoInfo;
end

function UIFabao:GetCloseBtn()
	if not self:IsShow() then return; end
	return self.objSwf.btnClose;
end