-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      快速战斗
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

BattlDramaHookRewardWindow = BattlDramaHookRewardWindow or BaseClass(BaseView)

local controller = BattleDramaController:getInstance() 
local model = BattleDramaController:getInstance():getModel()
local role_vo = RoleController:getInstance():getRoleVo()

function BattlDramaHookRewardWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "battledrama/battle_drama_hook_reward_windows"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
    }
    self.is_csb_action = true
    self.can_click = false
end

function BattlDramaHookRewardWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background then
        self.background:setScale(display.getMaxScale())
    end

    local main_container = self.root_wnd:getChildByName("main_container")
    -- self:playEnterAnimatianByObj(main_container, 2)
    main_container:getChildByName("get_title"):setString(TI18N("获得物品"))

    self.head_icon = PlayerHead.new(PlayerHead.type.circle)
    self.head_icon:setPosition(183, 404)

    self.head_icon:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
    self.head_icon:setScale(0.8)
    main_container:addChild(self.head_icon)

    local progress_container = main_container:getChildByName("progress_container")
    self.progress = progress_container:getChildByName("progress")
    self.progress_width = progress_container:getContentSize().width
    self.progress_bar = progress_container:getChildByName("progress_bar")

    self.title_container = main_container:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    self.guidesign_rewards_quick_btn = main_container:getChildByName("guidesign_rewards_quick_btn")
    self.vip_notice_label = self.guidesign_rewards_quick_btn:getChildByName("label")
    self.vip_notice_label:setString(TI18N("获得来自vip、称号的收益加成"))

    self.level = main_container:getChildByName("level")
    self.progress_val = main_container:getChildByName("progress_val")
    self.time_value = main_container:getChildByName("time_value")

    self.list_view = self.root_wnd:getChildByName("list_view")

    self.time_type_title = main_container:getChildByName("time_title")

    self.main_container = main_container
    self.progress_container = progress_container
end

function BattlDramaHookRewardWindow:register_event()
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                self:closeThisWindow()
            end
        end)
    end
    if self.guidesign_rewards_quick_btn then
        self.guidesign_rewards_quick_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                self:closeThisWindow()
            end
        end)
    end
end

function BattlDramaHookRewardWindow:closeThisWindow()
    if self.can_click == false then return end
    playButtonSound2()
    controller:openDramHookRewardView(false) 

    -- 这里破防物品飘向背包的特效
end

function BattlDramaHookRewardWindow:openRootWnd(data)
    playOtherSound("c_get") 
    self.can_click = false
    delayRun(self.main_container, 0.3, function() 
        self.can_click = true
    end)

    if data then
        self.result_type = data.type   -- 1.是挂机收益 2.是快速作战

        if self.result_type == 1 then
            self.time_type_title:setString(TI18N("挂机收益："))
        elseif self.result_type == 2 then
            self.time_type_title:setString(TI18N("快速作战："))
        end

        self:handleEffect(true)
        self:createItemList(data.items)
        self:setBaseInfo(data)

        -- 暂时屏蔽vip字样显示
        -- self.vip_notice_label:setString(TI18N("点击空白区域关闭界面"))
        if data.vip_buff then
            if data.vip_buff == 0 then
                self.vip_notice_label:setString(TI18N("vip可获额外收益加成"))
            else
                if data.honor_buff and data.honor_buff ~= 0 then
                    self.vip_notice_label:setString(TI18N("获得来自vip、称号的收益加成"))
                else
                    self.vip_notice_label:setString(TI18N("获得来自vip的收益加成"))
                end
            end
        end
    end
end

function BattlDramaHookRewardWindow:setBaseInfo(data)
    if data == nil then return end

    self.level:setString("LV."..data.new_lev)
    self.time_value:setString(TimeTool.GetTimeFormat(data.time))

    local old_lev = data.old_lev
    local old_exp = data.old_exp
    local old_config = Config.RoleData.data_role_attr[old_lev]
    local new_lev = data.new_lev
    local new_exp = data.new_exp
    local new_config = Config.RoleData.data_role_attr[new_lev]
    if old_config == nil or new_config == nil then return end

    -- 当前经验
    self.progress_val:setString(new_exp.."/"..new_config.exp_max)

    -- 先记录旧的当前经验
    self.old_exp_progress = 100*old_exp/old_config.exp_max
    self.progress:setPercent(self.old_exp_progress)
    self.progress_bar:setPositionX(self.old_exp_progress*0.01*self.progress_width+5)

    self.old_role_lev = old_lev
    self.old_role_exp = old_exp
    self.new_role_lev = new_lev
    self.new_role_exp = new_exp

    -- 跑进度条
    self:showProgressEffect()
end

