RedPackageView = RedPackageView or BaseClass(XuiBaseView)

function RedPackageView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = "res/xui/red_package.png"
	self.config_tab = {
		{"red_package_ui_cfg", 1, {0}},
	}

	self.donate_times = 0
	self.rob_data = {}
	self.first_rob_yb = 0
	self.rob_time = 0
	self.my_rob_num = 0
	self.pre_yb = 0
end

function RedPackageView:__delete()

end

function RedPackageView:ReleaseCallBack()
	if self.ranking_list ~= nil then
		self.ranking_list:DeleteMe()
		self.ranking_list = nil
	end

	if self.remaind_yb then
		self.remaind_yb:DeleteMe()
		self.remaind_yb = nil
	end

	if self.remaind_yb_2 then
		self.remaind_yb_2:DeleteMe()
		self.remaind_yb_2 = nil
	end

	if nil ~= self.pop_num_view then
		self.pop_num_view:DeleteMe()
		self.pop_num_view = nil
	end

	if nil ~= self.world_hair_list then
		self.world_hair_list:DeleteMe()
		self.world_hair_list = nil
	end
	if self.rob_result_back_evt then
		GlobalEventSystem:UnBind(self.rob_result_back_evt)
		self.rob_result_back_evt = nil
	end
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	if self.red_paper_eff_view then
		self.red_paper_eff_view:DeleteMe()		
		self.red_paper_eff_view = nil
	end
end

function RedPackageView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.btn_close.node, BindTool.Bind1(self.OnClose, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_rob.node, BindTool.Bind1(self.OnRobPackage, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_ques.node, BindTool.Bind1(self.OnQuesInfo, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_hair.node, BindTool.Bind1(self.OnHairPackage, self), true)
		XUI.AddClickEventListener(self.node_t_list.img9_bg.node, BindTool.Bind1(self.OnOpenPopNum, self), true)
		XUI.AddClickEventListener(self.node_t_list.txt_mingift.node, BindTool.Bind1(self.OnMinGiftTips, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_no_vip.node, BindTool.Bind1(self.OnReveice, self), true)

		self.pop_num_view = NumKeypad.New()
		self.pop_num_view:SetOkCallBack(BindTool.Bind1(self.OnOKCallBack, self))
		self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.RobFlushTime, self, -1),  1)
		-- self.rob_result_back_evt = GlobalEventSystem:Bind(OtherEventType.ROB_REDPAPER_RESULT, BindTool.Bind1(self.OnRobResult, self))
		if not self.red_paper_eff_view then
			self.red_paper_eff_view = RedPaperEffectText.New()
			self.red_paper_eff_view:SetEffecTime(0)
			self.red_paper_eff_view:SetData(0)
			self.node_t_list.layout_red_bag.layout_rob_pack.node:addChild(self.red_paper_eff_view:GetView(), 100)
		end	
		self.node_t_list.layout_no_vip_show.node:setVisible(false)
		self:CreateDonateRank()
		self:CreateNumBar()
		self:CreateNumBarNotVip()
		self:UpdateWorldGongGao()
	end

end


function RedPackageView:OnFlush(param_t, index)
	self:FlushMyRecord()
	local rank_data = RedPackageData.Instance:GetRankInfoData()
	self.ranking_list:SetDataList(rank_data)
	local vip_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	local my_rank, my_donate_yb, remaind_yb = RedPackageData.Instance:GetPersonalInfoData()
	local _, cd_time, rob_num, my_rob_yb_num = RedPackageData.Instance:GetMeterTime()
	local first_rob_yb, rob_time, my_rob_num = RedPackageData.Instance:GetNotVipRobNum()
	local front_donate = RedPackageData.Instance:GetFrontDonate()
	local txt_front = ""
	if front_donate == 0 then
		txt_front = ""
	else
		txt_front = string.format(Language.RedPaper.FrontDonate, front_donate)
	end
	self.node_t_list.btn_rob.node:setEnabled(cd_time <= 0)
	self.rob_time = cd_time
	self.my_rob_num = rob_num

	if my_rank == 0 then
		self.node_t_list.txt_my_rank.node:setString(Language.RedPaper.NotRank)
	else
		self.node_t_list.txt_my_rank.node:setString(string.format(Language.RedPaper.Rank, my_rank))
	end
	self.node_t_list.txt_donate_on.node:setString(txt_front)
	self.node_t_list.txt_my_yb.node:setString(string.format(Language.RedPaper.HairRedPaper, my_donate_yb))
	self.remaind_yb:SetNumber(remaind_yb)
	self:IsShowNotReceive(first_rob_yb, my_rob_yb_num)
	self:RobFlushTime()
end

function RedPackageView:IsShowNotReceive(num, my_rob_yb)
	self.first_rob_yb = num
	if num == 0 then
		self:RedPaperText(my_rob_yb)
		self.node_t_list.layout_no_vip_show.node:setVisible(false)
		self.node_t_list.layout_rob_pack.node:setVisible(true)
	else
		local time = 0
		if self.pre_yb ~= num then
			self.pre_yb = num
			time = 1.2
		end	
		self.remaind_yb_2:SetEffectNumber(EffectNumberBarActionType.EVERY_ROT,0,num,time, 7)
		self.node_t_list.layout_no_vip_show.node:setVisible(true)
		self.node_t_list.layout_rob_pack.node:setVisible(false)
	end
end

function RedPackageView:RobFlushTime()
	local time = self.rob_time - Status.NowTime
	local show_time = TimeUtil.FormatSecond(GameMath.Round(time), model)
	local remind_txt = ""
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE) or 0
	if time <= 1 then
		remind_txt = string.format(Language.RedPaper.Remian_time, self.my_rob_num)
		self.node_t_list.btn_rob.node:setEnabled(true)
	else
		self.node_t_list.btn_rob.node:setEnabled(false)
		remind_txt = Language.RedPaper.RobMeterTime .. show_time
	end
	self.node_t_list.remaind_time.node:setString(remind_txt)
