-- @Author: lwj
-- @Date:   2018-11-13 15:43:41
-- @Last Modified time: 2018-11-26 19:21:18


require("game.system.opentip.RequireOpenTip")
OpenTipController = OpenTipController or class("OpenTipController", BaseController)
local OpenTipController = OpenTipController

function OpenTipController:ctor()
    OpenTipController.Instance = self
    self.model = OpenTipModel:GetInstance()
    self:AddEvent()
    self:RegisterAllProtocal()
end

function OpenTipController:dctor()
    --for i, v in pairs(self.role_update_list) do
    --    GlobalEvent:RemoveListener(v)
    --end
    --self.role_update_list = {}
end

function OpenTipController:GetInstance()
    if not OpenTipController.Instance then
        OpenTipController.new()
    end
    return OpenTipController.Instance
end

function OpenTipController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1000_game_pb"
    self:RegisterProtocal(proto.GAME_SYSLIST, self.HandleSystemList)
    self:RegisterProtocal(proto.GAME_SYSOPEN, self.HandleSingleInfo)
end

function OpenTipController:AddEvent()
    GlobalEvent:AddListener(EventName.OpenNextSysTipPanel, handler(self, self.HandleOpenNext))
end

function OpenTipController:GameStart()
    local function step()
        self:RequestHadOpenList()
        self.model.isBeginGame = true
    end
    self.scheduleId_1 = GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Best)
end

function OpenTipController:RequestHadOpenList()
    self:WriteMsg(proto.GAME_SYSLIST)
end

function OpenTipController:HandleSystemList()
    local data = self:ReadMsg("m_game_syslist_toc")
    -- self.model.systemList=data.syslist
    self.model:AddSystemList(data.syslist)
    GlobalEvent:Brocast(EventName.UpdateOpenFunction)
end

function OpenTipController:HandleSingleInfo()
    local data = self:ReadMsg("m_game_sysopen_toc")
    --dump(data, "<color=#6ce19b>HandleSingleInfo   HandleSingleInfo  HandleSingleInfo  HandleSingleInfo</color>")
    local id = data["sysid"];
    self.model:AddSystem(id)
    local id_tbl = string.split(id, '@')
    for i, v in pairs(id_tbl) do
        id_tbl[i] = tonumber(v)
    end
    local cf = Config.db_sysopen[id]
    if not cf then
        dump(id, "<color=#FF4545>Sysopen配置没有这个id：" .. id .. "</color>")
        return
    end
    local isPop = cf.pop
    local isOpenUI = false
    if isPop == 2 or isPop == 3 then
        isOpenUI = true
    end
    if isPop == 1 or isPop == 2 then
        local data = {}
        data.id = id
        data.isOpenUI = isOpenUI
        data.isOpenTip = true
        self.model:AddNeedShowTip(data)
        local cf = GetOpenByKey(id)
        if cf then
            GlobalEvent:Brocast(MainEvent.CheckNeedPopSysShow, cf.key_str)
        end
    end
    GlobalEvent:Brocast(MainEvent.UpdateNextSysPrediction)
    GlobalEvent:Brocast(MainEvent.CheckLoadMainIcon, id)
    MainController.GetInstance():CheckMainTopRightIcon()

    local nameId
    local sysData = GetOpenByKey(id)
    if sysData then
        nameId = sysData.key_str
    else
        nameId = Config.db_sysopen[id].key
    end
    if isPop == 1 or isPop == 2 then
        local mainpanel = lua_panelMgr:GetPanelOrCreate(MainUIView)
        if mainpanel then
            mainpanel.main_bottom_right:SwitchToIcons(true)
        end
    end
    GlobalEvent:Brocast(EventName.UpdateOpenFunction, id, nameId)
    --end

    self:HandleSystemOpen()
end

function OpenTipController:HandleSystemOpen()
    local data = self.model:GetNextNeedShow()
    if not data then
        return
    end
    local id = data.id
    if id == "130@2" then
        local mainrole_data = RoleInfoModel:GetInstance():GetMainRoleData()
        local defaultID = mainrole_data.gender == 1 and 21000 or 22000;
        MountCtrl:GetInstance():RequestMorph(enum.TRAIN.TRAIN_WING, defaultID);
    elseif id == "130@3" then
        --MountCtrl:GetInstance():RequestMorph(enum.TRAIN.TRAIN_WING, self.modelViewID);
    elseif id == "130@4" then
        MountCtrl:GetInstance():RequestMorph(enum.TRAIN.TRAIN_TALIS, 30000);
    elseif id == "130@5" then
        MountCtrl:GetInstance():RequestMorph(enum.TRAIN.TRAIN_WEAPON, 40000);
    end
    local isPop = Config.db_sysopen[id].pop
    if isPop == 1 or isPop == 2 then
        if not self.model.isOpenning then
            if self.model.isBeginGame then
                self.model.isOpenning = true
                self:OpenPanel(data.id, data.isOpenUI)
            else
                self.model.isOpenning = true

                local function step()
                    self:OpenPanel(data.id, data.isOpenUI)
                end
                GlobalSchedule:StartOnce(step, 3)
            end
        end
    elseif isPop == 3 then
        if not self.model.isOpenning then
            UnpackLinkConfig(id)
        end
    end
end

function OpenTipController:OpenPanel(id, isOpenUI)
    self.model.isOpenning = true
    lua_panelMgr:GetPanelOrCreate(OpenTipPanel):Open(isOpenUI, id)
end

function OpenTipController:HandleOpenNext()
    local data = self.model:GetNextNeedShow()
    if data then
        dump(data.syslist, "<color=#6ce19b>HandleOpenNext   HandleOpenNext  HandleOpenNext  HandleOpenNext</color>")
        local nameId
        local sysData = GetOpenByKey(data.id)
        if sysData then
            nameId = sysData.key_str
        else
            nameId = Config.db_sysopen[data.id].key
        end
        GlobalEvent:Brocast(EventName.OpenFunction, 2, nameId)
        if not data.isOpenUI then
            self.model.isOpenning = false
        end
        if self.model:GetNeedShowNums() > 0 then
            self.model.isOpenning = true
            local data = self.model:GetNextNeedShow()
            if not data.isOpenTip then
                --不弹开放
                if data.isOpenUI then
                    --弹界面
                    UnpackLinkConfig(data.id)
                end
            else
                --弹开放
                local function step()
                    self:OpenPanel(data.id, data.isOpenUI)
                end
                GlobalSchedule:StartOnce(step, 0.2)
            end
        end
    end
end




