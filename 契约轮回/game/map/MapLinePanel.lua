--
-- @Author: LaoY
-- @Date:   2018-11-28 20:08:57
--
MapLinePanel = MapLinePanel or class("MapLinePanel",BasePanel)
local MapLinePanel = MapLinePanel

function MapLinePanel:ctor()
	self.abName = "map"
	self.assetName = "MapLinePanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.click_bg_close = true
	self.item_list = {}

	self.scene_data = SceneManager:GetInstance():GetSceneInfo()
end

function MapLinePanel:dctor()
	if self.scene_data_event_1 then
		self.scene_data:RemoveListener(self.scene_data_event_1)
	end

	for k,item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}
end

function MapLinePanel:Open( )
	MapLinePanel.super.Open(self)
end

function MapLinePanel:LoadCallBack()
	self.nodes = {
		"scroll","MapLineItem","text_line","scroll/Viewport/Content","img_bg",
	}
	self:GetChildren(self.nodes)
	self.scroll_heigth = GetSizeDeltaY(self.scroll)
	self.scroll_component = self.scroll:GetComponent('ScrollRect')
	self.text_line_component = self.text_line:GetComponent('Text')

	SetVisible(self.MapLineItem,false)
	self:AddEvent()
end

function MapLinePanel:AddEvent()
	local function call_back()
		self:UpdateInfo()
		if self.scene_data.line == self.select_id then
			self:Close()
		end
	end
	self.scene_data_event_1 = self.scene_data:BindData("line", call_back)
end

function MapLinePanel:OpenCallBack()
	if not self.scene_data then
		return
	end
	self:UpdateInfo()
	self:UpdateView()
end

function MapLinePanel:UpdateInfo()
	self.text_line_component = self.scene_data.line .. "Lane"
end

function MapLinePanel:UpdateView( )
	local list = self.scene_data:GetLines()
	
	local width = 130
	local height = 50
	local length = #list
	local content_height = height * math.ceil(length*0.5)
	content_height = content_height < self.scroll_heigth and self.scroll_heigth or content_height
	SetSizeDeltaY(self.Content,content_height)
	-- self.scroll_component.vertical = content_height > self.scroll_heigth
	SetLocalPositionY(self.Content,0)
	local function callback(line)
		self.select_id = line
		SceneControler:GetInstance():RequestSceneSwitch(line)
	end
	for i=1, #list do
		local item = self.item_list[i]
		if not item then
			item = MapLineItem(self.MapLineItem.gameObject,self.Content)
			self.item_list[i] = item
			local x = (i-1)%2 * width + 57
			local y = -math.floor((i-1)/2) * height - height*0.5
			item:SetPosition(x, y)
			item:SetCallBack(callback)
		end
		item:SetData(i,list[i])
	end
end

function MapLinePanel:CloseCallBack(  )

end