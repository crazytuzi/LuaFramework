require "Core.Module.Common.UISubPanel";
require "Core.Module.Skill.View.Item.SkillTalentItem";
require "Core.Module.Skill.View.Item.SkillTalentDetailItem";
require "Core.Module.Skill.View.Item.SkillTalentRecommend";

SkillTalentPanel = class("SkillTalentPanel", UISubPanel);

function SkillTalentPanel:_InitReference()
    self._btnReset = UIUtil.GetChildByName(self._transform, "UIButton", "btnReset");
    self._btnTuijian = UIUtil.GetChildByName(self._transform, "UIButton", "btnTuijian");
    self._btnConfirm = UIUtil.GetChildByName(self._transform, "UIButton", "btnConfirm");

    self._btnTog1 = UIUtil.GetChildByName(self._transform, "UIButton", "trsToggle/btnTog1");
    self._btnTog2 = UIUtil.GetChildByName(self._transform, "UIButton", "trsToggle/btnTog2");
    self._txtPoint = UIUtil.GetChildByName(self._transform, "UILabel", "txtPoint");

    --self._toggles = {self._btnTog1, self._btnTog2};

    self._redPoint1 = UIUtil.GetChildByName(self._btnTog1, "UISprite", "redPoint");
    self._redPoint2 = UIUtil.GetChildByName(self._btnTog2, "UISprite", "redPoint");

    self._trsTalents = UIUtil.GetChildByName(self._transform, "Transform", "trsTalents");
    self._trsRecommend = UIUtil.GetChildByName(self._transform, "Transform", "trsRecommend");
    
    self._recPanel = SkillTalentRecommend.New();
    self._recPanel:Init(self._trsRecommend);

    self._trsRecommend.gameObject:SetActive(false);
    self._showRecomment = false;

    self._items = {};
    for i = 1,4 do
        local itemGo = UIUtil.GetChildByName(self._trsTalents, "Transform", "talentItem" .. i);
        local item = SkillTalentItem.New();
        item:Init(itemGo);
        item:SetIndex(i);
        self._items[i] = item;
    end
    
    self._trsTalentDetail = UIUtil.GetChildByName(self._transform, "Transform", "trsTalentDetail");
    self._details = {};
    for i = 1,3 do
        local detailGo = UIUtil.GetChildByName(self._trsTalentDetail, "Transform", "detail" .. i);
        local detail = SkillTalentDetailItem.New();
        detail:Init(detailGo);
        self._details[i] = detail;
    end


    self._onResetBtnClick = function(go) self:_OnResetBtnClick() end
    UIUtil.GetComponent(self._btnReset, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onResetBtnClick);
    self._onTuijianBtnClick = function(go) self:_OnTuijianBtnClick() end
    UIUtil.GetComponent(self._btnTuijian, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onTuijianBtnClick);
    self._onConfirmBtnClick = function(go) self:_OnConfirmBtnClick() end
    UIUtil.GetComponent(self._btnConfirm, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onConfirmBtnClick);
    
    self._onTogClick = function(go) self:_OnTogClick(go) end
    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onTogClick);
    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onTogClick);
end

function SkillTalentPanel:_InitListener()
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_TALENT_CHG, SkillTalentPanel.OnTalentChg, self);
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_TALENT_UPDATE, SkillTalentPanel.OnTalentPointUpdate, self);
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_TALENT_CLICK, SkillTalentPanel.OnTalentClick, self);
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_TALENT_DETAIL_CLICK, SkillTalentPanel.OnTalentDetailClick, self);
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_TALENT_POINT_CHG, SkillTalentPanel.OnTalentPointChg, self);
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_TALENT_REC_CLOSE, SkillTalentPanel.OnRecommendClose, self);
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_TALENT_REC_SELECT, SkillTalentPanel.OnRecommendSelect, self);
    MessageManager.AddListener(PlayerManager, PlayerManager.SelfLevelChange, SkillTalentPanel._UpdateTalentData, self);
