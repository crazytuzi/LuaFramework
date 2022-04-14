-- @Author: lwj
-- @Date:   2019-05-09 11:37:15
-- @Last Modified time: 2019-05-09 11:37:22

require "game.factionPacket.RequireFPacket"
FPacketController = FPacketController or class("FPacketController", BaseController)
local FPacketController = FPacketController

function FPacketController:ctor()
    FPacketController.Instance = self
    self.model = FPacketModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function FPacketController:dctor()
end

function FPacketController:GetInstance()
    if not FPacketController.Instance then
        FPacketController.new()
    end
    return FPacketController.Instance
end

function FPacketController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1404_guild_redenvelope_pb"
    self:RegisterProtocal(proto.GUILD_REDENVELOPE_LIST, self.HandleInfoList)
    self:RegisterProtocal(proto.GUILD_REDENVELOPE_RECORD, self.HandleSerRecoList)
    self:RegisterProtocal(proto.GUILD_REDENVELOPE_SNATCH, self.HandleRushFP)
    self:RegisterProtocal(proto.GUILD_REDENVELOPE_UPDATE, self.HandleFPUpdate)
    self:RegisterProtocal(proto.GUILD_REDENVELOPE_SEND, self.HandleFPSend)
end

function FPacketController:AddEvents()
    self.global_event = {}
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(FPacketEvent.OpenPacketPaenl, handler(self, self.HandleOpenPanel))

    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(FPacketEvent.RequestSendFP, handler(self, self.RequestSendFP))
    self.model_event[#self.model_event + 1] = self.model:AddListener(FPacketEvent.RushTheFP, handler(self, self.RequeseRushFP))
end

-- overwrite
function FPacketController:GameStart()
    local function step()
        self.model.is_first_reque = true
        self:RequestInfoList()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Ordinary)
end

function FPacketController:HandleOpenPanel()
    self.model.is_open_ui_when_reci_data = true
    self:RequestSerRecoList()
    self:RequestInfoList()
end

function FPacketController:RequestInfoList()
    self:WriteMsg(proto.GUILD_REDENVELOPE_LIST)
end

function FPacketController:HandleInfoList()
    local data = self:ReadMsg("m_guild_redenvelope_list_toc")
    --dump(data, "<color=#6ce19b>HandleInfoList   HandleInfoList  HandleInfoList  HandleInfoList</color>")
    self.model:SetInfoList(data.guild_redenvelopes)
    if self.model.is_open_ui_when_reci_data then
        lua_panelMgr:GetPanelOrCreate(FactionPacketPanel):Open()
        self.model.is_open_ui_when_reci_data = false
    end
    --if self.model.is_first_reque then
    --    self.model.is_first_reque = false
    --    self.model:GetInfoList()
    --    if self.model:IsCanRush() then
    --        GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "shop", true, handler(self, self.OpenPanelAndCloseIcon), nil, nil, nil)
    --    end
    --end
    self:CheckRD()
end

function FPacketController:RequestSerRecoList()
    self:WriteMsg(proto.GUILD_REDENVELOPE_RECORD)
end
function FPacketController:HandleSerRecoList()
    local data = self:ReadMsg("m_guild_redenvelope_record_toc")
    self.model:SetRecoList(data.records)
end

function FPacketController:RequestSendFP(num, uid, id, money, desc)
    local pb = self:GetPbObject("m_guild_redenvelope_send_tos")
    pb.num = num
    pb.uid = uid
    pb.id = id
    pb.money = money
    pb.desc = desc
    self:WriteMsg(proto.GUILD_REDENVELOPE_SEND, pb)
end

function FPacketController:HandleFPSend()
    local data = self:ReadMsg("m_guild_redenvelope_send_toc")
    --dump(data, "<color=#6ce19b>HandleFPSend   HandleFPSend  HandleFPSend  HandleFPSend</color>")
    local uid = data.uid
    local fp = self.model:GetFPacket(uid)
    if fp then
        local desc = ""
        if fp.desc == "" then
            desc = Config.db_guild_redenvelope[fp.id].desc
        else
            desc = fp.desc
        end
        local str = string.format(ConfigLanguage.Faction.RedEnvelopeText, uid, desc)
        ChatController:GetInstance():RequestSendChat(enum.CHAT_CHANNEL.CHAT_CHANNEL_GUILD, 0, str)
    end
    self:CheckRD()
end

function FPacketController:RequeseRushFP(uid)
    local pb = self:GetPbObject("m_guild_redenvelope_snatch_tos")
    pb.uid = uid
    self:WriteMsg(proto.GUILD_REDENVELOPE_SNATCH, pb)
end
function FPacketController:HandleRushFP()
    local data = self:ReadMsg("m_guild_redenvelope_snatch_toc")
    --dump(data, "<color=#6ce19b>HandleRushFP   HandleRushFP  HandleRushFP  HandleRushFP</color>")
    self.model.cur_update_uid = data.uid
    self:CheckRD()
end

function FPacketController:HandleFPUpdate()
    local data = self:ReadMsg("m_guild_redenvelope_update_toc")
    --dump(data, "<color=#6ce19b>HandleFPUpdate   HandleFPUpdate  HandleFPUpdate  HandleFPUpdate</color>")
    self.model:UpdateFPGots(data.redenvelope)
    if self.model.is_update_panel_when_reci_data then
        self.model.is_update_panel_when_reci_data = false
        lua_panelMgr:GetPanelOrCreate(FPRecoPanel):Open(data.redenvelope, true)
    end
    self.model:Brocast(FPacketEvent.SuccessSendFP)
    self:CheckRD()
end

function FPacketController:FPOperation(uid)
    local data = self.model:GetRPDataByUid(uid)
    local my_id = RoleInfoModel.GetInstance():GetMainRoleId()
    if data.state == enum.RED_ENVELOPE_STATE.RED_ENVELOPE_STATE_SEND then
        --已发
        local result
        for i = 1, #data.gots do
            if data.gots[i].role.id == my_id then
                result = data.gots[i]
                break
            end
        end
        if result then
            --自己已领
            lua_panelMgr:GetPanelOrCreate(FPRecoPanel):Open(data, true)
        else
            self.model.is_update_panel_when_reci_data = true
            self.model:Brocast(FPacketEvent.RushTheFP, uid)
        end
    elseif data.state == 3 then
        lua_panelMgr:GetPanelOrCreate(FPRecoPanel):Open(data, true)
    end
end

function FPacketController:CheckRD()
    if RoleInfoModel.GetInstance():GetRoleValue("guild") == "0" then
        return
    end
    --遍历信息表
    self.model:GetInfoList()
    local is_show = self.model.is_show_rd
    GlobalEvent:Brocast(FPacketEvent.UpdateFPacketRedDot, is_show)

    if is_show and self.model.is_show_once_rd then
        GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "fpacket", true, handler(self, self.OpenPanelAndCloseIcon))
    end
end

function FPacketController:OpenPanelAndCloseIcon()
    self.model.is_show_once_rd = false
    self:HandleOpenPanel()
    GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "fpacket", false, handler(self, self.OpenPanelAndCloseIcon))
end
