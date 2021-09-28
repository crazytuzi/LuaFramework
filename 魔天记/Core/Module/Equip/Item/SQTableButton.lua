
-- 装备宝石容器
SQTableButton = class("SQTableButton");

function SQTableButton:New()
    local o = { };
    setmetatable(o, { __index = SQTableButton });
    return o;
end

function SQTableButton:Init(gameObject, index)

    self.gameObject = gameObject;
    self.index = index;

    self.icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self.Label = UIUtil.GetChildByName(self.gameObject, "UILabel", "Label");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

end

function SQTableButton:_OnClickBtn()

    if self.hander ~= nil then
        if self.handler_target ~= nil then
            self.hander(self.handler_target, self.index);
        else
            self.hander(self.index);
        end
    end

end

function SQTableButton:SetClickHandler(hander, handler_target)
    self.hander = hander;
    self.handler_target = handler_target;
end


function SQTableButton:SetSelected(v)

    self.selected = v;

    if self.selected then
        self.icon.spriteName = "tab2";
    else
        self.icon.spriteName = "tab1";
    end
end

function SQTableButton:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

function SQTableButton:Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
    self.hander = nil
    self.handler_target = nil
    self.gameObject = nil;
    self.data = nil;


    self.icon = nil;
    self.Label = nil;




end