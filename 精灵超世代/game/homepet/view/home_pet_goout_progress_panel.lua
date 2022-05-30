--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年7月1日
-- @description    : 
        -- 萌宠出行历程
---------------------------------
HomePetGooutProgressPanel = HomePetGooutProgressPanel or BaseClass(BaseView)

local controller = HomepetController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format

function HomePetGooutProgressPanel:__init(show_type)
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("homepet_travelling", "homepet_travelling"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_travelling_bg"), type = ResourcesType.single}
    }
    self.layout_name = "homepet/home_pet_goout_progress_panel"


    self.item_list = {}
    self.line_list = {}

    --scrollveiw的参数
    self.start_x = 10
    self.offset_y = 40

    self.homepet_vo = model:getHomePetVo()

    self.show_type = show_type or 1
end

function HomePetGooutProgressPanel:open_callback(  )
      self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")

    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("旅行中"))

    self.close_btn = main_panel:getChildByName("close_btn")
    
    --时间:
    self.time_val = self.main_container:getChildByName("time_val")

    self.item_scrollview = self.main_container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    self.item_scrollview:setSwallowTouches(false)
    self.item_scrollview_size = self.item_scrollview:getContentSize()
    self.item_scrollview_container = self.item_scrollview:getInnerContainer() 
    local container_y = self.item_scrollview_container:getPositionY()
    self.item_scrollview_container:setPositionY(0)

    --宠物跑
    self.mask_layout = self.main_container:getChildByName("mask_layout")
    self.mask_layout_size = self.mask_layout:getContentSize()
    
    self.bg_node = self.mask_layout:getChildByName("bg_node")
    self.pet_node = self.mask_layout:getChildByName("pet_node")
    
    self.btn_goto = self.main_container:getChildByName("btn_goto")
    self.btn_goto:getChildByName("label"):setString(TI18N("行囊"))
end

function HomePetGooutProgressPanel:playEnterAnimatian()
    if not self.main_container then return end
    --写动作
    if self.show_type and self.show_type == 1 then
        commonOpenActionCentreScale(self.main_container)
    else
        commonOpenActionLeftMove(self.main_container)
    end
end

function HomePetGooutProgressPanel:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    registerButtonEventListener(self.close_btn, function() self:onClosedBtn() end ,true, 2)
    -- registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn()  end ,true, 1)
    registerButtonEventListener(self.btn_goto, function() self:onGotoBtn()  end ,true, 1)


     self.item_scrollview:addEventListener(function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.containerMoved then
            self:checkOverShowByVertical()
        end
    end)

    --整体事件
    self:addGlobalEvent(HomepetEvent.HOME_PET_THIS_TIME_ALL_EVENT, function(data)
        if not data then return end
        self:initShowList(data, true)
        self.is_init_data = true
    end)

    self:addGlobalEvent(HomepetEvent.HOME_PET_GO_OUT_NEW_EVENT, function(data)
        if not data then return end
        for i,v in ipairs(data.evt_list) do
            if v.evt_sid == 2 then --2 表示归来
                self:onClosedBtn()
                return
            end
        end
    end)
end

--确定
function HomePetGooutProgressPanel:onClosedBtn()
    controller:openHomePetGooutProgressPanel(false)
end

--
function HomePetGooutProgressPanel:onGotoBtn()
    --去行囊
    -- if not self.main_container then return end
    -- doStopAllActions(self.main_container)
    -- local y = self.main_container:getPositionY()

    -- local moveto = cc.EaseBackOut:create(cc.MoveTo:create(0.3, cc.p(0, y))) 
    -- local fadeOut = cc.FadeOut:create(0.25)
    -- local spawn_action = cc.Spawn:create(moveto, fadeOut)
    -- local callback = function()
    --     self:onClosedBtn()
    -- end
    -- self.main_container:runAction(cc.Sequence:create(spawn_action, cc.CallFunc:create(callback)))
    self:onClosedBtn()

    controller:openHomePetTravellingBagPanel(true, {is_goto = true, show_type = 2})
end

function HomePetGooutProgressPanel:checkOverShowByVertical( )
    if not self.item_list then return end
    local container_y = self.item_scrollview_container:getPositionY()
    local _offset_y =  self.offset_y * 0.5
    local bot = -container_y
    local top = self.item_scrollview_size.height + bot
    for k,item in pairs(self.item_list) do
        local show_data = self.show_list[k]
        if show_data and show_data.size then
            local y = item:getPositionY()
            if y - show_data.size.height > top then
                item:setVisible(false)
            elseif y +  _offset_y   < bot then
                item:setVisible(false)
            else
                item:setVisible(true)
            end
        end
    end

end

