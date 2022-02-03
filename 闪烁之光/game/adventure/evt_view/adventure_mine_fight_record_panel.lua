-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      冒险矿井战斗记录
-- <br/> 2019年7月16日
-- --------------------------------------------------------------------
AdventureMineFightRecordPanel = AdventureMineFightRecordPanel or BaseClass(BaseView)

local controller = AdventureController:getInstance()
local model = controller:getUiModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function AdventureMineFightRecordPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "adventure/adventure_mine_fight_record_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }
end

function AdventureMineFightRecordPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("防守记录"))

    self.scroll_container = self.main_container:getChildByName("scroll_container")

    self.close_btn = self.main_panel:getChildByName("close_btn")
end

function AdventureMineFightRecordPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)


     --总日记列表
    self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_ALL_LOG_EVENT, function(data)
        if not data then return end
        model:setMineRecordRedpoint(false)
        -- GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_RECORD_RED_POINT_EVENT)
        self:setData(data)
    end)
     --反击返回
    self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_STRIKE_BACK_EVENT, function(data)
        if not data then return end
        local base_data = model:getAdventureBaseData()
        if base_data and base_data.current_id ~= data.floor then
            controller:requestEnterAdventureMine(data.floor, {room_id = data.room_id})
        else   
            local win = controller:getAdventureMineWindow()
            if win and win.gotoAdventureFloorRoom then
                win:gotoAdventureFloorRoom({room_id = data.room_id})
            else
                controller:requestEnterAdventureMine(data.floor, {room_id = data.room_id}) 
            end
        end
    end)
end

--关闭
function AdventureMineFightRecordPanel:onClickBtnClose()
    controller:openAdventureMineFightRecordPanel(false)
end

--
function AdventureMineFightRecordPanel:openRootWnd(setting)
    local setting = setting or {}
    controller:send20644()
end

function AdventureMineFightRecordPanel:setData(data)
    self.show_list = data.log_list
    self:updateList()
end

function AdventureMineFightRecordPanel:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 600,                -- 单元的尺寸width
            item_height = 168,               -- 单元的尺寸height
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
        commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无防守记录")})
    else
        commonShowEmptyIcon(self.scroll_container, false)
    end
    self.item_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function AdventureMineFightRecordPanel:createNewCell(width, height)
   local cell = AdventureMineFightRecordItem.new(width, height, self)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function AdventureMineFightRecordPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function AdventureMineFightRecordPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end


function AdventureMineFightRecordPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    controller:openAdventureMineFightRecordPanel(false)
end


-- 子项
AdventureMineFightRecordItem = class("AdventureMineFightRecordItem", function()
    return ccui.Widget:create()
end)

function AdventureMineFightRecordItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function AdventureMineFightRecordItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("adventure/adventure_mine_fight_record_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.icon = self.container:getChildByName("icon")
    self.item_name = self.container:getChildByName("item_name")
    self.name = self.container:getChildByName("name")
    self.time = self.container:getChildByName("time")

    self.captured_img = self.container:getChildByName("captured_img")

    self.defence_desc = self.container:getChildByName("defence_desc")

    self.strike_back_btn = self.container:getChildByName("strike_back_btn")
    self.check_fight_btn = self.container:getChildByName("check_fight_btn")

    self.desc = createRichLabel(22, cc.c4b(0xd9,0x50,0x14,0xff), cc.p(0,0.5), cc.p(183, 28), 6, nil, 900)
    self.container:addChild(self.desc)

    self.goto_btn_label = createRichLabel(22,cc.c4b(0x24,0x90,0x03,0xff), cc.p(0.5,0.5),cc.p(80, 26))
    self.goto_btn_label:setString(string_format("<div href=xxx>%s</div>", TI18N("前往查看")))
    self.container:addChild(self.goto_btn_label)

    self.goto_btn_label:addTouchLinkListener(function(type, value, sender, pos)
        if not self.parent then return end
        if self.data then
            self.base_data = model:getAdventureBaseData()
            if self.base_data.current_id ~= self.data.floor then
                controller:requestEnterAdventureMine(self.data.floor, {room_id = self.data.room_id})
            else
                local win = controller:getAdventureMineWindow()
                if win and win.gotoAdventureFloorRoom then
                    win:gotoAdventureFloorRoom({room_id = self.data.room_id})
                else
                    controller:requestEnterAdventureMine(self.data.floor, {room_id = self.data.room_id})
                end
            end
            self.parent:onClickBtnClose()
            --也关闭上一层的
            controller:openAdventureMineMyInfoPanel(false)
        end
    end, { "click", "href" })
end

function AdventureMineFightRecordItem:register_event( )
    registerButtonEventListener(self.strike_back_btn, function() self:onStrikeBackBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.check_fight_btn, function() self:onCheckFightBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
end

--反击
function AdventureMineFightRecordItem:onStrikeBackBtn()
    if not self.data then return end
    -- if not self.parent then return end
    controller:send20656(self.data.rid, self.data.srv_id)
end
--录像
function AdventureMineFightRecordItem:onCheckFightBtn()
    if not self.data then return end
    -- if not self.parent then return end
    BattleController:getInstance():csRecordBattle(self.data.replay_id, self.data.srv_id) 
end


--data
function AdventureMineFightRecordItem:setData(data)
    if not data then return end
    self.data = data
    self.config = Config.AdventureMineData.data_mine_data(self.data.mine_id)
    if not self.config then return end
    local res_id = self.config.res_id
    if res_id == nil or res_id == "" then
        res_id = 1001
    end
    local res = PathTool.getPlistImgForDownLoad("adventure/mine_icon", res_id, false)
    if self.record_res == nil or self.record_res ~= res then
        self.record_res = res
        self.item_load = loadSpriteTextureFromCDN(self.icon, res, ResourcesType.single, self.item_load) 
    end

    if self.data.ret == 1 then
        self.captured_img:setVisible(false)
        self.defence_desc:setString(TI18N("防守成功"))
        self.defence_desc:setTextColor(cc.c4b(0x24,0x90,0x03,0xff))
        self.strike_back_btn:setVisible(false)
        self.desc:setVisible(false)
    else
        if self.data.ret == 3 then
            self.captured_img:setVisible(true)
            -- self.strike_back_btn:setVisible(true)
        else
            self.captured_img:setVisible(false)
            -- self.strike_back_btn:setVisible(false)
        end
        self.strike_back_btn:setVisible(true)
        self.desc:setVisible(true)
        self.defence_desc:setString(TI18N("防守失败"))
        self.defence_desc:setTextColor(cc.c4b(0xd9,0x50,0x14,0xff))

        if self.data.loss and next(self.data.loss) ~= nil then
            local item_id = self.data.loss[1].item_id
            local item_config  = Config.ItemData.data_get_data(item_id)
            if item_config then
                local res = PathTool.getItemRes(item_config.icon)
                local str = string_format(TI18N("<img src=%s scale=0.3 /><div fontcolor=#d95014>-%s</div>"),res, self.data.loss[1].num)
                self.desc:setString(str)
            end
        end
    end

    self.item_name:setString(self.config.name)
    self.name:setString(self.data.name)
    self.time:setString(TimeTool.getYMDHMS(self.data.time))
end

function AdventureMineFightRecordItem:DeleteMe()

    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil

    self:removeAllChildren()
    self:removeFromParent()
end