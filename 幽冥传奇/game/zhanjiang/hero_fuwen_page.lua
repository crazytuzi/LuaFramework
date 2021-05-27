--英雄符文页面
HeroFuWenPage = HeroFuWenPage or BaseClass()
function HeroFuWenPage:__init()
	self.view = nil
end	

function HeroFuWenPage:__delete()
	self:RemoveEvent()
	if self.cur_attr_list then
		self.cur_attr_list:DeleteMe()
		self.cur_attr_list = nil
	end
	if self.nxt_attr_list then
		self.nxt_attr_list:DeleteMe()
		self.nxt_attr_list = nil
	end
	self.is_req = nil
	self.view = nil
	self.old_fuwen_lv = nil
	ClientCommonButtonDic[CommonButtonType.ZHANSHEN_FUWEN_UP_LEVEL_BTN] = nil
end	

--初始化页面接口
function HeroFuWenPage:InitPage(view)
	self.view = view
	--绑定要操作的元素
	self:CreateStarBeads()
	self:CreateCurAttrList()
	self:CreateNxtAttrList()
	

	XUI.AddClickEventListener(self.view.node_t_list.btn_fuwen_up_lev.node, BindTool.Bind2(self.UpLvClicked, self))
	XUI.AddClickEventListener(self.view.node_t_list.btn_fuwen_quick_buy.node, BindTool.Bind2(self.OpenQuickBuyShop, self))
	-- XUI.AddClickEventListener(self.view.node_t_list.layout_role_info.layout_shizhuang.btn_open_view.node, BindTool.Bind2(self.OpenViewRuleTips, self))
	-- XUI.AddClickEventListener(self.view.node_t_list.layout_hero_fuwen.btn_circle.node, BindTool.Bind2(self.OpenCircleView, self))

	self:InitEvent()

	ClientCommonButtonDic[CommonButtonType.ZHANSHEN_FUWEN_UP_LEVEL_BTN] = self.view.node_t_list.btn_fuwen_up_lev.node
	
end	

--初始化事件
function HeroFuWenPage:InitEvent()
	self.role_data_event = BindTool.Bind(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_event)

	-- self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback, self)			--监听物品数据变化
	-- ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
end

--移除事件
function HeroFuWenPage:RemoveEvent()
	if self.role_data_event then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
		self.role_data_event = nil
	end	
	if self.itemdata_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil 
	end

	if self.req_uplv_timer then
		GlobalTimerQuest:CancelQuest(self.req_uplv_timer)
		self.req_uplv_timer = nil
	end
end

function HeroFuWenPage:ItemDataChangeCallback()
	-- self.view:Flush(TabIndex.role_intro, "change_fashion")
end

--更新视图界面
function HeroFuWenPage:UpdateData(data)
	self.old_fuwen_lv = nil
	self.view.node_t_list.btn_fuwen_up_lev.node:setEnabled(true)
	self:FlushInfo()
end	

function HeroFuWenPage:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.HERO_FUWEN_LEVEL or key == OBJ_ATTR.HERO_FUWEN_EXP then
		self:FlushInfo()
	end
end

