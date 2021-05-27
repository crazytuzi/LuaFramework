AdVancedLevelMoshuUpView = AdVancedLevelMoshuUpView or BaseClass(BaseView)
function AdVancedLevelMoshuUpView:__init()
	-- self.title_img_path = ResPath.GetWord("title_jinjie")
	self:SetModal(true)
	self.is_any_click_close = true	
	self.texture_path_list = {
		'res/xui/role.png',
		'res/xui/advanced_level.png',
		'res/xui/bag.png',
	}
	self.config_tab = {
		{"advance_ui_cfg", 2, {0}},
		--{"common_ui_cfg", 2, {0}, nil, 999},
		--{"common_ui_cfg", 3, {0}},
	}

	-- self.btn_info = {ViewDef.Advanced.Moshu,ViewDef.Advanced.YuanSu, ViewDef.Advanced.ShengShou, ViewDef.Role.ZhuanSheng,}

	self.data = nil 
end

function AdVancedLevelMoshuUpView:__delete()
	-- body
end

function AdVancedLevelMoshuUpView:LoadCallBack()
	self.moshu_change = GlobalEventSystem:Bind(JINJIE_EVENT.NOSHU_CHANGE, BindTool.Bind1(self.OnMoShuChange,self))
	self:CreateGridList()
	self:CreateCell()
	self:CreateNextAttrList()
	self:CreateCurAttrList()
	self:CreateNumBar()
	XUI.AddClickEventListener(self.node_t_list.btn_use.node, BindTool.Bind1(self.UseItem, self), true)
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

function AdVancedLevelMoshuUpView:ItemDataListChangeCallback( ... )
	self:FlushShow()
end

function AdVancedLevelMoshuUpView:UseItem()
	if self.data then
		local series = BagData.Instance:GetItemSeriesInBagById(self.data.item_id)
		if series then
			AdvancedLevelCtrl.SendInnerEquipReq(series)
		else
			TipCtrl.Instance:OpenGetStuffTip(self.data.item_id)
		end
	end
end


function AdVancedLevelMoshuUpView:CreateNumBar()
	if nil == self.cur_num then
		local ph = self.ph_list.ph_cur_number
		self.cur_num = NumberBar.New()
	    self.cur_num:Create(ph.x + 5, ph.y -10, 0, 0, ResPath.GetCommon("num_133_"))
	    self.cur_num:SetGravity(NumberBarGravity.Center)
	    self.cur_num:SetSpace(-7)
	    self.cur_num:SetScale(0.3) 
	    self.node_t_list.layout_moshu_up.node:addChild(self.cur_num:GetView(), 101)
	end
	if nil == self.next_num then
		local ph = self.ph_list.ph_next_number
		self.next_num = NumberBar.New()
	    self.next_num:Create(ph.x + 5, ph.y - 10, 0, 0, ResPath.GetCommon("num_133_"))
	    self.next_num:SetGravity(NumberBarGravity.Center)
	    self.next_num:SetSpace(-7)
	   
	  	self.node_t_list.layout_moshu_up.node:addChild(self.next_num:GetView(), 101)
	end
end

function AdVancedLevelMoshuUpView:OnMoShuChange()
	self:SetEquipData()
	self:FlushShow()
end

function AdVancedLevelMoshuUpView:CreateCell()
	if self.consume_cell == nil then
		local ph = self.ph_list.ph_consume_cell
		self.consume_cell = BaseCell.New()
		self.consume_cell:SetPosition(ph.x, ph.y)
		self.consume_cell:SetScale(0.8)
		self.node_t_list.layout_moshu_up.node:addChild(self.consume_cell:GetView(), 99)
	end
end

function AdVancedLevelMoshuUpView:CreateCurAttrList()
	if nil == self.cur_attr_list then
		local ph = self.ph_list.ph_list1--获取区间列表
		self.cur_attr_list = ListView.New()
		self.cur_attr_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, AdvancedItemAttr, nil, nil, self.ph_list.ph_item1)
		self.cur_attr_list:SetItemsInterval(5)--格子间距
		self.cur_attr_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_moshu_up.node:addChild(self.cur_attr_list:GetView(), 20)

		self.cur_attr_list:GetView():setAnchorPoint(0, 0)
	end
end


