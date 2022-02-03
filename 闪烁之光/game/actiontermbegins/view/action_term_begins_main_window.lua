-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      活动主界面
--      开学季活动boss战 后端 锦汉 策划 建军 
-- <br/> 2019年8月22日
-- --------------------------------------------------------------------
ActiontermbeginsMainWindow = ActiontermbeginsMainWindow or BaseClass(BaseView)

local controller = ActiontermbeginsController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function ActiontermbeginsMainWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full
    self.layout_name = "actiontermbegins/action_term_begins_main_window"
    self.res_list = {
        -- {path = PathTool.getPlistImgForDownLoad("heroresonate", "heroresonate"), type = ResourcesType.plist},
        -- { path = string_format("", "action"), type = ResourcesType.single },
    }

    self.view_list = {}

    self.paper_item_id = 1
    local config = Config.HolidayTermBeginsData.data_const.paper_item_id
    if config then
        self.paper_item_id = config.val
    end

    --准考证id
    self.ticket_item_id = 1
    local config = Config.HolidayTermBeginsData.data_const.ticket_item_id
    if config then
        self.ticket_item_id = config.val
    end
end

function ActiontermbeginsMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self:setBackgroundImg("term_begins_chapter_bg")

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_container:setZOrder(2)
    self.container = self.main_container:getChildByName("container")

    -- self.spirit_btn = self.main_container:getChildByName("spirit_btn")
    -- self.spirit_btn:getChildByName("label"):setString(TI18N("魔液炼金"))

    self.close_btn = self.main_container:getChildByName("close_btn")

    self.top_panel = self.main_container:getChildByName("top_panel")
    local tab_name_list = {
        [1] = TI18N("关卡大挑战"),
        [2] = TI18N("boss大挑战")
    }
    self.tab_list = {}
    self.tab_container = self.top_panel:getChildByName("tab_container")
    for i=1,2 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.unselect_bg:setVisible(true)
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            -- object.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
            object.lable = tab_btn:getChildByName("title")
            object.lable:setString(tab_name_list[i])
            object.tab_btn = tab_btn
            object.index = i
            self.tab_list[i] = object
        end
    end
    self:adaptationScreen()
end

--设置适配屏幕
function ActiontermbeginsMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)
    local left_x = display.getLeft(self.main_container)
    local right_x = display.getRight(self.main_container)

    local container_size = self.main_container:getContentSize()
    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (container_size.height - tab_y))

    -- local spirit_btn_y = self.spirit_btn:getPositionY()
    -- self.spirit_btn:setPositionY(top_y - (container_size.height - spirit_btn_y))
    -- self.spirit_btn_x, self.spirit_btn_y = self.spirit_btn:getPosition()


    -- local bottom_panel_y = self.bottom_panel:getPositionY()
    -- self.bottom_panel:setPositionY(bottom_y + bottom_panel_y)
    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(bottom_y + close_btn_y)


    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
end

function ActiontermbeginsMainWindow:setBackgroundImg(bg_name)
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/termbegins", bg_name, true)
    if self.record_bg_res ~= bg_res then
        self.record_bg_res = bg_res
        self.item_load_bg = loadImageTextureFromCDN(self.background, bg_res, ResourcesType.single, self.item_load_bg) 
    end
end


function ActiontermbeginsMainWindow:register_event()
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    -- registerButtonEventListener(self.spirit_btn, handler(self, self.onClickBtnSpirit) ,true, 1)

    -- registerButtonEventListener(self.tip_btn, function(param,sender, event_type) 
    --     local config = Config.PartnerData.data_partner_const.game_rule1
    --     TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
    -- end ,true, 1)

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

    -- 开学副本基础信息
    self:addGlobalEvent(ActiontermbeginsEvent.TERM_BEGINS_MAIN_EVENT, function(data)
        if not data then return end
        self.scdata = data
        self:initData()
        for k,panel in pairs(self.view_list) do
            if panel.setScdata then
                 panel:setScdata(data)
            end
        end
        self:initTimeOut()
        self:updateLeftRedPoint()
        self:updateRightRedPoint()
    end)

    --  增加物品的更新,红点
    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code, add_list)
        self:updateRightRedPoint()
    end)

    -- 删除一个物品更新,红点
    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code,del_list)
        self:updateRightRedPoint()
    end)

    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,change_list)
        self:updateRightRedPoint()
    end)

    self:addGlobalEvent(ActiontermbeginsEvent.TERM_BEGINS_PAPER_REWARD_LIST_EVENT, function(data)
        if not data then return end
        self.paper_reward_scdata = data
        self:updateRightRedPoint()

        if self.view_list[ActiontermbeginsConstants.TabType.eBoss] then
            self.view_list[ActiontermbeginsConstants.TabType.eBoss]:updateRewardBtnRedpoint()
        end
    end)

    --奖励领取了更新红点
    self:addGlobalEvent(ActiontermbeginsEvent.TERM_BEGINS_REWARD_REDPOINT_EVENT, function(data)
        if not data then return end
        if not self.paper_reward_scdata then return end
        for i,v in ipairs(self.paper_reward_scdata.collect_schedule) do
            if v.id == data.id then
                v.staus = 2
            end
        end
        -- self:updateRightRedPoint()
        if self.view_list[ActiontermbeginsConstants.TabType.eBoss] then
            self.view_list[ActiontermbeginsConstants.TabType.eBoss]:updateRewardBtnRedpoint()
        end
    end)
end

