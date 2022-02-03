-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      选择重生英雄界面
-- <br/> 2019年6月24日
-- --------------------------------------------------------------------
ActionHeroResetSelectPanel = ActionHeroResetSelectPanel or BaseClass(BaseView)

local controller = ActionController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove

function ActionHeroResetSelectPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.is_hero_return = false -- 是否常驻英雄回退功能调用
    self.layout_name = "action/action_hero_reset_select_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3"), type = ResourcesType.single }
    }

end

function ActionHeroResetSelectPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N("重生英雄选择"))

    self.lay_scrollview = self.main_container:getChildByName("lay_scrollview")

    self.select_btn = self.main_container:getChildByName("select_btn")
    self.select_btn:getChildByName("label"):setString(TI18N("确 定"))

    self.close_btn = self.main_container:getChildByName("close_btn")
end

function ActionHeroResetSelectPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self._onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.select_btn, handler(self, self._onClickBtnSelect) ,true, 2)

end

--关闭
function ActionHeroResetSelectPanel:_onClickBtnClose()
    controller:openActionHeroResetSelectPanel(false)
end

--选择
function ActionHeroResetSelectPanel:_onClickBtnSelect()
    if self.is_hero_return == true then
        GlobalEvent:getInstance():Fire(HeroEvent.HERO_RETURN_SELECT_EVENT, self.select_hero_vo)
    else
        GlobalEvent:getInstance():Fire(ActionEvent.HERO_RESET_SELECT_EVENT, self.select_hero_vo)
    end
    self:_onClickBtnClose()
end

--@select_data 选择的数据
function ActionHeroResetSelectPanel:openRootWnd(setting)
    local setting = setting or {}
    self.select_hero_vo = setting.select_hero_vo
    if setting.is_hero_return ~= nil then
        self.is_hero_return = setting.is_hero_return
    end
    
    self:updateHeroList()   
end

--创建英雄列表 
function ActionHeroResetSelectPanel:updateHeroList()
    if self.list_view == nil then
        if tolua.isnull(self.lay_scrollview) then return end
        local scroll_view_size = self.lay_scrollview:getContentSize()
        local list_setting = {
            start_x = 0,
            space_x = 0,
            start_y = 4,
            space_y = 0,
            item_width = 148,
            item_height = 130,
            row = 0,
            col = 4,
            need_dynamic = true
        }
        self.list_view = CommonScrollViewSingleLayout.new(self.lay_scrollview, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    self.hero_list = {}
    if self.is_hero_return == true then--英雄常驻回退功能
        self.title:setString(TI18N("回退英雄选择"))
        local config = Config.PartnerData.data_partner_const.return_condition
        local dic_condition = {}
        if config then
            for i,v in ipairs(config.val) do
                if dic_condition[v] == nil then
                    dic_condition[v] = true
                end
            end
        end
        local hero_list = HeroController:getInstance():getModel():getHeroList() or {}
        for k,v in pairs(hero_list) do
            if dic_condition[v.star] then
                table_insert(self.hero_list, v)
            end
        end
    else--活动英雄重生
        local config = Config.PartnerData.data_partner_const.reborn_condition
        local dic_condition = {}
        if config then
            for i,v in ipairs(config.val) do
                if dic_condition[v[1]] == nil then
                    dic_condition[v[1]] = {}
                end
                dic_condition[v[1]][v[2]] = true
            end
        end
        local hero_list = HeroController:getInstance():getModel():getHeroList() or {}
        for k,v in pairs(hero_list) do
            if dic_condition[v.bid] and dic_condition[v.bid][v.star] then
                table_insert(self.hero_list, v)
            end
        end
    end
    



    local sort_func = SortTools.tableLowerSorter({"camp_type", "star", "bid"})
    table.sort(self.hero_list, sort_func) 

    self.list_view:reloadData()

    if #self.hero_list == 0 then 
        local tips = TI18N("暂无可重生英雄")
        if self.is_hero_return == true then
            tips = TI18N("暂无可回退英雄")
        end
        commonShowEmptyIcon(self.lay_scrollview, true, {text = tips})
    else
        commonShowEmptyIcon(self.lay_scrollview, false)
    end 
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionHeroResetSelectPanel:createNewCell(width, height)
    local cell = HeroExhibitionItem.new(1, true)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ActionHeroResetSelectPanel:numberOfCells()
    if not self.hero_list then return 0 end
    return #self.hero_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function ActionHeroResetSelectPanel:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.hero_list[index]
    cell:setData(hero_vo) 
    if hero_vo then
        -- cell:setData(hero_vo)
        local is_lock = hero_vo:isLock() or  (hero_vo.isInForm and hero_vo:isInForm()) or hero_vo:isResonateHero()
        cell:showLockIcon(is_lock)

        --设置选中状态 
        if self.select_hero_vo and self.select_hero_vo.partner_id == hero_vo.partner_id then
            cell:setSelected(true)
            self.select_cell = cell
        else
            cell:setSelected(false)
        end
    end

end

--点击cell .需要在 createNewCell 设置点击事件
function ActionHeroResetSelectPanel:onCellTouched(cell)
    local index = cell.index
    local hero_vo = self.hero_list[index]
    if hero_vo:checkHeroLockTips(true) then
        return 
    end

    if hero_vo:isResonateHero() == true then
        message(TI18N("赋能英雄无法回退"))
        return
    end

    if self.select_cell then
        self.select_cell:setSelected(false)
    end
    self.select_cell = cell

    if self.select_hero_vo and self.select_hero_vo.partner_id  == hero_vo.partner_id then
        self.select_hero_vo = nil
        self.select_cell = nil
    else
        self.select_hero_vo = hero_vo    
        if self.select_cell then
            self.select_cell:setSelected(true)
        end
    end
end

function ActionHeroResetSelectPanel:close_callback()
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end

    controller:openActionHeroResetSelectPanel(false)
end