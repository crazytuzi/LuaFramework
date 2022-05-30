-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      精英赛主界面
-- <br/>Create: 2019年2月16日
ElitematchMainWindow = ElitematchMainWindow or BaseClass(BaseView)

local controller = ElitematchController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort

function ElitematchMainWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("elitematch", "elitematch"), type = ResourcesType.plist},
        -- {path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_66",true), type = ResourcesType.single }
        -- {path = PathTool.getPlistImgForDownLoad("bigbg/elitematch", "elitematch_main_bg", true), type = ResourcesType.single}
        -- {path = PathTool.getPlistImgForDownLoad("bigbg/elitematch", "elitematch_matching_bg", true), type = ResourcesType.single}
    }
    self.layout_name = "elitematch/elitematch_main_window"

    self.tab_list = {}
    self.is_record_one = true
end

function ElitematchMainWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    local scale = display.getMaxScale() or 1
    self.background:setScale(scale)
    self:setBackgroundImg("elitematch_main_bg")

    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 1)
    self.container_size = self.container:getContentSize()
    self.close_btn = self.container:getChildByName("close_btn")

    self.top_panel = self.container:getChildByName("top_panel")
    self.bottom_panel = self.container:getChildByName("bottom_panel")

    --各种按钮
    self.rule_btn = self.container:getChildByName("rule_btn")
    self.rule_btn:getChildByName("label"):setString(TI18N("规则说明"))
    self.form_btn = self.container:getChildByName("form_btn")
    self.form_btn:getChildByName("label"):setString(TI18N("阵容调整"))
    self.record_btn = self.container:getChildByName("record_btn")
    self.record_btn:getChildByName("label"):setString(TI18N("赛季传奇"))
    self.challenge_btn = self.container:getChildByName("challenge_btn")
    self.challenge_btn:getChildByName("label"):setString(TI18N("挑战记录"))
    self.shop_btn = self.container:getChildByName("shop_btn")
    self.shop_btn:getChildByName("label"):setString(TI18N("段位商店"))
    
    self.elite_btn = self.container:getChildByName("elite_btn")
    self.elite_btn:getChildByName("label"):setString(TI18N("段位说明"))
    self.personal_btn = self.container:getChildByName("personal_btn")
    self.personal_btn:getChildByName("label"):setString(TI18N("个人战绩"))

    --战前宣言去除
    self.declaration_btn = self.container:getChildByName("declaration_btn")
    self.declaration_btn:getChildByName("label"):setString(TI18N("战前宣言"))
    self.declaration_btn:setVisible(false)

    self.detail_btn = self.container:getChildByName("detail_btn")
    self.detail_btn:getChildByName("label"):setString(TI18N("奖励一览"))

    self.orderaction_btn = self.container:getChildByName("orderaction_btn")
    self.orderaction_btn:getChildByName("label"):setString(TI18N("王者之证"))

    --icon
    self.level_node = self.container:getChildByName("level_node")
    self.level_txt_icon = self.container:getChildByName("level_txt_icon")
    self.level_txt = self.level_txt_icon:getChildByName("text")
    --提示tips
    self.tips_node =  self.container:getChildByName("tips_node")

    self.tab_container = self.top_panel:getChildByName("tab_container")
    for i=1,2 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.label = tab_btn:getChildByName("title")
            object.label:setTextColor(Config.ColorData.data_new_color4[6])
            object.label:disableEffect(cc.LabelEffect.SHADOW)
            object.tab_btn = tab_btn
            object.index = i
            self.tab_list[i] = object
            setLabelAutoScale(object.label,object.unselect_bg,10)
        end
    end
    --比赛时间
    self.match_time = createRichLabel(18, Config.ColorData.data_new_color4[1], cc.p(0.5,0.5), cc.p(360,-41), nil, nil, 600)
    self.top_panel:addChild(self.match_time)
    --预计王者比赛时间
    self.king_match_time = createRichLabel(18, Config.ColorData.data_new_color4[1], cc.p(0.5,0.5), cc.p(360,-80), nil, nil, 500)
    self.top_panel:addChild(self.king_match_time)

    --匹配比赛
    self.match_btn = self.bottom_panel:getChildByName("match_btn")
    self.match_btn_icon = self.match_btn:getChildByName("icon")
    self.match_btn_label = self.match_btn:getChildByName("label")
    self.match_btn_label:setString(TI18N("进入匹配"))
    
    self.goto_btn = self.bottom_panel:getChildByName("goto_btn")
    self.goto_btn_label = self.goto_btn:getChildByName("label")

    self.match_btn:setVisible(false)
    self.goto_btn:setVisible(false)
    -- self.match_btn_label2 = createRichLabel(26, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5), cc.p(92.33,31.52), nil, nil, 600)
    -- self.match_btn:addChild(self.match_btn_label2)
    
    local panel = self.bottom_panel:getChildByName("panel")
    self.panel = panel
    -- self.detail_btn = createRichLabel(22, cc.c4b(0x3d,0xf4,0x24,0xff), cc.p(0.5, 0.5), cc.p(596.60, 390))
    -- self.detail_btn:setString(string_format("<div outline=2,#000000 href=xxx>%s</div>", TI18N("详情")))
    -- self.detail_btn:addTouchLinkListener(function(type, value, sender, pos)
    --     if self.scdata then
    --         controller:openElitematchRewardPanel(true, 1, self.scdata.lev, self.scdata.rank)
    --     end
    -- end, { "click", "href" })
    -- panel:addChild(self.detail_btn)

    self.my_rank_label = createRichLabel(22, Config.ColorData.data_new_color4[1], cc.p(0.5,0.5), cc.p(SCREEN_WIDTH / 2,310), nil, nil, 600)
    panel:addChild(self.my_rank_label)
    --领取
    self.receive_btn = panel:getChildByName("receive_btn")
    self.receive_btn_label = self.receive_btn:getChildByName("label")
    self.receive_btn_label:setString(TI18N("领取"))
    self.current_tips = panel:getChildByName("current_tips")
    self.level_up_tips = panel:getChildByName("level_up_tips")
    self.next_level_tips = panel:getChildByName("next_level_tips")

    self.cool_time = createRichLabel(18, cc.c4b(0xff,0xf8,0xbf,0xff), cc.p(0.5,0.5), cc.p(360,220), nil, nil, 600)
    self.bottom_panel:addChild(self.cool_time)

    self.item_scrollview = panel:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    self.item_scrollview:setSwallowTouches(false)
    self.leve_up_node = panel:getChildByName("leve_up_node")
    self.reward_label = createRichLabel(18, Config.ColorData.data_new_color4[6], cc.p(0,0.5), cc.p(53,475), nil, nil, 600)
    panel:addChild(self.reward_label)

    local buy_panel = panel:getChildByName("buy_panel")
    buy_panel:getChildByName("key"):setString(TI18N("匹配次数:"))
    self.buy_count = buy_panel:getChildByName("label")
    self.buy_btn = buy_panel:getChildByName("add_btn")

    self.buy_tips = createRichLabel(18, Config.ColorData.data_new_color4[1], cc.p(1,0.5), cc.p(635,135), nil, nil, 600)
    panel:addChild(self.buy_tips)

    self.bule_tips = createLabel(20,Config.ColorData.data_new_color4[1],Config.ColorData.data_new_color4[6],self.level_up_tips:getPositionX(),560 ,"",panel,2, cc.p(0.5,0.5))
    self.bule_tips:setString(TI18N("蓝条部分为降级缓冲经验"))
    self.bule_tips:setVisible(false)
    self:adaptationScreen()