function BattlDramaHookRewardWindow:showProgressEffect()
    local role_attr_config = Config.RoleData.data_role_attr
    
    local baseCurMaxExp = role_attr_config[self.old_role_lev].exp_max
    local basePercent = self.old_role_exp/baseCurMaxExp*100
    local maxPercent = self.new_role_exp/baseCurMaxExp*100
    if self.old_role_lev ~= self.new_role_lev then -- 有升级
        maxPercent = 100
    end

    local call_back = function()
        basePercent = basePercent + 1
        if basePercent > maxPercent then
            if self.old_role_lev == self.new_role_lev then
                baseCurMaxExp = role_attr_config[self.new_role_lev].exp_max
                basePercent = self.new_role_exp/baseCurMaxExp*100

                self.progress:setPercent(basePercent)
                self.progress_bar:setPositionX(basePercent*0.01*self.progress_width+5)
                self.progress_val:setString(string.format("%d/%d", self.new_role_exp, tonumber(baseCurMaxExp)))

                GlobalTimeTicket:getInstance():remove("battle_drema_hook_reward_timer")
            else
                self.old_role_lev = self.old_role_lev + 1
                basePercent = 0
                maxPercent = 100
                baseCurMaxExp = Config.RoleData.data_role_attr[self.old_role_lev].exp_max
                if self.old_role_lev == self.new_role_lev then
                    maxPercent = self.new_role_exp/Config.RoleData.data_role_attr[self.new_role_lev].exp_max*100
                end
            end
        else
            self.progress:setPercent(basePercent)
            self.progress_bar:setPositionX(basePercent*0.01*self.progress_width+5)
            self.progress_val:setString(string.format("%d/%d", self.new_role_exp, tonumber(baseCurMaxExp)))
        end
    end
    GlobalTimeTicket:getInstance():add(call_back, 0.01, 0, "battle_drema_hook_reward_timer")
end

function BattlDramaHookRewardWindow:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        local effect_id = 278
        local action = PlayerAction.action_1
        if self.result_type == 2 then
            action = PlayerAction.action_2
        end
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(effect_id), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, action)
            self.title_container:addChild(self.play_effect, 1)
        end
    end
end 

function BattlDramaHookRewardWindow:createItemList(item_list)
    if item_list == nil or next(item_list) == nil then return end
    if self.scroll_view == nil then
        local scroll_view_size = self.list_view:getContentSize()
        local setting = {
            item_class = BattlDramaHookRewardItem,
            start_x = 94,
            space_x = 20,
            start_y = 0,
            space_y = 10,
            item_width = 120,
            item_height = 145,
            row = 4,
            col = 4,
            delay = 6,
            need_dynamic = true
        }
        self.scroll_view = CommonScrollViewLayout.new(self.list_view, nil, nil, nil, scroll_view_size, setting)
    end            
    self.scroll_view:setData(item_list)
end

function BattlDramaHookRewardWindow:close_callback()
    GlobalTimeTicket:getInstance():remove("battle_drema_hook_reward_timer")

    if self.scroll_view then
        self.scroll_view:DeleteMe()
    end
    self.scroll_view = nil

    if self.head_icon then
        self.head_icon:DeleteMe()
    end
    self.head_icon = nil
    if self.result_type and self.result_type == 1 then
        --1.是挂机收益 需要触发该事件
    	GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW)
    end
    controller:openDramHookRewardView(false)
end




BattlDramaHookRewardItem = class("BattlDramaHookRewardItem", function()
    return ccui.Layout:create()
end)


function BattlDramaHookRewardItem:ctor()
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(cc.size(120,145))
    self:setCascadeOpacityEnabled(true)

    self.item = BackPackItem.new(false, true, false, 1, false, true)
    self.item:setPosition(60,85)
    self:addChild(self.item)

    self.item_name_label = createLabel(24, cc.c4b(0xff,0xe8,0x87,0xff),nil, 60, 0, "", self, nil, cc.p(0.5, 0))

    self:registerEvent()
end

function BattlDramaHookRewardItem:registerEvent()
    self:registerScriptHandler(function(event)
        if "enter" == event then
            self:setOpacity(0)
            self:setScale(2)
            local fadeIn = cc.FadeIn:create(0.1)
            local scaleTo = cc.ScaleTo:create(0.1, 1)
            self:runAction(cc.Spawn:create(fadeIn, scaleTo))
        elseif "exit" == event then

        end 
    end)
end

function BattlDramaHookRewardItem:setData(data)
    if data then
        self.item:setBaseData(data.bid, data.num)

        local item_config = Config.ItemData.data_get_data(data.bid)
        if item_config then
            self.item_name_label:setString(item_config.name)
        end
    end
end

function BattlDramaHookRewardItem:suspendAllActions()
end

function BattlDramaHookRewardItem:DeleteMe()
    if self.item then
        self.item:DeleteMe()
    end
    self.item = nil
    self:removeAllChildren()
    self:removeFromParent()
end
