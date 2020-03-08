local Lplus = require("Lplus")
local ECCustomPate = Lplus.Class("ECCustomPate")
local EC = require("Types.Vector3")
local ECPlayer = Lplus.ForwardDeclare("ECPlayer")
local ECGUIMan = Lplus.ForwardDeclare("ECGUIMan")
local def = ECCustomPate.define
def.field("userdata").m_pate = nil
def.virtual(ECPlayer).Create = function(self, player)
end
def.virtual().Destroy = function(self)
  if self.m_pate and not self.m_pate.isnil then
    self.m_pate.parent:Destroy()
    self.m_pate = nil
  end
end
local _pate_scale = EC.Vector3.new(300, 300, 1)
local _pate_position = EC.Vector3.new(0, 0, -100000)
local t_vec = EC.Vector3.new(0, 0, 0)
def.method("userdata", ECPlayer, "string", "number").CreateObj = function(self, asset, player, name, offset)
  if asset == nil then
    return
  end
  local attachObj = player.m_model
  if attachObj == nil or attachObj:get_isnil() then
    return
  end
  local pate = Object.Instantiate(asset, "GameObject")
  pate.name = name
  self.m_pate = pate
  local hud = ECGUIMan.Instance():CreateHud(name)
  local follow = hud:AddComponent("HUDFollowTarget")
  follow.target = attachObj.transform
  follow.offset = t_vec:Assign(0, offset, 0)
  self.m_pate.parent = hud
  self.m_pate.localPosition = EC.Vector3.zero
  self.m_pate.localScale = EC.Vector3.one
  hud:SetLayer(ClientDef_Layer.PateText)
  hud:SetActive(true)
  pate.localScale = _pate_scale
  pate.localPosition = _pate_position
  pate:SetActive(player.m_visible and player.showModel and player.showPart)
end
ECCustomPate.Commit()
return ECCustomPate
