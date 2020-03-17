--[[
	妖丹主界面的TIPS
	2015年5月18日, PM 05:20:22
	wangyanwei
]]
_G.UIRoleBoegeyTips = BaseUI:new('UIRoleBoegeyTips');

function UIRoleBoegeyTips:Create()
	self:AddSWF('roleAttrobuteTip.swf', true, 'center');
end

function UIRoleBoegeyTips:OnLoaded(objSwf)
	objSwf.txt_1.text = UIStrConfig['role500'];
	objSwf.txt_2.text = UIStrConfig['role501'];
	objSwf.txt_3.text = UIStrConfig['role502'];
	objSwf.txt_4.text = UIStrConfig['role503'];
end

function UIRoleBoegeyTips:OnShow()
	self:UpdatePos();
	self:ShowTxt();
end

function UIRoleBoegeyTips:ShowTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = RoleBoegeyPillModel:GetYaoDanNumList();
	objSwf.txt_att.text = 	enAttrTypeName[AttrParseUtil.AttMap[(split('txt_att','_'))[2]]] .. '  +' .. 	  (cfg[1] or 0);
	objSwf.txt_def.text = 	enAttrTypeName[AttrParseUtil.AttMap[(split('txt_def','_'))[2]]] .. '  +' .. 	  (cfg[2] or 0);
	objSwf.txt_fhp.text = 	enAttrTypeName[AttrParseUtil.AttMap[(split('txt_fhp','_'))[2]]] .. '  +' .. 	  (cfg[3] or 0);
	objSwf.txt_cri.text = 	enAttrTypeName[AttrParseUtil.AttMap[(split('txt_cri','_'))[2]]] .. '  +' .. 	  (cfg[4] or 0);
	objSwf.txt_dodge.text = enAttrTypeName[AttrParseUtil.AttMap[(split('txt_dodge','_'))[2]]] .. '  +' .. 	  (cfg[5] or 0);
	objSwf.txt_hit.text = 	enAttrTypeName[AttrParseUtil.AttMap[(split('txt_hit','_'))[2]]] .. '  +' .. 	  (cfg[6] or 0);
end

function UIRoleBoegeyTips:onResize()
	self:UpdatePos();
end

function UIRoleBoegeyTips:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local tipsDir = TipsConsts.Dir_RightDown;
	local tipsX, tipsY = TipsUtils:GetTipsPos( self:GetWidth(), self:GetHeight(), tipsDir, self.target );
	objSwf._x = tipsX;
	objSwf._y = tipsY;
end

function UIRoleBoegeyTips:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		self:UpdatePos();
	end
end

function UIRoleBoegeyTips:ListNotificationInterests()
	return {
		NotifyConsts.StageMove,
	}
end