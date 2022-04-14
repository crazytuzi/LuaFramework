-- 
-- @Author: LaoY
-- @Date:   2018-09-12 15:04:06
-- 
PanelBackgroundFour = PanelBackgroundFour or class("PanelBackgroundFour",BaseWidget)
local PanelBackgroundFour = PanelBackgroundFour

function PanelBackgroundFour:ctor(parent_node,builtin_layer)
	self.abName = "system"
	self.assetName = "PanelBackgroundFour"
	-- 场景对象才需要修改
	-- self.builtin_layer = builtin_layer

	PanelBackgroundFour.super.Load(self)
end

function PanelBackgroundFour:dctor()
	if self.tab_item_list then
		for k,item in pairs(self.tab_item_list) do
			item:destroy()
		end
		self.tab_item_list = {}
	end
end

function PanelBackgroundFour:LoadCallBack()
	self.nodes = {
		"content","windowCloseBtn","text_title","img_bg_1","img_title"
	}
	self:GetChildren(self.nodes)
	self.transform:SetAsFirstSibling()

	self.text_title_component = self.text_title:GetComponent('Text')
	SetVisible(self.text_title,false)
	self.img_bg_component = self.img_bg_1:GetComponent('Image')
	self.img_title_component = self.img_title:GetComponent('Image')

	if self.is_need_settitle_visible then
		self:SetTitleVisible(self.title_visible)
	end
	self:AddEvent()
end

function PanelBackgroundFour:AddEvent()
	local function call_back(target,x,y)
		if self.close_call_back then
			self.close_call_back()
		end
	end
	AddButtonEvent(self.windowCloseBtn.gameObject,call_back)
end

function PanelBackgroundFour:SetBackgroundImage(abName,assetName)
	lua_resMgr:SetImageTexture(self,self.img_bg_component,abName,assetName,true)
end

-- function PanelBackgroundFour:SetCameraBlur(panel_cls)
-- 	self.panel_cls = panel_cls or self.panel_cls
-- 	if self.is_loaded then
-- 		lua_panelMgr:CameraBlur(self.panel_cls,self.bg)
-- 	else
-- 		self.need_set_camerablur = true
-- 	end
-- end

function PanelBackgroundFour:SetCallBack(close_call_back,switch_call_back)
	self.close_call_back = close_call_back
	self.switch_call_back = switch_call_back
end

function PanelBackgroundFour:IsShowSidebar(flag)
	flag = toBool(flag)
	self.show_sidebar = flag
end

function PanelBackgroundFour:SetData(data)
	if not self.show_sidebar then
		return
	end
	data = data or {}
	self.data = data
	self.tab_item_list = self.tab_item_list or {}
	local function callback(index)
		self:SetTabIndex(index)
	end
	local height = GetSizeDeltaY(self.content)
	local offy = 87
	for i=1,#data do
		local item = self.tab_item_list[i]
		if not item then
			item = PanelTabButtonTwo(self.content,self.layer)
			self.tab_item_list[i] = item
			item:SetPosition(110,-(i-0.5) * offy + height)
			item:SetCallBack(callback)
		end
		item:SetData(data[i])
	end
	-- callback(self.default_table_index)

	local height = #data * offy + 60
end

function PanelBackgroundFour:SetTabIndex(index)
	if self.tab_index == index then
		return
	end
	self.tab_index = index
	local data
	if self.tab_item_list then
		for k,item in pairs(self.tab_item_list) do
			item:SetSelectState(item.id == index)
			if item.id == index then
				data = item.data
			end
		end
	end

	-- if data and data.text then
	-- 	self:SetTileText(data.text)
	-- end
	if data and data.img_title then
		local image_res = string.split(data.img_title, ":")
		local abName = image_res[1] and image_res[1] .. "_image"
		local assetName = image_res[2]
		if abName and assetName then
			self:SetTileTextImage(abName,assetName)
		end
	end

	if self.switch_call_back then
		self.switch_call_back(index)
	end
end

function PanelBackgroundFour:SetTileText(text)
	-- if text then
	-- 	self.text_title_component.text = text
	-- end
end

function PanelBackgroundFour:SetTileIcon()
end

function PanelBackgroundFour:SetTileTextImage(abName,assetName)
	lua_resMgr:SetImageTexture(self,self.img_title_component,abName,assetName,false)
end

function PanelBackgroundFour:SetTitleVisible(flag)
	self.title_visible = flag
	if self.is_loaded then
		SetVisible(self.img_title,flag)
		self.is_need_settitle_visible = false
	else
		self.is_need_settitle_visible = true
	end
end

function PanelBackgroundFour:GetItem(id)
	if not self.tab_item_list then
        return nil
    end
    for k,item in pairs(self.tab_item_list) do
        if item.id == id then
            return item
        end
    end
    return nil
end

function PanelBackgroundFour:SetRedDotParam(id,param)
    local item = self:GetItem(id)
    if item then
        item:SetRedDotParam(param)
    end
end

function PanelBackgroundFour:SetRedDotType(id,red_dot_type)
    local item = self:GetItem(id)
    if item then
        item:SetRedDotType(red_dot_type)
    end
end

function PanelBackgroundFour:SetPanelSize(width, height)
    print2(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    print2("PanelBackgroundFour 不支持SetPanelSize");
    print2("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
end