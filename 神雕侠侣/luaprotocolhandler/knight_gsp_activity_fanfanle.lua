local sfanfanleinfo = require "protocoldef.knight.gsp.activity.fanfanle.sfanfanleinfo"
function sfanfanleinfo:process()
	local FFLMgr = require "ui.fanfanle.fanfanlemanager".getInstance()
	local FFLDlg = require "ui.fanfanle.fanfanledlg".getInstanceAndShow()
	FFLMgr:SetDataFromServer(self, nil, nil, nil)
	FFLDlg:RefreshAllView()
	FanfanleRewardDlg.DestroyDialog()
	if self.leftturnnum == 0 then
		local FFLRewardDlg = require "ui.fanfanle.fanfanlerewarddlg".getInstanceAndShow()
	end
	local FFLRewardDlg = require "ui.fanfanle.fanfanlerewarddlg"
end

local sdrawitem = require "protocoldef.knight.gsp.activity.fanfanle.sdrawitem"
function sdrawitem:process()
	local FFLMgr = require "ui.fanfanle.fanfanlemanager".getInstance()
	local FFLDlg = require "ui.fanfanle.fanfanledlg".getInstanceAndShow()
	FFLMgr:SetDataFromServer(nil, self ,nil, nil)
	FFLDlg:RefreshMainView()
	FFLDlg:RefreshTopView()
	if self.leftturnnum == 0 then
		FFLMgr:OpenGiftByTime()
	end
end

local supdatebox = require "protocoldef.knight.gsp.activity.fanfanle.supdatebox"
function supdatebox:process()
	local FFLMgr = require "ui.fanfanle.fanfanlemanager".getInstance()
	local FFLDlg = require "ui.fanfanle.fanfanledlg".getInstanceAndShow()
	FFLMgr:SetDataFromServer(nil, nil, self, nil)
	FFLDlg:RefreshTopView()
	FFLDlg:RefreshRightView()
end

local sfanfanlestate = require "protocoldef.knight.gsp.activity.fanfanle.sfanfanlestate"
function sfanfanlestate:process()
	local function ClickYes(self, args)
        GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
		local req = require "protocoldef.knight.gsp.activity.fanfanle.creqfanfanle".Create()
		LuaProtocolManager.getInstance():send(req)
    end

    local MHSD_UTILS = require "utils.mhsdutils"

	if self.remainfreenum > 0 then
		local msg = MHSD_UTILS.get_msgtipstring(145836)
		msg = string.gsub(msg,"%$parameter1%$",tostring(self.remainfreenum))
		GetMessageManager():AddConfirmBox(eConfirmNormal,msg,ClickYes,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
	elseif self.remainplaynum > 0 then
		local msg = MHSD_UTILS.get_msgtipstring(145837)
		msg = string.gsub(msg,"%$parameter1%$",tostring(self.costyuanbao))
		GetMessageManager():AddConfirmBox(eConfirmNormal,msg,ClickYes,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
	end
end

local sdrawaward = require "protocoldef.knight.gsp.activity.fanfanle.sdrawaward"
function sdrawaward:process()
	local FFLMgr = require "ui.fanfanle.fanfanlemanager".getInstance()
	local FFLDlg = require "ui.fanfanle.fanfanledlg".getInstanceAndShow()
	local FFLRewardDlg = require "ui.fanfanle.fanfanlerewarddlg"
	FanfanleRewardDlg.DestroyDialog()
	FFLMgr:SetDataFromServer(nil, nil, nil, self)
	FFLDlg:RefreshAllView()
end
