local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local CGEventAttachWeapon = Lplus.Class("CGEventAttachWeapon")
local def = CGEventAttachWeapon.define
local s_inst
def.static("=>", CGEventAttachWeapon).Instance = function()
  if not s_inst then
    s_inst = CGEventAttachWeapon()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local hostm = dramaTable[dataTable.hostid]
  local modelPath
  local id = dataTable.resourceID
  if id > 0 then
    do
      local partInfo = require("Main.Equip.EquipUtils").GetEquipBasicInfo(id)
      if partInfo == nil then
        return
      end
      local equipRes = GetEquipmentModelCfg(partInfo.equipmodel)
      if equipRes == nil or equipRes == "" then
        return
      end
      local resname = equipRes .. ".u3dext"
      print("Weapon Name = ", resname)
      local ECModel = require("Model.ECModel")
      local model = ECModel.new(id)
      model.defaultLayer = hostm.defaultLayer
      local offhand
      local WeaponType = require("consts.mzm.gsp.item.confbean.WeaponType")
      if partInfo.weaponType == WeaponType.BOTH then
        offhand = {
          id = partInfo.equipmodel
        }
      else
        offhand = nil
      end
      local OnLoadPartObj = function(ecModel, id, model, addToPart)
        if ecModel.m_model == nil then
          model:Destroy()
          return
        end
        local partObj = ecModel.m_model:FindChild(addToPart)
        if partObj == nil then
          model:Destroy()
          return
        end
        ecModel:AttachModel(id, model, addToPart)
      end
      local function onLoadObj(obj)
        if obj == nil then
          print("part is Nil !")
          return
        end
        obj:SetActive(true)
        OnLoadPartObj(hostm, tostring(id), obj, "Bip01_RightWeapon")
      end
      model:Load(resname, onLoadObj)
      eventObj:Finish()
      if offhand then
        local function onLoadOffhandObj(obj)
          if obj == nil then
            print("part is Nil !")
          end
          obj:SetActive(true)
          OnLoadPartObj(hostm, "offhand_" .. offhand.id, obj, "Bip01_LeftWeapon")
        end
        offhand.model = ECModel.new(offhand.id)
        offhand.model.parentNode = hostm.m_model
        offhand.model.defaultLayer = hostm.defaultLayer
        offhand.model:Load(resname, onLoadOffhandObj)
      else
        hostm:DestroyChild("Weapon")
        eventObj:Finish()
        return
      end
    end
  end
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  dataTable.isFinished = true
  if dataTable.model == "" then
    return
  end
  local hostm = dramaTable[dataTable.hostid]
  hostm:DestroyChild("Weapon")
end
CGEventAttachWeapon.Commit()
CG.RegEvent("CGLuaAttachWeapon", CGEventAttachWeapon.Instance())
return CGEventAttachWeapon
