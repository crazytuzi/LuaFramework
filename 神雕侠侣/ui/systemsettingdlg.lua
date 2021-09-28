--[[
author: lvxiaolong
date:   2013/5/30
function: for system setting ui
]]
--[[
 youhua: huangjie
 data:  2013/7/13
]]

require "ui.dialog"
require "ui.contactservicedialog"
require "ui.settingmainframe"
--require "utils.mhsdutils"
--require "ui.minifriendchatdialog"
--require "ui.friendsdialog"


SystemSettingDlg = {}
setmetatable(SystemSettingDlg, Dialog)
SystemSettingDlg.__index = SystemSettingDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance
function SystemSettingDlg.peekInstance()
	return _instance
end


function SystemSettingDlg.getInstance()
	LogInfo("enter getSystemSettingDlginstance")
    if not _instance then
        _instance = SystemSettingDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SystemSettingDlg.getInstanceAndShow()
	LogInfo("enter instance show")
    if not _instance then
        _instance = SystemSettingDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set visible")
		_instance:SetVisible(true)
    end
     
    if not SettingMainFrame.peekInstance() then
        SettingMainFrame.getInstanceAndShow()
    end
    return _instance
end

function SystemSettingDlg:SetVisible(bV)
	if bV == self.m_pMainFrame:isVisible() then
        return
   end
	self.m_pMainFrame:setVisible(bV);
	if bV and not SettingMainFrame.peekInstance() then
		SettingMainFrame.getInstanceAndShow()	
	end
end
function SystemSettingDlg.getInstanceNotCreate()
    return _instance
end

function SystemSettingDlg.DestroyDialog()
	LogInfo("_______SystemSettingDlg.DestroyDialog")
    if _instance then
		_instance:OnClose()
		_instance = nil
	end
    if SettingMainFrame:peekInstance() then
		SettingMainFrame.DestroyDialog()
	end
end

function SystemSettingDlg.hasCreatedAndShow()
    --LogInfo("SystemSettingDlg.hasCreatedAndShow?")
    
    if _instance then
        if _instance:IsVisible() then
            return 1
        else
            return 0
        end
    else
        return 0
    end
end

function SystemSettingDlg.ToggleOpenClose()
	if not _instance then 
		_instance = SystemSettingDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
----/////////////////////////////////////////------

function SystemSettingDlg.GetLayoutFileName()
    return "SystemSetting.layout"
end

function SystemSettingDlg:new()
    LogInfo("enter SystemSettingDlg:new")
    
    local self = {}
    self = Dialog:new()
    setmetatable(self, SystemSettingDlg)

    self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1

    return self
end

