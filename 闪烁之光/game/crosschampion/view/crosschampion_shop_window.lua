--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-07-26 10:14:36
-- @description    : 
		-- 跨服冠军赛商店
---------------------------------
local _controller = CrosschampionController:getInstance()
local _model = _controller:getModel()

CrosschampionShopWindow = CrosschampionShopWindow or BaseClass(BaseView)

function CrosschampionShopWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "crosschampion/crosschampion_shop_window"

    self.role_vo = RoleController:getInstance():getRoleVo()
    self.show_list = {}
end

function CrosschampionShopWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
	self.container = container
    self:playEnterAnimatianByObj(container, 2)

	local win_title = container:getChildByName("win_title")
	win_title:setString(TI18N("冠军商店"))

	self.close_btn = container:getChildByName("close_btn")

	self.list_panel = container:getChildByName("list_panel")
	self.res_label = container:getChildByName("res_label")

	local setting = {
        start_x = 0, -- 第一个单元的X起点
        space_x = 0, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 2, -- y方向的间隔
        item_width = 306, -- 单元的尺寸width
        item_height = 143, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 2                         -- 列数，作用于垂直滚动类
    }
    self.item_scroll_view = CommonScrollViewSingleLayout.new(self.list_panel, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, cc.size(self.list_panel:getContentSize().width, self.list_panel:getContentSize().height), setting, cc.p(0, 0))

	self.item_scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
	self.item_scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
	self.item_scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

function CrosschampionShopWindow:register_event(  )
	registerButtonEventListener(self.close_btn, function (  )
		_controller:openCrosschampionShopWindow(false)
	end, true, 2)

	registerButtonEventListener(self.background, function (  )
		_controller:openCrosschampionShopWindow(false)
	end, false, 2)

	self:addGlobalEvent(MallEvent.Open_View_Event, function ( data )
		if data.type == MallConst.MallType.CrosschampionShop then
            local list = self:getConfig(data)
            self.show_list =list
            self.item_scroll_view:reloadData()
        end
	end)

    if not self.role_lev_event and self.role_vo then
        self.role_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
            if key and key == "cluster_guess_cent" then 
                self:updateResNum()
            end
        end)
    end
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function CrosschampionShopWindow:createNewCell()
    local cell = MallItem.new()
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end

--获取数据数量
function CrosschampionShopWindow:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function CrosschampionShopWindow:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    cell:setData(data)
end


--点击cell .需要在 createNewCell 设置点击事件
function CrosschampionShopWindow:onCellTouched(cell)
    MallController:getInstance():openMallBuyWindow(true, cell:getData())
end

function CrosschampionShopWindow:getConfig(data)
    local item_list = {}
    local config = Config.ExchangeData.data_shop_exchage_crosschampion
    if config then
        local list = deepCopy(data.item_list)
        for a, j in pairs(config) do
            if list and next(list or {}) ~= nil  then
                for k, v in pairs(list) do --已经买过的限购物品
                    if j.id == v.item_id then
                        if v.ext[1].val then --不管是什么限购 赋值已购买次数就好了。。
                            j.has_buy = v.ext[1].val
                            table.remove(list, k)
                        end
                        break
                    else
                        j.has_buy = 0
                    end
                end
            else
                j.has_buy = 0
            end
            table.insert(item_list, j)
        end
    end
    table.sort(item_list ,function (a,b)
        if a.limit_count and a.limit_count > 0 and a.has_buy >= a.limit_count and (not b.limit_count or b.limit_count == 0 or b.has_buy < b.limit_count) then
            return false
        elseif b.limit_count and b.limit_count > 0 and b.has_buy >= b.limit_count and (not a.limit_count or a.limit_count == 0 or a.has_buy < a.limit_count) then
            return true
        else
            return  a.order < b.order
        end
    end)
    return item_list
end

function CrosschampionShopWindow:updateResNum(  )
	if self.role_vo then
        self.res_label:setString(self.role_vo.cluster_guess_cent)
    end
end

function CrosschampionShopWindow:openRootWnd(  )
	MallController:getInstance():sender13401(MallConst.MallType.CrosschampionShop)
	self:updateResNum()
end

function CrosschampionShopWindow:close_callback(  )
	if self.item_scroll_view then
        self.item_scroll_view:DeleteMe()
        self.item_scroll_view = nil
    end
    if self.role_lev_event and self.role_vo then
        self.role_vo:UnBind(self.role_lev_event)
        self.role_lev_event = nil
    end
	_controller:openCrosschampionShopWindow(false)
end