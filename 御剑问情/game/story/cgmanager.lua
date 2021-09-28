CgManager = CgManager or BaseClass()
function CgManager:__init()
	if CgManager.Instance ~= nil then
		ErrorLog("[CgManager] attempt to create singleton twice!")
		return
	end
	CgManager.Instance = self

	self.cg = nil
end

function CgManager:__delete()
	if nil ~= self.cg then
		self.cg:DeleteMe()
		self.cg = nil
	end

	CgManager.Instance = nil
end

function CgManager:Play(cg, end_callback, start_callback, is_jump_cg)
	if nil == cg or cg == self.cg then
		return
	end

	if nil ~= self.cg then
		self.cg:Stop()
		self.cg:DeleteMe()
	end

	self.cg = cg
	Scene.Instance:GetMainRole():StopMove()	-- 玩家停止移动
	GuajiCtrl.Instance:ClearAllOperate()	-- 停止所有操作

	self.cg:Play(function ()
			self.cg:DeleteMe()
			self.cg = nil
			end_callback()
		end, start_callback, is_jump_cg)
end

function CgManager:Stop()
	if nil ~= self.cg then
		self.cg:Stop()
		self.cg:DeleteMe()
		self.cg = nil
	end
end

function CgManager:IsCgIng()
	return nil ~= self.cg
end