-- @author 黄耀聪
-- @date 2017年6月12日, 星期一

QuestKingManager = QuestKingManager or BaseClass(BaseManager)

function QuestKingManager:__init()
    if QuestKingManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    QuestKingManager.Instance = self
    self.model = QuestKingModel.New()

    self.updateEvent = EventLib.New()

    self:InitHandler()
end

function QuestKingManager:__delete()
end

function QuestKingManager:InitHandler()
    self:AddNetHandler(10251, self.on10251)
    self:AddNetHandler(10252, self.on10252)
end

function QuestKingManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function QuestKingManager:OpenScrollMark(args)
    self.model:OpenScrollMark(args)
end

function QuestKingManager:OpenProgress(args)
    self.model:OpenProgress(args)
end

function QuestKingManager:RequestInitData()
    self.model.stage = 0

    self:send10251()
end

function QuestKingManager:CheckRed()
    for _,v in ipairs(self.model.currentList or {}) do
        local quest = QuestManager.Instance:GetQuest(v.quest_id)
        if quest ~= nil and quest.finish == 2 then
            NoticeManager.Instance:FloatTipsByString("任务完成了！！！")
            return true
        end
    end
    return false
end

function QuestKingManager.RewardFilter(list)
    local tab = {}
    -- local sex = RoleManager.Instance.RoleData.sex
    local classes = RoleManager.Instance.RoleData.classes
    for _,v in ipairs(list) do
        if v[4] == 0 or v[4] == classes then
            table.insert(tab, {v[1], v[3]})
        end
    end

    return tab
end

-- -----------------------------------------------------------------
-- -------------------------- 协议处理 -----------------------------
-- -----------------------------------------------------------------

-- 领取
function QuestKingManager:send10211(envelop)
    Connection.Instance:send(10211, {sec_type = QuestEumn.TaskType.king, args = envelop})
end

-- 放弃
function QuestKingManager:send10205(id)
    Connection.Instance:send(10205, {id = id})
end

-- 完成
function QuestKingManager:send10206(id)
    Connection.Instance:send(10206, {id = id})
end

-- -----------------------------------------------------------------
-- --------------------- 以上协议走任务模块监听 --------------------
-- -----------------------------------------------------------------

-- 推送皇家任务信息
function QuestKingManager:send10251()
    Connection.Instance:send(10251, {})
end

function QuestKingManager:on10251(data)
    self.model.stage = data.stage

    self.model.finishTab = {}
    for _,v in ipairs(data.finish) do
        self.model.finishTab[v.envelop] = v
    end

    self.model.currentList = data.doing
    self.model.rf_times = data.rf_times

    self.updateEvent:Fire()
end

-- 刷新皇家任务
function QuestKingManager:send10252(envelop)
    Connection.Instance:send(10252, {envelop = envelop})
end

function QuestKingManager:on10252(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
