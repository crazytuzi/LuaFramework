require("game.factionEscort.RequireFactionEscort")
FactionEscortController = FactionEscortController or class("FactionEscortController", BaseController)

function FactionEscortController:ctor()
    FactionEscortController.Instance = self
    self.model = FactionEscortModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function FactionEscortController:dctor()
end

function FactionEscortController:GetInstance()
    if not FactionEscortController.Instance then
        FactionEscortController.new()
    end
    return FactionEscortController.Instance
end

function FactionEscortController:RegisterAllProtocal()
    self.pb_module_name = "pb_1601_escort_pb"
    self:RegisterProtocal(proto.ESCORT_REFRESH, self.HandleRefersh);   --刷新
    self:RegisterProtocal(proto.ESCORT_SUPPORT, self.HandleSupport);   --申请支援
    self:RegisterProtocal(proto.ESCORT_REQUEST_SUPPORT, self.HandleRequsestSupport);  --被请求者送到请求支援
    self:RegisterProtocal(proto.ESCORT_HANDLE_REQUEST, self.HandleHandleSupport);   --处理请求
    self:RegisterProtocal(proto.ESCORT_START, self.HandleEscortStart);   --处理请求
    self:RegisterProtocal(proto.ESCORT_INFO, self.HandleEscortInfo);   --获取护送信息
    self:RegisterProtocal(proto.ESCORT_LIST, self.HandleEscortList);  --获取护送列表
    self:RegisterProtocal(proto.ESCORT_FINISH, self.HandleEscortFinish); --交任务
    self:RegisterProtocal(proto.ESCORT_COUNT, self.UpdateEscortTimes); ---跟新护送次数

end


function FactionEscortController:AddEvents()
    GlobalEvent:AddListener(ActivityEvent.ChangeActivity, handler(self, self.OpenActivity))

    GlobalEvent:AddListener(FactionEscortEvent.FactionEscortDoublePanel, handler(self, self.HandleOpenFactionEscortDounlePanel))--双倍时间段界面

    GlobalEvent:AddListener(FactionEscortEvent.FactionEscortNpcPanel, handler(self, self.HandleOpenFactionEscortNpcPanel))

  --  GlobalEvent:AddListener(EventName.KeyRelease, handler(self, self.Test))
end

function FactionEscortController:GameStart()
    local function step()
        self:RequestEscortInfo()
    end
    GlobalSchedule:StartOnce(step,Constant.GameStartReqLevel.Super-0.02)
end

function FactionEscortController:OpenActivity(isShow,id)
    local main_role = RoleInfoModel.GetInstance():GetMainRoleData()
    if main_role.level < 130 then
        return
    end
    if id == 10101 and isShow then
        lua_panelMgr:GetPanelOrCreate(FactionEscortTipsPanel):Open()
    end
end

function FactionEscortController:Test(keyCode)
    if keyCode == InputManager.KeyCode.N then
            local roadDb = Config.db_escort_road
            local start = roadDb[1].start
            local npcDB = Config.db_npc
            local sceneID = npcDB[start].scene
        	local endPos =  SceneConfigManager:GetInstance():GetNpcPosition(sceneID,start)
        	local main_role = SceneManager:GetInstance():GetMainRole()
        	local start_pos = main_role:GetPosition()
        	function callback()
                local npc_object = SceneManager:GetInstance():GetObject(start)
                if npc_object then
                    npc_object:OnClick()
                end
        	end
        	OperationManager:GetInstance():TryMoveToPosition(sceneID,start_pos,endPos,callback)
    end
end

function FactionEscortController:HandleOpenFactionEscortNpcPanel(npcId,type)
    lua_panelMgr:GetPanelOrCreate(FactionEscortNpcPanel):Open(npcId,type)
end
function FactionEscortController:HandleOpenFactionEscortDounlePanel(npcId)
    lua_panelMgr:GetPanelOrCreate(FactionEscortTipsPanel):Open()
end

-----刷新品质
function FactionEscortController:RequestRefersh()
    if self.model.itemQua == 4 then
        Notify.ShowText("Max quality reached")
        return
    end
    local pb = self:GetPbObject("m_escort_refresh_tos")
    self:WriteMsg(proto.ESCORT_REFRESH,pb)
end

function FactionEscortController:HandleRefersh()
    local data = self:ReadMsg("m_escort_refresh_toc")
    self.model.itemQua = data.quality
    self.model.refreshCount = data.refresh_count
    self.model.escortCount = data.escort_count
    GlobalEvent:Brocast(FactionEscortEvent.FactionEscortRefresh,data)
end


----申请支援
function FactionEscortController:RequestSupport(roleId)
    local pb = self:GetPbObject("m_escort_support_tos")
    pb.role_id = roleId
    self:WriteMsg(proto.ESCORT_SUPPORT,pb)
