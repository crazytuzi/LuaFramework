require "Core.Module.Common.UIItem"

AchievementItem = UIItem:New();
local allFinish = LanguageMgr.Get("Achievement/MyAchievementPanel/allFinish")
function AchievementItem:_Init()
    self._txtName = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtName")
    self._txtCount = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtCount")
    self._toggle = UIUtil.GetComponent(self.gameObject, "UIToggle")
    self:UpdateItem(self.data);
    self._onItemClick = function(go) self:_OnItemClick() end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onItemClick);
end


function AchievementItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onItemClick = nil
end 

function AchievementItem:UpdateItem(data)
    self.data = data
    if self.data then
        self._txtName.text = self.data.name
        local finishCount = 0
        local getRewardCount = 0
        local allCount = table.getCount(self.data.datas)

        for k, v in pairs(self.data.datas) do
            if (v.state == 2) then
                finishCount = finishCount + 1
            end

            if (v.state == 1) then
                getRewardCount = getRewardCount + 1
            end
        end

        if (allCount == finishCount) then
            self._txtCount.text = allFinish
        else
            if (getRewardCount == 0) then
                self._txtCount.text = ""
            else
                self._txtCount.text = "(" .. getRewardCount .. ")"
            end
        end
    end
end

function AchievementItem:_OnItemClick()
    ModuleManager.SendNotification(MainUINotes.CHANGE_ACHIEVEMENT_INDEX, self.index)
end

function AchievementItem:SetToggleEnable(enable)
    self._toggle.value = enable
end

