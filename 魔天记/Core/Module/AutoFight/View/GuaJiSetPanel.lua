require "Core.Module.Common.UIComponent"

require "Core.Module.AutoFight.ctr.GuajiSetProCtr"
require "Core.Module.AutoFight.ctr.GuajiSetSelectEqCtr"

GuaJiSetPanel = class("GuaJiSetPanel", UIComponent);
function GuaJiSetPanel:New()
    self = { };
    setmetatable(self, { __index = GuaJiSetPanel });
    return self
end


function GuaJiSetPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function GuaJiSetPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._transform, "UILabel");
    self._txtRestoreHP = UIUtil.GetChildInComponents(txts, "txtRestoreHP");
    self._txtRestoreMP = UIUtil.GetChildInComponents(txts, "txtRestoreMP");
    --  self._btnRecommend = UIUtil.GetChildByName(self._transform, "UIButton", "rightPanel/btnRecommend");


    local sliders = UIUtil.GetComponentsInChildren(self._transform, "UISlider");
    self._sliRestoreHP = UIUtil.GetChildInComponents(sliders, "restoreHP");
    self._sliRestoreMP = UIUtil.GetChildInComponents(sliders, "restoreMP");
    self._sliRestoreHP_content = UIUtil.GetChildByName(self._sliRestoreHP, "UISprite", "content");
    self._sliRestoreMP_content = UIUtil.GetChildByName(self._sliRestoreMP, "UISprite", "content");


    local proPanel1 = UIUtil.GetChildByName(self._transform, "Transform", "leftPanel/proPanel1");
    local proPanel2 = UIUtil.GetChildByName(self._transform, "Transform", "leftPanel/proPanel2");

    local eqpanel = UIUtil.GetChildByName(self._transform, "Transform", "rightPanel/eqpanel");

    self.txtOffLine = UIUtil.GetChildInComponents(txts, "txtOffLine");
    self.btnOffLine = UIUtil.GetChildByName(self._transform, "UIButton", "btnOffLine");
    self:UpdateOffLineTime();


    self._guajiSetProCtr1 = GuajiSetProCtr:New();
    self._guajiSetProCtr2 = GuajiSetProCtr:New();

    self._guajiSetProCtr1:Init(proPanel1, 1);
    self._guajiSetProCtr2:Init(proPanel2, 2);

    self._selectEqCtr = GuajiSetSelectEqCtr:New();
    self._selectEqCtr:Init(eqpanel);

    local togs = UIUtil.GetComponentsInChildren(self._transform, "UIToggle");

    self.checkEq1 = UIUtil.GetChildInComponents(togs, "checkEq1");
    self.checkEq2 = UIUtil.GetChildInComponents(togs, "checkEq2");
    self.checkEq3 = UIUtil.GetChildInComponents(togs, "checkEq3");
    self.checkEq4 = UIUtil.GetChildInComponents(togs, "checkEq4");

    self._onClickCheckEq1 = function(go) self:_OnClickCheckEq1(self) end
    UIUtil.GetComponent(self.checkEq1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickCheckEq1);

    self._onClickCheckEq2 = function(go) self:_OnClickCheckEq2(self) end
    UIUtil.GetComponent(self.checkEq2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickCheckEq2);

    self._onClickCheckEq3 = function(go) self:_OnClickCheckEq3(self) end
    UIUtil.GetComponent(self.checkEq3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickCheckEq3);

    self._onClickCheckEq4 = function(go) self:_OnClickCheckEq4(self) end
    UIUtil.GetComponent(self.checkEq4, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickCheckEq4);


    -- local chbs = UIUtil.GetComponentsInChildren(self._transform, "UIToggle");
    -- self._btnPointArea = UIUtil.GetChildInComponents(chbs, "btnPointArea");
    -- self._btnAllArea = UIUtil.GetChildInComponents(chbs, "btnAllArea");
    --  self._btnReliveProps = UIUtil.GetChildInComponents(chbs, "btnReliveProps");
    -- self._btnAwayBoss = UIUtil.GetChildInComponents(chbs, "btnAwayBoss");
    -- self._btnRevenge = UIUtil.GetChildInComponents(chbs, "btnRevenge");
    -- self._btnCastMinorSkill = UIUtil.GetChildInComponents(chbs, "btnCastMinorSkill");

    --[[
    self._onSelectedDefSkills = function(skills)
        self:_OnSelectedDefSkills(skills);
    end

    self._onSelectedSkill = function(skill)
        self:_OnSelectedSkill(skill);
    end

    local defSkillPanel = UIUtil.GetChildByName(self._transform, "defSkillPanel");
    self._defSkillPanel = DefSkillPanel:New();
    self._defSkillPanel:Init(defSkillPanel);
    self._defSkillPanel:AddChangeListener(self._onSelectedDefSkills);

    local selSkillPanel = UIUtil.GetChildByName(self._transform, "selSkillPanel");
    self._selSkillPanel = SelSkillPanel:New();
    self._selSkillPanel:Init(selSkillPanel);
    self._selSkillPanel:AddSelectedListener(self._onSelectedSkill);

    self._skillBtns = { };
    self._onSkillButonClick = function(go)
        self:_SelectSkillButton(go)
    end

    local btnSkill1_go = UIUtil.GetChildByName(rightPanel.gameObject, "Transform", "btnSkill1");
    local btnSkill1 = SelSkillButton:New(1);
    btnSkill1:Init(btnSkill1_go);
    btnSkill1:AddClickListener(self._onSkillButonClick);
    self._skillBtns[1] = btnSkill1;

    local btnSkill2_go = UIUtil.GetChildByName(rightPanel.gameObject, "Transform", "btnSkill2");
    local btnSkill2 = SelSkillButton:New(2);
    btnSkill2:Init(btnSkill2_go);
    btnSkill2:AddClickListener(self._onSkillButonClick);
    self._skillBtns[2] = btnSkill2;

    local btnSkill3_go = UIUtil.GetChildByName(rightPanel.gameObject, "Transform", "btnSkill3");
    local btnSkill3 = SelSkillButton:New(3);
    btnSkill3:Init(btnSkill3_go);
    btnSkill3:AddClickListener(self._onSkillButonClick);
    self._skillBtns[3] = btnSkill3;

    local btnSkill4_go = UIUtil.GetChildByName(rightPanel.gameObject, "Transform", "btnSkill4");
    local btnSkill4 = SelSkillButton:New(4);
    btnSkill4:Init(btnSkill4_go);
    btnSkill4:AddClickListener(self._onSkillButonClick);
    self._skillBtns[4] = btnSkill4;
    ]]

    local hp_v = math.round(AutoFightManager.restoreHP * 100);
    local mp_v = math.round(AutoFightManager.restoreMP * 100);

    self._sliRestoreHP.value = AutoFightManager.restoreHP;
    self._txtRestoreHP.text = LanguageMgr.Get("AutoFight/AutoFightPanel/hpLabel", { t = hp_v });

    self._sliRestoreMP.value = AutoFightManager.restoreMP;
    self._txtRestoreMP.text = LanguageMgr.Get("AutoFight/AutoFightPanel/mpLabel", { t = mp_v });

    -- self._btnPointArea.value = not AutoFightManager.attackAllArea;
    -- self._btnAllArea.value = AutoFightManager.attackAllArea;
    -- self._btnReliveProps.value = AutoFightManager.reliveProps;
    -- self._btnAwayBoss.value = AutoFightManager.awayBoss;
    -- self._btnRevenge.value = AutoFightManager.revenge;
    --  self._btnCastMinorSkill.value = AutoFightManager.castMinorSkill;

    --[[
    btnSkill1:SetSkill(PlayerManager.hero.info:GetSkill(AutoFightManager.skills[1]));
    btnSkill2:SetSkill(PlayerManager.hero.info:GetSkill(AutoFightManager.skills[2]));
    btnSkill3:SetSkill(PlayerManager.hero.info:GetSkill(AutoFightManager.skills[3]));
    btnSkill4:SetSkill(PlayerManager.hero.info:GetSkill(AutoFightManager.skills[4]));
    ]]

    MessageManager.AddListener(AutoUseDrugItem, AutoUseDrugItem.MESSAGE_PRODUCTS_SELECTED_CHANGE, GuaJiSetPanel.ProductSelectChange, self);
    MessageManager.AddListener(GuajiSetEqCtr, GuajiSetEqCtr.MESSAGE_GJEQ_SELECTED_CHANGE, GuaJiSetPanel.EqProductSelectChange, self);



    local data = { };

    if AutoFightManager.use_Drug_HP_id ~= nil then
        data.id = AutoFightManager.use_Drug_HP_id;
        data.has_num = BackpackDataManager.GetProductTotalNumBySpid(data.id);
        local pro_obj = ProductManager.GetProductInfoById(data.id, data.has_num);
        self._guajiSetProCtr1:SetProduct(pro_obj);

    else
        self._guajiSetProCtr1:SetProduct(nil);
    end

    if AutoFightManager.use_Drug_MP_id ~= nil then
        data.id = AutoFightManager.use_Drug_MP_id;
        data.has_num = BackpackDataManager.GetProductTotalNumBySpid(data.id);
        local pro_obj = ProductManager.GetProductInfoById(data.id, data.has_num);
        self._guajiSetProCtr2:SetProduct(pro_obj)

    else
        self._guajiSetProCtr2:SetProduct(nil);

    end

    if AutoFightManager.strengthen_eq_kind ~= nil then

        self.equip_lv_data = EquipLvDataManager.getItem(AutoFightManager.strengthen_eq_kind);
        self.slv = self.equip_lv_data["slv"];


        local productInfo = EquipDataManager.GetProductByIdx(self.equip_lv_data.idx - 1);
        if productInfo ~= nil then
            productInfo.slv = self.slv;
        end

        self:EqProductSelectChange(productInfo);

        else

        self._selectEqCtr:SetProduct(nil);

    end

