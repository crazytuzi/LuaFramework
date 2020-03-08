local Lplus = require("Lplus")
local PaintPart = Lplus.Class("PaintPart")
local def = PaintPart.define
local instance
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector3")
local ChildrensDayMgr = require("Main.Festival.ChildrensDay.ChildrensDayMgr")
local EC = require("Types.Vector")
def.field("table")._paintArea = nil
def.field("table")._prePos = nil
def.field("boolean")._bPreIsInArea = false
def.field("boolean")._bIsDragging = false
def.field("boolean")._bIsTouching = false
def.field("userdata")._rootGO = nil
def.field("table")._arrGOs = nil
def.field("table")._arrLines = nil
def.field("number")._iLineCount = 0
def.field("table")._linesInfo = nil
def.field("number")._curColor = 0
def.field("number")._nLineWidth = 0.02
def.field("userdata")._panel = nil
def.field("table")._tblSynToServer = nil
def.field("number")._synTimer = 0
def.field("boolean")._bIsMyTurn = false
def.const("number").COLOR_NUM = 8
def.field("table").MAP_LINE_WIDTH = nil
def.field("table").MAP_COLOR = nil
def.field("userdata")._uiModel = nil
def.field("userdata")._uiModelCam = nil
def.field("table")._uiGOs = nil
def.field("table")._canvasWorldPos = nil
def.field("table")._zOffset = nil
def.field("table")._oldUIModelCamPos = nil
def.const("number").SYN_TIMESTEP = 0.2
def.static("=>", PaintPart).Instance = function()
  if instance == nil then
    instance = PaintPart()
  end
  return instance
end
def.method("userdata", "boolean").OnCreate = function(self, panel, bIsMyTurn)
  local penCfg = ChildrensDayMgr.GetPenCfg()
  self.MAP_LINE_WIDTH = penCfg.sizes
  self.MAP_COLOR = penCfg.colors
  self._nLineWidth = self.MAP_LINE_WIDTH[2]
  self._linesInfo = {iTotalLines = 0}
  self._bIsMyTurn = bIsMyTurn
  self._panel = panel
  self._uiGOs = {}
  self._rootGO = self._panel:FindDirect("lineRoot")
  self._uiModel = self._panel:FindDirect("uiModel"):GetComponent("UIModel")
  self._uiModel.modelGameObject = self._rootGO
  self._uiModelCam = self._uiModel:get_modelCamera()
  self._uiModelCam.transform.localRotation = Quaternion.Euler(EC.Vector3.new(0, 0, 0))
  self._rootGO:set_layer(ClientDef_Layer.UI_Model1)
  self:CaculatePaintArea()
  self:Init()
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.DRAWER_CHANGE, PaintPart.OnDrawerChange)
  Event.RegisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.SYN_LINEDATA_SUCCESS, PaintPart.OnSynLinedataSuccess)
  Event.RegisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.RCV_LINEDATA, PaintPart.OnRcvOneLineData)
  Event.RegisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.RCV_LINE_APPEND, PaintPart.OnRcvLineAppend)
  Event.RegisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.STOP_SYN_LINEDATA, PaintPart.OnStopSendLineData)
  Event.RegisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.CLEAR_CANVAS, PaintPart.OnClearCanvas)
  Event.RegisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.SYN_HISTORY_LINEDATA_DONE, PaintPart.SynHistoryLineDataDone)
  self._arrGOs = {}
  self._arrLines = {}
  self._curColor = 1
  self._prePos = nil
  self._bPreIsInArea = false
  if self._bIsMyTurn then
  end
  local ctrl_root = self._panel:FindDirect("Group_Btn/Group_Btn/Group_Colour")
  for i = 1, PaintPart.COLOR_NUM do
    local ctrl_color = ctrl_root:FindDirect(("Color%d"):format(i))
    ctrl_color:GetComponent("UISprite").color = self.MAP_COLOR[i]
  end
  self._uiGOs.imgHint = self._panel:FindDirect("Img_Bg0/Img_BgPrint/Group_Tips/Sprite")
  local rubber = self._panel:FindDirect("Group_Btn/Group_Btn/Btn_Rubber")
  if rubber ~= nil then
    rubber:SetActive(false)
  end
  _G.Timer:RegisterIrregularTimeListener(self.CheckUIModelCamChange, self)
