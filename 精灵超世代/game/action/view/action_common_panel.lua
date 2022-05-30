--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 活动通用界面
-- @DateTime:    2019-04-10 10:29:42
-- *******************************
--[[
特殊说明：积天豪礼变成常驻模式，去掉倒计时显示
]]
ActionCommonPanel = class("ActionCommonPanel", function()
	return ccui.Widget:create()
end)

local color_text = {
    [1] = cc.c4b(0x80,0xf7,0x31,0xff),
    [2] = cc.c4b(0x64,0x32,0x23,0xff),
}

local controll = ActionController:getInstance()
function ActionCommonPanel:ctor(bid)
    self.holiday_bid = bid
	self:configUI()
    self:register_event()
    self.cell_data_list = {}
end

function ActionCommonPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_hero_expedit_panel"))
	self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.title_con = self.main_container:getChildByName("title_con")
    self.time_label = self.title_con:getChildByName("label_time_key")
    self.time_label:setString(TI18N("剩余时间："))
    self.time_text = self.title_con:getChildByName("label_time")
    --self.time_text:setTextColor(color_text[1])
    self.time_text:setAnchorPoint(cc.p(0, 0.5))
    self.rank_btn = self.title_con:getChildByName("rank_btn")
    self.rank_btn:getChildByName("label"):setString(TI18N("详细排行"))
    self.reward_btn = self.title_con:getChildByName("reward_btn")
    self.reward_btn:getChildByName("label"):setString(TI18N("奖励预览"))
    self.btn_rule = self.title_con:getChildByName("btn_rule") --规则说明按钮，，就是问号的图片
    self.btn_rule:setVisible(false)

    self:loadBannerImage()

    self.good_cons = self.main_container:getChildByName("charge_con")
    self:updateScrollviewList()
    controll:cs16603(self.holiday_bid)
end

function ActionCommonPanel:updateScrollviewList()
    if self.child_scrollview == nil then
        local scroll_view_size = self.good_cons:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 10,                     -- y方向的间隔
            item_width = 680,                -- 单元的尺寸width
            item_height = 152,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 4,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.child_scrollview = CommonScrollViewSingleLayout.new(self.good_cons, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.child_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.child_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.child_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.child_scrollview:setSwallowTouches(false)
    self.child_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionCommonPanel:createNewCell(width, height)
    local cell = ActionCommonItem.new()
	return cell
end

--获取数据数量
function ActionCommonPanel:numberOfCells()
    if not self.cell_data_list then return 0 end
    return #self.cell_data_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function ActionCommonPanel:updateCellByIndex(cell, index)
    if not self.cell_data_list then return end
    cell.index = index
    if self.tab ~= nil and cell.setExtendData ~= nil then
        cell:setExtendData(self.tab)
    end
    local cell_data = self.cell_data_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

--加载banner图片
function ActionCommonPanel:loadBannerImage()
    if self.holiday_bid == ActionRankCommonType.hero_expedit or self.holiday_bid == ActionRankCommonType.adventure then
        self.btn_rule:setVisible(true)
    elseif self.holiday_bid == ActionRankCommonType.longin_gift or self.holiday_bid == ActionRankCommonType.luckly_egg or
           self.holiday_bid == ActionRankCommonType.summon_luxury or self.holiday_bid == ActionRankCommonType.hero_awake or
           self.holiday_bid == ActionRankCommonType.recruit_luxury then
        self.time_label:setAnchorPoint(cc.p(1, 0.5))
        self.time_label:setPosition(cc.p(500, 20))
        self.time_text:setAnchorPoint(cc.p(0, 0.5))
        self.time_text:setPosition(cc.p(510, 20))
        self.reward_btn:setVisible(false)
        self.rank_btn:setVisible(false)
    --倒计时在右边的时候（本来在左边的）
    elseif self.holiday_bid == ActionRankCommonType.acc_luxury or self.holiday_bid == ActionRankCommonType.totle_charge or
           self.holiday_bid == ActionRankCommonType.totle_consume or self.holiday_bid == ActionRankCommonType.fusion_blessing or 
           self.holiday_bid == ActionRankCommonType.updata_star or self.holiday_bid == ActionRankCommonType.limit_charge or
           self.holiday_bid == ActionRankCommonType.limit_charge_1 or self.holiday_bid == ActionRankCommonType.new_totle_charge
           or self.holiday_bid == ActionRankCommonType.new_totle_charge1 then

        if self.holiday_bid == ActionRankCommonType.acc_luxury then
            self.btn_rule:setVisible(true)
        end
        self.time_label:setPosition(cc.p(450, 16))
        self.time_text:setAnchorPoint(cc.p(0, 0.5))
        self.time_text:setPosition(cc.p(547, 16))
        self.reward_btn:setVisible(false)
        self.rank_btn:setVisible(false) 
    end

    -- 横幅图片
    local title_img = self.title_con:getChildByName("title_img")
    local str_banner = "txt_cn_welfare_banner11"
    local tab_vo = controll:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.reward_title ~= "" and tab_vo.reward_title then
        str_banner = tab_vo.reward_title
    end

    local res = PathTool.getWelfareBannerRes(str_banner)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(title_img) then
                loadSpriteTexture(title_img, res, LOADTEXT_TYPE)
            end
        end,self.item_load)
    end
