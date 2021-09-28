local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local AchievementUtil = require "Zeus.UI.XmasterStronger.StrongerAchievementUtil"
local AchievementAPI = require "Zeus.Model.Achievement"

local self = {
    menu = nil,
}

local suitAtlaIndex = {50,48,52,49,51,47,46,44}

local function UpdateLeftCan()
  for i=1,8 do
      local icon = self.menu:FindChildByEditName("ib_part"..i, true)
      local show = false
      for _,v in ipairs(self.dataList) do
        if _ == i and v.states == 3 then
          show = true
        end
      end
      icon.Visible = show
  end
end

local function UpdateAttrList()
  local activityCount = 0
  for i,v in ipairs(self.dataList) do
    if v.states == 3 then
      activityCount = activityCount + 1
    end
  end

  local attList = GlobalHooks.DB.Find("ArmourPlus", {})
  self.sp_list1:Initialize(self.cvs_get_single1.Width+20, self.cvs_get_single1.Height+10, #attList, 1, self.cvs_get_single1, 
      function(x, y, cell)
          local data = attList[y + 1]
          local lb_cross = cell:FindChildByEditName("lb_cross", true)
          local lb_help = cell:FindChildByEditName("lb_help", true)
          lb_cross.Text = data.ActivateNum..Util.GetText(TextConfig.Type.SUIT, "jianproperty")

          local string = ""
          local list = string.split(data.Prop,";")
          for _,k in ipairs(list) do
              local tmp = string.split(k, ":")
              local attrEle = GlobalHooks.DB.Find('Attribute', tonumber(tmp[1]))
              string = string .. string.gsub(attrEle.attDesc,'{A}',tostring(tmp[2])) .. "    "
          end
          lb_help.Text = string

          if data.ActivateNum <= activityCount then
            lb_cross.FontColor = Util.FontColorGreen
            lb_help.FontColor = Util.FontColorGreen
          else
            lb_cross.FontColor = Util.FontColorWhite
            lb_help.FontColor = Util.FontColorWhite
          end
      end,
      function()

      end
  )
end

local function UpdateItemCell(cell, data)
    
    cell:FindChildByEditName("ib_not", true).Visible = data.states == 1
    cell:FindChildByEditName("lb_bj_active", true).Visible = data.states == 2
    cell:FindChildByEditName("ib_over", true).Visible = data.states == 3
    cell:FindChildByEditName("btn_activity", true).Visible = data.states == 2

    if data.states == 3 then
      cell:FindChildByEditName("lb_attr", true).FontColor = Util.FontColorGreen
    else
      cell:FindChildByEditName("lb_attr", true).FontColor = GameUtil.RGBA2Color(0xADCCF6FF)
    end
end

local function UpdateItemList()
  self.sp_list:Initialize(self.cvs_get_single.Width+20, self.cvs_get_single.Height+5, #self.dataList, 1, self.cvs_get_single, 
      function(x, y, cell)
          local data = self.dataList[y + 1]
          local suitData = GlobalHooks.DB.Find("ArmourAttribute",{ID = data.id})[1]
          local lb_cross = cell:FindChildByEditName("lb_cross", true)
          Util.HZSetImage2(lb_cross, "#dynamic_n/carnival/carnival.xml|carnival|"..suitAtlaIndex[y + 1], true, LayoutStyle.IMAGE_STYLE_BACK_4_CENTER)

          local lb_attr = cell:FindChildByEditName("lb_attr", true)
          local tmp = string.split(suitData.Prop, ":")
          local attrEle = GlobalHooks.DB.Find('Attribute', tonumber(tmp[1]))
          lb_attr.Text = string.gsub(attrEle.attDesc,'{A}',tostring(tmp[2]))

          UpdateItemCell(cell, data)
          local btn_activity = cell:FindChildByEditName("btn_activity", true)
          btn_activity.TouchClick = function ()
              AchievementAPI.ActivateHolyArmorRequest(data.id, function()
                  data.states = 3
                  UpdateItemCell(cell, data)
                  UpdateLeftCan()
                  UpdateAttrList()
              end)
          end
      end,
      function()

      end
  )
end

local function OnEnter()
    AchievementAPI.GetHolyArmorsRequest(function(data)
        self.dataList = data or {}
        UpdateItemList()
        UpdateAttrList()
        UpdateLeftCan()
    end)
end

local function OnExit()

end

local ui_names = 
{
  
  {name = 'btn_close'},
  {name = 'btn_go'},

  {name = 'sp_list'},
  {name = 'cvs_get_single'},
  {name = 'sp_list1'},
  {name = 'cvs_get_single1'},
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)

  self.cvs_get_single.Visible = false
  self.cvs_get_single1.Visible = false

  self.btn_close.TouchClick = function ()
    self.menu:Close()
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITarget, -1)
  end

  self.btn_go.TouchClick = function ()
    self.menu:Close()
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITarget, -1)
  end
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/chapter/targetSuit.gui.xml", GlobalHooks.UITAG.GameUITargetSuit)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  self.menu.ShowType = UIShowType.HideBackHud

  InitCompnent()
  self.menu:SubscribOnEnter(OnEnter)
  self.menu:SubscribOnExit(OnExit)
  self.menu:SubscribOnDestory(function ()
    self = nil
  end)
  return self.menu
end

local function Create(params)
    self = {}
    setmetatable(self, _M)
    local node = Init(params)
    return self
end

return {Create = Create}
