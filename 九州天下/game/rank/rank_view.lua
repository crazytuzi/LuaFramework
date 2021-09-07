require("game/rank/rank_content_view")
require("game/rank/rank_mingren_view")
RankView = RankView or BaseClass(BaseView)
local TOGGLE_MAX = 6                -- RANK_TOGGLE_TYPE 这个表里面的最大值(排行榜类型)
function RankView:__init()
	self.ui_config = {"uis/views/rank","RankView"}
	self:SetMaskBg()                      --使用蒙版
	self.full_screen = false
	self.play_audio = true  
	self.is_cell_active = false
	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
	self.cell_list = {}
	self.index = 1
	self.item_cell_list = {}
	self:SetMaskBg()
end

function RankView:LoadCallBack()
	self.toggle_type = 0
	self.toggle_index = 0
	self.is_on = {}

	self.leftBarList = {}
	for i = 0, TOGGLE_MAX do
		self.leftBarList[i] = {}
		self.leftBarList[i].select_btn = self:FindObj("select_btn_" .. i)
		self.leftBarList[i].btn_text = self:FindVariable("btn_text_" .. i)
		self:ListenEvent("select_btn_" .. i ,BindTool.Bind(self.OnClickSelect, self, i))
		self.leftBarList[i].btn_text:SetValue(Language.RankTogle.TogleList[i])
		if i > 0 then
			self.leftBarList[i].list = self:FindObj("list_" .. i)
			self:LoadCell(i)
		end
	end
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick,self))
	self:ListenEvent("ming_click",BindTool.Bind(self.OnMingClick,self))
	self:ListenEvent("rank_click",BindTool.Bind(self.RankClick,self))
	-- self:ListenEvent("add_money_click",BindTool.Bind(self.AddMoneyClick,self))
	-- self:ListenEvent("top_meili_click",BindTool.Bind(self.TopMeiLiClick,self))

	self.rank_content_view = RankContentView.New(self:FindObj("rank_content_view"))
	self.rank_mingren_view = RankMingRenView.New(self:FindObj("rank_mingren_view"))

	self.gold_text = self:FindVariable("gold_text")
	self.bind_gold_text = self:FindVariable("bind_gold_text")
	self.show_blue_bg = self:FindVariable("show_blue_bg")
	self.show_ming_red_point = self:FindVariable("show_ming_red_point")
	self.show_tab_list_view = self:FindVariable("show_tab_list_view")
	self.show_left_bar = self:FindVariable("Show_Left_Bar")
	self.show_left_bar:SetValue(true)
	self.show_btn_hl = self:FindVariable("show_btn_hl")


	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)

	self.list_view = self:FindObj("tab_list_view")
	-- self.rank_tab_toggle = self:FindObj("rank_tab_toggle")

	self.meili_tab_toggle = self:FindObj("meili_tab_toggle")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)
	-- self:OnClickSelect(6)
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	self.ming_tab_obj = self:FindObj("MingTabObj")
end

function RankView:ReleaseCallBack()
	self.toggle_type = 0
	self.toggle_index = 0
	self.is_on = {}

	if self.rank_content_view ~= nil then
		self.rank_content_view:DeleteMe()
		self.rank_content_view = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_list = {}
	if next(self.item_cell_list) then
		for k,v in pairs(self.item_cell_list) do
			for k2,v2 in pairs(v) do
				v2:DeleteMe()
				v2 = nil
			end
		end
	end
	self.item_cell_list = {}

	if self.rank_mingren_view ~= nil then
		self.rank_mingren_view:DeleteMe()
		self.rank_mingren_view = nil
	end
	self.index = 1
	PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)

	-- 清理变量和对象
	self.gold_text = nil
	self.bind_gold_text = nil
	self.show_ming_red_point = nil
	self.rotate_event_trigger = nil
	self.list_view = nil
	self.show_tab_list_view = nil
	self.meili_tab_toggle = nil
	self.is_cell_active = false
	self.show_btn_hl = nil
	self.show_left_bar = nil
	self.show_blue_bg = nil
	self.ming_tab_obj = nil
end

