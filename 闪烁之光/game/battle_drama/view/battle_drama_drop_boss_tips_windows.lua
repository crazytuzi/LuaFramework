-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      掉落信息查看面板
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattleDramaDropBossTipsWindow = class("BattleDramaDropBossTipsWindow", function()
    return ccui.Widget:create()
end)
function BattleDramaDropBossTipsWindow:ctor(max_dun_id)
    self.ctrl = BattleDramaController:getInstance()
    self.model = self.ctrl:getModel()
    self.drama_data = self.model:getDramaData()
    self.max_dun_id = max_dun_id or self.drama_data.max_dun_id
    self.item_list = {}
    self:open_callback()
end
function BattleDramaDropBossTipsWindow:open_callback()
    self.scroll = createScrollView(602,687,59, 260, self, ccui.ScrollViewDir.vertical)
    self:createItemList()
end

function BattleDramaDropBossTipsWindow:createItemList()
    local list = self.model:getBossShowData()
    if list and next(list or {}) ~= nil  then
        self.max_height = math.max(BattleDramaDropBossItem.HEIGHT * #list, self.scroll:getContentSize().height)
        self.scroll:setInnerContainerSize(cc.size(self.scroll:getContentSize().width, self.max_height))
        self.sum_num = tableLen(list)
        for k, v in ipairs(list) do
            delayRun(self.scroll,0.05 * k,function()
                    local item = BattleDramaDropBossItem.new()
                    item:setAnchorPoint(cc.p(0,1))
                    item:setData(v)
                    self.scroll:addChild(item)
                    item:setPosition(0, self.max_height - 3 - (BattleDramaDropBossItem.HEIGHT) * (k - 1))
                    self.item_list[k] = item
                    item:addCallBack(function(cell)
                        self:clickOpen(cell, k)
                    end)
                    if v.chapter_id == self.drama_data.chapter_id then
                        self:clickOpen(item,k)
                    end
            end)
        end
    end
    self:register_event()
end

function BattleDramaDropBossTipsWindow:clickOpen(cell,k)
    if self.cur_select ~= nil and (self.cur_index and self.cur_index ~= k) then
        self.cur_select:setSelect(false)
        self.cur_select:showMessagePanel(false)
    end
    self.cur_select = cell
    self.cur_index = k
    local status = self.cur_select:getIsShow()
    if status then
        --位置缩回去
        self.scroll:setInnerContainerSize(cc.size(self.scroll:getContentSize().width, self.max_height))
        for k, v in pairs(self.item_list) do
            v:setPosition(0,self.max_height - 3 - (BattleDramaDropBossItem.HEIGHT) * (k - 1))
        end
        self.cur_select:setSelect(false)
        self.cur_select:showMessagePanel(false)
    else
        self.cur_select:setSelect(true)
        self.cur_select:showMessagePanel(true)
        self.height = self.cur_select:getMsgPanleSize().height
        self:adjustPos()
    end
    --调整一下scrollview位置
    local percent = 0
    local scroll_height = self.max_height
    if self.height then
        scroll_height = self.max_height + self.height
    end
    if self.cur_select then
        local offset_height = (self.cur_index - 1) * BattleDramaDropBossItem.HEIGHT
        local temp_percent = offset_height / self.max_height * 100
        if self.height then
            offset_height = (self.cur_index - 1) * (BattleDramaDropBossItem.HEIGHT + 13)
            temp_percent = offset_height / scroll_height * 100
        end
        self.scroll:scrollToPercentVertical(temp_percent,0.1,true)
    end
end
function BattleDramaDropBossTipsWindow:adjustPos()
    if self.cur_select ~= nil then
        self.scroll:setInnerContainerSize(cc.size(self.scroll:getContentSize().width, self.max_height + self.height))
        local height = self.max_height + self.height
        for k, v in pairs(self.item_list) do
            if k <= self.cur_index then
                v:setPosition(0,height - 3 - (BattleDramaDropBossItem.HEIGHT) * (k - 1))
            else
                v:setPosition(0,height - self.height - 3 - (BattleDramaDropBossItem.HEIGHT) * (k - 1))
            end
        end
    end
end



function BattleDramaDropBossTipsWindow:register_event()
    if not self.update_dram_boss_data_event then
        self.update_dram_boss_data_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Boss_Update_Data, function()
            if self.cur_select ~= nil then
                self.cur_select:updateItemList()
            end
        end)
    end
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, data_list)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
                for i, v in pairs(data_list) do
                    if v and v.base_id and v.base_id == Config.DungeonData.data_drama_const["swap_item"].val then
                        if self.cur_select ~= nil then
                            self.cur_select:updateItemList()
                        end
                    end
                end
            end
        end)
    end
end

function BattleDramaDropBossTipsWindow:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end

function BattleDramaDropBossTipsWindow:DeleteMe()
    if self.cur_item then
        self.cur_item:DeleteMe()
        self.cur_item = nil
    end
    if self.update_dram_boss_data_event then
        GlobalEvent:getInstance():UnBind(self.update_dram_boss_data_event)
        self.update_dram_boss_data_event = nil
    end
    if self.add_goods_event then
        GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
    end
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i,v in ipairs(self.item_list) do
            if v then
                v:DeleteMe()
                v = nil
            end
        end
    end
    self.item_list = {}
end

