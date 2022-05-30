-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      石碑增益
-- <br/> 2019年8月1日
-- --------------------------------------------------------------------
HeroResonateTabResonatePanel = class("HeroResonateTabResonatePanel", function()
    return ccui.Widget:create()
end)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local role_vo = RoleController:getInstance():getRoleVo()

local math_floor = math.floor

function HeroResonateTabResonatePanel:ctor(parent)  
    self.parent = parent
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function HeroResonateTabResonatePanel:config()
    -- self.dic_config_level_up = {}
    -- self.dic_config_star_attr = {}

    --槽位上限
    self.item_max_count = 20
    local config = Config.ResonateData.data_const.cell_max
    if config then
        self.item_max_count = config.val
    end

    self.cystal_max_lev_limit = 400
    local config = Config.ResonateData.data_const.cystal_max_lev_limit
    if config then
        self.cystal_max_lev_limit = config.val
    end

    self.hero_param = 100

    self.time_desc_list = {}
    --能否更新list
    self.can_update_list = true
end

function HeroResonateTabResonatePanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("hero/hero_resonate_tab_resonate_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")

    -- self.title_bg = self.main_container:getChildByName("title_bg")
    -- self.title_name = self.title_bg:getChildByName("title_name")
    -- self.title_name:setString(TI18N("水晶等级"))
    -- -- self.lev = self.title_bg:getChildByName("lev")
    -- -- self.lev:setString("")
    -- self.lev = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5, 0.5), cc.p(97,-21),nil,nil,600)
    -- self.title_bg:addChild(self.lev)
    -- self.title_bg_x, self.title_bg_y = self.title_bg:getPosition()

    -- local pos = {
    --     [5] = {-600,-600},
    --     [3] = {-400,-600},
    --     [1] = {0,-700},
    --     [2] = {400,-600},
    --     [4] = {600,-600},
    -- }
    -- self.item_lay_list = {}
    -- for i=1, 5 do
    --     local item_lay = self.main_container:getChildByName("item_lay_"..i)
    --     self.item_lay_list[i] = {}
    --     self.item_lay_list[i].btn = item_lay
    --     self.item_lay_list[i].add_img = item_lay:getChildByName("add_img")
    --     self.item_lay_list[i].add_img:setVisible(false)
    --     self.item_lay_list[i].lock_img = item_lay:getChildByName("lock_img")
    --     self.item_lay_list[i].lock_img:setVisible(false)
    --     self.item_lay_list[i].lock_tips = self.item_lay_list[i].lock_img:getChildByName("lock_tips")
    --     local x, y = item_lay:getPosition()
    --     self.item_lay_list[i].x = x
    --     self.item_lay_list[i].y = y
    --     self.item_lay_list[i].pos = pos[i]

    --     y = y + self.hero_param
    --     local zorder = math_floor(1000 - y)
    --     item_lay:setZOrder(zorder)
    -- end

    self.bottom_panel = self.main_container:getChildByName("bottom_panel")
    self.bottom_panel_x, self.bottom_panel_y = self.bottom_panel:getPosition()


    self.tips = self.bottom_panel:getChildByName("tips")
    self.tips:setString(TI18N("水晶等级决定槽位中宝可梦的等级"))
    --升级 340级后的事情
    self.level_up_panel = self.bottom_panel:getChildByName("level_up_panel")
    self.level_up_panel:setVisible(false)
    self.cost_bg_list = {}
    for i=1, 3 do
        local cost_bg = self.level_up_panel:getChildByName("cost_bg_"..i)
        self.cost_bg_list[i] = {}
        self.cost_bg_list[i].cost_bg = cost_bg
        self.cost_bg_list[i].cost_icon = cost_bg:getChildByName("cost_icon")
        self.cost_bg_list[i].cost_txt = cost_bg:getChildByName("cost_txt")
    end

    self.level_up_btn = self.level_up_panel:getChildByName("level_up_btn")
    self.level_up_btn_label = self.level_up_btn:getChildByName("label")
    self.level_up_btn_label:setString(TI18N("升 级"))

    self.lay_scrollview = self.bottom_panel:getChildByName("lay_scrollview")
    
    local item_buy_panel = self.bottom_panel:getChildByName("item_buy_panel")
    self.add_btn = item_buy_panel:getChildByName("add_btn")
    self.count_label = item_buy_panel:getChildByName("label")

    -- self.look_btn = self.bottom_panel:getChildByName("look_btn")
