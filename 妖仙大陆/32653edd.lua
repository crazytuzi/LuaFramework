local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local MountModel = require "Zeus.Model.Mount"
local DetailModel = require'Zeus.Model.Item'
local RideModelBase = require 'Zeus.UI.XmasterRide.RideModelBase'

local self = {
  menu = nil,
}

local function AddScaleAction(self, node, scale, duration, cb)
  local scaleAction = ScaleAction.New()
  scaleAction.ScaleX = scale
  scaleAction.ScaleY = scale
  scaleAction.Duration = duration
  node:AddAction(scaleAction)
  scaleAction.ActionFinishCallBack = cb
end

local function Close(self)
  self.btn_close.Enable = false
  self.btn_confirm.Enable = false
  AddScaleAction(self, self.cvs_scale, 1.1, 0.15, function()
    AddScaleAction(self, self.cvs_scale, 0.5, 0.2, function()
      RemoveLateUpdate("Event.GameUINewItems.Update", true)
      self.menu:Close()
    end)
  end)
end

local function UseNewSkin()
  MountModel.activeMountSkinRequest(self.id, function ()
  end)

  if not DataMgr.Instance.UserData.RidingMount then
    DataMgr.Instance.UserData.RidingMount = true
  end

  Close(self)
end

local function SetRideSkinData(data)
  self.id = data.s2c_skinId

  local v = MountModel.GetSkinDataById(self.id)
  self.lb_name.Text = v.SkinName
  local modelFile = v.ModelFile
  RideModelBase.InitModelAvaterstr(self, self.cvs_3d, modelFile, nil, true)

  MountModel.getMountInfoRequest(function()
    if self.id == 1 then
      DataMgr.Instance.FlagPushData:SetAttribute(FlagPushData.FLAG_MOUNT,1,true)
    end
  end)
end

local function DoScaleAction(self)
  local x = self.cvs_scale.X
  local y = self.cvs_scale.Y
  local w = self.cvs_scale.Width
  local h = self.cvs_scale.Height

  AddLateUpdate("Event.GameUINewItems.Update", function(dt)
    self.cvs_scale.X = x - (self.cvs_scale.Scale.x-1)*w/2
    self.cvs_scale.Y = y - (self.cvs_scale.Scale.y-1)*h/2
    end)

  AddScaleAction(self, self.cvs_scale, 0.25, 0.01, function()
    AddScaleAction(self, self.cvs_scale, 1.1, 0.2, function()
      AddScaleAction(self, self.cvs_scale, 1, 0.2, function()
        self.btn_close.Enable = true
        self.btn_confirm.Enable = true
      end)
    end)
  end)
end

local function OnEnter()
  self.cvs_scale.X = 0
  self.cvs_scale.Y = 0
  self.cvs_scale.Scale = Vector3.New(1, 1, 1)
  self.btn_close.Enable = false
  self.btn_confirm.Enable = false
  DoScaleAction(self)
end

local function OnExit()
  RideModelBase.ClearModel(self)
end

local function initUI()
  self.ib_tx.Scale = Vector2.New(2.1, 1.55)
end

local ui_names = 
{
  
  {name = 'ib_tx'},
  {name = 'cvs_3d'},
  {name = 'lb_name'},
  {name = 'cvs_scale'},
  {name = 'btn_close',click = Close},
  {name = 'btn_confirm',click = function ()
    UseNewSkin()
  end},
}

local function InitCompnent()
  self.menu:SubscribOnEnter(OnEnter)
  self.menu:SubscribOnExit(OnExit)
  self.menu:SubscribOnDestory(function ()
    self = nil
  end)

  Util.CreateHZUICompsTable(self.menu,ui_names,self)

  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/ride/congratulation.gui.xml", GlobalHooks.UITAG.GameUIGetNewSkin)
  self.menu.ShowType = UIShowType.HideBackHud
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
  self.menu:SetFullBackground(lrt)
  InitCompnent()
  return self.menu
end

local function Create(params)
  self = {}
  setmetatable(self, _M)
  local node = Init(params)
  return self
end

_M.SetRideSkinData = SetRideSkinData

return {Create = Create}
