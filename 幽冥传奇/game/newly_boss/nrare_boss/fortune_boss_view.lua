
-- 运势boss
local FortuneBossView = BaseClass(SubView)

function FortuneBossView:__init()
	self.texture_path_list = {
		'res/xui/blessing.png',
		'res/xui/bag.png',
		'res/xui/boss.png',
	}
    self.config_tab = {
		{"new_boss_ui_cfg", 9, {0}},
	}

	self.select_index = 1
end

function FortuneBossView:__delete()
end

function FortuneBossView:ReleaseCallBack()
	if self.fortune_list then
		self.fortune_list:DeleteMe()
		self.fortune_list = nil
	end

	if self.share_gf_list then
		self.share_gf_list:DeleteMe()
		self.share_gf_list = nil
	end
end

function FortuneBossView:LoadCallBack(index, loaded_times)
	self:FortuneList()
	self:CreateShareList()
	self:CreateAddNumber()
	self:CreateAwardList()
	self:CreateMonsterAnimation()

	XUI.AddClickEventListener(self.node_t_list.btn_cq_ys.node, BindTool.Bind2(self.OnNewFortune, self))
	XUI.AddClickEventListener(self.node_t_list.btn_share.node, BindTool.Bind2(self.OnOpenList, self, 1))

	XUI.AddClickEventListener(self.node_t_list.layout_gf_list.btn_close_list.node, BindTool.Bind2(self.OnOpenList, self, 2))

	EventProxy.New(BlessingData.Instance, self):AddEventListener(BlessingData.FORTUNE_DATA, BindTool.Bind(self.OnFortuneData, self))

	-- local pos_x, pos_y = self.node_t_list.hyd_score.node:getPosition()
	-- RenderUnit.CreateEffect(1131, self.node_t_list.layout_fortune.node, 10, nil, nil, 255, 460)
	-- RenderUnit.CreateEffect(1132, self.node_t_list.layout_fortune.node, 10, nil, nil, 680, 460)

	self.node_t_list.layout_gf_list.node:setVisible(false)
	self.node_t_list.layout_gf_list.node:setLocalZOrder(999)
	XUI.AddClickEventListener(self.node_t_list.btn_ques5.node,  BindTool.Bind(self.OpenTips, self), true)
end

function FortuneBossView:OpenTips( ... )
	DescTip.Instance:SetContent(Language.DescTip.QiFuContent, Language.DescTip.QIFuTitle)
end

function FortuneBossView:OnFortuneData()
	self:Flush()
end

function FortuneBossView:ShowIndexCallBack()
	-- BlessingCtrl.Instance:SendFortune(3)
	self.fortune_list:ChangeToIndex(1)
	self:Flush()
end

-- 运势boss内观
function FortuneBossView:CreateMonsterAnimation()
	if nil == self.ys_boss_display then
		self.ys_boss_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.node_t_list.layout_fortune.node, GameMath.MDirDown)
		self.ys_boss_display:SetAnimPosition(780,200)
		self.ys_boss_display:SetFrameInterval(FrameTime.RoleStand)
		self.ys_boss_display:SetZOrder(100)
	end
	self:AddObj("ys_boss_display")
end

-- 加成数字显示
function FortuneBossView:CreateAddNumber()
	local ph = self.ph_list["ph_gj_add"]
	self.gj_add = NumberBar.New()
	self.gj_add:SetRootPath(ResPath.GetCommon("num_143_"))
	self.gj_add:SetPosition(ph.x+15, ph.y)
	self.gj_add:SetGravity(NumberBarGravity.Center)
	self.node_t_list["layout_fortune"].node:addChild(self.gj_add:GetView(), 300, 300)
	self:AddObj("gj_add")

	ph = self.ph_list["ph_yb_add"]
	self.yb_add = NumberBar.New()
	self.yb_add:SetRootPath(ResPath.GetCommon("num_143_"))
	self.yb_add:SetPosition(ph.x+15, ph.y)
	self.yb_add:SetGravity(NumberBarGravity.Center)
	self.node_t_list["layout_fortune"].node:addChild(self.yb_add:GetView(), 300, 300)
	self:AddObj("yb_add")

	ph = self.ph_list["ph_num_add"]
	self.num_add = NumberBar.New()
	self.num_add:SetRootPath(ResPath.GetCommon("num_143_"))
	self.num_add:SetPosition(ph.x+15, ph.y)
	self.num_add:SetGravity(NumberBarGravity.Center)
	self.node_t_list["layout_fortune"].node:addChild(self.num_add:GetView(), 300, 300)
	self:AddObj("num_add")
