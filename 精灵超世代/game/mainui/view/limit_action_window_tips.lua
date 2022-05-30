-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      限时活动的tips界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
LimitActionWindowTips = LimitActionWindowTips or BaseClass(BaseView)

local controller = MainuiController:getInstance()
local table_insert = table.insert
local string_format = string.format
local game_net = GameNet:getInstance()

function LimitActionWindowTips:__init(  )
    self.view_tag = ViewMgrTag.TOP_TAG
    self.win_type = WinType.Tips
	self.layout_name = "mainui/limit_action_window_tips"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("limitactiontips", "limitactiontips"), type = ResourcesType.plist},
	} 
end

function LimitActionWindowTips:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_panel = self.root_wnd:getChildByName("main_panel")
    self.check_panel = main_panel:getChildByName("check_panel")
    self.check_panel:getChildByName("label"):setString(TI18N("查看全天活动"))

    self.list_view = main_panel:getChildByName("list_view")
    self.item = main_panel:getChildByName("item")
    self.item:setVisible(false)

    local size = self.list_view:getContentSize()
	local setting = {
		item_class = LimitActionTipsItem,
		start_x = 6,
		space_x = 0,
		start_y = 7,
		space_y = 0,
		item_width = 376,
		item_height = 100,
		row = 0,
		col = 1,
		need_dynamic = true
	}
	self.scroll_view = CommonScrollViewLayout.new(self.list_view, nil, nil, nil, size, setting)
end

function LimitActionWindowTips:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
           controller:openLimitActionTips(false)
        end
    end)
    self.check_panel:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
			controller:changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.limit_action)
           	controller:openLimitActionTips(false)
        end
    end)
end

function LimitActionWindowTips:openRootWnd()
	local list = {}
	for k,v in pairs(Config.FunctionData.data_limit_action) do
		local vo = controller:getFucntionIconVoById(v.id)
		local data = DeepCopy(v)
		data.status = 3 
		data.end_time = 0
		data.show_line = true
		data.is_open = controller:checkMainFunctionOpenStatus(v.id, MainuiConst.function_type.other, true)
		if vo then
			data.status = vo.status or 3
			data.end_time = vo.end_time or 0
		end
		table_insert(list, data)
	end
	if list and next(list) then
		local sort_func = SortTools.tableLowerSorter({"status", "end_time", "id"})
		table.sort(list, sort_func)

		-- 最后一个不需要显示线
		list[#list].show_line = false

		local function call_back(data)
			self:clickItem(data)
		end
	    self.scroll_view:setData(list, call_back, nil, self.item) 
	end

	-- 统一一个定时器就好了
	if self.time_ticket == nil then
		self.time_ticket = GlobalTimeTicket:getInstance():add(function() 
			self:countTimeTicket()
		end, 1)
	end
end

function LimitActionWindowTips:countTimeTicket()
	local item_list = self.scroll_view:getItemList()
	if item_list then
		for k,v in pairs(item_list) do
			if v.setCoolTime then
				v:setCoolTime()
			end
		end
	end
end

function LimitActionWindowTips:clearTimeTicket()
	if self.time_ticket then
		GlobalTimeTicket:getInstance():remove(self.time_ticket)
		self.time_ticket = nil
	end
end

function LimitActionWindowTips:clickItem(data)
	if data == nil then return end
	if data.id == MainuiConst.icon.godbattle and data.status ~= 1 and data.status ~= 2 then
		controller:changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.limit_action)
	else
		controller:changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.function_icon, data.id)	
	end

	-- 关掉界面
    controller:openLimitActionTips(false)
end

function LimitActionWindowTips:close_callback()
	self:clearTimeTicket()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
    end
    self.scroll_view = nil
    controller:openLimitActionTips(false)
end

 
-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      被掠夺单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
LimitActionTipsItem = class("LimitActionTipsItem", function()
	return ccui.Layout:create()
end)

function LimitActionTipsItem:ctor()
	self.is_completed = false
	self.is_open = true
end

function LimitActionTipsItem:setExtendData(node)
	if not tolua.isnull(node) and self.root_wnd == nil then
		self.is_completed = true
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)

        self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5) 
		self.root_wnd:setTouchEnabled(true)
		self:addChild(self.root_wnd)

        self.icon = self.root_wnd:getChildByName("icon")
        self.icon:ignoreContentAdaptWithSize(true)

        self.line = self.root_wnd:getChildByName("line")
        self.status_icon = self.root_wnd:getChildByName("status_icon")
        self.item_name = self.root_wnd:getChildByName("name") 
        self.item_time = self.root_wnd:getChildByName("time")
		
		self:registerEvent()
	end
end

function LimitActionTipsItem:registerEvent()
	self.root_wnd:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data then
				if self.call_back and self.data.is_open == true then
					self.call_back(self.data)
				else
					message(self.data.desc)
				end
			end
		end
	end)
end

function LimitActionTipsItem:setData(data)
	self.data = data
	if data then
		if data.status == 2 then
			self.item_time:setTextColor(cc.c4b(0x55,0xec,0x45,0xff))
		else
			self.item_time:setTextColor(cc.c4b(0xcf,0xbe,0xa3,0xff))
		end
		self.item_name:setString(data.icon_name)

		-- 图标样式
		local target_res = PathTool.getFunctionRes(data.icon_res)
		if target_res ~= self.res_id then
			self.res_id = target_res
			self.icon:loadTexture(target_res, LOADTEXT_TYPE)
		end

		if data.status == 1 then 		-- 准备阶段
			self.status_icon:loadTexture(PathTool.getResFrame("limitaction", "limitaction_5"), LOADTEXT_TYPE_PLIST)
		elseif data.status == 2 then 	-- 进行中
			self.status_icon:loadTexture(PathTool.getResFrame("limitaction", "limitaction_4"), LOADTEXT_TYPE_PLIST)
		else
			self.status_icon:loadTexture(PathTool.getResFrame("limitaction", "limitaction_6"), LOADTEXT_TYPE_PLIST)
		end
		self.line:setVisible(data.show_line or false)

		if data.status == 3 then
			-- 这里需要判断功能是否开启
			if data.is_open == false then
				self.item_time:setString(data.desc)
			else
				self.item_time:setString(TI18N("活动暂未开启"))
			end
		else
			self:setCoolTime()
		end
	end
end

function LimitActionTipsItem:setCoolTime()
	if self.data == nil or self.data.status == 3 then return end
	local time = self.data.end_time - game_net:getTime()
	if time < 0 then time = 0 end
	local time_desc = ""
	if self.data.status == 1 then
		time_desc = string_format(TI18N("%s后开启"),TimeTool.GetTimeForFunction(time))
	elseif self.data.status == 2 then
		time_desc = string_format(TI18N("%s后结束"),TimeTool.GetTimeForFunction(time))
	end

	if time == 0 then
		time_desc = ""
	end

	if self.time_desc ~= time_desc then
		self.time_desc = time_desc
		self.item_time:setString(time_desc)
	end
end

function LimitActionTipsItem:addCallBack(call_back)
	self.call_back = call_back
end

function LimitActionTipsItem:suspendAllActions()
end

function LimitActionTipsItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end 