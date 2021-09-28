require "Core.Module.Common.UIItem"

SubMobaoSkillItem = class("SubMobaoSkillItem", UIItem);
function SubMobaoSkillItem:New(trs)
    self = { };
    setmetatable(self, { __index = SubMobaoSkillItem });
    return self
end


function SubMobaoSkillItem:_Init()
    self:_InitReference();
    self:_InitListener();
end
    
function SubMobaoSkillItem:_InitReference()
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
    self._txtDes = UIUtil.GetChildByName(self.transform, "UILabel", "des")
end

function SubMobaoSkillItem:_InitListener()
end

function SubMobaoSkillItem:_Dispose()
    self:_DisposeReference();
end

function SubMobaoSkillItem:_DisposeReference()
end

function SubMobaoSkillItem:UpdateItem(data)
    if (data) then
        self.data = data
        self._txtDes.text = NewTrumpManager.GetMobaoEffectDes(self.data)
        self._imgIcon.spriteName = self.data.effect_icon
        self._txtName.text = self.data.effect_name
    end
end
