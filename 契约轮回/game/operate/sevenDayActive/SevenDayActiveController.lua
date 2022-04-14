---
--- Created by  Administrator
--- DateTime: 2019/4/12 14:35
---
require('game.operate.sevenDayActive.RequireSevenDayActive')
SevenDayActiveController = SevenDayActiveController or class("SevenDayActiveController", BaseController)
local SevenDayActiveController = SevenDayActiveController

function SevenDayActiveController:ctor()
    SevenDayActiveController.Instance = self
    self.model = SevenDayActiveModel:GetInstance()
    self.events = {}
    self:AddEvents()
    self.isFirstReq = true
    self:RegisterAllProtocol()
end

function SevenDayActiveController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function SevenDayActiveController:GetInstance()
    if not SevenDayActiveController.Instance then
        SevenDayActiveController.new()
    end
    return SevenDayActiveController.Instance
end

function SevenDayActiveController:AddEvents()
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayActivePanel, handler(self, self.HandleOpenDayActiveEvent))
    GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, handler(self, self.ActiveInfo))
    GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.ReturnReward))

    
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(SevenDayActivePanel):Open(2)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenBuyPanel, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(SevenDayActivePanel):Open(3)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayRechargeOnePanel, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(SevenDayActivePanel):Open(4)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayTargePanel, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(SevenDayActivePanel):Open(5)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayRechargePanel, call_back)

    --宠物活动
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(SevenDayPetMainPanel):Open(1)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayPetPanel, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(SevenDayPetMainPanel):Open(2)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayPetBuyPanel, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(SevenDayPetMainPanel):Open(3)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayPetVipPanel, call_back)
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(SevenDayPetMainPanel):Open(4)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayPetRechargePanel, call_back)
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(SevenDayPetMainPanel):Open(5)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayPetTargetPanel, call_back)

    -- 图鉴冲榜
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(IllustratedMainPanel):Open(1)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenIllustratedRankPanel, call_back)
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(IllustratedMainPanel):Open(2)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenIllustratedBuyPanel, call_back)
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(IllustratedMainPanel):Open(3)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenIllustratedRechargePanel, call_back)
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(IllustratedMainPanel):Open(4)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenIllustratedTargetPanel, call_back)
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(IllustratedMainPanel):Open(5)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenIllustratedBoxPanel, call_back)

    --local function call_back()
    --    lua_panelMgr:GetPanelOrCreate(SevenDayPetBuyPanel):Open(6)
    --end
    --GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayBuyPanel, call_back)


    local function callback()
        local id1 = OperateModel:GetInstance():GetActIdByType(101)
        local id2 = OperateModel:GetInstance():GetActIdByType(102)
        local id3 = OperateModel:GetInstance():GetActIdByType(103)
        local id4 = OperateModel:GetInstance():GetActIdByType(304)
        if id1 ~= 0 then
           OperateController:GetInstance():Request1700006(id1)
        end
        if id2 ~= 0 then
            OperateController:GetInstance():Request1700006(id2)
        end
        if id3 ~= 0 then
            OperateController:GetInstance():Request1700006(id3)
        end
        if id4 ~= 0 then
            OperateController:GetInstance():Request1700006(id4)
        end
    end
    GlobalEvent:AddListener(EventName.CrossDayAfter, callback)


    local function call_back()
        lua_panelMgr:GetPanelOrCreate(MergeSerActivePanel):Open(1)
    end
    GlobalEvent:AddListener(SevenDayActiveEvent.OpenMergeRankPanel, call_back)

end

function SevenDayActiveController:HandleOpenDayActiveEvent()
    lua_panelMgr:GetPanelOrCreate(SevenDayActivePanel):Open(1)
end

function SevenDayActiveController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    --self.pb_module_name = "protobuff_Name"
    -- self:RegisterProtocal(proto.GAME_PAYSUCC, self.HandlePaySucc)
end

-- overwrite
function SevenDayActiveController:GameStart()

end

