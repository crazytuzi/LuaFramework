--[[
装备炼化
lizhuangzhuang
2016年1月11日14:46:51
]]

_G.UIEquipLianHua = BaseUI:new("UIEquipLianHua")

UIEquipLianHua.tabButton = {};

function UIEquipLianHua:Create()
	self:AddSWF("equipLianHuaPanel.swf",true,"center");
	
	self:AddChild(UIEquipSuperNewWash,FuncConsts.EquipSuperWash)
	self:AddChild(UIEquipSuperValWash,FuncConsts.EquipSuperValWash)
	self:AddChild(UIEquipSeniorJinglian,FuncConsts.EquipSeniorJinglian)
end

function UIEquipLianHua:OnLoaded(objSwf)
	objSwf.closepanel.click = function() self:OnClosePanel()end;
	--
	self:GetChild(FuncConsts.EquipSuperWash):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.EquipSuperValWash):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.EquipSeniorJinglian):SetContainer(objSwf.childPanel);

	self.tabButton[FuncConsts.EquipSuperWash] = objSwf.btnSuperNewWash;
	self.tabButton[FuncConsts.EquipSuperValWash] = objSwf.btnSuperJinglian;
	self.tabButton[FuncConsts.EquipSeniorJinglian] = objSwf.btnSeniorJinglian;
	--
	for name,btn in pairs(self.tabButton) do 
		btn.click = function() self:OnTabButtonClick(name);end;
	end;
end

function UIEquipLianHua:GetHeight()
	return 683;
end

function UIEquipLianHua:OnShow()
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
	self:OnTabButtonClick(FuncConsts.EquipSuperWash);
end

function UIEquipLianHua:OnTabButtonClick(name,...)
	if not self.tabButton[name] then
		return;
	end
	local child = self:GetChild(name);
	if not child then
		return;
	end
	self.tabButton[name].selected = true;
	self:ShowChild(name,nil,...);
end

function UIEquipLianHua:OnClosePanel()
	self:Hide();
end

-- 面板缓动
function UIEquipLianHua:IsTween()
	return true;
end

--面板类型
function UIEquipLianHua:GetPanelType()
	return 1;
end

-- 打开音效
function UIEquipLianHua:IsShowSound()
	return true;
end;

function UIEquipLianHua:IsShowLoading()
	return true;
end