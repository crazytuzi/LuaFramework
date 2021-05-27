UiInstanceMgr = UiInstanceMgr or BaseClass()

function UiInstanceMgr:__init()
	if UiInstanceMgr.Instance then
		ErrorLog("[UiInstanceMgr] Attempt to create singleton twice!")
		return
	end
	UiInstanceMgr.Instance = self
	
	self.coutdown_view_list = {}
	
	self.quick_buy_view = QuickBuy.New(ViewDef.QuickBuy)
	self.quick_buy_tip = QuickTips.New(ViewDef.QuickTip)
	self.buy_tip_view = BuyTip.New(ViewDef.BuyTip)
	self.buy_tip_new = NewBuyTip.New(ViewDef.NewBuyTip)
end

function UiInstanceMgr:__delete()
	UiInstanceMgr.Instance = nil
	
	if self.custom_menu then
		self.custom_menu:DeleteMe()
		self.custom_menu = nil
	end
	
	if self.quick_buy_view then
		self.quick_buy_view:DeleteMe()
		self.quick_buy_view = nil
	end
	
	if self.buy_tip_new then
		self.buy_tip_new:DeleteMe()
		self.buy_tip_new = nil
	end

	if self.buy_tip_view then
		self.buy_tip_view:DeleteMe()
		self.buy_tip_view = nil
	end

	if self.quick_buy_tip then
		self.quick_buy_tip:DeleteMe()
		self.quick_buy_tip = nil
	end
	
	if self.reward_bar then
		self.reward_bar:DeleteMe()
		self.reward_bar = nil
	end
	
	if self.coutdown_view_list then
		for k, v in pairs(self.coutdown_view_list) do
			self:DelOneCountDownView(k)
		end
		self.coutdown_view_list = nil
	end
end

-- 打开进度条
function UiInstanceMgr:OpenRewardBar(time, show_func, zorder)
	time = time or 0
	if nil == self.reward_bar then
		self.reward_bar = RewardBar.New()
	end
	
	self.reward_bar.zorder = zorder or - 10
	self.reward_bar:Open()
	self.reward_bar:SetGatherTime(time)
	self.reward_bar:SetShowCallback(show_func)
end

-- 关闭进度条
function UiInstanceMgr:CloseRewardBar()
	if self.reward_bar then
		self.reward_bar:Close()
	end
end

-- 打开通用菜单
function UiInstanceMgr:OpenCustomMenu(items, param, point, close_callback)
	if IS_ON_CROSSSERVER then
		-- 跨服处理
		items = {
			{menu_index = 0},
			{menu_index = 5},
			{menu_index = 6},
		}
	end
	
	if type(items) ~= "table" or #items < 1 then return end
	
	if nil == self.custom_menu then
		self.custom_menu = CustomMenu.New(ViewName.CustomMenu)
	end
	self.custom_menu:Open()
	self.custom_menu:SetPosition(point)
	self.custom_menu:SetParam(param)
	self.custom_menu:BindCloseCallBack(close_callback)
	self.custom_menu:Flush(0, nil, items)
end

function UiInstanceMgr:ShowEffectAnim(effid, scale)
	if nil == self.effect_anim then
		self.effect_anim = AnimateSprite:create()
		self.effect_anim:setPosition(HandleRenderUnit:GetWidth() / 2, HandleRenderUnit:GetHeight() / 2)
		HandleRenderUnit:AddUi(self.effect_anim, MAX_VIEW_ZORDER, 0)
	end
	
	local anim_path, anim_name = ResPath.GetEffectAnimPath(effid)
	self.effect_anim:setAnimate(anim_path, anim_name, 1, 0.15, false)
	self.effect_anim:setScale(scale)
end

