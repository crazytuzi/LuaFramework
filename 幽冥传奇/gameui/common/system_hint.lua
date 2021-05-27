--[[
	系统提示信息
]]

-- 滚动公告类型AND截断 滚动公告优先级0是最先播放 9999999就是最后播放的意思
GUNDONGYOUXIAN = {
	ACTIVITY_TYPE = 0,				-- 活动公告
	SYSTEM_TYPE = 1000,				-- 系统公告
	HEARSAY_TYPE = 2000,			-- 传闻公告
	CFG_TYPE = 3000,				-- 配置公告

	TRUNCATION = 5,				-- 截断
	EXPLORE_CATION = 5,				-- 截断
}


SystemHint = SystemHint or BaseClass()

-- 飘字效果设置
SystemHint.FLOATINGTEXT = {
	SIZE = 24,
	DELAYTIME = 2,
	COLOR = COLOR3B.YELLOW,
	FONT = COMMON_CONSTS.FONT,
	QUENESIZE = 3,
}

function SystemHint:__init()
	if SystemHint.Instance ~= nil then
		ErrorLog("[SystemHint] attempt to create singleton twice!")
		return
	end
	SystemHint.Instance = self

	self.text_quene = {}
	self.layout_str = {}
	self.xb_layout_str = {}
	self.layout_rich_quene = {}
	self.aboveChat_layout_str = {}
	self.layout_net_unstable = nil

	self.is_loading = true
	self.is_loading_aboveChat=true
	GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind1(self.IsLodingFinish, self))
	GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind1(self.OnSceneChangeComplete, self))

end

function SystemHint:__delete()
	SystemHint.Instance = nil
	
	for i,v in ipairs(self.text_quene) do
		v:release()
	end
	self.text_quene = {}

	self.layout_rich_quene = {}
end

function SystemHint:IsLodingFinish()
	self.is_loading = false
	self:RollingEffect()
	self.is_loading_aboveChat = false
	self:AboveChatWindowRollingEffect()
end

-- 坐骑羽翼等提升飘字效果
function SystemHint:FloatingText(parent, str, x, y)
	if nil == parent or nil == str or "" == str then
		return
	end
	local label = XUI.CreateText(x, y, 0, 0, nil, str, nil, SystemHint.FLOATINGTEXT.SIZE, SystemHint.FLOATINGTEXT.COLOR)
	parent:addChild(label, 999, 999)
	label:retain()

	local move_act = cc.MoveBy:create(0.5, cc.p(0, 20))
	local delay_time = cc.DelayTime:create(SystemHint.FLOATINGTEXT.DELAYTIME)
	local call_func = function()
		label:removeFromParent(true)
	end
	local call_back = cc.CallFunc:create(call_func)
	local action = cc.Sequence:create(move_act, delay_time, call_back)

	label:runAction(action)

	table.insert(self.text_quene, label)

	if #self.text_quene > SystemHint.FLOATINGTEXT.QUENESIZE then
		self.text_quene[1]:removeFromParent(true)
		self.text_quene[1]:release()
		table.remove(self.text_quene, 1)
	end
	for i, v in ipairs(self.text_quene) do
		v:runAction(cc.MoveBy:create(0.5, cc.p(0, 30)))
	end
end

--屏幕右下飘字提示
function SystemHint:FloatingLabel(str)
	self.bottom_right_list = self.bottom_right_list or {}

	local rich_text
	if #self.bottom_right_list >= 5 then
		rich_text = table.remove(self.bottom_right_list, 1)
		RichTextUtil.ParseRichText(rich_text, str, 20, nil, nil, nil, 250, 0, nil, {outline_size = 1})
		rich_text:stopAllActions()
		rich_text:setVisible(true)
		rich_text:setOpacity(255)
	else
		rich_text = RichTextUtil.ParseRichText(nil, str, 20, nil, nil, nil, 250, 0, nil, {outline_size = 1})
		rich_text:setAnchorPoint(0, 0)
		HandleRenderUnit:AddUi(rich_text, -1, -1)
	end

	table.insert(self.bottom_right_list, rich_text)
	rich_text:refreshView()
	local size = rich_text:getInnerContainerSize()
	rich_text:setContentSize(size)
	rich_text:setPosition(HandleRenderUnit:GetWidth() - 480, 160 - size.height)

	local delay_time = cc.DelayTime:create(2.5)
	local fade_out = cc.FadeOut:create(0.5)
	local call_back = cc.CallFunc:create(function()
		rich_text:setVisible(false)
	end)
	local action = cc.Sequence:create(delay_time, fade_out, call_back)
	rich_text:runAction(action)

	for i, v in ipairs(self.bottom_right_list) do
		v:runAction(cc.MoveBy:create(0.5, cc.p(0, size.height + 5)))
	end
