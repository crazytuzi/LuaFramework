-- --------------------------------------------------------------------
-- 竖版排行榜主界面
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: lwc@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      通用排行榜
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
RankMainWindow = RankMainWindow or BaseClass(BaseView)
local table_sort = table.sort
local controller = RankController:getInstance()

function RankMainWindow:__init()
    self.ctrl = RankController:getInstance()
    self.is_full_screen = true
    self.win_type = WinType.Full    
    self.layout_name = "rank/rank_main"
    self.title_str = TI18N("排行榜")
    self.cur_type = 0
    self.res_list = {
    }

    self.tab_info_list = {
        [RankConstant.MainTabType.LocalRank] = {label = TI18N("本服排行"), index = RankConstant.MainTabType.LocalRank, status = true},
        [RankConstant.MainTabType.CrossRank] = {label = TI18N("跨服排行"), index = RankConstant.MainTabType.CrossRank, status = true}
    }

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("guild","guild"), type = ResourcesType.plist },
    }
    self.view_list = {}
    -- self.tab_list = {}
    self.is_init = true
    self.select_type = RankConstant.MainTabType.LocalRank
    self.is_cluster = false

    self.rank_first_list = {}           -- 排行配置表
    self.showtips = {}
    --当前选中的索引
    self.cur_index = nil
end

function RankMainWindow:open_callback()
    -- local root = createCSBNote(PathTool.getTargetCSB("rank/rank_main"))
    -- root:setPosition(cc.p(0, -15))
    -- self.container:addChild(root)
    -- self.main_panel = root:getChildByName("main_panel")
    -- self:playEnterAnimatianByObj(self.main_panel , 1)

    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_106",true), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
    end
    
    self.mainContainer = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.mainContainer , 1) 

    self.main_panel = self.mainContainer:getChildByName("main_panel")

    self.tableContainer = self.main_panel:getChildByName("tab_container")

    self.container = self.main_panel:getChildByName("container")
    self.rank_panel = self.container:getChildByName("rank_panel")

    self.close_btn = self.mainContainer:getChildByName("close_btn")

    -- 世界等级
    -- self.main_panel:getChildByName("world_lv_title"):setString(TI18N("世界等级:"))
    -- self.world_lv_txt = self.main_panel:getChildByName("world_lv_txt")
    -- self.world_lv_btn = self.main_panel:getChildByName("world_lv_btn")
    -- -- 屏蔽世界等级显示
    -- self.main_panel:getChildByName("world_lv_title"):setVisible(false)
    -- self.world_lv_txt:setVisible(false)
    -- self.world_lv_btn:setVisible(false)
    -- self:updateWorldLevel()
end

-- 刷新世界等级
function RankMainWindow:updateWorldLevel(  )
    local world_lev = RoleController:getInstance():getModel():getWorldLev()
    self.world_lv_txt:setString(string.format(TI18N("%d级"), world_lev))
end

