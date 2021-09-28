
require "Core.Manager.Item.SystemUnlockManager";

SysOpenTipPanel = class("SysOpenTipPanel");


function SysOpenTipPanel:New()
    self = { };
    setmetatable(self, { __index = SysOpenTipPanel });
    return self
end

function SysOpenTipPanel:SetActive(active)
    if (self.gameObject) then
        self.gameObject.gameObject:SetActive(active);
    end
end

function SysOpenTipPanel:Init(gameObject)
    self.gameObject = gameObject;

    self.tipTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "tipTxt");
    self.icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
     self.bg = UIUtil.GetChildByName(self.gameObject, "UISprite", "bg");

    self._uiEffect = UIEffect:New()

    self._uiEffect:Init(self.gameObject.transform, self.icon, 0, "ui_activity_opening");
    self._uiEffect:Play();
    self._uiEffect:SetLayer(self.icon.gameObject.layer)
    self._uiEffect:Stop();

     self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);


    

    self:SetActive(false);
end

function SysOpenTipPanel:_OnClickBtn()
  
   -- 开始前需求
   ModuleManager.SendNotification(MainUINotes.OPEN_SYSOPENTIPPANEL,self.data );
end

function SysOpenTipPanel:CheckLev()

    if self.isInField then

        local obj = SystemUnlockManager.TryGetNeedTipInfo();
        self.data = obj;
        if obj ~= nil then
            -- 需要提示
            local foreshowLabel = obj.foreshowLabel;

            self.tipTxt.text = foreshowLabel;
            self.icon.spriteName = obj.icon;
            self.icon:MakePixelPerfect();
            self:SetActive(true);

            self._uiEffect:Stop();

            if obj.canShowEff then
                self._uiEffect:Play();
                self._uiEffect:SetPos(162, -31)
            end

        else
            self:SetActive(false);

        end

    else
        self:SetActive(false);
    end

end

function SysOpenTipPanel:SceneChange(isInField)

    self.isInField = isInField;

    self:CheckLev();

end


function SysOpenTipPanel:Dispose()

 UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;

    if (self._uiEffect) then
        self._uiEffect:Dispose()
        self._uiEffect = nil
    end

    self.gameObject = nil;
end
