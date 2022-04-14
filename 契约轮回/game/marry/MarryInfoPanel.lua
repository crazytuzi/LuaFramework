---
--- Created by  Administrator
--- DateTime: 2019/7/13 15:38
---
MarryInfoPanel = MarryInfoPanel or class("MarryInfoPanel", BaseItem)
local this = MarryInfoPanel

function MarryInfoPanel:ctor(parent_node, parent_panel)
    self.abName = "marry";
    self.assetName = "MarryInfoPanel"
    self.events = {}
    self.model = MarryModel:GetInstance()
    self.role = RoleInfoModel.GetInstance():GetMainRoleData()
    MarryInfoPanel.super.Load(self)
end

function MarryInfoPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if self.rolemodel then
        self.rolemodel:destroy()
        self.rolemodel = nil
    end

    if self.emodel then
        self.emodel:destroy()
        self.emodel = nil
    end
end

function MarryInfoPanel:LoadCallBack()
    self.nodes = {
        "marryPanel",
        "marryPanel/ringNum","marryPanel/marry_my/myName_1","marryPanel/dayNum",
        "marryPanel/divorceBtn","marryPanel/marryBtn",
        "marryPanel/marry_enemy/enemyName_1","marryPanel/intimacyNum",
        "marryPanel/enemyModel","marryPanel/myModel",
        "marryPanel/frendBtn",
        "marryPanel/marry_my/myGenderImg","marryPanel/marry_enemy/enemyGenderImg",
    }
    self:GetChildren(self.nodes)
    self.ringNum = GetText(self.ringNum)
    self.myName_1 =  GetText(self.myName_1)
    self.enemyName_1 = GetText(self.enemyName_1)
    self.intimacyNum = GetText(self.intimacyNum)
    self.dayNum = GetText(self.dayNum)
    self.myGenderImg = GetImage(self.myGenderImg)
    self.enemyGenderImg = GetImage(self.enemyGenderImg)
    self:InitUI()
    self:AddEvent()
     MarryController:GetInstance():RequsetMarriageInfo()
     MarryController:GetInstance():RequsetRingInfo()
end

function MarryInfoPanel:InitUI()

end

function MarryInfoPanel:AddEvent()
    local function call_back()  --前往结婚
        self.model:GoNpc()
        --self:Close()
        local  panel = lua_panelMgr:GetPanel(MarryPanel)
        if panel then
            panel:Close()
        end
    end
    AddClickEvent(self.marryBtn.gameObject,call_back)

    local function call_back()  --离婚
        lua_panelMgr:GetPanelOrCreate(MarryDivorcePanel):Open()
    end
    AddClickEvent(self.divorceBtn.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.MarriageInfo, handler(self, self.MarriageInfo))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.DivorceSuscc,handler(self,self.DivorceSuscc))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.RingInfo,handler(self,self.RingInfo))
end

function MarryInfoPanel:MarriageInfo(data)
    dump(data)
    if data.marry_with.id ~=0 then

        self.enemyName_1.text = data.marry_with.name
        self.intimacyNum.text = data.intimacy
        self.dayNum.text = string.format("%s days",data.day)
        self:InitEnemyModel(data)
    else
        self.enemyName_1.text = "Single"
        self.intimacyNum.text = 0
        self.dayNum.text = string.format("%s days",0)
    end
    self.myName_1.text = self.role.name
    self:InitMyModel()

end

function MarryInfoPanel:DivorceSuscc()
    
end

function MarryInfoPanel:RingInfo()

end



function MarryInfoPanel:InitMyModel()
    local genderIcon = "marry_gender1"
    if self.role.gender == 2 then
        genderIcon = "marry_gender2"
    end
    lua_resMgr:SetImageTexture(self, self.myGenderImg, "marry_image", genderIcon, false, nil, false)
    self.rolemodel = UIRoleCamera(self.myModel, nil, self.role)
end
function MarryInfoPanel:InitEnemyModel(data)
    local genderIcon = "marry_gender1"
    if data.marry_with.gender == 2 then
        genderIcon = "marry_gender2"
    end
    lua_resMgr:SetImageTexture(self, self.enemyGenderImg, "marry_image", genderIcon, false, nil, false)
    self.emodel = UIRoleCamera(self.enemyModel, nil, data.marry_with)
end

function MarryInfoPanel:RingInfo(data)
    local ring = data.ring
    self.ringNum.text = ring.grade.."Stage"..ring.level.."Level"
end