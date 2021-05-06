local CJoinOrgView = class("CJoinOrgView", CViewBase)

function CJoinOrgView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Org/JoinOrgView.prefab", cb)
    self.m_ExtendClose = "Black"
    self.m_OpenEffect = "Scale"
end

function CJoinOrgView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_WrapContent = self:NewUI(2, CWrapContent)
    self.m_InfoBox = self:NewUI(3, CJoinOrgBox)
    self.m_CreateOrgBtn = self:NewUI(4, CButton)
    self.m_QuickJoinBtn = self:NewUI(5, CButton)
    self.m_LimitBtn = self:NewUI(6, CButton)
    self.m_SearchInput = self:NewUI(7, CInput)
    self.m_SearchBtn = self:NewUI(8, CButton)
    self.m_LimitMark = self:NewUI(9, CBox)
    self.m_ScrollView = self:NewUI(10, CScrollView)
    self.m_ApplyInfoPart = self:NewUI(11, CBox)
    self.m_XiaoRenTexture = self:NewUI(12, CSpineTexture)
    self:InitContent()
end

function CJoinOrgView.InitContent(self)
    self.m_XiaoRenTexture:SetActive(false)
    self.m_XiaoRenTexture:ShapeOrg("XiaoRen", objcall(self, function(obj) 
            obj.m_XiaoRenTexture:SetActive(true)
            obj.m_XiaoRenTexture:SetAnimation(0, "idle_1", false)
        end))
    self.m_ApplyInfo = self:CreateApplyInfoPart()
    self.m_ApplyInfo:SetActive(false)
    self.m_IDToInfoBox = {}
    self.m_InfoBox:SetActive(false)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_CreateOrgBtn:AddUIEvent("click", callback(self, "OnClickCreate"))
    self.m_QuickJoinBtn:AddUIEvent("click", callback(self, "OnClickQuickJoin"))
    self.m_LimitBtn:AddUIEvent("click", callback(self, "OnClickLimit"))
    self.m_SearchBtn:AddUIEvent("click", callback(self, "OnClickSearch"))
    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
    self:InitWrapPart()
    self:SetData()
end

function CJoinOrgView.InitWrapPart(self)
    self.m_WrapContent:SetCloneChild(self.m_InfoBox, 
        function(oChild)
            oChild:SetParentView(self)
            oChild:AddUIEvent("click", callback(self, "OnSelectInfoBox", oChild))
            return oChild
        end
    )
    
    self.m_WrapContent:SetRefreshFunc(function(oChild, oData)
        if oData then
            oChild:SetData(oData)
            oChild:SetActive(true)
        else
            oChild:SetActive(false)
        end
    end)
end

function CJoinOrgView.CreateApplyInfoPart(self)
    local oInfo = self.m_ApplyInfoPart
    oInfo.m_CloseBtn = oInfo:NewUI(1, CButton)
    oInfo.m_AimLabel = oInfo:NewUI(2, CLabel)
    oInfo.m_PowerLimitLabel = oInfo:NewUI(3, CLabel)
    oInfo.m_NeedAproveLabel = oInfo:NewUI(4, CLabel)
    oInfo.m_EnterBtn = oInfo:NewUI(5, CButton)
    oInfo.m_EnterBtn:AddUIEvent("click", callback(self, "OnClickEnter", oInfo))
    oInfo.m_CloseBtn:AddUIEvent("click", callback(self, "OnCloseInfo"))

    function oInfo.SetData(self, oData)
        oInfo.m_ID = oData.info.orgid
        oInfo:SetActive(true)
        -- oInfo.m_AimLabel:SetText(oData.info.aim)
        oInfo.m_AimLabel:SetText(g_OrgCtrl:GetOrgAim(oInfo.m_ID))
        oInfo.m_PowerLimitLabel:SetText(tostring(oData.powerlimit))
        if oData.needallow == COrgCtrl.Need_Allow then
            oInfo.m_NeedAproveLabel:SetText("是")
        else
            oInfo.m_NeedAproveLabel:SetText("否")
        end
    end
    return oInfo
end

function CJoinOrgView.OnCloseInfo(self)
    self.m_ApplyInfo:SetActive(false)
end

function CJoinOrgView.OnClickEnter(self, oInfo)
    g_OrgCtrl:ApplyJoinOrg(oInfo.m_ID)
end

function CJoinOrgView.SetData(self)
    self.m_Data = self:GetData()
    self.m_WrapContent:SetData(self.m_Data, true)
    self:ResetSelect()
    self.m_ScrollView:ResetPosition()
end

function CJoinOrgView.GetData(self)
    local oData = g_OrgCtrl:GetOrgDic()
    local onlyShowCanAdd = self.m_LimitMark:GetActive()
    local tempData = {}
    for k,v in pairs(oData) do
         if (not onlyShowCanAdd) or (onlyShowCanAdd and g_AttrCtrl.power >= v.powerlimit) then
            table.insert(tempData, v)
         end
    end
    local function sortFunc(v1, v2)
        if v1.info.spread_endtime ~= v2.info.spread_endtime then
            return v1.info.spread_endtime > v2.info.spread_endtime
        end
        if v1.info.level ~= v2.info.level then
            return v1.info.level > v2.info.level
        end
        if v1.info.memcnt ~= v2.info.memcnt then
            return v1.info.memcnt > v2.info.memcnt
        end
        return v1.info.orgid < v2.info.orgid
    end
    table.sort(tempData, sortFunc)
    return tempData
end

function CJoinOrgView.OnSelectInfoBox(self, oInfoBox)
    self:ResetSelect()
    oInfoBox:SetSelect(true)
end

function CJoinOrgView.ResetSelect(self)
    for _, oInfoBox in ipairs(self.m_WrapContent:GetChildList()) do
        oInfoBox:SetSelect(false)
    end
end

function CJoinOrgView.OnClickCreate(self)
    CCreateOrgView:ShowView()
end

function CJoinOrgView.OnClickQuickJoin(self)
    netorg.C2GSMultiApplyJoinOrg()
end

function CJoinOrgView.OnClickLimit(self)
    self.m_LimitMark:SetActive(not self.m_LimitMark:GetActive())
    self:SetData()
end

function CJoinOrgView.OnClickSearch(self)
    -- if self.m_SearchInput:GetText() == "" then
    --     g_NotifyCtrl:FloatMsg("无法搜到该公会")
    --     return
    -- end
    netorg.C2GSSearchOrg(self.m_SearchInput:GetText())
end

function CJoinOrgView.OnNotify(self, oCtrl)
    if oCtrl.m_EventID == define.Org.Event.OnGetOrgDic then
        self:SetData()
    elseif oCtrl.m_EventID == define.Org.Event.GetOrgMainInfo then
        self:OnClose()
    elseif oCtrl.m_EventID == define.Org.Event.ApplySuccess then
        self:OnCloseInfo()
        local lChild = self.m_WrapContent:GetChildList()
        for i, oChild in ipairs(lChild) do
            if oChild.m_Data.info.orgid == oCtrl.m_EventData then
                oChild:SetData(g_OrgCtrl:GetOrgDic()[oCtrl.m_EventData])
            end
        end
    elseif oCtrl.m_EventID == define.Org.Event.GetOrgAim then
        self.m_ApplyInfo:SetData(g_OrgCtrl:GetOrgDic()[oCtrl.m_EventData.orgid])
    end
end

return CJoinOrgView