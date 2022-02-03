--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-04-30 17:47:32
-- @description    : 
		-- 跨服竞技场
---------------------------------
local _controller = CrossarenaController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert

CrossarenaChallengePanel = CrossarenaChallengePanel or BaseClass()

function CrossarenaChallengePanel:__init(parent)
    self.is_init = true
    self.parent = parent

    self.ticket_bid = Config.ArenaClusterData.data_const["arena_ticket"].val
    self.role_item_list = {}
    self.award_box_list = {}
    self.award_item_list = {}

    self:createRoorWnd()
    self:registerEvent()
end

function CrossarenaChallengePanel:createRoorWnd()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("crossarena/crossarena_challenge_panel"))
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
    end

    self.container = self.root_wnd:getChildByName("container")

    local bottom_panel = self.container:getChildByName("bottom_panel")
    self.bottom_panel = bottom_panel

    local progress_bg = bottom_panel:getChildByName("progress_bg")
    self.progress = progress_bg:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    self.progress:setPercent(0)
    self.progress_value = bottom_panel:getChildByName("progress_value")

    self.add_item_btn = bottom_panel:getChildByName("add_item_btn")
    self.btn_refresh = bottom_panel:getChildByName("btn_refresh")
    self.btn_refresh_label = self.btn_refresh:getChildByName("label")
    self.btn_refresh_label:setString(TI18N("刷新"))

    local item_icon = bottom_panel:getChildByName("item_icon")
    local item_cfg = Config.ItemData.data_get_data(self.ticket_bid)
    if item_cfg then
        local item_res = PathTool.getItemRes(item_cfg.icon)
        loadSpriteTexture(item_icon, item_res, LOADTEXT_TYPE)
    end

    self.item_num = bottom_panel:getChildByName("item_num")
    bottom_panel:getChildByName("title_my_rank"):setString(TI18N("我的排名:"))
    self.txt_my_rank = bottom_panel:getChildByName("txt_my_rank")
    bottom_panel:getChildByName("title_my_score"):setString(TI18N("我的积分:"))
    self.txt_my_score = bottom_panel:getChildByName("txt_my_score")
    self.title_time = bottom_panel:getChildByName("title_time")
    self.title_time:setString(TI18N("距本赛季结束:"))
    self.txt_time = bottom_panel:getChildByName("txt_time")

    -- 适配
    local bottom_off = display.getBottom(main_container)
    bottom_panel:setPositionY(bottom_off)
end

function CrossarenaChallengePanel:registerEvent(  )
    -- 刷新
    registerButtonEventListener(self.btn_refresh, function (  )
        if _model:checkCrossarenaIsOpen() then
            _controller:sender25609()
        end
    end, true)
    
    -- 增加挑战券
    registerButtonEventListener(self.add_item_btn, function (  )
        self:onClickAddItemBtn()
    end, true)

    -- 个人信息
    if not self.update_my_info_event then
        self.update_my_info_event = GlobalEvent:getInstance():Bind(CrossarenaEvent.Update_MyBaseInfo_Event, function ( )
            self:updateMyselfInfo()
        end)
    end

    -- 活动开启状态
    if not self.update_open_status_event then
        self.update_open_status_event = GlobalEvent:getInstance():Bind(CrossarenaEvent.Update_Open_Status_Event, function ( )
            self:updateMyselfInfo()
        end)
    end

    -- 刷新时间更新
    if not self.update_refresh_time_event then
        self.update_refresh_time_event = GlobalEvent:getInstance():Bind(CrossarenaEvent.Update_Refresh_Time_Event, function ( )
            self:updateRefreshBtnStatus()
        end)
    end

    -- 挑战玩家数据更新
    if not self.update_challenge_data_event then
        self.update_challenge_data_event = GlobalEvent:getInstance():Bind(CrossarenaEvent.Update_Challenge_Role_Event, function ( )
            self:updateRoleItemList()
        end)
    end

    -- 每日挑战奖励更新
    if not self.update_challenge_award_event then
        self.update_challenge_award_event = GlobalEvent:getInstance():Bind(CrossarenaEvent.Update_Challenge_Award_Event, function ( )
            self:updateChallengeAwardInfo()
        end)
    end

    -- 道具数量更新
    if not self.update_add_good_event then
        self.update_add_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function(bag_code, data_list)
            self:updateTicketNum(bag_code,data_list)
        end)
    end
    if not self.update_delete_good_event then
        self.update_delete_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function(bag_code, data_list)
            self:updateTicketNum(bag_code,data_list)
        end)
    end
    if not self.update_modify_good_event then
        self.update_modify_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, data_list)
            self:updateTicketNum(bag_code,data_list)
        end)
    end