end
def.method().SynLineData2Server = function(self)
  if self._bIsMyTurn then
    _G.Timer:RemoveIrregularTimeListener(self.OnUpdate)
    _G.Timer:RegisterIrregularTimeListener(self.OnUpdate, self)
    if self._synTimer ~= 0 then
      _G.GameUtil.RemoveGlobalTimer(self._synTimer)
    end
    self._synTimer = _G.GameUtil.AddGlobalTimer(PaintPart.SYN_TIMESTEP, false, function()
      self:SynLineDataToServer()
    end)
  end
end
def.method("boolean").UpdateDrawer = function(self, bIsMyTurn)
  self:ResetCanvas()
  if not self._bIsMyTurn and bIsMyTurn then
    self._bIsMyTurn = bIsMyTurn
    _G.Timer:RegisterIrregularTimeListener(self.OnUpdate, self)
    self._synTimer = _G.GameUtil.AddGlobalTimer(PaintPart.SYN_TIMESTEP, false, function()
      self:SynLineDataToServer()
    end)
    self:SetImgHintVisible(true)
  end
  if self._bIsMyTurn and not bIsMyTurn then
    self._bIsMyTurn = bIsMyTurn
    _G.Timer:RemoveIrregularTimeListener(self.OnUpdate)
    _G.GameUtil.RemoveGlobalTimer(self._synTimer)
    self._synTimer = 0
    self:ResetCanvas()
    self:SetImgHintVisible(false)
  end
end
def.method().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.DRAWER_CHANGE, PaintPart.OnDrawerChange)
  Event.UnregisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.SYN_LINEDATA_SUCCESS, PaintPart.OnSynLinedataSuccess)
  Event.UnregisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.RCV_LINEDATA, PaintPart.OnRcvOneLineData)
  Event.UnregisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.RCV_LINE_APPEND, PaintPart.OnRcvLineAppend)
  Event.UnregisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.STOP_SYN_LINEDATA, PaintPart.OnStopSendLineData)
  Event.UnregisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.CLEAR_CANVAS, PaintPart.OnClearCanvas)
  Event.UnregisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.SYN_HISTORY_LINEDATA_DONE, PaintPart.SynHistoryLineDataDone)
  self._paintArea = nil
  self._prePos = nil
  self._bIsDragging = false
  self._rootGO = nil
  self._arrGOs = nil
  self._arrLines = nil
  self._iLineCount = 0
  self._curColor = 0
  _G.Timer:RemoveIrregularTimeListener(self.OnUpdate)
  _G.GameUtil.RemoveGlobalTimer(self._synTimer)
  self._synTimer = 0
  self._linesInfo = nil
  self.MAP_COLOR = nil
  self.MAP_LINE_WIDTH = nil
  self._uiGOs = nil
  self._uiModel.modelGameObject = nil
  if self._uiModel then
    self._uiModel:Destroy()
  end
  self._uiModel = nil
  self._uiModelCam = nil
  self._canvasWorldPos = nil
  self._oldUIModelCamPos = nil
  _G.Timer:RemoveIrregularTimeListener(self.CheckUIModelCamChange)
end
def.method("number").CheckUIModelCamChange = function(self, dt)
  if self._oldUIModelCamPos == nil or self._oldUIModelCamPos.x ~= self._uiModelCam.transform.position.x then
    self._oldUIModelCamPos = self._uiModelCam.transform.position
    warn("old uiModel pos ", self._oldUIModelCamPos, " cur _uiModelCam pos ", self._uiModelCam.transform.position)
    self:CaculatePaintArea()
    self:RedrawAll()
  end
