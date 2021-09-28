local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local MountModel = require "Zeus.Model.Mount"
local DetailModel = require'Zeus.Model.Item'
local RideModelBase = require 'Zeus.UI.XmasterRide.RideModelBase'

local self = {
  menu = nil,
}

local function ChoiceNewSkin(self,id)
  MountModel.chooseFirstSkinRequest(id, function ()
  end)
  if self and self.menu then
      self.menu:Close()
  end
end

local function OnEnter()

end

local function OnExit()
  RideModelBase.ClearModel(self.list1)
  RideModelBase.ClearModel(self.list2)
  RideModelBase.ClearModel(self.list3)
end

local function initUI()
  self.list1 = {}
  self.list2 = {}
  self.list3 = {}
  local v1 = MountModel.GetSkinDataById(self.btn_name1.UserTag)
  local v2 = MountModel.GetSkinDataById(self.btn_name2.UserTag)
  local v3 = MountModel.GetSkinDataById(self.btn_name3.UserTag)

  self.ib_petshow1.IsInteractive = true
  self.ib_petshow2.IsInteractive = true
  self.ib_petshow3.IsInteractive = true

  RideModelBase.InitModelAvaterstr(self.list1, self.ib_petshow1, v1.ModelFile, nil, true)
  IconGenerator.instance:SetModelPos(self.list1.Model3DAssetBundel, Vector3.New(0.2, -5.5, 15))

  RideModelBase.InitModelAvaterstr(self.list2, self.ib_petshow2, v2.ModelFile, nil, true)
  IconGenerator.instance:SetModelPos(self.list2.Model3DAssetBundel, Vector3.New(0.2, -5.5, 15))

  RideModelBase.InitModelAvaterstr(self.list3, self.ib_petshow3, v3.ModelFile, nil, true)
  IconGenerator.instance:SetModelPos(self.list3.Model3DAssetBundel, Vector3.New(0.2, -5.5, 15))

  self.btn_name1.TouchClick = function (sender)
      ChoiceNewSkin(self,sender.UserTag)
  end
  self.btn_name2.TouchClick = function (sender)
      ChoiceNewSkin(self,sender.UserTag)
  end
  self.btn_name3.TouchClick = function (sender)
      ChoiceNewSkin(self,sender.UserTag)
  end
end

local ui_names = 
{
  
  {name = 'ib_petshow1'},
  {name = 'ib_petshow2'},
  {name = 'ib_petshow3'},
  {name = 'btn_name1'},
  {name = 'btn_name1'},
  {name = 'btn_name2'},
  {name = 'btn_name3'},
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
  self.menu = LuaMenuU.Create("xmds_ui/ride/ride_choice.gui.xml", GlobalHooks.UITAG.GameUINewSkinChoice)
  
  
  
  
  
  InitCompnent()
  return self.menu
end

local function Create(params)
  self = {}
  setmetatable(self, _M)
  local node = Init(params)
  return self
end

return {Create = Create}
