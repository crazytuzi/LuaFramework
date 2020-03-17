--[[
包含格子的面板基类
lizhuangzhuang
2014年7月17日17:51:22
]]
_G.classlist['BaseSlotPanel'] = 'BaseSlotPanel'
_G.BaseSlotPanel = {};
_G.BaseSlotPanel.objName = 'BaseSlotPanel'
function BaseSlotPanel:new(szName)
	local obj = BaseUI:new(szName);
	for i,v in pairs(BaseSlotPanel) do
		if type(v) == "function" then
			obj[i] = v;
		end
	end
	obj.dragEnabled = true;--是否可拖拽
	obj.listSlot = {};--面板的所有格子
	return obj;
end

--添加一个格子
function BaseSlotPanel:AddSlotItem(item,index)
	if self.listSlot[index] then
		print("error:panel ".. self.szName.." has a Slot at index: "..index);
		return;
	end
	self.listSlot[index] = item;
	item:SetSlotPanel(self);
	item.dragEnabled = self.dragEnabled;
end

--取一个格子
function BaseSlotPanel:GetSlotItem(index)
	return self.listSlot[index];
end

--移除一个格子
function BaseSlotPanel:RemoveSlotItem(index)
	if not self.listSlot[index] then
		return;
	end
	self.listSlot[index]:Destroy();
	self.listSlot[index] = nil
end

function BaseSlotPanel:RemoveAllSlotItem()
	for k,v in ipairs(self.listSlot) do
		self:RemoveSlotItem(k);
	end
end

function BaseSlotPanel:SetDragEnabled(val)
	self.dragEnabled = val;
	for i,item in pairs(self.listSlot) do
		item.dragEnabled = val;
	end
end

------------------以下是子类可以实现的事件------------------------
--开始拖拽item
function BaseSlotPanel:OnItemDragBegin(item)
end

--结束拖拽item
function BaseSlotPanel:OnItemDragEnd(item)
end

--正在拖拽item
function BaseSlotPanel:OnItemDragIn(fromData,toData)
end

--Press Item
function BaseSlotPanel:OnItemPress()

end

--点击Item
function BaseSlotPanel:OnItemClick(item)
end

--右键点击Item
function BaseSlotPanel:OnItemRClick(item)
end

--鼠标移上Item
function BaseSlotPanel:OnItemRollOver(item)
end

--鼠标移出Item
function BaseSlotPanel:OnItemRollOut(item)
end

--双击Item
function BaseSlotPanel:OnItemDoubleClick(item)

end
----------------以上是子类可以实现的事件--------------------------