end

function GuaJiSetPanel:EqProductSelectChange(info)

    self._selectEqCtr:SetProduct(info);

    if info ~= nil then
        local kind = info:GetKind();
        AutoFightManager.strengthen_eq_kind = kind;
    end

end

function GuaJiSetPanel:OnClickOffLine()
    MessageProxy.AddOffLineTIme();
end

local FormatTime = function(min)
    if min > 60 then
        local h = math.floor(min / 60);
        local m = math.floor(min - (h * 60));
        return LanguageMgr.Get("time/hhmm", {h = h, m = m});

    end
    return LanguageMgr.Get("time/mm", {m = min});
end

function GuaJiSetPanel:UpdateOffLineTime()
    self.txtOffLine.text = LanguageMgr.Get("offline/activity/time", { time = FormatTime(PlayerManager.OffLineData.time) });
end

function GuaJiSetPanel:_InitListener()

    --[[
    self._onClickBtnRecommend = function(go) self:_OnClickBtnRecommend(self) end
    UIUtil.GetComponent(self._btnRecommend, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRecommend);
    ]]

    --[[
    self._onClickBtnPointArea = function(go) self:_OnClickBtnPointArea(self) end
    UIUtil.GetComponent(self._btnPointArea, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnPointArea);

    self._onClickBtnAllArea = function(go) self:_OnClickBtnAllArea(self) end
    UIUtil.GetComponent(self._btnAllArea, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAllArea);


    self._onClickBtnReliveProps = function(go) self:_OnClickBtnReliveProps(self) end
    UIUtil.GetComponent(self._btnReliveProps, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReliveProps);


    self._onClickBtnAwayBoss = function(go) self:_OnClickBtnAwayBoss(self) end
    UIUtil.GetComponent(self._btnAwayBoss, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAwayBoss);


    self._onClickBtnRevenge = function(go) self:_OnClickBtnRevenge(self) end
    UIUtil.GetComponent(self._btnRevenge, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRevenge);


    self._onClickBtnCastMinorSkill = function(go) self:_OnClickBtnCastMinorSkill(self) end
    UIUtil.GetComponent(self._btnCastMinorSkill, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCastMinorSkill);
    ]]

    self._timer = Timer.New( function(val) self:_OnTimerHandler(val) end, 0, -1, false);
    self._timer:Start();


    self.slider_w = 270;--290;

    self._sliRestoreHP_content.width = self.slider_w * AutoFightManager.restoreHP;
    self._sliRestoreMP_content.width = self.slider_w * AutoFightManager.restoreMP;

    self.checkEq1.value = AutoFightManager.strengthen_eq_quality1;
    self.checkEq2.value = AutoFightManager.strengthen_eq_quality2;
    self.checkEq3.value = AutoFightManager.strengthen_eq_quality3;
    self.checkEq4.value = AutoFightManager.strengthen_eq_quality4;

    self._onClickBtnOffLine = function(go) self:OnClickOffLine(self) end
    UIUtil.GetComponent(self.btnOffLine, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnOffLine);
    MessageManager.AddListener(PlayerManager, PlayerManager.OffLineChg, GuaJiSetPanel.UpdateOffLineTime, self);
    --  test
   -- BackpackDataManager.CheckAndStrengthen();


