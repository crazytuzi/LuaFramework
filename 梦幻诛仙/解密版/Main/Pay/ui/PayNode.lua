local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TabNode = require("GUI.TabNode")
local PayNode = Lplus.Extend(TabNode, "PayNode")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local ItemModule = require("Main.Item.ItemModule")
local GUIUtils = require("GUI.GUIUtils")
local PayModule = Lplus.ForwardDeclare("PayModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = PayNode.define
local instance
def.static("=>", PayNode).Instance = function()
  if instance == nil then
    instance = PayNode()
  end
  return instance
end
def.field("number").ver = 0
def.field("table").saveAmfInfo = nil
def.field("table").awardItemsId = nil
def.field("table").getaward = nil
def.field("boolean").hasSaveAmtAward = false
def.field("number").num = 0
def.field("table").fillInfo = nil
def.field("number").importantOne = -1
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  self.ver = 0
  self.m_node = nil
  TabNode.Init(self, base, node)
  local groupReturn = self.m_node:FindDirect("Content_RechargeReturn")
  local groupPay = self.m_node:FindDirect("ScrollView_Buy")
  groupPay:SetActive(true)
  groupReturn:SetActive(false)
  if not PayModule.PAYON then
    self.m_panel:FindDirect("Img_Bg0/Tap_Recharge"):SetActive(false)
  end
end
def.override().OnShow = function(self)
  _G.SafeCall(function()
    self:ShowPayTip()
  end)
  self:UpdateTitle()
  self:UpdateInfo()
  local returnBtn = self.m_node:FindDirect("Group_Tab/Img_Tab/Group_RechargeTab")
  returnBtn:GetComponent("UIToggle"):set_value(true)
  GUIUtils.SetActive(self.m_node:FindDirect("Btn_Help"), not ClientCfg.IsOtherChannel() and _G.LoginPlatform ~= MSDK_LOGIN_PLATFORM.GUEST)
  self:UpdateFreeFlowBtn()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, PayNode.OnMoneyChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, PayNode.OnMoneyChanged)
  self:fillRechageReturnList()
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, PayNode.OnMoneyChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, PayNode.OnMoneyChanged)
end
def.method().ShowPayTip = function(self)
  local badVersion = 105
  local ECMSDK = require("ProxySDK.ECMSDK")
  if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    local value, name, content = GameUtil.GetProgramCurrentVersionInfo()
    local valueNumber = tonumber(value)
    if valueNumber and valueNumber == 105 and IsAndroidSix() then
      local PAYTIP = "PAYTIP"
      local toastTimes = 3
      local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
      local times = 1
      times = LuaPlayerPrefs.HasGlobalKey(PAYTIP) and (LuaPlayerPrefs.GetGlobalInt(PAYTIP) or 1)
      if toastTimes < times then
      else
        require("GUI.CommonConfirmDlg").ShowCerternConfirm(textRes.Pay[6], textRes.Pay[7], textRes.Pay[8], nil, nil)
        times = times + 1
        LuaPlayerPrefs.SetGlobalInt(PAYTIP, times)
        LuaPlayerPrefs.Save()
      end
    end
  end
end
def.static("table", "table").OnMoneyChanged = function(p1, p2)
  if PayNode.Instance().isShow and PayNode.Instance().m_node and not PayNode.Instance().m_node.isnil then
    PayNode.Instance():UpdateTitle()
    PayNode.Instance():setSaveAmtInfo(PayNode.Instance().saveAmfInfo)
  end
end
def.method().UpdateTitle = function(self)
  local yuanbaoNum = ItemModule.Instance():GetAllYuanBao()
  local yuanbaoStr = yuanbaoNum ~= nil and yuanbaoNum:tostring() or 0
  local yuanbaoLabel = self.m_node:FindDirect("Group_Top/Group_Money/Img_BgHaveMoney/Label_HaveMoneyNum"):GetComponent("UILabel")
  yuanbaoLabel:set_text(yuanbaoStr)
