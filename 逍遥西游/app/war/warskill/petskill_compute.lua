local DefineMaxCriValue = 9999999
local _checkDamage = function(damage)
  return math.max(math.floor(damage), 1)
end
function _computePetSkillRequireMp(petSkill, petLv, petClose, maxMp, roleType)
  local skillData = _getSkillData(petSkill) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  if petSkill == PETSKILL_HUIGEHUIRI then
    local temp = skillData.mprequire or {}
    local coeff = temp[1] or 0
    return _checkDamage(maxMp * coeff)
  elseif petSkill == PETSKILL_MIAOBISHENGHUA then
    local param = skillData.mprequire or {}
    local a = param[1] or 0
    local b = param[2] or 0
    local c = param[3] or 0
    return _checkDamage(a + petLv * b + petClose * c)
  elseif petSkill == PETSKILL_CHUNNUANHUAKAI then
    local param = skillData.mprequire or {}
    local a = param[1] or 0
    local b = param[2] or 0
    local c = param[3] or 0
    return _checkDamage(a + petLv * b + petClose * c)
  elseif petSkill == PETSKILL_BINGLINCHENGXIA then
    local _, _, coeff, _ = _computePetSkill_BingLinChengXia()
    return _checkDamage(maxMp * coeff)
  else
    return skillData.mprequire or 0
  end
