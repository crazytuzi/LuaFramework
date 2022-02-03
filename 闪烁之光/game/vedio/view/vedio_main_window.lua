--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-24 14:07:28
-- @description    : 
		-- 录像馆
---------------------------------
VedioMainWindow = VedioMainWindow or BaseClass(BaseView)

local _controller = VedioController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

function VedioMainWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full    
    self.layout_name = "vedio/vedio_main_window"       	
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    	{ path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_2",true), type = ResourcesType.single },
    }

    self.filt_is_show = false -- 筛选界面是否正在显示
    self.filt_btn_list = {}
    self.filt_index_list = {} -- 记录各页签当前选中的筛选下标
    self.vedio_data = {}      -- 当前选中的类型、条件的录像数据
    self.vedio_show_data = {} -- 当前显示的录像数据（可能经过筛选相近等级）
    self.cur_tab = nil
    self.cur_index = nil
    self.req_flag = false     -- 是否正在请求数据（避免滑到底部多次请求）
    self.scroll_to_top = true -- 列表是否要滑到顶部

    self.elite_vedio_data = {} -- 精英赛录像数据
end

function VedioMainWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_2",true), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
    end
    
    self.mainContainer = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.mainContainer, 1)
    self.share_panel = self.mainContainer:getChildByName("share_panel")
    self.share_panel:setVisible(false)
    self.share_panel:setSwallowTouches(false)
    self.share_bg = self.share_panel:getChildByName("share_bg")
    self.btn_guild = self.share_bg:getChildByName("btn_guild")
    self.btn_world = self.share_bg:getChildByName("btn_world")
    self.btn_cross = self.share_bg:getChildByName("btn_cross")
    self.share_bg:getChildByName("guild_label"):setString(TI18N("分享到公会频道"))
    self.share_bg:getChildByName("world_label"):setString(TI18N("分享到世界频道"))
    self.share_bg:getChildByName("cross_label"):setString(TI18N("分享到跨服频道"))

    self.main_panel = self.mainContainer:getChildByName("main_panel")

    self.main_panel:getChildByName("win_title"):setString(TI18N("录像馆"))
    self.like_limit_num = self.main_panel:getChildByName("like_limit_num")
    self.like_limit_num:setString("")

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.collect_btn = self.main_panel:getChildByName("collect_btn")
    self.collect_btn:getChildByName("label"):setString(TI18N("个人收藏"))
    self.myself_btn = self.main_panel:getChildByName("myself_btn")
    self.myself_btn:getChildByName("label"):setString(TI18N("个人记录"))

    self.no_vedio_image = self.main_panel:getChildByName("no_vedio_image")
    self.arrow = self.main_panel:getChildByName("arrow")
    local filt_bg = self.main_panel:getChildByName("filt_bg")
    self.filt_label = filt_bg:getChildByName("filt_label")
    self.filt_btn = filt_bg:getChildByName("filt_btn")

    self.filt_lv_btn = self.main_panel:getChildByName("filt_lv_btn")
    self.filt_lv_btn:getChildByName("name"):setString(TI18N("筛选临近等级"))
    local filt_lv_open = _model:getFiltLevelFlag()
    self.filt_lv_btn:setSelected(filt_lv_open)

    local scrollCon = self.main_panel:getChildByName("scrollCon")
    local bgSize = scrollCon:getContentSize()
    local scroll_view_size = cc.size(bgSize.width-10, bgSize.height-10)
    local setting = {
        --item_class = VedioMainItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 3,                   -- y方向的间隔
        item_width = 620,               -- 单元的尺寸width
        item_height = 452,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.vedio_scrollview = CommonScrollViewSingleLayout.new(scrollCon, cc.p(9,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.vedio_scrollview:setSwallowTouches(false)
    --self.vedio_scrollview:addScrollToBottomCallBack(handler(self, self._onBounceBottomCallBack))

    self.vedio_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.vedio_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.vedio_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    --self.vedio_scrollview:registerScriptHandlerSingle(handler(self,self._onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell

	self:createTabBtnList()
end

function VedioMainWindow:_createNewCell(  )
    local cell = VedioMainItem.new()
    cell:addCallBack(handler(self, self._onClickShareBtn))
    return cell
end

function VedioMainWindow:_numberOfCells(  )
    if not self.vedio_show_data then return 0 end
    return #self.vedio_show_data
end

function VedioMainWindow:_updateCellByIndex( cell, index )
    if not self.vedio_show_data then return end
    cell.index = index
    local cell_data = self.vedio_show_data[index]
    if not cell_data then return end
    if self.cur_index then
        if self.cur_index == VedioConst.Tab_Index.Hot then
            cell:setExtendData({is_hot = true, default_index = self.default_index})
        elseif self.cur_index == VedioConst.Tab_Index.Newhero then
            cell:setExtendData({is_newhero = true, default_index = self.default_index})
        else
            cell:setExtendData({})
        end
    end
    cell:setData(cell_data)
end

function VedioMainWindow:createTabBtnList(  )
    self.tabArray = {}
    for k,config in pairs(Config.VideoData.data_vedio) do
        if config.is_show == 1 then
            local tab_data = {}
            tab_data.title = config.name
            tab_data.index = config.id
            tab_data.sort_id = config.sort_id
            self.filt_index_list[config.id] = self:getDefaultFiltIndex(index) -- 各页签筛选默认选中的下标
            _table_insert(self.tabArray, tab_data)
        end
    end
    table.sort(self.tabArray, SortTools.KeyLowerSorter("sort_id"))

    local tab_container = self.main_panel:getChildByName("tab_container")
    local bgSize = tab_container:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height)
    local setting = {
        item_class = CommonTabBtn,      -- 单元类
        start_x = -3,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 155,               -- 单元的尺寸width
        item_height = 64,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    }
    self.tab_scrollview = CommonScrollViewLayout.new(tab_container, cc.p(0, 0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
end

-- 获取默认选中的筛选下标
function VedioMainWindow:getDefaultFiltIndex( tab_type )
    local filt_index = 1
    --[[if tab_type == VedioConst.Tab_Index.Arena then
    end--]]
    return filt_index
end

function VedioMainWindow:_onClickTabBtn( tab_btn )
    if not tab_btn or tab_btn.index == self.cur_index then return end

    if self.cur_tab then
        self.cur_tab:setBtnSelectStatus(false)
    end

    self.cur_index = tab_btn.index
    self.cur_tab = tab_btn
    self.cur_tab:setBtnSelectStatus(true)

    -- 竞技场才显示筛选相近等级玩家按钮
    self.filt_lv_btn:setVisible(self.cur_index == VedioConst.Tab_Index.Arena)

    local vedio_config = Config.VideoData.data_vedio[self.cur_index]
    local filt_index = self.filt_index_list[self.cur_index]
    if vedio_config then
        local evt = vedio_config.evt[filt_index]
        local btn_str = self:getFiltBtnNameByEvt(evt)
        self.filt_label:setString(btn_str)
    end

    self.vedio_data = {}
    self.scroll_to_top = true
    -- 没请求过数据则请求数据，否则直接显示缓存数据
    if self.cur_index == VedioConst.Tab_Index.Elite then
        -- 段位赛特殊处理
        self.vedio_scrollview:setVisible(false)
        if not self.elite_scrollview then
            self:createEliteScrollview()
        end
        self.elite_scrollview:setVisible(true)
        if not self.req_elite_flag then
            self.req_elite_flag = true
            ElitematchController:getInstance():sender24930(3)
        else
            self:updateEliteVedioData()
        end
    else
        if self.elite_scrollview then
            self.elite_scrollview:setVisible(false)
        end
        if not _model:checkIsReqVedioDataByType(self.cur_index, filt_index-1) then
            _controller:requestPublicVedioData(self.cur_index, filt_index-1, 1, VedioConst.ReqVedioDataNum)
        else
            self:setData()
        end
    end
end

function VedioMainWindow:openRootWnd( sub_index )
    if sub_index then
        local is_have = false
        -- 判断一下sub_index是否开放（标签页是否开放配置表控制）
        for k,v in pairs(self.tabArray or {}) do
            if v.index == sub_index then
                is_have = true
                break
            end
        end
        if not is_have then
            sub_index = VedioConst.Tab_Index.Hot
        end
    else
        sub_index = VedioConst.Tab_Index.Hot
    end

    self.default_index = sub_index

    local tab_setting = {}
    tab_setting.default_index = sub_index
    tab_setting.tab_size = cc.size(160, 64)
    tab_setting.title_offset = cc.p(0,-5)
	self.tab_scrollview:setData(self.tabArray, handler(self, self._onClickTabBtn), nil, tab_setting)
    self:refreshTodayLikeNum()

    -- 今日没打开过，则改变状态为打开过
    self.first_open_flag = SysEnv:getInstance():getBool(SysEnv.keys.video_first_open, true)
    if self.first_open_flag == true then
        SysEnv:getInstance():set(SysEnv.keys.video_first_open, false)
    end

    -- 本次登录打开过录像馆界面，则取消外部红点显示
    _model:setIsOpenView(true)
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.vedio, false)
end

-- 刷新点赞数
function VedioMainWindow:refreshTodayLikeNum(  )
    local today_num = _model:getTodayLikeNum()
    local total_num = 0
    local likes_limit_cfg = Config.VideoData.data_const["likes_limit"]
    if likes_limit_cfg then
        total_num = likes_limit_cfg.val
    end
    local left_num = total_num - today_num
    if left_num < 0 then left_num = 0 end
    self.like_limit_num:setString(string.format(TI18N("点赞数:%d/%d"), left_num, total_num))
end

-- 列表滑到最底部
function VedioMainWindow:_onBounceBottomCallBack(  )
    --[[if self.req_flag then return end -- 正在请求数据
    -- 缓存数据达到最大值则不再请求数据
    if not self.vedio_data or self.vedio_data.is_full then
        return 
    end

    if not self.cur_index then return end
    local filt_index = self.filt_index_list[self.cur_index]
    if not filt_index then return end
    local have_num = #(self.vedio_data.vedio_data or {})
    self._old_vedio_num = #(self.vedio_data.vedio_data or {})
    _controller:requestPublicVedioData( self.cur_index, filt_index-1, have_num+1, VedioConst.ReqVedioDataNum )
    self.req_flag = true--]]
end

function VedioMainWindow:setData(  )
    if not self.cur_index then return end

    local cur_filt_index = self.filt_index_list[self.cur_index]
    if not cur_filt_index then return end

    self.vedio_data = _model:getPublicVedioData(self.cur_index, cur_filt_index-1) or {}
    self.vedio_show_data = {}
    if self.cur_index == VedioConst.Tab_Index.Arena and _model:getFiltLevelFlag() then
        local uplimit_config = Config.VideoData.data_const["lev_interval_uplimit"]
        local lowlimit_config = Config.VideoData.data_const["lev_interval_lowlimit"]
        local uplimit_val = 5
        if uplimit_config then
            uplimit_val = uplimit_config.val or 5
        end
        local lowlimit_val = 5
        if lowlimit_config then
            lowlimit_val = lowlimit_config.val or 5
        end
        local role_vo = RoleController:getInstance():getRoleVo()
        for i,v in ipairs(self.vedio_data.vedio_data or {}) do
            local left_min_lv = v.a_lev - lowlimit_val
            local left_max_lv = v.a_lev + uplimit_val
            local right_min_lv = v.b_lev - lowlimit_val
            local right_max_lv = v.b_lev + uplimit_val
            if (role_vo.lev >= left_min_lv and role_vo.lev <= left_max_lv) or (role_vo.lev >= right_min_lv and role_vo.lev <= right_max_lv) then
                _table_insert(self.vedio_show_data, v)
            end
        end
    else
        self.vedio_show_data = self.vedio_data.vedio_data or {}
    end
    if next(self.vedio_show_data) ~= nil then
        -- 滑到顶部还是保持位置仅更新数据
        if self.scroll_to_top == true then
            self.vedio_scrollview:reloadData()
        else
            self.vedio_scrollview:resetCurrentItems()
        end
        self.vedio_scrollview:setVisible(true)
        self.no_vedio_image:setVisible(false)
        self.scroll_to_top = false
    else
        self.vedio_scrollview:setVisible(false)
        self.vedio_scrollview:reloadData()
        self.no_vedio_image:setVisible(true)
    end
end

function VedioMainWindow:_onClickShareBtn( world_pos, replay_id, share_num, srv_id, combat_type )
    self.replay_id = replay_id
    self.share_num = share_num
    self.srv_id = srv_id
    self.combat_type = combat_type
    local node_pos = self.share_panel:convertToNodeSpace(world_pos)
    if node_pos then
        self.share_bg:setPosition(cc.p(node_pos.x-38, node_pos.y+70))
        self.share_panel:setVisible(true)
    end
end

function VedioMainWindow:register_event(  )
	registerButtonEventListener(self.close_btn, function (  )
        _controller:openVedioMainWindow(false)
    end, true, 2)

    registerButtonEventListener(self.collect_btn, function (  )
        _controller:openVedioCollectWindow(true)
    end, true, 1)

    registerButtonEventListener(self.myself_btn, function (  )
        _controller:openVedioMyselfWindow(true)
    end, true, 1)

    -- 分享到公会
    registerButtonEventListener(self.btn_guild, function (  )
        if RoleController:getInstance():getRoleVo():isHasGuild() == false then
            message(TI18N("您暂未加入公会"))
            return
        end
        if self.replay_id then
            _controller:requestShareVedio(self.replay_id, ChatConst.Channel.Gang, self.srv_id, self.combat_type)
            local new_data = _model:updateVedioData(self.cur_index, self.replay_id, "share", self.share_num)
            GlobalEvent:getInstance():Fire(VedioEvent.UpdateVedioDataEvent, new_data)
        end
        self.replay_id = nil
        self.srv_id = nil
        self.combat_type = nil
        self.share_panel:setVisible(false)
    end, false, 1)
    -- 分享到世界
    registerButtonEventListener(self.btn_world, function (  )
        if self.replay_id then
            _controller:requestShareVedio(self.replay_id, ChatConst.Channel.World, self.srv_id, self.combat_type)
            local new_data = _model:updateVedioData(self.cur_index, self.replay_id, "share", self.share_num)
            GlobalEvent:getInstance():Fire(VedioEvent.UpdateVedioDataEvent, new_data)
        end
        self.replay_id = nil
        self.srv_id = nil
        self.combat_type = nil
        self.share_panel:setVisible(false)
    end, false, 1)
    -- 分享到跨服
    registerButtonEventListener(self.btn_cross, function (  )
        local cross_config = Config.MiscData.data_const["cross_level"]
        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo.lev < cross_config.val then
            message(string.format(TI18N("%d级开启跨服频道"), cross_config.val))
            return
        end
        if self.replay_id then
            _controller:requestShareVedio(self.replay_id, ChatConst.Channel.Cross, self.srv_id, self.combat_type)
            local new_data = _model:updateVedioData(self.cur_index, self.replay_id, "share", self.share_num)
            GlobalEvent:getInstance():Fire(VedioEvent.UpdateVedioDataEvent, new_data)
        end
        self.replay_id = nil
        self.srv_id = nil
        self.combat_type = nil
        self.share_panel:setVisible(false)
    end, false, 1)
    -- 点击关闭分享界面
    self.share_panel:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            self.share_panel:setVisible(false)
        end
    end)
    -- 筛选按钮
    registerButtonEventListener(self.filt_btn, function (  )
        self:_onClickFiltBtn()
    end, true, 1)

    -- 筛选等级相近的玩家录像
    self.filt_lv_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            _model:setFiltLevelFlag(true)
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            _model:setFiltLevelFlag(false)
        end
        self.scroll_to_top = true
        self:setData()
    end)

    self:addGlobalEvent(VedioEvent.UpdatePublicVedioEvent, function ( vedioType )
        if self.cur_index and vedioType and self.cur_index == vedioType then
            self:setData()
            self.req_flag = false
        end
    end)

    -- 精英赛数据
    self:addGlobalEvent(ElitematchEvent.Elite_Challenge_Record_Event, function ( data )
        if self.cur_index and self.cur_index == VedioConst.Tab_Index.Elite and data and data.type == 3 then
            self.elite_vedio_data = data.arena_elite_log or {}
            self:updateEliteVedioData()
        end
    end)

    -- 点赞数
    self:addGlobalEvent(VedioEvent.UpdateTodayLikeNum, function (  )
        self:refreshTodayLikeNum()
    end)
    -- 打开\关闭个人记录个人收藏界面
    self:addGlobalEvent(VedioEvent.OpenCollectViewEvent, function ( status )
        if not self.mainContainer then return end
        if status == true then
            self.mainContainer:setVisible(false)
        else
            self.mainContainer:setVisible(true)
        end
    end)
end

-- 点击筛选按钮
function VedioMainWindow:_onClickFiltBtn(  )
    if self.cur_index then
        local vedio_config = Config.VideoData.data_vedio[self.cur_index]
        if not vedio_config then return end

        if not self.filt_layout then
            self.filt_layout = ccui.Layout:create()
            self.filt_layout:setTouchEnabled(true)
            self.filt_layout:setContentSize(cc.size(676, 918))
            self.filt_layout:setAnchorPoint(0.5,0.5)
            self.filt_layout:setPosition(360, 485)
            self.mainContainer:addChild(self.filt_layout)

            self.filt_layout:addTouchEventListener(function(sender, event)
                if event == ccui.TouchEventType.began then
                    self:_onClickFiltBtn()
                end
            end)

            self.filt_bg = createImage(self.filt_layout, PathTool.getResFrame("common", "common_1092"), 0, 0, cc.p(1, 1), true, 1, true)
            self.filt_bg:setTouchEnabled(true)
            self.filt_bg:setAnchorPoint(cc.p(1, 1))
            local world_pos = self.filt_btn:convertToWorldSpace(cc.p(0, 0))
            local node_pos = self.filt_layout:convertToNodeSpace(world_pos)
            self.filt_bg:setPosition(cc.p(node_pos.x+45, node_pos.y))
        end

        local evt_list = vedio_config.evt or {}
        for k,btn in pairs(self.filt_btn_list) do
            btn:setVisible(false)
        end
        local space_y = 0
        local distance = 10
        local btn_size = cc.size(156, 50)
        local bg_size = cc.size(166, distance*2 + #evt_list*(btn_size.height+space_y)-space_y)
        self.filt_bg:setContentSize(bg_size)
        for i,v in ipairs(evt_list) do
            local btn = self.filt_btn_list[i]
            if btn == nil then
                btn = createButton(self.filt_bg, "", 0, 0, btn_size, PathTool.getResFrame("common", "common_1046"), 22, Config.ColorData.data_color4[1])
                btn:setAnchorPoint(cc.p(0.5, 1))
                btn:addTouchEventListener(function( sender, event_type )
                    customClickAction(sender, event_type)
                    if event_type == ccui.TouchEventType.ended then
                        self:_onClickFiltItem(i)
                    end
                end)
                _table_insert(self.filt_btn_list, btn)
            end
            btn:setVisible(true)
            local pos_y = (bg_size.height-distance) - (i-1)*(btn_size.height+space_y)
            btn:setPosition(cc.p(83, pos_y))
            local btn_str = self:getFiltBtnNameByEvt(v)
            btn:setBtnLabel(btn_str)
            btn:enableOutline(Config.ColorData.data_color4[264], 2)
        end

        self.filt_is_show = not self.filt_is_show
        self.filt_layout:setVisible(self.filt_is_show)
    end
end

function VedioMainWindow:_onClickFiltItem( index )
    if not self.cur_index then return end
    local vedio_config = Config.VideoData.data_vedio[self.cur_index]
    if vedio_config then
        self.filt_index_list[self.cur_index] = index
        local evt = vedio_config.evt[index]
        local btn_str = self:getFiltBtnNameByEvt(evt)
        self.filt_label:setString(btn_str)
        self:_onClickFiltBtn()

        if self.cur_index ~= VedioConst.Tab_Index.Elite then
            self.vedio_data = {}
            self.scroll_to_top = true
            -- 没请求过数据则请求数据，否则直接显示缓存数据
            if not _model:checkIsReqVedioDataByType(self.cur_index, index-1) then
                _controller:requestPublicVedioData(self.cur_index, index-1, 1, VedioConst.ReqVedioDataNum)
            else
                self:setData()
            end
        end
    end
end

function VedioMainWindow:getFiltBtnNameByEvt( evt )
    if not evt then return "" end
    local evt_name = evt[1]
    local btn_str = ""
    if evt_name == "all" then
        btn_str = TI18N("全部")
    elseif evt_name == "rank" then
        local min_num = evt[2]
        local max_num = evt[3]
        if min_num and max_num then
            btn_str = string.format(TI18N("%d-%d名"), min_num, max_num)
        elseif not max_num then
            btn_str = string.format(TI18N("%d名以后"), min_num)
        end
    elseif evt_name == "cham" then
        local cham_num = evt[2]
        btn_str = VedioConst.Cham_Name[cham_num]
    elseif evt_name == "lev" then
        local min_num = evt[2]
        local max_num = evt[3]
        if min_num and max_num then
            btn_str = string.format(TI18N("%d-%d级"), min_num, max_num)
        elseif not max_num then
            btn_str = string.format(TI18N("%d级以上"), min_num)
        end
    end
    return btn_str or ""
end

-------------------@精英赛录像特殊处理
function VedioMainWindow:createEliteScrollview(  )
    local scrollCon = self.main_panel:getChildByName("scrollCon")
    local bgSize = scrollCon:getContentSize()
    local scroll_view_size = cc.size(bgSize.width-2, bgSize.height-10)
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 3,                   -- y方向的间隔
        item_width = 628,               -- 单元的尺寸width
        item_height = 244,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.elite_scrollview = CommonScrollViewSingleLayout.new(scrollCon, cc.p(6,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.elite_scrollview:setSwallowTouches(false)

    self.elite_scrollview:registerScriptHandlerSingle(handler(self,self._eliteCreateNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.elite_scrollview:registerScriptHandlerSingle(handler(self,self._eliteNumberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.elite_scrollview:registerScriptHandlerSingle(handler(self,self._eliteUpdateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

function VedioMainWindow:_eliteCreateNewCell(  )
    local cell = ElitematchFightRecordItem.new()
    return cell
end

function VedioMainWindow:_eliteNumberOfCells(  )
    if not self.elite_vedio_data then return 0 end
    return #self.elite_vedio_data
end

function VedioMainWindow:_eliteUpdateCellByIndex( cell, index )
    cell.index = index
    local cell_data = self.elite_vedio_data[index]
    if not cell_data then return end
    cell:setData(cell_data, 3)
end

function VedioMainWindow:updateEliteVedioData(  )
    self.elite_scrollview:reloadData()
    if next(self.elite_vedio_data) ~= nil then
        self.no_vedio_image:setVisible(false)
    else
        self.no_vedio_image:setVisible(true)
    end
end

function VedioMainWindow:close_callback(  )
	if self.tab_scrollview then
		self.tab_scrollview:DeleteMe()
		self.tab_scrollview = nil
	end
    if self.vedio_scrollview then
        self.vedio_scrollview:DeleteMe()
        self.vedio_scrollview = nil
    end
    if self.elite_scrollview then
        self.elite_scrollview:DeleteMe()
        self.elite_scrollview = nil
    end
    _model:clearVedioData()
	_controller:openVedioMainWindow(false)
end