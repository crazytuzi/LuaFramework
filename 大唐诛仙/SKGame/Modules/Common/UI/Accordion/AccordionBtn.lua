AccordionBtn = BaseClass(LuaUI)

AccordionBtn.AutoId = -9999999999
function AccordionBtn:__init(arrowShow)
	self.arrowShow = arrowShow
	self.URL = "ui://0tyncec1sbfonii"
	self:__property()
	self:Config()
end

function AccordionBtn:SetProperty()
end

function AccordionBtn:Config()
	self.id = AccordionBtn.AutoId
	AccordionBtn.AutoId = AccordionBtn.AutoId + 1

	self.myHeight = 66
	self.data = nil
	self.root = nil

	self:AddEvent()
end

function AccordionBtn:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","AccordionBtn");

	self.subTabs = self.ui:GetChild("subTabs")
	self.head = self.ui:GetChild("head")
	self.subTabs = AccordionCellItems.Create(self.subTabs)
	self.head:GetChild("arrowUp").visible = self.arrowShow
	self.head:GetChild("arrowDown").visible = self.arrowShow
end

function AccordionBtn.Create(ui, ...)
	return AccordionBtn.New(ui, "#", {...})
end

function AccordionBtn:AddEvent()
	self.head.onClick:Add(self.OnClickHandler, self)
end

function AccordionBtn:RemoveEvent()
	self.head.onClick:Remove(self.OnClickHandler, self)
end

function AccordionBtn:SetSelect(samellType)
	self:SetShow(true)

	return self.subTabs:SetSelect(samellType)
end

function AccordionBtn:SelectSelf(bSelect)
	local urlUnselect = UIPackage.GetItemURL("Common","btnBg_001")
	local urlSelect = UIPackage.GetItemURL("Common","btnBg_002")
	if bSelect then
		self.head.icon = urlSelect
	else
		self.head.icon = urlUnselect
	end
end

function AccordionBtn:SetData(data, root)
	self.bigType = tonumber(data[1])
	self.typeName = data[2]
	self.root = root

	self.head.title = self.typeName
	self.subTabs:SetData(self.bigType, data[3], self.root)
	self:Hide(false)
end

function AccordionBtn:OnClickHandler(unNeedTween)
	if not self.root.canClick then return end
	self.root.canClick = false
	if self.subTabs.subItems and #self.subTabs.subItems == 0 then
		if self.root and self.root.callBack then
			local data = {self.bigType, nil}
			self.root.callBack(data)
		end
	end
	self:SetShow(false)
	self.root:UnTouchable()
	-- add by wuqi 2017/08/01 fix默认全选中bug ==>> start
	if self.root.btns then
		for i = 1, #self.root.btns do
			self.root.btns[i]:SelectSelf(false)
		end
	end
	self:SelectSelf(true)
	-- <<== end
	DelayCall(function() 
		self.root:Touchable()
	end, self.root.clickBigInternal)
end

function AccordionBtn:GetMyHeight()
	self.ui.height = self.myHeight + self.subTabs:GetMyHeight()
	return self.myHeight + self.subTabs:GetMyHeight()
end

function AccordionBtn:SetShow(unNeedTween)
	if self.root.curShow and self.root.curShow == self then 
		self:Hide(true)
		self.root.curShow = nil
		return 
	end
	self.root.curShow = self
	self.root:HideAll()
	self:Show(unNeedTween)
end

function AccordionBtn:Show(unNeedTween)
	-- self.head.selected = true
	-- if not self.arrowShow then
	-- 	self.head.icon = UIPackage.GetItemURL("Common","btnBg_002")
	-- end
	self.subTabs:Show(unNeedTween)
	if unNeedTween then
		self.root:Layout()
		self.root.canClick = true
	else
		self.root:UnTouchable()
		RenderMgr.Add(function () self:ShowInFrame() end, "AccordionBtn:ShowInFrame"..self.id)
	end
end

function AccordionBtn:ShowInFrame()
	if not self.root then
		RenderMgr.Realse("AccordionBtn:ShowInFrame"..self.id)
		return
	end
	self.root:Layout()
	if self.subTabs:GetMyHeight() >= self.subTabs.orginHeight then
		self.root:Touchable()
		RenderMgr.Realse("AccordionBtn:ShowInFrame"..self.id)
		self.root.canClick = true
	end
end

function AccordionBtn:Hide(needFrame)
	self.subTabs:Hide(not needFrame) --是否需要缓动
	-- self.head.selected = false
	-- if not self.arrowShow then
	-- 	self.head.icon = UIPackage.GetItemURL("Common","btnBg_000")
	-- end
	if needFrame then
		self.root:UnTouchable()
		RenderMgr.Add(function () self:HideInFrame() end, "AccordionBtn:HideInFrame"..self.id)
	else
		self.root.canClick = true
	end
end

function AccordionBtn:HideInFrame()
	self.root:Layout()
	if self.subTabs:GetMyHeight() <= 0 then
		self.root:Touchable()
		RenderMgr.Realse("AccordionBtn:HideInFrame"..self.id)
		self.root.canClick = true
	end
end

function AccordionBtn:__delete()
	self:RemoveEvent()
	self.head:Destroy()
	self.subTabs:Destroy()

	self.data = nil
	self.root = nil
	self.head = nil 
	self.subTabs = nil 
end