end

-- 购买挑战券
function CrossarenaChallengePanel:onClickAddItemBtn(  )
    ArenaController:getInstance():openArenaLoopChallengeBuy(true)
end

function CrossarenaChallengePanel:setVisibleStatus( status )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end

    if status == true and self.is_init == true then
        self.is_init = false
        -- 初次打开
        self:updateMyselfInfo()
        self:updateTicketNum()
        _controller:sender25610() -- 活动开启状态
        _controller:sender25600() -- 基础数据
        _controller:sender25601() -- 对手数据
        _controller:sender25607() -- 奖励数据
    end
end

-- 创建英雄列表
function CrossarenaChallengePanel:updateRoleItemList(  )
    local role_datas = _model:getChallengeRoleData()

    for i,data in ipairs(role_datas) do
        delayRun(self.container, i / display.DEFAULT_FPS, function ()
            local role_item = self.role_item_list[i]
            if not role_item then
                role_item = CrossareanRoleItem.New(self.container)
                self.role_item_list[i] = role_item
            end
            role_item:setData(data, i)
        end)
    end
end

-- 玩家信息
function CrossarenaChallengePanel:updateMyselfInfo(  )
    local myBaseInfo = _model:getCrossarenaMyBaseInfo()
    -- 排名
    if not myBaseInfo.rank or myBaseInfo.rank == 0 then
        self.txt_my_rank:setString(TI18N("暂无排名"))
    else
        self.txt_my_rank:setString(myBaseInfo.rank)
    end

    -- 积分
    self.txt_my_score:setString(myBaseInfo.score or 0)

    -- 结束/开启时间
    local less_time = 0
    local cur_time = GameNet:getInstance():getTime()
    self.arena_open_status = _model:getCrossarenaStatus()
    if self.arena_open_status == CrossarenaConst.Open_Status.Open then -- 活动开启中
        self.title_time:setString(TI18N("距本赛季结束:"))
        local end_time = myBaseInfo.end_time or 0
        less_time = end_time - cur_time
    else
        local start_time = myBaseInfo.start_time or 0
        less_time = start_time - cur_time
        if less_time < 0 then -- 开始时间小于当前时间，则说明为本赛季休赛期(剩余时间取距离第二天0点的剩余时间)
            self.title_time:setString(TI18N("距离玩法开始:"))
            less_time = TimeTool.getOneDayLessTime()
        else
            self.title_time:setString(TI18N("距下赛季开始:"))
        end
    end
    
    if less_time <= 0 then
        self.txt_time:setString("00:00:00")
    else
        self:setLessTime(less_time)
    end

    -- 刷新按钮状态
    self:updateRefreshBtnStatus()
end

--设置倒计时
function CrossarenaChallengePanel:setLessTime( less_time )
    if tolua.isnull(self.txt_time) then return end
    self.txt_time:stopAllActions()
    if less_time > 0 then
        self.txt_time:setString(TimeTool.GetTimeFormat(less_time))
        self.txt_time:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                self.txt_time:stopAllActions()
            else
                self.txt_time:setString(TimeTool.GetTimeFormat(less_time))
            end
        end)
        )))
    else
        self.txt_time:stopAllActions()
        self.txt_time:setString(TimeTool.GetTimeFormat(less_time))
    end
end

-- 刷新按钮状态
function CrossarenaChallengePanel:updateRefreshBtnStatus(  )
    local myBaseInfo = _model:getCrossarenaMyBaseInfo()

    self.btn_refresh_label:stopAllActions()

    local cur_time = GameNet:getInstance():getTime()
    local ref_time = myBaseInfo.ref_time or cur_time
    local less_time = ref_time - cur_time
    if less_time <= 0 then
        setChildUnEnabled(false, self.btn_refresh)
        self.btn_refresh:setTouchEnabled(true)
        self.btn_refresh_label:setString(TI18N("刷新"))
        self.btn_refresh_label:enableOutline(Config.ColorData.data_color4[263], 2)
    else
        setChildUnEnabled(true, self.btn_refresh)
        self.btn_refresh:setTouchEnabled(false)
        self.btn_refresh_label:disableEffect(cc.LabelEffect.OUTLINE)
        self.btn_refresh_label:setString(_string_format(TI18N("%d秒"), less_time))
        self.btn_refresh_label:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                setChildUnEnabled(false, self.btn_refresh)
                self.btn_refresh:setTouchEnabled(true)
                self.btn_refresh_label:setString(TI18N("刷新"))
                self.btn_refresh_label:enableOutline(Config.ColorData.data_color4[263], 2)
            else
                self.btn_refresh_label:setString(_string_format(TI18N("%d秒"), less_time))
            end
        end)
        )))
    end
