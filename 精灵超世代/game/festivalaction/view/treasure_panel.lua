--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 一元夺宝主界面
-- @DateTime:    2019-05-16 09:45:14
-- *******************************
TreasurePanel = class("TreasurePanel", function()
    return ccui.Widget:create()
end)

local goods_list = Config.HolidaySnatchData.data_join_goods_list
local controller = FestivalActionController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
function TreasurePanel:ctor(bid)
	self.holiday_bid = bid
    self.first_comme_in = false --第一次进来的时候
    self.recent_record_txt = {}
    self.recent_record_num = {}
	self:loadResources()
end

function TreasurePanel:loadResources()
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("treasure","treasure"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/festivalaction","txt_cn_festival_treasure"), type = ResourcesType.single},
    }
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(self.res_list, function()
        if self.loadResListCompleted then
            self:loadResListCompleted()
        end
    end)
end
function TreasurePanel:loadResListCompleted()
    self:configUI()
    self:register_event()
end
function TreasurePanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("festivalaction/treasure_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")
    local treasure_bg = main_container:getChildByName("treasure_bg")

    local str_bg = "txt_cn_festival_treasure"
    local tab_vo = ActionController:getInstance():getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.aim_title ~= "" and tab_vo.aim_title then
        str_bg = tab_vo.aim_title
    end

    local res = PathTool.getPlistImgForDownLoad("bigbg/festivalaction",str_bg)
    self.treasure_bg_load = loadSpriteTextureFromCDN(treasure_bg, res, ResourcesType.single, self.treasure_bg_load)

    self.btn_my_record = main_container:getChildByName("btn_my_record")
    self.btn_change_shop = main_container:getChildByName("btn_change_shop")
    self.btn_rule = main_container:getChildByName("btn_rule")
        
    main_container:getChildByName("Text_1"):setString(TI18N("剩余时间："))
    self.text_remain = main_container:getChildByName("text_remain")
    self.text_remain:setString("")
    self.holiday_time = main_container:getChildByName("holiday_time")
    self.holiday_time:setString("")
    self:setHolidayJoinTime()

    main_container:getChildByName("Text_2"):setString(TI18N("只需一个夺宝币，即有机会获得超值道具！若未中奖，\n夺宝币则按1:3返还为夺宝积分"))
    self.add_btn = main_container:getChildByName("add_btn")
    self.count_label = main_container:getChildByName("count_label")

    local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(37006)
    self.count_label:setString(count)
    local grade_icon = main_container:getChildByName("grade_icon")
    local item_config = Config.ItemData.data_get_data(37006)
    if item_config then
        local res = PathTool.getItemRes(item_config.icon)
        loadSpriteTexture(grade_icon, res, LOADTEXT_TYPE)
        grade_icon:setScale(0.40)
    end

    self.goods_scroll = main_container:getChildByName("goods_scroll")
    self.record_scroll = main_container:getChildByName("record_scroll")
    controller:sender25700()
end

--夺宝时间段
function TreasurePanel:setHolidayJoinTime()
    local time = model:setSnatchTime()
    self.holiday_time:setString(time)
end

--开奖物品
function TreasurePanel:setJoinLotteryData()
	if not self.item_scrollview then
        local view_size = self.goods_scroll:getContentSize()
        local setting = {
            start_x = 7,
            space_x = 5,
            start_y = 5,
            space_y = 0,
            item_width = 341,
            item_height = 260,
            row = 1,
            col = 2,
            need_dynamic = true
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.goods_scroll,cc.p(0, 0),ScrollViewDir.vertical,ScrollViewStartPos.top,view_size,setting)
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    --首次进来的时候不延迟刷新
    local delay_time = 0.5
    if self.first_comme_in == false then
        delay_time = 0.01
    end
    if self.update_join_ticket == nil then
        self.update_join_ticket = GlobalTimeTicket:getInstance():add(function()
            self:clearUpdataJoinTicket()
            self.show_list = {}
            self.show_list = model:getTreasureAllItemData()
            if self.show_list then
                table_sort(self.show_list,function(a,b) return a.pos < b.pos end)
            end
            if self.item_scrollview then
                if self.first_comme_in == false then
                    self.first_comme_in = true
                    self.item_scrollview:reloadData()
                else
                    self.item_scrollview:resetCurrentItems()
                end
            end
        end,delay_time)
    end
end

function TreasurePanel:clearUpdataJoinTicket()
    if self.update_join_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.update_join_ticket)
        self.update_join_ticket = nil
    end