-- --------------------------------------------------------------------
--
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      掉落item
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattleDramaDropBossItem =class('BattleDramaDropBossItem',function()
    return ccui.Layout:create()
end)
BattleDramaDropBossItem.WIDTH = 602
BattleDramaDropBossItem.HEIGHT = 57
function BattleDramaDropBossItem:ctor(is_bool, is_bools, size)
    self.size = size or cc.size(BattleDramaDropBossItem.WIDTH, BattleDramaDropBossItem.HEIGHT)
    self:setContentSize(self.size)
    -- self:setTouchEnabled(true)
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB('battledrama/battle_drama_drop_boss_item'))
    self:addChild(self.root_wnd)
    self.container = self.root_wnd:getChildByName('root')
    self.bg = self.container:getChildByName("bg")
    self.name_label = self.container:getChildByName('name_label')
    self.arrow = self.container:getChildByName("arrow")
    self.lock_panel = self.container:getChildByName("lock_panel")
    self.lock_panel:setVisible(false)
    self.unlock_label = self.lock_panel:getChildByName("unlock_label")
    self.unlock_label:setString(TI18N("暂未开启"))
    self.item_list = {}
    self.is_lock = true
    self.drama_data = BattleDramaController:getInstance():getModel():getDramaData()

    self:registerEvent()
end

function BattleDramaDropBossItem:registerEvent()
    self:setTouchEnabled(true)
    self:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click =            math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
                math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click == true then
                playButtonSound2()
                if self.callback then
                    if self.is_lock == false then
                        self:callback(self)
                    else
                        message(TI18N("通关本章后开启"))
                    end
                end
            end
        elseif event_type == ccui.TouchEventType.moved then
        elseif event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
        elseif event_type == ccui.TouchEventType.canceled then
        end
    end)
end

function BattleDramaDropBossItem:addCallBack(value)
    self.callback = value
end

function BattleDramaDropBossItem:setData(data)
    if not data then return  end
    self.drama_data = BattleDramaController:getInstance():getModel():getDramaData()
    self.data = data
    self.chapter_id = data.chapter_id
    if self.drama_data then
        local sum_chapter = BattleDramaController:getInstance():getModel():getOpenSumChapter(self.drama_data.mode)
        if data.chapter_id <= sum_chapter then
            self.is_lock = false
            self.lock_panel:setVisible(false)
            self.arrow:setVisible(true)
        else
            self.lock_panel:setVisible(true)
            self.arrow:setVisible(false)
        end
    end
    self.name_label:setString(TI18N("第")..StringUtil.numToChinese(data.chapter_id)..TI18N("章 ")..data.name)
end

function BattleDramaDropBossItem:getIsShow()
    return self.is_show
end

function BattleDramaDropBossItem:setSelect(bool)
    -- local res
    -- if bool then
    --     res = PathTool.getResFrame('common', 'common_1020')
    -- else
    --     res = PathTool.getResFrame('common', 'common_1029')
    -- end
    -- self.bg:loadTexture(res, LOADTEXT_TYPE_PLIST)
end

function BattleDramaDropBossItem:showMessagePanel(bool)
    self.is_show = bool
    if bool then
        if self.msg_panel == nil then
            self:createMessagePanel()
        end
        self.arrow:setScale(1)
    else
        self.arrow:setScale(-1)
    end
    self.msg_panel:setVisible(bool)
end

function BattleDramaDropBossItem:createMessagePanel()
    if self.msg_panel == nil then
        self.msg_panel = ccui.Layout:create()
        self.msg_panel:setAnchorPoint(0, 1)
        self.container:addChild(self.msg_panel)
    end
    local list = {}
    local final_list = {}
    if Config.DungeonData.data_drama_boss_show_reward then
        local max_dun_id = self.drama_data.max_dun_id
        if self.chapter_id and Config.DungeonData.data_drama_boss_show_reward[self.chapter_id] then
            local config = Config.DungeonData.data_drama_boss_show_reward[self.chapter_id]
            local sum = BattleDramaController:getInstance():getModel():getHasCurChapterPassListBossNum(self.drama_data.mode,self.chapter_id)
            local count = 0 
            if config then
                for i, v in pairs(config) do
                    table.insert(list,v)
                end
            end
            table.sort(list,function(a,b)
                return  a.dungeon_id < b.dungeon_id
            end)
            if list then
                for i, v in ipairs(list) do
                    if v.dungeon_id <= max_dun_id or count < sum then
                        table.insert(final_list, v)
                    end
                    count = count + 1
                end
            end
        end
    end
    if final_list and next(final_list or {}) ~= nil then --有子项
        local len = #final_list
        self.msg_panel:setContentSize(cc.size(585, len * (BattleDramaDropSecBossItem.HEIGHT)))
        self.msg_panel:setPosition(10, 0)
        for i, v in pairs(final_list) do
            delayRun(self.msg_panel,i * 2/display.DEFAULT_FPS,function ()
                if not self.item_list[i] then
                    local item = BattleDramaDropSecBossItem.new()
                    item:setAnchorPoint(cc.p(0, 1))
                    self.item_list[i] = item
                    self.msg_panel:addChild(item)
                end
                local item = self.item_list[i]
                if item then
                    item:setBossData(v)
                    item:setPosition(cc.p(-10, self.msg_panel:getContentSize().height - (BattleDramaDropSecBossItem.HEIGHT ) * (i - 1)))
                end
            end)
        end
    end
end


function BattleDramaDropBossItem:updateItemList()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i,v in ipairs(self.item_list) do
            if v and not tolua.isnull(v) then
                v:updateBtnStatus()
            end
        end
    end
end

function BattleDramaDropBossItem:getMsgPanleSize()
    if self.msg_panel and not tolua.isnull(self.msg_panel) then
        return self.msg_panel:getContentSize()
    end
end

function BattleDramaDropBossItem:DeleteMe()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    self:removeAllChildren()
    self:removeFromParent()
end