-- 世界等级tips
function RankMainWindow:showWorldLevelTips( status )
    if status == true then
        if not self.world_lv_layout then
            self.world_lv_layout = ccui.Layout:create()
            self.world_lv_layout:setTouchEnabled(true)
            self.world_lv_layout:setSwallowTouches(false)
            self.world_lv_layout:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
            self.world_lv_layout:setLocalZOrder(999)
            self.world_lv_layout:setAnchorPoint(cc.p(0.5, 0.5))
            self.world_lv_layout:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
            self:addChild(self.world_lv_layout)
            registerButtonEventListener(self.world_lv_layout, function (  )
                self:showWorldLevelTips(false)
            end)

            -- 背景
            local world_pos = self.world_lv_btn:convertToWorldSpace(cc.p(0, 0))
            local local_pos = self.world_lv_layout:convertToNodeSpace(world_pos) 
            local world_lv_bg = createImage(self.world_lv_layout, PathTool.getResFrame("common","common_1056"), local_pos.x+150, local_pos.y-10, cc.p(0.5, 1), true, nil, true)
            world_lv_bg:setTouchEnabled(true)
            local world_bg_size = cc.size(400, 150)

            -- 世界等级描述
            local world_lev_cfg = Config.WorldLevData.data_const["worldlev_des"]
            if world_lev_cfg then
                local world_lv_desc = createLabel(24,161,nil,30,85,world_lev_cfg.desc,world_lv_bg,nil,cc.p(0, 1))
                world_lv_desc:setMaxLineWidth(350)
                local desc_size = world_lv_desc:getContentSize()
                world_bg_size.height = world_bg_size.height + desc_size.height
                world_lv_desc:setPosition(cc.p(30, world_bg_size.height-90))
            end
            world_lv_bg:setContentSize(world_bg_size)

            -- 图标
            local world_lv_icon = createSprite(PathTool.getResFrame("common","txt_cn_common_90022"), 50, world_bg_size.height-40, world_lv_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
            local world_lv_title = createLabel(26,161,nil,85,world_bg_size.height-40,TI18N("世界等级"),world_lv_bg,nil,cc.p(0, 0.5))
            local world_lv_line = createSprite(PathTool.getResFrame("common","common_1072"), 200, world_bg_size.height-75, world_lv_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
            world_lv_line:setScaleY(3)
            world_lv_line:setRotation(90)
            
            -- 世界等级
            self.world_lv_txt = createRichLabel(24, 161, cc.p(0, 0.5), cc.p(30, 35))
            world_lv_bg:addChild(self.world_lv_txt)
            local world_lev = RoleController:getInstance():getModel():getWorldLev()
            self.world_lv_txt:setString(string.format(TI18N("当前世界等级:<div fontcolor=#249003>%d级</div>"), world_lev))
        end
        self.world_lv_layout:setVisible(true)
    elseif self.world_lv_layout then
        self.world_lv_layout:setVisible(false)
    end
end

function RankMainWindow:register_event()
    registerButtonEventListener(self.close_btn, function() controller:openMainView(false) end ,true, 2)

    -- for i,tab in pairs(self.tab_list) do
    --     tab.btn:addTouchEventListener(function(sender, event_type) 
    --         if event_type == ccui.TouchEventType.ended then
    --             playButtonSound2()
    --             self:changeTabIndex(tab.index)
    --         end
    --     end)
    -- end

    -- registerButtonEventListener(self.world_lv_btn, function (  )
    --     self:showWorldLevelTips(true)
    -- end)

    if not self.get_first_event then 
        self.get_first_event =  GlobalEvent:getInstance():Bind(RankEvent.RankEvent_Get_First_data,function(data)
            if not data then return end
            local index = RankConstant.MainTabType.LocalRank
            if data.is_cluster == 1 then
                index = RankConstant.MainTabType.CrossRank
            end
            if self.select_type ~= index then return end
            self.rank_first_list[index] = data.rank_list
            self:updateRankList()
        end)
    end

    -- -- 世界等级
    -- self:addGlobalEvent(RoleEvent.WORLD_LEV, function (  )
    --     self:updateWorldLevel()
    -- end)
end

--页签滚动列表
function RankMainWindow:updateTabBtnList(index)
    if not self.tab_info_list then return end

    if not self.tab_btn_list_view then
        local size = self.tableContainer:getContentSize()
        local count = self:numberOfCellsTabBtn()
        local item_width = 153
        local item_height = 64
        local position_data_list 
        if count <= 2  then
            position_data_list = {}
            local s_x = 5 --(size.width - count * item_width) * 0.5
            local y = item_height * 0.5
            for i=1,count do
                local x = s_x + item_width * 0.5 + (i -1) * item_width
                position_data_list[i] = cc.p(x, y)
            end
        end
        local setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = item_width,               -- 单元的尺寸width
            item_height = item_height,              -- 单元的尺寸height
            -- row = 1,                        -- 行数，作用于水平滚动类型
            -- col = 5,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true,
            position_data_list = position_data_list
        }

        self.tab_btn_list_view = CommonScrollViewSingleLayout.new(self.tableContainer, cc.p(size.width * 0.5, size.height * 0.5) , ScrollViewDir.horizontal, ScrollViewStartPos.top, size, setting, cc.p(0.5,0.5))

        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.createNewCellTabBtn), ScrollViewFuncType.CreateNewCell) --创建cell
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.numberOfCellsTabBtn), ScrollViewFuncType.NumberOfCells) --获取数量
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndexTabBtn), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.onCellTouchedTabBtn), ScrollViewFuncType.OnCellTouched) --更新cell

        if count <= 2  then
            self.tab_btn_list_view:setClickEnabled(false)
        end
    end
    local index = index or 1
    self.tab_btn_list_view:reloadData(index)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function RankMainWindow:createNewCellTabBtn(width, height)
    local cell = ccui.Widget:create()
    cell.root_wnd = createCSBNote(PathTool.getTargetCSB("common/common_tab_btn"))
    cell:addChild(cell.root_wnd)
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(cc.p(0.5, 0.5))
    cell:setContentSize(cc.size(width, height))
    cell.container = cell.root_wnd:getChildByName("container")
    cell.normal_img = cell.container:getChildByName("unselect_bg")
    cell.select_img = cell.container:getChildByName("select_bg")
    cell.select_img:setVisible(false)
    -- cell.setOntouch
    cell.container:setSwallowTouches(false)
    cell.label = cell.container:getChildByName("title")
    cell.label:setTextColor(Config.ColorData.data_new_color4[6])

    --红点. 暂时没有红点 先隐藏
    cell.red_point = cell.container:getChildByName("tab_tips")
    cell.red_num = cell.container:getChildByName("red_num")
    cell.red_point:setVisible(false)
    cell.red_num:setVisible(false)

    registerButtonEventListener(cell.container, function() self:onCellTouchedTabBtn(cell) end, false, 2, nil, nil, nil, true)
    -- --回收用
    -- cell.DeleteMe = function() 
    -- end
    return cell
