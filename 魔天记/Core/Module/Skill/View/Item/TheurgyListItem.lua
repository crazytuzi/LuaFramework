require "Core.Module.Common.UIItem"
require "Core.Module.Skill.View.Item.TheurgySkillItem"

TheurgyListItem = UIItem:New();

function TheurgyListItem:_Init()
    self._skillItems = { };
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "skill/imgIcon");
    self._imgLock = UIUtil.GetChildByName(self.transform, "UISprite", "skill/imgLock");

    for i = 1, 2 do
        local skItem = UIUtil.GetChildByName(self.transform, "Transform", "skill" .. i);
        self._skillItems[i] = TheurgySkillItem:New(skItem);
    end

    self:UpdateItem(self.data);
end

function TheurgyListItem:_Dispose()
    self._txtName = nil;
    self._imgIcon = nil;
    self._imgLock = nil;
    for i,v in pairs(self._skillItems) do
        self._skillItems[i] = nil;
    end
    self._skillItems = nil;
end

function TheurgyListItem:UpdateItem(data)
    if (data) then
        self.data = data;
    end
    local sData = self.data;
    if (sData and self._skillItems) then
        local v = string.split(sData.name,"·");
        self._txtName.text = v[1]
        --if (sData.currSkill) then
        if sData.enabled then
            self._imgIcon.spriteName = sData.currSkill.icon_id;
            self._imgIcon.gameObject:SetActive(true);
            self._imgLock.gameObject:SetActive(false);            
        else
            self._imgIcon.gameObject:SetActive(false);
            self._imgLock.gameObject:SetActive(true);
        end
        for i, v in ipairs(sData.skills) do
            local skillItem = self._skillItems[i];
            if (skillItem) then
                if (sData.currSkill) then
                    --skillItem:SetData(sData.idx, sData.layer, v, true, v.id == sData.currSkill.id)
                    skillItem:SetData(sData.idx, sData.layer, v, v.enabled, v.id == sData.currSkill.id)
                else
                    skillItem:SetData(sData.idx, sData.layer, v)
                end
            end
        end
    end
end
