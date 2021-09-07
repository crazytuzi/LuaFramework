ForceImproveManager = ForceImproveManager or BaseClass(BaseManager)

function ForceImproveManager:__init()
    if ForceImproveManager.Instance ~= nil then
        return
    end
    ForceImproveManager.Instance = self
    self.model = ForceImproveModel.New()
    self:InitHandler()

    self.onUpdateForce = EventLib.New()
    self.onUpgradeForceLevel = EventLib.New()
    self.onUpdataSlowState = EventLib.New()
end

function ForceImproveManager:__delete()
end

function ForceImproveManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function ForceImproveManager:InitHandler()
    self:AddNetHandler(10018, self.on10018)
    self:AddNetHandler(10032, self.on10032)
    self:AddNetHandler(10033, self.on10033)
    self:AddNetHandler(10041, self.on10041)
end

function ForceImproveManager:RequestInitData()
    self:send10018()
    self:send10032()

    self.model.firstTimeOpenForceImproveWindow = true
end

function ForceImproveManager:send10018()
  -- print("发送10018")
    Connection.Instance:send(10018, {})
end

function ForceImproveManager:on10018(data)
    -- BaseUtils.dump(data,"on10018---------------------")
    self.model.forceData = data

    self.is_no_speed = data.fc_speed_flag or 0
    local ext_score = 0
    for i,v in ipairs(data.mine) do
        if v.type == 1 then
            -- 装备
            self.model.classList[1].myScore = v.score
        elseif v.type == 6 then
            -- 宝石
            self.model.classList[2].myScore = v.score
        elseif v.type == 7 then
            -- 翅膀
            self.model.classList[3].myScore = v.score
        elseif v.type == 5 then
            -- 冒险
            self.model.classList[4].myScore = v.score
        elseif v.type == 8 then
            -- 坐骑
            self.model.classList[5].myScore = v.score
        elseif v.type == 10 then
            -- 守护
            self.model.classList[6].myScore = v.score
        elseif v.type == 13 then
            -- 守护
            self.model.classList[7].myScore = v.score
        elseif v.type == 2 or v.type == 3 or v.type == 4 or v.type == 9 or v.type == 12 then
            ext_score = ext_score + v.score
        end
    end
    self.model.classList[8].myScore = ext_score

    ext_score = 0
    for i,v in ipairs(data.max) do
        if v.type == 1 then
            -- 装备
            self.model.classList[1].serverTop = v.score
        elseif v.type == 6 then
            -- 宝石
            self.model.classList[2].serverTop = v.score
        elseif v.type == 7 then
            -- 翅膀
            self.model.classList[3].serverTop = v.score
        elseif v.type == 5 then
            -- 冒险
            self.model.classList[4].serverTop = v.score
        elseif v.type == 8 then
            -- 坐骑
            self.model.classList[5].serverTop = v.score
        elseif v.type == 10 then
            -- 守护
            self.model.classList[6].serverTop = v.score
        elseif v.type == 13 then
            -- 宝物
            self.model.classList[7].serverTop = v.score
        elseif v.type == 2 or v.type == 3 or v.type == 4 or v.type == 9 or v.type == 12 then
            ext_score = ext_score + v.score
        end
    end
    self.model.classList[8].serverTop = ext_score

    for i,v in ipairs(data.sub_mine) do
        if self.model.subTypeList[v.type] ~= nil then
            self.model.subTypeList[v.type].myScore = v.score
        end
    end

    for i,v in ipairs(data.sub_max) do
        if v.type ~= 122 then
            if self.model.subTypeList[v.type] ~= nil then
                self.model.subTypeList[v.type].serverTop = v.score
            end
        end
    end

    self.onUpdateForce:Fire()
end

function ForceImproveManager:send10032()
    Connection.Instance:send(10032, {})
end

function ForceImproveManager:on10032(data)
    self.model.fcLevel = data.lev

    self.onUpdateForce:Fire()
end

function ForceImproveManager:send10033()
    Connection.Instance:send(10033, {})
end

function ForceImproveManager:on10033(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.result == 1 then
        self.onUpgradeForceLevel:Fire()
    end
end

function ForceImproveManager:send10041(speedFlag)
    Connection.Instance:send(10041, {speed = speedFlag})
end

function ForceImproveManager:on10041(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.onUpdataSlowState:Fire()
    end
end