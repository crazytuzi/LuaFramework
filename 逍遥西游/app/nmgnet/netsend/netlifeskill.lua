local netlifeskill = {}
function netlifeskill.setLifeSkill(lsType)
  NetSend({type = lsType}, "lifeskill", "P1")
end
function netlifeskill.upgradeLifeSkill(addlv)
  NetSend({addlv = addlv}, "lifeskill", "P2")
end
function netlifeskill.lifeSkillMakeItem(itemId, num)
  NetSend({category = itemId, num = num}, "lifeskill", "P3")
end
function netlifeskill.addBSDWithMoney()
  NetSend({}, "lifeskill", "P4")
end
function netlifeskill.checkLifeSkillBuffById(itemId)
  NetSend({itemid = itemId}, "lifeskill", "P5")
end
function netlifeskill.reLearnedLifeSkill(lsType)
  NetSend({type = lsType}, "lifeskill", "P6")
end
function netlifeskill.cancelLifeSkillBuff(lsType)
  NetSend({type = lsType}, "lifeskill", "P7")
end
function netlifeskill.huoLiForFlower()
  NetSend({}, "lifeskill", "P8")
end
function netlifeskill.huoLiForCoin()
  NetSend({}, "lifeskill", "P9")
end
return netlifeskill