function RankView:OpenCallBack()
	self.jump_flag = true
	-- self.rank_tab_toggle.toggle.isOn = true

	if self.is_cell_active == true then
		self:CheckToJump()
		local rank_type_list = RankData.Instance:GetRankTypeList()
		self.rank_content_view:SetCurType(rank_type_list[self.index])
		RankCtrl.Instance:SendGetPersonRankListReq(rank_type_list[self.index])
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
	-- local scene_load_callback = function()
		-- self.show_blue_bg:SetValue(false)
	-- end

	-- self.show_blue_bg:SetValue(true)
	-- UIScene:SetUISceneLoadCallBack(scene_load_callback)
	-- UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai01", true}})
	self.show_ming_red_point:SetValue(RankData.Instance:GetRedPoint())
	RankCtrl.Instance:SendGetMarryRankListReq(PERSON_RANK_TYPE.COUPLE_RANK_TYPE_HUNYAN_RENQI)
	-- self:Flush()
	self.ming_tab_obj:SetActive(not LoginData.Instance:GetIsMerge())
end

function RankView:ShowIndexCallBack()
	local product_id = RankData.Instance:GetRankToProductId()
	if product_id.index > 0 then
		GlobalTimerQuest:AddDelayTimer(function()
			self:OnClickSelect(product_id.index - 1, product_id.rank_index)
		end, 1)
	else
		self:OnClickSelect(0)
	end
end

function RankView:OnFlush()
	self.rank_content_view:Flush()
end

function RankView:FlushMarryMyRank()
	self.rank_content_view:FlushMarryMyRank()
end

function RankView:GetNumberOfCells()
	return MAX_RANK_COUNT
end

function RankView:ChangePanelHeightMin()
	self.rank_content_view:ChangePanelHeightMin()
end

function RankView:ChangePanelHeightMax()
	self.rank_content_view:ChangePanelHeightMax()
end

function RankView:RefreshCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = RankTabItem.New(cell.gameObject,self)
		the_cell:SetToggleGroup(self.list_view.toggle_group)
		self.cell_list[cell] = the_cell
	end
	cell_index = cell_index + 1
	the_cell:SetIndex(cell_index)
	the_cell:Flush()
	self.is_cell_active = true
end

function RankView:LoadCell(index)
	local compose_item_list = Language.RankTogle.Testl[index]
	PrefabPool.Instance:Load(AssetID("uis/views/rank_prefab", "RankTogeleItemType"), function (prefab)
		if nil == prefab then
			return
		end

		local item_vo = {}
		for i=1,#compose_item_list do
			local obj = GameObject.Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.leftBarList[index].list.transform, false)
			obj:GetComponent("Toggle").group = self.leftBarList[index].list.toggle_group
			local item_cell = RankTogeleItem.New(obj)
			item_cell.parent_view = self
			item_cell:SetTogleIndex(index, i)
			item_cell:InitCell(compose_item_list[i])
			item_vo[i] = item_cell
		end
		self.item_cell_list[index] = item_vo
		PrefabPool.Instance:Free(prefab)
		
		--self.leftBarList[1].select_btn.accordion_element.isOn = true
	end)
	-- self:OnClickSelect(0)
end

function RankView:OnClickSelect(index, item_index)
	if index > 0 then
		self.show_btn_hl:SetValue(false)
		if self.leftBarList[index] then
			if self.is_on[index] then
				self.leftBarList[index].select_btn.accordion_element.isOn = false
			else
				self.leftBarList[index].select_btn.accordion_element.isOn = true
			end
		end
		if self.item_cell_list and self.item_cell_list[index] and self.item_cell_list[index][1]then
			if item_index and item_index > 0 then
				self.item_cell_list[index][item_index].root_node.toggle.isOn = true
				self.item_cell_list[index][item_index]:OnFlush()
			else
				self.item_cell_list[index][1].root_node.toggle.isOn = true
				self.item_cell_list[index][1]:OnFlush()
			end
		end
	else
		local rank_type_list = RankData.Instance:GetRankTypeList()
		self:SetToggleGroupIndex(RANK_TOGGLE_TYPE.DENG_JI_BANG, RANK_TOGGLE_TYPE.DENG_JI_BANG)
		self.show_btn_hl:SetValue(true)
		self.rank_content_view:SetCurType(RANK_TOGGLE_TYPE.DENG_JI_BANG)
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL)
		for i=1, TOGGLE_MAX do
			self.leftBarList[i].select_btn.accordion_element.interactable = true
		end	
	end

	if index == 0 then
		for i = 1, TOGGLE_MAX do
			self.is_on[i] = false
		end
	else
		for i = 1, TOGGLE_MAX do
			self.is_on[i] = self.leftBarList[i].select_btn.accordion_element.isOn
		end
	end
end

function RankView:ScrollerScrolledDelegate(go, param1, param2, param3)
	if self.is_cell_active and self.jump_flag == true then
		self:CheckToJump()
	end
end

function RankView:SetCurIndex(index)
	self.index = index
end

function RankView:GetCurIndex()
	return self.index
end

