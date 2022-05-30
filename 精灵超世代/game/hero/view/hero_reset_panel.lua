-- --------------------------------------------------------------------
-- @author: xhj
-- 宝可梦重生 --需求 王中键 后端: 
-- <br/>Create: 2019年6月24日
-- --------------------------------------------------------------------
HeroResetPanel = class("HeroResetPanel", function()
    return ccui.Widget:create()
end)

local controller = ActionController:getInstance()
local hero_controller = HeroController:getInstance()
local hero_model = hero_controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_merge = table.merge
local table_sort = table.sort
--@ bid 活动id 参照 holiday_role_data 表
--@ type 活动类型 参照 ActionType.Wonderful 定义
function HeroResetPanel:ctor()
    self.data = nil
    self.hero_retrun_items = {}
    self.is_send_items = false
    self:loadResources()
end

function HeroResetPanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("actionheroreset","actionheroreset"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_return_bg", true), type = ResourcesType.single }
    } 
    self.resources_load = ResourcesLoad.New(true) 
    self.resources_load:addAllList(self.res_list, function()
        self:configUI()
        self:register_event()
        self:initData()
    end)
end

function HeroResetPanel:configUI( )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("hero/hero_reset_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    local res  = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_return_bg",true)
    self.background = self.root_wnd:getChildByName("background")
    if not self.bg_load then
        self.bg_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.background) then
                loadSpriteTexture(self.background, res, LOADTEXT_TYPE)
            end
        end, self.bg_load)
    end
    self.background:setScale(display.getMaxScale())
    -- self.main_container_size = self.main_container:getContentSize()

    self.lay_scrollview = self.main_container:getChildByName("lay_scrollview")

    self.reset_btn = self.main_container:getChildByName("reset_btn")


    self.item_buy_panel = self.main_container:getChildByName("item_buy_panel")
    self.cost_icon = self.item_buy_panel:getChildByName("cost_icon")
    self.cost_label = self.item_buy_panel:getChildByName("label")
    self.add_btn = self.item_buy_panel:getChildByName("add_btn")

   
    self.change_btn = self.main_container:getChildByName("change_btn")
    local size = self.change_btn:getContentSize()
    self.change_btn_label = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5), cc.p(size.width * 0.5 ,size.height * 0.5 + 50), nil, nil, 900)
    self.change_btn:addChild(self.change_btn_label)
    

    self.reset_layout = self.main_container:getChildByName("reset_layout")
    self.time_title_0 = self.reset_layout:getChildByName("time_title_0")
    self.time_title_0:setString(TI18N("获\n得\n预\n览"))
    --宝可梦信息:
    self.lay_hero = self.main_container:getChildByName("lay_hero")

    self.item_scrollview = self.main_container:getChildByName("item_scrollview")

    local desc_label = createRichLabel(20, Config.ColorData.data_new_color4[15], cc.p(0,0.5), cc.p(60, 585), nil, nil, 600)
    self.main_container:addChild(desc_label)
    local config =  Config.PartnerData.data_partner_const.return_desc1
    if config then
        desc_label:setString(config.desc)
    end

    self.look_btn = self.main_container:getChildByName("look_btn")

    --重生宝可梦信息
    self.lay_hero = self.main_container:getChildByName("lay_hero")
    self.hero_info_panel = self.lay_hero:getChildByName("hero_info_panel")
    
    self.bg_img = self.lay_hero:getChildByName("bg_img")
    self.mode_node = self.lay_hero:getChildByName("mode_node")
    self.mode_node:setZOrder(2)
    self.star_node = self.hero_info_panel:getChildByName("star_node")
    self.star_node_2 = self.hero_info_panel:getChildByName("star_node_2")
    self.camp_icon = self.hero_info_panel:getChildByName("camp_icon")
    self.lv_lab_1 = self.hero_info_panel:getChildByName("lv_lab_1")
    self.lv_lab_2 = self.hero_info_panel:getChildByName("lv_lab_2")
    self.info_btn = self.hero_info_panel:getChildByName("info_btn")
    
    self.name = self.hero_info_panel:getChildByName("name")

    self:updateCostInfo()

end

