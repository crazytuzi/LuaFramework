local CPowerGuideTypeMenuBox = class("CPowerGuideTypeMenuBox", CBox)

function CPowerGuideTypeMenuBox.ctor(self, obj, oView)
	CBox.ctor(self, obj)
	self.m_MainMenuBtn = self:NewUI(1, CButton, true, false)
	self.m_MainMenuFlagOpenSpr = self:NewUI(2, CSprite)
	self.m_SubMenuBgSpr = self:NewUI(3, CSprite)
	self.m_SubMenuPanel = self:NewUI(4, CPanel)
	self.m_SubMenuGrid = self:NewUI(5, CGrid)
	self.m_SubMenuBtnClone = self:NewUI(6, CBox)
	self.m_MainMenuFlagCloseSpr = self:NewUI(7, CSprite)
	self.m_TaskTypeLabel = self:NewUI(8, CLabel)
	self.m_TweenHeight = self.m_SubMenuBgSpr:GetComponent(classtype.TweenHeight)
	self.m_ClickCallback = nil
	self.m_SubList = nil
	self.m_View = oView
	self.m_ClickMainCb = nil
	self.m_SubMenuBtnClone:SetActive(false)
end

function CPowerGuideTypeMenuBox.SetContent(self, name, subList, groupId, ClickCb, isOpen, selectId, args)
	if subList == nil then
		subList = {}			
	end
	self.m_TaskTypeLabel:SetText(name)
	self.m_SubList = subList
	self.m_ClickCallback = ClickCb
	self:RefMenuBox(groupId, isOpen, selectId, args)
end

function CPowerGuideTypeMenuBox.RefMenuBox(self, groupId, isOpen, selectId, args)
	local count = #self.m_SubList
	local subMenuBoxList = self.m_SubMenuGrid:GetChildList() or {}
	if count > 0 then
		for i = 1, count do
			local id = self.m_SubList[i]
			local d = data.powerguidedata.MAIN[id]
			local oSubMenu = nil
			if i > #subMenuBoxList then			
				oSubMenu = self.m_SubMenuBtnClone:Clone()
				oSubMenu.m_SubLabel = oSubMenu:NewUI(1, CLabel)
				oSubMenu.m_SelectSprite = oSubMenu:NewUI(2, CSprite)				
				oSubMenu:SetGroup(groupId)			
				self.m_SubMenuGrid:AddChild(oSubMenu)				
			else
				oSubMenu = subMenuBoxList[i]
			end
			--父画面来管理子按钮的选中态	
			if self.m_View then		
				self.m_View:AddSubMenuBox(oSubMenu)
			end		
			oSubMenu:AddUIEvent("click", callback(self, "OnClickSubMenu", i, id))
			oSubMenu.m_SubLabel:SetText(d.main_type_name)			
			oSubMenu:SetActive(true)
			if selectId == id then
				oSubMenu.m_SelectSprite:SetActive(true)
			else
				oSubMenu.m_SelectSprite:SetActive(false)	
			end
		end	
	end
	
	if count == 0 then
		self.m_TweenHeight.to = 0
		self.m_SubMenuBgSpr:SetHeight(0)
	else
		
		local _, h = self.m_SubMenuGrid:GetCellSize()	
		self.m_TweenHeight.to = count * h 
		self.m_SubMenuBgSpr:SetHeight(count * h )
	end

	if #subMenuBoxList > count then
		for i = count + 1, #subMenuBoxList do
			subMenuBoxList[i]:SetActive(false)
		end
	end

	self.m_ClickMainCb = args.clickMainCb
	self.m_MainMenuBtn:AddUIEvent("click", callback(self, "OnClickMainMenu", args.idx, true))

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

function CPowerGuideTypeMenuBox.SelectSubMenu(self, index, id)
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

function CPowerGuideTypeMenuBox.OnClickMainMenu(self, idx, isClick)
	self.m_MainMenuFlagOpenSpr:SetActive(not self.m_MainMenuFlagOpenSpr:GetActive())
	self.m_MainMenuFlagCloseSpr:SetActive(not self.m_MainMenuFlagCloseSpr:GetActive())
	if self.m_ClickMainCb and isClick then
		self.m_ClickMainCb(idx, not self.m_MainMenuFlagOpenSpr:GetActive())
	end
end

function CPowerGuideTypeMenuBox.HideSubMenu(self)
	self.m_MainMenuFlagOpenSpr:SetActive(true)
	self.m_MainMenuFlagCloseSpr:SetActive(false)
	self.m_SubMenuBgSpr:SetActive(false)
	self.m_TweenHeight:Toggle()
end

function CPowerGuideTypeMenuBox.OnClickSubMenu(self, index, id)
	if self.m_ClickCallback then
		self.m_ClickCallback(id)
	end
	self:SelectSubMenu(index)
end

function CPowerGuideTypeMenuBox.OnToggle(self)
	self.m_SubMenuBgSpr:SetActive(true)
	self.m_TweenHeight:Toggle()
end

return CPowerGuideTypeMenuBox
