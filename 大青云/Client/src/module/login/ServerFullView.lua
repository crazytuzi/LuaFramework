--[[
服务器满UI
lizhuangzhuang
2015年10月20日23:03:09
]]

_G.UIServerFull = BaseUI:new("UIServerFull");

function UIServerFull:Create()
	self:AddSWF("serverFull.swf",true,"loading");
end

function UIServerFull:OnLoaded(objSwf)
	objSwf.btn.click = function() self:OnBtnClick(); end
end

function UIServerFull:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if ismclient then
		objSwf.btn.visible = true;
		objSwf.tfInfo.text = StrConfig['login53'];
	else
		if _sys:getGlobal("is_ie") then
			objSwf.btn.visible = false;
			objSwf.tfInfo.text = StrConfig['login54'];
		else
			objSwf.btn.visible = true;
			objSwf.tfInfo.text = StrConfig['login53'];
		end
	end
end

function UIServerFull:OnBtnClick()
	if ismclient and _sys:getGlobal("mcallserver") then
		_sys:invoke('refresh', _sys:getGlobal("mcallserver"))
	else
		backLoginPage();
	end
end