--[[
-- 在场景中生成一个倒计时
-- 背景
local bg = XUI.CreateImageView(0, 0, ResPath.GetScene("fb_bg_101"), true)
local bg_size = bg:getContentSize()
bg:setPosition(bg_size.width * 0.5, bg_size.height * 0.5)

-- 文字
local word = XUI.CreateImageView(bg_size.width * 0.5, bg_size.height * 0.5, ResPath.GetScene("zyz_fuhuo_word"), true)

-- 图片数字节点
local rich_num = CommonDataManager.CreateLabelAtlasImage(0)
rich_num:setPosition(bg_size.width * 0.5 - 130, bg_size.height * 0.5)

local layout_t = {x = HandleRenderUnit:GetWidth() * 0.5, y = HandleRenderUnit:GetHeight() * 0.5, anchor_point = cc.p(0.5, 0.5), content_size = bg_size}
local num_t = {num_node = rich_num, num_type = "zdl_y_", folder_name = "scene"}
local img_t = {bg, word}

UiInstanceMgr.Instance:CreateOneCountdownView(5, layout_t, num_t, img_t)
--]]
function UiInstanceMgr:CreateOneCountdownView(seconds, layout_t, num_t, img_t, count_down_callback)
	layout_t = layout_t or {}
	layout_t.x = layout_t.x or 0
	layout_t.y = layout_t.y or 0
	layout_t.content_size = layout_t.content_size or {width = 0, height = 0}
	layout_t.anchor_point = layout_t.anchor_point or cc.p(0.5, 0.5)
	
	num_t = num_t or {}
	num_t.num_node = num_t.num_node or CommonDataManager.CreateLabelAtlasImage(0)
	num_t.num_type = num_t.num_type or "zdl_y_"
	num_t.folder_name = num_t.folder_name or "scene"
	
	local content_layout = XUI.CreateLayout(layout_t.x, layout_t.y, layout_t.content_size.width, layout_t.content_size.height)
	content_layout:setAnchorPoint(layout_t.anchor_point)
	HandleRenderUnit:AddUi(content_layout, COMMON_CONSTS.ZORDER_FB_PANEL, COMMON_CONSTS.ZORDER_FB_PANEL)
	
	for k, v in ipairs(img_t or {}) do
		content_layout:addChild(v, - 1)
	end
	
	content_layout:addChild(num_t.num_node, 99)
	content_layout:setVisible(true)
	
	local view_info = {layout = content_layout, num_t = num_t, cd_key = nil}
	self.coutdown_view_list[view_info] = view_info

	local count_down_func = function(elapse_time, total_time)
		local num = total_time - math.floor(elapse_time)
		
		if count_down_callback then
			count_down_callback(elapse_time, total_time)
		end
		
		if num > 0 then
			CommonDataManager.SetUiLabelAtlasImage(num, num_t.num_node, num_t.num_type, num_t.folder_name)
		else
			content_layout:setVisible(false)
			self:DelOneCountDownView(view_info)
		end
	end
		
	if seconds > 0 then
		view_info.cd_key = CountDown.Instance:AddCountDown(seconds, 1, count_down_func)
		count_down_func(0, seconds)
	end

	return view_info
end

