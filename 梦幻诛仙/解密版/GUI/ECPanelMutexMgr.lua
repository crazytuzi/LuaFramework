local Lplus = require("Lplus")
local ECPanelMutexMgr = Lplus.Class("ECPanelMutexMgr")
local s_inst
do
  local def = ECPanelMutexMgr.define
  def.static("=>", ECPanelMutexMgr).Instance = function()
    return s_inst
  end
  local ECPanelBase = require("GUI.ECPanelBase")
  def.method(ECPanelBase, "string").RegisterMutexPanel = function(self, panel, groupname)
    local index = self:Find(panel, groupname)
    if index == 0 then
      self.mPanelGroup[groupname] = self.mPanelGroup[groupname] or {}
      table.insert(self.mPanelGroup[groupname], panel)
    end
  end
  def.method(ECPanelBase).UnRegisterMutexPanel = function(self, panel)
    for k, panelList in pairs(self.mPanelGroup) do
      local index = self:Find(panel, k)
      if index > 0 then
        table.remove(self.mPanelGroup[k], index)
      end
    end
  end
  def.method(ECPanelBase, "string", "=>", "number").Find = function(self, panel, groupname)
    local panelList = self.mPanelGroup[groupname]
    if not panelList then
      return 0
    end
    for k, v in pairs(panelList) do
      if v == panel then
        return k
      end
    end
    return 0
  end
  def.method(ECPanelBase).CheckOpenTarget = function(self, panel)
    for _, panelList in pairs(self.mPanelGroup) do
      for _, v in pairs(panelList) do
        if v ~= panel then
          v:DestroyPanel()
        end
      end
    end
  end
  def.method(ECPanelBase, "table").MutexTo = function(self, panel, withPanelName)
    self.mMutex[panel] = self.mMutex[panel] or {}
    table.insert(self.mMutex[panel], withPanelName)
  end
  def.method(ECPanelBase, "table").MutexToEx = function(self, panel, withPanelNames)
    self.mMutex[panel] = self.mMutex[panel] or {}
    for k, v in pairs(withPanelNames) do
      table.insert(self.mMutex[panel], v)
    end
  end
  def.method(ECPanelBase).UnMutexTo = function(self, panel)
    self.mMutex[panel] = nil
  end
  def.method(ECPanelBase).TriggerMutex = function(self, panel)
    if not self.mMutex[panel] then
      return
    end
    local ECGUIMan = require("GUI.ECGUIMan")
    for _, v in pairs(self.mMutex[panel]) do
      local panelName = v[1]
      local func = v[2]
      if panelName and func then
        local thePanel = ECGUIMan.Instance():FindPanelByName(panelName)
        func(thePanel)
      end
    end
  end
  def.field("table").mPanelGroup = function()
    return {}
  end
  def.field("table").mMutex = function()
    return {}
  end
end
ECPanelMutexMgr.Commit()
s_inst = ECPanelMutexMgr()
return ECPanelMutexMgr
