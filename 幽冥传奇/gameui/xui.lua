
XUI = XUI or {
	IS_PLIST = true,								-- 默认纹理加载方式

	async_ui_list = {},
	async_ui_key_list = {},
	curr_config = nil,
	curr_info_list = {},
	curr_info_index = 0,
	async_load_list = {},							-- 异步加资源列表
	outline_size = 0,
}

XuiTouchEventType = {
	Began = 0,
	Moved = 1,
	Ended = 2,
	Canceled = 3,
}

function XUI.Delete()
	XUI.async_ui_list = {}
	async_ui_key_list = {}
	XUI.curr_config = nil
	XUI.curr_info_list = {}
	XUI.curr_info_index = 0
	async_load_list = {}
end

-- 添加点击事件监听，必须是有addTouchEventListener函数的控件
-- @click_callback 点击回调
-- @is_click_scale 点击是否放大
-- @dither_secs 点击回调间隔
function XUI.AddClickEventListener(node, click_callback, is_click_scale, dither_secs)
	node:setTouchEnabled(true)
	dither_secs = dither_secs or 0.2

	local last_callback_time = 0
	local dither_callback = function() 
		local diff = NOW_TIME - last_callback_time
		if diff >= dither_secs then
			click_callback()
			last_callback_time = NOW_TIME
		end
	end
	node:addClickEventListener(dither_callback)
	
	node.click_callback = dither_callback
	if nil ~= is_click_scale then
		node:setIsHittedScale(is_click_scale)
	end
end

function XUI.SetBackGroundColor(layout, c3b)
	layout:setBackGroundColor(c3b or COLOR3B.BLUE)
end

-- 监听节点事件，enter,enterTransitionFinish,exitTransitionStart,exit,cleanup
function XUI.RegisterNodeEvent(node, callback)
	node:registerScriptHandler(callback)
end

function XUI.UnregisterScriptHandler(node)
	node:unregisterScriptHandler()
end

-- 布局
function XUI.CreateLayout(x, y, w, h)
	local node = XLayout:create(w, h)
	node:setPosition(x, y)
	node:setAnchorPoint(0.5, 0.5)
	return node
end

-- 按钮
-- @is_s9：true才能设置大小
-- @normal：常态图片
-- @select：选择态图片，当此参数为空时，按下按钮is_s9为true变暗，false变大
-- @disable：禁用态图片
function XUI.CreateButton(x, y, w, h, is_s9, normal, select, disable, is_plist)
	if nil == is_plist then is_plist = true end
	local node = nil
	if is_s9 then
		node = XButton:create9Sprite(normal, select, disable, cc.rect(0, 0, 0, 0), is_plist)
	else
		node = XButton:create(normal, select, disable, is_plist)
	end

	if nil == node then return nil end

	node:setPosition(x, y)
	if is_s9 then
		node:setContentWH(w, h)
	end
	return node
end

-- 设置按钮不可用
function XUI.SetButtonEnabled(node, enabled)
	if nil ~= node then
		node:setEnabled(enabled)
	end
end

-- 开关按钮
function XUI.CreateToggleButton(x, y, w, h, is_s9, normal, select, disable, is_plist)
	if nil == is_plist then is_plist = true end
	local node = XUI.CreateButton(x, y, w, h, is_s9, normal, select, disable, is_plist)
	if nil == node then return nil end
	node:setToggle(true)
	return node
end

-- 选择按钮
function XUI.CreateCheckBox(x, y, bg, bg_select, bg_disable, cross, cross_disable, is_plist)
	if nil == is_plist then is_plist = true end
	local node = XCheckBox:create(bg, bg_select, bg_disable, cross, cross_disable, is_plist)
	if nil == node then return nil end
	node:setPosition(x, y)
	return node
end

-- 1：竖向 2：横向：3：横竖都可以
ScrollDir = { Vertical = 1, Horizontal = 2, Both = 3}
-- 卷轴视图
function XUI.CreateScrollView(x, y, w, h, direction)
	local node = XScrollView:create(direction or ScrollDir.Vertical)
	node:setAnchorPoint(0.5, 0.5)
	node:setPosition(x, y)
	node:setContentWH(w, h)
	return node