end
function _computePetSkill_ChangYinDongDu(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_CHANGYINDONGDU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local v = math.floor(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if v > criValue and roleType == LOGICTYPE_PET then
    v = math.floor(criValue + (v - criValue) * criCoeff)
  end
  return v
end
function _computePetSkill_YuanQuanWanHu(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_YUANQUANWANHU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local v = math.floor(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if v > criValue and roleType == LOGICTYPE_PET then
    v = math.floor(criValue + (v - criValue) * criCoeff)
  end
  return v
end
function _computePetSkill_ShenGongGuiLi(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_SHENGONGGUILI) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local v = math.floor(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if v > criValue and roleType == LOGICTYPE_PET then
    v = math.floor(criValue + (v - criValue) * criCoeff)
  end
  return v
end
function _computePetSkill_BeiDaoJianXing(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_BEIDAOJIANXING) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local v = math.floor(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if v > criValue and roleType == LOGICTYPE_PET then
    v = math.floor(criValue + (v - criValue) * criCoeff)
  end
  return v
end
function _computePetSkill_ShiSiYaoJue(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_SHISIYAOJUE) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro
end
function _computePetSkill_FenShenYaoJue(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_FENSHENYAOJUE) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro
end
function _computePetSkill_HunFeiYaoJue(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_HUNFEIYAOJUE) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro
end
function _computePetSkill_WanYingYaoJue(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_WANYINGYAOJUE) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro
end
function _computePetSkill_FenLieGongJi()
  local skillData = _getSkillData(PETSKILL_FENLIEGONGJI) or {}
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = not param[2] and 0
  if false and a > 0 then
    a = 1
  end
  return a, b
end
function _computePetSkill_CiWuFanBu(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_CIWUFANBU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro, d
end
function _computePetSkill_FanBuZhiSi(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_FANBUZHISI) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro, d
end
function _computePetSkill_ZhaoYunMuYu(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_ZHAOYUNMUYU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local cdRound = skillData.cd
  local ggRequire = skillData.gg
  local damage = _checkDamage(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if damage > criValue and roleType == LOGICTYPE_PET then
    damage = _checkDamage(criValue + (damage - criValue) * criCoeff)
  end
  return damage, cdRound, ggRequire
end
function _computePetSkill_XianFengDaoGu()
  local skillData = _getSkillData(PETSKILL_XIANFENGDAOGU) or {}
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  return a, b
end
function _computePetSkill_MiaoShouRenXin()
  local skillData = _getSkillData(PETSKILL_MIAOSHOURENXIN) or {}
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  return a, b
end
function _computePetSkill_FengYin(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_FENGYIN) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  if false and pro > 0 then
    pro = 1
  end
  return pro, d
end
function _computePetSkill_HunLuan(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_HUNLUAN) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  if false and pro > 0 then
    pro = 1
  end
  return pro, d
end
function _computePetSkill_ZhongCheng()
  local skillData = _getSkillData(PETSKILL_ZHONGCHENG) or {}
  local param = skillData.calparam or {}
  return param[1] or 0
end
function _computePetSkill_DaYi(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_DAYI) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local e = param[5] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro, d, e
end
function _computePetSkill_ZiYi(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_ZIYI) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local e = param[5] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro, d, e
end
function _computePetSkill_YiChan()
  local skillData = _getSkillData(PETSKILL_YICHAN) or {}
  local param = skillData.calparam or {}
  return param[1] or 0
end
function _computePetSkill_QingMingShu(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_QINGMINGSHU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro
end
function _computePetSkill_TuoKunShu(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_TUOKUNSHU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro
end
function _computePetSkill_NingShenShu(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_NINGSHENSHU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if criValue ~= 0 and pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro
end
function _computePetSkill_JinGangBuHuai(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_JINGANGBUHUAI) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  if false and pro > 0 then
    pro = 1
  end
  return pro
end
function _computePetSkill_ZhongBuBiWei(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_ZHONGBUBIWEI) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  if false and pro > 0 then
    pro = 1
  end
  return pro
end
function _computePetSkill_YiTuiWeiJin()
  local skillData = _getSkillData(PETSKILL_YITUIWEIJIN) or {}
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  return a, b, c
end
function _computePetSkill_HuiGeHuiRi()
  local skillData = _getSkillData(PETSKILL_HUIGEHUIRI) or {}
  local param = skillData.calparam or {}
  return param[1] or 0
end
function _computePetSkill_PanShan(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_PANSHAN) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local v = math.floor(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if v > criValue and roleType == LOGICTYPE_PET then
    v = math.floor(criValue + (v - criValue) * criCoeff)
  end
  return v
end
function _computePetSkill_NuXian(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_NUXIAN) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro
end
function _computePetSkill_HenXian(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_HENXIAN) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro
end
function _computePetSkill_DaoQiangBuRu(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_DAOQIANGBURU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local v = math.floor(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if v > criValue and roleType == LOGICTYPE_PET then
    v = math.floor(criValue + (v - criValue) * criCoeff)
  end
  return v
end
function _computePetSkill_JiShiYu()
  local skillData = _getSkillData(PETSKILL_JISHIYU) or {}
  local param = skillData.calparam or {}
  local pro = not param[1] and 0
  if false and pro > 0 then
    pro = 1
  end
  return pro
end
function _computePetSkill_FuShang(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_FUSHANG) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro, d
end
function _computePetSkill_LangYueQingFeng(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_LANGYUEQINGFENG) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro, pro, pro
end
function _computePetSkill_YiHuan(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_YIHUAN) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local damage = _checkDamage(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if damage > criValue and roleType == LOGICTYPE_PET then
    damage = _checkDamage(criValue + (damage - criValue) * criCoeff)
  end
  return damage
end
function _computePetSkill_XuanRen(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_XUANREN) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local damage = _checkDamage(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if damage > criValue and roleType == LOGICTYPE_PET then
    damage = _checkDamage(criValue + (damage - criValue) * criCoeff)
  end
  return damage
end
function _computePetSkill_GaoJiQingMingShu(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_GAOJIQINGMINGSHU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro
end
function _computePetSkill_GaoJiTuoKunShu(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_GAOJITUOKUNSHU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro
end
function _computePetSkill_GaoJiNingShenShu(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_GAOJININGSHENSHU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if criValue ~= 0 and pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro
end
function _computePetSkill_GaoJiFenLieGongJi()
  local skillData = _getSkillData(PETSKILL_GAOJIFENLIEGONGJI) or {}
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = not param[2] and 0
  if false and a > 0 then
    a = 1
  end
  return a, b
end
function _computePetSkill_GaoJiCiWuFanBu(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_GAOJICIWUFANBU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro, d
end
function _computePetSkill_GaoJiFanBuZhiSi(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_GAOJIFANBUZHISI) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro, d
end
function _computePetSkill_RenLaiFeng(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_RENLAIFENG) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local damage = _checkDamage(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if damage > criValue and roleType == LOGICTYPE_PET then
    damage = _checkDamage(criValue + (damage - criValue) * criCoeff)
  end
  if false and d > 0 then
    d = 1
  end
  return d, damage
end
function _computePetSkill_TaoMing(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_TAOMING) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local damage = _checkDamage(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if damage > criValue and roleType == LOGICTYPE_PET then
    damage = _checkDamage(criValue + (damage - criValue) * criCoeff)
  end
  return damage
end
function _computePetSkill_HuiYuan()
  local skillData = _getSkillData(PETSKILL_HUIYUAN) or {}
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = not param[2] and 0
  if false and a > 0 then
    a = 1
  end
  return a, b
end
function _computePetSkill_BaoFu(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_BAOFU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local e = param[5] or 0
  local f = param[6] or 0
  local criValueData = skillData.criticalValue or {}
  local criCoeffData = skillData.criticalCoeff or {}
  local criValue_1 = criValueData[1] or DefineMaxCriValue
  local criCoeff_1 = criCoeffData[1] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  if criValue_1 < pro and roleType == LOGICTYPE_PET then
    pro = criValue_1 + (pro - criValue_1) * criCoeff_1
  end
  local criValue_2 = criValueData[2] or DefineMaxCriValue
  local criCoeff_2 = criCoeffData[2] or 0
  local damage = _checkDamage(d + petLv * e + petClose * f)
  if criValue_2 < damage and roleType == LOGICTYPE_PET then
    damage = _checkDamage(criValue_2 + (damage - criValue_2) * criCoeff_2)
  end
  if false and pro > 0 then
    pro = 1
  end
  return pro, damage
end
function _computePetSkill_FeiYanHuiXiang(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_FEIYANHUIXIANG) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local mjRequire = skillData.mj or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro, d, mjRequire
end
function _computePetSkill_YingJiChangKong()
  local skillData = _getSkillData(PETSKILL_YINGJICHANGKONG) or {}
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local cdRound = skillData.cd
  local llRequire = skillData.ll or 0
  return cdRound, a, b, llRequire
end
function _computePetSkill_BuBuShengLian(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_BUBUSHENGLIAN) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local e = param[5] or 0
  local f = param[6] or 0
  local cdRound = skillData.cd
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return d, e, f, pro, cdRound
end
function _computePetSkill_LiuAnHuaMing()
  local skillData = _getSkillData(PETSKILL_LIUANHUAMING) or {}
  local param = skillData.calparam or {}
  return param[1] or 0
end
function _computePetSkill_JinTuiZiRu()
  local skillData = _getSkillData(PETSKILL_JINTUIZIRU) or {}
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  return a, b, c
end
function _computePetSkill_LongZhanYuYe(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_LONGZHANYUYE) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local e = param[5] or 0
  local cdRound = skillData.cd
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  pro = math.min(pro, 1)
  return pro, d, e, cdRound
end
function _computePetSkill_HengYunDuanFeng(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_HENGYUNDUANFENG) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local e = param[5] or 0
  local cdRound = skillData.cd
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro, d, e, cdRound
end
function _computePetSkill_ShuShouWuCe(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_SHUSHOUWUCE) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  if false and pro > 0 then
    pro = 1
  end
  return pro, d
end
function _computePetSkill_ShunShuiTuiZhou(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_SHUNSHUITUIZHOU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local e = param[5] or 0
  local f = param[6] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  if false and pro > 0 then
    pro = 1
  end
  return pro, d, e, f
end
function _computePetSkill_NianHuaYiXiao(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_NIANHUAYIXIAO) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local cdRound = skillData.cd
  local lxRequire = skillData.lx or 0
  local damage = _checkDamage(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if damage > criValue and roleType == LOGICTYPE_PET then
    damage = _checkDamage(criValue + (damage - criValue) * criCoeff)
  end
  return damage, cdRound, lxRequire
end
function _computePetSkill_FenHuaFuLiu(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_FENHUAFULIU) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  if false and pro > 0 then
    pro = 1
  end
  return pro
end
function _computePetSkill_FuLuShuangQuan()
  local skillData = _getSkillData(PETSKILL_FULUSHUANGQUAN) or {}
  local param = skillData.calparam or {}
  return param[1] or 0
end
function _computePetSkill_JiRenTianXiang()
  local skillData = _getSkillData(PETSKILL_JIRENTIANXIANG) or {}
  local param = skillData.calparam or {}
  local pro = param[1]
  if false and pro > 0 then
    pro = 1
  end
  return pro or 0
end
function _computePetSkill_MiaoBiShengHua(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_MIAOBISHENGHUA) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local cdRound = skillData.cd
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro, cdRound
end
function _computePetSkill_JinYuZhou(skillId)
  local skillData = _getSkillData(skillId) or {}
  local param = skillData.calparam or {}
  local cdRound = skillData.cd
  return param[1] or 0.5, param[2] or 0.5, param[3] or 3, cdRound
end
function _computePetSkill_TieShuKaiHua()
  local skillData = _getSkillData(PETSKILL_TIESHUKAIHUA) or {}
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  return a, b, c, d
end
function _computePetSkill_ZhiNanErTui(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_ZHINANERTUI) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local round = param[5] or 1
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or 0
  local criCoeff = skillData.criticalCoeff or 0
  if criValue > 0 and pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  if false and pro > 0 then
    pro = 1
    round = 10
  end
  return pro, d, round
end
function _computePetSkill_ShunShouQianYang(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_SHUNSHOUQIANYANG) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or 0
  local criCoeff = skillData.criticalCoeff or 0
  if criValue > 0 and pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  if false and pro > 0 then
    pro = 1
  end
  return pro
end
function _computePetSkill_GaoJiJiShiYu()
  local skillData = _getSkillData(PETSKILL_GAOJIJISHIYU) or {}
  local param = skillData.calparam or {}
  local pro = not param[1] and 0
  if false and pro > 0 then
    pro = 1
  end
  return pro
end
function _computePetSkill_WuXingHuTi(skillId, petLv, petClose, roleType)
  local skillData = _getSkillData(skillId) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local e = param[5] or 0
  local f = param[6] or 0
  local kang = (d + petLv * e + petClose * f) / 100
  local criValue = skillData.criticalValue or 0
  local criCoeff = skillData.criticalCoeff or 0
  if criValue > 0 and kang > criValue and roleType == LOGICTYPE_PET then
    kang = criValue + (kang - criValue) * criCoeff
  end
  return a, b, c, kang, kang, kang
end
function _computePetSkill_FengMo(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_FENGMO) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or 0
  local criCoeff = skillData.criticalCoeff or 0
  if criValue > 0 and pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  if false and pro > 0 then
    pro = 1
    d = 10
  end
  return pro, d
end
function _computePetSkill_HuiChunMiaoShou()
  local skillData = _getSkillData(PETSKILL_HUICHUNMIAOSHOU) or {}
  local param = skillData.calparam or {}
  local targetNum = param[1] or 1
  local round = param[2] or 1
  return targetNum, round
end
function _computePetSkill_JueJingFengSheng()
  local skillData = _getSkillData(PETSKILL_JUEJINGFENGSHENG) or {}
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  return a, b, c
end
function _computePetSkill_ZiXuWuYou()
  local skillData = _getSkillData(PETSKILL_ZIXUWUYOU) or {}
  local param = skillData.calparam or {}
  local keepRound = param[1] or 0
  local cdRound = skillData.cd
  return keepRound, cdRound
end
function _computePetSkill_ShuangGuanQiXia()
  local skillData = _getSkillData(PETSKILL_SHUANGGUANQIXIA) or {}
  local param = skillData.calparam or {}
  return _checkDamage(param[1] or 0)
end
function _computePetSkill_ZuoNiaoShouSan()
  local skillData = _getSkillData(PETSKILL_ZUONIAOSHOUSAN) or {}
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  return a, b
end
function _computePetSkill_ChunNuanHuaKai()
  local skillData = _getSkillData(PETSKILL_CHUNNUANHUAKAI) or {}
  local param = skillData.calparam or {}
  return skillData.cd or 0, param[1] or 0
end
function _computePetSkill_ChunHuiDaDi()
  local skillData = _getSkillData(PETSKILL_CHUNHUIDADI) or {}
  local param = skillData.calparam or {}
  return param[1] or 0
end
function _computePetSkill_DuoHunSuoMing(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_DUOHUNSUOMING) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local cdRound = skillData.cd or 0
  local ggRequire = not skillData.gg and 0
  if false and 0 < (petLv * a + petClose * b) / 100 then
    return 1, c, cdRound, ggRequire
  end
  local pro = (petLv * a + petClose * b) / 100
  local criValue = skillData.criticalValue or 0
  local criCoeff = skillData.criticalCoeff or 0
  if criValue > 0 and pro > criValue and roleType == LOGICTYPE_PET then
    pro = criValue + (pro - criValue) * criCoeff
  end
  return pro, c, cdRound, ggRequire
end
function _computePetSkill_QiangHuaXuanRen(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_QIANGHUAXUANREN) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local damage = _checkDamage(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if damage > criValue and roleType == LOGICTYPE_PET then
    return _checkDamage(criValue + (damage - criValue) * criCoeff)
  else
    return damage
  end
end
function _computePetSkill_QiangHuaYiHuan(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_QIANGHUAYIHUAN) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local damage = _checkDamage(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if damage > criValue and roleType == LOGICTYPE_PET then
    return _checkDamage(criValue + (damage - criValue) * criCoeff)
  else
    return damage
  end
end
function _computePetSkill_BingLinChengXia()
  local skillData = _getSkillData(PETSKILL_BINGLINCHENGXIA) or {}
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local d = param[4] or 0
  return a, b, c, d
end
function _computePetSkill_RuHuTianYi()
  local skillData = _getSkillData(PETSKILL_RUHUTIANYI) or {}
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  return a, b
end
function _computePetSkill_NiePan(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_NIEPAN) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local pro = (a + petLv * b + petClose * c) / 100
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = not skillData.criticalCoeff and 0
  if false and pro > 0 then
    return 1
  end
  if pro > criValue and roleType == LOGICTYPE_PET then
    return criValue + (pro - criValue) * criCoeff
  else
    return pro
  end
end
function _computePetSkill_JingGuanBaiRi()
  local skillData = _getSkillData(PETSKILL_JINGGUANBAIRI) or {}
  local param = skillData.calparam or {}
  return param[1] or 0
end
function _computePetSkill_ChaoMingDianChe(petLv, petClose, roleType)
  local skillData = _getSkillData(PETSKILL_CHAOMINGDIANCHE) or {}
  roleType = roleType or LOGICTYPE_PET
  if roleType == LOGICTYPE_PET then
    local maxCloseV = skillData.maxclosev or 500000
    if petClose >= maxCloseV then
      petClose = maxCloseV
    end
  end
  local param = skillData.calparam or {}
  local a = param[1] or 0
  local b = param[2] or 0
  local c = param[3] or 0
  local sp = math.floor(a + petLv * b + petClose * c)
  local criValue = skillData.criticalValue or DefineMaxCriValue
  local criCoeff = skillData.criticalCoeff or 0
  if sp > criValue and roleType == LOGICTYPE_PET then
    return math.floor(criValue + (sp - criValue) * criCoeff)
  else
    return sp
  end
end
