
XilianView = XilianView or BaseClass(BaseView)

function XilianView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/appraisal.png'
	self.config_tab = {
		{"equipment_ui_cfg", 8, {0}}
	}
	
	-- self.item_cell = nil

	-- self:SetIsAnyClickClose(true)
	-- self.zorder = 99

	self.xl_index = 1
	self.equip_index = 1
	self.check_item = 1
	self.old_attr = {}
	self.check_data = {}
end

function XilianView:__delete()
end

function XilianView:ReleaseCallBack()
	-- if nil ~= self.item_cell then
	-- 	self.item_cell:DeleteMe()
	-- 	self.item_cell = nil
	-- end

	if self.attr_list then
		self.attr_list:DeleteMe()
		self.attr_list = nilp
	end

	if self.xl_item_list then
		self.xl_item_list:DeleteMe()
		self.xl_item_list = nil
	end
end

function XilianView:OpenCallBack()
	
end

function XilianView:CloseCallBack()
	
end

function XilianView:LoadCallBack()
	-- self:CreateItemCell()
	self:CreateAttrList()
	self:CreateAddNumber()

	XUI.AddClickEventListener(self.node_t_list.btn_xl.node, BindTool.Bind2(self.OpenJianding, self))

	EventProxy.New(AuthenticateData.Instance, self):AddEventListener(AuthenticateData.HOOK_CHEAK, BindTool.Bind(self.FlushChrss, self))
	EventProxy.New(AuthenticateData.Instance, self):AddEventListener(AuthenticateData.AUTHENTICATE_DATA_CHANGE, BindTool.Bind(self.Flush, self))
	EventProxy.New(AuthenticateData.Instance, self):AddEventListener(AuthenticateData.RESULT, BindTool.Bind(self.FlushResult, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.Flush, self))
end

function XilianView:ShowIndexCallBack()
	self:Flush()
end

function XilianView:FlushChrss(index)
	self.attr_index = index
end

function XilianView:FlushResult(data)
	local old_data = self.old_attr[self.attr_index]
	local new_data = data[self.attr_index]
	
	local eff_id = 0
	local is_show = false
	if old_data.jd_type == new_data.jd_type then
		if old_data.attr_index > new_data.attr_index then
			eff_id = 10053    -- 失败并下降1星
			is_show = true
		elseif old_data.attr_index == new_data.attr_index then
			eff_id = 10052    -- 失败
			is_show = false
		elseif old_data.attr_index < new_data.attr_index then
			eff_id = 10051    -- 成功
			is_show = true
		end
	else
		if old_data.jd_type > new_data.jd_type then
			eff_id = 10053    -- 失败并下降1星
			is_show = true
		elseif old_data.jd_type < new_data.jd_type then
			eff_id = 10051    -- 成功
			is_show = true
		end
	end
	if eff_id ~= 0 then
		RenderUnit.CreateEffect(eff_id, self.node_t_list.img_title.node, 1000, nil, 1, 50, -250)
	end

	if is_show then
		for i,v in ipairs(self.attr_list:GetAllItems()) do
			v:ShowFlash()
		end
	end
end

function XilianView:OpenJianding()
	local _, index = AuthenticateData.Instance:GetHookState()
	local item_id = self.check_data.id
	local count = self.check_data.count

	local item = ShopData.GetItemPriceCfg(item_id)
	local n = BagData.Instance:GetItemNumInBagById(item_id, nil)
	if n >= count then
		if index == 0 then
			SystemHint.Instance:FloatingTopRightText("未选择装备属性")
		elseif self.check_item == 0 then
			SystemHint.Instance:FloatingTopRightText("未选择成功概率")
		else
			AuthenticateCtrl.SendAuthenticateReq(1, self.equip_index-1, self.xl_index+1, index, self.check_item, nil)
		end
	else
		if item then
			TipCtrl.Instance:OpenQuickTipItem(false, {item_id, item.price[1].type, 1})
		else
			TipCtrl.Instance:OpenGetStuffTip(item_id)
		end
	end
end

function XilianView:OnFlush(param_t, index)
	local xl_index = self.xl_index

	self.node_t_list.img_title.node:loadTexture(ResPath.GetAppraisal("img_title_" .. self.xl_index))
	self.node_t_list.btn_xl.node:setTitleText(Language.Equipment.JianDingBtn[self.xl_index])
	self.node_t_list["img_equipment_bg"].node:loadTexture(ResPath.GetEquipment("equipment_img_" .. (self.equip_index)))

	local star_level = AuthenticateData.Instance:GetOneEquipStar(self.equip_index)
	self.node_t_list.lbl_jd_lv.node:setString(star_level .. "星")

	-- local equip_data = EquipData.Instance:GetEquipDataBySolt(self.equip_index -1)
	-- self.item_cell:SetData(equip_data)

	self:AtrrFlushList()
end

