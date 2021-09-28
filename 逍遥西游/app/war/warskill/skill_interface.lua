if not g_SkillAI then
  g_SkillAI = {}
end
function g_SkillAI.getSkillStyle(skillID)
  return _getSkillStyle(skillID)
end
function g_SkillAI.getSkillTargetType(skillID)
  return _getSkillTargetType(skillID)
end
function g_SkillAI.getRoleIsInEffect(roleObj, checkEffList)
  return _getRoleIsInEffect(roleObj, checkEffList)
end
function g_SkillAI.getIsConfuse(warId, pos)
  return _getIsExistedEffect(warId, pos, EFFECTTYPE_CONFUSE)
end
function g_SkillAI.getIsFrozen(warId, pos)
  return _getIsExistedEffect(warId, pos, EFFECTTYPE_FROZEN)
end
function g_SkillAI.getIsSleep(warId, pos)
  return _getIsExistedEffect(warId, pos, EFFECTTYPE_SLEEP)
end
function g_SkillAI.getIsPoison(warId, pos)
  return _getIsExistedEffect(warId, pos, EFFECTTYPE_POISON)
end
function g_SkillAI.getIsFengMo(warId, pos)
  return _getIsExistedEffect(warId, pos, EFFECTTYPE_FENGMO)
end
function g_SkillAI.getIsStealth(warId, pos)
  return _getIsExistedEffect(warId, pos, EFFECTTYPE_STEALTH)
end
function g_SkillAI.checkAllShenBingXianQiBeforeRound(warId, pos)
  return _checkAllShenBingXianQiBeforeRound(warId, pos)
end
function g_SkillAI.checkAllPetSkillBeforeRound(warId, pos)
  return _checkAllPetSkillBeforeRound(warId, pos)
end
function g_SkillAI.checkAllPetSkillDamageBeforeRound(warId, warRound, pos, param)
  return _checkAllPetSkillDamageBeforeRound(warId, warRound, pos, param)
end
function g_SkillAI.checkOtherSkillBeforeRound(warId, warRound, pos)
  return _checkOtherSkillBeforeRound(warId, warRound, pos)
end
function g_SkillAI.checkMonsterTeXingBeforeRound(warId, warRound, pos)
  return _checkMonsterTeXingBeforeRound(warId, warRound, pos)
end
function g_SkillAI.checkAllEffectStateBeforeRound(warId, warRound, pos)
  return _checkAllEffectStateBeforeRound(warId, warRound, pos)
end
function g_SkillAI.checkAllEffectStateBeforeRoundCompleted(warId)
  return _checkAllEffectStateBeforeRoundCompleted(warId)
end
function g_SkillAI.checkAllEffectStateAfterRound(warId, pos)
  return _checkAllEffectStateAfterRound(warId, pos)
end
function g_SkillAI.checkPetSkillsAfterRound(warId, warType, warRound)
  return _checkPetSkillsAfterRound(warId, warType, warRound)
end
function g_SkillAI.checkSkillCanUseOnPVE(warId, skillID)
  return _checkSkillCanUseOnPVE(warId, skillID)
end
function g_SkillAI.checkSkillCanUseBeforeRound(warId, warRound, userPos, skillID)
  return _checkSkillCanUseBeforeRound(warId, warRound, userPos, skillID)
end
function g_SkillAI.checkCDValueOfSkill(warId, warRound, userPos, skillID)
  return _checkCDValueOfSkill(warId, warRound, userPos, skillID)
end
function g_SkillAI.checkNeedProsOfSkill(warId, warRound, userPos, skillID)
  return _checkNeedProsOfSkill(warId, warRound, userPos, skillID)
end
function g_SkillAI.getPetStolenSkillList(warId, warRound, userPos, warType)
  return _getPetStolenSkillList(warId, warRound, userPos, warType)
end
function g_SkillAI.getOnceSkillUseFlag(warId, userPos, skillID)
  return _getOnceSkillUseFlag(warId, userPos, skillID)
end
function g_SkillAI.getSkillUseOfMinRoundFlag(warId, userPos, skillID)
  return _getSkillUseOfMinRoundFlag(skillID)
