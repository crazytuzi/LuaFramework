ActiveAttackRobertAi = ActiveAttackRobertAi or BaseClass(BaseRobertAi)

function ActiveAttackRobertAi:__init()
	
end

function ActiveAttackRobertAi:__delete()

end

function ActiveAttackRobertAi:Update(now_time, elapse_time)
	BaseRobertAi.Update(self, now_time, elapse_time)
	
	if nil == self.atk_target then
		self.atk_target = RobertManager.Instance:FindEnemy(self.robert)
	end
end
