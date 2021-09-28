

local _M = {}
_M.__index = _M

local AllMail = {}
local maxNum = 99

local function sortMail()
  if AllMail~=nil then
    table.sort(AllMail,function(a,b) return tonumber(a.createTime)>tonumber(b.createTime) end )
  end
end

local function OneKeyGet(msg)
  if msg~=nil then
    for i=1,#msg do
      for k,v in pairs(AllMail) do
        if msg[i] == v.id then
          if v.mailRead==2 then
            table.remove(AllMail,k)
          else
            AllMail[k].attachment = nil
            AllMail[k].status = 3
          end
        end
      end
    end
  end
end

local function DeleteMail(id)
  for k,v in pairs(AllMail) do
    if v.id == id then
      table.remove(AllMail,k)
      break
    end
  end
end

local function GetAttachment(id)
  for k,v in pairs(AllMail) do
    if id == v.id then
      if v.mailRead==2 then
        table.remove(AllMail,k)
        break
      else
        AllMail[k].attachment = nil
        v.status = 3
        break
      end
    end
  end
end

local function OneKeyDelete(msg)
  if msg~=nil then
    for i=1,#msg do
      for k,v in pairs(AllMail) do
        if msg[i] == v.id then
          table.remove(AllMail,k)
        end
      end
    end
  end
end

local function OneKeyDeleteForLocal()
  if AllMail~=nil then
    for i=#AllMail,1,-1 do
      local v = AllMail[i]
      if v.hadAttach==1 and v.mailRead==2 and v.status==2 then
        table.remove(AllMail,i)
      end
    end
    
      
    
  end
end

function _M.MailDeleteRequest(mailrede,c2s_id,cb)
  if mailrede==1 then
    Pomelo.MailHandler.mailReadNotify({c2s_id})
  	Pomelo.MailHandler.mailDeleteRequest(c2s_id,function (ex,sjson)
      if not ex then
        local msg = sjson:ToData()
        DeleteMail(c2s_id)
        
        cb()
      end
    end)
  else
    Pomelo.MailHandler.mailReadNotify({c2s_id})
    DeleteMail(c2s_id)
    cb()
  end
end

function _M.MailGetAttachmentRequest(c2s_mailId,cb)
	Pomelo.MailHandler.mailGetAttachmentRequest(c2s_mailId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      GetAttachment(c2s_mailId)
      cb()
    end
  end)
end

function _M.MailGetAllRequest(cb)
  Pomelo.MailHandler.mailGetAllRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      AllMail = msg.mails
      if msg.s2c_maxMailNum~=nil then
        maxNum = msg.s2c_maxMailNum
      end
      if AllMail ~= nil then
        sortMail()
        
      else
        AllMail = {}
      end
      cb()
    end
  end)
end

function _M.MailGetAttachmentOneKeyRequest(cb)
	Pomelo.MailHandler.mailGetAttachmentOneKeyRequest(function (ex,sjson)
    
    if not ex then
      local msg = sjson:ToData()
      
      OneKeyGet(msg.s2c_ids)
      cb()
      if msg.s2c_msg ~= "" then
        GameAlertManager.Instance:ShowFloatingTips(msg.s2c_msg)
      end
    end
  end)
end

function _M.MailDeleteOneKeyRequest(cb)
  Pomelo.MailHandler.mailDeleteOneKeyRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      OneKeyDelete(msg.s2c_ids)
      OneKeyDeleteForLocal()
      cb()
    end
  end)
end

function _M.MailSendMailRequest(toPlayerId,mailTitle,mailText,mailRead,toPlayerName,cb)
  Pomelo.MailHandler.mailSendMailRequest(toPlayerId,mailTitle,mailText,mailRead,toPlayerName,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb()
    end
  end)
end

local function readmailbefor(id)
  for k,v in pairs(AllMail) do
    if id == v.id then
      if v.status==1 then 
        v.status = 2
      end
      break
    end
  end
end

function _M.readMail(id,bl)
  if bl then
    Pomelo.MailHandler.mailReadNotify(id)
  
    readmailbefor(id)
  end
end

function _M.sendMail(id,type)
  Pomelo.MailHandler.mailSendTestNotify(tonumber(id),type)
end


function _M.GetAllMail()
  sortMail()
  return AllMail
end

function _M.GetMaxMailNum()
  return maxNum
end

local function PushMail(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    if AllMail==nil then
       AllMail[1] = msg.mails[1]
    else
      if AllMail[1] == nil then
        AllMail[1] = msg.mails[1]
      else
        AllMail[#AllMail+1] = msg.mails[1]
      end
    end
  end
end

function _M.InitNetWork()
  Pomelo.MailHandler.onGetMailPush(PushMail)
end

return _M
