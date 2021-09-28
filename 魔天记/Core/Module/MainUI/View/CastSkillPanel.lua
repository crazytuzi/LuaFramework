require "Core.Module.Common.UIComponent"
require "Core.Module.MainUI.View.Item.SkillButton"
require "Core.Module.MainUI.View.Item.MountReSetButton"
require "Core.Info.SkillInfo";
require "Core.Scene.SceneSelecter"

CastSkillPanel = class("CastSkillPanel", UIComponent)
local _enable = true
function CastSkillPanel:New()
    self = { };
    setmetatable(self, { __index = CastSkillPanel });
    return self;
end

function CastSkillPanel:_Init()
    _enable = true
    -- local heroInfo = HeroController.GetInstance().info;
    local trsContent = UIUtil.GetChildByName(self._gameObject, "Transform", "trsContent");
    self._trsContent = trsContent;
    local btnAttack = UIUtil.GetChildByName(trsContent.gameObject, "Transform", "btnAttack");
    local btnSkill1 = UIUtil.GetChildByName(trsContent.gameObject, "Transform", "btnSkill1");
    local btnSkill2 = UIUtil.GetChildByName(trsContent.gameObject, "Transform", "btnSkill2");
    local btnSkill3 = UIUtil.GetChildByName(trsContent.gameObject, "Transform", "btnSkill3");
    local btnSkill4 = UIUtil.GetChildByName(trsContent.gameObject, "Transform", "btnSkill4");
    local btnSkill5 = UIUtil.GetChildByName(trsContent.gameObject, "Transform", "btnSkill5");


    ItemMoveManager.Bind(btnSkill1, ItemMoveManager.bind_name.skill1)
    ItemMoveManager.Bind(btnSkill2, ItemMoveManager.bind_name.skill2)
    ItemMoveManager.Bind(btnSkill3, ItemMoveManager.bind_name.skill3)
    ItemMoveManager.Bind(btnSkill4, ItemMoveManager.bind_name.skill4)

    local btnMountOut = UIUtil.GetChildByName(trsContent.gameObject, "Transform", "btnMountOut");

    self._iconToggle = UIUtil.GetChildByName(self._gameObject, "UISprite", "iconToggle");
    self._onToggle = function(go) self:Toggle() end
    UIUtil.GetComponent(self._iconToggle, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onToggle);
    self.mode = MainUIPanel.Mode.SHOW;

    self.btnAttack = SkillButton:New();
    self.btnAttack:Init(btnAttack, false);
    -- self.btnAttack:SetSkill(heroInfo:GetBaseSkill());
    self.btnAttack:AddPressListener(self._OnSkillButtonPress);

    self.btnSkill1 = SkillButton:New();
    self.btnSkill1:Init(btnSkill1);
    -- self.btnSkill1:SetSkill(heroInfo:GetSkillByIndex(1));
    self.btnSkill1:AddPressListener(self._OnSkillButtonPress);

    self.btnSkill2 = SkillButton:New();
    self.btnSkill2:Init(btnSkill2);
    -- self.btnSkill2:SetSkill(heroInfo:GetSkillByIndex(2));
    self.btnSkill2:AddPressListener(self._OnSkillButtonPress);

    self.btnSkill3 = SkillButton:New();
    self.btnSkill3:Init(btnSkill3);
    -- self.btnSkill3:SetSkill(heroInfo:GetSkillByIndex(3));
    self.btnSkill3:AddPressListener(self._OnSkillButtonPress);

    self.btnSkill4 = SkillButton:New();
    self.btnSkill4:Init(btnSkill4);
    -- self.btnSkill4:SetSkill(heroInfo:GetSkillByIndex(4));
    self.btnSkill4:AddPressListener(self._OnSkillButtonPress);

    self.btnSkill5 = SkillButton:New();
    self.btnSkill5:Init(btnSkill5);
    -- self.btnSkill4:SetSkill(heroInfo:GetSkillByIndex(4));
    self.btnSkill5:AddPressListener(self._OnSkillButtonPress);

    self.btnMountOut = MountReSetButton:New();
    self.btnMountOut:Init(btnMountOut);
    self.btnMountOut:AddClickListener(self._OutMountButonClick);
    self.btnMountOut:SetActive(false)

    MessageManager.AddListener(HeroController, HeroController.MESSAGE_ON_MOUNTLANG, CastSkillPanel.OnMountLang, self);
    MessageManager.AddListener(HeroController, HeroController.MESSAGE_OUT_MOUNTLANG, CastSkillPanel.OutMountLang, self);
    MessageManager.AddListener(PlayerManager, PlayerManager.SelfSkillChange, CastSkillPanel.OnSkillChange, self);
    MessageManager.AddListener(PlayerManager, PlayerManager.SelfLevelChange, CastSkillPanel.OnPlayerChange, self);
    MessageManager.AddListener(NewTrumpManager, NewTrumpManager.SelfTrumpFollow, CastSkillPanel.UpTrumpSkill, self);
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_SKILL_CHG, CastSkillPanel.UpSkills, self);
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_SKILL_SLOT_OPEN, CastSkillPanel.OnSkillSlotOpen, self);
    MessageManager.AddListener(SendSkillAction, SendSkillAction.CastSkill, CastSkillPanel.OnCastSkill, self);

    self:UpSkills();
    self:UpTrumpSkill()
    -- self:_InitListenerkeyboard();