end

--设置适配屏幕
function ElitematchMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.container)
    local bottom_y = display.getBottom(self.container)
    local left_x = display.getLeft(self.container)
    local right_x = display.getRight(self.container)

    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (self.container_size.height - tab_y))

    local bottom_panel_y = self.bottom_panel:getPositionY()
    self.bottom_panel:setPositionY(bottom_y + bottom_panel_y)
    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(bottom_y + close_btn_y)

    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
end


function ElitematchMainWindow:register_event(  )
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
    registerButtonEventListener(self.rule_btn, handler(self, self.onClickRuleBtn), true, 1)
    registerButtonEventListener(self.form_btn, handler(self, self.onClickFormBtn), true, 1)
    registerButtonEventListener(self.record_btn, handler(self, self.onClickRecordBtn), true, 1)
    registerButtonEventListener(self.challenge_btn, handler(self, self.onClickChallengeBtn), true, 1)
    registerButtonEventListener(self.shop_btn, handler(self, self.onClickShopBtn), true, 1)
    registerButtonEventListener(self.elite_btn, handler(self, self.onClickEliteBtn), true, 1)
    registerButtonEventListener(self.personal_btn, handler(self, self.onClicPersonalBtn), true, 1)
    registerButtonEventListener(self.declaration_btn, handler(self, self.onClicDeclarationBtn), true, 1)
    registerButtonEventListener(self.detail_btn, handler(self, self.onClicDetailBtn), true, 1)
    registerButtonEventListener(self.buy_btn, handler(self, self.onClickBuyCountBtn), true, 1)

    registerButtonEventListener(self.match_btn, handler(self, self.onClickMatchBtn), true, 1)
    registerButtonEventListener(self.goto_btn, handler(self, self.onClickGotoBtn), true, 1)
    registerButtonEventListener(self.orderaction_btn, handler(self, self.onClickOrderactionBtn), true, 1)

    self.receive_btn:addTouchEventListener(function(sender, event_type)
        if not self.show_data then return end
        if self.show_data.flag ~= 1 then
            return 
        end
        customClickAction(sender, event_type, scale)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:onClickReceiveBtn()
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

    self:addGlobalEvent(ElitematchEvent.Get_Elite_Main_Info_Event, function(scdata)
        if not scdata then return end
        self.is_sending = false
        self:setData(scdata)
    end)

    -- --挑战对手返回
    self:addGlobalEvent(ElitematchEvent.Elite_Challenge_count_Event, function(data)
        if not data then return end
        if not self.scdata then return end
        self.scdata.day_combat_count = data.day_combat_count
        self:updateBuyCount(data.day_combat_count)
        model:checkRedPoint(true)
    end)   

    --购买次数
    self:addGlobalEvent(ElitematchEvent.Elite_buy_count_Event, function(data)
        if not data then return end
        if not self.scdata then return end
        self.scdata.day_buy_count = data.day_buy_count
        self.scdata.day_combat_count = data.day_combat_count
        self:updateBuyCount(data.day_combat_count)
        model:checkRedPoint(true)
    end)

    --领取奖励返回
    self:addGlobalEvent(ElitematchEvent.Elite_Receive_Reward_Event, function(data)
        if not data then return end
        if not self.scdata then return end
        self.scdata.lev_reward = data.lev_reward
        self:updateCommonInfo()
        model:checkRedPoint(true)
    end)
    --请求开战时间
    self:addGlobalEvent(ElitematchEvent.Elite_Start_Time_Event, function(data)
        if not data then return end
        if self.is_record_one then
            self.fight_data = data
            self.is_record_one = false
        end
        if not self.scdata then return end
        if self.scdata.state == 0 then return end
       --更新按钮情况
        self:updateMatchBtn(data)
        self:changeSelectedTab(self.match_type, true)
    end)

    --战令信息
    self:addGlobalEvent(ElitematchEvent.Elite_OrderAction_Init_Event, function(data)
        if not data then return end
        self:updateOrderactionBtn(data.rmb_status)
        self:updateOrderactionRed()
    end)

    --战令红点刷新
    self:addGlobalEvent(ElitematchEvent.Elite_OrderAction_First_Red_Event, function()
        self:updateOrderactionRed()
    end)
end

-- 关闭
function ElitematchMainWindow:onClickCloseBtn(  )
    controller:openElitematchMainWindow(false)
end
-- 打开规则说明
function ElitematchMainWindow:onClickRuleBtn(  )
    if not self.scdata  then return end
    if self.scdata.state == 0 then return end
    MainuiController:getInstance():openCommonExplainView(true, Config.ArenaEliteData.data_explain)
end
-- 打开说明
function ElitematchMainWindow:onClickEliteBtn(  )
    if not self.scdata  then return end
    if self.scdata.state == 0 then return end
    MainuiController:getInstance():openCommonExplainView(true, Config.ArenaEliteData.data_explain2,TI18N("段位说明"))
end
-- 打开个人战绩
function ElitematchMainWindow:onClicPersonalBtn(  )
    if not self.scdata  then return end
    if self.scdata.state == 0 then return end
    controller:openElitematchPersonalInfoPanel(true, self.scdata.period)
end
-- 打开宣言设置
function ElitematchMainWindow:onClicDeclarationBtn(  )
    if not self.scdata  then return end
    if self.scdata.state == 0 then return end
    controller:openElitematchDeclarationPanel(true)
end
-- 打开奖励信息
function ElitematchMainWindow:onClicDetailBtn(  )
    if not self.scdata  then return end
    if self.scdata.state == 0 then return end
    controller:openElitematchRewardPanel(true, 1, self.scdata.lev, self.scdata.rank)
end
-- 打开调整布阵
function ElitematchMainWindow:onClickFormBtn(  )
    if not self.scdata  then return end
    if self.scdata.state == 0 then return end
    local match_type
    if self.scdata.is_king == 1 then
        match_type = 2
    else
        match_type = 1
    end
    HeroController:getInstance():openFormMainWindow(true, PartnerConst.Fun_Form.EliteMatch, {match_type = match_type})
end
-- 历史赛季
function ElitematchMainWindow:onClickRecordBtn(  )
    if not self.scdata  then return end
    if self.scdata.state == 0 then return end
    local period = self.scdata.period - 1
    if period <= 0 then
        period = 1
    end
    local max_period = self.scdata.period
    local zone_id = self.scdata.zone_id
    controller:openElitematchHistoryRecordWindow(true, period, max_period, zone_id)
end
-- 挑战记录
function ElitematchMainWindow:onClickChallengeBtn(  )
    if not self.scdata  then return end
    if self.scdata.state == 0 then return end
    controller:openElitematchFightRecordPanel(true, 1, self.scdata.lev)
end

-- 商店
function ElitematchMainWindow:onClickShopBtn(  )
    if not self.scdata  then return end
    if self.scdata.state == 0 then return end
    -- local setting = {}
    -- setting.mall_type = MallConst.MallType.EliteShop
    -- setting.item_id = Config.ItemData.data_assets_label2id.elite_coin
    -- setting.config = Config.ExchangeData.data_shop_exchage_elite
    -- setting.shop_name = TI18N("荣耀商店")
    -- MallController:getInstance():openMallSingleShopPanel(true, setting)
    MallController:getInstance():openMallPanel(true, MallConst.MallType.EliteShop)
end

-- 领取奖励
function ElitematchMainWindow:onClickReceiveBtn(  )
    if not self.scdata  then return end
    if self.scdata.state == 0 then return end
    if self.show_data and  self.show_data.flag == 1 then
        controller:sender24915(self.show_data.lev)
    end
end

-- 购买次数
function ElitematchMainWindow:onClickBuyCountBtn(  )
    if not self.scdata  then return end
    if self.scdata.state == 0 then return end

    local config = Config.ArenaEliteData.data_elite_const.match_count
    if config then 
        -- if self.scdata.day_combat_count >= config.val then
        --     message(TI18N("匹配次数已满"))
        --     return
        -- end

        local buy_config = Config.ArenaEliteData.data_elite_buy[(self.scdata.day_buy_count + 1)]

        if buy_config == nil then
            message(TI18N("购买次数已达上限"))
            return
        end
        

        if buy_config.need_vip > 0 then
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo and role_vo.vip_lev < buy_config.need_vip then
                message(string_format(TI18N("需要vip%s才能购买"), buy_config.need_vip))
                return
            end
            if role_vo == nil then
                return
            end
        end
        
        local item_id =  buy_config.cost[1][1] 
        local count =  buy_config.cost[1][2] 
        local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
        local str = string_format(TI18N("是否花费<img src='%s' scale=0.3 />%s购买一次匹配次数？"), iconsrc, count, config.val)
        local call_back = function()
            controller:sender24904()
        end
        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
    end
end

-- 开始匹配
function ElitematchMainWindow:onClickMatchBtn(  )
    if not self.scdata  then return end
    if self.scdata.state == 0 then
        message(TI18N("敬请期待下赛季"))
        return
    end
    local setting = setting or {}
    setting.match_type = self.tab_object.index
    setting.scdata = self.scdata
    MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.EliteMatchWar, setting)
