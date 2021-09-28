KejuEntrance = class("KejuEntrance", CcsSubView)
function KejuEntrance:ctor()
  KejuEntrance.super.ctor(self, "views/keju_entrance.csb", {isAutoCenter = false})
  local btnBatchListener = {
    btn_kejuReady = {
      listener = handler(self, self.Btn_EnterDianshi),
      variName = "btn_kejuReady"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.txt_kejuCdTime = self:getNode("txt_kejuCdTime")
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.frameUpdate))
  self:scheduleUpdate()
  self:KejuEntranceUpdate(0)
end
function KejuEntrance:Btn_EnterDianshi(btnObj, touchType)
  print("Btn_EnterDianshi")
  activity.keju:comfirmDianshi()
end
function KejuEntrance:frameUpdate(dt)
  self:KejuEntranceUpdate(dt)
end
function KejuEntrance:KejuEntranceUpdate(dt)
  local svrtime = g_DataMgr:getServerTime()
  if svrtime ~= nil and svrtime > 0 then
    local startTime = activity.keju:getDianshiStarttime()
    if startTime > 0 then
      local cdTime = startTime - svrtime
      if cdTime <= 0 then
        activity.keju:giveupDianshi()
      else
        local h, m, s = getHMSWithSeconds(cdTime)
        self.txt_kejuCdTime:setText(string.format("%02d:%02d:%02d", h, m, s))
      end
    end
  end
end
function KejuEntrance:Clear()
  activity.keju:KejuEntranceBtnClose(self)
end
