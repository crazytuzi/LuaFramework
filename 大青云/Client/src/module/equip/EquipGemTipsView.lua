--[[
宝石系统装备Tips
wangshuai

]]

_G.UIEquipGemTips = BaseUI:new("UIEquipGemTips");
UIEquipGemTips.pos = nil;
function UIEquipGemTips : Create ()
	self:AddSWF("equipgemTipsl.swf",true,"top");
end;

function UIEquipGemTips : Setdata(pos)
	self.pos = pos;
	self:Show();
end;
function UIEquipGemTips : OnShow()
	self:Sdata();
end;
function UIEquipGemTips : Sdata()
	local pos = self.pos;
	if not pos then 
		self:Hide();
		return ;
	end;
	local objSwf = self.objSwf;
	local list = EquipModel:GetGemAtPos(pos)
	local volist = {};
	local allatb = 0;
	local atbn = "";
	for c=1,3,1 do
		objSwf["item"..c]:setData(UIData.encode({}));
	end;
	for i,info in pairs(list)  do
		local cfg = t_gemgroup[info.id];
		local name = info.lvl..StrConfig["equip309"]..cfg.name;
		local atbname = enAttrTypeName[info.atbname];
		local solt = cfg.slot ;

		local vo = {};
		vo.Name = name;
		vo.atbname = atbname;
		vo.atbval = info.atbval;
		allatb = allatb + info.atbval;
		atbn = vo.atbname;
		vo.iconUrl = ResUtil:GetEquipGemIconUrl(cfg.icon, info.lvl)
		objSwf["item"..solt]:setData(UIData.encode(vo));
	end;
	if allatb == 0 then 
		allatb = "";
		atbn = StrConfig["equip315"]
	end;
	objSwf.atbval.text = allatb;
	objSwf.atbname.text = atbn;

	local coordinates = _sys:getRelativeMouse();
	local toX ,toY =  TipsUtils:GetTipsPos(objSwf._width,objSwf._height,TipsConsts.Dir_RightDown,nil)
	objSwf._x = toX;
	objSwf._y = toY;
end;

function UIEquipGemTips:Update()
	if not self.bShowState then return end;
	local objSwf = self.objSwf;
	local toX ,toY =  TipsUtils:GetTipsPos(self:GetWidth(),self:GetHeight(),TipsConsts.Dir_RightDown,nil)
	objSwf._x = toX;
	objSwf._y = toY;
end;
