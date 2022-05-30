-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: htp(必填, 创建模块的人员)
-- @editor: htp(必填, 后续维护以及修改的人员)
-- @description:
--      充值商城
-- <br/>Create: 2019-11-11
-- --------------------------------------------------------------------
local _controller = MallController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _table_sort = table.sort
local _tab_color_1 = cc.c4b(255,234,117,255)
local _tab_color_2 = cc.c4b(255,248,210,255)

ChargeShopWindow = ChargeShopWindow or BaseClass(BaseView)

function ChargeShopWindow:__init()
	self.is_full_screen = true
    self.win_type = WinType.Full    
    self.layout_name = "mall/charge_shop_window" 

    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("mall_charge", "mall_charge"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/mall","charge_bg_1", true), type = ResourcesType.single},
    }
    
    self.panel_list = {}
end

function ChargeShopWindow:open_callback( )
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
    	self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/mall","charge_bg_1", true), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
    end
    
    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 1) 

    self.image_bg = main_container:getChildByName("image_bg")
    self.close_btn = main_container:getChildByName("close_btn")

    self.sub_panel = main_container:getChildByName("sub_panel")

    -- 一级菜单按钮
    self.tab_btn_panel = main_container:getChildByName("tab_btn_panel")
    local scroll_view_size = self.tab_btn_panel:getContentSize()
	local setting = {
        start_x = 10,                  -- 第一个单元的X起点
        space_x = 3,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 175,               -- 单元的尺寸width
        item_height = 108,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.btn_scrollview = CommonScrollViewSingleLayout.new(self.tab_btn_panel, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.btn_scrollview:setSwallowTouches(false)

    self.btn_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell)
    self.btn_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells)
	self.btn_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex)
    self.btn_scrollview:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched)

    -- 二级菜单按钮
    self.sub_tab_btn_panel = main_container:getChildByName("sub_tab_btn_panel")
    local sub_scroll_size = self.sub_tab_btn_panel:getContentSize()
	local setting = {
        start_x = 50,                  -- 第一个单元的X起点
        space_x = 40,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 105,               -- 单元的尺寸width
        item_height = 125,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.sub_btn_scrollview = CommonScrollViewSingleLayout.new(self.sub_tab_btn_panel, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, sub_scroll_size, setting)
    self.sub_btn_scrollview:setSwallowTouches(false)

    self.sub_btn_scrollview:registerScriptHandlerSingle(handler(self, self.createSubNewCell), ScrollViewFuncType.CreateNewCell)
    self.sub_btn_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfSubCells), ScrollViewFuncType.NumberOfCells)
	self.sub_btn_scrollview:registerScriptHandlerSingle(handler(self, self.updateSubCellByIndex), ScrollViewFuncType.UpdateCellByIndex)
    self.sub_btn_scrollview:registerScriptHandlerSingle(handler(self,self.onSubCellTouched), ScrollViewFuncType.OnCellTouched)

    -- 适配
    local line_1 = main_container:getChildByName("line_1")
    local line_2 = main_container:getChildByName("line_2")
    MainuiController:getInstance():setIsShowMainUIBottom(false) -- 隐藏底部UI
    local top_off = display.getTop(main_container)
    local bottom_off = display.getBottom(main_container)
    local safe_width, safe_height = display.getScreenWH()
    self.offset_y = top_off - bottom_off - SCREEN_HEIGHT -- 屏幕高度差
    self.image_bg:setPositionY(top_off-59)
    self.close_btn:setPositionY(bottom_off+95)
    line_1:setPositionY(bottom_off+130)
    line_2:setPositionY(bottom_off+130)
    self.sub_panel:setPositionY(top_off-151)
    self.tab_btn_panel:setPositionY(bottom_off+10)
    self.sub_tab_btn_panel:setPositionY(bottom_off+142)

    if MAKELIFEBETTER == true then
        self.sub_tab_btn_panel:setVisible(false)
        self.tab_btn_panel:setVisible(false)
    end
end

function ChargeShopWindow:createNewCell(  )
    local cell = ChargeTabBtn.new()
    cell:addClickCallBack(function() self:onCellTouched(cell) end)
	return cell
