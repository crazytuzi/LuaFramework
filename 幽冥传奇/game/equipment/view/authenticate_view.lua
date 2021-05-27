------------------------------------------------------------
-- 锻造-鉴定 视图 配置:EquipSlotAppsalAttrsCfg
------------------------------------------------------------

local AuthenticateView = BaseClass(SubView)

function AuthenticateView:__init()
	self.texture_path_list = {
		'res/xui/appraisal.png',
		'res/xui/equipment.png',
	}

	self.config_tab = {
		{"equipment_ui_cfg", 7, {0}},
	}

	self.consume_data = {}	-- 消耗数据-缓存 用于判断打开引导面板
	self.is_tihuan = 0
end

function AuthenticateView:__delete()
end

function AuthenticateView:ReleaseCallBack()

	if self.equip_list then
		for i,v in ipairs(self.equip_list) do
			v:DeleteMe()
		end
		self.equip_list = nil
	end

	if self.attr_list then
		self.attr_list:DeleteMe()
		self.attr_list = nil
	end

	if self.new_attr_list then
		self.new_attr_list:DeleteMe()
		self.new_attr_list = nil
	end

	self.consume_data = {}
end

function AuthenticateView:LoadCallBack(index, loaded_times)
	self.select_equip_index = 1
	-- 身上穿的装备列表
	self.equip_data_list = EquipData.Instance:GetEquipData()
	self:CreateCells()
	self:CreateAttrList()
	--按钮监听
	XUI.AddClickEventListener(self.node_t_list.btn_equjd_ques.node, BindTool.Bind2(self.OpenTip, self))
	XUI.AddClickEventListener(self.node_t_list.btn_xilian.node, BindTool.Bind2(self.OnEquipJD, self, 1))--鉴定
	XUI.AddClickEventListener(self.node_t_list.btn_tihuan.node, BindTool.Bind2(self.OnEquipJD, self, 2))--替换
	XUI.AddClickEventListener(self.node_t_list.btn_attr.node, BindTool.Bind2(self.OpenSuitAttr, self))--套装
	-- 数据监听
	EventProxy.New(AuthenticateData.Instance, self):AddEventListener(AuthenticateData.AUTHENTICATE_DATA_CHANGE, BindTool.Bind(self.OnAuthenticateDataChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(AuthenticateData.Instance, self):AddEventListener(AuthenticateData.RESULT, BindTool.Bind(self.FlushResult, self))

end

function AuthenticateView:OpenTip()
    DescTip.Instance:SetContent(Language.DescTip.MeridiansContent, Language.DescTip.MeridiansTitle)
end

function AuthenticateView:OpenSuitAttr()
	EquipmentCtrl.Instance:OpenSuitAttr(3)
end

function AuthenticateView:FlushResult()
	if self.is_tihuan == 2 then
		for i,v in ipairs(self.attr_list:GetAllItems()) do
			v:ShowFlash()
		end
	end
end


function MeridiansView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MeridiansView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.select_equip_index = 1
end

function AuthenticateView:CreateAttrList()
	local ph = self.ph_list.ph_attr_list
	local parent = self.node_t_list["layout_jding"].node
	self.attr_list = ListView.New()
	self.attr_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.AttrTextRender, nil, nil, self.ph_list.ph_attr_txt_item)
	self.attr_list:SetItemsInterval(4)
	self.attr_list:SetMargin(2)
	-- self.attr_list:SetAutoSupply(true)
	parent:addChild(self.attr_list:GetView(), 50)

	local ph = self.ph_list.ph_new_attr_list
	self.new_attr_list = ListView.New()
	self.new_attr_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.NewAttrRender, nil, nil, self.ph_list.ph_new_attr_txt_item)
	self.new_attr_list:SetItemsInterval(4)
	self.new_attr_list:SetMargin(2)
	-- self.new_attr_list:SetAutoSupply(true)
	parent:addChild(self.new_attr_list:GetView(), 50)
end

--显示索引回调
function AuthenticateView:ShowIndexCallBack(index)
	self:Flush()
end

function AuthenticateView:OnFlush()
	self:FlushEquipList()
	self:FlushSelectEquip()
	self:FlushSelectConsume()
	self:FlushAttrList()
end

