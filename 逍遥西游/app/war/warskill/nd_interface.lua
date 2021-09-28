if not g_NeiDanSkill then
  g_NeiDanSkill = {}
end
function g_NeiDanSkill.getNeiDanCoefficient(petObj, neidanObj)
  if petObj == nil or neidanObj == nil then
    return 0
  end
  local petZhuan = petObj:getProperty(PROPERTY_ZHUANSHENG)
  local petLv = petObj:getProperty(PROPERTY_ROLELEVEL)
  local petFam = petObj:getProperty(PROPERTY_CLOSEVALUE)
  local ndType = neidanObj:getTypeId()
  local ndLv = neidanObj:getProperty(ITEM_PRO_LV)
  local ndZhuan = neidanObj:getProperty(ITEM_PRO_NEIDAN_ZS)
  local ssv = petObj:getProperty(PROPERTY_STARSKILLVALUE)
  return _computeNeiDanCoefficient(ndType, petZhuan, petLv, petFam, ndLv, ndZhuan, ssv)
end
function g_NeiDanSkill.getNeiDanPro_ChengFengPoLang(petObj)
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_CHENGFENGPOLANG)
  return _computeNeiDanPro_ChengFengPoLang(ndCoeff)
end
function g_NeiDanSkill.getNeiDanPro_PiLiLiuXing(petObj)
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_PILILIUXING)
  return _computeNeiDanPro_PiLiLiuXing(ndCoeff)
end
function g_NeiDanSkill.getNeiDanPro_DaHaiWuLiang(petObj)
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_DAHAIWULIANG)
  return _computeNeiDanPro_DaHaiWuLiang(ndCoeff)
end
function g_NeiDanSkill.getNeiDanPro_ZhuRongQuHuo(petObj)
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_ZHURONGQUHUO)
  return _computeNeiDanPro_ZhuRongQuHuo(ndCoeff)
end
function g_NeiDanSkill.getNeiDanPro_HongYanBaiFa(petObj)
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_HONGYANBAIFA)
  return _computeNeiDanPro_HongYanBaiFa(ndCoeff)
end
function g_NeiDanSkill.getNeiDanPro_MeiHuaSanNong(petObj)
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_MEIHUASANNONG)
  return _computeNeiDanPro_MeiHuaSanNong(ndCoeff)
end
function g_NeiDanSkill.getNeiDanPro_KaiTianPiDi(petObj)
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_KAITIANPIDI)
  return _computeNeiDanPro_KaiTianPiDi(ndCoeff)
end
function g_NeiDanSkill.getNeiDanPro_WanFoChaoZong(petObj)
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_WANFOCHAOZONG)
  return _computeNeiDanPro_WanFoChaoZong(ndCoeff)
end
function g_NeiDanSkill.getNeiDanPro_HaoRanZhengQi(petObj)
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_HAORANZHENGQI)
  local petLv = petObj:getProperty(PROPERTY_ROLELEVEL)
  local petMaxMp = petObj:getMaxProperty(PROPERTY_MP)
  return _computeNeiPro_HaoRanZhengQi(ndCoeff, petLv, petMaxMp)
end
function g_NeiDanSkill.getNeiDanPro_AnDuChenCang(petObj)
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_ANDUCHENCANG)
  return _computeNeiDanPro_AnDuChenCang(ndCoeff)
end
function g_NeiDanSkill.getNeiDanPro_JieLiDaLi(petObj)
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_JIELIDALI)
  return _computeNeiDanPro_JieLiDaLi(ndCoeff)
end
function g_NeiDanSkill.getNeiDanPro_LingBoWeiBu(petObj)
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_LINGBOWEIBU)
  return _computeNeiDanPro_LingBoWeiBu(ndCoeff)
end
function g_NeiDanSkill.getNeiDanPro_GeShanDaNiu(petObj)
  local ndCoeff = _getNeiDanCoeff(petObj, NDSKILL_GESHANDANIU)
  local petLv = petObj:getProperty(PROPERTY_ROLELEVEL)
  local petMaxMp = petObj:getMaxProperty(PROPERTY_MP)
  return _computeNeiDanDamage_GeShanDaNiu(ndCoeff, petLv, petMaxMp)
end
