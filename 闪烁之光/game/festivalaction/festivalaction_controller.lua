--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 
-- @DateTime:    2019-03-28 20:23:51
FestivalActionController = FestivalActionController or BaseClass(BaseController)

function FestivalActionController:config()
    self.model = FestivalActionModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function FestivalActionController:getModel()
    return self.model
end

function FestivalActionController:registerEvents()

end

function FestivalActionController:registerProtocals()
    self:RegisterProtocal(25700, "handle25700")
    self:RegisterProtocal(25701, "handle25701")
    self:RegisterProtocal(25702, "handle25702")
    self:RegisterProtocal(25703, "handle25703")
    self:RegisterProtocal(25704, "handle25704")

    --个人推送礼包
    self:RegisterProtocal(26300, "handle26300")
    self:RegisterProtocal(26301, "handle26301")
end
--夺宝基础信息
function FestivalActionController:sender25700()
    self:SendProtocal(25700, {})
end
function FestivalActionController:handle25700(data)
    self.model:setActionStartStatus(data.state)
    self.model:setTreasureData(data.holiday_snatch_info)
    self.model:setCountDownTime(data.state_time)
    GlobalEvent:getInstance():Fire(FestivalActionEvent.TreasureMessage,data)
end

--夺宝购买
function FestivalActionController:sender25701(pos,num)
    local proto = {}
    proto.pos = pos
    proto.num = num
    self:SendProtocal(25701, proto)
end
function FestivalActionController:handle25701(data)
    message(data.msg)
    if data.code == 1 then
        self:openTreasureJoinView(false)
    end
end

--当前开奖信息
function FestivalActionController:sender25702(pos)
    local proto = {}
    proto.pos = pos
    self:SendProtocal(25702, proto)
end
function FestivalActionController:handle25702(data)
    GlobalEvent:getInstance():Fire(FestivalActionEvent.Treasure_OpenStatus_Event,data)
end

--全部中奖日志
function FestivalActionController:sender25703()
    self:SendProtocal(25703, {})
end
function FestivalActionController:handle25703(data)
    GlobalEvent:getInstance():Fire(FestivalActionEvent.Treasure_AllServer_Event,data)
end

--个人记录
function FestivalActionController:sender25704()
    self:SendProtocal(25704, {})
end
function FestivalActionController:handle25704(data)
    GlobalEvent:getInstance():Fire(FestivalActionEvent.Treasure_MyServer_Event,data)
end

--打开全服记录界面
function FestivalActionController:openTreasureAllServerView(status)
    if status == true then
        if not self.all_server_view then
            self.all_server_view = TreasureAllServerWindow.New()
        end
        self.all_server_view:open()
    else
        if self.all_server_view then 
            self.all_server_view:close()
            self.all_server_view = nil
        end
    end
end
--打开个人记录界面
function FestivalActionController:openTreasureMyServerView(status)
    if status == true then
        if not self.my_server_view then
            self.my_server_view = TreasureMyServerWindow.New()
        end
        self.my_server_view:open()
    else
        if self.my_server_view then 
            self.my_server_view:close()
            self.my_server_view = nil
        end
    end
end
--打开个人记录界面
--data: 子项数据
--item_data: 服务端传过来的数据
function FestivalActionController:openTreasureJoinView(status, data,item_data)
    if status == true then
        if not self.join_server_view then
            self.join_server_view = TreasureJoinWindow.New()
        end
        self.join_server_view:open(data, item_data)
    else
        if self.join_server_view then
            self.join_server_view:close()
            self.join_server_view = nil
        end
    end
end
--打开开奖界面
function FestivalActionController:openTreasureOpenAwardView(status,data)
    if status == true then
        if not self.open_award_view then
            self.open_award_view = TreasureOpenAwardWindow.New()
        end
        self.open_award_view:open(data)
    else
        if self.open_award_view then 
            self.open_award_view:close()
            self.open_award_view = nil
        end
    end
end

function FestivalActionController:sender26300()
    self:SendProtocal(26300)
end
function FestivalActionController:handle26300(data)
    GlobalEvent:getInstance():Fire(FestivalActionEvent.Personal_Gift_Event,data)
end

function FestivalActionController:sender26301()
    self:SendProtocal(26301)
end
function FestivalActionController:handle26301(data)
    if data.flag == 1 then
        CommonAlert.show(TI18N("恭喜你激活专属钜惠礼包，是否前往购买？"), TI18N("前往"), function()
            self:openPersonalGiftView(true)
        end, TI18N("取消"), nil, nil, nil, {view_tag=ViewMgrTag.RECONNECT_TAG})
    end
end
--打开个人推送界面
function FestivalActionController:openPersonalGiftView(status)
    if status == true then
        if not self.personal_gift_view then
            self.personal_gift_view = PersonnalGiftWindow.New()
        end
        self.personal_gift_view:open()
    else
        if self.personal_gift_view then 
            self.personal_gift_view:close()
            self.personal_gift_view = nil
        end
    end
end

function FestivalActionController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end