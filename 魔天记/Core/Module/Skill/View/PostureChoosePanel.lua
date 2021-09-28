require "Core.Module.Common.UIComponent"
require "Core.Module.Skill.View.Item.SkillItemButton"
require "Core.Module.Skill.View.Item.PosturePanel"

PostureChoosePanel = class("PostureChoosePanel", UIComponent)
local insert = table.insert
 
function PostureChoosePanel:New()
    self = { };
    setmetatable(self, { __index = PostureChoosePanel });
    return self;
end 

function PostureChoosePanel:_InitPosture()
    local PostureCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_POSTURE);
    local heroInfo = PlayerManager.GetPlayerInfo();
    local kind = heroInfo.kind;
    self._postures = { };
    for i, v in pairs(PostureCfg) do
        if (v.career_id == kind) then
            insert(self._postures, 1, v);
        end
    end
end

function PostureChoosePanel:_Init()
    self._trsContent = UIUtil.GetChildByName(self._gameObject, "Transform", "trsContent");
    self:_InitPosture();
    self:_InitReference();
end

function PostureChoosePanel:_InitReference()
    local heroInfo = PlayerManager.GetPlayerInfo();
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");

    self._selPostureId = heroInfo.posture;

    self._btnUpgrade = UIUtil.GetChildByName(self._trsContent.gameObject, "UIButton", "btnUpgrade");
    self._txtSkillName = UIUtil.GetChildInComponents(txts, "txtSkillName");
    self._txtCD = UIUtil.GetChildInComponents(txts, "txtCD");
    self._txtMP = UIUtil.GetChildInComponents(txts, "txtMP");
    self._txtReLevel = UIUtil.GetChildInComponents(txts, "txtReLevel");
    self._txtDesc = UIUtil.GetChildInComponents(txts, "txtDesc");
    self._txtEffect = UIUtil.GetChildInComponents(txts, "txtEffect");

    self._onSkillButonClick = function(go)
        self._selSkillBtn = go;
        self:_SelectSkill(go:GetSkill())
    end

    self._onPostureSkillButonClick = function(go, id)
        self._selPostureSkillBtn = go;
        self._selPostureId = id;
        self:_Refresh();
    end

    self._onChangePostureButonClick = function(id)
        self:_ChangePosture(id);
    end

    local buttons = UIUtil.GetChildByName(self._trsContent.gameObject, "Transform", "skillButtons");

    self._skillButtons = { };

    local btnSkill1 = UIUtil.GetChildByName(buttons.gameObject, "Transform", "btnSkill1");
    self._btnSkill1 = SkillItemButton:New();
    self._btnSkill1:Init(btnSkill1);
    self._btnSkill1:SetSkill(heroInfo:GetBaseSkill());
    self._btnSkill1:AddClickListener(self._onSkillButonClick);
    self._btnSkill1:SetEnable(false);
    -- insert(self._skillButtons, self._btnSkill1);

    local btnSkill2 = UIUtil.GetChildByName(buttons.gameObject, "Transform", "btnSkill2");
    self._btnSkill2 = SkillItemButton:New();
    self._btnSkill2:Init(btnSkill2);
    self._btnSkill2:SetSkill(heroInfo:GetDefSkillByIndex(1));
    self._btnSkill2:AddClickListener(self._onSkillButonClick);
    insert(self._skillButtons, self._btnSkill2);

    local btnSkill3 = UIUtil.GetChildByName(buttons.gameObject, "Transform", "btnSkill3");
    self._btnSkill3 = SkillItemButton:New();
    self._btnSkill3:Init(btnSkill3);
    self._btnSkill3:SetSkill(heroInfo:GetDefSkillByIndex(2));
    self._btnSkill3:AddClickListener(self._onSkillButonClick);
    insert(self._skillButtons, self._btnSkill3);

    local btnSkill4 = UIUtil.GetChildByName(buttons.gameObject, "Transform", "btnSkill4");
    self._btnSkill4 = SkillItemButton:New();
    self._btnSkill4:Init(btnSkill4);
    self._btnSkill4:SetSkill(heroInfo:GetDefSkillByIndex(3));
    self._btnSkill4:AddClickListener(self._onSkillButonClick);
    insert(self._skillButtons, self._btnSkill4);

    local btnSkill5 = UIUtil.GetChildByName(buttons.gameObject, "Transform", "btnSkill5");
    self._btnSkill5 = SkillItemButton:New();
    self._btnSkill5:Init(btnSkill5);
    self._btnSkill5:SetSkill(heroInfo:GetDefSkillByIndex(4));
    self._btnSkill5:AddClickListener(self._onSkillButonClick);
    insert(self._skillButtons, self._btnSkill5);

    local btnSkill6 = UIUtil.GetChildByName(buttons.gameObject, "Transform", "btnSkill6");
    self._btnSkill6 = SkillItemButton:New();
    self._btnSkill6:Init(btnSkill6);
    self._btnSkill6:SetSkill(heroInfo:GetDefSkillByIndex(5));
    self._btnSkill6:AddClickListener(self._onSkillButonClick);
    insert(self._skillButtons, self._btnSkill6);

    local btnSkill7 = UIUtil.GetChildByName(buttons.gameObject, "Transform", "btnSkill7");
    self._btnSkill7 = SkillItemButton:New();
    self._btnSkill7:Init(btnSkill7);
    self._btnSkill7:SetSkill(heroInfo:GetDefSkillByIndex(6));
    self._btnSkill7:AddClickListener(self._onSkillButonClick);
    insert(self._skillButtons, self._btnSkill7);

    self._posturePanels = { };

    local posturePanel1 = UIUtil.GetChildByName(self._trsContent.gameObject, "Transform", "Posture1");
    self._posture1 = PosturePanel:New();
    self._posture1:Init(posturePanel1);
    self._posture1:SetInfo(self._postures[1]);
    self._posture1:Select(self._postures[1].id == heroInfo.posture);
    self._posture1:AddClickListener(self._onPostureSkillButonClick, self._onChangePostureButonClick);
    self._posturePanels[self._postures[1].id] = self._posture1;

    local posturePanel2 = UIUtil.GetChildByName(self._trsContent.gameObject, "Transform", "Posture2");
    self._posture2 = PosturePanel:New();
    self._posture2:Init(posturePanel2);
    self._posture2:SetInfo(self._postures[2]);
    self._posture2:Select(self._postures[2].id == heroInfo.posture);
    self._posture2:AddClickListener(self._onPostureSkillButonClick, self._onChangePostureButonClick);
    self._posturePanels[self._postures[2].id] = self._posture2;

    self:_Refresh();
