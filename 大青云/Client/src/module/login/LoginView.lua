--[[
登录面板
lizhuangzhuang
2014年7月17日16:35:41
]]

_G.UILogin = BaseUI:new("UILogin");
function UILogin:Create()
    Debug("################### UILogin:Create() ")
	self:AddSWF("loginPanel.swf",true,"center");

end

function UILogin:OnLoaded(objSwf,name)
	objSwf.panel.btnLogin.click = function() self:OnBtnLogin(); end
end

function UILogin:OnShow(name)
    local objSwf = self:GetSWF("loginPanel");
	if not objSwf then return; end
	local cfg = ConfigManager:GetCfg();
	if cfg.accountName then
		objSwf.panel.inputName.text = cfg.accountName;
	end
end

function UILogin:DeleteWhenHide()
	return true;
end

function UILogin:GetWidth()
	return 1280;
end

function UILogin:GetHeight()
	return 800;
end

function UILogin:OnResize(wWith,wHeight)
	if not self.bShowState then return; end
	local objSwf = self:GetSWF("loginPanel");
	if not objSwf then return; end 
	objSwf.bg._width = wWith;
	objSwf.bg._height = wHeight;
end

--点击登录
function UILogin:OnBtnLogin()
	
	local objSwf = self:GetSWF("loginPanel");
	if not objSwf then return; end
	local name = objSwf.panel.inputName.text;
	local pwd = objSwf.panel.inputPwd.text;
    if name == "" then
        UIConfirm:Open("请输入用户名");
        return
    end
    local ret = name:find('%w+%a*%d*')
    if ret ~= 1 then
        UIConfirm:Open("用户名不合法");
        return
    end
	LoginController:Login(name);
	--save config
	local cfg = ConfigManager:GetCfg();
	cfg.accountName = name;
	ConfigManager:Save();
end

--点击注册 
-- function UILogin:OnBtnReg()
-- end

