--[[
	帮派加持tips
	2015年5月18日, PM 09:15:17
	wangyanwei
]]

_G.UIUnionAidTips = BaseUI:new('UIUnionAidTips');

function UIUnionAidTips:Create()
	self:AddSWF("unionAidTips.swf", true, 'center');
end

function UIUnionAidTips:OnLoaded(objSwf)
	objSwf.txt_1.text = StrConfig['union174'];
	objSwf.txt_2.text = StrConfig['union175'];end


function UIUnionAidTips:OnShow()
	if UnionModel:GetMyUnionId() then
		UnionController:ReqAidInfo();
	end
	self:UpdatePos();
end

function UIUnionAidTips:OnUpDateAidInfo(obj)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_guildwash[obj.aidLevel];
	if not cfg then 
		cfg = {};
		cfg.expadd = 0;
		cfg.moneyadd = 0;
		cfg.zazenadd = 0;
	end
	objSwf.txt_aidLevel.htmlText = string.format(StrConfig['union170'],obj.aidLevel);
	objSwf.txt_aidExp.htmlText = string.format(StrConfig['union171'],cfg.expadd);
	objSwf.txt_aidMoney.htmlText = string.format(StrConfig['union172'],cfg.moneyadd);
	objSwf.txt_aidSit.htmlText = string.format(StrConfig['union173'],cfg.zazenadd);
	objSwf.txt_att.htmlText = "<font color ='#d5b772'>" .. enAttrTypeName[AttrParseUtil.AttMap[(split('txt_att','_'))[2]]] .. '</font>  +' .. obj.att;
	objSwf.txt_def.htmlText = "<font color ='#d5b772'>" .. enAttrTypeName[AttrParseUtil.AttMap[(split('txt_def','_'))[2]]] .. '</font>  +' .. obj.def;
	objSwf.txt_fhp.htmlText = "<font color ='#d5b772'>" .. enAttrTypeName[AttrParseUtil.AttMap[(split('txt_fhp','_'))[2]]] .. '</font>  +' .. obj.maxhp;
	objSwf.txt_subdef.htmlText = "<font color ='#d5b772'>" .. enAttrTypeName[AttrParseUtil.AttMap[(split('txt_subdef','_'))[2]]] .. '</font>  +' .. obj.cri;
	objSwf.txt_maxAtt.htmlText = string.format(StrConfig['union165'],cfg.atkmax);
	objSwf.txt_maxDef.htmlText = string.format(StrConfig['union165'],cfg.defmax);
	objSwf.txt_maxFhp.htmlText = string.format(StrConfig['union165'],cfg.hpmax);
	objSwf.txt_maxSubdef.htmlText = string.format(StrConfig['union165'],cfg.subdefmax);
end

function UIUnionAidTips:onResize()
	self:UpdatePos();
end

function UIUnionAidTips:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local tipsDir = TipsConsts.Dir_RightDown;
	local tipsX, tipsY = TipsUtils:GetTipsPos( self:GetWidth(), self:GetHeight(), tipsDir, self.target );
	objSwf._x = tipsX;
	objSwf._y = tipsY;
end

function UIUnionAidTips:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		self:UpdatePos();
	elseif name == NotifyConsts.UnionAidInfoUpDate then
		self:OnUpDateAidInfo(body);
	end
end

function UIUnionAidTips:ListNotificationInterests()
	return {
		NotifyConsts.StageMove,NotifyConsts.UnionAidInfoUpDate
	}
end