--倒计时
--@hbf
function UiInstanceMgr:AddTimeLeaveView(seconds, count_down_callback, text_name)
	if seconds <= 0 then return end
	if nil == count_down_callback then error("need params(func): @count_down_callback") end

	---- UI创建
	--layout图层 @用于控制倒计时显隐和位置
	local content_layout = XUI.CreateLayout(HandleRenderUnit:GetWidth() - 100, HandleRenderUnit:GetHeight() - 85, 0, 0)
	HandleRenderUnit:AddUi(content_layout, COMMON_CONSTS.ZORDER_FB_PANEL, COMMON_CONSTS.ZORDER_FB_PANEL)
	content_layout:setVisible(true)
	-- 文字
	local word = XUI.CreateImageView(-600, -80, ResPath.GetScene(text_name), true)
	content_layout:addChild(word, - 1)
	-- 背景
	local bg = XUI.CreateImageView(-600, -80, ResPath.GetScene("fb_bg_101"), true)
	local bg_size = bg:getContentSize()
	content_layout:addChild(bg, - 2)
	-- 图片数字
	local num_t = CommonDataManager.CreateLabelAtlasImage(0)
	num_t:setPosition(-640, -80)
	content_layout:addChild(num_t, 99)


	----添加外部调用方法
	local view = {}
	--控制显隐
	function view:SetLayoutVisible(is_visible)
		content_layout:setVisible(is_visible)
	end

	--设置资源
	function view:SetRes(tag)
	end

	function view:SetContentLayout(content_layout)
		self.content_layout = content_layout
	end

	--停止倒计时
	function view:StopTimeDowner()
		if self.content_layout then
			CountDown.Instance:RemoveCountDown(self.content_layout.key)
			self.content_layout:removeFromParent()
			self.content_layout = nil
		end
	end

	----倒计时
	--刷新视图
	local function count_down_func(elapse_time, total_time)
		local num = total_time - math.floor(elapse_time)
		--倒计时为0 自动停止
		if num <= 0 then 
			view:StopTimeDowner()
		else
			CommonDataManager.SetUiLabelAtlasImage(num, num_t, "zdl_y_", "scene")
			count_down_callback(elapse_time, total_time, view)
		end
	end

	--添加
	content_layout.key = CountDown.Instance:AddCountDown(seconds, 1, count_down_func)
	count_down_func(0, seconds)
	view:SetContentLayout(content_layout)

	return view
end

function UiInstanceMgr:DelOneCountDownView(key)
	if self.coutdown_view_list[key] then
		CountDown.Instance:RemoveCountDown(key)
		self.coutdown_view_list[key].layout:removeFromParent()
		self.coutdown_view_list[key] = nil
	end
end

function UiInstanceMgr.AddCircleEffect(node, time, init_size_scale, act_size_scale, effect_path, offset_x, offset_y)
	if node == nil then
		return
	end
	
	effect_path = effect_path or ResPath.GetSkillIcon("common_exterior_effect")
	time = time or 0.4
	
	if node.circle_effect == nil then
		local size = node:getContentSize()
		local x, y = size.width * 0.5, size.height * 0.5
		offset_x = offset_x or 0
		offset_y = offset_y or 0
		local effect = XUI.CreateImageView(x + offset_x, y + offset_y, effect_path, true)
		init_size_scale = init_size_scale or((size.width + 1) / effect:getContentSize().width)
		effect:setScale(init_size_scale)
		node:addChild(effect, 99)
		
		act_size_scale = act_size_scale or(init_size_scale * 2)
		local scale_to = cc.ScaleTo:create(time, act_size_scale)
		local fade_out = cc.FadeOut:create(time)
		local action_complete_callback = function()
			effect:setScale(init_size_scale)
			effect:setOpacity(255)
		end
		local action = cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(scale_to, fade_out), cc.CallFunc:create(action_complete_callback)))
		effect:runAction(action)
		
		node.circle_effect = effect
	end
end

function UiInstanceMgr.DelCircleEffect(node)
	if node == nil then
		return
	end
	
	if node.circle_effect ~= nil then
		node.circle_effect:removeFromParent()
		node.circle_effect = nil
	end
end

function UiInstanceMgr.AddRectEffect(t)
	local node = t.node
	if node == nil then
		return
	end
	
	local init_size_scale = t.init_size_scale or 1
	local act_size_scale = t.act_size_scale or(init_size_scale * 1.5)
	local offset_x = t.offset_x or 0
	local offset_y = t.offset_y or 0
	local offset_w = t.offset_w or 0
	local offset_h = t.offset_h or 0
	local color = t.color
	local res_path = t.res_path or ResPath.GetCommon("img9_109")
	local time = t.time or 0.4
	
	if node.rect_effect == nil then
		local size = node:getContentSize()
		local x, y = size.width * 0.5, size.height * 0.5
		
		local effect = XUI.CreateImageViewScale9(x + offset_x, y + offset_y, size.width + offset_w, size.height + offset_h, res_path, true)
		effect:setScale(init_size_scale)
		if color ~= nil then
			effect:setColor(color)
		end
		node:addChild(effect, 99)
		
		local scale_to = cc.ScaleTo:create(time, act_size_scale)
		local fade_out = cc.FadeOut:create(time)
		local action_complete_callback = function()
			effect:setScale(init_size_scale)
			effect:setOpacity(255)
		end
		local action = cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(scale_to, fade_out), cc.CallFunc:create(action_complete_callback)))
		effect:runAction(action)
		
		node.rect_effect = effect
	end
