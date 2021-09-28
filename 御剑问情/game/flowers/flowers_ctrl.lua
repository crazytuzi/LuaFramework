require("game/flowers/flowers_view")
require("game/flowers/backflowers_view")
require("game/flowers/flowers_data")

FlowersCtrl = FlowersCtrl or BaseClass(BaseController)

local UILayer = GameObject.Find("GameRoot/UILayer").transform

function FlowersCtrl:__init()
    if nil ~= FlowersCtrl.Instance then
        print_error("[FlowersCtrl] Attemp to create a singleton twice !")
        return
    end
    FlowersCtrl.Instance = self

    self.flowers_view = FlowersView.New(ViewName.Flowers)
    self.backflowers_view = BackFlowersView.New(ViewName.BackFlowers)
    self.flowers_data = FlowersData.New()

    self.is_hideeffect = false
    self.handle_list = {}
    self.effect_count = 0

    self:RegisterAllProtocols()
end

function FlowersCtrl:__delete()
    if self.flowers_view ~= nil then
        self.flowers_view:DeleteMe()
        self.flowers_view = nil
    end

    if self.backflowers_view ~= nil then
        self.backflowers_view:DeleteMe()
        self.backflowers_view = nil
    end

    if self.flowers_data ~= nil then
        self.flowers_data:DeleteMe()
        self.flowers_data = nil
    end
    self.effect_count = 0
    FlowersCtrl.Instance = nil
    self.handle_list = {}
    self:ClearCheckRoleInfo()
end

function FlowersCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCGiveFlower, "OnGiveFlower")
    self:RegisterProtocol(SCSoneHuaInfo, "SCFlowerInfo")
end

function FlowersCtrl:ClearCheckRoleInfo()
    if self.role_info then
        GlobalEventSystem:UnBind(self.role_info)
        self.role_info = nil
    end
end

function FlowersCtrl:RoleInfo(role_id, protocol)
    if role_id == self.from_uid then
        self.from_uid = 0
        self:ClearCheckRoleInfo()
        self.backflowers_view:SetRoleInfotable(protocol)
        self.backflowers_view:Open()
    end
end

local last_open_back_flower_time = 0
function FlowersCtrl:OnGiveFlower(protocol)
    self.flowers_data:OnGiveFlower(protocol)
    -- 被送花
    local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
    if protocol.target_uid == role_id and self.flowers_data:GetIsTips() then
        if not self.flowers_view:IsOpen() and (protocol.flower_num > 1 or Status.NowTime - last_open_back_flower_time > 60) then
            self.backflowers_view:SetInfo(protocol)
            self.from_uid = protocol.from_uid
            self.role_info = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfo, self))
            CheckCtrl.Instance:SendQueryRoleInfoReq(self.from_uid)
            last_open_back_flower_time = Status.NowTime
        end
    end

    self.is_hideeffect = SettingData.Instance:GetSettingData(SETTING_TYPE.FLOWER_EFFECT)
    if self.is_hideeffect or self.effect_count > 0 then
        return
    end

    if not OpenFunData.Instance:CheckIsHide("flower_effect") and role_id ~= protocol.target_uid and role_id ~= protocol.from_uid then
        return
    end

    -- 播放特效
    local is_all_man = false
    local effect_cfg = nil
    -- if self.protocol.item_id == 26903 then      --1   双方 纯色
    -- is_all_man = false

    if protocol.item_id == 26904 then --99   双方 纯色
        is_all_man = false
        effect_cfg = 1

    elseif protocol.item_id == 26905 then --520全服 纯色
        is_all_man = true
        effect_cfg = 2

    elseif protocol.item_id == 26906 then--999 全服 双色
        is_all_man = true
        effect_cfg = 3
    end

    if effect_cfg ~= nil then
        if is_all_man then
            if effect_cfg == 2 then
                self.effect_count = 2
                self:PlayerEffect("effects2/prefab/ui/ui_songhuaxinxing_hong_prefab", "UI_songhuaxinxing_hong", 8)
                self:PlayerEffect("effects2/prefab/ui/ui_songhua520_prefab", "UI_songhua520", 8)
            else
                self.effect_count = 2
                self:PlayerEffect("effects2/prefab/ui/ui_songhua999_prefab", "UI_songhua999", 8)
                self:PlayerEffect("effects2/prefab/ui/ui_songhuaxinxing_prefab", "UI_songhuaxinxing", 8)
            end
        else
            if protocol.target_uid == GameVoManager.Instance:GetMainRoleVo().role_id or protocol.from_uid == GameVoManager.Instance:GetMainRoleVo().role_id then
                self.effect_count = 1
                self:PlayerEffect("effects2/prefab/ui/ui_songhuabian_homeigu_prefab", "UI_songhuabian_homeigu", 8)
            end
        end
    end
