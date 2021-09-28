CPvpRule = class("CPvpRule", CcsSubView)
function CPvpRule:ctor()
  CPvpRule.super.ctor(self, "views/pvprule.json", {isAutoCenter = true, opacityBg = 0})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
end
function CPvpRule:Btn_Close(obj, t)
  self:CloseSelf()
end
function CPvpRule:Clear()
end
