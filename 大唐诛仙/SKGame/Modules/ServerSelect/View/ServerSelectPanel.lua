ServerSelectPanel = BaseClass(BaseView)
function ServerSelectPanel:__init(accountData)

	self.ui = UIPackage.CreateObject("ServerSelect","ServerSelectPanel");
	self.id = "ServerSelectPanel"
	
	self.loginBGComp = self.ui:GetChild("loginBGComp")
	self.btnClose = self.ui:GetChild("btnClose")
	self.btnNotice = self.ui:GetChild("btnNotice")
	self.btnLogin = self.ui:GetChild("btnLogin")

	self.bg0 = self.ui:GetChild("bg0")
	self.bg1 = self.ui:GetChild("bg1")
	self.bg2 = self.ui:GetChild("bg2")
	self.bg3 = self.ui:GetChild("bg3")
	self.bg4 = self.ui:GetChild("bg4")
	self.bg5 = self.ui:GetChild("bg5")
	self.bg6 = self.ui:GetChild("bg6")
	self.bg7 = self.ui:GetChild("bg7")
	self.groupBG = self.ui:GetChild("groupBG")
	self.serverState0 = self.ui:GetChild("serverState0")
	self.serverState1 = self.ui:GetChild("serverState1")
	self.serverState2 = self.ui:GetChild("serverState2")
	self.serverState3 = self.ui:GetChild("serverState3")
	self.groupServerState = self.ui:GetChild("groupServerState")
	self.serverTabs = self.ui:GetChild("serverTabs")
	self.serverContent = self.ui:GetChild("serverContent")
	self.groupContent = self.ui:GetChild("groupContent")

	self:InitData()
	self:InitUI()
	self:InitEvent()

	self:SetAccountData(accountData)
end
function ServerSelectPanel:InitEvent()
	--这里注册各种一次性创建事件
	self.closeCallback = function () end
	self.openCallback  = function () 
		self:Update()
	end

	self.serverContent.onClickItem:Add(self.OnServerItemClick , self)
	self.serverTabs.onClickItem:Add(self.OnServerTabItemClick , self)

	self.btnClose.onClick:Add(function ()
		
		LoginController:GetInstance():OpenVisitorLoginPanel(self.accountData)
	end)

	self.btnNotice.onClick:Add(function ()
		GgController:GetInstance():Open()
	end)

	self.btnLogin.onClick:Add(function ()
		LoginController:GetInstance():OpenAccountManagerPanel()
	end)
end

function ServerSelectPanel:InitData()
	self.defaultTabIndex = 0 --默认选中哪个页签
	self.lastTabIndex = -1
	self.curSelectedTabId = -1 
	self.serverItemUIList = {}
	self.serverTabUIList = {}
	self.loginModel = LoginModel:GetInstance()
	self.accountData = {}
end

function ServerSelectPanel:InitUI()
	self.loginBGComp = LoginBGComp.Create(self.loginBGComp)
	self.loginBGComp:UnActiveBtns()
	self.loginBGComp:SetMaskVisible(false)
	self.btnNotice.icon = StringFormat("Icon/Activity/fun_5") 
	self.btnLogin.icon = StringFormat("Icon/Activity/fun_18")
	self:InitServerItemsUI()
end

function ServerSelectPanel:InitServerItemsUI()
	for index = 1 , ServerSelectConst.ServerGroupItemCnt do
		curServerItem = ServerContentItem.New()
		table.insert(self.serverItemUIList , curServerItem)
		self.serverContent:AddChild(curServerItem.ui)
	end
end

function ServerSelectPanel:SetAccountData(accountData)
	self.accountData = accountData or {}
end

function ServerSelectPanel:Update()
	
	self:UpdateData()
	self:UpdateUI()
end

function ServerSelectPanel:UpdateData()
	self.serverList = self.loginModel:GetServerList()
end

function ServerSelectPanel:UpdateUI()
	self:SetServerTabUI()
	self:SetDefaultUI()
	self:SetServerItemsUI()
end

