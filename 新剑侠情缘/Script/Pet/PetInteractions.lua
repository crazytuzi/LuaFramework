Pet.tbInteractions = {}

Pet.tbInteractions["dog"] = {
	{
		"遛弯",	--交互按钮名
		function(self)	--执行交互
			Pet:FollowMe(self.nNpcId)
		end,
		function(self)	--控制是否显示此交互
			return Pet:CanFollowMe(self.nNpcId)
		end
	},
	{
		"休息",
		function(self)
			Pet:StopFollowMe(self.nNpcId)
		end,
		function(self)
			return Pet:CanStopFollowMe(self.nNpcId)
		end
	},
	{
		"喂食",
		function(self)
			Pet:OpenFeedPanel(self.nTemplateId)
		end,
		function(self)
			return House:IsInOwnHouse(me)
		end
	},
}

Pet.tbInteractions["cat"] = {
	{
		"玩耍",
		function(self)
			Pet:Play(self.nNpcId)
		end,
		function(self)
			return Pet:CanFollowMe(self.nNpcId)
		end
	},
	{
		"休息",
		function(self)
			Pet:StopFollowMe(self.nNpcId)
		end,
		function(self)
			return Pet:CanStopFollowMe(self.nNpcId)
		end
	},
	{
		"改名",
		function(self)
			Ui:OpenWindow("PetChangeName", self.nTemplateId)
		end,
		function(self)
			return House:IsInOwnHouse(me)
		end
	},
	{
		"遛弯",
		function(self)
			Pet:FollowMe(self.nNpcId)
		end,
		function(self)
			return Pet:CanFollowMe(self.nNpcId)
		end
	},
}
