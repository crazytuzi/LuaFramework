-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--       订单详情窗体,这个窗体包含了2个状态,一个是准备护送的,还有一个是护送过程中的
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildvoyageOrderEscortWindow = GuildvoyageOrderEscortWindow or BaseClass(BaseView)

local controller = GuildvoyageController:getInstance()
local model = controller:getModel() 
local backpack_model = BackpackController:getInstance():getModel()
local partner_model = HeroController:getInstance():getModel()
local table_insert = table.insert 
local table_sort = table.sort
local game_net = GameNet:getInstance()

function GuildvoyageOrderEscortWindow:__init(type)
    self.order_type = type
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
    self.is_init = false
	self.res_list = {
		-- {path = PathTool.getPlistImgForDownLoad("guildvoyage", "guildvoyage"), type = ResourcesType.plist}
	}
	self.layout_name = "guildvoyage/guildvoyage_order_escort_window"
    self.item_list = {}
    self.partner_list = {}
    self.condition_list = {}
    self.treasure_list = {}

    self.auto_cool_time = 0

    -- self.total_partner_list = {}        -- 可以使用的伙伴列表,这里是为了做自动派遣需要
    self.can_use_partner_list = {}      -- 可以使用的伙伴列表
    self.in_temp_use_list = {}          -- 零时上阵的伙伴列表
end

function GuildvoyageOrderEscortWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    container:getChildByName("escort_title"):setString(TI18N("护送宝物:"))
    container:getChildByName("dispatch_title"):setString(TI18N("派遣英雄:")) 
    container:getChildByName("probability_title"):setString(TI18N("概率加成:")) 
    container:getChildByName("reset_title_1"):setString(TI18N("固定奖励")) 
    local reset_title = container:getChildByName("reset_title_2")
    reset_title:setString(TI18N("概率奖励"))

    self.probability_value = container:getChildByName("probability_value")
    self.probability_value:setPositionX(reset_title:getPositionX()+reset_title:getContentSize().width+2)
    self.probability_value:setString(TI18N("(80%概率)"))

    local win_title = container:getChildByName("win_title")
    if self.order_type == GuildvoyageConst.escort_type.prepare then
        win_title:setString(TI18N("远航护送准备"))
    else
        win_title:setString(TI18N("远航护送"))
    end
    self.close_btn = container:getChildByName("close_btn")

    self.success_container = container:getChildByName("success_container")             -- 花费钻石提升成功率
    self.success_container.checkbox = self.success_container:getChildByName("checkbox")
    self.success_container:getChildByName("desc"):setString(TI18N("成功率100%"))
    local success_value = self.success_container:getChildByName("value")
    local config = Config.GuildShippingData.data_const.success_cost
    if config ~= nil then
        success_value:setString(config.val)
    end
    self.success_container:setVisible(false)

    self.item = container:getChildByName("item") -- 用于拷贝事件的list
    self.item:setVisible(false)

    -- 护送中的订单,这里成功率和双倍不可点击的
    if self.order_type == GuildvoyageConst.escort_type.escort then
        self.success_container:setTouchEnabled(false)
        self.success_container.checkbox:setOpacity(153)
    end

    self.prepare_btn_container = container:getChildByName("prepare_btn_container")
    self.prepare_object = {}
    self.prepare_object.escort_btn = self.prepare_btn_container:getChildByName("escort_btn")         -- 护送按钮
    self.prepare_object.time_label = self.prepare_object.escort_btn:getChildByName("time_label")          -- 护送需要时间
    self.prepare_object.dispatch_btn = self.prepare_btn_container:getChildByName("dispatch_btn")     -- 一键派送按钮
    self.prepare_object.dispatch_btn:getChildByName("label"):setString(TI18N("一键派送"))
    self.prepare_object.escort_btn:getChildByName("label"):setString(TI18N("护送"))

    self.escort_btn_container = container:getChildByName("escort_btn_container")
    self.escort_object = {}
    self.escort_object.time_label = self.escort_btn_container:getChildByName("time_label")           -- 护送剩余时间
    self.escort_object.finish_btn = self.escort_btn_container:getChildByName("finish_btn")           -- 立即完成
    self.escort_object.cost_value = self.escort_object.finish_btn:getChildByName("value")            -- 立即完成需要消耗的钻石数量
    self.escort_object.finish_btn:getChildByName("label"):setString(TI18N("立即完成"))

    self.prepare_btn_container:setVisible(self.order_type == GuildvoyageConst.escort_type.prepare)
    self.escort_btn_container:setVisible(self.order_type == GuildvoyageConst.escort_type.escort)

    self.center_x = container:getContentSize().width * 0.5
    self.container = container
