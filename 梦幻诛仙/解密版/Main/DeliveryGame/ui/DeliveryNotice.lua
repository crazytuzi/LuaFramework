local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DeliveryNotice = Lplus.Extend(ECPanelBase, "DeliveryNotice")
local DeliveryGameUtils = require("Main.DeliveryGame.DeliveryGameUtils")
local def = DeliveryNotice.define
def.field("string").content = ""
def.field("function").callback = nil
def.static("number", "string", "function").ShowDeliveryNoticeBig = function(activityId, content, cb)
  local dlg = DeliveryNotice()
  dlg.content = content
  dlg.callback = cb
  local res = DeliveryGameUtils.GetActivityRes(activityId)
  dlg:CreatePanel(res.PREFAB_DELIVERY_NOTICE_BIG, 1)
end
def.static("number", "string", "function").ShowDeliveryNoticeSmall = function(activityId, content, cb)
  local dlg = DeliveryNotice()
  dlg.content = content
  dlg.callback = cb
  local res = DeliveryGameUtils.GetActivityRes(activityId)
  dlg:CreatePanel(res.PREFAB_DELIVERY_NOTICE_SMALL, 1)
end
def.override().OnCreate = function(self)
  local lbl = self.m_panel:FindDirect("Img_Bg0/Label_Tips")
  lbl:GetComponent("UILabel"):set_text(self.content)
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Show" then
    local cb = self.callback
    self:DestroyPanel()
    if cb then
      cb()
    end
  elseif id == "Btn_Confirm" then
    self:DestroyPanel()
  end
end
DeliveryNotice.Commit()
return DeliveryNotice
