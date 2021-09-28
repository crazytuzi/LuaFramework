local snotifyswornapp = require "protocoldef.knight.gsp.sworn.snotifyswornapp"
function snotifyswornapp:process()
  local strbuilder = StringBuilder:new()
  strbuilder:Set("parameter1", self.leader)
  local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(146220))
  strbuilder:delete()

  local function ClickYes(self, args)
      GetMessageManager():CloseCurrentShowMessageBox()
      local req = require"protocoldef.knight.gsp.sworn.cswornappdo".Create()
      req.flag = 1 --agree
      LuaProtocolManager.getInstance():send(req)
  end
  
  local function ClickNo(self, args)
    if CEGUI.toWindowEventArgs(args).handled ~= 1 then
      GetMessageManager():CloseCurrentShowMessageBox()
    end
    local req = require"protocoldef.knight.gsp.sworn.cswornappdo".Create()
    req.flag = 2 --reject
    LuaProtocolManager.getInstance():send(req)
  end

  GetMessageManager():AddMessageBox("",msg,ClickYes,self,ClickNo,self,eMessageNormal,30000,0,0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
end

local sswornappsign = require "protocoldef.knight.gsp.sworn.sswornappsign"
function sswornappsign:process()
  require "ui.jieyi.jieyijinlanpudlg".getInstanceAndShow()
end

local sswornsigndo = require "protocoldef.knight.gsp.sworn.sswornsigndo"
function sswornsigndo:process()
  local _ins = require "ui.jieyi.jieyijinlanpudlg".getInstanceNotCreate()
  if _ins ~= nil then
    _ins.DestroyDialog()
  end
end

local ssworntitlechange = require "protocoldef.knight.gsp.sworn.ssworntitlechange"
function ssworntitlechange:process()
  local _ins = require "ui.jieyi.jieyichenghaodlg".getInstanceAndShow()
  _ins:SetData(self.prename, self.spend)
end

local ssworntitledone = require "protocoldef.knight.gsp.sworn.ssworntitledone"
function ssworntitledone:process()
  local _ins = require "ui.jieyi.jieyichenghaodlg".getInstanceNotCreate()
  if _ins ~= nil then
    _ins.DestroyDialog()
  end
end

local sswornjoin = require "protocoldef.knight.gsp.sworn.sswornjoin"
function sswornjoin:process()
  local strbuilder = StringBuilder:new()
  strbuilder:Set("parameter1", self.members)
  local tips = MHSD_UTILS.get_msgtipstring(146246)
  if self.flag == 1 then
    tips = MHSD_UTILS.get_msgtipstring(146268)
  end
  
  local msg=strbuilder:GetString(tips)
  strbuilder:delete()

  local function ClickYes(self, args)
      GetMessageManager():CloseCurrentShowMessageBox()
      local req = require"protocoldef.knight.gsp.sworn.cswornjoin".Create()
      req.flag = 1 --agree
      LuaProtocolManager.getInstance():send(req)
  end
  
  local function ClickNo(self, args)
    if CEGUI.toWindowEventArgs(args).handled ~= 1 then
      GetMessageManager():CloseCurrentShowMessageBox()
    end
    local req = require"protocoldef.knight.gsp.sworn.cswornjoin".Create()
    req.flag = 2 --reject
    LuaProtocolManager.getInstance():send(req)
  end

  GetMessageManager():AddMessageBox("",msg,ClickYes,self,ClickNo,self,eMessageNormal,30000,0,0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
end

local ssworninfo = require "protocoldef.knight.gsp.sworn.ssworninfo"
function ssworninfo:process()
  local _ins = require "ui.jieyi.jieyiinfodlg".getInstanceNotCreate()
  if _ins ~= nil then
    _ins:SetData(self)
  end
end

local sswornkick = require "protocoldef.knight.gsp.sworn.sswornkick"
function sswornkick:process()
  local strbuilder = StringBuilder:new()
  strbuilder:Set("parameter1", tostring(self.spend))
  strbuilder:Set("parameter2", self.name)
  local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(146289))
  strbuilder:delete()

  local function ClickYes(self, args)
      GetMessageManager():CloseCurrentShowMessageBox()
      local req = require"protocoldef.knight.gsp.sworn.cswornkick".Create()
      req.flag = 1 --agree
      LuaProtocolManager.getInstance():send(req)
  end
  
  local function ClickNo(self, args)
    if CEGUI.toWindowEventArgs(args).handled ~= 1 then
      GetMessageManager():CloseCurrentShowMessageBox()
    end
    local req = require"protocoldef.knight.gsp.sworn.cswornkick".Create()
    req.flag = 2 --reject
    LuaProtocolManager.getInstance():send(req)
  end

  GetMessageManager():AddMessageBox("",msg,ClickYes,self,ClickNo,self,eMessageNormal,30000,0,0,nil,MHSD_UTILS.get_resstring(1554),MHSD_UTILS.get_resstring(1557))
end

local sswornformal = require "protocoldef.knight.gsp.sworn.sswornformal"
function sswornformal:process()
  local strbuilder = StringBuilder:new()
  strbuilder:Set("parameter1", tostring(self.spend))
  local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(146224))
  strbuilder:delete()

  local function ClickYes(self, args)
      GetMessageManager():CloseCurrentShowMessageBox()
      local req = require"protocoldef.knight.gsp.sworn.cswornformal".Create()
      req.flag = 1 --agree
      LuaProtocolManager.getInstance():send(req)
  end
  
  local function ClickNo(self, args)
    if CEGUI.toWindowEventArgs(args).handled ~= 1 then
      GetMessageManager():CloseCurrentShowMessageBox()
    end
    local req = require"protocoldef.knight.gsp.sworn.cswornformal".Create()
    req.flag = 2 --reject
    LuaProtocolManager.getInstance():send(req)
  end

  GetMessageManager():AddMessageBox("",msg,ClickYes,self,ClickNo,self,eMessageNormal,30000,0,0,nil,MHSD_UTILS.get_resstring(1554),MHSD_UTILS.get_resstring(1557))
