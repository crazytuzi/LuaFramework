------------------------------------------------------------
-- 跨服BOSS-轮回地狱子视图 配置 reincarnationHellCfg
------------------------------------------------------------

local RebirthHellChildView = BaseClass(SubView)

function RebirthHellChildView:__init()
	self.texture_path_list[1] = 'res/xui/rebirth_hell.png'
	self.config_tab = {
		{"rebirth_hell_ui_cfg", 2, {0}},
	}
	
	self.item_cell = {} -- 物品列表
end

function RebirthHellChildView:__delete()
end

function RebirthHellChildView:ReleaseCallBack()

	if self.item_cell then
		for _, v in pairs(self.item_cell) do
			v:DeleteMe()
		end
		self.item_cell = nil
	end

end

function RebirthHellChildView:LoadCallBack(index, loaded_times)
	self.data = RebirthHellData.Instance:GetData() -- 获取轮回地狱数据索引(只需获取一次)

	self:CreateCellView()
	self:CreateTextBtn()

	local text = Language.CrossBoss.ConsumptionIngot .. reincarnationHellCfg.oneBookConsume
	self.node_t_list["lbl_buy_cost"].node:setString(text)

	--按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnBtn, self))

	EventProxy.New(RebirthHellData.Instance, self):AddEventListener(RebirthHellData.REBIRTH_HELL_DATA_CHANGE, BindTool.Bind(self.OnRebirthHellDataChange, self))
	-- EventProxy.New(LunHuiData.Instance, self):AddEventListener(LunHuiData.LUNHUI_DATA_CHANGE, BindTool.Bind(self.OnLunHuiDataChange, self))

end

--显示索引回调
function RebirthHellChildView:ShowIndexCallBack(index)
	--刷新"轮回地狱"副本名称
	local grade = (LunHuiData.Instance:GetLunGrade() + 1)
	self.node_t_list["hell_name"].node:loadTexture(ResPath.GetRebirthHell("hell_name_" .. grade))

	self:FlushNumberView()
end

----------视图函数----------

-- 创建"购买击杀次数"按钮
function RebirthHellChildView:CreateTextBtn()
	local ph = self.ph_list["ph_text_btn"]
	local text = RichTextUtil.CreateLinkText(Language.RebirthHell.TextBtn, 19, COLOR3B.GREEN, nil, true)
	text:setPosition(ph.x, ph.y)
	self.node_t_list["layout_rebirth_hell"].node:addChild(text, 20)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnTextBtn, self), true)
end

-- 创建"物品图标"视图
function RebirthHellChildView:CreateCellView()
	local data = RebirthHellData.Instance:GetItemData()
	self.item_cell = {}
	for i = 1, 6 do
		ph = self.ph_list["ph_cell_" .. i]
		self.item_cell[i] = BaseCell.New()
		self.item_cell[i]:SetPosition(ph.x, ph.y)
		-- self.item_cell[i]:GetView():setAnchorPoint(cc.p(0.5, 0.5))
		self.item_cell[i]:SetData(data[i])
		self.node_t_list["layout_rebirth_hell"].node:addChild(self.item_cell[i]:GetView(), 20)
	end
end

-- 刷新"可击杀数量"
function RebirthHellChildView:FlushNumberView()
	local text = string.format(Language.CrossBoss.RemainingCanKillBossTime, self.data.number)
	self.node_t_list["lbl_number"].node:setString(text)
end

----------end----------

--------------------

-- "参于挑战"按钮点击回调
function RebirthHellChildView:OnBtn()
	-- 请求进入"轮回地狱"(144, 2)
	CrossServerCtrl.Instance.SentJoinCrossServerReq(5, 1)
end

-- "轮回地狱"数据改变回调
function RebirthHellChildView:OnRebirthHellDataChange()
	self:FlushNumberView()
end

-- 文本按钮点击回调
function RebirthHellChildView:OnTextBtn()
	-- 请求购买"轮回地狱"击杀次数(144, 8)
	RebirthHellCtrl.Instance.SendRebirthHellDataReq(1)
end

return RebirthHellChildView