function ServerSelectPanel:SetDefaultUI()
	if self.lastTabIndex == -1 then
		self.serverTabs.selectedIndex = self.defaultTabIndex
		self.lastTabIndex  = self.defaultTabIndex
	end
end


--设置左侧服务器列表组页签UI表现
function ServerSelectPanel:SetServerTabUI()
	local tabCnt = self.loginModel:GetServerTabCnt()

	--先创建固定tab页签
	---- 我的服务器 和 推荐服务器是固定页签
	for index = 1, 2 do
		self:CreateTabItem(index)
	end

	--逆序创建剩下的tab页签
	
	for reverseIndex = tabCnt , 2 + 1, -1 do
		self:CreateTabItem(reverseIndex)
	end
end

function ServerSelectPanel:CreateTabItem(index)
	if index then
		
		local oldTabItem = self:GetServerTabItemByIndex(index)
		local curTabItem = {}
		if not TableIsEmpty(oldTabItem) then
			curTabItem = oldTabItem
		else
			curTabItem = ServerTabItem.New()
			self.serverTabUIList[index] = curTabItem
		end
		curTabItem:SetData(index)
		curTabItem:SetUI()
		
		self.serverTabs:AddChild(curTabItem.ui)
	end
end

function ServerSelectPanel:GetServerTabItemByIndex(index)
	return self.serverTabUIList[index] or {}
end

--设置当前服务器组页签下的具体服务器列表UI表现
function ServerSelectPanel:SetServerItemsUI()
	
	local curServerTypeList = self.loginModel:GetServerListByType(self.lastTabIndex)
	
	for index = 1 , #self.serverItemUIList do
		local curServerData = curServerTypeList[index]
		local curServerItem = self.serverItemUIList[index]
		if curServerItem then
			if not TableIsEmpty(curServerData) then
				curServerItem:SetData(curServerData)
				curServerItem:SetUI()
				curServerItem:SetVisible(true)
			else
				curServerItem:CleanData()
				curServerItem:CleanUI()
				curServerItem:SetVisible(false)
			end
		end
	end
end

function ServerSelectPanel:UnActiveServerItemUIList()
	for index = 1 , #self.serverItemUIList do
		if self.serverItemUIList[index] then
			self.serverItemUIList[index]:SetVisible(false)
		end
	end
end

function ServerSelectPanel:GetServerItemByIndex(index)
	return self.serverItemUIList[index] or {}
end

function ServerSelectPanel:OnServerItemClick()
	
	local selectedServerData = {}
	if self.serverItemUIList[self.serverContent.selectedIndex + 1] then
		selectedServerData = self.serverItemUIList[self.serverContent.selectedIndex + 1]:GetData()
	end
	

	LoginController:GetInstance():OpenVisitorLoginPanel(self.accountData)
	self.loginModel:SetLastServer(selectedServerData)
	GlobalDispatcher:DispatchEvent(EventName.SelectServer , selectedServerData)

end

function ServerSelectPanel:OnServerTabItemClick()
	
	if self.lastTabIndex ~= self.serverTabs.selectedIndex then
		self.lastTabIndex = self.serverTabs.selectedIndex
		
		self:SetServerItemsUI()
	end
end
-- Dispose use ServerSelectPanel obj:Destroy()
function ServerSelectPanel:__delete()
	if self.loginBGComp then
		self.loginBGComp:Destroy()
		self.loginBGComp = nil
	end
	self:DestroyServerItemUIList()
	self:DestroyServerTabUIList()
end

function ServerSelectPanel:DestroyServerItemUIList()
	if self.serverItemUIList then
		for index = 1 , #self.serverItemUIList do
			if self.serverItemUIList[index] then
				self.serverItemUIList[index]:Destroy()
			end
		end
		self.serverItemUIList = nil
	end
end

function ServerSelectPanel:DestroyServerTabUIList()
	if self.serverTabUIList then
		for k , v in pairs(self.serverTabUIList) do
			if self.serverTabUIList[k] then
				self.serverTabUIList[k]:Destroy()
			end
		end
		self.serverTabUIList = nil
	end
end