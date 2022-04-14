-- 
-- @Author: LaoY
-- @Date:   2018-07-20 15:43:42
-- 
PanelTabButton = PanelTabButton or class("PanelTabButton",BaseWidget)
local PanelTabButton = PanelTabButton

function PanelTabButton:ctor(parent_node,builtin_layer)
	self.abName = "system"
	self.assetName = "PanelTabButton"

	BaseWidget.Load(self)
end

function PanelTabButton:dctor()
	if self.red_dot then
		self.red_dot:destroy()
		self.red_dot = nil
	end
end

function PanelTabButton:LoadCallBack()
	self.nodes = {
		"text","click","sel_con","img_nor","img_icon"
	}
	self:GetChildren(self.nodes)

	self.img_component = self.img_icon:GetComponent('Image')
	self.text_component = self.text:GetComponent('Text')

	self.red_dot = RedDot(self.transform,nil,RedDot.RedDotType.Nor)
	self.red_dot:SetPosition(44,27)
	if self.red_dot_param ~= nil then
		self:SetRedDotParam(self.red_dot_param)
	end
	if self.red_dot_type ~= nil then
        self:SetRedDotType(self.red_dot_type)
    end

	-- self.transform:SetAsFirstSibling()
	self:AddEvent()
end

function PanelTabButton:AddEvent()
	local function call_back(target,x,y)
		PanelTabButton.OnClick(self)
	end
	AddClickEvent(self.click.gameObject,call_back)
end

-- 其他模块也会用到这个方法
function PanelTabButton.OnClick(button)
    local str = button.data.open_func and button.data.open_func()
    if button.data.open_func then
    	if str then
	        Notify.ShowText(str)
	        return
	    end
    elseif (button.data.open_lv or button.data.open_task) and not IsOpenModular(button.data.open_lv,button.data.open_task) then
        Notify.ShowText("Your level is too low to use this function")
        return
    end
    if button.callback then
        button.callback(button.id,button.data.show_toggle)
    end
end

function PanelTabButton:SetCallBack(callback)
	self.callback = callback
end

function PanelTabButton:SetData(data)
	data = data or {}
	self.data = data
	self.text_component.text = data.text or ""
	self.id = data.id or 1
end

function PanelTabButton:SetSelectState(flag)
	if self.select_state == flag then
		return
	end
	self.select_state = flag
	local icon_data
	if flag then
		icon_data = self.data.icon
		SetVisible(self.sel_con,true)
		SetVisible(self.img_nor,false)
		SetColor(self.text_component,HtmlColorStringToColor("#feeea4"))
	else
		icon_data = self.data.dark_icon
		SetVisible(self.sel_con,false)
		SetVisible(self.img_nor,true)
		SetColor(self.text_component,HtmlColorStringToColor("#4a4131"))
	end
	if icon_data then
		local image_res = string.split(icon_data, ":")
		local abName = image_res[1] and image_res[1] .. "_image"
		local assetName = image_res[2]
		if abName and assetName then
			lua_resMgr:SetImageTexture(self,self.img_component,abName,assetName,true)
		end
	end
end

function PanelTabButton:SetRedDotType(red_dot_type)
    if not self.red_dot then
        self.red_dot_type = red_dot_type
    else
        self.red_dot:SetRedDotType(red_dot_type)
    end
end

function PanelTabButton:SetRedDotParam(param)
	if not self.red_dot then
		self.red_dot_param = param
	else
		self.red_dot:SetRedDotParam(param)
	end
end