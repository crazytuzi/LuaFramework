-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      跨服时空 主界面 
-- <br/>Create: 2019年3月15日
CrossshowMainWindow = CrossshowMainWindow or BaseClass(BaseView)

local controller = CrossshowController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function CrossshowMainWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.res_list = {{
        path = PathTool.getPlistImgForDownLoad("crossshow", "crossshow"),
        type = ResourcesType.plist
    }, {
        path = PathTool.getPlistImgForDownLoad("bigbg/crossshow", "crossshow_bg", true),
        type = ResourcesType.single
    }}
    self.layout_name = "crossshow/crossshow_main_window"

    self.item_names = {TI18N("天梯争霸"), TI18N("公会战"), TI18N("跨服竞技场"), TI18N("周冠军赛"),
                       TI18N("组队竞技场"), TI18N("巅峰冠军赛")}

    -- 跨服名字
    self.cross_name_list = {}
end

function CrossshowMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/crossshow", "crossshow_bg", true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.container_size = self.main_container:getContentSize()
    self.close_btn = self.main_container:getChildByName("close_btn")
    -- top_panel
    self.top_panel = self.main_container:getChildByName("top_panel")
    self.title_name = self.top_panel:getChildByName("title_name")
    self.title_name:setString(TI18N("跨服时空"))

    self.lay_scrollview = self.main_container:getChildByName("lay_scrollview")

    -- bottom_panel
    self.bottom_panel = self.main_container:getChildByName("bottom_panel")

    self.icon_scrollview = self.bottom_panel:getChildByName("icon_scrollview")

    local label_cross = self.bottom_panel:getChildByName("label_cross")
    label_cross:setString(TI18N("当前跨服玩法"))

     local label_tips = self.bottom_panel:getChildByName("texDes")
    --local label_tips = createRichLabel(18,Config.ColorData.data_new_color4[1],
    --cc.p(0.5,0.5),cc.p(380,150),nil,nil,400)
    --self.bottom_panel:addChild(label_tips)
    label_tips:setString(TI18N("跨服时空每隔一段时间会重组"))

    self.rule_btn = self.main_container:getChildByName("rule_btn")
    self.rule_btn_label = self.rule_btn:getChildByName("label")
    self.rule_btn_label:setString(TI18N("规则说明"))

    self.rank_btn = self.main_container:getChildByName("rank_btn")
    self.rank_btn_label = self.rank_btn:getChildByName("label")
    self.rank_btn_label:setString(TI18N("排行榜"))

    -- self.leve_up_node = panel:getChildByName("leve_up_node")
    -- self.reward_label = createRichLabel(22, cc.c4b(0xff,0xf8,0xbf,0xff), cc.p(0,0.5), cc.p(53,391), nil, nil, 600)
    -- panel:addChild(self.reward_label)
    -- self.bule_tips = createLabel(20,cc.c4b(0x4c,0xb1,0xff,0xff),cc.c4b(0x00,0x00,0x00,0xff),self.level_up_tips:getPositionX(),465,"",panel,2, cc.p(0.5,0.5))
    -- self.bule_tips:setString(TI18N("蓝条部分为降级缓冲经验"))
    -- self.bule_tips:setVisible(false)
    self:adaptationScreen()
end

-- 设置适配屏幕
function CrossshowMainWindow:adaptationScreen()
    -- 对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)
    local left_x = display.getLeft(self.main_container)
    local right_x = display.getRight(self.main_container)

    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (self.container_size.height - tab_y))

    local bottom_panel_y = self.bottom_panel:getPositionY()
    self.bottom_panel:setPositionY(bottom_y + bottom_panel_y)
    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(bottom_y + close_btn_y)

    -- --主菜单 顶部的高度
    local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()

    -- 计算scrollview的高度
    local bottom_size = self.bottom_panel:getContentSize()
    self.scrollview_y = (bottom_y + bottom_panel_y) + bottom_size.height
    self.scrollview_height = top_y - top_height - self.scrollview_y + 58 -- 58 是角色框底到经验条的高度
end

