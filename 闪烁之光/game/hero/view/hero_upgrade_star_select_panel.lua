
-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      选择英雄界面
-- <br/> 2018年11月20日
-- --------------------------------------------------------------------
HeroUpgradeStarSelectPanel = HeroUpgradeStarSelectPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove

function HeroUpgradeStarSelectPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "hero/hero_upgrade_star_select_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("hero","txt_cn_hero_temp_01"), type = ResourcesType.single },
        -- { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3"), type = ResourcesType.single }
    }

end

function HeroUpgradeStarSelectPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 
    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N("请选择材料英雄"))

    self.label_select = self.main_container:getChildByName("label_select")
    
    self.label_tip = self.main_container:getChildByName("label_tip")
    self.label_tip:setString(TI18N("(100%返还材料英雄升级、进阶消耗的金币、经验和进阶石)"))

    self.lay_scrollview = self.main_container:getChildByName("lay_scrollview")

    self.select_btn = self.main_container:getChildByName("select_btn")
    self.select_btn_label = self.select_btn:getChildByName("label")
    self.select_btn_label:setString(TI18N("选 择"))

    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn_label = self.right_btn:getChildByName("label")
    self.right_btn_label:setString(TI18N("确 定"))
end

function HeroUpgradeStarSelectPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.select_btn, handler(self, self.onClickBtnSelect) ,true, 2)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickBtnRight) ,true, 2)

    self:addGlobalEvent(TipsEvent.TipsGoToEvent, function( )
        self:onClickBtnClose()
    end)
end

--关闭
function HeroUpgradeStarSelectPanel:onClickBtnClose()
    controller:openHeroUpgradeStarSelectPanel(false)
end

--选择
function HeroUpgradeStarSelectPanel:onClickBtnSelect()
    if not self.select_data then return end
    if self.select_data.star <= 4 then
        self:onKeySelect()
    else
        self:onClickBtnRight()
    end
end
--确定
function HeroUpgradeStarSelectPanel:onClickBtnRight()
    if not self.select_data then return end
    self.select_data.dic_select_list = self.dic_cur_select_list
    GlobalEvent:getInstance():Fire(HeroEvent.Upgrade_Star_Select_Event)
    self:onClickBtnClose()
end

--@select_data 选择的数据
--@select_data.is_ignore_hero_hun 是否忽略英雄魂(圣物用)
--@ dic_other_selected 其他已选的英雄数据 dic_other_selected[partner_id] = hero_vo 模式
--@ form_type --来源位置  1: 表示融合祭坛 2: 表示升星界面的 3:圣物 4:活动10星置换  参考 HeroConst.SelectHeroType 
--@ setting.is_master 是否是主卡(融合祭坛专用)
--@ setting.self_mark_bid 是否是本体的bid
--@ setting.is_
function HeroUpgradeStarSelectPanel:openRootWnd(select_data, dic_other_selected, form_type, setting)
    if not select_data then return end
    self.form_type = form_type or HeroConst.SelectHeroType.eStarFuse
    self.select_data = select_data

    local setting = setting or {}
    self.is_master = setting.is_master or false
    --本体bid
    self.self_mark_bid = setting.self_mark_bid
    --主卡判断信息
    if self.is_master then
        self.lock_type_list = {
            [1] = HeroConst.LockType.eHeroChangeLock, 
            -- [1] = HeroConst.LockType.eHeroLock, 
            -- [2] = HeroConst.LockType.eHeroResonateLock, 
        }
    end

    self.hero_list = {}
    --当前选择的
    self.dic_cur_select_list = {}

    self:initHeroList(dic_other_selected)

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
    self:updateSelectLabel() 

    --初始化按钮
    if self.main_container and self.select_data.star and self.select_data.star <= 4 then
        --小于等于4星的需要出现一键选取
        if self.select_btn_label then
            self.select_btn_label:setString(TI18N("一键选取"))
        end
        local size = self.main_container:getContentSize()
        self.select_btn:setPositionX(size.width * 0.2)
        self.right_btn:setVisible(true)
    end
end

function HeroUpgradeStarSelectPanel:checkSource()
    if not self.select_data then return end
    if self.select_data.bid == 0 then
        --随机卡 默认写死 没有来源 7星以上没有来源
        if self.select_data.star and self.select_data.star >= 7 then
            self.is_not_source = true  --表示没有来源
        end 
    else
        local key = getNorKey(self.select_data.bid, self.select_data.star)
        local star_config = Config.PartnerData.data_partner_star(key)    

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
end