end 

function GuaJiSetPanel:_OnClickCheckEq1()
    AutoFightManager.strengthen_eq_quality1 = self.checkEq1.value;
    SequenceManager.TriggerEvent(SequenceEventType.Guide.AUTO_STRENGTH_QUALITY);
end

function GuaJiSetPanel:_OnClickCheckEq2()
    AutoFightManager.strengthen_eq_quality2 = self.checkEq2.value;
    SequenceManager.TriggerEvent(SequenceEventType.Guide.AUTO_STRENGTH_QUALITY);
end

function GuaJiSetPanel:_OnClickCheckEq3()
    AutoFightManager.strengthen_eq_quality3 = self.checkEq3.value;
    SequenceManager.TriggerEvent(SequenceEventType.Guide.AUTO_STRENGTH_QUALITY);
end

function GuaJiSetPanel:_OnClickCheckEq4()
    AutoFightManager.strengthen_eq_quality4 = self.checkEq4.value;
    SequenceManager.TriggerEvent(SequenceEventType.Guide.AUTO_STRENGTH_QUALITY);
end

function GuaJiSetPanel:ProductSelectChange(data)


    self.pro_obj = ProductManager.GetProductInfoById(data.id, data.has_num);

    if data.name == 1 then

        self._guajiSetProCtr1:SetProduct(self.pro_obj)
        AutoFightManager.use_Drug_HP_id = self.pro_obj.id;

    elseif data.name == 2 then

        self._guajiSetProCtr2:SetProduct(self.pro_obj)
        AutoFightManager.use_Drug_MP_id = self.pro_obj.id;

    end


