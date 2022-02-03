-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      组队竞技场奖励界面
-- <br/> 2019年10月17日
-- --------------------------------------------------------------------
ArenateamBoxRewardPanel = ArenateamBoxRewardPanel or BaseClass(BaseView)

local controller = ArenateamController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ArenateamBoxRewardPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "arenateam/arenateam_box_reward_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }

    --奖励
    self.show_list = {}
end

function ArenateamBoxRewardPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("奖 励"))

    self.scroll_container = self.main_panel:getChildByName("scroll_container")

    self.close_btn = self.main_panel:getChildByName("close_btn")
end

function ArenateamBoxRewardPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)

    self:addGlobalEvent(ArenateamEvent.ARENATEAM_RECEIVE_BOX_EVENT, function(data)
        if not data then return end
        self.dic_receive[data.id] = 2
        if self.item_scrollview then
            self.item_scrollview:resetCurrentItems()
        end
    end)
end

--关闭
function ArenateamBoxRewardPanel:onClickBtnClose()
    controller:openArenateamBoxRewardPanel(false)
end

--@level_id 段位
function ArenateamBoxRewardPanel:openRootWnd(setting)

    self.my_team_info = model:getMyTeamInfo()
    if not self.my_team_info then return end
    local setting = setting or {}
    self.do_count = self.my_team_info.do_count or 0
    local award_list = self.my_team_info.award_list or {}
    self.dic_receive = {}
    for i,v in ipairs(award_list) do
        self.dic_receive[v.award_id] = v.status
    end
    
    self:setData()
end

function ArenateamBoxRewardPanel:setData()

    local config_list = Config.ArenaTeamData.data_challenge_count_reward_info
    if config_list then
        self.show_list = config_list
        table_sort(self.show_list, function(a, b) return a.id < b.id end )
    end
    self:updateList()
end

function ArenateamBoxRewardPanel:updateList()
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
function ArenateamBoxRewardPanel:createNewCell(width, height)
   local cell = ArenateamBoxRewardItem.new(width, height, self)
   -- cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ArenateamBoxRewardPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenateamBoxRewardPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data,  self.do_count)
end


function ArenateamBoxRewardPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    controller:openArenateamBoxRewardPanel(false)
end


ArenateamBoxRewardItem = class("ArenateamBoxRewardItem", function()
    return ccui.Widget:create()
end)

function ArenateamBoxRewardItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function ArenateamBoxRewardItem:configUI(width, height)
    self.size = cc.size(width, height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenateam/arenateam_box_reward_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.left_name = self.main_container:getChildByName("left_name")
    self.right_name = self.main_container:getChildByName("right_name")
    self.receive_img = self.main_container:getChildByName("receive_img")

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_btn_label:setString(TI18N("领 取"))
    self.item_scrollview = self.main_container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    
end

function ArenateamBoxRewardItem:register_event( )
    registerButtonEventListener(self.comfirm_btn, handler(self, self.onClickComfirmBtn) ,true, 2)
end

--领取
function ArenateamBoxRewardItem:onClickComfirmBtn()
    if not self.data then return end
    if not self.parent then return end
    if self.parent.dic_receive[self.data.id] == 0 then
        message(TI18N("未满足领取条件"))
        return
    elseif self.parent.dic_receive[self.data.id] == 1 then
        controller:sender27224(self.data.id)
    end
end

function ArenateamBoxRewardItem:setData(data)
    if not data then return end
    if not self.parent then return end
    self.data = data
    self.left_name:setString(string_format(TI18N("组队挑战%s次"), data.count))
    local num 
    local do_count = self.parent.do_count or 0
    if do_count >= data.count then
        num = data.count
    else
        num = do_count
    end 
    self.right_name:setString(string_format("(%s/%s)", num, data.count))

    if self.parent.dic_receive[data.id] == 2 then
        self.comfirm_btn:setVisible(false)
        self.receive_img:setVisible(true)
    elseif self.parent.dic_receive[data.id] == 1 then
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
    -- setting.is_center = true
    -- setting.show_effect_id = 263
    self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
end


function ArenateamBoxRewardItem:DeleteMe( )
    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end