end

function UiInstanceMgr.DelRectEffect(node)
	if node == nil then
		return
	end
	
	if node.rect_effect ~= nil then
		node.rect_effect:removeFromParent()
		node.rect_effect = nil
	end
end

function UiInstanceMgr:OpenTaskHelp()
	local data = {
		{stuff_way = Language.Task.TaskHelp[1], open_view = ViewName.RefiningExp},                                                    --经验炼制
		{stuff_way = Language.Task.TaskHelp[2], go_to = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(83), task_id = 4000},      --降妖除魔
		{stuff_way = Language.Task.TaskHelp[3], go_to = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(79), task_id = 4001},      --封魔塔防
		{stuff_way = Language.Task.TaskHelp[4], go_to = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(90)},                      --休闲挂机
		{stuff_way = Language.Task.TaskHelp[5], open_view = ViewName.ChargeFirst},                                                   --首冲大礼包
		{stuff_way = Language.Task.TaskHelp[6], open_view = ViewName.Explore},
	}
	local task_help_list = {}
	for i, v in ipairs(data) do
		if v.open_view then
			if ViewManager.Instance:CanShowUi(v.open_view) then
				if v.remind == nil or RemindManager.Instance:GetRemind(v.remind) > 0 then
					task_help_list[#task_help_list + 1] = v
				end
			end
		elseif v.task_id then
			if TaskData.Instance:GetTaskInfo(v.task_id) then
				local count_t = TaskData.Instance:GetTaskDoCount(v.task_id)
				if count_t == nil or(type(count_t) == "table" and count_t.now_count and count_t.max_count and count_t.now_count < count_t.max_count) then
					task_help_list[#task_help_list + 1] = v
				end
			end
		else
			task_help_list[#task_help_list + 1] = v
		end
	end
	TipCtrl.Instance:OpenStuffTip(Language.Task.TaskHelpTitle, task_help_list)
end

function UiInstanceMgr:CreateDierrfreshcdView(x, y, width, height, parent, zorder)
	local text = RichTextUtil.ParseRichText(nil, "", 19, COLOR3B.ORANGE, x, y, width, height)
	-- XUI.RichTextSetCenter(text)
	if parent then
		parent:addChild(text, zorder or 1)
	end
	local cd_timer
	local function UpdateText()
		GlobalTimerQuest:CancelQuest(cd_timer)
		local attr_value = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_DIERRFRESHCD)
		local cd_time = attr_value - TimeCtrl.Instance:GetServerTime()
		if cd_time > 0 then
			if cd_time < 86400 then
				local content = Language.Common.Dierrfreshcd .. TimeUtil.FormatSecond(cd_time, 2)
				RichTextUtil.ParseRichText(text, content, 19, COLOR3B.ORANGE, nil, nil, nil, nil, nil, {outline_size = 1})
				text:setVisible(true)
			else
				text:setVisible(false)
			end
			
			cd_timer = GlobalTimerQuest:AddDelayTimer(UpdateText, 1)
		else
			text:setVisible(false)
		end
	end
	
	local function OnAttrChange(key)
		if key == OBJ_ATTR.ACTOR_DIERRFRESHCD then
			local attr_value = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_DIERRFRESHCD)
			UpdateText()
		end
	end
	local main_role_info_h
	main_role_info_h = GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, function()
		GlobalEventSystem:UnBind(main_role_info_h)
		UpdateText()
	end)
	
	RoleData.Instance:NotifyAttrChange(OnAttrChange)
	
	UpdateText()
	return {
		node = text,
	}