end

function ChargeShopWindow:numberOfCells(  )
    if not self.tab_btn_data then return 0 end
    return #self.tab_btn_data
end

function ChargeShopWindow:updateCellByIndex( cell, index )
    if not self.tab_btn_data then return end
    cell.index = index
    local cell_data = self.tab_btn_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

-- 点击一级菜单
function ChargeShopWindow:onCellTouched( cell )
    if not cell or not cell.index then return end
    if self.cur_btn_index and self.cur_btn_index == cell.index then return end
    if not cell.config then -- 可能还没有数据就回调了
        local cell_data = self.tab_btn_data[cell.index]
        if cell_data then
            cell:setData(cell_data)
        end
    end
    if not cell.config then return end

    if self.cur_tab_btn then
        self.cur_tab_btn:setIsSelect(false)
    end
    cell:setIsSelect(true)
    self.cur_tab_btn = cell
    self.cur_btn_index = cell.index
    self.cur_sub_btn_index = nil

    -- 特权商城点击过红点就消失
    if cell.config.id == MallConst.Charge_Shop_Type.Privilege and VipController:getInstance():getGiftRedStatusById(VIPREDPOINT.PRIVILEGE) then
        VipController:getInstance():setTipsGiftStatus(VIPREDPOINT.PRIVILEGE, false)
    end

    -- 是否有二级菜单
    if cell.config.subtype and next(cell.config.subtype) ~= nil then
        self.sub_tab_btn_panel:setVisible(true)
        self:updateSubBtnList(cell.config.id, cell.config.subtype)
    else
        self.sub_tab_btn_panel:setVisible(false)
        self:showShopPanelById(cell.config.id)
    end
    -- 提审服
    if MAKELIFEBETTER == true then
        self.sub_tab_btn_panel:setVisible(false)
    end
end

-- 根据商店id显示对应商店的 panel
function ChargeShopWindow:showShopPanelById( id )
    if not id then return end
    if self.cur_panel_shop_id and self.cur_panel_shop_id == id then return end

    if self.cur_panel then
        self.cur_panel:setVisibleStatus(false)
    end

    self.cur_panel_shop_id = id
    if not self.panel_list[id] then
        if id == MallConst.Charge_Shop_Type.Diamond then -- 钻石商城
            self.panel_list[id] = ChargeDiamondPanel.New(self.sub_panel, self.offset_y)
        elseif id == MallConst.Charge_Shop_Type.Dialy then -- 每日礼包
            self.panel_list[id] = ChargeDialyPanel.New(self.sub_panel, self.offset_y)
        elseif id == MallConst.Charge_Shop_Type.Weekly then -- 每周限购
            self.panel_list[id] = ChargeWeeklyPanel.New(self.sub_panel, self.offset_y)
        elseif id == MallConst.Charge_Shop_Type.Monthly then -- 月度限量
            self.panel_list[id] = ChargeMonthlyPanel.New(self.sub_panel, self.offset_y)
        elseif id == MallConst.Charge_Shop_Type.Privilege then -- 特权商城
            self.panel_list[id] = ChargePrivilegePanel.New(self.sub_panel, self.offset_y)
        elseif id == MallConst.Charge_Shop_Type.Time then -- 限时礼包
            self.panel_list[id] = ChargeTimePanel.New(self.sub_panel, self.offset_y)
        elseif id == MallConst.Charge_Shop_Type.Cloth then -- 神装礼包
            self.panel_list[id] = ChargeClothPanel.New(self.sub_panel, self.offset_y)
        end
    end
    self.cur_panel = self.panel_list[id]
    if self.cur_panel then
        self.cur_panel:setVisibleStatus(true)
    end
    self:updateShopBgById()
end

