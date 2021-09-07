IngotCrashReward = IngotCrashReward or BaseClass(BaseWindow)

function IngotCrashReward:__init(model)
    self.model = model
    self.name = "IngotCrashReward"
    self.windowId = WindowConfig.WinID.ingot_crash_reward

    self.resList = {
        {file = AssetConfig.ingotcrash_reward, type = AssetType.Main}
    }

    self.itemList = {}

    -- if self.model.battleRewardList == nil then
    --     self.model.battleRewardList = {}
    --     local tab = {}
    --     for _,v in pairs(DataGoldLeague.data_battle_reward) do
    --         if v.result == 1 then
    --             local reward = {}
    --             reward.type = v.type
    --             reward.rewardList = {{v.base_id, v.num}}
    --             reward.totalList = {}
    --             table.insert(self.model.battleRewardList, reward)
    --         end
    --     end
    --     table.sort(self.model.battleRewardList, function(a,b) return a.type > b.type end)
    --     for _,v in ipairs(self.model.battleRewardList) do
    --         for i,vv in ipairs(v.rewardList) do
    --             tab[vv[1]] = (tab[vv[1]] or 0) + vv[2]
    --         end
    --         for base_id,num in pairs(tab) do
    --             if num ~= nil and num > 0 then
    --                 table.insert(v.totalList, {base_id, num})
    --             end
    --         end
    --     end
    --     table.sort(self.model.battleRewardList, function(a,b) return a.type < b.type end)

    --     -- BaseUtils.dump(self.model.battleRewardList, "self.model.battleRewardList")
    -- end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function IngotCrashReward:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in ipairs(self.itemList) do
            v:DeleteMe()
        end
        self.itemList = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    self:AssetClearAll()
end

function IngotCrashReward:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ingotcrash_reward))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    local main = t:Find("Main")
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.layout = LuaBoxLayout.New(main:Find("Scroll/Container"), {axis = BoxLayoutAxis.Y, border = 0, cspacingt = 0})
    self.cloner = main:Find("Scroll/Cloner").gameObject

    self.cloner:SetActive(false)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
end

function IngotCrashReward:OnOpen()
    self:Reload()
end

function IngotCrashReward:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function IngotCrashReward:OnHide()
end

function IngotCrashReward:Reload()
    self.layout:ReSet()
    for i,v in ipairs(DataGoldLeague.data_stat_reward) do
        local item = self.itemList[i] or IngotCrashRewardItem.New(self.model, GameObject.Instantiate(self.cloner))
        item:SetData(v, i)
        self.layout:AddCell(item.gameObject)
    end
    for i=#DataGoldLeague.data_stat_reward+1,#self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end
end
