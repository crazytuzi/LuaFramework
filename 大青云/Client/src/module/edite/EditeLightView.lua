_G.UIEditeLight = BaseUI:new("UIEditeLight");
UIEditeLight.types = nil;
UIEditeLight.names = nil;
UIEditeLight.adds = nil;
UIEditeLight.ranges = nil;
UIEditeLight.lights = nil;
UIEditeLight.currLight = nil;
UIEditeLight.items = nil;
UIEditeLight.currItem = nil;
UIEditeLight.values = nil;
UIEditeLight.panels = nil;

function UIEditeLight:Create()
	PanelPosConfig["UIEditeLight"] = {bottom=260,left=0};
	self:AddSWF("editeLightPanel.swf",true,"center");
end

function UIEditeLight:OnLoaded(objSwf)
	
	self.types = 
	{
		[1] = {type=1,name="共用",key="LightCommon"},
		[2] = {type=1,name="场景",key="SceneLight"},
	};
	
	self.names = 
	{
		ui 		= "界面",
		scene 	= "场景",
		horse 	= "骑乘",
		fog 	= "雾霾",
		[-1] 	= "其他",
		[1] 	= "物品",
		[2] 	= "怪物",
		[3] 	= "NPC",
		[4] 	= "玩家",
		[5] 	= "传送门",
		[6] 	= "采集物",
		[7] 	= "战场旗子",
		[8] 	= "神器",
		[9] 	= "陷阱",
		[10] 	= "跟宠",
		[11] 	= "特权",
		[12] 	= "灵兽",
		[13] 	= "家园",
		[14] 	= "旗帜",
		[15] 	= "预留",
		[16] 	= "婚车",
		[17] 	= "神武",
		[18] 	= "天神",
	};
	
	
	self.ranges = 
	{
		skyRange = {max=3000,min=600},
		color = {max=255,min=0},
		power = {max=200,min=0},
	};

	self.panels = {};
	
	objSwf.typeMenu.dataProvider:cleanUp();
	for i,v in ipairs(self.types) do
		objSwf.typeMenu.dataProvider:push(v.name);
	end
	objSwf.typeMenu.invalidateData();
	objSwf.typeMenu.selectedIndex = 0;
	objSwf.typeMenu.change = function(e) self:OnTypeMenuClick(e); end
	
	objSwf.addMenu.dataProvider:cleanUp();
	objSwf.addMenu.change = function(e) self:OnAddMenuClick(e); end
	
	objSwf.resetBtn.click = function() self:OnResetBtnClick(); end
	
	objSwf.lightList.itemClick = function(e) self:OnLightListClick(e); end
	objSwf.itemList.itemClick = function(e) self:OnItemListClick(e); end
	objSwf.saveBtn.click = function(e) self:OnSaveClick(e); end
	
end

function UIEditeLight:OnSaveClick()
	EditeController:Save();
end

function UIEditeLight:OnLightListClick(e)
	local light = self.lights[e.index+1];
	if not light then
		return;
	end
	self.currLight = light;
	self.items = {};
	self.objSwf.itemList.dataProvider:cleanUp();
	for name,config in pairs(light.light) do
		local vo = {};
		vo.name = name;
		vo.key = name;
		vo.light = config;
		table.push(self.items,vo);
		self.objSwf.itemList.dataProvider:push(vo.name);
	end
	self.objSwf.itemList:invalidateData();
	self.objSwf.itemList.selectedIndex = 0;
	self.objSwf.infoContainer._visible = false;
end

function UIEditeLight:OnItemListClick(e)
	local item = self.items[e.index+1];
	if not item then
		return;
	end
	self.objSwf.infoContainer._visible = true;
	self.currItem = item;
	self:UpdateLightInfo();
end

