if not CHeroData then
  CHeroData = class("CHeroData", CRoleData)
end
function CHeroData:ctor(playerId, objId, lTypeId, copyProperties)
  CHeroData.super.ctor(self, playerId, objId, lTypeId, copyProperties)
end
function CHeroData:CalculateProperty()
  local pairs = pairs
  for i, v in pairs({
    PROPERTY_GENDER,
    PROPERTY_RACE,
    PROPERTY_SHAPE
  }) do
    self:setProperty(v, data_getRoleProFromData(self:getTypeId(), v))
  end
  if WAR_CODE_IS_SERVER ~= true then
    for index, proName in ipairs(PROPERTY_LEVEL_WUXING) do
      local value = g_LocalPlayer:getObjProperty(1, proName)
      self:setProperty(proName, value)
    end
  else
    local player = WarAIGetOnePlayerData(self:getWarID(), self:getPlayerId())
    if player then
      local wxList = player:GetPlayerWuxingSetting()
      for index, proName in ipairs(PROPERTY_LEVEL_WUXING) do
        local value = wxList[index] / 100
        self:setProperty(proName, value)
      end
    end
  end
  local lv = self:getProperty(PROPERTY_ROLELEVEL)
  local starValue = 1
  self:setProperty(PROPERTY_STARSKILLVALUE, starValue)
  local zsData = self:getProperty(PROPERTY_ZSNUMLIST)
  if zsData == nil or zsData == 0 then
    zsData = {}
  end
  for _, proName in pairs(ZHUANSHENG_ADD_PROName_DICT) do
    self:setProperty(proName, 0)
  end
  local zsxzProData = {}
  for zsNum, tempData in ipairs(zsData) do
    local zsTypeID = tempData[1] or 0
    local pData = GetZSXZNumList(zsTypeID, zsNum)
    for _, tProData in pairs(pData) do
      local pro = ZHUANSHENG_ADD_PROName_DICT[tProData[1]]
      local n = tProData[2]
      zsxzProData[pro] = (zsxzProData[pro] or 0) + n
    end
  end
  for pro, num in pairs(zsxzProData) do
    self:setProperty(pro, num)
  end
  self:CheckZhuangBeiCanUse()
  local gg = self:getProperty(PROPERTY_OGenGu) + self:GetZhuangBeiAddNum(PROPERTY_GenGu) + self:getProperty(PROPERTY_Wing_GenGu)
  self:setProperty(PROPERTY_GenGu, gg)
  local lx = self:getProperty(PROPERTY_OLingxing) + self:GetZhuangBeiAddNum(PROPERTY_Lingxing) + self:getProperty(PROPERTY_Wing_Lingxing)
  self:setProperty(PROPERTY_Lingxing, lx)
  local ll = self:getProperty(PROPERTY_OLiLiang) + self:GetZhuangBeiAddNum(PROPERTY_LiLiang) + self:getProperty(PROPERTY_Wing_LiLiang)
  self:setProperty(PROPERTY_LiLiang, ll)
  local mj = self:getProperty(PROPERTY_OMinJie) + self:GetZhuangBeiAddNum(PROPERTY_MinJie) + self:getProperty(PROPERTY_Wing_MinJie)
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
  local race_ren_Lv = 0
  local race_mo_Lv = 0
  local race_xian_Lv = 0
  local race_gui_Lv = 0
  if self:getProperty(PROPERTY_RACE) == RACE_REN then
    race_ren_Lv = math.min(lv, MAX_RACE_LV_LIMIT)
  elseif self:getProperty(PROPERTY_RACE) == RACE_MO then
    race_mo_Lv = math.min(lv, MAX_RACE_LV_LIMIT)
  elseif self:getProperty(PROPERTY_RACE) == RACE_XIAN then
    race_xian_Lv = math.min(lv, MAX_RACE_LV_LIMIT)
  elseif self:getProperty(PROPERTY_RACE) == RACE_GUI then
    race_gui_Lv = math.min(lv, MAX_RACE_LV_LIMIT)
  end
  self:setProperty(PROPERTY_PDEFEND, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PDEFEND) + math.floor(race_mo_Lv / 8) / 100 + self:getProperty(PROPERTY_ZSPDEFEND) + self:GetZhuangBeiAddNum(PROPERTY_PDEFEND))
  self:setProperty(PROPERTY_KHUO, data_getRoleProFromData(self.m_LtypeId, PROPERTY_KHUO) + math.floor(race_xian_Lv / 4) / 100 + math.floor(race_mo_Lv / 12) / 100 - math.floor(race_gui_Lv / 8) / 100 + self:getProperty(PROPERTY_ZSKHUO))
  self:setProperty(PROPERTY_KSHUI, data_getRoleProFromData(self.m_LtypeId, PROPERTY_KSHUI) + math.floor(race_xian_Lv / 4) / 100 + math.floor(race_mo_Lv / 12) / 100 - math.floor(race_gui_Lv / 8) / 100 + self:getProperty(PROPERTY_ZSKSHUI))
  self:setProperty(PROPERTY_KFENG, data_getRoleProFromData(self.m_LtypeId, PROPERTY_KFENG) + math.floor(race_xian_Lv / 4) / 100 + math.floor(race_mo_Lv / 12) / 100 - math.floor(race_gui_Lv / 8) / 100 + self:getProperty(PROPERTY_ZSKFENG))
  self:setProperty(PROPERTY_KLEI, data_getRoleProFromData(self.m_LtypeId, PROPERTY_KLEI) + math.floor(race_xian_Lv / 4) / 100 + math.floor(race_mo_Lv / 12) / 100 - math.floor(race_gui_Lv / 8) / 100 + self:getProperty(PROPERTY_ZSKLEI))
  self:setProperty(PROPERTY_KAIHAO, data_getRoleProFromData(self.m_LtypeId, PROPERTY_KAIHAO) + math.floor(race_gui_Lv / 6) / 100 + self:getProperty(PROPERTY_ZSKAIHAO))
  self:setProperty(PROPERTY_KYIWANG, data_getRoleProFromData(self.m_LtypeId, PROPERTY_KYIWANG) + math.floor(race_gui_Lv / 6) / 100 + self:getProperty(PROPERTY_ZSKYIWANG))
  self:setProperty(PROPERTY_FPDEFEND, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FPDEFEND) + self:GetZhuangBeiAddNum(PROPERTY_FPDEFEND))
  self:setProperty(PROPERTY_FKHUO, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FKHUO) + self:GetZhuangBeiAddNum(PROPERTY_FKHUO))
  self:setProperty(PROPERTY_FKSHUI, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FKSHUI) + self:GetZhuangBeiAddNum(PROPERTY_FKSHUI))
  self:setProperty(PROPERTY_FKFENG, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FKFENG) + self:GetZhuangBeiAddNum(PROPERTY_FKFENG))
  self:setProperty(PROPERTY_FKLEI, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FKLEI) + self:GetZhuangBeiAddNum(PROPERTY_FKLEI))
  self:setProperty(PROPERTY_KFENGYIN, data_getRoleProFromData(self.m_LtypeId, PROPERTY_KFENGYIN) + math.floor(race_ren_Lv / 4) / 100 + math.floor(race_mo_Lv / 8) / 100 + math.floor(race_gui_Lv / 6) / 100 + self:getProperty(PROPERTY_ZSKFENGYIN) + self:GetZhuangBeiAddNum(PROPERTY_KFENGYIN))
  self:setProperty(PROPERTY_FKFENGYIN, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FKFENGYIN) + self:GetZhuangBeiAddNum(PROPERTY_FKFENGYIN))
  self:setProperty(PROPERTY_KHUNLUAN, data_getRoleProFromData(self.m_LtypeId, PROPERTY_KHUNLUAN) + math.floor(race_ren_Lv / 4) / 100 + math.floor(race_mo_Lv / 8) / 100 + math.floor(race_gui_Lv / 6) / 100 + self:getProperty(PROPERTY_ZSKHUNLUAN) + self:GetZhuangBeiAddNum(PROPERTY_KHUNLUAN))
  self:setProperty(PROPERTY_FKHUNLUAN, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FKHUNLUAN) + self:GetZhuangBeiAddNum(PROPERTY_FKHUNLUAN))
  self:setProperty(PROPERTY_KZHONGDU, data_getRoleProFromData(self.m_LtypeId, PROPERTY_KZHONGDU) + math.floor(race_ren_Lv / 4) / 100 + math.floor(race_mo_Lv / 8) / 100 + math.floor(race_gui_Lv / 6) / 100 + self:getProperty(PROPERTY_ZSKZHONGDU) + self:GetZhuangBeiAddNum(PROPERTY_KZHONGDU))
  self:setProperty(PROPERTY_FKZHONGDU, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FKZHONGDU) + self:GetZhuangBeiAddNum(PROPERTY_FKZHONGDU))
  self:setProperty(PROPERTY_KHUNSHUI, data_getRoleProFromData(self.m_LtypeId, PROPERTY_KHUNSHUI) + math.floor(race_ren_Lv / 4) / 100 + math.floor(race_mo_Lv / 8) / 100 + math.floor(race_gui_Lv / 6) / 100 + self:getProperty(PROPERTY_ZSKHUNSHUI) + self:GetZhuangBeiAddNum(PROPERTY_KHUNSHUI))
  self:setProperty(PROPERTY_FKHUNSHUI, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FKHUNSHUI) + self:GetZhuangBeiAddNum(PROPERTY_FKHUNSHUI))
  self:setProperty(PROPERTY_KZHENSHE, data_getRoleProFromData(self.m_LtypeId, PROPERTY_KZHENSHE) + math.floor(race_mo_Lv / 8) / 100 + self:getProperty(PROPERTY_ZSKZHENSHE) + self:GetZhuangBeiAddNum(PROPERTY_KZHENSHE))
  self:setProperty(PROPERTY_FKZHENSHE, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FKZHENSHE) + self:GetZhuangBeiAddNum(PROPERTY_FKZHENSHE))
  self:setProperty(PROPERTY_FKAIHAO, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FKAIHAO) + self:GetZhuangBeiAddNum(PROPERTY_FKAIHAO))
  self:setProperty(PROPERTY_FKYIWANG, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FKYIWANG) + self:GetZhuangBeiAddNum(PROPERTY_FKYIWANG))
  self:setProperty(PROPERTY_KSHUAIRUO, data_getRoleProFromData(self.m_LtypeId, PROPERTY_KSHUAIRUO) + self:GetZhuangBeiAddNum(PROPERTY_KSHUAIRUO))
  self:setProperty(PROPERTY_FKSHUAIRUO, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FKSHUAIRUO) + self:GetZhuangBeiAddNum(PROPERTY_FKSHUAIRUO))
  self:setProperty(PROPERTY_KXIXUE, data_getRoleProFromData(self.m_LtypeId, PROPERTY_KXIXUE) + math.floor(race_gui_Lv / 6) * 120 + self:getProperty(PROPERTY_ZSKXIXUE) + self:GetZhuangBeiAddNum(PROPERTY_KXIXUE))
  self:setProperty(PROPERTY_FKXIXUE, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FKXIXUE) + self:GetZhuangBeiAddNum(PROPERTY_FKXIXUE))
  self:setProperty(PROPERTY_PACC, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PACC) + math.floor(race_mo_Lv / 20) / 100 + math.floor(race_gui_Lv / 12) / 100 + self:GetZhuangBeiAddNum(PROPERTY_PACC))
  self:setProperty(PROPERTY_PSBL, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PSBL) + math.floor(race_gui_Lv / 4) / 100 + self:GetZhuangBeiAddNum(PROPERTY_PSBL))
  self:setProperty(PROPERTY_PFYL, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PFYL) + self:GetZhuangBeiAddNum(PROPERTY_PFYL))
  self:setProperty(PROPERTY_PCRIT, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PCRIT) + self:GetZhuangBeiAddNum(PROPERTY_PCRIT))
  self:setProperty(PROPERTY_FPCRIT, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FPCRIT) + self:GetZhuangBeiAddNum(PROPERTY_FPCRIT))
  self:setProperty(PROPERTY_PKUANGBAO, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PKUANGBAO) + self:GetZhuangBeiAddNum(PROPERTY_PKUANGBAO))
  self:setProperty(PROPERTY_PLJPRO, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PLJPRO) + self:GetZhuangBeiAddNum(PROPERTY_PLJPRO))
  self:setProperty(PROPERTY_PLJTIMES, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PLJTIMES) + self:GetZhuangBeiAddNum(PROPERTY_PLJTIMES))
  self:setProperty(PROPERTY_FTPRO, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FTPRO) + self:getProperty(PROPERTY_ZSFANZHEN) + self:GetZhuangBeiAddNum(PROPERTY_FTPRO))
  self:setProperty(PROPERTY_FTLV, data_getRoleProFromData(self.m_LtypeId, PROPERTY_FTLV) + self:getProperty(PROPERTY_ZSFZCD) + self:GetZhuangBeiAddNum(PROPERTY_FTLV))
  self:setProperty(PROPERTY_PKFTLV, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PKFTLV) + self:GetZhuangBeiAddNum(PROPERTY_PKFTLV))
  self:setProperty(PROPERTY_PWLFJPRO, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PWLFJPRO) + self:GetZhuangBeiAddNum(PROPERTY_PWLFJPRO))
  self:setProperty(PROPERTY_PWLFJTIMES, data_getRoleProFromData(self.m_LtypeId, PROPERTY_PWLFJTIMES) + self:GetZhuangBeiAddNum(PROPERTY_PWLFJTIMES))
  for _, proName in pairs({
    PROPERTY_PFSBL,
    PROPERTY_PFWLFJPRO,
    PROPERTY_QHSH,
    PROPERTY_HFQX,
    PROPERTY_HFFL,
    PROPERTY_DEL_DU,
    PROPERTY_DEL_ZHEN,
    PROPERTY_ADD_XIXUEHUIXUE
  }) do
    self:setProperty(proName, data_getRoleProFromData(self.m_LtypeId, proName) + self:GetZhuangBeiAddNum(proName))
  end
  for _, proName in pairs(PROPERTY_STRENGTHEN_MAGIC) do
    self:setProperty(proName, data_getRoleProFromData(self.m_LtypeId, proName) + self:GetZhuangBeiAddNum(proName))
  end
  for _, proName in pairs(PROPERTY_KANGNEIDAN) do
    self:setProperty(proName, data_getRoleProFromData(self.m_LtypeId, proName) + self:GetZhuangBeiAddNum(proName))
  end
  self:setProperty(PROPERTY_KANGNEIDAN_SSRS, self:getProperty(PROPERTY_KANGNEIDAN_SSRS) - math.floor(race_gui_Lv / 1) * 100)
  for _, proName in pairs({
    PROPERTY_KANGNEIDAN_HXWB,
    PROPERTY_KANGNEIDAN_LXYD,
    PROPERTY_KANGNEIDAN_MZYL,
    PROPERTY_KANGNEIDAN_MRCM
  }) do
    self:setProperty(proName, self:getProperty(proName) + self:getProperty(PROPERTY_ZSKNEIDAN))
  end
  for _, proName in pairs(PROPERTY_MAGICKUANGBAO) do
    self:setProperty(proName, data_getRoleProFromData(self.m_LtypeId, proName) + self:GetZhuangBeiAddNum(proName))
  end
  self:setProperty(PROPERTY_MAGICKUANGBAO_SHUI, self:getProperty(PROPERTY_MAGICKUANGBAO_SHUI) + 0.5)
  self:setProperty(PROPERTY_MAGICKUANGBAO_HUO, self:getProperty(PROPERTY_MAGICKUANGBAO_HUO) + 0.5)
  self:setProperty(PROPERTY_MAGICKUANGBAO_FENG, self:getProperty(PROPERTY_MAGICKUANGBAO_FENG) + 0.5)
  self:setProperty(PROPERTY_MAGICKUANGBAO_LEI, self:getProperty(PROPERTY_MAGICKUANGBAO_LEI) + 0.5)
  self:setProperty(PROPERTY_MAGICKUANGBAO_AIHAO, self:getProperty(PROPERTY_MAGICKUANGBAO_AIHAO) + 0.5)
  self:setProperty(PROPERTY_MAGICKUANGBAO_XIXUE, self:getProperty(PROPERTY_MAGICKUANGBAO_XIXUE) + 0.5)
  for _, proName in pairs(PROPERTY_PASSIVE_USEMAGIC) do
    self:setProperty(proName, data_getRoleProFromData(self.m_LtypeId, proName) + self:GetZhuangBeiAddNum(proName))
  end
  for proName, skillID in pairs({
    [PROPERTY_PASSIVE_USEMAGIC_SHUI] = ITEM_DEF_SKILL_SHUI_4,
    [PROPERTY_PASSIVE_USEMAGIC_HUO] = ITEM_DEF_SKILL_HUO_4,
    [PROPERTY_PASSIVE_USEMAGIC_FENG] = ITEM_DEF_SKILL_FENG_4,
    [PROPERTY_PASSIVE_USEMAGIC_LEI] = ITEM_DEF_SKILL_LEI_4,
    [PROPERTY_PASSIVE_USEMAGIC_DU] = ITEM_DEF_SKILL_DU_4,
    [PROPERTY_PASSIVE_USEMAGIC_HUNLUAN] = ITEM_DEF_SKILL_HUNLUAN_4,
    [PROPERTY_PASSIVE_USEMAGIC_FENGYIN] = ITEM_DEF_SKILL_FENGYIN_4,
    [PROPERTY_PASSIVE_USEMAGIC_HUNSHUI] = ITEM_DEF_SKILL_HUISHUI_4,
    [PROPERTY_PASSIVE_USEMAGIC_GONG] = ITEM_DEF_SKILL_GONG_5,
    [PROPERTY_PASSIVE_USEMAGIC_SU] = ITEM_DEF_SKILL_SU_5,
    [PROPERTY_PASSIVE_USEMAGIC_FANG] = ITEM_DEF_SKILL_FANG_5,
    [PROPERTY_PASSIVE_USEMAGIC_ZHEN] = ITEM_DEF_SKILL_ZHEN_4
  }) do
    self:setProperty(proName, skillID)
  end
  local xianFaKangXingNameDict = {
    [PROPERTY_KHUO] = true,
    [PROPERTY_KSHUI] = true,
    [PROPERTY_KFENG] = true,
    [PROPERTY_KLEI] = true,
    [PROPERTY_KAIHAO] = true,
    [PROPERTY_KYIWANG] = true
  }
  local xianFaTuTenDict = {}
  if WAR_CODE_IS_SERVER ~= true then
    if g_LocalPlayer and g_LocalPlayer:getMainHeroId() == self:getObjId() and g_BpMgr then
      local mainTotem = g_BpMgr:getMainTotem()
      local fuTotem = g_BpMgr:getFuTotem()
      local bpOffer = g_BpMgr:getLocalPlayerOffer()
      local proName, addkang = CalculateMainTotemKang(mainTotem, bpOffer)
      if proName ~= nil and addkang > 0 then
        if xianFaKangXingNameDict[proName] == true then
          xianFaTuTenDict[proName] = addkang
        else
          local kangPro = self:getProperty(proName)
          self:setProperty(proName, kangPro + addkang)
        end
      end
      local proName_2, addkang_2 = CalculateFuTotemKang(fuTotem, bpOffer)
      if proName_2 ~= nil and addkang_2 > 0 then
        if xianFaKangXingNameDict[proName_2] == true then
          xianFaTuTenDict[proName_2] = addkang_2
        else
          local kangPro_2 = self:getProperty(proName_2)
          self:setProperty(proName_2, kangPro_2 + addkang_2)
        end
      end
      local bpId = g_BpMgr:getLocalPlayerBpId()
      self:setProperty(PROPERTY_BPID, bpId)
      local bpName = g_BpMgr:getLocalBpName()
      self:setProperty(PROPERTY_BPNAME, bpName)
      local bpJob = g_BpMgr:getLocalBpPlace()
      self:setProperty(PROPERTY_BPJOB, bpJob)
    end
  else
    local player = WarAIGetOnePlayerData(self:getWarID(), self:getPlayerId())
    if player and player:getMainHeroId() == self:getObjId() then
      local mainTotem = player:GetBpMainTotem()
      local fuTotem = player:GetBpFuTotem()
      local bpOffer = player:GetBpOffer()
      local proName, addkang = CalculateMainTotemKang(mainTotem, bpOffer)
      if proName ~= nil and addkang > 0 then
        if xianFaKangXingNameDict[proName] == true then
          xianFaTuTenDict[proName] = addkang
        else
          local kangPro = self:getProperty(proName)
          self:setProperty(proName, kangPro + addkang)
        end
      end
      local proName_2, addkang_2 = CalculateFuTotemKang(fuTotem, bpOffer)
      if proName_2 ~= nil and addkang_2 > 0 then
        if xianFaKangXingNameDict[proName_2] == true then
          xianFaTuTenDict[proName_2] = addkang_2
        else
          local kangPro_2 = self:getProperty(proName_2)
          self:setProperty(proName_2, kangPro_2 + addkang_2)
        end
      end
    end
  end
  for proName, _ in pairs(xianFaKangXingNameDict) do
    local kangPro = self:getProperty(proName)
    local addkang = math.min(MAX_KANG_HERO_ForZB_TT, (xianFaTuTenDict[proName] or 0) + self:GetZhuangBeiAddNum(proName))
    self:setProperty(proName, kangPro + addkang)
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
    if self:getProperty(PROPERTY_RACE) == RACE_REN then
      if v == PROPERTY_KFENGYIN or v == PROPERTY_KHUNLUAN or v == PROPERTY_KZHONGDU or v == PROPERTY_KHUNSHUI then
        self:setProperty(v, math.min(MAX_KANG_HERO_REN_KANGREN_VALUE, self:getProperty(v)))
      elseif v == PROPERTY_KYIWANG then
        self:setProperty(v, math.min(MAX_KANG_HERO_REN_KANGYIWANG_VALUE, self:getProperty(v)))
      end
    elseif self:getProperty(PROPERTY_RACE) == RACE_MO then
      if v == PROPERTY_KFENGYIN or v == PROPERTY_KHUNLUAN or v == PROPERTY_KZHONGDU or v == PROPERTY_KHUNSHUI then
        self:setProperty(v, math.min(MAX_KANG_HERO_MO_KANGREN_VALUE, self:getProperty(v)))
      elseif v == PROPERTY_KYIWANG then
        self:setProperty(v, math.min(MAX_KANG_HERO_MO_KANGYIWANG_VALUE, self:getProperty(v)))
      end
    elseif self:getProperty(PROPERTY_RACE) == RACE_XIAN then
      if v == PROPERTY_KFENGYIN or v == PROPERTY_KHUNLUAN or v == PROPERTY_KZHONGDU or v == PROPERTY_KHUNSHUI then
        self:setProperty(v, math.min(MAX_KANG_HERO_XIAN_KANGREN_VALUE, self:getProperty(v)))
      elseif v == PROPERTY_KYIWANG then
        self:setProperty(v, math.min(MAX_KANG_HERO_XIAN_KANGYIWANG_VALUE, self:getProperty(v)))
      end
    elseif self:getProperty(PROPERTY_RACE) == RACE_GUI then
      if v == PROPERTY_KFENGYIN or v == PROPERTY_KHUNLUAN or v == PROPERTY_KZHONGDU or v == PROPERTY_KHUNSHUI then
        self:setProperty(v, math.min(MAX_KANG_HERO_GUI_KANGREN_VALUE, self:getProperty(v)))
      elseif v == PROPERTY_KYIWANG then
        self:setProperty(v, math.min(MAX_KANG_HERO_GUI_KANGYIWANG_VALUE, self:getProperty(v)))
      end
    end
  end
  self:setProperty(PROPERTY_PACC, math.min(MAX_PACC_NUM, math.max(MIN_PACC_NUM, self:getProperty(PROPERTY_PACC))))
  self:setProperty(PROPERTY_PSBL, math.min(MAX_PSBL_NUM, math.max(MIN_PSBL_NUM, self:getProperty(PROPERTY_PSBL))))
  self:setProperty(PROPERTY_PLJTIMES, math.min(MAX_PLJTIMES_NUM, math.max(MIN_PLJTIMES_NUM, self:getProperty(PROPERTY_PLJTIMES))))
  self:setProperty(PROPERTY_PWLFJTIMES, math.min(MAX_PWLFJTIMES_NUM, math.max(MIN_PWLFJTIMES_NUM, self:getProperty(PROPERTY_PWLFJTIMES))))
  self:setProperty(PROPERTY_FTLV, math.min(MAX_FTLV_NUM, math.max(MIN_FTLV_NUM, self:getProperty(PROPERTY_FTLV))))
  for _, proName in ipairs({
    PROPERTY_KE_WXJIN,
    PROPERTY_KE_WXMU,
    PROPERTY_KE_WXTU,
    PROPERTY_KE_WXSHUI,
    PROPERTY_KE_WXHUO
  }) do
    self:setProperty(proName, self:GetZhuangBeiAddNum(proName))
  end
  for _, proName in ipairs({
    PROPERTY_WINE_KE_WXJIN,
    PROPERTY_WINE_KE_WXMU,
    PROPERTY_WINE_KE_WXTU,
    PROPERTY_WINE_KE_WXSHUI,
    PROPERTY_WINE_KE_WXHUO
  }) do
    self:setProperty(proName, 0)
  end
  local fId = 0
  local wId = 0
  if WAR_CODE_IS_SERVER ~= true then
    if g_LocalPlayer and g_LocalPlayer:getMainHeroId() == self:getObjId() then
      local fuwenData = g_LocalPlayer:getLifeSkillFuData()
      if fuwenData.fid ~= nil and fuwenData.fid ~= 0 and fuwenData.v ~= nil and fuwenData.v ~= 0 then
        fId = fuwenData.fid
      end
      local wineData = g_LocalPlayer:getLifeSkillWineData()
      if wineData.wid ~= nil and wineData.wid ~= 0 and wineData.v ~= nil and wineData.v ~= 0 then
        wId = wineData.wid
      end
    end
  else
    local player = WarAIGetOnePlayerData(self:getWarID(), self:getPlayerId())
    if player and player:getMainHeroId() == self:getObjId() then
      fId = player:GetFuwenId()
      wId = player:GetWineId()
    end
  end
  self:setProperty(PROPERTY_ADDFENLIE, 0)
  if fId ~= 0 then
    for proName, addkang in pairs(data_getLifeItemFuwenEffDict(fId)) do
      local kangPro = self:getProperty(proName)
      self:setProperty(proName, kangPro + addkang)
    end
  end
  if wId ~= 0 then
    for proName, addkang in pairs(data_getLifeItemWineEffDict(wId)) do
      local kangPro = self:getProperty(proName)
      self:setProperty(proName, kangPro + addkang)
    end
  end
end
function CHeroData:UpdateLogicTypeId(lTypeId)
end
