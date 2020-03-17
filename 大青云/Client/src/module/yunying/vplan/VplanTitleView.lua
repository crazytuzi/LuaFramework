--[[
	V计划称号
	2015年5月12日, AM 11:07:04
	wangyanwei
]]

_G.UIVplanTitle = BaseUI:new('UIVplanTitle');

function UIVplanTitle:Create()
	self:AddSWF("vplanTitle.swf",true,nil);
end

function UIVplanTitle:OnLoaded(objSwf)
	objSwf.btn_mon.click = function () self:OnMonClick(); end
	objSwf.btn_year.click = function () self:OnYearClick(); end
	--objSwf.btn_VplanOfficialWeb.click = function () VplanController:ToWebSite() end
end

function UIVplanTitle:OnShow()
	self:UpUidata();
end

function UIVplanTitle:OnHide()
	
end

function UIVplanTitle:UpUidata()
	--按钮操作
	self:OnUpPanelData();
	--文本操作
	self:OnUpTxtData();
end;

--月点击
function UIVplanTitle:OnMonClick()
	if VplanModel:GetmTitleState() then
		VplanController:ReqVplanTitle(1);
	else
		FloatManager:AddNormal(StrConfig["vplan208"]);
	end
end

--年点击
function UIVplanTitle:OnYearClick()
	local isYv = VplanModel:GetYearVplan() --年费
	if not isYv then 
		FloatManager:AddNormal(StrConfig["vplan505"]);
		return 
	end;
	if VplanModel:GetyTitleState() then
		VplanController:ReqVplanTitle(2);
	else
		FloatManager:AddNormal(StrConfig["vplan208"]);
	end
end

function UIVplanTitle:OnUpPanelData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	--是否月V会员
	local isVplan = VplanModel:GetIsVplan();

	local isYv = VplanModel:GetYearVplan() --年费
	local isMv = VplanModel:GetMonVplan()  --月费
	if isYv then 
		objSwf.btn_mon.disabled = true;
		objSwf.btn_year.disabled = false;
	else
		objSwf.btn_mon.disabled = false;
		objSwf.btn_year.disabled = false;
	end;
	--月是否领取(true未领取)
	local isGetMonthTitle = VplanModel:GetmTitleState();
	--年是否领取(true未领取)
	local isGetYearTitle = VplanModel:GetyTitleState()
	

	if isGetMonthTitle then 
		objSwf.btn_mon._visible = true;
		objSwf.yue_ling._visible = false;
	else
		objSwf.btn_mon._visible = false;
		objSwf.yue_ling._visible = true;
	end;

	if isGetYearTitle then 
		objSwf.btn_year._visible = true;
		objSwf.nian_ling._visible = false;
	else
		objSwf.btn_year._visible = false;
		objSwf.nian_ling._visible = true;
	end;


	-- --是否年费
	-- local isYearV = VplanModel:GetYearVplan();
	-- objSwf.btn_year.disabled = false;
	-- objSwf.btn_mon.disabled = false;
	-- if isVplan then
	-- 	if isGetMonthTitle then
	-- 		objSwf.btn_mon.label = StrConfig['vplan504'];
	-- 		objSwf.btn_mon.disabled = true;
	-- 	else
	-- 		print('是否领取了称号 VplanModel:GetmTitleState() Back--');
	-- 		print(VplanModel:GetmTitleState())
	-- 		objSwf.btn_mon.label = StrConfig['vplan505'];
	-- 	end
	-- else
	-- 	objSwf.btn_mon.label = StrConfig['vplan502'];
	-- end
	
	-- if isYearV then
	-- 	if VplanModel:GetyTitleState() then
	-- 		objSwf.btn_year.label = StrConfig['vplan504'];
	-- 		objSwf.btn_year.disabled = true;
	-- 	else
	-- 		objSwf.btn_year.label = StrConfig['vplan506'];
	-- 	end
	-- else
	-- 	objSwf.btn_year.label = StrConfig['vplan503'];
	-- end
end

function UIVplanTitle:OnUpTxtData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfgT1,cfgT2 = t_title[t_vtype[1].title],t_title[t_vtype[2].title];
	if not cfgT1 or not cfgT2 then return end
	-- local spT1,spT2 = split(cfgT1,'#'),split(cfgT2,'#');
	
	objSwf.monTitleTxt1.text = enAttrTypeName[AttrParseUtil.AttMap.att] .. ' + ' .. cfgT1.att;
	objSwf.monTitleTxt2.text = enAttrTypeName[AttrParseUtil.AttMap.def] .. ' + ' .. cfgT1.def;
	objSwf.monTitleTxt3.text = enAttrTypeName[AttrParseUtil.AttMap.hp] .. ' + ' .. cfgT1.hp;
	objSwf.monTitleTxt4.text = enAttrTypeName[AttrParseUtil.AttMap.hit] .. ' + ' .. cfgT1.hit;
	objSwf.monTitleTxt5.text = enAttrTypeName[AttrParseUtil.AttMap.dodge] .. ' + ' .. cfgT1.dodge;
	-- objSwf.monTitleTxt6.text = enAttrTypeName[AttrParseUtil.AttMap.cri] .. ' + ' .. cfgT1.cri;
	
	objSwf.yearTitleTxt1.text = enAttrTypeName[AttrParseUtil.AttMap.att] .. ' + ' .. cfgT2.att;
	objSwf.yearTitleTxt2.text = enAttrTypeName[AttrParseUtil.AttMap.def] .. ' + ' .. cfgT2.def;
	objSwf.yearTitleTxt3.text = enAttrTypeName[AttrParseUtil.AttMap.hp] .. ' + ' .. cfgT2.hp;
	objSwf.yearTitleTxt4.text = enAttrTypeName[AttrParseUtil.AttMap.hit] .. ' + ' .. cfgT2.hit;
	objSwf.yearTitleTxt5.text = enAttrTypeName[AttrParseUtil.AttMap.dodge] .. ' + ' .. cfgT2.dodge;
	-- objSwf.yearTitleTxt6.text = enAttrTypeName[AttrParseUtil.AttMap.cri] .. ' + ' .. cfgT2.cri;
	--称号名称
end

function UIVplanTitle:HandleNotification(name,body)
	if name == NotifyConsts.VFlagChange then
		self:OnUpPanelData();
	end
end

function UIVplanTitle:ListNotificationInterests()
	return {
		NotifyConsts.VFlagChange,
	}
end