end

--获取数据数量
function RankMainWindow:numberOfCellsTabBtn()
    if not self.tab_info_list then return 0 end
    return #self.tab_info_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function RankMainWindow:updateCellByIndexTabBtn(cell, index)
    cell.index = index
    local tab_data = self.tab_info_list[index]
    if tab_data then
        cell.label:setString(tab_data.label)
        local tab_btn =  self.tab_btn_list_view:getCellByIndex(index)
        -- 有notice需要把按钮置灰
        if tab_data.notice ~= nil then
            setChildUnEnabled(true, tab_btn)
            tab_btn.label:setTextColor(Config.ColorData.data_new_color4[1])
            tab_btn.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
            return
        end
        if self.cur_index == index then
            cell.select_img:setVisible(true)
            cell.label:setTextColor(Config.ColorData.data_new_color4[1])
            cell.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
        else
            cell.select_img:setVisible(false)            
            cell.label:setTextColor(Config.ColorData.data_new_color4[6])
            cell.label:disableEffect(cc.LabelEffect.SHADOW)
        end

        --先不处理.都是1级开启的 省点
        -- if tab_data.can_touch then
        --     cell.label:enableOutline(cc.c4b(0x2a, 0x16, 0x0e, 0xff), 2)
        --     setChildUnEnabled(false, cell.tab_btn)
        -- else 
        --     cell.label:disableEffect(cc.LabelEffect.OUTLINE)
        --     setChildUnEnabled(true, cell.tab_btn)
        -- end
    end
end

--index :数据的索引
function RankMainWindow:onCellTouchedTabBtn(cell)
    local index = cell.index
    local tab_data = self.tab_info_list[index]
    if tab_data then
        --点击需要判断
        if tab_data.status then
            -- self:changeTabView(index, true)
            self:changeTabIndex(index)
        else
            message(TI18N(tab_data.notice))
        end
    end
end

-- function RankMainWindow:changeTabView(index, check_repeat_click)
--     if not index then return end
--     if check_repeat_click and self.cur_index == index then return end
--     local tab_data = self.tab_info_list[index]
--     if not tab_data then return end
-- print("RankMainWindow:changeTabView")
-- end

function RankMainWindow:openRootWnd(index)
    self.select_type = index or RankConstant.MainTabType.LocalRank
    self:checkTabUnlockInfo()
    -- -- 切换标签页
    -- self:setSelecteTab(self.select_type)
    self:updateTabBtnList(self.select_type)
