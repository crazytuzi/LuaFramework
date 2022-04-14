--
-- @Author: lwj
-- @Date:   2018-10-15 19:20:34
--

require "game.skill.RequireSkill"

SkillUIController = SkillUIController or class("SkillUIController", BaseController)
local SkillUIController = SkillUIController

function SkillUIController:ctor()
    SkillUIController.Instance = self

    self.model = SkillUIModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function SkillUIController:dctor()
    GlobalSchedule:Stop(self.scheduleId_1)
    --GlobalSchedule:Stop(self.scheduleId_2)
end

function SkillUIController:GetInstance()
    if not SkillUIController.Instance then
        SkillUIController.new()
    end
    return SkillUIController.Instance
end

function SkillUIController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1105_skill_pb"
    self:RegisterProtocal(proto.SKILL_LIST, self.HandleCurSkillList)
    self:RegisterProtocal(proto.SKILL_PUTON, self.HandleSkillPutOn)
    self:RegisterProtocal(proto.SKILL_SET_AUTO_USE, self.HandleAutoUse)
    self:RegisterProtocal(proto.SKILL_AUTO_USE, self.HandleSkillAutoMap)
    self:RegisterProtocal(proto.SKILL_SET_RECOMMEND, self.HandleSetRecommend)
    self:RegisterProtocal(proto.SKILL_GET_SKILL, self.HandleSkillGet)
    self:RegisterProtocal(proto.SKILL_REMOVE_SKILLS, self.HandleRemoveSkills)
    self:RegisterProtocal(proto.SKILL_UPDATE_CDS, self.HandleUpdateCd)
    self:RegisterProtocal(proto.TALENT_INFO, self.HandleTalentInfo)
    self:RegisterProtocal(proto.TALENT_UPGRADE, self.HandleTalentUpgrade)
    self:RegisterProtocal(proto.TALENT_RESET, self.HandleTalentReset)
    self:RegisterProtocal(proto.TALENT_POINT, self.HandleTalentPoint)
end

function SkillUIController:GameStart()
    local function step()
        self:RequestCurSkillList()
        self:RequestSkillAutoMap()
        self.model:FromatTalent()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Best)

    local function call_back()
        local wake = RoleInfoModel:GetInstance():GetRoleValue("wake") or 0
        if wake >= 4 then
            self:RequestTalentInfo()
        end
    end
    GlobalSchedule:StartOnce(call_back, Constant.GameStartReqLevel.VLow)
end

function SkillUIController:AddEvents()
    self:AddOpenSkillUIPanelEvent()
    local function callback(id, pos)
        self:RequestPutOnSkill(id, pos)
    end
    GlobalEvent:AddListener(SkillUIEvent.PutOnSkill, callback)

    local function call_back(id, useId)
        self:RequestAutoUse(id, useId)
    end
    GlobalEvent:AddListener(SkillUIEvent.SetSkillAutoUse, call_back)

    local function call_back(id)
        self:RequestSetRecommend(id)
    end
    GlobalEvent:AddListener(SkillUIEvent.SetRecommendInfo, call_back)

    local function call_back()
        self:RequestSkillAutoMap()
    end
    GlobalEvent:AddListener(SkillUIEvent.RequestItemList, call_back)

    local function call_back()
        local panel = lua_panelMgr:GetPanelOrCreate(SkillGetPanel)
        if not panel.opening then
            local skill = self.model:DelSkillGet()
            if skill then
                panel:Open(skill)
            else
                self:RequestCurSkillList()
            end
        end
    end
    self.model:AddListener(SkillUIEvent.SkillGet, call_back)

    GlobalEvent:AddListener(SkillUIEvent.RequsetAutoUseBeforeGetNewSkill, handler(self, self.RequestSkillAutoMap))

    local function call_back()
        local flag = self.model.point>0
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "skill", flag)
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 52, flag)
    end
    self.model:AddListener(SkillUIEvent.TalentUpdateInfo, call_back)
    self.model:AddListener(SkillUIEvent.TalentUpdateSkill, call_back)
end

function SkillUIController:AddOpenSkillUIPanelEvent()
    local function callback(id)
        id = id or 1
        self:RequestSkillAutoMap()
        lua_panelMgr:GetPanelOrCreate(SkillUIPanel):Open(id)
        --self.scheduleId_2 = GlobalSchedule:Start(handler(self, ), 0.3, 1)
    end
    GlobalEvent:AddListener(SkillUIEvent.OpenSkillUIPanel, callback)
end


--申请技能槽中的技能列表
function SkillUIController:RequestCurSkillList()
    self:WriteMsg(proto.SKILL_LIST)
end

function SkillUIController:HandleCurSkillList()
    local data = self:ReadMsg("m_skill_list_toc")
    --dump(data, "<color=#6ce19b>HandleCurSkillList   HandleCurSkillList  HandleCurSkillList  HandleCurSkillList</color>")
    self.model:SetSkillList(data.skills)
    GlobalEvent:Brocast(SkillUIEvent.UpdateSkillSlots)
end