end
function g_SkillAI.getAttackXuanRenFlag(warId)
  return _checkXuanRenFlagOfTeam(warId, TEAM_ATTACK)
end
function g_SkillAI.getDefendXuanRenFlag(warId)
  return _checkXuanRenFlagOfTeam(warId, TEAM_DEFEND)
end
function g_SkillAI.getAttackYiHuanFlag(warId)
  return _checkYiHuanFlagOfTeam(warId, TEAM_ATTACK)
end
function g_SkillAI.getDefendYiHuanFlag(warId)
  return _checkYiHuanFlagOfTeam(warId, TEAM_DEFEND)
end
function g_SkillAI.checkUserMpOfSkill(warId, userPos, skillID)
  return _checkUserMpOfSkill(warId, userPos, skillID)
end
function g_SkillAI.checkUserHpOfSkill(warId, userPos, skillID)
  return _checkUserHpOfSkill(warId, userPos, skillID)
end
function g_SkillAI.getEnemySideOfNoNegativeEffect(warId, pos)
  return _getEnemySideOfNoNegativeEffect(warId, pos)
end
function g_SkillAI.getMySideOfNoPositiveEffect(warId, pos)
  return _getMySideOfNoPositiveEffect(warId, pos)
end
function g_SkillAI.getTeammateOfNoPositiveEffect(warId, pos)
  return _getTeammateOfNoPositiveEffect(warId, pos)
end
function g_SkillAI.isExistedPositiveEffectOfSelf(warId, pos)
  return _isExistedPositiveEffectOfSelf(warId, pos)
end
function g_SkillAI.getEnemySideOfNoCertainEffect(warId, pos, certainEffectList)
  return _getEnemySideOfNoCertainEffect(warId, pos, certainEffectList)
end
function g_SkillAI.getMySideOfNoCertainEffect(warId, pos, certainEffectList)
  return _getMySideOfNoCertainEffect(warId, pos, certainEffectList)
end
function g_SkillAI.getMyTeammateOfNoCertainEffect(warId, pos, certainEffectList)
  return _getTeammateOfNoCertainEffect(warId, pos, certainEffectList)
end
function g_SkillAI.getMyTeammateOfCertainEffect(warId, pos, certainEffectList)
  return _getMyTeammateOfCertainEffect(warId, pos, certainEffectList)
end
function g_SkillAI.canSkillOnTarget(warId, targetPos, skillID)
  return _canSkillOnTarget(warId, targetPos, skillID)
end
function g_SkillAI.useSkillOnTarget(warId, warRound, userPos, selectPos, skillID, exPara)
  return _useSkillOnTarget(warId, warRound, userPos, selectPos, skillID, exPara)
end
function g_SkillAI.onCreateNewRoleOnPos(warId, userPos, skillID, param, callback)
  return _onCreateNewRoleOnPos(warId, userPos, skillID, param, callback)
end
function g_SkillAI.useDrugOnPos(warId, userPos, drugPos, drugID, callback)
  return _useDrugOnPos(warId, userPos, drugPos, drugID, callback)
end
function g_SkillAI.formatTipSequence(warId, objPos, tipID)
  return _formatTipSequence(warId, objPos, tipID)
end
function g_SkillAI.formatLackManaTipSequence(warId, objPos, skillId)
  return _formatLackManaTipSequence(warId, objPos, skillId)
end
function g_SkillAI.clearAllBuffWhenRoleDie(warId, pos)
end
function g_SkillAI.checkWhenPetEnter(warId, warRound, pos, param)
  return _checkWhenPetEnter(warId, warRound, pos, param)
end
function g_SkillAI.checkWhenPetLeave(warId, pos, leavePetObj)
  return _checkWhenPetLeave(warId, pos, leavePetObj)
end
function g_SkillAI.getTempLessenHpAndMp(roleObj)
  return _getTempLessenHpAndMp(roleObj)
end
function g_SkillAI.checkReliveWhenRoleIsDead(warId, pos, deadObj)
  return _checkReliveWhenRoleIsDead(warId, pos, deadObj)