end

ListViewGravity = {
	Left = 0,
	Right = 1,
	CenterHorizontal = 2,
	Top = 3,
	Bottom = 4,
	CenterVertical = 5,
}
-- 列表视图 @direction : ScrollDir
function XUI.CreateListView(x, y, w, h, direction)
	local node = XListView:create(direction or ScrollDir.Vertical)
	node:setAnchorPoint(0.5, 0.5)
	node:setPosition(x, y)
	node:setContentWH(w, h)
	return node
end

-- 翻页视图 @direction : ScrollDir
function XUI.CreatePageView(x, y, w, h, direction)
	local node = XPageView:create(direction or ScrollDir.Horizontal)
	node:setAnchorPoint(0.5, 0.5)
	node:setPosition(x, y)
	node:setContentWH(w, h)
	return node
end

-- 图片
function XUI.CreateImageView(x, y, path, is_plist)
	if nil == is_plist then is_plist = true end
	local node = XImage:create(path, is_plist)
	if nil == node then return nil end
	node:setPosition(x, y)
	return node
end

-- 九宫格图片
function XUI.CreateImageViewScale9(x, y, w, h, path, is_plist, cap_rect)
	if nil == is_plist then is_plist = true end
	local node = XImage:create9Sprite(path, cap_rect or cc.rect(0, 0, 0, 0), is_plist)
	if nil == node then return nil end
	node:setPosition(x, y)
	node:setContentWH(w, h)
	return node
end

-- 进度条
function XUI.CreateLoadingBar(x, y, progress, is_plist, bg, is_s9, w, h, cap_rect)
	if nil == is_plist then is_plist = true end
	local node = XLoadingBar:create(progress, is_plist)
	if bg then
		node:loadBgTexture(bg, is_plist)
	end
	node:setPosition(x, y)
	if is_s9 then
		node:setScale9Enabled(true)
		if nil ~= cap_rect then
			node:setCapInsets(cap_rect)
		end
		node:setContentWH(w, h)
	end
	return node
end

-- 滑块
function XUI.CreateSlider(x, y, ball, progress, bar, is_plist)
	if nil == is_plist then is_plist = true end
	local node = XSlider:create(ball, progress, bar, is_plist)
	if nil == node then return nil end
	node:setPosition(x, y)
	return node
end

-- 文本
-- @h_alignment：cc.TEXT_ALIGNMENT_LEFT = 0 左对齐，cc.TEXT_ALIGNMENT_CENTER = 1 居中，cc.TEXT_ALIGNMENT_RIGHT = 2 右对齐
function XUI.CreateText(x, y, w, h, h_alignment, text, font, font_size, color3b, v_alignment)
	local node = XText:create(text, 
		font or COMMON_CONSTS.FONT, 
		font_size or 20, 
		cc.size(w, h), 
		h_alignment or cc.TEXT_ALIGNMENT_CENTER,
		v_alignment or cc.VERTICAL_TEXT_ALIGNMENT_TOP
		)
	node:setPosition(x, y)
	if nil ~= color3b then
		node:setColor(color3b)
	end
	if XUI.outline_size > 0 then
		node:enableOutline(cc.c4b(0, 0, 0, 255), XUI.outline_size)
	end
	return node
end

-- 阴影
function XUI.EnableShadow(text, c4b, offset)
	-- text:enableShadow(c4b or COLOR4B.BLACK, offset or cc.size(1, -1))
end

-- 描边
function XUI.EnableOutline(text, c4b, size)
	text:enableOutline(c4b or COLOR4B.BLACK, size or 1)
end

RichHAlignment = {HA_LEFT = 0, HA_CENTER = 1, HA_RIGHT = 2, }	-- 水平对齐方式
RichVAlignment = {VA_TOP = 0, VA_CENTER = 1, VA_BOTTOM = 2, }	-- 竖直对齐方式
-- 富文本，可插入RichElementText，RichElementImage，RichElementCustomNode
-- @is_ignore 是否忽略size，false会自动换行
function XUI.CreateRichText(x, y, w, h, is_ignore)
	local node = XRichText:create()

	XUI.SetRichTextVerticalSpace(node,5)

	if x and y then
		node:setPosition(x, y)
	end
	if w and h then
		node:setContentWH(w, h)
	end
	if nil ~= is_ignore then
		node:setIgnoreSize(is_ignore)
	end
	return node
