if not CPetData then
  CPetData = class("CPetData", CRoleData)
end
function CPetData:ctor(playerId, objId, lTypeId, copyProperties)
  CPetData.super.ctor(self, playerId, objId, lTypeId, copyProperties)
end
function CPetData:CalculateProperty()
  local pairs = pairs
  self:initPetSkills(self:getProperty(PROPERTY_PETSKILLS), self:getProperty(PROPERTY_SSSKILLS), self:getProperty(PROPERTY_ZJSKILLSEXP))
  for _, v in pairs(PROPERTY_LEVEL_WUXING) do
    self:setProperty(v, data_getRoleProFromData(self.m_LtypeId, v))
  end
  for i, v in pairs({
    PROPERTY_RACE,
    PROPERTY_SHAPE,
    PROPERTY_SKILLNO,
    PROPERTY_TITLELV,
    PROPERTY_COMCOE,
    PROPERTY_PETTYPE
  }) do
    self:setProperty(v, data_getRoleProFromData(self.m_LtypeId, v))
  end
  local hjGrowup = 0
  local hjAddhp = 0
  local hjAddmp = 0
  local hjAddap = 0
  local hjAddsp = 0
  if data_getPetTypeIsCanHuaJing(self:getTypeId()) then
    local hjNum = self:getProperty(PROPERTY_HUAJING_NUM)
    if hjNum == 1 then
      hjGrowup = data_Variables.SS_HuaJing1_AddCZL or 0.05
    elseif hjNum == 2 then
      hjGrowup = (data_Variables.SS_HuaJing1_AddCZL or 0.05) + (data_Variables.SS_HuaJing2_AddCZL or 0.1)
    elseif hjNum == 3 then
      hjGrowup = (data_Variables.SS_HuaJing1_AddCZL or 0.05) + (data_Variables.SS_HuaJing2_AddCZL or 0.1)
      local hjAddProNum = self:getProperty(PROPERTY_HUAJING_ADDPRONUM)
      local tempAddNum = data_Variables.SS_HuaJing3_AddProNum or 60
      if hjAddProNum == SHENSHOU_HUAJING3_ADDHP_INDEX then
        hjAddhp = tempAddNum
      elseif hjAddProNum == SHENSHOU_HUAJING3_ADDMP_INDEX then
        hjAddmp = tempAddNum
      elseif hjAddProNum == SHENSHOU_HUAJING3_ADDAP_INDEX then
        hjAddap = tempAddNum
      elseif hjAddProNum == SHENSHOU_HUAJING3_ADDSP_INDEX then
        hjAddsp = tempAddNum
      end
    end
  end
  self:setProperty(PROPERTY_HUAJING_ADDHP, hjAddhp)
  self:setProperty(PROPERTY_HUAJING_ADDMP, hjAddmp)
  self:setProperty(PROPERTY_HUAJING_ADDAP, hjAddap)
  self:setProperty(PROPERTY_HUAJING_ADDSP, hjAddsp)
  local hlGrowup = 0
  if data_getPetTypeIsCanHuaLing(self:getTypeId()) then
    local hlNum = self:getProperty(PROPERTY_HUALING_NUM)
    for huaLingIndex = 1, LINGSHOU_HUALING_MAX_NUM do
      if huaLingIndex <= hlNum then
        hlGrowup = hlGrowup + data_LingShouHuaLing[huaLingIndex].addCZL
      end
    end
  end
  local growup = self:getProperty(PROPERTY_RANDOM_GROWUP) + self:getProperty(PROPERTY_ZHUANSHENG) * 0.1 + self:getProperty(PROPERTY_LONGGU_NUM) * 0.01 + hjGrowup + hlGrowup
  self:setProperty(PROPERTY_GROWUP, growup)
  local lv = self:getProperty(PROPERTY_ROLELEVEL)
  local starValue = 1
  self:setProperty(PROPERTY_STARSKILLVALUE, starValue)
  self:CheckZhuangBeiCanUse()
  local gg = self:getProperty(PROPERTY_OGenGu) + self:GetZhuangBeiAddNum(PROPERTY_GenGu)
  self:setProperty(PROPERTY_GenGu, gg)
  local lx = self:getProperty(PROPERTY_OLingxing) + self:GetZhuangBeiAddNum(PROPERTY_Lingxing)
  self:setProperty(PROPERTY_Lingxing, lx)
  local ll = self:getProperty(PROPERTY_OLiLiang) + self:GetZhuangBeiAddNum(PROPERTY_LiLiang)
  self:setProperty(PROPERTY_LiLiang, ll)
  local mj = self:getProperty(PROPERTY_OMinJie) + self:GetZhuangBeiAddNum(PROPERTY_MinJie)
  self:setProperty(PROPERTY_MinJie, mj)
  local hp = CalculateRoleHP(self)
  self:setProperty(PROPERTY_HP, hp)
  local curHp = self:getProperty(PROPERTY_INIT_HP)
  if curHp ~= nil and curHp ~= 0 then
    if hp < curHp then
      curHp = hp
    end
    self:setProperty(PROPERTY_HP, curHp)
  end
  self:setMaxProperty(PROPERTY_HP, hp)
  local mp = CalculateRoleMP(self)
  self:setProperty(PROPERTY_MP, mp)
  local curMp = self:getProperty(PROPERTY_INIT_MP)
  if curMp ~= nil and curMp ~= 0 then
    if mp < curMp then
      curMp = mp
    end
    self:setProperty(PROPERTY_MP, curMp)
  end
  self:setMaxProperty(PROPERTY_MP, mp)
  local ap = CalculateRoleAP(self)
  self:setProperty(PROPERTY_AP, ap)
  local sp = CalculateRoleSP(self)
  self:setProperty(PROPERTY_SP, sp)
  self:setMaxProperty(PROPERTY_SP, sp)
  local data_table = data_Pet[self:getTypeId()]
  if data_table ~= nil and data_table.skills[1] ~= nil and data_table.skills[1] ~= 0 then
    if self:getTypeId() == PETTYPE_HUAZHONGXIAN then
      if _getSkillStyle(data_table.skills[1]) == SKILLSTYLE_PASSIVE then
        self:setBDProficiency(data_table.skills[1], 1)
      else
        self:setProficiency(data_table.skills[1], 1)
      end
      if data_table.skills[2] ~= nil and data_table.skills[2] ~= 0 then
        if _getSkillStyle(data_table.skills[2]) == SKILLSTYLE_PASSIVE then
          self:setBDProficiency(data_table.skills[2], 1)
        else
          self:setProficiency(data_table.skills[2], 1)
        end
      end
    else
      if lv >= Skill_PetSkill1OpenLv then
        self:setProficiency(data_table.skills[1], 1)
      end
      if lv >= Skill_PetSkill2OpenLv and data_table.skills[2] ~= nil and data_table.skills[2] ~= 0 then
        self:setProficiency(data_table.skills[2], 1)
      end
    end
  end
  for i, v in pairs({
    PROPERTY_PDEFEND,
    PROPERTY_KHUO,
    PROPERTY_KSHUI,
    PROPERTY_KFENG,
    PROPERTY_KLEI,
    PROPERTY_KZHENSHE,
    PROPERTY_KFENGYIN,
    PROPERTY_KHUNLUAN,
    PROPERTY_KZHONGDU,
    PROPERTY_KHUNSHUI,
    PROPERTY_KYIWANG,
    PROPERTY_KAIHAO,
    PROPERTY_KXIXUE
  }) do
    self:setProperty(v, data_getRoleProFromData(self.m_LtypeId, v) + self:GetRandomKangByName(v) + self:GetZhuangBeiAddNum(v) + self:getProperty(PET_LIANHUA_KANG_DICT[v]))
  end
  for i, v in pairs({
    PROPERTY_FPDEFEND,
    PROPERTY_FKHUO,
    PROPERTY_FKSHUI,
    PROPERTY_FKFENG,
    PROPERTY_FKLEI,
    PROPERTY_FKFENGYIN,
    PROPERTY_FKHUNLUAN,
    PROPERTY_FKZHONGDU,
    PROPERTY_FKHUNSHUI,
    PROPERTY_FKZHENSHE,
    PROPERTY_FKSHUAIRUO,
    PROPERTY_FKXIXUE,
    PROPERTY_FKAIHAO,
    PROPERTY_FKYIWANG
  }) do
    self:setProperty(v, data_getRoleProFromData(self.m_LtypeId, v) + self:GetZhuangBeiAddNum(v))
  end
  for i, v in pairs({
    PROPERTY_PACC,
    PROPERTY_PSBL,
    PROPERTY_PFYL,
    PROPERTY_PCRIT,
    PROPERTY_FPCRIT,
    PROPERTY_PKUANGBAO,
    PROPERTY_PLJPRO,
    PROPERTY_PLJTIMES,
    PROPERTY_FTPRO,
    PROPERTY_FTLV,
    PROPERTY_PKFTLV,
    PROPERTY_PWLFJPRO,
    PROPERTY_PWLFJTIMES,
    PROPERTY_PFSBL,
    PROPERTY_PFWLFJPRO,
    PROPERTY_QHSH,
    PROPERTY_HFQX,
    PROPERTY_HFFL,
    PROPERTY_DEL_DU,
    PROPERTY_DEL_ZHEN
  }) do
    self:setProperty(v, data_getRoleProFromData(self.m_LtypeId, v) + self:GetZhuangBeiAddNum(v))
  end
  local zmpro = self:GetPetSkillJinGangBuHuai()
  if zmpro > 0 then
    self:setProperty(PROPERTY_FPCRIT, self:getProperty(PROPERTY_FPCRIT) + zmpro)
  end
  local def = self:GetPetSkillDaoQiangBuRu()
  if def > 0 then
    self:setProperty(PROPERTY_PFYL, self:getProperty(PROPERTY_PFYL) + def)
  end
  local petClose = self:getProperty(PROPERTY_CLOSEVALUE)
  local maxNum = #data_PetClose
  local addLJRate = 0
  local addLJTimes = 0
  local addZMRate = 0
  for i = maxNum, 1, -1 do
    local closeData = data_PetClose[i]
    if closeData ~= nil and petClose >= closeData.closeValue then
      addLJRate = closeData.addLJRate
      addLJTimes = closeData.addLJTimes
      addZMRate = closeData.addZMRate
      break
    end
  end
  self:setProperty(PROPERTY_PLJPRO, self:getProperty(PROPERTY_PLJPRO) + addLJRate)
  self:setProperty(PROPERTY_PLJTIMES, self:getProperty(PROPERTY_PLJTIMES) + addLJTimes)
  self:setProperty(PROPERTY_PCRIT, self:getProperty(PROPERTY_PCRIT) + addZMRate)
  for _, proName in pairs(PROPERTY_STRENGTHEN_MAGIC) do
    self:setProperty(proName, data_getRoleProFromData(self.m_LtypeId, proName) + self:GetZhuangBeiAddNum(proName))
  end
  for _, proName in pairs(PROPERTY_KANGNEIDAN) do
    self:setProperty(proName, data_getRoleProFromData(self.m_LtypeId, proName) + self:GetZhuangBeiAddNum(proName))
  end
  for _, proName in pairs(PROPERTY_KANGNEIDAN) do
    self:setProperty(proName, data_getRoleProFromData(self.m_LtypeId, proName) + self:GetZhuangBeiAddNum(proName))
  end
  for _, proName in pairs(PROPERTY_PASSIVE_USEMAGIC) do
    self:setProperty(proName, data_getRoleProFromData(self.m_LtypeId, proName) + self:GetZhuangBeiAddNum(proName))
  end
  for neidanId, proName in pairs(NEIDAN_ITEM_TO_PRO_TABLE) do
    local neidanObj = self:GetNeidanObj(neidanId)
    local temp = g_NeiDanSkill.getNeiDanCoefficient(self, neidanObj)
    self:setProperty(proName, temp)
  end
  local useSkillList = self:getUseSkillList()
  local needSave = false
  for _, petSkill in pairs(ACTIVE_PETSKILLLIST) do
    if self.petskills_[petSkill] ~= nil then
      self:setProficiency(petSkill, 1)
    else
      self:setProficiency(petSkill, 0)
      if useSkillList ~= 0 then
        for i, skillId in pairs(useSkillList) do
          if skillId == petSkill then
            table.remove(useSkillList, i)
            needSave = true
            break
          end
        end
      end
    end
  end
  for _, ndItemId in pairs(NEIDAN_MOJIE_ITEMLIST) do
    local ndSkillId = NEIDAN_ITEM_TO_SKILL_TABLE[ndItemId]
    if ndSkillId ~= nil then
      if self:GetNeidanObj(ndItemId) ~= nil then
        self:setProficiency(ndSkillId, 1)
      else
        self:setProficiency(ndSkillId, 0)
        if useSkillList ~= 0 then
          for i, skillId in pairs(useSkillList) do
            if skillId == ndSkillId then
              table.remove(useSkillList, i)
              needSave = true
              break
            end
          end
        end
      end
    end
  end
  if needSave then
    self:setProperty(PROPERTY_USESKILLLIST, useSkillList)
    local player = WarAIGetOnePlayerData(self:getWarID(), self:getPlayerId())
    if player and player.SaveRoleProperty then
      player:SaveRoleProperty(self:getObjId(), PROPERTY_USESKILLLIST, useSkillList, true)
    end
  end
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_FENG_RATE, g_NeiDanSkill.getNeiDanPro_ChengFengPoLang(self))
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_FENG, ITEM_DEF_SKILL_FENG_4)
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_LEI_RATE, g_NeiDanSkill.getNeiDanPro_PiLiLiuXing(self))
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_LEI, ITEM_DEF_SKILL_LEI_4)
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_SHUI_RATE, g_NeiDanSkill.getNeiDanPro_DaHaiWuLiang(self))
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_SHUI, ITEM_DEF_SKILL_SHUI_4)
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_HUO_RATE, g_NeiDanSkill.getNeiDanPro_ZhuRongQuHuo(self))
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_HUO, ITEM_DEF_SKILL_HUO_4)
  local rate, effect = g_NeiDanSkill.getNeiDanPro_HongYanBaiFa(self)
  local addRate = self:GetPetSkillNuXian()
  rate = rate + addRate
  for rateName, effectName in pairs({
    [PROPERTY_MAGICKUANGBAO_SHUI_RATE] = PROPERTY_MAGICKUANGBAO_SHUI,
    [PROPERTY_MAGICKUANGBAO_HUO_RATE] = PROPERTY_MAGICKUANGBAO_HUO,
    [PROPERTY_MAGICKUANGBAO_FENG_RATE] = PROPERTY_MAGICKUANGBAO_FENG,
    [PROPERTY_MAGICKUANGBAO_LEI_RATE] = PROPERTY_MAGICKUANGBAO_LEI
  }) do
    self:setProperty(rateName, rate)
    self:setProperty(effectName, effect)
  end
  local rate, effect = g_NeiDanSkill.getNeiDanPro_MeiHuaSanNong(self)
  self:setProperty(PROPERTY_NEIDAN_MHSN_EFFECTRATE, rate)
  self:setProperty(PROPERTY_NEIDAN_MHSN_EFFECT, effect)
  local rate, effect = g_NeiDanSkill.getNeiDanPro_KaiTianPiDi(self)
  local effectAdd = self:GetPetSkillHenXian()
  effect = effect + effectAdd
  self:setProperty(PROPERTY_NEIDAN_KTPD_EFFECTRATE, rate)
  self:setProperty(PROPERTY_NEIDAN_KTPD_EFFECT, effect)
  local rate, effect = g_NeiDanSkill.getNeiDanPro_WanFoChaoZong(self)
  self:setProperty(PROPERTY_NEIDAN_WFCZ_EFFECTRATE, rate)
  self:setProperty(PROPERTY_NEIDAN_WFCZ_EFFECT, effect)
  local rate, effect = g_NeiDanSkill.getNeiDanPro_HaoRanZhengQi(self)
  self:setProperty(PROPERTY_NEIDAN_HRZQ_EFFECTRATE, rate)
  self:setProperty(PROPERTY_NEIDAN_HRZQ_EFFECT, effect)
  local pfsbl, pfwlfjpro = g_NeiDanSkill.getNeiDanPro_AnDuChenCang(self)
  self:setProperty(PROPERTY_PFSBL, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PFSBL) + pfsbl)
  self:setProperty(PROPERTY_PFWLFJPRO, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PFWLFJPRO) + pfwlfjpro)
  local pwlfjpro, pwlftimes = g_NeiDanSkill.getNeiDanPro_JieLiDaLi(self)
  self:setProperty(PROPERTY_PWLFJPRO, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PWLFJPRO) + pwlfjpro)
  self:setProperty(PROPERTY_PWLFJTIMES, math.min(data_getRoleProFromData(self.m_LtypeId, PROPERTY_PWLFJTIMES) + pwlftimes, MAX_PET_PLJTIMES_NUM))
  local psbl = g_NeiDanSkill.getNeiDanPro_LingBoWeiBu(self)
  self:setProperty(PROPERTY_PSBL, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PSBL) + psbl)
  local rate, effect = g_NeiDanSkill.getNeiDanPro_GeShanDaNiu(self)
  self:setProperty(PROPERTY_NEIDAN_GSDN_EFFECTRATE, rate)
  self:setProperty(PROPERTY_NEIDAN_GSDN_EFFECT, effect)
  for i, v in pairs({
    PROPERTY_PDEFEND,
    PROPERTY_KHUO,
    PROPERTY_KSHUI,
    PROPERTY_KFENG,
    PROPERTY_KLEI,
    PROPERTY_KZHENSHE,
    PROPERTY_KFENGYIN,
    PROPERTY_KHUNLUAN,
    PROPERTY_KZHONGDU,
    PROPERTY_KHUNSHUI,
    PROPERTY_KYIWANG,
    PROPERTY_KAIHAO
  }) do
    self:setProperty(v, math.min(MAX_KANG_PET_NOMANAGE_VALUE, self:getProperty(v)))
  end
  local beManageFlag = false
  local playerId = self:getPlayerId()
  local player = WarAIGetOnePlayerData(self:getWarID(), self:getPlayerId())
  if player and player.getPetAddZQSkillDataForWar and player.getZuoqiByPetIdForWar then
    local zqId = player:getZuoqiByPetIdForWar(self.m_Id)
    if zqId ~= 0 then
      beManageFlag = true
    end
    local addDict = player:getPetAddZQSkillDataForWar(self.m_Id)
    for proName, proValue in pairs(addDict) do
      if proName ~= PROPERTY_HP and proName ~= PROPERTY_MP and proName ~= PROPERTY_SP and proName ~= PROPERTY_AP then
        self:setProperty(proName, self:getProperty(proName) + proValue)
      end
    end
  end
  for i, v in pairs({
    PROPERTY_PDEFEND,
    PROPERTY_KHUO,
    PROPERTY_KSHUI,
    PROPERTY_KFENG,
    PROPERTY_KLEI,
    PROPERTY_KZHENSHE,
    PROPERTY_KFENGYIN,
    PROPERTY_KHUNLUAN,
    PROPERTY_KZHONGDU,
    PROPERTY_KHUNSHUI,
    PROPERTY_KYIWANG,
    PROPERTY_KAIHAO
  }) do
    if beManageFlag then
      if v == PROPERTY_KFENGYIN or v == PROPERTY_KHUNLUAN or v == PROPERTY_KZHONGDU or v == PROPERTY_KHUNSHUI then
        self:setProperty(v, math.min(MAX_KANG_PET_MANAGE_REN_VALUE, self:getProperty(v)))
      elseif v == PROPERTY_KYIWANG then
        self:setProperty(v, math.min(MAX_KANG_PET_MANAGE_YIWANG_VALUE, self:getProperty(v)))
      else
        self:setProperty(v, math.min(MAX_KANG_PET_MANAGE_NOREN_VALUE, self:getProperty(v)))
      end
    else
      self:setProperty(v, math.min(MAX_KANG_PET_NOMANAGE_VALUE, self:getProperty(v)))
    end
  end
  local fyAddPro, hlAddPro, ywAddPro = self:GetPetSkillLangYueQingFeng()
  if fyAddPro > 0 then
    self:setProperty(PROPERTY_KFENGYIN, self:getProperty(PROPERTY_KFENGYIN) + fyAddPro)
  end
  if hlAddPro > 0 then
    self:setProperty(PROPERTY_KHUNLUAN, self:getProperty(PROPERTY_KHUNLUAN) + hlAddPro)
  end
  if ywAddPro > 0 then
    self:setProperty(PROPERTY_KYIWANG, self:getProperty(PROPERTY_KYIWANG) + ywAddPro)
  end
  local xzkangSub, fzRateAdd, fzProAdd = self:GetPetSkillYiTuiWeiJin()
  if xzkangSub > 0 then
    for _, xzProName in pairs({
      PROPERTY_KFENG,
      PROPERTY_KHUO,
      PROPERTY_KSHUI,
      PROPERTY_KLEI,
      PROPERTY_KAIHAO
    }) do
      local xzkang = self:getProperty(xzProName) - xzkangSub
      self:setProperty(xzProName, xzkang)
    end
  end
  if fzRateAdd > 0 then
    self:setProperty(PROPERTY_FTPRO, self:getProperty(PROPERTY_FTPRO) + fzRateAdd)
  end
  if fzProAdd > 0 then
    self:setProperty(PROPERTY_FTLV, self:getProperty(PROPERTY_FTLV) + fzProAdd)
  end
  local wxData, wxProName
  if wxData == nil then
    wxData = self:GetPetSkillWuXingHuTi(PETSKILL_JINLINGHUTI)
    wxProName = PROPERTY_WXJIN
  end
  if wxData == nil then
    wxData = self:GetPetSkillWuXingHuTi(PETSKILL_MULINGHUTI)
    wxProName = PROPERTY_WXMU
  end
  if wxData == nil then
    wxData = self:GetPetSkillWuXingHuTi(PETSKILL_SHUILINGHUTI)
    wxProName = PROPERTY_WXSHUI
  end
  if wxData == nil then
    wxData = self:GetPetSkillWuXingHuTi(PETSKILL_HUOLINGHUTI)
    wxProName = PROPERTY_WXHUO
  end
  if wxData == nil then
    wxData = self:GetPetSkillWuXingHuTi(PETSKILL_TULINGHUTI)
    wxProName = PROPERTY_WXTU
  end
  if wxData ~= nil then
    local k1, k2, k3, k_frozen, k_confuse, k_yiwang = unpack(wxData, 1, 6)
    for _, v in pairs(PROPERTY_LEVEL_WUXING) do
      local wxValue = self:getProperty(v)
      if wxProName == v then
        self:setProperty(v, wxValue * k1 + k2)
      else
        self:setProperty(v, wxValue * k3)
      end
    end
    self:setProperty(PROPERTY_KFENGYIN, self:getProperty(PROPERTY_KFENGYIN) + k_frozen)
    self:setProperty(PROPERTY_KHUNLUAN, self:getProperty(PROPERTY_KHUNLUAN) + k_confuse)
    self:setProperty(PROPERTY_KYIWANG, self:getProperty(PROPERTY_KYIWANG) + k_yiwang)
  end