end

function RedPackageView:OnOpenPopNum()
	local gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	if gold < 100 then
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	else
		if nil ~= self.pop_num_view then
			self.pop_num_view:Open()
			self.pop_num_view:SetText(self.donate_times)
			local max_val = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
			self.pop_num_view:SetMaxValue(max_val)
		end
	end
end

function RedPackageView:OnOKCallBack(num)
	self.donate_times = num 
	self:FlushText()
end

function RedPackageView:FlushText()
	self.node_t_list.txt_yuanbao.node:setString(self.donate_times)
end

function RedPackageView:OnMinGiftTips()
	local data = RedPackageData.Instance:GetGiftRemaind(1)
	TipsCtrl.Instance:OpenBuffTip(data)
end

function RedPackageView:OnReveice()
	RedPackageCtrl.Instance:SendReceiveRedPaper()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE) or 0
	if level < 1 then
		ViewManager.Instance:Open(ViewName.RedPackageTips)
		ViewManager.Instance:FlushView(ViewName.RedPackageTips, 0, "param", {self.first_rob_yb})
	end
end

-- 捐献排行
function RedPackageView:CreateDonateRank()
	if nil == self.ranking_list then
		local ph = self.ph_list.ph_rank_list
		self.ranking_list = ListView.New()
		self.ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, DonateRedPaperRender, nil, nil, self.ph_list.ph_rank_item)
		self.ranking_list:GetView():setAnchorPoint(0, 0)
		self.ranking_list:SetMargin(2)
		self.ranking_list:SetItemsInterval(5)
		self.ranking_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_red_bag.node:addChild(self.ranking_list:GetView(), 100)
	end		
end

-- 捐献公告
function RedPackageView:UpdateWorldGongGao()
	if nil == self.world_hair_list then
		local ph = self.ph_list.ph_world_hair_list
		self.world_hair_list = ListView.New()
		self.world_hair_list:Create(ph.x, ph.y, ph.w, ph.h, nil, WorldRedPaperRender, nil, nil, self.ph_list.ph_wordhair_item)
		self.world_hair_list:GetView():setAnchorPoint(0, 0)
		self.world_hair_list:SetJumpDirection(ListView.Bottom)
		self.world_hair_list:SetItemsInterval(15)
		self.node_t_list.layout_red_bag.node:addChild(self.world_hair_list:GetView(), 100)
	end		
end

function RedPackageView:FlushMyRecord()
	local rob_data = RedPackageData.Instance:GetRobInfoData()

	local cur_data = {}
	for k, v in pairs(rob_data) do
		if v.rob_type == 2 then
			table.insert(cur_data, v)
		end
	end
	self.rob_data = cur_data
	self.world_hair_list:SetDataList(cur_data)
end

function RedPackageView:CreateNumBar()
	local ph = self.ph_list.img_remaind_yb
	self.remaind_yb = NumberBar.New()
	self.remaind_yb:SetRootPath(ResPath.GetCommon("num_100_"))
	self.remaind_yb:SetPosition(ph.x + 7, ph.y)
	self.remaind_yb:SetSpace(0)
	self.node_t_list.layout_red_bag.layout_rob_pack.node:addChild(self.remaind_yb:GetView(), 90)
	self.remaind_yb:SetNumber(0)
	self.remaind_yb:SetGravity(NumberBarGravity.Center)
end

function RedPackageView:CreateNumBarNotVip()
	local ph = self.ph_list.remiand_num_2
	self.remaind_yb_2 = EffectNumberBar.New()
	self.remaind_yb_2:SetRootPath(ResPath.GetCommon("num_100_"))
	self.remaind_yb_2:SetPosition(ph.x + 24, ph.y)
	self.remaind_yb_2:SetSpace(7)
	self.node_t_list.layout_red_bag.layout_no_vip_show.node:addChild(self.remaind_yb_2:GetView(), 90)
	
	self.remaind_yb_2:SetGravity(NumberBarGravity.Right)
	self.remaind_yb_2:SetEffectNumber(EffectNumberBarActionType.EVERY_ROT,0,0,0, 7)
end

