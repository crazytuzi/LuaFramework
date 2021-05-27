--通用失败面板
PracticeLoseView = PracticeLoseView or BaseClass(BaseView)

--需要增加提升的选项
LOSE_SHOW_TYPE = 
{
	{desc="首充提升海量战力", link="前往", icon=1,open_params=ViewDef.ChargeEveryDay},
	{desc="寻宝获得神装", link="前往", icon=2,open_params=ViewDef.Explore},
	{desc="提升铸造等级", link="前往", icon=3,open_params=ViewDef.Equipment},
	{desc="提升神炉等级", link="前往", icon=4,open_params=ViewDef.GodFurnace},
	{desc="历练提升战力", link="前往", icon=5,open_params=ViewDef.PracticeIcon},
}

function PracticeLoseView:__init()
	self:SetModal(true)
	self.texture_path_list = {
        'res/xui/practice.png',
    }
	self.config_tab = {
        {"practice_result_ui_cfg", 2, {0}, nil},
	}
	
end

function PracticeLoseView:__delete()
end

function PracticeLoseView:ReleaseCallBack()
	if self.streng_list then 
		self.streng_list:DeleteMe()
	end
	self.streng_list = nil
end

function PracticeLoseView:LoadCallBack(index, loaded_times)
	XUI.AddClickEventListener(self.node_t_list.btn_lose_exit.node, BindTool.Bind(self.OnExit, self), true)

	RenderUnit.CreateEffect(1124, self.node_t_list.ph_eff.node, 10, nil, nil, 80, 20)

	self:CreateStrengList()
	self:Flush()
end

function PracticeLoseView:OnExit()
	self:Close()
end

function PracticeLoseView:OpenCallBack()
end

function PracticeLoseView:ShowIndexCallBack()
	self:Flush()
end

function PracticeLoseView:CreateStrengList()
	if not self.streng_list then
		local ph = self.ph_list.ph_practice_lose_list
		self.streng_list = ListView.New()
		self.streng_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, LoseStrengCell, nil, nil, self.ph_list.ph_practice_lose_item)
		self.streng_list:SetItemsInterval(4)
		self.streng_list:GetView():setAnchorPoint(0, 0)
		self.streng_list:SetJumpDirection(ListView.Top)
		self.streng_list:SetMargin(2)
		self.streng_list:GetView():setSwallowTouches(swallow)
		self.node_t_list.layout_practice_lose.node:addChild(self.streng_list:GetView(), 100)
	end
end

function PracticeLoseView:OnFlush(param_t, index)
	if not self.streng_types then return end
	self.streng_list:SetDataList(LOSE_SHOW_TYPE)
end

--streng_type 变强类型 cd_time 倒计时 callback 关闭面板回调
function PracticeLoseView:SetData(streng_types,cd_time,callback)
	self.streng_types = streng_types	
	if cd_time > 0 then
		function cd_callback(elapse_time, total_time)
			if elapse_time >= total_time then
				self:Close();
			else
				local c = math.ceil(total_time - elapse_time)
				self.node_t_list.btn_lose_exit.node:setTitleText("退出("..c.."s)")
			end
		end
		CountDown.Instance:RemoveCountDown(self.cd_key)
		self.cd_key = CountDown.Instance:AddCountDown(cd_time, 1, cd_callback)
	end
	self.close_callback = callback
end

function PracticeLoseView:CloseCallBack(is_all)
	CountDown.Instance:RemoveCountDown(self.cd_key)
	if self.close_callback then
		self.close_callback()
	end
end


LoseStrengCell = LoseStrengCell or BaseClass(BaseRender)

function LoseStrengCell:CreateChildCallBack()
	self.go_link = RichTextUtil.CreateLinkText("", 20, COLOR3B.GREEN, nil, true)
	local ph = self.ph_list.ph_rich_go
	self.go_link:setPosition(ph.x, ph.y)
	XUI.AddClickEventListener(self.go_link, BindTool.Bind(self.OnClickLink, self), true)
	self.view:addChild(self.go_link, 10)
end

function LoseStrengCell:OnFlush()
	if self.data then
		local path = ResPath.GetPractice("practice_" .. self.data.icon)
		self.node_tree.img_icon.node:loadTexture(path)
		self.node_tree.lbl_desc.node:setString(self.data.desc)
		self.go_link:setString(self.data.link)
	end
end

function LoseStrengCell:OnClickLink()
	if self.data and self.data.open_params then 
		ViewManager.Instance:OpenViewByDef(self.data.open_params)
	end
end

function LoseStrengCell:CreateSelectEffect()
end