function SystemSettingDlg:btnInit(num, t)
    local winMgr = CEGUI.WindowManager:getSingleton()
	local i
	if num == 3 then
		winMgr:getWindow("SystemSetting/btns3"):setVisible(true)
		winMgr:getWindow("SystemSetting/btns4"):setVisible(false)
		winMgr:getWindow("SystemSetting/btns5"):setVisible(false)
		winMgr:getWindow("SystemSetting/btns6"):setVisible(false)
		self.m_btn31 = winMgr:getWindow("SystemSetting/btn31")
		self.m_btn32 = winMgr:getWindow("SystemSetting/btn32")
		self.m_btn33 = winMgr:getWindow("SystemSetting/btn33")
		self.m_btn31:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn1Clicked, self)
		self.m_btn32:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn2Clicked, self)
		self.m_btn33:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn3Clicked, self)
		self.m_btn31:setText(t[1])
		self.m_btn32:setText(t[2])
		self.m_btn33:setText(t[3])
	end

	if num == 4 then
		winMgr:getWindow("SystemSetting/btns3"):setVisible(false)
		winMgr:getWindow("SystemSetting/btns4"):setVisible(true)
		winMgr:getWindow("SystemSetting/btns5"):setVisible(false)
		winMgr:getWindow("SystemSetting/btns6"):setVisible(false)
		self.m_btn41 = winMgr:getWindow("SystemSetting/btn41")
		self.m_btn42 = winMgr:getWindow("SystemSetting/btn42")
		self.m_btn43 = winMgr:getWindow("SystemSetting/btn43")
		self.m_btn44 = winMgr:getWindow("SystemSetting/btn44")
		self.m_btn41:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn1Clicked, self)
		self.m_btn42:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn2Clicked, self)
		self.m_btn43:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn3Clicked, self)
		self.m_btn44:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn4Clicked, self)
		self.m_btn41:setText(t[1])
		self.m_btn42:setText(t[2])
		self.m_btn43:setText(t[3])
		self.m_btn44:setText(t[4])
	end

	if num == 5 then
		winMgr:getWindow("SystemSetting/btns3"):setVisible(false)
		winMgr:getWindow("SystemSetting/btns4"):setVisible(false)
		winMgr:getWindow("SystemSetting/btns5"):setVisible(true)
		winMgr:getWindow("SystemSetting/btns6"):setVisible(false)
		self.m_btn51 = winMgr:getWindow("SystemSetting/btn51")
		self.m_btn52 = winMgr:getWindow("SystemSetting/btn52")
		self.m_btn53 = winMgr:getWindow("SystemSetting/btn53")
		self.m_btn54 = winMgr:getWindow("SystemSetting/btn54")
		self.m_btn55 = winMgr:getWindow("SystemSetting/btn55")
		self.m_btn51:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn1Clicked, self)
		self.m_btn52:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn2Clicked, self)
		self.m_btn53:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn3Clicked, self)
		self.m_btn54:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn4Clicked, self)
		self.m_btn55:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn5Clicked, self)
		self.m_btn51:setText(t[1])
		self.m_btn52:setText(t[2])
		self.m_btn53:setText(t[3])
		self.m_btn54:setText(t[4])
		self.m_btn55:setText(t[5])
	end

	if num == 6 then
		winMgr:getWindow("SystemSetting/btns3"):setVisible(false)
		winMgr:getWindow("SystemSetting/btns4"):setVisible(false)
		winMgr:getWindow("SystemSetting/btns5"):setVisible(false)
		winMgr:getWindow("SystemSetting/btns6"):setVisible(true)
		self.m_btn61 = winMgr:getWindow("SystemSetting/btn61")
		self.m_btn62 = winMgr:getWindow("SystemSetting/btn62")
		self.m_btn63 = winMgr:getWindow("SystemSetting/btn63")
		self.m_btn64 = winMgr:getWindow("SystemSetting/btn64")
		self.m_btn65 = winMgr:getWindow("SystemSetting/btn65")
		self.m_btn66 = winMgr:getWindow("SystemSetting/btn66")
		self.m_btn61:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn1Clicked, self)
		self.m_btn62:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn2Clicked, self)
		self.m_btn63:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn3Clicked, self)
		self.m_btn64:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn4Clicked, self)
		self.m_btn65:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn5Clicked, self)
		self.m_btn66:subscribeEvent("Clicked", SystemSettingDlg.HandleBtn6Clicked, self)
		self.m_btn61:setText(t[1])
		self.m_btn62:setText(t[2])
		self.m_btn63:setText(t[3])
		self.m_btn64:setText(t[4])
		self.m_btn65:setText(t[5])
		self.m_btn66:setText(t[6])
	end
end

function SystemSettingDlg:HandleBtn1Clicked(args)
	LogInfo("SystemSettingDlg:HandleBtn1Clicked")
	if Config.TRD_PLATFORM == 1 then
	    if Config.MOBILE_ANDROID ~= 0 then
	        return self:AndroidHandleClick(1)
	    end
    
		if Config.CUR_3RD_PLATFORM == "91" then
			--进入91社区
			SDXL.ChannelManager:EnterPlatformCenter()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "pp" then
			--联系客服
			ContactServiceDialog.getInstance()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "app" then
			--联系客服
			ContactServiceDialog.getInstance()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "feiliukuaiyong" then
			--切换帐号
			GetNetConnection():send(knight.gsp.CReturnToLogin())
			return true
		end
		if Config.CUR_3RD_PLATFORM == "feiliu" then
			--切换帐号
			GetNetConnection():send(knight.gsp.CReturnToLogin())
			return true
		end
		if Config.CUR_3RD_PLATFORM == "tiger" then
			--用户中心
			SDXL.ChannelManager:EnterPlatformCenter()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "ysuc" then
			--用户中心
			SDXL.ChannelManager:EnterPlatformCenter()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "downjoy" then
			--用户中心
			SDXL.ChannelManager:EnterPlatformCenter()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "tbt" then
			--用户中心
			SDXL.ChannelManager:EnterPlatformCenter()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "efunios" then
			--切换帐号
			GetNetConnection():send(knight.gsp.CReturnToLogin())
			return true
		end
		if Config.CUR_3RD_LOGIN_SUFFIX == "lawp" then
			--进入论坛
			if SDXL.ChannelManager:HasPlatformForum() == 1 then
				SDXL.ChannelManager:EnterBBS()
			else
				GetGameUIManager():AddMessageTipById(146516);
			end
			return true
		end
		if Config.CUR_3RD_PLATFORM == "itools" then
			--用户中心
			SDXL.ChannelManager:EnterPlatformCenter()
			return true
		end
        if Config.CUR_3RD_PLATFORM == "kris" then
			--用户中心
			SDXL.ChannelManager:EnterPlatformCenter()
			return true
		end
        if Config.CUR_3RD_PLATFORM == "this" then
            --切换帐号
			GetNetConnection():send(knight.gsp.CReturnToLogin())
			return true
        end
	else
		--进入官网
	end
