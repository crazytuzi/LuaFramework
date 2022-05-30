-- --------------------------------------------------------------------
-- @author: lwc
-- 宝可梦10星11星置换活动 --需求 任思义 后端: 子乔
-- <br/>Create: 2019年4月19日
-- --------------------------------------------------------------------
ActionHeroConvertPanel = class("ActionHeroConvertPanel", function()
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
function ActionHeroConvertPanel:ctor(parent)--(bid, type)
    --self.holiday_bid = bid
    --self.type = type
    self.parent = parent
    self.data = nil
    self.item_id = Config.HolidayConvertData.data_const.item_id.val   --置换道具id
    --可置换的宝可梦列表
    self.conver_hero_list = {}
     --scrollview列表
    self:loadResources()
end

function ActionHeroConvertPanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_replace_bg",true), type = ResourcesType.single },
        --{ path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_hero_convert_stage",false), type = ResourcesType.single },
    } 
    self.resources_load = ResourcesLoad.New(true) 
    self.resources_load:addAllList(self.res_list, function()
        self:configUI()
        self:register_event()
        self:initConvertData()
        self:onClickBtnShowByIndex(0)
    end)
end

function ActionHeroConvertPanel:configUI( )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_hero_convert_panel"))
    --self.root_wnd:setPosition(cc.p(0,290))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    -- self.main_container_size = self.main_container:getContentSize()

    local role_layout = self.main_container:getChildByName("role_layout")
    local camp_node = role_layout:getChildByName("camp_node")
    self.camp_btn_list = {}
    self.camp_btn_redpoint_list = {}
    self.camp_btn_list[0] = camp_node:getChildByName("camp_btn0")
    self.camp_btn_list[HeroConst.CampType.eWater] = camp_node:getChildByName("camp_btn1")
    self.camp_btn_list[HeroConst.CampType.eFire]  = camp_node:getChildByName("camp_btn2")
    self.camp_btn_list[HeroConst.CampType.eWind]  = camp_node:getChildByName("camp_btn3")
    self.camp_btn_list[HeroConst.CampType.eLight] = camp_node:getChildByName("camp_btn4")
    self.camp_btn_list[HeroConst.CampType.eDark]  = camp_node:getChildByName("camp_btn5")
    self.img_select = camp_node:getChildByName("img_select")
    local x, y = self.camp_btn_list[0]:getPosition()
    self.img_select:setPosition(x - 0.5, y + 1)

    self.lay_scrollview = self.main_container:getChildByName("lay_scrollview")


    self.left_panel = self.main_container:getChildByName("left_panel")
    --self.img_left = self.main_container:getChildByName("img_left")
    --if self.left_img_load == nil then
    --    local title_str = "txt_cn_hero_convert_stage"
    --    local res = PathTool.getPlistImgForDownLoad("bigbg/action", title_str, false)
    --    self.left_img_load = loadSpriteTextureFromCDN(self.img_left, res, ResourcesType.single, self.left_img_load)
    --end
    --
    self.right_panel = self.main_container:getChildByName("right_panel")
    --self.img_right  = self.main_container:getChildByName("img_right")
    --if self.right_img_load == nil then
    --    local title_str = "txt_cn_hero_convert_stage"
    --    local res = PathTool.getPlistImgForDownLoad("bigbg/action", title_str, false)
    --    self.right_img_load = loadSpriteTextureFromCDN(self.img_right, res, ResourcesType.single, self.right_img_load)
    --end

    self.title_img = self.main_container:getChildByName("title_img")
    self.title_img:setScale( display.getMaxScale())

    self.change_btn = self.main_container:getChildByName("change_btn")
    local size = self.change_btn:getContentSize()
    self.change_btn_label = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5), cc.p(size.width * 0.5 ,size.height * 0.5 + 50), nil, nil, 900)
    self.change_btn:addChild(self.change_btn_label)
    self:updateCostInfo()
    if self.item_load == nil then
        local title_str = "hero_replace_bg"
        local res = PathTool.getPlistImgForDownLoad("bigbg/hero", title_str, true)
        self.item_load = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load)
    end


    self.item_node = self.main_container:getChildByName("item_node")
    self.hero_item = HeroExhibitionItem.new(0.9, true)
    self.hero_item:addCallBack(function() self:onClickHeroItem() end)
    self.item_node:addChild(self.hero_item) 
    self.hero_item.num_label:setZOrder(1)
    self:updateHeroItem()

    self.time_val = self.main_container:getChildByName("time_title")
    self.time_val:setVisible(false)
    -- local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    -- if tab_vo then
    --     self:setLessTime(tab_vo.remain_sec)
    -- end
    self.item_buy_panel = self.main_container:getChildByName("item_buy_panel")
    local cost_icon = self.item_buy_panel:getChildByName("cost_icon")
    local item_config = Config.ItemData.data_get_data(self.item_id) 
    if item_config then
        cost_icon:loadTexture(PathTool.getItemRes(item_config.icon),LOADTEXT_TYPE)
    end

    --宝可梦数量
    self.cost_label = self.item_buy_panel:getChildByName("label")
    self.add_btn = self.item_buy_panel:getChildByName("add_btn")

    local val =  Config.HolidayConvertData.data_const.jump_to.val
    if val == 0 then
        self.add_btn:setVisible(false)        
    end


    --self.tips_label = self.main_container:getChildByName("tips_label")
    --self.tips_label:setString(TI18N("可参与置换宝可梦:"))
    self.look_btn = self.main_container:getChildByName("look_btn")
    self:updateItemInfo()
