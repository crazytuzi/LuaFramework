local Lplus = require("Lplus")
local CG = require("CG.CG")
local EC = require("Types.Vector")
local ECModel = require("Model.ECModel")
local ECGUIMan = Lplus.ForwardDeclare("ECGUIMan")
local ECPanelBase = require("GUI.ECPanelBase")
local EC2 = require("Types.Vector3")
local ECPanelOtherGUI = Lplus.Extend(ECPanelBase, "ECPanelOtherGUI")
local def = ECPanelOtherGUI.define
def.field("userdata").m_eventObj = nil
def.field("table").m_dramaTable = nil
def.static("=>", ECPanelOtherGUI).new = function()
  local otherGUI = ECPanelOtherGUI()
  otherGUI.m_depthLayer = GUIDEPTH.TOPMOST
  return otherGUI
end
def.override().OnCreate = function(self)
  if self.m_panel then
    self.m_eventObj:SetEvent(self.m_panel)
  end
end
def.method("string").onClick = function(self, id)
  print("click:", id)
  if id == "Btn_Skip" then
    local identity = self.m_dramaTable.identity
    print("click to exit cg:", identity)
    if identity and CG.IsServerCG(identity) then
      local CGProt = require("PB.pb_cg")
      CGProt.Skip(true)
    end
    self.m_dramaTable.drama:Stop()
  end
end
def.method("string").SetDialogText = function(self, txt)
  local textGo = self.m_panel:FindChild("DialogText")
  if textGo then
    local label = textGo:GetComponent("UILabel")
    label.text = txt
  end
end
ECPanelOtherGUI.Commit()
local CGEventPlayOther = Lplus.Class("CGEventPlayOther")
local def = CGEventPlayOther.define
local s_inst, timerUI, camEffectTimer
def.static("=>", CGEventPlayOther).Instance = function()
  if not s_inst then
    s_inst = CGEventPlayOther()
  end
  return s_inst
end
def.method("string", "=>", "boolean").IsCGPanel = function(self, resname)
  if not resname then
    return false
  end
  if string.find(resname, "Panel_CG") then
    return true
  end
  return false
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  print("event:", dataTable.event)
  local function load(obj)
    if eventObj.isnil or dataTable.isFinished then
      return
    end
    eventObj:Finish()
    if not obj then
      print("failed to load EventPlayOther res:", dataTable.event)
      return
    end
    if obj then
      if dataTable.type == 0 then
        do
          local panel = ECPanelOtherGUI.new()
          panel.m_eventObj = eventObj
          panel.m_dramaTable = dramaTable
          panel:CreateFromGameObject(obj, "cgguievent", nil, nil)
          panel:BringTop()
          dataTable.eventGo = panel
          if self:IsCGPanel(dataTable.event) then
            dramaTable.cgpanel = panel
          end
          local dialogCom = panel.m_panel:GetComponent("DialogLabel")
          if dialogCom ~= nil then
            dialogCom:SetType(dataTable.dialogType)
            dialogCom:SetText("")
            GameUtil.AddCGTimer(dataTable.txtTime, true, function()
              if dialogCom ~= nil and panel.m_panel ~= nil and not panel.m_panel.isnil then
                dialogCom:SetText(dataTable.txt)
              end
            end)
          end
          timerUI = panel
        end
      else
        do
          local m = Object.Instantiate(obj, "GameObject")
          eventObj:SetEvent(m)
          dataTable.eventGo = m
          local ECGame = require("Main.ECGame")
          if dataTable.type == 2 then
            camEffectTimer = GameUtil.AddCGTimer(0.05, false, function()
              if dataTable.eventGo == nil then
                return
              end
              dataTable.eventGo.position = ECGame.Instance().m_2DWorldCamObj.position
            end)
          end
        end
      end
      if 0 < dataTable.useTime then
        dataTable.timer = GameUtil.AddCGTimer(dataTable.useTime, true, function()
          if dataTable.eventGo ~= nil then
            dataTable.eventGo.m_panel:SetActive(false)
            dataTable.eventGo:DestroyPanel()
          end
          dataTable.timer = nil
        end)
      end
    end
  end
  GameUtil.AsyncLoad(dataTable.event, load)
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  dataTable.isFinished = true
  if dataTable.type == 0 then
    if dataTable.eventGo then
      dataTable.eventGo:DestroyPanel()
      if self:IsCGPanel(dataTable.event) then
        dramaTable.cgpanel = nil
      end
    end
  else
    if dataTable.eventGo then
      Object.Destroy(dataTable.eventGo)
    end
    GameUtil.RemoveCGTimer(camEffectTimer)
  end
  if dataTable.timer ~= nil then
    GameUtil.RemoveCGTimer(dataTable.timer)
  end
  dataTable.eventGo = nil
end
CGEventPlayOther.Commit()
CG.RegEvent("CGLuaEventPlayOther", CGEventPlayOther.Instance())
return CGEventPlayOther
