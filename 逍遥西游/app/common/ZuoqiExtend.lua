ZuoqiExtend = {}
function ZuoqiExtend.extend(object)
  function object:newZuoqiWithServerPro(objId, lTypeId, svrPro)
    local obj = object:newObject(objId, lTypeId)
    if obj then
      object:setSvrproToZuoqi(obj, svrPro)
      if object.m_IsLocal then
        obj:setPropertyChanagedListener(handler(object, object.ObjectPropertyChanged))
      end
      object:AddObject(objId, obj)
    end
    print("\n\n\n-------新增坐骑----------\n\n\n")
    SendMessage(MsgID_NewZuoqi, {
      pid = object.m_RoleId,
      zuoqiId = objId,
      zuoqiType = lTypeId
    })
    if g_DataMgr:getIsSendFinished() then
      ShowNewZuoqiAnimation(objId, lTypeId)
    end
    return obj
  end
  function object:setSvrproToZuoqi(zuoqi, svrPro, isNew)
    local proTable = {}
    for k, v in pairs(svrPro) do
      local pro = SVRKEY_PROPERTIES[k]
      if pro and zuoqi:getProperty(pro) ~= v then
        zuoqi:setProperty(pro, v)
        proTable[pro] = v
      end
    end
    local OldPetList = {}
    if svrPro.t_pets ~= nil then
      OldPetList = zuoqi:getProperty(PROPERTY_ZUOQI_PETLIST)
      local petListValue = {}
      for _, v in pairs(svrPro.t_pets) do
        petListValue[#petListValue + 1] = v.i_pid
      end
      table.sort(petListValue)
      if isListEqual(zuoqi:getProperty(PROPERTY_ZUOQI_PETLIST), petListValue) == false then
        zuoqi:setProperty(PROPERTY_ZUOQI_PETLIST, petListValue)
        proTable[PROPERTY_ZUOQI_PETLIST] = DeepCopyTable(petListValue)
      end
      if #petListValue > 0 then
        g_MissionMgr:GuideIdComplete(GuideId_ManagePet)
      end
    end
    if svrPro.t_sks ~= nil then
      local skillListValue = {}
      for _, v in pairs(svrPro.t_sks) do
        skillListValue[#skillListValue + 1] = v.i_skid
      end
      table.sort(skillListValue)
      if isListEqual(zuoqi:getProperty(PROPERTY_ZUOQI_SKILLLIST), skillListValue) == false then
        zuoqi:setProperty(PROPERTY_ZUOQI_SKILLLIST, skillListValue)
        proTable[PROPERTY_ZUOQI_SKILLLIST] = DeepCopyTable(skillListValue)
      end
    end
    if svrPro.i_ride ~= nil then
      if svrPro.i_ride == true then
        if isListEqual(zuoqi:getProperty(PROPERTY_ZuoqiRideState), 1) == false then
          zuoqi:setProperty(PROPERTY_ZuoqiRideState, 1)
          proTable[PROPERTY_ZuoqiRideState] = DeepCopyTable(1)
        end
      elseif isListEqual(zuoqi:getProperty(PROPERTY_ZuoqiRideState), 2) == false then
        zuoqi:setProperty(PROPERTY_ZuoqiRideState, 2)
        proTable[PROPERTY_ZuoqiRideState] = DeepCopyTable(2)
      end
    elseif isListEqual(zuoqi:getProperty(PROPERTY_ZuoqiRideState), 2) == false then
      zuoqi:setProperty(PROPERTY_ZuoqiRideState, 2)
      proTable[PROPERTY_ZuoqiRideState] = DeepCopyTable(2)
    end
    if table_is_empty(proTable) == false then
      zuoqi:CalculateProperty()
      if OldPetList ~= nil and OldPetList ~= 0 then
        for _, petId in pairs(OldPetList) do
          local petIns = object:getObjById(petId)
          if petIns then
            petIns:CalculateProperty()
          end
        end
      end
      if isNew ~= true then
        SendMessage(MsgID_ZuoqiUpdate, {
          pid = object.m_RoleId,
          zuoqiId = zuoqi:getObjId(),
          pro = proTable
        })
      end
    end
  end
  function object:DeleteZuoQi(objId)
    self:DeleteRole(objId)
    if self == g_LocalPlayer then
      SendMessage(MsgID_DeleteZuoqi, objId)
    end
  end
  function object:getZuoqiByPetId(petId)
    local zuoqiList = object:getAllRoleIds(LOGICTYPE_ZUOQI)
    for _, zqId in pairs(zuoqiList) do
      local zqObj = object:getObjById(zqId)
      if zqObj ~= nil then
        local petList = zqObj:getProperty(PROPERTY_ZUOQI_PETLIST)
        if petList ~= nil and petList ~= 0 then
          for _, tempPetId in pairs(petList) do
            if tempPetId == petId then
              return zqId, zqObj
            end
          end
        end
      end
    end
    return 0, nil
  end
  function object:getZQSkillData(zqId, skillId)
    local AddDict = {}
    local zqObj = object:getObjById(zqId)
    if zqObj == nil then
      return AddDict
    end
    local skillP = zqObj:getProperty(PROPERTY_ZUOQI_SKILLPVALUE)
    local gg = zqObj:getProperty(PROPERTY_ZUOQI_GenGu)
    local lx = zqObj:getProperty(PROPERTY_ZUOQI_Lingxing)
    local ll = zqObj:getProperty(PROPERTY_ZUOQI_LiLiang)
    local skillData = data_ZuoqiSkill[skillId]
    if skillData ~= nil then
      for _, addPro in ipairs(ZQSKILL_ADDPRO_DICT) do
        local value = (skillData[addPro] or 0) * ((lx * skillData[ZQSKILLDEF_FD_LX] + ll * skillData[ZQSKILLDEF_FD_LL] + gg * skillData[ZQSKILLDEF_FD_GG]) / 144 + skillP / 400000)
        AddDict[ZQSKILL_2_ROLEPRO[addPro]] = value
      end
    end
    return AddDict
  end
  function object:delAllZQData()
    local zuoqiList = object:getAllRoleIds(LOGICTYPE_ZUOQI)
    for _, zqId in pairs(zuoqiList) do
      object:DeleteRole(zqId)
    end
  end
  function object:getPetAddZQSkillDataForWar(petId)
    local AddDict = {}
    local zqId, zqObj = object:getZuoqiByPetId(petId)
    if zqObj ~= nil then
      local skillP = zqObj:getProperty(PROPERTY_ZUOQI_SKILLPVALUE)
      local gg = zqObj:getProperty(PROPERTY_ZUOQI_GenGu)
      local lx = zqObj:getProperty(PROPERTY_ZUOQI_Lingxing)
      local ll = zqObj:getProperty(PROPERTY_ZUOQI_LiLiang)
      local skillList = zqObj:getProperty(PROPERTY_ZUOQI_SKILLLIST)
      if skillList == nil or skillList == 0 then
        skillList = {}
      end
      for _, skillId in pairs(skillList) do
        local skillData = data_ZuoqiSkill[skillId]
        for _, addPro in ipairs(ZQSKILL_ADDPRO_DICT) do
          local value = (skillData[addPro] or 0) * ((lx * skillData[ZQSKILLDEF_FD_LX] + ll * skillData[ZQSKILLDEF_FD_LL] + gg * skillData[ZQSKILLDEF_FD_GG]) / 144 + skillP / 400000)
          if AddDict[ZQSKILL_2_ROLEPRO[addPro]] ~= nil then
            AddDict[ZQSKILL_2_ROLEPRO[addPro]] = AddDict[ZQSKILL_2_ROLEPRO[addPro]] + value
          else
            AddDict[ZQSKILL_2_ROLEPRO[addPro]] = value
          end
        end
      end
      return AddDict
    else
      return {}
    end
  end
  function object:getZuoqiByPetIdForWar(petId)
    local zuoqiList = object:getAllRoleIds(LOGICTYPE_ZUOQI)
    for _, zqId in pairs(zuoqiList) do
      local zqObj = object:getObjById(zqId)
      if zqObj ~= nil then
        local petList = zqObj:getProperty(PROPERTY_ZUOQI_PETLIST)
        if petList ~= nil and petList ~= 0 then
          for _, tempPetId in pairs(petList) do
            if tempPetId == petId then
              return zqId
            end
          end
        end
      end
    end
    return 0
  end
end
return ZuoqiExtend