end

function SystemSettingDlg:HandleBtn2Clicked(args)
	LogInfo("SystemSettingDlg:HandleBtn2Clicked")
	if Config.TRD_PLATFORM == 1 then
	    if Config.MOBILE_ANDROID ~= 0 then
	        return self:AndroidHandleClick(2)
	    end
    
		if Config.CUR_3RD_PLATFORM == "91" then
			--进入论坛
			SDXL.ChannelManager:EnterBBS()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "pp" then
			--进入PP中心
			SDXL.ChannelManager:EnterPlatformCenter()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "app" then
			--恢复默认值
			GetGameConfigManager():SetForDefaultConfig()
			self:Init()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "feiliukuaiyong" then
			--帐号管理
			SDXL.ChannelManager:EnterPlatformCenter()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "feiliu" then
			--进入论坛
			SDXL.ChannelManager:EnterBBS()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "tiger" then
			--进入客服
			ContactServiceDialog.getInstanceAndShow()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "ysuc" then
			--切换账号
			GetNetConnection():send(knight.gsp.CReturnToLogin())
			return true
		end
		if Config.CUR_3RD_PLATFORM == "downjoy" then
			--恢复默认值
			GetGameConfigManager():SetForDefaultConfig()
			self:Init()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "tbt" then
			--恢复默认值
			GetGameConfigManager():SetForDefaultConfig()
			self:Init()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "efunios" then
			--联系客服
			ContactServiceDialog.getInstance()
			return true
		end
		if Config.CUR_3RD_LOGIN_SUFFIX == "lawp" then
			--用户中心
			SDXL.ChannelManager:EnterPlatformCenter()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "itools" then
			--切换帐号
			GetNetConnection():send(knight.gsp.CReturnToLogin())
			return true
		end
        if Config.CUR_3RD_PLATFORM == "kris" then
			--切换帐号
			GetNetConnection():send(knight.gsp.CReturnToLogin())
			return true
		end
        if Config.CUR_3RD_PLATFORM == "this" then
            --恢复默认值
			GetGameConfigManager():SetForDefaultConfig()
			self:Init()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
        end
	else
		--进入论坛
	end
end