end

-- 创建一个战斗力ui
function UiInstanceMgr:CreateZhanDouLiUi(x, y, width, height, parent, zorder)
	local view = XUI.CreateLayout(x, y, width, height)
	if nil ~= parent then
		parent:addChild(view, zorder, zorder)
	end
	
	local bg_img = XUI.CreateImageView(width / 2, height / 2, ResPath.GetBigPainting("role_cap_bg", true))
	local bg_img_size = bg_img:getContentSize()
	view:addChild(bg_img, 1)
	
	local content_scale_x = width / bg_img_size.width
	local content_scale_y = height / bg_img_size.height
	bg_img:setScaleX(content_scale_x)
	bg_img:setScaleY(content_scale_y)
	
	local word_zhanli = XUI.CreateImageView(62, height * 2 / 3, ResPath.GetMainui("word_zhanli"))
	view:addChild(word_zhanli, 60)
	
	local img_frame = XUI.CreateImageViewScale9(width / 2, height / 2, width, height, ResPath.GetCommon("img9_141"), true)
	view:addChild(img_frame, 40)
	
	local fire_effect = AnimateSprite:create()
	fire_effect:setPosition(width / 2 + 10, height / 2)
	view:addChild(fire_effect, 30)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(988)
	fire_effect:setAnimate(anim_path, anim_name, 999999, FrameTime.Effect, false)
	-- 火焰自适应背景大小
	fire_effect:setScaleX(content_scale_x * 1.2)
	fire_effect:setScaleY(content_scale_y * 0.9)
	
	local number_bar = NumberBar.New()
	number_bar:Create(width * 1 / 3, height * 1 / 10, 1, 40, ResPath.GetMainui("num_"))
	number_bar:SetSpace(- 2)
	view:addChild(number_bar:GetView(), 50)
	view:registerScriptHandler(function(event_text)
		if "cleanup" == event_text then
			number_bar:DeleteMe()
			number_bar = nil
		end
	end)
	
	local ui_obj = {
		view = view,
		bg_img = bg_img,
		word_zhanli = word_zhanli,
		img_frame = img_frame,
		fire_effect = fire_effect,
		number_bar = number_bar,
		
		GetView = function(obj)
			return obj.view
		end,
		SetNumber = function(obj, ...)
			obj.number_bar:SetNumber(...)
		end,
	}
	
	return ui_obj
end

-- 生成一排星星ui对象
-- @param_t 结构如 {x=100, y=100, star_num=10, interval_x=5, parent=cc.node, zorder=1}
-- SetStarActNum:设置星星激活数量
function UiInstanceMgr:CreateStarsUi(param_t)
	local x, y = param_t.x or 0, param_t.y or 0
	local zorder = param_t.zorder or 10
	local parent = param_t.parent
	local interval_x = param_t.interval_x or 20
	local star_num = param_t.star_num or 5
	local margin = 10
	local star_size = cc.size(30, 30)
	local width, height = margin * 2 + star_size.width * star_num + interval_x *(star_num - 1), star_size.height
	
	local view = XUI.CreateLayout(x, y, width, height)
	if nil ~= parent then
		parent:addChild(view, zorder, zorder)
	end
	
	local gray_star_list = {}
	local star_effect_list = {}
	local star_y = height / 2
	for i = 1, star_num do
		local start_x = margin + star_size.width / 2 +(i - 1) *(star_size.width + interval_x)
		local img_star = XUI.CreateImageView(start_x, star_y, ResPath.GetCommon("star_1_lock"), true)
		view:addChild(img_star)
		gray_star_list[i] = img_star
		
		local star_effect = RenderUnit.CreateEffect(911, view, nil, nil, nil, start_x, star_y + 0.5)
		star_effect:setScale(1.15)
		star_effect:setVisible(false)
		star_effect_list[i] = star_effect
	end
	
	local ui_obj = {
		view = view,
		star_num = star_num,
		gray_star_list = gray_star_list,
		star_effect_list = star_effect_list,
		
		GetView = function(obj)
			return obj.view
		end,
		SetStarActNum = function(obj, num)
			local index = 1
			while obj.gray_star_list[index] do
				local gray_star = obj.gray_star_list[index]
				local star_eff = obj.star_effect_list[index]
				local is_act = index <= num
				gray_star:setVisible(not is_act)
				star_eff:setVisible(is_act)
				index = index + 1
			end
		end,
	}
	
	return ui_obj