end

function GuildvoyageOrderEscortWindow:register_event()
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openGuildvoyageOrderEscortWindow(false)
		end
    end) 
    if self.background then
        self.background:addTouchEventListener(function (sender,event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                controller:openGuildvoyageOrderEscortWindow(false)
            end
        end)
    end
    self.prepare_object.escort_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.order_info == nil or self.order_info.config == nil then return end
            -- 先判断物品足不足
            for k, object in pairs(self.treasure_list) do
                if object.status == FALSE then
                    message(TI18N("当前宝物不足!!"))
                    return
                end
            end
            -- 再判断伙伴足不足
            if tableLen(self.in_temp_use_list) < self.order_info.config.partner_num then
                message(TI18N("当前英雄数量不足!!"))
            end
            
            -- local is_success = (self.success_container.checkbox:isSelected()) and TRUE or FALSE
            -- local is_double =(self.double_container.checkbox:isSelected()) and TRUE or FALSE 
            local partner_ids = {}
            for k,v in pairs(self.in_temp_use_list) do
                table_insert(partner_ids, {partner_id = v.partner_id})
            end
            controller:requestEscortOrder(self.order_info.order_id, partner_ids, 0)
        end
    end)

    self.prepare_object.dispatch_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:autoDispatchPartner() 
        end
    end) 

    self.escort_object.finish_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.order_info then
                local total_value = self.escort_object.total_value or 0
                local msg = string.format(TI18N("是否确认花费 <img src=%s visible=true scale=0.5 />%s 立即完成该订单？"), PathTool.getItemRes(Config.ItemData.data_assets_label2id.gold), total_value)
                CommonAlert.show(msg, TI18N("确定"), function()
                    controller:requestFinishOrder(self.order_info.order_id)
                end, TI18N("取消"), nil, CommonAlert.type.rich)
            end
        end
    end) 

	-- self.success_container:addTouchEventListener(function(sender, event_type)
	-- 	if event_type == ccui.TouchEventType.ended then
    --         playButtonSound2()
    --         local isSelected = sender.checkbox:isSelected()
    --         sender.checkbox:setSelected(not isSelected)
    --         if not isSelected then
    --             self.probability_value:setString(TI18N("100%概率)"))
    --         else
    --             if self.original_rate then
    --                 self.probability_value:setString("(" .. self.original_rate .. TI18N("%概率)")) 
    --             end
    --         end
	-- 	end
	-- end)

    if self.order_type == GuildvoyageConst.escort_type.prepare and self.update_item_event == nil then 
        self.update_item_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, list)
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:updateTreasureList(list)
        end)
    end

    -- 只有在准备护送的时候才监听物品更新时间,护送过程中不产生影响
    if self.order_type == GuildvoyageConst.escort_type.prepare and self.add_item_event == nil then
        self.add_item_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, list)
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:updateTreasureList(list)
        end)
    end

    if self.order_type == GuildvoyageConst.escort_type.prepare and self.add_to_order_event == nil then
        self.add_to_order_event = GlobalEvent:getInstance():Bind(GuildvoyageEvent.AddToOrderPartnerListEvent, function(data) 
            self:fillPartnerToTempList(data)
        end)
    end
end

--勾选双倍时候情况
function GuildvoyageOrderEscortWindow:updateDoubleItemInfo(status)
    if self.item_list and next(self.item_list or {} ) ~= nil then
        for i, v in pairs(self.item_list) do
            if v then
                if v.is_fixed == false then
                    v:showDoubleTag(status,v.num)
                end
            end
        end
    end