function AuthenticateView:OnEquipJD(index)
	self.is_tihuan = index

	local item_id = index == 1 and 2278 or 2279
	local lock_num = AuthenticateData.Instance:GetLockNum()
	lock_num = lock_num > 4 and 4 or lock_num
	local cfg_count_1 = lock_num ~= 0 and EquipSlotAppsalAttrsCfg.lockConsumes[lock_num].count or 0

	local count = index == 2 and cfg_count_1 or 2

	local item = ShopData.GetItemPriceCfg(item_id)
	local n = BagData.Instance:GetItemNumInBagById(item_id, nil)
	if n >= count then
		local lock = AuthenticateData.Instance:LockState()

   		AuthenticateCtrl.SendAuthenticateReq(index, self.select_equip_index-1, 1, nil, nil, lock)
	else
		-- if item then
		-- 	TipCtrl.Instance:OpenQuickTipItem(false, {item_id, item.price[1].type, 1})
		-- else
		-- 	TipCtrl.Instance:OpenGetStuffTip(item_id)
		-- end
		TipCtrl.Instance:OpenGetNewStuffTip(item_id)
	end


end

----------视图函数----------

function AuthenticateView:CreateCells()
	local ph, cell
	local parent = self.node_t_list["layout_jding"].node
	local rander_ph = self.ph_list.ph_qh_item

	self.equip_list = {}
	for i = 1, 10 do
		cell = AuthenticateView.JianDingRender.New()
		cell:SetUiConfig(rander_ph, true)
		ph = self.ph_list["ph_authenticate_cell_" .. i]
		cell.ignore_data_to_select = true -- 是否可选中
		cell:SetIndex(i)
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setAnchorPoint(0.5, 0.5)
		-- cell:SetIsShowTips(false)
		cell:AddClickEventListener(BindTool.Bind(self.OnEquip, self))

		-- local path = ResPath.GetEquipment("equipment_img_" .. i)
		-- cell:SetBgTa(path)
		XUI.AddRemingTip(cell:GetView(), nil, nil, 15)
		parent:addChild(cell:GetView(), 99)

		self.equip_list[i] = cell
	end

	ph = self.ph_list["ph_consume_1"]
	cell = BaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	-- cell:SetCellBgVis(false)
	cell:GetView():setAnchorPoint(0.5, 0.5)
	parent:addChild(cell:GetView(), 2)
	self.consume_cell_1 = cell
	
	ph = self.ph_list["ph_consume_2"]
	cell = BaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	-- cell:SetCellBgVis(false)
	cell:GetView():setAnchorPoint(0.5, 0.5)
	parent:addChild(cell:GetView(), 2)
	self.consume_cell_2 = cell

	-- 消耗物品图标
	local item_1 = {["item_id"] = 2279, ["num"] = 1, ["is_bind"] = 0,}
	local item_2 = {["item_id"] = 2278, ["num"] = 1, ["is_bind"] = 0,}
	self.consume_cell_1:SetData(item_1)
	self.consume_cell_2:SetData(item_2)
	-- XUI.SetLayoutImgsGrey(self.consume_cell_1:GetView(), not can_anuthenticate)
	-- XUI.SetLayoutImgsGrey(self.consume_cell_2:GetView(), not can_anuthenticate)
end

function AuthenticateView:FlushEquipList()
	for i, v in ipairs(self.equip_list) do
		local equip_data = EquipData.Instance:GetEquipDataBySolt(i -1)
		v:SetData(equip_data)
		v:SetSelect(i == self.select_equip_index)

		if equip_data then
			
			local has_count = BagData.Instance:GetItemNumInBagById(2278)

			local vis = has_count >= 2
			v:GetView():UpdateReimd(vis)
		else
			v:GetView():UpdateReimd(false)
		end
	end
end

function AuthenticateView:FlushSelectEquip()
	local star_level = AuthenticateData.Instance:GetOneEquipStar(self.select_equip_index)
	self.node_t_list["img_equipment_bg"].node:loadTexture(ResPath.GetEquipment("equipment_img_" .. (self.select_equip_index)))
	self.node_t_list.lbl_qh_level.node:setString(star_level .. "星")
end

