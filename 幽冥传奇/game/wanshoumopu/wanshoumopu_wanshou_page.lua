--万兽界面
WanshoumopuWanshouPage = WanshoumopuWanshouPage or BaseClass()
function WanshoumopuWanshouPage:__init()

end	

function WanshoumopuWanshouPage:__delete()
	self:RemoveEvent()	
	self.view = nil

	if self.wanshou_list then
		self.wanshou_list:DeleteMe()
		self.wanshou_list = nil
	end
end	

--初始化页面接口
function WanshoumopuWanshouPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:InitEvent()
	self:CreateshowList()
	self.select_index = 1
end	
--初始化事件
function WanshoumopuWanshouPage:InitEvent()

end

function WanshoumopuWanshouPage:CreateshowList()
	local ph = self.view.ph_list.ph_wanshou_list
	self.wanshou_list = ListView.New()
	self.wanshou_list:Create(ph.x, ph.y, ph.w, ph.h, direction, WanMoRender, nil, false, self.view.ph_list.ph_wanshou_item)
	self.wanshou_list:SetItemsInterval(3)
	self.wanshou_list:SetMargin(3)
	self.wanshou_list:GetView():setAnchorPoint(0, 0)
	
	-- self.wanshou_list:JumpToTop(false)
	-- self.wanshou_list:SetSelectCallBack(BindTool.Bind(self.SelectTypeCallback, self))
	self.view.node_t_list.layout_wanshou.node:addChild(self.wanshou_list:GetView(), 100)
end

--移除事件
function WanshoumopuWanshouPage:RemoveEvent()
	
end

--更新视图界面
function WanshoumopuWanshouPage:UpdateData(data)
	self.wanshou_list:SetJumpDirection(ListView.Top)
	local real_data = WanShouMoPuData.Instance:GetWanshouDataByType(1)
	self.wanshou_list:SetDataList(real_data)
end

function WanshoumopuWanshouPage:FlushData(data)
	local real_data = WanShouMoPuData.Instance:GetWanshouDataByType(1)
	self.wanshou_list:SetDataList(real_data)
end

WanMoRender = WanMoRender or BaseClass(BaseRender)
function WanMoRender:__init()
	self.wanshou_cell = nil
end

function WanMoRender:__delete()
	if self.wanshou_cell then
		self.wanshou_cell:DeleteMe()
		self.wanshou_cell = nil
	end
	if nil ~= self.cell_gift_list then
		for k, v in pairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = nil
	end
end

function WanMoRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_wanshou_cell
	self.wanshou_cell = BaseCell.New()
	self.wanshou_cell:SetPosition(ph.x, ph.y)
	self.view:addChild(self.wanshou_cell:GetView(),999)
	self.node_tree.btn_finish.node:addClickEventListener(BindTool.Bind(self.GetFinish, self))
	self.node_tree.btn_map.node:addClickEventListener(BindTool.Bind(self.FlyMap, self))
	self.cell_gift_list = {}
	for i = 1, 3 do
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_wanshou_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		self.view:addChild(cell:GetView(), 300)
		table.insert(self.cell_gift_list, cell)
	end
end

function WanMoRender:OnFlush()
	if not self.data then return end
	-- local boss_id = self.data.bossInfo[1]
	local boss_data = ConfigManager.Instance:GetMonsterConfig(self.data.bossId)
	self.node_tree.img_icon.node:loadTexture(ResPath.GetBossHead("boss_icon_" .. boss_data.icon))
	self.node_tree.txt_boss_name.node:setString(boss_data.name)
	self.node_tree.txt_boss_level.node:setString(boss_data.level)
	local itemid = self.data.consume[1].id
	local item_data = ItemData.Instance:GetItemConfig(itemid)
	local id = ItemData.Instance:GetVirtualItemId(self.data.award[1].type)
	local award_data = ItemData.Instance:GetItemConfig(id)
	self.node_tree.txt_cosume.node:setString(item_data.name)
	local num = ItemData.Instance:GetItemNumInBagById(self.data.consume[1].id, nil)
	if num > 0 then
		RichTextUtil.ParseRichText(self.node_tree.txt_num.node, num .."/" .. self.data.consume[1].count, 20, COLOR3B.GREEN)
	else
		RichTextUtil.ParseRichText(self.node_tree.txt_num.node, num .."/" .. self.data.consume[1].count, 20, COLOR3B.RED)
	end	
	self.wanshou_cell:SetData({item_id = itemid, num = 1, is_bind = 0})
	local cur_data = {}
	for i, v in ipairs(self.data.award) do
		if v.id == 0 then
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
			if virtual_item_id then
				cur_data[i] = {["item_id"] = virtual_item_id, ["num"] = 1, is_bind = 0}
			end
		else
			cur_data[i] = {item_id = v.id, num = 1, is_bind = 1}
		end
	end
	local vis = false
	for i1, v1 in ipairs(cur_data) do
		for i1 = 1, 3 do
			vis = cur_data[i1] and true or false
			self.cell_gift_list[i1]:GetView():setVisible(vis)
		end
		self.cell_gift_list[i1]:SetData(v1)
	end
	self.node_tree.txt_award.node:setString("X" .. self.data.award[1].count )
	self.node_tree.txt_baotu.node:setString("X" .. self.data.award[2].count )
	self.node_tree.txt_award_1.node:setString("X" .. self.data.award[3].count )
	-- local scene_name = BossData.Instance:GetSceneCfg(self.data.posInfo[1])
	-- self.node_tree.btn_map.node:setTitleText(scene_name)
	local iss_index = WanShouMoPuData.Instance:GetTime()
	local txt = ""
	local bool = false
	if self.data.index == iss_index then
		txt = Language.AllDayActivity.wanshoumopu_state[2]
		bool =true
		self.node_tree.txt_remind.node:setVisible(false)
	elseif self.data.index > iss_index then
		txt = Language.AllDayActivity.wanshoumopu_state[2]
		bool = false
		self.node_tree.txt_remind.node:setVisible(true)
	else
		txt = Language.AllDayActivity.wanshoumopu_state[1]
		bool = false
		self.node_tree.txt_remind.node:setVisible(false)
		
	end
	self.node_tree.btn_finish.node:setEnabled(bool)
	self.node_tree.btn_finish.node:setTitleText(txt)
end
function WanMoRender:GetFinish()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 人物等级
	local circle_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)		-- 人物转生等级
	if circle_level <=	self.data.level[1] then
		if role_level>=self.data.level[2] then
			local index = WanShouMoPuData.Instance:GetTime()
			WanShouMoPuCtrl.Instance:FinishReq(index)
		else
			-- if 	self.data.level[2] == 60 then
			-- 	SysMsgCtrl.Instance:FloatingTopRightText(Language.AllDayActivity.wanshou_level)
			-- else	
			SysMsgCtrl.Instance:FloatingTopRightText(string.format(Language.AllDayActivity.wanmo_level,self.data.level[2]))
			-- end	
		end	
	else	
		local index = WanShouMoPuData.Instance:GetTime()
		WanShouMoPuCtrl.Instance:FinishReq(index)
	end	
	self:Flush()
end
function WanMoRender:FlyMap()
	if self.data.tele_id ~= nil then
		Scene.Instance:CommonSwitchTransmitSceneReq(self.data.tele_id)
	else
		Scene.Instance:GetMainRole():LeaveFor(self.data.posInfo[1], self.data.posInfo[2], self.data.posInfo[3], MoveEndType.FightByMonsterId, self.data.bossId)
	end
	ViewManager.Instance:Close(ViewName.WanShouMoPu)
end