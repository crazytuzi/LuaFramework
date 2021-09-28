require "Core.Module.Common.Panel"
require "Core.Module.Trump.View.Item.TrumpInfoPropertyItem"

TrumpInfoPanel = class("TrumpInfoPanel", Panel);
function TrumpInfoPanel:New()
    self = { };
    setmetatable(self, { __index = TrumpInfoPanel });
    return self
end
 
function TrumpInfoPanel:_Init()
    self._dressDes = LanguageMgr.Get("trump/trumpInfoPanel/dress")
    self._unDressDes = LanguageMgr.Get("trump/trumpInfoPanel/undress")
    self:_InitReference();
    self:_InitListener();


end

function TrumpInfoPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
    self._txtEquip = UIUtil.GetChildInComponents(txts, "txtEquip");
    self._txtlevel = UIUtil.GetChildInComponents(txts, "txtlevel");
    self._txtDes = UIUtil.GetChildInComponents(txts, "txtDes");
    self._txtProperty = UIUtil.GetChildInComponents(txts, "txtProperty");
    self._txtSkillNameAndLevel = UIUtil.GetChildInComponents(txts, "txtSkillNameAndLevel");

    self._imgQuailty = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgQuailty");
    self._imgIcon = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgIcon");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._btnEquip = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnEquip");
    self._btnFollow = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnFollow");
    self._trumpRefinePropertyPhalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "refinePropertyPhalanx")
    self._trumpRefinePropertyPhalanx = Phalanx:New()
    self._trumpRefinePropertyPhalanx:Init(self._trumpRefinePropertyPhalanxInfo, TrumpInfoPropertyItem)

end

function TrumpInfoPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtnEquip = function(go) self:_OnClickBtnEquip(self) end
    UIUtil.GetComponent(self._btnEquip, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnEquip);
    self._onClickBtnFollow = function(go) self:_OnClickBtnFollow(self) end
    UIUtil.GetComponent(self._btnFollow, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFollow);
end

function TrumpInfoPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(TrumpNotes.CLOSE_TRUMPINFOPANEL)
end

function TrumpInfoPanel:_OnClickBtnEquip()
    TrumpProxy.MoveProduct(self.data)
end

function TrumpInfoPanel:_OnClickBtnFollow()
    TrumpProxy.SendTrumpOnDress(self.data.id)
end

function TrumpInfoPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    self._trumpRefinePropertyPhalanx:Dispose()
end

function TrumpInfoPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btnEquip, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnEquip = nil;
    UIUtil.GetComponent(self._btnFollow, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnFollow = nil;
end

function TrumpInfoPanel:_DisposeReference()
    self._btn_close = nil;
    self._btnEquip = nil;
    self._btnFollow = nil;
end

function TrumpInfoPanel:UpdatePanel(data)
    if (data) then
        self.data = data
        if (self.data.st == ProductManager.ST_TYPE_IN_TRUMPBAG) then
            self._btnFollow.gameObject:SetActive(false)
            self._txtEquip.text = self._dressDes
        elseif (self.data.st == ProductManager.ST_TYPE_IN_TRUMPEQUIPBAG) then
            self._btnFollow.gameObject:SetActive(true)
            self._txtEquip.text = self._unDressDes
        end
        local trumpSkillInfo = self.data:GetTrumpSkillInfo()
        self._txtSkillNameAndLevel.text = string.format("%s %s:", trumpSkillInfo.name, GetLvDes(trumpSkillInfo.skill_lv))

        self._txtDes.text = trumpSkillInfo.skill_desc
        local name = self.data.configData.name
        if (self.data.refineLev > 0) then
            name = name .. "+" .. self.data.refineLev
        end
        self._txtName.text = name
        ProductManager.SetIconSprite(self._imgIcon, self.data.configData.icon_id)
        self._txtlevel.text = GetLvDes(self.data.lev)
        self._imgQuailty.spriteName = ProductManager.GetQulitySpriteName(self.data.configData.quality)
        self._txtProperty.text = self.data:GetTrumpPropertyDes()
        local p = self.data:GetRefineProperty()
        self._trumpRefinePropertyPhalanx:Build(table.getCount(p), 1, p)
    end
end 