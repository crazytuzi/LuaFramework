local JieYiZhaoHuan = class("JieYiZhaoHuan")

function JieYiZhaoHuan.onSkillZHClick(skillid)
    g_msgHandlerInst:sendNetDataByTable(SKILL_CS_SWORN_SKILL, "SkillSwornProtocol", {skillId=skillid})
    if G_MAINSCENE then
        G_MAINSCENE:doSkillCdAction(skillid,1)
    end
end

return JieYiZhaoHuan