function ActiontermbeginsMainWindow:initTimeOut()
    if not self.scdata then return end
    local time = self.scdata.end_time - GameNet:getInstance():getTime()
    if time <= 0 then
        time = 0
        self.is_time_out = true
    else
        if self.time_ticket == nil then
            local _callback = function()
                time = time - 1
                if time <= 0 then
                    self.is_time_out = true
                    self:updateLeftRedPoint()
                    self:updateRightRedPoint()
                    self:clearTimeTicket()
                end 
            end
            self.time_ticket = GlobalTimeTicket:getInstance():add(_callback, 1)
        end
    end
end

function ActiontermbeginsMainWindow:clearTimeTicket()
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end 

function ActiontermbeginsMainWindow:updateLeftRedPoint()
    if not self.scdata then return end
    if not self.select_index then return end
    if self.select_index ~= ActiontermbeginsConstants.TabType.eChapter then
        local max_chapter_id = Config.HolidayTermBeginsData.data_max_chapter_id[self.scdata.round] or 0
        if not self.is_time_out and self.scdata.cha_count > 0 and self.scdata.order < max_chapter_id  then
            self:updateRedPointByindex(ActiontermbeginsConstants.TabType.eChapter, true)
        else
            self:updateRedPointByindex(ActiontermbeginsConstants.TabType.eChapter, false)
        end
    else
        self:updateRedPointByindex(ActiontermbeginsConstants.TabType.eChapter, false) 
    end
end

function ActiontermbeginsMainWindow:updateRightRedPoint()
    if not self.scdata then return end
    if not self.paper_reward_scdata then return end
    if not self.select_index then return end
    if self.select_index ~= ActiontermbeginsConstants.TabType.eBoss then
        local count = 0 
        local cur_item_id 
        if self.scdata.boss_flag == 1 then --开启boss 显示的准考证
            count = BackpackController:getInstance():getModel():getItemNumByBid(self.ticket_item_id) 
        end
        local count2 = BackpackController:getInstance():getModel():getItemNumByBid(self.paper_item_id)

        local is_receive = false
        for i,v in ipairs(self.paper_reward_scdata.collect_schedule) do
            if v.staus == 1 then
                is_receive = true
                break
            end
        end

        if not self.is_time_out and (count > 0 or count2 > 0 or is_receive) then
            self:updateRedPointByindex(ActiontermbeginsConstants.TabType.eBoss, true)
        else
            self:updateRedPointByindex(ActiontermbeginsConstants.TabType.eBoss, false)
        end
    else
        self:updateRedPointByindex(ActiontermbeginsConstants.TabType.eBoss, false)
    end
end

function ActiontermbeginsMainWindow:updateRedPointByindex(index, status)
    local object = self.tab_list[index]
    local status = status or false
    if object then
        if index == 1 then
            addRedPointToNodeByStatus(object.tab_btn, status, -130, 5)
        else
            addRedPointToNodeByStatus(object.tab_btn, status, 0, 5)
        end
    end
end

function ActiontermbeginsMainWindow:onClickBtnClose()
    controller:openActiontermbeginsMainWindow(false)
end


-- 切换标签页
function ActiontermbeginsMainWindow:changeSelectedTab(index, not_check)
    -- if not self.scdata then return end
    if self.is_move_effect then return end
    if not not_check and self.tab_object ~= nil and self.tab_object.index == index then return end
    --标识是否改变页签的
    local is_change_tab = false
    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        -- self.tab_object.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
        self.tab_object = nil
        is_change_tab = true
    end
    self.select_index = index
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        -- self.tab_object.label:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
    end
    if index == ActiontermbeginsConstants.TabType.eChapter then
        self:setBackgroundImg("term_begins_chapter_bg")
    else
        self:setBackgroundImg("term_begins_boss_bg")
    end

    self:updateLeftRedPoint()
    self:updateRightRedPoint()

    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(false)
        else
            self.pre_panel:setVisible(false)
        end
    end
    self.pre_panel = self:createSubPanel(self.select_index)
    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(true)
        else
            self.pre_panel:setVisible(true)
        end
    end
    self.pre_panel:setData()
end

function ActiontermbeginsMainWindow:createSubPanel(index)
    local panel = self.view_list[index]
    if panel == nil then
       if index == ActiontermbeginsConstants.TabType.eChapter then
            --关卡
            panel = ActiontermbeginsTabChapterPanel.new(self)
        elseif index == ActiontermbeginsConstants.TabType.eBoss then
            --boss
            panel = ActiontermbeginsTabBossPanel.new(self)
        end
        local size = self.container:getContentSize()
        panel:setPosition(cc.p(size.width * 0.5 , size.height * 0.5))
        self.container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end

function ActiontermbeginsMainWindow:openRootWnd(setting)
    local setting = setting or {}
    self.select_index = setting.index
    -- self.select_index =  index or HeroConst.ResonateType.eStoneTablet
    --获取收集奖励信息
    controller:sender26705() --先
    
    controller:sender26700() --后
end

function ActiontermbeginsMainWindow:initData()
    if self.is_init then return end
    if not self.scdata then return end
    self.is_init = true
    if self.select_index then
        self:changeSelectedTab(self.select_index)
    else
        if self.scdata.boss_flag == 1 then
            self:changeSelectedTab(2)
        else
            self:changeSelectedTab(1)
        end
    end
end



function ActiontermbeginsMainWindow:close_callback()
    if self.item_load_bg then
        self.item_load_bg:DeleteMe()
    end
    self.item_load_bg = nil

    if self.view_list then
        for i,v in pairs(self.view_list) do 
            if v and v["DeleteMe"] then
                v:DeleteMe()
            end
        end
    end
    self.view_list = nil

    controller:openActiontermbeginsMainWindow(false)
end