---
--- Created by  Administrator
--- DateTime: 2019/12/19 14:56
---
MachineArmorPanel = MachineArmorPanel or class("MachineArmorPanel", WindowPanel)
local this = MachineArmorPanel

function MachineArmorPanel:ctor()
    self.abName = "machinearmor"
    self.imageAb = "machinearmor_image"
    self.assetName = "MachineArmorPanel"
    self.layer = "UI"
    self.is_show_money = {

    }
    --{ PetModel.DecomposeItemId, false } }
    self.win_type = 1 --窗体样式  1 1280*720
    self.show_sidebar = true --是否显示侧边栏
    self.sidebar_style = 2
    self.model = MachineArmorModel:GetInstance()

    self.currentIndex = -1
    self.panels = {}
    self.modelEvents = {}
    self.globalEvents = {}
    self.mecahItems = {}
    self.skilltab1 = {}
    self.skilltab2 = {}
end

function MachineArmorPanel:dctor()
    GlobalEvent:RemoveTabListener(self.globalEvents)
    self.model:RemoveTabListener(self.modelEvents)
    for _, item in pairs(self.panels) do
        item:destroy()
    end
    self.panels = {}

    if not table.isempty(self.mecahItems) then
        for _, item in pairs(self.mecahItems) do
            item:destroy()
        end
        self.mecahItems = {}
    end


    if not table.isempty(self.skilltab1) then
        for _, item in pairs(self.skilltab1) do
            item:destroy()
        end
        self.skilltab1 = {}
    end

    if not table.isempty(self.skilltab2) then
        for _, item in pairs(self.skilltab2) do
            item:destroy()
        end
        self.skilltab2 = {}
    end

    if self.monster then
        self.monster:destroy()
    end

end

function MachineArmorPanel:Open(default_tag)
    self.default_table_index = default_tag or 1
    MachineArmorPanel.super.Open(self)
end

