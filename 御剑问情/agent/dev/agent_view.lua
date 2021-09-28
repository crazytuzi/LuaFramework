AgentView = AgentView or BaseClass(BaseView)

function AgentView:__init()
	self.ui_config = {"uis/views/agents/dev_prefab", "AgentView"}
	self.active_close = false
	self.click_login_callback = nil
end
function AgentView:LoadCallBack()
	self:ListenEvent("LoginClick", BindTool.Bind(self.OnLoginClick, self)) 

	self.input_name = self:FindObj("AccountName") 
	self.input_name.input_field.text = UnityEngine.PlayerPrefs.GetString("account_name")
end

function AgentView:ReleaseCallBack()
	self.input_name = nil
end

function AgentView:SetClickLoginCallback(callback)
	self.click_login_callback = callback
end

function AgentView:OnLoginClick()
	local account_name = self.input_name.input_field.text
	if account_name == "" then
		return
	end

	UnityEngine.PlayerPrefs.SetString("account_name", account_name) 
	self.click_login_callback(account_name)  
	self:Close()
end
