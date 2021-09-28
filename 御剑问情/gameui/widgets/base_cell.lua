BaseCell = BaseCell or BaseClass(BaseRender)
function BaseCell:__init()
	self.data = nil
	self.index = 0
	self.name = ""

	self.click_callback = nil									-- 点击回调

	self.is_use_step_calc = false								-- 是否使用分步计算
	self.is_add_step = false									-- 是否添加入分步计算池
end

function BaseCell:__delete()
	if self.is_add_step then
		StepPool.Instance:DelStep(self)
	end
end

function BaseCell:GetData()
	return self.data
end

function BaseCell:SetData(data)
	self.data = data
	self:Flush()
end

function BaseCell:ClearData()
	self:SetData(nil)
end

function BaseCell:GetIndex()
	return self.index
end

function BaseCell:SetIndex(index)
	self.index = index
end

function BaseCell:SetPosition(x, y)
	self.root_node.transform:SetLocalPosition(x, y, 0)
end

function BaseCell:AddClickEventListener(callback)
	self.click_callback = callback
	self.root_node:GetOrAddComponent(typeof(UnityEngine.UI.Button))
	self.root_node.button:SetClickListener(BindTool.Bind(self.OnClick, self))
end

function BaseCell:SetClickCallBack(callback)
	self.click_callback = callback
end

-- 是否使用分步计算
function BaseCell:SetIsUseStepCalc(is_use_step_calc)
	self.is_use_step_calc = is_use_step_calc
end

-- 外部通知刷新，调用此接口
function BaseCell:Flush()
	if self.is_use_step_calc then
		if not self.is_add_step then
			self.is_add_step = true
			StepPool.Instance:AddStep(self)
		end
	else
		self:OnFlush()
	end
end

-- 分步计算回调
function BaseCell:Step()
	self.is_add_step = false
	self:OnFlush()
end

----------------------------------------------------
-- 可重写的接口 begin
----------------------------------------------------
-- 刷新
function BaseCell:OnFlush()
end

-- 点击回调
function BaseCell:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end
----------------------------------------------------
-- 可重写的接口 end
----------------------------------------------------
