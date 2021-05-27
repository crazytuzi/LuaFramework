--------------------------------------------------------
-- 绝版抢购  配置 JueBanQiangGouConfig
--------------------------------------------------------

OutOfPrintView = OutOfPrintView or BaseClass(BaseView)

function OutOfPrintView:__init()
	self.texture_path_list[1] = 'res/xui/out_of_print.png'
	self:SetModal(true)
	self.config_tab = {
		{"out_of_print_ui_cfg", 1, {0}},
	}

	self.gear = 1
end

function OutOfPrintView:__delete()
end

--释放回调
function OutOfPrintView:ReleaseCallBack()
	-- if nil ~= self.tabbar then
	-- 	self.tabbar:DeleteMe()
	-- 	self.tabbar = nil
	-- end
end

--加载回调
function OutOfPrintView:LoadCallBack(index, loaded_times)
	self:InitTextPos()
	self:CreatePetEff()
	self:CreateConsumeNumber()
	self:CreateCellList()

	self.node_t_list["img_diamond"].node:setAnchorPoint(0, 0)

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["layout_btn_1"].node, BindTool.Bind(self.OnClickBtn, self), true)
	XUI.AddClickEventListener(self.node_t_list["btn_left"].node, BindTool.Bind(self.OnGearChange, self, -1))
	XUI.AddClickEventListener(self.node_t_list["btn_right"].node, BindTool.Bind(self.OnGearChange, self, 1))

	self.node_t_list["btn_left"].node:setScale(1.5)
	self.node_t_list["btn_right"].node:setScale(1.5)


	-- 数据监听
	EventProxy.New(OutOfPrintData.Instance, self):AddEventListener(OutOfPrintData.INFO_CHANGE, BindTool.Bind(self.OnInfoChange, self))
end

