AddFriendPanel = AddFriendPanel or class("AddFriendPanel",WindowPanel)
local AddFriendPanel = AddFriendPanel

function AddFriendPanel:ctor()
	self.abName = "mail"
	self.assetName = "AddFriendPanel"
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

function AddFriendPanel:dctor()
end

function AddFriendPanel:Open( )
	AddFriendPanel.super.Open(self)
end

function AddFriendPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content","changebtn","searchbtn","InputField",
	}
	self:GetChildren(self.nodes)
	self.InputField = self.InputField:GetComponent('InputField')

	self:SetTileTextImage("mail_image", "friend_add_img_title")
	self:AddEvent()
	self:SetPanelSize(650, 450)
	if not self.roles then
		FriendController:GetInstance():RequestRecommend()
	end
end

function AddFriendPanel:AddEvent()

	local function call_back(target,x,y)
		if os.time()-self.model.change_recommend > 5 then
			self.model.change_recommend = os.time()
			FriendController:GetInstance():RequestRecommend()
		else
			Notify.ShowText("Too fast, please have a break")
		end
	end
	AddClickEvent(self.changebtn.gameObject,call_back)

	local function call_back(target,x,y)
		local name = string.trim(self.InputField.text)
		if name == "" then
			Notify.ShowText("Please enter information")
		else
			FriendController:GetInstance():RequestSearch(name)
		end
	end
	AddClickEvent(self.searchbtn.gameObject,call_back)
end

function AddFriendPanel:OpenCallBack()
	self:UpdateView()
end

function AddFriendPanel:UpdateView( )
	if self.roles then
		for i=1, #self.roles do
			local item = self.item_list[i] or AddFriendItem(self.Content)
			item:SetData(self.roles[i])
			self.item_list[i] = item
		end
		if #self.item_list > #self.roles then
			for i=#self.item_list, #self.roles+1, -1 do
				self.item_list[i]:destroy()
				self.item_list[i] = nil
			end
		end
	end
end

function AddFriendPanel:CloseCallBack(  )

end

function AddFriendPanel:SetData(roles)
	self.roles = roles
	if self.is_loaded then
		self:UpdateView()
	end
end
