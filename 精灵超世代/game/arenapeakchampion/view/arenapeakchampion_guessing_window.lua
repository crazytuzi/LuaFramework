-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      巅峰冠军赛竞猜界面 后端 锋林 策划 中建
-- <br/>Create: 2019年11月12日
ArenapeakchampionGuessingWindow = ArenapeakchampionGuessingWindow or BaseClass(BaseView)

local controller = ArenapeakchampionController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local math_ceil = math.ceil
local math_floor = math.floor

function ArenapeakchampionGuessingWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arenapeakchampion", "arenapeak_guessing"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/arenapeakchampion", "arenapeakchampion_guessing_bg", true), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_92", false), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_116", false), type = ResourcesType.single},
    }
    self.layout_name = "arenapeakchampion/arenapeakchampion_guessing_window"


    self.view_list = {}
    self.tab_list = {}

end

function ArenapeakchampionGuessingWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    local scale = display.getMaxScale() or 1
    self.background:setScale(scale)
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/arenapeakchampion", "arenapeakchampion_guessing_bg", true), LOADTEXT_TYPE)



    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 1)
    self.container_size = self.container:getContentSize()
    
    local bg = self.container:getChildByName("bg")
    self.bg_2 = bg:getChildByName("bg_2")
    self.bg_2:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_116"), LOADTEXT_TYPE)
    self.top_img = self.container:getChildByName("top_img")
    local res  = PathTool.getPlistImgForDownLoad("bigbg/arenapeakchampion","txt_cn_arenapeakchampion_guessing_title", false)
    self.item_load = loadSpriteTextureFromCDN(self.top_img, res, ResourcesType.single, self.item_load) 

    self.container_node = self.container:getChildByName("container_node")

    self.close_btn = self.container:getChildByName("close_btn")

    local tab_name_list = {
        [1] = TI18N("竞猜"),
        [2] = TI18N("晋级赛"),
        [3] = TI18N("冠军赛")
    }
    local tab_btn_obj = self.container:getChildByName("tab_btn")
    for i=1,3 do
        local tab_btn = {}
        local item = tab_btn_obj:getChildByName("tab_btn_"..i)
        tab_btn.btn = item
        tab_btn.index = i
        tab_btn.select_bg = item:getChildByName("select_img")
        tab_btn.select_bg:setVisible(false)
        tab_btn.title = item:getChildByName("label")
        tab_btn.title:setTextColor(Config.ColorData.data_new_color4[6])
        if tab_name_list[i] then
            tab_btn.title:setString(tab_name_list[i])
        end
        self.tab_list[i] = tab_btn
    end

    -- self:adaptationScreen()
end

--设置适配屏幕
function ArenapeakchampionGuessingWindow:adaptationScreen()
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


function ArenapeakchampionGuessingWindow:register_event(  )
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
    for index, tab_btn in pairs(self.tab_list) do
       registerButtonEventListener(tab_btn.btn, function() self:changeTabType(index, true) end ,false, 1) 
    end

    -- 红点
    self:addGlobalEvent(ArenapeakchampionEvent.ARENAPEAKCHAMPION_ALL_RED_POINT_EVENT, function (  )
        self:updateRedPoint()
    end)
end

function ArenapeakchampionGuessingWindow:updateRedPoint()
    if not self.tab_list then return end
    if self.tab_list[1] and self.tab_list[1].btn and self.cur_tab_index ~= ArenapeakchampionConstants.guessing_tab.eGuessing then
        local status = model:getGuessRedPoint()
        addRedPointToNodeByStatus(self.tab_list[1].btn, status, 5, 5)
    else
        addRedPointToNodeByStatus(self.tab_list[1].btn, false)
    end

    if self.tab_list[2] and self.tab_list[3] then
        local main_data = model:getMainData()
        if main_data and main_data.step ~= 0 and main_data.step_status ~= 2 then
            if model.match_stage_redpoint then
                if main_data.step == 256 then
                    addRedPointToNodeByStatus(self.tab_list[2].btn, true, 5, 5)
                    addRedPointToNodeByStatus(self.tab_list[3].btn, false, 5, 5)
                elseif main_data.step == 64 or main_data.step == 8 then
                    addRedPointToNodeByStatus(self.tab_list[2].btn, false, 5, 5)
                    addRedPointToNodeByStatus(self.tab_list[3].btn, true, 5, 5)
                end
            else
                addRedPointToNodeByStatus(self.tab_list[2].btn, false, 5, 5)
                addRedPointToNodeByStatus(self.tab_list[3].btn, false, 5, 5)
            end
        end
    end
