---
--- Created by  Administrator
--- DateTime: 2019/8/28 14:45
---
require('game.baby.RequireBaby')
BabyController = BabyController or class("BabyController", BaseController)
local BabyController = BabyController

function BabyController:ctor()
    BabyController.Instance = self
    self.model = BabyModel:GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
end

function BabyController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function BabyController:GetInstance()
    if not BabyController.Instance then
        BabyController.new()
    end
    return BabyController.Instance
end

function BabyController:AddEvents()
    local function call_back(index,id)
        lua_panelMgr:GetPanelOrCreate(BabyMainPanel):Open(index,id)
    end
    GlobalEvent:AddListener(BabyEvent.OpenBabyPanel, call_back)

    
    local function call_back()  --子女展示界面

    end
    GlobalEvent:AddListener(BabyEvent.OpenBabyShowPanel, call_back)

    
    local function call_back(id)
        for i, v in pairs(self.model.itemIds) do
            if id == i then
                self.model:CheckCulRedPoint()
            end
        end
    end
    GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)
    
    local function call_back()
        self.model:CheckCulRedPoint()
    end
    RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.BabyScore, call_back)
    
    local function call_back()
     --  local isTaskRed = false
        local isCheck = false
        local taskTab = String2Table(Config.db_baby[1].task)[1]
        for i = 1, #taskTab do
            local taskId = taskTab[i]
            local num =  self.model.taskInfo[taskId]
            local info = TaskModel:GetInstance():GetTask(taskId)
            if info  then
                if num ~= info.count then
                    self.model.taskInfo[taskId] = info.count
                    isCheck = true
                end
            end
        end
        if isCheck then
            self.model:CheckCulRedPoint()
        end

    end
    GlobalEvent:AddListener(TaskEvent.GlobalUpdateTask,call_back)


    --local function call_back(data)
    --    dump(data)
    --    logError("子女背包")
    --end
    --GlobalEvent:AddListener(BabyEvent.BabyBagInfo,call_back)

end

function BabyController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    --self.pb_module_name = "protobuff_Name"
    self.pb_module_name = "pb_1138_baby_pb"
    self:RegisterProtocal(proto.BABY_INFO, self.HandleBabyInfo);
    self:RegisterProtocal(proto.BABY_UPLEVEL, self.HandleUpLevel);
    self:RegisterProtocal(proto.BABY_PLAY, self.HandlePlay);
    self:RegisterProtocal(proto.BABY_ORDER_INFO, self.HandleOrderInfo);
    self:RegisterProtocal(proto.BABY_UP_ORDER, self.HandleUpOrder);
    self:RegisterProtocal(proto.BABY_ACTIVE, self.HandleActive);
    self:RegisterProtocal(proto.BABY_FIGURE, self.HandleFigure);
    self:RegisterProtocal(proto.BABY_HIDE, self.HandleHide);
    self:RegisterProtocal(proto.BABY_LIKE, self.HandleBabyLike);
    self:RegisterProtocal(proto.BABY_LIKE_RECORDS, self.HandleBabyLikeRecords);
    self:RegisterProtocal(proto.BABY_EQUIPS, self.HandleBabyEquips);
    self:RegisterProtocal(proto.BABY_EQUIP_PUTON, self.HandleBabyEquipPutOn);
    self:RegisterProtocal(proto.BABY_EQUIP_UPLEVEL, self.HandleBabyEquipUpLevel);
    self:RegisterProtocal(proto.BABY_EQUIP_DECOMPOSE, self.HandleBabyEquipDecompose);
    self:RegisterProtocal(proto.BABY_LIKE_INFO, self.HandleBabyLikeInfo);
    self:RegisterProtocal(proto.BABY_LIKE_RECORD, self.HandleBabyLikeRecord);
    self:RegisterProtocal(proto.BABY_WING, self.HandleChange);
    self:RegisterProtocal(proto.BABY_WING_UPLEVEL, self.HandleWingUpLevel);
    self:RegisterProtocal(proto.BABY_WING_SHOW, self.HandleShow);
end

-- overwrite
function BabyController:GameStart()
    local function call_back()
        self:RequstBabyInfo()
        self:RequstOrderInfo()
        self:RequstBabyEquips()
        self:RequstBabyLikeRecords()
        self:RequestChange()
        self.model:InitBabyTaskInfo()
    end
    GlobalSchedule:StartOnce(call_back, Constant.GameStartReqLevel.Low)
end

--子女信息
function BabyController:RequstBabyInfo()
    local pb = self:GetPbObject("m_baby_info_tos")

    self:WriteMsg(proto.BABY_INFO,pb)
end