end
def.method().UpdateInfo = function(self)
  local ver, payData = PayModule.GetPayData()
  self.ver = ver
  if payData == nil then
    PayModule.PullPayData()
    payData = {}
  end
  local num = #payData
  local list = self.m_node:FindDirect("ScrollView_Buy/List_Item")
  local uilist = list:GetComponent("UIList")
  uilist.itemCount = num
  uilist:Resize()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if uilist.isnil then
      return
    end
    uilist:Reposition()
  end)
  for i = 1, num do
    local item = list:FindDirect(string.format("Group_Pay_%d", i))
    local info = payData[i]
    local moneyTex = item:FindDirect(string.format("Img_BgItem_%d/Texture_Money_%d", i, i)):GetComponent("UITexture")
    local activity = item:FindDirect(string.format("Img_BgItem_%d/Texture_State_%d", i, i))
    local activityTex = activity:GetComponent("UITexture")
    local yuanbaoLabel = item:FindDirect(string.format("Img_BgItem_%d/Group_Num_%d/Img_BgNum_%d/Label_Num_%d", i, i, i, i)):GetComponent("UILabel")
    local rmbLabel = item:FindDirect(string.format("Img_BgItem_%d/Group_Price_%d/Label_Pricesign_%d", i, i, i)):GetComponent("UILabel")
    GUIUtils.FillIcon(moneyTex, info.cfg.icon)
    if info.sendnum > 0 then
      if info.isfirst then
        warn("Set First:", info.cfg.activityIcon)
        GUIUtils.FillIcon(activityTex, info.cfg.activityIcon)
      else
        warn("Set Not First:", info.cfg.commonIcon)
        GUIUtils.FillIcon(activityTex, info.cfg.commonIcon)
      end
    else
      activity:SetActive(false)
    end
    yuanbaoLabel:set_text(info.cfg.yuanbao)
    rmbLabel:set_text(string.format(textRes.Mall[6], info.cfg.rmb / 100))
    self.m_base.m_msgHandler:Touch(item)
  end
end
def.method().UpdateFreeFlowBtn = function(self)
  local FreeFlowMgr = require("Main.FreeFlow.FreeFlowMgr")
  local canShow = FreeFlowMgr.Instance():IsFeatureOpen() and FreeFlowMgr.Instance():IsOpen()
  print("UpdateFreeFlowBtn canShow = " .. tostring(canShow))
  GUIUtils.SetActive(self.m_node:FindDirect("Btn_DataBag"), canShow)
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if string.sub(id, 1, 10) == "Group_Pay_" then
    if IsCrossingServer() then
      ToastCrossingServerForbiden()
      return
    end
    local index = tonumber(string.sub(id, 11))
    warn("Pay Btn Click", id, index, self.ver)
    if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_RECHARGE) then
      Toast(textRes.Pay[3])
      return
    end
    local ver, payData = PayModule.GetPayData()
    if ver == self.ver then
      local info = payData[index]
      PayModule.Pay(info.cfg)
      PayModule.Instance():UpdatePayTLogData({
        amount = info.cfg.yuanbao
      })
    else
      warn("Bad Data Ver")
    end
  elseif id == "Group_RechargeTab" then
    if IsCrossingServer() then
      ToastCrossingServerForbiden()
      return
    end
    self:UpdateTitle()
    self:UpdateInfo()
    self:fillRechageReturnList()
  elseif id == "Group_RechargeReturn" then
    self:setSaveAmtInfo(self.saveAmfInfo)
    local checkBtn = self.m_node:FindDirect("Group_Tab/Img_Tab/Group_RechargeReturn")
    local returnBtn = self.m_node:FindDirect("Group_Tab/Img_Tab/Group_RechargeTab")
    checkBtn:GetComponent("UIWidget"):set_alpha(0)
    returnBtn:GetComponent("UIWidget"):set_alpha(1)
  elseif id == "Btn_OutGet" then
    if IsCrossingServer() then
      ToastCrossingServerForbiden()
      return
    end
    self:getRechargeAward(self.importantOne)
  elseif string.sub(id, 1, 8) == "Btn_Get_" then
    if IsCrossingServer() then
      ToastCrossingServerForbiden()
      return
    end
    local index = tonumber(string.sub(id, 9))
    self:getRechargeAward(index)
  elseif string.sub(id, 1, 11) == "Img_OutItem" then
    local index = tonumber(string.sub(id, 12))
    self:showAwardItemTip(index, id)
  elseif string.sub(id, 1, 8) == "Img_Item" then
    local index = tonumber(string.sub(id, 11))
    self:showAwardItemTip(index, id)
  elseif id == "Btn_Help" then
    local url = "https://kf.qq.com/touch/scene_faq.html?scene_id=kf2246"
    if platform == 1 then
      url = "https://kf.qq.com/touch/scene_faq.html?scene_id=kf2282"
    end
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.OpenURL(url)
  elseif id == "Btn_DataBag" then
    local FreeFlowMgr = require("Main.FreeFlow.FreeFlowMgr")
    FreeFlowMgr.Instance():OpenSpecialTrafficURL()
  end
