--[[
卓越道具获得属性
lizhuangzhuang
2015年6月2日11:36:28
]]

_G.UIEquipSuperAttrGet = BaseUI:new("UIEquipSuperAttrGet");

UIEquipSuperAttrGet.isNoTip = false;

UIEquipSuperAttrGet.id = 0;
UIEquipSuperAttrGet.val1 = 0;

function UIEquipSuperAttrGet:Create()
	self:AddSWF("superAttrGet.swf",true,"center");
end

function UIEquipSuperAttrGet:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
end

function UIEquipSuperAttrGet:Open(id,val1)
	if self.isNoTip then 
		FloatManager:AddCenter(string.format(StrConfig['equip622'],self:GetSuperStr(id,val1)));
		return;
	end
	--
	self.id = id;
	self.val1 = val1;
	if self:IsShow() then
		self:OnShow();
		self:Top();
	else
		self:Show();
	end
end

function UIEquipSuperAttrGet:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfContent.htmlText = self:GetSuperStr(self.id,self.val1);
end

function UIEquipSuperAttrGet:GetSuperStr(id,val1)
	local cfg = t_fujiashuxing[id];
	if not cfg then return ""; end
	local attrStr = formatAttrStr(cfg.attrType,val1);
	return string.format("<font color='%s'>「%s」%s</font>",TipsConsts.SuperColor,cfg.name,attrStr);
end

function UIEquipSuperAttrGet:OnBtnCloseClick()
	local objSwf = self.objSwf;
	if objSwf.cbNoTip.selected then
		self.isNoTip = true;
	end
	self:Hide();
end

function UIEquipSuperAttrGet:OnBtnConfirmClick()
	local objSwf = self.objSwf;
	if objSwf.cbNoTip.selected then
		self.isNoTip = true;
	end
	FuncManager:OpenFunc(FuncConsts.EquipSuperUp);
	self:Hide();
end