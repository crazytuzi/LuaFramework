-- --------------------------------------------------------------------
-- @author: lwc
-- 英雄重生 --需求 王中键 后端: 子乔
-- <br/>Create: 2019年6月24日
-- --------------------------------------------------------------------
ActionHeroResetPanel = class("ActionHeroResetPanel", function()
    return ccui.Widget:create()
end)

local controller = ActionController:getInstance()
local hero_controller = HeroController:getInstance()
local hero_model = hero_controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
--@ bid 活动id 参照 holiday_role_data 表
--@ type 活动类型 参照 ActionType.Wonderful 定义
function ActionHeroResetPanel:ctor(bid, type)
    self.holiday_bid = bid
    self.type = type
    self.data = nil
    self:loadResources()
end

function ActionHeroResetPanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("actionheroreset","actionheroreset"), type = ResourcesType.plist }
    } 
    self.resources_load = ResourcesLoad.New(true) 
    self.resources_load:addAllList(self.res_list, function()
        self:configUI()
        self:register_event()
        self:initData()
    end)
end

function ActionHeroResetPanel:configUI( )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_hero_reset_panel"))
    self.root_wnd:setPosition(-40,-80)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    -- self.main_container_size = self.main_container:getContentSize()

    self.title_img = self.main_container:getChildByName("title_img")

    if self.item_load == nil then
        local title_str = "action_hero_reset_bg"
        local res = PathTool.getPlistImgForDownLoad("bigbg/action", title_str, false)
        self.item_load = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load)
    end

    self.lay_scrollview = self.main_container:getChildByName("lay_scrollview")

    self.reset_btn = self.main_container:getChildByName("reset_btn")
    self.skin_btn = self.main_container:getChildByName("skin_btn")
    self.skin_btn_lab = self.skin_btn:getChildByName("lab")
    self.skin_btn_lab:setString(TI18N("皮肤置换"))

    self.item_buy_panel = self.main_container:getChildByName("item_buy_panel")
    self.cost_icon = self.item_buy_panel:getChildByName("cost_icon")
    self.cost_label = self.item_buy_panel:getChildByName("label")
    self.add_btn = self.item_buy_panel:getChildByName("add_btn")
    self.add_btn:setVisible(false)

   
    self.change_btn = self.main_container:getChildByName("change_btn")
    local size = self.change_btn:getContentSize()
    self.change_btn_label = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5), cc.p(size.width * 0.5 ,size.height * 0.5), nil, nil, 900)
    self.change_btn:addChild(self.change_btn_label)
    

    self.reset_layout = self.main_container:getChildByName("reset_layout")
    self.time_title_0 = self.reset_layout:getChildByName("time_title_0")
    self.time_title_0:setString(TI18N("获\n得\n预\n览"))
    --英雄信息:
    self.lay_hero = self.main_container:getChildByName("lay_hero")


    self.title_name = self.main_container:getChildByName("title_name")
    -- self.title_name:setString(TI18N("凤凰涅槃"))
    self.title_name:setString(TI18N("限时重生"))

    --时间
    self.time_title = self.main_container:getChildByName("time_title")
    self.time_title:setString(TI18N("剩余时间:"))
    self.time_val = self.main_container:getChildByName("time_val")
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo then
        self:setLessTime(tab_vo.remain_sec)
    end

    self.item_scrollview = self.main_container:getChildByName("item_scrollview")

    local desc_label = createRichLabel(20, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0,0.5), cc.p(75, 272), nil, nil, 9000)
    self.main_container:addChild(desc_label)
    local config =  Config.PartnerData.data_partner_const.reborn_desc1
    if config then
        desc_label:setString(config.desc)
    end

    self.look_btn = self.main_container:getChildByName("look_btn")

    --重生英雄信息
    self.lay_hero = self.main_container:getChildByName("lay_hero")
    self.bg_img = self.lay_hero:getChildByName("bg_img")
    self.mode_node = self.lay_hero:getChildByName("mode_node")
    self.mode_node:setZOrder(2)
    self.star_node = self.lay_hero:getChildByName("star_node")
    self.camp_icon = self.lay_hero:getChildByName("camp_icon")
    self.name = self.lay_hero:getChildByName("name")


    self:updateCostInfo()

        --奖励
    local config = Config.PartnerData.data_partner_const.reborn_pre_reward
    if config then
        local data_list = Config.PartnerData.data_partner_const.reborn_pre_reward.val
        local setting = {}
        setting.scale = 0.9
        setting.max_count = 4
        setting.is_center = true
        setting.space_x = 20
        -- setting.show_effect_id = 263
        self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
    end
