--
-- @Author: LaoY
-- @Date:   2018-12-07 15:23:07
--
Toggle = Toggle or class("Toggle",BaseCloneItem)
local Toggle = Toggle

function Toggle:ctor(obj,parent_node,layer)
	Toggle.super.Load(self)
end

function Toggle:dctor()
	if self.red_dot then
		self.red_dot:destroy()
		self.red_dot = nil
	end
end

function Toggle:LoadCallBack()
	self.nodes = {
		"img_bg","text"
	}
	self:GetChildren(self.nodes)
	self.text_component = self.text:GetComponent('Text')
	self.img_bg_component = self.img_bg:GetComponent('Image')
	self:SetSelectState(false)

	self.red_dot = RedDot(self.transform,nil,RedDot.RedDotType.Nor)
	self.red_dot:SetPosition(60,13)
	if self.red_dot_param ~= nil then
		self:SetRedDotParam(self.red_dot_param)
	end
	if self.red_dot_type ~= nil then
        self:SetRedDotType(self.red_dot_type)
    end

	self:AddEvent()
end

function Toggle:AddEvent()
	local function call_back(target,x,y)
		PanelTabButton.OnClick(self)
	end
	AddClickEvent(self.img_bg.gameObject,call_back)
end

function Toggle:SetSelectState(flag)
	local assetName = flag and "img_tog1_2" or "img_tog1_1"
	if self.assetName == assetName then
		return
	end
	self.assetName = assetName
	local abName = "system_image"
	local function call_back(sprite)
		self.img_bg_component.sprite = sprite
	end
	if flag then
		SetColor(self.text_component, 133, 132, 176, 255)
	else
		SetColor(self.text_component, 255, 255, 255, 255)
	end

	--local img_y = flag and -3 or 0
	--SetLocalPositionY(self.img_bg,img_y)
	lua_resMgr:SetImageTexture(self, self.img_bg_component, abName, assetName, false)
end

function Toggle:SetCallBack(callback)
	self.callback = callback
end

function Toggle:SetData(index,data)
	self.data = data
	self.id = data.id or index
	self.text_component.text = data.text
end

function Toggle:SetRedDotType(red_dot_type)
    if not self.red_dot then
        self.red_dot_type = red_dot_type
    else
        self.red_dot:SetRedDotType(red_dot_type)
    end
end

function Toggle:SetRedDotParam(param)
	if not self.red_dot then
		self.red_dot_param = param
	else
		self.red_dot:SetRedDotParam(param)
	end
end