--------------------------------------------------------------------------
-- MagicCardLottoView 魔卡抽奖面板
--------------------------------------------------------------------------
MagicCardLottoView = MagicCardLottoView or BaseClass(BaseRender)

local PAGE_NUM = 3		-- 页数
local ROW = 2
local COL = 6
local BLUE_ANI = "blue_ani"
local PURPLE_ANI = "purple_ani"
local ORANGE_ANI = "orange_ani"

function MagicCardLottoView:__init()
	MagicCardLottoView.Instance = self
	self:InitView()
end

function MagicCardLottoView:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
end

function MagicCardLottoView:InitView()
	self.BlueMg = self:FindVariable("BlueMg")
	self.PurpleMg = self:FindVariable("PurpleMg")
	self.OrangeMg = self:FindVariable("OrangeMg")
	self.RedMg = self:FindVariable("RedMg")
	self.one_num = self:FindVariable("one_num")
	self.five_num = self:FindVariable("five_num")
	self.ten_num = self:FindVariable("ten_num")
	self.is_child_show = self:FindVariable("is_child_show")
	self.is_nolotto_ani = self:FindVariable("is_nolotto_ani")
	self.gold = self:FindVariable("gold")
	self.today_free_lotto_time = self:FindVariable("today_free_lotto_time")
	self.is_free = self:FindVariable("is_free")

	self:ListenEvent("OneClick", BindTool.Bind(self.OnOneClick, self))
	self:ListenEvent("FiveClick", BindTool.Bind(self.OnFiveClick, self))
	self:ListenEvent("TenClick", BindTool.Bind(self.OnTenClick, self))
	self:ListenEvent("BlueClick", BindTool.Bind(self.OnBlueClick, self))
	self:ListenEvent("PurpleClick", BindTool.Bind(self.OnPurpleClick, self))
	self:ListenEvent("OrangeClick", BindTool.Bind(self.OnOrangeClick, self))

	self:ListenEvent("LottoAniClick", BindTool.Bind(self.LottoAniClick, self))
	self:ListenEvent("AddGold",BindTool.Bind(self.HandleAddGold, self))
	self:ListenEvent("CallBack",BindTool.Bind(self.CallBack,self))

	self.lotto_ani = self:FindObj("LottoAni").animator
	self.item_list = {}
	for i=1,10 do
		self.item_list[i] = ItemCell.New(self:FindObj("Item"..i))
	end

	self.ani_type = BLUE_ANI
	self.is_click = false
	self.is_bt_down = true
	self.is_no_ani = false
	self.cur_lotto_typ = 0
	self.cur_lotto_zu = 0
	self.purple_lotto_gold = MagicCardData.Instance:GetOtherCfg().purple_chou_card_consume_gold
	self.orange_lotto_gold = MagicCardData.Instance:GetOtherCfg().orange_chou_card_consume_gold
	self.red_lotto_gold = MagicCardData.Instance:GetOtherCfg().red_chou_card_consume_gold

	self.page = 0
	self.card_info = {}

	-- self:FlushData()
end

function MagicCardLottoView:CallBack()
	self.is_child_show:SetValue(false)
	self.is_bt_down = true
	if self.ani_type == BLUE_ANI then
		self.lotto_ani:SetBool("moveblue", false)
	elseif self.ani_type == PURPLE_ANI then
		self.lotto_ani:SetBool("movepurple", false)
	else
		self.lotto_ani:SetBool("moveorange", false)
	end
end

function MagicCardLottoView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function MagicCardLottoView:FlushGold()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local count = vo.gold
	if count > 99999 and count <= 99999999 then
		count = count / 10000
		count = math.floor(count)
		count = count .. Language.Common.Wan
	elseif count > 99999999 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. Language.Common.Yi
	end
	self.gold:SetValue(count)
end

function MagicCardLottoView:LottoAniClick()
	self.is_no_ani = not self.is_no_ani
	MagicCardData.Instance:SetIsNoAni(self.is_no_ani)
	self.is_nolotto_ani:SetValue(self.is_no_ani)
end

