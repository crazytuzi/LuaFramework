NpcshopManager = NpcshopManager or BaseClass(BaseManager)

function NpcshopManager:__init()
    if NpcshopManager.Instance ~= nil then
        return
    end

    NpcshopManager.Instance = self
    self.model = NpcshopModel.New()

    self:initHandler()
end

function NpcshopManager:initHandler()
    EventMgr.Instance:AddListener(event_name.role_asset_change, function ()
        self:RoleAssetsListener()
    end)
end

function NpcshopManager:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

-- args 1-->药物; 2-->装备
function NpcshopManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function NpcshopManager:Init()
    self.model.eqmData = nil
end

function NpcshopManager:RoleAssetsListener()
    self.model:RoleAssetsListener()
end

function NpcshopManager:send11400(wintype, base_id, num)
    if AutoQuestManager.Instance.model.isOpen then -- 防止多次购买 by 嘉俊
        if AutoQuestManager.Instance.model.lockSecondBuy == false then
            AutoQuestManager.Instance.model.lockSecondBuy = true
            Connection.Instance:send(11400, {["type"] = wintype, ["base_id"] = base_id, ["num"] = num})
        else
            -- 自动过程中已经购买了一次不能再次购买
        end
    else
        Connection.Instance:send(11400, {["type"] = wintype, ["base_id"] = base_id, ["num"] = num})
    end

    LuaTimer.Add(60, function() if self.model.npcshopWin ~= nil then self.model.npcshopWin:InitDataPanel(1) end end)
end

function NpcshopManager:IsNeed(base_id)
    if ShippingManager.Instance:IsShippingNeed(base_id) then
        return true
    else
        return false
    end
end

function NpcshopManager:GetNeedList()
    local needList = {}
    local shippingNeed = ShippingManager.Instance.shipping_need
    if shippingNeed ~= nil then
        for _,v in pairs(shippingNeed) do
            needList[v.id] = 0
        end
    end
    --BaseUtils.dump(needList, "需求列表")
    return needList
end