function MachineArmorPanel:LoadCallBack()
    self.nodes = {
        "leftObj/ScrollView/Viewport/Content",
        "middle/modelCon","middle/skillObj/zhudongObj/zhuDongParet",
        "middle/nameBg/name","middle/mechaGrade","middle/skillObj/beidongObj/beiDongParet",
        "middle/goBtn","MachineArmorSkillItem","leftObj","MachineArmorHeadItem",
        "middle/state_battle",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.mechaGrade = GetImage(self.mechaGrade)
    SetVisible(self.goBtn,false)
    SetVisible(self.state_battle,false)
    self:InitUI()
    self:AddEvent()
    self:SetTileTextImage(self.imageAb, "MachineArmor_title1")
    self:SetBackgroundImage("iconasset/icon_big_bg_MachineArmor_bigBg", "MachineArmor_bigBg", false)

    SetAlignType(self.leftObj.transform, bit.bor(AlignType.Left, AlignType.Null))
    MachineArmorController:GetInstance():RequstMechaListInfo()

  --
end

function MachineArmorPanel:InitUI()

end


function MachineArmorPanel:AddEvent()

    local function call_back()--出站
        MachineArmorController:GetInstance():RequstSelectInfo(self.curData.id)
    end
    AddButtonEvent(self.goBtn.gameObject,call_back)
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener( MachineArmorEvent.HeadItemClick,handler(self,self.HeadItemClick))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(MachineArmorEvent.MechaListInfo,handler(self,self.MechaListInfo))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(MachineArmorEvent.MechaUpStarInfo,handler(self,self.MechaUpStarInfo))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(MachineArmorEvent.MechaSelectInfo,handler(self,self.MechaSelectInfo))

    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(MachineArmorEvent.CheckRedPoint,handler(self,self.CheckRedPoint))

end

function MachineArmorPanel:CheckRedPoint()
    self:SetIndexRedDotParam(1,self.model.redPoints[1])
    self:SetIndexRedDotParam(2,self.model.redPoints[2])
    self:SetIndexRedDotParam(3,self.model.redPoints[3] or self.model.redPoints[4])


   -- v.data.id
   -- self.starRedPoints = {}
   -- self.equipRedPoints = {}
   -- self.lvRedPoints = {}
   -- self.isBatterEquip = {}

    for i, v in pairs(self.mecahItems) do
        local isRed = false
        local id = v.data.id
        if not table.isempty(self.model.equipRedPoints[id]) then
            for i, v in pairs(self.model.equipRedPoints[id]) do
                if v == true then
                    isRed = true
                end
            end
        end
        v:UpdateRedPoint(isRed or self.model.starRedPoints[id]  or
                self.model.lvRedPoints[id] or self.model.isBatterEquip[id])
    end
   -- UpdateRedPoint

end

function MachineArmorPanel:SwitchCallBack(index, toggle_id, update_toggle)
    if (self.currentIndex == index) then
        return
    else
        self:SwitchView(index)
    end
end

function MachineArmorPanel:SwitchView(index)
    self.currentIndex = index
    if self.currentView then
        --self.currentView:SetVisible(false)
        self.currentView = nil
    end

    if self.panels[self.currentIndex] then
        self.currentView = self.panels[self.currentIndex]
    else
        local p
        if self.currentIndex == 1 then --升星
            p = MachineArmorUpStarPanel(self.transform)
        elseif self.currentIndex == 2 then
            p = MachineArmorUpLvPanel(self.transform)
        elseif self.currentIndex == 3 then
            p = MachineArmorEquipPanel(self.transform)
        end
        self.panels[self.currentIndex] = p
        self.currentView = p
    end
    if self.currentView then
        if self.curData then
            self.currentView:SetData(self.curData)
        end
    end
    self:PopUpChild(self.currentView)

    if self.currentIndex == 3 then
        SetVisible(self.goBtn,false)
        SetVisible(self.state_battle,false)
    else
        if self.curData then
            SetVisible(self.goBtn,self.model.usedMecha ~= self.curData.id)
            SetVisible(self.state_battle,self.model.usedMecha == self.curData.id)
        end

    end
    --if self.currentView then
    --    if (self.CurrPetData) then
    --        self.currentView:SetData(self.CurrPetData)
    --    end
    --    self:PopUpChild(self.currentView)
    --end
end

function MachineArmorPanel:InitMecahItems(mechas)
    local cfg = Config.db_mecha
    table.sort(cfg, function(a,b)
        return a.order < b.order
    end)
    local index = 1
    for i = 1, #cfg do
        if cfg[i].show == 1 then
            local item = self.mecahItems[index]
            if not item then
                item = MachineArmorHeadItem(self.MachineArmorHeadItem.gameObject,self.Content,"UI")
                self.mecahItems[index] = item
            end
            item:SetData(cfg[i])
            index = index + 1
        end
    end
   -- self.mecahItems[i]
    if self.currentIndex == 1 then
        self:HeadItemClick(self.mecahItems[1].data)
    else
        local data
        for i = 1, #self.mecahItems do
            local id = self.mecahItems[i].data.id
            local info  = self.model:IsActive(id)
            if info then
                data = self.mecahItems[i].data
                break
            end
        end
        if not data then
            self:SwitchCallBack(1)
        else
            self:HeadItemClick(data)
        end

    end

end

function MachineArmorPanel:MechaListInfo(data)
    self:InitMecahItems(data.mechas)
    self:CheckRedPoint()
    --self.goBtn
   -- SetVisible(self.goBtn,)
end

function MachineArmorPanel:MechaSelectInfo()
    if self.currentIndex ~= 3 then
        SetVisible(self.goBtn,self.model.usedMecha ~= self.curData.id)
        SetVisible(self.state_battle,self.model.usedMecha == self.curData.id)

    end

end

function MachineArmorPanel:HeadItemClick(data)
    if self.currentIndex ~= 1 then
        if not self.model:IsActive(data.id) then
            local des = "Unable to upgrade this mecha - inactive"
            if self.currentIndex == 3 then
                des = "Unable to upgrade this mecha - inactive"
            end
            Notify.ShowText(des)
            return
        end
    end
    for i, v in pairs(self.mecahItems) do
        if v.data.id == data.id then
            self.curData = data
            if self.currentView then
                self.currentView:SetData(self.curData)
            end
            self.model.curMecha = data.id
            self:SetCurInfo()
            self:InitModel(data.res,data.ratio)
            if self.currentIndex == 3 then
                SetVisible(self.goBtn,false)
                SetVisible(self.state_battle,false)
            end

            v:SetShow(true)
        else

            v:SetShow(false)
        end
    end
end
function MachineArmorPanel:MechaUpStarInfo(data)
    if data.mecha.id == self.curData.id then
        self:SetCurInfo()
    end
end

function MachineArmorPanel:SetCurInfo()
    self.curSerInfo = self.model:GetMecha(self.curData.id)
    local cfg = Config.db_mecha_star[tostring(self.curData.id).."@".."0"]
    if not self.curSerInfo then
        self.name.text = "Not owned  "..self.curData.name
        SetVisible(self.goBtn,false)
        SetVisible(self.state_battle,false)
    else
        local key = tostring(self.curData.id).."@"..self.curSerInfo.star
         cfg  = Config.db_mecha_star[key]
        if cfg.star_client < 0 then --未激活
            self.name.text = "Not owned  "..self.curData.name
            SetVisible(self.goBtn,false)
            SetVisible(self.state_battle,false)
        else --已经激活了
            if self.currentIndex ~= 3 then
                SetVisible(self.goBtn,self.model.usedMecha ~= self.curData.id)
                SetVisible(self.state_battle,self.model.usedMecha == self.curData.id)
            else
                SetVisible(self.goBtn,false)
                SetVisible(self.state_battle,false)
            end
           -- SetVisible(self.goBtn,self.model.usedMecha ~= self.curData.id)
            self.name.text = cfg.star_client.."Stage  "..self.curData.name
        end
    end
    self:UpdateSkill()
    lua_resMgr:SetImageTexture(self, self.mechaGrade, "machinearmor_image", "MachineArmor_sign_"..self.curData.color, false)
end

function MachineArmorPanel:InitModel(resName,ratio)
    if self.monster then
        self.monster:destroy()
    end
    local cfg = {}
    cfg.pos = {x = -2000, y = -458, z = 500}
    cfg.scale = {x = ratio,y = ratio,z = ratio}
    cfg.trans_x = 900
    cfg.trans_y = 900
    cfg.trans_offset = {x=-126, y=0}
    cfg.carmera_size = 6
    self.monster = UIModelCommonCamera(self.modelCon, nil, "model_machiaction_"..resName)
    self.monster:SetConfig(cfg)
end

function MachineArmorPanel:UpdateSkill()
    --主动
   local tab1 = String2Table(self.curData.active_skill)
    for i = 1, #tab1 do
        local item = self.skilltab1[i]
        if not item then
            item = MachineArmorSkillItem(self.MachineArmorSkillItem.gameObject,self.zhuDongParet,"UI")
            self.skilltab1[i] = item
        end
        item:SetData(tab1[i],1,self.curData.id)
    end

    local tab2 = String2Table(self.curData.passive_skill)
    for i = 1, #tab2 do
        local item = self.skilltab2[i]
        if not item then
            item = MachineArmorSkillItem(self.MachineArmorSkillItem.gameObject,self.beiDongParet,"UI")
            self.skilltab2[i] = item
        end
        item:SetData(tab2[i],2,self.curData.id)
    end

end

