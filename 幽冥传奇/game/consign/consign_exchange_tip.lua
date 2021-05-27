-- 红钻兑换tip

RedDrillExchangePage = RedDrillExchangePage or BaseClass(BaseView)

function RedDrillExchangePage:__init()
	if RedDrillExchangePage.Instance then
		ErrorLog("[RedDrillExchangePage] Attemp to create a singleton twice !")
	end
	RedDrillExchangePage.Instance = self
	self.texture_path_list = {
		 'res/xui/zhuansheng.png',
		 'res/xui/bag.png',
	}
	self.config_tab = {
		{"consign_ui_cfg", 7, {0}},
	}

	self:SetIsAnyClickClose(false)
	self:SetModal(true)

	self.select_num = 1
	self.have_zuan = 0
end

function RedDrillExchangePage:__delete()
	RedDrillExchangePage.Instance = nil
end

function RedDrillExchangePage:LoadCallBack()
	self:CreateSlider()
	-- local use_item = nil
	-- use_item = function (num)
	-- 	if num == 0 then
	-- 		self:Close()
	-- 	else
	-- 		BagCtrl.SendSelectItemReq(self.data.parent_id, self.data.pro, self.data.index, 1)
	-- 		num = num - 1
	-- 		use_item(num)
	-- 	end
	-- end

	-- XUI.AddClickEventListener(self.node_t_list.btn_use_drill.node, function ()
	-- 	use_item(self.select_num)
	-- end)
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))

	XUI.AddClickEventListener(self.node_t_list.btn_zuan_recede.node, BindTool.Bind(self.OnZuanReduce, self))
	XUI.AddClickEventListener(self.node_t_list.btn_zuan_add.node, BindTool.Bind(self.OnZuanAdd, self))
	XUI.AddClickEventListener(self.node_t_list.btn_use_drill.node, BindTool.Bind(self.OnEXchangeZuan, self))
end

function RedDrillExchangePage:ReleaseCallBack()

	self.slider_add_point = nil
	self.tip_num = nil
end

function RedDrillExchangePage:ShowIndexCallBack()
	self:Flush()
end

function RedDrillExchangePage:OpenCallBack()
	self.have_zuan = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RED_DIAMONDS)
end

function RedDrillExchangePage:RoleDataChangeCallback(vo)
	local key = vo.key
	if key == OBJ_ATTR.ACTOR_RED_DIAMONDS
	or key == OBJ_ATTR.ACTOR_GOLD then
		self:Flush()
	end
end

function RedDrillExchangePage:CloseCallBack()
	self.select_num = 1
end

function RedDrillExchangePage:OnFlush()
	self.slider_add_point:setPercent((self.select_num / self.have_zuan) * 100)
	
	self:FlushHaveZuan()
end

-- 刷新数量显示
function RedDrillExchangePage:FlushHaveZuan()
	self.node_t_list.lbl_need_zuan.node:setString(self.select_num)
	self.node_t_list.lbl_get_zs.node:setString(self.select_num * ConsignmentType.exchangeRedDiamonds.awards[1].count)
	local red_zuan = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RED_DIAMONDS)
	self.node_t_list.lbl_my_zuan.node:setString(red_zuan)
end

-- 滑动进度条创建
function RedDrillExchangePage:CreateSlider()
	local path_ball = ResPath.GetZhuanSheng("bg_3")
	local path_progress = ResPath.GetZhuanSheng("prog")
	local path_progress_bg = ResPath.GetZhuanSheng("prog_progress_1")

	local ph = self.ph_list.ph_slider

	self.slider_add_point = XUI.CreateSlider(ph.x, ph.y, path_ball, path_progress_bg, path_progress, true)
	local ball = self.slider_add_point:getBallImage()
	self.tip_num = XUI.CreateText(16, 62, 40, 20, cc.TEXT_ALIGNMENT_CENTER, self.select_num, nil, 18, COLOR3B.GREEN)
	ball:addChild(self.tip_num)

	self.slider_add_point:setMaxPercent(100)
	self.slider_add_point:setMinPercent((1 / self.have_zuan) * 100)
	self.node_t_list.layout_duihuan_tip.node:addChild(self.slider_add_point, 100)
	self.slider_add_point:addSliderEventListener(BindTool.Bind(self.OnSliderEvent, self))
	self.slider_add_point:getBallImage():addClickEventListener(BindTool.Bind(self.OnClick, self))
end


function RedDrillExchangePage:OnClick()
end

function RedDrillExchangePage:OnSliderEvent(sender, percent, ...)
	self.select_num = math.ceil(self.have_zuan * (percent / 100))
	self.tip_num:setString(self.select_num)
	self.node_t_list.lbl_need_zuan.node:setString(self.select_num)
	self.node_t_list.lbl_get_zs.node:setString(self.select_num * ConsignmentType.exchangeRedDiamonds.awards[1].count)
end

-- 数量减少
function RedDrillExchangePage:OnZuanReduce()
	if 1 >= self.select_num then return end
	self.select_num = self.select_num - 1.1
	self.slider_add_point:setPercent((self.select_num / self.have_zuan) * 100)
end

-- 数量增加
function RedDrillExchangePage:OnZuanAdd()

	if self.select_num >= self.have_zuan then return end
	self.select_num = self.select_num + 0.9
	self.slider_add_point:setPercent((self.select_num / self.have_zuan) * 100)
end

-- 兑换红钻
function RedDrillExchangePage:OnEXchangeZuan()
	ConsignCtrl.Instance:SendExchangeDrillReq(self.select_num)
end