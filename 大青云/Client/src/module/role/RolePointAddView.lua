--[[
任务属性加点面板
2015年5月6日14:21:41
haohu
]]

_G.UIRolePointAdd = BaseUI:new("UIRolePointAdd");

UIRolePointAdd.pointBtns      = {}; -- 加点按钮
UIRolePointAdd.availablePoint = 0; -- 当前可用加点
UIRolePointAdd.pointAdd       = {}; -- 当前已用加点
UIRolePointAdd.conversion     = nil -- 属性换算系数表

function UIRolePointAdd:Create()
	self:AddSWF("pointAddPanel.swf", true, nil);
end


function UIRolePointAdd:OnLoaded( objSwf )
	self:Init( objSwf );
	self:RegisterEvents( objSwf );
end

UIRolePointAdd.MAX = "max";
UIRolePointAdd.ADD = "add";
UIRolePointAdd.RED = "red";
UIRolePointAdd.MIN = "min";

function UIRolePointAdd:Init( objSwf )
	self:InitTxts( objSwf ) -- 文本格式
	self:InitPointBtns( objSwf ) -- 属性点调整按钮
	self:InitAttrAddMc( objSwf ) -- 显示二级属性提高数值的mc
	self:InitAttrLabel( objSwf ) -- 一级属性label
end

function UIRolePointAdd:InitTxts( objSwf )
	objSwf.txtPoli.autoSize     = "center"
	objSwf.txtTipo.autoSize     = "center"
	objSwf.txtShenfa.autoSize   = "center"
	objSwf.txtJingshen.autoSize = "center"
end

function UIRolePointAdd:InitPointBtns( objSwf )
	objSwf.btnPoliMax.data        = { action = UIRolePointAdd.MAX, attr = enAttrType.eaHunLi }
	objSwf.btnPoliAdd.data        = { action = UIRolePointAdd.ADD, attr = enAttrType.eaHunLi }
	objSwf.btnPoliReduce.data     = { action = UIRolePointAdd.RED, attr = enAttrType.eaHunLi }
	objSwf.btnPoliMin.data        = { action = UIRolePointAdd.MIN, attr = enAttrType.eaHunLi }
	objSwf.btnTipoMax.data        = { action = UIRolePointAdd.MAX, attr = enAttrType.eaTiPo }
	objSwf.btnTipoAdd.data        = { action = UIRolePointAdd.ADD, attr = enAttrType.eaTiPo }
	objSwf.btnTipoReduce.data     = { action = UIRolePointAdd.RED, attr = enAttrType.eaTiPo }
	objSwf.btnTipoMin.data        = { action = UIRolePointAdd.MIN, attr = enAttrType.eaTiPo }
	objSwf.btnShenfaMax.data      = { action = UIRolePointAdd.MAX, attr = enAttrType.eaShenFa }
	objSwf.btnShenfaAdd.data      = { action = UIRolePointAdd.ADD, attr = enAttrType.eaShenFa }
	objSwf.btnShenfaReduce.data   = { action = UIRolePointAdd.RED, attr = enAttrType.eaShenFa }
	objSwf.btnShenfaMin.data      = { action = UIRolePointAdd.MIN, attr = enAttrType.eaShenFa }
	objSwf.btnJingshenMax.data    = { action = UIRolePointAdd.MAX, attr = enAttrType.eaJingShen }
	objSwf.btnJingshenAdd.data    = { action = UIRolePointAdd.ADD, attr = enAttrType.eaJingShen }
	objSwf.btnJingshenReduce.data = { action = UIRolePointAdd.RED, attr = enAttrType.eaJingShen }
	objSwf.btnJingshenMin.data    = { action = UIRolePointAdd.MIN, attr = enAttrType.eaJingShen }

	self.pointBtns = {
		objSwf.btnPoliMax,
		objSwf.btnPoliAdd,
		objSwf.btnPoliReduce,
		objSwf.btnPoliMin,
		objSwf.btnTipoMax,
		objSwf.btnTipoAdd,
		objSwf.btnTipoReduce,
		objSwf.btnTipoMin,
		objSwf.btnShenfaMax,
		objSwf.btnShenfaAdd,
		objSwf.btnShenfaReduce,
		objSwf.btnShenfaMin,
		objSwf.btnJingshenMax,
		objSwf.btnJingshenAdd,
		objSwf.btnJingshenReduce,
		objSwf.btnJingshenMin
	};
end