function SystemSettingDlg:HandleBtn3Clicked(args)
	LogInfo("SystemSettingDlg:HandleBtn3Clicked")
	if Config.TRD_PLATFORM == 1 then
	    if Config.MOBILE_ANDROID ~= 0 then
	        return self:AndroidHandleClick(3)
	    end
    
		if Config.CUR_3RD_PLATFORM == "91" then
			--联系客服
			ContactServiceDialog.getInstance()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "pp" then
			--切换帐号
			GetNetConnection():send(knight.gsp.CReturnToLogin())
			return true
		end
		if Config.CUR_3RD_PLATFORM == "app" then
			--保存设置
			self:ApplyConfig()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "ysuc" then
			--恢复默认值
			GetGameConfigManager():SetForDefaultConfig()
			self:Init()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "feiliukuaiyong" then
			--联系客服
			SDXL.ChannelManager:UserFeedBack()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "feiliu" then
			--帐号管理
			SDXL.ChannelManager:EnterPlatformCenter()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "downjoy" then
			--保存设置
			self:ApplyConfig()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true	
		end
		if Config.CUR_3RD_PLATFORM == "tiger" then
			--FAQ
			SDXL.ChannelManager:EnterGameHelp("http://sdxl.laohu.com/faq/")
			return true
		end
		if Config.CUR_3RD_PLATFORM == "tbt" then
			--保存设置
			self:ApplyConfig()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "efunios" then
			--恢复默认值
			GetGameConfigManager():SetForDefaultConfig()
			self:Init()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_LOGIN_SUFFIX == "lawp" then
			--切换帐号
			GetNetConnection():send(knight.gsp.CReturnToLogin())
			return true
		end
		if Config.CUR_3RD_PLATFORM == "itools" then
			--恢复默认值
			GetGameConfigManager():SetForDefaultConfig()
			self:Init()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
        if Config.CUR_3RD_PLATFORM == "kris" then
			--联系客服
			SDXL.ChannelManager:EnterCustomerService()
			return true
		end
        if Config.CUR_3RD_PLATFORM == "this" then
			--保存设置
			self:ApplyConfig()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
	else
		--切换帐号
		GetNetConnection():send(knight.gsp.CReturnToLogin())
		return true
	end
end

function SystemSettingDlg:HandleBtn4Clicked(args)
	LogInfo("SystemSettingDlg:HandleBtn4Clicked")
	if Config.TRD_PLATFORM == 1 then
	    if Config.MOBILE_ANDROID ~= 0 then
	        return self:AndroidHandleClick(4)
	    end
    
		if Config.CUR_3RD_PLATFORM == "91" then
			--切换帐号
			GetNetConnection():send(knight.gsp.CReturnToLogin())
			return true
		end
		if Config.CUR_3RD_PLATFORM == "pp" then
			--恢复默认值
			GetGameConfigManager():SetForDefaultConfig()
			self:Init()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "ysuc" then
			--保存设置
			self:ApplyConfig()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true	
		end
		if Config.CUR_3RD_PLATFORM == "feiliukuaiyong" then
			--恢复默认值
			GetGameConfigManager():SetForDefaultConfig()
			self:Init()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "feiliu" then
			--联系客服
			SDXL.ChannelManager:UserFeedBack()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "tiger" then
			--切换账号
			GetNetConnection():send(knight.gsp.CReturnToLogin())
			return true
		end
		if Config.CUR_3RD_PLATFORM == "efunios" then
			--保存设置
			self:ApplyConfig()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_LOGIN_SUFFIX == "lawp" then
			--恢复默认值
			GetGameConfigManager():SetForDefaultConfig()
			self:Init()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "itools" then
			--保存设置
			self:ApplyConfig()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
	else
		--恢复默认值
		GetGameConfigManager():SetForDefaultConfig()
		self:Init()
		GetGameConfigManager():ApplyConfig()
		GetGameConfigManager():SaveConfig()
		return true
	end
end

function SystemSettingDlg:HandleBtn5Clicked(args)
	LogInfo("SystemSettingDlg:HandleBtn5Clicked")
	if Config.TRD_PLATFORM == 1 then
	    if Config.MOBILE_ANDROID ~= 0 then
	        return self:AndroidHandleClick(5)
	    end
    
		if Config.CUR_3RD_PLATFORM == "91" then
			--用户反馈
			SDXL.ChannelManager:UserFeedBack()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "pp" then
			--保存设置
			self:ApplyConfig()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "feiliukuaiyong" then
			--保存设置
			self:ApplyConfig()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "feiliu" then
			--恢复默认值
			GetGameConfigManager():SetForDefaultConfig()
			self:Init()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "tiger" then
			--恢复默认值
			GetGameConfigManager():SetForDefaultConfig()
			self:Init()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_LOGIN_SUFFIX == "lawp" then
			--保存设置
			self:ApplyConfig()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
	else
		--保存设置
		self:ApplyConfig()
		GetGameConfigManager():ApplyConfig()
		GetGameConfigManager():SaveConfig()
		return true
	end
end

