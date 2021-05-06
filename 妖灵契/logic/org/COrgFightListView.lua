local COrgFightListView = class("COrgFightListView", CViewBase)

function COrgFightListView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Org/OrgFightListView.prefab", cb)
    self.m_ExtendClose = "Black"
    self.m_OpenEffect = "Scale"
end

function COrgFightListView.OnCreateView(self)
    -- self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_InfoGrid = self:NewUI(2, CGrid)
    self.m_InfoBox = self:NewUI(3, CBox)
    self:InitContent()
end

function COrgFightListView.InitContent(self)

    -- self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function COrgFightListView.SetData(self, oData)
    for i,v in ipairs(oData) do
        local oInfoBox = self:CreateInfoBox()
        oInfoBox:SetData(v)
        self.m_InfoGrid:AddChild(oInfoBox)
    end
    self.m_InfoBox:SetActive(false)
end

function COrgFightListView.CreateInfoBox(self)
    local oInfoBox = self.m_InfoBox:Clone()
    oInfoBox.m_OrgBox1 = oInfoBox:NewUI(1, CBox)
    oInfoBox.m_OrgBox2 = oInfoBox:NewUI(2, CBox)
    self:InitOrgBox(oInfoBox.m_OrgBox1)
    self:InitOrgBox(oInfoBox.m_OrgBox2)
    -- oInfoBox.m_BoxArr = {oInfoBox.m_OrgBox1, oInfoBox.m_OrgBox2}

    function oInfoBox.SetData(self, oData)
        oInfoBox.m_OrgBox1.m_IDLabel:SetText(oData.orgid1)
        oInfoBox.m_OrgBox2.m_IDLabel:SetText(oData.orgid2)
        oInfoBox.m_OrgBox1.m_NameLabel:SetText(oData.name1)
        oInfoBox.m_OrgBox2.m_NameLabel:SetText(oData.name2)
        oInfoBox.m_OrgBox1.m_WinMark:SetActive(oData.orgid1 == oData.winid)
        oInfoBox.m_OrgBox2.m_WinMark:SetActive(oData.orgid2 == oData.winid)
        -- for i,v in ipairs(oData) do
        --     oInfoBox.m_BoxArr[i].m_IDLabel:SetText(v.orgid)
        --     oInfoBox.m_BoxArr[i].m_NameLabel:SetText(v.name)
        -- end
    end
    return oInfoBox
end

function COrgFightListView.InitOrgBox(self, oBox)
    oBox.m_IDLabel = oBox:NewUI(1, CLabel)
    oBox.m_NameLabel = oBox:NewUI(2, CLabel)
    oBox.m_WinMark = oBox:NewUI(3, CBox)
    return oBox
end

return COrgFightListView