--
-- @Author: LaoY
-- @Date:   2018-12-20 19:37:30
--
MagictowerTreasureModel = MagictowerTreasureModel or class("MagictowerTreasureModel", BaseModel)
local MagictowerTreasureModel = MagictowerTreasureModel

function MagictowerTreasureModel:ctor()
    MagictowerTreasureModel.Instance = self
    self.is_skip = CacheManager:GetBool(MtTreasureConstant.CacheSkipKey, false)
    self:Reset()
end

function MagictowerTreasureModel:Reset()
    self.mt_treasure_info = nil

    self.cost_cf = {}

    -- 当前魔法卡寻宝寻路的数据
    self.cur_mtt_astar = {}

    self.dig_talk_index = nil
    self.dig_data = nil
end

function MagictowerTreasureModel.GetInstance()
    if MagictowerTreasureModel.Instance == nil then
        MagictowerTreasureModel()
    end
    return MagictowerTreasureModel.Instance
end

function MagictowerTreasureModel:CheckGoods(num, ok_func,auto_use)
    if not self.mt_treasure_info then
        return false
    end
    local value = self.mt_treasure_info.power or 0
    if value < num then

        local need_cf = Config.db_item[enum.ITEM.ITEM_MC_HUNT]
        local use_cf = Config.db_item[MtTreasureConstant.StarPowerStoneID]

        -- local cf = Config.db_item[MtTreasureConstant.StarPowerStoneID]
        local cf = Config.db_voucher[MtTreasureConstant.StarPowerStoneID]
        local need_num = math.ceil((num - value) / tonumber(use_cf.effect))
        local money_cf = Config.db_item[cf.type]
        local money = need_num * cf.price

        local function check_ok_func()
            local value = BagModel:GetInstance():GetItemNumByItemID(cf.type)
            if value <= money then
                -- Notify.ShowText(value)
                local message = string.format("Insufficient %s, top-up now?", money_cf.name)
                local function link_func()
                    UnpackLinkConfig("401@2")
                end
                Dialog.ShowTwo('Tip', message, 'Confirm', link_func, nil, 'Cancel', nil, nil, nil)
                return
            end
            if ok_func then
                ok_func()
            end
        end

        local function DialogFunc()
            local message = string.format("Insufficient %s,comsume %s %s to buy %s*%s to anto-use?",need_cf.name, money, money_cf.name, need_num,use_cf.name)
            Dialog.ShowTwo('Tip', message, 'Confirm', check_ok_func, nil, 'Cancel', nil, nil, "Don't notice me again today", true, false, self.__cname .. num)
        end

        local item = BagModel:GetInstance():GetItemByItemId(MtTreasureConstant.StarPowerStoneID)
        if auto_use and item and item.num > 0 then
            local function ok_func()
				local cf = Config.db_item[item.id]
				local one_count = tonumber(cf.effect)
				local need_use_count = math.ceil((num - value)/one_count)
				need_use_count = need_use_count > item.num and item.num or need_use_count
				BagModel.Instance:Brocast(BagEvent.UseGoods,item,need_use_count)
            end
            local function cancel_func()
                DialogFunc()
            end
            local message = string.format("There are unused %s in the bag, using %s first?",use_cf.name,use_cf.name)
            Dialog.ShowTwo('Tip',message,'Confirm',ok_func,nil,'Cancel',cancel_func)
        else
            DialogFunc()
        end
        return false
    end
    ok_func()
    return true
end

function MagictowerTreasureModel:StartTime()
    self:StopTime()
    local function step()
        if self.mt_treasure_info and self.mt_treasure_info.etime < os.time() then
            self:StopTime()
            self:ClearMtT()
            self:Brocast(MagictowerTreasureEvent.TimeOut)
        end
    end
    self.time_id = GlobalSchedule:Start(step, 1.0)
end

function MagictowerTreasureModel:StopTime()
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
        self.time_id = nil
    end
end

-- 清除当次的寻宝，包括寻宝寻路超时要停止
function MagictowerTreasureModel:ClearMtT()
    if self.mt_treasure_info then
        self.mt_treasure_info.etime = 0
        self.mt_treasure_info.dig = 0
        self.mt_treasure_info.pos = nil
    end
    self.dig_talk_index = nil
    self.select_index = nil
    self:StopAutoDig()
    -- 寻路中，把寻路停了
    if not table.isempty(self.cur_mtt_astar) and OperationManager:GetInstance():IsAutoWay() then
        local move_operation = OperationManager:GetInstance().move_operation
        if move_operation.scene_info.target_scene_id == self.cur_mtt_astar.scene_id and
                move_operation.end_pos.x == self.cur_mtt_astar.x and move_operation.end_pos.x == self.cur_mtt_astar.y then
            Notify.ShowText("The treasure hunt is over, please restart")
            OperationManager:GetInstance():StopAStarMove()
        end
    end
end

function MagictowerTreasureModel:CheckEnterNpcScene(call_back)
    local scene_id = self.mt_treasure_info.scene
    local cur_scene_id = SceneManager:GetInstance():GetSceneId()
    local message
    local cf = Config.db_mchunt_out[cur_scene_id]
    if scene_id ~= cur_scene_id and cf and cf.tipsneed == 1 then
        message = cf.dec
    end
    if message then
        local function ok_func()
            call_back()
        end
        Dialog.ShowTwo('Tip', message, 'Confirm', ok_func, nil, 'Cancel', nil, nil)
    else
        call_back()
    end
end