function HeroFuWenPage:FlushInfo()
	local fuwen_lv = RoleData.Instance:GetAttr(OBJ_ATTR.HERO_FUWEN_LEVEL)
	local fuwen_exp = RoleData.Instance:GetAttr(OBJ_ATTR.HERO_FUWEN_EXP)

	local step, star = ZhanjiangData.GetFuWenStepStar(fuwen_lv)
	for i, v in ipairs(self.beads_list) do
		if i <= star then
			v:setGrey(false)
		else
			v:setGrey(true)
		end
	end

	local cur_consume_cfg = ZhanjiangData.GetFuWenConsumeCfgByLv(fuwen_lv)
	if cur_consume_cfg then
		self.view.node_t_list.txt_cur_lev_name.node:setString(string.format(Language.Zhanjiang.FuWenStepStar, step, star))
	else
		self.view.node_t_list.txt_cur_lev_name.node:setString("")
	end
	local consume_cfg = ZhanjiangData.GetFuWenConsumeCfgByLv(fuwen_lv + 1)
	self.is_req = consume_cfg and fuwen_exp >= consume_cfg.consumes[1].count
	local color = COLOR3B.GREEN
	if consume_cfg then
		if fuwen_exp < consume_cfg.consumes[1].count then
			color = COLOR3B.RED
		end
		if self.old_fuwen_lv and self.old_fuwen_lv ~= fuwen_lv then
			self.view.node_t_list.btn_fuwen_up_lev.node:setEnabled(not self.is_req)
			if self.req_uplv_timer then
				GlobalTimerQuest:CancelQuest(self.req_uplv_timer)
			end
			self.req_uplv_timer = GlobalTimerQuest:AddDelayTimer(function ()
				if self.is_req then
					self.view.node_t_list.btn_fuwen_up_lev.node:setEnabled(false)
					ZhanjiangCtrl.Instance:HeroFuWenUpLvReq()
				end
			end, 0.35)
		end
		self.old_fuwen_lv = fuwen_lv
		self.view.node_t_list.txt_fuwen_cost.node:setString(consume_cfg.consumes[1].count)
	else
		self.is_req = nil
		self.view.node_t_list.txt_fuwen_cost.node:setString(Language.Common.MaxLevel)
	end
	local cur_add_attr_str_t = ZhanjiangData.GetHeroFuWenAddAttrByLv(fuwen_lv)
	local nxt_add_attr_str_t = ZhanjiangData.GetHeroFuWenAddAttrByLv(fuwen_lv + 1)
	self.cur_attr_list:SetDataList(cur_add_attr_str_t)
	self.nxt_attr_list:SetDataList(nxt_add_attr_str_t)
	self.view.node_t_list.txt_fuwen_own.node:setString(fuwen_exp)
	self.view.node_t_list.txt_fuwen_own.node:setColor(color)
	
end

function HeroFuWenPage:CreateStarBeads()
	self.beads_list = {}
	for i = 1, 10 do
		local ph = self.view.ph_list["ph_img_bead_" .. i]
		local bead_img = XUI.CreateImageView(ph.x, ph.y, ResPath.GetCommon("bead_1"), true)
		bead_img:setGrey(true)
		self.view.node_t_list.layout_hero_fuwen.node:addChild(bead_img, 20)
		self.beads_list[i] = bead_img
	end
end

function HeroFuWenPage:CreateCurAttrList()
	self.cur_attr_list = ListView.New()
	local ph_role_zhuattr_list = self.view.ph_list.ph_fuwen_attr_list_1
	self.cur_attr_list:Create(ph_role_zhuattr_list.x, ph_role_zhuattr_list.y, ph_role_zhuattr_list.w, ph_role_zhuattr_list.h, nil, HeroFuWenAttrRender, nil, nil, self.view.ph_list.ph_fuwen_attr_item)
	self.view.node_t_list.layout_hero_fuwen.node:addChild(self.cur_attr_list:GetView(), 100, 100)
	-- self.cur_attr_list:GetView():setAnchorPoint(0,0)
	self.cur_attr_list:SetItemsInterval(8)
	self.cur_attr_list:SetMargin(5)
	self.cur_attr_list:JumpToTop(true)
end

function HeroFuWenPage:CreateNxtAttrList()
	self.nxt_attr_list = ListView.New()
	local ph_role_fuattr_list = self.view.ph_list.ph_fuwen_attr_list_2
	self.nxt_attr_list:Create(ph_role_fuattr_list.x, ph_role_fuattr_list.y, ph_role_fuattr_list.w, ph_role_fuattr_list.h, nil, HeroFuWenAttrRender, nil, nil, self.view.ph_list.ph_fuwen_attr_item)
	self.view.node_t_list.layout_hero_fuwen.node:addChild(self.nxt_attr_list:GetView(), 100, 100)
	-- self.nxt_attr_list:GetView():setAnchorPoint(0,0)
	self.nxt_attr_list:SetItemsInterval(8)
	self.nxt_attr_list:SetMargin(5)
	self.nxt_attr_list:JumpToTop(true)
end

-- 符文升级
function HeroFuWenPage:UpLvClicked()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	self.is_req = true
	ZhanjiangCtrl.Instance:HeroFuWenUpLvReq()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function HeroFuWenPage:ResetReq()
	self.old_fuwen_lv = nil
	if self.req_uplv_timer then
		GlobalTimerQuest:CancelQuest(self.req_uplv_timer)
		self.req_uplv_timer = nil
	end
end

function HeroFuWenPage:OpenQuickBuyShop()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	ViewManager.Instance:Open(ViewName.Shop, 1)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function HeroFuWenPage:OpenViewRuleTips()
	DescTip.Instance:SetContent(Language.Role.FashionDescContent, Language.Role.FashionDescTitle)
end

function HeroFuWenPage:OpenCircleView()
	ViewManager.Instance:Open(ViewName.Circle)
end