--初始化英雄数据
--@ select_data的结构 参考 HeroUpgradeStarFuseWindow:getHeroData(bid, star, count, camp_type)
function HeroUpgradeStarSelectPanel:initHeroList(dic_other_selected)
    if not self.select_data then return end
    --别人已选
    local dic_other_selected = dic_other_selected or {}
    --自己已选
    local dic_select = self.select_data.dic_select_list
    --过滤
    local hero_array = model:getAllHeroArray()
    local size = hero_array:GetSize()

    if self.form_type == HeroConst.SelectHeroType.eTenConvert  then --10星置换活动的
        if self.select_data.hero_list then
            self.hero_list = self.select_data.hero_list
        else
            self.hero_list = {}
        end
        if dic_select then
            for k,hero_vo in pairs(dic_select) do
                self.dic_cur_select_list[hero_vo.id] = hero_vo
            end
        end
    elseif self.form_type == HeroConst.SelectHeroType.eResonate  then --共鸣选择
        for j=1, size do
            local hero_vo = hero_array:Get(j-1)
            if hero_vo and not hero_vo:isResonateHero() and  hero_vo.star >= self.select_data.star and dic_other_selected[hero_vo.id] == nil then
                if dic_select[hero_vo.id] then
                    self.dic_cur_select_list[hero_vo.id] = hero_vo
                else
                    table_insert(self.hero_list, hero_vo)
                end
            end
        end
    else
        if self.select_data.bid == 0 then
            --表示选择同阵营的随机卡
            for j=1, size do
                local hero_vo = hero_array:Get(j-1)
                if hero_vo  and not hero_vo:isResonateHero() and (self.select_data.camp_type == 0 or hero_vo.camp_type == self.select_data.camp_type) and
                    hero_vo.star == self.select_data.star and
                    dic_other_selected[hero_vo.id] == nil then
                    if dic_select[hero_vo.id] then
                        self.dic_cur_select_list[hero_vo.id] = hero_vo
                    end
                    table_insert(self.hero_list, hero_vo)
                end
            end
            --不忽略英雄魂
            if not self.select_data.is_ignore_hero_hun then
                -- 获取背包的英魂 BackpackController:getInstance():getModel()
                local list = BackpackController:getInstance():getModel():getHeroHunList()
                if self.item_list == nil then
                    self.item_list = {}
                end
                for _,v in pairs(list) do
                    if v.config and v.config.camp_type == self.select_data.camp_type and v.config.eqm_jie == self.select_data.star then
                        for i=1, v.quantity do
                            local hero_vo = {}
                            hero_vo.id = -(i + v.config.camp_type * 10)  --因为英雄id是正序的..这里就负序
                            hero_vo.partner_id = hero_vo.id
                            hero_vo.is_hero_hun = true
                            hero_vo.good_vo = v
                            if dic_select[hero_vo.id] then
                                self.dic_cur_select_list[hero_vo.id] = hero_vo
                            end
                            table_insert(self.item_list, hero_vo)
                        end
                    end
                end
            end
        else
            --表示指定卡
            for j=1, size do
                local hero_vo = hero_array:Get(j-1)
                if hero_vo  and not hero_vo:isResonateHero() and hero_vo.bid == self.select_data.bid and
                    hero_vo.star == self.select_data.star and
                    dic_other_selected[hero_vo.id] == nil then
                    if dic_select[hero_vo.id] then
                        self.dic_cur_select_list[hero_vo.id] = hero_vo
                    end
                    table_insert(self.hero_list, hero_vo)
                end
            end
        end
    end
end

function HeroUpgradeStarSelectPanel:updateSelectLabel()
    if not self.label_select then return end
    if not self.select_data then return end
    local count = 0
    for k,v in pairs(self.dic_cur_select_list) do
        count = count + 1
    end
    self.label_select:setString(string_format("%s:%s/%s", TI18N("已选择"), count, self.select_data.count))
end