end
--==============================--
--desc:上阵或者下阵伙伴
--time:2018-07-03 06:29:21
--@data:
--@return 
--==============================--
function GuildvoyageOrderEscortWindow:fillPartnerToTempList(data, item)
    if data == nil then return end
    local selected_item = self.selected_item
    if item ~= nil then
        selected_item = item
    end
    if selected_item == nil then return end

    if data.voyage_in_form == nil then
        data.voyage_in_form = true
    end
    if data.voyage_in_form == true then     -- 上阵操作
        controller:openChoosePartnerWindow(false)
        if selected_item.data ~= nil then
            self.in_temp_use_list[selected_item.data.partner_id] = nil 
        end
        self.in_temp_use_list[data.partner_id] = data
        selected_item:setData(data)
        selected_item:showAddIcon(false)
    else
        self.in_temp_use_list[data.partner_id] = nil
        selected_item:setData(nil)
        selected_item:showAddIcon(true)
    end

    -- 然后计算成功事件, is_success rate
    local rate = 0
    for k, object in pairs(self.condition_list) do
        if object.config and object.config.condition then
            local condition_event = object.config.condition[1]           -- 目标条件
            local target_value = object.config.condition[2]              -- 目标值
            local target_num = object.config.condition[3]                -- 目标需求数量           
            local _condition_disc = {}
            _condition_disc[condition_event] = 0
            for _, partner in pairs(self.in_temp_use_list) do
                if condition_event == "sum_partner_lev" then        -- 计算总等级
                    _condition_disc[condition_event] = _condition_disc[condition_event] + partner.lev
                elseif condition_event == "sum_partner_power" then  -- 计算总战力
                    _condition_disc[condition_event] = _condition_disc[condition_event] + partner.power
                elseif condition_event == "partner_star" then      -- 达到X星Y个伙伴
                    if partner.star >= target_value then
                        _condition_disc[condition_event] = _condition_disc[condition_event] + 1
                    end
                elseif condition_event == "partner_quality" then   -- 达到X品质Y个伙伴
                    if partner.rare_type >= target_value then
                        _condition_disc[condition_event] = _condition_disc[condition_event] + 1
                    end
                elseif condition_event == "partner_career" then     -- 存在X职业Y个伙伴
                    if partner.type == target_value then
                        _condition_disc[condition_event] = _condition_disc[condition_event] + 1
                    end
                end
            end
            local is_success = false
            if condition_event == "sum_partner_lev" or condition_event == "sum_partner_power" then
                if _condition_disc[condition_event] >= target_value then
                    is_success = true
                end
            else
                if _condition_disc[condition_event] >= target_num then 
                    is_success = true
                end
            end 
            object.is_success = is_success
            if is_success == true then
                rate = ( object.rate or 0 ) + rate
            end
            if is_success == true then
                object.sign:setVisible(true)
                object.desc:setTextColor(Config.ColorData.data_color4[178])
                object.probability:setTextColor(Config.ColorData.data_color4[178])
            else
                object.sign:setVisible(false)
                object.desc:setTextColor(Config.ColorData.data_color4[175])
                object.probability:setTextColor(Config.ColorData.data_color4[175])
            end
        end
    end

    -- 总概率
    if self.order_info and self.order_info.config and self.order_info.config.rate then
        rate = math.floor((self.order_info.config.rate + rate) * 0.1) 
        self.original_rate = rate 
    end

    if rate >= 100 then
        -- self.success_container:setTouchEnabled(false)
        -- self.success_container.checkbox:setSelected(false) 
        self.probability_value:setString("("..rate..TI18N("%概率)"))
    else
        -- self.success_container:setTouchEnabled(true)
        -- local is_success = self.success_container.checkbox:isSelected() 
        if is_success == true then
            self.probability_value:setString(TI18N("100%概率)"))
        else
            self.probability_value:setString("("..rate..TI18N("%概率)"))
        end
    end
end

--==============================--
--desc:一键派遣伙伴
--time:2018-07-04 09:41:49
--@return 
--==============================--
function GuildvoyageOrderEscortWindow:autoDispatchPartner()
    local cur_time = os.time()
    if cur_time - self.auto_cool_time < 2 then
        message(TI18N("操作太频繁了!!"))
        return
    end
    self.auto_cool_time = cur_time

    self.in_temp_use_list = {} --先清掉已上阵的那些
    if tableLen(self.can_use_partner_list) == 0 then
        message(TI18N("当前没有可上阵的伙伴"))
        return
    end
    -- 根据当前创建的伙伴列表去设置
    for i, item in ipairs(self.partner_list) do
        local partner_list = {}
        for partner_id,v in pairs(self.can_use_partner_list) do
            if self.in_temp_use_list[partner_id] == nil then
                v.voyage_recommend = 0
                v.voyage_in_form = false
                table_insert(partner_list, v)
            end
        end
        if next(partner_list) then
            for k,v in pairs(self.condition_list) do
                if v.is_success == false and v.config and v.config.condition then
                    local condition_event = v.config.condition[1]
                    local target_value = v.config.condition[2]
                    if self:needCheck(condition_event) then
                        for i, partner in ipairs(partner_list) do
                            if condition_event == "partner_star" then
                                if partner.star >= target_value then
                                    partner.voyage_recommend = 1
                                end
                            else
                                if condition_event == "partner_quality"  then
                                    if partner.rare_type >= target_value then
                                        partner.voyage_recommend = 1
                                    end
                                elseif condition_event == "partner_career"  then
                                    if partner.type == target_value then
                                        partner.voyage_recommend = 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
            local sort_func = SortTools.tableUpperSorter({"voyage_recommend", "power", "lev"})
            table_sort(partner_list, sort_func)
        end
        -- 再取出第一个
        local data = partner_list[1]
        if data ~= nil then
            data.voyage_in_form = true
            -- 再把第一个插入到当前的列表中区
            self:fillPartnerToTempList(data, item)
        end
    end