end
def.method("=>", "number").getVer = function(self)
  return self.ver
end
def.method("table").setSaveAmtInfo = function(self, info)
  if info == nil then
    return
  end
  self.saveAmfInfo = info
  self.hasSaveAmtAward = false
  local totalRecharge = ItemModule.Instance():GetYuanbao(ItemModule.CASH_SAVE_AMT)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SAVE_AMT_CFG)
  if entries == nil then
    return
  end
  self.num = 0
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  local i = 1
  self.fillInfo = {}
  local fillInfo = self.fillInfo
  for k, v in pairs(self.saveAmfInfo.activity_infos) do
    if k == constant.CQingfuCfgConsts.SAVE_AMT_ACTIVITY_CFG_ID then
      local itemsCount = 1
      local fi = {}
      fi.base_save_amt = v.base_save_amt
      fi.sortid = v.sortid
      fi.items = {}
      fillInfo[k] = fi
      local realSaveAmount = (totalRecharge - v.base_save_amt):ToNumber()
      for j = 1, recordCount do
        local record = DynamicDataTable.FastGetRecordByIdx(entries, j - 1)
        if record:GetIntValue("activity_cfg_id") == k then
          local see_amount = record:GetIntValue("display_save_amt_cond")
          if realSaveAmount >= see_amount then
            local r = {}
            r.award_id = record:GetIntValue("award_cfg_id")
            r.name = record:GetStringValue("name")
            r.desc = record:GetStringValue("desc")
            r.saveAmt = record:GetIntValue("save_amt_cond")
            r.sortid = record:GetIntValue("sort_id")
            fillInfo[k].items[itemsCount] = r
            self.num = self.num + 1
            itemsCount = itemsCount + 1
            if realSaveAmount >= r.saveAmt and v.sortid < r.sortid then
              self.hasSaveAmtAward = true
            end
          end
        end
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  Event.DispatchEvent(ModuleId.PAY, gmodule.notifyId.Pay.RECHARTE_RETURN_STATUS, nil)
  if self.isShow then
    self:fillRechageReturnList()
  end
end
def.method("=>", "boolean").canGetSaveAmtAward = function(self)
  if self.saveAmfInfo == nil then
    return false
  end
  return self.hasSaveAmtAward
end
def.method("table").updateSaveAmtInfo = function(self, info)
  if self.saveAmfInfo == nil or info.activity_id ~= constant.CQingfuCfgConsts.SAVE_AMT_ACTIVITY_CFG_ID then
    return
  end
  local totalRecharge = tonumber(ItemModule.Instance():GetYuanbao(ItemModule.CASH_SAVE_AMT):tostring())
  for k, v in pairs(self.saveAmfInfo.activity_infos) do
    if k == info.activity_id then
      v.sortid = info.sort_id
      self:setSaveAmtInfo(self.saveAmfInfo)
      break
    end
  end
