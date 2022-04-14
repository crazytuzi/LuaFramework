---
--- Created by  Administrator
--- DateTime: 2019/9/26 16:21
---
StigmasDungeEndPanel = StigmasDungeEndPanel or class("StigmasDungeEndPanel", BaseRewardPanel)
local this = StigmasDungeEndPanel

function StigmasDungeEndPanel:ctor()
    self.abName = "dungeon"
    self.imageAb = "dungeon_image"
    self.assetName = "StigmasDungeEndPanel"
    self.layer = "UI"
    self.events = {}
    self.use_background = true
    self.click_bg_close = true
    self.items = {}
    self.btn_list = {
        {btn_res = "common:btn_yellow_2",btn_name = "Confirm",format = "Auto closing in %s sec", auto_time=5, call_back = handler(self,self.Okfucn)},
    }
end

function StigmasDungeEndPanel:Okfucn()
    SceneControler:GetInstance():RequestSceneLeave();
    self:Close()
end

function StigmasDungeEndPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.items) do
        v:destroy()
    end
    self.items ={}
end

function StigmasDungeEndPanel:Open(data)
    self.data = data
    StigmasDungeEndPanel.super.Open(self)
end

function StigmasDungeEndPanel:LoadCallBack()
    self.nodes = {
        "exp","stone","ScrollView/Viewport/Content",
    }
    self:GetChildren(self.nodes)
    self.stone = GetText(self.stone)
    self.exp = GetText(self.exp)
    self:InitUI()
    self:AddEvent()
end

function StigmasDungeEndPanel:InitUI()
    local index = 0
    local count = 0
    local tab = {}
    for i,v in pairs(self.data.reward) do
        table.insert(tab,i)
    end
    table.sort(tab,function(a,b)
        local cfg1 = Config.db_item[a]
        local cfg2 = Config.db_item[b]
        return cfg1.color > cfg2.color
    end)

    local resTab = {}
    for i, v in pairs(tab) do
        --table.insert(resTab,self.data.reward[v])
        --logError(v)
        --dump(self.data.reward[v])
        local id = v
        local num = self.data.reward[v]
        if id ~= enum.ITEM.ITEM_EXP then
            index = index  + 1
            if self.items[index] == nil  then
                self.items[index] = GoodsIconSettorTwo(self.Content)
            end
            local param = {}
            param["model"] = self.model
            param["item_id"] = id
            param["num"] = num
            param["can_click"] = true
            self.items[index]:SetIcon(param)

            local itemCfg = Config.db_item[id]
            if itemCfg then
                local sType = itemCfg.stype
                if sType == enum.ITEM_STYPE.ITEM_STYPE_SOUL or sType == enum.ITEM_STYPE.ITEM_STYPE_SOUL_EXP or id == 90010023  then
                    count = count + num
                end
            end
        end
    end
    --logError("--1-")
    --dump(resTab)



    --for id, num in table.pairsByKeyMax(self.data.reward) do
    --    if id ~= enum.ITEM.ITEM_EXP then
    --        index = index  + 1
    --        if self.items[index] == nil  then
    --            self.items[index] = GoodsIconSettorTwo(self.Content)
    --        end
    --        local param = {}
    --        param["model"] = self.model
    --        param["item_id"] = id
    --        param["num"] = num
    --        param["can_click"] = true
    --        self.items[index]:SetIcon(param)
    --
    --        local itemCfg = Config.db_item[id]
    --        if itemCfg then
    --            local sType = itemCfg.stype
    --            if sType == enum.ITEM_STYPE.ITEM_STYPE_SOUL or sType == enum.ITEM_STYPE.ITEM_STYPE_SOUL_EXP or id == 90010023  then
    --                count = count + num
    --            end
    --        end
    --    end
    --end
    local number = self.data.reward[enum.ITEM.ITEM_EXP] or 0
    self.exp.text = string.format("<color=#FFFCA9>%s</color>",GetShowNumber(number))
    self.stone.text = string.format("<color=#FFFCA9>%s</color>",count)

end

function StigmasDungeEndPanel:AddEvent()

end