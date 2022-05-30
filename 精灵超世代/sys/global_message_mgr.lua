-- Created by IntelliJ IDEA.
-- User: lfl 1204825992@qq.com
-- Date: 2014/8/1
-- Time: 10:45
-- 文件功能：使用于全局的消息的显示
GlobalMessageMgr = GlobalMessageMgr or BaseClass(CommonUI)
--屏蔽提示
GlobalMessageMgr.is_hide_message = false
GlobalMessageMgr.Show_Global_Message = "Global_ShowMessage"
GlobalMessageMgr.Show_Type =
{
	fade_vertical = 1,  -- 竖直方向上的渐变
	fade_in_out = 2,    -- 不动的渐变
	move_horizontal = 3, -- 水平向左移动的
}
-- 默认参数
GlobalMessageMgr.Config =
{
	speed = 100,                                -- 速度
	delay = 1,                                  -- 显示时间
	max_num = 3,                                -- 最大显示数量
	max_width = 650,                            -- 文字宽度
	start_height = SCREEN_HEIGHT * 2 / 3,           -- 开始高度
	start_width = display.width / 2,               -- 开始宽度
}

-- 常驻提示的起始高度
GlobalMessageMgr.Permanent_Start_Height = SCREEN_HEIGHT * 2 / 3 + 150
-- 常驻提示移动高度
GlobalMessageMgr.Permanent_Move_Height = 90

function GlobalMessageMgr:__init()
	if GlobalMessageMgr.Instance ~= nil then
		error("[GlobalMessageMrg] accempt to create singleton twice!")
	end
	GlobalMessageMgr.Instance = self
	self.speed = GlobalMessageMgr.Config.speed --移动的速度
	self.delay = GlobalMessageMgr.Config.delay --默认消失时间
	self.per_msg_label = nil --上一个字符串
	self.msgs = Array.New()
	self.vertical_array = Array.New()
	self.vertical_array_tmp = {}
	self.item_effect_list = {}
end

function GlobalMessageMgr:getInstance()
	if GlobalMessageMgr.Instance == nil then
		GlobalMessageMgr.New()
	end
	return GlobalMessageMgr.Instance
end

--==============================--
--desc:竖直向上渐变小时的，最多同时显示3个
--time:2018-06-07 02:50:42
--@msg:
--@color:
--@return 
--==============================--
function GlobalMessageMgr:showMoveVertical(msg, color)
	local parent_wnd = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
	
	if self.vertical_array:GetSize() >= GlobalMessageMgr.Config.max_num then
		table.insert(self.vertical_array_tmp, {"showMoveVertical", {msg, color, delay}})
		if #self.vertical_array_tmp > 10 then
			table.remove(self.vertical_array_tmp, 1)
		end
		return
	end
	if string.len(msg) == 0 then return end
	
	--容器
	local container = ccui.Widget:create()
	container:setCascadeOpacityEnabled(true)
	container:setAnchorPoint(cc.p(0.5, 0))
	parent_wnd:addChild(container, 10)
	
	--背景
	local image = createScale9Sprite(PathTool.getResFrame("common", "common_90056"))
	image:setScale9Enabled(true)
	local image_height = 60
	container.image = image
	container:addChild(image)
	
	--文本
	local temp_msg = string.format("<div fontcolor=#ffda2f fontsize=24 >%s</div>", msg)
	local label = self:createhorizontalLabel(temp_msg, Config.ColorData.data_color3[1], GlobalMessageMgr.Config.max_width, 24)
	label:setAnchorPoint(0.5, 0.5)
	container:addChild(label)
	
	local label_size = label:getSize()
	local max_width = GlobalMessageMgr.Config.max_width
	local max_height = math.max(label_size.height + 28, image_height)
	local size = cc.size(max_width, max_height)
	local image_max_width = math.max(label_size.width + 50, 500)
	image:setContentSize(cc.size(image_max_width, max_height))
	container:setContentSize(size)
	image:setPosition(cc.p(size.width / 2, size.height / 2))
	label:setPosition(cc.p(size.width / 2, size.height / 2))
	
	--剔除当前的数据和ui
	local function deleteMessage()
		local temp_data = self.vertical_array:PopFront()
		local item = temp_data["item"]
		doRemoveFromParent(item)
		if #self.vertical_array_tmp > 0 then
			local data = table.remove(self.vertical_array_tmp, 1)
			if type(self[data[1]]) == "function" then
				self[data[1]](self, unpack(data[2]))
			end
		end
	end
	local delay = 2 --self.delay
	self.vertical_array:PushBack({msg = msg, delay_time = delay, item = container})
	self:sortPosition()
	delayRun(container.image, delay, function()
		deleteMessage()
	end)
