require "Core.Module.Common.Panel"

SkillTipsPanel = Panel:New();


function SkillTipsPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function SkillTipsPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");

    self._dtTxtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName");
    self._dtIcoSkill = UIUtil.GetChildByName(self._trsContent, "UISprite", "icoSkill");
    self._dtIcoTalent = UIUtil.GetChildByName(self._trsContent, "UISprite", "icoTalent");
    self._dtTxtLevel = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleLevel/txtLevel");
    self._dtTxtKind = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleKind/txtKind");
    self._dtTxtCd = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleCd/txtCd");
    self._dtTxtDis = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleDis/txtDis");
    self._dtTxtDesc = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleDesc/txtDesc");
end

function SkillTipsPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

end

function SkillTipsPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function SkillTipsPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
end

function SkillTipsPanel:_DisposeReference()
    self._btnClose = nil;
end

function SkillTipsPanel:IsPopup()
    return false;
end

function SkillTipsPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(SkillNotes.CLOSE_SKILL_TIPS_PANEL);
end

function SkillTipsPanel:SetData(skill)
    self.data = skill;
    self:UpdateDisplay();
end

function SkillTipsPanel:UpdateDisplay()
    local data = self.data;
    if data then
        local cfg = ConfigManager.GetSkillById(data.id, data.skill_lv);
        
        self._dtTxtName.text = cfg.name;
        self._dtIcoSkill.spriteName = cfg.icon_id;
        self._dtTxtLevel.text = data.skill_lv .. "/" .. cfg.max_lv;
        local cId = string.sub(data.id, 3, 3);
        self._dtTxtKind.text = LanguageMgr.Get("career/"..cId);
        self._dtTxtCd.text = LanguageMgr.Get("skill/cd", {s = cfg.cd / 1000});
        self._dtTxtDis.text = LanguageMgr.Get("skill/dis", {s = cfg.distance / 100});
        self._dtTxtDesc.text = LanguageMgr.GetColor("d", cfg.skill_desc);

    end
    
end