end

function ElitematchMainWindow:onClickGotoBtn()
    if not self.scdata  then return end
    if self.scdata.state == 0 then
        message(TI18N("敬请期待下赛季"))
        return
    end
    if not self.tab_object then return end
    if self.scdata.state ~= 3 then
        --常规赛阶段
        if self.tab_object.index == ElitematchConst.MatchType.eKingMatch then
            self:changeSelectedTab(ElitematchConst.MatchType.eNormalMatch)
            return
        end
    else
        --王者赛阶段
        if self.tab_object.index == ElitematchConst.MatchType.eKingMatch then
            if self.scdata.is_king ~= 1 then --没资格
                self:changeSelectedTab(ElitematchConst.MatchType.eNormalMatch)
                return     
            end
        else
            if self.scdata.is_king == 1 then --有资格
                self:changeSelectedTab(ElitematchConst.MatchType.eKingMatch) 
                return    
            end
        end
    end
end

--战令活动
function ElitematchMainWindow:onClickOrderactionBtn()
    controller:openElitematchOrderactionWindow(true)
end

-- 切换标签页
function ElitematchMainWindow:changeSelectedTab(index, not_check)
    if not not_check and self.tab_object ~= nil and self.tab_object.index == index then return end
    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object.label:setTextColor(Config.ColorData.data_new_color4[6])
        self.tab_object.label:disableEffect(cc.LabelEffect.SHADOW)
        setLabelAutoScale(self.tab_object.label,self.tab_object.unselect_bg,10)
        self.tab_object = nil
    end
    self.match_type = index
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
         self.tab_object.label:setTextColor(Config.ColorData.data_new_color4[1])
        self.tab_object.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
        setLabelAutoScale(self.tab_object.label,self.tab_object.select_bg,10)
    end
    if not self.scdata then return end
    if self.scdata.state == 0 then
        return
    end
    if index == ElitematchConst.MatchType.eNormalMatch then --常规赛
        self:setBackgroundImg("elitematch_main_bg")
        if self.scdata.state ~= 3 then
            --常规赛阶段
            self.tips_node:setVisible(false)
            self.level_node:setVisible(true)
            self.level_txt_icon:setVisible(true)
            self.panel:setVisible(true)
            self:setMatchBtnStatus(true, false)
            self.current_tips:setString("")
        else
            self.tips_node:setVisible(false)
            self.level_node:setVisible(true)
            self.level_txt_icon:setVisible(true)
            self.panel:setVisible(true)

            --王者赛阶段
            if self.scdata.is_king == 1 then --有资格
                self:setMatchBtnStatus(false, true, TI18N("前往王者赛"))
                self.current_tips:setString(TI18N("你已进入王者赛阶段, 请前往参与王者赛!"))
            else
                self:setMatchBtnStatus(true, false)
                self.current_tips:setString("")
            end
        end
    elseif index == ElitematchConst.MatchType.eKingMatch then --王者赛
        self:setBackgroundImg("elitematch_matching_bg")
        if self.scdata.state ~= 3 then
            --常规赛阶段
            self.tips_node:setVisible(true)
            self.level_node:setVisible(false)
            self.level_txt_icon:setVisible(false)
            self.panel:setVisible(false)
            self:setMatchBtnStatus(false, true, TI18N("前往常规赛"))
        else
            --王者赛阶段
            if self.scdata.is_king == 1 then --有资格
                self.tips_node:setVisible(false)
                self.level_node:setVisible(true)
                self.level_txt_icon:setVisible(true)
                self.panel:setVisible(true)
                self:setMatchBtnStatus(true, false)

                self.current_tips:setString(TI18N("你已进入王者赛,战斗改变为两队伍的车轮战模式"))
            else
                self.tips_node:setVisible(true)
                self.level_node:setVisible(false)
                self.level_txt_icon:setVisible(false)
                self.panel:setVisible(false)
                self:setMatchBtnStatus(false, true, TI18N("前往常规赛"))
            end
        end
    end

    
