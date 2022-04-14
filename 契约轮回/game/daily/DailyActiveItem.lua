-- @Author: lwj
-- @Date:   2019-01-15 15:53:56
-- @Last Modified time: 2019-01-15 15:53:59

DailyActiveItem = DailyActiveItem or class("DailyActiveItem", BaseCloneItem)
local DailyActiveItem = DailyActiveItem

function DailyActiveItem:ctor(parent_node, layer)
    DailyActiveItem.super.Load(self)
end

function DailyActiveItem:dctor()
    if self.effect then
        self.effect:destroy()
    end
    self:RemoveListener()
end

function DailyActiveItem:LoadCallBack()
    self.model = DailyModel.GetInstance()
    self.nodes = {
        "btn_go", "normal/time/times", "normal/time/liveness", "normal/time",
        "normal/floors",
        "normal",
        "bg",
        "icon",
        "flag",
        "lock",
        "lock/limit",
        "already_img",
    }
    self:GetChildren(self.nodes)
    self.liveness = GetText(self.liveness)
    self.times = GetText(self.times)
    self.floors = GetText(self.floors)
    self.icon = GetImage(self.icon)
    self.flag = GetImage(self.flag)
    self.limit = GetText(self.limit)
    self.btn_img = GetImage(self.btn_go)

    self:AddEvent()
end

function DailyActiveItem:AddEvent()
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(ActivityTips):Open(self.data.conData.id, self.bg)
    end
    AddClickEvent(self.bg.gameObject, call_back)
end

function DailyActiveItem:AddClickFun()
    local function call_back()
        if self.data.conData.link_type == 1 then
            --任务
            if self.data.conData.link then
                local link_id = tonumber(String2Table(self.data.conData.link)[1])
                if link_id == 930000 then
                    if RoleInfoModel.GetInstance():GetMainRoleData().guild == "0" then
                        Notify.ShowText("Please join the guild first")
                        return
                    end
                end
                local task_type
                if link_id == 920000 then
                    task_type = enum.TASK_TYPE.TASK_TYPE_DAILY
                elseif link_id == 930000 then
                    task_type = enum.TASK_TYPE.TASK_TYPE_GUILD
                end
                TaskModel.GetInstance():DoTaskByType(task_type)
                -- TaskModel.GetInstance():DoTask(link_id)
            end
        elseif self.data.conData.link_type == 2 then
            if self.hookData then
                SceneManager:GetInstance():AttackCreepByTypeId(self.hookData.creep)
            end
        elseif self.data.conData.link_type == 3 then
            --界面跳转
            if self.data.conData.link ~= "" then
                local pTab = String2Table(self.data.conData.link)
                OpenLink(unpack(pTab[1]))
            end
        elseif self.data.conData.link_type == 4 then
            --挂机
            if self.hookData then
                SceneManager:GetInstance():AttackCreepByTypeId(self.hookData.creep)
            end
        elseif self.data.conData.link_type == 5 then
            --npc
            if self.data.conData.link then
                SceneManager:GetInstance():FindNpc(String2Table(self.data.conData.link)[1])
            end
        end
        self.model:Brocast(DailyEvent.CloseDailyActPanel)
    end
    AddClickEvent(self.btn_go.gameObject, call_back)
end

function DailyActiveItem:GetLayerMessage()
    GlobalEvent:Brocast(DailyEvent.GetMagicTowerInfo, enum.SCENE_STYPE.SCENE_STYPE_DUNGE_MAGICTOWER)
    if not self.updatelayer_event_id then
        local function call_back(layer)
            self.data.taskInfo = self.data.taskInfo or {}
            self.data.taskInfo.progress = layer
            self:UpdateView()
        end
        self.updatelayer_event_id = GlobalEvent:AddListener(DailyEvent.UpdateMagicTowerLayer, call_back)
    end
    if not self.magictowerover_event_id then
        local function call_back(isClear)
            if isClear then
                self.data.taskInfo = self.data.taskInfo or {}
                self.data.taskInfo.progress = self.data.taskInfo.progress
                self:UpdateView()
            end
        end
        self.magictowerover_event_id = GlobalEvent:AddListener(DailyEvent.MagicTowerOver, call_back)
    end
end