end
function g_SkillAI.checkWhenRoleIsDead(warId, pos, deadObj)
  return _checkWhenRoleIsDead(warId, pos, deadObj)
end
function g_SkillAI.checkDefenceEffectStateBeforeRound(warId, pos, isDefence)
  return _checkDefenceEffectStateBeforeRound(warId, pos, isDefence)
end
function g_SkillAI.catchPet(warId, pos, targetPos)
  _catchPet(warId, pos, targetPos)
end
function g_SkillAI.getShowEnemyHpMpPosList(warId, warType)
  return _getShowEnemyHpMpPosList(warId, warType)
end
function g_SkillAI.checkWhenWarBegin(warId, warType)
  return _checkWhenWarBegin(warId, warType)
end
function g_SkillAI.computePetSkill_GaoJiJiShiYu()
  return _computePetSkill_GaoJiJiShiYu()
end
function g_SkillAI.computePetSkill_JiShiYu()
  return _computePetSkill_JiShiYu()
end
function g_SkillAI.createPetShanXian(warId, pos, param)
  return _createPetShanXian(warId, pos, param)
end
function g_SkillAI.createAddOneMst(warId, pos, param)
  return _createAddOneMst(warId, pos, param)
end
function g_SkillAI.setTipsChangeToAttack(warId, userPos, userObj, skillID)
  _ExecNormalAttackWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setTipsLackMp(warId, userPos, userObj, skillID)
  _LackManaWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setTipsLackHp(warId, userPos, userObj, skillID)
  _LackHpWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setTipsNoTarget(warId, userPos, userObj, skillID)
  _NoTargetWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setTipsLackCD(warId, userPos, userObj, skillID)
  _SkillIsCDWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setTipsHaveUsedOnceSkill(warId, userPos, userObj, skillID)
  _OnceSkillHaveUsedWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setTipsCanNotUseBeforeRound(warId, userPos, userObj, skillID)
  _CanNotUseWhenSkillInCurRound(warId, userPos, userObj, skillID)
end
function g_SkillAI.setTipsCanNotUseYiWangSkill(warId, userPos, userObj, skillID)
  _setTipsCanNotUseYiWangSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setTipsCanNotUseSkillOnDeadRole(warId, userPos, userObj, skillID)
  _setTipsCanNotUseSkillOnDeadRole(warId, userPos, userObj, skillID)
end
function g_SkillAI.setTipsCanNotUseSkillInAutoState(warId, userPos, userObj, skillID)
  _setTipsCanNotUseSkillInAutoState(warId, userPos, userObj, skillID)
end
function g_SkillAI.setTipsPVECanNotUse(warId, userPos, userObj, skillID)
  _CanNotUseWhenSkillInPVE(warId, userPos, userObj, skillID)
end
function g_SkillAI.setLackGenGuWhenSkill(warId, userPos, userObj, skillID)
  _LackGenGuWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setLackLingXingWhenSkill(warId, userPos, userObj, skillID)
  _LackLingXingWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setLackMinJieWhenSkill(warId, userPos, userObj, skillID)
  _LackMinJieWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setLackLiLiangWhenSkill(warId, userPos, userObj, skillID)
  _LackLiLiangWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setLackWxJinWhenSkill(warId, userPos, userObj, skillID)
  _LackWuXingJinWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setLackWxMuWhenSkill(warId, userPos, userObj, skillID)
  _LackWuXingMuWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setLackWxShuiWhenSkill(warId, userPos, userObj, skillID)
  _LackWuXingShuiWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setLackWxHuoWhenSkill(warId, userPos, userObj, skillID)
  _LackWuXingHuoWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.setLackWxTuWhenSkill(warId, userPos, userObj, skillID)
  _LackWuXingTuWhenSkill(warId, userPos, userObj, skillID)
end
function g_SkillAI.formatAndSendTipSequence(warId, userPos, userObj, skillID, tipsID)
  _SkillFormatAndSendTipSequence(warId, userPos, userObj, skillID, tipsID)
end
function g_SkillAI.checkSkillIsYiWang(roleObj, skillId)
  return _checkSkillIsYiWang(roleObj, skillId)
end