end

function ElitematchMainWindow:setBackgroundImg(bg_name)
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/elitematch", bg_name, true)
    if self.record_bg_res ~= bg_res then
        self.record_bg_res = bg_res
        self.item_load_bg = loadImageTextureFromCDN(self.background, bg_res, ResourcesType.single, self.item_load_bg) 
    end
end

function ElitematchMainWindow:setMatchBtnStatus(is_match, is_goto, goto_label)
    if self.is_open then
        self.match_btn:setVisible(is_match == true)
        self.goto_btn:setVisible(is_goto == true)
        if goto_label then
            self.goto_btn_label:setString(goto_label)
        end
    else
        self.match_btn:setVisible(false)
        self.goto_btn:setVisible(false)
    end
end

function ElitematchMainWindow:openRootWnd( setting )
    local setting = setting or {}
    self.match_type = setting.match_type or ElitematchConst.MatchType.eNormalMatch
    self.is_open_match = setting.is_open_match 
    self.is_sending = true
    controller:sender24905()
    controller:sender24900()
    if match_type == nil then
        self.auto_choice = true
    end
end

function ElitematchMainWindow:setData(scdata)
    self.scdata = model:getSCData()
    self:updateBuyCount()
    
    --当前开启状态 
    if self.scdata.state == 0 then
        --未开启没下面什么事情了
        local content_list = {"很遗憾","本赛季无法参与","敬请期待下赛季"}
        self:updateNotCanMatchIngInfo(content_list)
        return
    end
    if self.fight_data  then
        --更新按钮情况
        self:updateMatchBtn(self.fight_data)
        self.fight_data = nil
    end
    --是否自动选择到王者赛
    if self.auto_choice then
        self.auto_choice = false
        if self.scdata.is_king == 1 then
            self.match_type = ElitematchConst.MatchType.eKingMatch
        end        
    end

    self:changeSelectedTab(self.match_type, true)
    self:updateOrderactionBtn(model:getGiftStatus())
    self:updateOrderactionRed()
    --判断条件是否满足
    if not self:checkConditionInfo() then
        return 
    end

    --两个时间
    self:updateTimeInfo()
    --通用逻辑
    self:updateCommonInfo()

    if self.scdata.state ~= 3 then
        --普通赛
        self:updateNormalInfo()
        local content_list = {"王者赛未开启","请留意上方时间"}
        self:updateNotCanMatchIngInfo(content_list)
    else
        --开启了王者赛
        if self.scdata.is_king == 1 then
            --有参赛资格
            self:updateKingInfo()
        else
            self:updateNormalInfo()
            local content_list =  {"提升至“超凡王者”段位","可参与王者赛","(πvπ)"}
            self:updateNotCanMatchIngInfo(content_list)
        end
    end
    local rank_str 
    if self.scdata.rank == 0 then
        rank_str = string.format(TI18N("<div outline=2,#3d5078>%s</div>"),TI18N("我的排名:暂未上榜"))
    else
        rank_str = string.format(TI18N("<div outline=2,#3d5078>%s</div><div fontcolor=#0cff01 outline=2,#3d5078>%s</div>"),TI18N("我的排名:"), self.scdata.rank)
    end
    self.my_rank_label:setString(rank_str)

    if self.is_open_match then
        self:onClickMatchBtn()
    end