function BabyController:HandleBabyInfo()
    local data = self:ReadMsg("m_baby_info_toc")
    self.model.isHide = data.is_hide
    for i, v in pairs(data.babies) do
        self.model.babies[v.gender] = v
    end
   -- self.model.babies = data.babies
    for i, v in pairs(data.progress) do
        self.model.progress[i] = v
    end
    self.model:Brocast(BabyEvent.BabyInfo,data)

    self.model:CheckCulRedPoint()
end


--培养
function BabyController:RequstUpLevel(gender)
    local pb = self:GetPbObject("m_baby_uplevel_tos")
    pb.gender = gender
    self:WriteMsg(proto.BABY_UPLEVEL,pb)
end


function BabyController:HandleUpLevel()
    local data = self:ReadMsg("m_baby_uplevel_toc")
    self.model:Brocast(BabyEvent.BabyUpLevel,data)
end


--逗宝宝
function BabyController:RequstPlay(gender)
    local pb = self:GetPbObject("m_baby_play_tos")
    pb.gender = gender
    self:WriteMsg(proto.BABY_PLAY,pb)
end


function BabyController:HandlePlay()
    local data = self:ReadMsg("m_baby_play_toc")
    self.model:Brocast(BabyEvent.BabyPlay,data)
end

--进阶信息
function BabyController:RequstOrderInfo()
    local pb = self:GetPbObject("m_baby_order_info_tos")
    self:WriteMsg(proto.BABY_ORDER_INFO,pb)
end


function BabyController:HandleOrderInfo()
    local data = self:ReadMsg("m_baby_order_info_toc")
    dump(data)
    for i, v in pairs(data.babies) do
       -- if not self.model.orderBabies[v.id] then
            self.model.orderBabies[v.id] = v
      --  end
    end
   -- self.model.orderBabies = data.babies
    self.model.figure = data.figure
    self.model:Brocast(BabyEvent.BabyOrderInfo,data)
--    self.model:CheckRedPoint()
    self.model:CheckCulRedPoint()
end

--进阶
function BabyController:RequstUpOrder(id,item_id)
    local pb = self:GetPbObject("m_baby_up_order_tos")
    pb.id = id
    pb.item_id = item_id
    self:WriteMsg(proto.BABY_UP_ORDER,pb)
end


function BabyController:HandleUpOrder()
    local data = self:ReadMsg("m_baby_up_order_toc")
    self.model:Brocast(BabyEvent.BabyUpOrder,data)
end



--宝宝激活
function BabyController:RequstActive(id)
    local pb = self:GetPbObject("m_baby_active_tos")
    pb.id = id
    self:WriteMsg(proto.BABY_ACTIVE,pb)
end


function BabyController:HandleActive()
    local data = self:ReadMsg("m_baby_active_toc")
    self.model:Brocast(BabyEvent.BabyActive,data)
end


--宝宝幻化
function BabyController:RequstFigure(id)
    local pb = self:GetPbObject("m_baby_figure_tos")
    pb.id = id
    self:WriteMsg(proto.BABY_FIGURE,pb)
end


function BabyController:HandleFigure()
    local data = self:ReadMsg("m_baby_figure_toc")
    self.model:Brocast(BabyEvent.BabyFigure,data)
end



function BabyController:RequstHide(hide)
    local pb = self:GetPbObject("m_baby_hide_tos")
    pb.hide = hide
    self:WriteMsg(proto.BABY_HIDE,pb)
end

function BabyController:HandleHide()
    local data = self:ReadMsg("m_baby_hide_toc")
    self.model:Brocast(BabyEvent.BabyHide,data)
end




--点赞
function BabyController:RequstBabyLike(role_id)
    local pb = self:GetPbObject("m_baby_like_tos")
    pb.role_id = role_id
    self:WriteMsg(proto.BABY_LIKE,pb)
end

function BabyController:HandleBabyLike()
    local data = self:ReadMsg("m_baby_like_toc")
    if not table.isempty(self.model.recordsInfo) then
        for i = 1, #self.model.recordsInfo do
            local role_id = self.model.recordsInfo[i].role_id
            if data.role_id == role_id then
                self.model.recordsInfo[i].state = 1
            end
        end
    end
    self.model:Brocast(BabyEvent.BabyLike,data)
    self.model:CheckCulRedPoint()
end

--请求点赞记录
function BabyController:RequstBabyLikeRecords()
    local pb = self:GetPbObject("m_baby_like_records_tos")

    self:WriteMsg(proto.BABY_LIKE_RECORDS,pb)
end


function BabyController:HandleBabyLikeRecords()
    local data = self:ReadMsg("m_baby_like_records_toc")
    self.model.recordsInfo = data.records
    self.model:Brocast(BabyEvent.BabyLikeRecord,data)
    self.model:CheckCulRedPoint()