end

-- 每日挑战奖励(进度)
function CrossarenaChallengePanel:updateChallengeAwardInfo(  )
    local award_data = _model:getChallengeAwardData()
    if not award_data then return end
    
    if not self.award_cfg then
        self.award_cfg = {}
        for num,cfg in pairs(Config.ArenaClusterData.data_daily_award) do
            local temp_data = {}
            temp_data.num = num
            temp_data.award = cfg.items
            temp_data.effect_id = cfg.effect_id
            _table_insert(self.award_cfg, temp_data)
        end
        table.sort(self.award_cfg, SortTools.KeyLowerSorter("num"))
    end

    local max_count = self.award_cfg[#self.award_cfg].num
    -- 进度
    self.progress_value:setString(award_data.had_combat_num .. "/" .. max_count)
    self.progress:setPercent(award_data.had_combat_num/max_count*100)

    -- 宝箱
    for k,v in pairs(self.award_box_list) do
        v:setVisible(false)
    end

    for i,aData in ipairs(self.award_cfg) do
        local box_node = self.award_box_list[i]
        if not box_node then
            box_node = CrossarenaAwardBoxItem.new(handler(self, self._onClickShowAwardTips))
            self.bottom_panel:addChild(box_node)
            self.award_box_list[i] = box_node
        end
        local pos_x = 140 + (aData.num/max_count)*279
        box_node:setPosition(cc.p(pos_x, 247))
        box_node:setData(aData)
        box_node:setVisible(true)
    end
end

function CrossarenaChallengePanel:_onClickShowAwardTips( node, data, pos )
    if not self.tips_layer then
        self.tips_layer = ccui.Layout:create()
        self.tips_layer:setContentSize(cc.size(SCREEN_WIDTH, display.height))
        self.container:addChild(self.tips_layer)
        self.tips_layer:setTouchEnabled(true)
        self.tips_layer:setSwallowTouches(false)
        registerButtonEventListener(self.tips_layer, function()
            self.tips_layer:setVisible(false)
        end, false, 1)
    end

    self.tips_layer:setVisible(true)
    
    if not self.tips_bg then
        self.tips_bg = createImage(self.tips_layer, PathTool.getResFrame("common","common_1056"), 0, 0, cc.p(0,0), true, 10, true)
        self.tips_bg:setTouchEnabled(true)
    end
    if self.tips_bg then
        local bg_size = cc.size(BackPackItem.Width*0.8*#data+70+(#data-1)*15, BackPackItem.Height*0.8+70)
        self.tips_bg:setContentSize(bg_size)
        self.tips_bg:setAnchorPoint(cc.p(0.5, 0))
        local world_pos = node:convertToWorldSpace(cc.p(0, 0))
        local node_pos = self.container:convertToNodeSpace(world_pos)
        if node_pos.x - bg_size.width/2 < 0 then
            node_pos.x = 10 + bg_size.width/2
        end
        node_pos.y = node_pos.y + 20
        self.tips_bg:setPosition(node_pos)
    end

    for k,v in pairs(self.award_item_list) do
        v:setVisible(false)
    end
    for i,v in pairs(data) do
        local award_item = self.award_item_list[i]
        local item_config = Config.ItemData.data_get_data(v[1])
        if item_config then
            if not award_item then
                award_item = BackPackItem.new(nil,true,nil,0.8)
                self.award_item_list[i] = award_item
                award_item:setAnchorPoint(cc.p(0,0.5))
                self.tips_bg:addChild(award_item)
                award_item:setBaseData(v[1], v[2])
                award_item:setPosition(cc.p((BackPackItem.Width*0.8+15)*(i-1)+35, 95))
                award_item:setDefaultTip()
                award_item:setExtendDesc(true, item_config.name, 275)
            else
                award_item:setBaseData(v[1], v[2])
                award_item:setExtendDesc(true, item_config.name, 275)
                award_item:setPosition(cc.p((BackPackItem.Width*0.8+15)*(i-1)+35, 95))
                award_item:setVisible(true)
            end
        end
    end
end

-- 挑战券数量
function CrossarenaChallengePanel:updateTicketNum( bag_code, data_list )
    if self.ticket_bid and bag_code and data_list then
        if bag_code == BackPackConst.Bag_Code.BACKPACK then
            for i,v in pairs(data_list) do
                if v and v.base_id and self.ticket_bid == v.base_id then
                    local have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.ticket_bid)
                    self.item_num:setString(have_num)
                    break
                end
            end
        end
    elseif self.ticket_bid then
        local have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.ticket_bid)
        self.item_num:setString(have_num)
    end