function RankView:SetTuanZhangMameValue()
	self.rank_content_view:SetTuanZhangMameValue()
end

function RankView:CheckToJump()
	local rank_type_list = RankData.Instance:GetRankTypeList()
	if self.rank_content_view:GerCurType() ~= rank_type_list[self.index] then
		self.rank_content_view:SetCurType(rank_type_list[self.index])
		if self.index >= 7 then
			self:BagJumpPage(7)
		else
			self:BagJumpPage(0)
		end
		self.jump_flag = false
	end
end

function RankView:GetJumpFlag()
	return self.jump_flag
end

function RankView:BagJumpPage(page)
	self.list_view.scroller:JumpToDataIndex(page)
end

function RankView:AddMoneyClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--顶部魅力榜按钮
function RankView:TopMeiLiClick(is_click)
	if is_click then
		-- self.show_tab_list_view:SetValue(false)
		if self.rank_content_view:GetCurType() ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_ALL_CHARM then
			self.meili_tab_toggle.toggle.isOn = true
			self.rank_content_view:SetCurType(PERSON_RANK_TYPE.PERSON_RANK_TYPE_ALL_CHARM)
			RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_ALL_CHARM)
		end
	end
end

-- --左侧魅力榜按钮
-- function RankView:TabMeiLiClick(is_click)

-- end

function RankView:FlushRedPoint()
	self.show_ming_red_point:SetValue(RankData.Instance:GetRedPoint())
end

function RankView:OnMingClick(is_click)
	if is_click then
		-- self.show_tab_list_view:SetValue(false)
		local rank_data = RankData.Instance
		if rank_data:GetRedPointFlag() == true then
			rank_data:SetRedPointFlag(false)
			RemindManager.Instance:Fire(RemindName.Rank)
		end
		self.show_ming_red_point:SetValue(RankData.Instance:GetRedPoint())
		RemindManager.Instance:Fire(RemindName.Rank)
		self.show_left_bar:SetValue(false)
	end
end

function RankView:RankClick(is_click)
	if is_click then
		-- self.show_tab_list_view:SetValue(true)
		local rank_type_list = RankData.Instance:GetGuoJiaRankListItem()
		if self.toggle_type > 0 and self.toggle_index > 0 then
			self.rank_content_view:SetCurType(rank_type_list[self.toggle_type][self.toggle_index])
			if self.toggle_type ~= 2 and self.toggle_index ~= 4 then
				RankCtrl.Instance:SendGetPersonRankListReq(rank_type_list[self.toggle_type][self.toggle_index])
			end
			
		else
			RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL)
		end
			self.show_left_bar:SetValue(true)	
	end
end

function RankView:CloseCallBack()
	self.index = 1
	if self.rank_content_view then
		self.rank_content_view:CancelTheQuest()
	end
	RankData.Instance:SetRankToProductId(0)
end

function RankView:OnCloseClick()
	self:Close()
end


function RankView:GetRankContentView()
	return self.rank_content_view
end

function RankView:SetToggleGroupIndex(index, type)
	self.toggle_index = index
	self.toggle_type = type
end

-- 玩家钻石改变时
function RankView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.gold_text:SetValue(CommonDataManager.ConverMoney(value))
	end
	if attr_name == "bind_gold" then
		self.bind_gold_text:SetValue(CommonDataManager.ConverMoney(value))
	end
end

function RankView:SetHighLighFalse()
	for k,v in pairs(self.cell_list) do
		v:SetHighLigh(false)
	end
end

-- function RankView:SetRendering(value)
-- 	BaseView.SetRendering(self, value)
-- 	if value then
-- 		if UIScene.scene_asset == nil or UIScene.scene_asset[1] ~= "scenes/map/jszs01" then
-- 			-- self.show_blue_bg:SetValue(true)
-- 			local scene_load_callback = function()
-- 				self.rank_content_view:Flush()
-- 				-- self.show_blue_bg:SetValue(false)
-- 			end
-- 			-- UIScene:SetUISceneLoadCallBack(scene_load_callback)
-- 			-- UIScene:ChangeScene(self, self.ui_scene, {[1] = {"Pingtai01", true}})
-- 		else
-- 			CheckCtrl.Instance:SendQueryRoleInfoReq(self.rank_content_view:GetCurRoleInfo().user_id)
-- 		end
-- 	end
-- end

function RankView:GetToggleGroupIndex()
	return self.toggle_index, self.toggle_type 
end
----------------------------------------------------------
RankTabItem = RankTabItem  or BaseClass(BaseCell)