-- 根据商城类型显示不同的背景资源
function ChargeShopWindow:updateShopBgById(  )
    if not self.cur_panel_shop_id then return end
    local shop_cfg = Config.ChargeMallData.data_charge_shop[self.cur_panel_shop_id]
    if shop_cfg and shop_cfg.bg_id ~= "" then
        local res_path = PathTool.getPlistImgForDownLoad("bigbg/mall", shop_cfg.bg_id)
        local function loadCallBack(  )
            self.image_bg:setCapInsets(cc.rect(100, 450, 1, 40))
            self.image_bg:setContentSize(cc.size(705, 1130+self.offset_y))
        end
        self.image_bg_load = loadImageTextureFromCDN(self.image_bg, res_path, ResourcesType.single, self.image_bg_load, nil, loadCallBack)
    end
end

-- 更新二级标签页显示(id 为一级标签页id)
function ChargeShopWindow:updateSubBtnList( id, sub_data )
    if self.cur_sub_btn_id and self.cur_sub_btn_id == id then
        if self.cur_sub_panel_id then -- 选中上一次打开的二级标签页
            self:showShopPanelById(self.cur_sub_panel_id)
        end
        return
    end

    self.cur_sub_btn_id = id -- 当前显示的二级标签的商店id，避免重复刷新
    self.sub_tab_btn_data = {}
    for _,id in pairs(sub_data) do
        local cfg = Config.ChargeMallData.data_charge_shop[id]
        if cfg and self:checkShopIsOpen(cfg.id) then
            local data = {}
            data.config = cfg
            data.is_show_red = false
            if cfg.id == MallConst.Charge_Shop_Type.Diamond then -- vip礼包
                data.is_show_red = VipController:getInstance():getVipRedStatus() or false
            elseif cfg.id == MallConst.Charge_Shop_Type.Dialy then -- 每日礼包
                data.is_show_red = VipController:getInstance():getGiftRedStatusById(VIPREDPOINT.DAILY_AWARD) or false
            elseif data.config.id == MallConst.Charge_Shop_Type.Weekly then -- 周礼包
                data.is_show_red = _model:getMallRedStateByBid(MallConst.Red_Index.Weekly) or false
            elseif data.config.id == MallConst.Charge_Shop_Type.Monthly then -- 月礼包
                data.is_show_red = _model:getMallRedStateByBid(MallConst.Red_Index.Monthly) or false
            elseif data.config.id == MallConst.Charge_Shop_Type.Cloth then -- 自选礼包
                data.is_show_red = _model:getMallRedStateByBid(MallConst.Red_Index.Chose) or false
            end
            _table_insert(self.sub_tab_btn_data, data)
        end
    end
    local function sortFunc( objA, objB )
        return objA.config.sort < objB.config.sort
    end
    _table_sort(self.sub_tab_btn_data, sortFunc)

    local index = 1
    if self.default_sub_type then
        for k,sub_data in pairs(self.sub_tab_btn_data) do
            if sub_data.config.id == self.default_sub_type then
                index = k
                break
            end
        end
        self.default_sub_type = nil
    end
    self.sub_btn_scrollview:reloadData(index)
end

function ChargeShopWindow:createSubNewCell(  )
    local cell = ChargeSubTabBtn.new()
    cell:addCallBack(function() self:onSubCellTouched(cell) end)
	return cell
end

function ChargeShopWindow:numberOfSubCells(  )
    if not self.sub_tab_btn_data then return 0 end
    return #self.sub_tab_btn_data
end

function ChargeShopWindow:updateSubCellByIndex( cell, index )
    if not self.sub_tab_btn_data then return end
    cell.index = index
    local cell_data = self.sub_tab_btn_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

-- 点击二级标签页
function ChargeShopWindow:onSubCellTouched( cell )
    if not cell or not cell.config then return end
    if self.cur_sub_btn_index and self.cur_sub_btn_index == cell.index then return end

    if self.cur_sub_tab_btn then
        self.cur_sub_tab_btn:setIsSelect(false)
    end
    cell:setIsSelect(true)
    self.cur_sub_tab_btn = cell
    self.cur_sub_btn_index = cell.index
    self.cur_sub_panel_id = cell.config.id -- 这里记录一下当前显示的二级标签页id
    
    self:showShopPanelById(cell.config.id)
end