end
def.method().fillRechageReturnList = function(self)
  warn("fillRechageReturnList")
  warn(self.isShow, self.saveAmfInfo, self.m_node, self.fillInfo)
  if self.isShow == false or self.saveAmfInfo == nil or self.m_node == nil or self.fillInfo == nil then
    return
  end
  self.awardItemsId = {}
  self.getaward = {}
  local totalRecharge = ItemModule.Instance():GetYuanbao(ItemModule.CASH_SAVE_AMT):ToNumber()
  local fillInfo = self.fillInfo
  local num = self.num
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local list = self.m_node:FindDirect("Content_RechargeReturn/Scroll_View/List_Return")
  local uilist = list:GetComponent("UIList")
  uilist.itemCount = num
  uilist:Resize()
  local i = 1
  local fillInfoForActivity = fillInfo[constant.CQingfuCfgConsts.SAVE_AMT_ACTIVITY_CFG_ID]
  if fillInfoForActivity then
    self.importantOne = #fillInfoForActivity.items
    for ki, vi in pairs(fillInfoForActivity.items) do
      local item = list:FindDirect(string.format("Img_ListBg_%d", i))
      local saveAmt = totalRecharge - fillInfoForActivity.base_save_amt
      item:FindDirect("Img_Get_" .. i):SetActive(false)
      if false == saveAmt:lt(vi.saveAmt) then
        if fillInfoForActivity.sortid >= vi.sortid then
          item:FindDirect("Img_Get_" .. i):SetActive(true)
          item:FindDirect("Btn_Get_" .. i):SetActive(false)
        else
          item:FindDirect("Btn_Get_" .. i):SetActive(true)
          self.hasSaveAmtAward = true
          if ki < self.importantOne then
            self.importantOne = ki
          end
        end
        item:FindDirect("Btn_Get_" .. i):GetComponent("UIButton"):set_isEnabled(true)
      else
        item:FindDirect("Btn_Get_" .. i):GetComponent("UIButton"):set_isEnabled(false)
        if ki < self.importantOne then
          self.importantOne = ki
        end
      end
      local awardInBtn = {}
      awardInBtn.activity_id = constant.CQingfuCfgConsts.SAVE_AMT_ACTIVITY_CFG_ID
      awardInBtn.sortid = vi.sortid
      local need_amt = item:FindDirect("Label_Num_" .. i)
      local silder = item:FindDirect("Img_BgSlider_" .. i)
      if false == saveAmt:lt(vi.saveAmt) then
        need_amt:GetComponent("UILabel"):set_text(string.format(textRes.Pay[5], vi.saveAmt))
        silder:GetComponent("UISlider"):set_sliderValue(1)
      else
        need_amt:GetComponent("UILabel"):set_text(string.format(textRes.Pay[4], vi.saveAmt - saveAmt:ToNumber()))
        silder:GetComponent("UISlider"):set_sliderValue(saveAmt:ToNumber() / vi.saveAmt)
      end
      local silderLabel = item:FindDirect(string.format("Img_BgSlider_%d/Label_%d", i, i))
      if saveAmt:gt(vi.saveAmt) == true then
        silderLabel:GetComponent("UILabel"):set_text(string.format("%d/%d", vi.saveAmt, vi.saveAmt))
      else
        silderLabel:GetComponent("UILabel"):set_text(string.format("%s/%d", saveAmt:tostring(), vi.saveAmt))
      end
      local key = string.format("%d_%d_%d", vi.award_id, occupation.ALL, gender.ALL)
      local awardcfg = ItemUtils.GetGiftAwardCfg(key)
      item:FindDirect("Img_Item1_" .. i):SetActive(false)
      item:FindDirect("Img_Item2_" .. i):SetActive(false)
      item:FindDirect("Img_Item3_" .. i):SetActive(false)
      local idx = 1
      for k, v in ipairs(awardcfg.itemList) do
        item:FindDirect(string.format("Img_Item%d_%d", idx, i)):SetActive(true)
        local itemBase = ItemUtils.GetItemBase(v.itemId)
        local title = item:FindDirect(string.format("Img_Item%d_%d/Label_%d", idx, i, i)):GetComponent("UILabel")
        title:set_text(string.format("%d", v.num))
        local uiTexture = item:FindDirect(string.format("Img_Item%d_%d/Texture_%d", idx, i, i)):GetComponent("UITexture")
        GUIUtils.FillIcon(uiTexture, itemBase.icon)
        local sprite = item:FindDirect(string.format("Img_Item%d_%d", idx, i)):GetComponent("UISprite")
        sprite:set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
        self.awardItemsId[string.format("Img_Item%d_%d", idx, i)] = v.itemId
        idx = idx + 1
      end
      awardInBtn.itemcount = idx
      self.getaward[i] = awardInBtn
      i = i + 1
    end
    local outItem = self.m_node:FindDirect("Img_ListBg")
    local data = fillInfoForActivity.items[self.importantOne]
    local saveAmt = totalRecharge - fillInfoForActivity.base_save_amt
    local getBtn = outItem:FindDirect("Btn_OutGet")
    local checkBtn = self.m_node:FindDirect("Group_Tab/Img_Tab/Group_RechargeReturn")
    local returnBtn = self.m_node:FindDirect("Group_Tab/Img_Tab/Group_RechargeTab")
    if false == saveAmt:lt(data.saveAmt) then
      if fillInfoForActivity.sortid >= data.sortid then
        getBtn:SetActive(false)
        checkBtn:GetComponent("UIWidget"):set_alpha(1)
        returnBtn:GetComponent("UIWidget"):set_alpha(0)
      else
        getBtn:SetActive(true)
        checkBtn:GetComponent("UIWidget"):set_alpha(0)
        warn("list:get_activeInHierarchy()", list:get_activeInHierarchy())
        if list:get_activeInHierarchy() then
          returnBtn:GetComponent("UIWidget"):set_alpha(1)
        else
          returnBtn:GetComponent("UIWidget"):set_alpha(0)
        end
      end
    else
      getBtn:SetActive(false)
      checkBtn:GetComponent("UIWidget"):set_alpha(1)
      returnBtn:GetComponent("UIWidget"):set_alpha(0)
    end
    local need_amt = outItem:FindDirect("Label_Num")
    local silder = outItem:FindDirect("Img_BgSlider")
    if false == saveAmt:lt(data.saveAmt) then
      need_amt:GetComponent("UILabel"):set_text(string.format(textRes.Pay[5], data.saveAmt))
      silder:GetComponent("UISlider"):set_sliderValue(1)
    else
      need_amt:GetComponent("UILabel"):set_text(string.format(textRes.Pay[4], data.saveAmt - saveAmt:ToNumber()))
      silder:GetComponent("UISlider"):set_sliderValue(saveAmt:ToNumber() / data.saveAmt)
    end
    local silderLabel = outItem:FindDirect("Img_BgSlider/Label")
    if saveAmt:gt(data.saveAmt) == true then
      silderLabel:GetComponent("UILabel"):set_text(string.format("%d/%d", data.saveAmt, data.saveAmt))
    else
      silderLabel:GetComponent("UILabel"):set_text(string.format("%s/%d", saveAmt:tostring(), data.saveAmt))
    end
    local key = string.format("%d_%d_%d", data.award_id, occupation.ALL, gender.ALL)
    local awardcfg = ItemUtils.GetGiftAwardCfg(key)
    outItem:FindDirect("Img_OutItem1"):SetActive(false)
    outItem:FindDirect("Img_OutItem2"):SetActive(false)
    outItem:FindDirect("Img_OutItem3"):SetActive(false)
    for k, v in ipairs(awardcfg.itemList) do
      local aitem = outItem:FindDirect(string.format("Img_OutItem%d", k))
      aitem:SetActive(true)
      local itemBase = ItemUtils.GetItemBase(v.itemId)
      local title = aitem:FindDirect("Label"):GetComponent("UILabel")
      title:set_text(string.format("%d", v.num))
      local uiTexture = aitem:FindDirect("Texture"):GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, itemBase.icon)
      local sprite = aitem:GetComponent("UISprite")
      sprite:set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
    end
  end
  self.m_base.m_msgHandler:Touch(list)
