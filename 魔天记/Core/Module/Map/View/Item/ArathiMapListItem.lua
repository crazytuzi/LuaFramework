require "Core.Module.Common.UIItem"

ArathiMapListItem = class("ArathiMapListItem", UIItem);

function ArathiMapListItem:New()
    self = { };
    setmetatable(self, { __index = ArathiMapListItem });
    return self
end


function ArathiMapListItem:_Init()
    self._imgFrame = UIUtil.GetChildByName(self.transform, "UISprite", "imgFrame")
    self._imgCareer = UIUtil.GetChildByName(self.transform, "UISprite", "imgCareer")
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName")
    self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "txtLevel")
    self._txtPower = UIUtil.GetChildByName(self.transform, "UILabel", "txtPower")
    self._imgDie = UIUtil.GetChildByName(self.transform, "UISprite", "imgDie")
    self._onClickItem = function(go) self:_OnClickItem(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
    self:Refresh()
end 

function ArathiMapListItem:Refresh()
    self:UpdateItem(self.data)
end

function ArathiMapListItem:UpdateItem(data)
    if (data) then
        self.data = data
        self._imgCareer.spriteName = "c" .. data.info.kind
        self._txtName.text = self.data.info.name
        self._txtLevel.text = "lv." .. data.info.level;
        if (data.info.power) then
            self._txtPower.text = "战." .. data.info.power;
        else
            self._txtPower.text = "";
        end
        if (data:IsDie()) then
            self._imgDie.gameObject:SetActive(true);
            self._imgFrame.color = Color.New(0, 0, 0);
        else
            self._imgDie.gameObject:SetActive(false);
            self._imgFrame.color = Color.New(1, 1, 1);
        end
    end
end

function ArathiMapListItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;
    self._imgFrame = nil;
    self._imgCareer = nil;
    self._txtName = nil;
    self._txtLevel = nil;
    self._txtPower = nil;
    self._imgDie = nil;
end
 
function ArathiMapListItem:_OnClickItem()
    HeroController:GetInstance():MoveTo(self.data.transform.position)
end