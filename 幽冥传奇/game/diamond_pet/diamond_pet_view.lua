--------------------------------------------------------
-- 钻石萌宠  配置 DiamondsPetsConfig
--------------------------------------------------------

DiamondPetView = DiamondPetView or BaseClass(BaseView)

function DiamondPetView:__init()
	self.title_img_path = ResPath.GetWord("word_diamond_pet")
	self.texture_path_list[1] = 'res/xui/diamond_pet.png'
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"diamond_pet_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.select_data = {}
end

function DiamondPetView:__delete()
end

--释放回调
function DiamondPetView:ReleaseCallBack()
	self.pet_eff = nil
	self.select_data = {}
end

--加载回调
function DiamondPetView:LoadCallBack(index, loaded_times)
	self:CreatePetList()
	self:CreateAwardList()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnBtn, self))
	XUI.AddClickEventListener(self.node_t_list["btn_up"].node, BindTool.Bind(self.OnUp, self))
	XUI.AddClickEventListener(self.node_t_list["btn_down"].node, BindTool.Bind(self.OnDown, self))
	XUI.AddClickEventListener(self.node_t_list["btn_tip"].node, BindTool.Bind(self.OnTip, self))

	-- 数据监听
	EventProxy.New(DiamondPetData.Instance, self):AddEventListener(DiamondPetData.DIAMOND_PET_DATA_CHANGE, BindTool.Bind(self.OnDiamondPetDataChange, self))
end

function DiamondPetView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function DiamondPetView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.select_index = nil
end

--显示指数回调
function DiamondPetView:ShowIndexCallBack(index)
	self:Flush()
end
----------视图函数----------

function DiamondPetView:OnFlush()
	self:FlushPetList()

	local pet_data = DiamondPetData.Instance:GetDiamondPetData()
	local cur_pet_lv = pet_data.pet_lv or 0
	local pet_cfg = DiamondsPetsConfig and DiamondsPetsConfig.level or {}
	local cur_pet_cfg = pet_cfg[cur_pet_lv] or {}
	local diamond_count = pet_data.today_diamond or 0
	self.node_t_list["lbl_diamond_count"].node:setString(diamond_count)

	local max_times = cur_pet_cfg.limit or 0
	local excavate_times = pet_data.excavate_times or 0
	local color = excavate_times < max_times and COLOR3B.GREEN or COLOR3B.RED
	local text = string.format("%d/%d", excavate_times, max_times)
	self.node_t_list["lbl_times"].node:setString(text)
	self.node_t_list["lbl_times"].node:setColor(color)

	local max_yuanbao = cur_pet_cfg.diamondMax or 0
	self.node_t_list["lbl_max_yuanbao"].node:setString(max_yuanbao)

	self:FlushAwardList()
	self:FlushBtnVis()
end

function DiamondPetView:CreatePetList()
	local ph = self.ph_list["ph_pet_list"]
	local ph_item = self.ph_list["ph_pet_item"]
	local parent = self.node_t_list["layout_diamond_pet"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h +20, self.PetItemRender, ScrollDir.Vertical, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 20)
	grid_scroll:SetSelectCallBack(BindTool.Bind(self.SelectPetCallBack, self))
	self.pet_list = grid_scroll
	self:AddObj("pet_list")
end 

function DiamondPetView:FlushPetList()
	local data_list	= DiamondsPetsConfig and DiamondsPetsConfig.level or {}
	self.pet_list:SetDataList(data_list)

	-- 默认选择当前等级的精灵
	local pet_data = DiamondPetData.Instance:GetDiamondPetData()
	local pet_lv = pet_data.pet_lv or 0
	local index = pet_lv > 0 and pet_lv or 1
	self.pet_list:SelectItemByIndex(index)

	-- 跳至当前等级的精灵
	local view = self.pet_list:GetView()
	local items = self.pet_list:GetItems()
	local item_view = items[index] and items[index]:GetView()
	local ph_item = self.ph_list["ph_pet_item"]
	local x, y = item_view:getPosition()
	view:jumpToPosition(cc.p(x, -(y - ph_item.h / 2))) -- 跳至当前关卡