function UIRolePointAdd:InitAttrAddMc( objSwf )
	self.lv2AttrAddBtns = {
		[ enAttrType.eaMaxHp ]     = objSwf.btnHpAdd,
		[ enAttrType.eaGongJi ]    = objSwf.btnAtkAdd,
		[ enAttrType.eaFangYu ]    = objSwf.btnDefAdd,
		[ enAttrType.eaMingZhong ] = objSwf.btnHitAdd,
		[ enAttrType.eaShanBi ]    = objSwf.btnDodgeAdd,
		[ enAttrType.eaBaoJi ]     = objSwf.btnCritAdd,
		[ enAttrType.eaRenXing ]   = objSwf.btnTenacityAdd
	}
end

function UIRolePointAdd:InitAttrLabel( objSwf )
	objSwf.btnPoli.data     = enAttrType.eaHunLi
	objSwf.btnTipo.data     = enAttrType.eaTiPo
	objSwf.btnShenfa.data   = enAttrType.eaShenFa
	objSwf.btnJingshen.data = enAttrType.eaJingShen
end

function UIRolePointAdd:RegisterEvents( objSwf )
	for _, btn in pairs(self.pointBtns) do
		btn.click = function(e) self:OnPointBtnClick(e); end
	end
	objSwf.btnClose.click       = function() self:OnBtnCloseClick() end
	objSwf.btnConfirm.click     = function() self:OnBtnConfirmClick() end
	objSwf.btnSuggest.click     = function() self:OnBtnSuggestClick() end
	objSwf.rbManul.click        = function() self:OnAutoPointSetChange(false) end
	objSwf.rbAuto.click         = function() self:OnAutoPointSetChange(true) end
	objSwf.btnPoli.rollOver     = function(e) self:OnAttrLabelRollOver(e) end
	objSwf.btnPoli.rollOut      = function(e) self:OnAttrLabelRollOut(e) end
	objSwf.btnTipo.rollOver     = function(e) self:OnAttrLabelRollOver(e) end
	objSwf.btnTipo.rollOut      = function(e) self:OnAttrLabelRollOut(e) end
	objSwf.btnShenfa.rollOver   = function(e) self:OnAttrLabelRollOver(e) end
	objSwf.btnShenfa.rollOut    = function(e) self:OnAttrLabelRollOut(e) end
	objSwf.btnJingshen.rollOver = function(e) self:OnAttrLabelRollOver(e) end
	objSwf.btnJingshen.rollOut  = function(e) self:OnAttrLabelRollOut(e) end
end

function UIRolePointAdd:OnBtnCloseClick()
	self:Hide()
end