function HeroResetPanel:register_event(  )
    registerButtonEventListener(self.add_btn, function() self:onAddBtn() end,true, 1)
    registerButtonEventListener(self.change_btn, function() self:onChangeBtn() end,true, 1)
    registerButtonEventListener(self.reset_btn, function() self:onResetBtn() end,true, 1)
    registerButtonEventListener(self.lay_hero, function() self:onResetBtn() end,false, 1)
    registerButtonEventListener(self.info_btn, function() self:onInfoBtn() end,true, 1)
    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        local config =  Config.PartnerData.data_partner_const.return_desc2
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
        end
        local config = Config.PartnerData.data_partner_const.game_rule1
    end ,true, 1)


    --宝可梦重生返回
    if not self.action_hero_reset_event  then
        self.action_hero_reset_event = GlobalEvent:getInstance():Bind(HeroEvent.HERO_RESET_EVENT,function (data)
            if not data then return end
            self.is_reseting = false
            if data.result == TRUE then
                self.select_hero_vo = nil
                self:initData()
            end
        end)
    end


    --选择宝可梦返回
    if not self.hero_return_select_event  then
        self.hero_return_select_event = GlobalEvent:getInstance():Bind(HeroEvent.HERO_RETURN_SELECT_EVENT,function (select_hero_vo)
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
        self.hero_reset_star_event = GlobalEvent:getInstance():Bind(HeroEvent.HERO_RESET_ITEM_EVENT, function(data)
            if not data then return end
            if not self.select_hero_vo then return end
            if self.is_send_items == true then
                self.hero_retrun_items[self.select_hero_vo.partner_id] = data.list
                self:updateItemList(data.list)
            else
                if #data.list == 0 then
                    self:checkSender11066()
                else
                    hero_controller:openHeroResetOfferPanel(true, data.list, is_show_tip, function()
                        self:checkSender11066()
                    end, HeroConst.ResetType.eHeroReturn)
                end
            end 
            self.is_send_items = false
        end)
    end
end

function HeroResetPanel:checkSender11066()
    if not self.select_hero_vo then return end

    local bid = self.item_id 
    local num = 10
    local config = Config.PartnerData.data_partner_const.return_cost
    if config and config.val[1] then
        bid = config.val[1][1] or 1
        num = config.val[1][2] or 0
    end

    local item_config = Config.ItemData.data_get_data(bid)
    if not item_config then return end
    local iconsrc = PathTool.getItemRes(item_config.icon)
    local color = BackPackConst.getWhiteQualityColorStr(item_config.quality)
    local str = string_format(TI18N("是否消耗<img src='%s' scale=0.3 /><div fontcolor=#%s> %s x %s </div>对宝可梦进行重生？\n               操作无法撤回，请谨慎选择。"), iconsrc, color, item_config.name, num)
    local call_back = function()
        if tolua.isnull(self.root_wnd) then
            return
        end
        self.is_reseting = true
        if self.reset_btn then
            self.reset_btn:setVisible(false)
        end
        
        self:playResetEffect(true)
        delayRun(self.main_container, 1, function()
            hero_controller:sender11065(self.select_hero_vo.partner_id)                
        end)
    end
    CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
end

--宝可梦详细信息
function HeroResetPanel:onInfoBtn()
    if not self.select_hero_vo then return end   
    hero_controller:openHeroTipsPanel(true, self.select_hero_vo)
end

function HeroResetPanel:onAddBtn()
    local config = Config.PartnerData.data_partner_const.return_cost
    if config and config.val[1] then
        local config = Config.ItemData.data_get_data(config.val[1][1])
        if config then
            BackpackController:getInstance():openTipsSource(true, config)
        end
    end
end

function HeroResetPanel:onChangeBtn()
    if not self.select_hero_vo  then
        message(TI18N("请选择重生的宝可梦"))
        return
    end
    if self.is_reseting  then
        message(TI18N("宝可梦重生中"))
        return
    end

    local bid = self.item_id 
    local num = 10
    local config = Config.PartnerData.data_partner_const.return_cost
    if config and config.val[1] then
        bid = config.val[1][1] or 1
        num = config.val[1][2] or 0
    end
    local count = BackpackController:getInstance():getModel():getItemNumByBid(bid)
    if count < num then
        -- message(TI18N("道具不足!"))
        self:onAddBtn()
        return
    end

    hero_controller:sender11066(self.select_hero_vo.partner_id)
end

--选择重生列表
function HeroResetPanel:onResetBtn()
    if self.is_reseting then
        return
    end
    -- body
    controller:openActionHeroResetSelectPanel(true, { select_hero_vo = self.select_hero_vo,is_hero_return = true})
end

--更新模型,也是初始化模型
--@is_refresh  是否需要刷新(其实是假刷新)
function HeroResetPanel:updateSpine(parent_panel, hero_vo, is_refresh)
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


function HeroResetPanel:updateItemInfo()
    if not self.item_id then return end
    local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id)
    self.cost_label:setString(count)