end

function HeroResonateTabResonatePanel:playEnterAnimatian()
    if not self.bottom_panel then return end
    commonOpenActionLeftMove(self.bottom_panel)
end

--事件
function HeroResonateTabResonatePanel:registerEvents()
    registerButtonEventListener(self.level_up_btn, function() self:onClickLevelUpBtn()  end ,true, 2)
    registerButtonEventListener(self.add_btn, function() self:onAddBtn(2)  end ,true, 2)

    -- registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
    --     if self.parent and self.parent.is_move_effect then return end
    --     local config = Config.ResonateData.data_const.rule_tips
    --     if config then
    --         TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    --     end
    -- end ,true, 2, nil, 0.8)

    --共鸣信息更新
    if self.hero_resonate_info_event == nil then
        self.hero_resonate_info_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Resonate_Crystal_Info_Event, function(data)
           if not data then return end
           self:setScData(data)
           self:showChangePower()
        end)
    end  

    --能否更新list
    if self.hero_resonate_crystal_can_list_event == nil then
        self.hero_resonate_crystal_can_list_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Resonate_Crystal_Can_List_Event, function(status)
            self.can_update_list = status 
        end)
    end  
    --更新单个宝可梦信息
    if self.hero_resonate_crystal_put_in_event == nil then
        self.hero_resonate_crystal_put_in_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Resonate_Crystal_Update_One_Event, function(pos)
            self.can_update_list = true
            if pos and self.scroll_view then
                self.scroll_view:resetItemByIndex(pos)
            end
        end)
    end  

    if self.hero_resonate_power_event == nil then
        self.hero_resonate_power_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Resonate_Crystal_Power_Event, function(data)
            if not data then return end
            if self.show_left_power ~= nil then
                self.show_right_power = data.power
            end
        end)
    end  


    -- 选择宝可梦选择返回事件
    if self.select_hero_event == nil then
        self.select_hero_event = GlobalEvent:getInstance():Bind(HeroEvent.Select_Hero_Event, function(dic_cur_select_list, form_type)
            if not self.select_pos then return end
            if form_type  and form_type == HeroConst.SelectHeroType.eResonateCrystal then
                if dic_cur_select_list == nil or next(dic_cur_select_list) == nil then
                    return
                end
                for id,v in pairs(dic_cur_select_list) do
                    controller:sender26426(v.partner_id, self.select_pos)
                    break
                end
                self.select_pos = nil
            end
        end)
    end
end

function HeroResonateTabResonatePanel:showChangePower()
    if self.show_left_power and self.show_right_power then
        if (self.show_right_power - self.show_left_power) > 0 then
            GlobalMessageMgr:getInstance():showPowerMove( self.show_right_power - self.show_left_power, nil, self.show_left_power )
        end
        self.show_left_power = nil
        self.show_right_power = nil        
    end
end


function HeroResonateTabResonatePanel:onClickLevelUpBtn()
    if self.parent and self.parent.is_move_effect then return end
    if not self.scdata then return end
    if not model:isResonateCystalMaxLev() then
        return
    end
    if self.scdata.is_break == 1 then
        local setting = {}
        setting.left_lv = self.scdata.lev
        setting.right_lv = self.scdata.lev + 1

        local power = 0
        for i,v in ipairs(self.show_list) do
            if v.id ~= 0 then
                local hero_vo = model:getHeroById(v.id)
                if hero_vo then
                    power = power + hero_vo.power
                end
            end
        end
        setting.left_power = power
        self.show_left_power = power
        controller:openHeroResonateComfirmLevPanel(true, setting)
    else
        controller:sender26432()
    end
end