end
function TreasurePanel:createNewCell()
	local cell = TreasureItem.new()
    return cell
end
function TreasurePanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
function TreasurePanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function TreasurePanel:register_event()
    if not self.holiday_treasure_event then
        self.holiday_treasure_event = GlobalEvent:getInstance():Bind(FestivalActionEvent.TreasureMessage,function(data)
            self:setJoinLotteryData()
            self:setLateWinLogs(data.logs)

            if data.state == 1 then
                local time = data.state_time - GameNet:getInstance():getTime()
                if time <= 0 then
                    time = 0
                end
                commonCountDownTime(self.text_remain, time)
            else
                doStopAllActions(self.text_remain)
                self.text_remain:setString(TI18N("尚未开启"))
            end
        end)
    end

	registerButtonEventListener(self.btn_my_record, function()
		controller:openTreasureMyServerView(true)
	end,true, 1)
	registerButtonEventListener(self.btn_change_shop, function()
		MallController:getInstance():openMallActionWindow(true, self.holiday_bid)
	end,true, 1)
	registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
		local config = Config.HolidaySnatchData.data_const
        if config and config.holiday_rule and config.holiday_rule.desc then
            TipsManager:getInstance():showCommonTips(config.holiday_rule.desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
	end,true, 1)
	registerButtonEventListener(self.record_scroll, function()
		controller:openTreasureAllServerView(true)
	end,false, 1)

    registerButtonEventListener(self.add_btn, function()
        local action_controller = ActionController:getInstance()
        local tab_vo = action_controller:getActionSubTabVo(ActionRankCommonType.trause_grade_shop)
        if tab_vo and action_controller.action_operate and action_controller.action_operate.tab_list[tab_vo.bid] then
            action_controller.action_operate:handleSelectedTab(action_controller.action_operate.tab_list[tab_vo.bid])
        else
            message(TI18N("该活动已结束或未到开启时间段"))
        end
    end,false, 1)

    if not self.grade_count_add_event then
        self.grade_count_add_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function(bag_code,temp_list)
            self:changeGradeCount(temp_list)
        end)
    end
    if not self.grade_count_delete_event then
        self.grade_count_delete_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function(bag_code,temp_list)
            self:changeGradeCount(temp_list)
        end)
    end
    if not self.grade_count_modify_event then
        self.grade_count_modify_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code,temp_list)
            self:changeGradeCount(temp_list)
        end)
    end
end

function TreasurePanel:changeGradeCount(list)
    for i,v in pairs(list) do
        if v.base_id == 37006 then
            local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(37006)
            self.count_label:setString(count)
        end
    end
end

--最近获奖日记
function TreasurePanel:setLateWinLogs(data)
    if not data or next(data) == nil then return end
    self:setRecentAwardsData(data)
end
--近期获奖
function TreasurePanel:setRecentAwardsData(data)
    for i=1, #data do
        if not self.recent_record_txt[i] then
            self.recent_record_txt[i] = createRichLabel(20, cc.c3b(255,248,191), cc.p(0, 0.5), cc.p(22, 90-(i*25)), nil, nil, 400)
            self.record_scroll:addChild(self.recent_record_txt[i])

            self.recent_record_num[i] = createRichLabel(20, cc.c3b(255,248,191), cc.p(1, 0.5), cc.p(694, 90-(i*25)), nil, nil, 300)
            self.record_scroll:addChild(self.recent_record_num[i])
        end
        local num = 0
        if data[i].awards and data[i].awards[1] then
            num = data[i].awards[1].num or 0
        end
        local txt_str = string_format(TI18N("<div fontcolor=fff8bf outline=2,#000000>恭喜 </div><div fontcolor=ffd34c outline=2,#000000>%s</div><div fontcolor=fff8bf outline=2,#000000> 夺得 </div><div fontcolor=ff9a09 outline=2,#000000>%sx%d</div>"), data[i].win_name, data[i].award_name, num)
        self.recent_record_txt[i]:setString(txt_str)
        local txt_num = string_format(TI18N("<div fontcolor=fff8bf outline=2,#000000>参与 </div><div fontcolor=5fd54c outline=2,#000000>%s </div><div fontcolor=fff8bf outline=2,#000000> 人次 总共 </div><div fontcolor=5fd54c outline=2,#000000>%s</div><div fontcolor=fff8bf outline=2,#000000> 人次</div>"),self:changeJoinNumber(data[i].join_num), self:changeJoinNumber(data[i].max_num))
        self.recent_record_num[i]:setString(txt_num)
    end
