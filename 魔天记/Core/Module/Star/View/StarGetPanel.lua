require "Core.Module.Common.Panel"

local StarGetPanel = class("StarGetPanel",Panel);
function StarGetPanel:New()
	self = { };
	setmetatable(self, { __index =StarGetPanel });
	return self
end


function StarGetPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    local Item = require "Core.Module.Star.View.StarGetItem"
    self.items = {}
    for i = 1, 10 do
        local it = Item:New()
        local go = UIUtil.GetChildByName(self._trsTen, "Transform", "item" .. i)
        it:Init(go.gameObject)
        table.insert(self.items, it)
    end 
    local it = Item:New()
    it:Init(self._trsOne.gameObject)
    table.insert(self.items, it)
end

function StarGetPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");	
	self._txtDebrisNum = UIUtil.GetChildInComponents(txts, "txtDebrisNum");
	self._txtDiv = UIUtil.GetChildInComponents(txts, "txtDiv");	
	self._btnDiv = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnDiv");
	self._btnExit = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnExit");
	self._trsOne = UIUtil.GetChildByName(self._trsContent, "Transform", "trsOne");
	self._trsTen = UIUtil.GetChildByName(self._trsContent, "Transform", "trsTen");
end

function StarGetPanel:_InitListener()
	self:_AddBtnListen(self._btnDiv.gameObject)
	self:_AddBtnListen(self._btnExit.gameObject)
end

function StarGetPanel:_OnBtnsClick(go)
	if go == self._btnDiv.gameObject  then
		self:_OnClickBtnDiv()
	elseif go == self._btnExit.gameObject then
		self:_OnClickBtnExit()
	end
end

function StarGetPanel:_OnClickBtnDiv()
    local c = StarManager.currentDivinationConfig
    if c.req_num == 1 then        
	    StarProxy.SendDivination(0, StarManager.GetDivinationDt() <= 0)
    else
	    StarProxy.SendDivination(1)
    end
end

function StarGetPanel:_OnClickBtnExit()
	ModuleManager.SendNotification(StarNotes.CLOSE_STAR_GET_PANEL)
end

function StarGetPanel:SetData(data)
	if not data then return end
	self.data = data
    self._txtDebrisNum.text = data.star_debris
    local c = StarManager.currentDivinationConfig
    self._txtDiv.text = LanguageMgr.Get("StarPanel/get/tip",
        {c = c.item_price * c.req_num , n = c.req_num})
    local ls = data.l
    local len = #ls
    local Item = require "Core.Module.Star.View.StarGetItem"
    if len == 1 then
        self._trsOne.gameObject:SetActive(true)
        self._trsTen.gameObject:SetActive(false)
        local it = self.items[11]
        it:UpdateItem(ls[1])
        it:CheckRedEffect()
        it:ShowEffect(0)
    else
        self._trsTen.gameObject:SetActive(true)
        self._trsOne.gameObject:SetActive(false)
        for i = 1, 10 do
            local it = self.items[i]
            it:UpdateItem(ls[i])
            it:CheckRedEffect()
            it:ShowEffect(i - 1)
        end 
    end
end

function StarGetPanel:_Dispose()
	self:_DisposeReference();
    for i = #self.items, 1, -1 do
        self.items[i]:Dispose()
    end 
    self.items = nil
end

function StarGetPanel:_DisposeReference()
	self._btnDiv = nil;
	self._btnExit = nil;
	self._txtDebrisNum = nil;
	self._txtDiv = nil;
	self._trsOne = nil;
	self._trsTen = nil;
end
return StarGetPanel