end

function CrossarenaChallengePanel:__delete()
    for k,v in pairs(self.role_item_list) do
        v:DeleteMe()
        v = nil
    end
    for k,v in pairs(self.award_box_list) do
        v:DeleteMe()
        v = nil
    end
    for k,v in pairs(self.award_item_list) do
        v:DeleteMe()
        v = nil
    end
    if self.update_my_info_event then
        GlobalEvent:getInstance():UnBind(self.update_my_info_event)
        self.update_my_info_event = nil
    end
    if self.update_open_status_event then
        GlobalEvent:getInstance():UnBind(self.update_open_status_event)
        self.update_open_status_event = nil
    end
    if self.update_refresh_time_event then
        GlobalEvent:getInstance():UnBind(self.update_refresh_time_event)
        self.update_refresh_time_event = nil
    end
    if self.update_challenge_data_event then
        GlobalEvent:getInstance():UnBind(self.update_challenge_data_event)
        self.update_challenge_data_event = nil
    end
    if self.update_challenge_award_event then
        GlobalEvent:getInstance():UnBind(self.update_challenge_award_event)
        self.update_challenge_award_event = nil
    end
    if self.update_add_good_event then
        GlobalEvent:getInstance():UnBind(self.update_add_good_event)
        self.update_add_good_event = nil
    end
    if self.update_delete_good_event then
        GlobalEvent:getInstance():UnBind(self.update_delete_good_event)
        self.update_delete_good_event = nil
    end
    if self.update_modify_good_event then
        GlobalEvent:getInstance():UnBind(self.update_modify_good_event)
        self.update_modify_good_event = nil
    end
end

-------------------------@ 奖励宝箱item
CrossarenaAwardBoxItem = class("CrossarenaAwardBoxItem", function()
    return ccui.Widget:create()
end)

function CrossarenaAwardBoxItem:ctor(call_back)
    self.call_back = call_back

    self:configUI()
    self:register_event()
end

function CrossarenaAwardBoxItem:configUI(  )
    self.size = cc.size(50, 50)
    self:setTouchEnabled(false)
    self:setContentSize(self.size)

    self.container = ccui.Layout:create()
    self.container:setTouchEnabled(true)
    self.container:setContentSize(self.size)
    self.container:setAnchorPoint(0.5, 0.5)
    self.container:setPosition(cc.p(self.size.width/2, self.size.height/2))
    self:addChild(self.container)
end

function CrossarenaAwardBoxItem:register_event(  )
    registerButtonEventListener(self.container, function ( param, sender, event_type )
        if self.award_status == 2 then -- 可领取
            if self.data.num then
                _controller:sender25608(self.data.num)
            end
        elseif self.data and self.call_back then
            self.call_back(self, self.data.award, sender:getTouchBeganPosition())
        end
    end)
end

function CrossarenaAwardBoxItem:setData( data, chapter_id )
    if not data then return end

    self.data = data

    if not self.star_num_txt then
        self.star_num_txt = createLabel(22, cc.c3b(255,248,191), cc.c3b(0, 0, 0), self.size.width/2, 5, "", self.container, 2, cc.p(0.5, 1))
    end
    self.star_num_txt:setString(data.num)

    self:updateEffectStatus()
end

function CrossarenaAwardBoxItem:updateEffectStatus(  )
    if not self.data then return end

    self.award_status = _model:getChallengeAwardStatus(self.data.num)
    local action = PlayerAction.action_1
    if self.award_status == 2 then
        action = PlayerAction.action_2
    elseif self.award_status == 3 then
        action = PlayerAction.action_3
    end
    self:handleEffect(true, action)
end

function CrossarenaAwardBoxItem:handleEffect( status, action )
    if status == true then
        if not tolua.isnull(self.container) and self.box_effect == nil and self.data then
            self.box_effect = createEffectSpine(Config.EffectData.data_effect_info[self.data.effect_id], cc.p(self.size.width/2, 8), cc.p(0.5, 0.5), true, action)
            self.container:addChild(self.box_effect)
        elseif self.box_effect and (not self.cur_action_name or self.cur_action_name ~= action) then
            self.box_effect:setToSetupPose()
            self.box_effect:setAnimation(0, action, true)
        end
        self.cur_action_name = action
    else
        if self.box_effect then
            self.box_effect:clearTracks()
            self.box_effect:removeFromParent()
            self.box_effect = nil
        end
    end
end

function CrossarenaAwardBoxItem:DeleteMe(  )
    self:handleEffect(false)
    self:removeAllChildren()
    self:removeFromParent()
end