end

-- 排列位置
function GlobalMessageMgr:sortPosition()
	local offset = 0 --偏移
	local max_height = 0 --最大的高度
	local size = self.vertical_array:GetSize()
	if size > 0 then
		local _y = GlobalMessageMgr.Config.start_height         -- 往上提一点
		local _x = SCREEN_WIDTH / 2
		local last_height = self.vertical_array:Get(size - 1).item:getContentSize().height
		local last_y
		for i = self.vertical_array:GetSize(), 1, - 1 do
			local data = self.vertical_array:Get(i - 1)
			local item = data.item
			if tolua.isnull(item) then return end
            doStopAllActions(item)
			if size == i then
				item:setPosition(cc.p(_x, _y))
				last_y = _y + item:getContentSize().height
			else
				item:setPosition(cc.p(_x, last_y))
				last_y = last_y + item:getContentSize().height
			end
			item.action = item:runAction(cc.MoveBy:create(0.5, cc.p(0, last_height)))
		end
	end
end

--==============================--
--desc:跑马灯
--time:2018-06-07 12:06:12
--@msg:
--@color:
--@return 
--==============================--
function GlobalMessageMgr:showMoveHorizontal(msg, color)
	local curr_scene = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
	if tolua.isnull(curr_scene) then return end
	local _y = display.getTop() - 55
	
	local size = cc.size(682, 38)
	if self.per_bg_icon == nil then
		self.per_bg_icon = createScale9Sprite(PathTool.getResFrame("common", "common_90056"))
		self.per_bg_icon:setScale9Enabled(true)
		self.per_bg_icon:setAnchorPoint(0.5, 1)
		self.per_bg_icon:setContentSize(size)
		curr_scene:addChild(self.per_bg_icon)
		self.per_bg_icon:setPosition(cc.p(SCREEN_WIDTH / 2, _y))
	end
	if self.msg_save_arr == nil then
		self.msg_save_arr = Array.New()
	end
	
	--创建文本
	local function createLabel(msg, color)
		msg = string.gsub(msg, "fontsize=%d+", "fontsize = 15")
		local temp_msg = self:createhorizontalLabel(msg, color, 3000, 20)
		temp_msg:setAnchorPoint(cc.p(0, 0.5))
		temp_msg:setPosition(cc.p(0, - size.height / 2))
		self.per_bg_icon:addChild(temp_msg)
		return temp_msg
	end
	
	-- 只存储5条传闻
	if self.msg_save_arr:GetSize() >= 5 then
		self.msg_save_arr:PopFront()
	end
	self.msg_save_arr:PushBack({msg = msg, delay_time = 3, color = color})

	-- 如果当前有滚动
	if self.has_msg_moveing == true then return end;
	
	local function deleteMsg()
		self.has_msg_moveing = false
		if not tolua.isnull(self.per_move_msg_word) then
			doRemoveFromParent(self.per_move_msg_word)
			self.per_move_msg_word = nil
		end
		if self.msg_save_arr:GetSize() > 0 then
			self.has_msg_moveing = true
			local temp_tab = self.msg_save_arr:PopFront()
			local msg_word = createLabel(temp_tab.msg, temp_tab.color)
			local show_time = temp_tab.delay_time or 3
			self.per_move_msg_word = msg_word

			local sequence_1 = nil
			local font_size = msg_word:getSize()
			if font_size.width > size.width then
				msg_word:setPositionX(0)
				local move_to_ = cc.MoveTo:create(0.1, cc.p(msg_word:getPositionX(), size.height / 2))
				local move_to = cc.MoveTo:create(show_time, cc.p(size.width - font_size.width - 5, size.height / 2))
				local delay_time = cc.DelayTime:create(1)
				sequence_1 = cc.Sequence:create(move_to_, delay_time, move_to, delay_time, cc.CallFunc:create(deleteMsg))
			else
				msg_word:setPositionX(size.width / 2 - font_size.width / 2)
				local delay_time = cc.DelayTime:create(show_time)
				local move_to_ = cc.MoveTo:create(0.1, cc.p(msg_word:getPositionX(), size.height / 2))
				sequence_1 = cc.Sequence:create(move_to_, delay_time, cc.CallFunc:create(deleteMsg))
			end
			msg_word:runAction(sequence_1)
		else
			self.msg_save_arr = nil
			if self.per_bg_icon then
				doRemoveFromParent(self.per_bg_icon)
				self.per_bg_icon = nil
			end
		end
	end
	deleteMsg()
