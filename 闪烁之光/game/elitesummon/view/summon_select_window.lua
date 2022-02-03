--------------------------------------------
-- @Author  : xhj
-- @Editor  : xhj
-- @Date    : 2020-03-5 15:12:43
-- @description    : 
		-- up英雄选择界面
---------------------------------
local _controller = EliteSummonController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert

SummonSelectWindow = SummonSelectWindow or BaseClass(BaseView)

function SummonSelectWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "elitesummon/summon_select_window"
	
	self.cur_item_id = nil
	self.select_cell = nil
	self.hero_data_list = {}
	
end

function SummonSelectWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")

	container:getChildByName("win_title"):setString(TI18N("英雄选择"))
	self.left_btn = container:getChildByName("left_btn")
	self.left_btn:getChildByName("label"):setString(TI18N("取 消"))
	self.right_btn = container:getChildByName("right_btn")
	self.right_btn:getChildByName("label"):setString(TI18N("确 定"))
	self.close_btn = container:getChildByName("close_btn")
	self.hero_info_panel = container:getChildByName("hero_info_panel")
	self.hero_info_panel:getChildByName("name_txt"):setString(TI18N("请在下面列表中选择一名英雄作为指定UP英雄"))
	
end

function SummonSelectWindow:register_event(  )	
	registerButtonEventListener(self.right_btn, handler(self, self.onClickChooseBtn), true)

	registerButtonEventListener(self.left_btn, function (  )
		self:onClickCloseBtn()
	end, true, 2)

	registerButtonEventListener(self.close_btn, function (  )
		self:onClickCloseBtn()
	end, true, 2)

	
	registerButtonEventListener(self.background, function ( )
		self:onClickCloseBtn()
	end, false, 2)
end

function SummonSelectWindow:onClickCloseBtn(  )
	_controller:openSummonSelectWindow(false)
end

function SummonSelectWindow:onClickChooseBtn(  )
	if next(self.hero_data_list) == nil then
		message(TI18N("没有可选择的英雄"))
		return
	end

	if self.cur_item_id == nil or self.cur_item_id <= 0 then
		message(TI18N("请选择UP英雄"))
		return 
	end

	_controller:send23233(self.cur_item_id)
	self:onClickCloseBtn()
end


function SummonSelectWindow:setData( )
	--需要获取已选择up英雄id
	local data = _model:getSelectSummonData()
	if not data then
		return
	end
	
	self.cur_item_id = data.lucky_bid

	self.hero_data_list = {}
	local temp_list = {}
    local config =  Config.RecruitHolidayLuckyData.data_wish[data.camp_id]
    if config then
        for k,v in pairs(config) do
            _table_insert( temp_list, {id = k,sort = v.sort})
        end
	end
	
	table.sort(temp_list, SortTools.KeyLowerSorter("sort"))

	for i,v in ipairs(temp_list) do
        _table_insert( self.hero_data_list, v.id)
    end
	
    self:updateList()
end

function SummonSelectWindow:openRootWnd()
	self:setData()
end

function SummonSelectWindow:updateList()
    if not self.hero_data_list then return end
    if self.hero_list_view == nil then
         local width = 120
        if #self.hero_data_list >= 6 then
            width = 110
        end
        self.hero_list = self.hero_info_panel:getChildByName("hero_list")
        local scroll_view_size = self.hero_list:getContentSize()
        local list_setting = {
            start_x = 0,
            space_x = 0,
            start_y = 0,
            space_y = 10,
            item_width = width,
            item_height = 175,
            row = 1,
            col = 5,
            need_dynamic = true
        }
        self.hero_list_view = CommonScrollViewSingleLayout.new(self.hero_list, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

        self.hero_list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.hero_list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.hero_list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.hero_list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    self.hero_list_view:reloadData()
end

function SummonSelectWindow:createNewCell( width, height )
    local cell = SummonSelectItem.new(width, height)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end

function SummonSelectWindow:numberOfCells(  )
    if not self.hero_data_list then return 0 end
    return #self.hero_data_list
end

function SummonSelectWindow:updateCellByIndex( cell, index )
    cell.index = index
    local item_vo = self.hero_data_list[index]
    if item_vo then
        cell:setData(item_vo, #self.hero_data_list)
        if self.cur_item_id and self.cur_item_id == item_vo then
            cell:IsGetStatus(true)
            self.select_cell = cell
        else
            cell:IsGetStatus(false)
        end
    end
end

function SummonSelectWindow:onCellTouched( cell )
    local isSelect = false
    local item_vo = self.hero_data_list[cell.index]
    if self.cur_item_id and item_vo and item_vo == self.cur_item_id then
        self.select_cell:IsGetStatus(true)
        return
    end

    if self.cur_item_id and self.select_cell then
        self.select_cell:IsGetStatus(false)
        self.select_cell = nil
        self.cur_item_id = nil
    end

    self.select_cell = cell
    self.select_cell:IsGetStatus(true)
    self.cur_item_id = item_vo
end



function SummonSelectWindow:close_callback(  )
	if self.hero_list_view then
		self.hero_list_view:DeleteMe()
		self.hero_list_view = nil
	end

	_controller:openSummonSelectWindow(false)
end


--------------------------@ item
SummonSelectItem = class("SummonSelectItem", function()
    return ccui.Widget:create()
end)

function SummonSelectItem:ctor(width, height)
	self:configUI(width, height)
	self:register_event()
end

function SummonSelectItem:configUI( width, height )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("elitesummon/summon_select_item"))
    self:setAnchorPoint(cc.p(0, 0))
    self:setContentSize(cc.size(width, height))
	self:setTouchEnabled(false)
    
	self:addChild(self.root_wnd)
	self.container = self.root_wnd:getChildByName("container")
	
	self.checkbox = self.container:getChildByName("checkbox")
    self.item_node = BackPackItem.new(false, true, false, 0.9, nil, nil, false)
    self.item_node:setPosition(cc.p(self:getContentSize().width*0.5, self:getContentSize().height*0.5+30))
    self.root_wnd:addChild(self.item_node)
end

function SummonSelectItem:register_event(  )	
	self.checkbox:addEventListener(function ( sender,event_type )
		if self.callback then
			self.callback()
		end
	end)
end


function SummonSelectItem:addCallBack( callback )
	self.callback = callback
	if self.item_node then
		self.item_node:addCallBack(callback)
	end
end

function SummonSelectItem:setData( data , total_len)
	if self.item_node then
		self.item_node:setBaseData(data, 1)
        if total_len and total_len >= 6 then
            self.item_node.scale = 0.8
            self.item_node:setScale(0.8)
        end
	end
end


function SummonSelectItem:IsGetStatus( status )
	if self.checkbox then
		self.checkbox:setSelected(status)
	end
end

function SummonSelectItem:DeleteMe(  )
	if self.item_node then
		self.item_node:DeleteMe()
		self.item_node = nil
	end
end