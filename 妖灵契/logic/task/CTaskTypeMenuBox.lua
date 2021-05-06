local CTaskTypeMenuBox = class("CTaskTypeMenuBox", CBox)

function CTaskTypeMenuBox.ctor(self, obj, oView)
	CBox.ctor(self, obj)
	self.m_MainMenuBtn = self:NewUI(1, CButton, true, false)
	self.m_MainMenuFlagOpenSpr = self:NewUI(2, CSprite)
	self.m_SubMenuBgSpr = self:NewUI(3, CSprite)
	self.m_SubMenuPanel = self:NewUI(4, CPanel)
	self.m_SubMenuGrid = self:NewUI(5, CGrid)
	self.m_SubMenuBtnClone = self:NewUI(6, CBox)
	self.m_MainMenuFlagCloseSpr = self:NewUI(7, CSprite)
	self.m_TaskTypeLabel = self:NewUI(8, CLabel)
	self.m_SubMenuCustomBgSpr = self:NewUI(9, CSprite)
	self.m_TweenHeight = self.m_SubMenuBgSpr:GetComponent(classtype.TweenHeight)
	self.m_ClickCallback = nil
	self.m_TaskList = nil
	self.m_View = oView
	self.m_SubMenuBtnClone:SetActive(false)
end

function CTaskTypeMenuBox.SetContent(self, index, taskList, groupId, ClickCb, isOpen, defaultSelectId)
	self.m_TaskTypeLabel:SetText(define.Task.String[index])

	if taskList == nil then
		taskList = {}			
	end
	self.m_TaskList = taskList
	self.m_ClickCallback = ClickCb
	self:RefMenuBox(groupId, isOpen, defaultSelectId)
end

