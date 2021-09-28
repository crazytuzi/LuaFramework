require "Core.Module.Common.Panel"
require "Core.Module.MainUI.View.Item.MyRoleProperyPanel"
require "Core.Module.MainUI.View.Item.MyAchievementPanel"
require "Core.Module.MainUI.View.Item.MyTitlePanel"
local ArtifactPanel = require "Core.Module.MainUI.View.Item.ArtifactPanel"



MyRolePanel = class("MyRolePanel", Panel)
 
function MyRolePanel:New()
    self = { };
    setmetatable(self, { __index = MyRolePanel });
    return self;
end 

function MyRolePanel:IsPopup()
    return false
end 

function MyRolePanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self._rightPanelSet = { self._trsRole.gameObject, self._trsAchievement.gameObject, self._trsTitle.gameObject }
    self._rightPanels = { }
    self._rightPanels[1] = MyRoleProperyPanel:New()
    self._rightPanels[1]:Init(self._trsRole)
    self._rightPanels[2] = MyAchievementPanel:New()
    self._rightPanels[2]:Init(self._trsAchievement)
    self._rightPanels[3] = MyTitlePanel:New()
    self._rightPanels[3]:Init(self._trsTitle)
    self._rightPanels[4] = ArtifactPanel:New()
    --    self._rightPanenIndex = 1
    --    self:ChangeRightPanel(self._rightPanenIndex)
    --    self:UpdateLefePanel()
    self:UpdateTips()
end

function MyRolePanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    --    self._txtVip = UIUtil.GetChildInComponents(txts, "txtVip");
    --    self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
    --    self._txtLv = UIUtil.GetChildInComponents(txts, "txtLv");
    --    self._txtBanghui = UIUtil.GetChildInComponents(txts, "txtBanghui");
    --    self._txtChenghao = UIUtil.GetChildInComponents(txts, "txtChenghao");

    local imgs = UIUtil.GetComponentsInChildren(self._trsContent, "UISprite");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._btnRole = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnRole");
    self._btnTitle = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnTitle");
    self._btnArtifact = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnArtifact");
    self._btn_uknow = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_uknow");

    self._btnAchievement = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnAchievement");
    self._toggles = { }
    self._toggles[1] = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btnRole")
    self._toggles[2] = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btnAchievement")
    self._toggles[3] = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btnTitle")
    self._toggles[4] = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btnArtifact")


    local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
    self._trsRole = UIUtil.GetChildInComponents(trss, "trsRole");
    self._helpPanel = UIUtil.GetChildInComponents(trss, "helpPanel");

    self._trsTitle = UIUtil.GetChildInComponents(trss, "trsTitle");
    self._trsAchievement = UIUtil.GetChildInComponents(trss, "trsAchievement");
    self._goTip = UIUtil.GetChildByName(self._trsContent, "btnAchievement/tip").gameObject
    self._artifactTip = UIUtil.GetChildByName(self._trsContent, "UISprite", "btnArtifact/imgTip")

    self._helpPanelMark = UIUtil.GetChildByName(self._helpPanel, "UISprite", "mask")


    self._helpPanel_Label = UIUtil.GetChildByName(self._helpPanel, "UILabel", "Label");
    self._helpPanel_Label.text = LanguageMgr.Get("MyRolePanel/helpPanel/label1");

    --self._btnArtifact.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.Artifact))
    self._btnArtifact.gameObject:SetActive(false)

    self._bg = UIUtil.GetChildByName(self._trsContent, "UITexture", "bg")
    self._bg2 = UIUtil.GetChildByName(self._trsContent, "UITexture", "bg2")
end

function MyRolePanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtnRole = function(go) self:_OnClickBtnRole(self) end
    UIUtil.GetComponent(self._btnRole, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRole);
    self._onClickBtnTitle = function(go) self:_OnClickBtnTitle(self) end
    UIUtil.GetComponent(self._btnTitle, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTitle);
    self._onClickBtnAchievement = function(go) self:_OnClickBtnAchievement(self) end
    UIUtil.GetComponent(self._btnAchievement, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAchievement);
    self._onClickBtnArtifact = function(go) self:ToFormation(self) end
    UIUtil.GetComponent(self._btnArtifact, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnArtifact);

    self._onClickBtn_uknow = function(go) self:_OnClickBtn_uknow(self) end
    UIUtil.GetComponent(self._btn_uknow, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_uknow);

    self._onClickHelpPanelMark = function(go) self:_OnClickHelpPanelMark(self) end
    UIUtil.GetComponent(self._helpPanelMark, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickHelpPanelMark);


    self._helpPanel.gameObject:SetActive(false);
    --MessageManager.AddListener(MainUINotes, MainUINotes.ARTIFACT_CHANGE,MyRolePanel.UpdateTips, self)