--设置倒计时
function HomePetGooutProgressPanel:setLessTime( less_time )
    if tolua.isnull(self.time_val) then return end
    doStopAllActions(self.time_val)
    self:setTimeFormatString(less_time)
    self.time_val:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.DelayTime:create(1), cc.CallFunc:create(function()
        less_time = less_time + 1
        self:checkShowList(less_time)
        self:setTimeFormatString(less_time)
    end)
    )))
end

function HomePetGooutProgressPanel:setTimeFormatString(time)
    self.time_val:setString(TimeTool.GetTimeForFunction(time))
end

function HomePetGooutProgressPanel:openRootWnd(setting)
    if not self.homepet_vo then return end
    local setting = setting or {}
    
    self:runPetTimer()
    self:playPetSpine()
    controller:sender26109()
end

function HomePetGooutProgressPanel:initShowList(data ,is_init)
    if not self.homepet_vo then return end
    --测试用途..记得删除
    -- self.title:setString("城市id:"..tostring(data.city_id))
    self.start_time = data.start_time
    local svr_time = GameNet:getInstance():getTime()
    if self.start_time == 0 then
        self.start_time = svr_time
    end
    self.dic_show_data = {}
    local name = self.homepet_vo:getPetName() or ""
    for i,v in ipairs(data.evt_list) do
        if self.dic_show_data[v.evt_id] == nil then
            if  v.evt_sid == 2 then
                local time = v.time - self.start_time
                self.dic_show_data[v.evt_id] = {evt_id = v.evt_id, show_time = time, evt_sid = v.evt_sid}
            elseif v.evt_sid ~= 1 then
                local config = Config.HomePetData.data_event_info[v.evt_sid]
                if config then
                    local timeStr = TimeTool.getHMS(v.time)
                    local desc = string_format(config.desc, name, name) --第二个是容错的
                    local text = string_format("<div fontcolor=#249003>[%s]</div> %s", timeStr, desc)
                    local time = v.time - self.start_time
                    self.dic_show_data[v.evt_id] = {text = text, evt_id = v.evt_id, show_time = time, evt_sid = v.evt_sid}
                end
            end
        end
    end
    self.show_list = {}
    self.total_list = {}
    self.dic_evt_id = {}
    for k,v in pairs(self.dic_show_data) do
        table_insert(self.total_list, v)
    end
    table_sort(self.total_list, function(a, b) return a.evt_id < b.evt_id end)

    
    if data.start_time == 0 then
        self:setLessTime(0)
        self:checkShowList(0, true)
    else
        local time = svr_time - data.start_time
        self:setLessTime(time)
        self:checkShowList(time, true)
    end
end

function HomePetGooutProgressPanel:checkShowList(less_time, is_init)
    --初始化中..先不处理增加的
    if self.is_init_scroll_view then return end
    local is_update = false
    for i,v in ipairs(self.total_list) do
        if self.dic_evt_id[v.evt_id] == nil then
            if v.show_time <= less_time then
                self.dic_evt_id[v.evt_id] = true
                -- if v.evt_sid == 2 then
                --     --归来了.关闭该页面
                --     self:onClosedBtn()
                --     return 
                -- end
                if v.evt_sid ~= 2 then
                    table_insert(self.show_list, v)
                    is_update = true
                end
            end
        end
    end
    if is_init then
        self:initScrollViewList()
    elseif is_update then
        self:updateList()
    end
end

--萌宠背景出现动态
function HomePetGooutProgressPanel:runPetTimer()
    local res = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_travelling_bg", false)
    self.run_img = {}
    self.run_img[1] = createSprite(res, 0, 0, self.bg_node, cc.p(0, 0), LOADTEXT_TYPE)
    self.run_img_size = self.run_img[1]:getContentSize()
    
    local max_count = math.ceil(self.mask_layout_size.width / self.run_img_size.width) + 1
    for i=2, (max_count + 1) do
        local x = (i - 1) * self.run_img_size.width 
        self.run_img[i] = createSprite(res, x, 0, self.bg_node, cc.p(0, 0), LOADTEXT_TYPE)
    end
    local total_width = max_count* self.run_img_size.width 
    local move_x = total_width - self.run_img_size.width

    local move_to = cc.MoveTo:create(4, cc.p(-move_x, 0))
    local callfunc = cc.CallFunc:create(function() self.bg_node:setPosition(0, 0)  end)
    self.bg_node:runAction(cc.RepeatForever:create(cc.Sequence:create(move_to, callfunc)))
end