-- 属性刷新
function XilianView:AtrrFlushList()
	local attr_data = AuthenticateData.Instance:GetattrList(self.equip_index)

	-- 原本属性，临时属性
	local item, ls_item = AuthenticateData.Instance:GetDothData(attr_data)

	local attr_list = {}
	for k, v in pairs(item) do
		local vo = {
			pz = v.jd_type,
			attr_type = v.attr_type,
			star = v.attr_index,
			mian_type = self.xl_index,
			equ_idx = self.equip_index,
		}
		table.insert(attr_list, vo)
	end

	self.attr_list:SetDataList(attr_list)
	self:ConsumeItemFlush(attr_list)
end

-- 消耗物品刷新
function XilianView:ConsumeItemFlush(data)
	local attr_data = AuthenticateData.Instance:GetattrList(self.equip_index)
	self.old_attr = attr_data

	-- 原本属性，临时属性
	local item, ls_item = AuthenticateData.Instance:GetDothData(attr_data)
	local _, index = AuthenticateData.Instance:GetHookState()
	index = index == 0 and self.attr_index or index

	local pz, star = data[index].pz, data[index].star
	if (data[index].pz == 1 and data[index].star <= 10) or (data[index].pz == 2 and data[index].star == 10)  then
		pz = data[index].pz + 1
		star = 1
	end

	if (self.xl_index == 1 and (data[index].pz == 2 and data[index].star == 10)) then
		AuthenticateData.Instance:GetHookInit()
	end
	

	local authenticate = AuthenticateData.Instance:GetEquipCfg(pz)
	local attr_cfg = {}
	if pz <= 3 and star < 10 then
		attr_cfg = authenticate[1][data[index].attr_type][star+1].consumes
	end
	
	self.xl_item_list:SetDataList(attr_cfg)
	self.xl_item_list:SelectIndex(self.check_item)

	self.item_jl:SetNumber(next(attr_cfg) and attr_cfg[self.check_item].rate/100 or 0)
end

function XilianView:SetData(idx, equip, attr)
	self.xl_index = idx
	self.equip_index = equip
	self.attr_index = attr
end

-- 几率数字创建
function XilianView:CreateAddNumber()
	local ph = self.ph_list["ph_jilv_num"]
	self.item_jl = NumberBar.New()
	self.item_jl:SetRootPath(ResPath.GetAppraisal("jv_num_"))
	self.item_jl:SetPosition(ph.x+15, ph.y)
	self.item_jl:SetGravity(NumberBarGravity.Center)
	self.node_t_list["layout_xl_tip"].node:addChild(self.item_jl:GetView(), 300, 300)
	self:AddObj("item_jl")
	self.item_jl:SetNumber(0)
end

--创建物品格子
function XilianView:CreateItemCell()
	if self.item_cell then return end

	local item_cell = BaseCell.New()
	item_cell:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)
	item_cell:SetCellBg(ResPath.GetCommon("cell_100"))
	item_cell:GetCell():setAnchorPoint(0.5, 0.5)
	item_cell:SetIsShowTips(true)
	self.node_t_list.layout_xl_tip.node:addChild(item_cell:GetCell(), 1, 1)
	self.item_cell = item_cell
end

function XilianView:CreateAttrList()
	local ph = self.ph_list.ph_xilian_list
	local parent = self.node_t_list["layout_xl_tip"].node
	self.attr_list = ListView.New()
	self.attr_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.XlianRender, nil, nil, self.ph_list.ph_xilian_item)
	self.attr_list:SetItemsInterval(0)
	self.attr_list:SetMargin(0)
	parent:addChild(self.attr_list:GetView(), 1)

	ph = self.ph_list.ph_xlitem_list
	local parent = self.node_t_list["layout_xl_tip"].node
	self.xl_item_list = ListView.New()
	self.xl_item_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, self.XlItemRender, nil, nil, self.ph_list.ph_xlitem_item)
	self.xl_item_list:SetItemsInterval(5)
	self.xl_item_list:SetMargin(5)
	-- self.xl_item_list:SelectIndex(1)
	self.xl_item_list:SetSelectCallBack(BindTool.Bind(self.ItemCheck, self))
	parent:addChild(self.xl_item_list:GetView(), 50)
	
end

function XilianView:ItemCheck(item, index)
	self.check_item = index
	local data = item and item:GetData()
	if not data then return end

	self.check_data = data
	self:Flush()
end

Language.XilianView = {
	NextAttrText = "%s：%s(%s)"
}

-- 属性文本
XilianView.XlianRender = BaseClass(BaseRender)
local XlianRender = XilianView.XlianRender
function XlianRender:__init()
	
end

function XlianRender:__delete()

end

function XlianRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.layout_book.node:setVisible(false)
	self.node_tree.layout_book.img_hook.node:setVisible(false)
	XUI.AddClickEventListener(self.node_tree.layout_book.btn_nohint_checkbox.node, BindTool.Bind2(self.OnClickAutoHook, self))
end