end

function ElitematchMainWindow:updateOrderactionBtn(status)
    if tolua.isnull(self.orderaction_btn) then
        return
    end
    if status == 1 then
        self.orderaction_btn:loadTexture(PathTool.getResFrame("elitematch","elitematch_40"), LOADTEXT_TYPE_PLIST)
    else
        self.orderaction_btn:loadTexture(PathTool.getResFrame("elitematch","elitematch_40"), LOADTEXT_TYPE_PLIST)
    end

end

function ElitematchMainWindow:updateOrderactionRed()
    if tolua.isnull(self.orderaction_btn) then
        return
    end
    if model:getOrderactionRedpoint() == true then
        addRedPointToNodeByStatus(self.orderaction_btn, true, 5, 5)
    else
        addRedPointToNodeByStatus(self.orderaction_btn, false, 5, 5)
    end

end

function ElitematchMainWindow:updateMatchBtn(data)
    -- local is_open, time = model:getOpenMatchLessTime()
    local is_open = data.state == 1
    local time = data.end_time
    self.is_open = is_open
    if self.is_open then
        self.cool_time:setString("")
    else
        self:setOpenTime(time)
    end
end

--设置倒计时
function ElitematchMainWindow:setOpenTime(less_time)
    if tolua.isnull(self.cool_time) then
        return
    end
    local less_time =  less_time or 0
    self.cool_time:stopAllActions()
    if less_time > 0 then
        self:setCoolTimeFormatString(less_time)
        self.cool_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    self.cool_time:stopAllActions()
                else
                    self:setCoolTimeFormatString(less_time)
                end
            end))))
    else
        self:setCoolTimeFormatString(less_time)
    end
end
function ElitematchMainWindow:setCoolTimeFormatString(time)
    if self.is_open then return end
    local str = string.format(TI18N("<div fontcolor=#3df424 outline=2,#000000>%s</div><div outline=2,#000000>%s</div>"), TimeTool.GetTimeDayOrTime(time), TI18N("后开启"))
    self.cool_time:setString(str)
end


