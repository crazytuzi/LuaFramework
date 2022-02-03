-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      巅峰冠军赛 竞猜信息
-- <br/> 2019年11月19日
-- --------------------------------------------------------------------
ArenapeakchampionGuessInfoPanel = ArenapeakchampionGuessInfoPanel or BaseClass(BaseView)

local controller = ArenapeakchampionController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ArenapeakchampionGuessInfoPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "arenapeakchampion/arenapeakchampion_guess_info_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }

    --奖励
    -- self.dic_reward_list = {}
    self.show_list = {}
end

function ArenapeakchampionGuessInfoPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("竞猜"))

    self.scroll_container = self.main_panel:getChildByName("scroll_container")

    self.close_btn = self.main_panel:getChildByName("close_btn")
end

function ArenapeakchampionGuessInfoPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)


     --我的竞猜信息返回 
    self:addGlobalEvent(ArenapeakchampionEvent.ARENAPEAKCHAMPION_MY_GUESSING_INFO_EVENT, function(data)
        if not data then return end
        self:setData(data)
    end)
end

--关闭
function ArenapeakchampionGuessInfoPanel:onClickBtnClose()
    controller:openArenapeakchampionGuessInfoPanel(false)
end

function ArenapeakchampionGuessInfoPanel:openRootWnd()
    controller:sender27705()
end

function ArenapeakchampionGuessInfoPanel:setData(data)
    self.show_list = {}
    local list = data.list or {}
    local once_list = {}
    for i,v in ipairs(list) do
        if v.step ~= 0 then
            if v.step == 1 then
                table_insert(once_list, v)
            else
                table_insert(self.show_list, v)
            end
        end
    end 
    local func = SortTools.tableCommonSorter({{"step", false}, {"round", true}})
    table.sort(self.show_list,func )
    table.sort(once_list, function(a, b) return a.round > b.round end)
    for i,v in ipairs(once_list) do
        table_insert(self.show_list, v)
    end
    self:updateList()
end

function ArenapeakchampionGuessInfoPanel:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 606,                -- 单元的尺寸width
            item_height = 150,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    
    self.item_scrollview:reloadData()
    if #self.show_list == 0 then
        commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无竞猜数据")})
    else
        commonShowEmptyIcon(self.scroll_container, false)
    end
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenapeakchampionGuessInfoPanel:createNewCell(width, height)
   local cell = ArenapeakchampionGuessInfoItem.new(width, height)
   -- cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ArenapeakchampionGuessInfoPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenapeakchampionGuessInfoPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end


function ArenapeakchampionGuessInfoPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil

    controller:openArenapeakchampionGuessInfoPanel(false)
end

------------------------------------------
-- 子项
ArenapeakchampionGuessInfoItem = class("ArenapeakchampionGuessInfoItem", function()
    return ccui.Widget:create()
end)

function ArenapeakchampionGuessInfoItem:ctor(width, height)
    self:configUI(width, height)
    self:register_event()
end

function ArenapeakchampionGuessInfoItem:configUI( width, height )
    self.size = cc.size(width, height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)


    local csbPath = PathTool.getTargetCSB("arenapeakchampion/arenapeakchampion_guess_info_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(cc.p(width * 0.5 , height * 0.5))
    self:addChild(self.root_wnd)
   

    self.container = self.root_wnd:getChildByName("container")

    local left_role = self.container:getChildByName("left_role")
    self.left_head = PlayerHead.new(PlayerHead.type.circle)
    self.left_head:setHeadLayerScale(0.8)
    left_role:addChild(self.left_head)

    local right_role = self.container:getChildByName("right_role")
    self.right_head = PlayerHead.new(PlayerHead.type.circle)
    self.right_head:setHeadLayerScale(0.8)
    right_role:addChild(self.right_head)

    self.success_img = self.container:getChildByName("success_img")
    --观看
    self.check_fight_btn = self.container:getChildByName("check_fight_btn")
    --名字
    self.left_name = self.container:getChildByName("left_name")
    self.right_name = self.container:getChildByName("right_name")

    self.match_step_label = self.container:getChildByName("match_step_label")
    self.match_step_label:setString("")
    --投注
    self.guess_label = self.container:getChildByName("guess_label")
    self.guess_label:setString(TI18N("投注"))
    self.success_lable = self.container:getChildByName("success_lable")

    --竞猜信息
    self.guess_count_info = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), cc.p(310, 48),nil,nil,1000)
    self.container:addChild(self.guess_count_info)