end

function ActionHeroConvertPanel:register_event(  )
    registerButtonEventListener(self.add_btn, function() self:onAddBtn() end,true, 2)
    registerButtonEventListener(self.change_btn, function() self:onChangeBtn() end,true, 2)

    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        local config =  Config.HolidayConvertData.data_const.game_rule
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, cc.p(sender:getTouchBeganPosition().x,20))
        end
        local config = Config.PartnerData.data_partner_const.game_rule1
    end ,true, 1)
    --阵营按钮
    for select_camp, v in pairs(self.camp_btn_list) do
        registerButtonEventListener(v, function() self:onClickBtnShowByIndex(select_camp) end ,true, 2, nil, 0.8)
    end

    if not self.upgrade_star_select_event  then
        self.upgrade_star_select_event = GlobalEvent:getInstance():Bind(HeroEvent.Upgrade_Star_Select_Event,function (data)
            --刷新数据就星了
            if self.select_data then
                self:updateHeroItem(self.select_data)
            end
        end)
    end
    if not self.del_hero_event  then
        self.del_hero_event = GlobalEvent:getInstance():Bind(HeroEvent.Del_Hero_Event,function (data)
            --刷新数据就星了
            if self.parent.select_index == HeroConst.SacrificeType.eHeroReplace then 
                if not self.select_camp then return end
                self.left_hero_vo = nil
                self.select_data = nil
                self.left_panel:setVisible(false)
                self.right_panel:setVisible(false)
                self:updateHeroItem()
                self:initConvertData()
                self:updateHeroList(self.select_camp, true)
                if self.select_cell ~= nil then
                    self.select_cell:setSelected(false)
                end
                self.select_index = 0
                message(TI18N("置换成功!"))
            end
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
        self.hero_reset_star_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Reset_Star_Event, function(data)
            if not data then return end
            if not self.left_hero_vo then return end
            if #data.list == 0 then
                self:checkSender16686()
            else
                hero_controller:openHeroResetOfferPanel(true, data.list, is_show_tip, function()
                    if not self.left_hero_vo then return end
                    self:checkSender16686()
                end, HeroConst.ResetType.eTenStarChang)
            end
        end)
    end
end

function ActionHeroConvertPanel:checkSender16686()
    if not self.record_bid then return end
    if not self.record_hero_list then return end

    local config_data = self.dic_hero_star_camptype[self.left_hero_vo.star][self.left_hero_vo.camp_type]
    
    local bid = self.item_id --{14002,100}
    local num = 10
    if config_data then 
        local cost = config_data.loss
        if cost and next(cost) ~= nil then
            bid = cost[1][1]
            num = cost[1][2]
        end
    end
    local item_config = Config.ItemData.data_get_data(bid)
    if not item_config then return end
    local iconsrc = PathTool.getItemRes(item_config.icon)
    local color = BackPackConst.getWhiteQualityColorStr(item_config.quality)
    local str = string_format(TI18N("是否消耗<img src='%s' scale=0.3 /><div fontcolor=#%s> %s x %s </div>对宝可梦进行置换?操作无法撤回,请谨慎选择."), iconsrc, color, item_config.name, num)
    local call_back = function()
        controller:sender16686(self.left_hero_vo.partner_id, self.record_bid, self.record_hero_list)
        self.record_bid = nil
        self.record_hero_list = nil
    end
    CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