end

function GuildvoyageOrderEscortWindow:openRootWnd(order_id)
    if self.is_init == true then return end
    self.order_info = model:getOrderById(order_id)
    if self.order_info and self.order_info.config then
        -- 创建固定奖励
        self:createRewardsList(self.order_info.config.rewards)
        -- 创建概率奖励
	    self:createRandRewardsList(self.order_info.config.rand_rewards) 
        -- 创建需求宝物
        self:createTreasureList(self.order_info.loss_id)
        -- 创建条件事件
        self:createConditionList(self.order_info.config.cond_ids, self.order_info.cond_ids)

        if self.order_type == GuildvoyageConst.escort_type.prepare then
            self:createPartnerDemandList(self.order_info.config.partner_num) 
            -- 护送时间
            self.prepare_object.time_label:setString(TimeTool.GetTimeFormat(self.order_info.config.time))

            -- 找出当前可用的伙伴列表,拷贝过来进行修改吧,不对原始数据做改变
            local temp_partner_list = partner_model:getHeroList()
            local partner_list = DeepCopy(temp_partner_list)
            local busy_partner_list = model:getBusyPartnerList()
            for k,v in pairs(partner_list) do
                if busy_partner_list[v.partner_id] == nil then
                    v.voyage_recommend = 0
                    v.voyage_in_form = false
                    self.can_use_partner_list[v.partner_id] = v

                    -- table_insert(self.total_partner_list, v)
                end
            end
        else
            local end_time = self.order_info.end_time - game_net:getTime()
            if end_time <= 0 then
                end_time = 0
            end
            self.escort_object.time_label:setString(TimeTool.GetTimeFormat(end_time))
            local total_value = model:getFinishCost(end_time)
            self.escort_object.total_value = total_value
            self.escort_object.cost_value:setString(total_value)

            if end_time > 0 then
                if self.time_ticket == nil then
                    self.time_ticket = GlobalTimeTicket:getInstance():add(function() 
                        self:escortTimeCount()
                    end, 1)
                end
            end
            self:createPartnerAssignList(self.order_info.assign_ids)
        end
        -- self.success_container.checkbox:setSelected(self.order_info.is_success == TRUE)
        -- self.double_container.checkbox:setSelected(self.order_info.is_double == TRUE) 
        self.is_init = true
    end
end

--==============================--
--desc:按照当前的需求事件给当前伙伴做排序
--time:2018-07-04 09:37:27
--@return 
--==============================--
function GuildvoyageOrderEscortWindow:sortCurPartnerList()
    for k,v in pairs(self.condition_list) do
        if v.is_success == false and v.config and v.config.condition then
            local condition_event = v.config.condition[1]         -- 目标条件
            local target_value = v.config.condition[2]            -- 目标值
            if self:needCheck(condition_event) then
                for i, partner in ipairs(self.total_partner_list) do
                    if condition_event == "partner_star" then
                        if partner.star >= target_value then
                            partner.voyage_recommend = 1
                        end
                    else
                        if condition_event == "partner_quality"  then
                            if partner.rare_type >= target_value then
                                partner.voyage_recommend = 1
                            end
                        elseif condition_event == "partner_career"  then
                            if partner.type == target_value then
                                partner.voyage_recommend = 1
                            end
                        end
                    end
                end
            end
        end
    end
    local sort_func = SortTools.tableUpperSorter({"voyage_recommend", "power", "lev"})
    table_sort(self.total_partner_list, sort_func)