end

--设置行距，统一使用这个方法，可以根据平台不同处理代码
function XUI.SetRichTextVerticalSpace(rich,v)
	if PLATFORM == cc.PLATFORM_OS_ANDROID then
		rich:setVerticalSpace(v - 5)
	else
		rich:setVerticalSpace(v)
	end	
end	

-- 居中不换行
function XUI.RichTextSetCenter(rich)
	rich:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	rich:setIgnoreSize(true)
end

-- 富文本右对齐
function XUI.RichTextSetRight(rich)
	rich:setHorizontalAlignment(RichHAlignment.HA_RIGHT)
	rich:setIgnoreSize(true)
end

-- 富文本插入文字
function XUI.RichTextAddText(node, text, font, font_size, color3b, opacity, shadow_offset, outline_size)
	if nil == node or nil == text or "" == text then return false end
	font = font or COMMON_CONSTS.FONT
	font_size = font_size or 20
	color3b = color3b or COLOR3B.WHITE
	opacity = opacity or 255
	local element = XRichElementText:create(text, font, font_size, color3b, opacity)

	if nil ~= shadow_offset then
		-- element:enableShadow(COLOR4B.BLACK, shadow_offset)
	end
	outline_size = outline_size or XUI.outline_size
	if outline_size > 0 then
		element:enableOutline(COLOR4B.BLACK, outline_size)
	end

	node:pushBackElement(element)
	return true
end

-- 富文本插入图片
function XUI.RichTextAddImage(node, path, is_plist)
	if nil == is_plist then is_plist = true end
	if nil == node or nil == path or "" == path then return false end

	node:pushBackImage(path, is_plist)
	return true
end

--富文本插入九宫格图片
function XUI.RichTextAddImageScale9(node, path, w, h, is_plist, cap_rect)
	if nil == is_plist then is_plist = true end
	if nil == node or nil == path or "" == path then return false end

	local img = XUI.CreateImageViewScale9(0, 0, w, h, path, is_plist, cap_rect)
	if nil == img then return false end
	local element = XRichElementCustom:create(img)
	node:pushBackElement(element)
	return true
end

-- 富文本插入自定义节点
function XUI.RichTextAddElement(node, custom_node)
	if nil == node or nil == custom_node then return false end

	local element = XRichElementCustom:create(custom_node)
	node:pushBackElement(element)
	return true
end

-- 输入框
function XUI.CreateEditBox(x, y, w, h, font, input_mode, input_flag, bg_path, is_plist, cap_rect)
	if nil == is_plist then is_plist = true end
	local s9sprite = nil
	if is_plist then
		if nil ~= cap_rect then
			s9sprite = cc.Scale9Sprite:createWithSpriteFrameName(bg_path, cap_rect)
		else
			s9sprite = cc.Scale9Sprite:createWithSpriteFrameName(bg_path)
		end
	else
		if nil ~= cap_rect then
			s9sprite = cc.Scale9Sprite:create(cap_rect, bg_path)
		else
			s9sprite = cc.Scale9Sprite:create(bg_path)
		end
	end

	if nil ==  s9sprite then return nil end

	local node = cc.EditBox:create(cc.size(w, h), s9sprite)
	node:setPosition(x, y)
	node:setFont(font or COMMON_CONSTS.FONT, 20)
	node:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	node:setInputFlag(input_flag or cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_ALL_CHARACTERS)
	node:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	return node
end

-- 摇杆
function XUI.CreateJoystick(x, y, bg, joystick, is_plist)
	if nil == is_plist then is_plist = true end
	local node = XJoystick:create(bg, joystick, is_plist)
	node:setPosition(x, y)
	return node
end

-- 获取精灵帧
function XUI.GetSpriteFrame(path)
	return cc.SpriteFrameCache:getInstance():getSpriteFrame(path)
end

