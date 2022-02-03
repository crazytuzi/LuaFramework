--[[
试炼之门活动主界面
--]]
EsecsiceWindow = EsecsiceWindow or BaseClass(BaseView)
local controller = EsecsiceController:getInstance()

function EsecsiceWindow:__init()
    self._activityRoot = nil
    self.is_full_screen = true
    self.win_type = WinType.Full 
    self.layout_name = "esercise/esercise_window"
    self.ctrl = ActivityController:getInstance()
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("activity", "activity"), type = ResourcesType.plist}
    }
end

function EsecsiceWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    local bg = self.root_wnd:getChildByName("bg")
    bg:setScale(display.getMaxScale())

    local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_63",true)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(bg) then
                loadSpriteTexture(bg,res,LOADTEXT_TYPE)
            end
        end,self.item_load)
    end
    self.main_container:getChildByName("Text_1"):setString(TI18N("试炼之门"))
    self.scoreView = self.main_container:getChildByName("scoreView")
    local scroll_view_size = self.scoreView:getContentSize()

    local setting = {
        item_class = EsecsiceItem,      -- 单元类
        start_x = 9,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 3,                    -- 第一个单元的Y起点
        space_y = 25,                    -- y方向的间隔
        item_width = 690,               -- 单元的尺寸width
        item_height = 235,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        delay = 4
    }
    self.itemScrollview = CommonScrollViewLayout.new(self.scoreView, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)

    -- 引导中不给滑动列表
    if GuideController:getInstance():isInGuide() then
        self.itemScrollview:setClickEnabled(false)
    end
end

function EsecsiceWindow:register_event()
    self:addGlobalEvent(Stone_dungeonEvent.Updata_StoneDungeon_Data,function()
        self:updateItemListRedStatus()
    end)
    self:addGlobalEvent(Endless_trailEvent.UPDATA_ESECSICE_ENDLESS_REDPOINT,function()
        self:updateItemListRedStatus()
    end)
    self:addGlobalEvent(PlanesafkEvent.Update_Planes_Red_Event,function()
        self:updateItemListRedStatus()
    end)
    self:addGlobalEvent(PrimusEvent.Updata_Primus_RedPoint,function()
        self:updateItemListRedStatus()
    end)

    -- 引导中不给滑动列表
    self:addGlobalEvent(GuideEvent.Update_Guide_Status_Event, function ( in_guide )
        if in_guide then
            self.itemScrollview:setClickEnabled(false)
        else
            self.itemScrollview:setClickEnabled(true)
        end
    end)
end

function EsecsiceWindow:openRootWnd()
    local dataInfo = Config.DailyplayData.data_exerciseactivity
    self.itemScrollview:setData(dataInfo,function(cell)
        controller:switchEcersiceActivityView(cell:getData().goto_id)
    end)
    if self.itemScrollview then
        self.itemScrollview:addEndCallBack(function() 
            self:updateItemListRedStatus()
        end) 
    end
end

function EsecsiceWindow:updateItemListRedStatus()
    local item_list = self.itemScrollview:getItemList()
    if item_list then
        for k,item in pairs(item_list) do
            item:updateRedStatus()
        end
    end
end

function EsecsiceWindow:close_callback()
    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    if self.itemScrollview then
        self.itemScrollview:DeleteMe()
        self.itemScrollview = nil
    end
    controller:openEsecsiceView(false)
end


--=========================
EsecsiceItem = class("EsecsiceItem", function()
    return ccui.Widget:create()
end)

function EsecsiceItem:ctor()
    self.listReward = {}
    self:createRootWnd()
    self:registerEvent()
end
function EsecsiceItem:createRootWnd()
    self.rootWnd = createCSBNote(PathTool.getTargetCSB("esercise/esercise_item"))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.rootWnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(690, 235))

    self.mainContainer = self.rootWnd:getChildByName("main_container")
    self.itemBG = self.mainContainer:getChildByName("itemBG")
    self.redPoint = self.mainContainer:getChildByName("redPoint")
    self.redPoint:setVisible(false)

    self.limitMask = self.mainContainer:getChildByName("limitMask")
     self.textLimitLev = self.mainContainer:getChildByName("textLimitLev")
     self.textLimitLev:setString("")
     self.textLimitLev:setLocalZOrder(11)

    self.textTimeStart = self.mainContainer:getChildByName("textTimeStart")
    self.textTimeStart:setString("")
    self.textTimeStart:setVisible(false)
