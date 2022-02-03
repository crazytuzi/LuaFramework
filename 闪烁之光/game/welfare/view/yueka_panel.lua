-- --------------------------------------------------------------------
--- 月卡 集合
-- --------------------------------------------------------------------
YuekaPanel = class("YuekaPanel", function()
	return ccui.Widget:create()
end)

local controll = WelfareController:getInstance()
local card_data = Config.ChargeData.data_constant
local string_format = string.format
local card1_add_count = card_data.month_card1_sun.val
local item_bid_1 = card_data.month_card1_items.val[1][1]
local item_num_1 = card_data.month_card1_items.val[1][2]
local add_get_day_1 = card_data.month_card1_cont_day.val
function YuekaPanel:ctor()
	self.current_day = 0
	self:loadResources()
end

function YuekaPanel:loadResources()
	self:configUI()
	self:register_event()
end

function YuekaPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/sum_yueka_panel"))
	self:addChild(self.root_wnd)
	-- self:setCascadeOpacityEnabled(true)
	self:setPosition(-40, -86)
	self:setAnchorPoint(0, 0)
	
	self.main_container = self.root_wnd:getChildByName("main_container")
	self.HonorYuekaPanel = HonorYuekaPanel.new()
	self.main_container:addChild(self.HonorYuekaPanel)

	self.SupreYuekaPanel = SupreYuekaPanel.new()
	self.main_container:addChild(self.SupreYuekaPanel)
end

function YuekaPanel:register_event()
	
end

function YuekaPanel:setVisibleStatus(bool)
	bool = bool or false
	self:setVisible(bool)
end

function YuekaPanel:DeleteMe()
	if self.HonorYuekaPanel and self.HonorYuekaPanel.DeleteMe then
		self.HonorYuekaPanel:DeleteMe()
	end
	self.HonorYuekaPanel = nil

	if self.SupreYuekaPanel and self.SupreYuekaPanel.DeleteMe then
		self.SupreYuekaPanel:DeleteMe()
	end
	self.SupreYuekaPanel = nil
end 