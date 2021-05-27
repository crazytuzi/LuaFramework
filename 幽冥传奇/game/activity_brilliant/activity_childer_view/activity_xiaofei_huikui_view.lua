XiaoFeiHKView = XiaoFeiHKView or BaseClass(ActBaseView)

function XiaoFeiHKView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function XiaoFeiHKView:__delete()
	if self.gift_list then
		self.gift_list:DeleteMe()
		self.gift_list = nil
	end

	self.xf_act_cfg = nil
end

function XiaoFeiHKView:InitView()
	self.xf_act_cfg = ActivityBrilliantData.Instance:GetOperActCfg(ACT_ID.XFHK) or {}

	ActivityBrilliantData.Instance:GetXiaofeiSignList(ACT_ID.XFHK) -- 设置领取标记

	self:CreateGiftList()
end


function XiaoFeiHKView:RefreshView(param_list)
	local list = ActivityBrilliantData.Instance:GetXiaofeiSignList(ACT_ID.XFHK)
	for i,v in ipairs(self.xf_act_cfg.config or {}) do
		if v.one then
			v.sign = ActivityBrilliantData.Instance.sign_2[ACT_ID.XFHK]
		end
	end

	self:FlushGiftList()
end

function XiaoFeiHKView:CreateGiftList()
	local ph = self.ph_list["ph_xiaofei_gift_list"]
	local ph_item = self.ph_list["ph_xiaofei_item"]
	local parent = self.node_t_list["layout_xiaofei_huikui"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h + 3, self.XiaofeiItemRender, ScrollDir.Vertical, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 20)
	grid_scroll:JumpToTop() -- 跳至开头
	self.gift_list = grid_scroll
end

function XiaoFeiHKView:FlushGiftList()
	local data_list = {}
	for i,v in ipairs(self.xf_act_cfg.config or {}) do
		data_list[i] = v
	end
	table.sort(data_list, function(a, b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			return a.numbers < b.numbers
		end
	end)

	self.gift_list:SetDataList(data_list)
	self.gift_list:JumpToTop()
end

-- 刷新活动剩余
function XiaoFeiHKView:UpdateSpareTime(end_time)
	local now_time = TimeCtrl.Instance:GetServerTime()
	local str = TimeUtil.FormatSecond2Str(end_time - now_time)
	self.node_t_list["lbl_act_time"].node:setString(str)
end


XiaoFeiHKView.XiaofeiItemRender = BaseClass(BaseRender)
local XiaofeiItemRender = XiaoFeiHKView.XiaofeiItemRender
function XiaofeiItemRender:__init()
	self:AddClickEventListener()
end

function XiaofeiItemRender:__delete()
	if nil ~= self.award_list then
    	self.award_list:DeleteMe()
    	self.award_list = nil
    end
end

function XiaofeiItemRender:CreateChild()
	BaseRender.CreateChild(self)

	local ph = self.ph_list["ph_award_list"]
	self.award_list = ListView.New()
	self.award_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.award_list:SetItemsInterval(10)
	self.view:addChild(self.award_list:GetView(), 10)
	XUI.AddClickEventListener(self.node_tree["btn_lingqu"].node, BindTool.Bind(self.OnLingQu, self))

	XUI.AddRemingTip(self.node_tree["btn_lingqu"].node)
end

function XiaofeiItemRender:OnFlush()
	local cfg_consum_gold = self.data.numbers or 0
	local cur_gold = ActivityBrilliantData.Instance.consum_gold[ACT_ID.XFHK] or 0
	local can_lingqu = cur_gold >= cfg_consum_gold
	local color = can_lingqu and COLORSTR.GREEN or COLORSTR.RED
	local btn_title = can_lingqu and Language.Common.LingQuJiangLi or Language.Common.WeiDaCheng
	self.node_tree["btn_lingqu"].node:setTitleText(btn_title)
	self.node_tree["btn_lingqu"].node:setEnabled(can_lingqu)
	self.node_tree["btn_lingqu"].node:UpdateReimd(can_lingqu)

	local rich = self.node_tree["rich_consum_gold"].node
	local text = string.format("{color;%s;%d}/%d", color, cur_gold, cfg_consum_gold)
	rich = RichTextUtil.ParseRichText(rich, text, 22, COLOR3B.GREEN)
	rich:refreshView()

	-- 奖励
	local data_list = {}
	for k, v in pairs(self.data.award) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.InitItemDataByCfg(v))
		end
	end
	self.award_list:SetDataList(data_list)

	local is_lingqu = self.data.sign ~= 0
	self.node_tree["img_stamp"].node:setVisible(is_lingqu)
	self.node_tree["btn_lingqu"].node:setVisible(not is_lingqu)
	self.node_tree["img_diamond"].node:setVisible(not is_lingqu)
	self.node_tree["rich_consum_gold"].node:setVisible(not is_lingqu)
end

function XiaofeiItemRender:OnLingQu()
	ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.XFHK, self.data.index)
end

function XiaofeiItemRender:CreateSelectEffect()
end