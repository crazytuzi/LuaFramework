-----------------------------------------------------
--对scrollView常用的功能进行进一步封装。如额外增加的左右按钮，快速实现点击移动，根据情况控制按钮出现与消失
--@author bzw
-----------------------------------------------------
ScrollView = ScrollView or BaseClass()
ScrollView.CountDownId = 0
function ScrollView:__init()
	self.scrollview = nil
	self.left_btn = nil
	self.right_btn = nil
	self.view_rect_num = 0
	self.total_num = 0

	self.cur_precent = 0
	self.x = 0
end

function ScrollView:__delete()
	self.scrollview = nil
	self.left_btn = nil
	self.right_btn = nil
end

-- view_rect_num 显示item数量
-- total_num item总数
-- move_num_once 移动item数量
function ScrollView:SetScrollView(scrollview, left_btn, right_btn, view_rect_num, total_num, move_num_once)
	if scrollview == nil or left_btn == nil or right_btn == nil then return end

	self.scrollview = scrollview
	self.left_btn = left_btn
	self.right_btn = right_btn
	self.view_rect_num = view_rect_num
	self.total_num = total_num
	self.move_num_once = move_num_once or view_rect_num

	self:CheckBtnVisible()

	self.scrollview:addScrollEventListener(BindTool.Bind1(self.ScrollHandler, self))
	self.left_btn:addClickEventListener(BindTool.Bind2(self.ClickBtnHandler, self, true))
	self.right_btn:addClickEventListener(BindTool.Bind2(self.ClickBtnHandler, self, false))
end

function ScrollView:SetTotalNum(total_num)
	self.total_num = total_num
	self:CheckBtnVisible()
end

function ScrollView:ScrollHandler(sender, event_type, x, y)
	local content_size = sender:getContentSize()
	local inner_size = sender:getInnerContainerSize()
	if inner_size.width > content_size.width then
		self.x = self.x + x
		self.cur_precent = math.ceil(math.abs(self.x) / (inner_size.width - content_size.width) * 100)
	end
	self:CheckBtnVisible()
end

function ScrollView:ClickBtnHandler(is_to_left)
	self:ScrollTo(is_to_left)
end

function ScrollView:ScrollTo(is_to_left)
	local one_move_precent = math.ceil(100 / (self.total_num - self.view_rect_num))
	local move_precent = math.ceil(one_move_precent * self.move_num_once)

	if move_precent > 100 then
		move_precent = 100
	else
		move_precent = 0
	end

	if is_to_left then
		self.cur_precent = self.cur_precent - move_precent
	else
		self.cur_precent = self.cur_precent + move_precent
	end

	self.scrollview:scrollToPercentHorizontal(self.cur_precent, 0.3, false)
end

function ScrollView:CheckBtnVisible()
	if self.view_rect_num >= self.total_num or self.cur_precent < 0 then
		self.left_btn:setVisible(false)
		self.right_btn:setVisible(false)
		return
	end

	self.left_btn:setVisible(self.cur_precent > 0)
	self.right_btn:setVisible(self.cur_precent < 100)
end