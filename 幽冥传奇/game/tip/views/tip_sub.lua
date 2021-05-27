TipSub = TipSub or BaseClass()

TipSub.SIZE = cc.size(0, 0)

function TipSub:__init()
	self.view = XUI.CreateLayout(0, 0, TipSub.SIZE.width, TipSub.SIZE.height)
	self.view:setAnchorPoint(0, 0)
	self.y_order = 0
	self.content_height = 0
	self.is_ignore_height = false
	self.root_obj = nil

	self.is_created = false
end

function TipSub:__delete()
	self.view = nil
	self.root_obj = nil

	self.is_created = false
	self:Release()
end

function TipSub:SetRootObj(obj)
	self.root_obj = obj
end

function TipSub:GetView()
	return self.view
end

function TipSub:IsIgnoreHeight()
	return self.is_ignore_height
end

function TipSub:ContentHeight()
	return self.content_height
end

function TipSub:YOrder()
	return self.y_order
end

function TipSub:Flush()
	if not self.is_created then
		self:CreateChild()
	end
	self:OnFlush()
end

function TipSub:Close()
	if self.root_obj then
		self.root_obj:CloseHelper()
	end
end

------------------------------------------------------
function TipSub:SetData(data, fromView, param_t)
end

function TipSub:AlignSelf()
end

function TipSub:Release()
end

function TipSub:CreateChild()
	self.is_created = true
end

function TipSub:OnFlush()
end
