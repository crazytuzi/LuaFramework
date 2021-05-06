local CTaskMainView = class("CTaskMainView", CViewBase)

CTaskMainView.EnumTab = 
{
	CurPage = 1,
	AcePage = 2,
	StoryPage = 3,
}

function CTaskMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Task/TaskMainView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	--self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CTaskMainView.OnCreateView(self)
	self.m_ContentWidget = self:NewUI(1, CBox)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_TaskTable = self:NewUI(3, CTable)
	self.m_TaskMenuBox = self:NewUI(4, CTaskTypeMenuBox)
	self.m_PageWidget = self:NewUI(5, CBox)
	self.m_CurrentPage = self:NewPage(6, CTaskMainCurPage)
	self.m_AcceptPage = self:NewPage(7, CTaskMainAcePage)
	self.m_StoryPage = self:NewPage(8, CTaskMainStoryPage)
	self.m_CloseBtn = self:NewUI(9, CButton)
	self.m_TabGrid = self:NewUI(10, CGrid)
	self.m_TipsDownSpr = self:NewUI(11, CSprite)
	self.m_NoneTaskWidget = self:NewUI(12, CBox)
	self.m_NoneTaskLabel = self:NewUI(13, CLabel)
	self.m_TaskTypeTitleLabel = self:NewUI(14, CLabel)

	self.m_UpdateTimer = nil
	self.m_SubPageList = 
	{
		[1] = self.m_CurrentPage,
		[2] = self.m_AcceptPage,
		[3] = self.m_StoryPage,
	}
	self.m_TabIndex = nil
	self.m_SubMenuList = {}
	self:InitContent()

	--self:OnTabClick(g_TaskCtrl.m_RecordTaskPageTab, 0)
end

function CTaskMainView.ShowDefaultTask(self, defaultSelectId, pageTab)
	local defalutId = defaultSelectId or 0
	local page = pageTab or g_TaskCtrl.m_RecordTaskPageTab
	self:OnTabClick(page, defalutId)
end

function CTaskMainView.InitContent(self)
	self.m_TaskMenuBox:SetActive(false)
	self.m_TabGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox:SetGroup(self.m_TabGrid:GetInstanceID())
		oBox:AddUIEvent("click", callback(self, "OnTabClick", idx))
		return oBox 
	end)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTaskCtrlEvent"))

end

function CTaskMainView.OnTaskCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.RefreshAllTaskBox then
		self:RefreshAll()
		
	elseif oCtrl.m_EventID == define.Task.Event.RefreshSpecificTaskBox then		

	end
end

function CTaskMainView.OnTabClick(self, tabIndex, defaultSelectId)
	if tabIndex == self.m_TabIndex then
		return
	end
	self.m_TabGrid:GetChild(tabIndex):SetSelected(true)
	self.m_TabIndex = tabIndex
	--默认打开都是已接受任务标签
	--g_TaskCtrl.m_RecordTaskPageTab = tabIndex
	self:ShowSubPage(self.m_SubPageList[tabIndex])
	self:RefreshAll(defaultSelectId)
end

function CTaskMainView.RefreshAll(self, defaultSelectId)
	local taskTable = g_TaskCtrl:GetTaskMenuTable()
	local taskList = taskTable[self.m_TabIndex].taskList
	local noneTask = false
	if next(taskList) ~= nil then
		noneTask = true
	end
	-- printc("CTaskMainView.RefreshAll")
	-- table.print(taskList)

	if self.m_TabIndex ~= CTaskMainView.EnumTab.StoryPage then
		self.m_TaskTypeTitleLabel:SetText("委托列表")
		if not noneTask then
			self.m_NoneTaskWidget:SetActive(true)
			self.m_ContentWidget:SetActive(false)	
			self.m_PageWidget:SetActive(false)			
			if self.m_TabIndex == CTaskMainView.EnumTab.CurPage then
				self.m_NoneTaskLabel:SetText("当前已接委托全部都完成了哟~")				
			else
				self.m_NoneTaskLabel:SetText("当前没有可接委托了 哟~")
			end
		else
			self.m_PageWidget:SetActive(true)			
			self.m_ContentWidget:SetActive(true)
			self.m_NoneTaskWidget:SetActive(false)				
		end			
		self:RefTypeMenuBox(taskList, defaultSelectId)

	else
		self.m_TaskTypeTitleLabel:SetText("剧情列表")
		self.m_ContentWidget:SetActive(true)
		self.m_NoneTaskWidget:SetActive(false)	
		self:RefTypeMenuBox(taskList, defaultSelectId)
	end
	if self.m_UpdateTimer then
		Utils.DelTimer(self.m_UpdateTimer)
		self.m_UpdateTimer = nil
	end
	self.m_UpdateTimer = Utils.AddTimer(callback(self, "Update"), 0.5 , 0)
