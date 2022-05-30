-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      竞猜界面
-- <br/> 2019年11月13日
-- --------------------------------------------------------------------
ArenapeakchampionGuessingTabPromotion = class("ArenapeakchampionGuessingTabPromotion", function()
    return ccui.Widget:create()
end)

local controller = ArenapeakchampionController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format
local table_sort = table.sort

function ArenapeakchampionGuessingTabPromotion:ctor(parent)
    self.parent = parent
    self.role_vo = RoleController:getInstance():getRoleVo()
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function ArenapeakchampionGuessingTabPromotion:config()

    self.match_panel_list = {}

    --按钮的宽度
    self.item_width = 123

    --中间按钮显示 1:表示显示 64 强 ; 2: 表示 8强
    self.centre_btn_index = 0
end

function ArenapeakchampionGuessingTabPromotion:layoutUI()
    local csbPath = PathTool.getTargetCSB("arenapeakchampion/arenapeakchampion_guessing_tab_promotion")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.container = self.root_wnd:getChildByName("container")
    -- self.container:setSwallowTouches(false)

    self.zone_status = self.container:getChildByName("zone_status")
    self.zone_status:setString("")
    self.time_label = self.container:getChildByName("time_label")
    self.time_label:setString("--:--")
    self.zone_name = self.container:getChildByName("zone_name")
    self.zone_name:setString("--")

    self.zone_btn = self.container:getChildByName("zone_btn")
    self.zone_icon = self.container:getChildByName("promotion_16")
        --中间切换按钮
    self.centre_btn = self.container:getChildByName("centre_btn")
    self.centre_btn_label = self.centre_btn:getChildByName("label")
    self.centre_btn:setVisible(false)
    --底下两个左右按钮
    self.bootom_left_btn = self.container:getChildByName("bootom_left_btn")
    self.bootom_right_btn = self.container:getChildByName("bootom_right_btn")
    self.bottom_bg = self.container:getChildByName("bottom_bg")

    self.tips_label = self.container:getChildByName("tips_label")
    self.tips_label:setString(TI18N("向下滑动查看更多"))
    self.lay_scrollview = self.container:getChildByName("lay_scrollview")
    self.lay_scrollview_size = self.lay_scrollview:getContentSize()

    self.lay_scrollview_centre = self.container:getChildByName("lay_scrollview_centre")
    self.lay_scrollview_centre_size = self.lay_scrollview_centre:getContentSize()
    self.centre_scroll_view = createScrollView(self.lay_scrollview_centre_size.width, self.lay_scrollview_centre_size.height, 0, 0, self.lay_scrollview_centre, ScrollViewDir.vertical) 
    self.match_panel_height = 782 --这个是ui那边量出来的
    --默认就两个的高度
    self.centre_scroll_view_height = self.match_panel_height * 2
    self.centre_scroll_view:setInnerContainerSize(cc.size(720, self.centre_scroll_view_height))

    self.stage_label = self.container:getChildByName("stage_label")
    if self.stage_label then
        self.stage_label:setString("")
    end
    self:updateTime()
end