function OutOfPrintView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function OutOfPrintView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function OutOfPrintView:ShowIndexCallBack(index)
	self.buy_tag = OutOfPrintData.Instance:GetOutOfPrintBuyTag()
	self.gear = OutOfPrintData.Instance:GetCurPage()
	local cfg = JueBanQiangGouConfig or {}
	local awards = cfg.JBQGAwards or {}
	self.node_t_list["btn_left"].node:setVisible(self.gear > 1)
	self.node_t_list["btn_right"].node:setVisible(self.gear < #awards)

	self:Flush()
end

function OutOfPrintView:OnFlush(param_list, index)
	for k,v in pairs(param_list) do
		if k == "gear" then
			self.gear = 0
			self:OnGearChange(v.gear)
		elseif k == "all" then
			self:FlushName()
			self:FlushPetEff()
			self:FlushTipText()
			self:FlushCellList()
			self:FlushConditions()

			local buy_tag = self.buy_tag[self.gear] or 0
			local bool = buy_tag == 0
			local path = bool and ResPath.GetOutOfPrint("img_buy") or ResPath.GetOutOfPrint("img_buy2")
			self.node_t_list["img_btn_title"].node:loadTexture(path)
			XUI.SetLayoutImgsGrey(self.node_t_list["layout_btn_1"].node, not bool, true)

		end
	end
end

----------视图函数----------

function OutOfPrintView:InitTextPos()
	-- 调整img_text锚点为(0, 0) 不改实际渲染位置
	local x, y = self.node_t_list["img_text"].node:getPosition()
	local size = self.node_t_list["img_text"].node:getContentSize()
	x = x - size.width/2
	y = y - size.height/2 
	self.node_t_list["img_text"].node:setPosition(x, y)
	self.node_t_list["img_text"].node:setAnchorPoint(0, 0)
	self.node_t_list["img_text"].node:loadTexture(ResPath.GetBigPainting("out_of_print_text_" .. self.gear))
end


-- 创建宠物特效
function OutOfPrintView:CreatePetEff()
	local ph = self.ph_list["ph_eff"]
	local parent = self.node_t_list["layout_out_of_print"].node

	self.eff = AnimateSprite:create()
	self.eff:setPosition(ph.x, ph.y)
	parent:addChild(self.eff, 99)
end

function OutOfPrintView:CreateConsumeNumber()
	local path = ResPath.GetCommon("num_4_")
	local parent = self.node_t_list["layout_out_of_print"].node
	local number_bar = NumberBar.New()
	number_bar:Create(0, 0, 0, 0, path)
	number_bar:SetSpace(-10)
	number_bar:SetGravity(NumberBarGravity.Left)
	parent:addChild(number_bar:GetView(), 99)
	self.consume_num = number_bar
	self:AddObj("consume_num")
end

function OutOfPrintView:CreateCellList()
	local cfg = JueBanQiangGouConfig or {}
	local awards = cfg.JBQGAwards or {}
	local award = awards[self.gear] and awards[self.gear].award  or {}
	local line_count = math.max(#award / 2, 1) -- 最少一个格子
	local space = 10 -- cell之间的间隔
	local w = line_count * BaseCell.SIZE + (line_count - 1) * space -- 调整后的cell_list宽度

	-- 注意:宽度是有根据cell的数量调整
	local ph = self.ph_list["ph_cell_list"]
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.node_t_list["layout_out_of_print"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, w, ph.h, line_count, ph_item.w, self.CellItem, ScrollDir.Vertical, false, ph_item)

	parent:addChild(grid_scroll:GetView(), 99)
	self.cell_list = grid_scroll
	self:AddObj("cell_list")
end

-- 刷新功能名称
function OutOfPrintView:FlushName()
	self.node_t_list["img_name"].node:loadTexture(ResPath.GetOutOfPrint("img_out_of_print_" .. self.gear))

	if self.gear < 3  then
		self.node_t_list["img_probability"].node:setVisible(true)
		self.node_t_list["img_probability"].node:loadTexture(ResPath.GetOutOfPrint("img_probability_2")) -- 固定50%
	else
		self.node_t_list["img_probability"].node:setVisible(false)
	end 
end

-- 刷新宠物特效
function OutOfPrintView:FlushPetEff()
	local scale = 1
	local cfg = JueBanQiangGouConfig or {}
	local awards = cfg.JBQGAwards or {}
	local effect_id = awards[self.gear] and awards[self.gear].effect_id  or 1

	if nil ~= self.eff then
		if effect_id > 0 then
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
			self.eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
			self.eff:setScale(scale)
		else
			self.eff:setStop()
		end
		self.eff:setVisible(effect_id > 0)
	end
end

function OutOfPrintView:FlushTipText()
	-- 设置礼包价格
	local cfg = JueBanQiangGouConfig or {}
	local awards = cfg.JBQGAwards or {}
	local consumes = awards[self.gear] and awards[self.gear].consume or {}
	self.consume = consumes[1] and consumes[1].count or 0
	self.consume_num:SetNumber(self.consume)

	----------------------------------------
	-- 对齐 consume_num 和 美术字"钻石"
	----------------------------------------
	local x, y = self.node_t_list["img_text"].node:getPosition()
	self.node_t_list["img_text"].node:loadTexture(ResPath.GetBigPainting("out_of_print_text_" .. (self.gear or 1)))
	local new_size = self.node_t_list["img_text"].node:getContentSize()
	x = x + new_size.width - 60
	y = y + 2
	self.consume_num:SetPosition(x, y)
	local num_size = self.consume_num:GetNumberBar():getContentSize()
	local space = 2 -- 美术字"钻石"和 consume_num 的间隔
	local num_low_right_x = x + num_size.width -- consume_num的右下角x坐标
	local img_x = num_low_right_x + space
	self.node_t_list["img_diamond"].node:setPosition(img_x, y)
	----------------------------------------
end

function OutOfPrintView:FlushCellList()
	local cfg = JueBanQiangGouConfig or {}
	local awards = cfg.JBQGAwards or {}
	local award = awards[self.gear] and awards[self.gear].award  or {}
	
	self.cell_list:SetDataList(award)
end

function OutOfPrintView:FlushConditions()
	local cfg = JueBanQiangGouConfig or {}
	local cur_cfg = cfg.JBQGAwards and cfg.JBQGAwards[self.gear] or {}
	local need_diamond_lv = cur_cfg.needDiamondLv or 0
	local diamond_lv = ZsVipData.Instance:GetZsVipLv()
	local color = diamond_lv > need_diamond_lv and COLOR3B.GREEN or COLOR3B.RED
	local diamond_type = math.floor((need_diamond_lv - 1) / 3) + 1
	local diamond_child_lv = need_diamond_lv % 3 == 0 and 3 or need_diamond_lv % 3
	local diamond_type_str = Language.Common.DiamondVipType[diamond_type] or ""
	local diamond_child_lv_str = Language.Common.RomanNumerals[diamond_child_lv] or ""
	--例 "绿钻·Ⅱ"
	local text = string.format("%s·%s%s", diamond_type_str, diamond_child_lv_str, Language.Common.CanBuy)
	local rich = self.node_t_list["rich_conditions"].node
	rich = RichTextUtil.ParseRichText(rich, text, 18, color)
	XUI.RichTextSetCenter(rich)
	rich:refreshView()
end

----------end----------

function OutOfPrintView:OnClickBtn()
	local cfg = JueBanQiangGouConfig or {}
	local cur_cfg = cfg.JBQGAwards and cfg.JBQGAwards[self.gear] or {}
	local need_diamond_lv = cur_cfg.needDiamondLv or 0
	local diamond_lv = ZsVipData.Instance:GetZsVipLv()
	local can_buy = diamond_lv >= need_diamond_lv
	if nil == self.alert then
		local alert = Alert.New()
		alert:SetCancelString(Language.Common.Cancel)
		self.alert = alert
		self:AddObj("alert")
	end

	local text, func, ok_string
	if can_buy then
		func = function()
			OutOfPrintCtrl.SendOutOfPrintReq(self.gear) -- 购买
		end
		ok_string = Language.Common.Confirm
		text = string.format(Language.Common.OutOfPrintTip, self.consume)
	else
		func = function()
			ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge) -- 购买
		end
		ok_string = Language.Common.ToOpen
		local diamond_type = math.floor((need_diamond_lv - 1) / 5) + 1
		local diamond_child_lv = need_diamond_lv % 5
		local diamond_type_str = Language.Common.DiamondVipType[diamond_type] or ""
		local diamond_child_lv_str = Language.Common.RomanNumerals[diamond_child_lv] or ""
		text = string.format(Language.Common.OutOfPrintTip2, COLORSTR.GREEN, diamond_type_str, diamond_child_lv_str)
	end

	self.alert:SetOkFunc(func)
	self.alert:SetLableString(text)
	self.alert:Open()
end

function OutOfPrintView:OnInfoChange(buy_tag)
	local cfg = JueBanQiangGouConfig or {}
	local awards = cfg.JBQGAwards or {}
	local bool = false
	self.gear = 1
	for i,v in ipairs(buy_tag) do
		if v == 0 then
			bool = true
			self.gear = i
			break
		end
	end
	if bool then
		self.buy_tag = buy_tag

		local cfg = JueBanQiangGouConfig or {}
		local awards = cfg.JBQGAwards or {}
		self.node_t_list["btn_left"].node:setVisible(self.gear > 1)
		self.node_t_list["btn_right"].node:setVisible(self.gear < #awards)
		self:Flush()
	else
		self:Close()
	end
end

function OutOfPrintView:OnGearChange(value)
	self.gear = self.gear + value

	local cfg = JueBanQiangGouConfig or {}
	local awards = cfg.JBQGAwards or {}
	if self.gear <= 1 then
		self.gear = 1
	elseif self.gear >= #awards then
		self.gear = #awards
	end
	self.node_t_list["btn_left"].node:setVisible(self.gear > 1)
	self.node_t_list["btn_right"].node:setVisible(self.gear < #awards)

	self:Flush()
end

--------------------

----------------------------------------
-- 项目渲染命名
----------------------------------------
OutOfPrintView.CellItem = BaseClass(BaseRender)
local CellItem = OutOfPrintView.CellItem
function CellItem:__init()
	self.item_cell = nil
	self.special = nil
end

function CellItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.special = nil
end

function CellItem:CreateChild()
	BaseRender.CreateChild(self)
	local cell = BaseCell.New()
	self.view:addChild(cell:GetView(), 1)
	self.item_cell = cell
end

function CellItem:OnFlush()
	if nil == self.data then return end
	local item_data = ItemData.InitItemDataByCfg(self.data)
	self.item_cell:SetData(item_data)

	if self.data.special and self.data.special > 0 then
		local path = ResPath.GetOutOfPrint("img_out_of_print_2" .. self.data.special)
		if nil == self.special then
			local x, y = BaseCell.SIZE - 2, BaseCell.SIZE - 2
			self.special = XUI.CreateImageView(x, y, path, XUI.IS_PLIST)
			self.special:setAnchorPoint(1, 1)
			self.view:addChild(self.special, 2)
		else
			self.special:loadTexture(path)
			self.special:setVisible(true)
		end
	else
		if self.special then
			self.special:setVisible(false)
		end
	end 
end

function CellItem:CreateSelectEffect()
	return
end

function CellItem:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end
