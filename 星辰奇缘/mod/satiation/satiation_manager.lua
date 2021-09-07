-- 饱食度
-- @author zgs
SatiationManager = SatiationManager or BaseClass(BaseManager)

function SatiationManager:__init()
    if SatiationManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end

    SatiationManager.Instance = self
    self:initHandle()
    self.model = SatiationModel.New()

    self.lastSatiety = -1
end

function QuestManager:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

function SatiationManager:initHandle()
    --[[self:AddNetHandler(11300, self.on11300)--]]
    self:AddNetHandler(10012, self.on10012)

    EventMgr.Instance:AddListener(event_name.backpack_item_change, function ()
        self:BackPackItemChange()
    end)

     EventMgr.Instance:AddListener(event_name.role_asset_change, function ()
        self:roleAssetChange()
    end)

     EventMgr.Instance:AddListener(event_name.end_fight, function ()
        self:checkSatiation()
    end)
    EventMgr.Instance:AddListener(event_name.self_loaded, function ()
        self:checkSatiation()
    end)
end

function SatiationManager:checkSatiation()
    if RoleManager.Instance.RoleData.satiety == 0 then
        self:DoSomethingSatietyIsZero()
        LuaTimer.Add(500, function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.satiation_window)  end)
    end
end

function SatiationManager:DoSomethingSatietyIsZero()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.None then
        if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
            if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
                SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
            end
        elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow  then
            TeamManager.Instance:Send11706()
        end
    end
end

function SatiationManager:roleAssetChange()
    -- body
    if self.lastSatiety == -1 then
        self.lastSatiety = RoleManager.Instance.RoleData.satiety
    else
        if self.lastSatiety > 0 and RoleManager.Instance.RoleData.satiety == 0 then
            if gm_cmd.auto_ancient or gm_cmd.auto or gm_cmd.auto2 then
                NoticeManager.Instance:FloatTipsByString("老司机自动加油触发，你又饱了")
                SatiationManager.Instance:send10012(200 - RoleManager.Instance.RoleData.satiety)
                return
            end
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.satiation_window)
        end
        self.lastSatiety = RoleManager.Instance.RoleData.satiety
    end
    if self.model.gaWin ~= nil then
        self.model.gaWin:UpdateCoinContent()
    end
end
--是否处于饥饿状态
function SatiationManager:IsHunger()
    -- body
    if RoleManager.Instance.RoleData.satiety >= 50 then
        return false
    else
        return true
    end
end

function SatiationManager:BackPackItemChange()
    -- body
    if self.model.gaWin ~= nil then
        self.model.gaWin:UpdateItemContent()
    end
end

function SatiationManager:on10012(data)
    BaseUtils.dump(data, "on10012")
end

function SatiationManager:send10012(count)
    Connection.Instance:send(10012, {num = count})
end

-- function FirstRecharge:send11303(id, num)
--     --print("·¢ËÍ11303")
--     Connection.Instance:send(11303,{["id"] = id, ["num"] = num})
-- end