end

function ActionCommonPanel:register_event()
    if not self.update_holiday_common_event then
        self.update_holiday_common_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
            if not data then return end
            if data.bid == self.holiday_bid then
                self:setPanelData(data)
            end
        end)
    end    
    registerButtonEventListener(self.rank_btn, function()
        self:jumpRankView()
    end ,true, 1)
    registerButtonEventListener(self.reward_btn, function()
        RankController:getInstance():openRankRewardPanel(true, self.holiday_bid)
    end ,true, 1)
    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
        local config = Config.HolidayClientData.data_constant.expedit_rules
        if self.holiday_bid == ActionRankCommonType.adventure then
            config = Config.HolidayClientData.data_constant.adventure_rules
        elseif self.holiday_bid == ActionRankCommonType.acc_luxury then
            config = Config.HolidayClientData.data_constant.luxury_rules
        end
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    end ,true, 1)
end

function ActionCommonPanel:setPanelData(data)
    local is_time_end = false
    local time = data.remain_sec or 0
    if self.holiday_bid == ActionRankCommonType.epoint_gold or self.holiday_bid == ActionRankCommonType.speed_fight or
       self.holiday_bid == ActionRankCommonType.voyage or self.holiday_bid == ActionRankCommonType.hero_expedit or 
       self.holiday_bid == ActionRankCommonType.adventure or self.holiday_bid == ActionRankCommonType.planes_rank then
        --排行活动的,,提前一天显示已结束，然后一天过后，活动就会消失
        time = time - 24*60*60
        if time <= 0 then
            time = 0
            is_time_end = true
        end
    end
    if self.child_scrollview then
        controll:getModel():sortItemList(data.aim_list)
        local tab = {}
        tab.bid = self.holiday_bid
        tab.time_end = is_time_end --排行活动用到，用来判断时间是否结束
        tab.finish = data.finish --登录\累计充值
        self.cell_data_list = data.aim_list
        self.tab = tab
        self.child_scrollview:reloadData()
    end
    -- 积天豪礼特殊处理
    if self.holiday_bid == ActionRankCommonType.acc_luxury then
        self.time_text:setVisible(false)
        self.time_label:setVisible(false)
    else
        self.time_text:setVisible(true)
        self.time_label:setVisible(true)
        controll:getModel():setCountDownTime(self.time_text,time,is_time_end)
    end
end
--跳转排行，，目前仅用排行的活动
function ActionCommonPanel:jumpRankView()
    local jump_rank = RankConstant.RankType.hero_expedit
    if self.holiday_bid == ActionRankCommonType.speed_fight then
        jump_rank = RankConstant.RankType.speed_fight
    elseif self.holiday_bid == ActionRankCommonType.voyage then
        jump_rank = RankConstant.RankType.voyage
    elseif self.holiday_bid == ActionRankCommonType.epoint_gold then
        jump_rank = RankConstant.RankType.pointglod
    elseif self.holiday_bid == ActionRankCommonType.adventure then
        jump_rank = RankConstant.RankType.adventure_muster
    elseif self.holiday_bid == ActionRankCommonType.planes_rank then --位面排行榜
        jump_rank = RankConstant.RankType.planes_rank
    end
    RankController:getInstance():openRankView(true, jump_rank)
end

function ActionCommonPanel:setVisibleStatus(bool)
	bool = bool or false
	self:setVisible(bool)
end

function ActionCommonPanel:DeleteMe()
	doStopAllActions(self.time_text)
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    if self.child_scrollview then
        self.child_scrollview:DeleteMe()
    end
    self.child_scrollview = nil
    if self.update_holiday_common_event then
        GlobalEvent:getInstance():UnBind(self.update_holiday_common_event)
        self.update_holiday_common_event = nil
    end
end

------------------------------------------
-- 子项
ActionCommonItem = class("ActionCommonItem", function()
    return ccui.Widget:create()
end)

function ActionCommonItem:ctor()
    self:configUI()
    self:register_event()
    self.good_list_data = {}
end

function ActionCommonItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("welfare/luxury_item"))
    self:setContentSize(cc.size(680,152))
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.btn_goto = main_container:getChildByName("btn_goto")
    self.btn_goto_label = self.btn_goto:getChildByName("Text_7_0")
    self.btn_goto_label:setString(TI18N("前往"))
    self.btn_goto:setVisible(false)
    self.btn_get = main_container:getChildByName("btn_get")
    self.btn_get_label = self.btn_get:getChildByName("Text_7")
    self.btn_get_label:setString(TI18N("领取"))
    self.btn_get:setVisible(false)
    self.has_get = main_container:getChildByName("has_get")
    self.has_get:setVisible(false)
    self.text_tesk = main_container:getChildByName("text_tesk")
    self.text_tesk:setString("")

    self.item_goods = main_container:getChildByName("good_cons")
    self:updateScrollviewList()
    self.title_desc = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0,0.5), cc.p(15,130), nil, nil, 500)
    main_container:addChild(self.title_desc)
end

function ActionCommonItem:updateScrollviewList()
    if self.good_scrollview == nil then
        local scroll_view_size = self.item_goods:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 5,                     -- x方向的间隔
            start_y = 8,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = BackPackItem.Width*0.80,                -- 单元的尺寸width
            item_height = BackPackItem.Height*0.80,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 0,                         -- 列数，作用于垂直滚动类型
            delay = 4,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.good_scrollview = CommonScrollViewSingleLayout.new(self.item_goods, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.good_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.good_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.good_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.good_scrollview:setSwallowTouches(false)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionCommonItem:createNewCell(width, height)
    local cell = BackPackItem.new()
    cell:setDefaultTip()
    cell:setSwallowTouches(false)
    cell:setScale(0.80)
	return cell
end

--获取数据数量
function ActionCommonItem:numberOfCells()
    if not self.good_list_data then return 0 end
    return #self.good_list_data
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function ActionCommonItem:updateCellByIndex(cell, index)
    if not self.good_list_data then return end
    cell.index = index
    local cell_data = self.good_list_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ActionCommonItem:register_event()
    registerButtonEventListener(self.btn_get, function()
        if self.holiday_item_bid and self.data then
            controll:cs16604(self.holiday_item_bid,self.data.aim)
        end
    end ,true, 1)
    registerButtonEventListener(self.btn_goto, function()
        self:gotoSpecificView()
    end ,true, 1)
end
--点击前往按钮的处理
function ActionCommonItem:gotoSpecificView()
    --直接跳转到充值界面的
    if self.holiday_item_bid and (self.holiday_item_bid == ActionRankCommonType.acc_luxury or self.holiday_item_bid == ActionRankCommonType.totle_charge or
                                  self.holiday_item_bid == ActionRankCommonType.limit_charge or self.holiday_item_bid == ActionRankCommonType.limit_charge_1
                                  or self.holiday_item_bid == ActionRankCommonType.new_totle_charge or self.holiday_item_bid == ActionRankCommonType.new_totle_charge1 ) then
        --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
    elseif self.holiday_item_bid and self.holiday_item_bid == ActionRankCommonType.luckly_egg then --砸蛋的跳转是特殊的
        local id = ActionRankCommonType.smashegg
        local tab_vo = controll:getActionSubTabVo(id)
        if tab_vo then
            if controll.action_operate then
                controll.action_operate:handleSelectedTab(controll.action_operate.tab_list[id])
            end
        end
    elseif self.holiday_item_bid and self.holiday_item_bid == ActionRankCommonType.hero_awake then --觉醒豪礼特殊处理
        local hero_vo = HeroController:getInstance():getModel():getTopLevHeroInfoByBid(self.cur_bid)
        local all_role_list = HeroController:getInstance():getModel():getAllHeroArray()
        --无指定宝可梦则前往限时召唤获取
        if not hero_vo or not all_role_list or all_role_list.size == 0 then
            StrongerController:getInstance():clickCallBack(411)
        else
            HeroController:getInstance():openHeroMainInfoWindow(true, hero_vo, all_role_list.items, {show_model_type = HeroConst.BagTab.eBagHero})
        end
    else
        local num
        if self.holiday_item_bid == ActionRankCommonType.speed_fight then
            num = 132
        elseif self.holiday_item_bid == ActionRankCommonType.voyage then
            num = 126
        elseif self.holiday_item_bid == ActionRankCommonType.hero_expedit then
            num = 151
        elseif self.holiday_item_bid == ActionRankCommonType.epoint_gold then
            num = 123
        elseif self.holiday_item_bid == ActionRankCommonType.adventure then
            num = 407
        elseif self.holiday_item_bid == ActionRankCommonType.updata_star then
            num = 404
        elseif self.holiday_item_bid == ActionRankCommonType.fusion_blessing then
            num = 155
        elseif self.holiday_item_bid == ActionRankCommonType.summon_luxury then
            num = 120
        elseif self.holiday_item_bid == ActionRankCommonType.recruit_luxury then
            num = 204
        elseif self.holiday_item_bid == ActionRankCommonType.planes_rank then
            num = 151
        end
        if num then
            StrongerController:getInstance():clickCallBack(num)
        end
    end
end

function ActionCommonItem:setExtendData(tab)
    self.holiday_item_bid = tab.bid
    self.is_activity_end = tab.time_end
    self.finish = tab.finish
end

function ActionCommonItem:setData(data)
    self.data = data
    self:getButtonTeskProgress(data)
    self.title_desc:setString(data.aim_str)
    --有前往按钮的时候，需要判断按钮是否显示
    if self.holiday_item_bid ~= ActionRankCommonType.longin_gift then
        self.btn_goto:setVisible(data.status == 0)
    else
        if data.status == 0 then
            self.btn_get:setVisible(true)
            setChildUnEnabled(true, self.btn_get)
            --self.btn_get_label:disableEffect(cc.LabelEffect.OUTLINE)
        else
            setChildUnEnabled(false, self.btn_get)
            --self.btn_get_label:setColor(Config.ColorData.data_color4[1])
            --self.btn_get_label:enableOutline(Config.ColorData.data_color4[277], 2)
        end    
    end

    if self.is_activity_end == true and data.status == 0 then
        self.btn_goto_label:setString(TI18N("已结束"))
        --self.btn_goto_label:disableEffect(cc.LabelEffect.OUTLINE)
        setChildUnEnabled(true, self.btn_goto)
        self.btn_goto:setTouchEnabled(false)
    end

    -- 物品列表
    local item_list = data.item_list
    local list = {}
    for k, v in pairs(item_list) do
        local vo = {}
        vo.bid = v.bid
        vo.quantity = v.num
        table.insert(list, vo)
    end
    if #list > 4 then
        self.good_scrollview:setClickEnabled(true)
    else
        self.good_scrollview:setClickEnabled(false)
    end
    self.good_list_data = list
    self.good_scrollview:reloadData()
end
--读取按钮上方进度
function ActionCommonItem:getButtonTeskProgress(data)
    local str = ""
    if self.holiday_item_bid ~= ActionRankCommonType.longin_gift then
        local totle_count,current_count
        local totle_list = keyfind('aim_args_key', 4, data.aim_args) or nil
        if totle_list then
            totle_count = totle_list.aim_args_val or 0
        end
        local current_list = keyfind('aim_args_key', 5, data.aim_args) or nil
        if current_list then
            current_count = current_list.aim_args_val or 0
        end
        if totle_count and current_count then
            str = string.format("(%d/%d)",current_count,totle_count)
        end

        --升星有礼、融合祝福、觉醒豪礼
        local count
        local count_list = keyfind('aim_args_key', 6, data.aim_args) or nil
        if count_list then
            count = count_list.aim_args_val or 0
        end
        if count and totle_count then
            str = string.format("(%d/%d)", count, totle_count)
            if count >= totle_count and data.status == 0 then
                data.status = 2
            end
        end
        --觉醒豪礼所用
        local bid_list = keyfind('aim_args_key', 18, data.aim_args) or nil
        if bid_list then
            self.cur_bid = bid_list.aim_args_val or 0
        end
        --充值类型的
        if self.holiday_item_bid == ActionRankCommonType.acc_luxury then
            if data.status == 0 then
                str = "(0/1)"
            else
                str = "(1/1)"
            end
        elseif self.holiday_item_bid == ActionRankCommonType.totle_charge or self.holiday_item_bid == ActionRankCommonType.totle_consume or
               self.holiday_item_bid == ActionRankCommonType.limit_charge or self.holiday_item_bid == ActionRankCommonType.limit_charge_1 or
               self.holiday_item_bid == ActionRankCommonType.summon_luxury or self.holiday_item_bid == ActionRankCommonType.recruit_luxury
               or self.holiday_item_bid == ActionRankCommonType.new_totle_charge or self.holiday_item_bid == ActionRankCommonType.new_totle_charge1 then --累充和累消的
            str = string.format("(%d/%d)",self.finish,data.aim)
        end
    else
        str = string.format("(%d/%d)",self.finish,data.aim)
    end
    self.text_tesk:setString(str)
    self.btn_get:setVisible(data.status == 1)
    self.has_get:setVisible(data.status == 2)
end

function ActionCommonItem:DeleteMe()
    if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end