function SystemSettingDlg:HandleBtn6Clicked(args)
	LogInfo("SystemSettingDlg:HandleBtn6Clicked")
	if Config.TRD_PLATFORM == 1 then
	    if Config.MOBILE_ANDROID ~= 0 then
	        return self:AndroidHandleClick(6)
	    end
    
		if Config.CUR_3RD_PLATFORM == "91" then
			--保存设置
			self:ApplyConfig()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
		if Config.CUR_3RD_PLATFORM == "tiger" then
			--保存设置
			self:ApplyConfig()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true	
		end
		if Config.CUR_3RD_PLATFORM == "feiliu" then
			--保存设置
			self:ApplyConfig()
			GetGameConfigManager():ApplyConfig()
			GetGameConfigManager():SaveConfig()
			return true
		end
	end
end

function SystemSettingDlg:OnCreate()
	LogInfo("enter SystemSettingDlg oncreate")
    Dialog.OnCreate(self)

    self:GetWindow():setModalState(true)
    
    if Config.TRD_PLATFORM == 1 then
    
        if Config.MOBILE_ANDROID ~= 0 then
            self:AndroidInit()
        else

            if Config.CUR_3RD_PLATFORM == "91" then

                --91----    
                local strings = {
                    MHSD_UTILS.get_resstring(2852),
                    MHSD_UTILS.get_resstring(2853),
                    MHSD_UTILS.get_resstring(2854),
                    MHSD_UTILS.get_resstring(2855),
                    MHSD_UTILS.get_resstring(2856),
                    MHSD_UTILS.get_resstring(2857)
                }
                SystemSettingDlg:btnInit(6, strings)
            end

            if Config.CUR_3RD_PLATFORM == "pp" then

                --pp
                local strings = {
                    MHSD_UTILS.get_resstring(2858),
                    MHSD_UTILS.get_resstring(2859),
                    MHSD_UTILS.get_resstring(2860),
                    MHSD_UTILS.get_resstring(2861),
                    MHSD_UTILS.get_resstring(2862)
                }
                SystemSettingDlg:btnInit(5, strings)
            end
            if Config.CUR_3RD_PLATFORM == "app" then

                --app
                local strings = {
                    MHSD_UTILS.get_resstring(2868),
                    MHSD_UTILS.get_resstring(2869),
                    MHSD_UTILS.get_resstring(2870)
                }
                SystemSettingDlg:btnInit(3, strings)
            end
            if Config.CUR_3RD_PLATFORM == "feiliukuaiyong" then
                --feiliu
                local strings = {
                    MHSD_UTILS.get_resstring(2896),
                    MHSD_UTILS.get_resstring(2871),
                    MHSD_UTILS.get_resstring(2872),
                    MHSD_UTILS.get_resstring(2873),
                    MHSD_UTILS.get_resstring(2874)
                }
                SystemSettingDlg:btnInit(5, strings)
            end
            if Config.CUR_3RD_PLATFORM == "feiliu" then
                --feiliu
                local strings = {
                    MHSD_UTILS.get_resstring(2896),
                    MHSD_UTILS.get_resstring(2853),
                    MHSD_UTILS.get_resstring(2871),
                    MHSD_UTILS.get_resstring(2872),
                    MHSD_UTILS.get_resstring(2873),
                    MHSD_UTILS.get_resstring(2874)
                }
                SystemSettingDlg:btnInit(6, strings)
            end
			if Config.CUR_3RD_PLATFORM == "tiger" then
				--Tiger
				local strings = {
					MHSD_UTILS.get_resstring(2891),
					MHSD_UTILS.get_resstring(3005),
					MHSD_UTILS.get_resstring(3006),
					MHSD_UTILS.get_resstring(2893),
					MHSD_UTILS.get_resstring(2894),
					MHSD_UTILS.get_resstring(2895)
				}
				SystemSettingDlg:btnInit(6, strings)
			end
			if Config.CUR_3RD_PLATFORM == "ysuc" then
				--UC
				local strings = {
					MHSD_UTILS.get_resstring(2891),
					MHSD_UTILS.get_resstring(2893),
					MHSD_UTILS.get_resstring(2894),
					MHSD_UTILS.get_resstring(2895)
				}
				SystemSettingDlg:btnInit(4, strings)
			end
			if Config.CUR_3RD_PLATFORM == "downjoy" then
				--DownJoy
				local strings = {
					MHSD_UTILS.get_resstring(2891),
					MHSD_UTILS.get_resstring(2894),
					MHSD_UTILS.get_resstring(2895)
				}
				SystemSettingDlg:btnInit(3, strings)
			end
			if Config.CUR_3RD_PLATFORM == "tbt" then
				--tbt
				local strings = {
					MHSD_UTILS.get_resstring(2891),
					MHSD_UTILS.get_resstring(2894),
					MHSD_UTILS.get_resstring(2895)
				}
				SystemSettingDlg:btnInit(3, strings)
			end
            if Config.CUR_3RD_PLATFORM == "efunios" then

                --efunios
                local strings = {
                    MHSD_UTILS.get_resstring(2987),
                    MHSD_UTILS.get_resstring(2988),
                    MHSD_UTILS.get_resstring(2989),
                    MHSD_UTILS.get_resstring(2990)
                }
                SystemSettingDlg:btnInit(4, strings)
            end
			if Config.CUR_3RD_LOGIN_SUFFIX == "lawp" then

                --lawp
                local strings = {
					MHSD_UTILS.get_resstring(2853),
                	MHSD_UTILS.get_resstring(2891),
                    MHSD_UTILS.get_resstring(2987),
                    MHSD_UTILS.get_resstring(2989),
                    MHSD_UTILS.get_resstring(2990)
                }
                SystemSettingDlg:btnInit(5, strings)
            end
            if Config.CUR_3RD_PLATFORM == "itools" then

                --itools
                local strings = {
                	MHSD_UTILS.get_resstring(2891),
                    MHSD_UTILS.get_resstring(2987),
                    MHSD_UTILS.get_resstring(2989),
                    MHSD_UTILS.get_resstring(2990)
                }
                SystemSettingDlg:btnInit(4, strings)
            end
            
            if Config.CUR_3RD_PLATFORM == "kris" then
                --kris
                local strings = {
                	MHSD_UTILS.get_resstring(2891),
                    MHSD_UTILS.get_resstring(2987),
                    MHSD_UTILS.get_resstring(2988),
                    MHSD_UTILS.get_resstring(2989),
                    MHSD_UTILS.get_resstring(2990)
                }
                SystemSettingDlg:btnInit(5, strings)
            end
            if Config.CUR_3RD_PLATFORM == "this" then
                --this
                local strings = {
                	MHSD_UTILS.get_resstring(2987),
					MHSD_UTILS.get_resstring(2894),
					MHSD_UTILS.get_resstring(2895)
                }
                SystemSettingDlg:btnInit(3, strings)
            end

        end
    else --not third platform
        -- pwrd----
        local strings = {
            MHSD_UTILS.get_resstring(2863),
            MHSD_UTILS.get_resstring(2864),
            MHSD_UTILS.get_resstring(2865),
            MHSD_UTILS.get_resstring(2866),
            MHSD_UTILS.get_resstring(2867)
        }
        SystemSettingDlg:btnInit(5, strings)
    end --not third platform
    
    self:Init()
	
	LogInfo("exit SystemSettingDlg OnCreate")
