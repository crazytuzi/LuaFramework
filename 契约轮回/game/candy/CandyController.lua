-- @Author: lwj
-- @Date:   2019-02-15 19:30:12
-- @Last Modified time: 2019-02-15 19:30:24

require('game.candy.RequireCandy')
CandyController = CandyController or class("CandyController", BaseController)
local CandyController = CandyController

function CandyController:ctor()
    CandyController.Instance = self
    self.model = CandyModel:GetInstance()
    self.remain_cd = 0
    self:AddEvents()
    self:RegisterAllProtocal()
    self.act_id_list = { 10121, 10122 }
end

function CandyController:dctor()
    self:StopMySchedule()
    self:DestroyChatSchedual()
    self:DestroyLeftCenterSchedual()
    self.give_gift_panel = nil
    self.record_panel = nil
end

function CandyController:GetInstance()
    if not CandyController.Instance then
        CandyController.new()
    end
    return CandyController.Instance
end

function CandyController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1604_candyroom_pb"
    self:RegisterProtocal(proto.CANDYROOM_RANK, self.HandleRankInfo)
    self:RegisterProtocal(proto.CANDYROOM_GIFT_INFO, self.HandleGiveRemainCount)
    self:RegisterProtocal(proto.CANDYROOM_SEND_GIFT, self.HandleGiveGift)
    self:RegisterProtocal(proto.CANDYROOM_GIFT_LOG, self.HandleCandyRecordInfo)
    self:RegisterProtocal(proto.CANDYROOM_INFO, self.HandleLeftCenterInfo)
    self:RegisterProtocal(proto.CANDYROOM_BUY, self.HandleBuyGiveCount)
    self:RegisterProtocal(proto.CANDYROOM_OVER, self.HandleActOver)
    self:RegisterProtocal(proto.CANDYROOM_RECEIVE_GIFT, self.HandleReceiveGift)
end

function CandyController:AddEvents()
    GlobalEvent:AddListener(CandyEvent.OpenEnterEnterHousePanel, handler(self, self.HandleOpenEnterCandyPanel))
    GlobalEvent:AddListener(CandyEvent.RequestCandyRankInfo, handler(self, self.RequestRankInfo))
    GlobalEvent:AddListener(CandyEvent.OpenLeftCenter, handler(self, self.RequestLeftCenterInfo))
    GlobalEvent:AddListener(CandyEvent.ContinueCdCountDown, handler(self, self.ContinueDiceCountDown))

    GlobalEvent:AddListener(ActivityEvent.ChangeActivity, handler(self, self.HandleGetStartTime))
    GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.HandleSceneChangeEnd))

    self.model:AddListener(CandyEvent.RequestReaminGiveCount, handler(self, self.RequestCheckGiveRemianCount))
    self.model:AddListener(CandyEvent.RequestCandyRecord, handler(self, self.RequestCandyRecordInfo))
    self.model:AddListener(CandyEvent.RequestToSerGiveGift, handler(self, self.RequestGiveGift))
    self.model:AddListener(CandyEvent.ChangeUpdateChatRankInfoState, handler(self, self.ChangeChatRankStateChange))
    self.model:AddListener(CandyEvent.RequestBuyGiftCount, handler(self, self.RequestBuyGiveCount))
end

function CandyController:HandleSceneChangeEnd()
    local function step()
        local cur_scene_id = SceneManager:GetInstance():GetSceneId()
        if cur_scene_id == 30341 or cur_scene_id == 30342 then
            self.model.is_in_candy_scene = true
            self:RequestCheckGiveRemianCount()
        else
            self.model.is_in_candy_scene = false
        end
    end
    GlobalSchedule:StartOnce(step, 1)
end

function CandyController:HandleGetStartTime(flag, act_id, stime)
    --self.model.cur_act_id = sign
    if act_id ~= 10121 and act_id ~= 10122 then
        return
    end
    if flag then
        self.model.cur_act_id = act_id
        --活动开启
        if stime then
            self.after_five_min_stamp = stime + 300
            self:HandleOpenEnterCandyPanel()
        else
            self.after_five_min_stamp = 0
        end
    end
end

-- overwrite
function CandyController:GameStart()
end

function CandyController:HandleOpenEnterCandyPanel()
    local is_open = OpenTipModel.GetInstance():IsOpenSystem(1000, 1)
    if is_open then
        lua_panelMgr:GetPanelOrCreate(CandyEnterPanel):Open()
    end
end

function CandyController:RequestRankInfo(num)
    local pb = self:GetPbObject("m_candyroom_rank_tos")
    pb.num = num
    self:WriteMsg(proto.CANDYROOM_RANK, pb)
end

