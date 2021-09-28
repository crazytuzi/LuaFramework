require "Core.Module.Common.UIItem"

SubNewTrumpSkillItem = class("SubNewTrumpSkillItem", UIItem);
function SubNewTrumpSkillItem:New(trs)
    self = { };
    setmetatable(self, { __index = SubNewTrumpSkillItem });
    return self
end


function SubNewTrumpSkillItem:_Init()
    self:_InitReference();
    self:_InitListener();
end
    
function SubNewTrumpSkillItem:_InitReference()
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
    self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "level")
    self._txtDes = UIUtil.GetChildByName(self.transform, "UILabel", "des")
end

function SubNewTrumpSkillItem:_InitListener()
end

function SubNewTrumpSkillItem:_Dispose()
    self:_DisposeReference();
end

function SubNewTrumpSkillItem:_DisposeReference()
end

function SubNewTrumpSkillItem:UpdateItem(data)
    if (data) then
        self.data = data
        self._txtDes.text = self.data.skill_desc
        self._imgIcon.spriteName = self.data.icon_id
        self._txtLevel.text = tostring(self.data.skill_lv)
        self._txtName.text = self.data.name
    end
end
