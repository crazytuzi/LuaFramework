require "Core.Module.Common.Panel"
local NewestNoticeTypeItem = require "Core.Module.NewestNotice.View.Item.NewestNoticeTypeItem"
local SubNewestNoticePanel1 = require "Core.Module.NewestNotice.View.Item.SubNewestNoticePanel1"



local NewestNoticePanel = class("NewestNoticePanel", Panel);
function NewestNoticePanel:New()
	self = {};
	setmetatable(self, {__index = NewestNoticePanel});
	return self
end


function NewestNoticePanel:_Init()
	self:_InitReference();
	self:_InitListener();	
end

function NewestNoticePanel:_InitReference()
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	self._trsData = UIUtil.GetChildByName(self._trsContent, "trsData");
	self._scrollView = UIUtil.GetChildByName(self._trsData, "UIScrollView", "Sprite/scrollview")
	self._trsParent = UIUtil.GetChildByName(self._trsData, "Sprite/scrollview/trsParent");
	self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "scrollview/phalanx")
	self._phalanx = Phalanx:New()	
	self._phalanx:Init(self._phalanxInfo, NewestNoticeTypeItem)	
	self._panels = {}
	self._panelIndex = 1
end

function NewestNoticePanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function NewestNoticePanel:_OnClickBtn_close()
	ModuleManager.SendNotification(NewestNoticeNotes.CLOSE_NEWESTNOTICENOTESPANEL)
end

function NewestNoticePanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function NewestNoticePanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function NewestNoticePanel:_DisposeReference()
	self._btn_close = nil;
	self._trsData = nil;
	self._trsParent = nil;
	for k, v in pairs(self._panels) do
		if(v) then
			v:Dispose()
		end
	end
	self._panels = nil
end

function NewestNoticePanel:_InitPanel()
	local data = NewestNoticeManager.GetNoticeData()
	self._phalanx:Build(#data, 1, data)
	local items = self._phalanx:GetItems()
	if(items and #items > 0) then
		items[1].itemLogic:_OnClickItem()
	end
end

function NewestNoticePanel:UpdatePanel(data)
	self._panelIndex = data.order
	for k, v in pairs(self._panels) do
		if(v) then
			v:SetActive(k == self._panelIndex)
		end
	end
	
	
	-- self._scrollView:UpdatePosition();
	
	
	if(self._panels[self._panelIndex] == nil) then
		self._panels[self._panelIndex] = self:_CreatePanelByType(data.type)
	end
	self._scrollView:ResetPosition();
	self._panels[self._panelIndex]:UpdatePanel(data)
end



function NewestNoticePanel:_CreatePanelByType(t)
	if t == 1 then		
		return SubNewestNoticePanel1:New(self._trsParent)
	elseif t == 2 then
		
	elseif t == 3 then
		
	end
end

return NewestNoticePanel 