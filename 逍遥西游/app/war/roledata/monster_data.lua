if not CMonsterData then
  CMonsterData = class("CMonsterData", CRoleData)
end
function CMonsterData:ctor(playerId, objId, lTypeId, copyProperties)
  CMonsterData.super.ctor(self, playerId, objId, lTypeId, copyProperties)
end
function CMonsterData:CalculateProperty()
  local pairs = pairs
  local data_table = data_Monster[self:getTypeId()]
  if data_table then
    for _, dict in pairs({
      PROPERTY_LEVEL_WUXING,
      PROPERTY_LEVEL_MONSTER,
      PROPERTY_LEVEL_NORMAL,
      PROPERTY_LEVEL_2,
      PROPERTY_LEVEL_KANG
    }) do
      for k, v in pairs(dict) do
        local v_ = data_table[v]
        if v_ then
          self:setProperty(v, v_)
        end
      end
    end
  end
  local lv = self:getProperty(PROPERTY_ROLELEVEL)
  local starValue = 1
  self:setProperty(PROPERTY_STARSKILLVALUE, starValue)
  local hp = CalculateRoleHP(self)
  self:setProperty(PROPERTY_HP, math.floor(hp))
  self:setMaxProperty(PROPERTY_HP, math.floor(hp))
  local mp = CalculateRoleMP(self)
  self:setProperty(PROPERTY_MP, math.floor(mp))
  self:setMaxProperty(PROPERTY_MP, math.floor(mp))
  local ap = CalculateRoleAP(self)
  self:setProperty(PROPERTY_AP, math.floor(ap))
  local sp = CalculateRoleSP(self)
  self:setProperty(PROPERTY_SP, math.floor(sp))
  self:setMaxProperty(PROPERTY_SP, math.floor(sp))
  local data_table = data_Monster[self:getTypeId()]
  local proficiency = data_getRoleProFromData(self:getTypeId(), PROPERTY_JNSLD) * lv
  if data_table then
    for i, v in ipairs(data_table.skills) do
      self:setProficiency(v, proficiency)
    end
  end
  if data_table then
    local pskillList = {}
    for i, v in ipairs(data_table.pskills) do
      if data_getMonterCanUseSkill(v) == 1 then
        for _, sId in pairs(ACTIVE_PETSKILLLIST) do
          if sId == v then
            self:setProficiency(v, 1)
            break
          end
        end
        pskillList[#pskillList + 1] = v
      end
    end
    self:initMonsterSkills(pskillList)
  end
  self:setProperty(PROPERTY_SKILLCOEFF, 1 - data_Variables.MonsterSkillEffect)
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
  local def = self:GetPetSkillDaoQiangBuRu()
  if def > 0 then
    self:setProperty(PROPERTY_PFYL, self:getProperty(PROPERTY_PFYL) + def)
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
  local zmpro = self:GetPetSkillJinGangBuHuai()
  if zmpro > 0 then
    self:setProperty(PROPERTY_FPCRIT, self:getProperty(PROPERTY_FPCRIT) + zmpro)
  end
end