function HomePetGooutProgressPanel:playPetSpine(status)
    if status == false then
        if self.pet_spine then
            self.pet_spine:clearTracks()
            self.pet_spine:removeFromParent()
            self.pet_spine = nil
        end
    else
        if self.pet_spine == nil then
            self.pet_spine = createEffectSpine("H65005", cc.p(0, 0), cc.p(0.5, 0.5), true, PlayerAction.idle)
            -- self.pet_spine = createEffectSpine("E24177", cc.p(0, 0), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.pet_node:addChild(self.pet_spine, 1)
        end
    end
end
--保留代码
function HomePetGooutProgressPanel:runPetAction()
    -- local res = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_mask", false)
    -- -- self.mark_bg = createSprite(res, 0, 0, self.mask_layout, cc.p(0.5, 0.5), LOADTEXT_TYPE, 1)
    -- self.mask = createSprite(res, 0, 0, nil, cc.p(0.5, 0.5), LOADTEXT_TYPE)
    -- self.vSize = self.mask:getContentSize()
    -- self.clipNode = cc.ClippingNode:create(self.mask)
    -- self.clipNode:setAnchorPoint(cc.p(0.5,0.5))
    -- -- self.clipNode:setContentSize(self.vSize)
    -- self.clipNode:setCascadeOpacityEnabled(true)
    -- self.clipNode:setPosition(0, 0)
    -- self.clipNode:setAlphaThreshold(0)
    -- self.mask_layout:addChild(self.clipNode, 2)

    -- self.icon = createSprite(res, 0, 0, nil, cc.p(0.5, 0.5), LOADTEXT_TYPE)
    -- self.icon:setCascadeOpacityEnabled(true)
    -- self.icon:setAnchorPoint(0.5,0.5)
    -- self.icon:setPosition(0, 0)
    -- self.clipNode:addChild(self.icon,3)

    -- local call_back = function()
        
    -- end
    -- GlobalTimeTicket:getInstance():add(call_back, 0.02, 0, "homepet_goout_progress_timer") --添加
end

function HomePetGooutProgressPanel:updateList()
    if not self.show_list then return end
    if tolua.isnull(self.item_scrollview) then return end

    -- for i,v in ipairs(self.item_list) do
    --     v:setVisible(false)
    --     if self.line_list[i] then
    --         self.line_list[i]:setVisible(false)
    --     end
    -- end
    local lenght = #self.show_list
    if lenght == 0 then
        commonShowEmptyIcon(self.item_scrollview, true, {text = TI18N("暂无出行信息"), label_color = Config.ColorData.data_new_color4[1], line_color = Config.ColorData.data_new_color4[5]})
    else
        commonShowEmptyIcon(self.item_scrollview, false)
    end
    local x = self.start_x or 10
    local y = 0
    local offset_y = self.offset_y or 40 -- y方向的间隔

    for i=1,lenght do
        local show_data = self.show_list[i] 
        if self.item_list[i] == nil then
            self.item_list[i] = self:createItemLabel()
        else
            self.item_list[i]:setVisible(true)
        end

        if show_data.size == nil then
            self.item_list[i]:setString(show_data.text)
            local size = self.item_list[i]:getContentSize()
            self.item_list[i].line:setPositionY(size.height + offset_y * 0.5) 
            show_data.size = size    
        end
        
        show_data.y = y
        -- self.item_list[i]:setPosition(x, y)
        y = y + show_data.size.height + offset_y
    end
    local total_height = y - offset_y


    local max_height = math.max(self.item_scrollview_size.height, total_height)
    self.item_scrollview:setInnerContainerSize(cc.size(self.item_scrollview_size.width,max_height))

    for i=1,lenght do
        local show_data = self.show_list[i]
        y = show_data.y or 0
        self.item_list[i]:setPosition(x, max_height - y)
    end

    if max_height == self.item_scrollview_size.height then
        self.item_scrollview:setTouchEnabled(false)
    else
        self.item_scrollview:setTouchEnabled(true)
    end
    self.item_scrollview_container:setPositionY(0)
    self:checkOverShowByVertical()
end

function HomePetGooutProgressPanel:initScrollViewList()
    if not self.show_list then return end
    if tolua.isnull(self.item_scrollview) then return end
    self.is_init_scroll_view = true
    local lenght = #self.show_list
    if lenght == 0 then
        commonShowEmptyIcon(self.item_scrollview, true, {text = TI18N("暂无出行信息"), label_color = Config.ColorData.data_new_color4[1], line_color = Config.ColorData.data_new_color4[5]})
        self.is_init_scroll_view = false
        return
    else
        commonShowEmptyIcon(self.item_scrollview, false)
    end
   

    local x = self.start_x or 10
    local y = 0
    local offset_y = self.offset_y or 40 -- y方向的间隔
    local screen_count = 8 --一屏最大的显示数量

    for i=lenght,lenght - screen_count + 1, -1 do
        local show_data = self.show_list[i] 
        if not show_data then break end

        if self.item_list[i] == nil then
            self.item_list[i] = self:createItemLabel()
        else
            self.item_list[i]:setVisible(true)
        end

        if show_data.size == nil then
            self.item_list[i]:setString(show_data.text)
            local size = self.item_list[i]:getContentSize()
            self.item_list[i].line:setPositionY(size.height + offset_y * 0.5) 
            show_data.size = size    
        end
        show_data.top_y = y
        y = y + show_data.size.height
        show_data.y = y 
        -- self.item_list[i]:setPosition(x, y)
        y = y + offset_y
    end
    local total_height = y
    if lenght <= screen_count then 
        total_height = y - offset_y
    end

    local max_height = math.max(self.item_scrollview_size.height, total_height)
    local container_y = self.item_scrollview_container:getPositionY()
    self.item_scrollview:setInnerContainerSize(cc.size(self.item_scrollview_size.width,max_height))

    local is_start_time_ticket = false
    if total_height  < self.item_scrollview_size.height then
        --说明最初显示的不够一屏幕
        for i=1,lenght do
            local show_data = self.show_list[i]
            y = (max_height - total_height) + show_data.y
            self.item_list[i]:setPosition(x, y)
        end
        self.is_init_scroll_view = false
    else
        for i=lenght,lenght - screen_count + 1, -1 do
            local show_data = self.show_list[i]
            if not show_data then break end
            y = show_data.y or 0
            self.item_list[i]:setPosition(x, y)
        end
        --超过一屏幕.并且超过当前选定的数量 需要分帧处理
        if lenght > screen_count then
            is_start_time_ticket = true
        else
            self.is_init_scroll_view = false
        end
    end

    if max_height == self.item_scrollview_size.height then
        self.item_scrollview:setTouchEnabled(false)
    else
        self.item_scrollview:setTouchEnabled(true)
    end
    self.item_scrollview_container:setPositionY(0)
    self:checkOverShowByVertical()

    --是否需要开始定时器
    if is_start_time_ticket then
        local frame_index = lenght - screen_count
        local _callback = function()
            self:initFrameData(frame_index)
            frame_index = frame_index - 1
            if frame_index <= 0 then
                self.is_init_scroll_view = false
                if self.time_ticket ~= nil then
                    GlobalTimeTicket:getInstance():remove(self.time_ticket)
                    self.time_ticket = nil
                end
            end
        end

        self.time_ticket = GlobalTimeTicket:getInstance():add(_callback, 1 / display.DEFAULT_FPS)
    end
end
function HomePetGooutProgressPanel:createItemLabel()
    local item_label = createRichLabel(24, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,1), cc.p(-10000,0), 8, nil, 580)
    local res = PathTool.getResFrame("common","common_1016")
    local line = createImage(item_label, res, 290, 0, cc.p(0.5,0.5), true, 0, true)
    line:setContentSize(cc.size(560,2))
    line:setCapInsets(cc.rect(13, 1, 1, 1))
    item_label.line = line
    self.item_scrollview:addChild(item_label)
    return item_label