end

-- 显示一个常驻的提示，需要手动移除(战斗天平模式提示)
function GlobalMessageMgr:showPermanentMsg( is_show, msg )
	if is_show == true then
		if not self.permanentMsg then
			local parent_wnd = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)

			--容器
			self.permanentMsg = ccui.Widget:create()
			self.permanentMsg:setCascadeOpacityEnabled(true)
			self.permanentMsg:setAnchorPoint(cc.p(0.5, 0))
			self.permanentMsg:setPosition(cc.p(SCREEN_WIDTH / 2, GlobalMessageMgr.Permanent_Start_Height))
			self.permanentMsg:setOpacity(0)
			parent_wnd:addChild(self.permanentMsg, 10)
			
			--背景
			local image = createScale9Sprite(PathTool.getResFrame("common", "common_90056"))
			image:setScale9Enabled(true)
			image:setContentSize(cc.size(500, 60))
			self.permanentMsg.image = image
			self.permanentMsg:addChild(image)
			
			--文本
			local temp_msg = string.format("<div fontcolor=#ffda2f fontsize=24 >%s</div>", msg)
			local label = self:createhorizontalLabel(temp_msg, Config.ColorData.data_color3[1], GlobalMessageMgr.Config.max_width, 24)
			label:setAnchorPoint(0.5, 0.5)
			self.permanentMsg.label = label
			self.permanentMsg:addChild(label)
			
			local label_size = label:getSize()
			local max_width = GlobalMessageMgr.Config.max_width
			local max_height = math.max(label_size.height + 20, image:getContentSize().height)
			local size = cc.size(max_width, max_height)
			self.permanentMsg:setContentSize(size)
			image:setPosition(cc.p(size.width / 2, size.height / 2))
			label:setPosition(cc.p(size.width / 2, size.height / 2))
		end
		if self.permanentMsg and self.permanentMsg.label then
			self.permanentMsg:setOpacity(0)
			self.permanentMsg:stopAllActions()
			self.permanentMsg:setPosition(cc.p(SCREEN_WIDTH / 2, GlobalMessageMgr.Permanent_Start_Height))
			local move_by = cc.MoveBy:create(0.4, cc.p(0, GlobalMessageMgr.Permanent_Move_Height))
			local fade_in = cc.FadeIn:create(0.4)
			self.permanentMsg:runAction(cc.Spawn:create(move_by, fade_in))
			self.permanentMsg.label:setString(msg)
		end
	elseif self.permanentMsg then
		self.permanentMsg:stopAllActions()
		self.permanentMsg:removeAllChildren()
		self.permanentMsg:removeFromParent()
		self.permanentMsg = nil
	end
