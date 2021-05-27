--------------------------------------------------------
-- 充值大礼包  配置 EveryDayGiftBagConfig
--------------------------------------------------------

ChargeGiftView = ChargeGiftView or BaseClass(BaseView)

function ChargeGiftView:__init()
	self.texture_path_list[1] = 'res/xui/out_of_print.png'
	self.texture_path_list[2] = 'res/xui/charge_gift.png'
	self.texture_path_list[3] = 'res/xui/charge.png'
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.config_tab = {
		{"charge_gift_ui_cfg", 1, {0}},
	}

	self.gear = 1
	self.get_gear = 0
end

function ChargeGiftView:__delete()
end

--释放回调
function ChargeGiftView:ReleaseCallBack()
end

--加载回调
function ChargeGiftView:LoadCallBack(index, loaded_times)
	self:CreatePetEff()
	self:CreateConsumeNumber()
	self:CreateCellList()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["layout_btn_1"].node, BindTool.Bind(self.OnClickBtn, self), true)


	-- 数据监听
	EventProxy.New(ChargeGiftData.Instance, self):AddEventListener(ChargeGiftData.DAILY_GIFT_BAG_DATA_CHANGE, BindTool.Bind(self.OnInfoChange, self))
end

function ChargeGiftView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChargeGiftView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function ChargeGiftView:ShowIndexCallBack(index)
	self:Flush()
end

function ChargeGiftView:OnFlush()
	local info = ChargeGiftData.Instance:GetDailyGiftBagData()
	local index = ChargeGiftData.Instance:GetGiftGrade()
	self.gear = index
	self.buy_num = info[index].buy_num
	self.get_num = info[index].get_num

	local bool = self.buy_num < EveryDayGiftBagConfig.GradeGift[self.gear].buylimit
	local path = bool and ResPath.GetCharge("img_fuhao") or ResPath.ChargeBigGift("img_get")
	self.node_t_list["img_btn_title"].node:loadTexture(path)
	local x = bool and 80 or 93
	self.node_t_list["img_btn_title"].node:setPositionX(x)

	self.need_buy_num:GetView():setVisible(bool)

	self:FlushName()
	self:FlushPetEff()
	self:FlushCellList()
end

----------视图函数----------


-- 创建宠物特效
function ChargeGiftView:CreatePetEff()
	local ph = self.ph_list["ph_eff"]
	local parent = self.node_t_list["layout_charge_gift"].node

	self.eff = AnimateSprite:create()
	self.eff:setPosition(ph.x, ph.y)
	parent:addChild(self.eff, 99)
end

function ChargeGiftView:CreateConsumeNumber()
	local ph = self.ph_list.ph_cz_num
	-- 需要充值金额
	self.charge_num = NumberBar.New()
	self.charge_num:SetRootPath(ResPath.GetCommon("num_4_"))
	self.charge_num:SetPosition(ph.x, ph.y-20)
	self.charge_num:SetSpace(-7)
	self.charge_num:SetGravity(NumberBarGravity.Center)
	self.node_t_list["layout_charge_gift"].node:addChild(self.charge_num:GetView(), 300, 300)
	self:AddObj("charge_num")

	ph = self.ph_list.ph_buy_num
	-- 需要充值金额
	self.need_buy_num = NumberBar.New()
	self.need_buy_num:SetRootPath(ResPath.GetCommon("num_100_"))
	self.need_buy_num:SetPosition(ph.x, ph.y-10)
	self.need_buy_num:SetGravity(NumberBarGravity.Center)
	self.node_t_list["layout_btn_1"].node:addChild(self.need_buy_num:GetView(), 300, 300)
	self:AddObj("need_buy_num")
end

