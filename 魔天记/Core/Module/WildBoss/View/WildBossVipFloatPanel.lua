require "Core.Module.Common.UIComponent"
local WildBossVipFloatItem = require "Core.Module.WildBoss.View.Item.WildBossVipFloatItem";

local WildBossVipFloatPanel = class("WildBossVipFloatPanel", UIComponent);

function WildBossVipFloatPanel:_Init()
	self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView/phalanx")
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, WildBossVipFloatItem);

end

function WildBossVipFloatPanel:_Dispose()
	self:Exit()
	self._phalanx:Dispose();
	--[[
	UIUtil.GetComponent(self._btnAction, "LuaUIEventListener"):RemoveDelegate("OnClick")
	self._onClickFunctionHandler = nil
	self._txtNum = nil
	self._txtTime = nil
	self._btnAction = nil
    if self._mainTexturePath then
        UIUtil.RecycleTexture(self._mainTexturePath)
        self._mainTexturePath = nil
    end
    self._imgIcon = nil
    ]]
end

local _sort = table.sort;
function WildBossVipFloatPanel:Enter()

	local list = WildBossManager.GetVipBossListInMap();
	_sort(list, WildBossManager.SortBossByLv);
	self._phalanx:Build(#list, 1, list);
    self:Show()

    MessageManager.AddListener(WildBossNotes, WildBossNotes.RSP_VIP_BOSS_INFO, WildBossVipFloatPanel.UpdateStatus, self);
    WildBossProxy.ReqVipBossInfo();

    
    --TabooProxy.GetTabooInfo()
    --TabooProxy.SetInTaboo(true)
end

function WildBossVipFloatPanel:Exit()
    self:Close()
    MessageManager.RemoveListener(WildBossNotes, WildBossNotes.RSP_VIP_BOSS_INFO, WildBossVipFloatPanel.UpdateStatus)
end

function WildBossVipFloatPanel:Show()
    if self.showing then return end
	self.showing = true
    self._gameObject:SetActive(true)
end

function WildBossVipFloatPanel:Close()
    if not self.showing then return end
	self.showing = false
    self._gameObject:SetActive(false)
end

function WildBossVipFloatPanel:UpdateStatus(data)
	local items = self._phalanx:GetItems()
	for i, v in ipairs(items) do
		local item = v.itemLogic;
		item:UpdateItem(item.data);
	end
end

return WildBossVipFloatPanel;