function AdVancedLevelMoshuUpView:CreateNextAttrList()
	if nil == self.next_attr_list then
		local ph = self.ph_list.ph_list2--获取区间列表
		self.next_attr_list = ListView.New()
		self.next_attr_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, AdvancedItemAttr, nil, nil, self.ph_list.ph_item2)
		self.next_attr_list:SetItemsInterval(5)--格子间距
		self.next_attr_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_moshu_up.node:addChild(self.next_attr_list:GetView(), 20)

		self.next_attr_list:GetView():setAnchorPoint(0, 0)
	end
end


function AdVancedLevelMoshuUpView:CreateGridList()
	if nil == self.list_equip then
		local ph = self.ph_list.ph_grid_list1--获取区间列表
		self.list_equip = ListView.New()
		self.list_equip:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ShuLingEquipItemUp, nil, nil, self.ph_list.ph_item_dan)
		self.list_equip:SetItemsInterval(30)--格子间距
		self.list_equip:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_moshu_up.node:addChild(self.list_equip:GetView(), 20)
		self.list_equip:SetSelectCallBack(BindTool.Bind(self.SelectEquipListCallback, self))
		self.list_equip:GetView():setAnchorPoint(0, 0)
	end
end

function AdVancedLevelMoshuUpView:SetEquipData()
	local consume = InnerConfig.ConsumeId
	local data = {}
	for k,v in pairs(consume) do
		local cur_data = {}
		cur_data.index = k
		cur_data.item_id = v
		table.insert(data, cur_data)
	end
	self.list_equip:SetDataList(data)
end

function AdVancedLevelMoshuUpView:SelectEquipListCallback(item)
	if item == nil or item:GetData() == nil then
		return 
	end
	self.data = item:GetData()
	self:FlushShow()
end

function AdVancedLevelMoshuUpView:SetData(data)
	self.data = data
	
	self:Flush(index)
end


function AdVancedLevelMoshuUpView:OpenCallBack()
	-- body
end



function AdVancedLevelMoshuUpView:ShowIndexCallBack()
	self:Flush(index)
end

function AdVancedLevelMoshuUpView:ReleaseCallBack()
	if self.moshu_change then
		GlobalEventSystem:UnBind(self.moshu_change)
		self.moshu_change = nil 
	end

	if self.list_equip then
		self.list_equip:DeleteMe()
		self.list_equip = nil 
	end

	if self.consume_cell then
		self.consume_cell:DeleteMe()
		self.consume_cell = nil 
	end

	if self.cur_attr_list then
		self.cur_attr_list:DeleteMe()
		self.cur_attr_list = nil
	end


	if self.next_attr_list then
		self.next_attr_list:DeleteMe()
		self.next_attr_list = nil
	end

	if self.cur_num then
		self.cur_num:DeleteMe()
		self.cur_num = nil 
	end

	if self.next_num then
		self.next_num:DeleteMe()
		self.next_num = nil 
	end
end

function AdVancedLevelMoshuUpView:CloseCallBack()
	-- body
end

function AdVancedLevelMoshuUpView:OnFlush()
	if self.data then
		self:SetEquipData()
		if self.list_equip then
			self.list_equip:SelectIndex(self.data.index)
		end
		self:FlushShow()
	end
end