--加点确认
function UIRolePointAdd:OnBtnConfirmClick()
	local list = {};
	local attrs = { enAttrType.eaHunLi, enAttrType.eaTiPo, enAttrType.eaShenFa, enAttrType.eaJingShen };
	for _, attrType in pairs( attrs ) do
		local addingPoint = self.pointAdd[attrType];
		list[#list+1] = { type = attrType, value = toint( addingPoint, -1 ) };
	end
	RoleController:ChangePlayerPoint( list );
end

--推荐加点
function UIRolePointAdd:OnBtnSuggestClick()
	local info = MainPlayerModel.humanDetailInfo;
	local autoPoint = RoleUtil:GetAutoPoint( info.eaLeftPoint );
	for eaType, value in pairs(self.pointAdd ) do
		if autoPoint[eaType] then
			self.pointAdd[eaType] = autoPoint[eaType];
		end
	end
	self.availablePoint = 0;
	self:ShowLv1Attr();
	self:ShowLv2Attr()
	self:UpdateBtnState();
end


function UIRolePointAdd:OnPointBtnClick(e)
	local vo = e.target and e.target.data;
	if not vo then return end
	local action = vo.action;
	local attrType = vo.attr;
	if action == UIRolePointAdd.MAX then
		if self.availablePoint == 0 then return end
		self.pointAdd[attrType] = self.pointAdd[attrType] + self.availablePoint;
		self.availablePoint = 0;
	elseif action == UIRolePointAdd.ADD then
		if self.availablePoint == 0 then return end
		self.pointAdd[attrType] = self.pointAdd[attrType] + 1;
		self.availablePoint = self.availablePoint - 1;
	elseif action == UIRolePointAdd.RED then
		if self.pointAdd[attrType] <= 0 then return end;
		self.pointAdd[attrType] = self.pointAdd[attrType] - 1;
		self.availablePoint = self.availablePoint + 1;
	elseif action == UIRolePointAdd.MIN then
		if self.pointAdd[attrType] <= 0 then return end;
		self.availablePoint = self.availablePoint + self.pointAdd[attrType];
		self.pointAdd[attrType] = 0;
	end
	self:ShowLv1Attr();
	self:ShowLv2Attr()
	self:UpdateBtnState();
end

function UIRolePointAdd:OnShow()
	self:InitPoint()
	self:UpdateShow()
	self:UpdateParentEffect()
end

function UIRolePointAdd:InitPoint()
	UIRolePointAdd.availablePoint = MainPlayerModel.humanDetailInfo.eaLeftPoint;
	UIRolePointAdd.pointAdd = {
		[enAttrType.eaHunLi]    = 0,
		[enAttrType.eaTiPo]     = 0,
		[enAttrType.eaShenFa]   = 0,
		[enAttrType.eaJingShen] = 0
	};
end

function UIRolePointAdd:OnHide()
	self:UpdateParentEffect()
end

function UIRolePointAdd:ShowEffect()
	local objSwf = self.objSwf
	if not objSwf then return end
	-- objSwf.effect._visible = MainPlayerModel.humanDetailInfo.eaLeftPoint > 0
end

function UIRolePointAdd:UpdateParentEffect()
	UIRoleBasic:ShowAddPointEffect()
end

function UIRolePointAdd:OnDelete()
	for _, btn in pairs( self.pointBtns ) do
		btn.data = nil;
	end
	self.pointBtns = {};
	self.lv2AttrAddBtns = {};
end

function UIRolePointAdd:UpdateShow()
	self:ShowLv1Attr();
	self:ShowLv2Attr()
	self:UpdateBtnState();
	self:ShowOption();
	self:ShowEffect()
end

function UIRolePointAdd:ShowLv1Attr()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local info = MainPlayerModel.humanDetailInfo;
	local pointAdd = self.pointAdd;
	objSwf.txtPoli.htmlText     = self:BuildAttrStr( info.eaHunLi, pointAdd[enAttrType.eaHunLi] );
	objSwf.txtTipo.htmlText     = self:BuildAttrStr( info.eaTiPo, pointAdd[enAttrType.eaTiPo] );
	objSwf.txtShenfa.htmlText   = self:BuildAttrStr( info.eaShenFa, pointAdd[enAttrType.eaShenFa] );
	objSwf.txtJingshen.htmlText = self:BuildAttrStr( info.eaJingShen, pointAdd[enAttrType.eaJingShen] );
	objSwf.txtPoint.text = self.availablePoint;
end

function UIRolePointAdd:ShowLv2Attr()
	local objSwf = self.objSwf
	if not objSwf then return end
	local info = MainPlayerModel.humanDetailInfo
	objSwf.txtHp.htmlText       = info.eaMaxHp
	objSwf.txtAtk.htmlText      = info.eaGongJi
	objSwf.txtDef.htmlText      = info.eaFangYu
	objSwf.txtHit.htmlText      = info.eaMingZhong
	objSwf.txtDodge.htmlText    = info.eaShanBi
	objSwf.txtCrit.htmlText     = info.eaBaoJi
	objSwf.txtTenacity.htmlText = info.eaRenXing

	local lv2pointAdd = self:GetLv2PointAddTable()
	for attrType, btn in pairs( self.lv2AttrAddBtns ) do
		local attrAdd = lv2pointAdd[ attrType ]
		if attrAdd > 0 then
			btn._visible = true
			btn.label = string.format( "+%s", self:ParseNum( attrAdd ) )
		else
			btn._visible = false
		end
	end
end

function UIRolePointAdd:GetLv2PointAddTable()
	local table = {}
	local pointAdd = self.pointAdd
	local conversion = self:GetConversionTable()
	table[enAttrType.eaMaxHp]     = pointAdd[enAttrType.eaTiPo]     * conversion.TiPo_To_MaxHp
	table[enAttrType.eaGongJi]    = pointAdd[enAttrType.eaHunLi]    * conversion.Hunli_To_Atk
	table[enAttrType.eaFangYu]    = pointAdd[enAttrType.eaTiPo]     * conversion.TiPo_To_Def
	table[enAttrType.eaMingZhong] = pointAdd[enAttrType.eaShenFa]   * conversion.ShengFa_To_Hit
	table[enAttrType.eaShanBi]    = pointAdd[enAttrType.eaShenFa]   * conversion.Shengfa_To_Dodge
	table[enAttrType.eaBaoJi]     = pointAdd[enAttrType.eaJingShen] * conversion.JingShen_To_Cri
	table[enAttrType.eaRenXing]   = pointAdd[enAttrType.eaJingShen] * conversion.JingShen_To_DefCri
	return table
end

function UIRolePointAdd:GetConversionTable()
	if not self.conversion then
		local conversion = {}
		conversion.TiPo_To_MaxHp      = _G.t_baseAttr.TiPo_To_MaxHp.val
		conversion.Hunli_To_Atk       = _G.t_baseAttr.Hunli_To_Atk.val
		conversion.TiPo_To_Def        = _G.t_baseAttr.TiPo_To_Def.val
		conversion.ShengFa_To_Hit     = _G.t_baseAttr.ShengFa_To_Hit.val
		conversion.Shengfa_To_Dodge   = _G.t_baseAttr.Shengfa_To_Dodge.val
		conversion.JingShen_To_Cri    = _G.t_baseAttr.JingShen_To_Cri.val
		conversion.JingShen_To_DefCri = _G.t_baseAttr.JingShen_To_DefCri.val
		self.conversion = conversion
	end
	return self.conversion
end

-- 去掉小数部分
function UIRolePointAdd:ParseNum( num )
	-- local num1, num2 = math.modf( num )
	-- local strNum2 = tostring( math.modf( num2 * 1000 ) )
	-- while strNum2:tail("0") do
		-- strNum2 = string.sub( strNum2, 1, -2 )
	-- end
	-- return strNum2 == "" and tostring(num1) or string.format( "%s.%s", num1, strNum2 )
	return toint(num , -1)
end

function UIRolePointAdd:BuildAttrStr( attr, attrAddition )
	local attrAddStr = self:ParseNum( attrAddition )
	local attrAdditionStr = attrAddition > 0 and string.format( " +%s", attrAddStr ) or "";
	return string.format( "%s<font color='#29cc00'>%s</font>", attr, attrAdditionStr );
end

function UIRolePointAdd:UpdateBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local info = MainPlayerModel.humanDetailInfo;
	local totalPoint = info.eaLeftPoint;
	for _, btn in pairs( self.pointBtns ) do
		local vo = btn.data;
		if vo.action == UIRolePointAdd.MAX or vo.action == UIRolePointAdd.ADD then
			btn.disabled = not (self.availablePoint > 0);
		elseif vo.action == UIRolePointAdd.MIN or vo.action == UIRolePointAdd.RED then
			btn.disabled = not (self.pointAdd[vo.attr] > 0);
		end
	end
	objSwf.btnConfirm.disabled = not (self.availablePoint < totalPoint);
	objSwf.btnSuggest.disabled = not (self.availablePoint > 0);
	-- objSwf.btnSuggestEffect._visible = self.availablePoint > 0
	-- objSwf.btnConfirmEffect._visible = (self.availablePoint == 0) and (totalPoint > 0)
end

--自动加点设置改变
function UIRolePointAdd:OnAutoPointSetChange(auto)
	if auto == SetSystemVO:GetRoleAutoSet() then 
		return;
	end
	local val, str = SetSystemModel:GetSetSysModel();
	if auto then
		val = val + SetSystemConsts.ROLEAUTOPOINTSET;
	else
		val = val - SetSystemConsts.ROLEAUTOPOINTSET;
	end
	SetSystemController:OnSendSetModel(val, str);
end

function UIRolePointAdd:OnAttrLabelRollOver(e)
	local attrType = e.target.data
	local tips = "tool tips missing"
	if attrType == enAttrType.eaHunLi then
		tips = StrConfig['role116']
	elseif attrType == enAttrType.eaTiPo then
		tips = StrConfig['role117']
	elseif attrType == enAttrType.eaShenFa then
		tips = StrConfig['role118']
	elseif attrType == enAttrType.eaJingShen then
		tips = StrConfig['role119']
	end
	TipsManager:ShowBtnTips( tips, TipsConsts.Dir_RightDown )
end

function UIRolePointAdd:OnAttrLabelRollOut(e)
	TipsManager:Hide()
end

function UIRolePointAdd:ShowOption()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local auto = SetSystemVO:GetRoleAutoSet();
	objSwf.rbAuto.selected = auto;
	objSwf.rbManul.selected = not auto;
end

function UIRolePointAdd:ListNotificationInterests()
	return { NotifyConsts.PlayerAttrChange };
end

function UIRolePointAdd:HandleNotification( name, body )
	if name == NotifyConsts.PlayerAttrChange then
		local attrType = body.type;
		if attrType == enAttrType.eaLeftPoint or attrType == enAttrType.eaHunLi or
				attrType == enAttrType.eaTiPo or attrType == enAttrType.eaShenFa or
				attrType == enAttrType.eaJingShen then
			self:InitPoint();
			self:UpdateShow();
		elseif attrType == enAttrType.eaMaxHp or attrType == enAttrType.eaGongJi or
				attrType == enAttrType.eaFangYu or attrType == enAttrType.eaMingZhong or
				attrType == enAttrType.eaShanBi or attrType == enAttrType.eaBaoJi or
				attrType == enAttrType.eaRenXing then 
			self:ShowLv2Attr()
		end
	end
end
