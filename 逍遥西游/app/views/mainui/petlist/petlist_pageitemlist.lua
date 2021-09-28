CPetList_PageItemList = class(".CPetList_PageItemList", CcsSubView)
function CPetList_PageItemList:ctor(petId, petlistObj)
  CPetList_PageItemList.super.ctor(self, "views/pet_list_itemlist.json")
  self.m_PetId = nil
  self.m_PetlistObj = petlistObj
  self:LoadPet(petId)
  self:InitItemList()
  self:ListenMessage(MsgID_ItemInfo)
end
function CPetList_PageItemList:LoadPet(petId)
  self.m_PetId = petId
  self.m_PetIns = g_LocalPlayer:getObjById(self.m_PetId)
end
function CPetList_PageItemList:InitItemList()
  self.poslayer = self:getNode("poslayer")
  self.poslayer:setVisible(false)
  local p = self.poslayer:getParent()
  local x, y = self.poslayer:getPosition()
  local z = self.poslayer:getZOrder()
  local param = {
    itemSize = CCSize(84, 84),
    pageLines = 4,
    oneLineNum = 3,
    fadeoutAction = fadeoutAction,
    xySpace = ccp(1, 12),
    pageIconOffY = -50
  }
  local tempSelectFunc = function(itemObj)
    local itemId = itemObj:getObjId()
    local itemType = itemObj:getTypeId()
    local itemLargeType = itemObj:getType()
    if itemLargeType == ITEM_LARGE_TYPE_OTHERITEM then
      if itemType == ITEM_DEF_OTHER_GJJLL or itemTypeId == ITEM_DEF_OTHER_CJJLL then
        return false
      end
      for _, tempId in pairs(PetViewUseItemList) do
        if tempId == itemType then
          return true
        end
      end
      if itemType == ITEM_DEF_OTHER_LYF or itemType == ITEM_DEF_OTHER_JFS then
        return true
      end
      local subType = GetItemSubTypeByItemTypeId(itemType)
      if subType == ITEM_DEF_TYPE_SKILLBOOK then
        return true
      end
      return false
    elseif itemLargeType == ITEM_LARGE_TYPE_LIFEITEM then
      if data_getLifeSkillType(itemType) == IETM_DEF_LIFESKILL_DRUG then
        return true
      else
        return false
      end
    end
    return true
  end
  self.m_PackageFrame = CPackageFrame.new(ITEM_PACKAGE_TYPE_PETOTHER, handler(self, self.ShowPackageDetail), handler(self, self.OnPageChanged), param, tempSelectFunc)
  self.m_PackageFrame:setPosition(ccp(x, y))
  p:addChild(self.m_PackageFrame, z)
end
function CPetList_PageItemList:ShowPackageDetail(itemObjId, isCurrEquip)
  local itemIns = g_LocalPlayer:GetOneItem(itemObjId)
  if itemIns == nil then
    return
  end
  if isCurrEquip then
    local rightBtnParam
    local level = itemIns:getProperty(ITEM_PRO_LV)
    local zs = itemIns:getProperty(ITEM_PRO_NEIDAN_ZS)
    local lvMax = CalculateNeidanLevelLimit(zs)
    if zs < CalculateNeidanZSLimit() then
      if level >= lvMax then
        rightBtnParam = {
          btnText = "魂石转生",
          listener = handler(self, self.OnZhuanShengNeiDan)
        }
      else
        rightBtnParam = {
          btnText = "一键升级",
          listener = handler(self, self.OnOneKeyLevelUpNeiDan)
        }
      end
    elseif zs == CalculateNeidanZSLimit() and level < lvMax then
      rightBtnParam = {
        btnText = "一键升级",
        listener = handler(self, self.OnOneKeyLevelUpNeiDan)
      }
    end
    self.m_EquipDetail = CEquipDetail.new(itemObjId, {
      leftBtn = {
        btnText = "吐出魂石",
        listener = handler(self, self.OnTakeDownNeiDan)
      },
      rightBtn = rightBtnParam,
      closeListener = handler(self, self.OnEquipDetailClosed),
      eqptRoleId = self.m_PetId
    })
    self.m_PetlistObj:addSubView({
      subView = self.m_EquipDetail,
      zOrder = 9999
    })
    local x, y = self.m_PetlistObj.pic_leftbg:getPosition()
    local iSize = self.m_PetlistObj.pic_leftbg:getContentSize()
    local bSize = self.m_EquipDetail:getBoxSize()
    self.m_EquipDetail:setPosition(ccp(x + iSize.width / 2 - bSize.width, y - bSize.height / 2))
    self.m_EquipDetail:ShowCloseBtn()
  else
    local rightBtnParam
    local itemType = itemIns:getType()
    if itemType == ITEM_LARGE_TYPE_NEIDAN then
      rightBtnParam = {
        btnText = "装备",
        listener = handler(self, self.OnTakeUpNeiDan)
      }
    else
      rightBtnParam = {
        btnText = "使用",
        listener = handler(self, self.OnUseItemForPet)
      }
    end
    self.m_EquipDetail = CEquipDetail.new(itemObjId, {
      leftBtn = {
        btnText = "出售",
        listener = handler(self, self.OnSellItem)
      },
      rightBtn = rightBtnParam,
      closeListener = handler(self, self.OnEquipDetailClosed),
      eqptRoleId = self.m_PetId
    })
    self.m_PetlistObj:addSubView({
      subView = self.m_EquipDetail,
      zOrder = 9999
    })
    self.m_EquipDetail:ShowCloseBtn()
    local x, y = self.m_PetlistObj.pic_probg:getPosition()
    local iSize = self.m_PetlistObj.pic_probg:getContentSize()
    local bSize = self.m_EquipDetail:getBoxSize()
    self.m_EquipDetail:setPosition(ccp(x - bSize.width - 1, y - bSize.height / 2))
  end
