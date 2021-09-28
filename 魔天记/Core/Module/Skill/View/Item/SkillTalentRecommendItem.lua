require "Core.Module.Common.UIItem"

SkillTalentRecommendItem = UIItem:New();

function SkillTalentRecommendItem:_Init()
    self._btnUse = UIUtil.GetChildByName(self.transform, "UIButton", "btnUse");
    self._txtBtnTitle = UIUtil.GetChildByName(self.transform, "UILabel", "btnUse/txtBtnTitle");
    self._txtItemDesc = UIUtil.GetChildByName(self.transform, "UILabel", "txtItemDesc");
    --self._onSelect = function(go) self:_OnSelect() end
    --UIUtil.GetComponent(self._btnUse, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onSelect);
end

function SkillTalentRecommendItem:UpdateItem(data)
    self._data = data;
    self:UpdateDisplay();
end

function SkillTalentRecommendItem:UpdateDisplay()
    local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SKILL_RECOMMEND)[self._data];
    if cfg then
        self._txtBtnTitle.text = cfg.title;
        self._txtItemDesc.text = cfg.desc;
    else
        self._txtBtnTitle.text = "";
        self._txtItemDesc.text = "";
    end
end
--[[
function SkillTalentRecommendItem:_OnSelect()
    MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_TALENT_REC_SELECT, 0);
    MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_TALENT_REC_CLOSE);
end
]]
function SkillTalentRecommendItem:_Dispose()
    --UIUtil.GetComponent(self._btnUse, "LuaUIEventListener"):RemoveDelegate("OnClick");
    --self._onSelect = nil;
end

 