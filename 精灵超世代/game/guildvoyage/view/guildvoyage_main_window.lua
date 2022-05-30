-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会远航主界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildvoyageMainWindow = GuildvoyageMainWindow or BaseClass(BaseView)

local controller = GuildvoyageController:getInstance()
local model = controller:getModel()

function GuildvoyageMainWindow:__init()
	self.win_type = WinType.Big
	self.is_full_screen     = false
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("guildvoyage", "guildvoyage"), type = ResourcesType.plist}
	}
	self.layout_name = "guildvoyage/guildvoyage_main_window"
	self.panel_list = {}
	self.tab_list = {}
	self.cur_panel = nil
end 

function GuildvoyageMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    local main_panel = main_container:getChildByName("main_panel")
    main_panel:getChildByName("win_title"):setString(TI18N("公会远航"))

	self.close_btn = main_panel:getChildByName("close_btn")
    self.explain_btn = main_panel:getChildByName("explain_btn")

	local tab_container = main_panel:getChildByName("tab_container")
    for i=1,3 do
		local object = {}
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local title = tab_btn:getChildByName("title")
            if i == 1 then
                title:setString(TI18N("可接订单"))
            elseif i == 2 then
                title:setString(TI18N("正在护送"))
            elseif i == 3 then
                title:setString(TI18N("互动加速"))
            end
            title:setTextColor(cc.c4b(0xf5, 0xe0, 0xb9, 0xff))
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

function GuildvoyageMainWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openMainWindow(false) 
        end
    end) 
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openMainWindow(false)
		end
	end) 

	self.explain_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
            MainuiController:getInstance():openCommonExplainView(true, Config.GuildShippingData.data_explain) 
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

	-- 红点状态
	if self.update_red_status_event == nil then
		self.update_red_status_event = GlobalEvent:getInstance():Bind(GuildEvent.UpdateGuildRedStatus, function(type, status)
			self:updateSomeRedStatus(type, status)
		end)
	end 
end

function GuildvoyageMainWindow:updateSomeRedStatus(type, status)
	local red_status = false
	local object = nil
	if type == nil then
		red_status = model:getRedStatusByType(GuildConst.red_index.voyage_escort)
		object = self.tab_list[2]
		if object and object.tips then
			object.tips:setVisible(red_status)
		end
		red_status = model:getRedStatusByType(GuildConst.red_index.voyage_interaction)
		object = self.tab_list[3]
		if object and object.tips then
			object.tips:setVisible(red_status)
		end
	else
		if type == GuildConst.red_index.voyage_escort or type == GuildConst.red_index.voyage_temp_escort then -- 可提交
			object = self.tab_list[2]
			if object and object.tips then
				red_status = model:getEscortStatus()
				object.tips:setVisible(red_status)
			end
		elseif type == GuildConst.red_index.voyage_interaction then	-- 互助
			object = self.tab_list[3]
			if object and object.tips then
				object.tips:setVisible(status)
			end
		end
	end
end


function GuildvoyageMainWindow:openRootWnd(index)
    index = index or GuildvoyageConst.index.order
    self:changeSelectedTab(index)
	self:updateSomeRedStatus()
end

function GuildvoyageMainWindow:changeSelectedTab(index)
	if self.tab_object ~= nil and self.tab_object.index == index then return end
	if self.tab_object then
		self.tab_object.tab_btn:setBright(false)
		self.tab_object.label:setTextColor(cc.c4b(245, 224, 185, 255)) 
		self.tab_object = nil
	end
	self.tab_object = self.tab_list[index]
	if self.tab_object then
		self.tab_object.label:setTextColor(cc.c4b(89, 52, 41, 255))
		self.tab_object.tab_btn:setBright(true)
	end

	if self.select_panel then
		self.select_panel:addToParent(false)
		self.select_panel = nil
	end
	self.select_panel = self.panel_list[index]
	if self.select_panel == nil then
		if index == GuildvoyageConst.index.order then
			self.select_panel = GuildVoyageOrderPanel.new()
		elseif index == GuildvoyageConst.index.escort then
			self.select_panel = GuildVoyageEscortPanel.new()
		elseif index == GuildvoyageConst.index.interaction then
			self.select_panel = GuildVoyageInteractionPanel.new()
		end
		self.container:addChild(self.select_panel)
		self.panel_list[index] = self.select_panel
	end
	self.select_panel:addToParent(true)

	-- 取消掉互助的红点
	if index == GuildvoyageConst.index.escort then
		model:updateGuildRedStatus(GuildConst.red_index.voyage_temp_escort, false)
	end
end 

function GuildvoyageMainWindow:close_callback()
	if self.update_red_status_event then
		GlobalEvent:getInstance():UnBind(self.update_red_status_event)
		self.update_red_status_event = nil
	end
    for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
    self.panel_list = nil

    controller:openMainWindow(false)
end