end

function DiamondPetView:CreateAwardList()
	local ph = self.ph_list["ph_award_list"]
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.node_t_list["layout_diamond_pet"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 0, ActBaseCell, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.cell_list = grid_scroll
	self:AddObj("cell_list")
end

function DiamondPetView:FlushAwardList()
	local pet_data = DiamondPetData.Instance:GetDiamondPetData()
	local cur_pet_lv = pet_data.pet_lv or 0
	local pet_cfg = DiamondsPetsConfig and DiamondsPetsConfig.level or {}
	local cur_pet_cfg = pet_cfg[cur_pet_lv] or {}

	local rate_awards = cur_pet_cfg.rateAwards or {}
	local show_list = {}

	for i,v in ipairs(rate_awards) do
		if v.show_type then
			show_list[#show_list + 1] = ItemData.InitItemDataByCfg(v)
		end
	end
	self.cell_list:SetDataList(show_list)

	-- 居中处理
	self.cell_list:SetCenter()
end

function DiamondPetView:SelectPetCallBack(item)
	if self.select_index == item:GetIndex() then return end
	self.select_index = item:GetIndex() or 1
	self.select_data = item:GetData() or {}

	local pet_index = self.select_index
	self.node_t_list["img_pet_name"].node:loadTexture(ResPath.GetDiamondPet("pet_name_2_" .. pet_index))

	local yuanbao_count = self.select_data.diamondMax or 0
	local max_times = self.select_data.limit or 0
	local text = string.format("可挖掘运势BOSS尸体，每日最多可获得{color;ff2828;%d}钻石，每日最多可挖掘{color;1eff00;%d}次", yuanbao_count, max_times)
	RichTextUtil.ParseRichText(self.node_t_list["rich_pet_tip"].node, text, 20, Str2C3b("a29480"))
	self.node_t_list["rich_pet_tip"].node:refreshView()

	self:FlushBtnVis()
	self:FlushPet()
end


function DiamondPetView:FlushBtnVis()
	local pet_data = DiamondPetData.Instance:GetDiamondPetData()
	local cur_pet_lv = pet_data.pet_lv or 0
	local boor = cur_pet_lv < self.select_index
	local btn_title = boor and "激活" or "已激活"
	self.node_t_list["btn_1"].node:setTitleText(btn_title)
	self.node_t_list["btn_1"].node:setEnabled(boor)
	self.node_t_list["rich_conditions"].node:setVisible(boor)
	if boor then
		self:FlushConditions()
	end
end

-- 刷新激活条件
function DiamondPetView:FlushConditions()
	local text = ""
	local condition = self.select_data.condition or {}
	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) or 0
	local zslv = ZsVipData.Instance:GetZsVipLv() or 0
	local role_data = {["lv"] = role_lv, ["zslv"] = zslv}
	local conditions_key = {
		{"lv", "{color;%s;%d级}"},  -- "{color;%s;%d级}"
		{"zslv", "{color;%s;%s·%s}"}, -- "  {color;%s;转生：%d转}"
	}
	local boor = true
	for i,v in ipairs(conditions_key) do
		local key = v[1]
		local condition_lv = condition[key] or 0
		if condition_lv > 0 then
			local color = role_data[key] >= condition_lv and COLORSTR.GREEN or COLORSTR.RED
			if key == "zslv" then
				local need_diamond_lv = condition_lv
				local diamond_lv = role_data[key]
				local diamond_type = math.floor((need_diamond_lv - 1) / 3) + 1
				local diamond_child_lv = need_diamond_lv % 3 == 0 and 3 or need_diamond_lv % 3
				local diamond_type_str = Language.Common.DiamondVipType[diamond_type] or ""
				local diamond_child_lv_str = Language.Common.RomanNumerals[diamond_child_lv] or ""
				text = text .. string.format(v[2], color, diamond_type_str, diamond_child_lv_str)
			else
				text = text .. string.format(v[2], color, condition_lv)
			end
			boor = boor and role_data[key] >= condition_lv
		end
	end
	-- 满足所有激活条件时,只显示"可激活"
	text = boor and Language.Common.CanActivate or text .. Language.Common.CanActivate
	RichTextUtil.ParseRichText(self.node_t_list["rich_conditions"].node, text, 20, COLOR3B.GREEN)
	XUI.RichTextSetCenter(self.node_t_list["rich_conditions"].node)
	self.node_t_list["rich_conditions"].node:refreshView()
end

function DiamondPetView:FlushPet()
	local res_id = self.select_data.effect_ui or 1
	local path, name = ResPath.GetEffectUiAnimPath(res_id)
	if nil == self.pet_eff then
		local ph = self.ph_list["ph_pet"] or {x = 0, y = 0, w = 0, h = 0}
		local parent = self.node_t_list["layout_diamond_pet"].node
		self.pet_eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Stand, false)
		self.pet_eff:setPosition(ph.x, ph.y)
		parent:addChild(self.pet_eff, 50)
	else
		self.pet_eff:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Stand, false)
	end