end
function CPetList_PageItemList:OnZhuanShengNeiDan(itemId)
  local itemIns = g_LocalPlayer:GetOneItem(itemId)
  if itemIns == nil then
    return
  end
  local zs = itemIns:getProperty(ITEM_PRO_NEIDAN_ZS)
  if zs >= CalculateNeidanZSLimit() then
    ShowNotifyTips("魂石转生次数已达上限")
    return
  end
  local lv = itemIns:getProperty(ITEM_PRO_LV)
  local lvMax = CalculateNeidanLevelLimit(zs)
  if lv < lvMax then
    ShowNotifyTips(string.format("魂石达到%d转%d级时才能转生", zs, lvMax))
    return
  end
  local petZs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
  if zs >= petZs then
    ShowNotifyTips("魂石转生次数不能高于召唤兽转生次数")
    return
  end
  zs = zs + 1
  local tempPop = CPopWarning.new({
    title = "提示",
    text = string.format("#<r:206,g:187,b:151,>魂石转生后会变为##<r:217,g:120,b:10>\n%d转0级##<r:206,g:187,b:151>\n\n等级上限提升为##<r:217,g:120,b:10>\n%d级#", zs, lvMax),
    confirmFunc = function()
      self:ConfirmZhuanShengNeiDan(itemId)
    end
  })
  tempPop:ShowCloseBtn(false)
end
function CPetList_PageItemList:ConfirmZhuanShengNeiDan(itemId)
  netsend.netitem.requestNeiDanZhuanSheng(itemId, self.m_PetId)
  ShowWarningInWar()
end
function CPetList_PageItemList:OnOneKeyLevelUpNeiDan(itemId)
  local itemIns = g_LocalPlayer:GetOneItem(itemId)
  local ndZS = itemIns:getProperty(ITEM_PRO_NEIDAN_ZS)
  local ndLV = itemIns:getProperty(ITEM_PRO_LV)
  local petZs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
  local petLv = self.m_PetIns:getProperty(PROPERTY_ROLELEVEL)
  if ndZS > petZs then
    ShowNotifyTips("召唤兽转生次数小于魂石转生次数时不能升级")
  elseif ndZS == petZs and ndLV >= petLv then
    ShowNotifyTips("魂石等级不能高于召唤兽等级")
  else
    local myCoin = g_LocalPlayer:getCoin()
    local temp = data_ndLvupCondtion[ndLV + 1]
    netsend.netitem.requestOnekeyLevelupNeiDan(itemId, self.m_PetId)
    if temp then
      local lvupcost = temp[string.format("rb%d", ndZS)]
      if myCoin >= lvupcost then
        ShowWarningInWar()
      end
    end
  end
