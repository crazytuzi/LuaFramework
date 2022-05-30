-- --------------------------------------------------------------------
-- 弹幕的主界面
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
BarrageMainView = BarrageMainView or BaseClass(BaseView)

local controller = BarrageController:getInstance()
local table_sort = table.sort
local table_insert = table.insert

function BarrageMainView:__init(_type)
    self.win_type = WinType.Tips
    self.auto_id = 1
    self.view_tag = ViewMgrTag.WIN_TAG
    self.layout_name = "barrage/barrage_main_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("barrage", "barrage"), type = ResourcesType.plist}
    }   
    self.type = _type or 1
    self.barrage_list = {}
    self.container_index = 1
    self.cache_pool = {}                    -- 弹幕缓存池
    self.cache_list = {}                    -- 弹幕缓存列表,当前存活的

    self.barrage_pool_list = {}
    self.shrink_status = true
    self.list_step = 1
    self.loop_step = 1

    self.list_interval = 2
    self.loop_interval = 3
end

function BarrageMainView:open_callback()
    self.btn_container = self.root_wnd:getChildByName("btn_container")    

    self.btn_layout = self.btn_container:getChildByName("btn_layout")
    self.send_btn = self.btn_layout:getChildByName("send_btn")
    self.close_btn = self.btn_layout:getChildByName("close_btn")

    self.shrink_btn = self.btn_container:getChildByName("shrink_btn")
    self.shrink = self.shrink_btn:getChildByName("shrink")

    self.btn_layout_width = self.btn_layout:getContentSize().width

    --巅峰冠军赛的弹幕位置 --bylwc
    self.wirte_btn = self.root_wnd:getChildByName("wirte_btn")
    self.wirte_btn:getChildByName("label"):setString(TI18N("发送弹幕"))
    self.info_btn = self.root_wnd:getChildByName("info_btn")
    self.info_btn_lable = self.info_btn:getChildByName("label")
    self.info_btn_lable:setString(TI18N("开启弹幕"))

    self.look_btn = self.root_wnd:getChildByName("look_btn")
    self.look_btn:getChildByName("label"):setString(TI18N("规则说明"))
    self.record_btn = self.root_wnd:getChildByName("record_btn")
    self.record_btn:getChildByName("label"):setString(TI18N("竞猜记录"))

    if self.type == BarrageConst.type.arenapeakchampion then
        self.btn_container:setVisible(false)
        self.wirte_btn:setVisible(true)
        self.info_btn:setVisible(true)
        self.look_btn:setVisible(true)
        self.record_btn:setVisible(true)
    end

    self.list_container = {}
    local container = nil
    for i=1,4 do
        container = self.root_wnd:getChildByName("list_container_"..i)
        if container ~= nil then
            self.list_container[i] = container
        end
    end
end

function BarrageMainView:showBtn(status)
    if status then
        self.wirte_btn:setVisible(true)
        self.info_btn:setVisible(true)
        self.look_btn:setVisible(true)
        self.record_btn:setVisible(true)
    else
        self.wirte_btn:setVisible(false)
        self.info_btn:setVisible(false)
        self.look_btn:setVisible(false)
        self.record_btn:setVisible(false)
    end
end

function BarrageMainView:register_event()
    registerButtonEventListener(self.wirte_btn, function() self:onClickWirteBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.info_btn, function() self:onClickInfoBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.look_btn, function() self:onClickLookBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.record_btn, function() self:onClickRecordBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    self.shrink_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:shrinkRightContainer()
        end
    end)

    self.send_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if isQingmingShield and isQingmingShield() then
                return
            end
            controller:openEditView(true, self.type)
        end
    end)

    self.close_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if isQingmingShield and isQingmingShield() then
                return
            end
            if self.type ~= nil then
                self.open_status = not self.open_status
                controller:setBarrageOpen(self.type, self.open_status)
                self:setScheduleUpdate(self.open_status)
                if self.open_status == true then
                    self.close_btn:loadTexture(PathTool.getResFrame("commonicon", "common_icon_46"), LOADTEXT_TYPE_PLIST)
                    
                else
                    self.close_btn:loadTexture(PathTool.getResFrame("commonicon", "common_icon_45"), LOADTEXT_TYPE_PLIST)
                    
                    for k,v in pairs(self.cache_list) do
                        if v.clearInfo then
                            v:clearInfo()
                        end
                        table_insert( self.cache_pool, v )
                        self.cache_list[v.id] = nil
                    end
                    self.cache_list = {}
                end
            end
        end
    end)

    if self.update_barrage_event == nil then
        self.update_barrage_event = GlobalEvent:getInstance():Bind(BarrageEvent.UpdateBarrageData, function(data)
            if data == nil or data.type == nil then return end
            self:updateCacheBarrageList(data)
        end)
    end

    if self.update_barrage_status == nil then
        self.update_barrage_status = GlobalEvent:getInstance():Bind(BarrageEvent.SetVisibleStatus, function(status)
            if not tolua.isnull(self.root_wnd) then
                self.root_wnd:setVisible(status)
            end
        end)
    end

    -- 战斗开始
    self:addGlobalEvent(SceneEvent.ENTER_FIGHT, function (  )
        if self.type == BarrageConst.type.arenapeakchampion then
            -- self.wirte_btn:setPosition(473, 1124)
            -- self.info_btn:setPosition(563,1124)
            self.look_btn:setVisible(false)
            self.record_btn:setVisible(false)
        end
        
    end)

    -- 战斗开始
    self:addGlobalEvent(SceneEvent.EXIT_FIGHT, function (  )
        if self.type == BarrageConst.type.arenapeakchampion then
            -- self.wirte_btn:setPosition(347, 247)
            -- self.info_btn:setPosition(454,247)
            local win = ArenapeakchampionController:getInstance():getArenapeakchampionGuessingWindow()
            if win and win.cur_tab_index and win.cur_tab_index == ArenapeakchampionConstants.guessing_tab.eGuessing then
                self.look_btn:setVisible(true)
                self.record_btn:setVisible(true)
            end
        end
    end)
