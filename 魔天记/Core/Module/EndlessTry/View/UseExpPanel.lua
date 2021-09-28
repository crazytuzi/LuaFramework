require "Core.Module.Common.Panel"

local UseExpPanel = class("UseExpPanel",Panel);
local itemGap = 83
local itemStartY = 33
function UseExpPanel:New()
	self = { };
	setmetatable(self, { __index =UseExpPanel });
	return self
end


function UseExpPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function UseExpPanel:_InitReference()
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btnClose = UIUtil.GetChildInComponents(btns, "btnClose");
	self._trsitem = UIUtil.GetChildByName(self._trsContent, "Transform", "trsitem").gameObject;
	self._imgBg = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgBg");
    self._bgHeight = self._imgBg.height
    self:_InitItems()
end
function UseExpPanel:_InitItems()
    local ps = EndlessTryProxy.GetExpProductIds()
    self._items = {}
    local len = #ps
    local n = 0
    for i = 1, len, 3 do
        local p = ps[i]
        local cp = ProductManager.GetProductById(p)
        local it = self._trsitem
        if i > 1 then it = Resourcer.Clone(it, self._trsContent) end
        self:_InitItem(it, n, cp, ps[i + 1], ps[i + 2])
        n  = n + 1
    end
    self._imgBg.height = self._bgHeight + (n - 1) * itemGap
end
function UseExpPanel:_InitItem(it, i, cp, sid, cost)
    local icon = UIUtil.GetChildByName(it, "UISprite", "imgIcon")
    local txtExp = UIUtil.GetChildByName(it, "UILabel", "txtExp")
    local btnUse = UIUtil.GetChildByName(it, "UIButton", "btnUse")
    local txtnum = UIUtil.GetChildByName(it, "UILabel", "txtnum")
    local num = BackpackDataManager.GetProductTotalNumBySpid(cp.id)
    txtnum.text = num
    ProductManager.SetIconSprite(icon, cp.icon_id)
    txtExp.text = cp.name
	local onClickBtnUse = function(go)
        self:_OnClickBtnUse(cp, sid, cost)
        num = num - 1
        if num >= 0 then txtnum.text = num end
    end
	UIUtil.GetComponent(btnUse, "LuaUIEventListener"):RegisterDelegate("OnClick", onClickBtnUse)
    Util.SetLocalPos(it, 0, itemStartY - i * itemGap , 0)
    table.insert(self._items, it)
end

function UseExpPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function UseExpPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(EndlessTryNotes.CLOSE_ENDLESS_EXP_BUY_PANEL)
end

function UseExpPanel:_OnClickBtnUse(cp, sid, cost)
    EndlessTryProxy.UseExp(cp.id, sid, cp.name, cost)
end

function UseExpPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function UseExpPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
end

function UseExpPanel:_DisposeReference()
    for i = 1, #self._items do
        UIUtil.GetComponent(self._items[i], "LuaUIEventListener"):RemoveDelegate("OnClick")
    end
	self._btnClose = nil;
	self._btnUse = nil;
	self._txtExp = nil;
	self._imgIcon = nil;
	self._trsitem = nil;
    self._imgBg = nil;
    self._items = nil
end
return UseExpPanel