end



function MyRolePanel:_OnClickBtn_close()
    ModuleManager.SendNotification(MainUINotes.CLOSE_MYROLEPANEL)
end

function MyRolePanel:_OnClickBtnRole()
    self:ChangeRightPanel(1)
end

function MyRolePanel:_OnClickBtnTitle()
    LogHttp.SendOperaLog("称号")
    self:ChangeRightPanel(3)
end

function MyRolePanel:_OnClickBtnAchievement()
    LogHttp.SendOperaLog("成就")
    self:ChangeRightPanel(2)
end

function MyRolePanel:ToFormation()
    self:ChangeRightPanel(4)
end

function MyRolePanel:_OnClickBtn_uknow()
    self._helpPanel.gameObject:SetActive(true);
end

function MyRolePanel:_OnClickHelpPanelMark()
    self._helpPanel.gameObject:SetActive(false);
end

function MyRolePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

end

function MyRolePanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btnRole, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnRole = nil;
    UIUtil.GetComponent(self._btnTitle, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTitle = nil;
    UIUtil.GetComponent(self._btnAchievement, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAchievement = nil;
    UIUtil.GetComponent(self._btnArtifact, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnArtifact = nil;


    UIUtil.GetComponent(self._btn_uknow, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_uknow = nil;


    UIUtil.GetComponent(self._helpPanelMark, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickHelpPanelMark = nil;

    --MessageManager.RemoveListener(MainUINotes, MainUINotes.ARTIFACT_CHANGE,MyRolePanel.UpdateTips)
end

function MyRolePanel:_DisposeReference()
    self._btn_close = nil;
    self._btnRole = nil;
    self._btnTitle = nil;
    self._btnAchievement = nil;
    for k, v in ipairs(self._rightPanels) do
        v:Dispose()
    end
    self._rightPanels = nil
end

function MyRolePanel:ChangeRightPanel(to, data)
    for i = 1, table.getCount(self._rightPanels) do
        if i == to then
            --            if (not self._rightPanelSet[i].activeSelf) then
            self._rightPanels[i]:SetEnable(true, self)
            --            end
        else
            self._rightPanels[i]:SetEnable(false)
        end
    end
    self._rightPanenIndex = to
    self:UpdateRightPanel(self._rightPanenIndex, data)

    self._bg.enabled = to ~= 4
    self._bg2.enabled = to == 4
end

-- 整个面板更新
function MyRolePanel:UpdateRolePanel()
    self:UpdateRightPanel(self._rightPanenIndex)
end

-- tips更新
function MyRolePanel:UpdateTips()
    --self._artifactTip.enabled = FormationManager.HasTips()
end

function MyRolePanel:UpdateRightPanel(panelIndex, data)
    self._toggles[panelIndex].value = true
    self._goTip:SetActive(AchievementManager.GetIsAchievementFinish())
    if (self._rightPanels[panelIndex]) then
        self._rightPanels[panelIndex]:UpdatePanel(data);
    end

    if panelIndex == 1 then
        self._btn_uknow.gameObject:SetActive(true);
    else
        self._btn_uknow.gameObject:SetActive(false);
    end

    SequenceManager.TriggerEvent(SequenceEventType.Guide.ROLE_TAB, panelIndex);
    
end  

function MyRolePanel:UpdateAchievementSelect(index)
    self._rightPanels[2]:UpdateAchievementSelect(index)
    self._rightPanels[2]:ResetPosition()
end

function MyRolePanel:UpdateTitleSelect(index)
    self._rightPanels[3]:UpdateTitleSelect(index)
    self._rightPanels[3]:ResetPosition()
end
 