MainuiNavBtnGroupPanel = MainuiNavBtnGroupPanel or BaseClass()

function MainuiNavBtnGroupPanel:__init(parent, index)
	self.parent = parent

	self.mask_panel = XUI.CreateLayout(0,0,HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight())
	self.mask_panel:setAnchorPoint(0,0)
	parent:addChild(self.mask_panel)
	self.container = XUI.CreateLayout(0,0,100, 100)
	self.container:setAnchorPoint(0.5,0)
	self.mask_panel:addChild(self.container)
	self.bg = XUI.CreateImageViewScale9(0,0,100,100,ResPath.GetCommon("img9_171"),true,cc.rect(10,10,35,30))
	self.bg:setAnchorPoint(0,0)
	self.container:addChild(self.bg)
	self.index = index or 0
	self.orig_px, self.orig_py = 0, 0
	XUI.AddClickEventListener(self.mask_panel,BindTool.Bind(self.OnClose,self))
end

function MainuiNavBtnGroupPanel:__delete()
end

function MainuiNavBtnGroupPanel:GetIndex()
	return self.index
end

function MainuiNavBtnGroupPanel:SetSize(w,h)
	self.container:setContentWH(w,h)
	self.bg:setContentWH(w,h)
end	

function MainuiNavBtnGroupPanel:GetSize()
	return self.container:getContentSize()
end

function MainuiNavBtnGroupPanel:GetView()
	return self.container
end	

function MainuiNavBtnGroupPanel:SetPosition(x, y)
	self.orig_px, self.orig_py = x,y
	self.container:setPosition(x,y)
end

function MainuiNavBtnGroupPanel:SetVisible(v,is_action)
	self.container:stopAllActions()
	if is_action then
		local scaleAction, callFun, moveAction, spawn, ease_sine, seq
		local callBack = function () 
							self.mask_panel:setVisible(v)
						end
		callFun = cc.CallFunc:create(callBack)
		local time = 0.25
		local scale = v and 1 or 0
		local moveDelt = -45
		local origScale = v and 0 or 1
		self.container:setScale(origScale)
		scaleAction = cc.ScaleTo:create(time, scale)
		moveAction = cc.JumpTo:create(time, cc.p(self.orig_px,self.orig_py), moveDelt, 1)
		spawn = cc.Spawn:create(scaleAction, moveAction)
		ease_sine = v and cc.EaseSineIn:create(spawn) or cc.EaseSineOut:create(spawn)
		if not v then
			seq = cc.Sequence:create(ease_sine, callFun)
		else
			seq = cc.Sequence:create(callFun, ease_sine)
		end
		self.container:runAction(seq)
	else
		self.mask_panel:setVisible(v)
	end
	
end	

function MainuiNavBtnGroupPanel:IsVisible()
	return self.mask_panel:isVisible()
end

function MainuiNavBtnGroupPanel:OnClose()
	self:SetVisible(false, true)
end	

function MainuiNavBtnGroupPanel:SetContainerOrigPos(x, y)
	self.orig_px, self.orig_py = x, y
end

function MainuiNavBtnGroupPanel:SetMaskPanelTouchEnable(enabled)
	self.mask_panel:setTouchEnabled(enabled)
end	