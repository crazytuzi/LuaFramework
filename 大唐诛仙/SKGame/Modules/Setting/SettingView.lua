-- 主面板:设置
SettingView = BaseClass(CommonBackGround)

function SettingView:__init()
	self.model = SettingModel:GetInstance()
	self.id = "SettingView"
	self.bgUrl = "bg_big1"
	self.showBtnClose = true

	self.openTopUI = true
	self.openResources = {1, 2}
	self.defaultTabIndex = 0
	
	self:SetTitle("设  置")
	if not self.stgPanel then
		self.stgPanel = SettingPanel.New()
	end
	self.container:AddChild(self.stgPanel.ui)
	self.stgPanel:SetVisible(true)
end

function SettingView:Layout()
	self:InitEvent()
end

function SettingView:InitEvent()
	self.openCallback = function ()
		if self.stgPanel then
			self.stgPanel:Update() -- 打开面板更新
		end
	end

	self.handler = GlobalDispatcher:AddEventListener(EventName.NET_DISCONNECT, function ()
		self:Close()
		GlobalDispatcher:RemoveEventListener(self.handler)
	end)
end

function SettingView:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler)
	if self.stgPanel then
		self.stgPanel:Destroy()
	end
	self.stgPanel = nil
end