--攻城战活动信息页面
ImperialCityActInfoPage = ImperialCityActInfoPage or BaseClass()


function ImperialCityActInfoPage:__init()
	self.view = nil
	self.gongcheng_name_list = nil
end	

function ImperialCityActInfoPage:__delete()
	self:RemoveEvent()
	self.view = nil
	self.parent = nil

	if self.gongcheng_name_list then
		self.gongcheng_name_list:DeleteMe()
		self.gongcheng_name_list = nil
	end	
end	

--初始化页面接口
function ImperialCityActInfoPage:InitPage(view)
	if not view then ErrorLog("ImperialCityActInfoPage View Does Not Exist. InitPage Failed!!!!!") return end
	--绑定要操作的元素
	self.view = view
	self.parent = view and view.node_t_list.layout_act_info
	self:CreateGongchengListView()
	self:InitEvent()

	
end	

--初始化事件
function ImperialCityActInfoPage:InitEvent()
	if not self.parent then return end

	XUI.AddClickEventListener(self.parent.btn_back.node, BindTool.Bind(self.OnBack, self), true)
	XUI.AddClickEventListener(self.parent.baoming_btn.node, BindTool.Bind(self.OnBaoMing, self))
	
	self.manager_info_handler = GlobalEventSystem:Bind(GongchengEventType.GONGCHENG_WIN_MANAGER_INFO,BindTool.Bind(self.OnManagerInfoChange,self))
	self.guide_list_handler = GlobalEventSystem:Bind(GongchengEventType.GONGCHENG_GUILD_LIST,BindTool.Bind(self.OnManagerInfoChange,self))
end

--移除事件
function ImperialCityActInfoPage:RemoveEvent()
	if self.manager_info_handler then
		GlobalEventSystem:UnBind(self.manager_info_handler)
		self.manager_info_handler = nil
	end	
	if self.guide_list_handler then
		GlobalEventSystem:UnBind(self.guide_list_handler)
		self.guide_list_handler = nil
	end	
end

function ImperialCityActInfoPage:CreateGongchengListView()
	if self.gongcheng_name_list == nil then
		local ph = self.view.ph_list.ph_gongcheng_name_list
		self.gongcheng_name_list = ListView.New()
		self.gongcheng_name_list:Create(ph.x, ph.y, ph.w, ph.h, nil, GongchengNameRender, nil, nil, self.view.ph_list.ph_gongcheng_name_item)
		self.view.node_t_list.layout_act_info.node:addChild(self.gongcheng_name_list:GetView(), 100)
		self.gongcheng_name_list:SetItemsInterval(5)
		self.gongcheng_name_list:SetJumpDirection(ListView.Top)
	end	
end	

function ImperialCityActInfoPage:OnManagerInfoChange()
	self:UpdateData()
end	

--更新视图界面
function ImperialCityActInfoPage:UpdateData(data)
	if not self.parent then return end
	local date_str = WangChengZhengBaData.GetNextOpenTimeDateStr()
	self.parent.lbl_atk_city_time.node:setString(date_str)

	local win_name = WangChengZhengBaData.Instance:GetShouchengGuildName()
	self.parent.lbl_def_side.node:setString(win_name)

	self.gongcheng_name_list:SetDataList(WangChengZhengBaData.Instance:GetGongChengGuide())
		
	local content = Language.WangChengZhengBa.Rule_Content[2]
	HtmlTextUtil.SetString(self.parent.rich_apply_rules.node, content or "")
	-- RichTextUtil.ParseRichText(self.parent.rich_apply_rules.node, content, 22)
end	

function ImperialCityActInfoPage:OnBack()
	self.view:ShowIndex(TabIndex.imperial_city_competite)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function ImperialCityActInfoPage:OnBaoMing()
	local guild_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID)
	if guild_id > 0 then
		ViewManager.Instance:Open(ViewName.Guild,TabIndex.guild_activity)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.WangChengZhengBa.NotCanBaoMing)
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end	



GongchengNameRender = GongchengNameRender or BaseClass(BaseRender)
function GongchengNameRender:__init()
	
end

function GongchengNameRender:__delete()
	
end

function GongchengNameRender:OnFlush()
	self.node_tree.lbl_gongcheng_name_text.node:setString(self.data.name)	
end