end
function CPetList_PageItemList:OnTakeUpNeiDan(itemId)
  local itemIns = g_LocalPlayer:GetOneItem(itemId)
  local itemTypeId = itemIns:getTypeId()
  if self.m_PetIns:GetNeidanObj(itemTypeId) ~= nil then
    ShowNotifyTips("同一类型魂石只能装备一个")
    return
  end
  local msg = self.m_PetIns:CanAddItem(itemId)
  if msg == true then
    local canTakeupFlag = false
    for index = 1, 3 do
      local ndBtn = self.m_PetlistObj[string.format("btn_neidan_%d", index)]
      if ndBtn and ndBtn._ndState == 0 then
        canTakeupFlag = true
        break
      end
    end
    if canTakeupFlag then
      netsend.netitem.requestTakeUpNeiDan(itemId, self.m_PetId)
      ShowWarningInWar()
      self:CloseEquipDetail()
    else
      ShowNotifyTips("该召唤兽的魂石栏已满，无法装备")
    end
  else
    ShowNotifyTips(msg)
  end
end
function CPetList_PageItemList:OnTakeDownNeiDan(itemId)
  netsend.netitem.requestTakeDownNeiDan(itemId, self.m_PetId)
  ShowWarningInWar()
  self:CloseEquipDetail()
