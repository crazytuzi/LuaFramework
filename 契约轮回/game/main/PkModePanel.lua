--
-- @Author: LaoY
-- @Date:   2018-11-23 10:27:19
--
PkModePanel = PkModePanel or class("PkModePanel",BasePanel)
local PkModePanel = PkModePanel

function PkModePanel:ctor()
	self.abName = "main"
	self.assetName = "PkModePanel"
	self.layer = "Bottom"

	self.use_background = true
	self.change_scene_close = true
	self.click_bg_close = true

	self.item_list = {}
	-- self.model = 2222222222222end:GetInstance()
end

function PkModePanel:dctor()
	for k,item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}
end

function PkModePanel:Open( )
	PkModePanel.super.Open(self)
end

function PkModePanel:LoadCallBack()
	self.nodes = {
		"img_bg","PkModeItem",
	}
	self:GetChildren(self.nodes)

	-- self.img_bg_component = self.img_bg:GetComponent('Image')
	local height = GetSizeDeltaY(self.img_bg)
	local y = GetLocalPositionY(self.img_bg)
	self.img_bottom_y = y - height * 0.5

	SetAlignType(self,bit.bor(AlignType.Left,AlignType.Bottom))

	SetVisible(self.PkModeItem,false)
	self.PkModeItem_gameObject = self.PkModeItem.gameObject
	if self.background_img then
		SetAlpha(self.background_img,0)
	end
	self:AddEvent()
end

function PkModePanel:AddEvent()

end

function PkModePanel:OpenCallBack()
	self:UpdateView()
end

function PkModePanel:UpdateView( )
	local list = SceneConfigManager:GetInstance():GetPkModeList()
	local height = 72
	local length = #list
	local img_height = length*height + 20
	local function call_back()
		self:Close()
	end
	for i=1,#list do
		local item = self.item_list[i]
		if not item then
			item = PkModeItem(self.PkModeItem_gameObject,self.img_bg)
			local x = 0
			local y = (length - i + 1) * height - img_height * 0.5 - 20
			-- y = 0
			item:SetPosition(x,y)
			self.item_list[i] = item
		end
		item:SetCallBack(call_back)
		item:SetData(list[i])
		item:SetImageLineVisible(i~=length)
	end
	SetSizeDeltaY(self.img_bg,img_height)
	local y = self.img_bottom_y + img_height * 0.5
	SetLocalPositionY(self.img_bg,y)
end

function PkModePanel:CloseCallBack(  )

end