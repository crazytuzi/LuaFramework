function print_SkillLog_RoleIsNotExist(warId, pos)
  printLogDebug("war_skill", "【war log】[warid%d]角色 @%d 不存在", warId, pos)
end
function print_SkillLog_TargetRoleIsNotExist(warId, pos)
  printLogDebug("war_skill", "【war log】[warid%d]目标角色 @%d 不存在", warId, pos)
end
function print_SkillLog_UpdateAllStateBeforeRound(warId, pos)
  printLogDebug("war_skill", "【war log】[warid%d]回合前 @%d 刷新效果状态", warId, pos)
end
function print_SkillLog_UpdateAllStateInfo(warId, pos, name, effRound)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 状态刷新后:效果(%s)，剩余 %d 回合", warId, pos, name, effRound)
end
function print_SkillLog_PoisonDamage(warId, pos, damage)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 持续中毒，损失 %d 点hp", warId, pos, damage)
end
function print_SkillLog_StateRemoved(warId, pos, name)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 解除状态:效果(%s):", warId, pos, name)
end
function print_SkillLog_RoleIsDead(warId, pos)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 死亡", warId, pos)
end
function print_SkillLog_SkillDataError(warId, userPos, selectPos, skillID)
  printLogDebug("war_skill", "【war log】[warid%d]找不到技能数据，@%d 无法对 @%d 使用技能 [%d] !!!", warId, userPos, selectPos, skillID)
end
function print_SkillLog_UseSkill(warId, pos, tPos, name)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 准备对目标 @%d 使用法术(%s)", warId, pos, tPos, name)
end
function print_SkillLog_CanNotUseSkill(warId, pos, name)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 不能使用技能 [%s]", warId, pos, name)
end
function print_SkillLog_NoRightTarget(warId, pos, tPos)
  printLogDebug("war_skill", "【war log】[warid%d]找不到合适的攻击目标，@%d 无法对 @%d 进行攻击 !!!", warId, pos, tPos)
end
function print_SkillLog_LackMp(warId, mp, requireMp)
  printLogDebug("war_skill", "【war log】[warid%d]魔法值不够(%d,%d) !!!", warId, mp, requireMp)
end
function print_SkillLog_LackHp(warId, hp, requireHp)
  printLogDebug("war_skill", "【war log】[warid%d]生命值不够(%d,%d) !!!", warId, hp, requireHp)
end
function print_SkillLog_AddEffect(warId, pos1, pos2, eID, sRound)
  local eData = data_Effect[eID] or {}
  printLogDebug("war_skill", "【war log】[warid%d] @%d 对目标 @%d 添加效果 (%s), 持续 %d 回合", warId, pos1, pos2 or "未知", eData.name or "未知", sRound)
end
function print_SkillLog_DamageHp(warId, pos1, pos2, damagehp)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 对目标 @%d  造成伤害 %d", warId, pos1, pos2, damagehp)
end
function print_SkillLog_DamageHpAndMp(warId, pos1, pos2, damagehp, damagemp)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 对目标 @%d  造成hp伤害 %d， 燃烧魔法 %d", warId, pos1, pos2, damagehp, damagemp)
end
function print_SkillLog_UseSkillSucceed(warId, pos, tPos, name)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 对目标 @%d 使用法术[%s]成功", warId, pos, tPos, name)
end
function print_SkillLog_Miss(warId, pos)
  printLogDebug("war_skill", "【war log】[warid%d] 目标 @%d miss", warId, pos)
end
function print_SkillLog_AttackInvalid(warId, pos, tPos)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 对目标 @%d 攻击无效", warId, pos, tPos)
end
function print_SkillLog_Reverberate(warId, pos1, pos2, damagehp, damagemp)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 对 @%d 进行反弹, 造成伤害 %d, 燃烧魔法 %d", warId, pos1, pos2, damagehp, damagemp)
end
function print_SkillLog_CounterAttack(warId, pos1, pos2, damagehp)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 对 @%d 进行反击, 造成伤害 %d", warId, pos1, pos2, damagehp)
end
function print_SkillLog_SelectPosError(warId, selectPos, targetNum)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 所选位置为空或者技能攻击目标数(%d)小于0，不能使用技能 [%s]", warId, selectPos, targetNum, name)
end
function print_SkillLog_CanNotNormalAttack(warId, pos)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 不能使用普通攻击", warId, pos)
end
function print_SkillLog_NormalAttack(warId, pos, tPos)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 准备对目标 @%d 发起普通攻击", warId, pos, tPos)
end
function print_SkillLog_NormalAttackInvalid(warId, pos, tPos)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 对目标 @%d 普通攻击无效", warId, pos, tPos)
end
function print_SkillLog_DoubleHit(warId, pos, hitTimes)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 触发了 %d 连击", warId, pos, hitTimes)
end
function print_SkillLog_NoDoubleHitTimes(warId, pos)
  printLogDebug("war_skill", "【war log】[warid%d] @%d 触发了反击，但是本回合已经没有反击次数了", warId, pos)
end
function print_SkillLog_KuangBao(warId, pos)
  printLogDebug("war_skill", "【war log】[warid%d]@%d 触发了狂暴", warId, pos)
end
function print_SkillLog_ZhiMing(warId, pos)
  printLogDebug("war_skill", "【war log】[warid%d]@%d 触发了致命", warId, pos)
end
