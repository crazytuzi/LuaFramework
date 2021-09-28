local _M = {}
_M.__index = _M

local self = {
  selected = nil,
}
local Util = require "Zeus.Logic.Util"
local SignRq = require"Zeus.Model.Sign"
local allSignMsg = {}
local ui_text = 
{
  sign_sign     = Util.GetText(TextConfig.Type.SIGN, 'sign_sign'),
  sign_luxury   = Util.GetText(TextConfig.Type.SIGN, 'sign_luxury'),
  sign_vipcomp  = Util.GetText(TextConfig.Type.SIGN, 'sign_vipcomp'),
  sign_allsignday  = Util.GetText(TextConfig.Type.SIGN, 'sign_allsignday'),
  sign_pay   = Util.GetText(TextConfig.Type.SIGN, 'sign_pay'),
  sign_get   = Util.GetText(TextConfig.Type.SIGN, 'sign_get'),
  sign_isget   = Util.GetText(TextConfig.Type.SIGN, 'sign_isget'),
  sign_issign   = Util.GetText(TextConfig.Type.SIGN, 'sign_issign'),
  sign_alldays   = Util.GetText(TextConfig.Type.SIGN, 'sign_alldays'),
  sign_daysaward   = Util.GetText(TextConfig.Type.SIGN, 'sign_daysaward'),
  sign_Alreadydays   = Util.GetText(TextConfig.Type.SIGN, 'sign_Alreadydays'),
}

local function ShowItemsTitle(items)
  local str = ""
  for k,v in pairs(items) do
    if k == 1 then
      str = str..v.name.."x"..v.groupCount
    else
      str = str.."\n"..v.name.."x"..v.groupCount
    end
  end
  local target = Vector2.New(320,280)
  GameAlertManager.Instance:ShowNotify(str)
end

local function update_pan_Right(x,y,node)
  local index = x+1
  node.UserTag = index
  local info = allSignMsg.cumulativeList
  local allsignday = node:FindChildByEditName("lb_days",true)
  allsignday.Text = string.format(ui_text.sign_alldays,info[index].needCountDay)

  if (#info[index].itemList) > 1 then
    local icon = node:FindChildByEditName("cvs_icon",true)
    local kuang = icon:FindChildByEditName("cvs_frame",true)
    local item = Util.ShowItemShow(kuang, info[index].boxIcon, 3, 1)
    local str = string.format(ui_text.sign_daysaward,info[index].needCountDay)
    icon.TouchClick = function ()
      local node,menu = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISignAwardBox,0,1) 
      menu.AwardBoxInfo(info[index].itemList,str)
    end
    node:FindChildByEditName("lb_num",true).Visible = false
  else
    local icon = node:FindChildByEditName("cvs_icon",true)
    local kuang = icon:FindChildByEditName("cvs_frame",true)
    local item = Util.ShowItemShow(kuang, info[index].itemList[1].icon, info[index].itemList[1].qColor, 1)
    icon.TouchClick = function ()
      EventManager.Fire("Event.ShowItemDetail",{ templateId = info[index].itemList[1].code })
    end
    local iconnum = node:FindChildByEditName("lb_num",true)
    iconnum.Text = info[index].itemList[1].groupCount
  end

  local isalreadyGet = node:FindChildByEditName("ib_get",true)
  isalreadyGet.Visible = info[index].state==2

  local redPoint = node:FindChildByEditName("lb_bj_active",false)
  redPoint.Visible = info[index].state==1

  local getbtn = node:FindChildByEditName("btn_receive",true)
  if info[index].state==2 then
    getbtn.Text = ui_text.sign_isget
    getbtn.IsGray = true
  else
    if info[index].state==0 then
      getbtn.Text = Util.GetText(TextConfig.Type.SIGN, "notsuccess")
      getbtn.IsGray = false
    end
    getbtn.TouchClick = function ()
      SignRq.GetCumulativeRewardRequest(info[index].id,function ()
        getbtn.Text = ui_text.sign_isget
        node:FindChildByEditName("ib_get",true).Visible = true
        node:FindChildByEditName("lb_bj_active",false).Visible = false
        getbtn.IsGray = true

        allSignMsg = SignRq.GetAllSignMsg()
        self.callback()
        
        local gainItemTab ={}
        for i=1,#info[index].itemList,1 do
            local code = info[index].itemList[i].code
            local num = info[index].itemList[i].groupCount
            gainItemTab[code] = num
        end
         Util.SendBIData("SignIn","","2","","",gainItemTab,"")
         
      end)
    end
  end

end

local function rushScroll()
  local liftscroll = self.menu:FindChildByEditName("sp_see",true)
  local cell = self.menu:FindChildByEditName("cvs_package",true)
  cell.Visible = false
  local num = #allSignMsg.cumulativeList
  liftscroll:Initialize(
      cell.Width, 
      cell.Height, 
      1,
      num,
      cell, 
      LuaUIBinding.HZScrollPanUpdateHandler(function (x, y, node)
        update_pan_Right(x, y, node)
      end
      ),
      LuaUIBinding.HZTrusteeshipChildInit(function (node)
        
      end)
    )
end

local function OnEnter()
  allSignMsg = SignRq.GetAllSignMsg()
  local allsignnum = self.menu:FindChildByEditName("tbh_accunmulate",true)
  allsignnum.XmlText = string.format(ui_text.sign_Alreadydays,allSignMsg.signedCount)
  rushScroll()
end

local function OnExit()
  self.callback()
end

local function InitCompnent()
  local closebtn = self.menu:FindChildByEditName("btn_close",true)
  closebtn.TouchClick = function ()
    self.menu:Close()
  end

  self.menu.mRoot.IsInteractive = true
  self.menu.mRoot.EnableChildren = true
  LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = function() self.menu:Close() end})
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/welfare/sign_accumulate.gui.xml", GlobalHooks.UITAG.GameUISignAward)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  self.menu:SubscribOnEnter(OnEnter)
  self.menu:SubscribOnExit(OnExit)
  self.menu:SubscribOnDestory(function ()
    self = nil
  end)

  InitCompnent()
  return self.menu
end

function _M.SetCallback(callback)
  self.callback = callback
end

local function Create(params)
  self = {}
  setmetatable(self, _M)
  local node = Init(params)
  return self
end

return {Create = Create}
