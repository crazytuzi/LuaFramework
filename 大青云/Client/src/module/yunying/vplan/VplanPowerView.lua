--[[
	V计划威力
	2015年5月12日, AM 11:07:27
	wangyanwei
]]

_G.UIVplanPower = BaseUI:new('UIVplanPower');

UIVplanPower.dataList = {};
UIVplanPower.cuepage = 0

function UIVplanPower:Create()
	self:AddSWF("vplanPowerPanel.swf",true,nil);
end

function UIVplanPower:OnLoaded(objSwf)
	--objSwf.btn_mon.click = function () VplanController:ToMRecharge(); end
	--objSwf.btn_year.click = function () VplanController:ToYRecharge(); end
	objSwf.btn_VplanOfficialWeb.click = function () VplanController:ToWebSite() end

	objSwf.scrollbar.scroll = function() self:OnVplanScrollBar() end;

end

function UIVplanPower:OnHide()
	
end

function UIVplanPower:OnShow()
	self:OnUpBtnState();--按钮状态
	self:SetVAddAtb();
	local objSwf = self.objSwf;
	objSwf.scrollbar:setScrollProperties(5,0,#t_vlevel-5);
	objSwf.scrollbar.trackScrollPageSize = 1;
	objSwf.scrollbar.position = 0;

	--self:OnSetTxt();    --文本
	self:OnShowList(self.cuepage);
end

function UIVplanPower:OnVplanScrollBar()
	local objSwf = self.objSwf;
	local value = objSwf.scrollbar.position;
	self.cuepage = value
	self:OnShowList(value);
end;

function UIVplanPower:OnShowList(val)
	local listvo = {};
	for i=1,5 do 
		table.push(listvo,self.dataList[val+i])
	end;

	local objSwf = self.objSwf;
	-- trace(listvo)
	-- debug.debug()
	for i,info in ipairs(listvo) do 
		local item = objSwf["item"..i];
		if item then 
			if item.leve1_mc.source ~= ResUtil:GetVUIIcon(info.lvl) then 
				item.leve1_mc.source = ResUtil:GetVUIIcon(info.lvl);
			end;
			item.atb1_txt.htmlText = info.str
			item.state1._visible = info.state
			item.atb2_txt.htmlText = info.str2
			item.state2._visible = info.state2;
			item._visible = true;
		else
			item._visible = false;
		end;
	end;

end;

function UIVplanPower:SetVAddAtb()
	local myVLvl = VplanModel:GetVPlanLevel()
	local cfg = t_vlevel;
	self.dataList = {};
	for i,info in ipairs(cfg) do 
		--=月费
		local vo = {};
		vo.lvl = info.level;          --等级
		local list = AttrParseUtil:Parse(info.monthAttr);
		for aa,bb in pairs(list) do 
			local name = enAttrTypeName[bb.type];  --属性名称
			local str = name .."+" .. bb.val;      --属性值
			if not vo.str then vo.str = "" end;
			vo.str = vo.str .. str;   --月会员的属性加成信息
		end;
		if myVLvl == info.level then 
			if VplanModel:GetMonVplan() then 
				vo.state = true;
			else
				vo.state = false;
			end;
		else
			vo.state = false;        --月会员的激活状态
		end;
		--年费
		local list = AttrParseUtil:Parse(info.yearAttr);
		for aa,bb in pairs(list) do 
			local name = enAttrTypeName[bb.type];
			local str = name .."+" .. bb.val;
			if not vo.str2 then vo.str2 = "" end;
			vo.str2 = vo.str2 .. str; --年会员的属性加成信息
		end;
		if myVLvl == info.level then 
			if VplanModel:GetYearVplan() then 
				vo.state2 = true;
			else
				vo.state2 = false;
			end;
		else
			vo.state2 = false;        --年会员的激活状态
		end;
		table.push(self.dataList,vo)
	end;
	-- trace(self.dataList)
	-- print('-------------哈哈哈')
end;


--按钮状态
function UIVplanPower:OnUpBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	--是否V会员
	local isVplan = VplanModel:GetIsVplan();
	--是否年费
	local isVyear = VplanModel:GetYearVplan();
	--objSwf.btn_year.disabled,--objSwf.btn_mon.disabled = isVyear,isVplan;
	if isVplan then
		--objSwf.btn_mon.label = StrConfig['vplan704'];
	else
		--objSwf.btn_mon.label = StrConfig['vplan702'];
	end
	if isVyear then
		--objSwf.btn_year.label = StrConfig['vplan704'];
	else
		--objSwf.btn_year.label = StrConfig['vplan703'];
	end
end



function UIVplanPower:HandleNotification(name,body)
	if name == NotifyConsts.VFlagChange then
		self:OnUpBtnState();
	end
end

function UIVplanPower:ListNotificationInterests()
	return {
		NotifyConsts.VFlagChange
	}
end