--支付类型 1 物品 2 钻石 后端定义的 根据 26429
function HeroResonateTabResonatePanel:onAddBtn(pay_type)
    if not self.scdata then return end
    if not self.open_pos_count then return end

    local cost_list = nil
    local cost_count = 0
    local config = nil
    if pay_type == 2 then 
        cost_count = self.scdata.gold_count or 0
        cost_count = cost_count + 1
        if cost_count <=0 then
            cost_count = 1
        end
        local config = Config.ResonateData.data_cell_cost[cost_count]
        if not config then return end
        cost_list = config.loss2    
    else 
        cost_count = self.scdata.item_count or 0
        cost_count = cost_count + 1
        if cost_count <=0 then
            cost_count = 1
        end
        local config = Config.ResonateData.data_cell_cost[cost_count]
        if not config then return end
        cost_list = config.loss1
    end
    if cost_list and next(cost_list[1]) ~= nil then 
        local bid = cost_list[1][1] or 0
        local num = cost_list[1][2] or 0
        local item_config = Config.ItemData.data_get_data(bid)
        local now_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
        if item_config then 
            
            local fun = function()
                if now_num < num and bid ~= Config.ItemData.data_assets_label2id.gold then
                    --不足 弹来源
                    BackpackController:getInstance():openTipsSource(true, item_config)
                    return
                end 
                if self.open_pos_count then
                    controller:sender26429(self.open_pos_count + 1, pay_type)
                end
            end

            local res = PathTool.getItemRes(item_config.icon)
            local str = string.format(TI18N("确定花费 <img src='%s' scale=0.3 /> %s解锁一个槽位吗？"),res,num)
            CommonAlert.show(str,TI18N("确定"),fun,TI18N("取消"),nil,CommonAlert.type.rich,nil,nil,24)
        end
    end
end

function HeroResonateTabResonatePanel:setData(parent)
    self.parent = parent
    self.is_init_hero = true
    if self.is_send_26400 then return end
    self.is_send_26400 = true
    controller:sender26425()
end

function HeroResonateTabResonatePanel:setScData(scdata)
    self.scdata = scdata

    if self.parent and self.is_checkResonateCystal == nil then
        self.is_checkResonateCystal = true
        self.parent:checkResonateCystal()
    end

    if model:isResonateCystalMaxLev() then
        self.level_up_panel:setVisible(true)
        if self.break_tips then
            self.break_tips:setVisible(false)
        end
        if self.scdata.is_break == 1 then
            -- self.lev:setString(string_format("<div fontcolor=#FFEECC outline=2,#422A1B>Lv.<div fontcolor=#4BFFE8 outline=2,#422A1B>%s</div>/%s</div>", self.scdata.lev, self.scdata.max_cystal_lev))
            
            if self.scdata.lev >= self.cystal_max_lev_limit then
                --说明满级了
                self.level_up_btn:setTouchEnabled(false)
                setChildUnEnabled(true, self.level_up_btn)
                for i,v in ipairs(self.cost_bg_list) do
                    v.cost_bg:setVisible(false)
                end
                self.level_up_btn_label:enableOutline(Config.ColorData.data_color4[2], 2)
                if self.break_tips1 == nil then
                    local break_tips1 = TI18N("水晶已达最高级")
                    self.break_tips1 = createLabel(24, cc.c3b(0x4B,0xFF,0xE8), nil, 360, 50, break_tips1, self.level_up_panel, 2, cc.p(0.5,0.5))
                end
            else
                self.level_up_btn_label:setString(TI18N("升 级"))
                for i,v in ipairs(self.cost_bg_list) do
                    v.cost_bg:setVisible(true)
                end
                self:updateCostInfo(self.scdata.lev)
            end
        else
            -- self.lev:setString(string_format("<div fontcolor=#FFEECC outline=2,#422A1B>Lv.%s</div>", self.scdata.lev))
            self.level_up_btn_label:setString(TI18N("突 破"))
            for i,v in ipairs(self.cost_bg_list) do
                v.cost_bg:setVisible(false)
            end
            if self.break_tips == nil then
                local break_tips = TI18N("突破后可提升水晶等级, 解锁宝可梦等级上限")
                self.break_tips = createLabel(24, cc.c3b(0x4B,0xFF,0xE8), nil, 360, 50, break_tips, self.level_up_panel, 2, cc.p(0.5,0.5))
            else
                self.break_tips:setVisible(true)
            end
        end
    else
        self.level_up_panel:setVisible(false)
        -- self.lev:setString(string_format("<div fontcolor=#FFEECC outline=2,#422A1B>Lv.%s</div>", self.scdata.lev))
    end 

    self.dic_hero_vo = {}
    for i,v in ipairs(scdata.con_list) do
        if v.id ~= 0 then
            local hero_vo = model:getHeroById(v.id)
            if hero_vo and next(hero_vo) ~= nil then
                table_insert(self.dic_hero_vo, hero_vo)
            end
        end
    end

    self.show_list = self.scdata.res_list
    table_sort(self.show_list, function(a,b) return a.pos < b.pos end)
    self.open_pos_count = #self.show_list
    local item_max_count
    if model:isResonateCystalMaxLev() then
        item_max_count = self.item_max_count + 5
        self.count_label:setString(string_format("%s/%s", self.open_pos_count, item_max_count))
    else
        item_max_count = self.item_max_count
        
        self.count_label:setString(string_format("%s/%s", self.open_pos_count, self.item_max_count))
    end
    if self.open_pos_count < item_max_count  then
        self.add_btn:setVisible(true)
    else
        self.add_btn:setVisible(false)
    end

    if self.can_update_list == true then
        self:updateScrollList()
    end