end

function SystemSettingDlg:Init()
    --std::vector<int> allIDs
    --knight::gsp::SystemSetting::GetCGameconfigTableInstance().getAllID(allIDs)
    
    local id
    for id = 1,10 do
        local record = knight.gsp.SystemSetting.GetCGameconfigTableInstance():getRecorder(id)
        if (record.id ~= -1) then
            local strKey = record.key
            value = GetGameConfigManager():GetConfigValue(strKey)
            if value ~= -1 then
                local winMgr = CEGUI.WindowManager:getSingleton()
                if record.leixingtype == 0 then
                    local pBox = CEGUI.toCheckbox(winMgr:getWindow(record.wndname))
                    if pBox ~= nil then
                       if value == 0 then
                        pBox:setSelected(false)
                       else
                        pBox:setSelected(true)
                       end
                    end
                elseif record.leixingtype == 1 then
                    local pBar = CEGUI.toScrollbar(winMgr:getWindow(record.wndname))
                    if pBar ~= nil then
                        local totalHeight = pBar:getDocumentSize()
                        pBar:setScrollPosition( (value/255.0) * totalHeight )
                        pBar:EnbalePanGuesture(false)
                    end
                end
            end
        end
    end
end

function SystemSettingDlg.GetGameFunctionSetting( key )
    LogInfo("SystemSettingDlg.GetGameFunctionSetting")
    return 0
