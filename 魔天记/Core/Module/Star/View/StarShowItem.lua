require "Core.Module.Common.UIComponent"

local StarShowItem = class("StarShowItem",UIItem);
function StarShowItem:New()
	self = { };
	setmetatable(self, { __index =StarShowItem });
	return self
end


function StarShowItem:_Init()
	self:_InitReference();
	self:_InitListener();
    self:UpdateItem(self.data)
end

function StarShowItem:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self.gameObject, "UILabel")
	self._txtLock = UIUtil.GetChildInComponents(txts, "txtLock")
end

function StarShowItem:_InitListener()
end

function StarShowItem:_OnBtnsClick(go)
end

function StarShowItem:UpdateItem(data)
    if not data then return end
	self.data = data
    self._txtLock.text = data.num == 0 and LanguageMgr.Get('StarPanel/show/def') or 
        LanguageMgr.Get('StarPanel/show/unlock', { n = data.num })
    self.items = {}
    local Item = require "Core.Module.Star.View.StarItem2"
    local ids = data.star_gather
    for i = 1, 5 do
        local go = UIUtil.GetChildByName(self.gameObject, "Transform", "item" .. i)
        local it = Item:New()
        it:Init(go, ids[i])
        --it.ctroller = self
        table.insert(self.items, it)
    end  
end

function StarShowItem:SelectItem(item)
    local info = ProductInfo:New()
    info:Init({ spId = item.data.spId })
	ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = info})
end

function StarShowItem:_Dispose()
	self:_DisposeReference();
    for i = #self.items, 1, -1 do
        self.items[i]:Dispose()
    end 
    self.items = nil
end

function StarShowItem:_DisposeReference()
	self._txtLock = nil
end
return StarShowItem