end

--show_type :1冒险背包 2:背包
function GlobalMessageMgr:ItemEffectMove(is_show, show_type)
	--容器
	local pos = AdventureController:getInstance():getBackBtnPos()
	local scale = 1
	local selfpos = cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
	if show_type == 2 then
		selfpos = cc.p(0, 0)
		pos = MainuiController:getInstance():getBackPackBtnPos()
		scale = - 1
	end
	if not pos then
		return
	end
	local function deleteItemEffect(show_type)
		if self.item_effect_list and next(self.item_effect_list or {}) ~= nil then
			if self.item_effect_list[show_type] then
				if self.item_effect_list[show_type].item_effect_2 then
					self.item_effect_list[show_type].item_effect_2:runAction(cc.RemoveSelf:create(true))
					self.item_effect_list[show_type].item_effect_2 = nil
				end
				doStopAllActions(self.item_effect_list[show_type])
				self.item_effect_list[show_type]:removeAllChildren()
				self.item_effect_list[show_type]:removeFromParent()
				self.item_effect_list[show_type] = nil
			end
		end
	end
	if pos and is_show == true then
		local p = {}
		p.x = selfpos.x - pos.x
		p.y = selfpos.y - pos.y
		local r = math.atan2(p.y, p.x) * 180 / math.pi
		if not self.first_effect then
			-- --父容器
			local parent_wnd = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
			if not tolua.isnull(parent_wnd) then
				self.first_effect = createEffectSpine(PathTool.getEffectRes(251), cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), cc.p(0.5, 0.5), false, PlayerAction.action)
				parent_wnd:addChild(self.first_effect)
				local function animationCompleteFunc()
					if self.first_effect then
						self.first_effect:runAction(cc.RemoveSelf:create(true))
						self.first_effect = nil
					end
				end
				self.first_effect:registerSpineEventHandler(animationCompleteFunc, sp.EventType.ANIMATION_COMPLETE)
			end
		end
		if not self.item_effect_list[show_type] then
			local item_effect_container = ccui.Layout:create()
			item_effect_container:setCascadeOpacityEnabled(true)
			item_effect_container:setAnchorPoint(cc.p(0.5, 0.5))
			item_effect_container:setPosition(cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2))
			--父容器
			local parent_wnd = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
			parent_wnd:addChild(item_effect_container)
			self.item_effect_list[show_type] = item_effect_container
			local action_name = "action2"
			if not tolua.isnull(self.item_effect_list[show_type]) then
				self.item_effect_list[show_type].item_effect_2 = createEffectSpine(PathTool.getEffectRes(252), cc.p(0, 0), cc.p(0.5, 0.5), false, PlayerAction.action_1)
				self.item_effect_list[show_type].item_effect_2:setRotation(r)
				self.item_effect_list[show_type]:addChild(self.item_effect_list[show_type].item_effect_2)
			end
		end
		
		if self.item_effect_list and next(self.item_effect_list or {}) ~= nil then
			if self.item_effect_list[show_type] then
				doStopAllActions(self.item_effect_list[show_type])
				self.item_effect_list[show_type]:setOpacity(255)
				local delay_time = cc.DelayTime:create(0.5)
				local action = cc.MoveTo:create(0.8, cc.p(pos.x, pos.y))
				self.item_effect_list[show_type]:runAction(
				cc.Sequence:create(
				action,
				cc.CallFunc:create(function()
					self.item_effect_list[show_type].item_effect_2:setToSetupPose()
					self.item_effect_list[show_type].item_effect_2:setAnimation(0, PlayerAction.action_2, false)
				end),
				cc.DelayTime:create(0.3),
				cc.CallFunc:create(
				function()
					deleteItemEffect(show_type)
				end
				)
				)
				)
			end
		end
	else
		deleteItemEffect(show_type)
	end