--事件
function ArenapeakchampionGuessingTabPromotion:registerEvents()
    registerButtonEventListener(self.look_btn, function() self:onClickLookBtn()  end ,true, 1)
    registerButtonEventListener(self.bootom_left_btn, function() self:onClickTurnBtn(-1)  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.bootom_right_btn, function() self:onClickTurnBtn(1)  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.centre_btn, function() self:onClickCentreBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.zone_btn, function() self:onClickZoneBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    --64强 晋级赛
    if self.top_64_event == nil then
        self.top_64_event = GlobalEvent:getInstance():Bind(ArenapeakchampionEvent.ARENAPEAKCHAMPION_TOP_64_EVENT,function ( )
            self:initData()
        end)
    end
    --8强
    if self.top_8_event == nil then
        self.top_8_event = GlobalEvent:getInstance():Bind(ArenapeakchampionEvent.ARENAPEAKCHAMPION_TOP_8_EVENT,function ( data )
            self:initData()
        end)
    end

     --主面板信息 更新时间状态用
    if self.apc_main_event == nil then
        self.apc_main_event = GlobalEvent:getInstance():Bind(ArenapeakchampionEvent.ARENAPEAKCHAMPION_MAIN_EVENT,function ( data )
            self:updateTime()
        end)
    end 
end

function ArenapeakchampionGuessingTabPromotion:updateTime()
    if not self.zone_status then return end
    if not self.time_label then return end
    local main_data = model:getMainData()
    if main_data then 
        if main_data.step ~= 0  then
            doStopAllActions(self.time_label)
            local time = main_data.round_status_time - GameNet:getInstance():getTime() 
            if time < 0 then
                time = 0
            end
            commonCountDownTime(self.time_label, time)
        
            if self.select_zone_index == nil then
                self.zone_name:setString(string_format(TI18N("第%s赛区"), main_data.zone_id))
            end
            local _, str1 = model:getMacthText( main_data.step,  main_data.round, main_data.round_status)
            if self.stage_label then
                self.stage_label:setString((str1 or ""))
            end
        elseif main_data.step_status == 2 then
            self.time_label:setString("--:--")
            if self.select_zone_index == nil then
                self.zone_name:setString(string_format(TI18N("第%s赛区"), main_data.zone_id))
            end
            local _, str1 = model:getMacthText( main_data.step,  main_data.round, main_data.round_status)
            if self.stage_label then
                self.stage_label:setString((str1 or ""))
            end
        else
            self.zone_status:setString("")
            self.time_label:setString("--:--")
            self.zone_name:setString("--")
            if self.stage_label then
                self.stage_label:setString(TI18N("未开赛"))
            end 
        end
    else
        self.zone_status:setString("")
        self.time_label:setString("--:--")
        self.zone_name:setString("--")
        if self.stage_label then
            self.stage_label:setString(TI18N("未开赛"))
        end
    end

end

function ArenapeakchampionGuessingTabPromotion:onClickZoneBtn()
    local main_data = model:getMainData()
    if main_data == nil or main_data.step == 0 then
        return
    end
    if main_data.max_zone_id == 0 then
        return
    end
    self.main_data = main_data
    local world_pos = self.zone_btn:convertToWorldSpace(cc.p(0, 0))
    if not self.zone_list then
        self.zone_list = {}
        for i=1,main_data.max_zone_id do
            local value = string_format(TI18N("第%s赛区"), i)
            table_insert(self.zone_list, {id = i, value = value})
        end
        table_sort(self.zone_list, SortTools.KeyLowerSorter("id"))
    end
    local setting = {}
    setting.other_index = main_data.zone_id or 1
    setting.select_index = self.select_zone_index or setting.other_index

    setting.offsetx = 120 - 12
    setting.offsety = 0
    setting.combobox_max_size = cc.size(236, 190)
    setting.combobox_bg_size = cc.size(244, 198)
    setting.dir_type = 1
    setting.combo_show_type = 2
    CommonUIController:getInstance():openCommonComboboxPanel(true, world_pos, handler(self, self.onChoseZoneBtn), self.zone_list, setting )
end

function ArenapeakchampionGuessingTabPromotion:onChoseZoneBtn(index, data, setting)
    if not self.main_data then return end
    self.current_zone = data.id
    if self.tab_type == ArenapeakchampionConstants.guessing_tab.ePromotion then --晋级赛
        controller:sender27709(self.current_zone, 1) --256强 
    else
        self:checkSender()
    end
    self.select_zone_index = index
    self.zone_name:setString(data.value)
    if self.main_data.zone_id == data.id then
        self.zone_icon:setVisible(true)
    else
        self.zone_icon:setVisible(false)
    end
end

--点击 64 和 8强切换
function ArenapeakchampionGuessingTabPromotion:onClickCentreBtn()
    if self.centre_btn_index == 1 then
        self.centre_btn_index = 2
    else
        self.centre_btn_index = 1
    end
    self:checkSender()
    self:updateName()
end

--@hero_vo 宝可梦数据
function ArenapeakchampionGuessingTabPromotion:initData()

    local count = 0

    if self.tab_type ==  ArenapeakchampionConstants.guessing_tab.ePromotion then --晋级赛
        count = model.max_group_256[self.current_zone] or 16
        self.select_index = self.select_group_256 or 1
        -- self:updateCentreInfo256(self.select_index)
    else 
        if self.centre_btn_index == 1 then -- 64强
            count = model.max_group_64[self.current_zone] or 8
            self.select_index = self.select_group_64 or 1
            -- self:updateCentreInfo64(self.select_index)
        else
            self:updateCentreInfo8()
        end
    end
    
    if count > 0 then
        self.bootom_left_btn:setVisible(true)
        self.bootom_right_btn:setVisible(true)
        self.bottom_bg:setVisible(true)
        self.lay_scrollview:setVisible(true)

        self.show_list = {}
        for i=1,count do
            table_insert(self.show_list, i)
        end
        self:updateList()
    else
        self.bootom_left_btn:setVisible(false)
        self.bootom_right_btn:setVisible(false)
        self.bottom_bg:setVisible(false)
        self.lay_scrollview:setVisible(false)
    end
end

function ArenapeakchampionGuessingTabPromotion:initMatchPanelList(count, is_show, data_list, match_type)
    if not count then return end
    if not self.centre_scroll_view then return end
    for i,v in ipairs(self.match_panel_list) do
        v:setVisible(false)
    end

    for i=1,count do
        if self.match_panel_list[i] == nil then
            self.match_panel_list[i] = MatchImgPanel.new()    
            local y = self.centre_scroll_view_height - (i-1 + 0.5) * self.match_panel_height
            self.match_panel_list[i]:setPosition(360, y)
            self.centre_scroll_view:addChild(self.match_panel_list[i])
        else
            self.match_panel_list[i]:setVisible(true)
            if count == 2 and i == 1 then --说明是晋级赛的 位置可能被打开冠军赛的时候调整过 需要摆正回来 
                local y = self.centre_scroll_view_height - (i-1 + 0.5) * self.match_panel_height
                self.match_panel_list[i]:setPosition(360, y)
            end
        end
        self.match_panel_list[i]:setCetrePanelVisible(is_show)

        if data_list and data_list[i] then
            self.match_panel_list[i]:setData(data_list[i], match_type)
            self.match_panel_list[i]:setExtendDdata(self.current_zone, self.select_index)
        else
            self.match_panel_list[i]:setData(nil, match_type)
        end
    end
    if count == 1 and self.match_panel_list[1] then
        --冠军赛的..需要居中显示
        local size = self.centre_scroll_view:getContentSize()
        local y = self.centre_scroll_view_height - ((size.height - self.match_panel_height) * 0.5 + self.match_panel_height * 0.5)
        self.match_panel_list[1]:setPosition(360, y)
    end

end

function ArenapeakchampionGuessingTabPromotion:updateList()
    if not self.lay_scrollview then return end
    if self.item_scrollview == nil then
        local scroll_view_size = self.lay_scrollview_size
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = self.item_width,    -- 单元的尺寸width
            item_height = 50,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.lay_scrollview, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end

    self.item_scrollview:reloadData(self.select_index or 1)
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenapeakchampionGuessingTabPromotion:createNewCell(width, height)
    local cell = ccui.Widget:create()
    cell:setAnchorPoint(0.5,0.5)
    cell:setContentSize(cc.size(width, height))
    cell:setTouchEnabled(true)

    -- local res = PathTool.getResFrame("arenapeakchampion", "arenapeakchampion_promotion_08", false, "arenapeak_guessing")
    -- cell.left_img = createSprite(res, -0.5, height * 0.5, cell, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    -- cell.right_img = createSprite(res, width + 0.5, height * 0.5, cell, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)

    -- local select_res = PathTool.getResFrame("arenapeakchampion", "arenapeakchampion_promotion_09", false, "arenapeak_guessing")
    local select_res = PathTool.getResFrame("common", "common_1018")
    cell.select_img = createSprite(select_res, width * 0.5, height * 0.5, cell, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    cell.select_img:setScale(0.7)

    local unselect_res = PathTool.getResFrame("common", "common_1017")
    cell.unselect_img = createSprite(unselect_res, width * 0.5, height * 0.5, cell, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    cell.unselect_img:setScale(0.7)
    cell.unselect_img:setOpacity(178)

    cell.text_label = createLabel(20,Config.ColorData.data_new_color4[1],nil,width * 0.5, height * 0.5,"0",cell, nil, cc.p(0.5,0.5))

    registerButtonEventListener(cell, function() self:onCellTouched(cell) end ,false, 2)
    return cell
end
--获取数据数量
function ArenapeakchampionGuessingTabPromotion:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenapeakchampionGuessingTabPromotion:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell.text_label:setString(StringUtil.numToChinese(index))
    if self.select_index == index then
        cell.select_img:setVisible(true)
        cell.unselect_img:setVisible(false)
        cell.text_label:enableOutline(Config.ColorData.data_new_color4[10], 2)
        -- cell.text_label:disableEffect(cc.LabelEffect.OUTLINE)
        -- cell.text_label:setTextColor(cc.c4b(0x69,0x37,0x05,0xff))
    else
        cell.select_img:setVisible(false)
        cell.unselect_img:setVisible(true)
        cell.text_label:enableOutline(Config.ColorData.data_new_color4[6], 2)
        -- cell.text_label:enableOutline(cc.c4b(0x58,0x2d,0x14,0xff), 2)
        -- cell.text_label:setTextColor(cc.c4b(0xf4,0xdc,0xa1,0xff))
    end
end

function ArenapeakchampionGuessingTabPromotion:onCellTouched(cell)
    local index = cell.index
    if not index then return end
    self.select_index = index
    self:updateSelectIndex()
end

function ArenapeakchampionGuessingTabPromotion:onClickTurnBtn(num)
    if not self.select_index then return end
    local max_index = self:numberOfCells()
    if max_index == 0 then return end
    self.select_index = self.select_index + num
    if self.select_index <= 0 then
        self.select_index = 1
    elseif self.select_index > max_index then
        self.select_index = max_index
    end
    self:updateSelectIndex()
end

function ArenapeakchampionGuessingTabPromotion:updateSelectIndex()
    if not self.select_index then return end
    if not self.lay_scrollview_size then return end
    -- self.item_scrollview.scroll_view:stopAutoScroll() --先停止滑动.否则算的可能会错
    local new_item = self.item_scrollview:getCellByIndex(self.select_index)
    if not new_item then return end
    local x  = self.item_scrollview:getCellXYByIndex(self.select_index)
    x = x - self.item_width * 0.5
    local x1 = x + self.item_width
    local container_x = -self.item_scrollview:getContainerXY() --因为位置是负数的..
    local container_x1 = container_x + self.lay_scrollview_size.width

    if self.select_item then
        self.select_item.select_img:setVisible(false)
        self.select_item.unselect_img:setVisible(true)
        self.select_item.text_label:enableOutline(Config.ColorData.data_new_color4[6], 2)
        -- self.select_item.text_label:enableOutline(cc.c4b(0x58,0x2d,0x14,0xff), 2)
        -- self.select_item.text_label:setTextColor(cc.c4b(0xf4,0xdc,0xa1,0xff))
    end

    self.select_item = new_item

    if self.select_item then
        self.select_item.select_img:setVisible(true)
        self.select_item.unselect_img:setVisible(false)
        self.select_item.text_label:enableOutline(Config.ColorData.data_new_color4[10], 2)
        -- self.select_item.text_label:disableEffect(cc.LabelEffect.OUTLINE)
        -- self.select_item.text_label:setTextColor(cc.c4b(0x69,0x37,0x05,0xff))
    end
    if x < container_x or x1 < container_x then
        --在左边
        self.item_scrollview:setContainerXY(-x)
        self.item_scrollview:checkRectIntersectsRect()
    elseif x > container_x1 or x1 > container_x1 then
        --在右边
        self.item_scrollview:setContainerXY(-(x1 - self.lay_scrollview_size.width))
        self.item_scrollview:checkRectIntersectsRect()
    end 

    if self.tab_type ==  ArenapeakchampionConstants.guessing_tab.ePromotion then --晋级赛
        self.select_group_256 = self.select_index
        self:updateCentreInfo256(self.select_index)
    else 
        if self.centre_btn_index == 1 then
            self.select_group_64 = self.select_index
            self:updateCentreInfo64(self.select_index)
        else
            self:updateCentreInfo8()
        end
    end
end

--256 需要把数据转成可以用数据
function ArenapeakchampionGuessingTabPromotion:changeData(pos_list)
    local data_list = {}
    data_list[1] = {}
    data_list[2] = {}
    local new_pos_index = {1,2,3,4,1,2,3,4,5,6,7,8,5,6,7,8,9,10,9,10,11,12,11,12,13,14,13,14}
    for i,v in ipairs(pos_list) do
        v.new_pos = new_pos_index[v.pos]
        if (v.pos >= 1 and v.pos <= 4 ) or 
            (v.pos >= 9 and v.pos <= 12 ) or 
            v.pos == 17 or v.pos == 18 or v.pos == 21 or v.pos == 22 or v.pos == 25 or v.pos == 26 then
            table_insert(data_list[1], v)
        else
            table_insert(data_list[2], v)
        end
    end
    return data_list
end

--更新界面信息256
function ArenapeakchampionGuessingTabPromotion:updateCentreInfo256(group)
    local pos_list = model:getMatchData256ByGroup(group, self.current_zone)
    if pos_list and next(pos_list) ~= nil then
        table_sort( pos_list, function(a, b) return a.pos < b.pos end)
        local data_list = self:changeData(pos_list)
        self:initMatchPanelList(2, false, data_list, 256)
    else
        self:initMatchPanelList(2, false, nil, 256)
    end
end
--更新界面信息64
function ArenapeakchampionGuessingTabPromotion:updateCentreInfo64(group)
    local pos_list = model:getMatchData64ByGroup(group, self.current_zone)
    if pos_list and next(pos_list) ~= nil then
        table_sort( pos_list, function(a, b) return a.pos < b.pos end)
        self:initMatchPanelList(1, true, {pos_list}, 64)
    else
        self:initMatchPanelList(1, true, nil, 64)
    end
end

--更新界面信息8
function ArenapeakchampionGuessingTabPromotion:updateCentreInfo8()
    local pos_list = model:getMatchData8(self.current_zone)
    if pos_list and next(pos_list) ~= nil then
        table_sort( pos_list, function(a, b) return a.pos < b.pos end)
        self:initMatchPanelList(1, true, {pos_list}, 8)
    else
        self:initMatchPanelList(1, true, nil, 8)
    end
end

function ArenapeakchampionGuessingTabPromotion:setVisibleStatus(bool, index)
    self:setVisible(bool)
    if bool and self.centre_scroll_view then
        local main_data = model:getMainData()
        if self.current_zone == nil then --默认值
            self.current_zone = 0
        end
        self.tab_type = index
            
        if self.tab_type == ArenapeakchampionConstants.guessing_tab.ePromotion then --晋级赛
            self.centre_btn:setVisible(false)
            self.centre_scroll_view:setTouchEnabled(true)
            

            if main_data and main_data.step ~= 0 then
                if  self.current_zone == 0 then
                    self.current_zone = main_data.zone_id
                end
                if model:getMatchData256ByGroup(1, self.current_zone) then
                    self:initData()
                else
                    controller:sender27709(self.current_zone, 1) --256强    
                end
            else
                self:initData()
            end
        else --冠军赛
            self.centre_btn:setVisible(true)
            self.centre_scroll_view:setTouchEnabled(false)
            self.centre_scroll_view:stopAutoScroll() --停止自动滚动
            local container = self.centre_scroll_view:getInnerContainer() 
            local size = self.centre_scroll_view:getContentSize()
            container:setPosition(0, size.height - self.centre_scroll_view_height)--设置固定位置
            self:checkSender()
        end
        self:updateName()
    end
end

function ArenapeakchampionGuessingTabPromotion:updateName()
    if self.tab_type == ArenapeakchampionConstants.guessing_tab.ePromotion then --晋级赛
        self.zone_status:setString(TI18N("晋级赛 256进64"))
        if self.tips_label then
            self.tips_label:setVisible(true)
            local fadein = cc.FadeIn:create(0.8)
            local fadeout = cc.FadeOut:create(0.8)
            local fadein1 = cc.FadeIn:create(1)
            local fadeout1 = cc.FadeOut:create(1)
            self.tips_label:setVisible(true)
            self.tips_label:runAction(cc.Sequence:create(fadein, fadeout, fadein1, fadeout1,cc.CallFunc:create(function()
                self.tips_label:setVisible(false)
            end)))
        end
    else --冠军赛
        if self.tips_label then
            doStopAllActions(self.tips_label)
            self.tips_label:setVisible(false)
        end
        if self.centre_btn_index and self.centre_btn_index == 1 then
            self.zone_status:setString(TI18N("冠军赛 64进8"))
        else
            self.zone_status:setString(TI18N("冠军赛 8强赛"))
        end
    end
end

--冠军赛的检查发送协议
--是否需要设置中间按钮的样式
function ArenapeakchampionGuessingTabPromotion:checkSender()
    local main_data = model:getMainData()
    if not main_data then return end

    if self.centre_btn_index == 0 then
        if main_data.step ~= 0 then 
            if  self.current_zone == 0 then
                self.current_zone = main_data.zone_id
            end
            if main_data.step == 8 then
                --只有是8强赛的时候 显示8强 其他时间都默认显示64强赛
                self.centre_btn_index = 2
                controller:sender27710( self.current_zone)
            else
                self.centre_btn_index = 1
                controller:sender27709( self.current_zone, 2) 
            end
        else
            self.centre_btn_index = 1
            self:initData()
        end
        self:updateCentreBtnImg()
       
    else
        if self.centre_btn_index == 1 then
            if main_data.step ~= 0 then 
                if model:getMatchData64ByGroup(1, self.current_zone) then
                    self:initData()
                else
                    controller:sender27709( self.current_zone, 2) 
                end
            else
                self:initData()
            end
        else
            self.centre_btn_index = 2
             if main_data.step ~= 0 then 
                if model:getMatchData8(self.current_zone) then
                    self:initData()
                else
                    controller:sender27710( self.current_zone)
                end
            else
                self:initData()
            end
            
        end
        self:updateCentreBtnImg()
    end
end

function ArenapeakchampionGuessingTabPromotion:updateCentreBtnImg()
    if self.centre_btn_index == 2 then
        -- self.centre_btn:loadTexture(PathTool.getResFrame("arenapeakchampion", "arenapeakchampion_promotion_06", false, "arenapeak_guessing"), LOADTEXT_TYPE_PLIST)
        self.centre_btn_label:setString(TI18N("64进8"))
    else
        -- self.centre_btn:loadTexture(PathTool.getResFrame("arenapeakchampion", "arenapeakchampion_promotion_07", false, "arenapeak_guessing"), LOADTEXT_TYPE_PLIST)
        self.centre_btn_label:setString(TI18N("8强赛"))
    end
end

--移除
function ArenapeakchampionGuessingTabPromotion:DeleteMe()
    self.parent = nil
    doStopAllActions(self.time_label)
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    if self.top_64_event then
        GlobalEvent:getInstance():UnBind(self.top_64_event)
        self.top_64_event = nil
    end

    if self.top_8_event then
        GlobalEvent:getInstance():UnBind(self.top_8_event)
        self.top_8_event = nil
    end

    if self.apc_main_event then
        GlobalEvent:getInstance():UnBind(self.apc_main_event)
        self.apc_main_event = nil
    end
    if self.match_panel_list then
        for i,v in ipairs(self.match_panel_list) do
            v:DeleteMe()
        end
        self.match_panel_list = nil
    end

    -- if self.item_load_title then
    --     self.item_load_title:DeleteMe()
    --     self.item_load_title = nil
    -- end

    -- if self.role_update_event and self.role_vo then
    --     self.role_update_event = self.role_vo:UnBind(self.role_update_event)
    --     self.role_update_event = nil
    -- end
end
