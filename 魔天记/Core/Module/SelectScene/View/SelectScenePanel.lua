require "Core.Module.Common.Panel"
require "Core.Module.SelectScene.View.SelectSceneItem"

SelectScenePanel = class("SelectScenePanel", Panel);
local ScrollPos = Vector3(0, -24, 0)

function SelectScenePanel:New()
    self = { };
    setmetatable(self, { __index = SelectScenePanel });
    return self
end


function SelectScenePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function SelectScenePanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtCon = UIUtil.GetChildInComponents(txts, "txtCon");
    local imgs = UIUtil.GetComponentsInChildren(self._trsContent, "UISprite");
    self._imgSelect = UIUtil.GetChildInComponents(imgs, "imgSelect");
    self._imgStatus = UIUtil.GetChildInComponents(imgs, "imgStatus");
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
    self._trsScroll = UIUtil.GetChildInComponents(trss, "trsScroll");
    self._trsItemGo = UIUtil.GetChildInComponents(trss, "btnItem").gameObject;
    self._trsItemGo:SetActive(false)
    self._uiscroll = UIUtil.GetComponent(self._trsScroll, "UIScrollView");
end

function SelectScenePanel:_InitListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self.Close);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetSceneLines, self._GetSceneLines, self);
    SocketClientLua.Get_ins():SendMessage(CmdType.GetSceneLines);
end

-- 返回场景线列表callBack(lines：[{ln,st:0流畅 1拥挤 2爆满},..]
function SelectScenePanel:_GetSceneLines(cmd, data)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetSceneLines, self._GetSceneLines);
    self:ClearItems()
    local ls = data.lines
    -- for i=#ls+1, math.Random(1,20), 1 do table.insert(ls,{ ln = i, st = math.floor(math.Random(1,4))-1 }) end
    self.items = { }
    local curline = GameSceneManager.scenelineData.ln
    local w = 320 h = 72
    local gap =(self._uiscroll.panel.width - w * 2) / 3
    local x = w * 0.5 + gap y = - h
    local n = 0
    for i, v in pairs(ls) do
        local item = SelectSceneItem.New()
        local iv = Resourcer.Clone(self._trsItemGo, self._trsScroll);
        Util.SetLocalPos(iv, x +(w + gap) *(n % 2), y -(h + gap) * math.floor(n / 2), 0)
        --        iv.transform.localPosition = Vector3(x + (w +gap) * (n % 2),y - (h + gap) * math.floor(n / 2), 0)
        n = n + 1
        iv:SetActive(true)
        item:Init(iv)
        item:InitData(v, self)
        if v.ln == curline then item:Select(true) end
        table.insert(self.items, item)
    end
    -- self._uiTable:Reposition()
    Util.SetLocalPos(self._trsScroll, 0, -24, 0)

    --    self._trsScroll.localPosition = ScrollPos
end

function SelectScenePanel:Close()
    ModuleManager.SendNotification(SelectSceneNotes.CLOSE_SELECTSCENE_PANEL)
end

function SelectScenePanel:ClearItems()
    if not self.items then return end
    for i, v in pairs(self.items) do
        v:Dispose()
    end
    self.items = nil
end
function SelectScenePanel:_Dispose()
    self:ClearItems()
    self:_DisposeListener();
    self:_DisposeReference();
end

function SelectScenePanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
end

function SelectScenePanel:_DisposeReference()
    self._btnClose = nil;
    self._txtCon = nil;
    self._imgSelect = nil;
    self._imgStatus = nil;
    self._trsScroll = nil;
    self._trsItemGo = nil;
    self._uiTable = nil
    self._uiscroll = nil
end
