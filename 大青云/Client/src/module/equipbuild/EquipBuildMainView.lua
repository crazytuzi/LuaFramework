--[[
装备打造mainPanle
wangshaui
]]
_G.UIEquipBuildMain = BaseUI:new("UIEquipBuildMain")


UIEquipBuildMain.tabButton = {};

function UIEquipBuildMain:Create()
	self:AddSWF("equipBuildMainPanel.swf",true,"center")
	
	self:AddChild(UIEquipBuild,FuncConsts.EquipBuild);
	self:AddChild(UIEquipDecomp,FuncConsts.EquipDecomp);
	self:AddChild(UIEquipSuperUp,FuncConsts.EquipSuperUp);
	-- self:AddChild(UIEquipSuperDown,FuncConsts.EquipSuperDown);
end

function UIEquipBuildMain:OnLoaded(objSwf)
	objSwf.closepanel.click = function() self:OnClosePanel()end;
	--
	self:GetChild(FuncConsts.EquipSuperDown):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.EquipSuperUp):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.EquipBuild):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.EquipDecomp):SetContainer(objSwf.childPanel);
	
	-- self.tabButton[FuncConsts.EquipSuperDown] = objSwf.btnSuperDown;
	self.tabButton[FuncConsts.EquipSuperUp] = objSwf.btnSuperUp;

	self.tabButton[FuncConsts.EquipBuild] = objSwf.btnbuild;
	self.tabButton[FuncConsts.EquipDecomp] = objSwf.btnDecomp;

	for name,btn in pairs(self.tabButton) do 
		btn.click = function() self:OnTabButtonClick(name);end;
	end;
end

function UIEquipBuildMain:GetHeight()
	return 683;
end

function UIEquipBuildMain:OnShow()
	EquipNewTipsManager:CloseAll();
	for funcId,btn in pairs(self.tabButton) do
		if FuncManager:GetFuncIsOpen(funcId) then
			btn.visible = true;
		else
			btn.visible = false;
		end
	end
	if #self.args > 0 then
		local otherArgs = {};
		if #self.args > 1 then
			for i=2,#self.args do
				table.push(otherArgs,self.args[i]);
			end
		end
		if self.tabButton[self.args[1]] then
		
			self:OnTabButtonClick(self.args[1],unpack(otherArgs));
			return;
		end
	end
	self:OnTabButtonClick(FuncConsts.EquipBuild);
end;

function UIEquipBuildMain:OnHide()

end;

function UIEquipBuildMain:OnTabButtonClick(name,...)
	if not self.tabButton[name] then
		return;
	end
	local child = self:GetChild(name);
	if not child then
		return;
	end
	self.tabButton[name].selected = true;
	self:ShowChild(name,nil,...);
end;

function UIEquipBuildMain:OnClosePanel()
	self:Hide();
end;


-- 面板缓动
function UIEquipBuildMain:IsTween()
	return true;
end;

--面板加载的附带资源
function UIEquipBuildMain:WithRes()
	 return {"equipbuildPanel.swf"}
end

--面板类型
function UIEquipBuildMain:GetPanelType()
	return 1;
end

-- 打开音效
function UIEquipBuildMain:IsShowSound()
	return true;
end;

function UIEquipBuildMain:IsShowLoading()
	return true;
end
