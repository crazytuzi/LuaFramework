require "Core.Module.Common.UIComponent"

local ImmortalShopRevelryGet = class("ImmortalShopRevelryGet",UIComponent);
local ImmortalRevelryGetItem = require "Core.Module.ImmortalShop.View.Item.ImmortalRevelryGetItem"
function ImmortalShopRevelryGet:New()
	self = { };
	setmetatable(self, { __index =ImmortalShopRevelryGet });
	return self
end


function ImmortalShopRevelryGet:_Init()
	self:_InitReference();
	self:_InitListener();
end

function ImmortalShopRevelryGet:_InitReference()
	local btns = UIUtil.GetComponentsInChildren(self._gameObject, "UIButton");
	self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
	self._phalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "scrollView/phalanx");
	self._phalanx = Phalanx:New();
	self._phalanx:Init(self._phalanxInfo, ImmortalRevelryGetItem, true)
end

function ImmortalShopRevelryGet:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function ImmortalShopRevelryGet:_OnClickBtn_close()
	self:SetActive(false)
end

function ImmortalShopRevelryGet:UpdatePanel(d)
    if not d then return end
	local cs = ImmortalShopProxy.GetPointConfigs()
    local ds = {}
    local dps = d.l2
    for i = 1, #cs do
        local c = cs[i]
        local p = 0
        for j = 1, #dps do
            local dp = dps[j]
            if dp.id == c.id then p = dp.v break end
        end
        table.insert(ds, {c = c, p = p})
    end
    table.sort(ds, function(a, b) return a.c.point_all - a.p > b.c.point_all - b.p end)
	self._phalanx:Build(#ds, 1, ds)
end

function ImmortalShopRevelryGet:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function ImmortalShopRevelryGet:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function ImmortalShopRevelryGet:_DisposeReference()
	self._btn_close = nil;
	self._phalanx:Dispose()
	self._phalanx = nil
end
return ImmortalShopRevelryGet