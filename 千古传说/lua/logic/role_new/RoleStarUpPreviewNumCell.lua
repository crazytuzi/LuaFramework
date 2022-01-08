
local RoleStarUpPreviewNumCell = class("RoleStarUpPreviewNumCell", BaseLayer)

function RoleStarUpPreviewNumCell:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.role_new.RoleStarUpPreviewNumCell")

end

function RoleStarUpPreviewNumCell:initUI( ui )

	self.super.initUI(self, ui)

	self.ui = ui

	self.num_view = TFDirector:getChildByPath(ui, "num_view")
	self.curr_num = TFDirector:getChildByPath(self.num_view, "curr_num")
	self.total_num = TFDirector:getChildByPath(self.num_view, "total_num")	

	self.num_view_red = TFDirector:getChildByPath(ui, "num_view_red")
	self.curr_num_red = TFDirector:getChildByPath(self.num_view_red, "curr_num")
	self.total_num_red = TFDirector:getChildByPath(self.num_view_red, "total_num")	

end

function RoleStarUpPreviewNumCell:removeUI()
	
	self.super.removeUI(self)

end

function RoleStarUpPreviewNumCell:dispose()
	print("<<<<<<<<<<<<<<<<<<<RoleStarUpPreviewNumCell:dispose")
end

function RoleStarUpPreviewNumCell:registerEvents()
	self.super.registerEvents(self)
end

function RoleStarUpPreviewNumCell:removeEvents()

    self.super.removeEvents(self)
end

function RoleStarUpPreviewNumCell:setData(itemId,curr_num,total_num,type)
	
	local rewardInfo = {}
	rewardInfo.type = type or EnumDropType.GOODS
	rewardInfo.itemId = itemId
	rewardInfo.number = 1
	local _rewardInfo = BaseDataManager:getReward(rewardInfo)
	local reward_item =  Public:createIconNumNode(_rewardInfo)
	reward_item:setScale(0.65);
	reward_item:setPosition(ccp(0,-5))
	reward_item:setZOrder(1)
	self.ui:addChild(reward_item)

	if curr_num >= total_num then
		self.num_view:setVisible(true)
		self.num_view_red:setVisible(false)
		self.curr_num:setText(curr_num)
		self.total_num:setText("/"..total_num)
	else
		self.num_view:setVisible(false)
		self.num_view_red:setVisible(true)
		self.curr_num_red:setText(curr_num)
		self.total_num_red:setText("/"..total_num)
	end
	
end

return RoleStarUpPreviewNumCell