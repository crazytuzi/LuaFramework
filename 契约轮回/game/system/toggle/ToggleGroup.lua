--
-- @Author: LaoY
-- @Date:   2018-12-07 14:52:45
--
ToggleGroup = ToggleGroup or class("ToggleGroup",BaseWidget)
local ToggleGroup = ToggleGroup

function ToggleGroup:ctor(parent_node,builtin_layer,child_class)
	self.abName = "system"
	self.assetName = "ToggleGroup"
	-- 场景对象才需要修改
	-- self.builtin_layer = builtin_layer
	self.item_list = {}
	self.child_class = child_class
	ToggleGroup.super.Load(self)
end

function ToggleGroup:dctor()
	for k,item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}
end

function ToggleGroup:LoadCallBack()
	self.nodes = {
		"Toggle","scroll/Viewport/Content","scroll",
	}
	self:GetChildren(self.nodes)
	SetVisible(self.Toggle,false)
	self.scroll_component = self.scroll:GetComponent('ScrollRect')	
	self.Toggle_gameobject = self.Toggle.gameObject
	self:SetHorizontalLayoutGroupSpacing(138)
	self:AddEvent()
end

function ToggleGroup:AddEvent()
end

--其他设置另外处理
function ToggleGroup:SetHorizontalLayoutGroupSpacing(space)
	local hlgroup = self.Content:GetComponent('HorizontalLayoutGroup')
	hlgroup.spacing = space
	-- SetHorizontalLayoutGroupSpacing(self.Content,space)
end

function ToggleGroup:SetCallBack(call_back)
	self.call_back = call_back
end

function ToggleGroup:SetData(data,select_id)
	if not data then
		return
	end
	local function callback(id)
		if self.select_id == id then
			return
		end
		self.select_id = id 
		self:SetSelectId(id)
		if self.call_back then
			self.call_back(id)
		end
	end

	self.data = data
	local list = data
	local length = #list
	self.scroll_component.horizontal = length > 7
	for i=1, length do
		local item = self.item_list[i]
		if not item then
			if self.child_class then
				item = self.child_class(self.Content)
			else
				item = Toggle(self.Toggle_gameobject,self.Content)
			end
			self.item_list[i] = item
			item:SetCallBack(callback)
		end
		item:SetVisible(true)
		item:SetData(i,list[i])
	end

	select_id = self:GetToggleID(select_id)
	callback(select_id)

	for i=length+1,#self.item_list do
		local item = self.item_list[i]
		item:SetVisible(false)
	end
end

function ToggleGroup:GetToggleID(select_id)
	if not self.data then
		return select_id
	end

	local default
	if select_id then
		for i=1,#self.data do
			local info = self.data[i]
			if select_id == info.id then
				if IsOpenModular(info.show_lv,info.show_task) then
					return select_id
				end
				break
			end
		end
	end
	for i=1,#self.data do
		local info = self.data[i]
		if IsOpenModular(info.show_lv,info.show_task) then
			return info.id
		end
	end
	return nil
end

function ToggleGroup:SetSelectId(id)
	for k,item in pairs(self.item_list) do
		item:SetSelectState(item.id == id)
	end
end

function ToggleGroup:ResetRedDot()
	for k,item in pairs(self.item_list) do
		item:SetRedDotParam(false)
	end
end

function ToggleGroup:GetItem(id)
	for k,item in pairs(self.item_list) do
		if item.id == id then
			return item
		end
	end
	return nil
end

function ToggleGroup:SetRedDotParam(id,param)
	local item = self:GetItem(id)
	if item then
		item:SetRedDotParam(param)
	end
end