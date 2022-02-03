-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      限时礼包入口 运营任思仪 --by lwc
-- <br/>Create: 2018年12月11日
ActionLimitGiftMainPanel = class("ActionLimitGiftMainPanel", function()
    return ccui.Widget:create()
end)


local table_sort = table.sort
local string_format = string.format

function ActionLimitGiftMainPanel:ctor(data)
    --self.data 是 21210返回的单个信息 参考 ActionLimitGiftMainWindow:initData(scdata)
    self.data = data or {}
    self.ctrl = ActionController:getInstance()
    self.role_vo = RoleController:getInstance():getRoleVo()
    self:configUI()
    self:register_event()

end

function ActionLimitGiftMainPanel:configUI(  )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_limit_gift_main_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.title_img = self.main_container:getChildByName("title_img")
    self.is_level_gift = false
    if self.data and self.data.config then 
        local title = self.data.config.res_1 or "txt_cn_action_limit_gift_level"
        local res = PathTool.getPlistImgForDownLoad("bigbg/limit_gift",title, true)
        if not self.item_load1 then
            self.item_load1 = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load1)
        end

        if self.data.config.codition and self.data.config.codition[1] ~= nil then
            self.level_img = self.main_container:getChildByName("level_img")

            --2是等级礼包 需要等级
            if self.data.config.gift_type == 2 then
                --说明是等级礼包
                self.is_level_gift = true
                local level
                if self.data.config.res_2 == nil or self.data.config.res_2 == "" then
                    level = "action_limit_gift_level_18"
                else
                    level = self.data.config.res_2
                end
                local res = PathTool.getPlistImgForDownLoad("bigbg/limit_gift",level,false)
                if not self.item_load then
                    self.item_load = loadSpriteTextureFromCDN(self.level_img, res, ResourcesType.single, self.item_load)
                end
            end
        end
    end


    self.item_scrollview = self.main_container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    -- self.item_scrollview:setSwallowTouches(false)
    
    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_label = self.comfirm_btn:getChildByName("label")
    

    -- self.time_val = createRichLabel(20, Config.ColorData.data_color4[1], cc.p(0, 0.5), cc.p(33,66),nil,nil,540)
    -- self.main_container:addChild(self.time_val)
    self.time_val = self.main_container:getChildByName("time_val")
    --和后端协议好..活动结束后会有两天兑换时间..这里把时间减去了
    local time = self.data.end_time
    self:setLessTime(time)

    self.value = self.main_container:getChildByName("value")
    if self.is_level_gift then
        self.time_val:setPosition(24,380)
        self.item_scrollview:setPositionY(334)
        self.item_scrollview:setContentSize(cc.size(469,240))
    end
    self.item_scrollview_size = self.item_scrollview:getContentSize()

    if self.data.config.gift_type == 3 then
        --3表示是神装礼包
        local offset_y = 84
        self.value:setPositionY(self.value:getPositionY() - offset_y)
        self.time_val:setPositionY(self.time_val:getPositionY() - offset_y)
        self.item_scrollview:setPositionY(self.item_scrollview:getPositionY() - offset_y)
        
        self.comfirm_btn:setPositionY(self.comfirm_btn:getPositionY() - offset_y + 3)
        self.comfirm_btn:setContentSize(cc.size(140, 64))
        self.comfirm_label:setPositionX(70)
    end
    self:setData()
end

function ActionLimitGiftMainPanel:register_event(  )
    -- if not self.update_action_even_event  then
    --     self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
    --         if not data then return end
    --         if data.bid == self.holiday_bid then
    --             self:setData(data)
    --         end
    --     end)
    -- end

    if not self.role_lev_event and self.role_vo  then
        self.role_lev_event =  self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ACTION_ASSETS, function(id, value) 
            if id and id == self.action_item_id and self.role_vo then 
                local count = self.role_vo:getActionAssetsNumByBid(self.action_item_id)
                self.item_count:setString(count)
            end
        end)
    end

    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn() end ,true, 2)
end

--前往兑换
function ActionLimitGiftMainPanel:onComfirmBtn()
    if not self.data then return end
    if not self.data.config then return end
    local charge_id = self.data.config.package_id or 0
    local charge_config = Config.ChargeData.data_charge_data[charge_id]
    if charge_config then
        sdkOnPay(charge_config.val, nil, charge_config.id, charge_config.name, charge_config.name)
    end
end

--设置倒计时
function ActionLimitGiftMainPanel:setLessTime(less_time)
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
                else
                    self:setTimeFormatString(less_time)
                end
            end))))
    else
        self:setTimeFormatString(less_time)
    end
end
function ActionLimitGiftMainPanel:setTimeFormatString( time )
    if time > 0 then
        str = string.format(TI18N("剩余时间: %s"),TimeTool.GetTimeFormatDayIIIIII(time))
        self.time_val:setString(str)
    else
        self.time_val:setString("")
    end
end

function ActionLimitGiftMainPanel:setData(data)
    if not self.data then return end
    if not self.data.config then return end
    local num = self.data.num or 0
    self.value:setString(string_format(TI18N("剩余: %s"), num))
    
    local config = Config.ChargeData.data_charge_data[self.data.config.package_id]
    if config then
        local str = config.val..TI18N("元")
        self.comfirm_label:setString(str)
    end

    --物品id
    local reward = self.data.config.reward or {}
    --道具列表
    local scale = 0.9
    local offsetX = 8
    local item_count = #reward
    local item_width = BackPackItem.Width * scale

    local total_width =  (item_width + offsetX) * item_count
    local max_width = math.max(self.item_scrollview_size.width, total_width)
    self.item_scrollview:setInnerContainerSize(cc.size(max_width, self.item_scrollview_size.height))

    if item_count <= 4 or self.is_level_gift then
        --小于等于4 个不给移动
        self.item_scrollview:setTouchEnabled(false)
    end

    self.item_list = {}
    self.start_x = offsetX * 0.5
    local y = 0
    if self.is_level_gift then
        y = self.item_scrollview_size.height * 0.75
    else
        y = self.item_scrollview_size.height * 0.5
    end
    local item = nil
    for i, v in ipairs(reward) do
        delayRun(self.item_scrollview,i / display.DEFAULT_FPS,function ()
            if not self.item_list[i] then
                item = BackPackItem.new(true, true)
                item:setAnchorPoint(0, 0.5)
                item:setScale(scale)
                item:setSwallowTouches(false)
                self.item_scrollview:addChild(item)
                self.item_list[i] = item
                local _x = 0
                if i > 4 and self.is_level_gift then
                    _x = self.start_x + (i - 4 - 1) * (item_width + offsetX) + 4
                    y = self.item_scrollview_size.height * 0.25
                else
                    _x = self.start_x + (i - 1) * (item_width + offsetX) + 4
                end
                item:setPosition(_x, y)
                item:setBaseData(v[1], v[2], true)
                item:setDefaultTip()
            end
        end)
    end
    
end


function ActionLimitGiftMainPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
end

function ActionLimitGiftMainPanel:DeleteMe()

    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    doStopAllActions(self.item_scrollview)

    if self.item_load1 then 
        self.item_load1:DeleteMe()
        self.item_load1 = nil
    end
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    if self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end

    if self.role_lev_event and self.role_vo then
        self.role_lev_event = self.role_vo:UnBind(self.role_lev_event)
        self.role_lev_event = nil
    end

    doStopAllActions(self.time_val) 
    self:removeAllChildren()
    self:removeFromParent()
end
