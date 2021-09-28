ServerContentItem = BaseClass(LuaUI)

function ServerContentItem:__init(...)
	self.URL = "ui://csn9w87suq4w8";
	self:__property(...)
	self:Config()
end

function ServerContentItem:SetProperty(...)
	
end

function ServerContentItem:Config()
	
end

function ServerContentItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("ServerSelect","ServerContentItem");

	self.button = self.ui:GetController("button")
	self.bg = self.ui:GetChild("bg")
	self.bgSelected = self.ui:GetChild("bgSelected")
	self.loaderServerState = self.ui:GetChild("loaderServerState")
	self.labelServerName = self.ui:GetChild("labelServerName")
	self.loaderProfessionIcon = self.ui:GetChild("loaderProfessionIcon")
	self.labelPlayerLev = self.ui:GetChild("labelPlayerLev")
	self.imgNewServer = self.ui:GetChild("imgNewServer")
end

function ServerContentItem.Create(ui, ...)
	return ServerContentItem.New(ui, "#", {...})
end

function ServerContentItem:__delete()
end

function ServerContentItem:InitData()
	self.data = {}
end

function ServerContentItem:SetData(data)
	self.data = data or {}
end

function ServerContentItem:GetData()
	return self.data
end

-- serverName = "xxx-x服",
-- gamePort = 0,
-- severType = 0,
-- gameHost = "192.168.0.190",
-- serverNo = 2,
-- severState = 1,
-- loginFlag = 0,

function ServerContentItem:SetUI()
	self.labelServerName.text = StringFormat("这是第{0}个服务器" , self.data)
	if not TableIsEmpty(self.data) then
		self.imgNewServer.visible = self.data.severType == LoginConst.ServerType.New

		local serverStateIcon = ""
		local isGrayed = false
		if self.data.severState == LoginConst.ServerState.Smooth then
			serverStateIcon = UIPackage.GetItemURL("Common" , "1liuchang")
		elseif self.data.severState == LoginConst.ServerState.Crowd then
			serverStateIcon = UIPackage.GetItemURL("Common" , "2yongji")
		elseif self.data.severState == LoginConst.ServerState.Hot then
			serverStateIcon = UIPackage.GetItemURL("Common" , "3huobao")
		elseif self.data.severState == LoginConst.ServerState.Close then
			--serverStateIcon = UIPackage.GetItemURL("")
		elseif self.data.severState == LoginConst.ServerState.Maintenance then
			serverStateIcon = UIPackage.GetItemURL("Common" , "1liuchang")
			isGrayed = true
		end

		self.loaderServerState.grayed = isGrayed
		self.loaderServerState.url = serverStateIcon
		self.labelServerName.text = self.data.serverName

		if self.data.loginFlag == LoginConst.HasLogin.Yes then
			--self.loaderProfessionIcon.url = StringFormat("Icon/Activity/fun_18")
			self.loaderProfessionIcon.url = UIPackage.GetItemURL("Common" , "btn_zhanghao")
		elseif self.data.loginFlag == LoginConst.HasLogin.No then
			self.loaderProfessionIcon.url = ""
		end
	end
end

function ServerContentItem:CleanData()
	self.data = {}
end

function ServerContentItem:CleanUI()
	self.imgNewServer.visible = false
	self.labelServerName.text = ""
	self.labelPlayerLev.text = ""
	self.loaderProfessionIcon.url = ""
	self.loaderServerState.url = ""
end