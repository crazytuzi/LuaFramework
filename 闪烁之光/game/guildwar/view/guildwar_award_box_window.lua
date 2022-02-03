--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-21 19:30:20
-- @description    : 
		-- 公会战宝箱奖励
---------------------------------
GuildwarAwardBoxWindow = GuildwarAwardBoxWindow or BaseClass(BaseView)

local _controller = GuildwarController:getInstance()
local _model = _controller:getModel()

function GuildwarAwardBoxWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "guildwar/guildwar_award_box_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("guildwar", "guildwar"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg/guildwar","guildwar_3"), type = ResourcesType.single },
		{path = PathTool.getPlistImgForDownLoad("bigbg/guildwar","guildwar_4"), type = ResourcesType.single },
	}
end

function GuildwarAwardBoxWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)

	local win_title = main_container:getChildByName("win_title")
	win_title:setString(TI18N("公会战奖励"))
	self.time_tips = main_container:getChildByName("time_tips")
	self.tips_txt = main_container:getChildByName("tips_txt")
	self.tips_txt:setString(TI18N("宝箱在公会战结束后产生，成员每人可开启1次，试试你的手气吧！"))
	self.title_label = main_container:getChildByName("title_label")
	self.line_1 = main_container:getChildByName("line_1")
	self.line_2 = main_container:getChildByName("line_2")
	
	self.explain_btn = main_container:getChildByName("explain_btn")
	self.preview_btn = main_container:getChildByName("preview_btn")
	self.preview_btn:getChildByName("label"):setString(TI18N("奖励预览"))
	self.preview_btn:setVisible(false)

	self.no_box_image = main_container:getChildByName("no_box_image")
	self.no_box_image:getChildByName("label"):setString(TI18N("公会战尚未结算，暂无奖励内容"))

	local box_list = main_container:getChildByName("box_list")
	local scroll_view_size = box_list:getContentSize()
    local setting = {
        item_class = GuildwarAwardBoxItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 6,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 6,                   -- y方向的间隔
        item_width = 206,               -- 单元的尺寸width
        item_height = 218,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 3,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.box_scrollview = CommonScrollViewLayout.new(box_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.box_scrollview:setSwallowTouches(false)
end

function GuildwarAwardBoxWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openAwardBoxWindow(false)
	end, false, 2)

	registerButtonEventListener(self.explain_btn, function ( param, sender )
		local config = Config.GuildWarData.data_const.box_rule
		if config then
			TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
		end
	end)

	registerButtonEventListener(self.preview_btn, function (  )
		_controller:openAwardBoxPreview(true)
	end, true)

	-- 宝箱数据
	self:addGlobalEvent(GuildwarEvent.UpdateGuildWarBoxDataEvent, function ( data )
		self:setData(data)
	end)

	-- 玩家领取了宝箱
	self:addGlobalEvent(GuildwarEvent.UpdateMyAwardBoxEvent, function ( )
		self:refreshTimeTips()
	end)
end

function GuildwarAwardBoxWindow:openRootWnd(  )
	_controller:requestAwardBoxData()
end

function GuildwarAwardBoxWindow:setData( data )
	if not data then return end

	self.data = data

	local box_data = _model:getGuildWarBoxData()
	local cur_time = GameNet:getInstance():getTime()
	-- 领取时间已到或进行中或没有宝箱数据
	if (self.data.end_time <= cur_time) or next(box_data) == nil then
		self.no_box_image:setVisible(true)
		self.title_label:setVisible(false)
		self.time_tips:setVisible(false)
		self.line_1:setVisible(false)
		self.line_2:setVisible(false)
		self.box_scrollview:setVisible(false)
		self.box_scrollview:setData({})
	else
		self.no_box_image:setVisible(false)
		self.title_label:setVisible(true)
		self.time_tips:setVisible(true)
		self.line_1:setVisible(true)
		self.line_2:setVisible(true)
		self.box_scrollview:setVisible(true)
		
		self:refreshTimeTips()

		if self.data.result == GuildwarConst.box_type.gold then
			self.title_label:setString(TI18N("公会战荣耀黄金宝箱"))
		else
			self.title_label:setString(TI18N("公会战激励青铜宝箱"))
		end
		self.box_scrollview:setData(box_data)
	end 
end

-- 刷新领取状态
function GuildwarAwardBoxWindow:refreshTimeTips(  )
	if self.data and self.time_tips then
		-- 是否有权限领取（活跃人员可以领取）
		if self.data.status == 0 then
			self.time_tips:setString(string.format(TI18N("您此前处于不活跃状态，不可开启宝箱")))
			self.time_tips:setTextColor(cc.c3b(217,80,20))
			self:openBoxAwardTimer(false)
		elseif _model:checkIsGetBoxAward() then
			self.time_tips:setString(string.format(TI18N("您已开启过宝箱")))
			self.time_tips:setTextColor(cc.c3b(36,144,3))
			self:openBoxAwardTimer(false)
		else
			local cur_time = GameNet:getInstance():getTime()
			local left_time = self.data.end_time - cur_time
			if left_time < 0 then
				left_time = 0
			end
			self.time_tips:setString(string.format(TI18N("请在%s内领取宝箱"), TimeTool.GetTimeFormat(left_time)))
			self.time_tips:setTextColor(cc.c3b(36,144,3))
			self:openBoxAwardTimer(true)
		end
	end
end

-- 剩余领取时间倒计时
function GuildwarAwardBoxWindow:openBoxAwardTimer( status )
	if status == true then
		if not self.box_award_timer then
            self.box_award_timer = GlobalTimeTicket:getInstance():add(function()
            	if self.data then
            		local cur_time = GameNet:getInstance():getTime()
                	local left_time = self.data.end_time - cur_time
                	if left_time < 0 then
                		left_time = 0
                		GlobalTimeTicket:getInstance():remove(self.box_award_timer)
            			self.box_award_timer = nil
                	end
                	self.time_tips:setString(string.format(TI18N("请在%s内领取宝箱"), TimeTool.GetTimeFormat(left_time)))
            	else
            		GlobalTimeTicket:getInstance():remove(self.box_award_timer)
            		self.box_award_timer = nil
            	end
            end, 1)
        end
	else
		if self.box_award_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.box_award_timer)
            self.box_award_timer = nil
        end
	end