end

function SkillTalentPanel:_DisposeReference()
    for k,v in pairs(self._items) do
        v:Dispose();
    end

    for k,v in pairs(self._details) do
        v:Dispose();
    end

    self._recPanel:Dispose();

    UIUtil.GetComponent(self._btnReset, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onResetBtnClick = nil;
    UIUtil.GetComponent(self._btnTuijian, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onTuijianBtnClick = nil;
    UIUtil.GetComponent(self._btnConfirm, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onConfirmBtnClick = nil;

    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onUpgradeButtonClick = nil;
end

function SkillTalentPanel:_DisposeListener()
     
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_TALENT_CHG, SkillTalentPanel.OnTalentChg);
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_TALENT_UPDATE, SkillTalentPanel.OnTalentPointUpdate);
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_TALENT_CLICK, SkillTalentPanel.OnTalentClick);
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_TALENT_DETAIL_CLICK, SkillTalentPanel.OnTalentDetailClick);
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_TALENT_POINT_CHG, SkillTalentPanel.OnTalentPointChg);
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_TALENT_REC_CLOSE, SkillTalentPanel.OnRecommendClose);
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_TALENT_REC_SELECT, SkillTalentPanel.OnRecommendSelect);
    MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfLevelChange, SkillTalentPanel._UpdateTalentData);
end

function SkillTalentPanel:_OnEnable()
    self:UpdateDisplay();
end

function SkillTalentPanel:UpdateDisplay()
    --self._tabIdx = 1;
    --self._talentIdx = 1;
    local myinfo = PlayerManager.GetPlayerInfo();
    self._myLv = myinfo.level;
    self._talentSlotCfg = ConfigManager.GetCareerByKind(myinfo.kind).talentLv;

    self:_OnTogClick();

    self:_UpdateRedPoint();
end

--更新天赋配置
function SkillTalentPanel:_UpdateTalent()
    
end

--更新4个天赋的数据
function SkillTalentPanel:_UpdateTalentData()
    local activeIdx = SkillManager.GetIdx();
    for i = 1, 4 do
        local d = self._data[i];
        self._items[i]:SetData(d.id, d.lv);
        self._items[i]:SetActStaus(self._tabIdx == activeIdx);
    end
    self:_UpdateDetailData();
end

--更新3个选择天赋配置
function SkillTalentPanel:_UpdateDetail()
    local ids = SkillManager.GetTalentIds(PlayerManager.GetPlayerInfo().kind, self._talentIdx);
    for i = 1, 3 do
        self._details[i]:SetData(ids[i]);
    end
    self:_UpdateDetailData();
end

--更新3个选择天赋数据.
function SkillTalentPanel:_UpdateDetailData()
    local lv = self._data[self._talentIdx].lv;
    for j = 1, 3 do
        self._details[j]:SetLv(lv);
    end
end

function SkillTalentPanel:_UpdatePoint()
    self._txtPoint.text = LanguageMgr.Get("skill/talent/point", {point = self._point});
end

function SkillTalentPanel:_OnResetBtnClick()
    self._data = SkillManager.GetEmptyTalentData();
    self._point = SkillManager.GetEmptyTalentPoint();
    self:_UpdateTalentData();
    self:_UpdatePoint();
end

function SkillTalentPanel:_OnTuijianBtnClick()
    if self._showRecomment then
        return;
    end
    self._trsRecommend.gameObject:SetActive(true);
    self._recPanel:Show();
    self._showRecomment = true;
end

function SkillTalentPanel:_OnConfirmBtnClick()
    SkillProxy.ReqSaveTalent(self._tabIdx, self._data);
    SequenceManager.TriggerEvent(SequenceEventType.Guide.SKILL_TALENT_CONFIRM);
end

