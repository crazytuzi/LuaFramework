SkillTalentDetailItem = class("SkillTalentDetailItem");

function SkillTalentDetailItem:Init(tr)
    self._transform = tr;
    self:_Init();
end

function SkillTalentDetailItem:_Init()
    self._txtName = UIUtil.GetChildByName(self._transform, "UILabel", "txtName");
    self._txtType = UIUtil.GetChildByName(self._transform, "UILabel", "txtType");
    self._txtDesc = UIUtil.GetChildByName(self._transform, "UILabel", "txtDesc");
    self._icon = UIUtil.GetChildByName(self._transform, "UISprite", "icon");
    self.data = 0;
    self.lv = 0;

    self._onClick = function(go) self:_OnClick() end
    UIUtil.GetComponent(self._transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);
end

function SkillTalentDetailItem:Dispose()
    UIUtil.GetComponent(self._transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;
end

function SkillTalentDetailItem:SetData(tId)
    self.data = tId;
    self:UpdateDisplay();

end

function SkillTalentDetailItem:SetLv(lv)
    self.lv = lv;
    self:UpdateDisplay();
end

function SkillTalentDetailItem:UpdateDisplay()
    local cfg = SkillManager.GetTalentCfg(self.data);
    if cfg then
        self._icon.spriteName = cfg.icon;
        self._txtName.text = cfg.name;
        self._txtType.text = "";
    else
        self._icon.spriteName = "";
        self._txtName.text = "";
        self._txtType.text = "";
    end

    self.lv = math.max(1, self.lv);
    local detailCfg = SkillManager.GetTalentDetailCfg(self.data, self.lv);
    if detailCfg then
        self._txtDesc.text = SkillManager.GetTalentDesc(detailCfg);
    else
        self._txtDesc.text = "";
    end
end

function SkillTalentDetailItem:_OnClick()
    MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_TALENT_DETAIL_CLICK, self.data);
end