function MagictowerTreasureModel:FindIndex(index)
    if not self.mt_treasure_info then
        return false
    end
    if self.mt_treasure_info.etime < os.time() then
        Notify.ShowText("The treasure hunt is over, please restart")
        return false
    end
    local function call_back()
        local scene_id = self.mt_treasure_info.scene
        local pos = self.mt_treasure_info.pos[index]
        local function npc_call_back()
            self.cur_mtt_astar = {}
            -- lua_panelMgr:OpenPanel(MtTreasureDigPanel,index,1)
            local npc_id = MtTreasureConstant.NPCList[index]
            local npc_obj = SceneManager:GetInstance():GetObject(npc_id)
            if npc_obj then
                OperationManager:GetInstance():StopAStarMove()
                AutoFightManager:GetInstance():Stop()
                npc_obj:OnClick()
            end
        end
        local function callback()
            GlobalSchedule:StartOnce(npc_call_back,MtTreasureConstant.TouchNPCTime)
        end
        -- self:EnterMttScene()
        local bo = OperationManager:GetInstance():CheckMoveToPosition(scene_id, nil, pos, callback, SceneConstant.NPCRange,nil,nil,nil,nil,handler(self,self.EnterMttScene))
        if bo then
            TaskModel:GetInstance():PauseTask(false)
        end
        self.cur_mtt_astar.scene_id = scene_id
        self.cur_mtt_astar.pos = pos
        self.select_index = index
        self:Brocast(MagictowerTreasureEvent.SelectIndex, index)
    end
    self:CheckEnterNpcScene(call_back)
    return true
end

function MagictowerTreasureModel:EnterMttScene()
    local scene_id = self.mt_treasure_info.scene
    if scene_id == SceneManager:GetInstance():GetSceneId() then
        return
    end
    TaskModel:GetInstance():PauseTask(false)
    if MainModel.SwitchType.City == MainModel:GetSwitchType() then
        SceneControler:GetInstance():RequestSceneChange(scene_id, 2)
    else
        SceneControler:GetInstance():RequestSceneLeave(true)
    end
end

function MagictowerTreasureModel:AddNpcs()
    if not self.mt_treasure_info or not self.mt_treasure_info.pos then
        return
    end

    local scene_id = self.mt_treasure_info.scene

    if not self.mt_treasure_info.pos then
        return
    end

    for i = 1, #MtTreasureConstant.NPCList do
        local npc_id = MtTreasureConstant.NPCList[i]
        local pos = self.mt_treasure_info.pos[i]
        if pos then
            MapLayer:GetInstance():AddNpc(scene_id, npc_id, pos.x, pos.y)
        end
    end
    MapLayer:GetInstance():UpdateNpc()
end

function MagictowerTreasureModel:RemoveNpcs()
    if not self.mt_treasure_info then
        return
    end
    local scene_id = self.mt_treasure_info.scene
    if scene_id == 0 then
        return
    end
    for i = 1, #MtTreasureConstant.NPCList do
        local npc_id = MtTreasureConstant.NPCList[i]
        MapLayer:GetInstance():RemoveNpc(scene_id, npc_id)
    end
    MapLayer:GetInstance():UpdateNpc()
end

function MagictowerTreasureModel:IsMttNpc(npc_id)
    for k, id in pairs(MtTreasureConstant.NPCList) do
        if id == npc_id then
            return true
        end
    end
    return false
end

function MagictowerTreasureModel:GetNpcIndex(npc_id)
    for k, id in pairs(MtTreasureConstant.NPCList) do
        if id == npc_id then
            return k
        end
    end
    return
end

function MagictowerTreasureModel:ClickNpc(npc_id)
    local index = self:GetNpcIndex(npc_id)
    if index == self.dig_talk_index then
        lua_panelMgr:OpenPanel(MtTreasureDigPanel, index, 2)
    else
        lua_panelMgr:OpenPanel(MtTreasureDigPanel, index, 1)
    end
end

function MagictowerTreasureModel:DigMtt()
    if not self.dig_data then
        return
    end

    self:StopAutoDig()
    local function step()
        local object = SceneManager:GetInstance():GetObject(self.dig_data.uid)
        if not object then
            object = SceneManager:GetInstance():GetCreepInScreen()
        end
        -- if self.dig_data.type == 2 then

        -- elseif self.dig_data.type == 3 then

        -- end
        if object and object.is_loaded then
            -- 把自动战斗停了
            OperationManager:GetInstance():StopAStarMove()
            AutoFightManager:GetInstance():Stop()
            object:OnClick()
            self:StopAutoDig()
        end

        if not object then
            self:StopAutoDig()
        end
    end
    self.dig_time_id = GlobalSchedule:Start(step, 0.3, 4)
end

function MagictowerTreasureModel:StopAutoDig()
    if self.dig_time_id then
        GlobalSchedule:Stop(self.dig_time_id)
        self.dig_time_id = nil
    end
end

function MagictowerTreasureModel:GetCostInfo(index)
    local cost = self.cost_cf[index]
    if not cost then
        local cf = Config.db_mchunt[index]
        cost = String2Table(cf.cost)[1]
        self.cost_cf[index] = cost
    end
    return cost[1], cost[2]
end

function MagictowerTreasureModel:GetReddotByIndex(index)
    if not self.mt_treasure_info then
        return
    end
    local cost_id, cost = self:GetCostInfo(index)
    return self.mt_treasure_info.power >= cost
end

function MagictowerTreasureModel:UpdateReddot()
    if not self.mt_treasure_info then
        return
    end
    -- local red_dot = self:GetReddotByIndex(1)
    local cost_id, cost = self:GetCostInfo(1)
    local red_dot = self.mt_treasure_info.power >= cost * 4

    if self.last_red_dot ~= red_dot then
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "mttreasure", red_dot)
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 17, red_dot)
    end
    self.last_red_dot = red_dot
end