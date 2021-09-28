AwakePanel = BaseClass(LuaUI)

function AwakePanel:__init()
	self.ui = UIPackage.CreateObject("Wakan","AwakePanel")

	self.bg = self.ui:GetChild("bg")
	self.noActiveLevel = self.ui:GetChild("noActiveLevel")
	self.list = self.ui:GetChild("list")

	self.btnClose = self.bg:GetChild("close")
	self.btnClose.onClick:Add(function ()
		UIMgr.HidePopup(self.ui)
	end)
	self.listData = WakanModel:GetInstance().awakeData
	self._listItems = {}
	self._list = self.list
	self._list.itemRenderer = function(index, obj) self:RenderListItem(index, obj) end
	self._list.numItems = #self.listData
end

function AwakePanel:RenderListItem(index, obj)
	local item = AwakePanelItem.Create(obj) 
	item:FillData(self.listData[index + 1])
	item:Update()
	table.insert(self._listItems, item)
end

-- Dispose use AwakePanel obj:Destroy()
function AwakePanel:__delete()
	destroyUIList(self._listItems)
	self._listItems = nil
end