require "Core.Module.Common.Panel"
require "Core.Module.Common.UIComponent";
require "Core.Module.ChoosePKType.ChoosePKTypeNotes";
require "Core.Module.ChoosePKType.ChoosePKTypeProxy"

ChoosePKTypePanel = class("ChoosePKTypePanel", Panel);

ChoosePKTypePanel.COOLTIME = 10;
ChoosePKTypePanel.CurrTime = 0;

function ChoosePKTypePanel:New()
    self = { };
    setmetatable(self, { __index = ChoosePKTypePanel });
    return self
end

function ChoosePKTypePanel:_Init()
    self:_InitReference();
    self:_InitListener();
    ChoosePKTypeProxy.DisplayPkData();
end

function ChoosePKTypePanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    local labels = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtDesc = UIUtil.GetChildInComponents(labels, "txt_desc");
    self._txtDesc.text = LanguageMgr.Get("PVP/pkDataTitle") .. "0";

    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self._btn_desc = UIUtil.GetChildInComponents(btns, "btn_desc");
    self._btn_type1 = UIUtil.GetChildInComponents(btns, "btn_type1");
    self._btn_type2 = UIUtil.GetChildInComponents(btns, "btn_type2");
    self._btn_type3 = UIUtil.GetChildInComponents(btns, "btn_type3");
    self._btn_type4 = UIUtil.GetChildInComponents(btns, "btn_type4");

    local txtType1 = UIUtil.GetChildByName(self._btn_type1, "UILabel", "Label");
    txtType1.text = LanguageMgr.Get("PVP/pkType20");

    local txtType2 = UIUtil.GetChildByName(self._btn_type2, "UILabel", "Label");
    txtType2.text = LanguageMgr.Get("PVP/pkType21");

    local txtType3 = UIUtil.GetChildByName(self._btn_type3, "UILabel", "Label");
    txtType3.text = LanguageMgr.Get("PVP/pkType22");

    local txtType4 = UIUtil.GetChildByName(self._btn_type4, "UILabel", "Label");
    txtType4.text = LanguageMgr.Get("PVP/pkType23");
end


function ChoosePKTypePanel:_InitListener()
    self._onClickCloseHandler = function(go) self:_OnClickCloseHandler(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickCloseHandler);

    self._onClickDescHandler = function(go) self:_OnClickDescHandler(self) end
    UIUtil.GetComponent(self._btn_desc, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickDescHandler);

    self._onClickPKTypeHandler = function(go) self:_OnClickPKTypeHandler(go) end
    UIUtil.GetComponent(self._btn_type1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickPKTypeHandler);
    UIUtil.GetComponent(self._btn_type2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickPKTypeHandler);
    UIUtil.GetComponent(self._btn_type3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickPKTypeHandler);
    UIUtil.GetComponent(self._btn_type4, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickPKTypeHandler);

    MessageManager.AddListener(ChoosePKTypeNotes, ChoosePKTypeNotes.EVENT_DISPLAYPKDATA, ChoosePKTypePanel._OnDisplayPkData, self);
end

function ChoosePKTypePanel:_OnClickCloseHandler()
    ModuleManager.SendNotification(ChoosePKTypeNotes.CLOSE_CHOOSEPKTYPE);
end

function ChoosePKTypePanel:_OnClickDescHandler()
    ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM4PANEL, { title = LanguageMgr.Get("PVP/pkDescribeTitle"), msg = LanguageMgr.Get("PVP/pkDescribeMsg") });
end

function ChoosePKTypePanel:_OnDisplayPkData(data)
    if (data) then
        self._txtDesc.text = LanguageMgr.Get("PVP/pkDataTitle") .. data.pk;
    end
end

function ChoosePKTypePanel:_OnClickPKTypeHandler(go)
    local hInfo = PlayerManager.hero.info;
    if (hInfo.pkState == 2) then
        MsgUtils.ShowTips("PVP/pkTypeChooseMsg");
    else
        if (Time.time - ChoosePKTypePanel.CurrTime > ChoosePKTypePanel.COOLTIME) then
            if (go) then
                local btnName = go.name;
                local pkType = 0;
                if (btnName == self._btn_type2.name) then
                    pkType = 1;
                elseif (btnName == self._btn_type3.name) then
                    pkType = 2;
                elseif (btnName == self._btn_type4.name) then
                    pkType = 3;
                end
                ChoosePKTypeProxy.ChooseType(pkType)
                ChoosePKTypePanel.CurrTime = Time.time                
            end
            self:_OnClickCloseHandler();
        else
            MsgUtils.ShowTips("PVP/pkTypeCoolMsg");
        end
    end
end


function ChoosePKTypePanel:_Dispose()
    self:_DisposeListener();
    self._btn_close = nil;
    self._txtDesc = nil;
    self._btn_desc = nil;
    self._btn_type1 = nil;
    self._btn_type2 = nil;
    self._btn_type3 = nil;
    self._btn_type4 = nil;
end

function ChoosePKTypePanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickCloseHandler = nil;

    UIUtil.GetComponent(self._btn_desc, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickDescHandler = nil;

    UIUtil.GetComponent(self._btn_type1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btn_type2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btn_type3, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btn_type4, "LuaUIEventListener"):RemoveDelegate("OnClick");

    MessageManager.RemoveListener(ChoosePKTypeNotes, ChoosePKTypeNotes.EVENT_DISPLAYPKDATA, ChoosePKTypePanel._OnDisplayPkData);
    self._onClickPKTypeHandler = nil;
end