function DailyActiveItem:RemoveListener()
    if self.updatelayer_event_id then
        GlobalEvent:RemoveListener(self.updatelayer_event_id)
    end
    self.updatelayer_event_id = nil
    if self.magictowerover_event_id then
        GlobalEvent:RemoveListener(self.magictowerover_event_id)
    end
    self.magictowerover_event_id = nil
end

function DailyActiveItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
    if self.data.conData.show_type == 2 then
        self:GetLayerMessage()
    else
        self:RemoveListener()
    end
end

function DailyActiveItem:UpdateView()
    lua_resMgr:SetImageTexture(self, self.icon, "iconasset/icon_daily", self.data.conData.pic, true, nil, false)
    lua_resMgr:SetImageTexture(self, self.flag, "iconasset/icon_daily", self.data.conData.tips, true, nil, false)
    if self.data.isLock then
        RemoveClickEvent(self.btn_go.gameObject)
        SetVisible(self.normal, false)
        SetVisible(self.lock, true)
        SetVisible(self.already_img, false)
        ShaderManager.GetInstance():SetImageGray(self.btn_img)
        local level = GetLevelShow(String2Table(self.data.conData.reqs)[1][2])
        self.limit.text = string.format(ConfigLanguage.Daily.DailyShowLimitTwo, tostring(level))
    else
        self:AddClickFun()
        SetVisible(self.normal, true)
        SetVisible(self.lock, false)
        ShaderManager.GetInstance():SetImageNormal(self.btn_img)
        local type = self.data.conData.show_type
        if type == 1 then
            self:ShowTime()
            local curTimes = 0
            if self.data.taskInfo then
                curTimes = self.data.conData.count - self.data.taskInfo.progress
            else
                curTimes = self.data.conData.count
            end
            if curTimes > 0 then
                self:ShowGo()
                self.times.text = ConfigLanguage.Daily.ActiveItemTimesHead .. curTimes .. "/" .. self.data.conData.count
                self.liveness.text = ConfigLanguage.Daily.ActiveItemLivenessHead .. curTimes * self.data.conData.activation .. '/' .. self.data.conData.count * self.data.conData.activation
            else
                --剩余次数不足
                self:ShowAlreadyDone()
                self.times.text = ConfigLanguage.Daily.ActiveItemTimesHead .. "<color=#FF0000>" .. 0 .. "/" .. self.data.conData.count .. "</color>"
                self.liveness.text = ConfigLanguage.Daily.ActiveItemLivenessHead .. "<color=#FF0000>" .. 0 .. '/' .. self.data.conData.count * self.data.conData.activation .. "</color>"
            end
            if self.data.conData.group ~= 0 and self.data.taskInfo then
                self.model:Brocast(DailyEvent.UpdateActRemainCount, self.data.conData.group, self.data.taskInfo)
            end
        elseif type == 2 then
            self:ShowFloors()
            local f = 0
            if self.data.taskInfo and self.data.taskInfo.progress then
                f = self.data.taskInfo.progress
            end
            self.floors.text = ConfigLanguage.Daily.CurClearFloor .. f
        elseif type == 3 then
            self:ShowFloors()
            local curLv = RoleInfoModel.GetInstance():GetMainRoleLevel()
            self.hookData = {}
            self.hookData.level = 1
            for mapId, mapInfo in pairs(Config.db_afk_map) do
                if mapInfo.level > self.hookData.level and mapInfo.level <= curLv then
                    self.hookData = mapInfo
                end
            end
            self.floors.text = string.format(ConfigLanguage.Daily.RecommandHookPoint, self.hookData.level)
        end
    end

end

function DailyActiveItem:AddEffect()
    if self.effect then
        self.effect:destroy()
    end
    self.effect = UIEffect(self.btn_go, 10121, false, self.layer)
    self.effect:SetConfig({ scale = 0.7 })
end

function DailyActiveItem:RemoveEffect()
    if self.effect then
        self.effect:destroy()
    end
end

function DailyActiveItem:ShowGo()
    SetVisible(self.btn_go, true)
    SetVisible(self.already_img, false)
end

function DailyActiveItem:ShowAlreadyDone()
    SetVisible(self.btn_go, false)
    SetVisible(self.already_img, true)
end

function DailyActiveItem:ShowTime()
    SetVisible(self.time, true)
    SetVisible(self.floors, false)
end

function DailyActiveItem:ShowFloors()
    SetVisible(self.time, false)
    SetVisible(self.floors, true)
end


