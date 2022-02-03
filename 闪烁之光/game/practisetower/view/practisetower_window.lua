-- --------------------------------------------------------------------
-- 新人练武场主界面
-- 
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-4-09
-- --------------------------------------------------------------------
PractiseTowerWindow = PractiseTowerWindow or BaseClass(BaseView)
local table_insert = table.insert
function PractiseTowerWindow:__init()
    self.ctrl = PractisetowerController:getInstance()
    self.is_full_screen = true
    self.layout_name = "practisetower/practise_tower_window"
    self.cur_type = 0
    self.win_type = WinType.Full  
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("practisetower","practisetower"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("practisetower","practisetower_bg_2"), type = ResourcesType.single },
    }
    self.tab_list = {}
    self.select_type = 1 --伙伴类型选择,默认全部为1
    self.view_list = {}
    self.is_change = false
    self.top3_item_list = {}
    self.cell_data_list = {}
    self.bg_param = 3
    self.cur_id = 0
end


function PractiseTowerWindow:open_callback()
    self.mainContainer = self.root_wnd:getChildByName("main_container")

    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.mainContainer)
    local bottom_y = display.getBottom(self.mainContainer)

     -- --主菜单 顶部底部的高度
    local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    local bottom_height = MainuiController:getInstance():getMainUi():getBottomHeight()

    self.mainContainer_size = self.mainContainer:getContentSize()
    self.bg = self.mainContainer:getChildByName("bg")
    if self.bg ~= nil then
        self.bg:setScale(display.getMaxScale())
        self.bg:setPositionY(top_y)
    end
    self.container = self.mainContainer:getChildByName("container")
    
    self.black_bg = self.mainContainer:getChildByName("black_bg")
    self.close_btn = self.black_bg:getChildByName("close_btn")
   

    self.buy_panel = self.black_bg:getChildByName("buy_panel")
    self.buy_panel:setVisible(false)
    self.buy_panel:getChildByName("key"):setString(TI18N("挑战次数："))
    self.buy_count = self.buy_panel:getChildByName("label")
    self.buy_btn = self.buy_panel:getChildByName("add_btn")

    self.buy_tips = createRichLabel(20, cc.c4b(0xff,0xf5,0xf0,0xff), cc.p(0.5,0.5), cc.p(-14,-20), nil, nil, 600)
    self.buy_panel:addChild(self.buy_tips)

    self.top_panel = self.mainContainer:getChildByName("top_panel")
    
    self.title_lab = self.top_panel:getChildByName("title_lab")
    self.title_lab:setString(TI18N("英灵武神殿"))
    self.rank_container = self.black_bg:getChildByName("rank_container")
    self.rank_desc_label = createRichLabel(20, 1, cc.p(0,0.5), cc.p(35,20), nil, nil, 400)
    self.rank_container:addChild(self.rank_desc_label)    
 
    self.award_panel = self.top_panel:getChildByName("award_panel")
    self.award_title = self.award_panel:getChildByName("award_title")
    
    self.item_scrollview = self.award_panel:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    self.item_scrollview:setSwallowTouches(false)

    self.black_bg:setPositionY(bottom_y)
    self.top_panel:setPositionY(top_y)
    local height = top_y - bottom_y - 70 -50
    self.container:setPositionY(bottom_y+70)
    self.container:setContentSize(cc.size(720,height))
end


function PractiseTowerWindow:register_event()
    registerButtonEventListener(self.close_btn, function()
        self.ctrl:openMainView(false)
    end,true, 2)

    -- if self.btn_rule then
    --     self.btn_rule:addTouchEventListener(function( sender,event_type )
    --         if event_type == ccui.TouchEventType.ended then
    --             playButtonSound2()
    --             TipsManager:getInstance():showCommonTips(Config.HolidayPractiseTowerData.data_const.rules.desc, sender:getTouchBeganPosition())
    --         end
    --     end)
    -- end

    registerButtonEventListener(self.rank_container, function()
        self.ctrl:openRankWindow(true)
    end,true, 1)

    registerButtonEventListener(self.buy_btn, function()
        local function fun()
            self.ctrl:sender29104()
        end
        local have_buycount = self.ctrl:getModel():getBuyCount() or 0
        if have_buycount <= 0 then 
            message(TI18N("购买次数已达上限"))
        else
            local buy_config = Config.HolidayPractiseTowerData.data_const.holiday_practise_tower_buy_loss
            local role_vo = RoleController:getInstance():getRoleVo()
  
            if buy_config and buy_config.val and buy_config.val[1] and buy_config.val[1][1] and buy_config.val[1][2] and role_vo then 
                local cur_gold = role_vo.gold
                if  cur_gold>= buy_config.val[1][2] then
                    local item_id = buy_config.val[1][1]
                    local num = buy_config.val[1][2] or 0
                    local item_config = Config.ItemData.data_get_data(item_id)
                    if item_config and item_config.icon then
                        local res = PathTool.getItemRes(item_config.icon)
                        local str = string.format( TI18N("是否花费<img src='%s' scale=0.25 />%s购买一次挑战次数？"),res, num)
                        CommonAlert.show(str,TI18N("确定"),fun,TI18N("取消"),nil,CommonAlert.type.rich,nil,nil,24)
                    end
                else
                    local pay_config = nil
                    local pay_type = buy_config.val[1][1]
                    if type(pay_type) == 'number' then
                        pay_config = Config.ItemData.data_get_data(pay_type)
                    else
                        pay_config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id[pay_type])
                    end
                    if pay_config then
                        if pay_config.id == Config.ItemData.data_assets_label2id.gold then
                            if FILTER_CHARGE then
                                message(TI18N("钻石不足"))
                            else
                                local function fun()
                                    VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
                                end
                                local str = string.format(TI18N('%s不足，是否前往充值？'), pay_config.name)
                                CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
                            end
                        else
                            BackpackController:getInstance():openTipsSource(true, pay_config)
                        end
                    end
                end
            end
        end
    end,true, 1)

    self:addGlobalEvent(PractisetowerEvent.Update_All_Data,function()
        self.pt_data = self.ctrl:getModel():getPractiseTowerData()
        self:updateTowerList(true)
        self:updateCount()
        self:updateRank()
        self:updateAwardInfo()
    end)

    self:addGlobalEvent(PractisetowerEvent.Update_My_rank,function()
        self.pt_data = self.ctrl:getModel():getPractiseTowerData()
        self:updateRank()
    end)
    
