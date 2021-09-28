LookInfoPanel = BaseClass(CommonBackGround)
function LookInfoPanel:__init( ... )

	self.ui = UIPackage.CreateObject("Gay","LookInfoPanel");

	
	self.headIcon = self.ui:GetChild("headIcon")
	self.txt_playerName = self.ui:GetChild("txt_playerName")
	self.txt_family = self.ui:GetChild("txt_family")
	self.btn_info = self.ui:GetChild("btn_info")
	self.btn_Pk = self.ui:GetChild("btn_Pk")
	self.btn_team = self.ui:GetChild("btn_team")
	self.btn_family = self.ui:GetChild("btn_family")
	self.btn_black = self.ui:GetChild("btn_black")
	self.btn_delete = self.ui:GetChild("btn_delete")
end
function LookInfoPanel:InitEvent()
	--[[ 这里注册各种一次性创建事件
	self.closeCallback = function () end
	self.openCallback  = function () end
	--]]
end
-- 布局UI
function LookInfoPanel:Layout()
	self.container:AddChild(self.ui) -- 不改动，注意自行设置self.ui位置
	-- 以下开始UI布局
	
	
end

-- Dispose use LookInfoPanel obj:Destroy()
function LookInfoPanel:__delete()
end