end

--==============================--
--desc:创建条件
--time:2018-07-02 10:54:14
--@config_list:配置条件
--@data_list:数据
--@return 
--==============================--
function GuildvoyageOrderEscortWindow:createConditionList(config_list, data_list)
    if tolua.isnull(self.item) then return end
    if config_list == nil or data_list == nil then return end
    local _x, _y = self.center_x, 467
    local item = nil
    local index = 1
    local object = nil
    local config = nil
    local rate = 0
    for i,v in ipairs(config_list) do
        if v[1] and v[2] then
            config = Config.GuildShippingData.data_condition[v[1]]
            if config then
                object = {}
                item = self.item:clone()
                item:setVisible(true)
                _y = 467 - (index - 1) * 41
                item:setPosition(_x, _y)
                self.container:addChild(item)
                object.item = item
                object.sign = item:getChildByName("sign")
                object.desc = item:getChildByName("desc")
                object.probability = item:getChildByName("probability")
                object.config = config
                object.desc:setString(config.desc)
                object.rate = v[2] or 0          -- 订单成功率
                object.probability:setString("+"..(math.ceil(object.rate*0.1).."%"))
                if data_list[v[1]] ~= nil then
                    object.is_success = true
                    object.sign:setVisible(true)
                    object.desc:setTextColor(Config.ColorData.data_color4[178])
                    object.probability:setTextColor(Config.ColorData.data_color4[178])
                    rate = object.rate + rate       -- 统计成功率
                else
                    object.is_success = false
                    object.sign:setVisible(false)
                    object.desc:setTextColor(Config.ColorData.data_color4[175])
                    object.probability:setTextColor(Config.ColorData.data_color4[175])
                end
                self.condition_list[v[1]] = object
                index = index + 1
            end
        end
    end

    -- 总概率
    if self.order_info and self.order_info.config and self.order_info.config.rate then
        rate = math.floor((self.order_info.config.rate + rate)*0.1)
        self.original_rate = rate  
    end
    if self.order_type == GuildvoyageConst.escort_type.prepare then
        if rate >= 100 then
            -- self.success_container:setTouchEnabled(false)
            -- self.success_container.checkbox:setSelected(false)
            self.probability_value:setString("(" .. rate .. TI18N("%概率)"))
        else
            -- self.success_container:setTouchEnabled(true)
            -- local is_success = self.success_container.checkbox:isSelected()
            if is_success == true then
                self.probability_value:setString(TI18N("100%概率)"))
            else
                self.probability_value:setString("(" .. rate .. TI18N("%概率)"))
            end
        end
    else
        self.probability_value:setString("("..rate..TI18N("%概率)"))
    end
end

--==============================--
--desc:创建伙伴的需求列表
--time:2018-06-29 04:02:45
--@num:
--@return 
--==============================--
function GuildvoyageOrderEscortWindow:createPartnerDemandList(num)
    local scale = 0.8
    local off = 28
    local _x, _y = 0, 610
    local  item = nil
    local function callback(item)
        self:setChoosePartnerList(item)
    end

    for i=1, num do
        item = HeroExhibitionItem.new(scale, true, true)
         _x = 171 +(i - 1) *(BackPackItem.Width * scale + off) + BackPackItem.Width * scale * 0.5
        item:setPosition(_x, _y)
        self.container:addChild(item)
        item:addCallBack(callback)
        item:showAddIcon(true) 
        table_insert(self.partner_list, item)
    end
end

--==============================--
--desc:设置当前可以上阵的伙伴
--time:2018-07-03 04:01:47
--@item:
--@return 
--==============================--
function GuildvoyageOrderEscortWindow:setChoosePartnerList(item)
    if item == nil then return end
    local partner_list = {}
    for partner_id,v in pairs(self.can_use_partner_list) do
        if self.in_temp_use_list[partner_id] == nil then        -- 已经处于临时上阵的伙伴不存放到列表
            v.voyage_recommend = 0
            v.voyage_in_form = false
            table_insert(partner_list, v)
        end
    end

    for k,v in pairs(self.condition_list) do
        if v.is_success == false and v.config and v.config.condition then
            local condition_event = v.config.condition[1]         -- 目标条件
            local target_value = v.config.condition[2]            -- 目标值
            if self:needCheck(condition_event) then
                for i, partner in ipairs(partner_list) do
                    if condition_event == "partner_star" then
                        if partner.star >= target_value then
                            partner.voyage_recommend = 1
                        end
                    else
                        if condition_event == "partner_quality"  then
                            if partner.rare_type >= target_value then
                                partner.voyage_recommend = 1
                            end
                        elseif condition_event == "partner_career"  then
                            if partner.type == target_value then
                                partner.voyage_recommend = 1
                            end
                        end
                    end
                end
            end
        end
    end

    local sort_func = SortTools.tableUpperSorter({"voyage_recommend", "power", "lev"})
    table_sort(partner_list, sort_func)

    -- 这个时候再把当前的插到第一个位置,做下阵处理
    if item.data ~= nil then
        table_insert(partner_list, 1, item.data)
    end
    -- 储存当前选中的
    self.selected_item = item
    controller:openChoosePartnerWindow(true, partner_list)
