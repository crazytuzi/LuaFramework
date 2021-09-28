require "Core.Module.Common.UIComponent"
local GuildWarFloatItem = require "Core.Module.GuildWar.View.Item.GuildWarFloatItem";

local GuildWarFloatPanel = class("GuildWarFloatPanel", UIComponent);

function GuildWarFloatPanel:_Init()
	self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView/phalanx")
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, GuildWarFloatItem);

	self._timer = Timer.New( function(val) self:OnUpdate(val) end, 2.5, -1, false);
	self._timer:Start();
end

function GuildWarFloatPanel:_Dispose()
	self:Exit()
	self._phalanx:Dispose();
	if self._timer then
		self._timer:Stop();
		self._timer = nil;
	end

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
function GuildWarFloatPanel:Enter()

    self:Show()

    --MessageManager.AddListener(WildBossNotes, WildBossNotes.RSP_VIP_BOSS_INFO, GuildWarFloatPanel.UpdateStatus, self);
end

function GuildWarFloatPanel:Exit()
    self:Close()
    --MessageManager.RemoveListener(WildBossNotes, WildBossNotes.RSP_VIP_BOSS_INFO, GuildWarFloatPanel.UpdateStatus)
end

function GuildWarFloatPanel:Show()
    if self.showing then return end
	self.showing = true
    self._gameObject:SetActive(true)

    self:OnUpdate();
    self._timer:Pause(false);
end

function GuildWarFloatPanel:Close()
    if not self.showing then return end
	self.showing = false
    self._gameObject:SetActive(false)
    self._timer:Pause(true);
end

function GuildWarFloatPanel:UpdateStatus(data)
	local items = self._phalanx:GetItems()
	for i, v in ipairs(items) do
		local item = v.itemLogic;
		item:UpdateItem(item.data);
	end
end

local _insert = table.insert;
local _campList = {
	[1] = {129002,129003,129000,129001,129004}; --蓝
	[2] = {129000,129001,129002,129003,129004}; --红
}

local _postList = {
	[1] = {6,7,4,5,3}; --蓝
	[2] = {4,5,6,7,3}; --红
}

local _idxList = nil;
function GuildWarFloatPanel.GetListInMap()
	local list = {};
	_idxList = {}

	local camp = PlayerManager.GetPlayerInfo().camp;
	--Warning(camp)
	--Warning(camp == 1 and "blue" or "red")
	local pl = _postList[camp]
	for i, v in ipairs(_campList[camp]) do
		local m = TaskUtils.GetMonster(v);
		local d = {mid = v, info = m and m.info or nil, posId = pl[i]};
		list[i] = d;
		_idxList[d] = i;
	end
	_sort(list, GuildWarFloatPanel.SortList);
	--for i, v in ipairs(list) do
	--	log(v.mid);
	--end
	return list;
end

function GuildWarFloatPanel.SortList(a, b)
	if a.info == nil or b.info == nil then
		if a.info then
			return true;
		elseif b.info then
			return false;
		end
	end
	return _idxList[a] < _idxList[b];
end

function GuildWarFloatPanel:OnUpdate()
	local list = GuildWarFloatPanel.GetListInMap();
	self._phalanx:Build(#list, 1, list);
end


return GuildWarFloatPanel;