end
def.method().CaculatePaintArea = function(self)
  local canvas = self._panel:FindDirect("uiModel")
  local canvas_world_pos = canvas:get_position()
  self._canvasWorldPos = canvas_world_pos
  local ui_pos = PaintPart.WorldToScreenPoint(canvas_world_pos)
  local widget = canvas:GetComponent("UIWidget")
  local ui_w, ui_h = widget:get_width(), widget:get_height()
  local rb_wpos = PaintPart.ScreenToWorldPos(Vector.Vector3.new(ui_pos.x + ui_w * 0.5, ui_pos.y - ui_h * 0.5, 0))
  local lt_wpos = PaintPart.ScreenToWorldPos(Vector.Vector3.new(ui_pos.x - ui_w * 0.5, ui_pos.y + ui_h * 0.5, 0))
  local ui2Cam = ECGUIMan.Instance().m_ui2Camera
  local screen_rb, screen_lt = ui2Cam:WorldToScreenPoint(rb_wpos), ui2Cam:WorldToScreenPoint(lt_wpos)
  lt_wpos = self._uiModelCam:ScreenToWorldPoint(screen_lt)
  rb_wpos = self._uiModelCam:ScreenToWorldPoint(screen_rb)
  self._paintArea = {}
  self._paintArea.left = lt_wpos.x
  self._paintArea.right = rb_wpos.x
  self._paintArea.top = lt_wpos.y
  self._paintArea.bottom = rb_wpos.y
  warn(">>>left = " .. self._paintArea.left, "top = " .. self._paintArea.top, " right = " .. self._paintArea.right, "bottom = " .. self._paintArea.bottom)
  self._zOffset = self._uiModelCam:ScreenToWorldPoint(Vector.Vector3.new(0, 0, 1))
end
def.method().RedrawAll = function(self)
  if self._arrLines == nil or self._arrGOs == nil then
    return
  end
  local arrLines = self._arrLines
  local tblSynToServer = self._tblSynToServer
  self:ResetCanvas()
  self._tblSynToServer = tblSynToServer
  self:CaculatePaintArea()
  for idx, lineData in pairs(arrLines) do
    self:ProcessLineData(idx, lineData)
  end
end
def.method("number").OnUpdate = function(self, dt)
  if self._rootGO == nil then
    return
  end
  if self._paintArea == nil then
    return
  end
  if _G.Input.GetMouseButtonDown() then
    self._bIsTouching = true
    self._bIsDragging = true
    self:SetImgHintVisible(false)
  end
  if _G.Input.GetMouseButtonUp() then
    self._bIsTouching = false
    self._bIsDragging = false
    self._bPreIsInArea = false
    return
  end
  local touchPos = _G.Input.mousePosition
  local curPos = self._uiModelCam:ScreenToWorldPoint(touchPos)
  curPos.z = ChildrensDayMgr.Z_VAL
  if self:IsTouching() and self._bIsMyTurn then
    local intersectPos = {
      x = 0,
      y = 0,
      z = ChildrensDayMgr.Z_VAL
    }
    local intersectInfo = self:IsInPaintArea(curPos)
    local function addPt()
      if self._prePos == nil then
        return
      end
      local diff = curPos - self._prePos
      if math.abs(diff.x) > 0.02 or 0.02 < math.abs(diff.y) then
        local curLineNum = self:GetCurLineNumber()
        local line = self._arrLines[curLineNum]
        if line == nil then
          return
        end
        local vertices = line.vertices
        line.width = self:GetLineWidth()
        line.color = self._curColor
        local pt = curPos - self._uiModelCam.transform.position
        pt.z = ChildrensDayMgr.Z_VAL
        table.insert(vertices, pt)
        self._prePos = curPos
        local lineRenderer = self._arrGOs[curLineNum]:GetComponent("LineRenderer")
        local color = line.color
        self:DrawLine(lineRenderer, vertices, color, line.width)
      end
    end
    if intersectInfo.bNotInArea then
      if self._bPreIsInArea then
        curPos.x = intersectInfo.x or curPos.x
        curPos.y = intersectInfo.y or curPos.y
        addPt()
        self._bPreIsInArea = false
      end
    elseif self._bPreIsInArea then
      addPt()
    else
      self._prePos = curPos
      self._bPreIsInArea = true
      warn(">>>>add one line")
      self:AddOneLineGO(touchPos)
    end
  else
  end
end
def.method("=>", "boolean").IsDragging = function(self)
  return self._bIsDragging
end
def.method("=>", "boolean").IsTouching = function(self)
  return self._bIsTouching