function ChargeGiftView:CreateCellList()
	local cfg = EveryDayGiftBagConfig or {}
	local awards = cfg.GradeGift or {}
	local award = awards[self.gear] and awards[self.gear].awards  or {}
	local line_count = 4--math.max(#award / 2, 1) -- 最少一个格子
	local space = 10 -- cell之间的间隔
	local w = line_count * BaseCell.SIZE + (line_count - 1) * space -- 调整后的cell_list宽度

	-- 注意:宽度是有根据cell的数量调整
	local ph = self.ph_list["ph_cell_list"]
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.node_t_list["layout_charge_gift"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, w, ph.h, line_count, ph_item.w, self.CellItem, ScrollDir.Vertical, false, ph_item)

	parent:addChild(grid_scroll:GetView(), 99)
	self.cell_list = grid_scroll
	self:AddObj("cell_list")
end

-- 刷新功能名称
function ChargeGiftView:FlushName()
	self.node_t_list["img_name"].node:loadTexture(ResPath.ChargeBigGift("img_name_" .. self.gear))
	self.node_t_list["img_title"].node:loadTexture(ResPath.ChargeBigGift("img_title_" .. self.gear))
	self.node_t_list["img_text"].node:loadTexture(ResPath.GetBigPainting("charge_desc_" .. self.gear))

	local money = EveryDayGiftBagConfig.GradeGift[self.gear].yb
	if type(money) == "table" then
		local agent_id = GLOBAL_CONFIG and GLOBAL_CONFIG.package_info and GLOBAL_CONFIG.package_info.config.agent_id or ""
		local ios_charge = CLIENT_GAME_GLOBAL_CFG and CLIENT_GAME_GLOBAL_CFG.ios_charge or {}
		local bool = ios_charge[agent_id] == nil
		money = bool and money[1] or money[2]
	end

	self.charge_num:SetNumber(money)
	self.need_buy_num:SetNumber(money)
end

-- 刷新宠物特效
function ChargeGiftView:FlushPetEff()
	local scale = 1
	local cfg = EveryDayGiftBagConfig or {}
	local awards = cfg.GradeGift or {}
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
		local ph = self.ph_list["ph_eff"]
		local pox = {0, 60}
		self.eff:setPositionX(ph.x - pox[self.gear])
	end
end

function ChargeGiftView:FlushCellList()
	local cfg = EveryDayGiftBagConfig or {}
	local awards = cfg.GradeGift or {}
	local award = awards[self.gear] and awards[self.gear].awards  or {}
	
	self.cell_list:SetDataList(award)
end

----------end----------

function ChargeGiftView:OnClickBtn()
	if self.buy_num < EveryDayGiftBagConfig.GradeGift[self.gear].buylimit then
		-- InvestmentCtrl.Instance:SendGetRebateEveryDayReward(EveryDayGiftBagConfig.GradeGift[self.gear].yb)
		local money = EveryDayGiftBagConfig.GradeGift[self.gear].yb
		if type(money) == "table" then
			local agent_id = GLOBAL_CONFIG and GLOBAL_CONFIG.package_info and GLOBAL_CONFIG.package_info.config.agent_id or ""
			local ios_charge = CLIENT_GAME_GLOBAL_CFG and CLIENT_GAME_GLOBAL_CFG.ios_charge or {}
			local bool = ios_charge[agent_id] == nil
			money = bool and money[1] or money[2]
		end
		if self.gear == 1 then -- 麻痹戒指礼包
			ChongzhiCtrl.BuyRingGift(money)
		elseif self.gear == 2 then -- 灭霸手套礼包
			ChongzhiCtrl.BuyHandGift(money)
		end
	else
		ChargeGiftCtrl.RequestChargeGiftReq(self.gear)
	end
end

function ChargeGiftView:OnInfoChange(index)
	local grade = ChargeGiftData.Instance:GetGiftGrade()
	local data = ChargeGiftData.Instance:GetDailyGiftBagData()
	local cfg = EveryDayGiftBagConfig.GradeGift
	local vis = data[#cfg].get_num >= cfg[#cfg].buylimit 

	if not vis then
		self:Flush()
	else
		self:Close()
	end
end

--------------------

----------------------------------------
-- 项目渲染命名
----------------------------------------
ChargeGiftView.CellItem = BaseClass(BaseRender)
local CellItem = ChargeGiftView.CellItem
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