end

function GuildwarAwardBoxWindow:close_callback(  )
	if self.box_scrollview then
		self.box_scrollview:DeleteMe()
		self.box_scrollview = nil
	end
	self:openBoxAwardTimer(false)
	_controller:openAwardBoxWindow(false)
end

-----------------------------@ item

GuildwarAwardBoxItem = class("GuildwarAwardBoxItem", function()
    return ccui.Widget:create()
end)

function GuildwarAwardBoxItem:ctor()
	self:configUI()
	self:register_event()
end

function GuildwarAwardBoxItem:configUI(  )
	self.size = cc.size(206, 218)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("guildwar/guildwar_award_box_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.image_box = container:getChildByName("image_box")
    self.name_txt = container:getChildByName("name_txt")
    self.name_txt:setVisible(false)

    self.container:setSwallowTouches(false)
    self.load_image_flag = false -- 是否加载过宝箱图片
end

function GuildwarAwardBoxItem:setData( data )
	if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
    end

	if data ~= nil then
        self.data = data
        if self.update_self_event == nil then
            self.update_self_event = self.data:Bind(GuildwarEvent.UpdateSingleBoxDataEvent, function()
                self:refreshBoxItem()
            end)
        end
        self:refreshBoxItem()
    end
end

function GuildwarAwardBoxItem:refreshBoxItem(  )
	if not self.data then return end

	-- 是否已经被开启
	if self.data.rid == 0 then
		self.container:setTouchEnabled(true)
		self.image_box:setVisible(true)
		self.name_txt:setVisible(false)
		if self.item_node then
			self.item_node:setVisible(false)
		end
		-- 加载金或者铜宝箱，避免重复加载
		if not self.load_image_flag then
			self.load_image_flag = true
			if self.data.status == GuildwarConst.box_type.gold then
				self.image_box:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/guildwar","guildwar_3"), LOADTEXT_TYPE)
			elseif self.data.status == GuildwarConst.box_type.copper then
				self.image_box:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/guildwar","guildwar_4"), LOADTEXT_TYPE)
			end
		end
	else
		self.container:setTouchEnabled(false)
		self.image_box:setVisible(false)
		self.name_txt:setVisible(true)
		if not self.item_node then
			self.item_node = BackPackItem.new(false, true, false)
			self.item_node:setDefaultTip(true)
		    self.item_node:setPosition(cc.p(self.size.width/2, 130))
		    self.container:addChild(self.item_node)
		end
		self.item_node:setVisible(true)
		self.item_node:setBaseData(self.data.item_id, self.data.item_num)
		self.name_txt:setString(self.data.name)
		local role_vo = RoleController:getInstance():getRoleVo()
		if self.data.rid == role_vo.rid and self.data.sid == role_vo.srv_id then
			self.name_txt:setTextColor(cc.c3b(36,144,3))
		else
			self.name_txt:setTextColor(cc.c3b(100,50,35))
		end
	end
end

function GuildwarAwardBoxItem:register_event(  )
	self.container:addTouchEventListener(function ( sender, event_type )
		if event_type == ccui.TouchEventType.began then
			self.touch_began = sender:getTouchBeganPosition()
		elseif event_type == ccui.TouchEventType.ended then
			self.touch_end = sender:getTouchEndPosition()
			local is_click = true
            if self.touch_began ~= nil then
                is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click then
            	playButtonSound2()
            	if self.data then
					_controller:requestGetBoxAward(self.data.order)
				end
            end
		end
	end)
end

function GuildwarAwardBoxItem:suspendAllActions(  )
	if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        self.data = nil
    end
end

function GuildwarAwardBoxItem:DeleteMe(  )
	self:suspendAllActions()
	if self.item_node then
		self.item_node:DeleteMe()
		self.item_node = nil
	end
end