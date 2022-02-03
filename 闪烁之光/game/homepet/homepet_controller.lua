-- --------------------------------------------------------------------
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      萌宠功能 后端锋林  策划 中健
-- <br/>Create: 2019-06-28
-- --------------------------------------------------------------------
HomepetController = HomepetController or BaseClass(BaseController)

function HomepetController:config()
    self.model = HomepetModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function HomepetController:getModel()
    return self.model
end

function HomepetController:registerEvents()

    --事件触发
    self.home_pet_check_trigger = GlobalEvent:getInstance():Bind(HomepetEvent.HOME_PET_CHECK_TRIGGER_EVENT,function()
        if self:checkCurrentWinStatus() then
            self:showNextEvent()
        end
    end)

    --监听窗口关闭事件 检测事件触发
    self.close_base_view_event = GlobalEvent:getInstance():Bind(EventId.CLOSE_BASE_VIEW,function(close_win)
        if self:checkCurrentWinStatus(close_win) then
            self:showNextEvent()
        end
    end)
end

-- 忽略不处理关闭此win的监听事件
HOME_PET_EVENT_IGNORE_KEY = {}
HOME_PET_EVENT_IGNORE_KEY["homepet/home_pet_go_back_panel"] = true
HOME_PET_EVENT_IGNORE_KEY["homepet/home_pet_reward_panel"] = true
HOME_PET_EVENT_IGNORE_KEY["homepet/home_pet_event_info_panel"] = true
HOME_PET_EVENT_IGNORE_KEY["homepet/home_pet_on_way_event_panel"] = true