end

function ActionHeroConvertPanel:onAddBtn()
    if self.item_id then
        BackpackController:getInstance():openTipsSource(true, self.item_id)
    end
    --  local jump_to =  Config.HolidayConvertData.data_const.jump_to
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
function ActionHeroConvertPanel:onChangeBtn()
   -- 发送协议
    if not self.left_hero_vo  then 
        message(TI18N("请选择要置换的宝可梦"))
        return 
    end

    if not self.select_data or not self.select_data.dic_select_list then
        message(TI18N("请点击加号选择置换的宝可梦"))
        return
    end

    local hero_list = {}
    local bid = nil
    for k,v in pairs(self.select_data.dic_select_list) do
        if bid == nil then
            bid = v.bid
        end
        table_insert(hero_list, {partner_id = v.partner_id})   
    end
    local config_data = self.dic_hero_star_camptype[self.left_hero_vo.star][self.left_hero_vo.camp_type]
    if #hero_list < config_data.expend then
        message(TI18N("材料不足"))
        return
    end
    self.record_hero_list = hero_list
    self.record_bid = bid
    hero_controller:sender11087(hero_list)
end

function ActionHeroConvertPanel:onClickHeroItem()
    if not self.left_hero_vo then 
        message(TI18N("请选择要置换的宝可梦"))
        return 
    end
    if not self.dic_hero_star_camptype or not self.dic_hero_star_camptype[self.left_hero_vo.star] then return end

    local config_data = self.dic_hero_star_camptype[self.left_hero_vo.star][self.left_hero_vo.camp_type]
    if not config_data then return end
    local config_list = Config.HolidayConvertData.data_target_hero_list[config_data.target_group]
    if config_list and next(config_list) ~= nil then
        if self.select_data == nil then
            local select_data = {}
            select_data.bid = 0
            select_data.star = 5 --默认是5星宝可梦
            -- select_data.dic_select_list --记录已选的宝可梦 在openHeroUpgradeStarSelectPanel那边选择
            self.select_data = select_data
        end

        if self.select_data.left_hero_vo == nil or self.select_data.left_hero_vo.partner_id ~= self.left_hero_vo.partner_id then
            self.select_data.left_hero_vo = self.left_hero_vo
            self.select_data.dic_select_list = {}
            self.select_data.camp_type = self.left_hero_vo.camp_type
            self.select_data.count = config_data.expend --默认是5星宝可梦
        end

        self.select_data.hero_list = {}
        for bid,_ in pairs(config_list) do
            if self.left_hero_vo.bid ~= bid then
                local h_list = hero_model:getHeroInfoByBidStar(bid, self.select_data.star)
                if h_list then
                    for i,hero_vo in ipairs(h_list) do
                        if not hero_vo:isResonateHero() then
                            table_insert(self.select_data.hero_list, hero_vo)
                        end
                    end
                end
            end
        end
        hero_controller:openHeroUpgradeStarSelectPanel(true, self.select_data, {}, HeroConst.SelectHeroType.eTenConvert)
    end
end

--显示根据类型 0表示全部
function ActionHeroConvertPanel:onClickBtnShowByIndex(select_camp)
    if self.img_select and self.camp_btn_list[select_camp] then
        local x, y = self.camp_btn_list[select_camp]:getPosition()
        self.img_select:setPosition(x - 0.5, y + 1)
    end
    self:updateHeroList(select_camp)
end

