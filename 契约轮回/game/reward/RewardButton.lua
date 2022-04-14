--
-- @Author: LaoY
-- @Date:   2018-12-18 17:45:30
--
RewardButton = RewardButton or class("RewardButton",BaseCloneItem)
local RewardButton = RewardButton

function RewardButton:ctor(obj,parent_node,layer)
	RewardButton.super.Load(self)
end

function RewardButton:dctor()
	self:StopTime()

	if self.lua_link_image_text then
		self.lua_link_image_text:destroy()
		self.lua_link_image_text = nil
	end
end

function RewardButton:LoadCallBack()
	self.nodes = {
		"img_text_bg/text_des","btn","btn/text_btn","img_text_bg",
	}
	self:GetChildren(self.nodes)
	self.text_des_component = self.text_des:GetComponent('LinkImageText')
	self.lua_link_image_text = LuaLinkImageText(self,self.text_des_component)

	self.text_btn_component = self.text_btn:GetComponent('Text')
	self.btn_component = self.btn:GetComponent('Image')
	self:AddEvent()
end

function RewardButton:AddEvent()
	local function call_back(target,x,y)
		if self.data and self.data.call_back then
			self.data.call_back()
		end
	end
	AddClickEvent(self.btn.gameObject,call_back)
end

function RewardButton:SetData(index,data)
	self.data = data or self.data
	self:StopTime()
	if not self.data.text and not self.data.auto_time then
		SetVisible(self.img_text_bg,false)
	else
		SetVisible(self.img_text_bg,true)
		if self.data.auto_time then
			self.end_time = self.data.auto_time + os.time()
			self:StartTime()
		elseif type(self.data.text) == "function" then
			local text = self.data.text()
			self.text_des_component.text = text
		else
			self.text_des_component.text = self.data.text
		end
	end

	if self.data.btn_name then
		self.text_btn_component.text = self.data.btn_name
	end

	if self.data.btn_res then
		local abName,assetName = ResourceName(self.data.btn_res)
		if self.abName ~= abName or self.assetName ~= assetName then
			self.abName = abName
			self.assetName = assetName
			lua_resMgr:SetImageTexture(self,self.btn_component, abName, assetName,true)
		end
	end
end

function RewardButton:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
		self.end_time = os.time() + self.data.auto_time
	end
end

function RewardButton:StartTime()
	self:StopTime()
	if not self.end_time then
		return
	end
	local str
	if self.data.format then
		str = self.data.format
	else
		str = "<color=#06ff00>(closing in %s sec)</color>"
	end
	local function step()
		local last_time = self.end_time - os.time()
		if last_time <= 0 then
			self:StopTime()
			if self.data.call_back then
				self.data.call_back()
			end
			return
		end
		self.text_des_component.text = string.format(str,last_time)
	end
	self.time_id = GlobalSchedule:Start(step,1.0)
	step()
end