end

--近期获奖数字处理
function TreasurePanel:changeJoinNumber(num)
    if not num then return 0 end
    local init = 4 --数字保留的位数，用来保持字体平衡
    local temp_num = tostring(num)
    local len = string.len(temp_num)
    if init == len then
        return tostring(num)
    end
    local str = ""
    local temp_str = "  "
    for i=1,init-len do
        str = str..temp_str
    end
    str = str..num
    return str
end

function TreasurePanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end
function TreasurePanel:DeleteMe()
    self:clearUpdataJoinTicket()
    doStopAllActions(self.text_remain)
    if self.resources_load then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end

    if self.holiday_treasure_event then
        GlobalEvent:getInstance():UnBind(self.holiday_treasure_event)
        self.holiday_treasure_event = nil
    end
    if self.grade_count_add_event then
        GlobalEvent:getInstance():UnBind(self.grade_count_add_event)
        self.grade_count_add_event = nil
    end
    if self.grade_count_delete_event then
        GlobalEvent:getInstance():UnBind(self.grade_count_delete_event)
        self.grade_count_delete_event = nil
    end
    if self.grade_count_modify_event then
        GlobalEvent:getInstance():UnBind(self.grade_count_modify_event)
        self.grade_count_modify_event = nil
    end

	if self.treasure_bg_load then
        self.treasure_bg_load:DeleteMe()
        self.treasure_bg_load = nil
    end
    if self.record_scrollview then
		self.record_scrollview:DeleteMe()
		self.record_scrollview = nil
	end
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
end

--******************************
--物品获奖子项
TreasureItem = class("TreasureItem", function()
    return ccui.Widget:create()
end)

function TreasureItem:ctor()
    self:configUI()
    self:register_event()
end