--点击天赋页.
function SkillTalentPanel:_OnTogClick(go)
    local idx = go and (go.name == "btnTog1" and 1 or 2 ) or 1;
    if idx ~= self._tabIdx then
        self._tabIdx = idx;
        
        self._data = SkillManager.GetTalentData(idx);
        self._point = SkillManager.GetIdxPoint(idx);
        
        self:OnTalentClick(1);
        self:_UpdateTalentData();
        self:_UpdatePoint();
    end

    --[[
    for i, v in ipairs(self._toggles) do
        self:SetBtnToggleActive(v, i == idx);
    end
    ]]
end

--点击天赋树.
function SkillTalentPanel:OnTalentClick(idx)
    if self._talentIdx ~= idx then
        self._talentIdx = idx;
        self:_UpdateDetail();
    end
end
--[[
function SkillTalentPanel:SetBtnToggleActive(btn, bool)
    local toggle = UIUtil.GetComponent(btn, "UIToggle");
    toggle:Set(bool);
end
]]
--选择天赋内容.
function SkillTalentPanel:OnTalentDetailClick(talentId)

    local d = self._data[self._talentIdx];
    local updatePoint = false;

    if d.id <= 0 then
        --天赋点不足,不允许选天赋.
        if self._point <= 0 then
            MsgUtils.ShowTips("skill/talent/noPoint");
            return;
        end

        --天赋层等级判定未开启.
        local tCfg = SkillManager.GetTalentCfg(talentId);
        local needLv = self._talentSlotCfg[tCfg.phase];
        if self._myLv < needLv then
            return;
        end

        --新选天赋, 天赋点扣除1点.
        self._point = self._point - 1;
        updatePoint = true;
        d.lv = 1;
    end

    d.id = talentId;
    self:_UpdateTalentData();

    if updatePoint then
        self:_UpdatePoint();
    end
    SequenceManager.TriggerEvent(SequenceEventType.Guide.SKILL_TALENT_SKILL_CHANGE);
end

function SkillTalentPanel:OnTalentPointChg(data)
    --log("set " .. data.idx .. " - " .. data.num);
    local idx = data.idx
    local val = data.num;
    local d = self._data[idx];
    self:OnTalentClick(idx);
    if val > 0 then
        --判断剩余点数和目前等级
        if self._point < 1  then return; end
        if d.lv >= 30 then
            MsgUtils.ShowTips("skill/talent/max");
            return;
        end
    else
        --判断剩余等级
        if d.lv < 2 then
            return;
        end 
    end
    
    d.lv = d.lv + val;
    self._point = self._point - val;

    self:_UpdateTalentData();
    self:_UpdatePoint();    
end

function SkillTalentPanel:OnRecommendClose()
    self._trsRecommend.gameObject:SetActive(false);
    self._showRecomment = false;
end

function SkillTalentPanel:OnRecommendSelect(recId)
    --更新数值.
    self:OnRecommendClose();
    local tmp = SkillManager.GetTalentCommend(recId);
    self._point = tmp.p;
    self._data = tmp.d;

    self:_UpdateTalentData();
    self:_UpdatePoint();
end

--proxy 
function SkillTalentPanel:OnTalentChg()
    self:_UpdateRedPoint();
end

function SkillTalentPanel:OnTalentPointUpdate()
    self._point = SkillManager.GetIdxPoint(self._tabIdx);
    self:_UpdatePoint();
end

function SkillTalentPanel:_UpdateRedPoint()
    local p = SkillManager.talent.point;
    local r1 = 0;
    local r2 = 0;

    local tmp = 0;
    for i, v in ipairs(SkillManager.talent.t1) do
        if v.id > 0 then
            tmp = tmp + v.lv;
        end
    end
    r1 = p > tmp and 1 or 0;

    tmp = 0;
    for i, v in ipairs(SkillManager.talent.t2) do
        if v.id > 0 then
            tmp = tmp + v.lv;
        end
    end
    r2 = p > tmp and 1 or 0;

    self._redPoint1.alpha = r1;
    self._redPoint2.alpha = r2;
end