function CTaskTypeMenuBox.RefMenuBox(self, groupId, isOpen, defaultSelectId)
	local taskCount = #self.m_TaskList
	local subMenuBoxList = self.m_SubMenuGrid:GetChildList() or {}
	if taskCount > 0 then
		for i = 1, taskCount do
			local oTask = self.m_TaskList[i]
			local oSubMenu = nil
			if i > #subMenuBoxList then
				oSubMenu = self.m_SubMenuBtnClone:Clone()
				oSubMenu.m_SubTaskLabel = oSubMenu:NewUI(1, CLabel)
				oSubMenu.m_DoingWidget = oSubMenu:NewUI(2, CBox)
				oSubMenu.m_SelectSprite = oSubMenu:NewUI(3, CSprite)
				oSubMenu.m_AcceptWidget = oSubMenu:NewUI(4, CBox)
				oSubMenu.m_DefeatedWidget = oSubMenu:NewUI(5, CBox)
				oSubMenu.m_DoneWidget = oSubMenu:NewUI(6, CBox)
				oSubMenu:SetGroup(groupId)
				oSubMenu.m_Status = {}
				table.insert(oSubMenu.m_Status, oSubMenu.m_DoingWidget)
				table.insert(oSubMenu.m_Status, oSubMenu.m_AcceptWidget)
				table.insert(oSubMenu.m_Status, oSubMenu.m_DefeatedWidget)
				table.insert(oSubMenu.m_Status, oSubMenu.m_DoneWidget)				
				self.m_SubMenuGrid:AddChild(oSubMenu)				
			else
				oSubMenu = subMenuBoxList[i]
			end
			--父画面来管理子按钮的选中态	
			if self.m_View then		
				self.m_View:AddSubMenuBox(oSubMenu)
			end
			for k, v in ipairs(oSubMenu.m_Status) do				
				v:SetActive(false)				
			end
			local status = oTask:GetValue("status")
			local type = oTask:GetValue("type")
			--主线一直显示进行中
			if type == define.Task.TaskCategory.STORY.ID or status == define.Task.TaskStatus.Accept or status == define.Task.TaskStatus.HasCommmit then
				--可接任务暂时显示为进行中
				--oSubMenu.m_AcceptWidget:SetActive(true)
				oSubMenu.m_DoingWidget:SetActive(true)
			elseif status == define.Task.TaskStatus.Doing then
				oSubMenu.m_DoingWidget:SetActive(true)
			elseif status == define.Task.TaskStatus.Defeated then
				 oSubMenu.m_DefeatedWidget:SetActive(true)
			elseif status == define.Task.TaskStatus.Done then
				oSubMenu.m_DoneWidget:SetActive(true)
			end			

			oSubMenu:AddUIEvent("click", callback(self, "OnClickSubMenu", oTask, i))
			oSubMenu.m_SubTaskLabel:SetText(oTask:GetValue("name"))	
			oSubMenu.m_SelectSprite:SetActive(false)		
			oSubMenu:SetActive(true)

			--默认选中任务处理
			if defaultSelectId then
				if defaultSelectId == 0 then
					local lastAccpetTask = g_TaskCtrl:GetLastAcceptTask()
					if lastAccpetTask then						
						if lastAccpetTask:GetValue("type") == define.Task.TaskCategory.TEACH.ID and 
							oTask:GetValue("type") == define.Task.TaskCategory.TEACH.ID then						
							self:OnClickSubMenu(oTask, i)
						else
							if lastAccpetTask:GetValue("taskid") == oTask:GetValue("taskid") then
								self:OnClickSubMenu(oTask, i)
							end
						end									
					end
				else
					if defaultSelectId == oTask:GetValue("taskid") then
						self:OnClickSubMenu(oTask, i)
					end
				end
			end
		end	
	end
	
	if taskCount == 0 then
		self.m_TweenHeight.to = 0
		self.m_SubMenuBgSpr:SetHeight(0)
		self.m_SubMenuCustomBgSpr:SetActive(false)
	else
		self.m_SubMenuBgSpr:SetHeight(100)
		local _, h = self.m_SubMenuGrid:GetCellSize()	
		self.m_TweenHeight.to = (taskCount + 0.7 ) * h 
		self.m_SubMenuCustomBgSpr:SetActive(true)
		self.m_SubMenuCustomBgSpr:SetHeight((taskCount ) * h + 13)  
	end

	if #subMenuBoxList > taskCount then
		for i = taskCount + 1, #subMenuBoxList do
			subMenuBoxList[i]:SetActive(false)
		end
	end

	self.m_MainMenuBtn:AddUIEvent("click", callback(self, "OnClickMainMenu"))

	self.m_MainMenuFlagOpenSpr:SetActive(true)
	self.m_MainMenuFlagCloseSpr:SetActive(true)
	if isOpen then
		self.m_MainMenuFlagOpenSpr:SetActive(false)
		self.m_SubMenuBgSpr:SetActive(true)
		self.m_TweenHeight:Toggle()
	else
		self.m_MainMenuFlagCloseSpr:SetActive(false)
	end
end

function CTaskTypeMenuBox.SelectSubMenu(self, index)
	local gridList = self.m_SubMenuGrid:GetChildList()
	if gridList and #gridList > 0 and index ~= nil then
		if gridList[index] then
			--父画面来隐藏别的子按钮的选中态
			if self.m_View then	
				self.m_View:SetSubMenuBoxSelected(gridList[index])			
			end
			gridList[index].m_SelectSprite:SetActive(true)
		end
	end
end

function CTaskTypeMenuBox.OnClickMainMenu(self)
	self.m_MainMenuFlagOpenSpr:SetActive(not self.m_MainMenuFlagOpenSpr:GetActive())
	self.m_MainMenuFlagCloseSpr:SetActive(not self.m_MainMenuFlagCloseSpr:GetActive())
end

function CTaskTypeMenuBox.OnClickSubMenu(self, oTask, index)
	if Utils.IsNil(self) then
		return
	end
	if self.m_ClickCallback then
		self.m_ClickCallback(oTask)
	end
	self:SelectSubMenu(index)
end

function CTaskTypeMenuBox.OnToggle(self)
	self.m_SubMenuBgSpr:SetActive(true)
	self.m_TweenHeight:Toggle()
end

return CTaskTypeMenuBox
