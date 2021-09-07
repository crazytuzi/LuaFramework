RewardBackManager = RewardBackManager or BaseClass(BaseManager)

function RewardBackManager:__init()
    if RewardBackManager.Instance ~= nil then
        Log.Error("不能重复实例化")
        return
    end
    RewardBackManager.Instance = self
    self.model = RewardBackModel.New()

    self.rewardBackEvent = EventLib.New()

    self.mainuiRed = false
    self.isFirst = true

    self:InitHandler()
end

function RewardBackManager:__delete()
end

function RewardBackManager:OpenWindow(args)
    self.mainuiRed = false
    MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(37, self.mainuiRed)

    self.model:OpenWindow(args)
end

function RewardBackManager:InitHandler()
    self:AddNetHandler(18400, self.on18400)
    self:AddNetHandler(18401, self.on18401)
    self:AddNetHandler(18402, self.on18402)
end

function RewardBackManager:RequestInitData()
    self.isFirst = true
    self:send18400()
end

-- 请求状态
function RewardBackManager:send18400()
    print("<color='#fff000'>send18400</color>")
    Connection.Instance:send(18400, {})
end

function RewardBackManager:on18400(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>on18400</color>")
    self.model.rewardData = self.model.rewardData or {list = {}}

    local rewardData = self.model.rewardData or {}
    local tab = {}

    rewardData.last_lev = data.last_lev

    for _,v in pairs(rewardData.list) do
        tab[v.active_id] = 1
        rewardData.list[v.active_id].finish = 0
        rewardData.list[v.active_id].all = 0
        rewardData.list[v.active_id].back = 0
        rewardData.list[v.active_id].reward = nil
    end

    for i,v in ipairs(data.list) do
        if DataRewardBack.data_active_data[v.active_id] ~= nil then
            tab[v.active_id] = 0
            rewardData.list[v.active_id] = rewardData.list[v.active_id] or {active_id = v.active_id}
            rewardData.list[v.active_id].finish = (rewardData.list[v.active_id].finish or 0) + v.finish
            rewardData.list[v.active_id].all = (rewardData.list[v.active_id].all or 0) + v.all
            rewardData.list[v.active_id].back = (rewardData.list[v.active_id].back or 0) + v.back
            rewardData.list[v.active_id].reward = v.reward
        end
    end

    for _,v in ipairs(tab) do
        if v == 1 then
            rewardData.list[v] = nil
        end
    end

    if self:IsShowMainUI() then
        DataSystem.data_icon[37].lev = 0
        self.mainuiRed = self.isFirst
        self.isFirst = false
    else
        DataSystem.data_icon[37].lev = 300
        self.isFirst = true
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.reward_back_window)
    end

    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:showbaseicon2()
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(37, self.mainuiRed)
    end
    self.rewardBackEvent:Fire()
end

function RewardBackManager:IsShowMainUI()
    local bool = false
    for _,v in pairs(((self.model.rewardData or {}).list or {})) do
        if v ~= nil then
            if v.all - v.back - v.finish > 0 and #(v.reward or {}) > 0 then
                local exp = 0
                for _,reward in pairs(v.reward or {}) do
                    if reward.type == KvData.assets.exp then
                        exp = exp + reward.value
                    end
                end
                bool = (exp > 0)
                if bool then
                    break
                end
            end
        end
    end
    return bool
end

-- 找回奖励
function RewardBackManager:send18401(active_id, times, type)
    local dat = {acitve_id = active_id, times = times, type = type}
    BaseUtils.dump(dat)
    Connection.Instance:send(18401, dat)
end

function RewardBackManager:on18401(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 一键找回
function RewardBackManager:send18402(type)
    Connection.Instance:send(18402, {type = type})
end

function RewardBackManager:on18402(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
