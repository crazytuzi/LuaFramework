-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      选择英雄界面
-- <br/> 2018年11月20日
-- --------------------------------------------------------------------
HeroSelectHeroPanel = HeroSelectHeroPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove

function HeroSelectHeroPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Tips   
    self.is_full_screen = false
    self.layout_name = "hero/hero_select_hero_panel"

    self.res_list = {

    }

end

function HeroSelectHeroPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 
    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N("请选择英雄"))

    self.lay_scrollview = self.main_container:getChildByName("lay_scrollview")

    self.cancel_btn = self.main_container:getChildByName("cancel_btn")
    self.cancel_btn_label = self.cancel_btn:getChildByName("label")
    self.cancel_btn_label:setString(TI18N("取 消"))

    self.common_btn = self.main_container:getChildByName("common_btn")
    self.common_btn_label = self.common_btn:getChildByName("label")
    self.common_btn_label:setString(TI18N("确 定"))

    -- self.tips_label = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,0.5),cc.p(40, 530),nil,nil,1900)
    -- self.main_container:addChild(self.tips_label)
    self.close_btn = self.main_container:getChildByName("close_btn")
end

function HeroSelectHeroPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self._onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.cancel_btn, handler(self, self._onClickBtnCancel) ,true, 2)
    registerButtonEventListener(self.common_btn, handler(self, self._onClickBtnComfirm) ,true, 2)

    self:addGlobalEvent(TipsEvent.TipsGoToEvent, function( )
        self:_onClickBtnClose()
    end)
end

--关闭
function HeroSelectHeroPanel:_onClickBtnClose()
    controller:openHeroSelectHeroPanel(false)
end

--选择
function HeroSelectHeroPanel:_onClickBtnCancel()
    self:_onClickBtnClose()
end
--选择
function HeroSelectHeroPanel:_onClickBtnComfirm()
    if not self.dic_cur_select_list then return end
    GlobalEvent:getInstance():Fire(HeroEvent.Select_Hero_Event, self.dic_cur_select_list, self.form_type)
    self:_onClickBtnClose()
end

--setting.select_condition 选择条件 
--setting.select_condition.star 表示过滤星级    注意: 和star_start, star_end 互斥 优先 star的
--setting.select_condition.star_start 表示过滤开始
--setting.select_condition.star_end 表示过滤结束
--setting.select_condition.max_lev 表示过来比此等级高的

--setting.select_condition.camp_type 阵营  0表示搜友阵营
--setting.select_condition.bid  英雄id  0 或者 nil 表示无
--setting.dic_selected 已选 结构 [id] = hero_vo
--setting.dic_filter_selected 需过滤的选择 结构 [id] = hero_vo
--setting.select_count 选择数量  默认 1个
--setting.form_type 来自那里的选择类型 如果有特殊就写.没有就用通用的
function HeroSelectHeroPanel:openRootWnd(setting)
    local setting = setting or {}

    self.select_condition = setting.select_condition or {}
    self.dic_selected = setting.dic_selected or {}
    self.dic_filter_selected = setting.dic_filter_selected or {}

    self.select_count = setting.select_count or 1
    self.form_type = setting.form_type or 0
    local tips = setting.tips or ""
    self.hero_list = {}
    --当前选择的
    self.dic_cur_select_list = {}

    self:initHeroList()

    self.is_not_source = false

    self.source_config = self:checkSource()
    if self.is_not_source then
        --如果没有显示来源  没有数据就默认空空如也
        local item_list = self.item_list or {}
        if #self.hero_list == 0 and #item_list == 0 then
            commonShowEmptyIcon(self.lay_scrollview, true, {font_size = 22,scale = 1, text = TI18N("空空如也")})
            return 
        end
    end
    self:updateHeroList()

    -- self.tips_label:setString(tips)
end

