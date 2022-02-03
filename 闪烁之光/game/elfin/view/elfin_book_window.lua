--------------------------------------------
-- @Author  : htp--改版 xhj
-- @Editor  : htp
-- @Date    : 2019-08-17 16:10:48  --改版 2020-02-16
-- @description    : 
		-- 精灵图鉴
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format  = string.format

ElfinBookWindow = ElfinBookWindow or BaseClass(BaseView)

function ElfinBookWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "elfin/elfin_book_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("elfin", "elfin"), type = ResourcesType.plist}
    }

	self.cur_tab_data = {}
end

function ElfinBookWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
	
	container:getChildByName("win_title"):setString(TI18N("精灵图鉴"))
	self.have_txt = container:getChildByName("have_txt")
	self.have_txt:setString(TI18N("精灵满级效果预览"))
	self.btn_close = container:getChildByName("btn_close")

    local item_list = container:getChildByName("item_list")
    local scroll_view_size = item_list:getContentSize()
    local setting = {
        start_x = 13,                  -- 第一个单元的X起点
        space_x = 25,                    -- x方向的间隔
        start_y = 10,                    -- 第一个单元的Y起点
        space_y = 53,                   -- y方向的间隔
        item_width = BackPackItem.Width,               -- 单元的尺寸width
        item_height = BackPackItem.Height,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 4,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(item_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

  
end

function ElfinBookWindow:_createNewCell(  )
	local cell = BackPackItem.new(false, true, false)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end

function ElfinBookWindow:_numberOfCells(  )
	if not self.cur_tab_data then return 0 end
	return #self.cur_tab_data
end

function ElfinBookWindow:_updateCellByIndex( cell, index )
	cell.index = index
    local data = self.cur_tab_data[index]
    if data then
		cell:setData(data)
		cell:showItemQualityName(true)
    end
end

function ElfinBookWindow:onCellTouched( cell )
	local item_cfg = cell:getData()
	if item_cfg then
		_controller:openElfinInfoWindow(true, item_cfg)
	end
end

function ElfinBookWindow:updateCurTabData(  )
	
	self.cur_tab_data = {}
	local temp_step = 5
	local sprite_max_star_show = Config.SpriteData.data_const["sprite_max_star_show"]
	if sprite_max_star_show then
		temp_step = sprite_max_star_show.val
	end
	local config_list = Config.SpriteData.data_elfin_book[temp_step]
	for i,bid in ipairs(config_list) do
		local item_cfg = Config.ItemData.data_get_data(bid)
		if item_cfg then
			_table_insert(self.cur_tab_data, item_cfg)
		end
	end

	local function sortFunc( objA, objB )
		local a_activate = _model:checkElfinIsActivatedByBid(objA.id)
		local b_activate = _model:checkElfinIsActivatedByBid(objB.id)
		if a_activate and not b_activate then
			return true
		elseif not a_activate and b_activate then
			return false
		elseif objA.quality ~= objB.quality then
			return objA.quality > objB.quality
		else
			return objA.id < objB.id
		end
	end
	table.sort(self.cur_tab_data, sortFunc)

	self.item_scrollview:reloadData()
	
end

function ElfinBookWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openElfinBookWindow(false)
	end, false, 2)
	registerButtonEventListener(self.btn_close, function (  )
		_controller:openElfinBookWindow(false)
	end, true, 2)

end


function ElfinBookWindow:openRootWnd(  )
	self:updateCurTabData()
end

function ElfinBookWindow:close_callback(  )

	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	_controller:openElfinBookWindow(false)
end