BuffUIManager =BaseClass()

--*****************BUFF UI 管理
function BuffUIManager:__init( buffContainer, holderId, buffDescPanel, isPlayer, initData)
	self.buffContainer = buffContainer
	
	self.buffDescPanel = buffDescPanel
	self.buffDescContainer = self.buffDescPanel:GetChild("descContainer")
	self.buffDescContainerBg = self.buffDescPanel:GetChild("n0")

	self.isPlayer = isPlayer

	self._list = self.buffContainer.asList
	self.holderId = holderId
	self.buffList = {}
	self.buffContainer.visible = false
	self.buffDescPanel.visible = false
	self.renderMgrStr = "BuffUIManagerRender"..self.holderId
	self.canUpate = false

	self.buffDescList = {}
	self.descCount = 0
	self.descMax = 15
	--self.buffDescContainer.width = 340
	self.descHeight = 0
	self.maxDescWidth = 0

	if initData then
		self:BatchUpdate(initData)
	end
	self:InitEvent()
end

function BuffUIManager:InitEvent()
	self.buffDescContainer.onTouchEnd:Add(function()
		self.buffDescPanel.visible = false
	end, self)

	self.buffContainer.onClick:Add(function () 
		self.buffDescPanel.visible = not self.buffDescPanel.visible
	end, self)  

	self.handler=GlobalDispatcher:AddEventListener(EventName.BUFF_UPDATE_EVENT, function ( data )
		self:BatchUpdate(data)
	end)
end

function BuffUIManager:RemoveEvent()
	self.buffDescContainer.onTouchEnd:Clear()
	self.buffContainer.onClick:Clear()

	GlobalDispatcher:RemoveEventListener(self.handler)
end

function BuffUIManager:AddBuffDesc(buffVo, cfgData)
	local item = BuffDescItem.CreateFromPool()
	item:InitView(buffVo, cfgData)
	if self.descCount == 0 then
		item:HideLine()
	end
	item.ui.x = 10
	item.ui.y = self.descHeight
	self.descCount = self.descCount + 1
	self.descHeight = self.descHeight + item:GetHeight()
	self.buffDescContainer:AddChild(item.ui)
	if self.descCount < self.descMax then
		self.buffDescContainer.height = self.descHeight
		self.buffDescContainerBg.height = 15 + self.descHeight + 15
	end

	if item:GetW() > self.maxDescWidth then
		self.maxDescWidth = item:GetW()
	end

	if self.isPlayer then
		if self.descCount <= 5 then
			self.buffDescPanel.y = 152
		else
			self.buffDescPanel.y = 188
		end
	else
		self.buffDescPanel.y = 91
	end
	return item
end

function BuffUIManager:ClearBuffDesc()
	while self.buffDescContainer.numChildren > 0 do
		self.buffDescContainer:RemoveChildAt(0)
	end
	self.buffDescList = nil
	self.buffDescList = {}
	self.descHeight = 0
	self.descCount = 0
	self.maxDescWidth = 0
end

function BuffUIManager:BatchUpdate( data )
	if self.holderId == data.guid then
		self.canUpate = false
		local buffAry =  data.buffAry

		self:ClearList()
		self:ClearBuffDesc()

		local showBuff = false
		for i = 1, #buffAry do
			local buffVo = buffAry[i].vo
			local cfgData = buffAry[i].cfgData
			if cfgData and cfgData.bufficonID and cfgData.bufficonID ~= 0 then
				local descItem = self:AddBuffDesc(buffVo, cfgData)
				table.insert(self.buffDescList, descItem)

				local item = self._list:AddItemFromPool()
				local buffItem = BuffUIItem.Create(item)
				buffItem:InitView(buffVo, cfgData)
				table.insert(self.buffList, buffItem)
				self._list:EnsureBoundsCorrect()
				showBuff = true
			end
		end

		if showBuff then
			self.buffDescContainer.width = self.maxDescWidth
			self.buffContainer.visible = true
			RenderMgr.Add(function() self:Update() end, self.renderMgrStr)
		else
			self.buffContainer.visible = false
			self.buffDescPanel.visible = false
			RenderMgr.Remove(self.renderMgrStr)
		end
		
		self.canUpate = true
	end
end

function BuffUIManager:ClearList()
	while self._list.numItems > 0 do
		self._list:RemoveChildToPoolAt(0)
	end
	self.buffList = nil
	self.buffList = {}
end

function BuffUIManager:Update()
	if not self.canUpate then return end
	for i = 1, #self.buffList do
		local buff = self.buffList[i]
		buff:Update()
	end

	for i = 1, #self.buffDescList do
		local buffDesc = self.buffDescList[i]
		buffDesc:Update()
	end
end

function BuffUIManager:__delete()
	RenderMgr.Remove(self.renderMgrStr)
	for i,v in ipairs(self.buffList) do
		v:Destroy()
	end
	self.buffList = nil

	--由BuffDescItem.DestoryPool()在MainUIController:__delete()执行销毁
	self.buffDescList = nil

	self:RemoveEvent()
	self._list:RemoveChildrenToPool()

	self.holderId = 0
end