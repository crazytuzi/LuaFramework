
-- 运势
local FortuneView = BaseClass(SubView)

function FortuneView:__init()
	self.texture_path_list = {
		'res/xui/blessing.png',
		'res/xui/bag.png',
	}
    self.config_tab = {
		{"blessing_ui_cfg", 2, {0}},
	}

	self.select_index = 1
end

function FortuneView:__delete()
end

function FortuneView:ReleaseCallBack()
	if self.fortune_list then
		self.fortune_list:DeleteMe()
		self.fortune_list = nil
	end

	if self.share_gf_list then
		self.share_gf_list:DeleteMe()
		self.share_gf_list = nil
	end
end

function FortuneView:LoadCallBack(index, loaded_times)
	self:FortuneList()
	self:CreateShareList()

	XUI.AddClickEventListener(self.node_t_list.btn_cq_ys.node, BindTool.Bind2(self.OnNewFortune, self))

	XUI.AddClickEventListener(self.node_t_list.layout_gf_list.btn_close_list.node, BindTool.Bind2(self.OnOpenList, self, 2))

	EventProxy.New(BlessingData.Instance, self):AddEventListener(BlessingData.FORTUNE_DATA, BindTool.Bind(self.OnFortuneData, self))

	-- local pos_x, pos_y = self.node_t_list.hyd_score.node:getPosition()
	RenderUnit.CreateEffect(1131, self.node_t_list.layout_fortune.node, 10, nil, nil, 255, 460)
	RenderUnit.CreateEffect(1132, self.node_t_list.layout_fortune.node, 10, nil, nil, 680, 460)

	-- 分享运势
	local ph_txt = self.ph_list.ph_share_txt
	self.txt_share_pre = RichTextUtil.CreateLinkText("", 20, COLOR3B.GREEN)
	self.txt_share_pre:setPosition(ph_txt.x, ph_txt.y)
	XUI.AddClickEventListener(self.txt_share_pre, BindTool.Bind(self.OnOpenList, self, 1), true)
	self.node_t_list.layout_fortune.node:addChild(self.txt_share_pre, 100)

	self.node_t_list.layout_gf_list.node:setVisible(false)
	self.node_t_list.layout_gf_list.node:setLocalZOrder(101)
	XUI.AddClickEventListener(self.node_t_list.btn_ques5.node,  BindTool.Bind(self.OpenTips, self), true)
end

function FortuneView:OpenTips( ... )
	DescTip.Instance:SetContent(Language.DescTip.QiFuContent, Language.DescTip.QIFuTitle)
end

function FortuneView:OnFortuneData()
	self:Flush()
end

function FortuneView:ShowIndexCallBack()
	-- BlessingCtrl.Instance:SendFortune(3)
	self.fortune_list:ChangeToIndex(1)
	self:Flush()
end

function FortuneView:FortuneList()
	if nil == self.fortune_list then
		local ph = self.ph_list.ph_fortune_list
		self.fortune_list = ListView.New()
		self.fortune_list:Create(ph.x + 10, ph.y, ph.w, ph.h, ScrollDir.Horizontal, FortuneView.FortuneRender, nil, nil, self.ph_list.ph_fortune_item)
		self.fortune_list:SetMargin(10)
		-- self.fortune_list:ChangeToIndex(1)

		self.node_t_list.layout_fortune.node:addChild(self.fortune_list:GetView(), 100)
		self.fortune_list:SetItemsInterval(10)
		self.fortune_list:SetJumpDirection(ListView.Top)
		self.fortune_list:SetSelectCallBack(BindTool.Bind(self.OnSelectFortuneCallback, self))

		self.fortune_list:SetDataList(Fortunecfg.lucks)
	end			
end

-- 好友列表
function FortuneView:CreateShareList()
	if nil == self.share_gf_list then
		local ph = self.ph_list.ph_gf_list
		self.share_gf_list = ListView.New()
		self.share_gf_list:Create(ph.x, ph.y, ph.w, ph.h, nil, FortuneView.ShareRender, nil, nil, self.ph_list.ph_gf_item)
		-- self.share_gf_list:GetView():setAnchorPoint(0, 0)
		self.share_gf_list:SetItemsInterval(5)
		self.share_gf_list:SetJumpDirection(ListView.Top)
		-- self.share_gf_list:SetDelayCreateCount(10)
		self.node_t_list.layout_gf_list.node:addChild(self.share_gf_list:GetView(), 100)
	end	
end

function FortuneView:OnSelectFortuneCallback(item)
	self:FlushFortune()
end

function FortuneView:OnFlush(param_t)
	self:FlushFortune()
end

function FortuneView:OnOpenList(index)
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
function FortuneView:FlushFortune()
	local boss_num, share_num = BlessingData.Instance:GetFortuneNum()
	local type = BlessingData.Instance:GetFortuneType()
	type = type == 0 and 1 or type
	self.fortune_list:ChangeToIndex(type)

	self.txt_share_pre:setString(string.format(Language.Blessing.ShareNum, share_num, Fortunecfg.LuckNum))
	RichTextUtil.ParseRichText(self.node_t_list.rich_boss_time.node, string.format(Language.Blessing.FortuneText, boss_num, Fortunecfg.lucks[type].BossCount), 18, COLOR3B.OLIVE)
	self.node_t_list.txt_equ_add.node:setString(Fortunecfg.lucks[type].RecoveryAdditions/10000*100 .. "%")
	self.node_t_list.txt_equ_drop.node:setString(Fortunecfg.lucks[type].attr[1].value*100 .. "%")
	self.node_t_list.lbl_ys_money.node:setString(Fortunecfg.lucks[type].consume[1].count)
end

function FortuneView:OnNewFortune()
	BlessingCtrl.Instance:SendFortune(1)
end

-- 好友列表刷新
function FortuneView:FlushShareList()
	local data = SocietyData.Instance:GetRelationshipList(0)
	self.node_t_list.txt_online_no.node:setVisible(#data == 0)
	self.share_gf_list:SetDataList(data)
end

-- 运势显示
FortuneView.FortuneRender = BaseClass(BaseRender)
local FortuneRender = FortuneView.FortuneRender
function FortuneRender:__init()	

end

function FortuneRender:__delete()	
end

function FortuneRender:CreateChild()
	BaseRender.CreateChild(self)
end

function FortuneRender:OnFlush()
	if self.data == nil then return end

	self.node_tree.img_ys.node:loadTexture(ResPath.GetBlessing("img_ys_" .. self.index))
end

-- 创建选中特效
function FortuneRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_285"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

-- 分享好友列表
FortuneView.ShareRender = BaseClass(BaseRender)
local ShareRender = FortuneView.ShareRender
function ShareRender:__init()	

end

function ShareRender:__delete()	
end

function ShareRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.btn_share.node, BindTool.Bind2(self.OnShareGet, self))
end

function ShareRender:OnFlush()
	if self.data == nil then return end

	self.node_tree.icon_head.node:loadTexture(ResPath.GetBlessing("img_sex_" .. self.data.sex))
	self.node_tree.lbl_role_name.node:setString(self.data.name)
	self.node_tree.lbl_tole_guild.node:setString(Language.Blessing.GuildTxt .. (self.data.guild_name == "" and "无" or self.data.guild_name))
	self.node_tree.lbl_share_zs.node:setString(Fortunecfg.consume[1].count)
	self.node_tree.btn_share.node:setVisible(self.data.is_online == 1)
end

function ShareRender:OnShareGet()
	BlessingCtrl.Instance:SendFortune(2, self.data.role_id, 0)
end

return FortuneView