---
--- Created by  Administrator
--- DateTime: 2020/7/23 9:36
---
ToemsController = ToemsController or class("ToemsController", BaseController)
local ToemsController = ToemsController
require('game.toems.RequireToems')
function ToemsController:ctor()
    ToemsController.Instance = self
    self.model = ToemsModel:GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
end

function ToemsController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function ToemsController:GetInstance()
    if not ToemsController.Instance then
        ToemsController.new()
    end
    return ToemsController.Instance
end

function ToemsController:AddEvents()

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(ToemsMainPanel):Open();
    end
    GlobalEvent:AddListener(ToemsEvent.OpenToemsPanel,call_back)

    local function call_back(bagid)
        if bagid == BagModel.toems then
            self.model:UpdateReddot();
            self.model:UpdateStengthReddot();
        end
    end
    BagModel:GetInstance():AddListener(BagEvent.LoadItemByBagId, call_back)
end

function ToemsController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    self.pb_module_name = "pb_1800_totem_pb"
    self:RegisterProtocal(proto.TOTEM_LIST, self.HandleToemsListInfo);
    self:RegisterProtocal(proto.TOTEM_ADDSUMMON, self.HandleAddSummonInfo);
    self:RegisterProtocal(proto.TOTEM_EQUIP_LOAD, self.HandleEquipLoadInfo);
    self:RegisterProtocal(proto.TOTEM_EQUIP_UNLOAD, self.HandleEquipUnloadInfo);
    self:RegisterProtocal(proto.TOTEM_SUMMON, self.HandleSummonInfo);
    self:RegisterProtocal(proto.TOTEM_UNSUMMON, self.HandleUnSummonInfo);
    self:RegisterProtocal(proto.TOTEM_EQUIP_REINFORCE, self.HandleEquipReinforceInfo);

end

-- overwrite
function ToemsController:GameStart()
    local function step()
        self:RequesToemsListInfo();
        BagController:GetInstance():RequestBagInfo(BagModel.toems);
    end
    self.time_id = GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Super)

end


function ToemsController:RequesToemsListInfo()
    local pb = self:GetPbObject("m_totem_list_tos");
    --logError("图腾列表")
    self:WriteMsg(proto.TOTEM_LIST, pb);
end

function ToemsController:HandleToemsListInfo()
    local data = self:ReadMsg("m_totem_list_toc");
    local max_summon = data.max_summon;
    local p_beast_list = data.list;
    self.model.max_summon = max_summon;
    for k, v in pairs(p_beast_list) do
        local equips = v.equips;
        local tab = {};
        for k,equip in pairs(equips) do
            local equipConfig = Config.db_totems_equip[equip.id];
            tab[equipConfig.slot] = equip;
        end
        v.equips = tab;
        self.model.EmbedEquips[v.id] = v;
    end
    self.model:Brocast(ToemsEvent.ToemsListInfo,data)
    --self.model:UpdateReddot();
end




function ToemsController:RequesAddSummonInfo()
    local pb = self:GetPbObject("m_totem_addsummon_tos");

    self:WriteMsg(proto.TOTEM_ADDSUMMON, pb);
end

function ToemsController:HandleAddSummonInfo()
    local data = self:ReadMsg("m_totem_addsummon_toc");
    local max_summon = data.max_summon;
    self.model.max_summon = max_summon;
    self.model:Brocast(ToemsEvent.AddSummonInfo,data)
end


function ToemsController:RequesEquipLoadInfo(id,uid)
    local pb = self:GetPbObject("m_totem_equip_load_tos");
    pb.id = id
    pb.uid = uid
    self:WriteMsg(proto.TOTEM_EQUIP_LOAD, pb);
end


function ToemsController:HandleEquipLoadInfo()
    local data = self:ReadMsg("m_totem_equip_load_toc");
    local id = data.id;
    local p_item = data.equip;
    if not self.model.EmbedEquips[id] then
        self.model.EmbedEquips[id] = ProtoStruct2Lua(self:GetPbObject("p_totem"));--转成table
        self.model.EmbedEquips[id].id = id;
        self.model.EmbedEquips[id].summon = false;
        self.model.EmbedEquips[id].equips = {};
    end
    local equipConfig = Config.db_totems_equip[p_item.id];
    local p_beast = self.model.EmbedEquips[id];
    p_beast.equips[equipConfig.slot] = p_item;
    self.model:Brocast(ToemsEvent.EquipLoadInfo,data)
    self.model:UpdateReddot();
end



function ToemsController:RequesEquipUnloadInfo(id,slot)
    local pb = self:GetPbObject("m_totem_equip_unload_tos");
    pb.id = id
    pb.slot = slot
    self:WriteMsg(proto.TOTEM_EQUIP_UNLOAD, pb);
end

function ToemsController:HandleEquipUnloadInfo()
    local data = self:ReadMsg("m_totem_equip_unload_toc");
    local id = data.id;
    local slot = data.slot;

    if slot == 0 then
        if self.model.EmbedEquips[id] then
            self.model.EmbedEquips[id].equips = {};
        end
    else
        for k, v in pairs(self.model.EmbedEquips[id].equips) do
            local equipConfig = Config.db_totems_equip[v.id];
            if equipConfig.slot == slot then
                self.model.EmbedEquips[id].equips[k] = nil;
            end
        end
    end
    self.model:Brocast(ToemsEvent.EquipUnloadInfo,data)
    self.model:UpdateReddot();
end

function ToemsController:RequesSummonInfo(id)
    local pb = self:GetPbObject("m_totem_summon_tos");
    pb.id = id
    self:WriteMsg(proto.TOTEM_SUMMON, pb);
end

function ToemsController:HandleSummonInfo()
    local data = self:ReadMsg("m_totem_summon_toc");
    local id = data.id;
    if self.model.EmbedEquips[id] then
        self.model.EmbedEquips[id].summon = true;
    end
    self.model:Brocast(ToemsEvent.SummonInfo,data)
    self.model:UpdateReddot();
end


function ToemsController:RequesUnSummonInfo(id)
    local pb = self:GetPbObject("m_totem_unsummon_tos");
    pb.id = id
    self:WriteMsg(proto.TOTEM_UNSUMMON, pb);
end

function ToemsController:HandleUnSummonInfo()
    local data = self:ReadMsg("m_totem_unsummon_toc");
    local id = data.id;
    if self.model.EmbedEquips[id] then
        self.model.EmbedEquips[id].summon = false;
    end
    self.model:Brocast(ToemsEvent.UnSummonInfo,data)
    self.model:UpdateReddot();
end



function ToemsController:RequesEquipReinforceInfo(id, item_id, uids, use_gold)
    local pb = self:GetPbObject("m_totem_equip_reinforce_tos");
    pb.id = id
    pb.uid = item_id;
    for i = 1, #uids, 1 do
        pb.cellids:append(uids[i]);
    end
    pb.use_gold = toBool(use_gold);
    self:WriteMsg(proto.TOTEM_EQUIP_REINFORCE, pb);
end
function ToemsController:HandleEquipReinforceInfo()
    local data = self:ReadMsg("m_totem_equip_reinforce_toc");
    self.model.ItemsUid = {}
    local id = data.id;
    local p_item = data.equip;
    if self.model.EmbedEquips[id] then
        local equipConfig = Config.db_totems_equip[p_item.id];
        local equips = self.model.EmbedEquips[id].equips;
        self.model.EmbedEquips[id].equips[equipConfig.slot] = p_item;
    end
    self.model:Brocast(ToemsEvent.EquipReinforceInfo,data)
end
