function UIEditeLight:UpdateLightInfo()
	if not self.currItem then
		return;
	end
	
	local container = self.objSwf.infoContainer;
	for name,panel in pairs(self.panels) do
		panel:removeMovieClip();
		self.panels[name] = nil;
	end
	
	container.nameLabel.text = self.currItem.name;
	local y = container.nameLabel._y + container.nameLabel._height + 10;
	
	local panel = nil;
	local typestr =  type(self.currItem.light);
	local hideBar = self:GetHideBar();
	if typestr ~= "table" then
		if typestr == "number" then
			if string.find(self.currItem.key,'color') or string.find(self.currItem.key,"hightlight") then
				panel = self:CreateColorBar(container,self.currItem.key);
				local color = self.currItem.light;
				local a,r,g,b = EditeController:GetColorRGBA(color);
				panel.aBar.value = a;
				panel.avalueLabel.text = a..''; 
				panel.rBar.value = r;
				panel.rvalueLabel.text = r..''; 
				panel.gBar.value = g;
				panel.gvalueLabel.text = g..''; 
				panel.bBar.value = b;
				panel.bvalueLabel.text = b..'';
				panel.valueLabel.text = EditeController:ColorToString(color);
				local rgb,alpha = EditeController:GetRGBColor(r,g,b,a);
				panel:drawRect(rgb,alpha);
			else
				panel = self:CreateNumberBar(container,self.currItem.key,hideBar);
				panel.valueBar.value = self.currItem.light;
				panel.valueLabel.text = self.currItem.light.."";
				local range = self.ranges[self.currItem.key];
				if range then
					panel.valueBar.minimum = range.min;
					panel.valueBar.maximum = range.max;
				end
			end	
		else
			panel = self:CreateBoolBar(container,self.currItem.key);
			panel.valueBar.selected = self.currItem.light;
			panel.valueLabel.text = self.currItem.light and "true" or "false";
		end
		panel._y = y;
		self.panels[self.currItem.key] = panel;	
		return;
	end
	
	for attr,value in pairs(self.currItem.light) do
		typestr = type(value);
		panel = nil;
		if typestr == "number" then
			if string.find(attr,'color') then
				panel = self:CreateColorBar(container,attr);
				local color = value;
				local a,r,g,b = EditeController:GetColorRGBA(color);
				panel.aBar.value = a;
				panel.avalueLabel.text = a..''; 
				panel.rBar.value = r;
				panel.rvalueLabel.text = r..''; 
				panel.gBar.value = g;
				panel.gvalueLabel.text = g..''; 
				panel.bBar.value = b;
				panel.bvalueLabel.text = b..'';
				panel.valueLabel.text = EditeController:ColorToString(color);
				local rgb,alpha = EditeController:GetRGBColor(r,g,b,a);
				panel:drawRect(rgb,alpha);
				
			else
				panel = self:CreateNumberBar(container,attr);
				panel.valueBar.value = value;
				panel.valueLabel.text = value.."";
				local range = self.ranges[attr];
				if range then
					panel.valueBar.minimum = range.min;
					panel.valueBar.maximum = range.max;
				end
			end
		else
			panel = self:CreateBoolBar(container,attr);
			panel.valueBar.selected = value;
			panel.valueLabel.text = value and "true" or "false";
		end
		panel._y = y;
		y = y + panel._height + 10;
		self.panels[attr] = panel;
	end
	
end