function RedPackageView:OpenCallBack()
	RedPackageCtrl.Instance:SendRedPaperInfo()
end

function RedPackageView:CloseCallBack()
	
end

function RedPackageView:OnHairPackage()
	RedPackageCtrl.Instance:SendRedPaperNumber(self.donate_times)
	self.node_t_list.txt_yuanbao.node:setString("")
	self.donate_times = 0
end

function RedPackageView:OnClose()
	self:Close()
end

function RedPackageView:OnRobPackage()
	RedPackageCtrl.Instance:RobRedPaperInfo()
	
end

function RedPackageView:RedPaperText(num)
	local recv_type = RedPackageData.Instance:GetRecvDataType()
	if recv_type == 1 then
		self.red_paper_eff_view:SetEffecTime(1.2)
		self.red_paper_eff_view:SetData(num)
	else
		self.red_paper_eff_view:SetEffecTime(0)
		self.red_paper_eff_view:SetData(num)
	end
end

function RedPackageView:OnQuesInfo()
	DescTip.Instance:SetContent(Language.RedPaper.InterpContents, Language.RedPaper.InterpTitles)
end

-- 荣耀榜
DonateRedPaperRender = DonateRedPaperRender or BaseClass(BaseRender)

function DonateRedPaperRender:__init()
end

function DonateRedPaperRender:__delete()
end

function DonateRedPaperRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.txt_gift.node, BindTool.Bind1(self.OnGiftTips, self), true)
end

function DonateRedPaperRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_name.node:setString(self.data.player_name)

	self.node_tree.txt_rank.node:setString(string.format(Language.DesertKillGod.RankStr[1], self.index))

	--前三名的颜色
	if self.index == 1 then
		self.node_tree.txt_rank.node:setColor(Str2C3b("ffff00"))
		self.node_tree.txt_name.node:setColor(Str2C3b("ffff00"))
		self.node_tree.txt_gift.node:setColor(Str2C3b("ffff00"))
	elseif self.index == 2 then
		self.node_tree.txt_rank.node:setColor(Str2C3b("de00ff"))
		self.node_tree.txt_name.node:setColor(Str2C3b("de00ff"))
		self.node_tree.txt_gift.node:setColor(Str2C3b("de00ff"))
	elseif self.index == 3 then
		self.node_tree.txt_rank.node:setColor(Str2C3b("00ff00"))
		self.node_tree.txt_name.node:setColor(Str2C3b("00ff00"))
		self.node_tree.txt_gift.node:setColor(Str2C3b("00ff00"))
	end	
end

function DonateRedPaperRender:OnGiftTips()
	if self.index == 1 then
		ViewManager.Instance:Open(ViewName.RedPackageGift)
	else
		local data = RedPackageData.Instance:GetGiftRemaind(self.index)
		TipsCtrl.Instance:OpenBuffTip(data)
	end	
end

-- 公告
WorldRedPaperRender = WorldRedPaperRender or BaseClass(BaseRender)
function WorldRedPaperRender:__init()
	
end

function WorldRedPaperRender:__delete()	
end

function WorldRedPaperRender:CreateChild()
	BaseRender.CreateChild(self)
end

function WorldRedPaperRender:OnFlush()
	if self.data == nil then return end
	local txt = string.format(Language.RedPaper.RedPaperInfo, self.data.player_name, self.data.rob_yb_number)
	RichTextUtil.ParseRichText(self.node_tree.rich_explore_attr.node, txt, 18)
end

function WorldRedPaperRender:CreateSelectEffect() 
end

RedPaperEffectText = RedPaperEffectText or BaseClass(BaseRender)
function RedPaperEffectText:__init()
	self.time = 0
end

function RedPaperEffectText:__delete()
	self.view:removeFromParent()
end	

-- 创建选中特效
function RedPaperEffectText:CreateSelectEffect()
end

function RedPaperEffectText:CreateChild()
	-- HandleRenderUnit:AddUi(self.view, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)

	BaseRender.CreateChild(self)

	local number_bar = EffectNumberBar.New()
	number_bar:SetRootPath(ResPath.GetCommon("num_100_"))
	number_bar:SetPosition(0, -25)
	number_bar:SetContentSize(200, 50)
	number_bar:SetSpace(8)
	number_bar:SetHasPlus(false)
	number_bar:SetInterval(0.05)
	number_bar:SetGravity(NumberBarGravity.Right)
	number_bar:SetCompleteCallBack(BindTool.Bind(self.CompleteCallBack,self))
	self.number_bar = number_bar
	self.view:addChild(number_bar:GetView())

	-- local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
	self:SetPosition(-5, 35)
end	

function RedPaperEffectText:CompleteCallBack()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	if level > 0 and self.time > 0 then
		RedPackageCtrl.Instance:SendReceiveRedPaper()
	end
end	

function RedPaperEffectText:OnFlush()
	self.view:stopAllActions()
	self.number_bar:SetEffectNumber(EffectNumberBarActionType.EVERY_ROT,0,self.data,self.time, 7)
end	

function RedPaperEffectText:SetEffecTime(time)
	self.time = time
end