end

--==============================--
--desc:需要判断的事件
--time:2018-07-03 05:00:46
--@condition_event:
--@return 
--==============================--
function GuildvoyageOrderEscortWindow:needCheck(condition_event)
    return condition_event == "partner_star" or condition_event == "partner_quality" or condition_event == "partner_career" 
end

--==============================--
--desc:创建在护送队列中的伙伴
--time:2018-06-29 04:03:24
--@list:
--@return 
--==============================--
function GuildvoyageOrderEscortWindow:createPartnerAssignList(list)
    if list == nil or next(list) == nil then return end
    local scale = 0.8
    local off = 28
    local _x, _y = 0, 610
    local item = nil
    local index =1

    for i,v in ipairs(list) do
        local partner_vo = partner_model:getHeroById(v.partner_id)
        if partner_vo then
            item = HeroExhibitionItem.new(scale, true, true)
            _x = 171 +(i - 1) * (BackPackItem.Width * scale + off) + BackPackItem.Width * scale * 0.5
            item:setPosition(_x, _y)
            item:setData(partner_vo)
            item:shwoExtendPower(true, partner_vo.power)
            self.container:addChild(item)
            table_insert(self.partner_list, item)
            index = index + 1
        end
    end
end

--==============================--
--desc:创建宝物列表,这里要区分订单类型
--time:2018-06-29 03:43:01
--@return 
--==============================--
function GuildvoyageOrderEscortWindow:createTreasureList(loss_id)
    local consume_config = Config.GuildShippingData.data_consume[loss_id]
    if consume_config == nil or next(consume_config.loss) == nil then return end
    local item = nil
    local scale = 0.8
    local off = 28
    local _x, _y = 0, 733
    local bid = nil
    local item_config = nil
    local object = nil
    local function  add_callback(item)
        if item.data ~= nil then
            -- 这个时候找出当前还缺的物品bid
            local item_list = {}
            for k,treasure in pairs(self.treasure_list) do
                if treasure.status == FALSE then
                    table_insert(item_list, {bid= k, need_num = treasure.need_num})
                end
            end
            BackpackController:getInstance():openTipsSource(true, item.data, {"evt_league_help", true}, item_list)
        end
    end

    for i, v in ipairs(consume_config.loss) do
        bid = v[1]
        if bid then 
            item_config = Config.ItemData.data_get_data(bid)
            if item_config then
                item = BackPackItem.new(false, true, false, scale, true, true)
                _x = 171 +(i - 1) *(BackPackItem.Width * scale + off) + BackPackItem.Width * scale * 0.5
                item:setPosition(_x, _y)
                item:setBaseData(bid)
                self.container:addChild(item)

                local item_status = 0
                if self.order_type == GuildvoyageConst.escort_type.prepare then  -- 这个时候需要判断数量的
                    local sum = backpack_model:getBackPackItemNumByBid(bid)
                    item:setSpecialNum(sum.."/"..v[2])
                    if sum < v[2] then
                        item_status = 0
                    else
                        item_status = 1
                    end
                else
                    item_status = 1
                end 

                if item_status == FALSE then
                    setChildUnEnabled(true, item)
                    item:showAddIcon(true)
                    item:setDefaultTip(false)
                    item:addBtnCallBack(add_callback)
                else
                    setChildUnEnabled(false, item)
                    item:showAddIcon(false)
                    item:setDefaultTip(true)
                    item:addBtnCallBack(nil)
                end

                object = {}
                object.item = item
                object.need_num = v[2]
                object.status = item_status
                self.treasure_list[bid] = object
            end
        end
    end
end