-- 创建精灵
function XUI.CreateSprite(path, is_plist)
	if nil == is_plist then is_plist = true end
	return XCommon:createSprite(path, is_plist)
end

----------------------------------------------------
-- 根据配置创建一个控件
function XUI.CreateControl(arg)
	local node = nil

	if arg.t == "layout" then
		node = XUI.CreateLayout(arg.x + arg.w / 2, arg.y + arg.h/ 2, arg.w, arg.h)

	elseif arg.t == "btn" or arg.t == "btn2" or arg.t == "btn3" then
		local path_select = (arg.t == "btn2" or arg.t == "btn3") and arg.ps or ""
		local path_disable = (arg.t == "btn3") and arg.pd or ""
		node = XUI.CreateButton(arg.x, arg.y, 0, 0, false, arg.pn, path_select, path_disable, XUI.IS_PLIST)
		if nil ~= node then
			node:setTitleFontName(COMMON_CONSTS.FONT)
			local label = node:getTitleLabel()
			if label then
				label:enableOutline(cc.c4b(0, 0, 0, 255), XUI.outline_size)
			end
			if nil ~= arg.tfs then node:setTitleFontSize(arg.tfs) end
			if nil ~= arg.txt and arg.txt ~= "" then node:setTitleText(arg.txt) end
			if nil ~= arg.r and nil ~= arg.g and nil ~= arg.b then node:setTitleColor(cc.c3b(arg.r, arg.g, arg.b)) end
		end

	elseif arg.t == "toggle" then
		node = XUI.CreateToggleButton(arg.x, arg.y, 0, 0, false, arg.pn, arg.ps, "", XUI.IS_PLIST)
		if nil ~= node then
			node:setTitleFontName(COMMON_CONSTS.FONT)
			local label = node:getTitleLabel()
			if label then
				label:enableOutline(cc.c4b(0, 0, 0, 255), XUI.outline_size)
			end
			if nil ~= arg.tfs then node:setTitleFontSize(arg.tfs) end
			if nil ~= arg.txt and arg.txt ~= "" then node:setTitleText(arg.txt) end
		end
		
	elseif arg.t == "img" then
		node = XUI.CreateImageView(arg.x, arg.y, arg.p, XUI.IS_PLIST)
		if nil ~= node then
			if arg.sx and 1 ~= arg.sx then node:setScaleX(arg.sx) end
			if arg.sy and 1 ~= arg.sy then node:setScaleY(arg.sy) end
		end

	elseif arg.t == "img9" then
		node = XUI.CreateImageViewScale9(arg.x, arg.y, arg.w, arg.h, arg.p, XUI.IS_PLIST, cc.rect(arg.cx, arg.cy, arg.cw, arg.ch))

	elseif arg.t == "text" then
		node = XUI.CreateText(arg.x, arg.y, arg.w, arg.h, arg.ta, arg.txt, COMMON_CONSTS.FONT, arg.tfs, cc.c3b(arg.r, arg.g, arg.b))
		node:setAnchorPoint(0, 1)

	elseif arg.t == "check" then
		node = XUI.CreateCheckBox(arg.x, arg.y, arg.normal1, arg.select1, arg.disable1, arg.normal2, arg.disable2, XUI.IS_PLIST)

	elseif arg.t == "scroll" then
		node = XUI.CreateScrollView(arg.x, arg.y, arg.w, arg.h, arg.dir)

	elseif arg.t == "list" then
		node = XUI.CreateListView(arg.x, arg.y, arg.w, arg.h)

	elseif arg.t == "page" then
		node = XUI.CreatePageView(arg.x, arg.y, arg.w, arg.h)

	elseif arg.t == "prog" then
		node = XUI.CreateLoadingBar(arg.x, arg.y, arg.progress, XUI.IS_PLIST, arg.bg)
	elseif arg.t == "prog9" then
		node = XUI.CreateLoadingBar(arg.x, arg.y, arg.progress, XUI.IS_PLIST, nil, true, arg.w, arg.h, cc.rect(arg.cx, arg.cy, arg.cw, arg.ch))
	elseif arg.t == "slider" then
		node = XUI.CreateSlider(arg.x, arg.y, arg.ball, arg.progress, arg.bar, XUI.IS_PLIST)

	elseif arg.t == "rich" then
		node = XUI.CreateRichText(arg.x, arg.y, arg.w, arg.h, false)
		node:setAnchorPoint(0, 1)

	elseif arg.t == "edit" then
		node = XUI.CreateEditBox(arg.x, arg.y, arg.w, arg.h, COMMON_CONSTS.FONT, arg.imd, arg.ifg, arg.p, XUI.IS_PLIST)

	end

	if nil == node then
		ErrorLog("XUI:CreateControl node nil type:" .. tostring(arg.t) .. " name:" .. tostring(arg.n))
		return nil
	end
	
	return node
