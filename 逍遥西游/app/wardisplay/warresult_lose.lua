g_WarLoseResultIns = nil
local warresult_lose = class("warresult_lose", CcsSubView)
function warresult_lose:ctor(warType, warTypeData)
  warresult_lose.super.ctor(self, "views/warresult_lose.json", {isAutoCenter = true, opacityBg = 100})
  self.m_WarType = warType
  self.m_WarTypeData = warTypeData
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Continue),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetTishengBtns(GetWarTishengList())
  soundManager.playSound("xiyou/sound/war_lose_fb.wav")
  self:ListenMessage(MsgID_MapScene)
  if g_WarLoseResultIns ~= nil then
    g_WarLoseResultIns:CloseSelf()
    g_WarLoseResultIns = nil
  end
  g_WarLoseResultIns = self
end
function warresult_lose:Btn_Continue(obj, t)
  self:CloseSelf()
end
function warresult_lose:CloseSelf()
  print("--->>Btn_Continue_lose")
  warresult_lose.super.CloseSelf(self)
end
function warresult_lose:SetTishengBtns(tishengList)
  self:getNode("list"):removeAllItems()
  for _, tishengType in ipairs(tishengList) do
    local item = CTiShengItem.new(tishengType, "views/tishengboardinwar_item.json", function()
    end)
    self:getNode("list"):pushBackCustomItem(item:getUINode())
  end
end
function warresult_lose:UpdateTishengBoard()
  self:SetTishengBtns(GetWarTishengList())
end
function warresult_lose:OnMessage(msgSID, ...)
  if msgSID == MsgID_MapScene_AutoRoute and g_LocalPlayer:getNormalTeamer() ~= true then
    self:Btn_Continue()
  end
end
function warresult_lose:onEnterEvent()
  SendMessage(MsgID_Scene_WarResult_Enter)
end
function warresult_lose:Clear()
  if g_WarScene then
    g_WarScene:ClearWarResult(self)
  end
  if g_WarLoseResultIns == self then
    g_WarLoseResultIns = nil
  end
  SendMessage(MsgID_Scene_WarResult_Exit)
end
function ShowWarResult_Lose(warID, warType, warTypeData)
  QuitWarSceneAndBackToPreScene()
  if warType == WARTYPE_BpWAR then
  elseif warType == WARTYPE_LEITAI then
    ShowLeiWangZhengBaDlg()
  else
    local dlg = warresult_lose.new(warType, warTypeData)
    return getCurSceneView():addSubView({
      subView = dlg,
      zOrder = MainUISceneZOrder.warResultView
    })
  end
end