function UIEditeLight:CreateColorBar(container,name)
	local depth = container:getNextHighestDepth();
	local panel = container:attachMovie("ColorValueBar",name,depth);
	panel.nameLabel.text = name;
	panel.aBar.minimum = 0;
	panel.aBar.maximum = 255;
	panel.aBar.change = function()
		panel.avalueLabel.text = panel.aBar.value..''; 
		self:OnColorChanged(name);
	end
	panel.rBar.minimum = 0;
	panel.rBar.maximum = 255;
	panel.rBar.change = function() 
		panel.rvalueLabel.text = panel.rBar.value..''; 
		self:OnColorChanged(name);
	end
	panel.gBar.minimum = 0;
	panel.gBar.maximum = 255;
	panel.gBar.change = function() 
		panel.gvalueLabel.text = panel.gBar.value..''; 
		self:OnColorChanged(name);
	end
	panel.bBar.minimum = 0;
	panel.bBar.maximum = 255;
	panel.bBar.change = function() 
		panel.bvalueLabel.text = panel.bBar.value..''; 
		self:OnColorChanged(name);
	end
	
	panel.valueLabel.textChange = function() 
		local color = tonumlber(panel.valueLabel.text) or 0;
		local a,r,g,b = EditeController:GetColorRGBA(color);
		panel.aBar.value = a;
		panel.avalueLabel.text = a..''; 
		panel.rBar.value = r;
		panel.rvalueLabel.text = r..''; 
		panel.gBar.value = g;
		panel.gvalueLabel.text = g..''; 
		panel.bBar.value = b;
		panel.bvalueLabel.text = b..''; 
		self:OnColorChanged(name,true);
	end
	panel.btn.click = function()
		local color = _sys:selectColor();
		local colorstr = EditeController:ColorToString(color);
		if colorstr == "0xff0000" then
			return;
		end
		panel.valueLabel.text = colorstr;
		local a,r,g,b = EditeController:GetColorRGBA(color);
		panel.aBar.value = a;
		panel.avalueLabel.text = a..''; 
		panel.rBar.value = r;
		panel.rvalueLabel.text = r..''; 
		panel.gBar.value = g;
		panel.gvalueLabel.text = g..''; 
		panel.bBar.value = b;
		panel.bvalueLabel.text = b..''; 
		self:OnColorChanged(name,true);
	end
	return panel;
end

function UIEditeLight:CreateBoolBar(container,name)
	local depth = container:getNextHighestDepth();
	local panel = container:attachMovie("BoolValueBar",name,depth);
	panel.nameLabel.text = name;
	panel.valueBar.text = name;
	panel.valueBar.click = function()
		panel.valueLabel.text= panel.valueBar.selected and "true" or "false";
		self:OnBoolChanged(name);
	end
	return panel;
end

function UIEditeLight:CreateNumberBar(container,name,hideBar)
	local depth = container:getNextHighestDepth();
	local panel = container:attachMovie("NumberValueBar",name,depth);
	panel.nameLabel.text = name;
	panel.valueBar.text='';
	if hideBar then
		panel.valueBar._visible = false;
	else
		panel.valueBar._visible = true;
		panel.valueBar.change = function()
			panel.valueLabel.text = panel.valueBar.value..'';
			self:OnNumberChanged(name);
		end
	end
	panel.valueLabel.textChange = function() 
		local num = tonumber(panel.valueLabel.text) or 0;
		if not hideBar then
			panel.valueBar.value = num;
		end
		self:OnNumberChanged(name);
	end
	return panel;
end

function UIEditeLight:OnColorChanged(name,label)
	local panel = self.panels[name];
	if not panel then
		return;
	end
	
	local a = panel.aBar.value;
	local r = panel.rBar.value;
	local g = panel.gBar.value;
	local b = panel.bBar.value;
	
	local color = EditeController:GetRGBAColor(r,g,b,a);
	
	if not label then
		panel.valueLabel.text = EditeController:ColorToString(color);
	end
	
	if not self.currItem then
		return;
	end
	
	local rgb,alpha = EditeController:GetRGBColor(r,g,b,a);
	panel:drawRect(rgb,alpha);
	
	if self.currItem.key == name then
		self.currLight.light[name] = color;
		CPlayerMap:SetPlayerLight();
		CPlayerMap:SetSceneLight();
		CPlayerMap:SetSceneFog();
		CPlayerMap.objSceneMap:SetLights();
		return;
	end
	
	self.currItem.light[name] = color;
	
	
	CPlayerMap:SetPlayerLight();
	CPlayerMap:SetSceneLight();
	CPlayerMap:SetSceneFog();
	CPlayerMap.objSceneMap:SetLights();
	
end

function UIEditeLight:OnBoolChanged(name)
	local panel = self.panels[name];
	if not panel then
		return;
	end
	local value = panel.valueBar.selected;
	if self.currItem.key == name then
		self.currLight.light[name] = value;
		CPlayerMap:SetPlayerLight();
		CPlayerMap:SetSceneLight();
		CPlayerMap:SetSceneFog();
		CPlayerMap.objSceneMap:SetLights();
		return;
	end
	
	
	self.currItem.light[name] = value;
	CPlayerMap:SetPlayerLight();
	CPlayerMap:SetSceneLight();
	CPlayerMap:SetSceneFog();
	CPlayerMap.objSceneMap:SetLights();