end

function ActionHeroResetPanel:register_event(  )
    registerButtonEventListener(self.add_btn, function() self:onAddBtn() end,true, 1)
    registerButtonEventListener(self.change_btn, function() self:onChangeBtn() end,true, 1)
    registerButtonEventListener(self.reset_btn, function() self:onResetBtn() end,true, 1)
    registerButtonEventListener(self.lay_hero, function() self:onResetBtn() end,false, 1)
    registerButtonEventListener(self.skin_btn, function() self:onSkinBtn() end,true, 1)
    

    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        local config =  Config.PartnerData.data_partner_const.reborn_desc2
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
        end
        local config = Config.PartnerData.data_partner_const.game_rule1
    end ,true, 1)


    --英雄重生返回
    if not self.action_hero_reset_event  then
        self.action_hero_reset_event = GlobalEvent:getInstance():Bind(ActionEvent.ACTION_HERO_RESET_EVENT,function (data)
            if not data then return end
            self.is_reseting = false
            if data.result == TRUE then
                self.select_hero_vo = nil
                self:initData()
            end
        end)
    end


    --选择英雄返回
    if not self.hero_reset_select_event  then
        self.hero_reset_select_event = GlobalEvent:getInstance():Bind(ActionEvent.HERO_RESET_SELECT_EVENT,function (select_hero_vo)
            self.select_hero_vo = select_hero_vo
            self:initData()
        end)
    end

        --物品道具增加 判断红点
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
            if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
               self:updateItemInfo()
            end
        end)
    end
    --物品道具删除 判断红点
    if not self.del_goods_event then
        self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,temp_del)
            if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
               self:updateItemInfo()
            end
        end)
    end

    --物品道具改变 判断红点
    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
            if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
               self:updateItemInfo()
            end
        end)
    end

    --获取升星材料返回
    if not self.hero_reset_star_event then
        self.hero_reset_star_event = GlobalEvent:getInstance():Bind(ActionEvent.ACTION_HERO_RESET_ITEM_EVENT, function(data)
            if not data then return end
            if not self.select_hero_vo then return end
            if #data.list == 0 then
                self:checkSender11071()
            else
                hero_controller:openHeroResetOfferPanel(true, data.list, is_show_tip, function()
                    self:checkSender11071()
                end, HeroConst.ResetType.eActionHeroReset)
            end
        end)
    end
end

function ActionHeroResetPanel:checkSender11071()
    if not self.select_hero_vo then return end

    local bid = self.item_id 
    local num = 10
    local config = Config.PartnerData.data_partner_const.reborn_cost
    if config and config.val[1] then
        bid = config.val[1][1] or 1
        num = config.val[1][2] or 0
    end

    local item_config = Config.ItemData.data_get_data(bid)
    if not item_config then return end
    local iconsrc = PathTool.getItemRes(item_config.icon)
    local color = BackPackConst.getWhiteQualityColorStr(item_config.quality)
    local str = string_format(TI18N("是否消耗<img src='%s' scale=0.3 /><div fontcolor=#%s> %s x %s </div>对英雄进行重生?操作无法撤回,请谨慎选择."), iconsrc, color, item_config.name, num)
    local call_back = function()
        self.is_reseting = true
        self.reset_btn:setVisible(false)
        self:playResetEffect(true)
        delayRun(self.main_container, 1, function()
            controller:sender11071(self.select_hero_vo.partner_id)                
        end)
    end
    CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
end

function ActionHeroResetPanel:onAddBtn()
    -- local jump_to =  Config.HolidayConvertData.data_const.jump_to
    -- if jump_to.val == 0 then
    --     return   
    -- end
    -- local tab_vo = controller:getActionSubTabVo(jump_to.val)
    -- if tab_vo and controller.action_operate and controller.action_operate.tab_list[tab_vo.bid] then
    --     controller.action_operate:handleSelectedTab(controller.action_operate.tab_list[tab_vo.bid])
    -- else
    --     message(jump_to.desc)
    -- end
