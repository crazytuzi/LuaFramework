CGmWarSimulateView = class("CGmWarSimulateView", CViewBase)

function CGmWarSimulateView.ctor(self, cb)
	CViewBase.ctor(self, "UI/gm/GmWarSimulateView.prefab", cb)
end

function CGmWarSimulateView.OnCreateView(self)
    self.m_AttributeGrid = self:NewUI(1,CGrid)
    self.m_BtnsGrid = self:NewUI(2,CGrid)
    self.m_CloseBtn = self:NewUI(3,CButton)
	self:InitContent()
end

function CGmWarSimulateView.InitContent(self)   
    local function InitInput(obj,idx)
        local go = CInput.New(obj)
        return go
    end
    self.m_AttributeGrid:InitChild(InitInput)
    local function InitButton(obj,idx)
        local go = CButton.New(obj)
        return go
    end
    self.m_BtnsGrid:InitChild(InitButton)
    for i,v in ipairs(self.m_AttributeGrid:GetChildList()) do
        self["m_"..v:GetName()] = v
    end
    self:SetData(data.shimendata.DATA[11001])
    self:InitEvent()
end

function CGmWarSimulateView.InitEvent(self)
     self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
     self.m_ResetBtn = self.m_BtnsGrid:GetChild(1)
     self.m_ResetBtn:AddUIEvent("click", callback(self, "OnReset"))
     self.m_LookCombatBtn = self.m_BtnsGrid:GetChild(2)
     self.m_LookCombatBtn:AddUIEvent("click", callback(self, "OnLookCombat"))
     self.m_CombatBtn = self.m_BtnsGrid:GetChild(3)
     self.m_CombatBtn:AddUIEvent("click", callback(self, "OnCombat"))
end

function CGmWarSimulateView.OnReset(self)
    local monster = data.shimendata.DATA[tonumber(self.m_MonsterID:GetText())]
    if not monster then 
        g_NotifyCtrl:FloatMsg("怪物ID不存在!")
        return
    end
    self:SetData(monster)
end

function CGmWarSimulateView.SetData(self, monster)
    self.m_Blood:SetText(monster.hp)
    self.m_Attack:SetText(monster.phyAttack)
    self.m_MagAttack:SetText(monster.magAttack)
    self.m_PhyDefense:SetText(monster.phyDefense)
    self.m_MagDefense:SetText(monster.magDefense)
    self.m_Speed:SetText(monster.speed)
    self.m_Magic:SetText(monster.mp)
    self.m_CritRate:SetText(monster.critRate)
    self.m_DodgeRate:SetText(monster.dodgeRate)
    self.m_ZSkill:SetText("0")
    self.m_BSkill:SetText("0")
    self.m_MonsterCount:SetText("1")
    self.m_MonsterID:SetText(tostring(monster.id))
    self.m_MonsterLevel:SetText(tostring(1))
end

function CGmWarSimulateView.OnLookCombat(self)
     printc("观战模式")
end

function CGmWarSimulateView.OnCombat(self)
     printc("战斗模式")
     local textList = { self.m_MonsterCount:GetText(),
                        self.m_MonsterLevel:GetText(),
                        self.m_ZSkill:GetText(),
                        self.m_Attack:GetText(),
                        self.m_MagAttack:GetText(),
                        self.m_PhyDefense:GetText(),
                        self.m_MagDefense:GetText(),
                        self.m_Speed:GetText(),
                        self.m_CritRate:GetText(),
                        self.m_DodgeRate:GetText(),
                        self.m_Blood:GetText(),
                        self.m_Magic:GetText()
                        }
     --nettest.C2GSTestWar()
end

return CGmWarSimulateView