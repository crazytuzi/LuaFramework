local netlifeskill = {}
function netlifeskill.setBaseLifeSkill(param, ptc_main, ptc_sub)
  print("netlifeskill.setBaseLifeSkill:", param, ptc_main, ptc_sub)
  local lsType = param.type
  local lsLv = param.lv
  g_LocalPlayer:setBaseLifeSkill(lsType, lsLv)
end
function netlifeskill.setLifeSkillBuff(param, ptc_main, ptc_sub)
  print("netlifeskill.setLifeSkillBuff:", param, ptc_main, ptc_sub)
  local bsd = param.baoshidu
  local runeData = param.rune
  local wineData = param.wine
  if bsd ~= nil then
    g_LocalPlayer:setLifeSkillBSD(bsd)
  end
  if runeData ~= nil then
    local runeId = runeData.itemid or 0
    local runeV = runeData.val or 0
    g_LocalPlayer:setLifeSkillFuData(runeId, runeV)
  end
  if wineData ~= nil then
    local wineId = wineData.itemid or 0
    local wineV = wineData.val or 0
    g_LocalPlayer:setLifeSkillWineData(wineId, wineV)
  end
end
function netlifeskill.setLifeSkill_SXF_BSK(param, ptc_main, ptc_sub)
  print("netlifeskill.setLifeSkill_SXF_BSK:", param, ptc_main, ptc_sub)
  local itemId = param.itemid
  local lefttime = param.lefttime
  local bsfType = param.rtype
  g_LocalPlayer:setLifeSkillFuData(itemId, lefttime, bsfType)
end
function netlifeskill.clearAllFuWen(param, ptc_main, ptc_sub)
  print("netlifeskill.clearAllFuWen:", param, ptc_main, ptc_sub)
  g_LocalPlayer:setLifeSkillFuData(0, 0)
end
return netlifeskill
