--------------------------------------------------------
-- 红钻获取提示  配置
--------------------------------------------------------

RedDrilleTipView = RedDrilleTipView or BaseClass(BaseView)

function RedDrilleTipView:__init()
	self:SetIsAnyClickClose(true)
	self:SetModal(true)
	self.num = 0
end

function RedDrilleTipView:__delete()

end

--释放回调
function RedDrilleTipView:ReleaseCallBack()
	self.eff = nil
end

--加载回调
function RedDrilleTipView:LoadCallBack(index, loaded_times)
	self:CreateNumber()
end

function RedDrilleTipView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RedDrilleTipView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.num = 0
end

function RedDrilleTipView:SetNumber(num)
	if type(num) == "number" then
		self.num = num
	end
end

--显示指数回调
function RedDrilleTipView:ShowIndexCallBack(index)
	self:FlushEff()

	self.number_bar:SetNumber(self.num)
end
----------视图函数----------

function RedDrilleTipView:FlushEff()
	local res_id = 10055
	local path, name = ResPath.GetEffectUiAnimPath(res_id)
	if nil == self.eff then
		local ph = {x = 30, y = 50, w = 0, h = 0}
		local parent = self.root_node
		self.eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Stand, false)
		self.eff:setPosition(ph.x, ph.y)
		parent:addChild(self.eff, 50)
	else
		self.eff:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Stand, false)
	end
end

function RedDrilleTipView:CreateNumber()
	local ph = {x = 0, y = 0, w = 1, h = 1}
	local path = ResPath.GetCommon("num_133_")
	local parent = self.root_node
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y - 18, ph.w, ph.h, path)
	number_bar:SetSpace(-5)
	number_bar:SetGravity(NumberBarGravity.Center)
	parent:addChild(number_bar:GetView(), 99)
	self.number_bar = number_bar
	self:AddObj("number_bar")
end

----------end----------

--------------------