function RankTabItem:__init(instance, parent)
	self.parent = parent
	self:ListenEvent("click",BindTool.Bind(self.OnItemClick, self))
	self.text = self:FindVariable("text")
	self.show_hl = self:FindVariable("show_hl")
	self.tab_icon = self:FindVariable("tab_icon")
end

function RankTabItem:__delete()
	self.parent = nil
end

function RankTabItem:OnFlush()
	self:FlushName()
end

function RankTabItem:SetHighLigh(show_hl)
	self.show_hl:SetValue(show_hl)
end

function RankTabItem:FlushName()
	if self.index == -1 then return end
	local rank_data = RankData.Instance
	local rank_type_list = rank_data:GetRankTypeList()
	local text = rank_data:GetTabName(rank_type_list[self.index])
	local cur_index = self.parent:GetCurIndex()
	self.text:SetValue(text)
	self.tab_icon:SetAsset(rank_data:GetTabAsset(self.index))
	self.show_hl:SetValue(cur_index == self.index)
	self.root_node.toggle.isOn = false
	self.root_node.toggle.isOn = cur_index == self.index
end

function RankTabItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function RankTabItem:OnItemClick(is_click)
	if is_click then
		if self.parent:GetCurIndex() ~= self.index or self.parent:GetJumpFlag() == true then
			local rank_type_list = RankData.Instance:GetRankTypeList()
			RankCtrl.Instance:SendGetPersonRankListReq(rank_type_list[self.index])
			self.parent:SetHighLighFalse()
			self.show_hl:SetValue(true)
			self.parent:SetCurIndex(self.index)
			self.parent:GetRankContentView():SetCurType(rank_type_list[self.index])
		end
	end
end




---------------------------------------------------------------------------
RankTogeleItem = RankTogeleItem or BaseClass(BaseCell)
function RankTogeleItem:__init(instance)
	self.name = self:FindVariable("Name")
	self.num = self:FindVariable("Num")
	self.item_id = 0
	self.togle_index = 0
	self.toggle_type = 0
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnItemClick, self))
	self.can_buy_num = 0
	self.parent_view = nil
end

function RankTogeleItem:__delete()
	self.can_buy_num = nil
	self.item_id = nil
	self.parent_view = nil
end

function RankTogeleItem:SetTogleIndex(type, index)
	self.togle_index = index
	self.toggle_type = type
end

function RankTogeleItem:InitCell(item_id)
	self.item_id = item_id
	self.name:SetValue(self.item_id)
	--self:FlushNum()
end

function RankTogeleItem:OnFlush()
	self:OnItemClick(true)
end

function RankTogeleItem:FlushNum()
	self:SetHighLight()
end

-- 设置手风琴控件高亮
function RankTogeleItem:SetHighLight()
	if self.togle_index == RANK_TOGGLE_TYPE.ZHAN_LI_BANG and self.toggle_type == RANK_TOGGLE_INDEX.SHOU_FENG_QING_1 then
		self.root_node.toggle.isOn = true
	end
end

function RankTogeleItem:GetCanBuyNum()
	return self.can_buy_num
end

function RankTogeleItem:SetItemActive(is_active)
	self.root_node:SetActive(is_active)
end

function RankTogeleItem:OnItemClick(is_click)
	self.parent_view:SetToggleGroupIndex(self.togle_index, self.toggle_type)
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	if is_click then
		local rank_type_list = RankData.Instance:GetGuoJiaRankListItem()
		RankContentView.Instance:SetCurType(rank_type_list[self.toggle_type][self.togle_index])
		if self.toggle_type == RANK_TOGGLE_TYPE.RONG_YU_BANG and self.togle_index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_3 then
			RankCtrl.Instance:SendGetGuildRankListReq(RANK_GUILD_TYPE.GUILD_RANK_TYPE_GUILD_KILL_NUM)
		elseif self.toggle_type == RANK_TOGGLE_TYPE.SHE_JIAO_BANG and self.togle_index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_4 then
			RankCtrl.Instance:SendGetMarryRankListReq(PERSON_RANK_TYPE.COUPLE_RANK_TYPE_HUNYAN_RENQI)
		elseif self.toggle_type == RANK_TOGGLE_TYPE.RONG_YU_BANG and self.togle_index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_4 then
			RankCtrl.Instance:SendGetGuildRankListReq(RANK_GUILD_SEND[role_vo.camp])
		else
			RankCtrl.Instance:SendGetPersonRankListReq(rank_type_list[self.toggle_type][self.togle_index])
		end
		self.is_first = false
	end
end

function RankTogeleItem:GetItemId()
	return self.item_id
end