end

function HeroResetPanel:updateCostInfo(config_data)
    local config = Config.PartnerData.data_partner_const.return_cost
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


function HeroResetPanel:initData()
    local data_list = {}
    local setting = {}
    setting.scale = 0.9
    setting.max_count = 4
    setting.is_center = true
    setting.space_x = 20

    if self.select_hero_vo == nil then
        self.bg_img:setVisible(true)
        self:initStar(0,0)
        self.hero_info_panel:setVisible(false)
        self.mode_node:setVisible(false)
        self.reset_btn:setVisible(false)
        self:playCommonEffect(false)
        local config = Config.PartnerData.data_partner_const.return_pre_reward
        if config then
            data_list = Config.PartnerData.data_partner_const.return_pre_reward.val
        end
        self.item_list = hero_controller:showSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
    else
        self.bg_img:setVisible(false)
        local star = self.select_hero_vo.star or 0
        local return_star = Config.PartnerData.data_partner_const.return_star
        local star_2 = 10
        if return_star then
            star_2 = return_star.val
        end
        self:initStar(star,star_2)
        self.name:setString(self.select_hero_vo.name)
        self.lv_lab_1:setString("lv."..self.select_hero_vo.lev)
        local lv = self.select_hero_vo.lev
        local config = Config.PartnerData.data_partner_const.return_lv
        if config then
            if self.select_hero_vo.lev>config.val then
                lv = config.val
            end
            self.lv_lab_2:setString("lv."..lv)
        end

        self.hero_info_panel:setVisible(true)
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


        if self.hero_retrun_items and self.hero_retrun_items[self.select_hero_vo.partner_id] then
            self:updateItemList(self.hero_retrun_items[self.select_hero_vo.partner_id])
        else
            self.is_send_items = true
            hero_controller:sender11066(self.select_hero_vo.partner_id)
        end
    end
    
    
end

function HeroResetPanel:updateItemList(list)
    if tolua.isnull(self.root_wnd) then
        return
    end
    
    local data_list = {}
    for i,v in ipairs(list) do
        if v.is_partner == 1 then
            local info = {}
            info.bid = v.id
            info.star = v.star
            info.lev = v.lev
            info.show_type = MainuiConst.item_exhibition_type.partner_type
            table_insert(data_list, info)
        else
            table_insert(data_list, {v.id,v.num})
        end
    end

    local setting = {}
    setting.scale = 0.9
    setting.max_count = 4
    setting.is_center = true
    setting.space_x = 20
    self.item_list = hero_controller:showSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
end

--更新星星显示
function HeroResetPanel:initStar(num,num2)
    local num = num or 0
    local num2 = num2 or 0
    local width = 26
    self.star_setting = hero_controller:getModel():createStar(num, self.star_node, self.star_setting, width)
    self.star_setting_2 = hero_controller:getModel():createStar(num2, self.star_node_2, self.star_setting_2, width)
end

function HeroResetPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
    if bool == true then 
    end
end

--播放常态效果
function HeroResetPanel:playCommonEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        -- AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON,"c_xianji")
        if self.play_effect == nil then
            self.play_effect = createEffectSpine("E24702", cc.p(75, 13), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.play_effect:setScale(0.8)
            self.lay_hero:addChild(self.play_effect, 1)
        else
            self.play_effect:setAnimation(0, PlayerAction.action, true)
        end
    end
end

--播放重生效果
function HeroResetPanel:playResetEffect(status)
    if status == false then
        if self.play_effect2 then
            self.play_effect2:clearTracks()
            self.play_effect2:removeFromParent()
            self.play_effect2 = nil
        end
    else
        -- AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON,"c_xianji")
        if self.play_effect2 == nil then
            self.play_effect2 = createEffectSpine("E24701", cc.p(83, 143), cc.p(0.5, 0.5), false, PlayerAction.action)
            self.lay_hero:addChild(self.play_effect2, 3)
        else
            self.play_effect2:setAnimation(0, PlayerAction.action, false)
        end
    end
end

function HeroResetPanel:DeleteMe(  )
    CommonAlert.closeAllWin()
    self:playCommonEffect(false)
    self:playResetEffect(false)


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
    if self.hero_return_select_event then
        GlobalEvent:getInstance():UnBind(self.hero_return_select_event)
        self.hero_return_select_event = nil
    end

    if self.resources_load ~= nil then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    if self.bg_load ~= nil then
        self.bg_load:DeleteMe()
        self.bg_load = nil
    end
    
    doStopAllActions(self.main_container)
    
end