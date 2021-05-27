
-- 预加载
PerloadCtrl = PerloadCtrl or BaseClass(BaseController)

function PerloadCtrl:__init()
	if PerloadCtrl.Instance then
		ErrorLog("[PerloadCtrl]:Attempt to create singleton twice!")
	end
	PerloadCtrl.Instance = self

	self.finish_weight = 0							-- 已经完成权值
	self.total_weight = 0							-- 总权值

	self.callback_func = nil
end

function PerloadCtrl:__delete()
	PerloadCtrl.Instance = nil
end

function PerloadCtrl:GetPercent()
	if self.total_weight > 0 then
		return self.finish_weight / self.total_weight * 100
	end
	
	return 100
end

function PerloadCtrl:Start(callback_func)
	self.callback_func = callback_func

	self:AddLoad("res/xui/scene.png", 40)
	self:AddLoad("res/xui/fight.png", 40)

	self.total_weight = self.total_weight + 20
	ViewManager.Instance:GetView(ViewDef.MainUi):StartLoad(BindTool.Bind(self.OnLoadCallback, self, 20))
end

function PerloadCtrl:AddLoad(path, weight)
	self.total_weight = self.total_weight + weight

	ResourceMgr:getInstance():asyncLoadPlist(path, BindTool.Bind(self.OnLoadCallback, self, weight))
end

function PerloadCtrl:OnLoadCallback(weight, path, is_succ)
	if self.total_weight <= 0 then
		return
	end

	self.finish_weight = self.finish_weight + weight
	local percent = self.finish_weight / self.total_weight * 100

	if nil ~= self.callback_func then
		self.callback_func(percent)
	end
end

function PerloadCtrl:SetCallbackFunc(callback_func)
	self.callback_func = callback_func
end
