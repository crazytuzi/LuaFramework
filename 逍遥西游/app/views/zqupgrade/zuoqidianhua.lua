CZuoqiDianHuaHeadItem = class("CZuoqiDianHuaHeadItem", CZuoqiSkillHeadItem)
function CZuoqiDianHuaHeadItem:ctor(zqId, zqTypeId, clickHandler, size)
  CZuoqiDianHuaHeadItem.super.ctor(self, zqId, zqTypeId, clickHandler, size)
end
CZuoqiDianHua = class(".CZuoqiDianHua", CcsSubView)
function CZuoqiDianHua:ctor()
  CZuoqiDianHua.super.ctor(self, "views/zuoqi_dianhua.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_dh = {
      listener = handler(self, self.OnBtn_DianHua),
      variName = "btn_dh"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.txt_dh = self:getNode("txt_dh")
  self:LoadAllZuoqi()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CZuoqiDianHua:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ZuoqiUpdate then
    local param = arg[1]
    local myZuoqi = self.m_ZuoqiHeadList[self.m_CurChooseZuoQi]
    if myZuoqi:getId() == param.zuoqiId then
      local proTable = param.pro
      if proTable[PROPERTY_ZUOQI_DIANHUA] ~= nil then
        self:ReloadDianHuaState()
        self:CheckPopView()
      end
    end
  end
end
function CZuoqiDianHua:LoadAllZuoqi()
  self.m_ZuoqiHeadList = {}
  local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
  table.sort(myZuoqiList)
  local firstZq
  for index = 1, 6 do
    local zqpos = self:getNode(string.format("zqpos_%d", index))
    zqpos:setVisible(false)
    local zqId = myZuoqiList[index]
    if zqId ~= nil then
      local zqIns = g_LocalPlayer:getObjById(zqId)
      local parent = zqpos:getParent()
      local zOrder = zqpos:getZOrder()
      local x, y = zqpos:getPosition()
      local size = zqpos:getContentSize()
      local zqTypeId = zqIns:getTypeId()
      local zqItem = CZuoqiDianHuaHeadItem.new(zqId, zqTypeId, handler(self, self.SelectZuoqi), size)
      zqItem:setPosition(ccp(x + size.width / 2, y + size.height / 2))
      parent:addChild(zqItem)
      self.m_ZuoqiHeadList[zqId] = zqItem
      if firstZq == nil then
        firstZq = zqId
      end
    end
  end
  if firstZq ~= nil then
    self:SelectZuoqi(firstZq, false)
  end
end
function CZuoqiDianHua:ReloadDianHuaState()
  local zqHead = self.m_ZuoqiHeadList[self.m_CurChooseZuoQi]
  local zqId = zqHead:getId()
  local zqIns = g_LocalPlayer:getObjById(zqId)
  if zqIns then
    local isDh = zqIns:getProperty(PROPERTY_ZUOQI_DIANHUA)
    if isDh == 0 then
      self.btn_dh:setEnabled(true)
      self.txt_dh:setVisible(false)
    else
      self.btn_dh:setEnabled(false)
      self.txt_dh:setVisible(true)
    end
  else
    self.btn_dh:setEnabled(false)
    self.txt_dh:setVisible(false)
  end
end
function CZuoqiDianHua:SelectZuoqi(zqId, scaleAction)
  if self.m_CurChooseZuoQi == zqId then
    return
  end
  self.m_CurChooseZuoQi = zqId
  if scaleAction == nil then
    scaleAction = true
  end
  for zid, head in pairs(self.m_ZuoqiHeadList) do
    head:SetSelected(zid == zqId, scaleAction)
  end
  self:ReloadDianHuaState()
end
function CZuoqiDianHua:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CZuoqiDianHua:OnBtn_DianHua(btnObj, touchType)
  local zqHead = self.m_ZuoqiHeadList[self.m_CurChooseZuoQi]
  local zqId = zqHead:getId()
  local zqIns = g_LocalPlayer:getObjById(zqId)
  if zqIns then
    local isDh = zqIns:getProperty(PROPERTY_ZUOQI_DIANHUA)
    if isDh == 0 then
      if self:CheckCanDianHua() then
        local tempPop = CPopWarning.new({
          title = "提示",
          text = "你确定要点化该坐骑吗？\n\n(点化后等级和熟练度都会归零)",
          confirmFunc = function()
            self:ConfirmDianHua(zqId)
          end,
          confirmText = "确定",
          cancelText = "取消"
        })
        tempPop:ShowCloseBtn(false)
      end
    else
      ShowNotifyTips("该坐骑已点化")
      self:ReloadDianHuaState()
    end
  else
    print("点化坐骑排列异常？！")
  end
end
function CZuoqiDianHua:CheckCanDianHua()
  local zqHead = self.m_ZuoqiHeadList[self.m_CurChooseZuoQi]
  local zqId = zqHead:getId()
  local zqIns = g_LocalPlayer:getObjById(zqId)
  local isDh = zqIns:getProperty(PROPERTY_ZUOQI_DIANHUA)
  local lv = zqIns:getProperty(PROPERTY_ROLELEVEL)
  local lvlimit = CalculateZuoqiLevelLimit()
  if lv < lvlimit then
    ShowNotifyTips(string.format("坐骑等级不足%d", lvlimit))
    return false
  end
  local pValue = zqIns:getProperty(PROPERTY_ZUOQI_SKILLPVALUE)
  local pValueLimit = CalculateZuoqiSkillPValueLimit()
  if pValue < pValueLimit then
    ShowNotifyTips(string.format("坐骑技能熟练度不足%d", pValueLimit))
    return false
  end
  local ggbase = zqIns:getProperty(PROPERTY_ZUOQI_INIT_GenGu)
  local ggbaseMax = CalculateZuoqiBaseGGLimit(zqIns:getTypeId(), isDh)
  if ggbase < ggbaseMax then
    ShowNotifyTips(string.format("坐骑根骨初值不足%d", ggbaseMax))
    return false
  end
  return true
end
function CZuoqiDianHua:ConfirmDianHua(zqId)
  netsend.netbaseptc.requestDianHuaZuoqi(zqId)
end
function CZuoqiDianHua:CheckPopView()
  local zqHead = self.m_ZuoqiHeadList[self.m_CurChooseZuoQi]
  local zqId = zqHead:getId()
  local zqIns = g_LocalPlayer:getObjById(zqId)
  if zqIns then
    local isDh = zqIns:getProperty(PROPERTY_ZUOQI_DIANHUA)
    if isDh ~= 0 then
      local tempPop = CPopWarning.new({
        title = "提示",
        text = "坐骑成功点化了",
        confirmText = "知道了"
      })
      tempPop:OnlyShowConfirmBtn()
      tempPop:ShowCloseBtn(false)
    end
  end
end
function CZuoqiDianHua:Clear()
end
function ShowZuoqiDianHuaDlg(zqId)
  local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
  if #myZuoqiList <= 0 then
    ShowNotifyTips("等你有坐骑了再来找我吧")
  else
    local viewObj = CZuoqiDianHua.new()
    getCurSceneView():addSubView({
      subView = viewObj,
      zOrder = MainUISceneZOrder.popView
    })
    if zqId ~= nil then
      viewObj:SelectZuoqi(zqId)
    end
  end
end