function ActionHeroConvertPanel:updateHeroList(select_camp, is_must_reset)
    local select_camp = select_camp or 0
    if not is_must_reset and select_camp == self.select_camp then 
        return
    end
    
    self.left_hero_vo = nil
    self.select_data = nil
    --self.left_panel:setVisible(false)
    --self.right_panel:setVisible(false)
    self:updateHeroItem()
    self.select_index = 0

    if self.scroll_view == nil then
        local scroll_view_size = self.lay_scrollview:getContentSize()
        local list_setting = {
            start_x = 20,
            space_x = 0,
            start_y = 0,
            space_y = 0,
            item_width = 120,
            item_height = 120,
            row = 1,
            col = 5,
            need_dynamic = true
        }
        self.scroll_view = CommonScrollViewSingleLayout.new(self.lay_scrollview, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

        self.scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.scroll_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    self.select_camp = select_camp
    
    local hero_list = {}
    if select_camp == 0 then
        hero_list = self.conver_hero_list
    else
        self.show_list = {}
        for i,hero_vo in ipairs(self.conver_hero_list) do
            if hero_vo.camp_type == select_camp then
                table_insert(hero_list, hero_vo)
            end
        end    
    end


    self.show_list = {}
    local lock_list = {}
    for k, hero_vo in pairs(hero_list) do
        if select_camp == 0 or (select_camp == hero_vo.camp_type) then
            -- 锁定 , 上阵, 7星以上都不能被分解
            if hero_vo:isLock() or (hero_vo.isInForm and hero_vo:isInForm()) then --or hero_vo.star >= self.limit_star then
                table_insert(lock_list, hero_vo)
            else
                table_insert(self.show_list, hero_vo)
            end
            hero_vo.is_ui_select = nil
        end
    end 
    local sort_func = SortTools.tableLowerSorter({"camp_type", "star", "bid"})
    table_sort(lock_list, sort_func) 
    table_sort(self.show_list, sort_func) 
    for i,hero_vo in ipairs(lock_list) do
        table_insert(self.show_list, hero_vo)
    end

    self.scroll_view:reloadData()
    if #self.show_list == 0 then
        commonShowEmptyIcon(self.lay_scrollview, true, {font_size = 22,scale = 0.5, offset_y = 36, text = TI18N("暂无该类型宝可梦")})
    else
        commonShowEmptyIcon(self.lay_scrollview, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionHeroConvertPanel:createNewCell(width, height)
    local cell = HeroExhibitionItem.new(0.9, true)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ActionHeroConvertPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ActionHeroConvertPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
    if self.select_index == index then
        cell:setSelected(true)
    else
        cell:setSelected(false)
    end

    if (cell_data.isLock and cell_data:isLock()) or (cell_data.isInForm and cell_data:isInForm()) then --or cell_data.star >= self.limit_star then
        cell:showLockIcon(true)
    else
        cell:showLockIcon(false)
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function ActionHeroConvertPanel:onCellTouched(cell)
    if not cell.index then return end
    local cell_data = self.show_list[cell.index]
    if not cell_data then return end

    if cell_data:checkHeroLockTips(true) then
        return 
    end

    if self.select_cell ~= nil then
        self.select_cell:setSelected(false)
    end

    self.select_cell = cell
    self.select_index = cell.index

    if self.select_cell then
        self.select_cell:setSelected(true) 
    end

    self.left_hero_vo = cell_data
    self.left_panel:setVisible(true)
    self.right_panel:setVisible(false)
    self:updateSpine(self.left_panel, cell_data, true)
    if self.dic_hero_star_camptype and self.dic_hero_star_camptype[self.left_hero_vo.star] then
        local config_data = self.dic_hero_star_camptype[self.left_hero_vo.star][self.left_hero_vo.camp_type]
        self:updateCostInfo(config_data)
    end
    self:updateHeroItem()
end

--更新模型,也是初始化模型
--@is_refresh  是否需要刷新(其实是假刷新)
function ActionHeroConvertPanel:updateSpine(parent_panel, hero_vo, is_refresh)
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
            parent_panel.spine:setPosition(cc.p(100,190))
            parent_panel.spine:setAnchorPoint(cc.p(0.5,0.5)) 
            parent_panel.spine:setScale(0.8)
            parent_panel:addChild(parent_panel.spine) 
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

-- --设置倒计时
-- function ActionHeroConvertPanel:setLessTime(less_time)
--     if tolua.isnull(self.time_val) then
--         return
--     end
--     doStopAllActions(self.time_val)
--     if less_time > 0 then
--         self:setTimeFormatString(less_time)
--         self.time_val:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
--             cc.CallFunc:create(function()
--                 less_time = less_time - 1
--                 if less_time < 0 then
--                     doStopAllActions(self.time_val)
--                     self:setTimeFormatString(0)
--                 else
--                     self:setTimeFormatString(less_time)
--                 end
--             end))))
--     else
--         self:setTimeFormatString(0)
--     end
-- end

-- function ActionHeroConvertPanel:setTimeFormatString(time)
--     if time > 0 then
--         local str = string_format("%s: %s", TI18N("剩余时间"), TimeTool.GetTimeFormatDayIIIIII(time))
--         self.time_val:setString(str)
--     else
--         self.time_val:setString(TI18N("剩余时间: 00:00:00"))
--     end
-- end