function CrossshowMainWindow:register_event()
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
    registerButtonEventListener(self.rank_btn, handler(self, self.onClickRankBtn), true, 1)

    registerButtonEventListener(self.rule_btn, function(param, sender, event_type)
        local config = Config.CrossShowData.data_const.game_rule
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
        end
    end, true, 2)

    self:addGlobalEvent(CrossshowEvent.Get_Cross_Show_Info_Event, function(scdata)
        if not scdata then
            return
        end
        self:setData(scdata)
    end)
end

-- 关闭
function CrossshowMainWindow:onClickCloseBtn()
    controller:openCrossshowMainWindow(false)
end

-- 打开排行榜
function CrossshowMainWindow:onClickRankBtn()
    RankController:getInstance():openMainView(true, RankConstant.MainTabType.CrossRank)
end

function CrossshowMainWindow:openRootWnd()
    -- 世界等级
    self.world_lev = RoleController:getInstance():getModel():getWorldLev() or 0
    -- 个人等级
    self.role_vo = RoleController:getInstance():getRoleVo()
    if self.role_vo then
        self.role_lev = self.role_vo.lev or 0
    else
        self.role_lev = 0
    end

    controller:sender22150()
    self:addEffect()
end

function CrossshowMainWindow:setData(data)
    if not data then
        return
    end
    local list = {}
    for i, v in ipairs(data.srv_list) do
        local srv_index, is_local = getServerIndex(v.srv_id)
        local s_data = {}
        if srv_index == 0 then
            s_data.sort_index = 1
            s_data.srv_name = TI18N("异域")
        else
            if is_local then
                s_data.sort_index = 0 -- 本服
                s_data.srv_name = string_format(TI18N("本服%s服"), srv_index)
            else
                s_data.sort_index = 1
                s_data.srv_name = string_format(TI18N("%s服"), srv_index)
            end
        end
        s_data.srv_index = tonumber(srv_index)
        if s_data.srv_index == nil then
            s_data.srv_index = 0
        end
        s_data.world_name = string_format(TI18N("世界等级%s级"), v.world_lev)
        list[i] = s_data
    end
    local sort_func = SortTools.tableLowerSorter({"sort_index", "srv_index"})
    table_sort(list, sort_func)

    self.show_list = {}
    local count = math.ceil(#list / 2)
    for i = 1, count do
        local left_data = list[i * 2 - 1]
        local right_data = list[i * 2]
        local data = {}
        data.left_data = left_data
        data.right_data = right_data
        table_insert(self.show_list, data)
    end
    if #self.show_list == 0 then
        self:showNoInfo()
    else
        self:updateNameList()
    end

    self:initCrossInfo()
end

function CrossshowMainWindow:addEffect()
    self.size = self.main_container:getSize()
    -- 流星
    if self.scene_effect_1 == nil then
        self.scene_effect_1 = createEffectSpine(PathTool.getEffectRes(305),
            cc.p(self.size.width * 0.5, self.size.height * 0.5), cc.p(0.5, 0.5), true, PlayerAction.action)
        self.background:addChild(self.scene_effect_1, 1)
    end

    -- 星星
    if self.scene_effect_2 == nil then
        self.scene_effect_2 = createEffectSpine(PathTool.getEffectRes(306),
            cc.p(self.size.width * 0.5, self.size.height * 0.5), cc.p(0.5, 0.5), true, PlayerAction.action)
        self.background:addChild(self.scene_effect_2, 1)
    end
end

function CrossshowMainWindow:showNoInfo()
    if not self.role_vo then
        return
    end
    if self.cross_icon ~= nil then
        return
    end
    --local res = PathTool.getResFrame("commonicon", "common_icon_9")
    --cell.icon = createSprite(res, width * 0.5, height * 0.5, cell, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    local lay_scrollview_size = self.lay_scrollview:getContentSize()
    local x = lay_scrollview_size.width * 0.5
    local y = lay_scrollview_size.height * 0.5 + 200
    local icon_res =  PathTool.getTargetRes("crossshow", "icon_6",false)-- PathTool.getResFrame("crossshow", "crossshow_06")
    local cell = self.lay_scrollview
    self.cross_icon =  createSprite(icon_res, x, y, cell, cc.p(0.5, 0.5), LOADTEXT_TYPE) --loadSpriteTexture(cell, icon_res, LOADTEXT_TYPE)

    --local effect_id = Config.EffectData.data_effect_info[376]
    --self.cross_effect = createEffectSpine(effect_id, cc.p(x, y), cc.p(0.5, 0.5), true, PlayerAction.action)
    --cell:addChild(self.cross_effect, 1)

    local res = PathTool.getTargetRes("crossshow", "icon_bg",false) --PathTool.getResFrame("crossshow", "crossshow_02")
    self.left_level_bg = createImage(cell, res, x, y - 120, cc.p(0.5, 0.5), false, nil, true)
    self.left_level_bg:setContentSize(cc.size(156, 40))
    self.left_level_bg:setCapInsets(cc.rect(14, 20, 2, 0))

    local srv_index, is_local = getServerIndex(self.role_vo.main_srv_id)
    -- 左边名字
    local srv_name = string_format(TI18N("本服%s服"), srv_index)
    self.left_name = createLabel(22, cc.c4b(0x7c, 0xd7, 0x5d, 0xff), cc.c4b(0x00, 0x00, 0x00, 0xff), x, y - 120,
        srv_name, cell, 2, cc.p(0.5, 0.5))
    local world_name = string_format(TI18N("世界等级%s级"), self.world_lev)
    self.left_world_lev = createLabel(22, cc.c4b(0xff, 0xe6, 0xce, 0xff), cc.c4b(0x00, 0x00, 0x00, 0xff), x, y - 156,
        world_name, cell, 2, cc.p(0.5, 0.5))

    local tips = TI18N("该服尚未进行跨服分组(πvπ)")
    self.cross_show_tips = createLabel(24, cc.c4b(0xff, 0xe6, 0xce, 0xff), cc.c4b(0x00, 0x00, 0x00, 0xff), x, y - 200,
        tips, cell, 2, cc.p(0.5, 0.5))
end

function CrossshowMainWindow:updateNameList()
    if not self.show_list then
        return
    end
    if not self.scrollview_y then
        return
    end
    if not self.scrollview_height then
        return
    end

    if self.list_view == nil then
        local lay_scrollview_size = self.lay_scrollview:getContentSize()
        local scroll_view_size = cc.size(lay_scrollview_size.width, self.scrollview_height)

        local start_y = 135
        local space_y = -10
        local item_height = 250
        local content_height = self.scrollview_height - start_y

        local position_data_list
        local max_count = math.floor(content_height / (item_height + space_y))
        local count = self:numberOfCellsName()
        if max_count >= count then
            -- 如果数量不够单屏显示数量..居中显示
            position_data_list = {}
            local s_y = (content_height - (item_height + space_y) * count) * 0.5
            local x = scroll_view_size.width * 0.5
            for i = 1, count do
                local y = content_height - s_y - ((item_height + space_y) * 0.5 + (i - 1) * (item_height + space_y))
                position_data_list[i] = cc.p(x, y)
            end
        end
        local setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 0, -- 第一个单元的X起点
            space_x = 0, -- x方向的间隔
            start_y = start_y, -- 第一个单元的Y起点
            end_y = 0,
            space_y = space_y, -- y方向的间隔
            item_width = scroll_view_size.width, -- 单元的尺寸width
            item_height = item_height, -- 单元的尺寸height
            delay = 1,
            -- row = 1,                        -- 行数，作用于水平滚动类型
            col = 1, -- 列数，作用于垂直滚动类型
            need_dynamic = true,
            position_data_list = position_data_list
        }

        self.list_view = CommonScrollViewSingleLayout.new(self.lay_scrollview,
            cc.p(scroll_view_size.width * 0.5, self.scrollview_y), ScrollViewDir.vertical, ScrollViewStartPos.top,
            scroll_view_size, setting, cc.p(0.5, 0))

        self.list_view:registerScriptHandlerSingle(handler(self, self.createNewCellName),
            ScrollViewFuncType.CreateNewCell) -- 创建cell
        self.list_view:registerScriptHandlerSingle(handler(self, self.numberOfCellsName),
            ScrollViewFuncType.NumberOfCells) -- 获取数量
        self.list_view:registerScriptHandlerSingle(handler(self, self.updateCellByIndexName),
            ScrollViewFuncType.UpdateCellByIndex) -- 更新cell

        if max_count >= count then
            self.list_view:setClickEnabled(false)
        end
    end
    self.list_view:reloadData()
end
-- 创建cell 
-- @width 是setting.item_width
-- @height 是setting.item_height
function CrossshowMainWindow:createNewCellName(width, height)
    local cell = ccui.Layout:create()
    cell:setCascadeOpacityEnabled(true)
    cell:setTouchEnabled(false)
    cell:setAnchorPoint(0, 0)
    cell:setContentSize(cc.size(width, height))

    cell.left_item = {}
    cell.right_item = {}
    -- icon
    --local res = PathTool.getTargetRes("crossshow", "icon_6",false)
       -- loadSpriteTexture(cell.icon, res, LOADTEXT_TYPE)
    local icon_res = PathTool.getTargetRes("crossshow", "icon_6",false)
    cell.left_item.icon = createSprite(icon_res, 146, 163, cell, cc.p(0.5, 0.5), LOADTEXT_TYPE)-- loadSpriteTexture(cell, icon_res, LOADTEXT_TYPE)--createSprite(icon_res, 146, 164, cell, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    cell.left_item.icon:setScale(0.66)

    -- 右边icon
    cell.right_item.icon = createSprite(icon_res, 463, 133, cell, cc.p(0.5, 0.5), LOADTEXT_TYPE)
    cell.right_item.icon:setScale(0.66)

    local res = PathTool.getTargetRes("crossshow", "icon_bg",false)
    cell.left_item.level_bg = createImage(cell, res, 146, 76, cc.p(0.5, 0.5), false, nil, true)
    cell.left_item.level_bg:setContentSize(cc.size(156, 40))
    cell.left_item.level_bg:setCapInsets(cc.rect(14, 20, 2, 0))
    -- 右边背景
    cell.right_item.level_bg = createImage(cell, res, 463, 47, cc.p(0.5, 0.5), false, nil, true)
    cell.right_item.level_bg:setContentSize(cc.size(156, 40))
    cell.right_item.level_bg:setCapInsets(cc.rect(14, 20, 2, 0))

    -- 左边特效
    --local effect_id = Config.EffectData.data_effect_info[377]
    --cell.left_item.cross_effect =
    --    createEffectSpine(effect_id, cc.p(146, 164), cc.p(0.5, 0.5), true, PlayerAction.action)
    --cell.left_item.cross_effect:setScale(0.66)
    --cell:addChild(cell.left_item.cross_effect, 1)
--
    ---- 右边特效
    --effect_id = Config.EffectData.data_effect_info[376]
    --cell.right_item.cross_effect = createEffectSpine(effect_id, cc.p(463, 133), cc.p(0.5, 0.5), true,
    --    PlayerAction.action)
    --cell.right_item.cross_effect:setScale(0.66)
    --cell:addChild(cell.right_item.cross_effect, 1)

    -- 线
    effect_id = Config.EffectData.data_effect_info[378]
    cell.line_effect1 = createEffectSpine(effect_id, cc.p(width * 0.5, 150), cc.p(0.5, 0.5), true, PlayerAction.action)
    cell.line_effect1:setRotation(10)
    cell:addChild(cell.line_effect1, 1)

    -- 线2
    effect_id = Config.EffectData.data_effect_info[378]
    cell.line_effect2 = createEffectSpine(effect_id, cc.p(width * 0.5, 24), cc.p(0.5, 0.5), true, PlayerAction.action)
    cell.line_effect2:setRotation(130)
    cell.line_effect2:setScaleX(1.3)
    cell:addChild(cell.line_effect2, 1)

    -- 左边名字
    cell.left_item.name = createLabel(22, cc.c4b(0xff, 0xe6, 0xce, 0xff), cc.c4b(0x00, 0x00, 0x00, 0xff), 146, 76, "",
        cell, 2, cc.p(0.5, 0.5))
    cell.left_item.world_lev = createLabel(22, cc.c4b(0xff, 0xe6, 0xce, 0xff), cc.c4b(0x00, 0x00, 0x00, 0xff), 146, 40,
        "", cell, 2, cc.p(0.5, 0.5))
    -- 右边名字
    cell.right_item.name = createLabel(22, cc.c4b(0xff, 0xe6, 0xce, 0xff), cc.c4b(0x00, 0x00, 0x00, 0xff), 463, 47, "",
        cell, 2, cc.p(0.5, 0.5))
    cell.right_item.world_lev = createLabel(22, cc.c4b(0xff, 0xe6, 0xce, 0xff), cc.c4b(0x00, 0x00, 0x00, 0xff), 463, 11,
        "", cell, 2, cc.p(0.5, 0.5))
    -- local cell = createRichLabel(24, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5,0.5), cc.p(0,0), nil, nil, 300)

    cell.DeleteMe = function()
        --if cell.left_item.cross_effect then
        --    cell.left_item.cross_effect:clearTracks()
        --    cell.left_item.cross_effect:removeFromParent()
        --    cell.left_item.cross_effect = nil
        --end
--
        --if cell.left_item.cross_effect then
        --    cell.left_item.cross_effect:clearTracks()
        --    cell.left_item.cross_effect:removeFromParent()
        --    cell.left_item.cross_effect = nil
        --end
        if cell.line_effect1 then
            cell.line_effect1:clearTracks()
            cell.line_effect1:removeFromParent()
            cell.line_effect1 = nil
        end
        if cell.line_effect2 then
            cell.line_effect2:clearTracks()
            cell.line_effect2:removeFromParent()
            cell.line_effect2 = nil
        end
    end
    return cell
end
-- 获取数据数量
function CrossshowMainWindow:numberOfCellsName()

    if not self.show_list then
        return 0
    end
    return #self.show_list
end

-- 更新cell(拖动的时候.刷新数据时候会执行次方法)
-- cell :createNewCell的返回的对象
-- inde :数据的索引
function CrossshowMainWindow:updateCellByIndexName(cell, index)
    local data = self.show_list[index]
    if data then
        if data.left_data then --
            if data.left_data.sort_index == 0 then
                cell.left_item.name:setTextColor(cc.c4b(0x7c, 0xd7, 0x5d, 0xff))
            else
                cell.left_item.name:setTextColor(cc.c4b(0xff, 0xe6, 0xce, 0xff))
            end
            cell.left_item.name:setString(data.left_data.srv_name)
            cell.left_item.world_lev:setString(data.left_data.world_name)
        end

        if data.right_data then
            if data.right_data.sort_index == 0 then
                cell.right_item.name:setTextColor(cc.c4b(0x7c, 0xd7, 0x5d, 0xff))
            else
                cell.right_item.name:setTextColor(cc.c4b(0xff, 0xe6, 0xce, 0xff))
            end
            cell.right_item.name:setString(data.right_data.srv_name)
            cell.right_item.world_lev:setString(data.right_data.world_name)

            for k, v in pairs(cell.right_item) do
                v:setVisible(true)
            end
            cell.line_effect1:setVisible(true)
        else
            for k, v in pairs(cell.right_item) do
                v:setVisible(false)
            end
            cell.line_effect1:setVisible(false)
        end

        if index == self:numberOfCellsName() then
            -- 最后一个了..最后一条线不显示
            cell.line_effect2:setVisible(false)
        else
            cell.line_effect2:setVisible(true)
        end
    end
end

-- 设置倒计时(保留代码说不定那天改有时间就惨了)
-- function CrossshowMainWindow:setOpenTime(less_time)
--     if tolua.isnull(self.time_val) then
--         return
--     end
--     local less_time =  less_time or 0
--     self.time_val:stopAllActions()
--     if less_time > 0 then
--         self:setTimeFormatString(less_time)
--         self.time_val:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
--             cc.CallFunc:create(function()
--                 less_time = less_time - 1
--                 if less_time < 0 then
--                     self.time_val:stopAllActions()
--                 else
--                     self:setTimeFormatString(less_time)
--                 end
--             end))))
--     else
--         self:setTimeFormatString(less_time)
--     end
-- end
-- function CrossshowMainWindow:setTimeFormatString(time)
--     if time > 0 then
--         self.time_val:setString(TimeTool.GetTimeDayOrTime(time))
--     else
--         self.time_val:setString("00:00:00")
--     end
--     -- local str = string.format(TI18N(""), TimeTool.GetTimeDayOrTime(time), TI18N("后开启"))
-- end