function HeroSelectHeroPanel:checkSource()
    local bid = self.select_condition.bid or 0
    local star = self.select_condition.star 
    local star_start = self.select_condition.star_start or 0
    if bid == 0 then    
        --随机卡 默认写死 没有来源 7星以上没有来源
        if (star and star >= 7) or star_start > 7 then
            self.is_not_source = true  --表示没有来源
        end 
    else
        local check_star_source = function(bid, star)
            local key = getNorKey(bid, star)
            local star_config = Config.PartnerData.data_partner_star(key)    
            if not star_config then 
                self.is_not_source = true
                return 
            end
            if star_config.source[1] == nil then --表示读item表
                
            else
                if type(star_config.source[1]) == "number" then
                    if star_config.source[1] == 1 then
                        self.is_not_source = true --表示没有来源
                    end
                elseif type(star_config.source[1]) == "table" then
                    --说明有来源 读这里的..
                    return star_config
                end
            end
        end
        if star then
            return check_star_source(bid, star)
        else
            local star_end = self.select_condition.star_end or 0
            if star_start == 0 and star_end == 0 then
                --说明没有设星级 拿最低级的
                local config = Config.PartnerData.data_partner_base(bid)
                if config then
                    star_start = config.init_star
                    star_end = config.init_star
                    self.select_condition.star_start = star_start
                    self.select_condition.star_end = star_start
                else
                    self.is_not_source = true
                    return 
                end
            end
            return check_star_source(bid, star_start)
        end
    end
end

--初始化英雄数据
function HeroSelectHeroPanel:initHeroList()
    --别人已选
    local dic_filter_selected = self.dic_filter_selected or {}
    --自己已选
    local dic_selected = self.dic_selected or {}
    --过滤
    local hero_array = model:getAllHeroArray()
    local size = hero_array:GetSize()

    local bid = self.select_condition.bid or 0
    local temp_list = {}
    if bid == 0 then
        local camp_type = self.select_condition.camp_type or 0
        for j=1, size do
            local hero_vo = hero_array:Get(j-1)
            if hero_vo and not hero_vo:isResonateHero() and (camp_type == 0 or hero_vo.camp_type == camp_type) and dic_filter_selected[hero_vo.id] == nil then
                if self.select_count == 1  then --单选
                    if dic_selected[hero_vo.id] then
                        self.dic_cur_select_list[hero_vo.id] = hero_vo
                    else
                        table_insert(temp_list, hero_vo)
                    end
                else
                    if dic_selected[hero_vo.id] then
                        self.dic_cur_select_list[hero_vo.id] = hero_vo
                    end
                    table_insert(temp_list, hero_vo)
                end
            end
        end
    else
        for j=1, size do
            local hero_vo = hero_array:Get(j-1)
            if hero_vo and not hero_vo:isResonateHero() and hero_vo.bid == bid and dic_filter_selected[hero_vo.id] == nil then
                if self.select_count == 1  then --单选
                    if dic_selected[hero_vo.id] then
                        self.dic_cur_select_list[hero_vo.id] = hero_vo
                    else
                        table_insert(temp_list, hero_vo)
                    end
                else
                    if dic_selected[hero_vo.id] then
                        self.dic_cur_select_list[hero_vo.id] = hero_vo
                    end
                    table_insert(temp_list, hero_vo)
                end
            end
        end
    end
    if #temp_list > 0 then
        --星级计算
        local star = self.select_condition.star
        if star then
            for i,hero_vo in ipairs(temp_list) do
                if star ==  hero_vo.star then
                   table_insert(self.hero_list, hero_vo) 
                end
            end
        else
            local star_start = self.select_condition.star_start or 0
            local star_end = self.select_condition.star_end or 1000
            for i,hero_vo in ipairs(temp_list) do
                if hero_vo and hero_vo.star >= star_start and hero_vo.star <= star_end   then
                   table_insert(self.hero_list, hero_vo) 
                end
            end
        end
    end

    if self.form_type == HeroConst.SelectHeroType.eResonateEmpowerment then --共鸣赋能
        --共鸣赋能 规定可升至该星级的英雄才可被选择 不懂问策划 星宇
        local temp_list = self.hero_list
        local star_end = self.select_condition.star_end or 0
        self.hero_list = {}
        local config_max_star = Config.PartnerData.data_partner_max_star
        if config_max_star then
            for i,hero_vo in ipairs(temp_list) do
                if config_max_star[hero_vo.bid] and config_max_star[hero_vo.bid] >= star_end and hero_vo.star < star_end then
                    table_insert(self.hero_list, hero_vo) 
                end
            end
        end
    end
    local max_lev = self.select_condition.max_lev
    if max_lev then
        temp_list = self.hero_list
        self.hero_list = {}
        for i,hero_vo in ipairs(temp_list) do
            if hero_vo.lev <= max_lev  then
                table_insert(self.hero_list, hero_vo) 
            end
        end
    end

