-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      神界冒险的bufftips
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------

AdventureBuffTips = AdventureBuffTips or BaseClass()

local string_format = string.format

function AdventureBuffTips:__init(buff_list, holiday_buff_list)
    self.buff_list = buff_list or {}
    self.holiday_buff_list = holiday_buff_list or {}

	--Debug.info(buff_list)
	self.delay = 10
	self.label_list = {}
	self.holiday_label_list = {}
	self:createRootWnd()
end

function AdventureBuffTips:createRootWnd()
	self:LoadLayoutFinish()
	self:registerCallBack()
end

function AdventureBuffTips:closeCallBack()
end

function AdventureBuffTips:LoadLayoutFinish()
	self.screen_bg = ccui.Layout:create()
	self.screen_bg:setAnchorPoint(cc.p(0.5, 0.5))
	self.screen_bg:setContentSize(cc.size(SCREEN_WIDTH, display.height))
	self.screen_bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
	self.screen_bg:setTouchEnabled(true)
	self.screen_bg:setSwallowTouches(false)
	
	self.root_wnd = ccui.Widget:create()
	self.root_wnd:setTouchEnabled(true)
	self.root_wnd:setAnchorPoint(cc.p(0, 0))
	self.root_wnd:setPosition(cc.p(0, 0))
	self.screen_bg:addChild(self.root_wnd)
	
	self.background = ccui.ImageView:create(PathTool.getResFrame("common", "common_90024"), LOADTEXT_TYPE_PLIST)
	self.background:setScale9Enabled(true)
	self.background:setAnchorPoint(cc.p(0, 0))
	self.root_wnd:addChild(self.background)
end

function AdventureBuffTips:registerCallBack()
	self.screen_bg:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.began then
			TipsManager:getInstance():hideTips()
		end
	end)
end

function AdventureBuffTips:setPosition(x, y)
	self.root_wnd:setAnchorPoint(cc.p(0, 1))
	self.root_wnd:setPosition(cc.p(x, y))
end

function AdventureBuffTips:addToParent(parent, zOrder)
	self.parent_wnd = parent
	if not tolua.isnull(self.root_wnd) then
		self.root_wnd:removeFromParent()
		if not tolua.isnull(parent) then
			self.parent_wnd:addChild(self.root_wnd, zOrder)
		end
	end
end

function AdventureBuffTips:setPos(x, y)
	self.root_wnd:setPosition(cc.p(x, y))
end

function AdventureBuffTips:getContentSize()
	return self.root_wnd:getContentSize()
end


function AdventureBuffTips:getScreenBg()
	return self.screen_bg
end

function AdventureBuffTips:showTips()
	self.buff_list = self.buff_list or {}
	self.holiday_buff_list = self.holiday_buff_list or {}

	local count = #self.buff_list
	local width = 510
	if count == 1 then		-- 线板宽度确定
		width = 255
	end
	local col = math.ceil(count * 0.5)
	local height = col * 40 + 55

	-- 活动buff
	local add_height = 0
	if next(self.holiday_buff_list) ~= nil then
		local add_count = #self.holiday_buff_list
		local add_col = math.ceil(add_count * 0.5)
		add_height = add_col * 40 + 10
		width = 510
	end
	self.root_wnd:setContentSize(cc.size(width, height + add_height))
	self.background:setContentSize(cc.size(width, height + add_height))

	if self.desc_label == nil then
		self.desc_label = createLabel(20, Config.ColorData.data_new_color4[6], nil, width*0.5, 16, TI18N("该属性仅本轮冒险生效"), self.root_wnd, nil, cc.p(0.5, 0))
	end
	if add_height > 0 then
		if self.line_image == nil then
			self.line_image = createImage(self.root_wnd, PathTool.getResFrame("common","common_1097"), width/2, height-10, cc.p(0.5, 0.5), true, nil, true)
			self.line_image:setContentSize(cc.size(2, width-60))
			self.line_image:setRotation(90)
		end
		if self.holiday_label == nil then
			self.holiday_label = createLabel(24, Config.ColorData.data_new_color4[6], nil, 30, height + add_height - 20, TI18N("活动加成:"), self.root_wnd, nil, cc.p(0, 1))
		end
	end
	self:createBuffList(width, height, add_height)
end

-- 创建列表
function AdventureBuffTips:createBuffList(width, height, add_height)
	local color = Config.ColorData.data_new_color4[6]
	local base_config = Config.BuffData.data_get_buff_data
	-- 活动buff
	for i,v in ipairs(self.holiday_buff_list or {}) do
		if self.holiday_label_list[i] == nil then
			self.holiday_label_list[i] = createRichLabel(24, color, cc.p(0, 1)) 
			self.root_wnd:addChild(self.holiday_label_list[i])
			local _x = 30 + ((i) % 2) * 220
			local _y = height + add_height - math.floor( (i) / 2 ) * 40 - 20
			self.holiday_label_list[i]:setPosition(_x, _y)
		end
		local label = self.holiday_label_list[i]
		local config = base_config[v.bid]
		local time = v.time or 1
		self:setBuffLabelData(label, config, time)
	end

	-- 冒险buff
	for i,v in ipairs(self.buff_list) do
		if self.label_list[i] == nil then
			self.label_list[i] = createRichLabel(24, color, cc.p(0, 1)) 
			self.root_wnd:addChild(self.label_list[i])
			local _x = 30 + ((i - 1) % 2) * 220
			local _y = height - math.floor( (i - 1) / 2 ) * 40 - 20
			self.label_list[i]:setPosition(_x, _y)
		end
		local label = self.label_list[i]
		local config = base_config[v.bid]
		local time = v.time or 1
		self:setBuffLabelData(label, config, time)
	end
end

function AdventureBuffTips:setBuffLabelData( label, config, time )
	if label and config and time then
		local buff_desc = ""
		for i,v in ipairs(config.effect) do
			local attr_key = v[1]
			local attr_val = v[2] * time
			if buff_desc ~= "" then
				buff_desc = buff_desc..","
			end
			local attr_name = Config.AttrData.data_key_to_name[attr_key] or ""
			if PartnerCalculate.isShowPerByStr(attr_key) then
				buff_desc = string_format(TI18N("%s提升%s%s"), attr_name, attr_val*0.1, "%")
			else
				buff_desc = string_format(TI18N("%s提升%s"), attr_name, attr_val)
			end
		end
		local str = string_format("<img src=%s scale=0.3 visible=true />%s", PathTool.getBuffRes(config.icon), buff_desc)
		label:setString(str)
	end
end

-- 从新计算文本的大小
function AdventureBuffTips:recoutTextFieldSize(str_label, width, font_size)
	local label = createRichLabel(font_size, Config.ColorData.data_new_color4[6], cc.p(0, 1), nil, 6, 0, width)
	label:setString(str_label)
	return label
end

function AdventureBuffTips:setAnchorPoint(pos)
	self.screen_bg:setAnchorPoint(pos)
end
function AdventureBuffTips:open()
	local parent = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
	parent:addChild(self.screen_bg)
	doStopAllActions(self.screen_bg)
	delayRun(self.screen_bg, self.delay, function()
		TipsManager:getInstance():hideTips()
	end)
end


function AdventureBuffTips:close()
	if self.screen_bg then
		doStopAllActions(self.screen_bg)
		self.screen_bg:removeFromParent()
		self.screen_bg = nil
	end
end 