end
def.method("number").getRechargeAward = function(self, idx)
  if self.saveAmfInfo == nil then
    return
  end
  local awardInBtn = self.getaward[idx]
  if awardInBtn == nil then
    return
  end
  for k, v in pairs(self.saveAmfInfo.activity_infos) do
    if k == awardInBtn.activity_id then
      if awardInBtn.sortid > 1 and awardInBtn.sortid - v.sortid > 1 then
        Toast(textRes.Pay[100])
        return
      end
      if awardInBtn.sortid <= v.sortid then
        return
      end
      if awardInBtn.itemcount > ItemModule.Instance():GetBagLeftSize() then
        Toast(textRes.Pay[104])
        return
      end
      local req = require("netio.protocol.mzm.gsp.qingfu.CGetSaveAmtActivityAward").new(awardInBtn.activity_id, awardInBtn.sortid)
      gmodule.network.sendProtocol(req)
      local ECMSDK = require("ProxySDK.ECMSDK")
      ECMSDK.SendTLogToServer(_G.TLOGTYPE.RECHARGEAWARD, {
        awardInBtn.sortid
      })
    end
  end
end
def.method("number", "string").showAwardItemTip = function(self, idx, name)
  warn("showAwardItemTip")
  if string.sub(name, 1, 11) == "Img_OutItem" then
    local source = self.m_node:FindDirect(string.format("Img_ListBg/%s", name))
    if source ~= nil then
      local rename = string.format("Img_Item%d_%d", idx, self.importantOne)
      warn(rename)
      local itemid = self.awardItemsId[rename]
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemid, source, 0, false)
    end
  elseif string.sub(name, 1, 8) == "Img_Item" then
    local source = self.m_node:FindDirect(string.format("Content_RechargeReturn/Scroll_View/List_Return/Img_ListBg_%d/%s", idx, name))
    if source ~= nil then
      local itemid = self.awardItemsId[name]
      warn(name)
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemid, source, 0, false)
    end
  end
end
return PayNode.Commit()