end

-- 同步创建UI
function XUI.GeneratorUI(config, parent, tag, node_list, node_tree, ph_list)
	local node = nil

	if "ph" ~= config.t then
		node = XUI.CreateControl(config)
		if nil == node then
			ErrorLog("XUI:GeneratorUI error 1:" .. config.n)
			return nil
		end
		if nil ~= parent then
			parent:addChild(node, tag or 0, tag or 0)
		end
	else
		if nil == parent then
			ErrorLog("XUI:GeneratorUI error 2:" .. config.n)
			return
		end

		node = parent
	end

	local t = {["node"] = node}
	if nil ~= config.n and "" ~= config.n then
		if nil ~= node_list then node_list[config.n] = t end
		if nil ~= node_tree then node_tree[config.n] = t end
	end

	-- 解析childs
	XUI.Parse(config, node, node_list, t, ph_list)

	return t
end

-- 解析ph
function XUI.ParsePh(config, ph_list)
	for i, v in ipairs(config) do
		if "ph" == v.t then
			if nil ~= v.n and "" ~= v.n and nil ~= ph_list then
				ph_list[v.n] = v
			end
		end
	end
end

-- 解析并创建
function XUI.Parse(config, parent, node_list, node_tree, ph_list)
	for i, v in ipairs(config) do
		if "ph" == v.t then
			if nil ~= v.n and "" ~= v.n and nil ~= ph_list then
				ph_list[v.n] = v
			end
		else
			local node = XUI.CreateControl(v)
			if nil == node then
				ErrorLog("XUI:Parse error:" .. v.n)
				return nil
			end

			parent:addChild(node, i, i)

			local t = {["node"] = node}
			if nil ~= v.n and "" ~= v.n then
				if nil ~= node_list then node_list[v.n] = t end
				if nil ~= node_tree then node_tree[v.n] = t end
			end

			XUI.Parse(v, node, node_list, t, ph_list)
		end
	end
end

-- 异步创建UI
function XUI.AsyncGeneratorUI(config, parent, tag, node_list, node_tree, ph_list, callback, key, is_visible)
	if nil == config or nil == parent then
		ErrorLog("XUI.AsyncGeneratorUI error 1")
		return
	end

	if nil ~= key then
		XUI.async_ui_key_list[key] = true
	end

	table.insert(XUI.async_ui_list, {
		["config"] = config,
		["parent"] = parent,
		["tag"] = tag,
		["node_list"] = node_list,
		["node_tree"] = node_tree,
		["ph_list"] = ph_list,
		["callback"] = callback,
		["key"] = key,
		["is_visible"] = is_visible,
	})
end

-- 解析配置
function XUI.ParseConfig()
	if nil ~= XUI.curr_config then
		return
	end

	XUI.curr_config = table.remove(XUI.async_ui_list, 1)
	if nil == XUI.curr_config then
		return
	end

	local parent_index = 0
	local function parse(config, i, p_index)
		table.insert(XUI.curr_info_list, {
			["config"] = config,
			["parent_index"] = p_index,
			["index"] = i,
			["node_tree"] = {}, })

		parent_index = parent_index + 1

		if 1 == parent_index or "ph" ~= config.t then
			local temp_index = parent_index
			for i, v in ipairs(config) do
				parse(v, i, temp_index)
			end
		end
	end

	XUI.curr_info_list = {}
	parse(XUI.curr_config.config, 0, 0)
end

