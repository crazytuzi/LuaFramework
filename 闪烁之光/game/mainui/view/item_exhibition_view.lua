-- --------------------------------------------------------------------
-- 通用获得道具展示显示面板,这边只支持物品样式的不支持其他任何样式的
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
ItemExhibitionView = ItemExhibitionView or BaseClass(BaseView)

local controller = MainuiController:getInstance()

function ItemExhibitionView:__init(extend, open_type, ref_class)
    self.win_type = WinType.Mini
    self.layout_name = "mainui/item_exhibition_view"
    self.start_y = 20
    self.space = 50
    self.col = 4
    self.cache_list = {}
    self.extend = extend or {}
    self.can_close = false
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.open_type = open_type or MainuiConst.item_open_type.normal
    self.ref_class = ref_class or ItemExhibitionList
    self.ref_width = width or 119
    self.ref_height = height or 119
    self.effect_cache_list = {}
    self.is_csb_action = true
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
    }
end

function ItemExhibitionView:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self.center_x = main_container:getContentSize().width * 0.5

    self.title_container = main_container:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    self.scroll_view = self.root_wnd:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
    -- self.scroll_view:setSwallowTouches(false)
    self.scroll_width = self.scroll_view:getContentSize().width
    self.scroll_height = self.scroll_view:getContentSize().height

    self.notice_label = self.root_wnd:getChildByName("notice_label")
    self.confirm_btn = main_container:getChildByName("confirm_btn")

    self.close_btn = main_container:getChildByName("close_btn")
    self.close_btn:setName("guide_close_btn")
    self.close_btn_label = self.close_btn:getChildByName("label")
    self.fun_btn = main_container:getChildByName("fun_btn")
    self.fun_btn_label = self.fun_btn:getChildByName("label")

    if self.open_type == MainuiConst.item_open_type.normal then
        self.close_btn:setVisible(false)
        self.fun_btn:setVisible(false)
        self.confirm_btn:setVisible(true)
    elseif self.open_type == MainuiConst.item_open_type.seerpalace then
        self.close_btn:setVisible(true)
        self.fun_btn:setVisible(true)
        self.confirm_btn:setVisible(false)
        self.close_btn_label:setString(TI18N("确定"))
        self.fun_btn_label:setString(TI18N("再次召唤"))
    elseif self.open_type == MainuiConst.item_open_type.heavendial then
        self.close_btn:setVisible(true)
        self.fun_btn:setVisible(true)
        self.confirm_btn:setVisible(false)
        self.close_btn_label:setString(TI18N("确定"))
        if self.extend.times == 10 then
            self.fun_btn_label:setString(string.format(TI18N("祈祷%d次"), self.extend.times))
        else
            self.fun_btn_label:setString(TI18N("再次祈祷"))
        end
    end

    self.main_container = main_container
end

function ItemExhibitionView:register_event()
    self.confirm_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            -- if self.can_close == true then
                self:onClickClose()
            -- end
        end
    end)
    self.background:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            if not self.open_type or self.open_type == MainuiConst.item_open_type.normal then
                self:onClickClose()
            end
        end
    end)

    -- 关闭按钮
    registerButtonEventListener(self.close_btn, function (  )
        self:onClickClose()
    end, true, 2)

    -- 功能按钮
    registerButtonEventListener(self.fun_btn, function (  )
        self:onClickFunBtn()
    end, true, 2)
end

function ItemExhibitionView:onClickClose()
    controller:openGetItemView(false)
    -- ActionController:getInstance():checkOpenActionLimitGiftMainWindow()
    GlobalEvent:getInstance():Fire(BattleEvent.NEXT_SHOW_RESULT_VIEW)
end

function ItemExhibitionView:onClickFunBtn(  )
    if self.open_type == MainuiConst.item_open_type.seerpalace then
        local group_id = SeerpalaceController:getInstance():getModel():getLastSummonGroupId()
        if group_id and group_id ~= 0 then
            SeerpalaceController:getInstance():requestSeerpalaceSummon(group_id)
        end
        self:onClickClose()
    elseif self.open_type == MainuiConst.item_open_type.heavendial then
        local times = self.extend.times
        local group_id = self.extend.group_id
        if times and group_id then
            local group_cfg = Config.HolyEqmLotteryData.data_group[group_id]
            if not group_cfg or not group_cfg.loss_item_once or not group_cfg.loss_item_once[1] then return end
            local cost_item_bid = group_cfg.loss_item_once[1][1]
            local have_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_item_bid)
            local is_free = HeavenController:getInstance():getModel():getHeavenDialIsFreeById(group_id)
            if times == 1 and is_free then
                HeavenController:getInstance():sender25217( group_id, times, 1 )
            elseif times <= have_num then
                HeavenController:getInstance():sender25217( group_id, times, 4 )
            elseif group_cfg.gain_once and group_cfg.gain_once[1] then
                local gain_item_bid = group_cfg.gain_once[1][1]
                local gain_item_num = group_cfg.gain_once[1][2]
                local item_cfg = Config.ItemData.data_get_data(gain_item_bid)
                if item_cfg and gain_item_bid and gain_item_num then
                    local role_vo = RoleController:getInstance():getRoleVo()
                    local need_gold = group_cfg.loss_gold_once
                    if times == 10 then
                        need_gold = group_cfg.loss_gold_ten
                    end
                    local tips_str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.4 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(拥有:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)祈祷<div fontColor=#289b14 fontsize= 26>%d</div>次\n</div>"),PathTool.getItemRes(3), need_gold, role_vo.gold, times)
                    tips_str = tips_str .. string.format(TI18N("祈祷后可获得<div fontColor=#289b14 fontsize= 26>%d</div><div fontColor=#d95014 fontsize= 26>%s</div><div fontColor=#764519>(同时附赠</div><div fontColor=#289b14 fontsize= 26>%d</div>次随机奖励)</div>"), gain_item_num*times, item_cfg.name, times)
                    CommonAlert.show(tips_str, TI18N("确定"), function (  )
                       HeavenController:getInstance():sender25217( group_id, times, 3 )
                    end, TI18N("取消"), nil, CommonAlert.type.rich)
                end
            end
        end
        self:onClickClose()
    end
