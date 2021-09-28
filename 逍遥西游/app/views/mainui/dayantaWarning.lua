DayantaWarning = class("DayantaWarning", CcsSubView)
function DayantaWarning:ctor()
  DayantaWarning.super.ctor(self, "views/dayantawarning.csb", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_continue = {
      listener = handler(self, self.OnBtn_Continue),
      variName = "btn_continue"
    },
    btn_exit = {
      listener = handler(self, self.OnBtn_Exit),
      variName = "btn_exit"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local curIdx
  local lastMissionId = activity.dayanta:getLastMissionId()
  if lastMissionId ~= nil then
    print("lastMissionId:", lastMissionId)
    curIdx = tonumber(string.sub(tostring(lastMissionId), -1, -1))
    print("curIdx:", curIdx)
  end
  if curIdx == nil then
    curIdx = 1
  end
  self:getNode("txt_progress"):setText(string.format("%d/9", curIdx))
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.popView
  })
end
function DayantaWarning:Continue()
  self:CloseSelf()
end
function DayantaWarning:Exit()
  self:CloseSelf()
  netsend.netteamwar.exitDayanta()
end
function DayantaWarning:OnBtn_Continue(btnObj, touchType)
  self:Continue()
end
function DayantaWarning:OnBtn_Exit(btnObj, touchType)
  self:Exit()
end
function DayantaWarning:OnBtn_Close(btnObj, touchType)
  self:Continue()
end