end


function PractiseTowerWindow:updateCount()
    local count = self.ctrl:getModel():getTowerLessCount() or 0
    local all_count = Config.HolidayPractiseTowerData.data_const["holiday_practise_tower_free_time"].val or 0
    local str = string.format("%s/%s",count,all_count)
    self.buy_count:setString(str)

    local have_buycount = self.ctrl:getModel():getBuyCount() or 0
    local str = string.format(TI18N("<div outline=1,#552e20>今日可购买次数：%s</div>"), have_buycount)
    self.buy_tips:setString(str)

    if self.pt_data and self.pt_data.last_unixtime-GameNet:getInstance():getTime() <= 0 then
        self.buy_panel:setVisible(false)
        self.rank_container:setPositionY(150)
    else
        self.buy_panel:setVisible(true)
        self.rank_container:setPositionY(201.57)
    end
end

function PractiseTowerWindow:openRootWnd()
    self.pt_data = self.ctrl:getModel():getPractiseTowerData()
    if self.pt_data ~= nil then
        self:updateTowerList(true)
    end
    
     --请求塔数据
     self.ctrl:sender29100()
     self.ctrl:sender29107(2)
end

function PractiseTowerWindow:updateTowerList(is_reload)
    --最大数量
    self.max_count = #Config.HolidayPractiseTowerData.data_tower
    if not self.list_view then
       local scroll_view_size = self.container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = -180,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            end_y = 300,                     -- y方向的间隔
            item_width = 720,                -- 单元的尺寸width
            item_height = 331,               -- 单元的尺寸height
            row = 0,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 4,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
            -- inner_hight_offset = 300*display.getMaxScale()
        }
        self.list_view = CommonScrollViewSingleLayout.new(self.container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.bottom, scroll_view_size, setting, cc.p(0, 0))
        
        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.list_view:setSwallowTouches(false)
        self.list_view:setBounceEnabled(false)
  
    end
    local max_num = self.ctrl:getModel():getNowTowerId()
    if max_num>0 then
        max_num = max_num+1
    end
    if is_reload and not self.is_init_list then
        self.is_init_list = true
        
        self.cell_data_list = deepCopy(Config.HolidayPractiseTowerData.data_tower)
        table_insert(self.cell_data_list,1,{id = 0,type = 2})
        table_insert(self.cell_data_list,{id = self.max_count+1,type = 1})
        
        self.list_view:reloadData(max_num)
        self.list_view:jumpToMoveByIndex(max_num)
    else
        self.list_view:resetCurrentItems()
        if self.pt_data and self.cur_id~= self.pt_data.id then
            self.list_view:jumpToMoveByIndex(max_num)
            self.cur_id = self.pt_data.id
        end
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function PractiseTowerWindow:createNewCell(width, height)
    local cell = PractisetowerItem.new()
	return cell
end

--获取数据数量
function PractiseTowerWindow:numberOfCells()
    if not self.cell_data_list then return 0 end
    return #self.cell_data_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function PractiseTowerWindow:updateCellByIndex(cell, index)
    if not self.cell_data_list then return end
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function PractiseTowerWindow:updateAwardInfo()
    local special_floor = Config.HolidayPractiseTowerData.data_const.special_floor
    if not special_floor or not special_floor.val or not self.pt_data then
        return
    end

    
    local cur_id = special_floor.val[#special_floor.val] or 40
    for k,v in pairs(special_floor.val) do
        if v>=self.pt_data.id+1 and v<cur_id then
            cur_id = v
        end
    end

    local data_list = {}
    local award_cfg = Config.HolidayPractiseTowerData.data_tower[cur_id]
    if award_cfg then
        data_list = award_cfg.reward
        self.award_title:setString(string.format(TI18N("%d层奖励"),award_cfg.id))
    end
    local setting = {}
    setting.scale = 0.65
    setting.max_count = 2
    setting.is_center = true
    setting.show_effect_id = 263
    self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
end

function PractiseTowerWindow:updateRank()
    if not self.pt_data then
        return
    end
    local my_rank = self.pt_data.role_rank or 0
    if my_rank == 0 then
        my_rank = TI18N("未上榜")
    end
    
    self.rank_desc_label:setString(string.format(TI18N("<div outline=2,#d87a00 >当前排名：%s</div>"),my_rank ))--fontcolor=#fff5f0 href=xxx
end

function PractiseTowerWindow:close_callback()
    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end

    self.ctrl:openMainView(false)
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    self.select_item = nil
  
end