-- 初始化 icon信息
function CrossshowMainWindow:initCrossInfo()
    local config = Config.CrossShowData.data_base
    self.cross_list = {}
    if config then
        for k, v in pairs(config) do
            table_insert(self.cross_list, v)
        end
    end
    table_sort(self.cross_list, function(a, b)
        return a.id < b.id
    end)
    self:updateCrossList()
end

function CrossshowMainWindow:updateCrossList()
    if not self.cross_list then
        return
    end
    if self.cross_list_view == nil then
        local scroll_view_size = self.icon_scrollview:getContentSize()
        local item_width = 150
        local item_height = 120
        local position_data_list
        local max_count = math.floor(scroll_view_size.width / item_width)
        local count = self:numberOfCells()
        if max_count >= count then
            position_data_list = {}
            -- local s_x = (scroll_view_size.width - item_width * count) * 0.5
            local s_x = 50
            local y = item_height * 0.5
            for i = 1, count do
                local x = s_x + item_width * 0.5 + (i - 1) * item_width
                position_data_list[i] = cc.p(x, y)
            end
        end

        local setting = {
            start_x = 0, -- 第一个单元的X起点
            space_x = 0, -- x方向的间隔
            start_y = 0, -- 第一个单元的Y起点
            space_y = 0, -- y方向的间隔
            item_width = 128, -- 单元的尺寸width
            item_height = item_height, -- 单元的尺寸height
            delay = 1,
            -- row = 1,                        -- 行数，作用于水平滚动类型
            col = 1, -- 列数，作用于垂直滚动类型
            need_dynamic = true,
            position_data_list = position_data_list
        }

        self.cross_list_view = CommonScrollViewSingleLayout.new(self.icon_scrollview,
            cc.p(scroll_view_size.width * 0.5, scroll_view_size.height * 0.5), ScrollViewDir.horizontal,
            ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0.5, 0.5))

        self.cross_list_view:registerScriptHandlerSingle(handler(self, self.createNewCell),
            ScrollViewFuncType.CreateNewCell) -- 创建cell
        self.cross_list_view:registerScriptHandlerSingle(handler(self, self.numberOfCells),
            ScrollViewFuncType.NumberOfCells) -- 获取数量
        self.cross_list_view:registerScriptHandlerSingle(handler(self, self.updateCellByIndex),
            ScrollViewFuncType.UpdateCellByIndex) -- 更新cell
        self.cross_list_view:registerScriptHandlerSingle(handler(self, self.onCellTouched),
            ScrollViewFuncType.OnCellTouched) -- 更新cell

        if max_count >= count then
            self.cross_list_view:setClickEnabled(false)
        end
    end
    self.cross_list_view:reloadData()
