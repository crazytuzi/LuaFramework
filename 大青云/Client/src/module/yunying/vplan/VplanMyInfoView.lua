--[[
v计划，我的信息
wangshuai
]]

_G.UIMyVplanInfo = BaseUI:new("UIMyVplanInfo");

function UIMyVplanInfo:Create()
	self:AddSWF("vplanMyInfoPanel.swf",true,nil)
end;

function UIMyVplanInfo:OnLoaded(objSwf)
	objSwf.look_btn.click = function() self:OnLookClick()end;
	objSwf.btn_VplanOfficialWeb.click = function () VplanController:ToWebSite() end
end;

function UIMyVplanInfo:OnShow()
	self:UpdataUI();
end;

function UIMyVplanInfo:OnHide()

end;

function UIMyVplanInfo:UpdataUI()
	self:ShowMyinfo();
end;

function UIMyVplanInfo:OnLookClick()
	VplanController:ToWebSite()
end;

function UIMyVplanInfo:ShowMyinfo()	
	local objSwf = self.objSwf;
	local myinfo = VplanModel:GEtMyVInfo()
	-- trace(myinfo)
	-- print("哈哈哈哈哈哈哈")
	if not myinfo.exp then 
		objSwf.lvl_txt.htmlText = "";
		objSwf.vtype_txt.htmlText = "";
		objSwf.speed_txt.htmlText = "";
		objSwf.vtime_txt.htmlText = "";
		return 
	end;
	if not VplanModel:GetIsVplan() then 
		objSwf.lvl_txt.htmlText = StrConfig['vplan1004'];
		objSwf.vtype_txt.htmlText = StrConfig['vplan1004']
		objSwf.speed_txt.htmlText = StrConfig['vplan1004'];
		objSwf.vtime_txt.htmlText = StrConfig['vplan1004'];
		return 
	end;

	local mystr = string.format(StrConfig['vplan1001'],myinfo.vlvl,myinfo.exp,myinfo.allexp)
	objSwf.lvl_txt.htmlText = mystr
	local vtype = ""
	if VplanModel:GetMonVplan()  then 
		-- 是月费
		vtype = StrConfig['vplan1002']
	elseif VplanModel:GetYearVplan() then 
		--是年费
		vtype = StrConfig['vplan1003']
	else 
		--都不是
		vtype = StrConfig['vplan1004']
	end;
	objSwf.vtype_txt.htmlText = vtype
	objSwf.speed_txt.htmlText = myinfo.speed..StrConfig["vplan1005"]
	local vtime = "";
	if myinfo.time and myinfo.time > 0 then 
		local year, month, day, hour, minute, second = CTimeFormat:todate(myinfo.time,true);
		objSwf.vtime_txt.htmlText = string.format('%02d-%02d-%02d',year, month, day);
	end;
end;