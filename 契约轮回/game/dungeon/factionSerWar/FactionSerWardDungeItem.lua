---
--- Created by  Administrator
--- DateTime: 2020/5/26 10:31
---
FactionSerWardDungeItem = FactionSerWardDungeItem or class("FactionSerWardDungeItem", BaseCloneItem)
local this = FactionSerWardDungeItem

function FactionSerWardDungeItem:ctor(obj, parent_node, parent_panel)
    FactionSerWardDungeItem.super.Load(self)
    self.events = {}
end

function FactionSerWardDungeItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function FactionSerWardDungeItem:LoadCallBack()
    self.nodes = {
        "name","deathObj","sliderObj/slider","repairObj","sliderObj/sliderTex",
        "sliderObj/sliderbg","goBtn","icon","goBtn/goText",
    }
    self:GetChildren(self.nodes)
    self.sliderTex = GetText(self.sliderTex)
    self.slider = GetImage(self.slider)
    self.name = GetText(self.name)
    self.icon = GetImage(self.icon)
    self.goText = GetText(self.goText)
    self:InitUI()
    self:AddEvent()
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    if role.group == 1 then
        self.goText.text = FactionSerWarModel.desTab.goText2
    else
        self.goText.text = FactionSerWarModel.desTab.goText
    end
end

function FactionSerWardDungeItem:InitUI()

end

function FactionSerWardDungeItem:AddEvent()
    local function call_back()
        local x,y = FactionSerWarModel:GetInstance():GetCreepAddress(self.data.id)
        local main_role = SceneManager:GetInstance():GetMainRole()
        local main_pos = main_role:GetPosition();
        AutoFightManager:GetInstance():StopAutoFight()
        TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
        OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, { x = x, y = y }, handler(self, self.MoveCallBack, self.data.id));
    end
    AddClickEvent(self.goBtn.gameObject,call_back)

    --if self.type == 2 then
    --    local function call_back(isShow)
    --        SetVisible(self.gameObject,isShow)
    --    end
    --    FactionSerWarModel.GetInstance():AddListener(FactionSerWarEvent.SetShowStatue,call_back)
    --end
end

function FactionSerWardDungeItem:GetRange()
    if not AutoFightManager:GetInstance().def_range then
        return nil
    end
    -- return AutoFightManager:GetInstance().def_range * 0.9
    return 500
end

function FactionSerWardDungeItem:MoveCallBack()
    AutoFightManager:GetInstance():StartAutoFight()
end

function FactionSerWardDungeItem:SetData(data)
    self.data = data
    self.slider.fillAmount = 0
    self.sliderTex.text = "0%"
    self.cfg = Config.db_creep[self.data.id]
    self.name.text = self.cfg.name
    self.hp = 0
    --if self.data.type == 1 then
    --    FactionSerWarModel.GetInstance():Brocast(FactionSerWarEvent.SetShowStatue,false);
    --end
    SetVisible(self.repairObj,false)
    SetVisible(self.deathObj,true)
    SetVisible(self.goBtn,false)
    lua_resMgr:SetImageTexture(self,self.icon,"dungeon_image","FactionSerWar_static"..self.data.type, true)
end

function FactionSerWardDungeItem:UpdataHpInfo(hp,maxHp)
    local  value = hp/maxHp
    self.hp = hp
    self.slider.fillAmount = value
    self.sliderTex.text =  math.floor(value * 100).."%"
    if hp <= 0 then
        SetVisible(self.deathObj,true)
        SetVisible(self.goBtn,false)
        --if self.data.type == 1 then
        --    FactionSerWarModel.GetInstance():Brocast(FactionSerWarEvent.SetShowStatue,true);
        --end

    else
        SetVisible(self.deathObj,false)
        SetVisible(self.goBtn,true)
        --if self.data.type == 1 then
        --    FactionSerWarModel.GetInstance():Brocast(FactionSerWarEvent.SetShowStatue,false);
        --end
    end
end