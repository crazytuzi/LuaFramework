require "Core.Module.Common.UIComponent"

local ImmortalShopRevelry = class("ImmortalShopRevelry",UIComponent);
local ImmortalShopRevelryItem = require "Core.Module.ImmortalShop.View.Item.ImmortalShopRevelryItem"
local ImmortalShopRevelryGet = require "Core.Module.ImmortalShop.View.ImmortalShopRevelryGet"

function ImmortalShopRevelry:New()
	self = { };
	setmetatable(self, { __index =ImmortalShopRevelry });
	return self
end

function ImmortalShopRevelry:_Init()
	self:_InitReference();
	self:_InitListener();
end

function ImmortalShopRevelry:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._txtBtn = UIUtil.GetChildInComponents(txts, "txtBtn");
	self._txtRevelryNum = UIUtil.GetChildInComponents(txts, "txtRevelryNum");
	self._btnGo = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnGo");
	self._revelryGetPanel = UIUtil.GetChildByName(self._gameObject, "Transform", "RevelryGetPanel");
	self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView/phalanx");
	self._phalanx = Phalanx:New();
	self._phalanx:Init(self._phalanxInfo, ImmortalShopRevelryItem)
end

function ImmortalShopRevelry:_InitListener()
	self._onClickBtnGet = function(go) self:_OnClickBtnGet(self) end
	UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGet);
    MessageManager.AddListener(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_REVELRY_CHANGE, ImmortalShopRevelry._OnChange, self)
    MessageManager.AddListener(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_REVELRY_INFO, ImmortalShopRevelry._OnInfo, self)
end

function ImmortalShopRevelry:_OnClickBtnGet()
    if not self._RevelryGetPanel then
        self._RevelryGetPanel = ImmortalShopRevelryGet:New()
        self._RevelryGetPanel:Init(self._revelryGetPanel)
    end
	self._RevelryGetPanel:SetActive(true)
    self._RevelryGetPanel:UpdatePanel(self.data)
end

function ImmortalShopRevelry:SetActive(active)
    if (self._gameObject and self._isActive ~= active) then
        self._gameObject:SetActive(active);
        self._isActive = active;
    end
    if active then ImmortalShopProxy.SendImmortalRevelry() end
end
function ImmortalShopRevelry:_OnChange(d)
    self:_OnInfo(d)
end
function ImmortalShopRevelry:_OnInfo(d)
    PrintTable(d, '----' , Warning)
    self.data = d
    self:_ResetBuild(d.l, d.v)
end
function ImmortalShopRevelry:_ResetBuild(geteds, p)
    self._txtRevelryNum.text = p
    local cs = ImmortalShopProxy.GetAllConfigs()
    local ds = {}
    for i = 1, #cs do
        local c = cs[i]        
        local geted = table.contains(geteds, c.id)
        table.insert(ds, {c = c, geted = geted, p = p})
    end
	self._phalanx:Build(#ds, 1, ds)
end

function ImmortalShopRevelry:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function ImmortalShopRevelry:_DisposeListener()
	UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGet = nil;
    MessageManager.RemoveListener(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_REVELRY_CHANGE, ImmortalShopRevelry._OnChange)
    MessageManager.RemoveListener(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_REVELRY_INFO, ImmortalShopRevelry._OnInfo)
end

function ImmortalShopRevelry:_DisposeReference()
	self._btnGo = nil;
	self._txtBtn = nil;
	self._txtRevelryNum = nil;
	self._phalanx:Dispose()
	self._phalanx = nil
    if self._RevelryGetPanel then
        self._RevelryGetPanel:Dispose()
        self._RevelryGetPanel = nil
    end
end
return ImmortalShopRevelry