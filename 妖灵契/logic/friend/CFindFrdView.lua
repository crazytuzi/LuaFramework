local CFindFrdView = class("CFindFrdView", CViewBase)

function CFindFrdView.ctor(self, cb)
	CViewBase.ctor(self, "UI/friend/FindFriendView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CFindFrdView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TagSearch = self:NewUI(2, CButton)
	self.m_TagBtn = self:NewUI(3, CButton)
	self.m_TagLabel = self:NewUI(4, CLabel)
	self.m_Input = self:NewUI(5, CInput)
	self.m_ClearBtn = self:NewUI(6, CButton)
	self.m_Grid = self:NewUI(7, CGrid)
	self.m_FriendItem = self:NewUI(8, CBox)
	self.m_SearchBtn = self:NewUI(9, CButton)
	self.m_RefreshBtn = self:NewUI(10, CButton)
	self.m_BackBtn = self:NewUI(11, CButton)
	self.m_RecommandLabel = self:NewUI(12, CLabel)
	self.m_ScrollView = self:NewUI(13, CScrollView)
	self:InitContent()
end

function CFindFrdView.InitContent(self)
	self.m_FriendItem:SetActive(false)
	self.m_BackBtn:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SearchBtn:AddUIEvent("click", callback(self, "OnSearch"))
	self.m_ClearBtn:AddUIEvent("click", callback(self, "OnClearInput"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnRefresh"))
	self.m_TagSearch:AddUIEvent("click", callback(self, "OnShowTagFilter"))
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendCtrl"))
	self:OnFindNear()
end

function CFindFrdView.OnFriendCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.UpdateSearch then
		self:InitGrid(oCtrl.m_EventData, 1)
	
	elseif oCtrl.m_EventID == define.Friend.Event.UpdateRecommand then
		self.m_RecommandData = oCtrl.m_EventData
		self:InitGrid(oCtrl.m_EventData, 2)
	
	else
		self:RefreshGrid()
	end
end

function CFindFrdView.InitGrid(self, data, itype)
	local function hassame(t1, t2)
		for _, v in ipairs(t1) do
			if table.index(t2, v) then
				return true
			end
		end
		return false
	end
	if data == nil then
		data = {}
	end
	self.m_FrdData = data
	self.m_TagList = self.m_TagList or {}
	self.m_Grid:Clear()
	for _, frddata in ipairs(data) do
		if hassame(frddata["labal"], self.m_TagList) or #self.m_TagList == 0 or itype == 1 then
			local itemobj = self:CreateItem()
			itemobj:SetGroup(self.m_Grid:GetInstanceID())
			itemobj.m_ID = frddata["pid"]
			itemobj.m_NameLabel:SetText(frddata["name"])
			itemobj.m_GradeLabel:SetText(string.format("%d", frddata["grade"]))
			itemobj.m_AddrLabel:SetText("")
			itemobj.m_IconSpr:SpriteAvatar(frddata["shape"])
			self:UpadteLabal(itemobj, frddata["labal"])
			itemobj.m_AddBtn:AddUIEvent("click", callback(self, "OnAddFriend", itemobj.m_ID, itemobj))
			itemobj.m_SchoolSpr:SpriteSchool(frddata["school"])
			if g_FriendCtrl:IsMyFriend(itemobj.m_ID) then
				itemobj.m_GreySpr:SetActive(true)
			else
				itemobj.m_GreySpr:SetActive(false)
			end
			self.m_Grid:AddChild(itemobj)
		end
	end
	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
	if #self.m_Grid:GetChildList() > 0 and itype == 1 then
		self.m_TagLabel:SetText("查找结果")
		self.m_TagSearch:SetActive(false)
	else
		self.m_TagSearch:SetActive(true)
		local str = "未选择标签"
		if #self.m_TagList > 0 then
			str = "已选择："..table.concat(self.m_TagList, "、")
		else
			self.m_TagLabel:SetText(str)
		end
	end
	if itype == 2 and #self.m_Grid:GetChildList() == 0 then
		g_NotifyCtrl:FloatMsg("未找到符合要求的玩家，请修改标签查找后再进行搜索")
	end
end

function CFindFrdView.ReloadGrid(self)
	local function hassame(t1, t2)
		for _, v in ipairs(t1) do
			if table.index(t2, v) then
				return true
			end
		end
		return false
	end

	local data = self.m_FrdData or {}
	self.m_TagList = self.m_TagList or {}
	self.m_Grid:Clear()
	for _, frddata in ipairs(data) do
		if hassame(frddata["labal"], self.m_TagList) or #self.m_TagList == 0 then
			local itemobj = self:CreateItem()
			itemobj:SetGroup(self.m_Grid:GetInstanceID())
			itemobj.m_ID = frddata["pid"]
			itemobj.m_NameLabel:SetText(frddata["name"])
			itemobj.m_GradeLabel:SetText(string.format("%d", frddata["grade"]))
			itemobj.m_AddrLabel:SetText("")
			itemobj.m_IconSpr:SpriteAvatar(frddata["shape"])
			self:UpadteLabal(itemobj, frddata["labal"])
			itemobj.m_AddBtn:AddUIEvent("click", callback(self, "OnAddFriend", itemobj.m_ID, itemobj))
			itemobj.m_SchoolSpr:SpriteSchool(frddata["school"])
			if g_FriendCtrl:IsMyFriend(itemobj.m_ID) then
				itemobj.m_GreySpr:SetActive(true)
			else
				itemobj.m_GreySpr:SetActive(false)
			end
			self.m_Grid:AddChild(itemobj)
		end
	end
	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
	if #self.m_Grid:GetChildList() == 0 then
		g_NotifyCtrl:FloatMsg("未找到符合要求的玩家，请修改标签查找后再进行搜索")
	end
end

function CFindFrdView.UpadteLabal(self, box, list)
	box.m_LabalLabel:SetActive(false)
	box.m_LabalGrid:Clear()
	for _, text in ipairs(list) do
		local label = box.m_LabalLabel:Clone()
		label:SetActive(true)
		label:SetText(text)
		box.m_LabalGrid:AddChild(label)
	end
	box.m_LabalGrid:Reposition()
	box.m_NoLabalLabel:SetActive(#list == 0)
end

function CFindFrdView.RefreshGrid(self)
	for _, itemobj in ipairs(self.m_Grid:GetChildList()) do
		if g_FriendCtrl:IsMyFriend(itemobj.m_ID) then
			itemobj.m_GreySpr:SetActive(true)
			itemobj.m_AddBtn:SetActive(false)
		else
			itemobj.m_GreySpr:SetActive(false)
			itemobj.m_AddBtn:SetActive(true)
		end
	end
end

function CFindFrdView.CreateItem(self)
	local itemobj = self.m_FriendItem:Clone()
	itemobj:SetActive(true)
	itemobj.m_IconSpr = itemobj:NewUI(1, CSprite)
	itemobj.m_NameLabel = itemobj:NewUI(2, CLabel)
	itemobj.m_GradeLabel = itemobj:NewUI(3, CLabel)
	itemobj.m_AddrLabel = itemobj:NewUI(4, CLabel)
	itemobj.m_LabalLabel = itemobj:NewUI(5, CLabel)
	itemobj.m_AddBtn = itemobj:NewUI(6, CButton)
	itemobj.m_SchoolSpr = itemobj:NewUI(7, CSprite)
	itemobj.m_LabalGrid = itemobj:NewUI(8, CGrid)
	itemobj.m_GreySpr = itemobj:NewUI(9, CSprite)
	itemobj.m_NoLabalLabel = itemobj:NewUI(10, CLabel)
	itemobj.m_NoLabalLabel:SetActive(false)
	return itemobj
end

function CFindFrdView.OnSearch(self)
	local text = self.m_Input:GetText()
	if self:CheckGM(text) then
		return
	end
	if text == "" then
		g_NotifyCtrl:FloatMsg("请输入你要查找的内容")
	else
		local pid = tonumber(text)
		netfriend.C2GSFindFriend(pid, text)
	end
end

function CFindFrdView.CheckGM(self, sText)
	if sText == "$n1test" then
		local oView = CNotifyView:GetView()
		if oView then
			oView.m_OrderBtn:SetActive(true)
		end
		local path = IOTools.GetPersistentDataPath(string.format("/%s.file", Utils.MD5HashString(Utils.GetDeviceUID())))
		IOTools.SaveTextFile(path, define.GameName)
		Utils.UpdateLogLevel()
		return true
	end
end

function CFindFrdView.OnShowTagFilter(self)
	self.m_TagList = self.m_TagList or {}
	CFrdTagView:ShowView(function(oView)
		oView:UpdateSelectTag(table.copy(self.m_TagList))
		oView:SetCallback(callback(self, "RefreshTagList"))
	end)
end

function CFindFrdView.RefreshTagList(self, tagList)
	self.m_TagList = tagList
	self:ReloadGrid()
	local str = "未选择标签"
	if #tagList > 0 then
		str = "已选择："..table.concat(tagList, "、")
		if #tagList > 4 then
			str = "已选择："
			for i = 1, 4 do
				str = str .. tagList[i].."、"
			end
			str = str .. string.format("...（共%d种标签）", #tagList)
		end
	end
	self.m_TagLabel:SetText(str)
end

function CFindFrdView.OnClearInput(self)
	self.m_Input:SetText("")
end

function CFindFrdView.OnRefresh(self)
	netfriend.C2GSNearByFriend()
end

function CFindFrdView.OnAddFriend(self, pid, btn)
	if g_FriendCtrl:ApplyFriend(pid) then
		btn.m_GreySpr:SetActive(true)
		btn.m_AddBtn:SetActive(false)
	end
end

function CFindFrdView.OnFindNear(self)
	netfriend.C2GSNearByFriend()
end

return CFindFrdView