function ChargeShopWindow:register_event( )
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)

    -- 已开启的商店列表
    self:addGlobalEvent(MallEvent.Get_Open_Charge_Shop_Event, function ( data )
        if data and data.open_id and next(data.open_id) ~= nil then
            self:updateShopBtnList(data.open_id)
        end
    end)

    self:addGlobalEvent(VipEvent.Update_Gift_Red_state, function (  )
        self:updateBtnRedStatus()
    end)

    self:addGlobalEvent(MallEvent.Update_Mall_Red_Event, function (  )
        self:updateBtnRedStatus()
    end)
end

function ChargeShopWindow:onClickCloseBtn(  )
    _controller:openChargeShopWindow(false)
end

-- 更新红点
function ChargeShopWindow:updateBtnRedStatus(  )
    local vip_controll = VipController:getInstance()
    if self.tab_btn_data then
        for k,data in pairs(self.tab_btn_data) do
            data.is_show_red = false
            if data.config.id == MallConst.Charge_Shop_Type.Normal then -- 常规礼包中包含每日礼包、周礼包、月礼包的红点
                data.is_show_red = vip_controll:getGiftRedStatusById(VIPREDPOINT.DAILY_AWARD) or vip_controll:getVipRedStatus() or _model:getMallRedStateByBid(MallConst.Red_Index.Weekly) or _model:getMallRedStateByBid(MallConst.Red_Index.Monthly) or false
            elseif data.config.id == MallConst.Charge_Shop_Type.Value then  -- 超值礼包中的自选礼包要显示红点
                data.is_show_red = _model:getMallRedStateByBid(MallConst.Red_Index.Chose) or false
            elseif data.config.id == MallConst.Charge_Shop_Type.Privilege then  -- 特权礼包
                data.is_show_red = vip_controll:getGiftRedStatusById(VIPREDPOINT.PRIVILEGE) or false
            end
        end
        self.btn_scrollview:reloadData()
    end

    if self.sub_tab_btn_data then
        for k,data in pairs(self.sub_tab_btn_data) do
            data.is_show_red = false
            if data.config.id == MallConst.Charge_Shop_Type.Dialy then -- 每日礼包
                data.is_show_red = vip_controll:getGiftRedStatusById(VIPREDPOINT.DAILY_AWARD) or false
            elseif data.config.id == MallConst.Charge_Shop_Type.Diamond then -- vip
                data.is_show_red = vip_controll:getVipRedStatus() or false
            elseif data.config.id == MallConst.Charge_Shop_Type.Weekly then -- 周礼包
                data.is_show_red = _model:getMallRedStateByBid(MallConst.Red_Index.Weekly) or false
            elseif data.config.id == MallConst.Charge_Shop_Type.Monthly then -- 月礼包
                data.is_show_red = _model:getMallRedStateByBid(MallConst.Red_Index.Monthly) or false
            elseif data.config.id == MallConst.Charge_Shop_Type.Cloth then -- 自选礼包
                data.is_show_red = _model:getMallRedStateByBid(MallConst.Red_Index.Chose) or false
            end
        end
        self.sub_btn_scrollview:reloadData()
    end
end

-- 更新已开启的商店列表
function ChargeShopWindow:updateShopBtnList( open_list )
    self.open_shop_list = open_list
    if self.temp_sub_type then
        self.default_tab_type = nil
        self.default_sub_type = nil

        local role_vo = RoleController:getInstance():getRoleVo()
        if self.temp_sub_type == MallConst.Charge_Shop_Type.Diamond and role_vo then
            -- 如果打开的是钻石商店，则根据VIP等级判断默认选中哪个商店
            local vip_lev = role_vo.vip_lev
            if vip_lev == 0 then -- vip等级为0打开钻石商城
                self.default_tab_type = MallConst.Charge_Shop_Type.Normal
                self.default_sub_type = MallConst.Charge_Shop_Type.Diamond
            elseif vip_lev < 3 then -- vip等级小于3打开特权商店
                self.default_tab_type = MallConst.Charge_Shop_Type.Privilege
            else -- vip等级大于等于3打开月度限量
                self.default_tab_type = MallConst.Charge_Shop_Type.Normal
                if self:checkShopIsOpen(MallConst.Charge_Shop_Type.Monthly) then
                    self.default_sub_type = MallConst.Charge_Shop_Type.Monthly
                else
                    self.default_sub_type = MallConst.Charge_Shop_Type.Diamond
                end
            end
        else
            for _,cfg in pairs(Config.ChargeMallData.data_charge_shop) do
                if next(cfg.subtype) ~= nil then
                    for k,id in pairs(cfg.subtype) do
                        if id == self.temp_sub_type then
                            self.default_tab_type = cfg.id
                            self.default_sub_type = self.temp_sub_type
                            break
                        end
                    end
                elseif cfg.id == self.temp_sub_type and not self.default_sub_type then
                    self.default_tab_type = self.temp_sub_type
                end
            end
        end

        -- 这种状态下默认进入常规商店的钻石商城
        if MAKELIFEBETTER then
            self.default_tab_type = MallConst.Charge_Shop_Type.Normal
            self.default_sub_type = MallConst.Charge_Shop_Type.Diamond
        end
        self:updateTabBtnList(1)
        self.temp_sub_type = nil
    end
