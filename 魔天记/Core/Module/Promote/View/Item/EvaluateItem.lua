require "Core.Module.Common.UIComponent"

EvaluateItem = class("EvaluateItem", UIComponent);

function EvaluateItem:New(transform)
    self = { };
    setmetatable(self, { __index = EvaluateItem });
    if (transform) then
        self:Init(transform);
    end
    return self
end

function EvaluateItem:_Init()
    self:_InitReference();
end

function EvaluateItem:_InitReference()
    self._imgEvaluate1 = UIUtil.GetChildByName(self._transform, "UISprite", "imgEvaluate1");
    self._imgEvaluate2 = UIUtil.GetChildByName(self._transform, "UISprite", "imgEvaluate2");
    self._imgEvaluate3 = UIUtil.GetChildByName(self._transform, "UISprite", "imgEvaluate3");
end

  
function EvaluateItem:_Dispose()
    self:_DisposeReference();
end

function EvaluateItem:_DisposeReference()
    self._imgEvaluate1 = nil
    self._imgEvaluate2 = nil
    self._imgEvaluate3 = nil
end

function EvaluateItem:SetEvaluate(evaluate)
    if (evaluate) then
        if (evaluate == 1) then
            self._imgEvaluate1.spriteName = "c";
            self._imgEvaluate2.spriteName = "";
            self._imgEvaluate3.spriteName = "";
            return;
        elseif (evaluate == 2) then
            self._imgEvaluate1.spriteName = "b";
            self._imgEvaluate2.spriteName = "";
            self._imgEvaluate3.spriteName = "";
            return;
        elseif (evaluate == 3) then
            self._imgEvaluate1.spriteName = "a";
            self._imgEvaluate2.spriteName = "";
            self._imgEvaluate3.spriteName = "";
            return;
        elseif (evaluate == 4) then
            self._imgEvaluate1.spriteName = "s";
            self._imgEvaluate2.spriteName = "";
            self._imgEvaluate3.spriteName = "";
            return;
        elseif (evaluate == 5) then
            self._imgEvaluate1.spriteName = "s";
            self._imgEvaluate2.spriteName = "s";
            self._imgEvaluate3.spriteName = "";
            return;
        elseif (evaluate == 6) then
            self._imgEvaluate1.spriteName = "s";
            self._imgEvaluate2.spriteName = "s";
            self._imgEvaluate3.spriteName = "s";
            return;
        end
    end
    self._imgEvaluate1.spriteName = "";
    self._imgEvaluate2.spriteName = "";
    self._imgEvaluate3.spriteName = "";
end