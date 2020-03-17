--[[
V计划，特权介绍
wangshuai
]]

_G.UIVplanPrivilege = BaseUI:new("UIVplanPrivilege")

function UIVplanPrivilege:Create()
	self:AddSWF("vplanPrivilegePanel.swf",true,nil)
end;

function UIVplanPrivilege:OnLoaded(objSwf)
	for i=1,4 do 
		local btn = objSwf["btn"..i];
		btn.click = function() self:OnBtnClick(i) end;
	end;
	--objSwf.btn3.disabled = true;
	--objSwf.btn_VplanOfficialWeb.click = function () VplanController:ToWebSite() end
end;

function UIVplanPrivilege:OnBtnClick(i)
	if i == 1 then 
		UIVplanMain:OnTabButtonClick(VplanConsts.UIchenghao)
	elseif i == 2 then 
		UIVplanMain:OnTabButtonClick(VplanConsts.UIweili)
	elseif i == 3 then 
		UIVplanMain:OnTabButtonClick(VplanConsts.UIBuyGift)
	elseif i == 4 then 
		UIVplanMain:OnTabButtonClick(VplanConsts.UIchouchong)
	end;
end;

function UIVplanPrivilege:OnHide()

end;