end

-- 创建cell 
-- @width 是setting.item_width
-- @height 是setting.item_height
function CrossshowMainWindow:createNewCell(width, height)
    local cell = ccui.Layout:create()
    cell:setCascadeOpacityEnabled(true)
    cell:setTouchEnabled(true)
    cell:setAnchorPoint(0, 0)
    cell:setContentSize(cc.size(width, height))
    local res = PathTool.getResFrame("commonicon", "common_icon_9")
    cell.icon = createSprite(res, width * 0.5, height * 0.5, cell, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    -- cell.name = createRichLabel(24, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5,0.5), cc.p(0,0), nil, nil, 300)
    -- cell.name = createLabel(24,cc.c4b(0x4c,0xb1,0xff,0xff),cc.c4b(0x00,0x00,0x00,0xff), width*0.5 ,30,"",cell,2, cc.p(0.5,0.5))

    cell.goto_info = createLabel(18, cc.c4b(0x7c, 0xd7, 0x5d, 0xff), cc.c4b(0xff, 0xe7, 0xbe, 0xff), width * 0.5 - 2,
        36, "", cell, 2, cc.p(0.5, 0.5))
    cell.lbl_title = createLabel(20, cc.c4b(0xde, 0xb4, 0x6d, 0xff), cc.c4b(0x28, 0x17, 0x0f, 0xff), width * 0.5 - 2,
        15, "", cell, 1, cc.p(0.5, 0.5))

    -- 点击事件
    cell:addTouchEventListener(function(sender, event_type)
        if cell.is_lock then
            return
        end
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:onCellTouched(cell)
        end
    end)

    -- 回收用
    cell.DeleteMe = function()
        if cell.item_load ~= nil then
            cell.item_load:DeleteMe()
            cell.item_load = nil
        end
    end
    return cell