end

function CTaskMainView.RefTypeMenuBox(self, taskMenu, defaultSelectId)
	self.m_SubMenuList = {}
	local gourpId = self.m_TaskTable:GetInstanceID()
	local taskMenuList = self.m_TaskTable:GetChildList() or {}

	for i = 1, #taskMenuList do
		local oTaskMenu = taskMenuList[i]
		if oTaskMenu then
			oTaskMenu:SetActive(false)
		end
	end

	--需要显示的任务类型
	local taskMenuShowTbale = {}
	local d = data.taskdata.TASKTYPE
	for k = 1, #d do
		if d[k].menu_show_index ~= 0 then
			taskMenuShowTbale[d[k].menu_show_index] = taskMenuShowTbale[d[k].menu_show_index] or {}
			taskMenuShowTbale[d[k].menu_show_index][d[k].menu_show_index_sort] = d[k].id
		end
	end


	for i = 1, #taskMenuShowTbale do
		--控件开始序号
		local oTaskMenu = nil
		if taskMenuList[i] == nil then
			oTaskMenu = self.m_TaskMenuBox:Clone(self)
			self.m_TaskTable:AddChild(oTaskMenu)
		else
			oTaskMenu = taskMenuList[i]
		end		
		local taskList = {}
		if #taskMenuShowTbale[i] > 0 then
			for k, v in ipairs(taskMenuShowTbale[i]) do
				if taskMenu[v] and next(taskMenu[v]) then
					for _k, _v in pairs(taskMenu[v]) do
						table.insert(taskList, _v)
					end
				end
			end
		end
		--除了主线任务以外，其余没有任务的标签，不显示
		if next(taskList) or i == 1 then
			oTaskMenu:SetActive(true)			
		else
			oTaskMenu:SetActive(false)
		end
		oTaskMenu:SetContent(taskMenuShowTbale[i][1], taskList, gourpId, callback(self, "ClickSubTaskCallback"), true, defaultSelectId)		
	end
end

function CTaskMainView.ClickSubTaskCallback(self, oTask)
	self.m_SubPageList[self.m_TabIndex]:SetTaskInfo(oTask)
end

function CTaskMainView.AddSubMenuBox(self, oBox)
	table.insert(self.m_SubMenuList, oBox)
end

function CTaskMainView.SetSubMenuBoxSelected(self, oBox)
	for k, v in pairs(self.m_SubMenuList) do
		if v and v:GetInstanceID() ~= oBox:GetInstanceID() then
			v.m_SelectSprite:SetActive(false)
		end
	end
end

function CTaskMainView.Update(self, dt)
	local bounds = UITools.CalculateRelativeWidgetBounds(self.m_TaskTable.m_Transform)
	local content_h = math.abs(bounds.center.y - bounds.extents.y) 
	local _, size_y = self.m_ScrollView:GetSize()
	local offset_h = self.m_ScrollView.m_UIPanel.clipOffset.y
	if (content_h < size_y) or (size_y - offset_h  >  content_h - 10 )then
		self.m_TipsDownSpr:SetActive(false)
	else
		self.m_TipsDownSpr:SetActive(true)
	end
	return true
end

function CTaskMainView.Destroy(self)
	if self.m_UpdateTimer then
		Utils.DelTimer(self.m_UpdateTimer)
		self.m_UpdateTimer = nil
	end	
	CViewBase.Destroy(self)
end

return CTaskMainView