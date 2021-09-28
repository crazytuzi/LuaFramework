require "ui.dialog"
OnlineGiftBtn = {}
setmetatable(OnlineGiftBtn, Dialog)
OnlineGiftBtn.__index = OnlineGiftBtn

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function OnlineGiftBtn.getInstance()
    if not _instance then
        _instance = OnlineGiftBtn:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function OnlineGiftBtn.getInstanceAndShow()
    if not _instance then
        _instance = OnlineGiftBtn:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function OnlineGiftBtn.getInstanceNotCreate()
    return _instance
end

function OnlineGiftBtn.DestroyDialog()
	if _instance then 
        if CDeviceInfo:GetDeviceType() == 3 then
                local sizeMem = CDeviceInfo:GetTotalMemSize()
                if sizeMem <= 1024 then
                    if _instance.m_ani then
                        local aniMan = CEGUI.AnimationManager:getSingleton()
                        aniMan:destroyAnimationInstance(_instance.m_ani)
                        _instance.m_ani = nil
                    end
                end
            end
		_instance:OnClose()
		_instance = nil
	end
end

function OnlineGiftBtn.ToggleOpenClose()
	if not _instance then 
		_instance = OnlineGiftBtn:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function OnlineGiftBtn.GetLayoutFileName()
    return "giftbag.layout"
end

function OnlineGiftBtn.Refresh()
	if GetWelfareManager() and (not GetWelfareManager():getOnLineWelfareFinish()) and 
       ( not GetBattleManager():IsInBattle()) and (not GetScene():IsInFuben()) then
        OnlineGiftBtn.getInstanceAndShow():InitByID(GetWelfareManager():getGiftId(), 0);
        GetWelfareManager():setCountDownEnable(true)
    end
end

function OnlineGiftBtn.SetTime( time )
    if _instance then
        _instance:setTime(time, isReady)
    end
end

function OnlineGiftBtn.SetIsReady( isReady )
    if _instance then
        _instance:setIsReady(isReady)
    end
end

function OnlineGiftBtn.Process( giftid, remainTime )
    if GetWelfareManager() then
        if giftid == -1 then
            GetWelfareManager():setOnLineWelfareFinish(true);
            OnlineGiftBtn.DestroyDialog()
        else
            GetWelfareManager():setGiftId(giftid);
            OnlineGiftBtn:getInstance():InitByID(giftid, remainTime);
            OnlineGiftBtn:getInstance():removeEffect();
            GetWelfareManager():setOnLineWelfareFinish(false);
        end
    end
end

------------------- private: -----------------------------------
function OnlineGiftBtn:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, OnlineGiftBtn)
    return self
end

function OnlineGiftBtn:OnCreate()
    self.m_eDialogType = eDlgTypeNull
    Dialog.OnCreate(self)

    if CDeviceInfo:GetDeviceType() == 3 then
		local sizeMem = CDeviceInfo:GetTotalMemSize()
		if sizeMem <= 1024 then
			local aniMan = CEGUI.AnimationManager:getSingleton()
			aniMan:loadAnimationsFromXML("example.xml")
			local animation = aniMan:getAnimation("flash")
			self.m_ani = aniMan:instantiateAnimation(animation)
			self.m_ani:setTargetWindow(self:GetWindow())
		end
	end

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_timeLeft = winMgr:getWindow("Giftbag/Time")
    self.m_btn = CEGUI.Window.toPushButton(winMgr:getWindow("Giftbag/Btn"))
    self.m_BtnCover = winMgr:getWindow("Giftbag/Btn/Geffect")
    self.m_BtnCover:setMousePassThroughEnabled(true);

    self.m_btn:subscribeEvent("Clicked", self.HandleClicked, self);
end

function OnlineGiftBtn:HandleClicked()
	if GetBattleManager() and GetBattleManager():IsInBattle() then 
        return true
    end
    COnLineWelfareDlg:GetSingletonDialog():InitByID(self.m_id)
end

function OnlineGiftBtn:setRemainTime( x )
	if GetBattleManager() and GetBattleManager():IsInBattle() then
        return
    end
    self.remainTime:setText(tostring(x));
    
    --若没有可领取的，隐藏按钮
    self.button:setVisible(x > 0);
end

function OnlineGiftBtn:InitByID( id, remainTime )
    if remainTime < 0 then remainTime = 0 end

    self.m_id = id;
    if id ~= -1 then
        if remainTime <= 0 then
            self.m_timeLeft:setText(MHSD_UTILS.get_resstring(2936));
        elseif GetWelfareManager() then
            GetWelfareManager():setBeginTime(remainTime / 1000);
        end
        return true;
    end
    return false;
end

function OnlineGiftBtn:setTime( time )
    self.m_time = time
    if self.m_timeLeft then
        self.m_timeLeft:setText(self.m_time)
    end
end

function OnlineGiftBtn:setIsReady( isReady )
    if isReady and self.m_timeLeft then
        if self.m_Effect == nil then
            self.m_Effect = GetGameUIManager():AddUIEffect(self.m_BtnCover,MHSD_UTILS.get_effectpath(10305),true);
            if self.m_Effect then
                if GetBattleManager() and GetBattleManager():IsInBattle() then
                    self.m_Effect:Stop()
                end
            end
            if CDeviceInfo:GetDeviceType() == 3 then
                local sizeMem = CDeviceInfo:GetTotalMemSize()
                if sizeMem <= 1024 then
                    if self.m_ani then
                        self.m_ani:start()
                    end
                end
            end
        end
    end
end

function OnlineGiftBtn:removeEffect()
    if self.m_Effect and GetGameUIManager() then
        GetGameUIManager():RemoveUIEffect(self.m_Effect)
        self.m_Effect = nil
        if CDeviceInfo:GetDeviceType() == 3 then
			local sizeMem = CDeviceInfo:GetTotalMemSize()
			if sizeMem <= 1024 then
				if self.m_ani then
					self.m_ani:stop()
				end
			end
		end
    end
end

return OnlineGiftBtn
