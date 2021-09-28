require "Core.Module.Common.UIComponent"

SelectSceneItem = class("SelectSceneItem",UIComponent);
function SelectSceneItem:New()
	self = { };
	setmetatable(self, { __index =SelectSceneItem });
	return self
end

--l：[{ln,st:0流畅 1拥挤 2爆满},..]
function SelectSceneItem:InitData(data, panel)
    self.data = data
    self.panel = panel
    --logTrace(tostring(data.ln) ..":" .. tostring(data.st))
    self._txtCon.text = "分线" .. data.ln .. (data.ln > 9 and "  " or "   ") .. SelectSceneProxy.GetStateDes(data.st)
    self._imgStatus.spriteName = SelectSceneProxy.GetStateSprName(data.st)
end

function SelectSceneItem:_Init()
	self:_InitReference();
	self:_InitListener();
end

function SelectSceneItem:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._txtCon = UIUtil.GetChildInComponents(txts, "txtCon");
	self._imgSelect = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgSelect");
	self._imgStatus = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgStatus");
	self._uiToggle = UIUtil.GetComponent(self._gameObject, "UIToggle");
end

function SelectSceneItem:_InitListener()
	self._onClickSelect = function(go) self:_OnSelect(self) end
	UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickSelect);
end
function SelectSceneItem:_OnSelect()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SceneLineChange, self._OnSelected, self);
    SocketClientLua.Get_ins():SendMessage(CmdType.SceneLineChange, {ln = self.data.ln });
end
function SelectSceneItem:_OnSelected(cmd,data)
    --PrintTable(data, "_OnSelected:")
    if data.errCode then return end
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SceneLineChange, self._OnSelected);
    GameSceneManager.SetSceneLine(data.line)
    self.panel:Close()
end
function SelectSceneItem:Select(val)
    self._uiToggle.value = val
end

function SelectSceneItem:_Dispose()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SceneLineChange, self._OnSelected);
	UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickSelect = nil
	self:_DisposeReference();
end

function SelectSceneItem:_DisposeReference()
	self._txtCon = nil;
	self._imgSelect = nil;
	self._imgStatus = nil;
end
