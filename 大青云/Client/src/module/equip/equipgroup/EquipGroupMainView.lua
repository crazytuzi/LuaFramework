--[[
装备套装
wangshaui
2015年10月31日17:18:08
]]
_G.UIEquipGroupMain = BaseUI:new("UIEquipGroupMain")


UIEquipGroupMain.tabButton = {};

function UIEquipGroupMain:Create()
	self:AddSWF("equipGroupPanel.swf",true,"center")
	
	self:AddChild(UIEquipGroupChange,"EquipGroupChange")
	self:AddChild(UIEquipGroupPeel,"EquipGroupPeel")
	self:AddChild(UIEquipGroupLvlUp,"EquipGroupLvlUp")
	self:AddChild(UIEquipGroupActivation,"EquipGroupActivation")
end

function UIEquipGroupMain:OnLoaded(objSwf)
	objSwf.closeBtn.click = function() self:OnClosePanel()end;
	--
	self:GetChild("EquipGroupChange"):SetContainer(objSwf.childPanel);
	self:GetChild("EquipGroupPeel"):SetContainer(objSwf.childPanel);
	self:GetChild("EquipGroupLvlUp"):SetContainer(objSwf.childPanel);
	self:GetChild("EquipGroupActivation"):SetContainer(objSwf.childPanel);
	
	self.tabButton["EquipGroupChange"] = objSwf.btnGroupChang;
	self.tabButton["EquipGroupPeel"] = objSwf.btnGroupPeel;
	self.tabButton["EquipGroupLvlUp"] = objSwf.btnGroupLvlUp;
	self.tabButton["EquipGroupActivation"] = objSwf.btnaActivation;

	for name,btn in pairs(self.tabButton) do 
		btn.click = function() self:OnTabButtonClick(name);end;
	end;
end

function UIEquipGroupMain:UpdataBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local rolelvl = MainPlayerModel.humanDetailInfo.eaLevel;
	
	if not FuncManager:GetFuncIsOpen(FuncConsts.GroupYangc) then
		objSwf.btnaActivation.visible = false;
	else
		objSwf.btnaActivation.visible = true;
	end;
end;

function UIEquipGroupMain:GetHeight()
	return 744;
end
function UIEquipGroupMain:GetWidth()
	return 1489;
end

function UIEquipGroupMain:OnShow()
	self:UpdataBtnState();
	self:UpdateMask()
	self:UpdateCloseButton()
	
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
	self:OnTabButtonClick("EquipGroupChange");
end;

function UIEquipGroupMain:OnHide()

end;

function UIEquipGroupMain:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

function UIEquipGroupMain:OnTabButtonClick(name,...)
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

function UIEquipGroupMain:OnClosePanel()
	self:Hide();
end;


-- 面板缓动
function UIEquipGroupMain:IsTween()
	return true;
end;

--面板加载的附带资源
function UIEquipGroupMain:WithRes()
	 return {"equipGroupChange.swf"}
end

--面板类型
function UIEquipGroupMain:GetPanelType()
	return 1;
end

-- 打开音效
function UIEquipGroupMain:IsShowSound()
	return true;
end;

function UIEquipGroupMain:IsShowLoading()
	return true;
end

function UIEquipGroupMain:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 10
	objSwf.mcMask._height = wHeight + 10
end

function UIEquipGroupMain:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
	self:UpdateCloseButton()
end

function UIEquipGroupMain:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.closeBtn._x = math.min( math.max( wWidth - 50, 1280 ), 1380 )
end