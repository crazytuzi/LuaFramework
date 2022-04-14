--
-- @Author: lwj
-- @Date:   2018-10-15 19:01:12
--

SkillUIEvent = SkillUIEvent or
        {
            OpenSkillUIPanel = "SkillUIEvent.OpenSkillUIPanel", --打开技能界面
            UpdateActiveDesShow = "SkillUIEvent.UpdateActiveDesShow", --更新主动技能显示的信息
            UpdatePassiveDesShow = "SkillUIEvent.UpdatePassiveDesShow", --更新被动技能显示的信息
            PutOnSkill = "SkillUIEvent.PutOnSkill", --装备技能
            UpdateSkillSlots = "SkillUIEvent.UpdateSkillSlots", --更新技能槽显示
            SetSkillAutoUse = "SkillUIEvent.SetSkillAutoUse", --设置技能的自动释放选项
            SetRecommendInfo = "SkillUIEvent.SetRecommendInfo", --设置推荐技能
            UpdateListAutoUse = "SkillUIEvent.UpdateListAutoUse", --更新列表中的自动使用显示
            RequestItemList = "SkillUIEvent.RequestItemList",
            SkillGet = "SkillUIEvent.SkillGet", --获得技能
            RequsetAutoUseBeforeGetNewSkill = "SkillUIEvent.RequsetAutoUseBeforeGetNewSkill",
            UpdatePetSkill = "SkillUIEvent.UpdatePetSkill",
            PassiveItemClick = "SkillUIEvent.PassiveItemClick",

            TalentSelectGroup = "SkillUIEvent.TalentSelectGroup",       --选天赋
            TalentUpdateInfo = "SkillUIEvent.TalentUpdateInfo",         --更新信息
            TalentSelectSkill = "SkillUIEvent.TalentSelectSkill",       --选技能
            TalentUpdateSkill = "SkillUIEvent.TalentUpdateSkill",       --更新技能
            TalentReset       = "SkillUIEvent.TalentReset",             --天赋重设
        }