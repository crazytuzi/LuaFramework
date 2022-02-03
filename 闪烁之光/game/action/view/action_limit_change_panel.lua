 -- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
-- 限时兑换活动通用面板
--
ActionLimitChangePanel = class("ActionLimitChangePanel", function()
    return ccui.Widget:create()
end)

local limit_change_const = Config.FunctionData.data_limit_change_const
local table_sort = table.sort
local string_format = string.format
local controller = ActionController:getInstance()
function ActionLimitChangePanel:ctor(bid, type)
    self.holiday_bid = bid

    self.role_vo = RoleController:getInstance():getRoleVo()
    self:configUI()
    self:register_event()

    --此活动的兑换id 后端会传过来 先默认 80101
    self.action_item_id = 80101
end

function ActionLimitChangePanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_limit_change_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.title_img = self.main_container:getChildByName("title_img")

    local str = "txt_cn_action_limit_change_panel"
    local config_data = limit_change_const[self.holiday_bid]
    if config_data then
        str = config_data.bg_name 
    end

    local res = PathTool.getPlistImgForDownLoad("bigbg/action", str)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.title_img) then
                loadSpriteTexture(self.title_img, res, LOADTEXT_TYPE)
            end
        end,self.item_load)
    end

    self.item_scrollview = self.main_container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    self.item_scrollview_size = self.item_scrollview:getContentSize()

    local dec_node = self.main_container:getChildByName("dec_node")
    self.dec_val = createRichLabel(20, nil, cc.p(0, 1), cc.p(0,0),12,nil,540)
    self.dec_title = self.main_container:getChildByName("dec_title")
    local item_dec_label = self.main_container:getChildByName("item_dec_label")
    
    
    local rule_color_1 = "ffcf90ff"
    if config_data then
        rule_color_1 = config_data.title_color
    end
    local color = self:colorChangeData(rule_color_1)
    self.dec_val:setColor(color)
    dec_node:addChild(self.dec_val)
    self.dec_title:setColor(color)
    self.dec_title:setString(TI18N("活动规则"))

    local has_color = "ffcf90ff"
    if config_data then
        has_color = config_data.has_prop_color
    end
    local color_title = self:colorChangeData(has_color)
    item_dec_label:setColor(color_title)
    item_dec_label:disableEffect(cc.LabelEffect.OUTLINE)
    item_dec_label:setString(TI18N("当前拥有道具:"))

    --道具
    self.item_icon = self.main_container:getChildByName("item_icon")
    self.item_count =  self.main_container:getChildByName("item_count")

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_label:setString(TI18N("前往兑换"))

    local time_color = Config.ColorData.data_color4[1]
    if config_data then
        time_color = self:colorChangeData(config_data.time_color1)
    end
    self.time_val = createRichLabel(20, time_color, cc.p(0, 0.5), cc.p(33,66),nil,nil,540)
    self.main_container:addChild(self.time_val)
end

function ActionLimitChangePanel:register_event()
    if not self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
            if not data then return end
            if data.bid == self.holiday_bid then
                self:setData(data)
                self:setLessTime(data.remain_sec - 2*24*60*60)
            end
        end)
    end

    if not self.role_lev_event and self.role_vo then
        self.role_lev_event =  self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ACTION_ASSETS, function(id, value) 
            if id and id == self.action_item_id and self.role_vo then 
                local count = self.role_vo:getActionAssetsNumByBid(self.action_item_id)
                self.item_count:setString(count)
            end
        end)
    end

    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn() end,true, 2)
end

--颜色转换
function ActionLimitChangePanel:colorChangeData(value)
    local r,g,b,a = "ff", "ff", "ff", "ff"
    r = string.sub(value,1,2)
    g = string.sub(value,3,4)
    b = string.sub(value,5,6)
    a = string.sub(value,7,8)
    if r=="" then
        r = "ff"
    end
    if g=="" then
        g = "ff"
    end
    if b=="" then
        b = "ff"
    end
    if a=="" then
        a = "ff"
    end
    return cc.c4b(tonumber("0x"..r), tonumber("0x"..g), tonumber("0x"..b), tonumber("0x"..a))
end
--前往兑换
function ActionLimitChangePanel:onComfirmBtn()
    MallController:getInstance():openMallActionWindow(true, self.holiday_bid)
end