function ActionHeroConvertPanel:updateHeroItem(select_data)
    if not self.hero_item then return end
    if not self.left_hero_vo then 
        --默认显示
        self.hero_item:setData()
        self.hero_item:setLev("0/5")
        self.hero_item:showAddIcon(true)
        return 
    end
    if not self.dic_hero_star_camptype or not self.dic_hero_star_camptype[self.left_hero_vo.star] then return end

    local config_data = self.dic_hero_star_camptype[self.left_hero_vo.star][self.left_hero_vo.camp_type]
    if not config_data then return end

    if select_data then
        local count = 0
        local select_hero_vo
        if self.select_data.dic_select_list then
            for k,v in pairs(self.select_data.dic_select_list) do
                if select_hero_vo == nil then
                    select_hero_vo = v
                end
                count = count + 1
            end
        end
        
        if select_hero_vo ~= nil then
            self.hero_item:setData(select_hero_vo)
            self.hero_item:showAddIcon(false)
            --右边的
            self.right_panel:setVisible(true)
            local hero_data = {}
            hero_data.bid = select_hero_vo.bid
            hero_data.star = config_data.star
            self:updateSpine(self.right_panel, hero_data, false)
        else
            self.hero_item:setData()
            self.right_panel:setVisible(false)
            self.hero_item:showAddIcon(true)    
        end
        self.hero_item:setLev(string_format("%s/%s", count, config_data.expend))
    else
        self.hero_item:setData()
        self.hero_item:setLev(string_format("0/%s", config_data.expend))
        self.hero_item:showAddIcon(true)
    end
end

function ActionHeroConvertPanel:updateItemInfo()
    local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id)
    self.cost_label:setString(count)
end

function ActionHeroConvertPanel:updateCostInfo(config_data)
    local bid = self.item_id --{14002,100}
    local num = 10
    if config_data then 
        local cost = config_data.loss
        if cost and next(cost) ~= nil then
            bid = cost[1][1]
            num = cost[1][2]
        end
    end
    local item_config = Config.ItemData.data_get_data(bid)
    if item_config then
        local name = TI18N("置换")
        local label_str = string.format("<img src=%s visible=true scale=0.3 /><div fontColor=#ffffff fontsize=26 >%d </div>", PathTool.getItemRes(item_config.icon), num)
        self.change_btn_label:setString(label_str)
    end
end

--初始化置换数据
function ActionHeroConvertPanel:initConvertData()
    local convert_info = Config.HolidayConvertData.data_convert_info
    if not convert_info then return end


    --可置换的宝可梦列表
    self.conver_hero_list = {}
    --说明 self.dic_hero_star_camptype[star][camp_tpye] == v  data_convert_info 的数据
    --eg self.dic_hero_star_camptype[10][1] == config_data : 表示  10 星 水系 的数据是: data_convert_info 的数据
    self.dic_hero_star_camptype = {}
    for star, list in pairs(convert_info) do
        if self.dic_hero_star_camptype[star] == nil then
            self.dic_hero_star_camptype[star] = {}
        end
        for k,v in pairs(list) do
            self.dic_hero_star_camptype[star][k] = v
            local config_list = Config.HolidayConvertData.data_hero_list[v.src_group]
            for bid, _ in pairs(config_list) do
                local h_list = hero_model:getHeroInfoByBidStar(bid, star)
                if h_list then
                    for i,hero_vo in ipairs(h_list) do
                        table_insert(self.conver_hero_list, hero_vo)
                    end
                end
           end
        end
    end
end

function ActionHeroConvertPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
    -- if bool == true then 
    --     controller:sender16666(self.holiday_bid)
    --     controller:cs16603(self.holiday_bid)
    -- end
end


function ActionHeroConvertPanel:DeleteMe(  )
    if self.item_scrollview then 
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end

    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    if self.left_img_load then 
        self.left_img_load:DeleteMe()
        self.left_img_load = nil
    end
    if self.right_img_load then 
        self.right_img_load:DeleteMe()
        self.right_img_load = nil
    end

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


    if self.upgrade_star_select_event then
        GlobalEvent:getInstance():UnBind(self.upgrade_star_select_event)
        self.upgrade_star_select_event = nil
    end
    if self.limin_common_event then
        GlobalEvent:getInstance():UnBind(self.limin_common_event)
        self.limin_common_event = nil
    end
    if self.del_hero_event then
        GlobalEvent:getInstance():UnBind(self.del_hero_event)
        self.del_hero_event = nil
    end

    if self.resources_load ~= nil then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    
    -- doStopAllActions(self.time_val)
end