function MagicCardLottoView:OnBlueClick()
	if self.is_bt_down then
		self.ani_type = BLUE_ANI
		self.cur_lotto_zu = 0
		self:FlushCurZuInfo()
		self.page = 0
		self:FlushChosenData()
	end
	self.lotto_ani:SetBool("moveblue", self.is_bt_down)
	self.is_child_show:SetValue(self.is_bt_down)

	self.is_bt_down = not self.is_bt_down
end

function MagicCardLottoView:OnPurpleClick()
	if self.is_bt_down then
		self.ani_type = PURPLE_ANI
		self.cur_lotto_zu = 1
		self:FlushCurZuInfo()
		self.page = 1
		self:FlushChosenData()
	end
	self.is_child_show:SetValue(self.is_bt_down)
	self.lotto_ani:SetBool("movepurple", self.is_bt_down)

	self.is_bt_down = not self.is_bt_down
end

function MagicCardLottoView:OnOrangeClick()
	if self.is_bt_down then
		self.ani_type = ORANGE_ANI
		self.cur_lotto_zu = 2
		self:FlushCurZuInfo()
		self.page = 2
		self:FlushChosenData()
	end
	self.is_child_show:SetValue(self.is_bt_down)
	self.lotto_ani:SetBool("moveorange", self.is_bt_down)

	self.is_bt_down = not self.is_bt_down
end

function MagicCardLottoView:FlushCurZuInfo()
	self.card_info = MagicCardData.Instance:GetCardLottoInfo()
	for i=1,10 do
		local data = {item_id = self.card_info[10*self.cur_lotto_zu + i][1].item_id}
		self.item_list[i]:SetData(data)
	end
end

function MagicCardLottoView:OnOneClick()
	if MagicCardData.Instance:GetBagCardNum() <= 120 then
		local gold = GameVoManager.Instance:GetMainRoleVo().gold
		if self.page == 0 then
			if MagicCardData.Instance:GetTodayIsCanFreeLotto() then
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,0,1)
				self.cur_lotto_typ = CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_1
				MagicCardData.Instance:SetCurLottoType(0)
			else
				if gold < self.purple_lotto_gold then
					TipsCtrl.Instance:ShowLackDiamondView()
				else
					MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,0,1)
					self.cur_lotto_typ = CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_1
					MagicCardData.Instance:SetCurLottoType(0)
				end
			end
		elseif self.page == 1 then
			if gold < self.orange_lotto_gold then
				TipsCtrl.Instance:ShowLackDiamondView()
			else
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,1,1)
				self.cur_lotto_typ = CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_1
				MagicCardData.Instance:SetCurLottoType(1)
			end
		else
			if gold < self.red_lotto_gold then
				TipsCtrl.Instance:ShowLackDiamondView()
			else
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,2,1)
				self.cur_lotto_typ = CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_1
				MagicCardData.Instance:SetCurLottoType(2)
			end
		end
		self.is_click = true
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function MagicCardLottoView:OnFiveClick()
	if MagicCardData.Instance:GetBagCardNum() <= 115 then
		local gold = GameVoManager.Instance:GetMainRoleVo().gold
		if self.page == 0 then
			if gold < (self.purple_lotto_gold * 5) then
				TipsCtrl.Instance:ShowLackDiamondView()
			else
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,0,5)
				self.cur_lotto_typ = CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_5
				MagicCardData.Instance:SetCurLottoType(0)
				self.is_click = true
			end
		elseif self.page == 1 then
			if gold < (self.orange_lotto_gold * 5) then
				TipsCtrl.Instance:ShowLackDiamondView()
			else
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,1,5)
				self.cur_lotto_typ = CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_5
				MagicCardData.Instance:SetCurLottoType(1)
				self.is_click = true
			end
		else
			if gold < (self.red_lotto_gold * 5) then
				TipsCtrl.Instance:ShowLackDiamondView()
			else
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,2,5)
				self.cur_lotto_typ = CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_5
				MagicCardData.Instance:SetCurLottoType(2)
				self.is_click = true
			end
		end
		self.is_click = true
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function MagicCardLottoView:OnTenClick()
	if MagicCardData.Instance:GetBagCardNum() <= 110 then
		local gold = GameVoManager.Instance:GetMainRoleVo().gold
		if self.page == 0 then
			if gold < (self.purple_lotto_gold * 10) then
				TipsCtrl.Instance:ShowLackDiamondView()
			else
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,0,10)
				self.cur_lotto_typ = CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_10
				MagicCardData.Instance:SetCurLottoType(0)
				self.is_click = true
			end
		elseif self.page == 1 then
			if gold < (self.orange_lotto_gold * 10) then
				TipsCtrl.Instance:ShowLackDiamondView()
			else
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,1,10)
				self.cur_lotto_typ = CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_10
				MagicCardData.Instance:SetCurLottoType(1)
				self.is_click = true
			end
		else
			if gold < (self.red_lotto_gold * 10) then
				TipsCtrl.Instance:ShowLackDiamondView()
			else
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,2,10)
				self.cur_lotto_typ = CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_10
				MagicCardData.Instance:SetCurLottoType(2)
				self.is_click = true
			end
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function MagicCardLottoView:SetLottoData(cur_lotto_typ)
	self.is_click = true
	self.cur_lotto_typ = cur_lotto_typ