end

function UIEditeLight:OnNumberChanged(name)
	local panel = self.panels[name];
	if not panel then
		return;
	end

	local value = tonumber(panel.valueLabel.text);
	if self.currItem.key == name then
		self.currLight.light[name] = value;
		CPlayerMap:SetPlayerLight();
		CPlayerMap:SetSceneLight();
		CPlayerMap:SetSceneFog();
		CPlayerMap.objSceneMap:SetLights();
		return;
	end
	
	
	self.currItem.light[name] = value;
	CPlayerMap:SetPlayerLight();
	CPlayerMap:SetSceneLight();
	CPlayerMap:SetSceneFog();
	CPlayerMap.objSceneMap:SetLights();
	
end

function UIEditeLight:OnResetBtnClick()
	EditeController:ResetLight();
	self:OnTypeMenuClick();
end

function UIEditeLight:GetItemPanel()
	
end

function UIEditeLight:OnTypeMenuClick(event)
	local index = self.objSwf.typeMenu.selectedIndex + 1;
	local item = self.types[index];
	if not item then
		return; 
	end
	self['Update'..item.key](self);
end

function UIEditeLight:OnAddMenuClick(event)
	local index = self.objSwf.typeMenu.selectedIndex + 1;
	if index ~= 2 then
		return;
	end
	
	index = self.objSwf.addMenu.selectedIndex + 1;
	local item = self.adds[index];
	if not item then
		return; 
	end
	
	local map = EditeModel:GetSceneLight(CPlayerMap:GetCurMapID(),true);
	local new = table.clone(item.light);
	map[item.key] = new;
	
	self:UpdateList(map);
end

function UIEditeLight:UpdateLightCommon()
	_G.AnlyLightCommon = true;
	self:UpdateList(LightCommon);
	CPlayerMap:SetPlayerLight();
	CPlayerMap:SetSceneLight();
	CPlayerMap:SetSceneFog();
	CPlayerMap.objSceneMap:SetLights();
	self:UpdateAddMenu();
	self.objSwf.addMenu.disabled = true;
end

function UIEditeLight:UpdateSceneLight()
	_G.AnlyLightCommon = false;
	local map = EditeModel:GetSceneLight(CPlayerMap:GetCurMapID(),true);
	self:UpdateList(map);
	CPlayerMap:SetPlayerLight();
	CPlayerMap:SetSceneLight();
	CPlayerMap:SetSceneFog();
	CPlayerMap.objSceneMap:SetLights();
	self.objSwf.addMenu.disabled = false;
end

function UIEditeLight:UpdateList(data)
	self.currLight = nil;
	self.currItem = nil;
	self.lights = {};
	self.items = {};
	local swf = self.objSwf;
	swf.lightList.dataProvider:cleanUp();
	for name,light in pairs(data) do
		local vo = {};
		vo.name = self.names[name];
		vo.key = name;
		vo.light = light;
		table.push(self.lights,vo);
		swf.lightList.dataProvider:push(vo.name);
	end
	swf.lightList:invalidateData();
	swf.lightList.selectedIndex = 0;
	
	swf.itemList.dataProvider:cleanUp();
	swf.itemList:invalidateData();
	self.objSwf.infoContainer._visible = false;
	
end

function UIEditeLight:UpdateAddMenu()
	self.adds = {};
	self.objSwf.addMenu.dataProvider:cleanUp();
	for name,light in pairs(LightCommon) do
		local vo = {};
		vo.name = self.names[name];
		vo.key = name;
		vo.light = light;
		table.push(self.adds,vo);
		self.objSwf.addMenu.dataProvider:push(vo.name);
	end
	self.objSwf.addMenu.invalidateData();
	self.objSwf.addMenu.selectedIndex = 0;
end

function UIEditeLight:OnShow()
	-- self:UpdateLightCommon();
	self:OnTypeMenuClick();
end

function UIEditeLight:OnHide()
	_G.AnlyLightCommon = false;
end

function UIEditeLight:GetHideBar()
	if not self.currLight then
		return;
	end
	return self.currLight.key == 'fog';
end
