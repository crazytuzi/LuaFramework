FriendTreeSubMenuItem = FriendTreeSubMenuItem or class("FriendTreeSubMenuItem",BaseTreeTwoMenu)
local FriendTreeSubMenuItem = FriendTreeSubMenuItem

function FriendTreeSubMenuItem:ctor(parent_node,layer, first_menu_item)
	self.abName = "system"
	self.assetName = "FriendTreeSubMenuItem"
	self.layer = layer
	self.first_menu_item = first_menu_item
	self.parent_cls_name = self.first_menu_item.parent_cls_name

	--self.model = 2222222222222end:GetInstance()
	FriendTreeSubMenuItem.super.Load(self)
end

function FriendTreeSubMenuItem:dctor()
	self.FriendItem:destroy()
end

function FriendTreeSubMenuItem:ShowPanel()
	if self.data then
		if self.Text then
			self.Text:GetComponent('Text').text = self.data[2]
		end
		self:Select(self.select_sub_id)
		self.FriendItem = FriendItem(self.transform)
		self.FriendItem:SetData(self.data[1])
	end
end

function FriendTreeSubMenuItem:UpdateData(data)
	self.data = data
	if self.data then
		if self.Text then
			self.Text:GetComponent('Text').text = self.data[2]
			self:Select(self.select_sub_id)
			self.FriendItem:SetData(self.data[1])
		end
	end
end

