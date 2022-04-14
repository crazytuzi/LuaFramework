--
-- Created by IntelliJ IDEA.
-- User: jielin
-- Date: 2018/9/26
-- Time: 15:19
-- To change this template use File | Settings | File Templates.
--

require("game.combine.RequireCombine")
CombineController = CombineController or class("CombineController", BaseController)
local CombineController = CombineController

function CombineController:ctor()
    CombineController.Instance = self
    self.model = CombineModel:GetInstance()
    self.rd_show_tog_key = "Is_Show_Combine_Red_Dot"

    self:AddEvents()
    self:RegisterAllProtocal()
end

function CombineController:dctor()
    RoleInfoModel.GetInstance():GetMainRoleData():RemoveListener(self.lv_up_bind_event)
end

function CombineController:GetInstance()
    if not CombineController.Instance then
        CombineController.new()
    end
    return CombineController.Instance
end

function CombineController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1106_equip_pb"
    self:RegisterProtocal(proto.EQUIP_COMBINE, self.HandleCombine)
end

function CombineController:AddEvents()
    self.global_event = {}
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(CombineEvent.OpenCombinePanel, handler(self, self.DealShowEquipCombinePanel))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(CombineEvent.UpdateRDSwitch, handler(self, self.HandleRDSwitch))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, handler(self, self.CheckRedDot))

    self.lv_up_bind_event = RoleInfoModel.GetInstance():GetMainRoleData():BindData("level", handler(self, self.CheckRedDot))
end

function CombineController:DealShowEquipCombinePanel(index, toggle, is_auto_judge_gender, defa_fist_id, defa_sec_id)
    --self.model.default_tog = toggle
    if defa_sec_id then
        local cf = Config.db_equip_combine_type_set[defa_sec_id]
        if cf then
            local cur_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
            local limit_lv = cf.open_level
            if cur_lv < limit_lv then
                local final_lv = GetLevelShow(limit_lv)
                local str = 'Unlocks at L.%s'
                Notify.ShowText(string.format(str, final_lv))
                return
            end
        else
            logError("CombineController,53:db_equip_combine_type_set中没有id为:" .. defa_sec_id .. "  的配置")
            return
        end
    end
    if toggle and toggle < 30 then
        toggle = nil
    end
    if defa_fist_id and defa_fist_id < 30 then
        defa_fist_id = nil
    end
    if defa_sec_id and defa_sec_id < 30 then
        defa_sec_id = nil
    end
    lua_panelMgr:GetPanelOrCreate(CombinePanel):Open(index, toggle, is_auto_judge_gender, defa_fist_id, defa_sec_id)
end

-- overwrite
function CombineController:GameStart()
    local function step()
        self:CheckRedDot()
    end
    self.crossday_delay_sche = GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.VLow)
end

--请求基本信息
function CombineController:RequestCombine(ItemId)
    local pb = self:GetPbObject("m_equip_combine_tos")
    pb.item_id = ItemId
    for id, num in pairs(self.model:GetUsedUids()) do
        local item = pb.cost:add()
        item.key = id
        item.value = num
    end
    self:WriteMsg(proto.EQUIP_COMBINE, pb)
end

--服务的返回信息
function CombineController:HandleCombine()
    self:CheckRedDot()
    local data = self:ReadMsg("m_equip_combine_toc")
    local tips = ""
    if data.result == 0 then
        tips = "Combination successful!!"
        self.model:Brocast(CombineEvent.SuccessCombine)
        Notify.ShowText(tips)
    elseif data.result == 1 then
        tips = "Combination failed....."
        Notify.ShowText(tips)
    end
    GlobalEvent:Brocast(CombineEvent.UpdateCombineArea)
end


--获取可以作为材料的装备
function CombineController:GetAllCombineEquips(ItemIds)
    local result = {}
    for _, ItemId in pairs(ItemIds) do
        local itemlist = BagController:GetInstance():GetEquipList(ItemId)
        for _, p_item_base in pairs(itemlist) do
            if not self.model:IsUidUsed(p_item_base.uid) then
                table.insert(result, p_item_base)
            end
        end
    end
    local function sortFun(a, b)
        return a.score < b.score
    end
    table.sort(result, sortFun)
    local tbl = {}
    local count = 20
    if #result < count then
        count = #result
    end
    for i = 1, count do
        tbl[#tbl + 1] = result[i]
    end
    return tbl
end

function CombineController:CheckRedDot()
    self.model:CheckScanListRD()
    self.model.is_hide_combine_rd = CacheManager.GetInstance():GetBool(self.rd_show_tog_key)
    local is_show_main_rd = false
    --有红点
    if self.model.side_rd_list and (not table.isempty(self.model.side_rd_list)) then
        for i, v in pairs(self.model.side_rd_list) do
            local is_show = v
            if self.model.is_hide_combine_rd and v then
                --红点已开，显示红点
                is_show = false
            elseif v then
                is_show_main_rd = true
            end
            self.model:Brocast(CombineEvent.UpdateEquipCombineRD, is_show, i)
        end
        self.model.is_show_combine_rd = is_show_main_rd
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "combine", is_show_main_rd)
    end
end

function CombineController:HandleRDSwitch(is_hide_rd)
    if is_hide_rd then
        --隐藏红点
        for i = 1, 3 do
            self.model:Brocast(CombineEvent.UpdateEquipCombineRD, false, i)
        end
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "combine", false)
    else
        --显示红点
        --检查有没有红点
        self:CheckRedDot()
    end
end