--创建英雄列表 
function HeroUpgradeStarSelectPanel:updateHeroList()
    if self.list_view == nil then
        if tolua.isnull(self.lay_scrollview) then return end
        local scroll_view_size = cc.size(640,250)
        local list_setting = {
            start_x = 0,
            space_x = 0,
            start_y = 5,
            space_y = 0,
            item_width = 128,
            item_height = 140,
            row = 0,
            col = 5,
            need_dynamic = true
        }
        local size = self.lay_scrollview:getContentSize()
        self.list_view = CommonScrollViewSingleLayout.new(self.lay_scrollview, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end


    local sort_func = function(a, b)
        local a_is_lock, b_is_lock
        if self.is_master then
            a_is_lock = a.is_lock or 0
            b_is_lock = b.is_lock or 0
        else
            if a:checkHeroLockTips(true, nil, true) then
                a_is_lock = 1 
            else
                a_is_lock = 0 
            end
            if b:checkHeroLockTips(true, nil, true) then
                b_is_lock = 1 
            else
                b_is_lock = 0 
            end
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
    table.sort(self.hero_list, sort_func)
    if self.item_list then
        for i,v in ipairs(self.item_list) do
            table_insert(self.hero_list, 1, v)
        end
    end 

    if self.form_type == HeroConst.SelectHeroType.eResonate  then --共鸣选择
        for i,v in pairs(self.dic_cur_select_list) do
            table_insert(self.hero_list, 1, v)
        end
    end


    self.list_view:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroUpgradeStarSelectPanel:createNewCell(width, height)
    local cell = HeroExhibitionItem.new(0.9, true)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function HeroUpgradeStarSelectPanel:numberOfCells()
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
function HeroUpgradeStarSelectPanel:updateCellByIndex(cell, index)
    cell.index = index
    local x, y = cell:getPosition()
    cell:setPosition(x, y + 10)
    local hero_vo = self.hero_list[index]
    if hero_vo then
        if hero_vo.is_hero_hun then
            cell:setData(hero_vo) 
            if hero_vo.good_vo.config then
                cell:setQualityImg(hero_vo.good_vo.config.eqm_jie - 1)
                cell:setDefaultHead(hero_vo.good_vo.config.icon)
                cell.star_setting = cell:createStar(hero_vo.good_vo.config.eqm_jie, cell.star_con, cell.star_setting) 
                cell:setCampImg(hero_vo.good_vo.config.camp_type)
                cell:setHeroName(true, hero_vo.good_vo.config.name)
            end
            cell:setLev(nil)  
            cell:showLockIcon(false)
            cell:showSelfMarkImg(false)
        else
            cell:setData(hero_vo)
            cell:setHeroName(true, hero_vo.name)
            --锁定 或者 在布阵中 要锁定 data.isLock and data:isLock() o
            local is_lock = false
            if self.is_master then
                -- is_lock = hero_vo:isLock()
                if hero_vo:checkHeroLockTips(false, self.lock_type_list, true) then
                    is_lock = true
                else
                    is_lock = false
                end
            else
                if self.form_type == HeroConst.SelectHeroType.eResonate  then --共鸣选择
                    if self.select_data and self.select_data.dic_select_list[hero_vo.id] then
                        is_lock = false
                    else
                        is_lock = hero_vo:isLock() or (hero_vo.isInForm and hero_vo:isInForm()) 
                    end
                else
                    is_lock = hero_vo:isLock() or (hero_vo.isInForm and hero_vo:isInForm()) 
                end
            end
            cell:showLockIcon(is_lock)
            if cell.showSelfMarkImg then
                if not self.dic_cur_select_list[hero_vo.id] and self.self_mark_bid and self.self_mark_bid == hero_vo.bid then
                    cell:showSelfMarkImg(true)
                else
                    cell:showSelfMarkImg(false)
                end
            end
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
        cell:setHeroName(false)
        cell:setSelected(false)
    end

end

--点击cell .需要在 createNewCell 设置点击事件
function HeroUpgradeStarSelectPanel:onCellTouched(cell)
    local index = cell.index
    local hero_vo = self.hero_list[index]
    if hero_vo then
        self:selectHero(cell, hero_vo)
    else
        local item_id 
        if self.select_data.bid == 0 then
            item_id = model:getSourceHeroCombinationByCampStar(self.select_data.camp_type, self.select_data.star)
        else
            if self.source_config then
                --先从升星表读..
                BackpackController:getInstance():openTipsOnlySource(true, self.source_config)
                return 
            end
            -- 如果没有在从item表读
            local partner_config = Config.PartnerData.data_partner_base[self.select_data.bid] or {}
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

function HeroUpgradeStarSelectPanel:selectHero(cell, hero_vo)
    if not hero_vo  then return end
    if not cell then return end

    if not hero_vo.is_hero_hun then
        if self.is_master then
            if hero_vo:checkHeroLockTips(false, self.lock_type_list) then
                return 
            end
        else
            if self.form_type == HeroConst.SelectHeroType.eResonate  then --共鸣选择
                if self.select_data and self.select_data.dic_select_list[hero_vo.id] == nil then
                    if hero_vo:checkHeroLockTips(true) then
                        return 
                    end
                end
             else
                if hero_vo:checkHeroLockTips(true) then
                    return 
                end
            end
        end
    end
    if self.form_type ==  HeroConst.SelectHeroType.eResonate  then --共鸣选择
        
    end

    --打开英雄信息ui
    if self.dic_cur_select_list[hero_vo.id] then
        cell:setSelected(false)
        self.dic_cur_select_list[hero_vo.id] = nil  
    else
        local count = 0
        for k,v in pairs(self.dic_cur_select_list) do
            count = count + 1
        end
        if count >= self.select_data.count then
            message(TI18N("选择数量已满"))
            return
        end

        if self.form_type == HeroConst.SelectHeroType.eTenConvert then --10星置换活动的 多一个要求
            local selectd_hero_vo
            for k,vo in pairs(self.dic_cur_select_list) do
                selectd_hero_vo = vo
                break
            end
            --选择的和已选择的 bid不一样的不满足条件
            if selectd_hero_vo and hero_vo.bid ~= selectd_hero_vo.bid then
                message(TI18N("无法选择不一样的材料英雄"))
                return
            end
        end

        self.dic_cur_select_list[hero_vo.id] = hero_vo
        cell:setSelected(true)
    end
    if cell.showSelfMarkImg then
        if not self.dic_cur_select_list[hero_vo.id] and self.self_mark_bid and self.self_mark_bid == hero_vo.bid then
            cell:showSelfMarkImg(true)
        else
            cell:showSelfMarkImg(false)
        end
    end

    if self.form_type ==  HeroConst.SelectHeroType.eResonate  then --共鸣选择
        if self.select_data and self.select_data.dic_select_list[hero_vo.id] then
            local is_have = false
            for select_id,_ in pairs(self.select_data.dic_select_list) do
                for cur_id ,__ in pairs(self.dic_cur_select_list) do
                    if cur_id == select_id then
                        is_have = true
                        break
                    end
                end
            end
            if is_have then
                self.select_btn_label:setString(TI18N("取消选择"))
            else
                self.select_btn_label:setString(TI18N("选 择"))
            end
        end
    end

    self:updateSelectLabel()
end

--一键选择
function HeroUpgradeStarSelectPanel:onKeySelect()
    if not self.select_data then return end
    local count = 0
    for k,v in pairs(self.dic_cur_select_list) do
        count = count + 1
    end
    if count >= self.select_data.count then
        return
    end
    local must_refresh = false
    local select_count = self.select_data.count - count
    for i,hero_vo in ipairs(self.hero_list) do
        if select_count > 0 and self:checkSelect(hero_vo) and self.dic_cur_select_list[hero_vo.id] == nil then
            self.dic_cur_select_list[hero_vo.id] = hero_vo
            must_refresh = true
            select_count = select_count - 1
            if select_count == 0 then
                break
            end
        end
    end
    if must_refresh then
        if self.list_view then
            self.list_view:resetCurrentItems()
        end
        self:updateSelectLabel()
    end
end

function HeroUpgradeStarSelectPanel:checkSelect(hero_vo)
    if not hero_vo then return false end
    if not hero_vo.is_hero_hun then
        if self.is_master then
            if hero_vo:checkHeroLockTips(false, self.lock_type_list, true) then
                return false
            end
        else
            if self.form_type == HeroConst.SelectHeroType.eResonate  then --共鸣选择
                if self.select_data and self.select_data.dic_select_list[hero_vo.id] == nil then
                    if hero_vo:checkHeroLockTips(true, nil, true) then
                        return false
                    end
                end
             else
                if hero_vo:checkHeroLockTips(true, nil, true) then
                    return false
                end
            end
        end
    end
    return true
end

function HeroUpgradeStarSelectPanel:close_callback()
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end

    controller:openHeroUpgradeStarSelectPanel(false)
end