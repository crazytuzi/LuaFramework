--
-- @Author: LaoY
-- @Date:   2018-12-18 17:27:54
--

BaseRewardPanel = BaseRewardPanel or class("BaseRewardPanel",BasePanel)
local BaseRewardPanel = BaseRewardPanel

function BaseRewardPanel:ctor()
	self.use_close_btn = false
	-- 四种情况
	self.btn_list = {
		{btn_res = "common:btn_blue_2",btn_name = "Confirm",call_back = handler(self,self.Close)},
		-- 说明
		-- {btn_res = "common:btn_yellow_2",btn_name = "按钮1",call_back = handler(self,self.Close)},
		-- {btn_res = "common:btn_blue_2",btn_name = "按钮2",text = "不带倒计时文本",call_back = handler(self,self.Close)},
		-- {btn_res = "common:btn_blue_2",btn_name = "按钮2",format = "%s倒计时",auto_time = 5,call_back = handler(self,self.Close)},
		-- {btn_res = "common:btn_blue_2",btn_name = "按钮2",auto_time = 5,call_back = handler(self,self.Close)},
	}
end

function BaseRewardPanel:dctor()
	if self.back_ground then
		self.back_ground:destroy()
		self.back_ground = nil
	end
end

function BaseRewardPanel:Open()
	if self.isShow then
		self:CreateBackground()
		self:AfterOpen()
		return
	end
	BaseRewardPanel.super.Open(self)
end

function BaseRewardPanel:CreateBackground()
	if not self.back_ground then
		self.child_transform:SetAsFirstSibling()
		if self.background_transform then
			self.background_transform:SetAsFirstSibling()
		end
		if self.use_close_btn then
			self.back_ground = RewardBackground(self.child_transform,nil,handler(self,self.ClickClose))
		else
			self.back_ground = RewardBackground(self.child_transform)
		end
	end
	self.back_ground:SetData(self.btn_list)
end


--[[
	@author LaoY
	@des	设置button的位置，只需要设置Y 
	LoadCallBack 后调用
--]]
function BaseRewardPanel:SetButtonConPosition(y)
	if self.back_ground then
		self.back_ground:SetButtonConPosition(y)
	end
end

--[[
	@author LaoY
	@des	设置底图大小，只需要设置高 
	LoadCallBack 后调用
--]]
function BaseRewardPanel:SetBackgroundHeight(height)
	if self.back_ground then
		self.back_ground:SetBackgroundHeight(height)
	end
end

function BaseRewardPanel:SetTitlePosition(y)
	if self.back_ground then
		self.back_ground:SetTitlePosition(y)
	end
end

function BaseRewardPanel:ClickClose()
	self:Close()
end

function BaseRewardPanel:AfterCreate()
	self:CreateBackground()
	self:LoadCallBack()
end

function BaseRewardPanel:CloseCallBack(  )

end

--[[
	@author LaoY
	@des	获取货币奖励的文本展示 一行
			/*参数说明*/
			可以是table支持 单个参数
			{item_id,num} 或者 {id = item_id,num = num}

			**
			或者两个number
--]]
function BaseRewardPanel:GetMoneyTypeText(reward,reward_num)
	if type(reward) == "table" then
		local tab = {}
		for i=1,#reward do
			local info = reward[i]
			local item_id = info[1] or info.id
			local num = info[2] or info.num
			local item_cf = Config.db_item[item_id]
			tab[#tab+1] = string.format("Obtain <color=#%s>%s</color>：%s",ColorUtil.GetColor(item_cf.color),item_cf.name,num)
		end
		return table.concat(tab,"\t")
	else
		local item_cf = Config.db_item[reward]
		return string.format("Obtain <color=#%s>%s</color>：%s",ColorUtil.GetColor(item_cf.color),item_cf.name,reward_num)
	end
end