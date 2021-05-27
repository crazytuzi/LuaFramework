
--仇人页面
SocietyEnemyPage = SocietyEnemyPage or BaseClass()


function SocietyEnemyPage:__init()
	self.view = nil
end	

function SocietyEnemyPage:__delete()
	self:RemoveEvent()
	if self.enemy_list_view then
		self.enemy_list_view:DeleteMe()
		self.enemy_list_view = nil
	end
	self.view = nil
end	

--初始化页面接口
function SocietyEnemyPage:InitPage(view)
	--绑定要操作的元素

	self.view = view
	local ph = view.ph_list.ph_enemy_list
	self.enemy_list_view = ListView.New()
	self.enemy_list_view:Create(ph.x, ph.y, ph.w, ph.h, dir, InfoListItem, gravity, bounce, view.ph_list.ph_enemy_list_item)
	view.node_t_list["layout_enemy"].node:addChild(self.enemy_list_view:GetView(), 99)
	self.enemy_list_view:SetItemsInterval(2)
	self.enemy_list_view:SetAutoSupply(true)
	self.enemy_list_view:SetMargin(2)
	self.enemy_list_view:SetJumpDirection(ListView.Top)
	self:InitEvent()
	
end	

--初始化事件
function SocietyEnemyPage:InitEvent()
	self.view.node_t_list["btn_remove_the_col"].node:addClickEventListener(BindTool.Bind(self.OnRemoveColClicked, self))
end

--移除事件
function SocietyEnemyPage:RemoveEvent()

end

--更新视图界面
function SocietyEnemyPage:UpdateData(data)
	
	local data_tbl = SocietyData.Instance:GetRelationshipList(SOCIETY_RELATION_TYPE.ENEMY)
	if data_tbl == nil then return end
	local enemy_list = self.view:SetShowOnlineOrAll(data_tbl)
	
	self.enemy_list_view:SetDataList(enemy_list)
end	


function SocietyEnemyPage:OnRemoveColClicked()
	if self.enemy_list_view:GetSelectItem() then
		local select_item_data = self.enemy_list_view:GetSelectItem():GetData()
		if select_item_data then
			local name = select_item_data.name
			local id = select_item_data.role_id
			SocietyCtrl.Instance:AskAddOrDeleteSomeBody(SOCIETY_OPERATE_TYPE.DEL, SOCIETY_RELATION_TYPE.ENEMY, id, name)
		end
	end
end