end

-- 显示引导指针
function UiInstanceMgr:ShowGuideArrow(node, param_t)
	if nil == node then
		return
	end

	if param_t.is_remove then
		if node.arrow_root then
			node.arrow_root:removeFromParent()
			node.arrow_root = nil
		end
		return
	end

	-- 参数
	local arrow_dir = param_t.dir or "down"
	local title_txt = param_t.word or ""
	local root_zorder = param_t.root_zorder or 1
	local root_x = param_t.root_x or 0
	local root_y = param_t.root_y or 0

	local arrow_root = node.arrow_root
	if nil == arrow_root then
		arrow_root = cc.Node:create()
		node.arrow_root = arrow_root
		node:addChild(arrow_root, root_zorder, root_zorder)
		local arrow_node = cc.Node:create()
		arrow_root:addChild(arrow_node, 1, 1)
		local arrow_frame = XButton:create(ResPath.GetGuide("arrow_frame"), "", "")
		arrow_frame:setTitleFontSize(25)
		arrow_frame:setTouchEnabled(false)
		arrow_node:addChild(arrow_frame, 1, 1)
		arrow_frame:setTitleFontName(COMMON_CONSTS.FONT)
		local label = arrow_frame:getTitleLabel()
		if label then
			label:setColor(COLOR3B.G_Y)
			label:enableOutline(cc.c4b(0, 0, 0, 100), 1.5)
		end
		local arrow_point = XUI.CreateImageView(0, 0, ResPath.GetGuide("arrow_point"))
		arrow_point:setAnchorPoint(1, 0.5)
		arrow_node:addChild(arrow_point, 2, 2)
	end

	local offset_x = 37
	local rotation, anc_x, anc_y, x, y = -90, 0.5, 1, 0, -offset_x
	local move1, move2 = nil, nil
	if arrow_dir == "up" then
		rotation, anc_x, anc_y, x, y = -90, 0.5, 1, 0, -offset_x
		move1 = cc.MoveTo:create(0.5, cc.p(0, -10))
		move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
	elseif arrow_dir == "down" then
		rotation, anc_x, anc_y, x, y = 90, 0.5, 0, 0, offset_x
		move1 = cc.MoveTo:create(0.5, cc.p(0, 10))
		move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
	elseif arrow_dir == "left" then
		rotation, anc_x, anc_y, x, y = 180, 0, 0.5, offset_x, 0
		move1 = cc.MoveTo:create(0.5, cc.p(10, 0))
		move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
	else
		rotation, anc_x, anc_y, x, y = 0, 1, 0.5, -offset_x, 0
		move1 = cc.MoveTo:create(0.5, cc.p(-10, 0))
		move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
	end

	arrow_root:setPosition(root_x, root_y)
	local arrow_node = arrow_root:getChildByTag(1)
	local arrow_frame = arrow_node:getChildByTag(1)
	local arrow_point = arrow_node:getChildByTag(2)

	arrow_point:setRotation(rotation)
	arrow_frame:setAnchorPoint(anc_x, anc_y)
	arrow_frame:setPosition(x, y)
	arrow_frame:setTitleText(title_txt)
	local action = cc.RepeatForever:create(cc.Sequence:create(move1, move2))
	arrow_node:stopAllActions()
	arrow_node:runAction(action)
