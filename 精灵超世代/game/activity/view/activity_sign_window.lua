-- --------------------------------------------------------------------
-- 能用报名面板
-- 
-- @author: whjing2012@163.com(必填, 创建模块的人员)
-- @editor: whjing2012@163.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

ActivitySignWindow = ActivitySignWindow or BaseClass(BaseView)
local controller = ActivityController:getInstance()

function ActivitySignWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Tips
    self.item_list = {}
    self.layout_name = "activity/activity_sign_window"
end

function ActivitySignWindow:open_callback()
    self.main_panel = self.root_wnd:getChildByName("main_panel")

    self.background = self.root_wnd:getChildByName("background")
    self.background:setTouchEnabled(true)
    self.background:setScale(display.getMaxScale())

    self.main_container = self.main_panel:getChildByName("main_container")
    -- self:playEnterAnimatianByObj(self.main_container, 2)
    self.label = createRichLabel(24, 175, cc.p(0, 0.5), cc.p(30,52), nil, nil, 500)
    self.main_container:addChild(self.label)

    self.item_container = self.main_panel:getChildByName("item_container")
    local Text_1 = self.item_container:getChildByName("Text_1")
    local Text_1_en = self.item_container:getChildByName("Text_1_en")

    showLabelByCode(Text_1, Text_1_en)

    self.item_view = self.item_container:getChildByName("item_view")
	self.item_view:setScrollBarEnabled(false)
    self.item_view:setSwallowTouches(false)

    self.ok_btn = self.main_panel:getChildByName("ok_btn")
    self.ok_btn_label = self.ok_btn:getChildByName("label")
    self.cancel_btn = self.main_panel:getChildByName("cancel_btn")
    self.cancel_btn_label = self.cancel_btn:getChildByName("label")
    self.close_btn = self.main_panel:getChildByName("close_btn")
    -- local btnLabel = self.cancel_btn:getTitleRenderer()
    -- if btnLabel ~= nil then
    -- 	btnLabel:enableOutline(Config.ColorData.data_color4[278], 2)
    -- end
    -- btnLabel = self.ok_btn:getTitleRenderer()
    -- if btnLabel ~= nil then
    -- 	btnLabel:enableOutline(Config.ColorData.data_color4[277], 2)
    -- end
end

function ActivitySignWindow:openRootWnd(id, data)
    if id == nil then return end
    local config = Config.ActivityData.data_sign_info[id]
    if config == nil then return end
    self.id = id
    self.time = config.time
    self.label:setString(config.desc)
    self:createItemList(config.items)
    -- self.cancel_btn:setTitleText(config.cancel)
    -- self.ok_btn:setTitleText(config.ok)
    self.cancel_btn_label:setString(config.cancel)
    self.ok_btn_label:setString(config.ok)
    if data and data.timer then
        self:setTimer(config)
    end
end

function ActivitySignWindow:createItemList(list)
    if list == nil or next(list) == nil then return end
    if not self.item_list then return end
    if self.item_list then
        for i, item in ipairs(self.item_list) do
            item:suspendAllActions()
            item:setVisible(false)
        end
    end
    if self.item_list == nil then return end
    
    local item = nil
    local scale = 0.8
    local off = 6
    local _x, _y = 0, 2
    local sum = #list
    local item_conf = nil
    local total_width = sum * BackPackItem.Width * scale + (sum - 1) * off
    local start_x = 0
    local index = 1

    local max_width = math.max(self.item_view:getContentSize().width, total_width)
    self.item_view:setInnerContainerSize(cc.size(max_width, self.item_view:getContentSize().height))
    for i, v in ipairs(list) do
        local bid = v
        local num = 1
        item_conf = Config.ItemData.data_get_data(bid)
        if item_conf then
            item = self.item_list[index]
            if item == nil then
                item = BackPackItem.new(false, true, false, scale, false, true)
                table.insert(self.item_list, item)
                self.item_view:addChild(item)
            end
            _x = start_x + (BackPackItem.Width * scale + off) * (index-1) + BackPackItem.Width*scale*0.5
            item:setBaseData(bid, num)
            item:setDefaultTip(true,false)
            item:setAnchorPoint(cc.p(0.5, 0))
            item:setPosition(_x, _y)
            item:setVisible(true)
            index = index + 1
        end
    end 
end

function ActivitySignWindow:setTimer()
    local config = Config.ActivityData.data_sign_info[self.id]
    if self.time == nil or self.time < 1 then return end
    if self.timer_id then
        GlobalTimeTicket:getInstance():remove(self.timer_id)
    end
    self.timer_id = GlobalTimeTicket:getInstance():add(function()
        self.time = self.time - 1
        if self.time == 0 then
            controller:openSignView(false) 
        elseif not tolua.isnull(self.cancel_btn) then
            -- self.cancel_btn:setTitleText(string.format("%s(%s)", config.cancel, self.time))
            self.cancel_btn_label:setString(string.format("%s(%s)", config.cancel, self.time))
        end
    end, 1, self.time)
    -- self.cancel_btn:setTitleText(string.format("%s(%s)", config.cancel, self.time))
    self.cancel_btn_label:setString(string.format("%s(%s)", config.cancel, self.time))
end

function ActivitySignWindow:register_event()
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                controller:openSignView(false) 
            end
        end)
    end
    if self.cancel_btn then
        self.cancel_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                controller:openSignView(false) 
            end
        end)
    end
    if self.ok_btn then
        self.ok_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                self:clickHandle()
                controller:openSignView(false) 
            end
        end)
    end
end

function ActivitySignWindow:clickHandle()
    if self.id == ActivitySignType.arena_champion then
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.champion_call)
    elseif self.id == ActivitySignType.arena_champion_guess then
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.champion_call)
    elseif self.id == ActivitySignType.godbattle or self.id == ActivitySignType.godbattle_sign then
        if GodbattleController:getInstance():getModel():getApplyStatus() == GodBattleConstants.apply_status.un_apply then
            GodbattleController:getInstance():requestApplyGodBattle()
        else
            GodbattleController:getInstance():requestEnterGodBattle()
        end
    elseif self.id == ActivitySignType.cross_champion or self.id == ActivitySignType.cross_champion_guess then
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.crosschampion)
    elseif self.id == ActivitySignType.peak_champion or self.id == ActivitySignType.peak_champion_guess then
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.peakchampion)
    end
end

function ActivitySignWindow:close_callback()
    if self.item_list then
        for i, item in ipairs(self.item_list) do
            item:DeleteMe()
        end
    end
    if self.timer_id then
        GlobalTimeTicket:getInstance():remove(self.timer_id)
    end
    self.item_list = nil
end
