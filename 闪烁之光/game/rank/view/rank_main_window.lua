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
    self.title_str = TI18N("排行榜")
    self.cur_type = 0
    self.res_list = {
    }

    self.tab_info_list = {
        [RankConstant.MainTabType.LocalRank] = {label = TI18N("本服排行"), index = RankConstant.MainTabType.LocalRank, status = true},
        [RankConstant.MainTabType.CrossRank] = {label = TI18N("跨服排行"), index = RankConstant.MainTabType.CrossRank, status = true}
    }
    self.view_list = {}
    self.tab_list = {}
    self.is_init = true
    self.select_type = RankConstant.MainTabType.LocalRank
    self.is_cluster = false

    self.rank_first_list = {}           -- 排行配置表
    self.showtips = {}
end

function RankMainWindow:open_callback()
    local root = createCSBNote(PathTool.getTargetCSB("rank/rank_main"))
    root:setPosition(cc.p(0, -15))
    self.container:addChild(root)
    self.main_panel = root:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel , 1)

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

function RankMainWindow:openRootWnd(index)
    self.select_type = index or RankConstant.MainTabType.LocalRank
    self:checkTabUnlockInfo()
    -- 切换标签页
    self:setSelecteTab(self.select_type)
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
                    self:setTabBtnTouchStatus(false, RankConstant.MainTabType.CrossRank)
                    self.tab_btn_list[RankConstant.MainTabType.CrossRank].notice = string.format(TI18N("世界等级%s级解锁"), v[2])
                end
            end
        end
    else
        self.tab_info_list[RankConstant.MainTabType.CrossRank].status = false    
        self:setTabBtnTouchStatus(false, RankConstant.MainTabType.CrossRank)
    end
end

function RankMainWindow:selectedTabCallBack(index)
    self:changeTabIndex(index)
end

function RankMainWindow:changeTabIndex(index)
     if index == RankConstant.MainTabType.CrossRank and not self.tab_info_list[index].status then
        if self.showtips[index] then
            message(self.showtips[index])
        end
        return 
    end
    self.select_type = index
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
        local scroll_view_size = cc.size(630,750)
        local setting = {
            item_class = RankMainItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 5,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 605,               -- 单元的尺寸width
            item_height = 168,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 1                         -- 列数，作用于垂直滚动类型
        }
        self.list_view = CommonScrollViewLayout.new(self.main_panel, cc.p(16, 35) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
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