--设置倒计时
function ActionLimitChangePanel:setLessTime(less_time)
    if tolua.isnull(self.time_val) then
        return
    end
    local less_time =  less_time or 0
    self.time_val:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time_val:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    self.time_val:stopAllActions()
                    local str = string.format(TI18N("结束时间: <div fontcolor=#00ff0c>活动已结束</div>"))
                    if self.holiday_bid == ActionChangeCommonType.limit_yuanzhen or self.holiday_bid == ActionChangeCommonType.limit_yuanzhen1 then
                        str = string.format(TI18N("结束时间: <div fontcolor=#249003>活动已结束</div>"))
                    end
                    self.time_val:setString(str)
                else
                    self:setTimeFormatString(less_time)
                end
            end))))
    else
        self:setTimeFormatString(less_time)
    end
end
function ActionLimitChangePanel:setTimeFormatString(time)
    local fontcolor = "249003"
    if time > 0 then
        local str = string.format(TI18N("结束时间: <div fontcolor=#%s>%s</div>"),fontcolor,TimeTool.GetTimeFormatDayIIIIII(time))
        self.time_val:setString(str)
    else
        local str = string.format(TI18N("结束时间: <div fontcolor=#%s>活动已结束</div>"),fontcolor)
        self.time_val:setString(str)
    end
end

function ActionLimitChangePanel:setData(data)
    local text = data.client_reward
    text = string.gsub(text, "（", "(")
    text = string.gsub(text, "）", ")")
    self.dec_val:setString(text)

    --物品id
    local item_id
    if data.aim_list[1] and data.aim_list[1].aim_args then
        local item_list = keyfind('aim_args_key', 4, data.aim_list[1].aim_args) or nil
        if item_list then
            item_id = item_list.aim_args_val
        end
    end
    if item_id then
        self.action_item_id = item_id
        local config = Config.ItemData.data_get_data(item_id)
        if config and self.item_icon then
            local head_icon = PathTool.getItemRes(config.icon, false)
            loadSpriteTexture(self.item_icon, head_icon, LOADTEXT_TYPE) 
            self.item_icon:setScale(0.4)       
        end
        local count = self.role_vo:getActionAssetsNumByBid(item_id)
        self.item_count:setString(count)
    end

    if self.item_list then return end
    --道具列表
    local scale = 0.9
    local offsetX = 10
    local item_count = #data.item_effect_list
    local item_width = BackPackItem.Width * scale

    local total_width =  (item_width + offsetX) * item_count
    local max_width = math.max(self.item_scrollview_size.width, total_width)
    self.item_scrollview:setInnerContainerSize(cc.size(max_width, self.item_scrollview_size.height))

    if item_count <= 4 then
        --小于等于3 个不给移动
        self.item_scrollview:setTouchEnabled(false)
    end

    self.item_list = {}
    self.start_x = offsetX * 0.5
    local item = nil 
    for i, v in ipairs(data.item_effect_list) do
        delayRun(self.item_scrollview,i / display.DEFAULT_FPS,function ()
            if not self.item_list[i] then
                item = BackPackItem.new(true, true)
                item:setAnchorPoint(0, 0.5)
                item:setScale(scale)
                item:setSwallowTouches(false)
                self.item_scrollview:addChild(item)
                self.item_list[i] = item
                local _x = self.start_x + (i - 1) * (item_width + offsetX) + 8
                item:setPosition(_x, self.item_scrollview_size.height * 0.5)
                item:setBaseData(v.bid, 1, true)
                item:setDefaultTip()
                if v.effect_1 > 0 then
                    local config = Config.ItemData.data_get_data(v.bid)
                    if config and config.quality >= 4 then
                        item:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
                    else
                       item:showItemEffect(true, 263, PlayerAction.action_2, true, 1.1)
                    end
                end
            end
        end)
    end
end

function ActionLimitChangePanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
    if bool == true then 
        controller:cs16603(self.holiday_bid)
    end
end

function ActionLimitChangePanel:DeleteMe()
    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    doStopAllActions(self.item_scrollview)

    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    if self.update_action_even_event then
        GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end

    if self.role_lev_event and self.role_vo then
        self.role_vo:UnBind(self.role_lev_event)
        self.role_lev_event = nil
    end
    doStopAllActions(self.time_val) 
end

