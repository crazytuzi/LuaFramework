g_shitu_flag = 0 --0 none  1 tudi  2shifu
local snotifymaster = require "protocoldef.knight.gsp.master.snotifymaster"
function snotifymaster:process()
  LogInfo("snotifymaster process")
  g_shitu_flag = self.flag
end

local sevaluate = require "protocoldef.knight.gsp.master.sevaluate"
function sevaluate:process()
  LogInfo("sevaluate process")
  
  --tudi dui shifu
  if self.flag == 1 then
    local _ins = require "ui.shitu.tudi2shifu".getInstanceAndShow()
    _ins:SetRoleID(self.roleid)
  --shifu dui tudi
  else
    local _ins = require "ui.shitu.shifu2tudi".getInstanceAndShow()
    _ins:SetRoleID(self.roleid)
  end
end

local snotifydismissmaster = require "protocoldef.knight.gsp.master.snotifydismissmaster"
function snotifydismissmaster:process()
  LogInfo("snotifydismissmaster process")
  require "ui.shitu.bashi".getInstanceAndShow()
end

local sdismissapprentces = require "protocoldef.knight.gsp.master.sdismissapprentces"
function sdismissapprentces:process()
  LogInfo("sdismissapprentces process")
  if self.prenticelist == nil or #self.prenticelist == 0 then
    return
  end

  require "ui.shitu.batu".getInstanceAndShow():SetData(self)
end

local sprenticeslist = require "protocoldef.knight.gsp.master.sprenticeslist"
function sprenticeslist:process()
  LogInfo("sprenticeslist process")
  
  local _ins = require "ui.shitu.shitulianxindlg".getInstanceNotCreate()
  if _ins then
    _ins:SetData(self)
  end
end

local stakeachivefresh = require "protocoldef.knight.gsp.master.stakeachivefresh"
function stakeachivefresh:process()
  LogInfo("stakeachivefresh process")
  
  local _ins = require "ui.shitu.shitulianxindlg".getInstanceNotCreate()
  if _ins then
    _ins:SetAchiveFresh(self)
  end
end

local snotifyappmaster = require "protocoldef.knight.gsp.master.snotifyappmaster"
function snotifyappmaster:process()
  LogInfo("snotifyappmaster process")
  
  local _ins = require "ui.shitu.baishiqueren".getInstanceAndShow()
  if _ins then
    _ins:SetData(self.mastername)
  end
end