end

function MagicCardLottoView:AgainLotto(LOTTO_TYPE)
	self.is_click = false

	if LOTTO_TYPE == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_1 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_1)
	elseif LOTTO_TYPE == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_5 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_5)
	elseif LOTTO_TYPE == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_10 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_10)
	elseif LOTTO_TYPE == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_1 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_1)
	elseif LOTTO_TYPE == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_5 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_5)
	elseif LOTTO_TYPE == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_10 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_10)
	elseif LOTTO_TYPE == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_1 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_1)
	elseif LOTTO_TYPE == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_5 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_5)
	elseif LOTTO_TYPE == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_10 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_10)
	end
end

function MagicCardLottoView:FlushData()
	self.is_free:SetValue(MagicCardData.Instance:GetTodayIsCanFreeLotto())

	self.bluemg_num = MagicCardData.Instance:GetMagicNumByColor(0)
	self.purplemg_num = MagicCardData.Instance:GetMagicNumByColor(1)
	self.orangemg_num = MagicCardData.Instance:GetMagicNumByColor(2)
	self.redmg_num = MagicCardData.Instance:GetMagicNumByColor(3)
	self.today_free_lotto_time:SetValue(MagicCardData.Instance:GetOtherCfg().day_free_times)

	self.BlueMg:SetValue(self.bluemg_num)
	self.PurpleMg:SetValue(self.purplemg_num)
	self.OrangeMg:SetValue(self.orangemg_num)
	self.RedMg:SetValue(self.redmg_num)
end

function MagicCardLottoView:OnFlush()

end

function MagicCardLottoView:FlushInfoView()
	if self.is_click then
		self:AgainLotto(self.cur_lotto_typ)
	end

	self:FlushData()
	self:FlushGold()
	self:FlushChosenData()
end

function MagicCardLottoView:FlushChosenData()
	if self.page == 0 then
		self.is_free:SetValue(MagicCardData.Instance:GetTodayIsCanFreeLotto())
		self.one_num:SetValue(self.purple_lotto_gold)
		self.five_num:SetValue(self.purple_lotto_gold*5)
		self.ten_num:SetValue(self.purple_lotto_gold*10)
	elseif self.page == 1 then
		self.is_free:SetValue(false)
		self.one_num:SetValue(self.orange_lotto_gold)
		self.five_num:SetValue(self.orange_lotto_gold*5)
		self.ten_num:SetValue(self.orange_lotto_gold*10)
	elseif self.page == 2 then
		self.is_free:SetValue(false)
		self.one_num:SetValue(self.red_lotto_gold)
		self.five_num:SetValue(self.red_lotto_gold*5)
		self.ten_num:SetValue(self.red_lotto_gold*10)
	end
end

function MagicCardLottoView:SetBtnActive()
	if self.page == 0 then
		self.LeftBt:SetActive(false)
		self.RightBt:SetActive(true)
	elseif self.page == 1 then
		self.RightBt:SetActive(true)
		self.LeftBt:SetActive(true)
	else
		self.LeftBt:SetActive(true)
		self.RightBt:SetActive(false)
	end
end