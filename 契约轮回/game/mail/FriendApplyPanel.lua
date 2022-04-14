FriendApplyPanel = FriendApplyPanel or class("FriendApplyPanel",WindowPanel)
local FriendApplyPanel = FriendApplyPanel

function FriendApplyPanel:ctor()
	self.abName = "mail"
	self.assetName = "FriendApplyPanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 3								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false		--是否显示侧边栏
	self.table_index = nil
	self.model = FriendModel:GetInstance()

	self.item_list = {}
end

function FriendApplyPanel:dctor()
	if self.event_id then
		self.model:RemoveListener(self.event_id)
		self.event_id = nil
	end

	if self.event_id2 then
		self.model:RemoveListener(self.event_id2)
		self.event_id2 = nil
	end

	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
end

function FriendApplyPanel:Open( )
	FriendApplyPanel.super.Open(self)
end

function FriendApplyPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content","noapply","refuseallbtn","acceptallbtn",
	}
	self:GetChildren(self.nodes)

	self:SetTileTextImage("mail_image", "friend_apply_img_title")
	--FriendController:GetInstance():RequestApplyList()
	self:AddEvent()

	self:SetPanelSize(650, 450)
end

function FriendApplyPanel:AddEvent()
	local function call_back()
		self:UpdateView()
	end
	self.event_id = self.model:AddListener(FriendEvent.ApplyList, call_back)

	self.event_id2 = self.model:AddListener(FriendEvent.HandleAccept, call_back)

	local function call_back(target,x,y)
		FriendController:GetInstance():RequestRefuse()
	end
	AddClickEvent(self.refuseallbtn.gameObject,call_back)

	local function call_back(target,x,y)
		FriendController:GetInstance():RequestAccept()
	end
	AddClickEvent(self.acceptallbtn.gameObject,call_back)
end

function FriendApplyPanel:OpenCallBack()
	self:UpdateView()
end

function FriendApplyPanel:UpdateView()
	local apply_list = self.model:GetApplyList()
	local num = table.nums(apply_list)
	if num > 0 then
		SetVisible(self.noapply, false)
		local i = 1
		for _, role in pairs(apply_list) do
			local item = self.item_list[i] or FriendApplyItem(self.Content)
			item:SetData(role)
			self.item_list[i] = item
			i = i + 1
		end
	else
		SetVisible(self.noapply, true)
	end
	if #self.item_list > num then
		for i=#self.item_list, num+1, -1 do
			self.item_list[i]:destroy()
			self.item_list[i] = nil
		end
	end
end

function FriendApplyPanel:CloseCallBack(  )

end