--申请技能修改的列表
function SkillUIController:RequestSkillAutoMap()
    self:WriteMsg(proto.SKILL_AUTO_USE)
end

function SkillUIController:HandleSkillAutoMap()
    local data = self:ReadMsg("m_skill_auto_use_toc")
    --dump(data, "<color=#6ce19b>HandleSkillAutoMap   HandleSkillAutoMap  HandleSkillAutoMap  HandleSkillAutoMap</color>")
    self.model.autoUseChangeList = data.auto_use
    GlobalEvent:Brocast(SkillUIEvent.UpdateListAutoUse)
    self.model:Brocast(SkillUIEvent.UpdatePetSkill)
end


--装备技能
function SkillUIController:RequestPutOnSkill(skillId, pos)
    local pb = self:GetPbObject("m_skill_puton_tos")
    pb.id = skillId
    pb.pos = pos
    self:WriteMsg(proto.SKILL_PUTON, pb)

    -- print('--BagController 请求装配技能 70-- data=',pb.id,pb.pos)
end

function SkillUIController:HandleSkillPutOn()
end


--自动使用修改
function SkillUIController:RequestAutoUse(skillId, useId)
    local pb = self:GetPbObject("m_skill_set_auto_use_tos")
    pb.id = skillId
    pb.auto_use = useId
    self:WriteMsg(proto.SKILL_SET_AUTO_USE, pb)
    --self:RequestSkillAutoMap()
end

function SkillUIController:HandleAutoUse()
    local data = self:ReadMsg("m_skill_set_auto_use_toc")
    self.model.autoUseChangeList[data.id] = data.auto_use
    GlobalEvent:Brocast(SkillUIEvent.UpdateListAutoUse)
end

--设置推荐技能
function SkillUIController:RequestSetRecommend(id)
    local pb = self:GetPbObject("m_skill_set_recommend_tos")
    pb.id = id
    self:WriteMsg(proto.SKILL_SET_RECOMMEND, pb)
end

function SkillUIController:HandleSetRecommend()
    local data = self:ReadMsg("m_skill_set_recommend_toc")
end

function SkillUIController:HandleSkillGet()
    local data = self:ReadMsg("m_skill_get_skill_toc")
    local skill = data.skill
    local skill_id = skill.id
    local skillitem = Config.db_skill[skill_id]
    if skillitem.pop_win == 1 then
        self.model:AddSkillGet(skill)
        self.model:Brocast(SkillUIEvent.SkillGet)
    else
        self.model:AddToSkillList(skill)
        GlobalEvent:Brocast(SkillUIEvent.UpdateSkillSlots)
    end
end

function SkillUIController:HandleRemoveSkills()
    local data = self:ReadMsg("m_skill_remove_skills_toc")
    local skill_ids = data.skill_ids
    self.model:RemoveSkills(skill_ids)
end

function SkillUIController:HandleUpdateCd()
    local data = self:ReadMsg("m_skill_update_cds_toc")
    self.model:UpdateCd(data.cds)
end


--------------------------------------------------天赋技能-------------------------------------------
--获取天赋技能
function SkillUIController:RequestTalentInfo()
    local pb = self:GetPbObject("m_talent_info_tos", "pb_1141_talent_pb")
    self:WriteMsg(proto.TALENT_INFO, pb)
end

function SkillUIController:HandleTalentInfo()
    local data = self:ReadMsg("m_talent_info_toc","pb_1141_talent_pb")
    
    self.model:SetTalentInfo(data)
    self.model:Brocast(SkillUIEvent.TalentUpdateInfo, data.group)
end

--天赋技能升级
function SkillUIController:RequestTalentUpgrade(skill_id)
    local pb = self:GetPbObject("m_talent_upgrade_tos", "pb_1141_talent_pb")
    pb.id = skill_id
    self:WriteMsg(proto.TALENT_UPGRADE, pb)
end

function SkillUIController:HandleTalentUpgrade()
    local data = self:ReadMsg("m_talent_upgrade_toc","pb_1141_talent_pb")
    
    self.model.talent_skills[data.id] = (self.model.talent_skills[data.id] or 0) + 1
    self.model.point = data.point

    self.model:Brocast(SkillUIEvent.TalentUpdateSkill, data.id)
end

--天赋重置
function SkillUIController:RequestTalentReset()
    local pb = self:GetPbObject("m_talent_reset_tos", "pb_1141_talent_pb")
    self.model.talent_skills = {}
    self:WriteMsg(proto.TALENT_RESET, pb)
end

function SkillUIController:HandleTalentReset()
    local data = self:ReadMsg("m_talent_reset_toc","pb_1141_talent_pb")
    
    Notify.ShowText("Talent reset")
    self.model:Brocast(SkillUIEvent.TalentReset)
end

function SkillUIController:HandleTalentPoint()
    local data = self:ReadMsg("m_talent_point_toc","pb_1141_talent_pb")
    self.model.point = data.point

    local flag = self.model.point>0
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "skill", flag)
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 52, flag)
end

-----------------------------------------------------------------------------------------------------