require "Core.Module.Common.Panel"
require "Core.Module.Promote.View.Item.EvaluateItem"
require "Core.Module.Promote.View.Item.PromoteLeftListItem"
require "Core.Module.Promote.View.Item.PromoteRightListItem"

PromotePanel = class("PromotePanel", Panel);

local strongFightCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_STRONG_FIGHT);
local strongBaseCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_STRONG_BASE);
local strongLevelCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_STRONG_LEVEL);
local _sortfunc = table.sort 

function PromotePanel:New()
    self = { };
    setmetatable(self, { __index = PromotePanel });
    return self
end

function PromotePanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self:_InitData();
end


function PromotePanel:_InitReference()
    local leftPhalanx = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "left/trsList/phalanx");
    local rightPhalanx = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "right/trsList/phalanx");

    self._leftScrollView = UIUtil.GetChildByName(self._trsContent, "UIScrollView", "left/trsList");
    self._leftPhalanx = Phalanx:New();
    self._leftPhalanx:Init(leftPhalanx, PromoteLeftListItem);

    self._rightScrollView = UIUtil.GetChildByName(self._trsContent, "UIScrollView", "right/trsList");
    self._rightPhalanx = Phalanx:New();
    self._rightPhalanx:Init(rightPhalanx, PromoteRightListItem);

    local evaluate = UIUtil.GetChildByName(self._trsContent, "Transform", "evaluate");
    self._evaluate = EvaluateItem:New(evaluate);


    self._txtCurrent = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtCurrent");
    self._txtRecommend = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtRecommend");

    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
end

function PromotePanel:_InitListener()
    self._onClickCloseHandler = function(go) self:_OnClickCloseHandler(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickCloseHandler);
    MessageManager.AddListener(PromoteNotes, PromoteNotes.EVENT_CHOOSE_BRANCH, PromotePanel.OnChooseBranch, self);
    MessageManager.AddListener(PromoteNotes, PromoteNotes.EVENT_CALL_INTERFACE, PromotePanel.OnCallInterface, self);
    MessageManager.AddListener(PlayerManager, PlayerManager.SelfLevelChange, PromotePanel.OnPlayerLevelChange, self)
end

function PromotePanel:_InitData()
    self:OnPlayerLevelChange();
    local items = self._leftPhalanx:GetItems();
    if (items[1]) then
        items[1].itemLogic:SetSelected(true);
    end
    self._leftScrollView:ResetPosition();
end

-- 根据等级、战力获取strong_fight配置表对应的推荐战力、评价等级
function PromotePanel:_GetStrongFight(level, power)
    for i, v in pairs(strongFightCfg) do
        if (v and v.min_lev <= level and v.max_lev >= level) then
            for ii = 1, 6 do
                local tvs = string.splitToNum(v["appraise_" .. ii], "_");
                if (tvs[1] <= power and tvs[2] >= power) then
                    return v.rec_fighting, ii
                end
            end
        end
    end
    return nil;
end

-- 根据等级整合strong_base、strong_lev配置数据
function PromotePanel:_GetStrongData(level)
    local data = { };
    local index = 1;
    for i, v in pairs(strongBaseCfg) do
        if (v and v.type_lev <= level) then
            local typeid = v.type_id;
            local cIndex = self:_CheckStrongData(data, typeid);
            if (cIndex == -1) then
                cIndex = index;
                index = index + 1;
                data[cIndex] = { }
                data[cIndex].typeId = typeid
                data[cIndex].name = v.type_name
                data[cIndex].list = { };
            end
            if (v.kind_lev <= level) then
                local sIndex = table.getCount(data[cIndex].list) + 1;
                data[cIndex].list[sIndex] = { };
                data[cIndex].list[sIndex].base = v;
                data[cIndex].list[sIndex].level = self:_GetStrongLevelData(typeid, v.kind_id, level);
            end
        end
    end
    for i, v in pairs(data) do
        _sortfunc(v.list, function(a, b) return a.base.kind_id < b.base.kind_id end)
    end
    _sortfunc(data, function(a, b) return a.typeId < b.typeId end)
    return data;
end

function PromotePanel:_CheckStrongData(list, typeId)
    if (list) then
        for i, v in pairs(list) do
            if (v.typeId == typeId) then
                return i;
            end
        end
    end
    return -1
end

function PromotePanel:_GetStrongLevelData(typeId, kindId, level)
    local lv = math.ceil(level)
    for i, v in pairs(strongLevelCfg) do
        if (v and v.type_id == typeId and v.kind_id == kindId and level >= v.min_lev and level <= v.max_lev) then
            return v
        end
    end
    return nil;