end

-- 根据商店id判断是否开启
function ChargeShopWindow:checkShopIsOpen( id )
    local is_open = false
    for _,v in pairs(self.open_shop_list or {}) do
        if v.id == id then
            is_open = true
            break
        end
    end
    return is_open
end

function ChargeShopWindow:openRootWnd( sub_type )
    self.temp_sub_type = sub_type or MallConst.Charge_Shop_Type.Normal
    _controller:sender21022() -- 请求已开启的礼包商城列表
end

function ChargeShopWindow:updateTabBtnList( index )
    if not self.tab_btn_data then
        self.tab_btn_data = {}
        for k,cfg in pairs(Config.ChargeMallData.data_charge_shop) do
            if cfg.first_tab == 1 and self:checkShopIsOpen(cfg.id) then
                local data = {}
                data.config = cfg
                data.is_show_red = false
                local vip_controll = VipController:getInstance()
                if cfg.id == MallConst.Charge_Shop_Type.Normal then -- 常规礼包中包含每日礼包
                    data.is_show_red = vip_controll:getGiftRedStatusById(VIPREDPOINT.DAILY_AWARD) or vip_controll:getVipRedStatus() or _model:getMallRedStateByBid(MallConst.Red_Index.Weekly) or _model:getMallRedStateByBid(MallConst.Red_Index.Monthly) or false
                elseif cfg.id == MallConst.Charge_Shop_Type.Value then  -- 超值礼包中的自选礼包要显示红点
                    data.is_show_red = _model:getMallRedStateByBid(MallConst.Red_Index.Chose) or false
                elseif cfg.id == MallConst.Charge_Shop_Type.Privilege then  -- 特权礼包
                    data.is_show_red = vip_controll:getGiftRedStatusById(VIPREDPOINT.PRIVILEGE) or false
                end
                _table_insert(self.tab_btn_data, data)
            end
        end
        local function sortFunc( objA, objB )
            return objA.config.sort < objB.config.sort
        end
        _table_sort(self.tab_btn_data, sortFunc)
    end

    for k,data in pairs(self.tab_btn_data) do
        if self.default_tab_type and self.default_tab_type == data.config.id then
            index = k
        end
    end
    self.btn_scrollview:reloadData(index)
    self.default_tab_type = nil
end

function ChargeShopWindow:close_callback( )
    if self.btn_scrollview then
        self.btn_scrollview:DeleteMe()
        self.btn_scrollview = nil
    end
    if self.sub_btn_scrollview then
        self.sub_btn_scrollview:DeleteMe()
        self.sub_btn_scrollview = nil
    end
    if self.image_bg_load then
        self.image_bg_load:DeleteMe()
        self.image_bg_load = nil
    end
    for _,panel in pairs(self.panel_list) do
        panel:DeleteMe()
        panel = nil
    end
    self.panel_list = {}
    MainuiController:getInstance():setIsShowMainUIBottom(true) -- 隐藏底部UI
    _controller:openChargeShopWindow(false)
end