end

function BabyController:HandleBabyLikeRecord()
    local data = self:ReadMsg("m_baby_like_record_toc")
    if table.isempty(self.model.recordsInfo)  then
        table.insert(self.model.recordsInfo,data.record)
    else
        local isHas = false
        for i = 1, #self.model.recordsInfo do
            local role_id = self.model.recordsInfo[i].role_id
            if data.role_id == role_id then
                self.model.recordsInfo[i] = data.record
                isHas = true
                break
              
            end
        end
        if not isHas then
            table.insert(self.model.recordsInfo,data.record)
        end
    end
    self.model:CheckCulRedPoint()
end




function BabyController:RequstBabyLikeInfo(role_id)
    local pb = self:GetPbObject("m_baby_like_info_tos")
    pb.role_id = role_id
    self:WriteMsg(proto.BABY_LIKE_INFO,pb)
end


function BabyController:HandleBabyLikeInfo()
    local data = self:ReadMsg("m_baby_like_info_toc")
    lua_panelMgr:GetPanelOrCreate(BabyShowPanel):Open(data)
    self.model:Brocast(BabyEvent.BabyLikeInfo,data)
end



--请求装备
function BabyController:RequstBabyEquips()
    local pb = self:GetPbObject("m_baby_equips_tos")
    self:WriteMsg(proto.BABY_EQUIPS,pb)
end

function BabyController:HandleBabyEquips()
    local data = self:ReadMsg("m_baby_equips_toc")
    self.model:DealEquipsInfo(data.equips)
   -- self.model.equipsInfo = data.equips
    self.model:Brocast(BabyEvent.BabyEquips,data)
    self.model:CheckCulRedPoint()
    self.model:CheckIsBatterEquip()
end



--穿戴
function BabyController:RequstBabyEquipPutOn(uid)
    local pb = self:GetPbObject("m_baby_equip_puton_tos")
    pb.uid = uid
    self:WriteMsg(proto.BABY_EQUIP_PUTON,pb)
end

function BabyController:HandleBabyEquipPutOn()
    local data = self:ReadMsg("m_baby_equip_puton_toc")
    Notify.ShowText("Equipped")
    self.model:Brocast(BabyEvent.BabyEquipPutOn,data)
   -- self:CheckCulRedPoint()
end




--升級
function BabyController:RequstBabyEquipUpLevel(slot)
    local pb = self:GetPbObject("m_baby_equip_uplevel_tos")
    pb.slot = slot
    self:WriteMsg(proto.BABY_EQUIP_UPLEVEL,pb)
end

function BabyController:HandleBabyEquipUpLevel()
    local data = self:ReadMsg("m_baby_equip_uplevel_toc")

    self.model:Brocast(BabyEvent.BabyEquipUpLevel,data)
    --self:CheckCulRedPoint()
end



--分解
function BabyController:RequstBabyEquipDecompose(uids)
    local pb = self:GetPbObject("m_baby_equip_decompose_tos")
    for i, uid in pairs(uids) do
        pb.uid:append(uid)
    end
    self:WriteMsg(proto.BABY_EQUIP_DECOMPOSE,pb)
   -- self:CheckCulRedPoint()
end

function BabyController:HandleBabyEquipDecompose()
    local data = self:ReadMsg("m_baby_equip_decompose_toc")
    if self.model.selectEquip then
        self.model.selectEquip = {}
    end
    self.model:Brocast(BabyEvent.BabyEquipDecompose,data)
end


--翅膀 幻化
function BabyController:RequestChange()
    local pb = self:GetPbObject("m_baby_wing_tos")
    self:WriteMsg(proto.BABY_WING,pb)
end

function BabyController:HandleChange()
    local data = self:ReadMsg("m_baby_wing_toc")
    self.model:SetWingInfo(data)
    self.model:CheckCulRedPoint()
	self.model:Brocast(BabyEvent.BabyWingUpdate)
end


function BabyController:RequestWingUpLevel(id)
    local pb = self:GetPbObject("m_baby_wing_uplevel_tos")
    pb.id = id
    self:WriteMsg(proto.BABY_WING_UPLEVEL,pb)
end

function BabyController:HandleWingUpLevel()
    local data = self:ReadMsg("m_baby_wing_uplevel_toc")
    Notify.ShowText("Advanced")
end


function BabyController:RequestShow(id)
    local pb = self:GetPbObject("m_baby_wing_show_tos")
    pb.id = id
    self:WriteMsg(proto.BABY_WING_SHOW,pb)
end

function BabyController:HandleShow()
    local data = self:ReadMsg("m_baby_wing_show_toc")
    Notify.ShowText("Transmorphed")
end