function XUI.Update()
	XUI.ParseConfig()

	if nil ~= XUI.curr_config then
		local info_count = #XUI.curr_info_list

		local end_index = XUI.curr_info_index + 30
		if end_index > info_count then
			end_index = info_count
		end

		local info, name = nil, ""
		for i = XUI.curr_info_index + 1, end_index do
			XUI.curr_info_index = XUI.curr_info_index + 1

			info = XUI.curr_info_list[i]
			name = info.config.n

			if 1 == i then
				if "ph" == info.config.t then
					if nil ~= XUI.curr_config.ph_list then
						XUI.curr_config.ph_list[name] = info.config
					end
				else
					info.node_tree.node = XUI.CreateControl(info.config)
					local tag = XUI.curr_config.tag or 0
					XUI.curr_config.parent:addChild(info.node_tree.node, tag, tag)
					if false == XUI.curr_config.is_visible then
						info.node_tree.node:setVisible(false)
					end
				end

				if nil ~= name and "" ~= name then
					if nil ~= XUI.curr_config.node_tree then
						XUI.curr_config.node_tree[name] = info.node_tree
					end

					if nil ~= XUI.curr_config.node_list then
						XUI.curr_config.node_list[name] = info.node_tree
					end
				end
			else
				if "ph" == info.config.t then
					if nil ~= XUI.curr_config.ph_list then
						XUI.curr_config.ph_list[name] = info.config
					end
				else
					info.node_tree.node = XUI.CreateControl(info.config)
					local parent_info = XUI.curr_info_list[info.parent_index]

					if nil ~= name and "" ~= name then
						parent_info.node_tree[name] = info.node_tree

						if nil ~= XUI.curr_config.node_list then
							XUI.curr_config.node_list[name] = info.node_tree
						end
					end

					parent_info.node_tree.node:addChild(info.node_tree.node, info.index, info.index)
				end
			end

			if XCommon:getHighPrecisionTime() - HIGH_TIME_NOW >= 0.010 then
				break
			end
		end

		if XUI.curr_info_index >= info_count then
			local temp_config = XUI.curr_config
			local node_tree = XUI.curr_info_list[1].node_tree
			XUI.curr_config = nil
			XUI.curr_info_index = 0
			XUI.curr_info_list = {}
			temp_config.callback(node_tree)
		end
	end
end

-- 取消异步
function XUI.cancelAsyncByKey(key)
	if nil == key or nil == XUI.async_ui_key_list[key] then
		return
	end
	XUI.async_ui_key_list[key] = nil

	if nil ~= XUI.curr_config and XUI.curr_config.key == key then
		XUI.curr_config = nil
		XUI.curr_info_index = 0
		XUI.curr_info_list = {}
	end

	for i = #XUI.curr_info_list, 1, -1 do
		if XUI.curr_info_list[i].key == key then
			table.remove(XUI.curr_info_list, i)
		end
	end
end

-- 异步更新纹理
function XUI.AsyncLoadTexture(image, path, callback)
	local info = XUI.async_load_list[image]
	if nil ~= info then
		image:unregisterScriptHandler()
		ResourceMgr:getInstance():abortAsyncLoad(info.path, info.request_id)
		XUI.async_load_list[image] = nil
	end

	local request_id = 0
	local function load_callback(path, is_succ, texture)
		XUI.async_load_list[image] = nil
		image:unregisterScriptHandler()
		if is_succ then
			image:loadTexture(path)
			callback()
		end
	end
	local function node_event_callback(event_text)
		if event_text == "cleanup" then
			XUI.async_load_list[image] = nil
			ResourceMgr:getInstance():abortAsyncLoad(path, request_id)
		end
	end
	request_id = ResourceMgr:getInstance():asyncLoadTexture(path, load_callback)
	image:registerScriptHandler(node_event_callback)

	XUI.async_load_list[image] = {["path"] = path, ["request_id"] = request_id}
end