function TreasureItem:configUI()
	self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("festivalaction/treasure_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(341,260))
    local main_container = self.root_wnd:getChildByName("main_container")
    
    self.tag = main_container:getChildByName("tag")
    self.tag:setVisible(false)
    self.tag:setLocalZOrder(10)
    self.icon = main_container:getChildByName("icon")
    self.btn_open = main_container:getChildByName("btn_open")
    self.btn_open:getChildByName("Text_6"):setString(TI18N("已开奖"))
    self.btn_open:setVisible(false)
    self.btn_get = main_container:getChildByName("btn_get")
    self.btn_get:getChildByName("Text_6"):setString(TI18N("待开奖"))
    self.btn_get:setVisible(false)
    self.btn_goto = main_container:getChildByName("btn_goto")
    self.btn_goto:getChildByName("Text_6"):setString(TI18N("立即参与"))
    self.btn_goto:setVisible(false)
    self.btn_next = main_container:getChildByName("btn_next")
    self.btn_next:getChildByName("Text_6"):setString(TI18N("未开奖"))
    self.btn_next:setVisible(false)
    self.next_text = main_container:getChildByName("next_text")
    self.next_text:setString(TI18N("未达到最低开奖人数"))
    self.next_text:setVisible(false)
    self.name = main_container:getChildByName("name")
    self.name:setString("")
    self.assets = main_container:getChildByName("assets")
    self.assets:setString("")

    --待开奖
    self.people_full = main_container:getChildByName("people_full")
    self.people_full:setVisible(false)
    self.full_bar = self.people_full:getChildByName("full_bar")
    self.full_bar:setScale9Enabled(true)
    self.full_bar:setPercent(100)
    self.people_full:getChildByName("Text_8"):setString(TI18N("人数已满"))
    self.people_full:getChildByName("Text_8_0"):setString(TI18N("倒计时："))
    self.time = self.people_full:getChildByName("time")
    self.time:setString("")

    --立即参与
    self.people_join = main_container:getChildByName("people_join")
    self.people_join:setVisible(false)
    self.join_bar = self.people_join:getChildByName("join_bar")
    self.join_bar:setScale9Enabled(true)
    self.join_bar:setPercent(0)
    self.people_join:getChildByName("Text_11"):setString(TI18N("已参与"))
    self.people_join:getChildByName("Text_11_0"):setString(TI18N("总需次数"))
    self.people_join:getChildByName("Text_11_1"):setString(TI18N("剩余"))
    self.current_count = self.people_join:getChildByName("current_count")
    self.current_count:setString("")
    self.totle_count = self.people_join:getChildByName("totle_count")
    self.totle_count:setString("")
    self.remain_count = self.people_join:getChildByName("remain_count")
    self.remain_count:setString("")

    --开奖阶段
    self.people_open = main_container:getChildByName("people_open")
    self.people_open:setVisible(false)
    self.people_open:getChildByName("Text_8_0"):setString(TI18N("倒计时："))
    self.open_time = self.people_open:getChildByName("time")
    self.open_time:setString("")

    self.goods_item = BackPackItem.new(nil,true,nil,0.8,false,true)
    main_container:addChild(self.goods_item)
    self.goods_item:setPosition(cc.p(65, 195))
   
end
function TreasureItem:setData(data)
    if not data then return end
    local item_data = goods_list[data.id]
    if item_data == nil then return end

    self.treasure_item_data = item_data--配置表的数据

    data.start_status = 1
    if model:getActionStartStatus() == 0 then
        if data.state == 4 then
            data.start_status = 2
            self.next_text:setString(TI18N("未达到最低开奖人数"))
        else
            data.state = 5
            data.start_status = 3
            self.next_text:setString(TI18N("活动尚未开启"))
        end
    end
    self.item_data = data --服务器的数据

    self.people_join:setVisible(data.state == 0)
    self.people_full:setVisible(data.state == 1)
    self.people_open:setVisible(data.state == 2 or data.state == 3)
    self.btn_goto:setVisible(data.state == 0)
    self.btn_get:setVisible(data.state == 1)
    self.btn_open:setVisible(data.state == 2 or data.state == 3)
    self.btn_next:setVisible(data.state == 4 or data.state == 5)
    self.next_text:setVisible(data.state == 4 or data.state == 5)
        
    self.name:setString(item_data.name)
    self.tag:setVisible(item_data.is_hot == 1)

    self:showJoinMessage(item_data,data)

	if self.goods_item then
		self.goods_item:setBaseData(item_data.award[1][1], item_data.award[1][2])
	end
	local item_config = Config.ItemData.data_get_data(37006)
	if item_config then
	    local res = PathTool.getItemRes(item_config.icon)
	    loadSpriteTexture(self.icon, res, LOADTEXT_TYPE)
	    self.icon:setScale(0.40)
	end
    self.assets:setString(item_data.price)
end

--显示参与的信息
--data：配置表数据
--item_data：服务器的数据
function TreasureItem:showJoinMessage(data,item_data)
    if self.people_full:isVisible() then
        model:CountDownTime(self.time,item_data.state_time)
    elseif self.people_join:isVisible() then
        local num = item_data.num or 0
        local limit_max = data.limit_max or 0
        
        --本人参与次数
        local my_join_count = 0
        if item_data.ext then
            local my_join_list = keyfind('key', 1, item_data.ext) or nil
            if my_join_list then
                my_join_count = my_join_list.val or 0
            end
        end
        self.current_count:setString(my_join_count)

        self.totle_count:setString(limit_max)
        local remain_num = limit_max - num
        if remain_num <= 0 then
            remain_num = 0
        end
        self.remain_count:setString(remain_num)

        local percent = num / limit_max * 100
        self.join_bar:setPercent(percent)
    elseif self.people_open:isVisible() then
        model:CountDownTime(self.open_time,item_data.state_time)
    end
end

function TreasureItem:register_event()
	registerButtonEventListener(self.btn_open, function()
        if self.item_data then
            controller:openTreasureOpenAwardView(true,self.item_data)
        end
	end,true, 1)
	registerButtonEventListener(self.btn_goto, function()
        if self.treasure_item_data and self.item_data then
    		controller:openTreasureJoinView(true, self.treasure_item_data,self.item_data)
        end
	end,true, 1)

    registerButtonEventListener(self.btn_get, function()
        message(TI18N("尚未开奖，请耐心等待哦~~~"))
    end,true, 1)
    registerButtonEventListener(self.btn_next, function()
        if self.item_data and self.item_data.start_status then
            if self.item_data.start_status == 1 or self.item_data.start_status == 2 then
                message(TI18N("未达到最低开奖人数，请参与下一轮~~~"))
            elseif self.item_data.start_status == 3 then
                message(TI18N("活动尚未开启~~~"))
            end
        end
    end,true, 1)
end

function TreasureItem:DeleteMe()
    doStopAllActions(self.time)
    doStopAllActions(self.open_time)
	if self.goods_item then 
       self.goods_item:DeleteMe()
       self.goods_item = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end