end
function CPetData:setPetNeidanDataForOtherPlayer(neidanData)
  local petZhuan = self:getProperty(PROPERTY_ZHUANSHENG)
  local petLv = self:getProperty(PROPERTY_ROLELEVEL)
  local petFam = self:getProperty(PROPERTY_CLOSEVALUE)
  local ssv = self:getProperty(PROPERTY_STARSKILLVALUE)
  for _, data in pairs(neidanData) do
    local neidanId = data.i_sid
    local ndLv = data.i_nlv or 0
    local ndZhuan = data.i_nzs or 0
    if neidanId ~= nil then
      local proName = NEIDAN_ITEM_TO_PRO_TABLE[neidanId]
      if proName ~= nil then
        local temp = _computeNeiDanCoefficient(neidanId, petZhuan, petLv, petFam, ndLv, ndZhuan, ssv)
        self:setProperty(proName, temp)
      end
    end
  end
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_FENG_RATE, g_NeiDanSkill.getNeiDanPro_ChengFengPoLang(self))
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_FENG, ITEM_DEF_SKILL_FENG_4)
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_LEI_RATE, g_NeiDanSkill.getNeiDanPro_PiLiLiuXing(self))
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_LEI, ITEM_DEF_SKILL_LEI_4)
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_SHUI_RATE, g_NeiDanSkill.getNeiDanPro_DaHaiWuLiang(self))
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_SHUI, ITEM_DEF_SKILL_SHUI_4)
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_HUO_RATE, g_NeiDanSkill.getNeiDanPro_ZhuRongQuHuo(self))
  self:setProperty(PROPERTY_PASSIVE_USEMAGIC_HUO, ITEM_DEF_SKILL_HUO_4)
  local rate, effect = g_NeiDanSkill.getNeiDanPro_HongYanBaiFa(self)
  local addRate = self:GetPetSkillNuXian()
  rate = rate + addRate
  for rateName, effectName in pairs({
    [PROPERTY_MAGICKUANGBAO_SHUI_RATE] = PROPERTY_MAGICKUANGBAO_SHUI,
    [PROPERTY_MAGICKUANGBAO_HUO_RATE] = PROPERTY_MAGICKUANGBAO_HUO,
    [PROPERTY_MAGICKUANGBAO_FENG_RATE] = PROPERTY_MAGICKUANGBAO_FENG,
    [PROPERTY_MAGICKUANGBAO_LEI_RATE] = PROPERTY_MAGICKUANGBAO_LEI
  }) do
    self:setProperty(rateName, rate)
    self:setProperty(effectName, effect)
  end
  local rate, effect = g_NeiDanSkill.getNeiDanPro_MeiHuaSanNong(self)
  self:setProperty(PROPERTY_NEIDAN_MHSN_EFFECTRATE, rate)
  self:setProperty(PROPERTY_NEIDAN_MHSN_EFFECT, effect)
  local rate, effect = g_NeiDanSkill.getNeiDanPro_KaiTianPiDi(self)
  local effectAdd = self:GetPetSkillHenXian()
  effect = effect + effectAdd
  self:setProperty(PROPERTY_NEIDAN_KTPD_EFFECTRATE, rate)
  self:setProperty(PROPERTY_NEIDAN_KTPD_EFFECT, effect)
  local rate, effect = g_NeiDanSkill.getNeiDanPro_WanFoChaoZong(self)
  self:setProperty(PROPERTY_NEIDAN_WFCZ_EFFECTRATE, rate)
  self:setProperty(PROPERTY_NEIDAN_WFCZ_EFFECT, effect)
  local rate, effect = g_NeiDanSkill.getNeiDanPro_HaoRanZhengQi(self)
  self:setProperty(PROPERTY_NEIDAN_HRZQ_EFFECTRATE, rate)
  self:setProperty(PROPERTY_NEIDAN_HRZQ_EFFECT, effect)
  local pfsbl, pfwlfjpro = g_NeiDanSkill.getNeiDanPro_AnDuChenCang(self)
  self:setProperty(PROPERTY_PFSBL, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PFSBL) + pfsbl)
  self:setProperty(PROPERTY_PFWLFJPRO, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PFWLFJPRO) + pfwlfjpro)
  local pwlfjpro, pwlftimes = g_NeiDanSkill.getNeiDanPro_JieLiDaLi(self)
  self:setProperty(PROPERTY_PWLFJPRO, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PWLFJPRO) + pwlfjpro)
  self:setProperty(PROPERTY_PWLFJTIMES, math.min(data_getRoleProFromData(self.m_LtypeId, PROPERTY_PWLFJTIMES) + pwlftimes, MAX_PET_PLJTIMES_NUM))
  local psbl = g_NeiDanSkill.getNeiDanPro_LingBoWeiBu(self)
  self:setProperty(PROPERTY_PSBL, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PSBL) + psbl)
  local rate, effect = g_NeiDanSkill.getNeiDanPro_GeShanDaNiu(self)
  self:setProperty(PROPERTY_NEIDAN_GSDN_EFFECTRATE, rate)
  self:setProperty(PROPERTY_NEIDAN_GSDN_EFFECT, effect)
end
