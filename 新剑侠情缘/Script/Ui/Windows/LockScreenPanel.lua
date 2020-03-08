local tbUi = Ui:CreateClass("LockScreenPanel");
local fSpeed = 0.1 				-- 每帧移动的距离
local nTimeInterval = 1 		-- 定时器执行的帧数
local f2Close = 0.7 			-- 超过这个距离滑向右边自动解锁

function tbUi:OnOpen()
	Ui.nLockScreenState = true
	self.pPanel:SliderBar_SetValue("Slider", 0);
	self.pPanel:SetActive("Tip", true)
end

function tbUi:TryStartTimer()
	local fValue = self.pPanel:SliderBar_GetValue("Slider");
	if fValue <= 0 then
		self.pPanel:SetActive("Tip", true)
	elseif fValue >= 1 then
		self:CloseSelf()
	else
		if fValue > 0 and fValue < f2Close then
			self.nTimer = Timer:Register(nTimeInterval, self.Update2Left, self);
		elseif fValue >= f2Close and fValue < 1 then
			self.nTimer = Timer:Register(nTimeInterval, self.Update2Right, self);
		end
	end
end
	
function tbUi:Update2Left()
	local fValue = self.pPanel:SliderBar_GetValue("Slider");
	if fValue <= 0 then
		self.nTimer = nil
		self.pPanel:SetActive("Tip", true)
		return false
	end
	local fNextValue = fValue - fSpeed
	self.pPanel:SliderBar_SetValue("Slider", fNextValue < 0 and 0 or fNextValue);
	return true
end

function tbUi:Update2Right()
	local fValue = self.pPanel:SliderBar_GetValue("Slider");
	if fValue >= 1 then
		self.nTimer = nil
		self:CloseSelf()
		return false
	end
	local fNextValue = fValue + fSpeed
	self.pPanel:SliderBar_SetValue("Slider", fNextValue > 1 and 1 or fNextValue);
	return true
end

function tbUi:CloseSelf()
	Ui.nLockScreenState = nil
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:CloseTimer()
	 if self.nTimer then
        Timer:Close(self.nTimer)
        self.nTimer = nil
    end
end

function tbUi:OnClose()
	self:CloseTimer()
end

function tbUi:OnLeaveMap()
	Ui:CloseWindow(self.UI_NAME)
	-- 主要为了清掉拖动的状态（不清掉切地图的时候拖动有问题）
	Ui.UiManager.DestroyUi(self.UI_NAME)
end

tbUi.tbOnDragEnd =
{
	BtnLock = function (self)
		self:TryStartTimer()
	end;
}

tbUi.tbOnDrag = 
{
	BtnLock = function (self)
		self:CloseTimer()
		self.pPanel:SetActive("Tip", false)
	end;
}

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_MAP_LEAVE,			self.OnLeaveMap},
    };

    return tbRegEvent;
end