end

function PostureChoosePanel:_SelectSkill(skill)
    if (self._selPostureSkillBtn) then
        local pskill = self._selPostureSkillBtn:GetSkill();
        if (pskill ~= skill) then
            -- self._selPostureSkillBtn:SetSkill(skill);
            self._posturePanels[self._selPostureId]:SetSkillByButton(self._selPostureSkillBtn, skill);
            local data = {
                id = self._selPostureId;
                sk = self._posturePanels[self._selPostureId]:GetSkills();
            }
            SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ChangePostureSkill, self._CmdChooseSkillHandler, self);
            SocketClientLua.Get_ins():SendMessage(CmdType.ChangePostureSkill, data);
        end
    end
end

function PostureChoosePanel:_ChangePosture(id)
    local data = {
        id = id;
    }
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ChangePosture, self._CmdChoosePostureHandler, self);
    SocketClientLua.Get_ins():SendMessage(CmdType.ChangePosture, data);
end

function PostureChoosePanel:_Refresh()
    local pSkill = nil;
    if (self._selPostureSkillBtn) then
        pSkill = self._selPostureSkillBtn:GetSkill();
    end
    for i, v in pairs(self._skillButtons) do
        local tskill = v:GetSkill();
        v:Select(tskill == pSkill);
        v:SetEnable((tskill.posture_id == 0 or tskill.posture_id == self._selPostureId) and self._selPostureId ~= 0)
    end
end

function PostureChoosePanel:_CmdChoosePostureHandler(cmd, data)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ChangePosture, self._CmdChoosePostureHandler);
    if (data and(not data.errCode)) then
        local heroInfo = PlayerManager.GetPlayerInfo();
        PlayerManager.hero:SetPosture(data.id);
        MessageManager.Dispatch(PlayerManager, PlayerManager.SelfSkillChange, heroInfo.posture);

        for i, v in pairs(self._posturePanels) do
            v:Select(i == data.id);
        end
    end
end

function PostureChoosePanel:_CmdChooseSkillHandler(cmd, data)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ChangePostureSkill, self._CmdChooseSkillHandler);
    if (data and(not data.errCode)) then
        local heroInfo = PlayerManager.GetPlayerInfo();
        local pSkill = self._selPostureSkillBtn:GetSkill();
        heroInfo:SetPostureSkill(self._selPostureSkillBtn:GetSkill(), self._selPostureSkillBtn.index, self._selPostureId)
        if (self._selPostureId == heroInfo.posture) then
            MessageManager.Dispatch(PlayerManager, PlayerManager.SelfSkillChange, heroInfo.posture)
        end
    end
end

function PostureChoosePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function PostureChoosePanel:_DisposeListener()
    self._onSkillButonClick = nil;
end

function PostureChoosePanel:_DisposeReference()
    self._btnSkill1 = nil;
    self._btnSkill2 = nil;
    self._btnSkill3 = nil;
    self._btnSkill4 = nil;
    self._btnSkill5 = nil;
    self._btnSkill6 = nil;
    self._btnSkill7 = nil;
end
