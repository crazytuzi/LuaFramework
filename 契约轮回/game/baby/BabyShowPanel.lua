---
--- Created by  Administrator
--- DateTime: 2019/11/11 14:59
---
BabyShowPanel = BabyShowPanel or class("BabyShowPanel", WindowPanel)
local this = BabyShowPanel

function BabyShowPanel:ctor(parent_node, parent_panel)
    self.abName = "baby"
    self.assetName = "BabyShowPanel"
    self.image_ab = "baby_image";
    self.layer = "UI"
    self.panel_type = 3
    self.events = {}
    self.model = BabyModel:GetInstance()

end

function BabyShowPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if self.monster then
        self.monster:destroy()
    end
    self.monster = nil
end


function BabyShowPanel:Open(data)
    self.data = data
    WindowPanel.Open(self)
end


local bloodTab = {[1] = "A",[2] = "B",[3] = "O",[4] = "AB"}
local constellationTab =
{
    [1] = "Aquarius",
    [2] = "Pisces",
    [3] = "Aries",
    [4] = "Taurus",
    [5] = "Gemini",
    [6] = "Cancer",
    [7] = "Leo",
    [8] = "Virgo",
    [9] = "Libra",
    [10] = "Scorpio",
    [11] = "Sagittarius",
    [12] = "Capricornus",
}

function BabyShowPanel:LoadCallBack()
    self.nodes = {
        "heat","playBtn","title/babyName","left/blood/bloodName","left/xingzuo/xingzuoName",
        "left/chenghu/chenghuName","left/gender/genderName","left/player/playerName","modelCon",
        "hand","timesObj/times",
    }
    self:GetChildren(self.nodes)
    self.babyName = GetText(self.babyName)
    self.bloodName = GetText(self.bloodName)
    self.xingzuoName = GetText(self.xingzuoName)
    self.chenghuName = GetText(self.chenghuName)
    self.genderName = GetText(self.genderName)
    self.playerName = GetText(self.playerName)
    self.times = GetText(self.times)
    SetVisible(self.hand,false)
    self:InitUI()
    self:AddEvent()
    self:SetTileTextImage("baby_image", "baby_titile_tex2");
end

function BabyShowPanel:InitUI()
    local babyInfo = self.data.baby
    local id = babyInfo.id
    local order = babyInfo.order
    local cfgkey = id.."@"..order
    local cfg = Config.db_baby_order[cfgkey]
    self.cfg = cfg
    if not cfg then
        return
    end
    self.babyName.text = self.data.role_name.."baby"
    self.bloodName.text = bloodTab[babyInfo.blood_type]
    self.xingzuoName.text = constellationTab[babyInfo.constellation]
    self.chenghuName.text = cfg.name
    self.bName = cfg.name
    local gender = "Male"
    if cfg.gender == 2 then
        gender = "Saintess"
    end
    self.genderName.text = gender
    self.playerName.text = self.data.role_name
    self.times.text = string.format("Today’s Like: <color=#%s>%s</color>","aa5d25",self.data.count)
    self:InitModel(cfg.res_id)
end

function BabyShowPanel:AddEvent()
    local function call_back()
        if not self.isPlayAni  then
            if RoleInfoModel:GetInstance():GetMainRoleId() == self.data.role_id then
                BabyController:GetInstance():RequstPlay(self.cfg.gender)
                return
            end
            if RoleInfoModel:GetInstance():GetMainRoleLevel() > 180 then
                BabyController:GetInstance():RequstBabyLike(self.data.role_id)
            else
                Notify.ShowText("You can tap like when your level is above 180")
            end

        end
    end
    AddButtonEvent(self.playBtn.gameObject,call_back)
    AddButtonEvent(self.heat.gameObject,call_back)

    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyPlay,handler(self,self.BabyPlay))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyLike,handler(self,self.BabyLike))
end

function BabyShowPanel:BabyPlay()
    self:PlayBabyAni()
    Notify.ShowText(string.format("You amuse %s’s baby: %s, he/she laughs.",RoleInfoModel:GetInstance():GetMainRoleData().name,self.bName))
end

function BabyShowPanel:BabyLike(data)
    Notify.ShowText(string.format("You amuse %s’s baby: %s, he/she laughs.",self.data.role_name,self.bName))
    self.isPlayAni = true
    self:PlayBabyAni()
    if data.add_count then
        self.data.count = self.data.count + 1
        self.times.text = string.format("Today’s Like: <color=#%s>%s</color>","aa5d25",self.data.count)
    end
    --self.data.count = self.data.count + 1
    --self.times.text = string.format("今日点赞：<color#=%s>%s</color>次","aa5d25",self.data.count)
end

function BabyShowPanel:PlayBabyAni()
    SetVisible(self.hand,true)
    local action
    action = cc.ScaleTo(0.3, 1.3)
    action = cc.Sequence(action,cc.ScaleTo(0.3, 0.7))
    action = cc.Sequence(action,cc.ScaleTo(0.3, 1.3))
    action = cc.Sequence(action,cc.ScaleTo(0.3, 1))
    action = cc.Sequence(action, cc.CallFunc(handler(self,self.EndAni)))
    cc.ActionManager:GetInstance():addAction(action, self.hand)
    self.monster.UIModel:AddAnimation({"show","idle"},false,"idle",0)--,"casual"
end

function BabyShowPanel:EndAni()
    self.isPlayAni = false
    SetVisible(self.hand,false)
end


function BabyShowPanel:InitModel(resName)
    if self.monster then
        self.monster:destroy()
    end
    local cfg = {}
    cfg.pos = {x = -2000, y = -60, z = 193}
    cfg.scale = {x=200, y=200, z=200}
    cfg.trans_offset = {y=60}
    if self.data.wing_id ~= 0 then
       self.monster = UIModelCommonCamera(self.modelCon, nil, resName, self.data.wing_id)
    else
        self.monster = UIModelCommonCamera(self.modelCon, nil, resName)
    end
    self.monster:SetConfig(cfg)
end