end
def.method("table", "=>", "table").IsInPaintArea = function(self, pos)
  local res = {}
  res.bNotInArea = false
  if self._paintArea == nil then
    return res
  end
  if pos.x < self._paintArea.left then
    res.x = self._paintArea.left
    res.bNotInArea = true
  elseif pos.x > self._paintArea.right then
    res.x = self._paintArea.right
    res.bNotInArea = true
  end
  if pos.y > self._paintArea.top then
    res.y = self._paintArea.top
    res.bNotInArea = true
  elseif pos.y < self._paintArea.bottom then
    res.y = self._paintArea.bottom
    res.bNotInArea = true
  end
  return res
end
def.method("table").AddOneLineGO = function(self, touchPos)
  local pt = self._prePos - self._uiModelCam.transform.position
  pt.z = ChildrensDayMgr.Z_VAL
  if self._linesInfo.iTotalLines > 0 then
    local preLine = self._arrLines[self:GetCurLineNumber()]
    if preLine == nil then
      return
    end
    if #preLine.vertices < 2 then
      preLine.vertices[1] = pt
      return
    end
  end
  local line = {}
  line.width = self:GetLineWidth()
  line.color = self:GetCurColor()
  line.vertices = {}
  table.insert(line.vertices, pt)
  self:AddOneLineGOEx(self:AddGetCurLineNumber(), line)
end
def.method("number", "table").AddOneLineGOEx = function(self, lineIdx, lineData)
  local strLineId = ("line_%d"):format(lineIdx)
  local GO = GameObject.GameObject(strLineId)
  GO:set_layer(ClientDef_Layer.UI_Model1)
  GO.parent = self._rootGO
  GO:AddComponent("LineRenderer")
  local lineRenderer = GO:GetComponent("LineRenderer")
  lineRenderer:set_useWorldSpace(true)
  lineRenderer:set_material(Material.Material(Shader.Find("Particles/Alpha Blended Premultiply")))
  lineRenderer:get_material().renderQueue = lineIdx
  self._arrGOs[lineIdx] = GO
  self._arrLines[lineIdx] = lineData
