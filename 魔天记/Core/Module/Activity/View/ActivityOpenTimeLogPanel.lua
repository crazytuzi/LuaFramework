require "Core.Module.Common.Panel"

require "Core.Module.Activity.View.item.ActivityOpenTimeLogItem"

local ActivityOpenTimeLogPanel = class("ActivityOpenTimeLogPanel", Panel);
function ActivityOpenTimeLogPanel:New()
    self = { };
    setmetatable(self, { __index = ActivityOpenTimeLogPanel });
    return self
end


function ActivityOpenTimeLogPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function ActivityOpenTimeLogPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtTitle1 = UIUtil.GetChildInComponents(txts, "txtTitle1");
    self._txtTitle1 = UIUtil.GetChildInComponents(txts, "txtTitle1");
    self._txtTitle1 = UIUtil.GetChildInComponents(txts, "txtTitle1");
    self._txtTitle1 = UIUtil.GetChildInComponents(txts, "txtTitle1");
    self._txtTitle1 = UIUtil.GetChildInComponents(txts, "txtTitle1");
    self._txtTitle1 = UIUtil.GetChildInComponents(txts, "txtTitle1");
    self._txtTitle1 = UIUtil.GetChildInComponents(txts, "txtTitle1");
    self._txtTitle1 = UIUtil.GetChildInComponents(txts, "txtTitle1");
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
    self._trsTitle = UIUtil.GetChildInComponents(trss, "trsTitle");
    self._trsList = UIUtil.GetChildInComponents(trss, "trsList");

    local time = GetOffsetTime();
    local wfd = os.date("*t", time);
    local wd = wfd.wday;
    -- 从星期天开始



    self.wselectes = { };
    for i = 1, 7 do
        local go = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView/weekSelelect/w" .. i);
        self.wselectes[i] = go;

        if wd ~= i then
            go.gameObject:SetActive(false);
        else
            go.gameObject:SetActive(true);
        end
    end


    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, ActivityOpenTimeLogItem);

    local data = self:GetDataList()
    self._phalanx:Build(table.getCount(data), 1, data)

end

function ActivityOpenTimeLogPanel:GetDataList()
    local cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_WEEK_LIST);
    local t_num = table.getCount(cf);
    local changeBg = true;
    for i = 1, t_num do
        cf[i].changeBg = changeBg;
        changeBg = not changeBg;
    end

    return cf;
end

function ActivityOpenTimeLogPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function ActivityOpenTimeLogPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITYOPENTIMELOGPANEL);
end

function ActivityOpenTimeLogPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ActivityOpenTimeLogPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;


    if (self._phalanx) then
        self._phalanx:Dispose()
        self._phalanx = nil
    end

end

function ActivityOpenTimeLogPanel:_DisposeReference()
    self._btnClose = nil;
    self._txtTitle1 = nil;
    self._txtTitle1 = nil;
    self._txtTitle1 = nil;
    self._txtTitle1 = nil;
    self._txtTitle1 = nil;
    self._txtTitle1 = nil;
    self._txtTitle1 = nil;
    self._txtTitle1 = nil;
    self._trsTitle = nil;
    self._trsList = nil;
end
return ActivityOpenTimeLogPanel