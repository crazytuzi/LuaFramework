require "ui.dialog"
require "utils.mhsdutils"

local XiangFuZhenShouBtn = {}

setmetatable(XiangFuZhenShouBtn, Dialog)
XiangFuZhenShouBtn.__index = XiangFuZhenShouBtn

XiangFuZhenShouBtn.iconShow = 0

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function XiangFuZhenShouBtn.getInstance()
    if not _instance then
        _instance = XiangFuZhenShouBtn:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function XiangFuZhenShouBtn.getInstanceAndShow()
    if not _instance then
        _instance = XiangFuZhenShouBtn:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function XiangFuZhenShouBtn.getInstanceNotCreate()
    return _instance
end

function XiangFuZhenShouBtn.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function XiangFuZhenShouBtn.ToggleOpenClose()
	if not _instance then 
		_instance = XiangFuZhenShouBtn:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

-- 这段代码时做什么的，搞笑么
function XiangFuZhenShouBtn:setVisible(b)
	if _instance then
		_instance:SetVisible(b)
	end
end

----/////////////////////////////////////////------

function XiangFuZhenShouBtn.GetLayoutFileName()
    return "huodongzhoubtn.layout"
end

function XiangFuZhenShouBtn:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow("huodongzhoubtn/button"))

    -- subscribe event
    self.m_pBtn:subscribeEvent("Clicked", XiangFuZhenShouBtn.HandleBtnClicked, self) 

end

------------------- private: -----------------------------------

function XiangFuZhenShouBtn:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, XiangFuZhenShouBtn)
    return self
end

function XiangFuZhenShouBtn:HandleBtnClicked(args)
  	GetMessageManager():AddConfirmBox(eConfirmNormal,
  		MHSD_UTILS.get_msgtipstring(145791),
  		XiangFuZhenShouBtn.HandleTransferClicked,
  		self,
  		CMessageManager.HandleDefaultCancelEvent,
  		CMessageManager)
	return true
end

function XiangFuZhenShouBtn:HandleTransferClicked()

	GetMessageManager():CloseConfirmBox(eConfirmNormal, false);
	
	local sb = StringBuilder:new()
	sb:SetNum("parameter1", "50")
	local tipMsg = sb:GetString(MHSD_UTILS.get_msgtipstring(145848))
	sb:delete()

	if not GetTeamManager():IsOnTeam() or  GetTeamManager():IsMyselfLeader() or GetTeamManager():GetMemberSelf().eMemberState == 2 then
		if GetDataManager():GetMainCharacterLevel() < 50 then
			GetGameUIManager():AddMessageTip(tipMsg)
		else	
			GetMainCharacter():FlyOrWarkToPos(1007, 100, 21, -1)
		end
	else
		GetChatManager():AddTipsMsg(145817)
	end

	return true 
end

return XiangFuZhenShouBtn