end
def.method("userdata", "table", "number", "number").DrawLine = function(self, lineRenderer, vertices, color, width)
  lineRenderer:SetWidth(width, width)
  lineRenderer:SetVertexCount(#vertices)
  local camPos = self._uiModelCam.transform.position
  for i = 1, #vertices do
    local pt = vertices[i] + camPos
    pt.z = pt.z + 1
    lineRenderer:SetPosition(i - 1, pt)
  end
  color = self.MAP_COLOR[color]
  lineRenderer:SetColors(color, color)
end
def.method("=>", "number").AddGetCurLineNumber = function(self)
  self._iLineCount = self._iLineCount + 1
  self._linesInfo.iTotalLines = self._iLineCount
  return self._iLineCount
end
def.method("=>", "number").GetCurLineNumber = function(self)
  return self._iLineCount
end
def.method("number").SetColor = function(self, color)
  self._curColor = color
end
def.method("=>", "number").GetCurColor = function(self)
  return self._curColor
end
def.method("number").SetLineWidth = function(self, w)
  self._nLineWidth = w
end
def.method("=>", "number").GetLineWidth = function(self)
  return self._nLineWidth
end
def.method("boolean").SetImgHintVisible = function(self, bShow)
  self._uiGOs.imgHint:SetActive(bShow)
end
def.method().ResetCanvas = function(self)
  warn(">>>>ResetCanvas" .. os.clock())
  for _, go in pairs(self._arrGOs) do
    _G.GameObject.Destroy(go)
    go = nil
  end
  self._arrGOs = {}
  self._iLineCount = 0
  self._arrLines = {}
  self._linesInfo.iTotalLines = 0
  self._tblSynToServer = nil
end
def.static("table", "=>", "table").ScreenToWorldPos = function(vec)
  return _G.ScreenPosToWorld(vec.x, vec.y)
end
def.static("table", "=>", "table").WorldToScreenPoint = function(vec)
  return _G.WorldPosToScreen(vec.x, vec.y)
end
def.static("table", "=>", "table").UI2ScreenPos = function(self, vec)
  local screemHeight = ECGUIMan.Instance().m_ui
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  warn("ID = " .. id)
  if id == "Btn_Clear" then
    self:OnBtnClearClick()
    return true
  elseif id == "Btn_Rubber" then
    self:OnBtnRubberClick()
    return true
  elseif id == "Btn_Pen1" then
    self:OnBtnPen1Click()
    return true
  elseif id == "Btn_Pen2" then
    self:OnBtnPen2Click()
    return true
  elseif string.find(id, "Color") ~= nil then
    local idx = tonumber(string.sub(id, string.find(id, "%d")))
    self:OnSelectColor(idx)
    return true
  end
  return false
end
def.method().OnBtnClearClick = function(self)
  self:ResetCanvas()
  ChildrensDayMgr.SendEmptyCanvasReq()
end
def.method().OnBtnRubberClick = function(self)
  self:SetColor(#self.MAP_COLOR)
end
def.method().OnBtnPen1Click = function(self)
  self:SetLineWidth(self.MAP_LINE_WIDTH[1])
end
def.method().OnBtnPen2Click = function(self)
  self:SetLineWidth(self.MAP_LINE_WIDTH[2])
end
def.method("number").OnSelectColor = function(self, idx)
  local arrSize = #self.MAP_COLOR
  local colorIdx = idx
  if idx > arrSize then
    colorIdx = arrSize
  end
  self:SetColor(colorIdx)
end
def.method("number", "=>", "number").GetLineWidthIdx = function(self, width)
  for i = 1, #self.MAP_LINE_WIDTH do
    if math.abs(self.MAP_LINE_WIDTH[i] - width) <= 1.0E-4 then
      return i
    end
  end
  return 1
end
def.static("table", "table").OnDrawerChange = function(p, c)
  if require("Main.Hero.HeroModule").Instance().roleId == p[1] then
    local self = PaintPart.Instance()
    self:UpdateDrawer(true)
  else
    self:UpdateDrawer(false)
  end
end
def.static("table", "table").OnSynLinedataSuccess = function(p, c)
  local self = PaintPart.Instance()
  if self._panel == nil or self._tblSynToServer == nil then
    return
  end
  warn("bVerified = " .. os.clock())
  self._tblSynToServer.bVerified = true
end
def.static("table", "table").OnRcvOneLineData = function(p, c)
  local lineIdx = p.lineIdx
  local line = {}
  line.color = p.colorIdx
  line.vertices = p.vertices
  local self = PaintPart.Instance()
  line.width = self.MAP_LINE_WIDTH[p.width] or 0.01
  self:ProcessLineData(lineIdx, line)
end
def.static("table", "table").OnRcvLineAppend = function(p, c)
  local self = PaintPart.Instance()
  self:RcvAppendData(p.lineIdx, p.vertices)
end
def.static("table", "table").OnStopSendLineData = function(p, c)
  local self = PaintPart.Instance()
  if self._panel == nil then
    return
  end
  _G.Timer:RemoveIrregularTimeListener(self.OnUpdate)
  _G.GameUtil.RemoveGlobalTimer(self._synTimer)
  self._synTimer = 0
end
def.static("table", "table").SynHistoryLineDataDone = function(p, c)
  local self = PaintPart.Instance()
  if self._panel == nil then
    return
  end
  if self._bIsMyTurn then
    if p ~= nil then
      self._tblSynToServer = {}
      local synData = self._tblSynToServer
      synData.sentLineIdx = p.lineIdx
      synData.vIdxStart = p.vIdxStart
      synData.vIdxEnd = p.vIdxEnd
      synData.bVerified = true
      synData.bIsAppend = false
    end
    self:SynLineData2Server()
  end
end
def.static("table", "table").OnClearCanvas = function(p, c)
  local self = PaintPart.Instance()
  if self._panel == nil then
    return
  end
  self:ResetCanvas()
  if self._bIsMyTurn then
    self:SetImgHintVisible(true)
  end
end
def.method().SynLineDataToServer = function(self)
  if self._arrLines == nil or self._linesInfo.iTotalLines == 0 then
    return
  end
  if self._tblSynToServer == nil then
    local arrLines = self._arrLines
    if #arrLines[1].vertices < 2 then
      return
    end
    warn(">>>>send first line")
    self._tblSynToServer = {}
    if not self:SendOneLine(1) then
      self._tblSynToServer = nil
    end
  else
    local synData = self._tblSynToServer
    local lineIdx = synData.sentLineIdx
    if lineIdx == nil then
      return
    end
    if synData.bVerified then
      local localLine = self._arrLines[lineIdx]
      if localLine == nil then
        return
      end
      if #localLine.vertices > synData.vIdxEnd then
        self:AppendLineToServer(lineIdx)
      elseif lineIdx < self._linesInfo.iTotalLines then
        self:SendOneLine(lineIdx + 1)
      end
    else
      local now = _G.GetServerTime()
      local timeDiff = now - synData.timestamp
      if timeDiff < 3 then
        return
      end
      if 2 > synData.vIdxEnd and 2 > synData.vIdxStart then
        self:SendOneLine(lineIdx)
        return
      end
      local line = self._arrLines[lineIdx]
      if line == nil then
        return
      end
      local width = self:GetLineWidthIdx(line.width)
      warn("synData.bIsAppend :" .. tostring(synData.bIsAppend))
      if synData.bIsAppend then
        local inputVertices = line.vertices
        synData.timestamp = _G.GetServerTime()
        ChildrensDayMgr.SendAppendLineReq(lineIdx, inputVertices, synData.vIdxStart, synData.vIdxEnd)
      else
        warn("send again width = " .. width, " lineIdx=" .. lineIdx, "s=" .. synData.vIdxStart, "e=" .. synData.vIdxEnd)
        synData.timestamp = _G.GetServerTime()
        ChildrensDayMgr.SendLineInfoReq(lineIdx, line, width)
      end
    end
  end
end
def.method("number", "=>", "boolean").SendOneLine = function(self, lineIdx)
  local synData = self._tblSynToServer
  local arrLines = self._arrLines
  if arrLines[lineIdx] == nil then
    return false
  end
  local iS, iE = 1, #arrLines[lineIdx].vertices
  if iE - iS < 1 then
    return false
  end
  local line = arrLines[lineIdx]
  local widthIdx = self:GetLineWidthIdx(line.width)
  ChildrensDayMgr.SendLineInfoReq(lineIdx, arrLines[lineIdx], widthIdx)
  synData.sentLineIdx = lineIdx
  synData.vIdxStart = iS
  synData.vIdxEnd = iE
  synData.bVerified = false
  synData.timestamp = _G.GetServerTime()
  synData.bIsAppend = false
  return true
end
def.method("number").AppendLineToServer = function(self, lineIdx)
  local synData = self._tblSynToServer
  local localLine = self._arrLines[lineIdx]
  local iS, iE = synData.vIdxEnd + 1, #localLine.vertices
  if iE < 3 then
    return
  end
  ChildrensDayMgr.SendAppendLineReq(lineIdx, localLine.vertices, iS, iE)
  synData.vIdxStart = iS
  synData.vIdxEnd = iE
  synData.bVerified = false
  synData.bIsAppend = true
  synData.timestamp = _G.GetServerTime()
  warn("Append: vIdxStart:" .. synData.vIdxStart, "vIdxEnd:" .. synData.vIdxEnd, "lineIdx:" .. lineIdx, "clock:" .. os.clock())
end
def.method("number", "table").ProcessLineData = function(self, idx, line)
  self._arrLines[idx] = line
  self:AddGetCurLineNumber()
  self:AddOneLineGOEx(idx, line)
  if self._arrGOs[idx] == nil then
    warn("There are something wrong, line idx =" .. idx, " current line number =" .. self:GetCurLineNumber())
    return
  end
  local lineRenderer = self._arrGOs[idx]:GetComponent("LineRenderer")
  local color = line.color or 1
  self:DrawLine(lineRenderer, line.vertices, color, line.width)
end
def.method("number", "table").RcvAppendData = function(self, idx, vertices)
  local line = self._arrLines[idx]
  if line == nil then
    return
  end
  local verts = line.vertices
  for i = 1, #vertices do
    table.insert(verts, vertices[i])
  end
  local lineGO = self._arrGOs[idx]
  if lineGO == nil then
    warn(">>>>There are some errors when rcv append line data")
    return
  end
  local lineRenderer = lineGO:GetComponent("LineRenderer")
  local color = line.color
  self:DrawLine(lineRenderer, line.vertices, color, line.width)
end
return PaintPart.Commit()
