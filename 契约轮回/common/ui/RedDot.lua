---
-- @Author: LaoY
-- @Date:   2019-03-29 16:10:56
--
RedDot = RedDot or class("RedDot",BaseWidget)

RedDot.__cache_count = 15

RedDot.RedDotType = {
	Nor = 1,  	-- 普通
	Num = 2, 	-- 数字
}
function RedDot:ctor(parent_node,builtin_layer,reddot_type)
	self.abName = "system"
	self.assetName = "RedDot"

	self.img_assetName = "img_red_dot_1"
	-- 场景对象才需要修改
	-- self.builtin_layer = builtin_layer
	self:SetRedDotType(reddot_type)
	RedDot.super.Load(self)
end

function RedDot:dctor()
end

function RedDot:__reset(parent_node,builtin_layer,reddot_type)
	RedDot.super.__reset(self,parent_node,builtin_layer,reddot_type)
	self:SetRedDotType(reddot_type)
	self:SetVisible(false)

    SetLocalPosition(self.img_red_dot , 0,0,0);
end

function RedDot:__clear()
	RedDot.super.__clear(self)
	self.reddot_type = nil
	self.param = nil
	self.number_visible = nil
end

function RedDot:LoadCallBack()
	self.nodes = {
		"img_red_dot/text_num","img_red_dot",
	}
	self:GetChildren(self.nodes)
	self.text_num_component = self.text_num:GetComponent('Text')

	self.img_red_dot_component = self.img_red_dot:GetComponent('Image')

	if self.reddot_type == RedDot.RedDotType.Nor then
		SetVisible(self.text_num,false)
	elseif self.reddot_type == RedDot.RedDotType.Num then
		SetVisible(self.text_num,true)
	end
	self:SetRedDotParam(false)

	if self.scale ~= nil then
		self:SetScale(self.scale)
	end

	self:SetReddotImage()
	self:AddEvent()
end

function RedDot:SetReddotImage()
	local abName = 'system_image'
	local img_assetName = '1'
	if self.reddot_type == RedDot.RedDotType.Nor then
		img_assetName = "img_red_dot_1"
	elseif self.reddot_type == RedDot.RedDotType.Num then
		img_assetName = "img_red_dot"
	end
	if self.img_assetName == img_assetName then
		return
	end
	self.img_assetName = img_assetName
	lua_resMgr:SetImageTexture(self,self.img_red_dot_component, abName, img_assetName,false)
end

function RedDot:AddEvent()
end

function RedDot:SetNumberVisible(flag)
	if self.number_visible == flag then
		return
	end
	self.number_visible = flag
	SetVisible(self.text_num,flag)
end

--[[
	@author LaoY
	@des	
	@param1 reddot_type 	设置红点类型；默认普通类型
--]]
function RedDot:SetRedDotType(reddot_type)
	reddot_type = reddot_type or RedDot.RedDotType.Nor
	if self.reddot_type == reddot_type then
		return
	end
	self.reddot_type = reddot_type
	self:SetReddotImage()
	if self.reddot_type == RedDot.RedDotType.Nor then
		self:SetScale(1.0)
		self:SetNumberVisible(false)
	else
		self:SetScale(1.0)
	end
	if self.param ~= nil then
		self:SetRedDotParam(self.param)
	end
end

--[[
	@author LaoY
	@des	设置红点
	@param1 param 	如果是普通红点，填bool；如果是数字红点，填number
--]]
function RedDot:SetRedDotParam(param)
	self.param = param
	if type(param) == "boolean" then
		if self.reddot_type == RedDot.RedDotType.Num then
			self:SetNumberVisible(false)
		end
		self:SetVisible(param)
	elseif type(param) == "number" then
		if self.reddot_type == RedDot.RedDotType.Num then
			self:SetNumberVisible(true)
			local num_text = param > 99 and 99 or param
			self.text_num_component.text = num_text
		end
		self:SetVisible(param > 0)
	end
end