end
-- 获取数据数量
function CrossshowMainWindow:numberOfCells()
    return #self.cross_list
end

-- 更新cell(拖动的时候.刷新数据时候会执行次方法)
-- cell :createNewCell的返回的对象
-- index :数据的索引
function CrossshowMainWindow:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.cross_list[index]
    if data then
        local is_lock, lock_str = self:checkIconLockInfo(data.open_limit)
        --dump(data.open_limit,"限制的等级---》》")
        if is_lock then
            cell.goto_info:disableEffect(cc.LabelEffect.OUTLINE)

            setChildUnEnabled(true, cell)
            cell.goto_info:enableOutline(cc.c4b(0x00, 0x00, 0x00, 0xff), 2)
            cell.goto_info:setString(lock_str)
        else
            setChildUnEnabled(false, cell)
            cell.goto_info:enableOutline(cc.c4b(0x00, 0x00, 0x00, 0xff), 2)
            cell.goto_info:setString(TI18N("点击前往"))
        end
        cell.lbl_title:setString(self.item_names[tonumber(data.icon)])
        -- cell.name:setString(data.name)
        cell.is_lock = is_lock
        local icon_name = string_format("txt_cn_cross_icon_%s", data.icon)
        -- local bg_res = PathTool.getPlistImgForDownLoad("crossshow/cross_icon",icon_name, false)

        -- if cell.record_icon_res ~= bg_res then
        --     cell.record_icon_res = bg_res
        --     cell.item_load = createResourcesLoad(bg_res, ResourcesType.single, function()
        --         if not tolua.isnull(cell.icon) then
        --             loadSpriteTexture(cell.icon, bg_res, LOADTEXT_TYPE)
        --             if is_lock then
        --                 setChildUnEnabled(true, cell)
        --             end
        --         end
        --     end, cell.item_load)
        -- end

        local res = PathTool.getTargetRes("crossshow/cross_icon", 
        string.format("txt_cn_cross_icon_%s", data.icon),
            false)
        loadSpriteTexture(cell.icon, res, LOADTEXT_TYPE)
    end