end

function CastSkillPanel:_InitListenerkeyboard()
    self._listenerKeyboardTimer = Timer.New( function(val) self:_OnListenerKeyboardTimer(val) end, 0, -1, false);
    self._listenerKeyboardTimer:Start()
end

function CastSkillPanel:_OnListenerKeyboardTimer()
    if (Input.GetKeyDown(KeyCode.Keypad0) or Input.GetKeyDown(KeyCode.Alpha0)) then
        self.btnAttack:OnPress(true);
    elseif (Input.GetKeyUp(KeyCode.Keypad0) or Input.GetKeyUp(KeyCode.Alpha0)) then
        self.btnAttack:OnPress(false);

    elseif (Input.GetKeyDown(KeyCode.Keypad1) or Input.GetKeyDown(KeyCode.Alpha1)) then
        self.btnSkill1:OnPress(true);
    elseif (Input.GetKeyUp(KeyCode.Keypad1) or Input.GetKeyUp(KeyCode.Alpha1)) then
        self.btnSkill1:OnPress(false);

    elseif (Input.GetKeyDown(KeyCode.Keypad2) or Input.GetKeyDown(KeyCode.Alpha2)) then
        self.btnSkill2:OnPress(true);
    elseif (Input.GetKeyUp(KeyCode.Keypad2) or Input.GetKeyUp(KeyCode.Alpha2)) then
        self.btnSkill2:OnPress(false);

    elseif (Input.GetKeyDown(KeyCode.Keypad3) or Input.GetKeyDown(KeyCode.Alpha3)) then
        self.btnSkill3:OnPress(true);
    elseif (Input.GetKeyUp(KeyCode.Keypad3) or Input.GetKeyUp(KeyCode.Alpha3)) then
        self.btnSkill3:OnPress(false);

    elseif (Input.GetKeyDown(KeyCode.Keypad4) or Input.GetKeyDown(KeyCode.Alpha4)) then
        self.btnSkill4:OnPress(true);
    elseif (Input.GetKeyUp(KeyCode.Keypad4) or Input.GetKeyUp(KeyCode.Alpha4)) then
        self.btnSkill4:OnPress(false);
    end
end

function CastSkillPanel:UpSkills()
    local hero = HeroController.GetInstance();
    if (not hero:IsOnLMount()) then
        self:_RefreshSkillByInfo(hero.info);
    end
end

function CastSkillPanel:UpMountSkills()
    self:_RefreshSkillByInfo(HeroController.GetInstance()._mountLangController.info);
end


function CastSkillPanel:UpTrumpSkill()
    if (HeroController.GetInstance():IsOnLMount()) then
        self.btnSkill5:SetSkill(nil)
        self.btnSkill5:SetActive(false)
    else
        local heroInfo = PlayerManager.GetPlayerInfo()
        local skill = heroInfo:GetTrumpSkill()
        self.btnSkill5:SetSkill(skill)
        if (skill) then
            self.btnSkill5:SetActive(true)
        else
            self.btnSkill5:SetActive(false)
        end
    end
end


--  lmount_time  战斗载具的 存在时间
function CastSkillPanel:OnMountLang(lmount_time)
    self:UpMountSkills();
    local hide = HeroController.GetInstance().currMountInfo.hideBtn;
    self.btnMountOut:SetElseTime(lmount_time);
    if not hide then
        self.btnMountOut:SetActive(true);
    end
end


function CastSkillPanel:OutMountLang()
    local hero = HeroController.GetInstance();
    if (not hero:IsOnLMount()) then
        self:_RefreshSkillByInfo(hero.info);
    end
    self.btnMountOut:SetActive(false)
end



function CastSkillPanel:OnSkillChange()
    local hero = HeroController.GetInstance();
    if (not hero:IsOnLMount()) then
        self:_RefreshSkillByInfo(hero.info);
    end
end

function CastSkillPanel:OnPlayerChange()
    local hero = HeroController.GetInstance();
    if (not hero:IsOnLMount()) then
        self:_RefreshSkillByInfo(hero.info);
    end
end

function CastSkillPanel:_RefreshSkillByInfo(heroInfo)
    local level = HeroController.GetInstance().info.level;
    self.btnAttack:SetSkill(heroInfo:GetBaseSkill());
    --[[    local skill1 = heroInfo:GetSkillByIndex(1);
    if (skill1) then
        self.btnSkill1:SetSkill(skill1);
    else
        self.btnSkill1:SetSkill(nil);
    end

    local skill2 = heroInfo:GetSkillByIndex(2);
    if (skill2) then
        self.btnSkill2:SetSkill(skill2);
    else
        self.btnSkill2:SetSkill(nil);
    end

    local skill3 = heroInfo:GetSkillByIndex(3);
    if (skill3) then
        self.btnSkill3:SetSkill(skill3);
    else
        self.btnSkill3:SetSkill(nil);
    end

    local skill4 = heroInfo:GetSkillByIndex(4);
    if (skill4) then
        self.btnSkill4:SetSkill(skill4);
    else
        self.btnSkill4:SetSkill(nil);
    end
    ]]
    for i = 1, 4 do
        self["btnSkill" .. i]:SetSkillIndex(i);
    end
