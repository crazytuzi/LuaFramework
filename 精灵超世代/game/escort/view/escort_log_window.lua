-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      护送记录
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EscortLogWindow = EscortLogWindow or BaseClass(BaseView)

local controller = EscortController:getInstance()

function EscortLogWindow:__init()
    self.is_full_screen = false
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.layout_name = "escort/escort_log_window"
	self.panel_list = {}
	self.tab_list = {}
	self.cur_panel = nil
	self.res_list = {
	}
	self.log_type_list = {}
end

function EscortLogWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)
    local main_panel = main_container:getChildByName("main_panel")
    main_panel:getChildByName("win_title"):setString(TI18N("掠夺记录"))

	self.close_btn = main_panel:getChildByName("close_btn")

	local tab_container = main_panel:getChildByName("tab_container")
    for i=1,2 do
		local object = {}
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local title = tab_btn:getChildByName("title")
            if i == 1 then
                title:setString(TI18N("谁掠夺我"))
            elseif i == 2 then
                title:setString(TI18N("掠夺他人"))
            end
            title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
            tab_btn:setBright(false)
			local tips = tab_btn:getChildByName("tips")

            object.tab_btn = tab_btn
			object.label = title
			object.index = i
			object.tips = tips
            self.tab_list[i] = object
        end
    end
	self.container = main_panel:getChildByName("container")
end

function EscortLogWindow:register_event()
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openEscortLogWindow(false)
		end
	end) 

	for k, object in pairs(self.tab_list) do
		if object.tab_btn then
			object.tab_btn:addTouchEventListener(function(sender, event_type)
				if event_type == ccui.TouchEventType.ended then
					playTabButtonSound()
					self:changeSelectedTab(object.index)
				end
			end)
		end
    end

	if self.update_escort_log_event == nil then
		self.update_escort_log_event = GlobalEvent:getInstance():Bind(EscortEvent.UpdateEscortLogInfoEvent, function(data)
			if data == nil or data.type == nil or self.tab_object == nil then return end
			self.log_type_list[data.type] = data.logs
			if self.tab_object.index == data.type and self.select_panel then
				self.select_panel:setData(data.logs)
			end
		end)
	end
	if self.update_single_log_event == nil then
		self.update_single_log_event = GlobalEvent:getInstance():Bind(EscortEvent.UpdateEscortSingleLogInfo, function(data)
			if data == nil or data.id == nil then return end
			self:insertToAtkLog(data)
		end)
	end
end

--==============================--
--desc:往掠夺日志里面去更新东西
--time:2018-09-04 11:18:01
--@data:
--@return 
--==============================--
function EscortLogWindow:insertToAtkLog(data)
	if self.log_type_list[EscortConst.log_type.def] == nil then return end
	local need_update = false
	for k,v in pairs(self.log_type_list[EscortConst.log_type.def]) do
		if v.id == data.id then
			self.log_type_list[EscortConst.log_type.def][k] = data
			need_update = true
			break
		end
	end
	-- 只有在被掠夺界面的时候才需要刷新数据
	if need_update == true and self.tab_object and self.tab_object.index == EscortConst.log_type.def and self.select_panel then
		self.select_panel:refreshData(self.log_type_list[EscortConst.log_type.def])
	end
end

function EscortLogWindow:openRootWnd(index)
    index = index or GuildvoyageConst.index.order
    self:changeSelectedTab(index)
end

function EscortLogWindow:changeSelectedTab(index)
	if self.tab_object ~= nil and self.tab_object.index == index then return end
	if self.tab_object then
		self.tab_object.tab_btn:setBright(false)
		self.tab_object.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
		self.tab_object = nil
	end
	self.tab_object = self.tab_list[index]
	if self.tab_object then
		self.tab_object.label:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
		self.tab_object.tab_btn:setBright(true)
	end

	if self.select_panel then
		self.select_panel:addToParent(false)
		self.select_panel = nil
	end

	self.select_panel = self.panel_list[index]
	if self.select_panel == nil then
		if index == EscortConst.log_type.def then
			self.select_panel = EscortLogDefPanel.New(self.container)
		elseif index == EscortConst.log_type.atk then
            self.select_panel = EscortLogAtkPanel.New(self.container)
		end

        if self.select_panel then
		    self.panel_list[index] = self.select_panel
        end
	end
    if self.select_panel then
	    self.select_panel:addToParent(true)
    end
end 

function EscortLogWindow:close_callback()
	if self.update_escort_log_event then
		GlobalEvent:getInstance():UnBind(self.update_escort_log_event)
		self.update_escort_log_event = nil
	end
	if self.update_single_log_event then
		GlobalEvent:getInstance():UnBind(self.update_single_log_event)
		self.update_single_log_event = nil
	end

    for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
    self.panel_list = nil
    controller:openEscortLogWindow(false)
end