end


--处理分帧数据
function HomePetGooutProgressPanel:initFrameData(frame_index)
    if not self.show_list then return end
    if tolua.isnull(self.item_scrollview) then return end
    local i = frame_index
    local show_data = self.show_list[i] 
    if not show_data then return end
    if self.item_list[i] == nil then
        self.item_list[i] = self:createItemLabel()
    else
        self.item_list[i]:setVisible(true)
    end
    local offset_y = self.offset_y or 40
    if show_data.size == nil then
        self.item_list[i]:setString(show_data.text)
        local size = self.item_list[i]:getContentSize()
        self.item_list[i].line:setPositionY(size.height + offset_y * 0.5) 
        show_data.size = size    
    end
    
    --当前的高度
    local max_height = self.item_scrollview:getInnerContainerSize().height
    local x = self.start_x or 10
    self.item_list[i]:setPosition(x, max_height + show_data.size.height)
    if frame_index == 1 then
        max_height = max_height + show_data.size.height
        self.item_list[i].line:setVisible(false)
    else
        max_height = max_height + show_data.size.height + offset_y
    end
    local container_y = self.item_scrollview_container:getPositionY()
    self.item_scrollview:setInnerContainerSize(cc.size(self.item_scrollview_size.width, max_height))
    self.item_scrollview_container:setPositionY(container_y)
    self:checkOverShowByVertical()
end

function HomePetGooutProgressPanel:close_callback()

    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
    -- GlobalTimeTicket:getInstance():remove("homepet_goout_progress_timer") -- 移除
    self:playPetSpine(false)
    doStopAllActions(self.time_val)
    controller:openHomePetGooutProgressPanel(false)
end