---------------------@ 一级标签页 start
ChargeTabBtn = class('ChargeTabBtn',function()
    return ccui.Layout:create()
end)

function ChargeTabBtn:ctor()
    self:configUI()
    self:registerEvent()
end

function ChargeTabBtn:configUI()
    self.size = cc.size(175, 107)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("mall/charge_tab_btn")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.normal_sp = self.container:getChildByName("normal_sp")
    self.normal_icon_sp = self.normal_sp:getChildByName("icon")
    self.select_sp = self.container:getChildByName("select_sp")
    self.select_sp:setVisible(false)
    self.select_icon_sp = self.select_sp:getChildByName("icon")
    self.name_txt = self.container:getChildByName("name_txt")
end

function ChargeTabBtn:registerEvent()
    registerButtonEventListener(self.container, handler(self, self.onClickItem), false)
end

function ChargeTabBtn:onClickItem(  )
    if self.clickCallBack then
        self.clickCallBack(self)
    end
end

function ChargeTabBtn:addClickCallBack( callback )
    self.clickCallBack = callback
end

function ChargeTabBtn:setIsSelect( status )
    self.normal_sp:setVisible(not status)
    self.select_sp:setVisible(status)
    if status == true then
        self.name_txt:setTextColor(_tab_color_1)
    else
        self.name_txt:setTextColor(_tab_color_2)
    end
end

function ChargeTabBtn:setData(data)
    if not data then return end

    self.config = data.config or {}

    -- 图标
    if self.config.res_id and self.config.res_id ~= "" then
        local normal_res = PathTool.getResFrame("mall_charge", self.config.res_id .. "_s")
        local select_res = PathTool.getResFrame("mall_charge", self.config.res_id)
        loadSpriteTexture(self.normal_icon_sp, normal_res, LOADTEXT_TYPE_PLIST)
        loadSpriteTexture(self.select_icon_sp, select_res, LOADTEXT_TYPE_PLIST)
    end

    -- 名称
    self.name_txt:setString(self.config.name or "")

    -- 红点
    addRedPointToNodeByStatus(self, data.is_show_red)
end

function ChargeTabBtn:DeleteMe()
    self:removeAllChildren()
	self:removeFromParent()
end

---------------------@ 一级标签页 end

---------------------@ 二级标签页 start
ChargeSubTabBtn = class('ChargeSubTabBtn',function()
    return ccui.Layout:create()
end)

function ChargeSubTabBtn:ctor()
    self:configUI()
    self:registerEvent()
end

function ChargeSubTabBtn:configUI()
    self.size = cc.size(105, 125)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("mall/charge_sub_tab_btn")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.normal_img = self.container:getChildByName("normal_img")
    self.select_img = self.container:getChildByName("select_img")
    self.icon_sp = self.container:getChildByName("icon_sp")
    self.name_txt = self.container:getChildByName("name_txt")

    self:setIsSelect(false)
end

function ChargeSubTabBtn:registerEvent()
    registerButtonEventListener(self.container, handler(self, self.onClickItem), false)
end

function ChargeSubTabBtn:onClickItem(  )
    if self.clickCallBack then
        self.clickCallBack(self)
    end
end

function ChargeSubTabBtn:addCallBack( callback )
    self.clickCallBack = callback
end

function ChargeSubTabBtn:setIsSelect( status )
    self.normal_img:setVisible(not status)
    self.select_img:setVisible(status)
    if status == true then
        self.icon_sp:setOpacity(255)
    else
        self.icon_sp:setOpacity(178)
    end
end

function ChargeSubTabBtn:setData(data)
    if not data then return end

    self.config = data.config or {}

    -- 图标
    if self.config.res_id and self.config.res_id ~= "" then
        local res_path = PathTool.getResFrame("mall_charge", self.config.res_id)
        loadSpriteTexture(self.icon_sp, res_path, LOADTEXT_TYPE_PLIST)
    end

    -- 名称
    self.name_txt:setString(self.config.name or "")

    -- 红点
    addRedPointToNodeByStatus(self, data.is_show_red)
end

function ChargeSubTabBtn:DeleteMe()
    self:removeAllChildren()
	self:removeFromParent()
end