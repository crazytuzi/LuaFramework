local sweddinglist = require "protocoldef.knight.gsp.marry.sweddinglist"
function sweddinglist:process()
	require "ui.marry.weddinglistsdlg"
	LogInfo("sweddinglist process")
	local _instance = WeddingListsDlg.getInstanceAndShow()
	_instance:SetWeddingListsData(self.family)
end

local smarryappnotice = require "protocoldef.knight.gsp.marry.smarryappnotice"
function smarryappnotice:process()
	LogInfo("smarryappnotice process")

	local formatstr = MHSD_UTILS.get_resstring(3081)
	local sb = require "utils.stringbuilder":new()
	sb:Set("parameter1", self.person.name or " ")
	local msg = sb:GetString(formatstr)
    sb:delete()

	require "ui.marry.yesidodlg".getInstanceAndShow():SetTipMessage(msg)
end

local sdevoiceappdo = require "protocoldef.knight.gsp.marry.sdevoiceappdo"
function sdevoiceappdo:process()
	LogInfo("sdevoiceappdo process")

	local function acceptNotice()
		LogInfo("sdevoiceappdo process accept")
		GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
		require "protocoldef.knight.gsp.marry.cdevoicedo"
		local p = CDevoiceDo.Create()
		p.flag = 1
		require "manager.luaprotocolmanager":send(p)
	end
	local function rejectNotice()
		LogInfo("sdevoiceappdo process reject")
		GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
		require "protocoldef.knight.gsp.marry.cdevoicedo"
		local p = CDevoiceDo.Create()
		p.flag = 2
		require "manager.luaprotocolmanager":send(p)
	end
	
	local msg = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146134).msg
	GetMessageManager():AddConfirmBox(eConfirmNormal,
	msg,
	acceptNotice,
  	self,
  	rejectNotice,
  	CMessageManager)
end

local snoticesendinvitation = require "protocoldef.knight.gsp.marry.snoticesendinvitation"
function snoticesendinvitation:process()
	LogInfo("snoticesendinvitation process")

	if self.flag == 1 then
		--meiyouwupin goumai dingqingxinwu
		require "ui.marry.dingqingxinwudlg".getInstanceAndShow()
	elseif self.flag == 2 then
		--qingtie
		require "ui.marry.qingtiedlg".getInstanceAndShow():SetServiceId(self.serviceid, self.man, self.woman)
	elseif self.flag == 3 then
		--simple wedding start
	end
end

local sweddingbless = require "protocoldef.knight.gsp.marry.sweddingbless"
function sweddingbless:process()
	LogInfo("sweddingbless process")
	local _instance = require "ui.marry.weddingmiddlg".getInstanceNotCreate()
	if _instance ~= nil then
		_instance:AddZhufuItem({str=self.from .. ":" .. self.content, flag=self.flag})
		return
	end
end

local sbroadcastwedding = require "protocoldef.knight.gsp.marry.sbroadcastwedding"
function sbroadcastwedding:process()
  LogInfo("sbroadcastwedding process")
  local _instance = require "ui.marry.weddingmiddlg".getInstanceNotCreate()
  if _instance ~= nil then

    local msg = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cannounce"):getRecorder(self.messageid).announce
    local sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", self.teamleader)
    sb:Set("parameter2", self.other)
    local strmessage = sb:GetString(msg)
    sb:delete()
    
    --flag ==3 for system message
    _instance:AddZhufuItem({str=strmessage, flag=3})
    return
  end
end

local sinvitation = require "protocoldef.knight.gsp.marry.sinvitation"
function sinvitation:process()
	LogInfo("sinvitation process")
	require "ui.marry.invitationcardsmalldlg".getInstanceAndShow():SetMessage(self)
end

local snoticeweddingstatus = require "protocoldef.knight.gsp.marry.snoticeweddingstatus"
function snoticeweddingstatus:process()
	LogInfo("snoticeweddingstatus process")
	
	--wedding start
	if self.state == 1 then
	   --close add wedding dialog
	   if require"ui.marry.weddinglistsdlg".getInstanceNotCreate() then
	     require"ui.marry.weddinglistsdlg".DestroyDialog()
	   end
	  
	  --jingdian self.flag == 2
		local _instance = require "ui.marry.weddingmiddlg".getInstanceAndShow()
		_instance:SetLeftTime(self.lefttime, self.totaltime)
		_instance:SetMaster(self.master, self.flag==2, self.man, self.woman)
	--wedding end
	else
		local _instance = require "ui.marry.weddingmiddlg".getInstanceNotCreate()
		if _instance ~= nil then
			_instance.DestroyDialog()
		end
	end
end

local ssubzan = require "protocoldef.knight.gsp.marry.ssubzan"
function ssubzan:process()
	LogInfo("ssubzan process")
	local _instance = require "ui.marry.weddingmiddlg".getInstanceNotCreate()
	if _instance ~= nil then
		_instance:SetZanTimes(self.count)
		return
	end
end

local sredpackage = require "protocoldef.knight.gsp.marry.sredpackage"
function sredpackage:process()
	LogInfo("sredpackage process")
	local _instance = require "ui.marry.weddingmiddlg".getInstanceNotCreate()
	if _instance ~= nil then
		_instance:AddHongbaoItem({flag=self.flag, content=self.content})
		return
	end
end

local sgiftremove = require "protocoldef.knight.gsp.marry.sgiftremove"
function sgiftremove:process()
	LogInfo("sgiftremove process")
	local _instance = require "ui.marry.weddingmiddlg".getInstanceNotCreate()
	if _instance ~= nil then
		_instance:RemoveHongbaoItem({content=self.giftids})
		return
	end
end

local sfamilylist = require "protocoldef.knight.gsp.marry.sfamilylist"
function sfamilylist:process()
	LogInfo("sfamilylist process")
	require "ui.marry.weddingrank".getInstanceAndShow():SetRank(self)
end

local sleavewedding = require "protocoldef.knight.gsp.marry.sleavewedding"
function sleavewedding:process()
  LogInfo("sleavewedding process")
  local _instance = require "ui.marry.weddingmiddlg".getInstanceNotCreate()
  if _instance ~= nil then
    _instance.DestroyDialog()
  end
end

local ssubinvitation = require "protocoldef.knight.gsp.marry.ssubinvitation"
function ssubinvitation:process()
  LogInfo("ssubinvitation process")
  local _instance = require "ui.marry.qingtiedlg".getInstanceNotCreate()
  if _instance ~= nil then
    _instance.DestroyDialog()
  end
end

local ssendbless = require "protocoldef.knight.gsp.marry.ssendbless"
function ssendbless:process()
  LogInfo("ssendbless process")
  local _instance = require "ui.marry.blessdlg".getInstanceNotCreate()
  if _instance ~= nil then
    _instance.DestroyDialog()
  end
end

local snoticeweddingstage = require "protocoldef.knight.gsp.marry.snoticeweddingstage"
function snoticeweddingstage:process()
  LogInfo("snoticeweddingstage process")
  --just do nothing.
end

local sringinfo = require "protocoldef.knight.gsp.marry.sringinfo"
function sringinfo:process()
  LogInfo("sringinfo process")
  local _ins = require "ui.marry.jiezhidlg".getInstanceAndShow()
  if _ins then
    _ins:SetData(self)
  end
end

local ssynlefttime = require "protocoldef.knight.gsp.marry.ssynlefttime"
function ssynlefttime:process()
  LogInfo("ssynlefttime process")
  local _instance = require "ui.marry.weddingmiddlg".getInstanceNotCreate()
  if _instance then
    _instance:SetLeftTime(self.lefttime, self.totaltime)
  end
end

