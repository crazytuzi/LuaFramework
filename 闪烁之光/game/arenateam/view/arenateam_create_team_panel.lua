-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      创建队伍界面
-- <br/> 2019年10月8日
-- --------------------------------------------------------------------
ArenateamCreateTeamPanel = ArenateamCreateTeamPanel or BaseClass(BaseView)

local controller = ArenateamController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ArenateamCreateTeamPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "arenateam/arenateam_create_team_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }

    self.select_level_index = 1
    self.select_power_index = 1

    self.level_data_list = {}
    self.power_data_list = {}
end

function ArenateamCreateTeamPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("创建队伍"))

    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.main_container:getChildByName("name_key"):setString(TI18N("创建队伍名字:"))
    self.main_container:getChildByName("level_key"):setString(TI18N("入队最低等级:"))
    self.main_container:getChildByName("power_key"):setString(TI18N("入队最低战力:"))
   
    -- self.textField = self.main_container:getChildByName("TextField")

    self.default_msg = TI18N("输入队伍名字")
    local size = cc.size(320,51)
    local res = PathTool.getResFrame("common", "common_1021")
    self.edit_box =  createEditBox(self.main_container, res,size, nil, 24, Config.ColorData.data_color3[151], 20, self.default_msg, nil, nil, LOADTEXT_TYPE_PLIST, nil, nil--[[, cc.KEYBOARD_RETURNTYPE_SEND]])
    self.edit_box:setAnchorPoint(cc.p(0,0))
    self.edit_box:setPlaceholderFontColor(Config.ColorData.data_color4[151])
    self.edit_box:setFontColor(Config.ColorData.data_color4[66])
    self.edit_box:setPosition(cc.p(275,370))
    self.edit_box:setMaxLength(14)
    -- local function editBoxTextEventHandle(strEventName,pSender)
    --     if strEventName == "return" then
    --         local str = pSender:getText()
    --         if GmCmd and GmCmd.show_from_chat and GmCmd:show_from_chat(str) then return end
    --     end
    -- end
    -- if not tolua.isnull(self.edit_box) then
    --     self.edit_box:registerScriptEditBoxHandler(editBoxTextEventHandle)
    -- end

    --等级
    self.level_btn = self.main_container:getChildByName("level_btn")
    self.level_value = self.level_btn:getChildByName("value")
    --战力
    self.power_btn = self.main_container:getChildByName("power_btn")
    self.power_value = self.power_btn:getChildByName("value")

     --下拉框面板
    self.combobox_panel = self.main_container:getChildByName("combobox_panel")
    self.combobox_bg = self.combobox_panel:getChildByName("bg")
    self.combobox_bg_size = self.combobox_bg:getContentSize()
    self.combobox_max_size = cc.size(308, 190) --最大size 根据示意图得出来的

    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("取 消"))
    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("确 定"))


    self.checkbox = self.main_container:getChildByName("checkbox")
    self.checkbox_label = self.checkbox:getChildByName("name")
    self.checkbox_label:setString(TI18N("是否需要审核"))
    self.checkbox:setSelected(false)

    self:onHideComboboxPanel()
end

function ArenateamCreateTeamPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickBtnRight) ,true, 1)

    registerButtonEventListener(self.level_btn, handler(self, self.onClickBtnLevel) ,false, 1)
    registerButtonEventListener(self.power_btn, handler(self, self.onClickBtnPower) ,false, 1)

    registerButtonEventListener(self.main_container, function() self:onHideComboboxPanel()  end ,false, 0)
    -- self:addGlobalEvent(ElitematchEvent.Elite_Declaration_Event, function(data)
    --     if not data then return end
    --     self:setData(data)
    -- end)
end

--提交
function ArenateamCreateTeamPanel:onClickBtnRight()
    if not self.level_data_list then return end
    local name = self.edit_box:getText() or ""
    if name == "" then
        message(self.default_msg)
        return
    end
    local status = self.checkbox:isSelected() or false
    local is_check = 0
    if status then
        is_check = 1
    end

    local limit_lev = 0
    if self.level_data_list[self.select_level_index] then
        limit_lev = self.level_data_list[self.select_level_index].lev
    end
    local limit_power = 0
    if self.power_data_list[self.select_power_index] then
        limit_power = self.power_data_list[self.select_power_index].power
    end

    controller:sender27201(name, limit_lev, limit_power, is_check)
end

--等级
function ArenateamCreateTeamPanel:onClickBtnLevel()
    if not self.level_data_list then return end
    self.combobox_panel:setPositionY(280)
    self:updateComboboxList(self.level_data_list, 1)
end

--战力
function ArenateamCreateTeamPanel:onClickBtnPower()
    if not self.power_data_list then return end
    self.combobox_panel:setPositionY(195)
    self:updateComboboxList(self.power_data_list, 2)
end

--关闭
function ArenateamCreateTeamPanel:onClickBtnClose()
    controller:openArenateamCreateTeamPanel(false)
end

function ArenateamCreateTeamPanel:openRootWnd()
    self:initData()
end

