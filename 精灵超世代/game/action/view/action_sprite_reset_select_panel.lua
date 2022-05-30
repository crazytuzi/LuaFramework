-- --------------------------------------------------------------------
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      选择重生精灵界面
-- <br/> 2020年1月3日
-- --------------------------------------------------------------------
ActionSpriteResetSelectPanel = ActionSpriteResetSelectPanel or BaseClass(BaseView)

local controller = ActionController:getInstance()
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local table_insert = table.insert


function ActionSpriteResetSelectPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "action/action_hero_reset_select_panel"

    self.res_list = {
        
    }

end

function ActionSpriteResetSelectPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N("精灵重生选择"))

    self.lay_scrollview = self.main_container:getChildByName("lay_scrollview")

    self.select_btn = self.main_container:getChildByName("select_btn")
    self.select_btn:getChildByName("label"):setString(TI18N("选 择"))

    self.close_btn = self.main_container:getChildByName("close_btn")
end

function ActionSpriteResetSelectPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self._onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.select_btn, handler(self, self._onClickBtnSelect) ,true, 2)

end

--关闭
function ActionSpriteResetSelectPanel:_onClickBtnClose()
    controller:openActionSpriteResetSelectPanel(false)
end

--选择
function ActionSpriteResetSelectPanel:_onClickBtnSelect()
    GlobalEvent:getInstance():Fire(ActionEvent.SPRITE_RESET_SELECT_EVENT, self.select_sprite_vo)
    self:_onClickBtnClose()
end

--@select_data 选择的数据
function ActionSpriteResetSelectPanel:openRootWnd(setting)
    local setting = setting or {}
    self.select_sprite_vo = setting.select_sprite_vo
    self.can_select_sprite_list = setting.can_select_sprite_list
    
    self:updateHeroList()   
end

--创建宝可梦列表 
function ActionSpriteResetSelectPanel:updateHeroList()
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

    -- 背包中所有的精灵
	local elfin_data = BackpackController:getInstance():getModel():getAllBackPackArray(BackPackConst.item_tab_type.ELFIN) or {}
	-- 古树中上阵的精灵
	local elfin_bid_list = _model:getElfinTreeElfinList()
	self.chose_elfin_list = deepCopy(elfin_bid_list)
	table.sort(self.chose_elfin_list, SortTools.KeyLowerSorter("pos"))
    self.sprite_list = {}
	local temp_list = deepCopy(elfin_data)
	for k,v in pairs(elfin_bid_list) do
		if v.item_bid and v.item_bid ~= 0 then
			local goodvo = GoodsVo.New(v.item_bid)
            goodvo.quantity = 1
            goodvo.is_lock = true
            table_insert(temp_list, goodvo)
		end
	end
    
    if self.can_select_sprite_list then
        for k,v in pairs(temp_list) do
            for j,vo in pairs(self.can_select_sprite_list) do
                if v.base_id == j then
                    table_insert(self.sprite_list, v)
                end
            end
        end
    else
        self.sprite_list = temp_list
    end
    
    if #self.sprite_list > 0 then
        local function sortFunc( objA, objB )
            if objA.eqm_jie ~= objB.eqm_jie then
                return objA.eqm_jie > objB.eqm_jie
            elseif objA.quality ~= objB.quality then
                return objA.quality > objB.quality
            else
                return objA.base_id > objB.base_id
            end
        end
        table.sort(self.sprite_list, sortFunc) 
        commonShowEmptyIcon(self.lay_scrollview, false)
    else
        commonShowEmptyIcon(self.lay_scrollview, true, {text = TI18N("暂无可重生精灵")})
    end

    self.list_view:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionSpriteResetSelectPanel:createNewCell(width, height)
    local cell = BackPackItem.new(false, true,false)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ActionSpriteResetSelectPanel:numberOfCells()
    if not self.sprite_list then return 0 end
    return #self.sprite_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function ActionSpriteResetSelectPanel:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.sprite_list[index]
    cell:setData(hero_vo) 
    if hero_vo then
        local is_lock = hero_vo.is_lock or false
        cell:showArtifactLock(is_lock)
        cell:setItemIconUnEnabled(is_lock)

        --设置选中状态 
        if self.select_sprite_vo and self.select_sprite_vo.id == hero_vo.id then
            cell:IsGetStatus(true)
            self.select_cell = cell
        else
            cell:IsGetStatus(false)
        end
    end

end

--点击cell .需要在 createNewCell 设置点击事件
function ActionSpriteResetSelectPanel:onCellTouched(cell)
    local index = cell.index
    local hero_vo = self.sprite_list[index]
    if hero_vo.is_lock == true then
        message(TI18N("上阵精灵无法重生"))
        return 
    end

    if self.select_cell then
        self.select_cell:IsGetStatus(false)
    end
    self.select_cell = cell

    if self.select_sprite_vo and self.select_sprite_vo.id  == hero_vo.id then
        self.select_sprite_vo = nil
        self.select_cell = nil
    else
        self.select_sprite_vo = hero_vo    
        if self.select_cell then
            self.select_cell:IsGetStatus(true)
        end
    end
end

function ActionSpriteResetSelectPanel:close_callback()
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end

    controller:openActionSpriteResetSelectPanel(false)
end