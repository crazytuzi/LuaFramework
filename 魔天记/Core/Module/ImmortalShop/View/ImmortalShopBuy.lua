require "Core.Module.Common.UIComponent"

local ImmortalShopBuy = class("ImmortalShopBuy",UIComponent);
local ImmortalShopBuyItem = require "Core.Module.ImmortalShop.View.Item.ImmortalShopBuyItem"
function ImmortalShopBuy:New()
	self = { };
	setmetatable(self, { __index =ImmortalShopBuy });
	return self
end


function ImmortalShopBuy:_Init()
	self:_InitReference();
	self:_InitListener();
    self._timer = Timer.New(function() self:_UpdateTime() end, 1, -1, true)
    self._timer:Start()
    ImmortalShopProxy.SetRedPoint(false)    
end

function ImmortalShopBuy:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._txtRefreshTime = UIUtil.GetChildInComponents(txts, "txtRefreshTime");
	self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "phalanx");
	self._phalanx = Phalanx:New();
	self._phalanx:Init(self._phalanxInfo, ImmortalShopBuyItem)
end

function ImmortalShopBuy:SetActive(active)
    if (self._gameObject and self._isActive ~= active) then
        self._gameObject:SetActive(active);
        self._isActive = active;
    end
    if active then ImmortalShopProxy.SendImmortalShopList() end
end

function ImmortalShopBuy:_InitListener()
    MessageManager.AddListener(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_SHOP_LIST, ImmortalShopBuy._OnGetShopList, self)
end


function ImmortalShopBuy:_OnGetShopList(d)
    PrintTable(d, '----' , Warning)
    if not d then return end
	self._phalanx:Build(4, 2, d)
    self._endTime = ImmortalShopProxy.GetEndTime() 
    self:_UpdateTime()
end
function ImmortalShopBuy:_UpdateTime()
    if not self._endTime or self._endTime < 1 then return end
    local dt = self._endTime - GetTime()
    --Warning( os.date('%c', self._endTime) .. '_____' .. os.date('%c', GetTime()))
    if dt < 0 then
        return
    end
	self._txtRefreshTime.text = TimeUtil.GetStrForTime(dt, 'HH:mm:ss')
end

function ImmortalShopBuy:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function ImmortalShopBuy:_DisposeListener()
    MessageManager.RemoveListener(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_SHOP_LIST, ImmortalShopBuy._OnGetShopList)
end

function ImmortalShopBuy:_DisposeReference()
    if self._timer then self._timer:Stop() self._timer = nil end
	self._txtRefreshTime = nil;
	self._phalanx:Dispose()
	self._phalanx = nil
end
return ImmortalShopBuy