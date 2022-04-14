---
--- Created by  Administrator
--- DateTime: 2020/3/31 17:28
---
ThroneStarPanel = ThroneStarPanel or class("ThroneStarPanel", BaseItem)
local this = ThroneStarPanel

function ThroneStarPanel:ctor(parent_node, layer)
    self.abName = "dungeon"
    self.assetName = "ThroneStarPanel"
    self.layer = layer
    self.events = {}
    self.mEvents = {}
    self.model = ThroneStarModel:GetInstance()
    self.btnSelects = {}
    self.btnSelectsTex ={}
    self.items = {}
    ThroneStarPanel.super.Load(self)
end

function ThroneStarPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.mEvents)
    self.btnSelects = {}
    self.btnSelectsTex ={}
    if not table.isempty(self.items) then
        for i, v in pairs(self.items) do
            v:destroy()
        end
    end
end

function ThroneStarPanel:LoadCallBack()
    self.nodes = {
        "items/item1/select1","items/item2/people2","items/item3/people3","items/item3/select3","items/item3/bg3",
        "items/item2/bg2","items/item2/select2","items/item1/bg1","items/item1/people1",
        "right/desObj/levelTex","right/desObj/actFromTex","right/bossListIcon","enterBtn"
        ,"right/desObj/timeTex","right/iconParent","right/desObj/ScrollView/Viewport/Content/des",

    }
    self:GetChildren(self.nodes)
    self.people1 = GetText(self.people1)
    self.people2 = GetText(self.people2)
    self.people3 = GetText(self.people3)
    self.timeTex = GetText(self.timeTex)
    self.timeTex.text = "Every Tue,Thu,Sat 21:30"
    self.bg1 = GetImage(self.bg1)
    self.bg2 = GetImage(self.bg2)
    self.bg3 = GetImage(self.bg3)

    self.des = GetText(self.des)

    self.enterBtnImg = GetImage(self.enterBtn)

    self.levelTex = GetText(self.levelTex)

    self.btnSelects[1] = self.select1
    self.btnSelects[2] = self.select2
    self.btnSelects[3] = self.select3


    self.des.text = HelpConfig.throne.des
    self:InitUI()
    self:AddEvent()
    if ActivityModel:GetInstance():GetActivity(self.model.actId) then
        ThroneStarController:GetInstance():RequestPanelInfo()
    else
        self:SetNotOpenInfo()
    end
    self:CreateIcon({246201,44004})
end

function ThroneStarPanel:InitUI()
   -- TimeManager:GetWeekDay(tonumber(tbl[i]))
    --self.model.actId
    local actCfg = Config.db_activity[self.model.actId]
    if actCfg then

        local daysTab = actCfg.days
        self.levelTex.text = "Lv."..actCfg.level
    end


end


function ThroneStarPanel:AddEvent()
    self.mEvents[#self.mEvents + 1] =  self.model:AddListener(ThroneStarEvent.ThronePanelInfo,handler(self,self.ThronePanelInfo))


    local function call_back() --怪物列表
        lua_panelMgr:GetPanelOrCreate(ThroneStarShowPanel):Open()
    end
    AddButtonEvent(self.bossListIcon.gameObject,call_back)

    local function call_back()
        if not ActivityModel:GetInstance():GetActivity(self.model.actId)  then
            Notify.ShowText("Event Not available")
            return
        end
        SceneControler.GetInstance():RequestSceneChange(self.curSceneId, enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, self.model.actId)
    end
    AddButtonEvent(self.enterBtn.gameObject,call_back)

    
    local function call_back()
        if not  ActivityModel:GetInstance():GetActivity(self.model.actId) then
            Notify.ShowText("Event Not available")
            return
        end
        self:Click(1)
    end
    AddClickEvent(self.bg1.gameObject,call_back)
    local function call_back()
        if not  ActivityModel:GetInstance():GetActivity(self.model.actId) then
            Notify.ShowText("Event Not available")
            return
        end
        self:Click(2)
    end
    AddClickEvent(self.bg2.gameObject,call_back)
    local function call_back()
        if not  ActivityModel:GetInstance():GetActivity(self.model.actId) then
            Notify.ShowText("Event Not available")
            return
        end
        if not self.ioUnLock then
            Notify.ShowText("The map is locked")
            return
        end
        self:Click(3)
    end
    AddClickEvent(self.bg3.gameObject,call_back)

end

function ThroneStarPanel:SetData(data)
    --self.selectedBossid = data
    --ActivityModel:GetInstance():GetActivity(self.model.actId)
end

function ThroneStarPanel:Click(index)
    --if not self.ioUnLock then
    --    return
    --end
    if not  ActivityModel:GetInstance():GetActivity(self.model.actId) then
        Notify.ShowText("Event Not available")
        return
    end
    for i = 1, 3 do
        if index == i then
            self.curSceneId = self.model.sceneIds[index]
            SetVisible(self.btnSelects[i],true)
        else
            SetVisible(self.btnSelects[i],false)
        end
    end
end

function ThroneStarPanel:SetNotOpenInfo()
    self.people1.text = string.format("<color=#E6E296>Number：</color><color=#40FA51>%s</color>",0)
    self.people2.text = string.format("<color=#E6E296>Number：</color><color=#40FA51>%s</color>",0)
    self.people3.text = string.format("<color=#E6E296>Number：</color><color=#40FA51>%s</color>",0)
    ShaderManager.GetInstance():SetImageGray(self.bg1)
    ShaderManager.GetInstance():SetImageGray(self.bg2)
    ShaderManager.GetInstance():SetImageGray(self.bg3)
    ShaderManager.GetInstance():SetImageGray(self.enterBtnImg)

end

function ThroneStarPanel:ThronePanelInfo(data)
    ShaderManager.GetInstance():SetImageNormal(self.bg1)
    self.ioUnLock = data.unlock
    if data.unlock then
        self:Click(3)
        ShaderManager.GetInstance():SetImageNormal(self.bg3)
    else
        self:Click(1)
        ShaderManager.GetInstance():SetImageGray(self.bg3)
    end
    ShaderManager.GetInstance():SetImageNormal(self.enterBtnImg)
    for i = 1, #self.model.sceneIds do
        local id = self.model.sceneIds[i]
        if data.roles[id] then
            self["people"..i].text = string.format("<color=#E6E296>Number：</color><color=#40FA51>%s</color>",data.roles[id])
        else
            self["people"..i].text = string.format("<color=#E6E296>Number：</color><color=#40FA51>%s</color>",0)
        end
    end

end

function ThroneStarPanel:CreateIcon(tab)
    for i=1, #tab do
        local item_id = tab[i]
        local param = {}
        param["item_id"] = item_id
        param["bind"] = 2
        param["size"] = {x=70, y=70}
        param["can_click"] = true
        if i == 1 then
            param["cfg"] = Config.db_pet_equip[tab[i].."@"..2]
        end
        if not self.items[i] then
            self.items[i] = GoodsIconSettorTwo(self.iconParent)
        else
            self.items[i]:SetVisible(true)
        end
        self.items[i]:SetIcon(param)
    end
end