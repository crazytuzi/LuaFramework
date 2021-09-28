local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local DaoyouModel   = require "Zeus.Model.Daoyou"
local ChatUtil  = require "Zeus.UI.Chat.ChatUtil"


local self = {
    menu = nil,
}
local MaxLength = 20

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.DAOYOU, key)
end

function _M.setCall(callfuc)
   self.callfuc = callfuc
 end 

function _M.setParams(opType, str, callback)
  if opType == "notice" then
    self.lb_title.Text = GetTextConfg("notice")
    self.btn_publication.Text = GetTextConfg("comfirm")
    str = string.gsub(str,"<br/>","")
    str = string.gsub(str,"<b>","")
    str = string.gsub(str,"</b>","")
    self.ti_detail.Input.Text = str
  elseif opType == "message" then
    self.lb_title.Text = GetTextConfg("message")
    self.btn_publication.Text = GetTextConfg("send")
    self.ti_detail.Input.Text = ""
  end

  self.btn_publication.TouchClick = function ()
    if not self.nottextIsChange then
      self.menu:Close()
      return
    end
    if opType == "notice" then
      DaoyouModel.ModifyNoticeRequest(self.inputStr or "",function ()
        callback(self.inputStr)
        self.menu:Close()
      end)
    elseif opType == "message" then
        DaoyouModel.LeaveMessageRequest(self.inputStr or "",function ()
          callback(self.inputStr)
          self.menu:Close()
        end)
    end
  end
end

local function HandleTxtInputPrivate(displayNode, self)
    self.lb_click.Visible = false
    
    if self.ti_detail.Input.text == " " then
        self.m_StrInput = ChatUtil.HandleOriginalToInput(self.m_StrTmpOriginal)
        self.ti_detail.Input.text = self.m_StrInput

        if(self.m_htmlText ~= nil)then
            self.m_htmlText.Visible = false;
        end
    end
end

local function HandleInputChangeCallBack(displayNode, self)
    
  local msg = ChatUtil.HandleInputToOriginal(self.ti_detail.Input.text)
  local num = ChatUtil.HandleOriginalToInput(msg) 
  self.lb_tips2.Text = (MaxLength - string.utf8len(num))
  
  if tonumber(self.lb_tips2.Text) < 0 then
    self.lb_tips2.Text = 0
  end
end




local function OnEnter()
  
end

local function OnExit()
  self.nottextIsChange = false
end

local function initUI()
  self.ti_detail.Input.lineType = UnityEngine.UI.InputField.LineType.MultiLineNewline
  self.ti_detail.event_endEdit = function (sender,txt)
    if string.utf8len(txt) < 100 then
      self.inputStr = tostring(txt)
    else
      local text = Util.GetText(TextConfig.Type.GUILD, "guild_words_toolong")
      GameAlertManager.Instance:ShowNotify(text)
    end
    self.nottextIsChange = true
    self.ti_detail.Input.Text = self.inputStr or ""
  end

  self.ti_detail.Input.characterLimit = MaxLength
  self.ti_detail.InputTouchClick = function(displayNode)
     HandleTxtInputPrivate(displayNode, self)
  end
  self.ti_detail.event_ValueChanged = LuaUIBinding.InputValueChangedHandler(function(displayNode)
      HandleInputChangeCallBack(displayNode, self)
  end)
  self.lb_tips2.Text = MaxLength
end

local ui_names = 
{
  
  {name = 'lb_title'},
  {name = 'btn_publication'},
  {name = 'ti_detail'},
  {name = 'lb_tips2'},
  {name = 'lb_click'},
}

local function InitCompnent()
  local closebtn = self.menu:FindChildByEditName("btn_close",true)
  closebtn.TouchClick = function ()
    self.menu:Close()
  end
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/social/dao_message.gui.xml", GlobalHooks.UITAG.GameUISocialDaoqunNotice)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
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