end

function ArenapeakchampionGuessingWindow:onClickCloseBtn()
    controller:openArenapeakchampionGuessingWindow(false)
end

--@check_repeat_click 是否检查重复点击
function ArenapeakchampionGuessingWindow:changeTabType(index, check_repeat_click)
    if check_repeat_click and self.cur_tab_index == index then return end

    if index == 1 then
        self.bg_2:setVisible(false)
    else
        self.bg_2:setVisible(true)
    end

    if self.cur_tab ~= nil then
        self.cur_tab.title:setTextColor(Config.ColorData.data_new_color4[6])
        self.cur_tab.title:disableEffect(cc.LabelEffect.SHADOW)
        self.cur_tab.select_bg:setVisible(false)
    end
    self.cur_tab_index = index
    self.cur_tab = self.tab_list[self.cur_tab_index]

    if self.cur_tab ~= nil then
        self.cur_tab.title:setTextColor(Config.ColorData.data_new_color4[1])
        self.cur_tab.title:enableShadow(Config.ColorData.data_new_color4[3],cc.size(0, -2),2)
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
    
    if index == ArenapeakchampionConstants.guessing_tab.eGuessing then
        BarrageController:getInstance():showWirteBtn(true)
    else
        BarrageController:getInstance():showWirteBtn(false)
        if model.match_stage_redpoint then
            local main_data = model:getMainData()
            if main_data and  main_data.step ~= 0 and main_data.step_status ~= 2 then
                if (main_data.step == 256 and index == ArenapeakchampionConstants.guessing_tab.ePromotion) or 
                    ((main_data.step == 64 or main_data.step == 8) and index == ArenapeakchampionConstants.guessing_tab.eChampion) then
                    controller:sender27731(2)
                    model:setMatchStageRedPoint(false)
                end
            end
        end
    end
    self:updateRedPoint()
end

function ArenapeakchampionGuessingWindow:createSubPanel(index)
    --冠军赛和晋级赛用同一个界面 不同的数据
    if index == ArenapeakchampionConstants.guessing_tab.eChampion then --冠军赛
        index = ArenapeakchampionConstants.guessing_tab.ePromotion
    end

    local panel = self.view_list[index]
    if panel == nil then
        if index == ArenapeakchampionConstants.guessing_tab.eGuessing then --竞猜
            panel = ArenapeakchampionGuessingTabGuessing.new(self) 
        elseif index == ArenapeakchampionConstants.guessing_tab.ePromotion then --晋级赛
            panel = ArenapeakchampionGuessingTabPromotion.new(self)
        -- elseif index == ArenapeakchampionConstants.guessing_tab.eChampion then --冠军赛
        --     panel = ArenapeakchampionGuessingTabPromotion.new(self)
        end
        if not panel then return end
        local size = self.container:getContentSize()
        panel:setPosition(cc.p(size.width * 0.5 , size.height * 0.5))
        self.container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end

function ArenapeakchampionGuessingWindow:openRootWnd(setting)
    local setting = setting or {}
    local index = setting.index or ArenapeakchampionConstants.guessing_tab.eGuessing
    self:changeTabType(index) 

    GlobalEvent:getInstance():Fire(BarrageEvent.HandleBarrageType, true, BarrageConst.type.arenapeakchampion)
end

function ArenapeakchampionGuessingWindow:close_callback(  )
    
    if self.view_list then
        for i,v in pairs(self.view_list) do 
            if v and v["DeleteMe"] then
                v:DeleteMe()
            end
        end
    end
    self.view_list = nil

    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    
    GlobalEvent:getInstance():Fire(BarrageEvent.HandleBarrageType, false, BarrageConst.type.arenapeakchampion)
    controller:openArenapeakchampionGuessingWindow(false)
end