local text_format = {
	[1] = {outline_size = 0, font = COMMON_CONSTS.FONT, font_size = 22, h_alignment = cc.TEXT_ALIGNMENT_CENTER, v_alignment = cc.VERTICAL_TEXT_ALIGNMENT_TOP, color = COLOR3B.BROWN2},
	[2] = {outline_size = 0, font = COMMON_CONSTS.FONT, font_size = 20, h_alignment = cc.TEXT_ALIGNMENT_RIGHT, v_alignment = cc.VERTICAL_TEXT_ALIGNMENT_TOP, color = COLOR3B.WHITE},
	[3] = {outline_size = 0, font = COMMON_CONSTS.FONT, font_size = 22, h_alignment = cc.TEXT_ALIGNMENT_CENTER, v_alignment = cc.VERTICAL_TEXT_ALIGNMENT_TOP, color = COLOR3B.WHITE},
	[4] = {outline_size = 0, font = COMMON_CONSTS.FONT, font_size = 20, h_alignment = cc.TEXT_ALIGNMENT_RIGHT, v_alignment = cc.VERTICAL_TEXT_ALIGNMENT_TOP, color = COLOR3B.G_W},
}
function XUI.CreateTextByType(x, y, w, h, text, type)
	local format = text_format[type]
	if nil == format then
		return
	end
	local node = XText:create(text,
		format.font, 
		format.font_size, 
		cc.size(w, h), 
		format.h_alignment,
		format.v_alignment
		)
	if nil ~= format.color then
		node:setColor(format.color)
	end
	if format.outline_size > 0 then
		node:enableOutline(cc.c4b(0, 0, 0, 255), format.outline_size)
	end
	node:setPosition(x, y)
	return node
end

XUI.CENTER        = 1
XUI.LEFT_TOP      = 2; XUI.TOP_LEFT      = 2
XUI.CENTER_TOP    = 3; XUI.TOP_CENTER    = 3
XUI.RIGHT_TOP     = 4; XUI.TOP_RIGHT     = 4
XUI.CENTER_LEFT   = 5; XUI.LEFT_CENTER   = 5
XUI.CENTER_RIGHT  = 6; XUI.RIGHT_CENTER  = 6
XUI.BOTTOM_LEFT   = 7; XUI.LEFT_BOTTOM   = 7
XUI.BOTTOM_RIGHT  = 8; XUI.RIGHT_BOTTOM  = 8
XUI.BOTTOM_CENTER = 9; XUI.CENTER_BOTTOM = 9

XUI.ANCHOR_POINTS = {
    cc.p(0.5, 0.5),  -- CENTER
    cc.p(0, 1),      -- TOP_LEFT
    cc.p(0.5, 1),    -- TOP_CENTER
    cc.p(1, 1),      -- TOP_RIGHT
    cc.p(0, 0.5),    -- CENTER_LEFT
    cc.p(1, 0.5),    -- CENTER_RIGHT
    cc.p(0, 0),      -- BOTTOM_LEFT
    cc.p(1, 0),      -- BOTTOM_RIGHT
    cc.p(0.5, 0),    -- BOTTOM_CENTER
}

function XUI.Align(target, anchorPoint, x, y)
    target:setAnchorPoint(XUI.ANCHOR_POINTS[anchorPoint])
    if x and y then target:setPosition(x, y) end
end

-- 变灰
function XUI.MakeGrey(node, is_grey)
	if node then
		XCommon:makeGrey(node, is_grey)
	end
end

-- 布局节点变灰
function XUI.SetLayoutImgsGrey(layout, is_grey, is_set_enabled)
	if layout then 
		for k, v in pairs(layout:getChildren()) do
			if v and v.setGrey then
				v:setGrey(is_grey)
			end
		end
		if is_set_enabled then
			layout:setTouchEnabled(not is_grey)
		end
	end
end

