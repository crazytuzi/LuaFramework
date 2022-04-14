--限时寻宝抽奖结果界面
TimeLimitedTreasureHuntResultPanel = TimeLimitedTreasureHuntResultPanel or class("TimeLimitedTreasureHuntResultPanel",YYSTResultPanel)
local TimeLimitedTreasureHuntResultPanel = TimeLimitedTreasureHuntResultPanel


function TimeLimitedTreasureHuntResultPanel:ctor()
	
	self.btn_list = {
		{btn_res = "common:btn_yellow_2",btn_name = ConfigLanguage.Mix.Confirm,format = "Automatic shutdown after %s seconds", auto_time=10, call_back = handler(self,self.OkFunc)},
		-- 说明
		{btn_res = "common:btn_blue_2",btn_name = "One more",call_back = handler(self,self.SearchOne)},
		{btn_res = "common:btn_blue_2",btn_name = "Ten more time",call_back = handler(self,self.SearchTen)},
	}
end

function TimeLimitedTreasureHuntResultPanel:dctor()
end

function TimeLimitedTreasureHuntResultPanel:CreateBackground()
	if not self.back_ground then
		self.child_transform:SetAsFirstSibling()
		if self.background_transform then
			self.background_transform:SetAsFirstSibling()
		end

		local function callback(  )
			--改下抽奖结果界面的背景图和标题
			lua_resMgr:SetImageTexture(self,self.back_ground.img_bg_component,"timeLimitedTreasureHunt_image","img_timeLimitedTreasureHunt_result_bg")
			lua_resMgr:SetImageTexture(self,GetImage(self.back_ground.img_title_1_1),"timeLimitedTreasureHunt_image","img_timeLimitedTreasureHunt_text3")
			
			SetLocalPositionY(self.back_ground.img_bg,403.3)
		end

		if self.use_close_btn then
			self.back_ground = RewardBackground(self.child_transform,nil,handler(self,self.ClickClose),callback)
		else
			self.back_ground = RewardBackground(self.child_transform,nil,nil,callback)
		end
	end
	self.back_ground:SetData(self.btn_list)
end