end

function FlowersCtrl:SCFlowerInfo(protocol)
    self.flowers_data:SetFreeFlowerTime(protocol.daily_use_free_times)
    RemindManager.Instance:Fire(RemindName.ScoietyOtherFriend)
    if self.flowers_view:IsOpen() then
        self.flowers_view:Flush()
    end
end

function FlowersCtrl:GetFlowersView()
    return self.flowers_view
end

function FlowersData:GetFlowersData()
    return self.flowers_data
end

function FlowersCtrl:GetFriendName(friend_name)
    FlowersData.Instance:SetFriendName(friend_name)
end

function FlowersCtrl:GetFlowerName(flower_name)
    FlowersData.Instance:SetFlowerName(flower_name)
end

function FlowersCtrl:SetFlowerId(item_id)
    FlowersData.Instance:SetFlowerId(item_id)
end

function FlowersCtrl:SetFriendInfo(info)
    FlowersData.Instance:SetFriendInfo(info)
end

function FlowersCtrl:SendFlowersReq(grid_index, item_id, target_uid, is_anonymity, auto_buy)
    local send_protocol = ProtocolPool.Instance:GetProtocol(CSGiveFlower)
    send_protocol.grid_index = grid_index
    send_protocol.item_id = item_id
    send_protocol.target_uid = target_uid
    send_protocol.is_anonymity = is_anonymity
    send_protocol.is_marry = auto_buy-- 0 自动购买 1 消耗背包
    send_protocol:EncodeAndSend()
end


function FlowersCtrl.SendFlowerInfoReq()
    local send_protocol = ProtocolPool.Instance:GetProtocol(CSSoneHuaInfoReq)
    send_protocol:EncodeAndSend()
end

function FlowersCtrl:PlayerEffect(path, objname, time)
    if not MainUICtrl.Instance.view:IsRendering() or MainUICtrl.Instance.view.root_node == nil then
        return
    end

    ViewManager.Instance:Open(ViewName.FlowerReMindView)
    PrefabPool.Instance:Load(AssetID(path, objname), function (prefab)
        if prefab == nil then
            self.effect_count = self.effect_count - 1
            return
        end
        PrefabPool.Instance:Free(prefab)

        local obj = GameObject.Instantiate(prefab)
        obj.transform:SetParent(MainUICtrl.Instance.view.root_node.transform, false)

        local handle = nil

        local delay_time_quest = GlobalTimerQuest:AddDelayTimer(function()
            if obj and not IsNil(obj) then
                self.effect_count = self.effect_count - 1
                GameObject.Destroy(obj)
            end
            ViewManager.Instance:Close(ViewName.FlowerReMindView)
            self:RemoveEventListen(handle)
        end, time)

        handle = self:AddStopEventListen(function ()
            if obj and not IsNil(obj) then
                self.effect_count = self.effect_count - 1
                GameObject.Destroy(obj)
            end
            GlobalTimerQuest:CancelQuest(delay_time_quest)
        end)
    end)
end

function FlowersCtrl:AddStopEventListen(event)
    local handle = {func = event}
    self.handle_list[handle] = handle
    return handle
end

function FlowersCtrl:RemoveEventListen(handle)
    if nil ~= handle then
        self.handle_list[handle] = nil
    end
end

function FlowersCtrl:StopEffect()
    for k,v in pairs(self.handle_list) do
        v.func()
    end
    self.handle_list = {}
end