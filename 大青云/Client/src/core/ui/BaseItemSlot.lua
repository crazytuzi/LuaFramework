--[[
拖拽格子基类
lizhuangzhuang
2014年7月17日17:50:37
]]
_G.classlist['BaseItemSlot'] = 'BaseItemSlot'
_G.BaseItemSlot = {};
_G.BaseItemSlot.objName = 'BaseItemSlot'
function BaseItemSlot:new(mc)
	local obj = {};
	for i,v in pairs(BaseItemSlot) do
		if type(v) == "function" then
			obj[i] = v;
		end
	end
	if mc then
		obj:SetMc(mc);
	end
	obj.slotPanel = nil;--item归属的面板
	obj.dragEnabled = true;--是否可拖拽
	return obj;
end

--设置控制的显示对象
function BaseItemSlot:SetMc(mc)
	if not mc then
		return;
	end
	if not self.mc then
		self:ClearMc();
	end
	self.mc = mc;
	mc.beginDrag = function() self:DoDragBegin(); end;
	mc.dragEnd = function() self:DoDragEnd(); end;
	mc.drop = function(e) self:DoDragIn(e); end;
	if mc.button then
		mc.button.press = function() self:OnPress(); end;
		mc.button.click = function() self:OnClick(); end;
		mc.button.rclick = function() self:OnRClick(); end;
		mc.button.rollOver = function() self:OnRollOver(); end;
		mc.button.rollOut = function() self:OnRollOut(); end;
		mc.button.doubleClickEnabled = true;
		mc.button.doubleClick = function() self:OnDoubleClick(); end;
	end
end

--清除mc
function BaseItemSlot:ClearMc()
	if not self.mc then return; end
	self.mc.beginDrag = nil;
	self.mc.dragEnd = nil;
	self.mc.drop = nil;
	if not self.mc.button then return; end
	self.mc.button.press = nil;
	self.mc.button.click = nil;
	self.mc.button.rclick = nil;
	self.mc.button.rollOver = nil;
	self.mc.button.rollOut = nil;
	self.mc.button.doubleClick = nil;
end

function BaseItemSlot:SetSlotPanel(panel)
	self.slotPanel = panel;
end

--设置类型
function BaseItemSlot:SetType(type)
	if self.mc then
		self.mc.type = type;
	end
end

--设置接收类型
function BaseItemSlot:SetAcceptType(array)
	if self.mc then
		self.mc:setDragAcceptTypes(unpack(array));
	end
end

--设置数据
function BaseItemSlot:SetData(data)
	if self.mc then
		self.mc.userdata = data;
	end
end

--获取数据
function BaseItemSlot:GetData()
	if self.mc then
		return self.mc.userdata;
	end
	return nil;
end


-----------------以下是事件处理--------------------------------------------
--开始拖拽
function BaseItemSlot:DoDragBegin()
	if not self.dragEnabled then
		return;
	end
	if not self.mc then
		return;
	end
	local popUpMc = self.mc:start();
	local itemData = self:GetData();
	if itemData and itemData.iconUrl then
		popUpMc.source = itemData.iconUrl;
	end
	self:OnDragBegin();
end
--结束拖拽
function BaseItemSlot:DoDragEnd()
	self:OnDragEnd();
end
--有东西拖入
function BaseItemSlot:DoDragIn(e)
	self:OnDragIn(e.data.srcdata,e.target);
end
-----------------以上是事件处理-------------------------------------------

-----------------以下是子类可以实现的事件---------------------------------
--开始拖拽
function BaseItemSlot:OnDragBegin()
	if self.slotPanel then
		self.slotPanel:OnItemDragBegin(self);
	end
end
--结束拖拽
function BaseItemSlot:OnDragEnd()
	if self.slotPanel then
		self.slotPanel:OnItemDragEnd(self);
	end
end
--有东西拖入
function BaseItemSlot:OnDragIn(fromData,toMc)
	if self.slotPanel then
		self.slotPanel:OnItemDragIn(fromData,toMc.userdata);
	end
end
--press
function BaseItemSlot:OnPress()
	if self.slotPanel then
		self.slotPanel:OnItemPress(self);
	end
end
--点击
function BaseItemSlot:OnClick()
	if self.slotPanel then
		self.slotPanel:OnItemClick(self);
	end
end
--右键点击
function BaseItemSlot:OnRClick()
	if self.slotPanel then
		self.slotPanel:OnItemRClick(self);
	end
end
--鼠标移入
function BaseItemSlot:OnRollOver()
	if self.slotPanel then
		self.slotPanel:OnItemRollOver(self);
	end
end
--鼠标移出
function BaseItemSlot:OnRollOut()
	if self.slotPanel then
		self.slotPanel:OnItemRollOut(self);
	end
end
--双击
function BaseItemSlot:OnDoubleClick()
	if self.slotPanel then
		self.slotPanel:OnItemDoubleClick(self);
	end
end
-----------------以上是子类可以实现的事件---------------------------------

--销毁格子对象
function BaseItemSlot:Destroy()
	self.slotPanel = nil;
	self:ClearMc();
	self.mc = nil;
end