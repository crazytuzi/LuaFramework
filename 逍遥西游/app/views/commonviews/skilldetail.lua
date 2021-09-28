g_Click_Skill_View = nil
CSkillDetailView = class("CSkillDetailView", CcsSubView)
function CSkillDetailView:ctor(roleId, skillId, autoDel, posPara, roleTypeId, playerId, delBtnFlag, isBaitanPlayer, isChatSys)
  self.m_isLingwuSkillFlag = false
  self.m_isChatSys = isChatSys
  self.m_petId = roleId
  self.m_petTypeId = roleTypeId
  if GetObjType(skillId) == LOGICTYPE_PETSKILL then
    self.m_isLingwuSkillFlag = true
  end
  if self.m_isLingwuSkillFlag then
    CSkillDetailView.super.ctor(self, "views/petskilldetail.json")
  else
    CSkillDetailView.super.ctor(self, "views/skilldetail.json")
  end
  print("CSkillDetailView---create")
  self.m_AutoDel = autoDel
  self.m_SkillId = skillId
  self.m_RoleId = roleId
  self.m_RoleTypeId = roleTypeId
  self.m_DelBtnFlag = delBtnFlag
  self.m_XuiLianData = nil
  self.m_Bg = self:getNode("bg")
  if playerId ~= nil then
    if isBaitanPlayer == true then
      self.m_Player = g_BaitanDataMgr:getPlayer(playerId)
    else
      self.m_Player = g_DataMgr:getPlayer(playerId)
      if self.m_Player == nil then
        self.m_Player = g_DataMgr:CreatePlayer(playerId, false)
      end
    end
  else
    self.m_Player = g_LocalPlayer
  end
  if self.m_isLingwuSkillFlag == true then
    local btnBatchListener = {
      btn_xiulian = {
        listener = handler(self, self.OnBtn_XiuLianSkill),
        variName = "btn_xiulian"
      },
      btn_del = {
        listener = handler(self, self.OnBtn_DelSkill),
        variName = "btn_del"
      },
      bg = {
        listener = handler(self, self.OnBtn_Close),
        variName = "bg",
        param = {0}
      }
    }
    self:addBatchBtnListener(btnBatchListener)
    local roleIns
    if roleId ~= nil then
      roleIns = self.m_Player:getObjById(roleId)
    end
    if roleIns then
      local zjSkillExpInfo = roleIns:getProperty(PROPERTY_ZJSKILLSEXP)
      if zjSkillExpInfo and type(zjSkillExpInfo) == "table" and zjSkillExpInfo[skillId] ~= nil then
        self.m_XuiLianData = DeepCopyTable(zjSkillExpInfo[skillId])
      end
    end
    if self.m_XuiLianData ~= nil then
      self.btn_xiulian:setEnabled(true)
      local x, y = self.btn_xiulian:getPosition()
      self.btn_xiulian:setPosition(ccp(x + 80, y))
      local x, y = self.btn_del:getPosition()
      self.btn_del:setPosition(ccp(x - 80, y))
    else
      self.btn_xiulian:setEnabled(false)
    end
    if self.m_DelBtnFlag == false then
      self.btn_del:setEnabled(false)
      self.btn_xiulian:setEnabled(false)
    end
    self:setSkillImg()
    self:setLingwuSkill()
  else
    self:setSkillImg()
    self:setNormalSkill()
  end
  if self.m_AutoDel == true then
    self:AutoDelSelf()
  end
  tipssetposExtend.extend(self, posPara)
  if self.m_isLingwuSkillFlag == true then
    local x, y = self:getPosition()
    local size = self:getContentSize()
    local wp1 = self:getParent():convertToWorldSpace(ccp(x, y))
    self:enableCloseWhenTouchOutsideBySize(CCRect(wp1.x, wp1.y, size.width, size.height))
  else
    tipsviewExtend.extend(self)
  end
end
function CSkillDetailView:setSkillImg()
  local path = data_getSkillShapePath(self.m_SkillId)
  if self.m_XuiLianData ~= nil then
    path = "xiyou/skill/skill_unknown.png"
  end
  local tempImg = display.newSprite(path)
  local x, y = self:getNode("skillImg"):getPosition()
  local z = self:getNode("skillImg"):getZOrder()
  local size = self:getNode("skillImg"):getSize()
  local mSize = tempImg:getContentSize()
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  tempImg:setScale(size.width / mSize.width)
  self.m_Bg:addNode(tempImg, z)