function AuthenticateView:FlushSelectConsume()
	local lock_num = AuthenticateData.Instance:GetLockNum()
	-- local index = lock_num == 0 and 1 or lock_num

	-- 消耗物品数量 
	-- local consume = cfg.consume or {}
	-- local consume_1 = consume[1] or {id = 0, count = 0}
	-- local consume_2 = consume[2] or {id = 0, count = 0}
	local num_1 = BagData.Instance:GetItemNumInBagById(2279)
	local num_2 = BagData.Instance:GetItemNumInBagById(2278)
	local cfg_count_2 = 2--can_anuthenticate and consume_2.count or 0
	local text_2 = num_2 .. "/" .. cfg_count_2
	local color_2 = num_2 >= cfg_count_2 and COLOR3B.GREEN or COLOR3B.RED
	self.node_t_list["lbl_consume_count_2"].node:setString(text_2)
	self.node_t_list["lbl_consume_count_2"].node:setColor(color_2)

	self.node_t_list["lbl_consume_count_1"].node:setString("")
	self.consume_cell_1:GetView():setVisible(lock_num ~= 0)

	if lock_num == 0 then return end
	lock_num = lock_num > 4 and 4 or lock_num
	local cfg_count_1 = EquipSlotAppsalAttrsCfg.lockConsumes[lock_num].count
	local text_1 = num_1 .. "/" .. cfg_count_1
	local color_1 = num_1 >= cfg_count_1 and COLOR3B.GREEN or COLOR3B.RED
	self.node_t_list["lbl_consume_count_1"].node:setString(text_1)
	self.node_t_list["lbl_consume_count_1"].node:setColor(color_1)

	-- 鉴定按钮
	-- local text = Language.Authenticate.BtnsTitle[can_anuthenticate]
	-- self.node_t_list["btn_authenticate"].node:setTitleText(text)
	-- self.node_t_list["btn_authenticate"].node:setEnabled(can_anuthenticate)

	-- 消耗数据 缓存
	-- self.consume_data[1] = {boor = num_1 >= cfg_count_1, item_id = consume_1.id or 0}
	-- self.consume_data[2] = {boor = num_1 >= cfg_count_1, item_id = consume_2.id or 0}
end