function ArenateamCreateTeamPanel:initData()
    self.level_data_list = {}
    self.power_data_list = {}
    self.select_level_index = 1
    self.select_power_index = 1

    local level_list = Config.ArenaTeamData.data_level_info or {}
    for i,v in ipairs(level_list) do
        local data = {}
        data.lev = v.lev
        if v.lev == 0 then
            data.value = TI18N("不限制")
        else
            data.value = v.lev..TI18N("级")
        end
        table_insert(self.level_data_list, data)
    end
    local power_list = Config.ArenaTeamData.data_power_info or {}
    for i,v in ipairs(power_list) do
        local data = {}
        data.power = v.power
        if v.power == 0 then
            data.value = TI18N("不限制")
        else
            local power = v.power/10000 
            data.value = power..TI18N("万")
        end
        table_insert(self.power_data_list, data)
    end

    if self.level_data_list[self.select_level_index] ~= nil then
        self.level_value:setString(self.level_data_list[self.select_level_index].value)
    end

    if self.power_data_list[self.select_power_index] ~= nil then
        self.power_value:setString(self.power_data_list[self.select_power_index].value)
    end
end



--更新下拉列表 
--_type 类型 1 表示 等级 ,2 表示战力
function ArenateamCreateTeamPanel:updateComboboxList(data_list, _type)
    if not data_list then return end

    self.combobox_type = _type or 1
    local item_height = 54
    if self.combobox_scrollview == nil then
        local setting = {
            start_x = 2,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 308,                -- 单元的尺寸width
            item_height = item_height,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.combobox_scrollview = CommonScrollViewSingleLayout.new(self.combobox_panel, cc.p(4,3) , ScrollViewDir.vertical, ScrollViewStartPos.top, self.combobox_max_size, setting, cc.p(0, 0))

        self.combobox_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.combobox_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.combobox_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    if next(data_list) ~= nil then 
        local count = #data_list
        if count > 4 then
            self.combobox_scrollview:setClickEnabled(true)
            self.combobox_bg:setContentSize(self.combobox_bg_size)
        else
            self.combobox_scrollview:setClickEnabled(false)
            local total_height = count * item_height + (self.combobox_bg_size.height - self.combobox_max_size.height)
            self.combobox_bg:setContentSize(cc.size(self.combobox_bg_size.width, total_height))
        end
        self.show_list = data_list

        if self.combobox_type == 1 then
            self.select_index = self.select_level_index or 1
        else
            self.select_index = self.select_power_index or 1
        end
        self.combobox_scrollview:reloadData(self.select_index)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenateamCreateTeamPanel:createNewCell(width, height)
    local cell = ccui.Layout:create()
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0.5,0.5)
    cell:setTouchEnabled(true)
    cell:setContentSize(cc.size(width, height))

    local size = cc.size(width - 15, 3)
    local res = PathTool.getResFrame("common","common_1016")
    cell.bg = createImage(cell, res, 5, 2, cc.p(0, 0), true, 0, true)
    cell.bg:setContentSize(size)
    cell.bg:setOpacity(90)
    cell.bg:setCapInsets(cc.rect(13, 1, 1, 1))

    -- local res = PathTool.getResFrame("common","common_90058_1")
    -- cell.select_bg = createImage(cell, res, 0, 2, cc.p(0, 0), true, 0, true)
    -- cell.select_bg:setContentSize(size)
    -- -- cell.select_bg:setOpacity(90)
    -- cell.select_bg:setCapInsets(cc.rect(8, 10, 2, 1))
    -- cell.select_bg:setVisible(false)

    cell.label = createLabel(26, cc.c4b(0x64,0x32,0x23,0xff), nil, 10, height * 0.5 , "", cell, nil, cc.p(0,0.5))

    -- local mark_res = PathTool.getResFrame("common", "common_1043")
    -- cell.mark_img = createSprite(mark_res, width - 10, height * 0.5 + 2, cell, cc.p(1,0.5), LOADTEXT_TYPE_PLIST)
    -- cell.mark_img:setScale(0.8)

    -- registerButtonEventListener(cell, function() self:setCellTouched(cell) end ,false, 1)
    cell:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            -- cell.select_bg:setVisible(true)
            cell.touch_began = sender:getTouchBeganPosition()
        elseif event_type == ccui.TouchEventType.moved then
            -- cell.select_bg:setVisible(false)
        elseif event_type == ccui.TouchEventType.ended then
            local touch_began = cell.touch_began
            local touch_end = sender:getTouchEndPosition()
            if touch_began and touch_end and (math.abs(touch_end.x - touch_began.x) > 10 or math.abs(touch_end.y - touch_began.y) > 10) then 
                --点击无效了
                return
            end 

            playButtonSound2()
            self:setCellTouched(cell)
        end
    end)
    return cell
end

--获取数据数量
function ArenateamCreateTeamPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenateamCreateTeamPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    -- cell.select_bg:setVisible(false)
    cell.label:setString(data.value)

    -- if self.select_index  == index then
    --     cell.mark_img:setVisible(true)
    -- else
    --     cell.mark_img:setVisible(false)
    -- end
end

--点击cell .需要在 createNewCell 设置点击事件
function ArenateamCreateTeamPanel:setCellTouched(cell)
    local index = cell.index
    local data = self.show_list[index]
    if not data then return end
    if self.combobox_type == 1 then --等级
        self.select_level_index = index
        self.level_value:setString(data.value)
    else --战力
        self.select_power_index = index
        self.power_value:setString(data.value)
    end
    self:onHideComboboxPanel()
end

--隐藏列表
function ArenateamCreateTeamPanel:onHideComboboxPanel()
    -- body
    if self.combobox_panel then
        self.combobox_panel:setPositionY(-10000)
    end
end


function ArenateamCreateTeamPanel:close_callback()
    if self.combobox_scrollview then
        self.combobox_scrollview:DeleteMe()
        self.combobox_scrollview = nil
    end
    controller:openArenateamCreateTeamPanel(false)
end