end

----------end----------

-- "激活宠物"按钮
function DiamondPetView:OnBtn()
	local pet_name_list = {"月娥仙子", "紫羽仙子", "灵翼仙子", "兔耳仙子", "绿萝仙子", "蝶翼仙子", "天羽仙子",}
	local pet_data = DiamondPetData.Instance:GetDiamondPetData()
	local cur_pet_lv = pet_data.pet_lv or 0
	if (self.select_index - cur_pet_lv) == 1 then
		DiamondPetCtrl.SendActivationDiamondPetReq()
		self.node_t_list["btn_1"].node:setEnabled(false)
	else
		local pet_name = pet_name_list[self.select_index - 1] or ""
		local str = string.format("请先激活%s", pet_name)
		SystemHint:FloatingTopRightText(str)
	end
end

-- "上滑"按钮
function DiamondPetView:OnUp()

end

-- "下滑"按钮
function DiamondPetView:OnDown()

end

function DiamondPetView:OnTip()
	DescTip.Instance:SetContent(Language.DescTip.DiamondPetContent, Language.DescTip.DiamondPetTitle)
end

function DiamondPetView:OnDiamondPetDataChange()
	self:Flush()
end

----------------------------------------
-- 宠物Item
----------------------------------------
DiamondPetView.PetItemRender = BaseClass(BaseRender)
local PetItemRender = DiamondPetView.PetItemRender
function PetItemRender:__init()

end

function PetItemRender:__delete()

end

function PetItemRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddRemingTip(self.node_tree["icon_pet"].node)
	self.node_tree["img_bg"].node:setLocalZOrder(0)
end

function PetItemRender:OnFlush()
	if nil == self.data then return end
	local pet_index = self.index
	self.node_tree["img_pet_name"].node:loadTexture(ResPath.GetDiamondPet("pet_name_" .. pet_index))
	self.node_tree["icon_pet"].node:loadTexture(ResPath.GetDiamondPet("icon_pet_" .. pet_index))

	local pet_data = DiamondPetData.Instance:GetDiamondPetData()
	local is_inactive = pet_data.pet_lv < pet_index
	self.node_tree["img_bg"].node:setGrey(is_inactive)
	self.node_tree["icon_pet"].node:setGrey(is_inactive)
	self.node_tree["img_pet_name"].node:setGrey(is_inactive)

	if is_inactive then
		local condition = self.data.condition or {lv = 0,viplv = 0}
		local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		local zslv = ZsVipData.Instance:GetZsVipLv() or 0
		local cfg_role_lv = condition.lv or 0
		local cfg_zslv = condition.zslv or 0
		local can_activate = role_lv >= cfg_role_lv and zslv >= cfg_zslv
		self.node_tree["icon_pet"].node:UpdateReimd(can_activate)
	else
		self.node_tree["icon_pet"].node:UpdateReimd(false)
	end
end

function PetItemRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetDiamondPet("diamond_pet_8"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 1)
end
--------------------
