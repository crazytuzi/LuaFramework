------------------------------------------------------------
--战将职业选择View
------------------------------------------------------------
HeroProfChoseView = HeroProfChoseView or BaseClass(XuiBaseView)
function HeroProfChoseView:__init()
	self.texture_path_list[1] = "res/xui/zhanjiang.png"
	self.is_async_load = false
	-- self:SetModal(true)

	self.config_tab = {
		{"hero_prof_chose_ui_cfg", 1, {0}},
	}

	self.selec_id = NewHeroConfig.HeroList[1].heroId
end

function HeroProfChoseView:__delete()
end

function HeroProfChoseView:ReleaseCallBack()
	if self.hero_prof_chose_list then
		self.hero_prof_chose_list:DeleteMe()
		self.hero_prof_chose_list = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function HeroProfChoseView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		self:InitTabbar()
		self:CreateHeroProfChoseList()
		XUI.AddClickEventListener(self.node_t_list.btn_confirm.node, BindTool.Bind(self.ConfirmActivateClicked, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_close.node, BindTool.Bind1(self.OnClose, self), true)
	end
end

function HeroProfChoseView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local index = sex == 0 and 2 or 1
	self.tabbar:ChangeToIndex(index)
	self:OnChangeTabbar(index)
	Scene.Instance:GetMainRole():StopMove()
end

function HeroProfChoseView:ShowIndexCallBack(index)
	self:Flush(index)
end

function HeroProfChoseView:OnFlush(param_t, index)
	RichTextUtil.ParseRichText(self.node_t_list.txt_desc.node, Language.Zhanjiang.HeroChoseSkillDesc, 20, COLOR3B.YELLOW)
end

function HeroProfChoseView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self:DeleteDelayTimer()
	if self.selec_id then
		-- print("selec_id", self.selec_id)
		ZhanjiangCtrl.Instance:HeroActivateReq(self.selec_id)
	end
	Scene.Instance:GetMainRole():AutoTask()
end

function HeroProfChoseView:OnClose()
	self:Close()
end

function HeroProfChoseView:CreateHeroProfChoseList()
	self.hero_prof_chose_list = ListView.New()
	local ph = self.ph_list.ph_hero_prof_list
	self.hero_prof_chose_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, HeroProfItem, gravity, isBounce, self.ph_list.ph_prof_item)
	-- self.hero_prof_chose_list:SetMargin(3)
	self.hero_prof_chose_list:SetItemsInterval(2)
	self.hero_prof_chose_list:SetSelectCallBack(BindTool.Bind(self.SelectItemCallback, self))
	self.node_t_list.layout_hero_prof_chose.node:addChild(self.hero_prof_chose_list:GetView(), 100, 100)
end

function HeroProfChoseView:InitTabbar()
	if nil == self.tabbar then
		local ph = self.ph_list.ph_tabbar
		local path_list = {ResPath.GetCommon("toggle_119_normal"), ResPath.GetCommon("toggle_120_normal"),}
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithPathList(self.root_node, ph.x, ph.y, BindTool.Bind(self.OnChangeTabbar, self), 
			path_list, false)
		self.tabbar:SetSpaceInterval(15)
		self.tabbar:ChangeToIndex(self:GetShowIndex())
	end
end

function HeroProfChoseView:OnChangeTabbar(index)
	if index > 0 then
		local prof_data = ZhanjiangData.GetHeroIdTable(index)
		self.hero_prof_chose_list:SetData(prof_data)
		self.hero_prof_chose_list:SelectIndex(1)
	end
end

function HeroProfChoseView:SelectItemCallback(item, index)
	if not item or not item:GetData() then return end
	local data = item:GetData()
	self.selec_id = data.id
	-- self:DeleteDelayTimer()
	self:CreateDelayTimer()	
	self.node_t_list.layout_hero_prof_chose.layout_frame.img_bg_hero_prof.node:loadTexture(ResPath.GetBigPainting("hero_chose_bg_" .. index,true))
end

function HeroProfChoseView:DelayRandomChose()
	self.cd_time = self.cd_time - 1
	self.node_t_list.txt_time.node:setString(string.format(Language.Zhanjiang.HeroChoseTime, self.cd_time))
	if self.cd_time < 1 then
		self:DeleteDelayTimer()
		local index = self.tabbar:GetCurSelectIndex()
		if index and index > 0 then
			local prof_data = ZhanjiangData.GetHeroIdTable(index)
			if next(prof_data) then
				local chose_idx = math.random(1, 3)
				self.selec_id = prof_data[chose_idx].id
				self:OnCloseHandler()
			end
		end
	end
end

function HeroProfChoseView:CreateDelayTimer()
	self.cd_time = 30
	if not self.delay_chose_timer then
		self.delay_chose_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.DelayRandomChose, self),  1)
	end
end

function HeroProfChoseView:DeleteDelayTimer()
	if self.delay_chose_timer then
		GlobalTimerQuest:CancelQuest(self.delay_chose_timer)
		self.delay_chose_timer = nil
	end
end

--确定激活
function HeroProfChoseView:ConfirmActivateClicked()
	self:OnCloseHandler()
end



--英雄职业itemrender
HeroProfItem = HeroProfItem or BaseClass(BaseRender)
function HeroProfItem:__init()
end

function HeroProfItem:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img_hero_prof.node:setAnchorPoint(0, 0)
	self.node_tree.img_hero_prof.node:setPosition(0, 0)
end

function HeroProfItem:OnFlush()
	if self.data == nil then return end
	self.node_tree.img_hero_prof.node:loadTexture(ResPath.GetBigPainting("hero_prof_" .. self.data.sex .. "_" .. self.index, false))
end

function HeroProfItem:CreateSelectEffect()
	local size = self.view:getContentSize()
	local path = ResPath.GetZhanjiang("prof_bg_" .. self.index)
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, path, true)
	self.select_effect:setAnchorPoint(0, 0)
	self.select_effect:setPosition(-10, -10)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end


