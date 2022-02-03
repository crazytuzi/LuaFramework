-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      巅峰冠军赛 我的比赛
-- <br/>Create: 2019年11月19日
ArenapeakchampionMymatchPanel = ArenapeakchampionMymatchPanel or BaseClass(BaseView)

local controller = ArenapeakchampionController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local math_ceil = math.ceil
local math_floor = math.floor

function ArenapeakchampionMymatchPanel:__init()
    -- self.win_type = WinType.Full
    -- self.is_full_screen = true
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arenapeakchampion", "arenapeak_guessing"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/arenapeakchampion", "arenapeakchampion_guessing_centre", false), type = ResourcesType.single},
    }
    self.layout_name = "arenapeakchampion/arenapeakchampion_mymatch_panel"


    self.view_list = {}
    self.tab_list = {}

end

function ArenapeakchampionMymatchPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    local scale = display.getMaxScale() or 1
    self.background:setScale(scale)
    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 1)
    self.container_size = self.container:getContentSize()
    
    self.container_node = self.container:getChildByName("container_node")
    local main_panel = self.container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("我的赛程"))

    self.close_btn = main_panel:getChildByName("close_btn")

    local tab_name_list = {
        [1] = TI18N("我的赛程"),
        [2] = TI18N("比赛记录")
    }
    self.tab_btn_obj = self.container:getChildByName("tab_btn")
    for i=1,2 do
        local tab_btn = {}
        local item = self.tab_btn_obj:getChildByName("tab_btn_"..i)
        tab_btn.btn = item
        tab_btn.index = i
        tab_btn.select_bg = item:getChildByName("select_img")
        tab_btn.select_bg:setVisible(false)
        tab_btn.title = item:getChildByName("label")
        if tab_name_list[i] then
            tab_btn.title:setString(tab_name_list[i])
        end
        self.tab_list[i] = tab_btn
    end
    self.tips_label = self.container:getChildByName("tips_label")
    self.tips_label:setString(TI18N("向下滑动查看更多信息"))
    -- self:adaptationScreen()
end

--设置适配屏幕
function ArenapeakchampionMymatchPanel:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.container)
    local bottom_y = display.getBottom(self.container)
    local left_x = display.getLeft(self.container)
    local right_x = display.getRight(self.container)

    -- local tab_y = self.top_panel:getPositionY()
    -- self.top_panel:setPositionY(top_y - (self.container_size.height - tab_y))

    -- local bottom_panel_y = self.bottom_panel:getPositionY()
    -- self.bottom_panel:setPositionY(bottom_y + bottom_panel_y)
    -- local close_btn_y = self.close_btn:getPositionY()
    -- self.close_btn:setPositionY(bottom_y + close_btn_y)

    -- --多出的高度
    -- local height = (top_y - self.container_size.height) - bottom_y

    -- local size = self.panel_bg:getContentSize()
    -- self.panel_bg:setContentSize(cc.size(size.width, size.height + height))

    -- local size = self.panel_bg_0:getContentSize()
    -- self.panel_bg_0:setContentSize(cc.size(size.width, size.height + height))

    -- local lay_size = self.lay_srollview:getContentSize()
    -- self.lay_srollview:setContentSize(cc.size(lay_size.width, lay_size.height + height))

    -- local time_y = self.time_label:getPositionY()
    -- self.time_label:setPositionY(time_y - height)
    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
end


function ArenapeakchampionMymatchPanel:register_event(  )
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
    for index, tab_btn in pairs(self.tab_list) do
       registerButtonEventListener(tab_btn.btn, function() self:changeTabType(index, true) end ,false, 1) 
    end
end

function ArenapeakchampionMymatchPanel:onClickCloseBtn()
    controller:openArenapeakchampionMymatchPanel(false)
end


function ArenapeakchampionMymatchPanel:setTabBtnVisible(visible)
    if self.tab_btn_obj then
        self.tab_btn_obj:setVisible(visible)
        self.tips_label:setVisible(visible)
    end
end

--@check_repeat_click 是否检查重复点击
function ArenapeakchampionMymatchPanel:changeTabType(index, check_repeat_click)
    if check_repeat_click and self.cur_tab_index == index then return end

    if self.cur_tab ~= nil then
        -- self.cur_tab.label:setTextColor(Config.ColorData.data_color4[141])
        self.cur_tab.select_bg:setVisible(false)
    end
    self.cur_tab_index = index
    self.cur_tab = self.tab_list[self.cur_tab_index]

    if self.cur_tab ~= nil then
        -- self.cur_tab.label:setTextColor(Config.ColorData.data_color4[180])
        self.cur_tab.select_bg:setVisible(true)
    end

    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(false)
        end
    end
    self.pre_panel = self:createSubPanel(self.cur_tab_index)
    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(true, self.cur_tab_index)
        end
    end
end

function ArenapeakchampionMymatchPanel:createSubPanel(index)

    local panel = self.view_list[index]
    if panel == nil then
        if index == 1 then --我的比赛
            panel = ArenapeakchampionMymatchTabForm.new(self) 
        elseif index == 2 then --比赛记录
            panel = ArenapeakchampionMymatchTabRecord.new(self)
        end
        if not panel then return end
        local size = self.container:getContentSize()
        panel:setPosition(cc.p(size.width * 0.5 , size.height * 0.5))
        self.container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end

function ArenapeakchampionMymatchPanel:openRootWnd(setting)
    local setting = setting or {}
    local index = setting.index or 1
    self:changeTabType(index) 
end

function ArenapeakchampionMymatchPanel:close_callback(  )
    if self.view_list then
        for i,v in pairs(self.view_list) do 
            if v and v["DeleteMe"] then
                v:DeleteMe()
            end
        end
    end
    self.view_list = nil
    controller:openArenapeakchampionMymatchPanel(false)
end