function ElitematchMainWindow:updateTimeInfo()
    if not self.scdata then return end


    local config = Config.ArenaEliteData.data_zone_fun(self.scdata.zone_id)

    local zone_name = ""
    if config then 
        zone_name = string_format(TI18N("(%s赛区)"), config.name)
    end

    local server_time = GameNet:getInstance():getTime()
    local start_time = TimeTool.getMD2(self.scdata.start_time)
    local end_time = TimeTool.getMD2(self.scdata.end_time- 10)
    self.match_time:setString(string_format(TI18N("<div outline=2,#3d5078>S%s赛季%s时间: </div><div fontcolor=#0cff01 >%s-%s</div>"), self.scdata.period, zone_name, start_time, end_time))
    
    if self.scdata.state == 1 then
        self.match_time_str1 = TI18N("当前为上半赛季,").." "
        self.match_time_str2 = " "..TI18N("后开启下半赛季")
    elseif self.scdata.state == 2 then
        self.match_time_str1 = TI18N("当前为下半赛季,").." "
        self.match_time_str2 = " "..TI18N("后开启王者赛")
    elseif self.scdata.state == 3 then
        self.match_time_str1 = TI18N("当前为下半赛季(已开王者赛),").." "
        self.match_time_str2 = " "..TI18N("后结束本赛季")
    else
        return
    end
    self:setLessTime(self.scdata.state_time)
end

--@day_combat_count 剩余挑战次数
function ElitematchMainWindow:updateBuyCount()
    local day_combat_count = self.scdata.day_combat_count or 1
    local config = Config.ArenaEliteData.data_elite_const.match_count
    if config then
        local str = string_format("%s/%s",day_combat_count, config.val)
        self.buy_count:setString(str)
    end

    local is_redpoint = model:getMatchCountRedpoint()
    addRedPointToNodeByStatus(self.match_btn, is_redpoint, 5, 5)

    local day_buy_count = self.scdata.day_buy_count or 1

    local count = self.scdata.day_max_buy_count - day_buy_count
    if count < 0 then
        count = 0
    end
    local str = string.format(TI18N("<div outline=2,#3d5078>%s </div><div fontcolor=#0cff01>%s</div>"),TI18N("剩余购买次数:"), count)
    self.buy_tips:setString(str)
end


function ElitematchMainWindow:updateCommonInfo()
    local config = Config.ArenaEliteData.data_elite_level[self.scdata.lev]
    if config then
        --self:playLevelSpine(true, config)
        local bg_res = PathTool.getPlistImgForDownLoad("elitematch/elitematch_icon",config.little_ico, false)
        if self.record_res ~= bg_res then
            self.record_res = bg_res
            self.item_load2 = loadSpriteTextureFromCDN(self.level_node, bg_res, ResourcesType.single, self.item_load2)
        end
        bg_res = PathTool.getPlistImgForDownLoad("elitematch/elitematch_icon",config.name_ico, false)
        if self.record_txt_res ~= bg_res then
            self.record_txt_res = bg_res
            self.item_load1 = loadSpriteTextureFromCDN(self.level_txt_icon, bg_res, ResourcesType.single, self.item_load1) 
        end
        self.level_txt:setPosition(93,25)
        self.level_txt:setString(config.name)
    end

    table_sort(self.scdata.lev_reward, function(a, b) return a.lev < b.lev end )
    
    self.show_data = nil
    for i,v in ipairs(self.scdata.lev_reward) do
        if v.flag == 1 then --先找可领取的
            self.show_data = v
            break
        end
    end
    if self.show_data == nil then
        for i,v in ipairs(self.scdata.lev_reward) do
            if v.flag == 0 then --在找不可领取的
                self.show_data = v
                break
            end
        end
    end

    if self.show_data == nil then
        --最高级了
        self.show_data = self.scdata.lev_reward[#self.scdata.lev_reward]
    end
    local config = Config.ArenaEliteData.data_elite_level[self.show_data.lev]
    if config then
        local str1 = TI18N("本赛季首次达到 ")
        local str2 = TI18N(" 可得如下奖励")
        self.reward_label:setString(string_format("<div>%s</div><div fontcolor=#ffb400>\"%s\"</div><div>%s</div>", str1, config.name, str2))
        --奖励数据
        local setting = {}
        setting.scale = 0.8
        setting.max_count = 4
        self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, config.lev_award, setting)


        --决定按钮
        if self.show_data.flag == 0 then
            --不可领取
            self.receive_btn_label:setString(TI18N("领取"))
            self.receive_btn_label:disableEffect(cc.LabelEffect.SHADOW)
            setChildUnEnabled(true, self.receive_btn)
            addRedPointToNodeByStatus(self.receive_btn, false, 5, 5)
        elseif self.show_data.flag == 1 then
            --可领取
            self.receive_btn_label:setString(TI18N("领取"))
            --self.receive_btn_label:enableOutline(Config.ColorData.data_color4[264], 2) --橙色
            self.receive_btn_label:enableShadow(Config.ColorData.data_new_color4[4],cc.size(0, -2),2)
            setChildUnEnabled(false, self.receive_btn)
            addRedPointToNodeByStatus(self.receive_btn, true, 5, 5)
        else
            self.receive_btn_label:setString(TI18N("已领取"))
            --self.receive_btn_label:enableOutline(Config.ColorData.data_color4[264], 2) --橙色
            self.receive_btn_label:enableShadow(Config.ColorData.data_new_color4[4],cc.size(0, -2),2)

            setChildUnEnabled(false, self.receive_btn)
            addRedPointToNodeByStatus(self.receive_btn, false, 5, 5)
        end
    end
end