end

function FortuneBossView:FortuneList()
	if nil == self.fortune_list then
		local ph = self.ph_list.ph_fortune_list
		self.fortune_list = ListView.New()
		self.fortune_list:Create(ph.x + 10, ph.y, ph.w, ph.h, ScrollDir.Horizontal, FortuneBossView.FortuneRender, nil, nil, self.ph_list.ph_fortune_item)
		self.fortune_list:SetMargin(10)
		-- self.fortune_list:ChangeToIndex(1)

		self.node_t_list.layout_fortune.node:addChild(self.fortune_list:GetView(), 100)
		self.fortune_list:SetItemsInterval(10)
		self.fortune_list:SetJumpDirection(ListView.Top)
		self.fortune_list:SetSelectCallBack(BindTool.Bind(self.OnSelectFortuneCallback, self))

		self.fortune_list:SetDataList(Fortunecfg.lucks)
	end			
end

function FortuneBossView:CreateAwardList()
	local ph = self.ph_list["ph_award_list"]
	local ph_item = {w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.node_t_list["layout_fortune"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, BaseCell, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.award_list = grid_scroll
	self:AddObj("award_list")
end

-- 好友列表
function FortuneBossView:CreateShareList()
	if nil == self.share_gf_list then
		local ph = self.ph_list.ph_gf_list
		self.share_gf_list = ListView.New()
		self.share_gf_list:Create(ph.x, ph.y, ph.w, ph.h, nil, FortuneBossView.ShareRender, nil, nil, self.ph_list.ph_gf_item)
		-- self.share_gf_list:GetView():setAnchorPoint(0, 0)
		self.share_gf_list:SetItemsInterval(5)
		self.share_gf_list:SetJumpDirection(ListView.Top)
		-- self.share_gf_list:SetDelayCreateCount(10)
		self.node_t_list.layout_gf_list.node:addChild(self.share_gf_list:GetView(), 100)
	end	
end

function FortuneBossView:OnSelectFortuneCallback(item)
	self:FlushFortune()
end

function FortuneBossView:OnFlush(param_t)
	self:FlushFortune()
end

function FortuneBossView:OnOpenList(index)
	local _, num = BlessingData.Instance:GetFortuneNum()
	if index == 1 then
		if num >= Fortunecfg.LuckNum then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Blessing.NorNumTips)
		else
			self.node_t_list.layout_gf_list.node:setVisible(true)
			self:FlushShareList()
		end
	else
		self.node_t_list.layout_gf_list.node:setVisible(false)
	end

end

-- 运势显示
function FortuneBossView:FlushFortune()
	local boss_num, share_num = BlessingData.Instance:GetFortuneNum()
	local type = BlessingData.Instance:GetFortuneType()
	type = type == 0 and 1 or type
	self.fortune_list:ChangeToIndex(type)

	self.node_t_list.lbl_fx_num.node:setString(share_num .. "/" .. Fortunecfg.LuckNum .. "次")
	self.node_t_list.img_ys_type.node:loadTexture(ResPath.GetBoss("ys_txt_" .. type))

	-- RichTextUtil.ParseRichText(self.node_t_list.rich_boss_time.node, string.format(Language.Blessing.FortuneText, boss_num, Fortunecfg.lucks[type].BossCount), 18, COLOR3B.OLIVE)
	-- self.node_t_list.txt_equ_add.node:setString(Fortunecfg.lucks[type].RecoveryAdditions/10000*100 .. "%")
	-- self.node_t_list.txt_equ_drop.node:setString(Fortunecfg.lucks[type].attr[1].value*100 .. "%")
	self.node_t_list.lbl_ys_money.node:setString(Fortunecfg.lucks[type].consume[1].count)

	self.gj_add:SetNumber(Fortunecfg.lucks[type].attr[1].value*100)
	self.yb_add:SetNumber(Fortunecfg.lucks[type].RecoveryAdditions/10000*100)
	self.num_add:SetNumber(Fortunecfg.lucks[type].BossCount)

	self:RewardShow(Fortunecfg.lucks[type].drops)

	local boss_cfg = BossData.GetMosterCfg(Fortunecfg.lucks[type].BossId)
	self.ys_boss_display:Show(boss_cfg.modelid)
	local model_cfg = BossData.GetMosterModelCfg(boss_cfg.modelid)
	self.ys_boss_display:SetScale(0.8)  --model_cfg.modelScale
end

-- 运势boss奖励显示
function FortuneBossView:RewardShow(data)
	local item = {}
	for k, v in pairs(data) do
		item[k] = {item_id = v.id, num = v.count, is_bind = v.bind}
	end
	self.award_list:SetDataList(item)
end

function FortuneBossView:OnNewFortune()
	local type = BlessingData.Instance:GetFortuneType()
	
	if type == 4 then
		if self.fortune_alert == nil then
			self.fortune_alert = Alert.New()
			self.fortune_alert:SetLableString(Language.Blessing.MaxFortune)
		end
		self.fortune_alert:SetOkFunc(function()
			BlessingCtrl.Instance:SendFortune(1)
		end)
		self.fortune_alert:Open()
	else
		BlessingCtrl.Instance:SendFortune(1)
	end
end

-- 好友列表刷新
function FortuneBossView:FlushShareList()
	local data = SocietyData.Instance:GetFriendList()
	self.node_t_list.txt_online_no.node:setVisible(#data == 0)

	self.share_gf_list:SetDataList(data)
end

-- 运势显示
FortuneBossView.FortuneRender = BaseClass(BaseRender)
local FortuneRender = FortuneBossView.FortuneRender
function FortuneRender:__init()	

end

function FortuneRender:__delete()	
end

function FortuneRender:CreateChild()
	BaseRender.CreateChild(self)
end

function FortuneRender:OnFlush()
	if self.data == nil then return end

	self.node_tree.img_ys.node:loadTexture(ResPath.GetBoss("ys_txt_" .. self.index))
	self.node_tree.img_boss_head.node:loadTexture(ResPath.GetBlessing("img_boss_" .. self.index))
end

-- 创建选中特效
function FortuneRender:CreateSelectEffect()
	self.select_effect = XUI.CreateImageView(65, 61, ResPath.GetBoss("kuang_select"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

-- 分享好友列表
FortuneBossView.ShareRender = BaseClass(BaseRender)
local ShareRender = FortuneBossView.ShareRender
function ShareRender:__init()	

end

function ShareRender:__delete()	
end

function ShareRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.btn_share.node, BindTool.Bind2(self.OnShareGet, self))
end

local have_share_list = {} -- 已分享缓存
function ShareRender:OnFlush()
	if self.data == nil then return end

	self.node_tree.icon_head.node:loadTexture(ResPath.GetBlessing("img_sex_" .. self.data.sex))
	self.node_tree.lbl_role_name.node:setString(self.data.name)
	self.node_tree.lbl_tole_guild.node:setString(Language.Blessing.GuildTxt .. (self.data.guild_name == "" and "无" or self.data.guild_name))
	self.node_tree.lbl_share_zs.node:setString(Fortunecfg.consume[1].count)
	self.node_tree.btn_share.node:setVisible(self.data.is_online == 1 and have_share_list[self.data.role_id] == nil)

	self.node_tree["lbl_tip"].node:setVisible(have_share_list[self.data.role_id] ~= nil)
end

function ShareRender:OnShareGet()
	BlessingCtrl.Instance:SendFortune(2, self.data.role_id, 0)
	local boss_num, share_num = BlessingData.Instance:GetFortuneNum()

	if share_num < Fortunecfg.LuckNum then
		have_share_list[self.data.role_id] = 1
		self:OnFlush()
	end
end

return FortuneBossView