function XlianRender:OnFlush()
	if nil == self.data then 
		return 
	end
	local next_txt = ""
	local book_vis = false
	if self.data.mian_type == 1 then
		if self.data.pz == 1 then
			if self.data.star < 10 then
				next_txt = "需要达到10星"
				book_vis = false
			elseif self.data.star == 10 then
				next_txt = self:BeAttrStar(self.data.pz+1, self.data.attr_type, 1)
				book_vis = true
			end
		elseif self.data.pz == 2 then
			if self.data.star < 10 then
				next_txt = self:BeAttrStar(self.data.pz, self.data.attr_type, self.data.star+1)
				book_vis = true
			elseif self.data.star == 10 then
				next_txt = "已经最高级了"
				book_vis = false
			end
		elseif self.data.pz == 3 then
			next_txt = "已经最高级了"
			book_vis = false
		end
	elseif self.data.mian_type == 2 then
		if self.data.pz == 1 then
			next_txt = "需要达到S10星"
			book_vis = false
		elseif self.data.pz == 2 then
			if self.data.star < 10 then
				next_txt = "需要达到S10星"
				book_vis = false
			elseif self.data.star == 10 then
				next_txt = self:BeAttrStar(self.data.pz+1, self.data.attr_type, 1)
				book_vis = true
			end
		elseif self.data.pz == 3 then
			if self.data.star < 10 then
				next_txt = self:BeAttrStar(self.data.pz, self.data.attr_type, self.data.star+1)
				book_vis = true
			elseif self.data.star == 10 then
				next_txt = "已经最高级了"
				book_vis = false
			end
		end
	end

	self.node_tree.layout_book.node:setVisible(book_vis)
	
	local attr_txt = self:BeAttrStar(self.data.pz, self.data.attr_type, self.data.star)
	local color = AuthenticateData.Instance:GetAttrColor(self.data.pz, self.data.star)
	self.node_tree.lbl_attr_name.node:setString(attr_txt)
	self.node_tree.lbl_attr_name.node:setColor(color)
	self.node_tree.lbl_attr_desc.node:setString(next_txt)

	self.node_tree.layout_book.img_hook.node:setVisible(AuthenticateData.Instance:GetHookState()[self.index] == 1)
end

function XlianRender:OnClickAutoHook()
	AuthenticateData.Instance:GetAttrCheck(self.index)
end

-- 获取属性
function XlianRender:BeAttrStar(pz, type, star)
	local authenticate = AuthenticateData.Instance:GetEquipCfg(pz)
	local attr_cfg = authenticate[1][type][star].attrs
	local next_attr = RoleData.FormatRoleAttrStr(attr_cfg)[1]
	local star_txt = string.format(Language.Equipment.JianDingStarTxt[pz], star)
	local next_txt = string.format(Language.XilianView.NextAttrText, next_attr.type_str, next_attr.value_str, star_txt)

	return next_txt
end

function XlianRender:ShowFlash()
	if nil == self.select_effect then
		local size = self.node_tree.img9_bg.node:getContentSize()
		self.select_effect = XUI.CreateImageViewScale9(110, size.height / 2, size.width/2-10, size.height, ResPath.GetCommon("img9_292"), true)
		self.node_tree.img9_bg.node:addChild(self.select_effect, 999)
		self.select_effect:setOpacity(0)
	end

	local fade_out = cc.FadeTo:create(0.2, 140)
	local fade_in = cc.FadeTo:create(0.3, 80)
	local fade_in2 = cc.FadeTo:create(0.2, 0)
	local action = cc.Sequence:create(fade_out, fade_in, fade_out, fade_in2)
	self.select_effect:runAction(action)
end

function XlianRender:CreateSelectEffect()
end

-- 消耗物品
XilianView.XlItemRender = BaseClass(BaseRender)
local XlItemRender = XilianView.XlItemRender
function XlItemRender:__init()
	
end

function XlItemRender:__delete()
	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function XlItemRender:CreateChild()
	BaseRender.CreateChild(self)

	if self.item_cell then return end

	local item_cell = BaseCell.New()
	item_cell:SetPosition(self.ph_list.ph_item.x, self.ph_list.ph_item.y)
	item_cell:SetCellBg(ResPath.GetCommon("cell_100"))
	item_cell:GetCell():setAnchorPoint(0.5, 0.5)
	item_cell:SetIsShowTips(true)
	self.view:addChild(item_cell:GetCell(), 1, 1)
	self.item_cell = item_cell
end

function XlItemRender:OnFlush()
	if nil == self.data then return end

	self.item_cell:SetData({item_id = self.data.id, is_bind = 0})

	self.node_tree.lbl_jilv.node:setString(Language.Equipment.JdItemPro[self.index])

	local n = BagData.Instance:GetItemNumInBagById(self.data.id)
	local color = n >= self.data.count and COLOR3B.GREEN or COLOR3B.RED
	self.node_tree.lbl_item_num.node:setString(n .. "/" .. self.data.count)
	self.node_tree.lbl_item_num.node:setColor(color)

	local path = self:IsSelect() and ResPath.GetAppraisal("img_cheack") or ResPath.GetAppraisal("img_normal")
	self.node_tree.img_check.node:loadTexture(path)
end

function XlItemRender:CreateSelectEffect()
end