end
function CPetList_PageItemList:OnUseItemForPet(itemId)
  local player = g_DataMgr:getPlayer()
  local itemIns = player:GetOneItem(itemId)
  if itemIns ~= nil then
    do
      local itemType = itemIns:getType()
      local itemTypeId = itemIns:getTypeId()
      for _, tempId in pairs(PetViewUseItemList) do
        if tempId == itemTypeId then
          if itemTypeId == ITEM_DEF_OTHER_LZG then
            if self.m_PetIns:getProperty(PROPERTY_LONGGU_NUM) < 3 then
              netsend.netitem.requestUseItem(itemId, self.m_PetId)
              ShowWarningInWar()
            else
              ShowNotifyTips("每个宠物最多只能使用3个成长丹")
              self:CloseEquipDetail()
              return
            end
          elseif itemTypeId == ITEM_DEF_OTHER_XSD then
            if self.m_PetIns:getProperty(PROPERTY_LONGGU_NUM) <= 0 then
              ShowNotifyTips("没有成长丹效果无法使用成长重置丹")
            else
              local petName = self.m_PetIns:getProperty(PROPERTY_NAME)
              local dlg = CPopWarning.new({
                title = "提示",
                text = string.format(" 使用成长重置丹后，将会#<G,>去除召唤兽所有成长丹增加的属性及次数#，你确定要对%s使用吗？ ", petName or "召唤兽"),
                confirmFunc = function(...)
                  netsend.netitem.requestUseItem(itemId, self.m_PetId)
                  ShowWarningInWar()
                end,
                confirmText = "确定",
                cancelText = "取消"
              })
              dlg:ShowCloseBtn(false)
            end
          elseif itemTypeId == ITEM_DEF_OTHER_JZYJW then
            local petZs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
            if petZs >= 1 then
              ShowNotifyTips("0转宠物才能使用")
              self:CloseEquipDetail()
              return
            end
            local mainHeroIns = g_LocalPlayer:getMainHero()
            if mainHeroIns then
              local zs = mainHeroIns:getProperty(PROPERTY_ZHUANSHENG)
              if zs <= 0 then
                ShowNotifyTips("主角达到1转以上才能使用")
                self:CloseEquipDetail()
                return
              end
              netsend.netitem.requestUseItem(itemId, self.m_PetId)
              ShowWarningInWar()
              self:CloseEquipDetail()
            end
          elseif itemTypeId == ITEM_DEF_OTHER_HYD then
            local xiFlag = false
            local lv = self.m_PetIns:getProperty(PROPERTY_ROLELEVEL)
            for _, k in pairs({
              PROPERTY_OGenGu,
              PROPERTY_OLiLiang,
              PROPERTY_OMinJie,
              PROPERTY_OLingxing
            }) do
              local pts = self.m_PetIns:getProperty(k)
              if lv < pts then
                xiFlag = true
                break
              end
            end
            if not xiFlag then
              ShowNotifyTips("你的召唤兽目前不需要使用该物品")
              return
            end
            local function func2()
              netsend.netitem.requestUseItem(itemId, self.m_PetId)
              ShowWarningInWar()
            end
            local tempPop = CPopWarning.new({
              title = "提示",
              text = string.format("你确定要使用#<G>%s#重置召唤兽的加点吗？", data_getItemName(ITEM_DEF_OTHER_HYD)),
              confirmFunc = func2,
              align = CRichText_AlignType_Left,
              cancelFunc = nil,
              closeFunc = nil,
              confirmText = "确定",
              cancelText = "取消"
            })
            tempPop:ShowCloseBtn(false)
            self:CloseEquipDetail()
          elseif itemTypeId == ITEM_DEF_OTHER_SSD or itemTypeId == ITEM_DEF_OTHER_GJSSD or itemTypeId == ITEM_DEF_OTHER_CJSSD then
            local mainHeroIns = g_LocalPlayer:getMainHero()
            if mainHeroIns then
              local petLv = self.m_PetIns:getProperty(PROPERTY_ROLELEVEL)
              local petZs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
              local name = self.m_PetIns:getProperty(PROPERTY_NAME)
              local heroLv = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
              local heroZs = mainHeroIns:getProperty(PROPERTY_ZHUANSHENG)
              local itemName = itemIns:getProperty(ITEM_PRO_NAME)
              if petZs > heroZs or heroZs == petZs and petLv >= heroLv + PETLV_HEROLV_MAXDEL then
                ShowNotifyTips(string.format("%s超过你的等级%d级,无法使用%s", name, PETLV_HEROLV_MAXDEL, itemName))
                self:CloseEquipDetail()
              else
                netsend.netitem.requestUseItem(itemId, self.m_PetId)
                ShowWarningInWar()
              end
            end
          elseif itemTypeId == ITEM_DEF_OTHER_HJD then
            self:CloseEquipDetail()
            if data_getPetTypeIsCanHuaJing(self.m_PetIns:getTypeId()) == false then
              ShowNotifyTips("神兽才能使用化境丹")
              return
            end
            local hjNum = self.m_PetIns:getProperty(PROPERTY_HUAJING_NUM)
            local tempData = data_ShenShouHuaJing[hjNum + 1]
            local needLv = tempData.needLv
            local needZs = tempData.needZs
            local alwaysJudgeLvFlag = tempData.AlwaysJudgeLvFlag
            local curZs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
            local curLv = self.m_PetIns:getProperty(PROPERTY_ROLELEVEL)
            local canHJFlag = data_judgeFuncOpen(curZs, curLv, needZs, needLv, alwaysJudgeLvFlag)
            if hjNum == 0 then
              if not canHJFlag then
                ShowNotifyTips(tempData.tip or "")
                return
              end
            elseif hjNum == 1 then
              if not canHJFlag then
                ShowNotifyTips(tempData.tip or "")
                return
              end
            elseif hjNum == 2 then
              if not canHJFlag then
                ShowNotifyTips(tempData.tip or "")
                return
              end
            elseif hjNum == 3 and not canHJFlag then
              ShowNotifyTips(tempData.tip or "")
              return
            end
            local dlg = CShenShouHuajing.new(self.m_PetId)
            getCurSceneView():addSubView({
              subView = dlg,
              zOrder = MainUISceneZOrder.menuView
            })
          elseif itemTypeId == ITEM_DEF_OTHER_HUALINGWAN then
            self:CloseEquipDetail()
            if data_getPetTypeIsCanHuaLing(self.m_PetIns:getTypeId()) == false then
              ShowNotifyTips("灵兽才能使用化灵丸")
              return
            end
            local hlNum = self.m_PetIns:getProperty(PROPERTY_HUALING_NUM)
            if hlNum >= LINGSHOU_HUALING_MAX_NUM then
              ShowNotifyTips("灵兽最多化灵9次")
              return
            end
            local tempData = data_LingShouHuaLing[hlNum + 1]
            local needLv = tempData.needLv
            local needZs = tempData.needZs
            local alwaysJudgeLvFlag = tempData.AlwaysJudgeLvFlag
            local curZs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
            local curLv = self.m_PetIns:getProperty(PROPERTY_ROLELEVEL)
            local canHLFlag = data_judgeFuncOpen(curZs, curLv, needZs, needLv, alwaysJudgeLvFlag)
            if not canHLFlag then
              ShowNotifyTips(tempData.tip or "")
              return
            end
            local dlg = CLingShouHualing.new(self.m_PetId)
            getCurSceneView():addSubView({
              subView = dlg,
              zOrder = MainUISceneZOrder.menuView
            })
          elseif itemTypeId == ITEM_DEF_OTHER_JIAYIWAN then
            local popFlag = true
            if g_LocalPlayer then
              local jyPet = g_LocalPlayer:GetJiaYiWanPetId()
              if jyPet == nil then
                popFlag = false
              elseif jyPet == self.m_PetId then
                popFlag = false
              end
            end
            if popFlag then
              local petName = self.m_PetIns:getProperty(PROPERTY_NAME)
              local zs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
              local color = NameColor_Pet[zs] or ccc3(255, 255, 255)
              local tempPop = CPopWarning.new({
                title = "提示",
                text = string.format("你确定要对#<r:%d,g:%d,b:%d>%s#使用传功丹吗？(确认后将会清除其它召唤兽传功丹效果)", color.r, color.g, color.b, petName),
                confirmFunc = function()
                  netsend.netitem.requestUseItem(itemId, self.m_PetId)
                end,
                align = CRichText_AlignType_Left
              })
              tempPop:ShowCloseBtn(false)
              self:CloseEquipDetail()
              return
            else
              netsend.netitem.requestUseItem(itemId, self.m_PetId)
              self:CloseEquipDetail()
              return
            end
          elseif itemTypeId == ITEM_DEF_OTHER_TaiXuDan then
            self:CloseEquipDetail()
            ShowXiuLianSkillView(self.m_PetId)
            return
          elseif itemTypeId == ITEM_DEF_OTHER_QMD or itemTypeId == ITEM_DEF_OTHER_GJQMD or itemTypeId == ITEM_DEF_OTHER_CJQMD then
            local maxClose = data_PetClose[#data_PetClose].closeValue
            local petClose = self.m_PetIns:getProperty(PROPERTY_CLOSEVALUE)
            if maxClose and maxClose <= petClose then
              ShowNotifyTips("该召唤兽亲密度已满，不能使用亲密丹")
            else
              netsend.netitem.requestUseItem(itemId, self.m_PetId)
              ShowWarningInWar()
            end
          else
            netsend.netitem.requestUseItem(itemId, self.m_PetId)
            ShowWarningInWar()
          end
        end
      end
      if itemType == ITEM_LARGE_TYPE_OTHERITEM then
        if itemTypeId == ITEM_DEF_OTHER_LYF then
          self.m_PetlistObj:OnBtn_SkillLearn()
          local skillLearn = self.m_PetlistObj:getPageSkillLearn()
          if skillLearn then
            skillLearn:OnUseItem_LYF()
          end
          self:CloseEquipDetail()
        elseif itemTypeId == ITEM_DEF_OTHER_JFS then
          self.m_PetlistObj:OnBtn_SkillLearn()
          local skillLearn = self.m_PetlistObj:getPageSkillLearn()
          if skillLearn then
            skillLearn:OnUseItem_JFS()
          end
          self:CloseEquipDetail()
        else
          local subType = GetItemSubTypeByItemTypeId(itemTypeId)
          if subType == ITEM_DEF_TYPE_SKILLBOOK then
            do
              local petName = self.m_PetIns:getProperty(PROPERTY_NAME)
              local zs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
              local color = NameColor_Pet[zs] or ccc3(255, 255, 255)
              local itemSkill = data_getItemValueCoeff(itemTypeId)
              local skillName = data_getSkillName(itemSkill)
              local bookType = GetPetSkillBookTypeByItemTypeId(itemTypeId)
              local tip = string.format("是否确定#<r:%d,g:%d,b:%d>%s#学习#<CI:%d>%s#技能?", color.r, color.g, color.b, petName, itemTypeId, skillName)
              if bookType == ITEM_DEF_SKILLBOOK_NORMAL then
                local properSkillPos
                local skills = self.m_PetIns:getProperty(PROPERTY_PETSKILLS)
                if type(skills) ~= "table" then
                  skills = {}
                end
                for index, d in pairs(skills) do
                  if d == PETSKILL_NONESKILL then
                    properSkillPos = index
                    break
                  end
                end
                if properSkillPos == nil then
                  tip = string.format("是否确定#<r:%d,g:%d,b:%d>%s#学习#<CI:%d>%s#技能？(召唤兽没有多余技能栏,如果继续学习,可能会替换掉一个普通技能)", color.r, color.g, color.b, petName, itemTypeId, skillName)
                end
              elseif bookType == ITEM_DEF_SKILLBOOK_SENIOR then
                local seniorSkillNum = 0
                local skills = self.m_PetIns:getProperty(PROPERTY_PETSKILLS)
                if type(skills) ~= "table" then
                  skills = {}
                end
                for _, d in pairs(skills) do
                  if d > 0 and data_SeniorPetSkill[d] ~= nil then
                    seniorSkillNum = seniorSkillNum + 1
                  end
                end
                local petTypeId = self.m_PetIns:getTypeId()
                local petLevel = data_getPetLevelType(petTypeId)
                if seniorSkillNum >= 2 or (data_getPetTypeIsNormalShou(petTypeId) or data_getPetTypeIsGaoJiShouHu(petTypeId)) and seniorSkillNum >= 1 then
                  tip = string.format("是否确定#<r:%d,g:%d,b:%d>%s#学习#<CI:%d>%s#技能？(召唤兽已拥有了高级技能,如果继续学习,可能会替换掉一个原有技能)", color.r, color.g, color.b, petName, itemTypeId, skillName)
                end
              elseif bookType == ITEM_DEF_SKILLBOOK_SUPREME then
                local properSkillPos
                local skills = self.m_PetIns:getProperty(PROPERTY_PETSKILLS)
                if type(skills) ~= "table" then
                  skills = {}
                end
                for index, d in pairs(skills) do
                  if d == PETSKILL_NONESKILL then
                    properSkillPos = index
                    break
                  end
                end
                if properSkillPos == nil then
                  tip = string.format("是否确定#<r:%d,g:%d,b:%d>%s#学习#<CI:%d>%s#技能?（如果继续学习,可能会替换一个原有技能）", color.r, color.g, color.b, petName, itemTypeId, skillName)
                end
              end
              local confirmBoxDlg = CPopWarning.new({
                title = "提示",
                text = tip,
                confirmFunc = function()
                  self:OnLearnSkill(itemSkill, bookType, itemId, itemTypeId, petName, color)
                end,
                confirmText = "确定",
                cancelText = "取消",
                align = CRichText_AlignType_Left,
                emptyLineH = 15
              })
              local tipBox = confirmBoxDlg:getTextBox()
              local lineNum = tipBox:getLineNum()
              for i = 1, 7 - lineNum do
                tipBox:newLine()
              end
              tipBox:addRichText("#<IRP,F:17,r:93,g:183,b:179> 普通召唤兽通过技能书最多学习1个高级技能,灵兽和神兽最多2个。(战斗中随机领悟的技能不受此限制)#")
            end
          end
        end
      elseif itemType == ITEM_LARGE_TYPE_DRUG then
        if JudgeIsInWar() then
          ShowNotifyTips("自动战斗不能使用药品。")
          self:CloseEquipDetail()
          return
        end
        local drugData = data_Drug[itemTypeId]
        local addHPValue = drugData.drugAddHPValue
        local addMPValue = drugData.drugAddMPValue
        if addHPValue == 0 then
          addHPValue = math.floor(self.m_PetIns:getMaxProperty(PROPERTY_HP) * drugData.drugAddHPPercent / 100)
        end
        if addMPValue == 0 then
          addMPValue = math.floor(self.m_PetIns:getMaxProperty(PROPERTY_MP) * drugData.drugAddMPPercent / 100)
        end
        local needAddHP = math.max(self.m_PetIns:getMaxProperty(PROPERTY_HP) - self.m_PetIns:getProperty(PROPERTY_HP), 0)
        local needAddMp = math.max(self.m_PetIns:getMaxProperty(PROPERTY_MP) - self.m_PetIns:getProperty(PROPERTY_MP), 0)
        if addHPValue > 0 and addMPValue > 0 then
          if needAddHP <= 0 and needAddMp <= 0 then
            ShowNotifyTips("血气值已满")
            self:CloseEquipDetail()
            return
          end
        elseif addHPValue > 0 then
          if needAddHP <= 0 then
            ShowNotifyTips("血气值已满")
            self:CloseEquipDetail()
            return
          end
        elseif needAddMp <= 0 then
          ShowNotifyTips("法力值已满")
          self:CloseEquipDetail()
          return
        end
        netsend.netitem.requestUseDrugOutOfWar(self.m_PetId, itemId, math.min(addHPValue, needAddHP), math.min(addMPValue, needAddMp))
        return
      elseif itemType == ITEM_LARGE_TYPE_LIFEITEM then
        if JudgeIsInWar() then
          ShowNotifyTips("自动战斗不能使用药品。")
          self:CloseEquipDetail()
          return
        end
        if data_getLifeSkillType(itemTypeId) == IETM_DEF_LIFESKILL_DRUG then
          local drugData = data_LifeSkill_Drug[itemTypeId]
          local addHPValue = drugData.AddHp
          local addMPValue = drugData.AddMp
          local needAddHP = math.max(self.m_PetIns:getMaxProperty(PROPERTY_HP) - self.m_PetIns:getProperty(PROPERTY_HP), 0)
          local needAddMp = math.max(self.m_PetIns:getMaxProperty(PROPERTY_MP) - self.m_PetIns:getProperty(PROPERTY_MP), 0)
          if addHPValue > 0 and addMPValue > 0 then
            if needAddHP <= 0 and needAddMp <= 0 then
              ShowNotifyTips("血气值已满")
              self:CloseEquipDetail()
              return
            end
          elseif addHPValue > 0 then
            if needAddHP <= 0 then
              ShowNotifyTips("血气值已满")
              self:CloseEquipDetail()
              return
            end
          elseif needAddMp <= 0 then
            ShowNotifyTips("法力值已满")
            self:CloseEquipDetail()
            return
          end
          netsend.netitem.requestUseDrugOutOfWar(self.m_PetId, itemId, math.min(addHPValue, needAddHP), math.min(addMPValue, needAddMp))
          return
        end
      end
    end
  else
    self:CloseEquipDetail()
    return
  end
end
function CPetList_PageItemList:OnLearnSkill(itemSkill, bookType, itemId, itemTypeId, petName, color)
  local skills = self.m_PetIns:getProperty(PROPERTY_PETSKILLS)
  if type(skills) ~= "table" then
    skills = {}
  end
  local xlSkills = self.m_PetIns:getProperty(PROPERTY_ZJSKILLSEXP)
  if type(xlSkills) ~= "table" then
    xlSkills = {}
  end
  local categoryId = data_getSkillCategoryId(itemSkill)
  local fgSkill
  local fgIndex = -1
  for index, d in pairs(skills) do
    if d > 0 then
      if d == itemSkill then
        ShowNotifyTips(string.format("你的#<r:%d,g:%d,b:%d>%s#已有相同的技能", color.r, color.g, color.b, petName))
        return
      end
      if data_getSkillCategoryId(d) == categoryId and categoryId > 0 and xlSkills[d] == nil then
        fgSkill = d
        fgIndex = index
      end
    end
  end
  local gg, lx, mj, ll = data_getGGLXMJLL(itemSkill)
  if gg > 0 then
    local ugg = self.m_PetIns:getProperty(PROPERTY_GenGu)
    if gg > ugg then
      ShowNotifyTips(string.format("你的#<r:%d,g:%d,b:%d>%s#的根骨属性小于%d，无法学习", color.r, color.g, color.b, petName, gg))
      return
    end
  end
  if lx > 0 then
    local ulx = self.m_PetIns:getProperty(PROPERTY_Lingxing)
    if lx > ulx then
      ShowNotifyTips(string.format("你的#<r:%d,g:%d,b:%d>%s#的灵性属性小于%d，无法学习", color.r, color.g, color.b, petName, lx))
      return
    end
  end
  if mj > 0 then
    local umj = self.m_PetIns:getProperty(PROPERTY_MinJie)
    if mj > umj then
      ShowNotifyTips(string.format("你的#<r:%d,g:%d,b:%d>%s#的敏捷属性小于%d，无法学习", color.r, color.g, color.b, petName, mj))
      return
    end
  end
  if ll > 0 then
    local ull = self.m_PetIns:getProperty(PROPERTY_LiLiang)
    if ll > ull then
      ShowNotifyTips(string.format("你的#<r:%d,g:%d,b:%d>%s#的力量属性小于%d，无法学习", color.r, color.g, color.b, petName, ll))
      return
    end
  end
  local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(itemSkill)
  if jin > 0 then
    local ujin = self.m_PetIns:getProperty(PROPERTY_WXJIN)
    if jin > ujin then
      ShowNotifyTips(string.format("你的#<r:%d,g:%d,b:%d>%s#的五行金小于%d，无法学习", color.r, color.g, color.b, petName, jin * 100))
      return
    end
  end
  if mu > 0 then
    local umu = self.m_PetIns:getProperty(PROPERTY_WXMU)
    if mu > umu then
      ShowNotifyTips(string.format("你的#<r:%d,g:%d,b:%d>%s#的五行木小于%d，无法学习", color.r, color.g, color.b, petName, mu * 100))
      return
    end
  end
  if shui > 0 then
    local ushui = self.m_PetIns:getProperty(PROPERTY_WXSHUI)
    if shui > ushui then
      ShowNotifyTips(string.format("你的#<r:%d,g:%d,b:%d>%s#的五行水小于%d，无法学习", color.r, color.g, color.b, petName, shui * 100))
      return
    end
  end
  if huo > 0 then
    local uhuo = self.m_PetIns:getProperty(PROPERTY_WXHUO)
    if huo > uhuo then
      ShowNotifyTips(string.format("你的#<r:%d,g:%d,b:%d>%s#的五行火小于%d，无法学习", color.r, color.g, color.b, petName, huo * 100))
      return
    end
  end
  if tu > 0 then
    local utu = self.m_PetIns:getProperty(PROPERTY_WXTU)
    if tu > utu then
      ShowNotifyTips(string.format("你的#<r:%d,g:%d,b:%d>%s#的五行土小于%d，无法学习", color.r, color.g, color.b, petName, tu * 100))
      return
    end
  end
  if fgSkill ~= nil then
    local skillName = data_getSkillName(itemSkill)
    local fgskillName = data_getSkillName(fgSkill)
    local tip = string.format("你此时学习的#<R>%s#技能将会与#<R>%s#等技能产生覆盖效果，你确定要学习吗？", skillName, fgskillName)
    CPopWarning.new({
      title = "提示",
      text = tip,
      confirmFunc = function()
        ShowWarningInWar()
        netsend.netitem.requestUseItem(itemId, self.m_PetId)
      end,
      confirmText = "确定",
      cancelText = "取消",
      align = CRichText_AlignType_Left
    })
  else
    ShowWarningInWar()
    netsend.netitem.requestUseItem(itemId, self.m_PetId)
  end
end
function CPetList_PageItemList:OnSellItem(itemId)
  SellItemPopView(itemId, handler(self, self.OnConfirmSell))
  self:CloseEquipDetail()
end
function CPetList_PageItemList:OnConfirmSell(itemId, itemNum)
  netsend.netitem.requestSellItem(itemId, itemNum)
  self:CloseEquipDetail()
end
function CPetList_PageItemList:OnEquipDetailClosed(obj)
  if self.m_EquipDetail ~= nil and self.m_EquipDetail == obj then
    self.m_EquipDetail = nil
    if self.m_PackageFrame then
      self.m_PackageFrame:ClearSelectItem()
    end
  end
end
function CPetList_PageItemList:CloseEquipDetail()
  if self.m_EquipDetail then
    self.m_EquipDetail:CloseSelf()
  end
end
function CPetList_PageItemList:OnPageChanged(pageIndex, maxIndex)
end
function CPetList_PageItemList:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemInfo_TakeEquip then
    local itemId = arg[2]
    if self.m_EquipDetail ~= nil and self.m_EquipDetail:getItemObjId() == itemId then
      self:CloseEquipDetail()
    end
  elseif msgSID == MsgID_ItemInfo_TakeDownEquip then
    local itemId = arg[2]
    if self.m_EquipDetail ~= nil and self.m_EquipDetail:getItemObjId() == itemId then
      self:CloseEquipDetail()
    end
  elseif msgSID == MsgID_ItemInfo_ItemUpdate then
    if self.m_EquipDetail then
      local param = arg[1]
      if param.itemId == self.m_EquipDetail:getItemObjId() then
        local proTable = param.pro
        if proTable[ITEM_PRO_NEIDAN_ZS] ~= nil or proTable[ITEM_PRO_LV] ~= nil then
          local itemIns = g_LocalPlayer:GetOneItem(param.itemId)
          if itemIns then
            local level = itemIns:getProperty(ITEM_PRO_LV)
            local zs = itemIns:getProperty(ITEM_PRO_NEIDAN_ZS)
            local lvMax = CalculateNeidanLevelLimit(zs)
            local rightBtnParam
            if zs < CalculateNeidanZSLimit() then
              if level >= lvMax then
                rightBtnParam = {
                  btnText = "魂石转生",
                  listener = handler(self, self.OnZhuanShengNeiDan)
                }
              else
                rightBtnParam = {
                  btnText = "一键升级",
                  listener = handler(self, self.OnOneKeyLevelUpNeiDan)
                }
              end
            elseif zs == CalculateNeidanZSLimit() and level < lvMax then
              rightBtnParam = {
                btnText = "一键升级",
                listener = handler(self, self.OnOneKeyLevelUpNeiDan)
              }
            end
            self.m_EquipDetail:UpdateRightButton(rightBtnParam)
          end
        end
      end
    end
  elseif msgSID == MsgID_ItemInfo_DelItem then
    local itemId = arg[1]
    if self.m_EquipDetail ~= nil and self.m_EquipDetail:getItemObjId() == itemId then
      self:CloseEquipDetail()
    end
  end
end
function CPetList_PageItemList:Clear()
  self.m_PetlistObj = nil
end