end

function SystemSettingDlg.SetGameFunctionSetting(key, val)
    LogInfo("SystemSettingDlg.SetGameFunctionSetting")
end

function SystemSettingDlg:ApplyConfig()
    LogInfo("SystemSettingDlg:ApplyConfig")

    for id = 1, 10 do
        local record=knight.gsp.SystemSetting.GetCGameconfigTableInstance():getRecorder(id)
        if record.id ~= -1 then
            local strKey = record.key
            local value = GetGameConfigManager():GetConfigValue(strKey)
            if value ~=-1 then
                local winMgr = CEGUI.WindowManager:getSingleton()
                -- special for PVP state
                -- it need send to sever
                -- id = 6
                if record.id == 6 then
            	    local winMgr = CEGUI.WindowManager:getSingleton()
            	    local pBox = CEGUI.toCheckbox(winMgr:getWindow(record.wndname))
            	    if pBox ~= nil then
                        local bSelect=pBox:isSelected()
                        local saveValue = 0
                        if bSelect == true then
                            saveValue = 1
                        end
                        local req = require "protocoldef.knight.gsp.csyssettings".Create()
                        req.syssettings[6] = saveValue
                        LuaProtocolManager.getInstance():send(req)
                        GetGameConfigManager():SetConfigValue(strKey, saveValue)
                    end
                -- end of the special
                elseif record.leixingtype == 0 then
                    local pBox = CEGUI.toCheckbox(winMgr:getWindow(record.wndname))
                    if pBox ~= nil then
                        local bSelect=pBox:isSelected()
                        local saveValue = 0
                        if bSelect == true then
                            saveValue = 1
                        end
                        GetGameConfigManager():SetConfigValue(strKey, saveValue)
                    end
                elseif record.leixingtype == 1 then
                    local pBar = CEGUI.toScrollbar(winMgr:getWindow(record.wndname))
                    if pBar ~= nil then
                        local totalHeight = pBar:getDocumentSize()
                        local curPos = pBar:getScrollPosition()
                        local saveValue = math.floor(255.0 * curPos/totalHeight)
                        if saveValue<0 or saveValue>255 then
                            saveValue=128
                        end
                        GetGameConfigManager():SetConfigValue(strKey, saveValue)
                    end
                end
            end
        end
    end
end

----------Android functions
local AndroidButtonType_Forum = 1
local AndroidButtonType_UserCenter = 2
local AndroidButtonType_UserFeedback = 3
local AndroidButtonType_SwitchAccount = 4
local AndroidButtonType_RestoreConfig = 5
local AndroidButtonType_SaveConfig = 6
local AndroidButtonType_LianXiKeFu = 7
local AndroidButtonType_MoreGames = 8
local AndroidButtonType_FAQ = 9