end

function GlobalMessageMgr:PowerMove(num, res, old_num, setting)
	local title_res = res or PathTool.getResFrame("common", "txt_cn_common_90002")
	local num = tonumber(num) or 0
	local old_num = tonumber(old_num) or 0
	local setting = setting or {}
	
	--容器
	local size = cc.size(700, 150)
	if not self.power_container then
		self.power_container = ccui.Widget:create()
		self.power_container:setCascadeOpacityEnabled(true)
		self.power_container:setContentSize(size)
		self.power_container:setAnchorPoint(cc.p(0.5, 0))
		self.power_container:setPosition(cc.p(SCREEN_WIDTH / 2, 920))
		--父容器
		local parent_wnd = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
		parent_wnd:addChild(self.power_container)
		
		local res = PathTool.getResFrame("mainui","mainui_1035")
		local power_bg = createSprite(res, size.width / 2, size.height / 2, self.power_container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
		power_bg:setScaleX(1.6)
			
		local res_offset_x =  setting.res_offset_x or 0
		local power_title = createSprite(title_res, 140 + res_offset_x, 80, self.power_container, cc.p(0, 0.5), LOADTEXT_TYPE_PLIST)
		
		self.power = CommonNum.new(23, self.power_container, 0, 0, cc.p(0, 0.5))
		self.power:setPosition(cc.p(310, 100))
		
		self.add_num = createLabel(50, cc.c4b(149, 244, 82, 255), cc.c4b(23, 65, 0, 255), 310, 50, "", self.power_container, 1, cc.p(0, 0))
		
		local effect_id = PathTool.getEffectRes(179)
		local light_effect = createEffectSpine(effect_id, cc.p(size.width / 2, size.height / 2), cc.p(0.5, 0.5), true, "action")
		self.power_container:addChild(light_effect)
		playOtherSound("c_levelup")
		local effect_id = PathTool.getEffectRes(171)
		local effect = createEffectSpine(effect_id, cc.p(size.width / 2, size.height / 2), cc.p(0.5, 0.5), false, "action", function()
			if effect then
				effect:runAction(cc.RemoveSelf:create(true))
				effect = nil
			end
		end)
		effect:setLocalZOrder(10)
		self.power_container:addChild(effect)
	end
	-- 先暂停掉动作
	doStopAllActions(self.power_container)
	if tolua.isnull(self.add_num) then return end
	self:clearPowerTimer()
	
	local count = 0
	local count_num = old_num
	while count_num > 0 do
		count = count + 1
		count_num = math.floor(count_num / 10)
	end
	if count == 0 then
		count = 1
	end
	self.power:setNum(old_num)
	self.add_num:setPositionX(count * 26 + 315)
	local add_count = 0
	if not self.num_timer then
		self.num_timer = GlobalTimeTicket:getInstance():add(function()
			add_count = add_count + 1
			local temp_num = math.ceil(add_count *(num / 10))
			local max_num = math.min(temp_num, num)
			self.add_num:setString("+" .. max_num)
			if temp_num >= num then
				self:clearPowerTimer()
			end
		end, 0.05, 10)
	end
	
	--剔除当前的数据和ui
	local function deletePower()
		self:clearPowerTimer()
		if self.power and not tolua.isnull(self.power) then
			self.power:DeleteMe()
			self.power = nil
		end
		if self.power_container and not tolua.isnull(self.power_container) then
			self.power_container:removeAllChildren()
			self.power_container:removeFromParent()
			self.power_container = nil
		end
	end
	
	self.power_container:setOpacity(255)
	local delay_time = cc.DelayTime:create(1)
	local action = cc.FadeOut:create(1)
	self.power_container:runAction(cc.Sequence:create(delay_time, action, cc.CallFunc:create(function()
		deletePower()
	end)))
end

--res 为传入的是艺术字资源，例如 战斗力
function GlobalMessageMgr:showPowerMove(num, res, old_num, setting)
	local showNum = changeBtValueForPower(num)
	local showOldNum = changeBtValueForPower(old_num)
	self:PowerMove(showNum, res, showOldNum, setting)
end

--res 为传入的是艺术字资源，例如 属性提升
function GlobalMessageMgr:showArtTextMove(res, offset_y)
	if not res then return end
	local title_res = res
	offset_y = offset_y or 0
	--容器
	local size = cc.size(700, 150)
	if not self.arttxt_container then
		self.arttxt_container = ccui.Widget:create()
		self.arttxt_container:setCascadeOpacityEnabled(true)
		self.arttxt_container:setContentSize(size)
		self.arttxt_container:setAnchorPoint(cc.p(0.5, 0))
		self.arttxt_container:setPosition(cc.p(SCREEN_WIDTH / 2, 920+offset_y))
		--父容器
		local parent_wnd = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
		parent_wnd:addChild(self.arttxt_container)
		
		local res = PathTool.getResFrame("mainui","mainui_1035")
		local power_bg = createSprite(res, size.width / 2, size.height / 2, self.arttxt_container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
		power_bg:setScaleX(1.6)
		
		local power_title = createSprite(title_res, size.width / 2, 80, self.arttxt_container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
		
		local effect_id = PathTool.getEffectRes(179)
		local light_effect = createEffectSpine(effect_id, cc.p(size.width / 2, size.height / 2), cc.p(0.5, 0.5), true, "action")
		self.arttxt_container:addChild(light_effect)
		playOtherSound("c_levelup")
		local effect_id = PathTool.getEffectRes(171)
		local effect = createEffectSpine(effect_id, cc.p(size.width / 2, size.height / 2), cc.p(0.5, 0.5), false, "action", function()
			if effect then
				effect:runAction(cc.RemoveSelf:create(true))
				effect = nil
			end
		end)
		effect:setLocalZOrder(10)
		self.arttxt_container:addChild(effect)
	end
	-- 先暂停掉动作
	doStopAllActions(self.arttxt_container)
	
	--剔除当前的数据和ui
	local function deleteArtText()
		if self.arttxt_container and not tolua.isnull(self.arttxt_container) then
			self.arttxt_container:removeAllChildren()
			self.arttxt_container:removeFromParent()
			self.arttxt_container = nil
		end
	end
	
	self.arttxt_container:setOpacity(255)
	local delay_time = cc.DelayTime:create(1)
	local action = cc.FadeOut:create(1)
	self.arttxt_container:runAction(cc.Sequence:create(delay_time, action, cc.CallFunc:create(function()
		deleteArtText()
	end)))
end

function GlobalMessageMgr:clearPowerTimer()
	if self.num_timer then
		GlobalTimeTicket:getInstance():remove(self.num_timer)
		self.num_timer = nil
	end
end

--属性列表
function GlobalMessageMgr:showAttrMove(attr_list)
	local title_res = res or PathTool.getResFrame("common", "txt_cn_common_90002")
	local num = tonumber(num) or 0
	local old_num = tonumber(old_num) or 0
	--容器
	local size = cc.size(700, 150)
	if not self.attr_container then
		
		self.attr_container = ccui.Widget:create()
		self.attr_container:setCascadeOpacityEnabled(true)
		self.attr_container:setContentSize(size)
		self.attr_container:setAnchorPoint(cc.p(0.5, 0))
		self.attr_container:setPosition(cc.p(SCREEN_WIDTH / 2, 800))
		--父容器
		local parent_wnd = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
		parent_wnd:addChild(self.attr_container)
		
		local res = PathTool.getResFrame("mainui","mainui_1035")
		local power_bg = createSprite(res, size.width / 2, size.height / 2, self.attr_container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
		power_bg:setScaleX(1.6)
		power_bg:setScaleY(2)
	end
	
	if not self.attr_list then
		self.attr_list = {}
	end
	attr_list = attr_list or {}
	for i, v in pairs(attr_list) do
		if not self.attr_list[i] then
			self.attr_list[i] = {}
			local name = createLabel(24, cc.c4b(149, 244, 82, 255), cc.c4b(23, 65, 0, 255), 310, 50, "", self.attr_container, 2, cc.p(0, 0))
			local label = createLabel(26, cc.c4b(149, 244, 82, 255), cc.c4b(23, 65, 0, 255), 310, 50, "", self.attr_container, 2, cc.p(0, 0))
			self.attr_list[i].name = name
			self.attr_list[i].label = label
		end
	end
	
	--剔除当前的数据和ui
	local function deleteAttr()
		if self.attr_container and not tolua.isnull(self.attr_container) then
			self.attr_container:removeAllChildren()
			self.attr_container:removeFromParent()
			self.attr_container = nil
			self.attr_list = {}
		end
	end
	self.attr_container:stopAllActions()
	local delay_time = cc.DelayTime:create(1)
	local action = cc.FadeOut:create(1)
	self.attr_container:runAction(cc.Sequence:create(delay_time, action, cc.CallFunc:create(function()
		if self.num_load then
			self.num_load:DeleteMe()
			self.num_load = nil
		end
		deleteAttr()
	end)))
end



--创建水平方向移动的文本
function GlobalMessageMgr:createhorizontalLabel(msg, color, max_width, fontsize)
	local fontcolor = color or Config.ColorData.data_color3[2]
	local label = createRichLabel(fontsize, fontcolor, cc.p(0, 1), cc.p(0, 0), 0, 0, max_width)
	label:setString(msg)
	return label
end

function GlobalMessageMgr:__delete()
	-- if self.event ~= nil then
	--     GlobalEvent:getInstance():UnBind(self.event)
	--     self.event = nil
	-- end
	GlobalMessageMgr.Instance = nil
end

--全局 message 提示方法
function message(msg, show_type, quality, color, delay)
	if msg == nil or msg == "" then return end
	if StoryController:getInstance():getModel():isStoryState() then return end
	if color == nil then
		color = Config.ColorData.data_color3[1]
	end
	GlobalMessageMgr:getInstance():showMoveVertical(msg, color)
end

--富文本提示
function showRichMsg(msg, color, delay)
	if GlobalMessageMgr:getInstance():isHideMessage() then return end
	if StoryController:getInstance():getModel():isStoryState() then return end
	GlobalMessageMgr:getInstance():showMoveVertical(msg, color)
end

--资产提示
function showAssetsMsg(msg, color, delay, add_notice)
	if GlobalMessageMgr:getInstance():isHideMessage() then return end
	if StoryController:getInstance():getModel():isStoryState() then return end
	local msg = WordCensor:getInstance():relapceAssetsTag(msg)
	-- 聊天系统频道中所有的资产消耗的提示，都走12761协议
	--[[if add_notice then
		ChatController:getInstance():pushAssetsMsg(string.gsub(msg, "fontsize=17", ""))
	end--]]
	GlobalMessageMgr:getInstance():showMoveVertical(msg, color)
end

--泡泡的提示方法
function message2(msg, color)
	if GlobalMessageMgr:getInstance():isHideMessage() then return end
	if StoryController:getInstance():getModel():isStoryState() then return end
	if color == nil then
		color = Config.ColorData.data_color3[1]
	end
	GlobalMessageMgr:getInstance():showMoveVertical(msg, color)
end

--水平的提示
function showHorizontalMsg(msg, quality, color, delay)
	GlobalMessageMgr:getInstance():showMoveHorizontal(msg, color)
end

function GlobalMessageMgr:isHideMessage()
	return self.is_hide_message
end

function GlobalMessageMgr:setHideMessage(bool)
	self.is_hide_message = bool
end
