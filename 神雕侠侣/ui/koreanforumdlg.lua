require "utils.mhsdutils"
require "ui.dialog"

KoreanForumDlg = {}
setmetatable(KoreanForumDlg, Dialog)
KoreanForumDlg.__index = KoreanForumDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function KoreanForumDlg.getInstance()
	if Config.MOBILE_ANDROID == 0 then
		if Config.CUR_3RD_PLATFORM ~= "kris" then return end
	else
		if not KoreanForumDlg.isKoreanAndroid() then return end
	end
	LogInfo("enter get KoreanForumDlg instance")
    if not _instance then
        _instance = KoreanForumDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function KoreanForumDlg.WantShow()
	if Config.MOBILE_ANDROID == 0 then
		if Config.CUR_3RD_PLATFORM ~= "kris" then return end
	else
		if not KoreanForumDlg.isKoreanAndroid() then return end
	end
	if _instance then
		_instance:SetVisible(true)
	end
end

function KoreanForumDlg.WantHide()
	if Config.MOBILE_ANDROID == 0 then
		if Config.CUR_3RD_PLATFORM ~= "kris" then return end
	else
		if not KoreanForumDlg.isKoreanAndroid() then return end
	end
	if _instance then
		_instance:SetVisible(false)
	end
end

function KoreanForumDlg.getInstanceAndShow()
	if Config.MOBILE_ANDROID == 0 then
		if Config.CUR_3RD_PLATFORM ~= "kris" then return end
	else
		if not KoreanForumDlg.isKoreanAndroid() then return end
	end
	LogInfo("enter KoreanForumDlg instance show")
    if not _instance then
        _instance = KoreanForumDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set KoreanForumDlg visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function KoreanForumDlg.getInstanceNotCreate()
    return _instance
end

function KoreanForumDlg.DestroyDialog()
	if Config.MOBILE_ANDROID == 0 then
		if Config.CUR_3RD_PLATFORM ~= "kris" then return end
	else
		if not KoreanForumDlg.isKoreanAndroid() then return end
	end
	if _instance then 
		LogInfo("destroy KoreanForumDlg")
		_instance:OnClose()
		_instance = nil
	end
end

function KoreanForumDlg.ToggleOpenClose()
	if not _instance then 
		_instance = KoreanForumDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function KoreanForumDlg.refreshEffect()
	LogInfo("KoreanForumDlg refresh effect")
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

----/////////////////////////////////////////------

function KoreanForumDlg.GetLayoutFileName()
    return "luntan.layout"
end

function KoreanForumDlg:OnCreate()
	LogInfo("KoreanForumDlg oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow("luntan/btn"))

    -- subscribe event
    self.m_pBtn:subscribeEvent("Clicked", KoreanForumDlg.HandleBtnClicked, self) 
	--KoreanForumDlg.refreshEffect()
	LogInfo("KoreanForumDlg oncreate end")
end

------------------- private: -----------------------------------

function KoreanForumDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, KoreanForumDlg)
    return self
end

function KoreanForumDlg:HandleBtnClicked(args)
	LogInfo("KoreanForumDlg button clicked")
	SDXL.ChannelManager:EnterBBS()
	return true
end

function KoreanForumDlg.isKoreanAndroid()
	return Config.isKoreanAndroid()
end

return KoreanForumDlg
