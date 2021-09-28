local _M = {}
_M.__index = _M


local ChatUtil      = require "Zeus.UI.Chat.ChatUtil"
local Util          = require "Zeus.Logic.Util"


local PetModelBase          = require 'Zeus.UI.XmasterPet.PetModelBase'

local self = {
    m_Root = nil,

}

local function AddScaleAction(self, node, scale, duration, cb)
  local scaleAction = ScaleAction.New()
  scaleAction.ScaleX = scale
  scaleAction.ScaleY = scale
  scaleAction.Duration = duration
  node:AddAction(scaleAction)
  scaleAction.ActionFinishCallBack = cb
end

local function OnClickClose(displayNode)
    
    self.btn_yes.Enable = false
    AddScaleAction(self, self.cvs_scale, 1.1, 0.15, function()
        AddScaleAction(self, self.cvs_scale, 0.5, 0.2, function()
        RemoveLateUpdate("Event.GameUINewItems.Update", true)
            if self ~= nil and self.m_Root ~= nil then
                self.m_Root:Close()
            end
        end)
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
        self.btn_yes.Enable = true
      end)
    end)
  end)
end

local function OnEnter()
  self.cvs_scale.X = 0
  self.cvs_scale.Y = 0
  self.cvs_scale.Scale = Vector3.New(1, 1, 1)
  self.btn_yes.Enable = false
  DoScaleAction(self)
end

local function OnExit()
    
    PetModelBase.ClearModel(self)
end

local function InitUI()
    
    local UIName = {
        "cvs_word",
        "cvs_close",

        
        "btn_yes",
        "cvs_scale",
        "ib_tx",
        "cvs_3d",
        "cvs_3d2",
        "lb_name",
        "ib_1",
        "ib_2",
        "ib_3",
        "ib_4",
    }   

    for i = 1, #UIName do
        self[UIName[i]] = self.m_Root:GetComponent(UIName[i])
    end

    self.cvs_word.Visible =true
    self.cvs_close.Visible =false
    self.ib_1.Visible = false
    self.ib_2.Visible = false
    self.ib_3.Visible = true
    self.ib_4.Visible = true
    self.btn_yes.Visible = true
    self.cvs_3d.Visible = false
end



function _M.setPetInfo(params)
    self.curPetInfo = params
    print(PrintTable(params))
    self.lb_name.Text = params.petInfo.name
    
    local petData = GlobalHooks.DB.Find('BaseData',{PetID = params.petInfo.id})[1]
    self.cvs_3d2.Visible =true
    PetModelBase.InitModelAvaterstr(self, self.cvs_3d2, petData, nil, true)
end

local function InitCompnent()
    InitUI()
    self.menu.ShowType = UIShowType.HideBackHud
    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = OnClickClose})

    self.btn_yes.TouchClick = OnClickClose
    self.ib_tx.Scale = Vector2.New(2.1, 1.55)


    self.m_Root:SubscribOnEnter(OnEnter)
    self.m_Root:SubscribOnExit(OnExit)

    self.m_Root:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
    self.m_Root = LuaMenuU.Create("xmds_ui/ride/congratulation.gui.xml", GlobalHooks.UITAG.GameUIPetGetNewPush)
    
    self.menu = self.m_Root

    local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
    self.menu:SetFullBackground(lrt)

    InitCompnent()
    return self.m_Root
end

local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    local node = Init(tag, params)
    return self
end

return {Create = Create}
