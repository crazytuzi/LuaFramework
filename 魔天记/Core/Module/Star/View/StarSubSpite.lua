require "Core.Module.Common.UIComponent"

local StarSubSpite = class("StarSubSpite",UIComponent);
function StarSubSpite:New(trs)
	self = { };
	setmetatable(self, { __index =StarSubSpite });
    if trs then self:Init(trs) end
	return self
end


function StarSubSpite:_Init()
	self:_InitReference();
	self:_InitListener();
end

function StarSubSpite:_InitReference()
	self._txtUpgradeNeed = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtUpgradeNeed");
	self._btnColor1 = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnColor1");
	self._btnColor2 = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnColor2");
	self._btnColor3 = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnColor3");
	self._btnColor4 = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnColor4");
	self._btnColor5 = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnColor5");
	self._btnColor6 = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnColor6");
	self._btnColor7 = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnColor7");
	self._btnSpite = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnSpite");
	self._NextStar = UIUtil.GetChildByName(self._gameObject, "UILabel", "NextStar");
    self._NextStar.text = LanguageMgr.Get('StarPanel/upgrade/next')
    self._scrollView = UIUtil.GetChildByName(self._gameObject, "UIScrollView", "scrollView");
    self._phalanxInfo = UIUtil.GetChildByName(self._scrollView, "LuaAsynPhalanx", "phalanx");
	self._phalanx = Phalanx:New();
    local Item = require "Core.Module.Star.View.StarItem2"
	self._phalanx:Init(self._phalanxInfo, Item)
	self._bg = UIUtil.GetChildByName(self._scrollView, "UISprite", "bg");
	self._effetParent = UIUtil.GetChildByName(self._scrollView, "Transform", "effetParent");
    self._effect = UIEffect:New()
    self._effect:Init(self._effetParent, self._bg, 10, "ui_yangHun")
end

function StarSubSpite:_InitListener()
	self:_AddBtnListen(self._btnColor1.gameObject)
	self:_AddBtnListen(self._btnColor2.gameObject)
	self:_AddBtnListen(self._btnColor3.gameObject)
	self:_AddBtnListen(self._btnColor4.gameObject)
	self:_AddBtnListen(self._btnColor5.gameObject)
	self:_AddBtnListen(self._btnColor6.gameObject)
	self:_AddBtnListen(self._btnColor7.gameObject)
	self:_AddBtnListen(self._btnSpite.gameObject)
    MessageManager.AddListener(StarNotes, StarNotes.STAR_DATA_CHANGE, StarSubSpite.UpdatePanel, self)
end

function StarSubSpite:_OnBtnsClick(go)
	if go == self._btnColor1.gameObject then
		self:_OnClickBtnColor1(go, 1)
	elseif go == self._btnColor2.gameObject then
		self:_OnClickBtnColor1(go, 2)
	elseif go == self._btnColor3.gameObject then
		self:_OnClickBtnColor1(go, 3)
	elseif go == self._btnColor4.gameObject then
		self:_OnClickBtnColor1(go, 4)
	elseif go == self._btnColor5.gameObject then
		self:_OnClickBtnColor1(go, 5)
	elseif go == self._btnColor6.gameObject then
		self:_OnClickBtnColor1(go, 6)
	elseif go == self._btnColor7.gameObject then
		self:_OnClickBtnColor1(go, 7)
	elseif go == self._btnSpite.gameObject then
		self:_OnClickBtnSpite(go)
	end
end

function StarSubSpite:_OnClickBtnColor1(go, i)
	local s = UIUtil.GetChildByName(go, "UISprite", "select")
    s.enabled = not s.enabled
    self:UpdateQuality(s.enabled, i - 1)
end

function StarSubSpite:UpdateQuality(f, quality)
	local its = self._phalanx:GetItems()
    for i = #its, 1, -1 do
        local it = its[i].itemLogic
        --if it.data.quality == quality then it:SetSelect(f) end
        if quality <= EquipQuality.Blue then
            if it.data.quality <= quality then it:SetSelect(f) end
        elseif it.data.quality == quality then
            it:SetSelect(f)
        end
    end
    self:UpdateNeed()
end

function StarSubSpite:_OnClickBtnSpite()
    local ids = {}
    local its = self._phalanx:GetItems()
    for i = #its, 1, -1 do
        local it = its[i].itemLogic
        if it:GetSelect() then table.insert(ids, it.data.id) end
    end
    if #ids > 0 then
        StarProxy.SendSpite(ids)
        if self._effect then self._effect:Play() end
        UISoundManager.PlayUISound(UISoundManager.ui_compose)
    end
end

function StarSubSpite:UpdatePanel()
    local d = StarManager.bag
    table.sort(d, function(a, b)
        if a.quality ~= b.quality then  return a.quality > b.quality end
        return a.id < b.id
    end)
	self._phalanx:Build(40, 5, d)
    self:InitSelect()
end

function StarSubSpite:InitSelect()
    for i = EquipQuality.Red, EquipQuality.Blue, -1 do
        local s = UIUtil.GetChildByName(self['_btnColor' .. (i + 1)], "UISprite", "select")
        s.enabled = i <= EquipQuality.Blue
    end
    local its = self._phalanx:GetItems()
    for i = #its, 1, -1 do
        local it = its[i].itemLogic
        it:SetSelect(it.data.quality <= EquipQuality.Blue
            or it.data.kind == StarManager.STAR_ELITE_TYPE)
        --it:SetSelect(false)
        it.ctroller = self
    end
    self:UpdateNeed()
    self._scrollView:ResetPosition()
end

function StarSubSpite:SelectItem(item)
    item:SetSelect(not item:GetSelect())
    self:UpdateNeed()
end

function StarSubSpite:UpdateNeed()
    local add = 0
    local its = self._phalanx:GetItems()
    for i = #its, 1, -1 do
        local it = its[i].itemLogic
        if it:GetSelect() then
            if not it.data.fusion_exp then
                local ac =  StarManager.GetAttConfig(it.data.quality, it.data.level)
                add = add + ac.fusion_exp
            else
                add = add + it.data.fusion_exp
            end
        end
    end
	self._txtUpgradeNeed.text = StarManager.GetCoin() .. '  [00ff00]+'  .. add
end


function StarSubSpite:_Dispose()
	self:_DisposeReference();
    self._phalanx:Dispose()
	self._phalanx = nil
    self._effect:Dispose()
    self._effect = nil
end

function StarSubSpite:_DisposeReference()
	self._btnColor1 = nil;
	self._btnColor2 = nil;
	self._btnColor3 = nil;
	self._btnColor4 = nil;
	self._btnColor5 = nil;
	self._btnColor6 = nil;
	self._btnColor7 = nil;
	self._btnSpite = nil;
	self._txtUpgradeNeed = nil;
    MessageManager.RemoveListener(StarNotes, StarNotes.STAR_DATA_CHANGE, StarSubSpite.UpdatePanel, self)
end
return StarSubSpite