end

function FactionEscortController:HandleSupport()
    local data = self:ReadMsg("m_escort_support_toc")
    GlobalEvent:Brocast(FactionEscortEvent.FactionEscortSupport,data)
end
----被请求者收到请求支援
function FactionEscortController:HandleRequsestSupport()
    local data = self:ReadMsg("m_escort_request_support_toc")

    GlobalEvent:Brocast(FactionEscortEvent.FactionEscortRequsestSupport,data)
end

---处理请求 is_accept 0-拒绝，1-接受
function FactionEscortController:RequestSupport(roleId,is_accept)
    local pb = self:GetPbObject("m_escort_handle_request_tos")
    pb.role_id = roleId
    pb.is_accept = is_accept
    self:WriteMsg(proto.ESCORT_HANDLE_REQUEST,pb)
end

function FactionEscortController:HandleHandleSupport()
    local data = self:ReadMsg("m_escort_handle_request_toc")
    GlobalEvent:Brocast(FactionEscortEvent.FactionEscortHandleSupport,data)
end

---开始护送
function FactionEscortController:RequestEscortStart()
    local pb = self:GetPbObject("m_escort_start_tos")
    self:WriteMsg(proto.ESCORT_START,pb)
end

function FactionEscortController:HandleEscortStart()
    local data = self:ReadMsg("m_escort_start_toc")
    self.model.isEscorting = true
    GlobalEvent:Brocast(FactionEscortEvent.FactionEscortStart,data)
    self:RequestEscortInfo()
end

--获取护送信息
function FactionEscortController:RequestEscortInfo()
    local pb = self:GetPbObject("m_escort_info_tos")
    self:WriteMsg(proto.ESCORT_INFO,pb)
end
function FactionEscortController:HandleEscortInfo()
    local data = self:ReadMsg("m_escort_info_toc")
    self.model.itemQua = data.quality
    self.model.escortCount = data.escort_count
    self.model.refreshCount = data.refresh_count
    self.model.escortEndTime = data.end_time
    self.model.progress = data.progress
    if data.end_time == 0 then  --不在护送
        self.model.isEscorting = false
        GlobalEvent:Brocast(FactionEscortEvent.FactionEscortIsEscorting,false)
    else
        self.model.isEscorting = true
        GlobalEvent:Brocast(FactionEscortEvent.FactionEscortIsEscorting,true)
    end

    GlobalEvent:Brocast(FactionEscortEvent.FactionEscortInfo,data)

end

--获取护送列表
function FactionEscortController:RequestEscortList()
    local pb = self:GetPbObject("m_escort_list_tos")
    self:WriteMsg(proto.ESCORT_LIST,pb)
end
function FactionEscortController:HandleEscortList()
    local data = self:ReadMsg("m_escort_info_toc")
    GlobalEvent:Brocast(FactionEscortEvent.FactionEscortInfo,data)
end

-----劫掠
function FactionEscortController:RequestEscortRob(roleId)
    local pb = self:GetPbObject("m_escort_rob_tos")
    pb.roleId = roleId
    self:WriteMsg(proto.ESCORT_ROB,pb)
end
function FactionEscortController:HandleEscortRob()
    local data = self:ReadMsg("m_escort_rob_toc")
    GlobalEvent:Brocast(FactionEscortEvent.FactionEscortRob,data)
end

---提交护送
function FactionEscortController:RequestEscortFinish(progress)
    local pb = self:GetPbObject("m_escort_finish_tos")
    pb.progress = progress
    self:WriteMsg(proto.ESCORT_FINISH,pb)
end
function FactionEscortController:HandleEscortFinish()
    local data = self:ReadMsg("m_escort_finish_toc")
    self.model.progress =  data.progress
    if data.result == 1 then  --成功
        if data.progress ~= 1 then
            self.model.isEscorting = false
            lua_panelMgr:GetPanelOrCreate(FactionEscortMiddleEndPanel):Open(self.model.itemQua,data)
            self:RequestEscortInfo()
        else
            lua_panelMgr:GetPanelOrCreate(FactionEscortMiddleEndPanel):Open(self.model.itemQua,data)
        end
    else
        self.model.isEscorting = false
        lua_panelMgr:GetPanelOrCreate(FactionEscortMiddleEndPanel):Open(self.model.itemQua,data)
        self:RequestEscortInfo()
    end

    --if data.progress then
    --    self.model.progress =  data.progress
    --end
    --if data.progress ~= 1 then
    --    self.model.isEscorting = false --护送结束
    --    self:RequestEscortInfo()
    --end
    GlobalEvent:Brocast(FactionEscortEvent.FactionEscortFinish,data)
end

function FactionEscortController:UpdateEscortTimes()
    local data = self:ReadMsg("m_escort_count_toc")
    self.model.escort_count = data.escort_count
end






