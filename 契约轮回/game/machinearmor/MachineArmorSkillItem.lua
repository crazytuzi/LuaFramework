---
--- Created by  Administrator
--- DateTime: 2019/12/26 15:16
---
MachineArmorSkillItem = MachineArmorSkillItem or class("MachineArmorSkillItem", BaseCloneItem)
local this = MachineArmorSkillItem

function MachineArmorSkillItem:ctor(obj, parent_node, parent_panel)
    MachineArmorSkillItem.super.Load(self)
    self.events = {}
    self.model = MachineArmorModel:GetInstance()
end

function MachineArmorSkillItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function MachineArmorSkillItem:LoadCallBack()
    self.nodes = {
        "icon","des"
    }
    self:GetChildren(self.nodes)
    self.icon = GetImage(self.icon)
    self.des = GetText(self.des)
    SetVisible(self.des,false)
    self:InitUI()
    self:AddEvent()
end

function MachineArmorSkillItem:InitUI()

end

function MachineArmorSkillItem:AddEvent()

    local function call_back()  --技能
        local tipsPanel = lua_panelMgr:GetPanelOrCreate(TipsSkillPanel)
        tipsPanel:Open()
        tipsPanel:SetId(self.skillId, self.icon.transform)
    end
    AddButtonEvent(self.icon.gameObject,call_back)
end
--1 主动  2被动
function MachineArmorSkillItem:SetData(data,mType,mechaId)
    self.data = data
    self.type = mType
    self.mechaId = mechaId
    local curSerInfo = self.model:GetMecha(self.mechaId)
    local curStar = 0
    if self.type == 2 then
        if type(self.data[1]) == "table" then
            self.skillId  = self.data[1][1]
            self.star  = self.data[1][2]
            local curSerInfo = self.model:GetMecha(self.mechaId)
            local cfg = Config.db_mecha_star[tostring(self.mechaId).."@".."0"]
            if curSerInfo then
                curStar = curSerInfo.star
            end
            if self.star  ~= 0 and curStar < self.star  then
                local showCfg = Config.db_mecha_star[tostring(self.mechaId).."@"..self.star]
                local str = string.format("Activate: T%sS%s",showCfg.star_client,showCfg.plot_client)
                self.des.text = str
                ShaderManager.GetInstance():SetImageGray(self.icon)
                SetVisible(self.des,true)
            else
                for i = 1, #self.data do
                    local item = self.data[i]
                    local tSkill = item[1]
                    local tStar = item[2]
                    if curStar >= tStar then
                        self.skillId = tSkill
                    end
                end
                ShaderManager.GetInstance():SetImageNormal(self.icon)
                SetVisible(self.des,false)
            end
        else

            self.skillId  = self.data[1]
            self.star = self.data[2]
        end
    else
        self.skillId  = self.data[1]
        self.star = self.data[2]
    end

    local cfg  = Config.db_skill[self.skillId]
    lua_resMgr:SetImageTexture(self, self.icon, "iconasset/icon_skill", cfg.icon,true)

    self:SetActInfo()
end

function MachineArmorSkillItem:SetActInfo()
    if self.type == 2 then


        --self.star
        --local curSerInfo = self.model:GetMecha(self.mechaId)
        --local cfg = Config.db_mecha_star[tostring(self.mechaId).."@".."0"]
        --local showCfg = Config.db_mecha_star[tostring(self.mechaId).."@".. self.star]
        --if not curSerInfo then
        --
        --    local str = string.format("%s阶%s星激活",showCfg.star_client,showCfg.plot_client)
        --    if self.star == 0 then
        --        str = "获得后激活"
        --    end
        --    self.des.text = str
        --    SetVisible(self.des,true)
        --    ShaderManager.GetInstance():SetImageGray(self.icon)
        --else
        --    local key = tostring(self.mechaId).."@"..curSerInfo.star
        --    cfg  = Config.db_mecha_star[key]
        --    if cfg.star_client < 0 then --未激活
        --        local str = string.format("%s阶%s星激活",showCfg.star_client,showCfg.plot_client)
        --        if self.star == 0 then
        --            str = "获得后激活"
        --        end
        --        self.des.text = str
        --        SetVisible(self.des,true)
        --        ShaderManager.GetInstance():SetImageGray(self.icon)
        --    else --已经激活了
        --        --curSerInfo.star
        --        if curSerInfo.star >= self.star then
        --            SetVisible(self.des,false)
        --            ShaderManager.GetInstance():SetImageNormal(self.icon)
        --        else
        --            local str = string.format("%s阶%s星激活",showCfg.star_client,showCfg.plot_client)
        --            self.des.text = str
        --            SetVisible(self.des,true)
        --            ShaderManager.GetInstance():SetImageGray(self.icon)
        --        end
        --
        --    end
        --end
    end
end