end

--说明
function BarrageMainView:onClickLookBtn()
    MainuiController:getInstance():openCommonExplainView(true, Config.ArenaPeakChampionData.data_explain_guess)
end

--记录
function BarrageMainView:onClickRecordBtn()
    ArenapeakchampionController:getInstance():openArenapeakchampionGuessInfoPanel(true)
end

--写弹幕
function BarrageMainView:onClickWirteBtn()
    if isQingmingShield and isQingmingShield() then
        return
    end
    controller:openEditView(true, self.type)
end
--关闭弹幕
function BarrageMainView:onClickInfoBtn( )
    if isQingmingShield and isQingmingShield() then
        return
    end
    if self.type ~= nil then
        self.open_status = not self.open_status
        controller:setBarrageOpen(self.type, self.open_status)
        self:setScheduleUpdate(self.open_status)
        if self.open_status == true then
            self.info_btn:loadTexture(PathTool.getResFrame("commonicon", "common_icon_46", false), LOADTEXT_TYPE_PLIST)
            self.info_btn_lable:setString(TI18N("开启弹幕"))
        else
            self.info_btn:loadTexture(PathTool.getResFrame("commonicon", "common_icon_45", false), LOADTEXT_TYPE_PLIST)
            self.info_btn_lable:setString(TI18N("关闭弹幕"))
            for k,v in pairs(self.cache_list) do
                if v.clearInfo then
                    v:clearInfo()
                end
                table_insert( self.cache_pool, v )
                self.cache_list[v.id] = nil
            end
            self.cache_list = {}
        end
    end
end

function BarrageMainView:openRootWnd(type,open_type)
    self.type = type or 1
    self.open_type = open_type or 1
    
    if Config.SubtitleData.data_const["sub_space"] ~= nil then
        self.list_interval = Config.SubtitleData.data_const["sub_space"].val or 2
    end
    if Config.SubtitleData.data_const["subcircle_space"] ~= nil then
        self.loop_interval = Config.SubtitleData.data_const["subcircle_space"].val or 3
    end

    -- 这个时候取出系统的弹幕.通过配置表
    local config_list = Config.SubtitleData.data_system[self.type]
    if config_list ~= nil then
        self.barrage_list = deepCopy(config_list)
    end

    -- 把弹幕设置写到本地缓存中去吧
    self.open_status = controller:getBarrageOpen(self.type)
    
    if isQingmingShield and isQingmingShield(true) then
        self.open_status = false
    end
    self:setScheduleUpdate(self.open_status)

    if self.type == BarrageConst.type.arenapeakchampion then
        if self.open_status == true then
            self.info_btn:loadTexture(PathTool.getResFrame("commonicon", "common_icon_46", false), LOADTEXT_TYPE_PLIST)
            self.info_btn_lable:setString(TI18N("开启弹幕"))
        else
            self.info_btn:loadTexture(PathTool.getResFrame("commonicon", "common_icon_45", false), LOADTEXT_TYPE_PLIST)
            self.info_btn_lable:setString(TI18N("关闭弹幕"))
        end
    else
        if self.open_status == true then
            self.close_btn:loadTexture(PathTool.getResFrame("commonicon", "common_icon_46"), LOADTEXT_TYPE_PLIST)
        else
            self.close_btn:loadTexture(PathTool.getResFrame("commonicon", "common_icon_45"), LOADTEXT_TYPE_PLIST)
        end
    end

    -- 通知服务端进入了弹幕系统
    controller:requestEnterBarrage(self.type)
end