end

local ssworncancledo = require "protocoldef.knight.gsp.sworn.ssworncancledo"
function ssworncancledo:process()
  local strbuilder = StringBuilder:new()
  strbuilder:Set("parameter1", tostring(self.spend))
  local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(146280))
  strbuilder:delete()

  local function ClickYes(self, args)
      GetMessageManager():CloseCurrentShowMessageBox()
      local req = require"protocoldef.knight.gsp.sworn.csworncancledo".Create()
      req.flag = 1 --agree
      LuaProtocolManager.getInstance():send(req)
  end
  
  local function ClickNo(self, args)
    if CEGUI.toWindowEventArgs(args).handled ~= 1 then
      GetMessageManager():CloseCurrentShowMessageBox()
    end
    local req = require"protocoldef.knight.gsp.sworn.csworncancledo".Create()
    req.flag = 2 --reject
    LuaProtocolManager.getInstance():send(req)
  end

  GetMessageManager():AddMessageBox("",msg,ClickYes,self,ClickNo,self,eMessageNormal,30000,0,0,nil,MHSD_UTILS.get_resstring(1554),MHSD_UTILS.get_resstring(1557))
end

local sswornformaljoin = require "protocoldef.knight.gsp.sworn.sswornformaljoin"
function sswornformaljoin:process()
  local strbuilder = StringBuilder:new()
  strbuilder:Set("parameter1", tostring(self.spend))
  local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(146224))
  strbuilder:delete()

  local function ClickYes(self, args)
      GetMessageManager():CloseCurrentShowMessageBox()
      local req = require"protocoldef.knight.gsp.sworn.cswornformaljoin".Create()
      req.flag = 1 --agree
      LuaProtocolManager.getInstance():send(req)
  end
  
  local function ClickNo(self, args)
    if CEGUI.toWindowEventArgs(args).handled ~= 1 then
      GetMessageManager():CloseCurrentShowMessageBox()
    end
    local req = require"protocoldef.knight.gsp.sworn.cswornformaljoin".Create()
    req.flag = 2 --reject
    LuaProtocolManager.getInstance():send(req)
  end

  GetMessageManager():AddMessageBox("",msg,ClickYes,self,ClickNo,self,eMessageNormal,30000,0,0,nil,MHSD_UTILS.get_resstring(1554),MHSD_UTILS.get_resstring(1557))
end

local sswornlooseappconfirm = require "protocoldef.knight.gsp.sworn.sswornlooseappconfirm"
function sswornlooseappconfirm:process()
  local msg=MHSD_UTILS.get_msgtipstring(146490)
  
  local function ClickYes(self, args)
      GetMessageManager():CloseCurrentShowMessageBox()
      local req = require"protocoldef.knight.gsp.sworn.cswornlooseappconfirmdo".Create()
      req.flag = 1 --agree
      LuaProtocolManager.getInstance():send(req)
  end
  
  local function ClickNo(self, args)
    if CEGUI.toWindowEventArgs(args).handled ~= 1 then
      GetMessageManager():CloseCurrentShowMessageBox()
    end
    local req = require"protocoldef.knight.gsp.sworn.cswornlooseappconfirmdo".Create()
    req.flag = 2 --reject
    LuaProtocolManager.getInstance():send(req)
  end

  GetMessageManager():AddMessageBox("",msg,ClickYes,self,ClickNo,self,eMessageNormal,30000,0,0,nil,MHSD_UTILS.get_resstring(1554),MHSD_UTILS.get_resstring(1557))
end

local ssworntitleconfirm = require "protocoldef.knight.gsp.sworn.ssworntitleconfirm"
function ssworntitleconfirm:process()
  local strbuilder = StringBuilder:new()
  strbuilder:Set("parameter1", tostring(self.newtitle))
  local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(146488))
  strbuilder:delete()
  
  local function ClickYes(self, args)
      GetMessageManager():CloseCurrentShowMessageBox()
      local req = require"protocoldef.knight.gsp.sworn.csworntitleconfirm".Create()
      req.flag = 1 --agree
      LuaProtocolManager.getInstance():send(req)
  end
  
  local function ClickNo(self, args)
    if CEGUI.toWindowEventArgs(args).handled ~= 1 then
      GetMessageManager():CloseCurrentShowMessageBox()
    end
    local req = require"protocoldef.knight.gsp.sworn.csworntitleconfirm".Create()
    req.flag = 2 --reject
    LuaProtocolManager.getInstance():send(req)
  end

  GetMessageManager():AddMessageBox("",msg,ClickYes,self,ClickNo,self,eMessageNormal,30000,0,0,nil,MHSD_UTILS.get_resstring(1554),MHSD_UTILS.get_resstring(1557))
end

