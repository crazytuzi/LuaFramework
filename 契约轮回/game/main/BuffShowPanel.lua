--
-- @Author: LaoY
-- @Date:   2018-11-24 15:51:27
--
BuffShowPanel = BuffShowPanel or class("BuffShowPanel",BasePanel)
local BuffShowPanel = BuffShowPanel

function BuffShowPanel:ctor()
	self.abName = "main"
	self.assetName = "BuffShowPanel"
	self.layer = "Bottom"

	self.use_background = true
	self.change_scene_close = true
	self.click_bg_close = true

	self.item_list = {}
end

function BuffShowPanel:dctor()
	for k,item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}
end

function BuffShowPanel:Open(index)
	self.index = index
	BuffShowPanel.super.Open(self)
end

function BuffShowPanel:LoadCallBack()
	self.nodes = {
		"img_bg/scroll","img_bg/scroll/Viewport","img_bg/scroll/Viewport/Content","img_bg","BuffShowItem","btn_close",
	}
	self:GetChildren(self.nodes)

	self.scroll_component = self.scroll:GetComponent('ScrollRect')
	-- self.scroll_component.vertical = false

	local height = GetSizeDeltaY(self.img_bg)
	local y = GetLocalPositionY(self.img_bg)
	self.img_top_y = y + height * 0.5

	local scroll_height = GetSizeDeltaY(self.scroll)
	self.offset_height = height - scroll_height + 10

	SetAlignType(self,bit.bor(AlignType.Left,AlignType.Top))
	SetVisible(self.BuffShowItem,false)
	self.BuffShowItem_gameObject = self.BuffShowItem.gameObject
	if self.background_img then
		SetAlpha(self.background_img,0)
	end

	-- self:SetOrderIndex(102)

	self:AddEvent()
end

function BuffShowPanel:AddEvent()
	AddButtonEvent(self.btn_close.gameObject, handler(self, self.Close))
end

function BuffShowPanel:OpenCallBack()
	self:UpdateView()
end

function BuffShowPanel:UpdateView( )
	local role_data = RoleInfoModel:GetInstance():GetMainRoleData()
	local list = role_data:GetShowBuffList() or {}

	-- list[#list+1] = list[1]
	-- list[#list+1] = list[1]
	-- list[#list+1] = list[1]
	-- list[#list+1] = list[1]

	local height = 112
	local length = #list
	local toall_height = 0
	local select_y = 0
	for i=1,#list do
		local item = self.item_list[i]
		if not item then
			item = BuffShowItem(self.BuffShowItem_gameObject,self.Content)
			self.item_list[i] = item
		end
		item:SetData(list[i])
		local item_height = item:GetItemHeight()
		local x = 250
		local y = -0.5 * item_height - toall_height + 224
		if self.index == i then
			select_y = toall_height
		end
		toall_height = toall_height + item_height
		-- item:SetPosition(x,y)
	end

	local scroll_height = length <= 4 and toall_height or 4*height
	if length < 2 then
		scroll_height = 2*height
	end
	SetSizeDeltaY(self.scroll,scroll_height)

	SetSizeDelta(self.Viewport,0,0)
	SetSizeDeltaY(self.Content,toall_height)

	self.scroll_component.vertical = length > 4

	local img_height = scroll_height + self.offset_height
	SetSizeDeltaY(self.img_bg,img_height)
	local y = self.img_top_y - img_height * 0.5
	SetLocalPositionY(self.img_bg,y)


	if self.index and self.index > 4 then
		-- local offset_y = 0
		-- if self.index == #list then
		-- 	offset_y = (self.index - 2) * height
		-- else
		-- 	offset_y = (self.index - 1) * height
		-- end
		SetLocalPositionY(self.Content,select_y)
	end
end

function BuffShowPanel:CloseCallBack(  )

end