end

function ActionHeroResetPanel:onChangeBtn()
    if not self.select_hero_vo  then
        message(TI18N("请选择重生的英雄"))
        return
    end
    if self.is_reseting  then
        message(TI18N("英雄重生中"))
        return
    end

    local bid = self.item_id 
    local num = 10
    local config = Config.PartnerData.data_partner_const.reborn_cost
    if config and config.val[1] then
        bid = config.val[1][1] or 1
        num = config.val[1][2] or 0
    end
    local count = BackpackController:getInstance():getModel():getItemNumByBid(bid)
    if count < num then
        message(TI18N("道具不足!"))
        return
    end

    controller:sender11072(self.select_hero_vo.partner_id)
end

--选择皮肤兑换
function ActionHeroResetPanel:onSkinBtn()
    controller:openActionHeroSkinResetPanel(true)
end

--选择重生列表
function ActionHeroResetPanel:onResetBtn()
    if self.is_reseting then
        return
    end
    -- body
    controller:openActionHeroResetSelectPanel(true, { select_hero_vo = self.select_hero_vo})
end

--更新模型,也是初始化模型
--@is_refresh  是否需要刷新(其实是假刷新)
function ActionHeroResetPanel:updateSpine(parent_panel, hero_vo, is_refresh)
    if parent_panel.record_spine_bid and parent_panel.record_spine_bid == hero_vo.bid and 
        parent_panel.record_spine_star and parent_panel.record_spine_star == hero_vo.star then
        if is_refresh then
            if parent_panel.spine then
                local action1 = cc.FadeOut:create(0.2)
                local action2 = cc.FadeIn:create(0.2)
                parent_panel.spine:runAction(cc.Sequence:create(action1,action2))
            end    
        end
        return
    end
    parent_panel.record_spine_bid = hero_vo.bid
    parent_panel.record_spine_star = hero_vo.star

    local fun = function()    
        if not parent_panel.spine then
            parent_panel.spine = BaseRole.new(BaseRole.type.partner, hero_vo, nil, {scale = 1, skin_id = hero_vo.use_skin})
            parent_panel.spine:setAnimation(0,PlayerAction.show,true) 
            parent_panel.spine:setCascade(true)
            -- parent_panel.spine:setPosition(cc.p(100,190))
            parent_panel.spine:setPositionY(66)
            parent_panel.spine:setAnchorPoint(cc.p(0.5,0.5)) 
            parent_panel.spine:setScale(0.8)
            parent_panel:addChild(parent_panel.spine, 2) 
            parent_panel.spine:setOpacity(0)
            local action = cc.FadeIn:create(0.2)
            parent_panel.spine:runAction(action)
        end
    end
    if parent_panel.spine then
        doStopAllActions(parent_panel.spine)
        parent_panel.spine:removeFromParent()
        parent_panel.spine = nil
        fun()
    else
        fun()
    end
end

--设置倒计时
function ActionHeroResetPanel:setLessTime(less_time)
    if tolua.isnull(self.time_val) then
        return
    end
    doStopAllActions(self.time_val)
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time_val:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    doStopAllActions(self.time_val)
                    self:setTimeFormatString(0)
                else
                    self:setTimeFormatString(less_time)
                end
            end))))
    else
        self:setTimeFormatString(0)
    end
end

function ActionHeroResetPanel:setTimeFormatString(time)
    if time > 0 then
        self.time_val:setString(TimeTool.GetTimeFormatDayIIIIII(time))
    else
        self.time_val:setString(TI18N("00:00:00"))
    end
end

function ActionHeroResetPanel:updateItemInfo()
    if not self.item_id then return end
    local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id)
    self.cost_label:setString(count)
end

function ActionHeroResetPanel:updateCostInfo(config_data)
    local config = Config.PartnerData.data_partner_const.reborn_cost
    if config and config.val[1] then
        self.item_id = config.val[1][1]
        local item_config = Config.ItemData.data_get_data(self.item_id)
        local num = config.val[1][2]
        if item_config then
            local name = TI18N("重生")
            local label_str = string.format("<img src=%s visible=true scale=0.3 /><div fontColor=#ffffff fontsize=26 outline=2,#6c2b00>%d %s</div>", PathTool.getItemRes(item_config.icon), num, name)
            self.change_btn_label:setString(label_str)
            self.cost_icon:loadTexture(PathTool.getItemRes(item_config.icon),LOADTEXT_TYPE)
        end
        self:updateItemInfo()
    end