function SystemSettingDlg:AndroidInit()
    local buttonTexts = { "", "", "", "", "", "" }
    local buttonIndex = 1

    self.androidButtonTypes = { -1, -1, -1, -1, -1, -1 }
    
    if SDXL.ChannelManager:HasPlatformForum() ~= 0 then
    	buttonTexts[buttonIndex] = SDXL.ChannelManager:GetPlatformForumName()
    	self.androidButtonTypes[buttonIndex] = AndroidButtonType_Forum
    	buttonIndex = buttonIndex + 1
    end
	
    if SDXL.ChannelManager:HasPlatformCenter() ~= 0 then
    	buttonTexts[buttonIndex] = SDXL.ChannelManager:GetPlatformCenterName()
    	self.androidButtonTypes[buttonIndex] = AndroidButtonType_UserCenter
    	buttonIndex = buttonIndex + 1
    end
	
    if SDXL.ChannelManager:HasFeedback() ~= 0 then
    	buttonTexts[buttonIndex] = SDXL.ChannelManager:GetPlatformFeedbackName()
    	self.androidButtonTypes[buttonIndex] = AndroidButtonType_UserFeedback
    	buttonIndex = buttonIndex + 1
    end

    if SDXL.ChannelManager:SupportFeature(1) ~= 0 then
        buttonTexts[buttonIndex] = MHSD_UTILS.get_resstring(2860)
        self.androidButtonTypes[buttonIndex] = AndroidButtonType_SwitchAccount
        buttonIndex = buttonIndex + 1
	end
	if SDXL.ChannelManager:SupportFeature(2) ~= 0 then
        buttonTexts[buttonIndex] = MHSD_UTILS.get_resstring(2858)
        self.androidButtonTypes[buttonIndex] = AndroidButtonType_LianXiKeFu
        buttonIndex = buttonIndex + 1
	end
	if SDXL.ChannelManager:SupportFeature(3) ~=0 then
        buttonTexts[buttonIndex] = MHSD_UTILS.get_resstring(2992)
        self.androidButtonTypes[buttonIndex] = AndroidButtonType_MoreGames
        buttonIndex = buttonIndex + 1
    end
	if SDXL.ChannelManager:SupportFeature(4) ~=0 then
        buttonTexts[buttonIndex] = MHSD_UTILS.get_resstring(3006)
        self.androidButtonTypes[buttonIndex] = AndroidButtonType_FAQ
        buttonIndex = buttonIndex + 1
    end


	buttonTexts[buttonIndex] = MHSD_UTILS.get_resstring(2866)
	self.androidButtonTypes[buttonIndex] = AndroidButtonType_RestoreConfig
	buttonIndex = buttonIndex + 1
	
	buttonTexts[buttonIndex] = MHSD_UTILS.get_resstring(2867)
	self.androidButtonTypes[buttonIndex] = AndroidButtonType_SaveConfig
	buttonIndex = buttonIndex + 1
	
	local buttonCount = buttonIndex - 1
    
	LogInfo("SystemSettingDlg:AndroidInit buttonCount" .. buttonCount)
	
    self:btnInit(buttonCount, buttonTexts)
end

function SystemSettingDlg:AndroidHandleClick(buttonIndex)
	LogInfo("android hanle click enter")
	LogInfo("buttonIndex " .. buttonIndex )
	LogInfo( "self ".. self.androidButtonTypes[buttonIndex])

	if self.androidButtonTypes[buttonIndex] == AndroidButtonType_Forum then
		SDXL.ChannelManager:EnterBBS()
	elseif self.androidButtonTypes[buttonIndex] == AndroidButtonType_UserCenter then
		SDXL.ChannelManager:EnterPlatformCenter()
	elseif self.androidButtonTypes[buttonIndex] == AndroidButtonType_UserFeedback then
		SDXL.ChannelManager:UserFeedBack()
	elseif self.androidButtonTypes[buttonIndex] == AndroidButtonType_SwitchAccount then
		SDXL.ChannelManager:LogoutAndRelogin()
	elseif self.androidButtonTypes[buttonIndex] == AndroidButtonType_RestoreConfig then
		GetGameConfigManager():SetForDefaultConfig()
		self:Init()
		GetGameConfigManager():ApplyConfig()
		GetGameConfigManager():SaveConfig()
	elseif self.androidButtonTypes[buttonIndex] == AndroidButtonType_SaveConfig then
		self:ApplyConfig()
		GetGameConfigManager():ApplyConfig()
		GetGameConfigManager():SaveConfig()
	elseif self.androidButtonTypes[buttonIndex] == AndroidButtonType_LianXiKeFu then
        if Config.isKoreanAndroid() then
           require "luaj"
           luaj.callStaticMethod("com.wanmei.korean.KoreanCommon", "LianXiKeFu", nil, "()V")
        else
            ContactServiceDialog.getInstance()
        end
	elseif self.androidButtonTypes[buttonIndex] == AndroidButtonType_MoreGames then
		require "luaj"
		luaj.callStaticMethod("com.wanmei.mini.condor.mobile.Platformmobile", "MoreGames", nil, "()V")
	elseif self.androidButtonTypes[buttonIndex] == AndroidButtonType_FAQ then
		require "luaj"
		local value = {}
		value[1] = "http://sdxl.laohu.com/faq/"
		if Config.CUR_3RD_LOGIN_SUFFIX == "aiyx" then
			luaj.callStaticMethod("com.wanmei.mini.condor.iyouxi.PlatformIYouXi", "FAQ", value, "(Ljava/lang/String;)V")
		else
			luaj.callStaticMethod("com.wanmei.mini.condor.tiger.TigerPlatform", "FAQ", value, "(Ljava/lang/String;)V")
		end
	end

	return true
end

return SystemSettingDlg
