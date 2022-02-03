-- --------------------------------------------------------------------
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      多人竞技场奖励界面
-- <br/> 2020-03-19
-- --------------------------------------------------------------------
ArenaManyPeopleBoxRewardPanel = ArenaManyPeopleBoxRewardPanel or BaseClass(BaseView)

local controller = ArenaManyPeopleController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function ArenaManyPeopleBoxRewardPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "arenamanypeople/amp_box_reward_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }

    --奖励
    self.show_list = {}
end

function ArenaManyPeopleBoxRewardPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    -- 通用进场动效
    ActionHelp.itemScaleAction(self.main_panel)

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("奖 励"))
    self.tips_lab = self.main_panel:getChildByName("tips_lab")

    self.scroll_container = self.main_panel:getChildByName("scroll_container")

    self.close_btn = self.main_panel:getChildByName("close_btn")
end

function ArenaManyPeopleBoxRewardPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)

    self:addGlobalEvent(ArenaManyPeopleEvent.ARENAMANYPOEPLE_RECEIVE_BOX_EVENT, function(data)
        if not data then return end
        self.dic_receive[data.id] = 2
        if self.item_scrollview then
            self.item_scrollview:resetCurrentItems()
        end
    end)
end

--关闭
function ArenaManyPeopleBoxRewardPanel:onClickBtnClose()
    controller:openArenaManyPeopleBoxRewardPanel(false)
end

--@level_id 段位
function ArenaManyPeopleBoxRewardPanel:openRootWnd()
    self.my_team_info = model:getMyTeamInfo()
    self.my_info = model:getMyInfo()
    if not self.my_team_info or not self.my_info then return end
    self.score_lev = self.my_info.score_lev or 0
    local award_list = self.my_team_info.award_list or {}
    self.dic_receive = {}
    for i,v in ipairs(award_list) do
        self.dic_receive[v.award_id] = v.status
    end

    local elite_config = Config.HolidayArenaTeamData.data_elite_level[self.my_info.score_lev]
    if elite_config then
        self.tips_lab:setString(string_format(TI18N("我的段位：%s段位"),elite_config.name))
    end
    self:setData()
end

function ArenaManyPeopleBoxRewardPanel:setData()
    local config_list = Config.HolidayArenaTeamData.data_elite_award
    if config_list then
        local temp_list = {}
        for k,v in pairs(config_list) do
            table_insert(temp_list,v)
        end
        self.show_list = temp_list
        table_sort(self.show_list, function(a, b) return a.lev < b.lev end )
    end
    self:updateList()
end

function ArenaManyPeopleBoxRewardPanel:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 600,                -- 单元的尺寸width
            item_height = 153,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无奖励信息")})
    else
        commonShowEmptyIcon(self.scroll_container, false)
    end
    self.item_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenaManyPeopleBoxRewardPanel:createNewCell(width, height)
   local cell = ArenaManyPeopleBoxRewardItem.new(width, height, self)
    return cell
end
--获取数据数量
function ArenaManyPeopleBoxRewardPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenaManyPeopleBoxRewardPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data,  self.score_lev)
end


function ArenaManyPeopleBoxRewardPanel:close_callback()
    doStopAllActions(self.main_panel)
    
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    controller:openArenaManyPeopleBoxRewardPanel(false)
end


ArenaManyPeopleBoxRewardItem = class("ArenaManyPeopleBoxRewardItem", function()
    return ccui.Widget:create()
end)

function ArenaManyPeopleBoxRewardItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function ArenaManyPeopleBoxRewardItem:configUI(width, height)
    self.size = cc.size(width, height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenamanypeople/amp_box_reward_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.left_name = self.main_container:getChildByName("left_name")
    
    self.receive_img = self.main_container:getChildByName("receive_img")

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_btn_label:setString(TI18N("领 取"))
    self.item_scrollview = self.main_container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    
end

function ArenaManyPeopleBoxRewardItem:register_event( )
    registerButtonEventListener(self.comfirm_btn, handler(self, self.onClickComfirmBtn) ,true, 2)
end

--领取
function ArenaManyPeopleBoxRewardItem:onClickComfirmBtn()
    if not self.data then return end
    if not self.parent then return end
    if self.parent.dic_receive[self.data.lev] == 0 then
        message(TI18N("未满足领取条件"))
        return
    elseif self.parent.dic_receive[self.data.lev] == 1 then
        controller:sender29031(self.data.lev)
    end
end

function ArenaManyPeopleBoxRewardItem:setData(data)
    if not data then return end
    if not self.parent then return end
    self.data = data
    local conf =  Config.HolidayArenaTeamData.data_elite_level[data.lev]
    if conf then
        self.left_name:setString(string_format(TI18N("%s段位"), conf.name))
    end
    

    if self.parent.dic_receive[data.lev] == 2 then
        self.comfirm_btn:setVisible(false)
        self.receive_img:setVisible(true)
    elseif self.parent.dic_receive[data.lev] == 1 then
        self.comfirm_btn:setVisible(true)
        self.receive_img:setVisible(false)
        setChildUnEnabled(false, self.comfirm_btn)
        self.comfirm_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
    else
        self.comfirm_btn:setVisible(true)
        self.receive_img:setVisible(false)
        setChildUnEnabled(true, self.comfirm_btn)
        self.comfirm_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    end
    

    local data_list = data.award
    local setting = {}
    setting.scale = 0.7
    setting.max_count = 3
    self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
end


function ArenaManyPeopleBoxRewardItem:DeleteMe( )
    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end