end


function ActionHeroResetPanel:initData()
    if self.select_hero_vo == nil then
        self.bg_img:setVisible(true)
        self:initStar(0)
        self.name:setString("")
        self.camp_icon:setVisible(false)
        self.mode_node:setVisible(false)
        self.reset_btn:setVisible(false)
        self:playCommonEffect(false)
    else
        self.bg_img:setVisible(false)
        local star = self.select_hero_vo.star or 0
        self:initStar(star)
        self.name:setString(self.select_hero_vo.name)

        self.camp_icon:setVisible(true)
        local camp_type = self.select_hero_vo.camp_type or 1
        local res = PathTool.getHeroCampTypeIcon(self.select_hero_vo.camp_type)
        if self.record_camp_type_res == nil or self.record_camp_type_res ~= res then
            self.record_camp_type_res = res
            loadSpriteTexture(self.camp_icon, res, LOADTEXT_TYPE_PLIST)
        end

        self.mode_node:setVisible(true)
        self:updateSpine(self.mode_node, self.select_hero_vo, true)
        self.reset_btn:setVisible(true)
        self:playCommonEffect(true)
    end
end

--更新星星显示
function ActionHeroResetPanel:initStar(num)
    local num = num or 0
    local width = 26
    self.star_setting = HeroController:getInstance():getModel():createStar(num, self.star_node, self.star_setting, width)
end

function ActionHeroResetPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
    if bool == true then 
        -- controller:sender16666(self.holiday_bid)
        -- controller:cs16603(self.holiday_bid)
        -- self:initData()
    end
end

--播放常态效果
function ActionHeroResetPanel:playCommonEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        -- AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON,"c_xianji")
        if self.play_effect == nil then
            self.play_effect = createEffectSpine("E24702", cc.p(75, 53), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.lay_hero:addChild(self.play_effect, 1)
        else
            self.play_effect:setAnimation(0, PlayerAction.action, false)
        end
    end
end

--播放重生效果
function ActionHeroResetPanel:playResetEffect(status)
    if status == false then
        if self.play_effect2 then
            self.play_effect2:clearTracks()
            self.play_effect2:removeFromParent()
            self.play_effect2 = nil
        end
    else
        -- AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON,"c_xianji")
        if self.play_effect2 == nil then
            self.play_effect2 = createEffectSpine("E24701", cc.p(83, 203), cc.p(0.5, 0.5), false, PlayerAction.action)
            self.lay_hero:addChild(self.play_effect2, 3)
        else
            self.play_effect2:setAnimation(0, PlayerAction.action, false)
        end
    end
end


function ActionHeroResetPanel:DeleteMe(  )
    self:playCommonEffect(false)
    self:playResetEffect(false)
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

     if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v:DeleteMe()
        end
    end
    self.item_list = nil

    if self.modify_goods_event then
        GlobalEvent:getInstance():UnBind(self.modify_goods_event)
        self.modify_goods_event = nil
    end

    if self.add_goods_event then
        GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
    end

    if self.del_goods_event then
        GlobalEvent:getInstance():UnBind(self.del_goods_event)
        self.del_goods_event = nil
    end

    if self.hero_reset_star_event then
        GlobalEvent:getInstance():UnBind(self.hero_reset_star_event)
        self.hero_reset_star_event = nil
    end

    if self.limin_common_event then
        GlobalEvent:getInstance():UnBind(self.limin_common_event)
        self.limin_common_event = nil
    end
    if self.action_hero_reset_event then
        GlobalEvent:getInstance():UnBind(self.action_hero_reset_event)
        self.action_hero_reset_event = nil
    end
    if self.hero_reset_select_event then
        GlobalEvent:getInstance():UnBind(self.hero_reset_select_event)
        self.hero_reset_select_event = nil
    end

    if self.resources_load ~= nil then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    
    doStopAllActions(self.main_container)
end