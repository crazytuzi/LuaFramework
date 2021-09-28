
local _M = {}
_M.__index = _M
local cjson = require "cjson" 
local Util       = require "Zeus.Logic.Util"
local ChatUtil   = require "Zeus.UI.Chat.ChatUtil"

local _M = {}

local DaoQunInfo = {}

function _M.ReqDaoqunInfo(cb)
  Pomelo.DaoYouHandler.daoYouRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      if param then
        DaoQunInfo = param
      end
      cb(DaoQunInfo)
    else
     
     
      cb(DaoQunInfo)
    end
  end)
end

function _M.GetDaoqunInfo()
  return DaoQunInfo
end

function _M.GetDaoqunAdinId()
  for i,v in ipairs(DaoQunInfo.dyInfo) do
    if v.isAdmin == 1 then
      return v.playerId
    end
  end
  return 0
end


function _M.InviteDaoYouRequest(id,cb)
  Pomelo.DaoYouHandler.daoYouInviteDaoYouRequest(id,function(ex,sjson)
    if not ex then
      cb()
    end
  end)
end


function _M.EditDaoqunNameRequest(string,cb)
  Pomelo.DaoYouHandler.daoYouEditTeamNameRequest(string,function(ex,sjson)
    if not ex then
      cb()
    end
  end)
end


function _M.KickMumberRequest(id,cb)
  Pomelo.DaoYouHandler.daoYouKickTeamRequest(id,function(ex,sjson)
    if not ex then
      cb()
    end
  end)
end


function _M.TransferAdminRequest(id,cb)
  Pomelo.DaoYouHandler.daoYouTransferAdminRequest(id,function(ex,sjson)
    if not ex then
      cb()
    end
  end)
end


function _M.LeaveDaoqunRequest(cb)
  Pomelo.DaoYouHandler.daoYouQuitTeamRequest(function(ex,sjson)
    if not ex then
      cb()
    end
  end)
end


function _M.ModifyNoticeRequest(s2c_notice, cb)
  Pomelo.DaoYouHandler.daoYouNoticeRequest(s2c_notice, function (ex,sjson)
    if not ex then
      cb()
    end
  end)
end


function _M.LeaveMessageRequest(s2c_msg, cb)
  Pomelo.DaoYouHandler.daoYouLeaveMessageRequest(s2c_msg, function (ex,sjson)
    if not ex then
      cb()
    end
  end)
end


function _M.RebateRequest(cb)
  Pomelo.DaoYouHandler.daoYouRebateRequest(function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      
      
      cb(param)
    end
  end)
end


function _M.QuickCreateTeamRequest(cb)
  Pomelo.DaoYouHandler.daoYouFastInviteDaoYouRequest(function (ex,sjson)
    if not ex then
      cb()
    end
  end)
end

function _M.GetChangeAllyStr(data)
    local str = Util.GetText(TextConfig.Type.DAOYOU, "AskChangeMaster")
    local sdata = {}
    sdata[1] = ChatUtil.GetNameXml(data.name, data.pro)
    return ChatUtil.HandleString(str, sdata)
end

function _M.GetKickedOutAllyStr(data)
    local str = Util.GetText(TextConfig.Type.DAOYOU, "AskIsKick")
    local sdata = {}
    sdata[1] = ChatUtil.GetNameXml(data.name, data.pro)
    return ChatUtil.HandleString(str, sdata)
end




function _M.InitNetWork()

end

return _M
