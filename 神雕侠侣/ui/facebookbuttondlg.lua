require "ui.dialog"
require "utils.mhsdutils"
FacebookButtonDlg = {}
setmetatable(FacebookButtonDlg, Dialog)
FacebookButtonDlg.__index = FacebookButtonDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;

local function PlatformJudgement()
	
	if Config.MOBILE_ANDROID == 0 then
		if Config.CUR_3RD_PLATFORM == "efunios" then 
			return true
		else 
			return false
		end
	else
		local suffix = Config.CUR_3RD_LOGIN_SUFFIX
		if  suffix == "efad" or suffix == "tw36" then
		 	return true
		else 
			return false
		end
	end
end

function FacebookButtonDlg.getInstance()
	-- if Config.MOBILE_ANDROID == 0 then
	-- 	if Config.CUR_3RD_PLATFORM ~= "efunios" then return end
	-- else
	-- 	local suffix = self.m_loginSuffix
	-- 	if  suffix ~= "efad" or  then return end
	-- end

	if not PlatformJudgement() then 
		return 
	end

	print("enter getinstance")
    if not _instance then
        _instance = FacebookButtonDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function FacebookButtonDlg.WantShow()
	
	if _instance then
		_instance:SetVisible(true)
	end
end

function FacebookButtonDlg.WantHide()
	-- if Config.MOBILE_ANDROID == 0 then
	-- 	if Config.CUR_3RD_PLATFORM ~= "efunios" then return end
	-- else
	-- 	if Config.CUR_3RD_LOGIN_SUFFIX ~= "efad" then return end
	-- end

	if not PlatformJudgement() then 
		return 
	end

	if _instance then
		_instance:SetVisible(false)
	end
end

function FacebookButtonDlg.getInstanceAndShow()
	-- if Config.MOBILE_ANDROID == 0 then
	-- 	if Config.CUR_3RD_PLATFORM ~= "efunios" then return end
	-- else
	-- 	if Config.CUR_3RD_LOGIN_SUFFIX ~= "efad" then return end
	-- end

	if not PlatformJudgement() then 
		return 
	end


	print("enter instance show")
    if not _instance then
        _instance = FacebookButtonDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end
function FacebookButtonDlg.getInstanceNotCreate()
    return _instance
end

function FacebookButtonDlg.DestroyDialog()
	-- if Config.MOBILE_ANDROID == 0 then
	-- 	if Config.CUR_3RD_PLATFORM ~= "efunios" then return end
	-- else
	-- 	if Config.CUR_3RD_LOGIN_SUFFIX ~= "efad" then return end
	-- end

	if not PlatformJudgement() then 
		return 
	end

	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function FacebookButtonDlg.ToggleOpenClose()
	if not _instance then 
		_instance = FacebookButtonDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function FacebookButtonDlg.refreshEffect()
	LogInfo("FacebookButtonDlg refresh effect")
	if _instance and ActivityManager.getInstanceNotCreate() then
		if ActivityManager.getInstanceNotCreate():getNeedEffect() then
			if not _instance.m_effect then
				GetGameUIManager():AddUIEffect(_instance:GetWindow(), MHSD_UTILS.get_effectpath(10305))	
				_instance.m_effect = true 
			end
		else
			GetGameUIManager():RemoveUIEffect(_instance:GetWindow())
			_instance.m_effect = nil
		end
	end	

end


function FacebookButtonDlg.GetLayoutFileName()
    return "luntan.layout"
end

function tracedeb(event,line)
print("facebook debug",debug.getinfo(2).short_src .. line)

end

function FacebookButtonDlg:OnCreate()
	local pre = "fb"
    Dialog.OnCreate(self,nil,pre)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow(pre .. "luntan/btn"))	
    self.m_pBtn:subscribeEvent("Clicked", FacebookButtonDlg.HandleBtnClicked, self) 

    self.m_loginSuffix = Config.CUR_3RD_LOGIN_SUFFIX
debug.sethook(tracedub,"l")
end
------------------- private: -----------------------------------
function FacebookButtonDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FacebookButtonDlg)
	self.m_bIsVisibleBeforeBattle = false
    return self
end

function FacebookButtonDlg:StartBattle()
	self.m_bIsVisibleBeforeBattle = false
	if self:IsVisible() then
		self.m_bIsVisibleBeforeBattle = true
		self:SetVisible(false)
	end 
end

function FacebookButtonDlg:EndBattle()
	if self.m_bIsVisibleBeforeBattle then
		self.m_bIsVisibleBeforeBattle = false 
		self:SetVisible(true)
	end 
end

function FacebookButtonDlg:StartEnchou()
	self.m_bIsVisibleBeforeEnchou = false
	if self:IsVisible() then
		self.m_bIsVisibleBeforeEnchou = true
		self:SetVisible(false)
	end 
end

function FacebookButtonDlg:EndEnchou()
	if self.m_bIsVisibleBeforeEnchou then
		self.m_bIsVisibleBeforeEnchou = false 
		self:SetVisible(true)
	end 
end

FacebookButtonDlg.s_flagFacebookReqServiceID = 2

function FacebookButtonDlg:HandleBtnClicked(args)
	local p = require "protocoldef.knight.gsp.yuanbao.creqserverid" : new()
	p.flag = FacebookButtonDlg.s_flagFacebookReqServiceID
	LuaProtocolManager.getInstance():send(p)
end

function FacebookButtonDlg:GetServerIdHandler(args)
	require "luaj"
	local value = {}
	value[1] = args
	value[2] = GetDataManager():GetMainCharacterID()
    value[3] = GetDataManager():GetMainCharacterLevel()

    if Config.MOBILE_ANDROID == 0 then
		SDXL.ChannelManager:FacebookInvite(value[2],value[1])
	else
		local suffix = Config.CUR_3RD_LOGIN_SUFFIX
		if  suffix == "efad" then
			luaj.callStaticMethod("com.wanmei.mini.condor.efun.PlatformEFun", "facebookInvite", value, "(ILjava/lang/String;I)V")
		elseif suffix == "tw36" then
			luaj.callStaticMethod("com.wanmei.mini.condor.tw360.PlatformTw360", "facebookInvite", value, "(ILjava/lang/String;I)V")
		end
	end
end

return FacebookButtonDlg