function CandyController:HandleRankInfo()
    local data = self:ReadMsg("m_candyroom_rank_toc")
    --dump(data, "<color=#6ce19b>HandleRankInfo   HandleRankInfo  HandleRankInfo  HandleRankInfo</color>")
    if self.model.cur_rank_mode == 1 then
        self.model:SetChatRankList(data.ranks)
        if not self.model.isOpenningChatPanel then
            lua_panelMgr:GetPanelOrCreate(CandyChatPanel):Open()
        end
    elseif self.model.cur_rank_mode == 2 then
        self.model:SetPopRankList(data.ranks)
        if not self.model.isOpenningPopRank then
            lua_panelMgr:GetPanelOrCreate(CandyPopularRankPanel):Open()
        else
            self.model:Brocast(CandyEvent.UpdatePopRankPanel)
        end
    end
    --self.model.cur_rank_mode = 1
end

function CandyController:HandleActOver()
    local data = self:ReadMsg("m_candyroom_over_toc")
    lua_panelMgr:GetPanelOrCreate(CandyClosingPanel):Open(data)
end

function CandyController:RequestGiveGift()
    local pb = self:GetPbObject("m_candyroom_send_gift_tos")
    pb.id = self.model.targetPlayerId
    pb.gift_id = self.model.cur_sel_gift
    self:WriteMsg(proto.CANDYROOM_SEND_GIFT, pb)
end

function CandyController:HandleGiveGift()
    local data = self:ReadMsg("m_candyroom_send_gift_toc")
    Notify.ShowText("Gifted!")
    self.model.give_gift_count = data.num
    self.model:Brocast(CandyEvent.UpdateGiveGiftRemainNum, data.num)
    local my_name = "<color=#ff9600>" .. RoleInfoModel.GetInstance():GetMainRoleData().name .. "</color>"
    local target_name = "<color=#ff9600>" .. self.model.targetPlayerName .. "</color>"
    local str = string.format(msgno[Config.db_candyroom_gift[self.model.cur_sel_gift].msg_no].desc, my_name, target_name)
    str = string.trim(str)
    GlobalEvent:Brocast(ChatEvent.AutoSendTextMsg, str)
    self:ChecksGiveCountRedDot()
    --dump(data, "<color=#6ce19b>HandleGiveGift   HandleGiveGift  HandleGiveGift  HandleGiveGift</color>")
    --lua_panelMgr:GetPanelOrCreate(CandyGiveGiftPanel):Open(data.num)
end

----送礼次数
function CandyController:RequestCheckGiveRemianCount()
    self:WriteMsg(proto.CANDYROOM_GIFT_INFO)
end

function CandyController:HandleGiveRemainCount()
    local data = self:ReadMsg("m_candyroom_gift_info_toc")
    --dump(data, "<color=#6ce19b>HandleGiveRemainCount   HandleGiveRemainCount  HandleGiveRemainCount  HandleGiveRemainCount</color>")
    self.model.give_gift_count = data.num
    if self.give_gift_panel then
        self.give_gift_panel:Close()
        self.give_gift_panel = nil
    end
    if self.record_panel then
        self.record_panel:Close()
        self.record_panel = nil
    end
    if self.model.is_open_give_gift then
        self.model.is_open_give_gift = false
        self.give_gift_panel = lua_panelMgr:GetPanelOrCreate(CandyGiveGiftPanel)
        self.give_gift_panel:Open(data.num)
    end
    self:ChecksGiveCountRedDot()
end
----送礼次数红点检查
function CandyController:ChecksGiveCountRedDot()
    if self.model.is_in_candy_scene then
        GlobalEvent:Brocast(CandyEvent.UpdateCandyGiveGiftRD, self.model.give_gift_count > 0)
    end
end

----送礼记录
function CandyController:RequestCandyRecordInfo(type)
    local pb = self:GetPbObject("m_candyroom_gift_log_tos")
    pb.type = type
    self:WriteMsg(proto.CANDYROOM_GIFT_LOG, pb)
end

function CandyController:HandleCandyRecordInfo()
    local data = self:ReadMsg("m_candyroom_gift_log_toc")
    --dump(data, "<color=#6ce19b>HandleCandyRecordInfo   HandleCandyRecordInfo  HandleCandyRecordInfo  HandleCandyRecordInfo</color>")
    self.model:SetRecordListByType(data.type, data.logs)
    if not self.model.isOpenningRecordPanel then
        self.record_panel = lua_panelMgr:GetPanelOrCreate(CandyRecordPanel)
        self.record_panel:Open()
        self.model.isOpenningRecordPanel = true
    end
    self.model:Brocast(CandyEvent.LoadRecordItem, data.type)
end

function CandyController:HandleReceiveGift()
    self.model.is_showing_record_rd = true
    GlobalEvent:Brocast(CandyEvent.UpdateCandyChatIconRD, true)
    self.model:Brocast(CandyEvent.UpdateRecoBtnRD)