--==============================--
--desc:设置计时器
--time:2017-09-08 04:31:18
--@status:
--@return 
--==============================--
function BarrageMainView:setScheduleUpdate(status)
    if status == true then
        if self.queue_timer == nil then
            self.queue_timer = GlobalTimeTicket:getInstance():add(function()
                if self.barrage_list ~= nil and next(self.barrage_list) ~= nil then
                    if self.list_step >= self.list_interval then
                        local data = table.remove( self.barrage_list, 1 )
                        self:updateBarrage(data)
                        -- table_insert(self.barrage_pool_list, data)
                        self.list_step = 1
                    else
                        self.list_step = self.list_step + 1
                    end
                else
                    if self.cache_list == nil or next(self.cache_list) == nil then
                        if self.loop_step >= self.loop_interval then
                            self.barrage_list = deepCopy(self.barrage_pool_list)
                            self.barrage_pool_list = {}
                            self.loop_step = 1
                        else
                            self.loop_step = self.loop_step + 1
                        end
                    end
                end
            end, 1)
        end
    else
        if self.queue_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.queue_timer)
            self.queue_timer = nil
        end
    end
end

--==============================--
--desc:缓存将要播放的弹幕列表,
--time:2017-09-08 03:21:56
--@data:
--@return 
--==============================--
function BarrageMainView:updateCacheBarrageList(data)
    if data == nil or data.list == nil or next(data.list) == nil then 
        return 
    end
    for i,v in ipairs(data.list) do
        table_insert(self.barrage_list, v)
    end

    -- 这里做一个排序,按照时间来,宝可梦评论那边的弹幕要反过来，系统弹幕先出来
    if self.barrage_list ~= nil and next(self.barrage_list) then
        if self.open_type == 1 then 
            table_sort( self.barrage_list, function(a, b) 
                a.time = a.time or 0
                b.time = b.time or 0
                return a.time > b.time
            end)
        else 
            table_sort( self.barrage_list, function(a, b) 
                a.time = a.time or 0
                b.time = b.time or 0
                return a.time < b.time
            end)
        end
    end
end

--==============================--
--desc:创建并开始移动弹幕
--time:2017-09-08 02:04:38
--@data:
--@return 
--==============================--
function BarrageMainView:updateBarrage(data)
    if data == nil or data.msg == "" then
        return 
    end

    local function finish_action_callback(list)
        if list ~= nil and list.clearInfo then
            list:clearInfo()
        end
        table_insert( self.cache_pool, list )
        self.cache_list[list.id] = nil
    end

    local item = nil
    if self.cache_pool == nil or next(self.cache_pool) == nil then
        item = BarrageItemList.new(self.auto_id)
        self.cache_list[self.auto_id] = item
        self.auto_id = self.auto_id + 1
    else
        item = table.remove( self.cache_pool, 1 )
        self.cache_list[item.id] = item
    end
    self.list_container[self.container_index]:addChild(item)
    if item ~= nil then
        item:setPosition(display.width+10, 15)
        item:actionFinishCallBack(finish_action_callback)
        item:update(data)
    end
    self.container_index = self.container_index + 1
    if self.container_index > 4 then
        self.container_index = 1
    end
end

function BarrageMainView:close_callback()
    controller:openMainView(false)

    if self.type == BarrageConst.type.arenapeakchampion then
        controller:requestArenaPeakExitBarrage()
    else
        controller:requestExitBarrage()
    end
    
    self:setScheduleUpdate(false)
    for k,v in pairs(self.cache_pool) do
        if v.DeleteMe then
            v:DeleteMe()
        end
    end
    self.cache_pool = nil
    for k,v in pairs(self.cache_list) do
        if v.DeleteMe then
            v:DeleteMe()
        end
    end
    self.cache_list = nil
    if self.update_barrage_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_barrage_event)
        self.update_barrage_event = nil
    end
    if self.update_barrage_status then
        GlobalEvent:getInstance():UnBind(self.update_barrage_status)
        self.update_barrage_status = nil
    end
end

function BarrageMainView:shrinkRightContainer(status)
    if self.is_shrink_ing == true then return end
    self.is_shrink_ing = true
    self.shrink_status = not self.shrink_status
    self.btn_layout:setVisible(true)
    local fade = nil
    local move = nil
    if self.shrink_status == true then
        move = cc.MoveTo:create(0.1, cc.p(0, 0))
        fade = cc.FadeIn:create(0.1)
    else
        move = cc.MoveTo:create(0.1, cc.p(self.btn_layout_width, 0))
        fade = cc.FadeOut:create(0.1)
    end

    local call_fun = cc.CallFunc:create(function()
        self.is_shrink_ing = false
        if self.shrink_status == false then
            self.btn_layout:setVisible(false)
            self.shrink:setScaleX(1)
        else
            self.shrink:setScaleX(-1)
        end
    end)
    self.btn_layout:runAction(cc.Sequence:create(cc.Spawn:create(fade, move), call_fun))
end