function AuthenticateView:FlushAttrList()

	local attr_data = AuthenticateData.Instance:GetattrList(self.select_equip_index)

	-- 原本属性，临时属性
	local item, ls_item = AuthenticateData.Instance:GetDothData(attr_data)

	--  现有属性
	local attr_list = {}
	for k1, v1 in pairs(item) do
		local authenticate = AuthenticateData.Instance:GetEquipCfg(v1.jd_type)
		if authenticate and v1.attr_type ~= 0 and v1.attr_index ~= 0 then
			local attr_cfg = authenticate[1][v1.attr_type][v1.attr_index].attrs
			for i2, v2 in ipairs(attr_cfg) do
				attr_list[#attr_list + 1] = {type = v2.type, value = v2.value}
			end
		end
	end

	-- 临时属性
	local ls_attr_list = {}
	for i,v in ipairs(ls_item) do
		local authenticate = AuthenticateData.Instance:GetEquipCfg(v.ls_jd_type)
		if authenticate and v.ls_attr_type ~= 0 and v.ls_attr_index ~= 0 then
			local attr_cfg = authenticate[1][v.ls_attr_type][v.ls_attr_index].attrs
			for i1, v1 in ipairs(attr_cfg) do
				ls_attr_list[#ls_attr_list + 1] = {type = v1.type, value = v1.value}
			end
		end
	end
	
	attr_list = self:GetLsAttrData(attr_list, item, 1)
	ls_attr_list = self:GetLsAttrData(ls_attr_list, ls_item, 2)

	self.attr_list:SetDataList(attr_list)
	self.new_attr_list:SetDataList(ls_attr_list)
end

--非组合属性
function AuthenticateView:GetLsAttrData(title_attrs, item, index)
    local attr_str_list = {}
    local attr = RoleData.FormatRoleAttrStr(title_attrs)

    -- if #attr > 0 then
	    for i = 1, 5 do
	    	local vo = {
	    		index = i,
	   			attr_str = attr[i] or nil,
	   			pz = (index == 1) and item[i].jd_type or item[i].ls_jd_type,
	   			star = (index == 1) and item[i].attr_index or item[i].ls_attr_index,
	   			equ_index = self.select_equip_index,
	   		} 
	   		table.insert(attr_str_list, vo)
	    end
	-- end

    return attr_str_list
end

----------end----------

function AuthenticateView:OnBagItemChange()
	self:FlushSelectConsume()
end

function AuthenticateView:OnEquip(item)
	for i,v in ipairs(self.equip_list) do
		v:SetSelect(v == item)
	end

	if self.select_equip_index ~= item:GetIndex() then
		self.select_equip_index = item:GetIndex()
		AuthenticateData.Instance:InitCheck()
		self:Flush()
	end
end

function AuthenticateView:OnAuthenticateDataChange()
	-- 有更换选中的装备时,不再刷新.
	-- if slot == self.select_equip_index then
		self:Flush()
	-- end
end

-- 属性文本
AuthenticateView.AttrTextRender = BaseClass(BaseRender)
local AttrTextRender = AuthenticateView.AttrTextRender
function AttrTextRender:__init()
	self.pz_eff = nil
end

function AttrTextRender:__delete()
	
end

function AttrTextRender:CreateChild()
	BaseRender.CreateChild(self)
	AuthenticateData.Instance:InitCheck()
	XUI.AddClickEventListener(self.node_tree.img_pz.node, BindTool.Bind2(self.PzWask, self))
	XUI.AddClickEventListener(self.node_tree.img_sou.node, BindTool.Bind2(self.IsLock, self))

	if nil == self.pz_eff then
	 	self.pz_eff = AnimateSprite:create()
	 	self.node_tree.img_pz.node:addChild(self.pz_eff, 100)
	end

	self.is_lock = 1
end

function AttrTextRender:OnFlush()
	if nil == self.data.attr_str then 
		-- self.node_tree.lbl_attr_txt.node:setString("")
		self.node_tree.lbl_attr_name.node:setString("空白属性")
		self.node_tree.lbl_star.node:setString("")
		self.node_tree.img_pz.node:setVisible(false)
		self.node_tree.img_sou.node:setVisible(false)
		self.node_tree.lbl_attr_name.node:setColor(COLOR3B.GRAY)
		return 
	end

	self.node_tree.img_sou.node:setVisible(true)
	-- 例: "属性名："
	self.node_tree.lbl_attr_name.node:setString(self.data.attr_str.type_str .. "：" .. self.data.attr_str.value_str)
	-- self.node_tree.lbl_attr_txt.node:setString(self.data.attr_str.value_str)
	if self.data.pz ~= 0 and self.data.star ~= 0 then
		self.node_tree.lbl_star.node:setString(string.format(Language.Equipment.JianDingStarTxt[self.data.pz], self.data.star))
	end

	local txt_color = AuthenticateData.Instance:GetAttrColor(self.data.pz, self.data.star)
	self.node_tree.lbl_attr_name.node:setColor(txt_color)
	-- self.node_tree.lbl_attr_txt.node:setColor(txt_color)
	self.node_tree.lbl_star.node:setColor(txt_color)

	local path = ResPath.GetAppraisal("img_jing")
	local pz_eff
	local eff_x, eff_y = 0, 0
	if (self.data.pz == 1 and self.data.star == 10) or (self.data.pz == 2 and self.data.star < 10) then
		path = ResPath.GetAppraisal("img_jing")
		pz_eff = 1190
		eff_x, eff_y = 20, 15
	elseif (self.data.pz == 2 and self.data.star == 10) or (self.data.pz == 3 and self.data.star <= 10) then
		path = ResPath.GetAppraisal("img_ji")
		pz_eff = 1191
		eff_x, eff_y = 17, 11
	end
	self.node_tree.img_pz.node:loadTexture(path)
	self.node_tree.img_pz.node:setVisible(not (self.data.pz == 1 and self.data.star < 10))

	if pz_eff then
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(pz_eff)
		self.pz_eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.pz_eff:setPosition(eff_x, eff_y)
	end

	local state = AuthenticateData.Instance:LockState()[self.index]
	local sou_path = state == 1 and ResPath.GetAppraisal("img_sou_1") or ResPath.GetAppraisal("img_sou_2")
	self.node_tree.img_sou.node:loadTexture(sou_path)
end

function AttrTextRender:PzWask()
	local index = self:GetXilianIndex()
	AuthenticateCtrl.Instance:OpenXilian(index, self.data.equ_index, self.index)
	AuthenticateData.Instance:GetAttrCheck(self.index)
end

-- 获取是是精致还是极致
function AttrTextRender:GetXilianIndex()
	local index = 1
	if (self.data.pz == 1 and self.data.star == 10) or (self.data.pz == 2 and self.data.star < 10) then
		index = 1
	elseif (self.data.pz == 2 and self.data.star == 10) or (self.data.pz == 3 and self.data.star <= 10) then
		index = 2
	end
	return index
end

function AttrTextRender:IsLock()
	local state = AuthenticateData.Instance:LockState()[self.index]
	local lock_num = AuthenticateData.Instance:GetLockNum()
	if state == 0 then 
		self.is_lock = 1 
	end

	if self.is_lock == 1 then
		self.is_lock = 2
	elseif self.is_lock == 2 then
		self.is_lock = 1
	end

	if (lock_num + 1 == 5) and self.is_lock == 2 then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.JianDingLock)
	else
		AuthenticateData.Instance:GetIsLock(self.index, self.is_lock)
	end
end

function AttrTextRender:ShowFlash()
	if nil == self.select_effect then
		local size = self.node_tree.img9_bg.node:getContentSize()
		self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_292"), true)
		self.node_tree.img9_bg.node:addChild(self.select_effect, 999)
		self.select_effect:setOpacity(0)
	end

	local fade_out = cc.FadeTo:create(0.2, 140)
	local fade_in = cc.FadeTo:create(0.3, 80)
	local fade_in2 = cc.FadeTo:create(0.2, 0)
	local action = cc.Sequence:create(fade_out, fade_in, fade_out, fade_in2)
	self.select_effect:runAction(action)
end

function AttrTextRender:CreateSelectEffect()
end

-- 属性文本
AuthenticateView.NewAttrRender = BaseClass(BaseRender)
local NewAttrRender = AuthenticateView.NewAttrRender
function NewAttrRender:__init()
	
end

function NewAttrRender:__delete()

end

function NewAttrRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img_pz.node:setVisible(false)
end

function NewAttrRender:OnFlush()
	if nil == self.data.attr_str then 
		self.node_tree.lbl_attr_name.node:setString("空白属性")
		self.node_tree.lbl_star.node:setString("")
		self.node_tree.lbl_attr_name.node:setColor(COLOR3B.GRAY)
		return 
	end

	-- 例: "属性名："

	self.node_tree.lbl_attr_name.node:setString(self.data.attr_str.type_str .. "：" .. self.data.attr_str.value_str)


	if self.data.pz ~= 0 and self.data.star then
		self.node_tree.lbl_star.node:setString(string.format(Language.Equipment.JianDingStarTxt[self.data.pz], self.data.star))
	end

	local txt_color = AuthenticateData.Instance:GetAttrColor(self.data.pz, self.data.star)
	self.node_tree.lbl_attr_name.node:setColor(txt_color)
	self.node_tree.lbl_star.node:setColor(txt_color)

end

function NewAttrRender:CreateSelectEffect()
end

----------------------------------------------------------------------------------------------------
--强化item
----------------------------------------------------------------------------------------------------
AuthenticateView.JianDingRender = BaseClass(BaseRender)
local JianDingRender = AuthenticateView.JianDingRender

function JianDingRender:__init()
end

function JianDingRender:__delete()
	
end

function JianDingRender:CreateChild()
	BaseRender.CreateChild(self)

end

function JianDingRender:OnFlush()

	self.node_tree.img_equipment_bg.node:loadTexture(ResPath.GetEquipment("equipment_img_" .. self.index))

	local star_level = AuthenticateData.Instance:GetOneEquipStar(self.index)
	self.node_tree.lbl_qh_level.node:setString(star_level .. "星")

	self.node_tree.lbl_qh_level.node:setColor(COLOR3B.GREEN)


end

function JianDingRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2,  size.height / 2, size.width + 10, size.height + 10, ResPath.GetCommon("img9_286"), true, cc.rect(8, 9, 13, 11))
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 99)
end

--------------------

--------------------

return AuthenticateView