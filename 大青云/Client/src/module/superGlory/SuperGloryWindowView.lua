--[[
至尊王帮弹出ui 查看详细信息
wangshaui
]]

_G.UISuperGloryWindow =  BaseUI:new("UISuperGloryWindow");
	
UISuperGloryWindow.roleId = nil;
function UISuperGloryWindow:Create()
	self:AddSWF("SuperGloryRoleInfoWindow.swf",true,"top")
end;

function UISuperGloryWindow:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:OnClosePanel() end;
	objSwf.btnSearch.click = function() self:OnRoleSearchInfo() end;
end;

function UISuperGloryWindow:OnShow()
	local objSwf = self.objSwf;
	local vo = SuperGloryModel:GetSuperRoleInfoID(self.roleId);
	if not vo then 
		self:Hide()
		return;
	end;
	objSwf.roleName.text = vo.roleName;
	objSwf.unionName.text = vo.unionName;
	objSwf.roleLvl.text = vo.lvl;
	objSwf.roleFight.text = vo.fight;
	
	local toX ,toY =  TipsUtils:GetTipsPos(self:GetWidth(),self:GetHeight(),TipsConsts.Dir_RightDown,nil)
	objSwf._x = toX;
	objSwf._y = toY;
end;

function UISuperGloryWindow:OnRoleSearchInfo()
	RoleController:ViewRoleInfo(self.roleId,0)
	self:Hide();
end;

function UISuperGloryWindow:OnHide()

end;

function UISuperGloryWindow:SetShowData(id)
	self.roleId = id;
end;
function UISuperGloryWindow:OnClosePanel()
	self:Hide()
end;