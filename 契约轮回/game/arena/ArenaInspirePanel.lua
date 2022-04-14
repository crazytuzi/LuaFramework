---
--- Created by  Administrator
--- DateTime: 2019/5/10 17:28
---
ArenaInspirePanel = ArenaInspirePanel or class("ArenaInspirePanel", WindowPanel)
local this = ArenaInspirePanel

function ArenaInspirePanel:ctor(parent_node, parent_panel)
    self.abName = "arena";
    self.image_ab = "arena_image";
    self.assetName = "ArenaInspirePanel"
    self.layer = "UI"
    self.events = {}
    self.use_background = true
    self.click_bg_close = true
    self.panel_type = 4
    self.model = ArenaModel:GetInstance()
end
function ArenaInspirePanel:Open(times)
    self.sti_times = times
    ArenaInspirePanel.super.Open(self)
end

function ArenaInspirePanel:dctor()
    self.model:RemoveTabListener(self.events)
end

function ArenaInspirePanel:LoadCallBack()
    self.nodes = {
        "qxBtn","okBtn","des","times",
    }
    self:GetChildren(self.nodes)
    self:SetTileTextImage("arena_image", "arena_title5")
    self.times = GetText(self.times)
    self.des = GetText(self.des)
    self:InitUI()
    self:AddEvent()
end

function ArenaInspirePanel:InitUI()
    local cfg = Config.db_arena_stimulate
    self.maxTimes = #cfg
    self:SetTimes(self.model.sti_times)
    self:SetDes()
end

function ArenaInspirePanel:AddEvent()

    local function call_back()
        if  self.sti_times >= self.maxTimes  then
            Notify.ShowText("Attempts are used up")
            return
        end
        ArenaController:GetInstance():RequstStinulate()
    end
    AddClickEvent(self.okBtn.gameObject,call_back)
    
    local function call_back()
        self:Close()
    end
    AddClickEvent(self.qxBtn.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaStinulate, handler(self, self.ArenaStinulate))
end

function ArenaInspirePanel :ArenaStinulate(data)
    self:SetTimes(self.model.sti_times)
    self:SetDes()
end

function ArenaInspirePanel:SetTimes(times)
    self.sti_times = times
    self.times.text = string.format("Inspired: %s/%s",self.sti_times,self.maxTimes )
end

function ArenaInspirePanel:SetDes()
    local cfg = Config.db_arena_stimulate
    local itemCfg = cfg[self.sti_times + 1]
    local color = "42A6C6"
    if not itemCfg then
        self.des.text = string.format("Inspiration reached Max Level, +<color=#%s>50%s</color> CP",color,"%")
    else
        local costStr = String2Table(itemCfg.cost)
        local id = costStr[1]
        local number = costStr[2]
        local moneyName = enumName.ITEM[id]
        self.des.text = string.format("Cost <color=#42A6C6>%s</color> %s to increase CP by <color=#42A6C6>%s%s</color>",number,moneyName,itemCfg.stimulate/100,"%")
    end
end