--==============================--
--desc:创建固定奖励
--time:2018-06-26 05:56:35
--@return 
--==============================--
function GuildvoyageOrderEscortWindow:createRewardsList(list)
	if list == nil or next(list) == nil then return end
	local item = nil
	local scale = 0.8
	local off = 10
	local _x, _y = 0, 245
	for i, v in ipairs(list) do
		if v[1] then
            item = BackPackItem.new(false, true, false, scale, false, true)
            _x = 35 +(i - 1) *(BackPackItem.Width * scale + off) + BackPackItem.Width * scale * 0.5
            item:setPosition(_x, _y)
            item:setBaseData(v[1], v[2])
            item.is_fixed = true
            item.num = v[2]
            -- item:setDefaultTip(true, true)
            self.container:addChild(item)
            self.item_list[v[1]] = item
        end
	end
end

--==============================--
--desc:创建随机奖励
--time:2018-06-26 05:56:52
--@return 
--==============================--
function GuildvoyageOrderEscortWindow:createRandRewardsList(list)
	if list == nil or next(list) == nil then return end
	local item = nil
	local scale = 0.8
	local off = 10
	local _x, _y = 0, 245
	for i, v in ipairs(list) do
        if v[1] then
            item = BackPackItem.new(false, true, false, scale, false, true)
            _x = 289 +(i - 1) *(BackPackItem.Width * scale + off) + BackPackItem.Width * scale * 0.5
            item:setPosition(_x, _y)
            item:setDefaultTip(true, true)
            item:setBaseData(v[1], v[2])
            self.container:addChild(item)
            item.is_fixed = false
            item.num = v[2]
            self.item_list[v[1]] = item
        end
	end
end 

--==============================--
--desc:更新宝物数量,物品事件触发之后造成的
--time:2018-07-02 08:26:13
--@list:
--@return 
--==============================--
function GuildvoyageOrderEscortWindow:updateTreasureList(list)
    for k, item in pairs(list) do
        if item.config then
            local treasure = self.treasure_list[item.config.id]
            if treasure and treasure.item then
                treasure.item:setSpecialNum(item.quantity .. "/" .. treasure.need_num)
                local item_status = FALSE
                if item.quantity >= treasure.need_num then
                    item_status = TRUE
                end
                if treasure.status ~= item_status then
                    treasure.status = item_status
                    if item_status == FALSE then
                        setChildUnEnabled(true, treasure.item)
                        treasure.item:showAddIcon(true)
                        treasure.item:setDefaultTip(false)
                    else
                        setChildUnEnabled(false, treasure.item)
                        treasure.item:showAddIcon(false)
                        treasure.item:setDefaultTip(true)
                        treasure.item:addBtnCallBack(nil)
                    end
                end
            end
        end
    end 
end

function GuildvoyageOrderEscortWindow:clearTimeCount()
    if self.time_ticket then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end

--==============================--
--desc:立即完成倒计时
--time:2018-07-05 11:16:58
--@return 
--==============================--
function GuildvoyageOrderEscortWindow:escortTimeCount()
    if self.order_info == nil then
        self:clearTimeCount()
        return
    end
    local end_time = self.order_info.end_time - game_net:getTime()
    if end_time <= 0 then
        self:clearTimeCount()
        return
    end
    self.escort_object.time_label:setString(TimeTool.GetTimeFormat(end_time))
    local total_value = model:getFinishCost(end_time)
    if self.escort_object.total_value ~= total_value then
        self.escort_object.cost_value:setString(total_value)
        self.escort_object.total_value = total_value
    end
end

function GuildvoyageOrderEscortWindow:close_callback()
    self:clearTimeCount()

    for i,v in ipairs(self.partner_list) do
        v:DeleteMe()
    end
    self.partner_list = nil

    for i,v in pairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = nil

    for k,v in pairs(self.treasure_list) do
        if v.item then
            v.item:DeleteMe()
        end
    end
    self.treasure_list = nil

    if self.add_to_order_event then
        GlobalEvent:getInstance():UnBind(self.add_to_order_event)
        self.add_to_order_event = nil
    end

    if self.add_item_event then
        GlobalEvent:getInstance():UnBind(self.add_item_event)
        self.add_item_event = nil
    end
    if self.update_item_event then
        GlobalEvent:getInstance():UnBind(self.update_item_event)
        self.update_item_event = nil
    end

	controller:openGuildvoyageOrderEscortWindow(false)
end