end

function HeroResonateTabResonatePanel:updateCostInfo(lev)

    local config = Config.ResonateData.data_crystal_cost[lev]
    if config and next(config.expend) ~= nil then
        for i=1,3 do
            local cost_data = config.expend[i]
            local cost_icon = self.cost_bg_list[i].cost_icon
            local cost_txt = self.cost_bg_list[i].cost_txt
            if cost_data then
                local bid = cost_data[1]
                local num = cost_data[2]
                local item_config = Config.ItemData.data_get_data(bid)
                if item_config then
                    cost_icon:loadTexture(PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
                    local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                    cost_txt:setString(MoneyTool.GetMoneyString(have_num) .. "/" .. MoneyTool.GetMoneyString(num))
                    if have_num >= num then
                        cost_txt:setTextColor(Config.ColorData.data_new_color4[6] )
                    else
                        cost_txt:setTextColor(Config.ColorData.data_new_color4[11])
                    end
                end
            else
                cost_txt:setString("")
            end
        end
    end
end

function HeroResonateTabResonatePanel:startTimeTicket()
    if self.timeticket == nil then
        self:countDownEndTime()
        self.timeticket = GlobalTimeTicket:getInstance():add(function()
            self:countDownEndTime()
        end, 1)
    end
end

function HeroResonateTabResonatePanel:countDownEndTime()
    if self.scroll_view then
         for i,v in pairs(self.scroll_view.activeCellIdx) do
            if v and self.time_desc_list[i] then
                self:updateTimeByIndex(i, self.time_desc_list[i])
            end
        end
    end
end

function HeroResonateTabResonatePanel:updateTimeByIndex(index, time_desc)
    -- body 
    local data = self.show_list[index]
    if data then
        if time_desc then
            local time = data.cool_time - GameNet:getInstance():getTime()
            if time < 0 then
                time = 0
                data.cool_time = 0
                self.scroll_view:resetItemByIndex(index)
                self.time_desc_list[index] = nil
                return
            end
            -- time_desc:setString(string_format("%s%s", TI18N("剩余"), TimeTool.getDayOrHour(time)))
            time_desc:setString(TimeTool.GetTimeFormat(time))
        end
    end
end

function HeroResonateTabResonatePanel:updateScrollList()
    if self.scroll_view == nil then
        local scroll_view_size = self.lay_scrollview:getContentSize()
        local list_setting = {
            start_x = 5,
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
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    if self.is_init_scroll_view == nil then
        self.is_init_scroll_view = true
        self.scroll_view:reloadData()
    else

        if self.record_count ~= self:numberOfCells() then
            self.scroll_view:reloadData()
        else
            self.scroll_view:resetCurrentItems()    
        end
        
    end
    self.record_count = self:numberOfCells()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroResonateTabResonatePanel:createNewCell(width, height)
    local cell = HeroExhibitionItem.new(0.9, true, 0, true,true)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function HeroResonateTabResonatePanel:numberOfCells()
    if not self.show_list then return self.item_max_count end
    local count = #self.show_list
    if model:isResonateCystalMaxLev() then
        if count <= (self.item_max_count + 5) then
            return (self.item_max_count + 5)
        else
            return count
        end
    else
        if count <= self.item_max_count then
            return self.item_max_count
        else
            return count
        end
    end
    
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function HeroResonateTabResonatePanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]

    cell:showResonateCrystalTime(false)
    self.time_desc_list[index] = nil

    if data and data.id ~= 0 then
        local hero_vo =  model:getHeroById(data.id)
        cell:setData(hero_vo)
        cell:showLockIcon(false)
        cell:showAddIcon(false)
    else
        cell:setData(nil)
        cell:showAddIcon(false)
        if index == (self.open_pos_count + 1) then
            cell:showLockIcon(true, "", {res = PathTool.getResFrame("common","common_90099")})
        elseif index > (self.open_pos_count + 1) then
            cell:showLockIcon(true, "", {res = PathTool.getResFrame("common","common_90009"), is_unenabled_bg = true})
        else
            cell:showLockIcon(false)

            if data and data.cool_time and data.cool_time > 0 then
                local time = data.cool_time - GameNet:getInstance():getTime()
                if time > 0 then
                    --显示时间
                    local time_str = TimeTool.GetTimeFormat(time)
                    self.time_desc_list[index] = cell:showResonateCrystalTime(true, time_str)
                    self:startTimeTicket()
                else
                    cell:showAddIcon(true)    
                end
            else
                cell:showAddIcon(true)
            end
        end
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function HeroResonateTabResonatePanel:onCellTouched(cell)
    if not cell.index then return end
    local index = cell.index
    local data = self.show_list[index]
    if data and data.id ~= 0 then
        local hero_vo =  model:getHeroById(data.id)
        local setting = {}
        setting.left_hero_vo = hero_vo
        setting.pos = index
        controller:openHeroResonatePutDownPanel(true, setting)
    else
        if index == (self.open_pos_count + 1) then
            --购买
            self:onAddBtn(1)
        elseif index > (self.open_pos_count + 1) then
            message(TI18N("需先解锁前面的槽位"))
        else
            if data and data.cool_time and data.cool_time ~= 0 then
                --显示时间
                local time = data.cool_time - GameNet:getInstance():getTime()
                if time > 0 then
                    self:refreshTime(index)
                else
                    self:onClickHeroBtn(index)
                end
            else
                self:onClickHeroBtn(index)
            end
        end
    end
end

function HeroResonateTabResonatePanel:refreshTime(index)
    local cell_flush_expend = {3,100}

    local config = Config.ResonateData.data_const.cell_flush_expend
    if config then
        cell_flush_expend = config.val
    end
    if cell_flush_expend and next(cell_flush_expend) ~= nil then 
        local bid = cell_flush_expend[1][1] or 0
        local num = cell_flush_expend[1][2] or 0
        local item_config = Config.ItemData.data_get_data(bid)
        if item_config then 
            local fun = function()
                controller:sender26428(index)
            end

            local res = PathTool.getItemRes(item_config.icon)
            local str = string.format(TI18N("是否花费<img src='%s' scale=0.3 />%s立即刷新冷却时间？"),res,num)
            CommonAlert.show(str,TI18N("确定"),fun,TI18N("取消"),nil,CommonAlert.type.rich,nil,nil,24)
        end
    end
end

function HeroResonateTabResonatePanel:onClickHeroBtn(pos)
    self.select_pos = pos
    local setting = {}
    setting.select_condition = {}
    setting.select_condition.star_start = 0
    setting.select_condition.camp_type = 0
    setting.select_condition.bid = 0
    setting.select_condition.max_lev = self.scdata.lev
    setting.select_count = 1
    setting.form_type = HeroConst.SelectHeroType.eResonateCrystal
    setting.dic_selected = {}

    setting.dic_filter_selected = {}
    if not model:isResonateCystalMaxLev() then
        if self.dic_hero_vo then
            for k,v in pairs(self.dic_hero_vo) do
                setting.dic_filter_selected[v.id] = v
            end
        end
    end
    if self.show_list then
        for k,v in ipairs(self.show_list) do
            if v.id ~= 0 then
                local hero_vo = model:getHeroById(v.id)
                if hero_vo then
                    setting.dic_filter_selected[v.id] = hero_vo
                end
            end
        end
    end
    controller:openHeroSelectHeroPanel(true, setting)
end

function HeroResonateTabResonatePanel:checkResonateStoneRedpoint(  )
    if model.is_resonate_stone_redpoint then
        addRedPointToNodeByStatus(self.level_up_btn, true, 5, 5)
    else
        addRedPointToNodeByStatus(self.level_up_btn, false, 5, 5)
    end
end

function HeroResonateTabResonatePanel:runShowAction(is_run)
    if is_run then
        -- if self.title_bg then
        --     local fadeOut = cc.FadeIn:create(0.8)
        --     local moveto = cc.MoveTo:create(0.8,cc.p(self.title_bg_x, 2000))
        --     local spawn_action = cc.Spawn:create(moveto, fadeOut)
        --     self.title_bg:runAction(spawn_action)
        -- end
        --移开的
        if self.bottom_panel then
            local fadeOut = cc.FadeIn:create(0.8)
            local moveto = cc.MoveTo:create(0.8,cc.p(self.bottom_panel_x, -1000))
            local spawn_action = cc.Spawn:create(moveto, fadeOut)
            self.bottom_panel:runAction(spawn_action)
        end
        -- if self.item_lay_list then
        --     for i,v in ipairs(self.item_lay_list) do
        --         self:runActionTo(v)
        --     end
        -- end
    else
        self.delayTime_param = self.parent.delayTime_param or 0.5
        -- if self.title_bg then
        --     self.title_bg:setPositionY(2000)
        --     local fadeIn = cc.FadeIn:create(0.65)
        --     local moveto = cc.MoveTo:create(0.65,cc.p(self.title_bg_x, self.title_bg_y))
        --     local spawn_action = cc.Spawn:create(moveto, fadeIn)
        --     self.title_bg:runAction(cc.Sequence:create(cc.DelayTime:create(self.delayTime_param), spawn_action))
        -- end
        if self.bottom_panel then
            self.bottom_panel:setPositionY(-1000)
            local fadeIn = cc.FadeIn:create(0.65)
            local moveto = cc.MoveTo:create(0.65,cc.p(self.bottom_panel_x, self.bottom_panel_y))
            local spawn_action = cc.Spawn:create(moveto, fadeIn)
            self.bottom_panel:runAction(cc.Sequence:create(cc.DelayTime:create(self.delayTime_param), spawn_action))
        end
        -- if self.item_lay_list then
        --     for i,v in ipairs(self.item_lay_list) do
        --         self:runActionBack(v)
        --     end
        -- end
    end
end

function HeroResonateTabResonatePanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

--移除
function HeroResonateTabResonatePanel:DeleteMe()
    if self.hero_resonate_info_event then
        GlobalEvent:getInstance():UnBind(self.hero_resonate_info_event)
        self.hero_resonate_info_event = nil
    end
    if self.hero_resonate_crystal_can_list_event then
        GlobalEvent:getInstance():UnBind(self.hero_resonate_crystal_can_list_event)
        self.hero_resonate_crystal_can_list_event = nil
    end
    if self.hero_resonate_crystal_put_in_event then
        GlobalEvent:getInstance():UnBind(self.hero_resonate_crystal_put_in_event)
        self.hero_resonate_crystal_put_in_event = nil
    end
    if self.hero_resonate_crystal_put_down_event then
        GlobalEvent:getInstance():UnBind(self.hero_resonate_crystal_put_down_event)
        self.hero_resonate_crystal_put_down_event = nil
    end
    if self.select_hero_event then
        GlobalEvent:getInstance():UnBind(self.select_hero_event)
        self.select_hero_event = nil
    end

    if self.timeticket then
        GlobalTimeTicket:getInstance():remove(self.timeticket)
        self.timeticket = nil
    end

    if role_vo then
        if self.role_lev_event then
            role_vo:UnBind(self.role_lev_event)
            self.role_lev_event = nil
        end
    end

    if self.item_lay_list then
        for i,v in ipairs(self.item_lay_list) do
            if v.add_spine then
                v.add_spine:clearTracks()
                v.add_spine:removeFromParent()
                v.add_spine = nil
            end
            if v.btn and v.btn.spine then
                v.btn.spine:removeFromParent()
                v.btn.spine = nil
            end
        end
    end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end

    doStopAllActions(self.main_container)
    doStopAllActions(self.bottom_panel)

end
