-- 开服英雄光翼
OpenServiceHeroWingPage = OpenServiceHeroWingPage or BaseClass()

function OpenServiceHeroWingPage:__init()
	self.view = nil
	
end	

function OpenServiceHeroWingPage:__delete()
	self:RemoveEvent()
	self.view = nil
end	

--初始化页面接口
function OpenServiceHeroWingPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:InitEvent()
	self:CreateWingShow()
	self:OnOpenSerHeroWingDataChange()
	XUI.RichTextSetCenter(self.view.node_t_list.rich_wing_addup_day.node)
end	      

--初始化事件
function OpenServiceHeroWingPage:InitEvent()
	self.hero_wing_evt = GlobalEventSystem:Bind(OpenServerActivityEventType.OPENSERVER_HERO_WING, BindTool.Bind(self.OnOpenSerHeroWingDataChange, self))
	XUI.AddClickEventListener(self.view.node_t_list.btn_wing_back_fetch.node, BindTool.Bind(self.OnFetchAward, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_wing_back_active.node, BindTool.Bind(self.OnGoActive, self), true)
end

--移除事件
function OpenServiceHeroWingPage:RemoveEvent()
	if self.hero_wing_evt then
		GlobalEventSystem:UnBind(self.hero_wing_evt)
		self.hero_wing_evt = nil
	end

	if self.big_herowing_effec then
		self.big_herowing_effec:setStop()
		self.big_herowing_effec = nil
	end
end

--更新视图界面
function OpenServiceHeroWingPage:UpdateData(data)
	for k, v in pairs(data) do
		if k == "all" then
			OpenServiceAcitivityCtrl.Instance:GetOpenServerHeroWingData(0)
		end
	end
end

function OpenServiceHeroWingPage:CreateWingShow()
	local ph = self.view.ph_list.ph_wing_show
	if nil == self.big_herowing_effec then
		local hero_wing_data = HeroWingData.Instance:GetHeroesInfoList()[5]
		self.big_herowing_effec = RenderUnit.CreateEffect(hero_wing_data.modelIcon, self.view.node_t_list.layout_wing_back_yb.node, 99, frame_interval, loops, ph.x, ph.y, callback_func)
	end
end

function OpenServiceHeroWingPage:OnOpenSerHeroWingDataChange()
	local data = OpenServiceAcitivityData.Instance:GetHeroWingData()
	if data then
		self.view.node_t_list.btn_wing_back_active.node:setVisible(data.buy_state == 0)
		self.view.node_t_list.btn_wing_back_fetch.node:setVisible(data.buy_state == 1)
		XUI.SetLayoutImgsGrey(self.view.node_t_list.btn_wing_back_fetch.node, data.award_state ~= 1, true)
		local content = string.format(Language.OpenServiceAcitivity.HeroWingDayTip, data.login_day)
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_wing_addup_day.node, content, 20)
	end
end

function OpenServiceHeroWingPage:OnFetchAward()
	OpenServiceAcitivityCtrl.Instance:GetOpenServerHeroWingData(1)
end

function OpenServiceHeroWingPage:OnGoActive()
	ViewManager.Instance:Open(ViewName.HeroWing)
end