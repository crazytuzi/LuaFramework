-- --------------------------------------------------------------------

-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      萌宠功能 后端锋林  策划 中健
-- <br/>Create: 2019-06-28
-- --------------------------------------------------------------------
HomepetModel = HomepetModel or BaseClass()

local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort

function HomepetModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function HomepetModel:config()
    --宠物对象
    self.homepet_vo = nil

    self.event_data_list = {}
    self.dic_event_data = {}

    --记录当前已经弹窗的事件id
    self.cur_evt_id = 0

    --珍品已拥有
    self.dic_have_treasure_id = {}

    --相片和日记的数据
    self.dic_photo_data = {}
    self.dic_letter_data = {}

    self.is_init_event = false
end

function HomepetModel:updatePhotodData( data )
    for i,v in ipairs(data.list) do
        if self.dic_photo_data[v.id] == nil then
            self.dic_photo_data[v.id] = v
            self.dic_photo_data[v.id].config = Config.ItemData.data_get_data(v.base_id)
        end
    end
end

function HomepetModel:updateLetterdData( data )
    for i,v in ipairs(data.list) do
       if self.dic_letter_data[v.id] == nil then
            self.dic_letter_data[v.id] = v
            self.dic_letter_data[v.id].config = Config.ItemData.data_get_data(v.base_id)
        end
    end
end


function HomepetModel:deletePhotodData( id )
    if self.dic_photo_data ~= nil and self.dic_photo_data[id] then
        self.dic_photo_data[id] = nil
        GlobalEvent:getInstance():Fire(HomepetEvent.HOME_PET_DELETE_PHOTO_EVENT, id)
    end
end

function HomepetModel:deleteLetterdData( id )
    if self.dic_letter_data ~= nil and self.dic_letter_data[id] then
        self.dic_letter_data[id] = nil
        GlobalEvent:getInstance():Fire(HomepetEvent.HOME_PET_DELETE_LETTER_EVENT, id)
    end
end

function HomepetModel:getHomePetVo()
    if not self.homepet_vo then
        self.homepet_vo = HomepetVo.New()
    end
    return self.homepet_vo
end

function HomepetModel:checkTalkInfoBy(_type)
    if true then return false end
    local homepet_vo = self:getHomePetVo()
    if not homepet_vo then return true end

    if _type == 1 then --对话
        local config = Config.HomePetData.data_const.conversation_upper_limit
        if config and homepet_vo.day_talk >= config.val then
            message(TI18N("萌宠也需要休息滴,明天再试吧~"))
            return true
        end
    elseif _type == 2 then --喂食
        local config = Config.HomePetData.data_const.pocket_money_upper_limit
        if config and homepet_vo.day_feed >= config.val then
            message(TI18N("萌宠也需要休息滴,明天再试吧~"))
            return true
        end
    end
    return false
end


function HomepetModel:updateHomepetVoInfo(scdata)
    local homepet_vo = self:getHomePetVo()
    if scdata then
        homepet_vo:updateAttrData(scdata)
    end
end

--@scdata 26105协议内容
--@is_init_event --是否是初始化事件
function HomepetModel:updateEventInfo(scdata, is_init_event)
    if not scdata then return end
    if is_init_event then
        self.is_init_event = true
    end

    if self.event_data_list and self.dic_event_data then
        for i,v in ipairs(scdata.evt_list) do
            if not self.dic_event_data[v.evt_id] then
                v.config = Config.HomePetData.data_event_info[v.evt_sid]
                table_insert(self.event_data_list, v)    
                self.dic_event_data[v.evt_id] = v
            end
        end
        table_sort(self.event_data_list, function(a, b) return a.evt_id < b.evt_id end)
    end

    --检查红点
    self:checkHomeWorldRedpoint()

    if self.is_init_event then
        --判断如果在家园界面.才相应事件(HOME_PET_CHECK_TRIGGER_EVENT 里面检测了)
        GlobalEvent:getInstance():Fire(HomepetEvent.HOME_PET_CHECK_TRIGGER_EVENT)
    end
end

--检查宠物对家园主城按钮的红点
function HomepetModel:checkHomeWorldRedpoint()
    local status = false
    for k,v in pairs(self.event_data_list) do
        if v.evt_sid ~= 1 then
            status = true
            break
        end 
    end
    HomeworldController:getInstance():getModel():updateHomeworldRedStatus( HomeworldConst.Red_Index.PetEvent, status )
end

--获取在旅行中事件信息(暂时没用)
function HomepetModel:getTravllingEventInfo()
    local new_event_list = {}

    local lenght = #self.event_data_list
    for i=lenght,1 do
        local event_data = self.event_data_list[i]
        -- event
    end
    for i,v in ipairs(self.event_data_list) do

    end
end

-- 移除事件内容
function HomepetModel:removeEventInfoByEvtID(evt_id)
    if self.dic_event_data then
        self.dic_event_data[evt_id] = nil
    end

    if self.event_data_list then
        for i,v in ipairs(self.event_data_list) do
            if v.evt_id == evt_id then
                table_remove(self.event_data_list, i)
                break
            end
        end
    end
end

function HomepetModel:getEventDataByEvtId(evt_id)
    if self.dic_event_data then
        return self.dic_event_data[evt_id]
    end
end

--获取下一个事件数据
function HomepetModel:checkNextEventData()
    if not self.is_init_event then return end
    self.cur_evt_id  = 0
    if self.event_data_list and #self.event_data_list > 0 then
        local is_check = false
        if self.cur_evt_id == 0 then
            is_check = true
        end
        for i,v in ipairs(self.event_data_list) do
            if not is_check and self.cur_evt_id == v.evt_id then
                is_check = true     
            else
                if is_check and v.config and v.config.is_notice == TRUE then
                    self.cur_evt_id = v.evt_id
                    return v
                end
            end
        end
    end
    return nil
end

function HomepetModel:getCurrentEventData()
     if self.cur_evt_id == 0 then
        return self:checkNextEventData()
    else
        return self:getEventDataByEvtId(self.cur_evt_id)
    end
end

function HomepetModel:updateTravellingBagInfo(set_item)
    local homepet_vo = self:getHomePetVo()
    homepet_vo:updateAttrData({set_item = set_item})
end


--根据品质获取萌宠的 R SSR 图片资源
function HomepetModel:getHomepetResNameByQuality(quality)
    local quality = quality or 0
    if quality <= BackPackConst.quality.green then --R
        return "r"
    elseif quality == BackPackConst.quality.blue then --SR
        return "sr"
    elseif quality >= BackPackConst.quality.purple then --SR
        return "ssr"
    end
end


--更新已拥有珍品记录
function HomepetModel:updateHaveTreasureInfo(list)
    if self.dic_have_treasure_id then
        for i,v in ipairs(list) do
            self.dic_have_treasure_id[v.id] = true     
        end
    end
end

--更新已拥有珍品记录 根据id
function HomepetModel:updateHaveTreasureInfoById(id)
    if self.dic_have_treasure_id then
        self.dic_have_treasure_id[id] = true
    end
end

function HomepetModel:__delete()
end