end

--屏幕中上方飘字效果有背景的
function SystemHint:FloatingLayoutText(str)
	self.top_center_list = self.top_center_list or {}

	local tips_layout, rich_text
	if #self.top_center_list >= 3 then
		tips_layout = table.remove(self.top_center_list, 1)
		tips_layout:stopAllActions()
		tips_layout:setVisible(true)
		tips_layout:setOpacity(255)
		rich_text = tips_layout:getChildByTag(1)
	else
		local tips_width, tips_height = 738, 30
		tips_layout = XUI.CreateLayout(0, 0, tips_width, tips_height)
		local img_bg = XUI.CreateImageViewScale9(tips_width / 2, tips_height / 2, tips_width, tips_height, ResPath.GetCommon("bg_110"), true, cc.rect(140, 8, 49, 15))
		tips_layout:addChild(img_bg)
	
		rich_text = XUI.CreateRichText(tips_width / 2, tips_height / 2, tips_width, tips_height, true)
		rich_text:setAnchorPoint(0.5, 0.5)
		XUI.RichTextSetCenter(rich_text)
		rich_text:setVerticalAlignment(RichVAlignment.VA_CENTER)
		RichTextUtil.ParseRichText(rich_text, str, 25, COLOR3B.YELLOW)
		tips_layout:addChild(rich_text, 1, 1)

		HandleRenderUnit:AddUi(tips_layout, COMMON_CONSTS.ZORDER_SYSTEM_HINT, COMMON_CONSTS.ZORDER_SYSTEM_HINT)
	end

	RichTextUtil.ParseRichText(rich_text, str, 25, COLOR3B.YELLOW)

	table.insert(self.top_center_list, tips_layout)
	tips_layout:setPosition(HandleRenderUnit:GetWidth() / 2, HandleRenderUnit:GetHeight() / 2 + 220)

	local delay_time = cc.DelayTime:create(2.5)
	local fade_out = cc.FadeOut:create(0.5)
	local call_back = cc.CallFunc:create(function()
		tips_layout:setVisible(false)
	end)
	local action = cc.Sequence:create(delay_time, fade_out, call_back)
	tips_layout:runAction(action)

	for i, v in ipairs(self.top_center_list) do
		v:runAction(cc.MoveBy:create(0.5, cc.p(0, 32)))
	end
end

--屏幕右上方飘字
function SystemHint:FloatingTopRightText(str)
	self.top_right_list = self.top_right_list or {}

	local rich_text
	if #self.top_right_list >= 3 then
		rich_text = table.remove(self.top_right_list, 1)
		RichTextUtil.ParseRichText(rich_text, str, 20, nil, nil, nil, 280, 0, nil, {outline_size = 1})
		rich_text:stopAllActions()
		rich_text:setVisible(true)
		rich_text:setOpacity(255)
	else
		rich_text = RichTextUtil.ParseRichText(nil, str, 20, nil, nil, nil, 280, 0, nil, {outline_size = 1})
		rich_text:setAnchorPoint(0, 0)
		HandleRenderUnit:AddUi(rich_text, COMMON_CONSTS.ZORDER_SYSTEM_HINT, COMMON_CONSTS.ZORDER_SYSTEM_HINT)
	end

	table.insert(self.top_right_list, rich_text)
	rich_text:refreshView()
	local size = rich_text:getInnerContainerSize()
	rich_text:setContentSize(size)
	rich_text:setPosition(HandleRenderUnit:GetWidth() - 280,
		HandleRenderUnit:GetHeight() - 320 - size.height)

	local delay_time = cc.DelayTime:create(2.5)
	local fade_out = cc.FadeOut:create(0.5)
	local call_back = cc.CallFunc:create(function()
		rich_text:setVisible(false)
	end)
	local action = cc.Sequence:create(delay_time, fade_out, call_back)
	rich_text:runAction(action)

	for i, v in ipairs(self.top_right_list) do
		v:runAction(cc.MoveBy:create(0.5, cc.p(0, size.height + 5)))
	end
