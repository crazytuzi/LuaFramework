-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      队伍改名
-- <br/> 2019年10月11日
-- --------------------------------------------------------------------
ArenateamChangTeamNamePanel = ArenateamChangTeamNamePanel or BaseClass(BaseView)

local controller = ArenateamController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ArenateamChangTeamNamePanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "arenateam/arenateam_chang_team_name_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }
end

function ArenateamChangTeamNamePanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("队伍改名"))

    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.default_msg = TI18N("输入队伍名字")
    local size = cc.size(320,50)
    local res = PathTool.getResFrame("common", "common_1021")
    self.edit_box =  createEditBox(self.main_container, res,size, nil, 24, Config.ColorData.data_color3[151], 20, self.default_msg, nil, nil, LOADTEXT_TYPE_PLIST, nil, nil--[[, cc.KEYBOARD_RETURNTYPE_SEND]])
    self.edit_box:setAnchorPoint(cc.p(0,0))
    self.edit_box:setPlaceholderFontColor(Config.ColorData.data_color4[151])
    self.edit_box:setFontColor(Config.ColorData.data_color4[66])
    self.edit_box:setPosition(cc.p(180,176))
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
    self.name_key = self.main_container:getChildByName("name_key")
    self.name_key:setString(TI18N("请输入队伍新名字:"))
    
    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("取 消"))
    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("确 定"))
end

function ArenateamChangTeamNamePanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickBtnRight) ,true, 1)

end

--提交
function ArenateamChangTeamNamePanel:onClickBtnRight()
    local name = self.edit_box:getText() or ""
    if name == "" then
        message(self.default_msg)
        return
    end
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_CHANGE_NAME_CALLBACK, name)
    controller:sender27226(name)
    self:onClickBtnClose()
end

--关闭
function ArenateamChangTeamNamePanel:onClickBtnClose()
    controller:openArenateamChangTeamNamePanel(false)
end

function ArenateamChangTeamNamePanel:openRootWnd(setting)
    local setting = setting or {}
    local name = setting.name or ""
    if self.edit_box then
        self.edit_box:setText(name)
    end
end

function ArenateamChangTeamNamePanel:initData()
    self.level_data_list = {}
    self.power_data_list = {}
    self.select_level_index = 1
    self.select_power_index = 1

    for i=1,10 do
        local level = i * 10
        local data = {}
        data.value = level..TI18N("级")
        table_insert(self.level_data_list, data)
    end

    for i=1,10 do
        local level = i * 100
        local data = {}
        data.value = level..TI18N("万")
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
function ArenateamChangTeamNamePanel:updateComboboxList(data_list, _type)
    if not data_list then return end

    self.combobox_type = _type or 1
    local item_height = 42
    if self.combobox_scrollview == nil then
        local setting = {
            start_x = 2,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 175,                -- 单元的尺寸width
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
function ArenateamChangTeamNamePanel:createNewCell(width, height)
    local cell = ccui.Layout:create()
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0.5,0.5)
    cell:setTouchEnabled(true)
    cell:setContentSize(cc.size(width, height))

    local size = cc.size(width, height - 2)
    local res = PathTool.getResFrame("common","common_90058")
    cell.bg = createImage(cell, res, 0, 2, cc.p(0, 0), true, 0, true)
    cell.bg:setContentSize(size)
    cell.bg:setOpacity(90)
    cell.bg:setCapInsets(cc.rect(15, 15, 1, 1))

    local res = PathTool.getResFrame("common","common_90058_1")
    cell.select_bg = createImage(cell, res, 0, 2, cc.p(0, 0), true, 0, true)
    cell.select_bg:setContentSize(size)
    -- cell.select_bg:setOpacity(90)
    cell.select_bg:setCapInsets(cc.rect(8, 10, 2, 1))
    cell.select_bg:setVisible(false)

    cell.label = createLabel(22, cc.c4b(0x64,0x32,0x23,0xff), nil, 10, height * 0.5 , "", cell, nil, cc.p(0,0.5))

    local mark_res = PathTool.getResFrame("common", "common_1043")
    cell.mark_img = createSprite(mark_res, width - 10, height * 0.5 + 2, cell, cc.p(1,0.5), LOADTEXT_TYPE_PLIST)
    cell.mark_img:setScale(0.8)

    -- registerButtonEventListener(cell, function() self:setCellTouched(cell) end ,false, 1)
    cell:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            cell.select_bg:setVisible(true)
            cell.touch_began = sender:getTouchBeganPosition()
        elseif event_type == ccui.TouchEventType.moved then
            cell.select_bg:setVisible(false)
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
function ArenateamChangTeamNamePanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenateamChangTeamNamePanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    cell.select_bg:setVisible(false)
    cell.label:setString(data.value)

    if self.select_index  == index then
        cell.mark_img:setVisible(true)
    else
        cell.mark_img:setVisible(false)
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function ArenateamChangTeamNamePanel:setCellTouched(cell)
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
function ArenateamChangTeamNamePanel:onHideComboboxPanel()
    -- body
    if self.combobox_panel then
        self.combobox_panel:setPositionY(-10000)
    end
end


function ArenateamChangTeamNamePanel:close_callback()

    if self.combobox_scrollview then
        self.combobox_scrollview:DeleteMe()
        self.combobox_scrollview = nil
    end
    controller:openArenateamChangTeamNamePanel(false)
end