end

function CastSkillPanel._OnSkillButtonPress(isPress, skill)
    local hero = HeroController.GetInstance();
    if (hero) then
        if (_enable) then
            if (isPress) then
                if skill then
                    BusyLoadingPanel.CheckAndStopLoadingPanel();
                    local isEnable = hero:SetAutoFightSkill(skill)

                    if (not isEnable) then
                        hero:CastSkill(skill, true)
                    end
                    SequenceManager.TriggerEvent(SequenceEventType.Base.MANUALLY_SKILL, skill.id);
                end
            else
                if (skill and skill.skill_type == 1) then
                    hero:SetAutoFightSkill(nil);
                end
                hero:StopAttack();
            end
        else
            -- hero:SetAutoFightSkill(nil)
            hero:StopAttack();
        end
    end
end


--[[function CastSkillPanel._OnAttackButtonPress(isPress)
    if (_enable) then
        local hero = HeroController.GetInstance();
        if (hero) then
            hero:Attack(isPress, true)
            SequenceManager.TriggerEvent(SequenceEventType.Base.MANUALLY_SKILL, 0);
        end
    end
end

function CastSkillPanel._OnSkillButonClick(skill)
    if (_enable) then
        local hero = HeroController.GetInstance();
        if (hero) then
            hero:CastSkill(skill, true)
            SequenceManager.TriggerEvent(SequenceEventType.Base.MANUALLY_SKILL, skill.id);
        end
    end
end
]]
function CastSkillPanel._OutMountButonClick()
    --  下 载具
    HeroController.GetInstance():StopMountLang();
end

function CastSkillPanel:_Dispose()
    if (self._listenerKeyboardTimer) then
        self._listenerKeyboardTimer:Stop()
        self._listenerKeyboardTimer = nil;
    end
    self.btnAttack:Dispose();
    self.btnSkill1:Dispose();
    self.btnSkill2:Dispose();
    self.btnSkill3:Dispose();
    self.btnSkill4:Dispose();
    self.btnSkill5:Dispose();
    self.btnMountOut:Dispose()
    self.btnAttack = nil
    self.btnSkill1 = nil
    self.btnSkill2 = nil
    self.btnSkill3 = nil
    self.btnSkill4 = nil
    self.btnSkill5 = nil
    self.btnMountOut = nil

    UIUtil.GetComponent(self._iconToggle, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onToggle = nil

    MessageManager.RemoveListener(HeroController, HeroController.MESSAGE_ON_MOUNTLANG, CastSkillPanel.OnMountLang);
    MessageManager.RemoveListener(HeroController, HeroController.MESSAGE_OUT_MOUNTLANG, CastSkillPanel.OutMountLang);
    MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfSkillChange, CastSkillPanel.OnSkillChange);
    MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfLevelChange, CastSkillPanel.OnPlayerChange);
    MessageManager.RemoveListener(NewTrumpManager, NewTrumpManager.SelfTrumpFollow, CastSkillPanel.UpTrumpSkill);
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_SKILL_CHG, CastSkillPanel.UpSkills);
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_SKILL_SLOT_OPEN, CastSkillPanel.OnSkillSlotOpen);
    MessageManager.RemoveListener(SendSkillAction, SendSkillAction.CastSkill, CastSkillPanel.OnCastSkill, self);

end

function CastSkillPanel:OnCastSkill(data)
    self.btnSkill1:SetGray(data)
    self.btnSkill2:SetGray(data)
    self.btnSkill3:SetGray(data)
    self.btnSkill4:SetGray(data)
    self.btnSkill5:SetGray(data)
end

function CastSkillPanel:Toggle()
    -- self.mode = self.mode == MainUIPanel.Mode.SHOW and MainUIPanel.Mode.HIDE or MainUIPanel.Mode.SHOW;
    -- self._trsContent.gameObject:SetActive(self.mode == MainUIPanel.Mode.SHOW);
    SceneSelecter.GetInstance():ChangeEnemy()
    if GameSceneManager.debug then ModuleManager.SendNotification(LDNotes.OPEN_LDPANEL) end
end

function CastSkillPanel:SetOperateEnable(enable)
    if (not enable) then
        self.btnAttack:Upspring();
        self.btnSkill1:Upspring();
        self.btnSkill2:Upspring();
        self.btnSkill3:Upspring();
        self.btnSkill4:Upspring();
        self.btnSkill5:Upspring();
        local hero = HeroController.GetInstance();
        if (hero) then
            hero:StopAttack();
        end
    end
    _enable = enable
end

function CastSkillPanel:OnSkillSlotOpen(index)
    if self["btnSkill" .. index] then
        self["btnSkill" .. index]:PlayUnlockEff();
    end
end 