--检测当前win状态 能否触发萌宠显示事件
--@close_win  被关闭的win
function HomepetController:checkCurrentWinStatus(close_win)
    local cur_win = BaseView.winMap[#BaseView.winMap]
    --当前窗口最前面的是 家园主界面.才能下一步处理
    if cur_win and not tolua.isnull(cur_win.root_wnd) then
        if cur_win.cur_home_type and cur_win.cur_home_type == HomeworldConst.Type.Myself then
            if close_win then
                --忽略不处理关闭此win的监听事件
                if HOME_PET_EVENT_IGNORE_KEY[close_win.layout_name] then
                    return false
                end
            end
            return true
        end
    end
    return false
end

--设置事件等待下一个触发
function HomepetController:setWaitNextEvent(status)
    self.is_wait_event = status
end

---萌宠触发下一个事件
function HomepetController:showNextEvent()
    if self.is_wait_event then return end
    local event_data = self.model:getCurrentEventData()
    if event_data and event_data.config then
        --后端默认1 2表示出行和归来
        if event_data.evt_sid == 1 or event_data.evt_sid == 2 then
            self:openHomePetGoBackPanel(true, {event_data = event_data})
        else
            self:openHomePetOnWayEventPanel(true, {event_data = event_data})
        end 
    end
end

function HomepetController:registerProtocals()
    self:RegisterProtocal(26100, "handle26100")     --宠物出行基础信息 
    self:RegisterProtocal(26101, "handle26101")     --请求精力值
    self:RegisterProtocal(26102, "handle26102")     --宠物改名

    self:RegisterProtocal(26103, "handle26103")     --宠物交互
    self:RegisterProtocal(26104, "handle26104")     --宠物交互支付道具

    self:RegisterProtocal(26105, "handle26105")     --宠物事件
    self:RegisterProtocal(26108, "handle26108")     --宠物事件推送
    self:RegisterProtocal(26106, "handle26106")     --宠物事件奖励领取

    self:RegisterProtocal(26107, "handle26107")     --宠物行囊协议

    self:RegisterProtocal(26109, "handle26109")     --获取本次出行所有事件

    self:RegisterProtocal(26110, "handle26110")     --请求珍宝图鉴数据

    self:RegisterProtocal(26111, "handle26111")     --请求相册日记背包
    self:RegisterProtocal(26112, "handle26112")     --请求增加相册日记
    self:RegisterProtocal(26113, "handle26113")     --请求删除相册日记
end

--宠物出行基础信息  (登陆获取申请了)
function HomepetController:sender26100()
    local protocal ={}
    self:SendProtocal(26100,protocal)
end

--当状态有变化的时候.此方法也会推送26100
function HomepetController:handle26100( data )
    self.model:updateHomepetVoInfo(data)
end

--请求精力值
function HomepetController:sender26101()
    local protocal ={}
    self:SendProtocal(26101,protocal)
end

function HomepetController:handle26101( data )
    self.model:updateHomepetVoInfo(data)
end

---宠物改名
function HomepetController:sender26102(name)
    local protocal ={}
    protocal.name = name
    self:SendProtocal(26102,protocal)
end

function HomepetController:handle26102( data )
    message(data.msg)
    self.model:updateHomepetVoInfo(data)
    if self.home_pet_base_info_panel then
        self.home_pet_base_info_panel:closeSetNameAlert()
    end
end

--宠物交互
function HomepetController:sender26103(_type)
    if self.model:checkTalkInfoBy(_type) then
        return
    end
    local protocal ={}
    protocal.type = _type
    self:SendProtocal(26103,protocal)
end

function HomepetController:handle26103( data )
    message(data.msg)
    if data.flag == 1 then
        self.model:updateHomepetVoInfo(data)
        self:openHomePetInteractionTipsPanel(true,{id = data.id})
    else
        GlobalEvent:getInstance():Fire(HomepetEvent.HOME_PET_TALK_EVENT, data)
    end
end
--宠物交互支付道具
function HomepetController:sender26104()
    local protocal ={}
    self:SendProtocal(26104,protocal)
end

function HomepetController:handle26104( data )
    self.model:updateHomepetVoInfo(data)
    self:openHomePetInteractionTipsPanel(false)
end

--宠物事件
function HomepetController:sender26105()
    local protocal ={}
    self:SendProtocal(26105,protocal)
end

function HomepetController:handle26105( data )
    self.model:updateEventInfo(data, true)
end
--宠物事件推送
function HomepetController:handle26108( data )
    self.model:updateEventInfo(data)
    GlobalEvent:getInstance():Fire(HomepetEvent.HOME_PET_GO_OUT_NEW_EVENT, data)
end

--"宠物事件奖励领取"
function HomepetController:sender26106( evt_id)
    local protocal ={}
    protocal.evt_id = evt_id
    self:SendProtocal(26106,protocal)
    -- self:handle26106(protocal)
end

function HomepetController:handle26106( data )
    message(data.msg)
    self.model:removeEventInfoByEvtID(data.evt_id)
    self.model:checkNextEventData()
    GlobalEvent:getInstance():Fire(HomepetEvent.HOME_PET_CHECK_TRIGGER_EVENT)
end

--宠物行囊协议
function HomepetController:sender26107(set_item)
    local protocal ={}
    protocal.set_item = set_item
    self:SendProtocal(26107,protocal)
end

function HomepetController:handle26107( data )
    message(data.msg)
    if data.code == TRUE then
        self.model:updateTravellingBagInfo(data.set_item)
        GlobalEvent:getInstance():Fire(HomepetEvent.HOME_PET_TRAVELLING_BAG_UPDATE_EVENT)
    end
end  

--获取本次出行所有事件
function HomepetController:sender26109()
    local protocal ={}
    self:SendProtocal(26109,protocal)
end

function HomepetController:handle26109( data )
    GlobalEvent:getInstance():Fire(HomepetEvent.HOME_PET_THIS_TIME_ALL_EVENT, data)
end 

--获取珍品记录(登陆获取)
function HomepetController:sender26110()
    local protocal ={}
    self:SendProtocal(26110,protocal)
end

function HomepetController:handle26110( data )
    self.model:updateHaveTreasureInfo(data.list)
end

--获取相册 日记背包
function HomepetController:sender26111(_type)
    local protocal ={}
    protocal.type = _type
    self:SendProtocal(26111,protocal)
end

function HomepetController:handle26111( data )
    if data.type == BackPackConst.item_type.HOME_PET_PHOTO then
        self.model:updatePhotodData(data)
    else --data.type == 35 then
        self.model:updateLetterdData(data)
    end
end 

-- --获取相册 日记背包
-- function HomepetController:sender26112(_type)
--     local protocal ={}
--     protocal.type = _type
--     self:SendProtocal(26111,protocal)
-- end

function HomepetController:handle26112( data )
    if data.type == BackPackConst.item_type.HOME_PET_PHOTO then
        self.model:updatePhotodData(data)
    else --data.type == 35 then
        self.model:updateLetterdData(data)
    end
end  

-- 删除相册 日记背包
function HomepetController:sender26113(_type, id)
    local protocal ={}
    protocal.type = _type
    protocal.id = id
    self:SendProtocal(26113,protocal)
end

function HomepetController:handle26113( data )
    if data.type == BackPackConst.item_type.HOME_PET_PHOTO then
        self.model:deletePhotodData(data.id)
    else --data.type == 35 then
        self.model:deleteLetterdData(data.id)
    end
    --如果打开相册日记 关闭
    if self.home_pet_event_info_panel then
        self:openHomePetEventInfoPanel(false)
    end
end  

--打开零花钱tips
function HomepetController:openHomePetInteractionTipsPanel(status, setting)
    if status == false then
        if self.home_pet_interaction_tips_panel ~= nil then
            self.home_pet_interaction_tips_panel:close()
            self.home_pet_interaction_tips_panel = nil
        end
    else
        if self.home_pet_interaction_tips_panel == nil then
            self.home_pet_interaction_tips_panel = HomePetInteractionTipsPanel.New()
        end
        self.home_pet_interaction_tips_panel:open(setting)
    end
end

--打开行囊
function HomepetController:openHomePetTravellingBagPanel(status, setting)
    if status == false then
        if self.home_pet_travelling_bag_panel ~= nil then
            self.home_pet_travelling_bag_panel:close()
            self.home_pet_travelling_bag_panel = nil
        end
    else
        if self.home_pet_travelling_bag_panel == nil then
            local setting = setting or {}
            self.home_pet_travelling_bag_panel = HomePetTravellingBagPanel.New(setting.show_type)
        end
        self.home_pet_travelling_bag_panel:open(setting)
    end
end

--打开道具背包界面
function HomepetController:openHomePetItemBagPanel(status, setting)
    if status == false then
        if self.home_pet_item_bag_panel ~= nil then
            self.home_pet_item_bag_panel:close()
            self.home_pet_item_bag_panel = nil
        end
    else
        if self.home_pet_item_bag_panel == nil then
            self.home_pet_item_bag_panel = HomePetItemBagPanel.New()
        end
        self.home_pet_item_bag_panel:open(setting)
    end
end
--打开道具出售界面
function HomepetController:openHomePetItemSellPanel(status, setting)
    if status == false then
        if self.home_pet_item_sell_panel ~= nil then
            self.home_pet_item_sell_panel:close()
            self.home_pet_item_sell_panel = nil
        end
    else
        if self.home_pet_item_sell_panel == nil then
            self.home_pet_item_sell_panel = HomePetItemSellPanel.New()
        end
        self.home_pet_item_sell_panel:open(setting)
    end
end

--打开萌宠出行提示界面 和回来提示界面
function HomepetController:openHomePetGoBackPanel(status, setting)
    if status == false then
        if self.home_pet_to_back_panel ~= nil then
            self.home_pet_to_back_panel:close()
            self.home_pet_to_back_panel = nil
        end
    else
        self:setWaitNextEvent(true)
        if self.home_pet_to_back_panel == nil then
            self.home_pet_to_back_panel = HomePetGoBackPanel.New()
        end
        self.home_pet_to_back_panel:open(setting)
    end
end

--打开萌宠出行中的界面
function HomepetController:openHomePetGooutProgressPanel(status, setting)
    if status == false then
        if self.home_pet_goout_progress_panel ~= nil then
            self.home_pet_goout_progress_panel:close()
            self.home_pet_goout_progress_panel = nil
        end
    else
        if self.home_pet_goout_progress_panel == nil then
            local setting = setting or {}
            self.home_pet_goout_progress_panel = HomePetGooutProgressPanel.New(setting.show_type)
        end
        self.home_pet_goout_progress_panel:open(setting)
    end
end

--打开萌宠基本信息
function HomepetController:openHomePetBaseInfoPanel(status, setting)
    if status == false then
        if self.home_pet_base_info_panel ~= nil then
            self.home_pet_base_info_panel:close()
            self.home_pet_base_info_panel = nil
        end
    else
        if self.home_pet_base_info_panel == nil then
            self.home_pet_base_info_panel = HomePetBaseInfoPanel.New()
        end
        self.home_pet_base_info_panel:open(setting)
    end
end

--打开萌途中事件
function HomepetController:openHomePetOnWayEventPanel(status, setting)
    if status == false then
        if self.home_pet_onway_event_panel ~= nil then
            self.home_pet_onway_event_panel:close()
            self.home_pet_onway_event_panel = nil
        end
    else
        self:setWaitNextEvent(true)
        if self.home_pet_onway_event_panel == nil then
            self.home_pet_onway_event_panel = HomePetOnWayEventPanel.New()
        end
        self.home_pet_onway_event_panel:open(setting)
    end
end

--打开萌途中事件信息
function HomepetController:openHomePetEventInfoPanel(status, setting)
    if status == false then
        if self.home_pet_event_info_panel ~= nil then
            self.home_pet_event_info_panel:close()
            self.home_pet_event_info_panel = nil
        end
    else
        if self.home_pet_event_info_panel == nil then
            self.home_pet_event_info_panel = HomePetEventInfoPanel.New()
        end
        self.home_pet_event_info_panel:open(setting)
    end
end

--打开收藏面板
function HomepetController:openHomePetCollectionPanel(status, setting)
    if status == false then
        if self.home_pet_collection_panel ~= nil then
            self.home_pet_collection_panel:close()
            self.home_pet_collection_panel = nil
        end
    else
        if self.home_pet_collection_panel == nil then
            self.home_pet_collection_panel = HomePetCollectionPanel.New()
        end
        self.home_pet_collection_panel:open(setting)
    end
end

--打开珍品tips
function HomepetController:openHomePetTreasureInfoPanel(status, setting)
    if status == false then
        if self.home_pet_treasure_info_panel ~= nil then
            self.home_pet_treasure_info_panel:close()
            self.home_pet_treasure_info_panel = nil
        end
    else
        if self.home_pet_treasure_info_panel == nil then
            self.home_pet_treasure_info_panel = HomePetTreasureInfoPanel.New()
        end
        self.home_pet_treasure_info_panel:open(setting)
    end
end

--打开奖励
function HomepetController:openHomePetRewardPanel(status, setting)
    if status == false then
        if self.home_pet_reward_panel ~= nil then
            self.home_pet_reward_panel:close()
            self.home_pet_reward_panel = nil
        end
    else
        if self.home_pet_reward_panel == nil then
            self.home_pet_reward_panel = HomePetRewardPanel.New()
        end
        self.home_pet_reward_panel:open(setting)
    end
end


function HomepetController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end