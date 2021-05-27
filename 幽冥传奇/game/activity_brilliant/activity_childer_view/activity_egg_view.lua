ZanDangView = ZanDangView or BaseClass(ActBaseView)

function ZanDangView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ZanDangView:__delete()
	if self.egg_cap ~= nil then
		self.egg_cap:DeleteMe()
		self.egg_cap = nil
	end

	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
	if nil ~= self.show_item then
		self.show_item:DeleteMe()
		self.show_item = nil
	end
	if nil ~= self.show_list then
		self.show_list:DeleteMe()
		self.show_list = nil
	end
end

function ZanDangView:InitView()
 	self.cell_list = {}
	self:CreateEggNum()
	self:CreateShowList()
	self:EggAddClickEventListener()
	self.show_item = ActivityShowItem.New()
end

function ZanDangView:RefreshView()
	local destor_list = ActivityBrilliantData.Instance:GetDestorList()
	-- local draw_num = ActivityBrilliantData.Instance.mine_num[ACT_ID.EGG] -- 数量不正确,一直为零 弃用
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.EGG)
	local show_list = {}
	for i,v in ipairs(cfg.config.show_list or {}) do
		show_list[i] = ItemData.InitItemDataByCfg(v)
	end
	self.show_list:SetDataList(show_list)
	self.show_list:JumpToTop()
	self.egg_cap:SetNumber(ActivityBrilliantData.Instance:GetEggGold())
	local draw_num = 0
	for k,v in ipairs(destor_list) do
		if v.sign == 1 then
			draw_num = draw_num + 1
			local data = nil
			local scale_num = 1
			if k >= 10 then
				data = cfg.config.supereggaward[k-9]
				self.node_t_list["img_egg_" .. k].node:loadTexture(ResPath.GetActivityBrilliant("act_34_2_open"))
			else
				data = cfg.config.egg_award[v.award_idx].award
				self.node_t_list["img_egg_" .. k].node:loadTexture(ResPath.GetActivityBrilliant("act_34_1_open"))
				scale_num = 0.9
			end

			local item_cfg = data[v.idx]
			if nil ~= item_cfg then 
				if nil == self.cell_list[k] then
					local cell = ActBaseCell.New()
					local ph = self.ph_list["ph_egg_cel_" .. k]
					cell:SetPosition(ph.x, ph.y - 10)
					cell:SetIndex(i)
					cell:SetCellBg()
					cell:SetAnchorPoint(0.5, 0.5)
					cell:GetView():setScale(scale_num)
					self.cell_list[k] = cell
					self.node_t_list["layout_egg"].node:addChild(cell:GetView(), 300)
				end
				self.cell_list[k]:SetData({item_id = item_cfg.id, num = item_cfg.count, is_bind = 0})
				self.cell_list[k]:SetVisible(true)
				self.cell_list[k]:SetRightBottomText(item_cfg.count, COLOR3B.GREEN)
				XUI.EnableOutline(self.cell_list[k].right_bottom_text)
			else
				if nil ~= self.cell_list[k] then 
					self.cell_list[k]:SetVisible(false)
				end
			end
		else
			if k < 10 then
				self.node_t_list["img_egg_" .. k].node:loadTexture(ResPath.GetActivityBrilliant("act_34_1"))
			else
				self.node_t_list["img_egg_" .. k].node:loadTexture(ResPath.GetActivityBrilliant("act_34_2"))
			end
			if nil ~= self.cell_list[k] then 
				self.cell_list[k]:SetVisible(false)
			end
		end
	end
	self.node_t_list.lbl_cegg_num.node:setString(draw_num)
end

function ZanDangView:EggAddClickEventListener()
	for i = 1, 12 do
		XUI.AddClickEventListener(self.node_t_list["img_egg_" .. i].node, BindTool.Bind(self.OnClickEgg, self, i), false)
	end
end

function ZanDangView:CreateEggNum()
	local ph = self.ph_list["ph_gold_count"]
	self.egg_cap = NumberBar.New()
	self.egg_cap:SetRootPath(ResPath.GetCommon("num_4_"))
	self.egg_cap:SetPosition(ph.x, ph.y)
	self.egg_cap:SetSpace(-8)
	self.egg_cap:SetGravity(NumberBarGravity.Center)
	self.node_t_list.layout_egg.node:addChild(self.egg_cap:GetView(), 300, 300)
end

function ZanDangView:OnClickEgg(tag)
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.EGG)
	local destor_list = ActivityBrilliantData.Instance:GetDestorList()
	local idx = destor_list[tag].idx
	local data = nil
	if tag >= 10 then
		data = cfg.config.supereggaward[tag - 9]
	else
		data = cfg.config.egg_award[tag].award
	end
	local act_id = ACT_ID.EGG
	local destor_list = ActivityBrilliantData.Instance:GetDestorList()
	if destor_list[tag].sign == 1 then
		TipCtrl.Instance:OpenItem({item_id = data[idx].id, num =  data[idx].count, is_bind = 0}, EquipTip.FROM_NORMAL)
	else
		local callback = cc.CallFunc:create(function ()
	   		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, tag)
	   	end)
	   	local action_left = cc.RotateTo:create(0.03, 5)
	   	local action_right = cc.RotateTo:create(0.03, -5)
	   	local action_revant = cc.RotateTo:create(0.03, 0)
	   	self.node_t_list["img_egg_" .. tag].node:runAction(cc.Sequence:create(action_left, action_right, action_revant, callback))
	end
   
end

function ZanDangView:OnClickCEgg(tag)
	local act_id = ACT_ID.EGG
   	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, tag)
end

function ZanDangView:UpdateSpareTime(end_time)
	local now_time = TimeCtrl.Instance:GetServerTime()
	local str = TimeUtil.FormatSecond2Str(end_time - now_time)
	self.node_t_list["lbl_cegg_spare_time"].node:setString(str)
end

function ZanDangView:CreateShowList()
	local ph = self.ph_list["ph_show_list"]
	self.show_list = ListView.New()
	self.show_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.show_list:SetItemsInterval(10)
	self.node_t_list["layout_egg"].node:addChild(self.show_list:GetView(), 10)
end