end

function EsecsiceItem:setData(data)
    self.escesiceData = data

    if data.pic_name then
        local bg_res = PathTool.getPlistImgForDownLoad("activity/activity_big", data.pic_name)
        self.bg_load = loadSpriteTextureFromCDN(self.itemBG, bg_res, ResourcesType.single, self.bg_load)
    end

    if data.val[1] then
        for i,v in pairs(data.val[1]) do
            if not self.listReward[i] then
                local item = BackPackItem.new(nil,true,nil,0.7)
                if self.mainContainer then
                    self.mainContainer:addChild(item,1)
                end
                self.listReward[i] = item
            end
            if self.listReward[i] then
                self.listReward[i]:setPosition(cc.p(68*i+(30*(i-1)), 59))
                self.listReward[i]:setBaseData(v)
                self.listReward[i]:setDefaultTip()
            end
        end
    end
    
    if data.desc then
        if self.textTimeStart then
            self.textTimeStart:setString(data.desc)
            self.textTimeStart:setVisible(true)
        end
    end

    if data.is_open == 1 then
        local _bool = MainuiController:getInstance():checkIsOpenByActivate(data.activate)
        if _bool == true then
            self:setTouchEnabled(true)
            self:handleEffect(true)
            self.limitMask:setVisible(false)
            self.textLimitLev:setVisible(false)
        else
            self:handleEffect(false)
            self.limitMask:setVisible(true)
            self.textLimitLev:setString(data.lock_desc)
            self.textLimitLev:setVisible(true)
        end
    else
        self.limitMask:setVisible(true)
        self.textLimitLev:setVisible(true)
        self:handleEffect(false)
        self:setTouchEnabled(false)
    end

    -- 引导使用,不要删
    if data and data.id then
        self:setName("guide_activity_item_"..data.id)
    end
end
function EsecsiceItem:getData()
    return self.escesiceData
end
function EsecsiceItem:addCallBack( value )
    self.callback =  value
end
function EsecsiceItem:registerEvent()
    self:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click =
                    math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
                    math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click == true then
                playButtonSound2()
                if self.callback then
                    self:callback()
                end
            end
            elseif event_type == ccui.TouchEventType.moved then
            elseif event_type == ccui.TouchEventType.began then
                self.touch_began = sender:getTouchBeganPosition()
            elseif event_type == ccui.TouchEventType.canceled then
            end
    end)
end
function EsecsiceItem:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        if not tolua.isnull(self._mainContainer) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(505), cc.p(self._itemBG:getContentSize().width-106, 28), cc.p(1, 0), true, PlayerAction.action)
            self._mainContainer:addChild(self.play_effect, 1)
        end
    end
end

function EsecsiceItem:updateRedStatus()
    if self.escesiceData then
        local red_status = false
        if self.escesiceData.id == EsecsiceConst.exercise_index.endless then --日常副本
            red_status = Stone_dungeonController:getInstance():getModel():checkRedStatus()
        elseif self.escesiceData.id == EsecsiceConst.exercise_index.stonedungeon then --无尽试炼
            red_status = Endless_trailController:getInstance():getModel():checkRedStatus()
        elseif self.escesiceData.id == EsecsiceConst.exercise_index.honourfane then --神殿
            red_status = PrimusController:getInstance():getModel():checkPrimusRedStatus()
        elseif self.escesiceData.id == EsecsiceConst.exercise_index.heroexpedit then ---远征(现为位面)
            red_status = PlanesafkController:getInstance():getModel():getPlanesAfkRedStatus()
            -- 位面红点
        end
        self.redPoint:setVisible(red_status)
    end
end

function EsecsiceItem:DeleteMe()
    if self.listReward and next(self.listReward) ~= nil then
        for i,v in ipairs(self.listReward) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    self.listReward = {}
    self:handleEffect(false)
    self:removeAllChildren()
    self:removeFromParent()
end