end

-- 根据类型切换场景清除滚动条里面的内容不播放了
function SystemHint:OnSceneChangeComplete()
	if #self.layout_str > 0 then
		for i = #self.layout_str, 1, -1 do
			if self.layout_str[i][4] == SYS_MSG_TYPE.SYS_MSG_SPECIAL_SCENE_CENTER_AND_ROLL then
				table.remove(self.layout_str, i)
			end
		end
	end
end

-- 寻宝所有服广播 (文字, 优先级, 类型)
function SystemHint:ExploreAllServerBroadcast(str, priority, msg_type)
	-- 如果队列中有数据在播放，那么先保存起来等播放完了再播放下一条
	if nil ~= str and "" ~= str then
		msg_type = msg_type or 0
		priority = priority or 0

		for i = 1, GUNDONGYOUXIAN.EXPLORE_CATION + 1 do
			if nil == self.xb_layout_str[i] or self.xb_layout_str[i][2] > priority then
				table.insert(self.xb_layout_str, i, {str, priority, msg_type})
				break
			end
		end

		if #self.xb_layout_str > GUNDONGYOUXIAN.EXPLORE_CATION then
			table.remove(self.xb_layout_str, #self.xb_layout_str)
		end
	end

	if self.is_loading or self.is_sx_rolling or #self.xb_layout_str <= 0 then
		return
	end

	local roll_str = self.xb_layout_str[1][1]
	table.remove(self.xb_layout_str, 1)

	if nil == self.xb_tips_layout then
		local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
		local tips_width, tips_height = 826, 42

		self.xb_tips_layout = XUI.CreateLayout(screen_w / 2, MainuiChat.height + 120, tips_width, tips_height)
		HandleRenderUnit:AddUi(self.xb_tips_layout, COMMON_CONSTS.ZORDER_SYSTEM_HINT, COMMON_CONSTS.ZORDER_SYSTEM_HINT)

		local background = XUI.CreateImageViewScale9(tips_width / 2, tips_height / 2, 826, 42, ResPath.GetCommon("bg_112"), true)
		self.xb_tips_layout:addChild(background)

		local clipping_layout = XUI.CreateLayout(tips_width / 2, tips_height / 2, tips_width, tips_height, 2)
		clipping_layout:setClippingEnabled(true)
		self.xb_tips_layout:addChild(clipping_layout)

		self.xb_rich_text = XUI.CreateRichText(tips_width / 2, tips_height / 2, 0, tips_height, true)
		self.xb_rich_text:setVerticalAlignment(RichVAlignment.VA_CENTER)
		XUI.RichTextSetCenter(self.xb_rich_text)
		clipping_layout:addChild(self.xb_rich_text)
	end

	RichTextUtil.ParseRichText(self.xb_rich_text, roll_str, 25, COLOR3B.YELLOW, nil, nil, nil, nil)
	self.xb_rich_text:refreshView()
	local size = self.xb_rich_text:getInnerContainerSize()
	self.xb_rich_text:setPositionY(0)

	local move_by = cc.MoveBy:create(0.5, cc.p(0, size.height))
	local delay = cc.DelayTime:create(4)
	local move_by2 = cc.MoveBy:create(0.5, cc.p(0, size.height))
	local call_func = function()
		self.is_sx_rolling = false
		if nil ~= self.xb_layout_str[1] then
			self:ExploreAllServerBroadcast()
		else
			self.xb_tips_layout:removeFromParent()
			self.xb_tips_layout = nil
			self.xb_rich_text = nil
		end
	end
	local call_back = cc.CallFunc:create(call_func)
	local action = cc.Sequence:create(move_by, delay, move_by2, call_back)
	self.is_sx_rolling = true
	self.xb_rich_text:runAction(action)
end

-- 系统公告滚动效果 (文字, 优先级, 类型)
function SystemHint:RollingEffect(str, priority, msg_type)
	-- 如果队列中有数据在播放，那么先保存起来等播放完了再播放下一条
	if nil ~= str and "" ~= str then
		msg_type = msg_type or 0

		for i = 1, GUNDONGYOUXIAN.TRUNCATION + 1 do
			if nil == self.layout_str[i] or self.layout_str[i][2] > priority then
				table.insert(self.layout_str, i, {str, priority, msg_type})
				break
			end
		end

		if #self.layout_str > GUNDONGYOUXIAN.TRUNCATION then
			table.remove(self.layout_str, #self.layout_str)
		end
	end

	if self.is_loading or self.is_rolling or #self.layout_str <= 0 then
		return
	end

	local roll_str = self.layout_str[1][1]
	table.remove(self.layout_str, 1)

	local clipping_widths = 548

	if nil == self.roll_tips_layout then
		local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
		local tips_width, tips_height = 826, 42
		self.roll_tips_layout = XUI.CreateLayout(screen_w / 2, screen_h - 110, tips_width, tips_height)
		HandleRenderUnit:AddUi(self.roll_tips_layout, COMMON_CONSTS.ZORDER_SYSTEM_HINT, COMMON_CONSTS.ZORDER_SYSTEM_HINT)

		local background = XUI.CreateImageViewScale9(tips_width / 2, tips_height / 2, 826, 42, ResPath.GetCommon("bg_112"), true)
		self.roll_tips_layout:addChild(background)

		local clipping_layout = XUI.CreateLayout(tips_width / 2, tips_height / 2, clipping_widths, tips_height, 2)
		clipping_layout:setClippingEnabled(true)
		self.roll_tips_layout:addChild(clipping_layout)

		self.roll_rich_text = XUI.CreateRichText(clipping_widths / 2, tips_height / 2, 0, tips_height, true)
		self.roll_rich_text:setVerticalAlignment(RichVAlignment.VA_CENTER)
		self.roll_rich_text:setIgnoreSize(true)
		clipping_layout:addChild(self.roll_rich_text)
	end

	RichTextUtil.ParseRichText(self.roll_rich_text, roll_str, 25, COLOR3B.YELLOW, nil, nil, nil, nil, true)
	self.roll_rich_text:refreshView()
	local size = self.roll_rich_text:getInnerContainerSize()
	self.roll_rich_text:setPositionX(clipping_widths)

	local move_length = clipping_widths + size.width
	local move_by = cc.MoveBy:create(move_length / 100, cc.p(-move_length, 0))
	local call_func = function()
		self.is_rolling = false
		if nil ~= self.layout_str[1] then
			self:RollingEffect()
		else
			self.roll_tips_layout:removeFromParent()
			self.roll_tips_layout = nil
			self.roll_rich_text = nil
		end
	end
	local call_back = cc.CallFunc:create(call_func)
	local action = cc.Sequence:create(move_by, call_back)
	self.is_rolling = true
	self.roll_rich_text:runAction(action)
end

function SystemHint:SetLoadingEffectVisible(is_visible)
	if is_visible then
		LoginController.Instance:ShowWaitingEffect(true)
	else
		LoginController.Instance:RemoveWaitingEffect()
	end
end
local point_bg_t = nil
local point_bg_vis_index = 0
function SystemHint:ShowNetUnstableTips()
	if nil == self.layout_net_unstable then	
		self.layout_net_unstable = XUI.CreateLayout(0, 0, HandleRenderUnit:GetWidth() , HandleRenderUnit:GetHeight())
		self.layout_net_unstable:setBackGroundColor(COLOR3B.BLACK)
  		self.layout_net_unstable:setBackGroundColorOpacity(128)
		self.layout_net_unstable:setAnchorPoint(0, 0)
		self.layout_net_unstable:setTouchEnabled(true)

		local img_bg = XUI.CreateImageView(HandleRenderUnit:GetWidth() / 2, HandleRenderUnit:GetHeight() / 2, ResPath.GetBigPainting("re_connect_bg", false), false)
		self.layout_net_unstable:addChild(img_bg)

		local point_path = ResPath.GetCommon("orn_103")
		local point_bg = XUI.CreateImageView(178, 92, point_path)
		img_bg:addChild(point_bg)
		point_bg_t = {}
		for i = 1, 4 do
			point_bg_t[i] = XUI.CreateImageView(178 + i * 15, 92, point_path)
			img_bg:addChild(point_bg_t[i])
			point_bg_t[i]:setVisible(false)
		end

		HandleRenderUnit:AddUi(self.layout_net_unstable, COMMON_CONSTS.ZORDER_SYSTEM_HINT, COMMON_CONSTS.ZORDER_SYSTEM_HINT)
	end
	local delay_time = cc.DelayTime:create(1.1)
	local func = function()
		self.layout_net_unstable:removeFromParent()
		self.layout_net_unstable = nil
		point_bg_t = nil
		point_bg_vis_index = 0
	end
	local call_back = cc.CallFunc:create(func)
	local action = cc.Sequence:create(delay_time, call_back)
	self.layout_net_unstable:stopAllActions()
	self.layout_net_unstable:runAction(action)
	point_bg_vis_index = point_bg_vis_index + 1
	if point_bg_vis_index > 4 then
		for k,v in pairs(point_bg_t) do
			v:setVisible(false)
		end
		point_bg_vis_index = 0
	elseif point_bg_t[point_bg_vis_index] then
		point_bg_t[point_bg_vis_index]:setVisible(true)
	end
end

-- res/xui/master
--自定义图片与数字飘字
function SystemHint:FloatingRichText(num, icon, num_path, icon_path)
	local tips_width, tips_height = 738, 30
	
	local rich_text = XUI.CreateRichText(tips_width / 2, tips_height / 2, tips_width, tips_height, true)
	
	local tips_layout = XUI.CreateLayout(HandleRenderUnit:GetWidth()/2 , 230, tips_width, tips_height)
	tips_layout:addChild(rich_text)
	
	XUI.RichTextAddImage(rich_text, "res/xui/"..icon_path.."/"..icon..".png", true)
	if num < 0 then
		XUI.RichTextAddImage(rich_text, "res/xui/"..num_path.."/r_minus.png", true)
	end
	XUI.RichTextAddImage(rich_text, "res/xui/"..num_path.."/r_"..math.abs(num)..".png", true)
	
	HandleRenderUnit:AddUi(tips_layout, COMMON_CONSTS.ZORDER_SYSTEM_HINT, COMMON_CONSTS.ZORDER_SYSTEM_HINT)

	local move_by = cc.MoveBy:create(0.5, cc.p(0,64))	
	local delay_time = cc.DelayTime:create(1.5)
	local fade_out = cc.FadeOut:create(0.5)
	local func = function()
		tips_layout:setVisible(false)
	end
	local call_back = cc.CallFunc:create(func)
	local action = cc.Sequence:create(move_by, delay_time, fade_out, call_back)
	tips_layout:runAction(action)

	table.insert(self.layout_rich_quene, tips_layout)

	if #self.layout_rich_quene > 3 then
		self.layout_rich_quene[1]:removeFromParent(true)
		table.remove(self.layout_rich_quene, 1)
	end
	for i,v in ipairs(self.layout_rich_quene) do
		v:runAction(cc.MoveBy:create(0.5, cc.p(0,32)))
	end
end

-- 聊天窗口上部公告滚动效果 (文字, 优先级, 类型)
function SystemHint:AboveChatWindowRollingEffect(str, priority, msg_type)
	-- 如果队列中有数据在播放，那么先保存起来等播放完了再播放下一条
	if nil ~= str and "" ~= str then
		msg_type = msg_type or 0
		for i = 1, GUNDONGYOUXIAN.TRUNCATION + 1 do
			if nil == self.aboveChat_layout_str[i] or self.aboveChat_layout_str[i][2] > priority then
				table.insert(self.aboveChat_layout_str, i, {str, priority, msg_type})
				break
			end
		end

		if #self.aboveChat_layout_str > GUNDONGYOUXIAN.TRUNCATION then
			table.remove(self.aboveChat_layout_str, #self.aboveChat_layout_str)
		end
	end
	if self.is_loading_aboveChat or self.is_rolling_aboveChat or #self.aboveChat_layout_str <= 0 then
		return
	end

	local roll_str = self.aboveChat_layout_str[1][1]
	table.remove(self.aboveChat_layout_str, 1)

	local clipping_widths = 548

	if nil == self.aboveChat_roll_tips_layout then
		local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
		local tips_width, tips_height = 826, 42
		self.aboveChat_roll_tips_layout = XUI.CreateLayout(screen_w / 2, 250, tips_width, tips_height)
		HandleRenderUnit:AddUi(self.aboveChat_roll_tips_layout, COMMON_CONSTS.ZORDER_SYSTEM_HINT, COMMON_CONSTS.ZORDER_SYSTEM_HINT)

		local background = XUI.CreateImageViewScale9(tips_width / 2, tips_height / 2, 826, 42, ResPath.GetCommon("bg_112"), true)
		self.aboveChat_roll_tips_layout:addChild(background)

		local clipping_layout = XUI.CreateLayout(tips_width / 2, tips_height / 2, clipping_widths, tips_height, 2)
		clipping_layout:setClippingEnabled(true)
		self.aboveChat_roll_tips_layout:addChild(clipping_layout)

		self.aboveChat_roll_rich_text = XUI.CreateRichText(clipping_widths / 2, tips_height / 2, 0, tips_height, true)
		self.aboveChat_roll_rich_text:setVerticalAlignment(RichVAlignment.VA_CENTER)
		self.aboveChat_roll_rich_text:setIgnoreSize(true)
		clipping_layout:addChild(self.aboveChat_roll_rich_text)
	end

	RichTextUtil.ParseRichText(self.aboveChat_roll_rich_text, roll_str, 25, COLOR3B.YELLOW, nil, nil, nil, nil, true)
	self.aboveChat_roll_rich_text:refreshView()
	local size = self.aboveChat_roll_rich_text:getInnerContainerSize()
	self.aboveChat_roll_rich_text:setPositionX(clipping_widths)

	local move_length = clipping_widths + size.width
	local move_by = cc.MoveBy:create(move_length / 100, cc.p(-move_length, 0))
	local call_func = function()
		self.is_rolling_aboveChat = false
		if nil ~= self.aboveChat_layout_str[1] then
			self:AboveChatWindowRollingEffect()
		else
			self.aboveChat_roll_tips_layout:removeFromParent()
			self.aboveChat_roll_tips_layout = nil
			self.aboveChat_roll_rich_text = nil
		end
	end
	local call_back = cc.CallFunc:create(call_func)
	local action = cc.Sequence:create(move_by, call_back)
	self.is_rolling_aboveChat = true
	self.aboveChat_roll_rich_text:runAction(action)
end

function SystemHint:textEffect(imageName)
	-- boss盾开启同屏公告
	if nil ~= imageName then
		local hx, hy = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
		local text_img = XUI.CreateImageView(hx / 2 - 25, 216, ResPath.GetMainUiImg(imageName), true)
		-- HandleRenderUnit:AddUi(text_img, 0)
		text_img:setOpacity(0)
		text_img:setScale(4)

		local node_grid = cc.NodeGrid:create()
		HandleRenderUnit:AddUi(node_grid, 0)
		node_grid:addChild(text_img)

		local show_in_time = 0.7
		local spawn = cc.Spawn:create(cc.EaseExponentialIn:create(cc.ScaleTo:create(show_in_time, 1)), cc.FadeIn:create(show_in_time / 2))
		-- local call_func = cc.CallFunc:create(function() node_grid:runAction(cc.Shaky3D:create(3, cc.size(15, 10), 4, true)) end)
		local call_func = cc.CallFunc:create(function() CommonAction.ShowShakeAction(text_img) end)
		local sequence = cc.Sequence:create(spawn, call_func)
		text_img:runAction(sequence)

		GlobalTimerQuest:AddDelayTimer(
			function()
				local sequence = cc.Sequence:create(
					cc.FadeOut:create(0.8),
					cc.CallFunc:create(function()
						if nil ~= node_grid then
							node_grid:removeFromParent()
							node_grid = nil
						end
					end)
				)
				text_img:runAction(sequence)
			end,
			5
		)
	end
end