end

function PromotePanel:OnPlayerLevelChange()
    local heroInfo = PlayerManager:GetPlayerInfo();
    if (heroInfo) then
        local power = PlayerManager.GetSelfFightPower();
        local sPower, evaluate = self:_GetStrongFight(heroInfo.level, power);
        self.data = self:_GetStrongData(heroInfo.level);
        if (sPower) then
            self._txtRecommend.text = sPower;
            self._evaluate:SetEvaluate(evaluate);
        end
        self._txtCurrent.text = PlayerManager.GetSelfFightPower();
        self._leftPhalanx:Build(#self.data, 1, self.data);
    end
end

function PromotePanel:OnChooseBranch(item)
    if (item) then
        local data = item.data;
        if (data) then
            local ls = data.list;
            self._rightPhalanx:Build(#ls, 1, ls);
        else
            self._rightPhalanx:Build(0, 1, { });
        end
        self._rightScrollView:ResetPosition();
        if (self._currBranch ~= nil) then
            self._currBranch:SetSelected(false)
        end
        self._currBranch = item
    end
end

function PromotePanel:OnCallInterface(id)
    ModuleManager.SendNotification(PromoteNotes.CLOSE_PROMOTE);

    if (id == 1) then
        ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_5);
    elseif (id == 2) then
        ModuleManager.SendNotification(RealmNotes.OPEN_REALM);
    elseif (id == 3) then
        ModuleManager.SendNotification(PetNotes.OPEN_PETPANEL, 2);
    elseif (id == 4) then
        ModuleManager.SendNotification(LingYaoNotes.OPEN_LINGYAOPANEL);
    elseif (id == 5) then
        ModuleManager.SendNotification(NewTrumpNotes.OPEN_NEWTRUMPPANEL);
    elseif (id == 6) then
        ModuleManager.SendNotification(RideNotes.OPEN_RIDEPANEL);
    elseif (id == 7) then
        ModuleManager.SendNotification(WingNotes.OPEN_WINGPANEL);
    elseif (id == 8) then
        ModuleManager.SendNotification(GuildNotes.OPEN_GUILDPANEL, 3);
    elseif (id == 9) then
        ModuleManager.SendNotification(GuildNotes.OPEN_GUILDPANEL, 4);
    elseif (id == 10) then
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_RICHANGFB });
    elseif (id == 11) then
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_RICHANGACTIVITY });
    elseif (id == 12) then
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_TIMEACTIVITY });
    elseif (id == 13) then
        ModuleManager.SendNotification(SkillNotes.OPEN_SKILLPANEL);
    elseif (id == 14) then
        --ModuleManager.SendNotification(MainUINotes.OPEN_MYROLEPANEL, { 4 });
        ModuleManager.SendNotification(FormationNotes.OPEN_FORMATION_PANEL)
    elseif (id == 15) then
        ModuleManager.SendNotification(StarNotes.OPEN_STAR_PANEL)

    elseif (id == 16) then
        ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_1);
    elseif (id == 17) then
        ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_4);
    elseif (id == 18) then
        ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_2);

    elseif (id == 19) then
        ModuleManager.SendNotification(WiseEquipPanelNotes.OPEN_WISEEQUIPPANEL, { tabIndex = 2, eqIndex = 1, selectEqInBag = nil });
    else
        log("-------OnCallInterface----------- " .. id);

    end
end



function PromotePanel:_OnClickCloseHandler()
    ModuleManager.SendNotification(PromoteNotes.CLOSE_PROMOTE)
end


function PromotePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function PromotePanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickCloseHandler = nil;
    MessageManager.RemoveListener(PromoteNotes, PromoteNotes.EVENT_CHOOSE_BRANCH, PromotePanel.OnChooseBranch, self);
    MessageManager.RemoveListener(PromoteNotes, PromoteNotes.EVENT_CALL_INTERFACE, PromotePanel.OnCallInterface, self);
    MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfLevelChange, PromotePanel.OnPlayerLevelChange, self)
end

function PromotePanel:_DisposeReference()
    self._btnClose = nil;
    self._leftPhalanx:Dispose();
    self._leftPhalanx = nil;
    self._leftScrollView = nil;

    self._rightPhalanx:Dispose();
    self._rightPhalanx = nil;
    self._rightScrollView = nil;

    self._txtCurrent = nil;
    self._txtRecommend = nil;

    self._currBranch = nil;

    self.data = nil;

    self._evaluate:Dispose();
    self._evaluate = nil;
end