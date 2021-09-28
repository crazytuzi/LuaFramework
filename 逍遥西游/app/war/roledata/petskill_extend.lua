if not PetSkillExtend then
  PetSkillExtend = {}
end
function PetSkillExtend.extend(object)
  object.petskills_ = {}
  object.petskills_cover_ = {}
  object.petskills_thieve_ = {}
  function object:initPetSkills(skillInfo, ssSkillInfo, zjSkillExpInfo)
    if type(skillInfo) ~= "table" then
      skillInfo = {}
    end
    if type(ssSkillInfo) ~= "table" then
      ssSkillInfo = {}
    end
    if type(zjSkillExpInfo) ~= "table" then
      zjSkillExpInfo = {}
    end
    object.petskills_ = {}
    object.petskills_cover_ = {}
    local tempCoverTable = {}
    for i = #ssSkillInfo, 1, -1 do
      local d = ssSkillInfo[i]
      if d > 0 and zjSkillExpInfo[d] == nil then
        local skillId = d
        local categoryId = data_getSkillCategoryId(skillId)
        if categoryId == 0 then
          object.petskills_[skillId] = true
        elseif tempCoverTable[categoryId] == nil then
          object.petskills_[skillId] = true
          tempCoverTable[categoryId] = true
        else
          object.petskills_cover_[skillId] = true
        end
      end
    end
    for i = #skillInfo, 1, -1 do
      local d = skillInfo[i]
      if d > 0 and zjSkillExpInfo[d] == nil then
        local skillId = d
        local categoryId = data_getSkillCategoryId(skillId)
        if categoryId == 0 then
          object.petskills_[skillId] = true
        elseif tempCoverTable[categoryId] == nil then
          object.petskills_[skillId] = true
          tempCoverTable[categoryId] = true
        else
          object.petskills_cover_[skillId] = true
        end
      end
    end
  end
  function object:initMonsterSkills(skillInfo)
    if type(skillInfo) ~= "table" then
      skillInfo = {}
    end
    for _, skillId in pairs(skillInfo) do
      object.petskills_[skillId] = true
    end
  end
  function object:hasLearnPetSkill(skillId)
    if object.petskills_[skillId] ~= nil then
      return true
    end
    if object.petskills_cover_[skillId] ~= nil then
      return true
    end
    return false
  end
  function object:petSkillIsActing(skillId)
    if object.petskills_[skillId] == nil then
      return false
    end
    return object:_checkBaseAttrAndState(skillId)
  end
  function object:getAllCanThievedPetSkills()
    local skillList = {}
    for skillId, _ in pairs(object.petskills_) do
      if object.petskills_thieve_[skillId] == nil then
        skillList[#skillList + 1] = skillId
      end
    end
    return skillList
  end
  function object:setThieveSkill(skillId)
    object.petskills_thieve_[skillId] = true
    object.petskills_[skillId] = true
    if _getSkillStyle(skillId) == SKILLSTYLE_INITIATIVE then
      object:setProficiency(skillId, 1)
    end
  end
  function object:resetThieveSkill(skillId)
    if object.petskills_thieve_[skillId] then
      object.petskills_thieve_[skillId] = nil
      object.petskills_[skillId] = nil
      object:setProficiency(skillId, 0)
    end
  end
  function object:getAllThieveInitiativeSkills()
    local skillList = {}
    for skillId, _ in pairs(object.petskills_thieve_) do
      if _getSkillStyle(skillId) == SKILLSTYLE_INITIATIVE then
        skillList[#skillList + 1] = skillId
      end
    end
    return skillList
  end
  function object:checkIsThieveSkill(skillId)
    return object.petskills_thieve_[skillId] ~= nil
  end
  function object:skillIsCoverByOtherSkill(skillId)
    local allSkillInfo = {}
    local zjSkillExpInfo = object:getProperty(PROPERTY_ZJSKILLSEXP)
    if type(zjSkillExpInfo) ~= "table" then
      zjSkillExpInfo = {}
    end
    local skillInfo = object:getProperty(PROPERTY_PETSKILLS)
    if type(skillInfo) == "table" then
      for _, d in ipairs(skillInfo) do
        if d > 0 and zjSkillExpInfo[d] == nil then
          allSkillInfo[#allSkillInfo + 1] = d
        end
      end
    end
    local ssskillInfo = object:getProperty(PROPERTY_SSSKILLS)
    if type(ssskillInfo) == "table" then
      for _, d in ipairs(ssskillInfo) do
        if d > 0 and zjSkillExpInfo[d] == nil then
          allSkillInfo[#allSkillInfo + 1] = d
        end
      end
    end
    local flag = false
    local categoryId = data_getSkillCategoryId(skillId)
    local coverSkill
    if categoryId > 0 then
      for _, sId in ipairs(allSkillInfo) do
        local cId = data_getSkillCategoryId(sId)
        if flag and cId == categoryId then
          coverSkill = sId
        end
        if sId == skillId then
          flag = true
        end
      end
    end
    return coverSkill
  end
  function object:_checkBaseAttrAndState(skillID)
    if object:getType() == LOGICTYPE_MONSTER then
      return true
    end
    local gg, lx, mj, ll = data_getGGLXMJLL(skillID)
    if gg > 0 then
      local ugg = object:getProperty(PROPERTY_GenGu)
      if gg > ugg then
        return false
      end
    end
    if lx > 0 then
      local ulx = object:getProperty(PROPERTY_Lingxing)
      if lx > ulx then
        return false
      end
    end
    if mj > 0 then
      local umj = object:getProperty(PROPERTY_MinJie)
      if mj > umj then
        return false
      end
    end
    if ll > 0 then
      local ull = object:getProperty(PROPERTY_LiLiang)
      if ll > ull then
        return false
      end
    end
    local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(skillID)
    if jin > 0 then
      local ujin = object:getProperty(PROPERTY_WXJIN)
      if jin > ujin then
        return false
      end
    end
    if mu > 0 then
      local umu = object:getProperty(PROPERTY_WXMU)
      if mu > umu then
        return false
      end
    end
    if shui > 0 then
      local ushui = object:getProperty(PROPERTY_WXSHUI)
      if shui > ushui then
        return false
      end
    end
    if huo > 0 then
      local uhuo = object:getProperty(PROPERTY_WXHUO)
      if huo > uhuo then
        return false
      end
    end
    if tu > 0 then
      local utu = object:getProperty(PROPERTY_WXTU)
      if tu > utu then
        return false
      end
    end
    return true
  end
  function object:GetPetSkillChangYinDongDu()
    local d = object.petskills_[PETSKILL_CHANGYINDONGDU]
    if d == nil or not object:_checkBaseAttrAndState(PETSKILL_CHANGYINDONGDU) then
      return 0
    end
    local petLv = object:getProperty(PROPERTY_ROLELEVEL)
    local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
    local addHp = _computePetSkill_ChangYinDongDu(petLv, petClose, object:getType())
    return addHp
  end
  function object:GetPetSkillYuanQuanWanHu()
    local d = object.petskills_[PETSKILL_YUANQUANWANHU]
    if d == nil or not object:_checkBaseAttrAndState(PETSKILL_YUANQUANWANHU) then
      return 0
    end
    local petLv = object:getProperty(PROPERTY_ROLELEVEL)
    local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
    local addMp = _computePetSkill_YuanQuanWanHu(petLv, petClose, object:getType())
    return addMp
  end
  function object:GetPetSkillShenGongGuiLi()
    local d = object.petskills_[PETSKILL_SHENGONGGUILI]
    if d == nil or not object:_checkBaseAttrAndState(PETSKILL_SHENGONGGUILI) then
      return 0
    end
    local petLv = object:getProperty(PROPERTY_ROLELEVEL)
    local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
    local addAp = _computePetSkill_ShenGongGuiLi(petLv, petClose, object:getType())
    return addAp
  end
  function object:GetPetSkillBeiDaoJianXing()
    if object.petskills_[PETSKILL_CHAOMINGDIANCHE] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_CHAOMINGDIANCHE) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local addSp = _computePetSkill_ChaoMingDianChe(petLv, petClose, object:getType())
        return addSp
      else
        return 0
      end
    elseif object.petskills_[PETSKILL_BEIDAOJIANXING] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_BEIDAOJIANXING) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local addSp = _computePetSkill_BeiDaoJianXing(petLv, petClose, object:getType())
        return addSp
      else
        return 0
      end
    else
      return 0
    end
  end
  function object:GetPetSkillShiSiYaoJue()
    local d = object.petskills_[PETSKILL_SHISIYAOJUE]
    if d == nil or not object:_checkBaseAttrAndState(PETSKILL_SHISIYAOJUE) then
      return 0
    end
    local petLv = object:getProperty(PROPERTY_ROLELEVEL)
    local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
    local coeff = _computePetSkill_ShiSiYaoJue(petLv, petClose, object:getType())
    return coeff
  end
  function object:GetPetSkillFenShenYaoJue()
    local d = object.petskills_[PETSKILL_FENSHENYAOJUE]
    if d == nil or not object:_checkBaseAttrAndState(PETSKILL_FENSHENYAOJUE) then
      return 0
    end
    local petLv = object:getProperty(PROPERTY_ROLELEVEL)
    local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
    local coeff = _computePetSkill_FenShenYaoJue(petLv, petClose, object:getType())
    return coeff
  end
  function object:GetPetSkillHunFeiYaoJue()
    local d = object.petskills_[PETSKILL_HUNFEIYAOJUE]
    if d == nil or not object:_checkBaseAttrAndState(PETSKILL_HUNFEIYAOJUE) then
      return 0
    end
    local petLv = object:getProperty(PROPERTY_ROLELEVEL)
    local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
    local coeff = _computePetSkill_HunFeiYaoJue(petLv, petClose, object:getType())
    return coeff
  end
  function object:GetPetSkillWanYingYaoJue()
    local d = object.petskills_[PETSKILL_WANYINGYAOJUE]
    if d == nil or not object:_checkBaseAttrAndState(PETSKILL_WANYINGYAOJUE) then
      return 0
    end
    local petLv = object:getProperty(PROPERTY_ROLELEVEL)
    local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
    local coeff = _computePetSkill_WanYingYaoJue(petLv, petClose, object:getType())
    return coeff
  end
  function object:GetPetSkillFenLieGongJi()
    if object.petskills_[PETSKILL_GAOJIFENLIEGONGJI] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_GAOJIFENLIEGONGJI) then
        local pro, num = _computePetSkill_GaoJiFenLieGongJi()
        return pro, num, PETSKILL_GAOJIFENLIEGONGJI
      else
        return 0, 0, 0
      end
    elseif object.petskills_[PETSKILL_FENLIEGONGJI] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_FENLIEGONGJI) then
        local pro, num = _computePetSkill_FenLieGongJi()
        return pro, num, PETSKILL_FENLIEGONGJI
      else
        return 0, 0, 0
      end
    else
      return 0, 0, 0
    end
  end
  function object:GetPetSkillCiWuFanBu()
    if object.petskills_[PETSKILL_GAOJICIWUFANBU] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_GAOJICIWUFANBU) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local pro, coeff = _computePetSkill_GaoJiCiWuFanBu(petLv, petClose, object:getType())
        return pro, coeff, PETSKILL_GAOJICIWUFANBU
      else
        return 0, 0, 0
      end
    elseif object.petskills_[PETSKILL_CIWUFANBU] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_CIWUFANBU) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local pro, coeff = _computePetSkill_CiWuFanBu(petLv, petClose, object:getType())
        return pro, coeff, PETSKILL_CIWUFANBU
      else
        return 0, 0, 0
      end
    else
      return 0, 0, 0
    end
  end
  function object:GetPetSkillFanBuZhiSi()
    if object.petskills_[PETSKILL_GAOJIFANBUZHISI] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_GAOJIFANBUZHISI) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local pro, coeff = _computePetSkill_GaoJiFanBuZhiSi(petLv, petClose, object:getType())
        return pro, coeff, PETSKILL_GAOJIFANBUZHISI
      else
        return 0, 0, 0
      end
    elseif object.petskills_[PETSKILL_FANBUZHISI] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_FANBUZHISI) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local pro, coeff = _computePetSkill_FanBuZhiSi(petLv, petClose, object:getType())
        return pro, coeff, PETSKILL_FANBUZHISI
      else
        return 0, 0, 0
      end
    else
      return 0, 0, 0
    end
  end
  function object:GetPetSkillXianFengDaoGu()
    if object.petskills_[PETSKILL_XIANFENGDAOGU] ~= nil and object:_checkBaseAttrAndState(PETSKILL_XIANFENGDAOGU) then
      local proHp, proMp = _computePetSkill_XianFengDaoGu()
      return proHp, proMp, PETSKILL_XIANFENGDAOGU
    else
      return 0, 0, 0
    end
  end
  function object:GetPetSkillMiaoShouRenXin()
    if object.petskills_[PETSKILL_MIAOSHOURENXIN] ~= nil and object:_checkBaseAttrAndState(PETSKILL_MIAOSHOURENXIN) then
      local proHp, proMp = _computePetSkill_MiaoShouRenXin()
      return proHp, proMp, PETSKILL_MIAOSHOURENXIN
    else
      return 0, 0, 0
    end
  end
  function object:GetPetSkillFengYin()
    if object.petskills_[PETSKILL_FENGYIN] ~= nil and object:_checkBaseAttrAndState(PETSKILL_FENGYIN) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local pro, round = _computePetSkill_FengYin(petLv, petClose, object:getType())
      return pro, round, PETSKILL_FENGYIN, 30016
    else
      return 0, 0, 0, 0
    end
  end
  function object:GetPetSkillHunLuan()
    if object.petskills_[PETSKILL_HUNLUAN] ~= nil and object:_checkBaseAttrAndState(PETSKILL_HUNLUAN) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local pro, round = _computePetSkill_HunLuan(petLv, petClose, object:getType())
      return pro, round, PETSKILL_HUNLUAN, 30011
    else
      return 0, 0, 0, 0
    end
  end
  function object:GetPetSkillZhongCheng()
    if object.petskills_[PETSKILL_ZHONGCHENG] ~= nil and object:_checkBaseAttrAndState(PETSKILL_ZHONGCHENG) then
      local coeff = _computePetSkill_ZhongCheng()
      return coeff, PETSKILL_ZHONGCHENG
    else
      return 0, 0
    end
  end
  function object:GetPetSkillDaYi()
    if object.petskills_[PETSKILL_DAYI] ~= nil and object:_checkBaseAttrAndState(PETSKILL_DAYI) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local pro, less, coeff = _computePetSkill_DaYi(petLv, petClose, object:getType())
      return pro, less, coeff, PETSKILL_DAYI
    else
      return 0, 0, 0, 0
    end
  end
  function object:GetPetSkillZiYi()
    if object.petskills_[PETSKILL_ZIYI] ~= nil and object:_checkBaseAttrAndState(PETSKILL_ZIYI) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local pro, less, coeff = _computePetSkill_ZiYi(petLv, petClose, object:getType())
      return pro, less, coeff, PETSKILL_ZIYI
    else
      return 0, 0, 0, 0
    end
  end
  function object:GetPetSkillYiChan()
    if object.petskills_[PETSKILL_YICHAN] ~= nil and object:_checkBaseAttrAndState(PETSKILL_YICHAN) then
      local coeff = _computePetSkill_YiChan()
      return coeff, PETSKILL_YICHAN
    else
      return 0, 0
    end
  end
  function object:GetPetSkillQingMingShu()
    if object.petskills_[PETSKILL_GAOJIQINGMINGSHU] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_GAOJIQINGMINGSHU) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local pro = _computePetSkill_GaoJiQingMingShu(petLv, petClose, object:getType())
        return pro, PETSKILL_GAOJIQINGMINGSHU
      else
        return 0, 0
      end
    elseif object.petskills_[PETSKILL_QINGMINGSHU] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_QINGMINGSHU) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local pro = _computePetSkill_QingMingShu(petLv, petClose, object:getType())
        return pro, PETSKILL_QINGMINGSHU
      else
        return 0, 0
      end
    else
      return 0, 0
    end
  end
  function object:GetPetSkillTuoKunShu()
    if object.petskills_[PETSKILL_GAOJITUOKUNSHU] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_GAOJITUOKUNSHU) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local pro = _computePetSkill_GaoJiTuoKunShu(petLv, petClose, object:getType())
        return pro, PETSKILL_GAOJITUOKUNSHU
      else
        return 0, 0
      end
    elseif object.petskills_[PETSKILL_TUOKUNSHU] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_TUOKUNSHU) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local pro = _computePetSkill_TuoKunShu(petLv, petClose, object:getType())
        return pro, PETSKILL_TUOKUNSHU
      else
        return 0, 0
      end
    else
      return 0, 0
    end
  end
  function object:GetPetSkillNingShenShu()
    if object.petskills_[PETSKILL_GAOJININGSHENSHU] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_GAOJININGSHENSHU) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local pro = _computePetSkill_GaoJiNingShenShu(petLv, petClose, object:getType())
        return pro, PETSKILL_GAOJININGSHENSHU
      else
        return 0, 0
      end
    elseif object.petskills_[PETSKILL_NINGSHENSHU] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_NINGSHENSHU) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local pro = _computePetSkill_NingShenShu(petLv, petClose, object:getType())
        return pro, PETSKILL_NINGSHENSHU
      else
        return 0, 0
      end
    else
      return 0, 0
    end
  end
  function object:GetPetSkillJinGangBuHuai()
    if object.petskills_[PETSKILL_JINGANGBUHUAI] ~= nil and object:_checkBaseAttrAndState(PETSKILL_JINGANGBUHUAI) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local pro = _computePetSkill_JinGangBuHuai(petLv, petClose, object:getType())
      return pro
    else
      return 0
    end
  end
  function object:GetPetSkillZhongBuBiWei()
    if object.petskills_[PETSKILL_ZHONGBUBIWEI] ~= nil and object:_checkBaseAttrAndState(PETSKILL_ZHONGBUBIWEI) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local pro = _computePetSkill_ZhongBuBiWei(petLv, petClose, object:getType())
      return pro, PETSKILL_ZHONGBUBIWEI
    else
      return 0, 0
    end
  end
  function object:GetPetSkillYiTuiWeiJin()
    if object.petskills_[PETSKILL_JINTUIZIRU] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_JINTUIZIRU) then
        return _computePetSkill_JinTuiZiRu()
      else
        return 0, 0, 0
      end
    elseif object.petskills_[PETSKILL_YITUIWEIJIN] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_YITUIWEIJIN) then
        return _computePetSkill_YiTuiWeiJin()
      else
        return 0, 0, 0
      end
    else
      return 0, 0, 0
    end
  end
  function object:GetPetSkillPanShan()
    local d = object.petskills_[PETSKILL_PANSHAN]
    if d == nil or not object:_checkBaseAttrAndState(PETSKILL_PANSHAN) then
      return 0
    end
    local petLv = object:getProperty(PROPERTY_ROLELEVEL)
    local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
    local subSp = _computePetSkill_PanShan(petLv, petClose, object:getType())
    return subSp
  end
  function object:GetPetSkillNuXian()
    local d = object.petskills_[PETSKILL_NUXIAN]
    if d == nil or not object:_checkBaseAttrAndState(PETSKILL_NUXIAN) then
      return 0
    end
    local petLv = object:getProperty(PROPERTY_ROLELEVEL)
    local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
    local pro = _computePetSkill_NuXian(petLv, petClose, object:getType())
    return pro
  end
  function object:GetPetSkillHenXian()
    local d = object.petskills_[PETSKILL_HENXIAN]
    if d == nil or not object:_checkBaseAttrAndState(PETSKILL_HENXIAN) then
      return 0
    end
    local petLv = object:getProperty(PROPERTY_ROLELEVEL)
    local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
    local pro = _computePetSkill_HenXian(petLv, petClose, object:getType())
    return pro
  end
  function object:GetPetSkillDaoQiangBuRu()
    local d = object.petskills_[PETSKILL_DAOQIANGBURU]
    if d == nil or not object:_checkBaseAttrAndState(PETSKILL_DAOQIANGBURU) then
      return 0
    end
    local petLv = object:getProperty(PROPERTY_ROLELEVEL)
    local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
    local def = _computePetSkill_DaoQiangBuRu(petLv, petClose, object:getType())
    return def
  end
  function object:GetPetSkillFuShang()
    if object.petskills_[PETSKILL_FUSHANG] ~= nil and object:_checkBaseAttrAndState(PETSKILL_FUSHANG) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local pro, coeff = _computePetSkill_FuShang(petLv, petClose, object:getType())
      return pro, coeff, PETSKILL_FUSHANG
    else
      return 0, 0, 0
    end
  end
  function object:GetPetSkillLangYueQingFeng()
    local d = object.petskills_[PETSKILL_LANGYUEQINGFENG]
    if d == nil or not object:_checkBaseAttrAndState(PETSKILL_LANGYUEQINGFENG) then
      return 0, 0, 0
    end
    local petLv = object:getProperty(PROPERTY_ROLELEVEL)
    local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
    return _computePetSkill_LangYueQingFeng(petLv, petClose, object:getType())
  end
  function object:GetPetSkillYiHuan()
    if object.petskills_[PETSKILL_QIANGHUAYIHUAN] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_QIANGHUAYIHUAN) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local damage = _computePetSkill_QiangHuaYiHuan(petLv, petClose, object:getType())
        return damage, PETSKILL_QIANGHUAYIHUAN
      else
        return 0, 0
      end
    elseif object.petskills_[PETSKILL_YIHUAN] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_YIHUAN) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local damage = _computePetSkill_YiHuan(petLv, petClose, object:getType())
        return damage, PETSKILL_YIHUAN
      else
        return 0, 0
      end
    else
      return 0, 0
    end
  end
  function object:GetPetSkillXuanRen()
    if object.petskills_[PETSKILL_QIANGHUAXUANREN] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_QIANGHUAXUANREN) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local damage = _computePetSkill_QiangHuaXuanRen(petLv, petClose, object:getType())
        return damage, PETSKILL_QIANGHUAXUANREN
      else
        return 0, 0
      end
    elseif object.petskills_[PETSKILL_XUANREN] ~= nil then
      if object:_checkBaseAttrAndState(PETSKILL_XUANREN) then
        local petLv = object:getProperty(PROPERTY_ROLELEVEL)
        local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
        local damage = _computePetSkill_XuanRen(petLv, petClose, object:getType())
        return damage, PETSKILL_XUANREN
      else
        return 0, 0
      end
    else
      return 0, 0
    end
  end
  function object:GetPetSkillRenLaiFeng()
    if object.petskills_[PETSKILL_RENLAIFENG] ~= nil and object:_checkBaseAttrAndState(PETSKILL_RENLAIFENG) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local pro, damage = _computePetSkill_RenLaiFeng(petLv, petClose, object:getType())
      return pro, damage, PETSKILL_RENLAIFENG
    else
      return 0, 0, 0
    end
  end
  function object:GetPetSkillTaoMing()
    local d = object.petskills_[PETSKILL_TAOMING]
    if d == nil or not object:_checkBaseAttrAndState(PETSKILL_TAOMING) then
      return 0, 0
    end
    local petLv = object:getProperty(PROPERTY_ROLELEVEL)
    local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
    return _computePetSkill_TaoMing(petLv, petClose, object:getType()), PETSKILL_TAOMING
  end
  function object:GetPetSkillHuiYuan()
    if object.petskills_[PETSKILL_HUIYUAN] ~= nil and object:_checkBaseAttrAndState(PETSKILL_HUIYUAN) then
      local pro, coeff = _computePetSkill_HuiYuan()
      return pro, coeff, PETSKILL_HUIYUAN
    else
      return 0, 0, 0
    end
  end
  function object:GetPetSkillBaoFu()
    if object.petskills_[PETSKILL_BAOFU] ~= nil and object:_checkBaseAttrAndState(PETSKILL_BAOFU) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local pro, damage = _computePetSkill_BaoFu(petLv, petClose, object:getType())
      return pro, damage, PETSKILL_BAOFU
    else
      return 0, 0, 0
    end
  end
  function object:GetPetSkillYingJiChangKong()
    if object.petskills_[PETSKILL_YINGJICHANGKONG] ~= nil and object:_checkBaseAttrAndState(PETSKILL_YINGJICHANGKONG) then
      local round, targetNum, coeff, llRequire = _computePetSkill_YingJiChangKong()
      return round, targetNum, coeff, llRequire, PETSKILL_YINGJICHANGKONG
    else
      return 0, 0, 0, 0, 0
    end
  end
  function object:GetPetSkillLiuAnHuaMing()
    if object.petskills_[PETSKILL_LIUANHUAMING] ~= nil and object:_checkBaseAttrAndState(PETSKILL_LIUANHUAMING) then
      local kang = _computePetSkill_LiuAnHuaMing()
      return kang, PETSKILL_LIUANHUAMING
    else
      return 0, 0
    end
  end
  function object:GetPetSkillShunShuiTuiZhou()
    if object.petskills_[PETSKILL_SHUNSHUITUIZHOU] ~= nil and object:_checkBaseAttrAndState(PETSKILL_SHUNSHUITUIZHOU) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local pro, round, coeff_1, coeff_2 = _computePetSkill_ShunShuiTuiZhou(petLv, petClose, object:getType())
      return pro, round, coeff_1, coeff_2, PETSKILL_SHUNSHUITUIZHOU
    else
      return 0, 0, 0, 0, 0
    end
  end
  function object:GetPetSkillFenHuaFuLiu()
    if object.petskills_[PETSKILL_FENHUAFULIU] ~= nil and object:_checkBaseAttrAndState(PETSKILL_FENHUAFULIU) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local pro = _computePetSkill_FenHuaFuLiu(petLv, petClose, object:getType())
      return pro, PETSKILL_FENHUAFULIU
    else
      return 0, 0
    end
  end
  function object:GetPetSkillFuLuShuangQuan()
    if object.petskills_[PETSKILL_FULUSHUANGQUAN] ~= nil and object:_checkBaseAttrAndState(PETSKILL_FULUSHUANGQUAN) then
      local kang = _computePetSkill_FuLuShuangQuan()
      return kang, PETSKILL_FULUSHUANGQUAN
    else
      return 0, 0
    end
  end
  function object:GetPetSkillJiRenTianXiang()
    if object.petskills_[PETSKILL_JIRENTIANXIANG] ~= nil and object:_checkBaseAttrAndState(PETSKILL_JIRENTIANXIANG) then
      local hp = _computePetSkill_JiRenTianXiang()
      return hp, PETSKILL_JIRENTIANXIANG
    else
      return 0, 0
    end
  end
  function object:GetPetSkillZhiNanErTui()
    if object.petskills_[PETSKILL_ZHINANERTUI] ~= nil and object:_checkBaseAttrAndState(PETSKILL_ZHINANERTUI) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local pro, coeff, round = _computePetSkill_ZhiNanErTui(petLv, petClose, object:getType())
      return pro, coeff, round, PETSKILL_ZHINANERTUI
    else
      return 0, 0, 0, 0
    end
  end
  function object:GetPetShunShouQianYang()
    if object.petskills_[PETSKILL_SHUNSHOUQIANYANG] ~= nil and object:_checkBaseAttrAndState(PETSKILL_SHUNSHOUQIANYANG) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local pro = _computePetSkill_ShunShouQianYang(petLv, petClose, object:getType())
      return pro, PETSKILL_SHUNSHOUQIANYANG
    else
      return 0, 0
    end
  end
  function object:GetPetSkillDaoZhuanQianKun()
    if object.petskills_[PETSKILL_DAOZHUANQIANKUN] ~= nil and object:_checkBaseAttrAndState(PETSKILL_DAOZHUANQIANKUN) then
      return PETSKILL_DAOZHUANQIANKUN
    else
      return 0
    end
  end
  function object:GetPetSkillTanHuaYiXian()
    if object.petskills_[PETSKILL_TANHUAYIXIAN] ~= nil and object:_checkBaseAttrAndState(PETSKILL_TANHUAYIXIAN) then
      return PETSKILL_TANHUAYIXIAN
    else
      return 0
    end
  end
  function object:GetPetSkillWuXingHuTi(skillId)
    if object.petskills_[skillId] ~= nil and object:_checkBaseAttrAndState(skillId) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local k1, k2, k3, k_frozen, k_confuse, k_yiwang = _computePetSkill_WuXingHuTi(skillId, petLv, petClose, object:getType())
      return {
        k1,
        k2,
        k3,
        k_frozen,
        k_confuse,
        k_yiwang
      }
    else
      return nil
    end
  end
  function object:GetPetSkillHuaWu()
    if object.petskills_[PETSKILL_HUAWU] ~= nil and object:_checkBaseAttrAndState(PETSKILL_HUAWU) then
      return 30056
    else
      return 0
    end
  end
  function object:GetPetSkillJiangSi()
    if object.petskills_[PETSKILL_JIANGSI] ~= nil and object:_checkBaseAttrAndState(PETSKILL_JIANGSI) then
      return PETSKILL_JIANGSI
    else
      return 0
    end
  end
  function object:GetPetSkillDangTouBangHe()
    if object.petskills_[PETSKILL_DANGTOUBANGHE] ~= nil and object:_checkBaseAttrAndState(PETSKILL_DANGTOUBANGHE) then
      return PETSKILL_DANGTOUBANGHE
    else
      return 0
    end
  end
  function object:GetPetSkillMingChaQiuHao()
    if object.petskills_[PETSKILL_MINGCHAQIUHAO] ~= nil and object:_checkBaseAttrAndState(PETSKILL_MINGCHAQIUHAO) then
      return true
    else
      return false
    end
  end
  function object:GetPetSkillShuangGuanQiXia()
    if object.petskills_[PETSKILL_SHUANGGUANQIXIA] ~= nil and object:_checkBaseAttrAndState(PETSKILL_SHUANGGUANQIXIA) then
      local hp = _computePetSkill_ShuangGuanQiXia()
      return hp, PETSKILL_SHUANGGUANQIXIA
    else
      return 0, 0
    end
  end
  function object:GetPetSkillZuoNiaoShouSan()
    if object.petskills_[PETSKILL_ZUONIAOSHOUSAN] ~= nil and object:_checkBaseAttrAndState(PETSKILL_ZUONIAOSHOUSAN) then
      local hpCoeff, mpCoeff = _computePetSkill_ZuoNiaoShouSan()
      return hpCoeff, mpCoeff, PETSKILL_ZUONIAOSHOUSAN
    else
      return 0, 0, 0
    end
  end
  function object:GetPetSkillYiYaHuanYa()
    if object.petskills_[PETSKILL_YIYAHUANYA] ~= nil and object:_checkBaseAttrAndState(PETSKILL_YIYAHUANYA) then
      return PETSKILL_YIYAHUANYA
    else
      return 0
    end
  end
  function object:GetPetSkillBingLinChengXia()
    if object.petskills_[PETSKILL_BINGLINCHENGXIA] ~= nil and object:_checkBaseAttrAndState(PETSKILL_BINGLINCHENGXIA) then
      local pro, hpcoeff, mpcoeff, apcoeff = _computePetSkill_BingLinChengXia(petLv, petClose)
      return pro, hpcoeff, mpcoeff, apcoeff, PETSKILL_BINGLINCHENGXIA
    else
      return 0, 0, 0, 0, 0
    end
  end
  function object:GetPetSkillRuHuTianYi()
    if object.petskills_[PETSKILL_RUHUTIANYI] ~= nil and object:_checkBaseAttrAndState(PETSKILL_RUHUTIANYI) then
      local round, effSkillId = _computePetSkill_RuHuTianYi()
      return round, effSkillId, PETSKILL_RUHUTIANYI
    else
      return 0, 0, 0
    end
  end
  function object:GetPetSkillNiePan()
    if object.petskills_[PETSKILL_NIEPAN] ~= nil and object:_checkBaseAttrAndState(PETSKILL_NIEPAN) then
      local petLv = object:getProperty(PROPERTY_ROLELEVEL)
      local petClose = object:getProperty(PROPERTY_CLOSEVALUE)
      local pro = _computePetSkill_NiePan(petLv, petClose, object:getType())
      return pro, PETSKILL_NIEPAN
    else
      return 0, 0
    end
  end
  function object:GetPetSkillJingGuanBaiRi()
    if object.petskills_[PETSKILL_JINGGUANBAIRI] ~= nil and object:_checkBaseAttrAndState(PETSKILL_JINGGUANBAIRI) then
      local coeff = _computePetSkill_JingGuanBaiRi()
      return coeff, PETSKILL_JINGGUANBAIRI
    else
      return 0, 0
    end
  end
  function object:getPetSkillSerialization()
    local cloneSkills = {}
    for k, v in pairs(object.petskills_) do
      cloneSkills[k] = v
    end
    local cloneSkills_cover = {}
    for k, v in pairs(object.petskills_cover_) do
      cloneSkills_cover[k] = v
    end
    return {cloneSkills, cloneSkills_cover}
  end
  function object:setPetSkillSerialization(proSerialization)
    local cloneSkills, cloneSkills_cover = proSerialization[1], proSerialization[2]
    object.petskills_ = {}
    if cloneSkills then
      for k, v in pairs(cloneSkills) do
        object.petskills_[k] = v
      end
    end
    object.petskills_cover_ = {}
    if cloneSkills_cover then
      for k, v in pairs(cloneSkills_cover) do
        object.petskills_cover_[k] = v
      end
    end
  end
end