end

function ArenapeakchampionGuessInfoItem:register_event( )
    registerButtonEventListener(self.check_fight_btn, handler(self, self.onClickFightBtn) ,true, 2)
end

function ArenapeakchampionGuessInfoItem:onClickFightBtn()
    if not self.data then return end
    if self.data.ret == 0 then
        return
    end
    controller:openLookFightVedioPanel(self.data)
end


function ArenapeakchampionGuessInfoItem:setData(data)
    if not data then return end
    self.data = data

    self.left_head:setHeadRes(self.data.a_face, false, LOADTEXT_TYPE, self.data.a_face_file, self.data.a_face_update_time)
    self.right_head:setHeadRes(self.data.b_face, false, LOADTEXT_TYPE, self.data.b_face_file, self.data.b_face_update_time)
    self.left_head:setLev(self.data.a_lev)
    self.right_head:setLev(self.data.b_lev)

    self.left_name:setString(self.data.a_name)
    self.right_name:setString(self.data.b_name)

    --胜利的
    if self.data.ret == 0 then
        self.success_img:setVisible(false)
        self.check_fight_btn:setVisible(false)
    else
        self.success_img:setVisible(true)
        self.check_fight_btn:setVisible(true)
        if self.data.ret == 1 then
            self.success_img:setPositionX(32)
        else
            self.success_img:setPositionX(180)
        end
    end

    --投注
    if self.data.target == 1 then
        self.guess_label:setPositionX(62)
    elseif self.data.target == 2 then    
        self.guess_label:setPositionX(218)
    else
        self.guess_label:setPositionX(-10000)
    end

    local str, str1 = model:getMacthText( self.data.step,  self.data.round)
    self.match_step_label:setString(str)

    self:setSuccessInfo()
end

function ArenapeakchampionGuessInfoItem:setSuccessInfo()
    if not self.data then return end
       --竞猜
    local item_config = Config.ItemData.data_get_data(33)
    local icon_res =  PathTool.getItemRes(item_config.icon)
    local count = 0
    local str = ""

    if self.data.ret == 0 then --未打
        self.success_lable:setString(TI18N("进行中"))
        count = self.data.bet
        str = string_format(TI18N("投注：<img src=%s visible=true scale=0.35 /> %s"),icon_res, count)
    else
        if self.data.ret == 1 then --a玩家赢了
            if self.data.target == 1 then
                count = self.data.get_bet
                self.success_lable:setString(TI18N("竞猜成功"))
                str = string_format(TI18N("<div fontcolor=#249003>获得：</div><img src=%s visible=true scale=0.35 /><div fontcolor=#249003> %s</div>"),icon_res, count)
            elseif self.data.target == 2 then
                count = self.data.bet
                self.success_lable:setString(TI18N("竞猜失败"))
                str = string_format(TI18N("<div fontcolor=#d95014>损失：</div><img src=%s visible=true scale=0.35 /><div fontcolor=#d95014> %s</div>"),icon_res, count)
            else
                self.success_lable:setString(TI18N(""))
            end    
        else --a玩家输了 
            if self.data.target == 1 then
                count = self.data.bet
                self.success_lable:setString(TI18N("竞猜失败"))
                str = string_format(TI18N("<div fontcolor=#d95014>损失：</div><img src=%s visible=true scale=0.35 /><div fontcolor=#d95014> %s</div>"),icon_res, count)
            elseif self.data.target == 2 then
                count = self.data.get_bet
                self.success_lable:setString(TI18N("竞猜成功"))
                str = string_format(TI18N("<div fontcolor=#249003>获得：</div><img src=%s visible=true scale=0.35 /><div fontcolor=#249003> %s</div>"),icon_res, count)
            else
                self.success_lable:setString(TI18N(""))
            end 
        end
    end

    self.guess_count_info:setString(str)
end


function ArenapeakchampionGuessInfoItem:DeleteMe( )
    if self.left_head then
        self.left_head:DeleteMe()
        self.left_head = nil
    end

    if self.right_head then
        self.right_head:DeleteMe()
        self.right_head = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end