end

-- 点击cell .需要在 createNewCell 设置点击事件
function CrossshowMainWindow:onCellTouched(cell)
    local index = cell.index
    local data = self.cross_list[index]

    local is_lock, lock_str = self:checkIconLockInfo(data.open_limit)
    if is_lock then
        message(lock_str)
        return
    end

    local config = Config.SourceData.data_source_data[data.source_id]
    if config then
        BackpackController:getInstance():gotoItemSources(config.evt_type, config.extend)
    end
end

function CrossshowMainWindow:checkIconLockInfo(open_limit)
    if not open_limit then
        return
    end
    local is_lock = false
    local lock_str
    for i, v in ipairs(open_limit) do
        if v[1] == "world_lev" then
            if self.world_lev < v[2] then
                is_lock = true
                lock_str = string_format(TI18N("%s世界等级解锁"), v[2])
                break
            end
        elseif v[1] == "lev" then
            if self.role_lev < v[2] then
                is_lock = true
                lock_str = string_format(TI18N("%s级解锁"), v[2])
                break
            end
        elseif v[1] == "guild_war" then
            local checkIsCanOpenGuildWarWindow
        end
    end
    return is_lock, lock_str
end

function CrossshowMainWindow:close_callback()
    if self.list_view then
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    if self.cross_list_view then
        self.cross_list_view:DeleteMe()
        self.cross_list_view = nil
    end

    --if self.cross_effect then
    --    self.cross_effect:clearTracks()
    --    self.cross_effect:removeFromParent()
    --    self.cross_effect = nil
    --end
    if self.scene_effect_1 then
        self.scene_effect_1:clearTracks()
        self.scene_effect_1:removeFromParent()
        self.scene_effect_1 = nil
    end
    if self.scene_effect_2 then
        self.scene_effect_2:clearTracks()
        self.scene_effect_2:removeFromParent()
        self.scene_effect_2 = nil
    end
    -- self.time_val:stopAllActions()
    -- self.king_match_time:stopAllActions()
    controller:openCrossshowMainWindow(false)
end