function AdVancedLevelMoshuUpView:FlushShow()
	if self.data == nil then
		return
	end
	local path = ResPath.GetJinJiePath("shayudan1")
	if self.data.index == 2 then
		path = ResPath.GetJinJiePath("xueyadan1")
	elseif self.data.index == 3 then
		path = ResPath.GetJinJiePath("zhihuangdan1")
	end
	self.node_t_list.img_name.node:loadTexture(path)
	self.node_t_list.img_next_name.node:loadTexture(path)

	local num1 = BagData.Instance:GetItemNumInBagById(self.data.item_id)
	if self.consume_cell then
		self.consume_cell:SetData({item_id = self.data.item_id, num = 1,is_bind = 0})
	end

	local text = num1 .. "/"..1 
	local color = num1 >= 1 and COLOR3B.GREEN or COLOR3B.RED
	self.consume_cell:SetRightBottomText(text, color)

	local had_num =  AdvancedLevelData.Instance:GetHadNumByIndex(self.data.index - 1) or 0

	local cur_attr = AdvancedLevelData.GetOneEquipAttr(self.data.index, had_num)

	local cur_attr_list = RoleData.FormatRoleAttrStr(cur_attr)


	local next_attr = AdvancedLevelData.GetOneEquipAttr(self.data.index, had_num + 1)
	local next_attr_list = RoleData.FormatRoleAttrStr(next_attr)

	self.cur_attr_list:SetDataList(cur_attr_list)

	self.next_attr_list:SetDataList(next_attr_list)

	 self.cur_num:SetNumber(had_num)
	 self.cur_num:SetScale(0.8)
	 self.next_num:SetNumber(had_num + 1)
	 self.next_num:SetScale(0.8) 

	local inner_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL)
	local cur_cfg = AdvancedLevelData.GetInnerCfg(inner_level)

	local vis = true
	if cur_cfg and cur_cfg.InjectionLimit <= had_num then
		vis = false
	end	
	self.consume_cell:SetVisible(vis)
	local need_level = cur_cfg and cur_cfg.consume_lv or 0
	local need_step =  AdvancedLevelData.Instance:CanGetStepByLevel(need_level)
	-- print("<<<<<<<",need_level)
	local need_cfg = AdvancedLevelData.GetInnerCfg(need_level + 1, prof)
	local text = "" 
	if need_cfg and (not vis) then
		local limit = need_cfg.InjectionLimit
		text = string.format(Language.Advanced.TipsShow2, need_step, limit)
	end 
	RichTextUtil.ParseRichText(self.node_t_list.text_show_tip.node, text, 18, COLOR3B.RED)
	XUI.RichTextSetCenter(self.node_t_list.text_show_tip.node)
end


ShuLingEquipItemUp = ShuLingEquipItemUp or BaseClass(BaseRender)
function ShuLingEquipItemUp:__init()
	-- body
end

function ShuLingEquipItemUp:__delete()
	if self.had_number then
		self.had_number:DeleteMe()
		self.had_number = nil 
	end
end

function ShuLingEquipItemUp:CreateChild()
	BaseRender.CreateChild(self)

	if nil == self.had_number then
		local ph = self.ph_list.ph_number
		self.had_number = NumberBar.New()
	    self.had_number:Create(ph.x, ph.y, 0, 0, ResPath.GetCommon("num_133_"))
	    self.had_number:SetGravity(NumberBarGravity.Center)
	    self.had_number:SetSpace(-8)
	    self.view:addChild(self.had_number:GetView(), 101)
	end

end


function ShuLingEquipItemUp:OnFlush()
	if self.data == nil then
		return
	end
	local config = ItemData.Instance:GetItemConfig(self.data.item_id)
	local icon = config.icon 
	self.node_tree.ph_path_1.node:loadTexture(ResPath.GetItem(icon))

	local num = BagData.Instance:GetItemNumInBagById(self.data.item_id)

	local inner_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL)
	local cur_cfg = AdvancedLevelData.GetInnerCfg(inner_level)
	local use_num = AdvancedLevelData.Instance:GetHadNumByIndex(self.data.index - 1) or 0
	local  vis = false

	--达到开放等级且该等级上限未用完，并且背包数量未用完
	if (num >= 1) and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) >= InnerConfig.openAptitude and ((cur_cfg and cur_cfg.InjectionLimit or 0) > use_num)then
		vis = true
	end
	self.node_tree.remind_img_1.node:setVisible(vis)

	local path = ResPath.GetJinJiePath("shayudan")
	if self.data.index == 2 then
		path = ResPath.GetJinJiePath("xueyadan")
	elseif self.data.index == 3 then
		path = ResPath.GetJinJiePath("zhihuangdan")
	end
	self.node_tree.img_name1.node:loadTexture(path)
	--local num = AdvancedLevelData.Instance:GetHadNumByIndex(self.data.index - 1) or 0
	if use_num > 0 then
		self.had_number:SetNumber(use_num) 
		self.had_number:SetScale(0.8)
	end

end


AdvancedItemAttr = AdvancedItemAttr or BaseClass(BaseRender)
function AdvancedItemAttr:__init()
	-- body
end

function AdvancedItemAttr:__delete()
	-- body
end

function AdvancedItemAttr:CreateChild()
	BaseRender.CreateChild(self)
end

function AdvancedItemAttr:OnFlush()
	if self.data == nil then return end
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str.."：")
	self.node_tree.lbl_this_time_poist.node:setString(self.data.value_str)
end

function AdvancedItemAttr:CreateSelectEffect()
	
end