end

function CandyController:ChangeChatRankStateChange(flag)
    self:DestroyChatSchedual()
    if flag then
        self.chat_rank_update_schedual = GlobalSchedule.StartFun(handler(self, self.CheckChatRankState), 10, -1)
    end
end

function CandyController:CheckChatRankState()
    --local cur_act_data = self.model.cur_act_data_tbl
    --if cur_act_data then
    --检查活动开始的时间  改变请求频率
    local cur_stamp = os.time()
    local five_min_stamp = self.after_five_min_stamp
    --五分钟前
    if cur_stamp <= five_min_stamp then
        if self.model.isFiveMinBefo == false then
            self.model.isFiveMinBefo = true
        end
    else
        if self.model.isFiveMinBefo == true then
            self.model.isFiveMinBefo = false
            self:DestroyChatSchedual()
            self.chat_rank_update_schedual = GlobalSchedule.StartFun(handler(self, self.CheckChatRankState), 1, -1)
        end
    end
    if self.model.cur_rank_mode == 1 then
        self:RequestRankInfo(6)
    elseif self.model.cur_rank_mode == 2 then
        self:RequestRankInfo(100)
    end
    --end
end

function CandyController:DestroyChatSchedual()
    if self.chat_rank_update_schedual then
        GlobalSchedule:Stop(self.chat_rank_update_schedual)
        self.chat_rank_update_schedual = nil
    end
end

function CandyController:RequestLeftCenterInfo()
    self:WriteMsg(proto.CANDYROOM_INFO)
end

function CandyController:HandleLeftCenterInfo()
    local data = self:ReadMsg("m_candyroom_info_toc")
    --dump(data, "<color=#6ce19b>HandleLeftCenterInfo   HandleLeftCenterInfo  HandleLeftCenterInfo  HandleLeftCenterInfo</color>")
    self.model:SetLeftCenterInfo(data)
    if not self.model.isOpenningLeftCenter then
        lua_panelMgr:GetPanelOrCreate(CandyLeftCenter):Open()
    end
    self.model:Brocast(CandyEvent.UpdateLeftCenter)
end

function CandyController:SetUpdateLeftCenterState(flag)
    self:DestroyLeftCenterSchedual()
    if flag then
        self.left_center_update_schedual = GlobalSchedule.StartFun(handler(self, self.RequestLeftCenterInfo), 5, -1)
    end
end

function CandyController:DestroyLeftCenterSchedual()
    if self.left_center_update_schedual then
        GlobalSchedule:Stop(self.left_center_update_schedual)
        self.left_center_update_schedual = nil
    end
end

function CandyController:RequestBuyGiveCount(num)
    local pb = self:GetPbObject("m_candyroom_buy_tos")
    pb.num = num
    self:WriteMsg(proto.CANDYROOM_BUY, pb)
end

function CandyController:HandleBuyGiveCount()
    local data = self:ReadMsg("m_candyroom_buy_toc")
    --dump(data, "<color=#6ce19b>HandleBuyGiveCount   HandleLeftCenterInfo  HandleLeftCenterInfo  HandleLeftCenterInfo</color>")
    self.model.give_gift_count = data.num
    self.model:Brocast(CandyEvent.UpdateBuyCount, data.num)
    self.model:Brocast(CandyEvent.UpdateGiveGiftRemainNum, data.num)
    Notify.ShowText("Purchased!")
    --更新送礼红点
    self:ChecksGiveCountRedDot()
end

function CandyController:ContinueDiceCountDown(cd)
    self:StopMySchedule()
    self.remain_cd = cd
    self.schedule_cd = GlobalSchedule.StartFun(handler(self, self.BeginningCD), 1, -1)
end

function CandyController:BeginningCD()
    if self.remain_cd > 0 then
        self.remain_cd = self.remain_cd - (self.model.per_move * 10)
    else
        self.remain_cd = 0
        self:StopMySchedule()
    end
end

function CandyController:StopMySchedule()
    if self.schedule_cd then
        GlobalSchedule:Stop(self.schedule_cd)
        self.schedule_cd = nil
    end
end

function CandyController:CheckCandyIconShow(sceneId)
    if sceneId then
        local config = Config.db_scene[sceneId]
        if not config then
            return
        end
    else
        sceneId = SceneManager:GetInstance():GetSceneId()
    end
    local flag = sceneId == 30341 or sceneId == 30342
    if flag then
        GlobalEvent:Brocast(CandyEvent.OpenLeftCenter)
    else
        GlobalEvent:Brocast(CandyEvent.CloseLeftCenter)
    end
    SetVisible(self.candy_house, sceneId == 30341)
    SetVisible(self.candy_house, sceneId == 30342)
end
