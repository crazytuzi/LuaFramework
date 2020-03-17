--[[
帮派仓库，
wangshaui
]]

_G.UIUnionWareHouse = BaseUI:new("UIUnionWareHouse")

UIUnionWareHouse.lablelist = {};
function UIUnionWareHouse:Create()
	self:AddSWF("unionWarehouse.swf",nil,true)
	self:AddChild(UIUnionWareHouseDonation,"donation");
	self:AddChild(UIUnionWareHouseInfomation,"infomation");
	self:AddChild(UIWarehouseWindow,"windowNum");
	self:AddChild(UIUnionWareHouseApply,"applyList");
end;

function UIUnionWareHouse:OnLoaded(objSwf)
	objSwf.btn_3._visible = false;
	self:GetChild("donation"):SetContainer(objSwf.childPanel)
	self:GetChild("infomation"):SetContainer(objSwf.childPanel)
	self:GetChild("windowNum"):SetContainer(objSwf.childPanel)
	self:GetChild("applyList"):SetContainer(objSwf.childPanel)

	self.lablelist["donation"] = objSwf.btn_1;
	self.lablelist["infomation"] = objSwf.btn_2;
	self.lablelist["applyList"] = objSwf.btn_3;

	for i,info in pairs(self.lablelist) do 
		info.click = function() self:OnLableClick(i) end;
	end;
	
end;

function UIUnionWareHouse:OnLableClick(name)
	self:ShowChildPanle(name)
end;

function UIUnionWareHouse:ShowChildPanle(name)
	local child = self:GetChild(name);

	if not child then return end;
	self:ShowChild(name);
	self.lablelist[name].selected = true;
end;

function UIUnionWareHouse:OnShow()
	self:ShowChildPanle("donation")
end;

function UIUnionWareHouse:OnHide()

end;