end
function CSkillDetailView:setNormalSkill()
  local skillId = self.m_SkillId
  local roleId = self.m_RoleId
  local roleTypeId = self.m_RoleTypeId
  local x, y = self:getNode("skillDesc"):getPosition()
  local descSize = self:getNode("skillDesc"):getSize()
  local tempDesc = CRichText.new({
    width = descSize.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 20,
    color = ccc3(255, 255, 255)
  })
  self.m_Bg:addChild(tempDesc)
  local name = data_getSkillName(skillId)
  tempDesc:addRichText(name)
  tempDesc:newLine()
  if SKILLATTR_ALL_NAME_DICT[attr] ~= nil then
    tempDesc:addRichText(string.format("【法术系】%s", SKILLATTR_ALL_NAME_DICT[attr]))
    tempDesc:newLine()
  end
  local roleIns
  if roleId ~= nil then
    roleIns = self.m_Player:getObjById(roleId)
  else
    local tempRoleFactory = CRoleFactory.new()
    roleIns = tempRoleFactory:newObject(0, 0, roleTypeId)
    local data_table = data_Pet[roleIns:getTypeId()]
    roleIns:setProperty(PROPERTY_ROLELEVEL, 1)
    roleIns:setProperty(PROPERTY_STARSKILLVALUE, 1)
    if data_table ~= nil and data_table.skills[1] ~= nil and data_table.skills[1] ~= 0 then
      roleIns:setProficiency(data_table.skills[1], 1)
      if data_table.skills[2] ~= nil and data_table.skills[2] ~= 0 then
        roleIns:setProficiency(data_table.skills[2], 1)
      end
    end
  end
  if roleIns ~= nil then
    local roleLV = roleIns:getProperty(PROPERTY_ROLELEVEL)
    local skillP = roleIns:getProficiency(skillId) or 0
    if roleId == self.m_Player:getMainHeroId() then
      local roleLV = roleIns:getProperty(PROPERTY_ROLELEVEL)
      local roleZS = roleIns:getProperty(PROPERTY_ZHUANSHENG)
      local maxProficiency = 0
      if GetObjType(skillId) == LOGICTYPE_MARRYSKILL then
        local fValue = 0
        local banLvID = g_FriendsMgr:getBanLvId()
        if banLvID ~= nil then
          fValue = g_FriendsMgr:getFriendValue(banLvID) or 0
        end
        maxProficiency = math.min(data_Variables.FriendCloseLimit or 25000, fValue)
      else
        maxProficiency = data_getSkillExpLimitByZsAndLv(roleZS, roleLV)
        if maxProficiency == nil then
          maxProficiency = CalculateSkillProficiency(roleZS)
        end
      end
      tempDesc:addRichText(string.format("【熟练度】%d/%d", skillP, maxProficiency))
      tempDesc:newLine()
    end
    local NeedMp
    local userMp = roleIns:getProperty(PROPERTY_MP)
    if GetObjType(skillId) == LOGICTYPE_NEIDANSKILL then
      local skillData = _getSkillData(skillId)
      if skillData ~= nil then
        NeedMp = _computeNeiDanRequireMp(skillId)
        local attr = skillData.attr
        if attr == NDATTR_MOJIE then
          if skillId == NDSKILL_QINGMIANLIAOYA then
            local ndCoeff = roleIns:getProperty(PROPERTY_NEIDAN_QMLY_NUM)
            local loseMp, _ = _getNeiDanDamage_QingMianLiaoYa_ByNDEffectAndCurMp(ndCoeff, userMp)
            NeedMp = NeedMp + loseMp
          elseif skillId == NDSKILL_XIAOLOUYEKU then
            local ndCoeff = roleIns:getProperty(PROPERTY_NEIDAN_XLYK_NUM)
            local loseMp, _ = _getNeiDanDamage_XiaoLouYeKu_ByNDEffectAndCurMp(ndCoeff, userMp)
            NeedMp = NeedMp + loseMp
          end
        end
      end
    elseif GetObjType(skillId) == LOGICTYPE_MARRYSKILL then
      NeedMp = _computeMarrySkillRequireMp(skillId, math.max(1, skillP))
    else
      NeedMp = _computeSkillRequireMp(skillId, skillP)
    end
    if NeedMp ~= nil then
      local mpEnough = true
      if g_WarScene then
        local warPos = g_WarScene:getWarPosByRoleID(roleId)
        mpEnough = g_WarScene:roleSkillMpEnough(warPos, skillId)
      elseif userMp < NeedMp then
        mpEnough = false
      end
      if mpEnough then
        tempDesc:addRichText(string.format("【消耗MP】%d", NeedMp))
      else
        tempDesc:addRichText(string.format("【消耗MP】#<R>%d#", NeedMp))
      end
      tempDesc:newLine()
    end
    local des = data_getSkillDesc(skillId)
    local skillData = _getSkillData(skillId)
    if skillData ~= nil then
      if GetObjType(skillId) == LOGICTYPE_NEIDANSKILL then
        if skillId == ITEM_DEF_NEIDAN_TMJT then
          local rate1, rate2 = _getNeiDanDamage_TianMoJieTi_DisPlay(roleIns)
          des = string.gsub(des, "#<PM>#", string.format("#<Y>%s%%%%#", math.floor(rate1 * 10000) / 100))
          des = string.gsub(des, "#<PN>#", string.format("#<Y>%s%%%%#", math.floor(rate2 * 10000) / 100))
        elseif skillId == ITEM_DEF_NEIDAN_FGHY then
          local rate1, rate2 = _getNeiDanDamage_FenGuangHuaYing_DisPlay(roleIns)
          des = string.gsub(des, "#<PO>#", string.format("#<Y>%s%%%%#", math.floor(rate1 * 10000) / 100))
          des = string.gsub(des, "#<PP>#", string.format("#<Y>%s%%%%#", math.floor(rate2 * 10000) / 100))
        elseif skillId == ITEM_DEF_NEIDAN_QMLY then
          local rate1, rate2 = _getNeiDanDamage_QingMianLiaoYa_DisPlay(roleIns)
          des = string.gsub(des, "#<PQ>#", string.format("#<Y>%s%%%%#", math.floor(rate1 * 10000) / 100))
          des = string.gsub(des, "#<PR>#", string.format("#<Y>%s%%%%#", math.floor(rate2 * 10000) / 100))
        elseif skillId == ITEM_DEF_NEIDAN_XLYK then
          local rate1, rate2 = _getNeiDanDamage_XiaoLouYeKu_DisPlay(roleIns)
          des = string.gsub(des, "#<PS>#", string.format("#<Y>%s%%%%#", math.floor(rate1 * 10000) / 100))
          des = string.gsub(des, "#<PT>#", string.format("#<Y>%s%%%%#", math.floor(rate2 * 10000) / 100))
        elseif skillId == ITEM_DEF_NEIDAN_CFPL then
          des = string.gsub(des, "#<PU>#", string.format("#<Y>%s%%%%#", math.floor(g_NeiDanSkill.getNeiDanPro_ChengFengPoLang(roleIns) * 10000) / 100))
          des = string.gsub(des, "#<PAM>#", string.format("#<Y>%s#", _getNeiDanDamage_ChengFengPoLang(roleIns, 0, 0, true)))
        elseif skillId == ITEM_DEF_NEIDAN_PLLX then
          des = string.gsub(des, "#<PV>#", string.format("#<Y>%s%%%%#", math.floor(g_NeiDanSkill.getNeiDanPro_PiLiLiuXing(roleIns) * 10000) / 100))
          des = string.gsub(des, "#<PAN>#", string.format("#<Y>%s#", _getNeiDanDamage_PiLiLiuXing(roleIns, 0, 0, true)))
        elseif skillId == ITEM_DEF_NEIDAN_DHWL then
          des = string.gsub(des, "#<PW>#", string.format("#<Y>%s%%%%#", math.floor(g_NeiDanSkill.getNeiDanPro_DaHaiWuLiang(roleIns) * 10000) / 100))
          des = string.gsub(des, "#<PAO>#", string.format("#<Y>%s#", _getNeiDanDamage_DaHaiWuLiang(roleIns, 0, 0, true)))
        elseif skillId == ITEM_DEF_NEIDAN_ZRQH then
          des = string.gsub(des, "#<PX>#", string.format("#<Y>%s%%%%#", math.floor(g_NeiDanSkill.getNeiDanPro_ZhuRongQuHuo(roleIns) * 10000) / 100))
          des = string.gsub(des, "#<PAP>#", string.format("#<Y>%s#", _getNeiDanDamage_ZhuRongQuHuo(roleIns, 0, 0, true)))
        elseif skillId == ITEM_DEF_NEIDAN_HYBF then
          local rate, effect = g_NeiDanSkill.getNeiDanPro_HongYanBaiFa(roleIns)
          des = string.gsub(des, "#<PY>#", string.format("#<Y>%s%%%%#", math.floor(rate * 10000) / 100))
          des = string.gsub(des, "#<PZ>#", string.format("#<Y>%s%%%%#", math.floor(effect * 10000) / 100))
        elseif skillId == ITEM_DEF_NEIDAN_MHSN then
          local rate, effect = g_NeiDanSkill.getNeiDanPro_MeiHuaSanNong(roleIns)
          des = string.gsub(des, "#<PAA>#", string.format("#<Y>%s%%%%#", math.floor(rate * 10000) / 100))
          des = string.gsub(des, "#<PAB>#", string.format("#<Y>%s#", effect))
        elseif skillId == ITEM_DEF_NEIDAN_KTPD then
          local rate, effect = g_NeiDanSkill.getNeiDanPro_KaiTianPiDi(roleIns)
          des = string.gsub(des, "#<PAC>#", string.format("#<Y>%s%%%%#", math.floor(rate * 10000) / 100))
          des = string.gsub(des, "#<PAD>#", string.format("#<Y>%s%%%%#", math.floor(effect * 10000) / 100))
        elseif skillId == ITEM_DEF_NEIDAN_WFCZ then
          local rate, effect = g_NeiDanSkill.getNeiDanPro_WanFoChaoZong(roleIns)
          des = string.gsub(des, "#<PAE>#", string.format("#<Y>%s%%%%#", math.floor(rate * 10000) / 100))
          des = string.gsub(des, "#<PAF>#", string.format("#<Y>%s%%%%#", math.floor(effect * 10000) / 100))
        elseif skillId == ITEM_DEF_NEIDAN_HRZQ then
          local rate, effect = g_NeiDanSkill.getNeiDanPro_HaoRanZhengQi(roleIns)
          des = string.gsub(des, "#<PAG>#", string.format("#<Y>%s%%%%#", math.floor(rate * 10000) / 100))
          des = string.gsub(des, "#<PAR>#", string.format("#<Y>%s%%%%#", math.floor(effect * 10000) / 100))
        elseif skillId == ITEM_DEF_NEIDAN_ADCC then
          local rate, _ = g_NeiDanSkill.getNeiDanPro_AnDuChenCang(roleIns)
          des = string.gsub(des, "#<PAH>#", string.format("#<Y>%s%%%%#", math.floor(rate * 10000) / 100))
        elseif skillId == ITEM_DEF_NEIDAN_JLDL then
          local rate, effect = g_NeiDanSkill.getNeiDanPro_JieLiDaLi(roleIns)
          des = string.gsub(des, "#<PAI>#", string.format("#<Y>%s%%%%#", math.floor(rate * 10000) / 100))
          des = string.gsub(des, "#<PAQ>#", string.format("#<Y>%s#", effect))
        elseif skillId == ITEM_DEF_NEIDAN_LBWB then
          des = string.gsub(des, "#<PAJ>#", string.format("#<Y>%s%%%%#", math.floor(g_NeiDanSkill.getNeiDanPro_LingBoWeiBu(roleIns) * 10000) / 100))
        elseif skillId == ITEM_DEF_NEIDAN_GSDN then
          local rate, effect = g_NeiDanSkill.getNeiDanPro_GeShanDaNiu(roleIns)
          des = string.gsub(des, "#<PAK>#", string.format("#<Y>%s%%%%#", math.floor(rate * 10000) / 100))
          des = string.gsub(des, "#<PAL>#", string.format("#<Y>%s%%%%#", math.floor(effect * 10000) / 100))
        end
      elseif GetObjType(skillId) == LOGICTYPE_MARRYSKILL then
        if skillId == MARRYSKILL_QINMIWUJIAN then
          local value, _, _ = _computeMarrySkill_QinMiWuJian(roleLV, math.max(1, skillP))
          des = string.gsub(des, "#PPY#", string.format("#<Y>%s#", math.floor(value)))
        elseif skillId == MARRYSKILL_TONGCHOUDIKAI then
          local rate, _, _ = _computeMarrySkill_TongChouDiKai(roleLV, math.max(1, skillP))
          des = string.gsub(des, "#PPZ#", string.format("#<Y>%s%%%%#", math.floor(rate * 10000) / 100))
        elseif skillId == MARYYSKILL_QINGSHENSIHAI then
          local rate = _computeMarrySkill_QingShenSiHai(roleLV, math.max(1, skillP))
          des = string.gsub(des, "#PPZ#", string.format("#<Y>%s%%%%#", math.floor(rate * 10000) / 100))
        end
      else
        local attr = data_getSkillAttr(skillId)
        des = string.gsub(des, "#<PA>#", string.format("#<Y>%s#", _getSkillTargetNumBySkillExp(skillId, skillP, skillData.targetNum, roleIns:getType())))
        if attr == SKILLATTR_POISON then
          local ssv = roleIns:getProperty(PROPERTY_STARSKILLVALUE)
          des = string.gsub(des, "#<POA>#", string.format("#<Y>%s%%%%#", math.floor(_computeSkillDamage_Poison_FirstRound(skillId, skillP, roleLV, ssv) * 10000) / 100))
          des = string.gsub(des, "#<POC>#", string.format("#<Y>%s#", _computeSkillRound(skillId, skillP)))
        elseif attr == SKILLATTR_SLEEP then
          des = string.gsub(des, "#<POB>#", string.format("#<Y>%s#", _computeSkillRound(skillId, skillP)))
        elseif attr == SKILLATTR_CONFUSE then
          des = string.gsub(des, "#<POD>#", string.format("#<Y>%s#", _computeSkillRound(skillId, skillP)))
        elseif attr == SKILLATTR_ICE then
          des = string.gsub(des, "#<POE>#", string.format("#<Y>%s#", _computeSkillRound(skillId, skillP)))
        elseif attr == SKILLATTR_FIRE or attr == SKILLATTR_WIND or attr == SKILLATTR_THUNDER or attr == SKILLATTR_WATER then
          local ssv = roleIns:getProperty(PROPERTY_STARSKILLVALUE)
          local value = _computeSkillDamage_XianZu(skillId, 0, 0, skillP, roleLV, ssv)
          value = math.floor(value)
          des = string.gsub(des, "#<PB>#", string.format("#<Y>%s#", value))
        elseif attr == SKILLATTR_PAN then
          local ssv = roleIns:getProperty(PROPERTY_STARSKILLVALUE)
          local wlKang, xzKang, rzKang = _computeSkillEffect_Pan(skillId, skillP, ssv)
          des = string.gsub(des, "#<PD>#", string.format("#<Y>%s%%%%#", math.floor(wlKang * 10000) / 100))
          des = string.gsub(des, "#<PE>#", string.format("#<Y>%s%%%%#", math.floor(xzKang * 10000) / 100))
          des = string.gsub(des, "#<PF>#", string.format("#<Y>%s%%%%#", math.floor(rzKang * 10000) / 100))
          des = string.gsub(des, "#<POF>#", string.format("#<Y>%s#", _computeSkillRound(skillId, skillP)))
        elseif attr == SKILLATTR_ATTACK then
          local ssv = roleIns:getProperty(PROPERTY_STARSKILLVALUE)
          local ap, mz = _computeSkillEffect_Attack(skillId, skillP, ssv)
          des = string.gsub(des, "#<PG>#", string.format("#<Y>%s%%%%#", math.floor(ap * 10000) / 100))
          des = string.gsub(des, "#<PH>#", string.format("#<Y>%s%%%%#", math.floor(mz * 10000) / 100))
          des = string.gsub(des, "#<POG>#", string.format("#<Y>%s#", _computeSkillRound(skillId, skillP)))
        elseif attr == SKILLATTR_SPEED then
          local ssv = roleIns:getProperty(PROPERTY_STARSKILLVALUE)
          des = string.gsub(des, "#<PI>#", string.format("#<Y>%s%%%%#", math.floor(_computeSkillEffect_Speed(skillId, skillP, ssv) * 100)))
          des = string.gsub(des, "#<POH>#", string.format("#<Y>%s#", _computeSkillRound(skillId, skillP)))
        elseif attr == SKILLATTR_ZHEN then
          local ssv = roleIns:getProperty(PROPERTY_STARSKILLVALUE)
          local hpL, hpS, mpL, mpS = _computeSkillDamage_Zhen_Detail(skillId, skillP, roleLV, ssv)
          des = string.gsub(des, "#<PON>#", string.format("#<Y>%s#", hpL))
          des = string.gsub(des, "#<POO>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(hpS * 10000) / 100)))
          des = string.gsub(des, "#<POP>#", string.format("#<Y>%s#", mpL))
          des = string.gsub(des, "#<POQ>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(mpS * 10000) / 100)))
        elseif attr == SKILLATTR_SHUAIRUO then
          local ssv = roleIns:getProperty(PROPERTY_STARSKILLVALUE)
          local k_zhen, k_yw, k_ah, k_xx = _computeSkillEffect_ShuaiRuo(skillId, skillP, ssv)
          des = string.gsub(des, "#<PD>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(k_zhen * 10000) / 100)))
          des = string.gsub(des, "#<PE>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(k_yw * 10000) / 100)))
          des = string.gsub(des, "#<PF>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(k_ah * 10000) / 100)))
          des = string.gsub(des, "#<PG>#", string.format("#<Y>%s#", math.floor(math.abs(k_xx))))
          des = string.gsub(des, "#<POF>#", string.format("#<Y>%s#", _computeSkillRound(skillId, skillP)))
        elseif attr == SKILLATTR_XIXUE then
          local ssv = roleIns:getProperty(PROPERTY_STARSKILLVALUE)
          des = string.gsub(des, "#<POP>#", string.format("#<Y>%s#", _computeSkillDamage_XiXue(skillId, 0, 0, skillP, roleLV, ssv, 0)))
          local rate = _computeSkillDamage_XiXueAddHp_BaseCoeff(skillId)
          des = string.gsub(des, "#<POK>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(rate * 10000) / 100)))
        elseif attr == SKILLATTR_AIHAO then
          local ssv = roleIns:getProperty(PROPERTY_STARSKILLVALUE)
          des = string.gsub(des, "#<POP>#", string.format("#<Y>%s#", _computeSkillDamage_AiHao(skillId, 0, 0, skillP, roleLV, ssv, 0, 0, 0, 0)))
        elseif attr == SKILLATTR_YIWANG then
          des = string.gsub(des, "#<POB>#", string.format("#<Y>%s#", _computeSkillRound(skillId, skillP)))
        elseif attr == SKILLATTR_MINGLINGFEIZI then
          des = string.gsub(des, "#<POI>#", string.format("#<Y>%s#", _computeSkillRound(skillId, skillP)))
          local ssv = roleIns:getProperty(PROPERTY_STARSKILLVALUE)
          local wlKang, xzKang, rzKang = _computeSkillEffect_MingLingFeiZi(skillId, ssv)
          des = string.gsub(des, "#<POK>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(wlKang * 10000) / 100)))
          des = string.gsub(des, "#<POL>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(xzKang * 10000) / 100)))
          des = string.gsub(des, "#<POM>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(rzKang * 10000) / 100)))
        elseif attr == SKILLATTR_JIXIANGGUOZI then
          des = string.gsub(des, "#<POJ>#", string.format("#<Y>%s#", _computeSkillRound(skillId, skillP)))
          local ssv = roleIns:getProperty(PROPERTY_STARSKILLVALUE)
          local k_zs, k_yw, k_ah, k_xx = _computeSkillEffect_JiXiangGuoZi(skillId, ssv)
          des = string.gsub(des, "#<PL>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(k_zs * 10000) / 100)))
          des = string.gsub(des, "#<PI>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(k_yw * 10000) / 100)))
          des = string.gsub(des, "#<PJ>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(k_ah * 10000) / 100)))
          des = string.gsub(des, "#<PK>#", string.format("#<Y>%s#", math.floor(math.abs(k_xx))))
        elseif attr == SKILLATTR_SHOUHUCANGSHENG then
          des = string.gsub(des, "#<POI>#", string.format("#<Y>%s#", _computeSkillRound(skillId, skillP)))
          local _, _, cdRound = _computeSkillEffect_ShouHuCangSheng(skillId)
          des = string.gsub(des, "#<POG>#", string.format("#<Y>%s#", cdRound))
        elseif attr == SKILLATTR_NIAN then
          local adv_kb, adv_mz, adv_zm = _computeSkillEffect_Nian(skillId)
          des = string.gsub(des, "#<POI>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(adv_kb * 10000) / 100)))
          des = string.gsub(des, "#<POJ>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(adv_mz * 10000) / 100)))
          des = string.gsub(des, "#<POK>#", string.format("#<Y>%s%%%%#", math.floor(math.abs(adv_zm * 10000) / 100)))
          des = string.gsub(des, "#<POG>#", string.format("#<Y>%s#", _computeSkillRound(skillId, skillP)))
        end
      end
      if roleId == self.m_Player:getMainHeroId() and skillData ~= nil and type(skillData.targetNum) == "table" then
        local nextExp, nextNum
        for index = #skillData.targetNum, 1, -1 do
          local data = skillData.targetNum[index]
          local needExp = data[1]
          local num = data[2]
          if skillP < needExp then
            nextExp = needExp
            nextNum = num
          end
        end
        if nextExp ~= nil then
          des = des .. string.format("\n\n#<G>*%d熟练度以上，可对%d个目标使用#", nextExp, nextNum)
        end
      end
      if roleId ~= self.m_Player:getMainHeroId() and roleIns:getType() == LOGICTYPE_HERO and not roleIns:getSkillIsOpen(skillId) then
        local step = data_getSkillStep(skillId)
        if step == 3 then
          des = des .. string.format("\n\n#<G>%d级时开启#", Skill_HuobanSkill1OpenLv)
        elseif step == 4 then
          des = des .. string.format("\n\n#<G>%d级时开启#", Skill_HuobanSkill2OpenLv)
        elseif step == 5 then
          des = des .. string.format("\n\n#<G>%d级时开启#", Skill_HuobanSkill3OpenLv)
        end
      end
      if roleIns:getType() == LOGICTYPE_PET and not roleIns:getSkillIsOpen(skillId) and not roleIns:getBDSkillIsOpen(skillId) then
        local step = data_getSkillStep(skillId)
        if step == 3 then
          des = des .. string.format("\n\n#<G>召唤兽等级到达%d时开启#", Skill_PetSkill1OpenLv)
        elseif step == 4 then
          des = des .. string.format("\n\n#<G>召唤兽等级到达%d时开启#", Skill_PetSkill2OpenLv)
        end
      end
    end
    tempDesc:addRichText(string.format("%s", des))
  end
  local realDescSize = tempDesc:getContentSize()
  tempDesc:setPosition(ccp(x, y + descSize.height - realDescSize.height))
  local bgSize = self.m_Bg:getSize()
  local w = bgSize.width
  local h = bgSize.height
  if realDescSize.height > descSize.height then
    self.m_Bg:ignoreContentAdaptWithSize(false)
    self.m_Bg:setSize(CCSize(w, h + realDescSize.height - descSize.height))
    self.m_Bg:setPosition(ccp(0, h + realDescSize.height - descSize.height))
  end
end
function CSkillDetailView:setLingwuSkill()
  local path = data_getSkillPinJieIconPath(self.m_SkillId)
  local tempImg = display.newSprite(path)
  local x, y = self:getNode("iconImg"):getPosition()
  local z = self:getNode("iconImg"):getZOrder()
  local size = self:getNode("iconImg"):getSize()
  local mSize = tempImg:getContentSize()
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  tempImg:setScale(size.width / mSize.width)
  self.m_Bg:addNode(tempImg, z)
  local skillName = data_getSkillName(self.m_SkillId)
  self:getNode("txt_name"):setText(skillName)
  local x, y = self:getNode("skillDesc"):getPosition()
  local descSize = self:getNode("skillDesc"):getSize()
  local tempDesc = CRichText.new({
    width = descSize.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 20,
    color = ccc3(255, 255, 255)
  })
  self.m_Bg:addChild(tempDesc)
  local roleIns
  if self.m_RoleId ~= nil then
    roleIns = self.m_Player:getObjById(self.m_RoleId)
  end
  local des = ""
  if roleIns ~= nil and self.m_isChatSys ~= true then
    des = GetSkillDesString(roleIns, self.m_SkillId, self.m_XuiLianData)
  elseif self.m_isChatSys == true then
    des = data_getPetSkillWbDesc(self.m_SkillId)
  end
  tempDesc:addRichText(des)
  local realDescSize = tempDesc:getContentSize()
  tempDesc:setPosition(ccp(x, y + descSize.height - realDescSize.height))
  local bgSize = self.m_Bg:getSize()
  local w = bgSize.width
  local h = bgSize.height
  if realDescSize.height > descSize.height then
    self.m_Bg:ignoreContentAdaptWithSize(false)
    self.m_Bg:setSize(CCSize(w, h + realDescSize.height - descSize.height))
    self.m_Bg:setPosition(ccp(0, h + realDescSize.height - descSize.height))
  end
  local x, y = self.btn_del:getPosition()
  self.btn_del:setPosition(ccp(x, y - realDescSize.height + descSize.height))
  local x, y = self.btn_xiulian:getPosition()
  self.btn_xiulian:setPosition(ccp(x, y - realDescSize.height + descSize.height))
end
function CSkillDetailView:AutoDelSelf()
  if self.m_DelSelfHandler then
    scheduler.unscheduleGlobal(self.m_DelSelfHandler)
  end
  self.m_DelSelfHandler = scheduler.scheduleGlobal(function()
    print("CSkillDetailView---removeself")
    self:removeFromParent()
  end, 3)
end
function CSkillDetailView:getViewSize()
  return self.m_Bg:getSize()
end
function CSkillDetailView:Clear()
  print("CSkillDetailView---del")
  if self.m_DelSelfHandler then
    scheduler.unscheduleGlobal(self.m_DelSelfHandler)
  end
  g_Click_Skill_View = nil
end
function CSkillDetailView:OnBtn_Close(btnObj, touchType)
  self:removeFromParent()
end
function CSkillDetailView:OnBtn_DelSkill(btnObj, touchType)
  print("点击删除技能")
  if self.m_RoleId ~= nil then
    roleIns = self.m_Player:getObjById(self.m_RoleId)
    if roleIns then
      do
        local skillPos, ssFlag
        local pskills = roleIns:getProperty(PROPERTY_PETSKILLS)
        if type(pskills) ~= "table" then
          pskills = {}
        end
        for index, d in pairs(pskills) do
          if d > 0 and d == self.m_SkillId then
            skillPos = index
            break
          end
        end
        if skillPos == nil then
          local ssskills = roleIns:getProperty(PROPERTY_SSSKILLS)
          if type(ssskills) ~= "table" then
            ssskills = {}
          end
          for index, d in pairs(ssskills) do
            if d > 0 and d == self.m_SkillId then
              skillPos = index
              ssFlag = 1
              break
            end
          end
        end
        if skillPos ~= nil then
          local petName = roleIns:getProperty(PROPERTY_NAME)
          local zs = roleIns:getProperty(PROPERTY_ZHUANSHENG)
          local color = NameColor_Pet[zs] or ccc3(255, 255, 255)
          local cost, costType = data_getDelPetSkillCost(self.m_SkillId)
          local skillName = data_getSkillName(self.m_SkillId)
          local txt = string.format("删除技能需要花费%d#<IR%d>#，是否需要立即删除#<r:%d,g:%d,b:%d>%s#所领悟的#<R>%s#技能？", cost, costType, color.r, color.g, color.b, petName, skillName)
          local confirmBoxDlg = CPopWarning.new({
            title = "提示",
            text = txt,
            confirmFunc = function()
              ShowWarningInWar()
              netsend.netbaseptc.deleteSkillAtPos(self.m_RoleId, skillPos, ssFlag)
            end,
            confirmText = "确定",
            cancelText = "取消",
            align = CRichText_AlignType_Left,
            fontSize = 20
          })
          confirmBoxDlg:ShowCloseBtn(false)
        end
      end
    end
  end
  self:removeFromParent()
end
function CSkillDetailView:OnBtn_XiuLianSkill(btnObj, touchType)
  if self.m_Player == g_LocalPlayer then
    ShowXiuLianSkillView(self.m_petId, self.m_SkillId)
    self:removeFromParent()
  end
end
function GetSkillDesString(roleIns, skillId, xiulianData)
  if roleIns == nil then
    return ""
  end
  local returnDes = ""
  if xiulianData ~= nil then
    local curExp = xiulianData[1] or 0
    local maxExp = xiulianData[2] or 0
    local itemName = data_getItemName(ITEM_DEF_OTHER_TaiXuDan)
    local skillName = data_getSkillName(skillId)
    returnDes = string.format("修炼进度:%d/%d\n修炼完成后可领悟#<Y>%s#技能,#<CTP>使用##<CI:%d>%s##<CTP>可以增加修炼进度。#", curExp, maxExp, skillName, ITEM_DEF_OTHER_TaiXuDan, itemName)
    return returnDes
  end
  local skillType = _getSkillStyle(skillId)
  if skillType == SKILLSTYLE_INITIATIVE then
    returnDes = returnDes .. "【类型】主动\n"
  else
    returnDes = returnDes .. "【类型】被动\n"
  end
  local petLv = roleIns:getProperty(PROPERTY_ROLELEVEL)
  local petClose = roleIns:getProperty(PROPERTY_CLOSEVALUE)
  local maxMp = roleIns:getMaxProperty(PROPERTY_MP)
  local roleType = roleIns:getType()
  local needMp = _computePetSkillRequireMp(skillId, petLv, petClose, maxMp, roleType)
  if skillType == SKILLSTYLE_INITIATIVE then
    returnDes = returnDes .. string.format("【消耗MP】%d\n", needMp)
  end
  local des = ""
  des = data_getSkillDesc(skillId)
  if skillId == PETSKILL_CHANGYINDONGDU then
    des = string.gsub(des, "#PPA#", string.format("#<Y>%s#", _computePetSkill_ChangYinDongDu(petLv, petClose)))
  elseif skillId == PETSKILL_YUANQUANWANHU then
    des = string.gsub(des, "#PPA#", string.format("#<Y>%s#", _computePetSkill_YuanQuanWanHu(petLv, petClose)))
  elseif skillId == PETSKILL_SHENGONGGUILI then
    des = string.gsub(des, "#PPA#", string.format("#<Y>%s#", _computePetSkill_ShenGongGuiLi(petLv, petClose)))
  elseif skillId == PETSKILL_BEIDAOJIANXING then
    des = string.gsub(des, "#PPA#", string.format("#<Y>%s#", _computePetSkill_BeiDaoJianXing(petLv, petClose)))
  elseif skillId == PETSKILL_SHISIYAOJUE then
    des = string.gsub(des, "#PPB#", string.format("#<Y>%s%%%%#", math.floor(_computePetSkill_ShiSiYaoJue(petLv, petClose) * 100)))
  elseif skillId == PETSKILL_FENSHENYAOJUE then
    des = string.gsub(des, "#PPC#", string.format("#<Y>%s%%%%#", math.floor(_computePetSkill_FenShenYaoJue(petLv, petClose) * 100)))
  elseif skillId == PETSKILL_HUNFEIYAOJUE then
    des = string.gsub(des, "#PPB#", string.format("#<Y>%s%%%%#", math.floor(_computePetSkill_HunFeiYaoJue(petLv, petClose) * 100)))
  elseif skillId == PETSKILL_WANYINGYAOJUE then
    des = string.gsub(des, "#PPC#", string.format("#<Y>%s%%%%#", math.floor(_computePetSkill_WanYingYaoJue(petLv, petClose) * 100)))
  elseif skillId == PETSKILL_FENLIEGONGJI then
  elseif skillId == PETSKILL_CIWUFANBU then
    local rate, _ = _computePetSkill_CiWuFanBu(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_FANBUZHISI then
    local rate, _ = _computePetSkill_FanBuZhiSi(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_ZHAOYUNMUYU then
    local hurt, _, _ = _computePetSkill_ZhaoYunMuYu(petLv, petClose)
    des = string.gsub(des, "#PPE#", string.format("#<Y>%s#", hurt))
  elseif skillId == PETSKILL_XIANFENGDAOGU then
  elseif skillId == PETSKILL_MIAOSHOURENXIN then
  elseif skillId == PETSKILL_FENGYIN then
    local rate, _ = _computePetSkill_FengYin(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_HUNLUAN then
    local rate, _ = _computePetSkill_HunLuan(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_ZHONGCHENG then
  elseif skillId == PETSKILL_DAYI then
    local rate, _, _ = _computePetSkill_DaYi(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_ZIYI then
    local rate, _ = _computePetSkill_ZiYi(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_YICHAN then
  elseif skillId == PETSKILL_QINGMINGSHU then
    local rate = _computePetSkill_QingMingShu(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_TUOKUNSHU then
    local rate = _computePetSkill_TuoKunShu(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_NINGSHENSHU then
    local rate = _computePetSkill_NingShenShu(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_JINGANGBUHUAI then
    local rate = _computePetSkill_JinGangBuHuai(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_ZHONGBUBIWEI then
    local rate = _computePetSkill_ZhongBuBiWei(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_YITUIWEIJIN then
  elseif skillId == PETSKILL_HUIGEHUIRI then
    des = string.gsub(des, "#PPF#", string.format("#<Y>%s#", _computePetSkill_HuiGeHuiRi()))
  elseif skillId == PETSKILL_PANSHAN then
    des = string.gsub(des, "#PPG#", string.format("#<Y>%s#", _computePetSkill_PanShan(petLv, petClose)))
  elseif skillId == PETSKILL_NUXIAN then
    local rate = _computePetSkill_NuXian(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_HENXIAN then
    local rate = _computePetSkill_HenXian(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_DAOQIANGBURU then
    des = string.gsub(des, "#PPH#", string.format("#<Y>%s#", _computePetSkill_DaoQiangBuRu(petLv, petClose)))
  elseif skillId == PETSKILL_FUSHANG then
    local rate, _ = _computePetSkill_FuShang(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_LANGYUEQINGFENG then
    des = string.gsub(des, "#PPI#", string.format("#<Y>%s%%%%#", math.floor(_computePetSkill_LangYueQingFeng(petLv, petClose) * 100)))
  elseif skillId == PETSKILL_YIHUAN then
    local hurt = _computePetSkill_YiHuan(petLv, petClose)
    des = string.gsub(des, "#PPO#", string.format("#<Y>%s#", hurt))
  elseif skillId == PETSKILL_XUANREN then
    local hurt = _computePetSkill_XuanRen(petLv, petClose)
    des = string.gsub(des, "#PPE#", string.format("#<Y>%s#", hurt))
  elseif skillId == PETSKILL_GAOJIQINGMINGSHU then
    local rate = _computePetSkill_GaoJiQingMingShu(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_GAOJITUOKUNSHU then
    local rate = _computePetSkill_GaoJiTuoKunShu(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_GAOJININGSHENSHU then
    local rate = _computePetSkill_GaoJiNingShenShu(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_GAOJIFENLIEGONGJI then
  elseif skillId == PETSKILL_GAOJICIWUFANBU then
    local rate, _ = _computePetSkill_GaoJiCiWuFanBu(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_GAOJIFANBUZHISI then
    local rate, _ = _computePetSkill_GaoJiCiWuFanBu(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_RENLAIFENG then
    local rate, hurt = _computePetSkill_RenLaiFeng(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
    des = string.gsub(des, "#PPE#", string.format("#<Y>%s#", hurt))
  elseif skillId == PETSKILL_TAOMING then
    des = string.gsub(des, "#PPJ#", string.format("#<Y>%s#", _computePetSkill_TaoMing(petLv, petClose)))
  elseif skillId == PETSKILL_HUIYUAN then
    local rate, _ = _computePetSkill_HuiYuan(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_BAOFU then
    local rate, hurt = _computePetSkill_BaoFu(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
    des = string.gsub(des, "#PPE#", string.format("#<Y>%s#", hurt))
  elseif skillId == PETSKILL_FEIYANHUIXIANG then
    local rate = _computePetSkill_FeiYanHuiXiang(petLv, petClose)
    des = string.gsub(des, "#PPP#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_YINGJICHANGKONG then
  elseif skillId == PETSKILL_BUBUSHENGLIAN then
    local _, _, _, rate, _ = _computePetSkill_BuBuShengLian(petLv, petClose)
    des = string.gsub(des, "#PPK#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_LIUANHUAMING then
  elseif skillId == PETSKILL_JINTUIZIRU then
  elseif skillId == PETSKILL_LONGZHANYUYE then
    local rate, _, _ = _computePetSkill_LongZhanYuYe(petLv, petClose)
    des = string.gsub(des, "#PPL#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_HENGYUNDUANFENG then
    local rate, _, _, _ = _computePetSkill_HengYunDuanFeng(petLv, petClose)
    des = string.gsub(des, "#PPM#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_SHUSHOUWUCE then
    local rate, _ = _computePetSkill_ShuShouWuCe(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_SHUNSHUITUIZHOU then
    local rate, _ = _computePetSkill_ShunShuiTuiZhou(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_NIANHUAYIXIAO then
    local hurt, _, _ = _computePetSkill_NianHuaYiXiao(petLv, petClose)
    des = string.gsub(des, "#PPN#", string.format("#<Y>%s#", hurt))
  elseif skillId == PETSKILL_FENHUAFULIU then
    local rate = _computePetSkill_FenHuaFuLiu(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_FULUSHUANGQUAN then
  elseif skillId == PETSKILL_JIRENTIANXIANG then
  elseif skillId == PETSKILL_MIAOBISHENGHUA then
    local rate, _ = _computePetSkill_MiaoBiShengHua(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_JINYUZHOU then
  elseif skillId == PETSKILL_XIUMUZHOU then
  elseif skillId == PETSKILL_LIUSHUIZHOU then
  elseif skillId == PETSKILL_LIEYANZHOU then
  elseif skillId == PETSKILL_LIETUZHOU then
  elseif skillId == PETSKILL_ZHINANERTUI then
    local rate, _, _ = _computePetSkill_ZhiNanErTui(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_SHUNSHOUQIANYANG then
    local rate = _computePetSkill_ShunShouQianYang(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_JINLINGHUTI or skillId == PETSKILL_MULINGHUTI or skillId == PETSKILL_SHUILINGHUTI or skillId == PETSKILL_HUOLINGHUTI or skillId == PETSKILL_TULINGHUTI then
    local _, _, _, rate, _, _ = _computePetSkill_WuXingHuTi(skillId, petLv, petClose)
    des = string.gsub(des, "#PPI#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_FENGMO then
    local rate, _ = _computePetSkill_FengMo(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_JUEJINGFENGSHENG then
  elseif skillId == PETSKILL_ZIXUWUYOU then
  elseif skillId == PETSKILL_HUAWU then
  elseif skillId == PETSKILL_JIANGSI then
  elseif skillId == PETSKILL_DANGTOUBANGHE then
  elseif skillId == PETSKILL_MINGCHAQIUHAO then
  elseif skillId == PETSKILL_SHUANGGUANQIXIA then
  elseif skillId == PETSKILL_ZUONIAOSHOUSAN then
  elseif skillId == PETSKILL_CHUNNUANHUAKAI then
  elseif skillId == PETSKILL_YIYAHUANYA then
  elseif skillId == PETSKILL_CHUNHUIDADI then
  elseif skillId == PETSKILL_DUOHUNSUOMING then
    local rate, _, _, _ = _computePetSkill_DuoHunSuoMing(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_QIANGHUAXUANREN then
    local hurt = _computePetSkill_QiangHuaXuanRen(petLv, petClose)
    des = string.gsub(des, "#PPE#", string.format("#<Y>%s#", hurt))
  elseif skillId == PETSKILL_QIANGHUAYIHUAN then
    local hurt = _computePetSkill_QiangHuaYiHuan(petLv, petClose)
    des = string.gsub(des, "#PPO#", string.format("#<Y>%s#", hurt))
  elseif skillId == PETSKILL_BINGLINCHENGXIA then
  elseif skillId == PETSKILL_RUHUTIANYI then
  elseif skillId == PETSKILL_NIEPAN then
    local rate = _computePetSkill_NiePan(petLv, petClose)
    des = string.gsub(des, "#PPD#", string.format("#<Y>%s%%%%#", math.floor(rate * 100)))
  elseif skillId == PETSKILL_JINGGUANBAIRI then
  elseif skillId == PETSKILL_CHAOMINGDIANCHE then
    des = string.gsub(des, "#PPA#", string.format("#<Y>%s#", _computePetSkill_ChaoMingDianChe(petLv, petClose)))
  end
  returnDes = returnDes .. string.format("%s\n", des)
  local coverSkill = roleIns:skillIsCoverByOtherSkill(skillId)
  if coverSkill ~= nil then
    local coverSkillName = data_getSkillName(coverSkill)
    returnDes = returnDes .. string.format("#<G>此技能已被##<R>%s##<G>所覆盖,暂时失效#", coverSkillName)
  end
  return returnDes
end
