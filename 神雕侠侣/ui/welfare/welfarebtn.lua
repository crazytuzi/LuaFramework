require "ui.dialog"
WelfareBtn = {}
setmetatable(WelfareBtn, Dialog)
WelfareBtn.__index = WelfareBtn

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function WelfareBtn.getInstance()
    if not _instance then
        _instance = WelfareBtn:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function WelfareBtn.getInstanceAndShow()
    if not _instance then
        _instance = WelfareBtn:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function WelfareBtn.getInstanceNotCreate()
    return _instance
end

function WelfareBtn.DestroyDialog()
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

function WelfareBtn.ToggleOpenClose()
	if not _instance then 
		_instance = WelfareBtn:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function WelfareBtn.GetLayoutFileName()
    return "fulibtndialog.layout"
end

function WelfareBtn.Refresh()
	if _instance then
		_instance:refresh()
	end
end

------------------- private: -----------------------------------
function WelfareBtn:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, WelfareBtn)
    return self
end

function WelfareBtn:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.button = CEGUI.Window.toPushButton(winMgr:getWindow("fulibtndialog"))
	self.remainTime = winMgr:getWindow("fulibtndialog/pic/num")
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
	self.button:subscribeEvent("Clicked", WelfareBtn.HandleClicked, self)
	self:refresh()
end

function WelfareBtn:HandleClicked()
	if CWalfarePannelDlg:GetSingleton() then
        CWalfarePannelDlg:ToggleOpenHide()
    else
        CWalfarePannelDlg:GetSingletonDialogAndShowIt()
    end
end

function WelfareBtn:setRemainTime( x )
	if GetBattleManager() and GetBattleManager():IsInBattle() then
        return
    end
    self.remainTime:setText(tostring(x));
    
    --若没有可领取的，隐藏按钮
    self:SetVisible(x > 0);
end

function WelfareBtn:refresh()
	if (not GetBattleManager():IsInBattle()) and (not GetScene():IsInFuben()) then
        local p    = GetWelfareManager()
        local game = GetGameUIManager()
        if p ~= nil and game ~= nil then
            local isShowEffect  = p:getEffectEnabel(0);
            local isExistEffect = game:IsWindowHaveEffect(self.button)
            if isShowEffect and (not isExistEffect) then
                game:AddUIEffect(self.button, MHSD_UTILS.get_effectpath(10305), true);
                if CDeviceInfo:GetDeviceType() == 3 then
                    local sizeMem = CDeviceInfo:GetTotalMemSize()
                    if sizeMem <= 1024 then
                        if self.m_ani then
                            self.m_ani:start()
                        end
                    end
                end
            elseif (not isShowEffect) then
                game:RemoveUIEffect(self.button);
                if CDeviceInfo:GetDeviceType() == 3 then
                    local sizeMem = CDeviceInfo:GetTotalMemSize()
                    if sizeMem <= 1024 then
                        if self.m_ani then
                            self.m_ani:stop()
                        end
                    end
                end
			end
            -- 设置小数字
            self:setRemainTime(p:getCount());
        end
    else
        self:SetVisible(false);
    end
end

return WelfareBtn