--段位iconspine
function ElitematchMainWindow:playLevelSpine(status, config)
    if status == false then
        if self.level_spine then
            self.level_spine:clearTracks()
            self.level_spine:removeFromParent()
            self.level_spine = nil
        end
    else
        if not config then return end
        if self.level_spine_record == nil or self.level_spine_record ~= config.ico then
            self.level_spine_record = config.ico
            self:playLevelSpine(false)
            self.level_spine = createEffectSpine(config.ico, cc.p(0, 0), cc.p(0.5, 0.5), true, PlayerAction.action)
            -- self.level_spine = createEffectSpine("E24177", cc.p(0, 0), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.level_node:addChild(self.level_spine, 1)
        end
    end
end

--更新常规赛
function ElitematchMainWindow:updateNormalInfo()
    local config = Config.ArenaEliteData.data_elite_level[self.scdata.lev]
    if not config then  return end
    local next_config = Config.ArenaEliteData.data_elite_level[config.next_id]
    if next_config then
        self.next_level_tips:setString(string_format(TI18N("下一段位: %s"), next_config.name))
    else
        self.next_level_tips:setString("")
    end
    if #self.scdata.promoted_info > 0 then
        --表示晋级赛
        self:showProgressbar(false)
        self.bule_tips:setVisible(false)
        self.level_up_tips:setVisible(true)
        --最大场数
        local max_count = config.promoted_info[1] or 1
        --需要胜利场数
        local win_count = config.promoted_info[2] or 1

        self.level_up_tips:setString(string_format(TI18N("%s局%s胜后升段"), max_count, win_count))
        -- self.level_up_tips:setPositionY(446)
        self:showLevelUpUI(true, max_count)
    else
        self.level_up_tips:setVisible(false)
        if config.init_exp > 0 then
            self.bule_tips:setVisible(true)
        else
            self.bule_tips:setVisible(false)
        end
        --常规赛
        local percent, str, blue_percent
        local total_exp = config.init_exp + config.need_exp
        if self.scdata.score >= 0 then
            percent = (self.scdata.score + config.init_exp)*100/total_exp
            blue_percent = config.init_exp*100/total_exp
            str = string_format("%s/%s", self.scdata.score, config.need_exp)
        else
            percent = 0
            local count = config.init_exp + self.scdata.score
            blue_percent = count*100/config.need_exp
            str = count
        end

        self:showProgressbar(true, percent, blue_percent, str)
        self:showLevelUpUI(false)
    end
end

--目前王者赛和常规赛的显示逻辑一样
function ElitematchMainWindow:updateKingInfo()
    self:updateNormalInfo()
end

--@percent 百分比
--@label 进度条中间文字描述
--@is_blue 是否 ture:蓝条
function ElitematchMainWindow:showProgressbar(status, percent, blue_percent, label)
    if not self.leve_up_node then return end
    if status then
        local size = cc.size(220, 18)
        if not self.comp_bar then
            local res = PathTool.getResFrame("elitematch","elitematch_bar_bg")
            local res1 = PathTool.getResFrame("elitematch","elitematch_bar")
            local res2 = PathTool.getResFrame("elitematch","elitematch_bar_1")
            self.camp_bar_record_res = res1
            local bg,comp_bar = createLoadingBar(res, res1, size, self.leve_up_node, cc.p(0.5,0.5), 0, 0, true)
            self.comp_bar_bg = bg
            self.comp_bar = comp_bar

            --蓝色进度条
            local progress = ccui.LoadingBar:create()
            progress:setAnchorPoint(cc.p(0.5, 0.5))
            --progress:setScale9Enabled(true)
            progress:setCascadeOpacityEnabled(true)
            progress:loadTexture(res2,LOADTEXT_TYPE_PLIST)
            --progress:setContentSize(cc.size(size.width-4, size.height-4))
            progress:setPosition(cc.p(size.width/2, size.height/2))
            bg:addChild(progress)
            self.comp_bar_blue = progress
        end
        if not self.comp_bar_label then
            local text_color = cc.c3b(255,255,255)
            local line_color = cc.c3b(0,0,0)
            self.comp_bar_label = createLabel(16, text_color, line_color, size.width/2, size.height/2, "", self.comp_bar, 2, cc.p(0.5, 0.5))
        end

        self.comp_bar_bg:setVisible(true)

        self.comp_bar:setPercent(percent)    
        self.comp_bar_blue:setPercent(blue_percent)
        self.comp_bar_label:setString(label)
    else
        if self.comp_bar_bg then
            self.comp_bar_bg:setVisible(false)
        end
    end
end

function ElitematchMainWindow:showLevelUpUI(status, max_count)
    if self.level_up_item_list then
        for i,item in ipairs(self.level_up_item_list) do
            item.bg:setVisible(false)
        end
    end
    if status then
        if self.level_up_item_list == nil then
            self.level_up_item_list = {}
        end
        local item_width = 50 
        local x = -item_width * max_count * 0.5 + item_width * 0.5
        local dic_data = {}
        for i,v in ipairs(self.scdata.promoted_info) do
            dic_data[v.count] = v.flag
        end
        for i=1,max_count do
            local _x = x + (i - 1) * item_width
            if self.level_up_item_list[i] == nil then
                self.level_up_item_list[i] = self:createLevelUpItem( _x, 0)
            else
                self.level_up_item_list[i].bg:setPositionX(_x)
            end
            self.level_up_item_list[i].bg:setVisible(true)
            if dic_data[i] == nil or dic_data[i] == 0 then
               self.level_up_item_list[i].icon:setVisible(false)
               self.level_up_item_list[i].mask_icon:setVisible(false)
            else
                self.level_up_item_list[i].icon:setVisible(true)
                self.level_up_item_list[i].mask_icon:setVisible(true)
                if dic_data[i] == 1 then
                    --胜利
                    setChildUnEnabled(false, self.level_up_item_list[i].icon)
                    local res2 = PathTool.getTargetRes("elitematch", "txt_cn_elitematch_15",false)
                    loadSpriteTexture(self.level_up_item_list[i].mask_icon, res2, LOADTEXT_TYPE)
                else
                    --失败
                    setChildUnEnabled(true, self.level_up_item_list[i].icon)
                    local res2 = PathTool.getTargetRes("elitematch", "txt_cn_elitematch_16",false)
                    loadSpriteTexture(self.level_up_item_list[i].mask_icon, res2, LOADTEXT_TYPE)
                end
            end
        end
    end
end

function ElitematchMainWindow:createLevelUpItem(x, y)
    if not self.leve_up_node then return end
    local item = {}
    local res = PathTool.getResFrame("elitematch", "elitematch_14")
    item.bg = createSprite(res, x, y, self.leve_up_node, cc.p(0.5,0.5))
    local bg_size = item.bg:getContentSize()
    local res1 = PathTool.getResFrame("elitematch", "elitematch_12")
    item.icon = createSprite(res1, bg_size.width * 0.5, bg_size.height * 0.5, item.bg, cc.p(0.5,0.5))
    local res2 = PathTool.getResFrame("elitematch", "txt_cn_elitematch_15")
    item.mask_icon = createSprite(res2, 35, 36, item.bg, cc.p(0.5,0.5))
    return item
end

--更新不能匹配界面信息
--@ content_list显示的内容信息
function ElitematchMainWindow:updateNotCanMatchIngInfo(content_list)
    if not content_list then return end

    if self.tips_label_list == nil then
        self.tips_label_list = {}
    end
    for i,label in ipairs(self.tips_label_list) do
        label:setVisible(false)
    end
    local label_height = 24
    local start_y = #content_list * label_height * 0.5 - label_height * 0.5
    for i,content in ipairs(content_list) do
        local y = start_y - label_height * (i - 1)
        if self.tips_label_list[i] == nil then
            self.tips_label_list[i] = createLabel(22, cc.c4b(0xff,0xf8,0xbf,0xff), nil, 0, y, "", self.tips_node, 2, cc.p(0.5, 0.5))
        else
            self.tips_label_list[i]:setPositionY(y)
        end
        self.tips_label_list[i]:setString(TI18N(content))
    end
end

--return ture 表示条件满足  return false 表不满足.也有可能是数据错误
function ElitematchMainWindow:checkConditionInfo()
    local config_world = Config.ArenaEliteData.data_elite_const["open_world_lev_limit"]
    if not config_world then return false end
    local config_lev = Config.ArenaEliteData.data_elite_const["open_person_lev_limit"]
    if not config_lev then return false end

    local role_vo = RoleController:getInstance():getRoleVo()
    if not role_vo then return false end
    local lev = role_vo.lev
    local world_lev = RoleController:getInstance():getModel():getWorldLev()

    local is_ok = true
    local content_list = {}
    local index = 1
    if config_world.val > world_lev then
        content_list[index] = string_format(TI18N("世界等级需要达到%s级"), config_world.val)
        is_ok = false
        index = index + 1
    end

    if config_lev.val > lev then
        content_list[index] = string_format(TI18N("个人等级需要达到%s级"), config_lev.val)
        is_ok = false
    end

    if not is_ok then
        self:updateNotCanMatchIngInfo(content_list)    
    end
    return is_ok
end

--设置倒计时
function ElitematchMainWindow:setLessTime(less_time)
    if tolua.isnull(self.king_match_time) then
        return
    end
    local less_time =  less_time or 0
    self.king_match_time:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.king_match_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    self.king_match_time:stopAllActions()
                else
                    self:setTimeFormatString(less_time)
                end
            end))))
    else
        self:setTimeFormatString(less_time)
    end
end
function ElitematchMainWindow:setTimeFormatString(time)
    local timestr = TimeTool.GetTimeForFunction(time)
    local str = string.format(TI18N("<div outline=2,#3d5078>%s</div> <div fontcolor=#0cff01>%s</div> <div outline=2,#3d5078>%s</div>"), self.match_time_str1, timestr, self.match_time_str2)
    self.king_match_time:setString(str)
    if time <= 0 then
        if not self.is_sending then
            self.is_sending = true
            -- controller:sender24900()
        end
    end
end


function ElitematchMainWindow:close_callback(  )
    
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end

    if self.item_load_bg then
        self.item_load_bg:DeleteMe()
    end
    self.item_load_bg = nil

    if self.item_load1 then
        self.item_load1:DeleteMe()
    end
    self.item_load1 = nil
    if self.item_load2 then
        self.item_load2:DeleteMe()
    end
    self.item_load2 = nil
    self.cool_time:stopAllActions()
    self.king_match_time:stopAllActions()
    controller:openElitematchMainWindow(false)
end