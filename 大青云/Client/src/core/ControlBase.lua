--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/6/20
-- Time: 17:03
--
_G.classlist['CControlBase'] = 'CControlBase'
_G.CControlBase ={}
_G.CControlBase.objName = 'CControlBase'
CControlBase.objContext = nil;
CControlBase.setAllControl = {};
CControlBase.bIsUsable = false;
CControlBase.oldKey = {};
CControlBase.disabled = true;
function CControlBase:new(bIsUsable,objContext)
    local obj = {};
    obj.objContext = objContext;
    obj.bIsUsable = bIsUsable or false;

    obj.SetContext = self.SetContext;
    obj.GetContext = self.GetContext;
    obj.OnMouseMove = self.OnMouseMove;
    obj.OnMouseDown = self.OnMouseDown;
    obj.OnMouseUp = self.OnMouseUp;
    obj.OnMouseDbclick = self.OnMouseDbclick;
    obj.OnMouseWheel = self.OnMouseWheel;
    obj.OnKeyDown = self.OnKeyDown;
    obj.OnKeyUp = self.OnKeyUp;
    table.insert(self.setAllControl,obj);
    return obj;
end;

--设置宿主
function CControlBase:SetContext(objContext)
    self.objContext = objContext;
end;
--得到宿主
function CControlBase:GetContext()
    return self.objContext;
end;
--注册控制器
function CControlBase:RegControl(objControl,bIsUsable)
    objControl.bIsUsable = bIsUsable or false;
    table.insert(self.setAllControl,objControl);
end;

function CControlBase:OnActive(bIsActive)
    if not self.setAllControl then
        return
    end
    self.oldKey = {}
    for I, Control in pairs(self.setAllControl) do
        if Control.bIsUsable and Control.OnActive then
            Control:OnActive(bIsActive)
        end
    end
end

function CControlBase:OnMouseMove(nXPos,nYPos)
	if GameController.loginState then
		CLoginScene:OnMouseMove(nXPos,nYPos) ;
	else
		if CControlBase.disabled then return end;
		if not self.setAllControl then return end;
		
		for I,Control in pairs(self.setAllControl) do
			if Control.bIsUsable and Control.OnMouseMove then
				Control:OnMouseMove(nXPos,nYPos) ;
			end;
		end;
	end
end;

function CControlBase:OnMouseDown(nButton,nXPos,nYPos)
	if GameController.loginState then
		CLoginScene:OnMouseDown(nButton,nXPos,nYPos)
		return
	end
    if CControlBase.disabled then return end;
    if not self.setAllControl then return end;
    --Debug("OnMouseDown")
    for I,Control in pairs(self.setAllControl) do
        if Control.bIsUsable and Control.OnMouseDown then
            Control:OnMouseDown(nButton,nXPos,nYPos);
        end;
    end;
end;

function CControlBase:OnMouseUp(nButton,nXPos,nYPos)
    if CControlBase.disabled then return end;
    if not self.setAllControl then return end;
    for I,Control in pairs(self.setAllControl) do
        if Control.bIsUsable and Control.OnMouseUp then
            Control:OnMouseUp(nButton,nXPos,nYPos) ;
        end;
    end;
end;

function CControlBase:OnMouseDbclick(nXPos,nYPos)
    if CControlBase.disabled then return end;
    if not self.setAllControl then return end;
    for I,Control in pairs(self.setAllControl) do
        if Control.bIsUsable and Control.OnMouseDbclick then
            Control:OnMouseDbclick(nXPos,nYPos);
        end;
    end;
end;

function CControlBase:OnMouseWheel(fDelta)
	if GameController.loginState then
		CLoginScene:OnMouseWheel(fDelta) ;
	else
		if CControlBase.disabled then return end;
		if not self.setAllControl then return end;
		for I,Control in pairs(self.setAllControl) do
			if Control.bIsUsable and Control.OnMouseWheel then
				Control:OnMouseWheel(fDelta);
			end;
		end;
	end
end;

function CControlBase:OnKeyDown(dwKeyCode)
    -- if dwKeyCode == _System.KeyAlt then
    -- return;
    -- end;
	if GameController.loginState then
		CLoginScene:OnKeyDown(dwKeyCode)
	else
		if CControlBase.disabled then
        Debug("OnKeyDown:controlBase Disabled return");
        return
		end;
		if not self.oldKey  then
			Debug("OnKeyDown:OldKey Does Not Initialize Return");
			return;
		end;

		self.oldKey[dwKeyCode] = dwKeyCode;
		--CPlayerSystem:BreakAutoRun();
		if not self.setAllControl then
			Debug("OnKeyDown:setAllControl Not Initialize.return")
			return
		end;
		for I,Control in pairs(self.setAllControl) do
			if Control.bIsUsable and Control.OnKeyDown then
				Control:OnKeyDown(dwKeyCode);
			end;
		end;
	end
end;

function CControlBase:OnKeyUp(dwKeyCode)
    -- if dwKeyCode == _System.KeyAlt then
    -- return;
    -- end;
    --if CControlBase.disabled then return end;
    if not self.oldKey  then return; end;
    if not self.oldKey[dwKeyCode] then
        return ;
    end;
    self.oldKey[dwKeyCode] = nil;

    if not self.setAllControl then return end;
    for I,Control in pairs(self.setAllControl) do
        if Control.bIsUsable and Control.OnKeyUp then
            Control:OnKeyUp(dwKeyCode);
        end;
    end;
end;

--禁用消息
function CControlBase:SetControlDisable(bDisabled)
    if bDisabled then
        self.disabled = true;
        --_sys.messageUI = false;
    else
        self.disabled = nil;
        --_sys.messageUI = true;
    end;
end;