end

function GuaJiSetPanel:_OnTimerHandler()
    if (AutoFightManager.restoreHP ~= self._sliRestoreHP.value) then
        AutoFightManager.restoreHP = self._sliRestoreHP.value;

        local pv = math.round(AutoFightManager.restoreHP * 100);
        self._txtRestoreHP.text = LanguageMgr.Get("AutoFight/AutoFightPanel/hpLabel", { t = pv });

        -- 更新长度
        self._sliRestoreHP_content.width = self.slider_w *(pv / 100);
        self._isChangled = true;
    end
    if (AutoFightManager.restoreMP ~= self._sliRestoreMP.value) then
        AutoFightManager.restoreMP = self._sliRestoreMP.value;

        local pv = math.round(AutoFightManager.restoreMP * 100);

        self._txtRestoreMP.text = LanguageMgr.Get("AutoFight/AutoFightPanel/mpLabel", { t = pv });

        self._sliRestoreMP_content.width = self.slider_w *(pv / 100);
        self._isChangled = true;
    end
end

function GuaJiSetPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function GuaJiSetPanel:_DisposeListener()

    --[[
    UIUtil.GetComponent(self._btnRecommend, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnRecommend = nil;
    ]]

    --[[
    UIUtil.GetComponent(self._btnPointArea, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnPointArea = nil;


    UIUtil.GetComponent(self._btnAllArea, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAllArea = nil;


    UIUtil.GetComponent(self._btnReliveProps, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnReliveProps = nil;


    UIUtil.GetComponent(self._btnAwayBoss, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAwayBoss = nil;


    UIUtil.GetComponent(self._btnRevenge, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnRevenge = nil;


    UIUtil.GetComponent(self._btnCastMinorSkill, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnCastMinorSkill = nil;

    ]]

    --[[
    for i = 1, 4 do
        self._skillBtns[i]:Dispose()
    end
    self._skillBtns = nil
    ]]

    if (self._timer) then
        self._timer:Stop();
    end
end

function GuaJiSetPanel:_DisposeReference()
    --  self._btnRecommend = nil;
    -- self._btnPointArea = nil;

    -- self._btnAllArea = nil;
    -- self._btnReliveProps = nil;
    --  self._btnAwayBoss = nil;
    -- self._onClickBtnRevenge = nil;
    --  self._onClickBtnCastMinorSkill = nil;
end


function GuaJiSetPanel:_OnClickBtnAutoFight()
    --  AutoFightManager.Save();
    PlayerManager.hero:StartAutoFight(AutoFightManager);
    ModuleManager.SendNotification(AutoFightNotes.CLOSE_AUTOFIGHTPANEL);
end

--[[
function GuaJiSetPanel:_OnClickBtnRecommend()
    self._defSkillPanel:SetActive(true);
end
]]

--[[
function GuaJiSetPanel:_OnClickBtnPointArea()

    AutoFightManager.attackAllArea = self._btnAllArea.value;
    self._isChangled = true;
end


function GuaJiSetPanel:_OnClickBtnAllArea()
    AutoFightManager.attackAllArea = self._btnAllArea.value;
    self._isChangled = true;
end


function GuaJiSetPanel:_OnClickBtnReliveProps()
    AutoFightManager.reliveProps = self._btnReliveProps.value;
    self._isChangled = true;
end


function GuaJiSetPanel:_OnClickBtnAwayBoss()
    AutoFightManager.awayBoss = self._btnAwayBoss.value;
    self._isChangled = true;
end


function GuaJiSetPanel:_OnClickBtnRevenge()
    AutoFightManager.revenge = self._btnRevenge.value;
    self._isChangled = true;
end


function GuaJiSetPanel:_OnClickBtnCastMinorSkill()
    AutoFightManager.castMinorSkill = self._btnCastMinorSkill.value;
    self._isChangled = true;
end

]]

function GuaJiSetPanel:_Dispose()
    if (self._isChangled) then
        --  AutoFightManager.Save();
    end
    -- self._defSkillPanel:Dispose()
    -- self._selSkillPanel:Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

    self._guajiSetProCtr1:Dispose();
    self._guajiSetProCtr2:Dispose();

    self._selectEqCtr:Dispose()


    UIUtil.GetComponent(self.checkEq1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.checkEq2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.checkEq3, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.checkEq4, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self._onClickCheckEq1 = nil;
    self._onClickCheckEq2 = nil;
    self._onClickCheckEq3 = nil;
    self._onClickCheckEq4 = nil;

    MessageManager.RemoveListener(AutoUseDrugItem, AutoUseDrugItem.MESSAGE_PRODUCTS_SELECTED_CHANGE, GuaJiSetPanel.ProductSelectChange);
    MessageManager.RemoveListener(GuajiSetEqCtr, GuajiSetEqCtr.MESSAGE_GJEQ_SELECTED_CHANGE, GuaJiSetPanel.EqProductSelectChange);

    UIUtil.GetComponent(self.btnOffLine, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnOffLine = nil;
    MessageManager.RemoveListener(PlayerManager, PlayerManager.OffLineChg, GuaJiSetPanel.UpdateOffLineTime);

    --  保存  设置数据


end

--[[
function GuaJiSetPanel:_OnSelectedDefSkills(skills)
    if (skills) then
        for i, v in pairs(skills) do
            AutoFightManager.skills[i] = v;
            self._skillBtns[i]:SetSkill(PlayerManager.hero.info:GetSkill(v));
        end
        self._isChangled = true;
    end
end

function GuaJiSetPanel:_OnSelectedSkill(skill)
    if (self._selSkillBtn) then
        if (skill) then
            AutoFightManager.skills[self._selSkillBtn.index] = skill.id;
            self._selSkillBtn:SetSkill(skill);
        end
        self._selSkillBtn:Select(false);
        self._isChangled = true;
    end
end
]]

--[[
function GuaJiSetPanel:_SelectSkillButton(go)
    if (go) then
        self._selSkillBtn = go;
        self._selSkillBtn:Select(true);
        self._selSkillPanel:SetActive(true);
    end
end
]]