end

function RankMainWindow:checkTabUnlockInfo()
    local config = Config.CityData.data_base[CenterSceneBuild.crossshow]
    self.tab_info_list[RankConstant.MainTabType.CrossRank].status = true
    if config then
        for i,v in ipairs(config.activate) do
            if v[1] == "world_lev" then
                local world_lev = RoleController:getInstance():getModel():getWorldLev() or 0
                if world_lev < v[2] then
                    self.tab_info_list[RankConstant.MainTabType.CrossRank].status = false
                    -- self:setTabBtnTouchStatus(false, RankConstant.MainTabType.CrossRank)
                    self.tab_info_list[RankConstant.MainTabType.CrossRank].notice = string.format(TI18N("世界等级%s级解锁"), v[2])
                end
            end
        end
    else
        self.tab_info_list[RankConstant.MainTabType.CrossRank].status = false
        -- self:setTabBtnTouchStatus(false, RankConstant.MainTabType.CrossRank)
    end
end

-- function RankMainWindow:selectedTabCallBack(index)
--     self:changeTabIndex(index)
-- end

function RankMainWindow:changeTabIndex(index)
    if index == RankConstant.MainTabType.CrossRank and not self.tab_info_list[index].status then
        if self.showtips[index] then
            message(self.showtips[index])
        end
        return 
    end

    if self.cur_tab ~= nil then
        if self.cur_tab.label then
            self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[6])
            self.cur_tab.label:disableEffect(cc.LabelEffect.SHADOW)
        end
        self.cur_tab.select_img:setVisible(false)
    end

    self.select_type = index
    self.cur_tab =  self.tab_btn_list_view:getCellByIndex(self.select_type)

    if self.cur_tab ~= nil then
        if self.cur_tab.label then
            self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[1])
            self.cur_tab.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
        end
        self.cur_tab.select_img:setVisible(true)
    end

    local first_data = self.rank_first_list[index]
    if first_data ~= nil then
        self:updateRankList()
    else
        self.is_cluster = (self.select_type == RankConstant.MainTabType.CrossRank)
        controller:send_12902(self.is_cluster)
    end
end

function RankMainWindow:updateRankList()
    if self.select_type == nil then return end
    local first_data = self.rank_first_list[self.select_type]
    if first_data == nil then return end
    if not self.list_view then
        local scroll_view_size = cc.size(662,638)
        local setting = {
            item_class = RankMainItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 662,               -- 单元的尺寸width
            item_height = 148,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 1                         -- 列数，作用于垂直滚动类型
        }
        self.list_view = CommonScrollViewLayout.new(self.rank_panel, cc.p(9, 9) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    end
   
    local list = {}
    if self.select_type == RankConstant.MainTabType.LocalRank then
        local sort_list = {}
        sort_list[2] = 2
        sort_list[3] = 3
        sort_list[4] = 5
        sort_list[5] = 4
        sort_list[6] = 1
        for i,v in pairs(first_data) do
            local sort = sort_list[v.type]
            table.insert(list, {sort = sort, rank_type=v.type, rank_vo = v })
        end
        table_sort(list, function(a, b)  return a.sort < b.sort end)
    else
        for i,v in pairs(first_data) do
            table.insert(list, {rank_type=v.type, rank_vo = v })
        end
        table_sort(list, function(a, b)  return a.rank_type < b.rank_type end)
    end

    local is_cluster = (self.select_type == RankConstant.MainTabType.CrossRank)
    local function callback(item,vo)
        if vo and next(vo)~=nil then
            local index = item:getRankIndex() or 1
            self.ctrl:openRankView(true,index,is_cluster)
        end
    end
    self.list_view:setData(list, callback, nil, is_cluster)
end

function RankMainWindow:close_callback()
    self.ctrl:openMainView(false)
    if self.get_first_event then 
        GlobalEvent:getInstance():UnBind(self.get_first_event)
        self.get_first_event = nil
    end
    if self.list_view then 
        self.list_view:DeleteMe()
    end
    self.list_view = nil
end