end

--排序信息
function HeroSelectHeroPanel:getSortFun(a, b)
    if self.form_type == HeroConst.SelectHeroType.eResonateEmpowerment or --共鸣赋能
        self.form_type == HeroConst.SelectHeroType.eResonateCrystal or --共鸣水晶
        self.form_type == HeroConst.SelectHeroType.eResonateStone then --共鸣圣阵
        if a.lev == b.lev then
            if a.star == b.star then
                if a.camp_type == b.camp_type then
                    return a.sort_order < b.sort_order
                else
                    return a.camp_type < b.camp_type
                end
            else
                return a.star > b.star
            end
        else
            return a.lev > b.lev
        end
    else
        local a_is_lock, b_is_lock
        if a.isInForm and a:isInForm() then
            a_is_lock = 1
        else
            a_is_lock = a.is_lock
        end 
        if b.isInForm and b:isInForm() then
            b_is_lock = 1
        else
            b_is_lock = b.is_lock
        end 
        if a_is_lock == b_is_lock then
            if a.lev == b.lev then
                return a.sort_order < b.sort_order
            else
                return a.lev > b.lev
            end
        else
            return a_is_lock < b_is_lock
        end
    end
end


--创建英雄列表 
function HeroSelectHeroPanel:updateHeroList()
    if self.list_view == nil then
        if tolua.isnull(self.lay_scrollview) then return end
        local scroll_view_size = self.lay_scrollview:getContentSize()
        local list_setting = {
            start_x = 0,
            space_x = 0,
            start_y = 4,
            space_y = 0,
            item_width = 140,
            item_height = 130,
            row = 0,
            col = 4,
            need_dynamic = true
        }
        self.list_view = CommonScrollViewSingleLayout.new(self.lay_scrollview, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end

    table.sort(self.hero_list, function(a, b) return self:getSortFun(a, b) end)

    if self.select_count == 1  then --单选
        self.is_select = false
        for i,v in pairs(self.dic_cur_select_list) do
            self.is_select = true
            table_insert(self.hero_list, 1, v)
        end

        if self.form_type == HeroConst.SelectHeroType.eResonateStone then
            for i,v in pairs(self.dic_filter_selected) do
                table_insert(self.hero_list, v)
            end
        end

        if self.is_select then
            self.list_view:reloadData(1)
        else
            self.list_view:reloadData()
        end
    else
        self.list_view:reloadData()
    end

end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroSelectHeroPanel:createNewCell(width, height)
    local cell = HeroExhibitionItem.new(1, true)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function HeroSelectHeroPanel:numberOfCells()
    if self.is_not_source then
        --没有来源
        return #self.hero_list
    else
        -- + 1 的那个是最后的加号 
        return #self.hero_list + 1
    end
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function HeroSelectHeroPanel:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.hero_list[index]
    
    if hero_vo then
        if hero_vo.is_hero_hun then --保留的 目前没有用
            cell:setData(hero_vo) 
            if hero_vo.good_vo.config then
                cell:setQualityImg(hero_vo.good_vo.config.eqm_jie - 1)
                cell:setDefaultHead(hero_vo.good_vo.config.icon)
                cell.star_setting = cell:createStar(hero_vo.good_vo.config.eqm_jie, cell.star_con, cell.star_setting) 
                cell:setCampImg(hero_vo.good_vo.config.camp_type)
            end
            cell:setLev(nil)  
            cell:showLockIcon(false)  
        else
            cell:setData(hero_vo)
            --锁定 或者 在布阵中 要锁定 data.isLock and data:isLock() o
            local is_lock = false
            
            if self.select_count == 1  then --单选
                if self.dic_selected and self.dic_selected[hero_vo.id] then
                    is_lock = false
                else
                    if self.form_type == HeroConst.SelectHeroType.eResonateStone then
                        if self.dic_filter_selected[hero_vo.id] then
                            is_lock = true
                        else
                            is_lock = false
                        end
                    elseif self.form_type == HeroConst.SelectHeroType.eResonateEmpowerment then
                        is_lock = false
                    elseif self.form_type == HeroConst.SelectHeroType.eResonateCrystal then
                        is_lock = false
                    else
                        is_lock = hero_vo:isLock() or (hero_vo.isInForm and hero_vo:isInForm())   
                    end
                end
            else
                is_lock = hero_vo:isLock() or (hero_vo.isInForm and hero_vo:isInForm())
            end
            cell:showLockIcon(is_lock)  
        end
        --设置选中状态 
        if self.dic_cur_select_list[hero_vo.id] then
            cell:setSelected(true)
        else
            cell:setSelected(false)
        end
        cell:showAddIcon(false)
    else
        cell:setData(nil) 
        --空表示最后的加号
        cell:showAddIcon(true)
    end

end

--点击cell .需要在 createNewCell 设置点击事件
function HeroSelectHeroPanel:onCellTouched(cell)
    local index = cell.index
    local hero_vo = self.hero_list[index]
    if hero_vo then
        self:selectHero(cell, hero_vo)
    else
        if not self.select_condition then return end
        local item_id 
        if self.select_condition.bid == 0 then
            if self.select_condition.star  then
                item_id = model:getSourceHeroCombinationByCampStar(self.select_condition.camp_type, self.select_condition.star)
            else
                local star_start = self.select_condition.star_start or 0
                item_id = model:getSourceHeroCombinationByCampStar(self.select_condition.camp_type, self.select_condition.star)
            end
        else
            if self.source_config then
                --先从升星表读..
                BackpackController:getInstance():openTipsOnlySource(true, self.source_config)
                return 
            end
            -- 如果没有在从item表读
            local partner_config = Config.PartnerData.data_partner_base[self.select_condition.bid] or {}
            item_id = partner_config.item_id
        end
        if item_id then 
            local config = Config.ItemData.data_get_data(item_id)
            if config then
                BackpackController:getInstance():openTipsOnlySource(true, config)
            end
        end
    end
end

function HeroSelectHeroPanel:selectHero(cell, hero_vo)
    if not hero_vo  then return end
    if not cell then return end

    if self.select_count == 1  then --单选
        if self.dic_selected and self.dic_selected[hero_vo.id] == nil then
            local is_check = false
            if self.form_type == HeroConst.SelectHeroType.eResonateStone then
                if self.dic_filter_selected[hero_vo.id] then
                    is_check = false
                    message(TI18N("该英雄已在晶碑的其他阵位中"))
                    return
                end
            elseif self.form_type == HeroConst.SelectHeroType.eResonateEmpowerment then
                is_check = false
            elseif self.form_type == HeroConst.SelectHeroType.eResonateCrystal then
                is_check = false
            else
                is_check = true
            end
            if is_check then
                if hero_vo:checkHeroLockTips(true) then
                    return 
                end
            end
        end
     else
        if hero_vo:checkHeroLockTips(true) then
            return 
        end
    end
    
    if self.select_count == 1  then --单选
        --如果是单选.选把已选的去掉
        if self.single_select_cell then
            self.single_select_cell:setSelected(false)
        end

        if not self.is_select and self.dic_cur_select_list[hero_vo.id] then
            --保险
            cell:setSelected(false)
            self.dic_cur_select_list[hero_vo.id] = nil
        else
            self.single_select_cell = cell
            if self.single_select_cell then
                self.single_select_cell:setSelected(true)
            end   
            self.dic_cur_select_list = {}
            self.dic_cur_select_list[hero_vo.id] = hero_vo 
            self.is_select = false
        end
        
        -- if self.dic_selected and self.dic_selected[hero_vo.id] then
        --     self.common_btn_label:setString(TI18N("取消选择"))
        -- else
        --     self.common_btn_label:setString(TI18N("选 择"))
        -- end    
    else
        --多选
        if self.dic_cur_select_list[hero_vo.id] then
            cell:setSelected(false)
            self.dic_cur_select_list[hero_vo.id] = nil  
        else
            local count = 0
            for k,v in pairs(self.dic_cur_select_list) do
                count = count + 1
            end
            if count >= self.select_count then
                message(TI18N("选择数量已满"))
                return
            end

            self.dic_cur_select_list[hero_vo.id] = hero_vo
            cell:setSelected(true)
        end
    end
end

function HeroSelectHeroPanel:close_callback()
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end

    controller:openHeroSelectHeroPanel(false)
end