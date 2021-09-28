GuildDonateView = GuildDonateView or BaseClass(BaseView)

function GuildDonateView:__init()
	self.ui_config = {"uis/views/guildview_prefab","DonateWindow"}
	self.view_layer = UiLayer.Pop
end

function GuildDonateView:__delete()

end

function GuildDonateView:LoadCallBack()
	-- self.donate_window = self:FindObj("DonateWindow")
	self.contribution_self = self:FindVariable("ContributionSelf")
	self.card = self:FindVariable("Card")
	self.gold = self:FindVariable("Gold")
	self.card_input = self:FindVariable("CardInput")
	self.gold_input = self:FindVariable("GoldInput")
	self.add_exp = self:FindVariable("AddExp")
	self.add_gong_xian = self:FindVariable("AddGongXian")
	self.zi_jin = self:FindVariable("ZiJin")
	self.wu_zi = ItemCell.New()
	self.wu_zi:SetInstanceParent(self:FindObj("WuZiItemCell"))
	self.zuan_shi = ItemCell.New()
	self.zuan_shi:SetInstanceParent(self:FindObj("ZuanShiItemCell"))
	local wu_zi_data = {}
	wu_zi_data.item_id = 26909
	local zuan_shi_data = {}
	zuan_shi_data.item_id = 65534
	self.wu_zi:SetData(wu_zi_data)
	self.zuan_shi:SetData(zuan_shi_data)

	local config = GuildData.Instance:GetGuildConfig()
	if config then
		local wuzi_id = GuildData.Instance:GetGuildJianSheId() or 0
		for k,v in pairs(config.juanxian_config) do
			if v.item_id == wuzi_id then
				self.add_exp:SetValue(v.add_guild_exp)
				self.add_gong_xian:SetValue(v.add_gongxian)
			end
		end
	end

	self:ListenEvent("OnCardPlus",
		BindTool.Bind(self.OnCardPlus, self))
	self:ListenEvent("OnCardReduce",
		BindTool.Bind(self.OnCardReduce, self))
	self:ListenEvent("OnCardMax",
		BindTool.Bind(self.OnCardMax, self))
	self:ListenEvent("OnGoldPlus",
		BindTool.Bind(self.OnGoldPlus, self))
	self:ListenEvent("OnGoldReduce",
		BindTool.Bind(self.OnGoldReduce, self))
	self:ListenEvent("OnGoldMax",
		BindTool.Bind(self.OnGoldMax, self))
	self:ListenEvent("OnCardDonate",
		BindTool.Bind(self.OnCardDonate, self))
	self:ListenEvent("OnGoldDonate",
		BindTool.Bind(self.OnGoldDonate, self))
	self:ListenEvent("OnClickGoldInput",
		BindTool.Bind(self.OnClickGoldInput, self))
	self:ListenEvent("OnClickCardInput",
		BindTool.Bind(self.OnClickCardInput, self))
	self:ListenEvent("OnClose",
		BindTool.Bind(self.Close, self))
end

function GuildDonateView:OpenCallBack()

end

function GuildDonateView:ReleaseCallBack()
	self.contribution_self = nil
	self.card = nil
	self.gold = nil
	self.card_input = nil
	self.gold_input = nil
	self.add_exp = nil
	self.add_gong_xian = nil
	self.zi_jin = nil
	if self.wu_zi then
		self.wu_zi:DeleteMe()
		self.wu_zi = nil
	end
	if self.zuan_shi then
		self.zuan_shi:DeleteMe()
		self.zuan_shi = nil
	end
end

function GuildDonateView:CloseCallBack()

end

--刷新捐赠面板
function GuildDonateView:OnFlush()
	self.card_num = 0
	local card_id = GuildData.Instance:GetGuildJianSheId()
	if card_id then
		self.card_num = ItemData.Instance:GetItemNumInBagById(card_id)
	end
	self.card:SetValue(self.card_num)

	self.gold_input:SetValue(0)
	self.card_input:SetValue(self.card_num)
	self.donate_gold = 0
	self.donate_card = self.card_num

	local guild_gongxian = GuildData.Instance:GetGuildGongxian()
	local guild_total_gongxian = GuildData.Instance:GetGuildTotalGongxian()
	self.contribution_self:SetValue(guild_gongxian)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.gold_num = vo.gold
	self.gold:SetValue(self.gold_num)

	local exp = CommonDataManager.ConverMoney(GuildDataConst.GUILDVO.guild_exp)
	self.zi_jin:SetValue(exp)
end

--增加捐献令牌
function GuildDonateView:OnCardPlus()
	self.donate_card = self.donate_card + 1
	if(self.donate_card > self.card_num) then
		self.donate_card = self.card_num
	end
	self.card_input:SetValue(self.donate_card)
end

--减少捐献令牌
function GuildDonateView:OnCardReduce()
	self.donate_card = self.donate_card - 1
	if(self.donate_card < 0) then
		self.donate_card = 0
	end
	self.card_input:SetValue(self.donate_card)
end

--最大捐献令牌
function GuildDonateView:OnCardMax()
	self.donate_card = self.card_num
	self.card_input:SetValue(self.donate_card)
end

--捐献令牌
function GuildDonateView:OnCardDonate()
	if self.donate_card > 0 then
		local card_id = GuildData.Instance:GetGuildJianSheId()
		GuildCtrl.Instance:SendAddGuildExpReq(ADD_GUILD_EXP_TYPE.ADD_GUILD_EXP_TYPE_ITEM, 0, 0, {{item_id = card_id, item_num = self.donate_card}})
	end
end

--增加捐献钻石
function GuildDonateView:OnGoldPlus()
	self.donate_gold = self.donate_gold + 10
	if(self.donate_gold > self.gold_num) then
		self.donate_gold = self.gold_num
	end
	self.gold_input:SetValue(self.donate_gold)
end

--减少捐献钻石
function GuildDonateView:OnGoldReduce()
	self.donate_gold = self.donate_gold - 10
	if(self.donate_gold < 0) then
		self.donate_gold = 0
	end
	self.gold_input:SetValue(self.donate_gold)
end

--最大捐献钻石
function GuildDonateView:OnGoldMax()
	self.donate_gold = self.gold_num
	self.gold_input:SetValue(self.donate_gold)
end

--捐献钻石
function GuildDonateView:OnGoldDonate()
	local num = self.donate_gold
	if num > 0 then
		GuildCtrl.Instance:SendAddGuildExpReq(ADD_GUILD_EXP_TYPE.ADD_GUILD_EXP_TYPE_GOLD, num, 1, {})
	end
end

-- 点击钻石输入框
function GuildDonateView:OnClickGoldInput()
	TipsCtrl.Instance:OpenCommonInputView(0, BindTool.Bind(self.GoldInputEnd, self), nil, self.gold_num)
end

function GuildDonateView:GoldInputEnd(str)
	local num = tonumber(str)
	if(num < 0) then
		num = 0
	elseif(num > self.gold_num) then
		num = self.gold_num
	end
	self.donate_gold = num
	self.gold_input:SetValue(num)
end

-- 点击令牌输入框
function GuildDonateView:OnClickCardInput()
	TipsCtrl.Instance:OpenCommonInputView(0, BindTool.Bind(self.CardInputEnd, self), nil, self.card_num)
end


function GuildDonateView:CardInputEnd(str)
	local num = tonumber(str)
	if(num < 0) then
		num = 0
	elseif(num > self.card_num) then
		num = self.card_num
	end
	self.donate_card = num
	self.card_input:SetValue(num)
end
