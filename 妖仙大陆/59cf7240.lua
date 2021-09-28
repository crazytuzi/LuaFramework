local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"

local self = {
    menu = nil,
}

local function RefreshCellData(cell, data)
  
  local icon = cell:FindChildByEditName("ib_icon",true)
  Util.HZSetImage(icon,data.icon,false,LayoutStyle.IMAGE_STYLE_BACK_4)

  local nameLabel = cell:FindChildByEditName("lb_cross", true)
  nameLabel.Text = data.name

  local desLabel = cell:FindChildByEditName("lb_help", true)
  desLabel.Text = data.des

  local lvLimite = cell:FindChildByEditName("lb_lv",true)
  lvLimite.Text = Util.GetText(TextConfig.Type.ACHIEVEMENT, "funcLvLimite", data.LvLimit)

  local btn_go = cell:FindChildByEditName("btn_go",true)
  btn_go.TouchClick = function ()
    local lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
    if data.LvLimit > lv then
      GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ACHIEVEMENT,'needlv', data.LvLimit))
    else
      EventManager.Fire('Event.Goto', {id = data.FunId})
    end
  end
end

local function GetFuncList(index)
  local funcList = GlobalHooks.DB.Find("BeStr_Config", {type = index})
  table.sort(funcList,function (a,b)
      return a.id <= b.id
  end)
  return funcList
end

local function InitStrongerChildUI(index)
  local funcList = GetFuncList(index)
  self.sp_list1:Initialize(
          self.cvs_get_single.Width + 0, 
          self.cvs_get_single.Height + 0, 
          #funcList,
          1,
          self.cvs_get_single, 
          function(x, y, cell)
            local index = y + 1
            local data = funcList[index]
            RefreshCellData(cell, data)
          end,
          function() end)
end

local function SwitchPage(i, index)
  InitStrongerChildUI(index)

  if self.lastClassify then
    self.lastClassify.Enable = true
    self.lastClassify:FindChildByEditName("ib_click",true).Visible = false
  end
  self.lastClassify = self.classifyList[i]
  self.lastClassify.Enable = false
  self.lastClassify:FindChildByEditName("ib_click",true).Visible = true
end

function SetGropUpTargetFlag()
  
  if #self.classifyList > 0 then

    local node = self.classifyList[#self.classifyList]
    local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GROWUP_TARGET)
    node:FindChildByEditName("lb_bj_strong",true).Visible = num ~= 0
  end
end

local function OnEnter()
  local index = tonumber(self.menu.ExtParam)
  if index and index > 0 then
    SwitchPage(index, self.strongTypeList[index].id)
  else
    SwitchPage(1, self.strongTypeList[1].id)
  end
  
end

local function OnExit()

end

local function SortTypeList()
    table.sort(self.strongTypeList, function (aa,bb)
        if  aa.id < bb.id then
            return true
        end
        return false
    end)
end

local function initUI()
  self.strongTypeList = GlobalHooks.DB.Find("BeStr_List", {})
  SortTypeList()
  
  self.classifyList = {}
  self.cvs_equip_brief.Visible = false
  for i=1,#self.strongTypeList do
    local node = self.cvs_equip_brief:Clone()
    node.UserTag = self.strongTypeList[i].id
    node.Y = node.Y+(i-1)*node.Height
    node.Visible = true
    node.Enable = true
    node:FindChildByEditName("ib_click",true).Visible = false
    node:FindChildByEditName("lb_wenben",true).Text = self.strongTypeList[i].btnText
    node.TouchClick = function(sender)
        XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('zuobiaoqian')
        SwitchPage(i, sender.UserTag)
    end
    self.sp_list.Scrollable.Container:AddChild(node)
    table.insert(self.classifyList,node)
  end

  self.cvs_get_single.Visible = false

end

local ui_names = 
{
  
  {name = 'btn_close',click = function ()
    self.menu:Close()
  end},
  {name = 'sp_list'},
  {name = 'cvs_equip_brief'},
  {name = 'sp_list1'},
  {name = 'cvs_get_single'},
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/bestronger/stronger.gui.xml", GlobalHooks.UITAG.GameUIStrongerMain)
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

_M.SetGropUpTargetFlag = SetGropUpTargetFlag

return {Create = Create}