function SevenDayActiveController:ActiveInfo(info)
    local id = info.id

    if OperateModel:GetInstance():GetActIdByType(104) == info.id then --限購
        self.model.redPoints[id] = self.model.isFirstOpen_buy
    elseif OperateModel:GetInstance():GetActIdByType(105) == info.id then
        self.model.redPoints[id] = self.model.isFirstOpen_rank
    end
    if OperateModel:GetInstance():GetActIdByType(101) == info.id or OperateModel:GetInstance():GetActIdByType(102) == info.id or OperateModel:GetInstance():GetActIdByType(103) == info.id then  --开服累冲
       -- dump(info)
        self.model.redPoints[id] = false
        for i = 1, #info.tasks do
            if info.tasks[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then --已完成
                self.model.redPoints[id] = true
                break
            end
        end
        local isRed = false
        for i, v in pairs(self.model.redPoints) do
            if v == true then
                isRed = true
                break
            end
        end

        OperateModel:GetInstance():UpdateIconReddot(id,isRed)
        if self.model:GetActType(id) == 101 then
            GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,29,self.model.redPoints[id])
        elseif self.model:GetActType(info.id) == 102 then
            GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,31,self.model.redPoints[id])
        elseif self.model:GetActType(info.id) == 103 then
            GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,30,self.model.redPoints[id])
        end
    end
   -- self.model.mergeRedPoints
    if OperateModel:GetInstance():GetActIdByType(802) == info.id or OperateModel:GetInstance():GetActIdByType(803) == info.id  then
        self.model.mergeRedPoints[id] = false
        for i = 1, #info.tasks do
            if info.tasks[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then --已完成
                self.model.mergeRedPoints[id] = true
                break
            end
        end
        local isRed = false
        for i, v in pairs(self.model.mergeRedPoints) do
            if v == true then
                isRed = true
                break
            end
        end
        OperateModel:GetInstance():UpdateIconReddot(id,isRed)
    end


    self.model:Brocast(SevenDayActiveEvent.RedPointInfo)
    self:CheckPetRedPoint(info)
end
function SevenDayActiveController:ReturnReward(data)
    for id, v in pairs(self.model.redPoints) do
        if data.act_id == id then
            local info =  OperateModel:GetInstance():GetActInfo(id)
            local boo = false
            for i = 1, #info.tasks do
                if info.tasks[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH  then
                    boo = true
                    break
                end
            end
            self.model.redPoints[id] = boo
        end
    end
    local isRed = false
    for i, v in pairs(self.model.redPoints) do
        if v == true then
            isRed = true
           -- break
        end
        OperateModel:GetInstance():UpdateIconReddot(i,v)
        if self.model:GetActType(i) == 101 then
            GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,29,self.model.redPoints[i])
        elseif self.model:GetActType(i) == 102 then
            GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,31,self.model.redPoints[i])
        elseif self.model:GetActType(i) == 103 then
            GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,30,self.model.redPoints[i])
        end
    end


    for id, v in pairs(self.model.mergeRedPoints) do
        if data.act_id == id then
            local info =  OperateModel:GetInstance():GetActInfo(id)
            local boo = false
            for i = 1, #info.tasks do
                if info.tasks[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH  then
                    boo = true
                    break
                end
            end
            self.model.mergeRedPoints[id] = boo
        end
    end
    local isRed = false
    for i, v in pairs(self.model.mergeRedPoints) do
        if v == true then
            isRed = true
            -- break
        end
        OperateModel:GetInstance():UpdateIconReddot(i,v)
    end

    self.model:Brocast(SevenDayActiveEvent.RedPointInfo)




    for id, v in pairs(self.model.petRedPoints) do
        if data.act_id == id then
            local info =  OperateModel:GetInstance():GetActInfo(id)
            local boo = false
            for i = 1, #info.tasks do
                if info.tasks[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH  then
                    boo = true
                    break
                end
            end
            self.model.petRedPoints[id] = boo
        end
    end
    local isRed = false
    for i, v in pairs(self.model.petRedPoints) do
        if v == true then
            isRed = true
            -- break
        end
        OperateModel:GetInstance():UpdateIconReddot(i,v)
    end
    self.model:Brocast(SevenDayActiveEvent.PetRedPointInfo)

end

-- function SevenDayActiveController:HandlePaySucc()
--     local data = self:ReadMsg("m_game_paysucc_toc", "pb_1000_game_pb")

--     self.model:Brocast(SevenDayActiveEvent.PaySucc)
-- end

function SevenDayActiveController:CheckPetRedPoint(info)
    local id = info.id
    if id == 130301 or id == 130401 or id == 130501 then

        self.model.petRedPoints[id] = false
        for i = 1, #info.tasks do
            if info.tasks[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then --已完成
                self.model.petRedPoints[id] = true
                break
            end
        end
        local isRed = false
        for i, v in pairs(self.model.petRedPoints) do
            if v == true then
                isRed = true
                break
            end
        end
        OperateModel:GetInstance():UpdateIconReddot(id,isRed)
    end
    self.model:Brocast(SevenDayActiveEvent.PetRedPointInfo)
end