end

function ItemExhibitionView:openRootWnd(list,source)

    BattleResultMgr:getInstance():setWaitShowPanel(true)
    self:handleEffect(true)
    self.can_close = false
    self.render_list = list
    -- 物品来源做描述使用
    if source ~= 0 then
        if not tolua.isnull(self.main_container) then
            -- 冠军赛来源
            if source > 10 and source < 1000 then
                local step = math.floor(source * 0.1)   -- 阶段
                local round = source%10                -- 当前回合
                local desc = ArenaConst.getMatchStepDesc2(step, round) 
                self.notice_label:setString(string.format(TI18N("恭喜你在%s竞猜中押注成功"), desc))
            elseif source == 3 then --巅峰冠军赛的奖励
                local apc_model = ArenapeakchampionController:getInstance():getModel()
                if not apc_model then return end
                local main_data = apc_model:getMainData()
                if main_data and main_data.step ~= 0 then
                    local str = apc_model:getMacthText( main_data.step,  main_data.round)
                    self.notice_label:setString(string.format(TI18N("恭喜你在 %s 竞猜中押注成功"), str))
                else
                    self.notice_label:setString(TI18N("恭喜你在巅峰冠军赛竞猜中押注成功"))
                end

            end
        end
    end
    self:updateData()
end

function ItemExhibitionView:updateData()
    self.cache_list = {}
    local sum = #self.render_list
    -- 算出最多多少行
    self.row = math.ceil(sum / self.col)

    local max_height = self.start_y + (self.space + self.ref_height) * self.row
    self.max_height = math.max(max_height, self.scroll_height)
	self.scroll_view:setInnerContainerSize(cc.size(self.scroll_width, self.max_height))

    if sum >= self.col then
        sum = self.col
    end
    local total_width = sum * self.ref_width + (sum - 1)*self.space
    self.start_x = (self.scroll_width - total_width) * 0.5

    -- 只有一行的话
    if self.row == 1 then
        self.start_y = self.max_height * 0.5
    else
        self.start_y = self.max_height - self.start_y - self.ref_height * 0.5
    end
    self.action_effect = {}
    for i,v in ipairs(self.render_list) do
        delayRun(self.root_wnd, i*0.1, function() 
            local function one_fun()
                if self.action_effect[i] then
                    self.action_effect[i]:runAction(cc.RemoveSelf:create(true)) 
                    self.action_effect[i] = nil
                end
            end
            local _x = self.start_x + self.ref_width * 0.5 + ((i - 1) % self.col) * (self.ref_width + self.space)
            local _y = self.start_y - math.floor((i - 1) / self.col) * (self.ref_height + self.space)
            
            local effect_id = Config.EffectData.data_effect_info[156]
            local action = PlayerAction.action_3
            self.action_effect[i] = createEffectSpine(effect_id, cc.p(_x, _y), cc.p(0.5, 0.5), false, action, one_fun, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
            self.scroll_view:addChild(self.action_effect[i], 1)
            
            local function animationEventFunc(event)
                if event.eventData.name == "appear" then
                    local item = self.ref_class.new(i)
                    item:setData(v,self.extend)
                    local _x = self.start_x + self.ref_width * 0.5 + ((i - 1) % self.col) * (self.ref_width + self.space)
                    local _y = self.start_y - math.floor((i - 1) / self.col) * (self.ref_height + self.space)
                    item:setPosition(cc.p(_x, _y+15))
                    self.scroll_view:addChild(item)
                    table.insert(self.cache_list, item)
                end
            end
            self.action_effect[i]:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)
        end)
    end
end

function ItemExhibitionView:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        local effect_id = 274
        local action = PlayerAction.action_3
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(effect_id), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, action)
            self.title_container:addChild(self.play_effect, 1)
        end
    end
end 

function ItemExhibitionView:close_callback()
    self:finalClose()
    controller:openGetItemView(false)
end

function ItemExhibitionView:finalClose()
    for i, v in ipairs(self.cache_list) do
        if v and v.DeleteMe then
            v:DeleteMe()
        end
    end
    self.cache_list = {}
    self:handleEffect(false)
    self.render_list = {}
    GlobalEvent:getInstance():Fire(MainuiEvent.CLOSE_ITEM_VIEW,self.extend)
    GlobalEvent:getInstance():Fire(EventId.CAN_OPEN_LEVUPGRADE, true)
    GlobalEvent:getInstance():Fire(PokedexEvent.Call_End_Event)
end