end

-- 显示引导光圈
function UiInstanceMgr:ShowGuideLightCircle(node, param_t)
	if nil == node then
		return
	end

	if param_t.is_remove then
		if node.guide_light_circle then
			node.guide_light_circle:removeFromParent()
			node.guide_light_circle = nil
		end
		return
	end

	-- 参数
	local root_zorder = param_t.root_zorder or 1
	local x = param_t.root_x or 0
	local y = param_t.root_y or 0

	local guide_light_circle = node.guide_light_circle
	if nil == guide_light_circle then
		guide_light_circle = XUI.CreateImageView(x, y, ResPath.GetCommon("common_exterior_effect"))
		node:addChild(guide_light_circle, root_zorder, root_zorder)
		node.guide_light_circle = guide_light_circle

		local scale_to = cc.ScaleTo:create(0.4, 0.5)
		local fade_out = cc.FadeOut:create(0.3)
		local init_func = cc.CallFunc:create(function() 
			guide_light_circle:setScale(1)
			guide_light_circle:setOpacity(255)
		end)
		local act_seq = cc.Sequence:create(init_func, cc.Spawn:create(scale_to, fade_out), cc.DelayTime:create(0.3))
		guide_light_circle:runAction(cc.RepeatForever:create(act_seq))
	end

	guide_light_circle:setPosition(x, y)
end


--添加打开面板按钮
function UiInstanceMgr:AddIconToOpenView(x, y, icon_id, view_name)
	local node = XUI.CreateLayout(x, y, 100, 100)
	node.view_name = view_name
	local img_bg = XUI.CreateImageView(0, 0, ResPath.GetMainui(string.format("icon_bg", icon_id)))
	node.img_word = XUI.CreateImageView(0, -35, ResPath.GetMainui(string.format("icon_%s_word", icon_id)))
	node.img_icon = XUI.CreateImageView(0, 0, ResPath.GetMainui(string.format("icon_%s_img", icon_id)))

	XUI.AddClickEventListener(node.img_icon, function ()
		ViewManager.Instance:OpenViewByDef(view_name)
	end, true)

	--切换按钮
	node.ChangeIconId = function (icon_id, view_name)

	end

	node:addChild(img_bg, 1)
	node:addChild(node.img_icon, 2)
	node:addChild(node.img_word, 3)
	return node
end


----刷新属性富文本
UiInstanceMgr.ATTR_STYLE = {
	ROLE_ATTR = 1,
	ATTR_ADD_SHOW = 2,
}

Language.UiInstanceMgr = {
	MaxTip = "已经是最高级了",
}

--@attr_about = 1 :{{type=9,value=2,},{type=11,value=5,},{type=21,value=1,},}
-- 				2 :"最大攻击： 1 - 20"
-- 传入属性配置 或直接传入文本（可传定义的富文本格式， 如{wordcolor;ffffff;测试}）
function UiInstanceMgr.FlushAttr(rich_node, attr_about, style)
	if nil == attr_about then
		RichTextUtil.ParseRichText(rich_node, Language.UiInstanceMgr.MaxTip, nil, COLOR3B.OLIVE)
		return 
	end

	local str = ""
	style = style or UiInstanceMgr.ATTR_STYLE.ROLE_ATTR

	--人物属性
	if "table" == type(attr_about) then 
		if style == UiInstanceMgr.ATTR_STYLE.ROLE_ATTR then
			local rich_param = {
				type_str_color = COLOR3B.OLIVE,
				value_str_color = COLOR3B.OLIVE
			}
		
			str = RoleData.FormatAttrContent(attr_about, rich_param)
		elseif style == UiInstanceMgr.ATTR_STYLE.ATTR_ADD_SHOW then
			
		end
	elseif "string" == type(attr_about) then
		str = attr_about
	end

	RichTextUtil.ParseRichText(rich_node, str, nil, COLOR3B.OLIVE)
end