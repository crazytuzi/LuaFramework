CDuelRule = class("CDuelRule", CcsSubView)
function CDuelRule:ctor()
  CDuelRule.super.ctor(self, "views/duelrule.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local txt_cost = self:getNode("txt_cost")
  txt_cost:setText(string.format("2.下战书需要扣除一定费用,费用=人物等级*%d", data_Variables.HuangGongCostCoinPerLv))
end
function CDuelRule:Btn_Close(obj, t)
  self:CloseSelf()
end
function CDuelRule:Clear()
end