XUI.XuiShaderSpriteGlow = "XuiShaderSpriteGlow"
local vertDefaultSource = [[
attribute vec4 a_position; 
attribute vec2 a_texCoord; 
attribute vec4 a_color; 
#ifdef GL_ES 
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
#else 
varying vec4 v_fragmentColor; 
varying vec2 v_texCoord;  
#endif 
void main() 
{
	gl_Position = CC_PMatrix * a_position; 
	v_fragmentColor = a_color;
	v_texCoord = a_texCoord;
}
]]
local glowFragSource = [[
#ifdef GL_ES
precision mediump float;
#endif
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;
void main()
{
	vec4 u_color = vec4(1.0, 1.0, 0.0, 1.0);
    vec4 accum = vec4(0.0);
    vec4 normal = vec4(0.0);
    normal = texture2D(CC_Texture0, v_texCoord);
	float radius = 1.0;
    float val = 0.001;
    for(float i = 1.0; i <= radius; i += 1.0)
    {
    	accum += texture2D(CC_Texture0, vec2(v_texCoord.x - val * i, v_texCoord.y - val * i));
	    accum += texture2D(CC_Texture0, vec2(v_texCoord.x + val * i, v_texCoord.y - val * i));
	    accum += texture2D(CC_Texture0, vec2(v_texCoord.x + val * i, v_texCoord.y + val * i));
	    accum += texture2D(CC_Texture0, vec2(v_texCoord.x - val * i, v_texCoord.y + val * i));
    }
    accum.rgb =  u_color.rgb * u_color.a * accum.a * 1.0;
    float opacity = ((1.0 - normal.a) / radius) * 0.6;
    normal = (accum * opacity) + (normal * normal.a);    
    gl_FragColor = v_fragmentColor * normal;
}
]]
-- 外发光
function XUI.MakeGlow(sprite, bool)
	if nil == sprite then
		return
	end

	if bool then
		local pProgram = cc.GLProgramCache:getInstance():getGLProgram(XUI.XuiShaderSpriteGlow)
		if nil == pProgram then
		    pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource, glowFragSource)
		    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
		    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
		    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
		    pProgram:updateUniforms()
		    cc.GLProgramCache:getInstance():addGLProgram(pProgram, XUI.XuiShaderSpriteGlow);
		end

		sprite:setGLProgram(pProgram);
	else
		sprite:setGLProgram(cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP"));
	end
end

--node 添加红点提示
function XUI.AddRemingTip(parent, check_have_remind_func, eff_id, x, y, z_order)
	local size = parent:getContentSize()
	--判断是否已添加红点提醒功能
	if nil == parent.remind_img then 
		parent.remind_img = XUI.CreateImageView(x or size.width - 2, y or size.height - 10, ResPath.GetRemindImg(), true)
		parent:addChild(parent.remind_img, z_order or 300)
		parent.remind_img:setVisible(false)
	end

	if nil == parent.remind_img_eff and eff_id and eff_id > 0 then
		parent.remind_img_eff = RenderUnit.CreateEffect(eff_id, parent, 10, nil, nil, size.width / 2, size.height / 2)
		parent.remind_img_eff:setVisible(false)
	end

	--为父节点添加提醒方法
	function parent:UpdateReimd(is_remind)
		is_remind = is_remind or (check_have_remind_func and check_have_remind_func())
		
		if parent.remind_img then
			parent.remind_img:setVisible(is_remind)
		end

		if parent.remind_img_eff then
			parent.remind_img_eff:setVisible(is_remind)
		end
	end
end

--解析ui配置到分层布局
function XUI.AddPraseUiInMainuiMultiLayout(root_layout, ui_cfg, zOrder)
	local ui_node_list = {}
	local ui_ph_list = {}
	root_layout:TextureLayout():addChild(XUI.GeneratorUI(ui_cfg, nil, nil, ui_node_list, nil, ui_ph_list).node, zOrder or 999)
	return ui_node_list, ui_ph_list
end

--node 添加模态和点击任意处关闭效果
function XUI.AddModelAndAnyClose(node, is_modal, is_any_click_close, click_func)
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	local real_root_node = XUI.CreateLayout(node:getContentSize().width / 2, node:getContentSize().height / 2, screen_w, screen_h)
	real_root_node:setTouchEnabled(true)
	real_root_node:setAnchorPoint(0.5,0.5)

	node:addChild(real_root_node, -1)
	node.click_func = click_func

	if is_modal then
		real_root_node:setBackGroundColor(COLOR3B.BLACK)
		real_root_node:setBackGroundColorOpacity(165)
	end

	if is_any_click_close then
		XUI.AddClickEventListener(real_root_node, function ()
			if click_func then
				click_func()
			end
		end)
	end
end