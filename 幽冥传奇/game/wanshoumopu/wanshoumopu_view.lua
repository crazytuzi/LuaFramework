require("scripts/game/wanshoumopu/wanshoumopu_wanshou_page")
require("scripts/game/wanshoumopu/wanshoumopu_wanmo_page")
WanShouMoPuView = WanShouMoPuView or BaseClass(XuiBaseView)

function WanShouMoPuView:__init()
	-- self:SetModal(true)
	self.def_index = TabIndex.wanshou

	self.texture_path_list[1] = "res/xui/boss.png"
	self.texture_path_list[2] = "res/xui/role.png"
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
		{"wanshoumopu_ui_cfg", 1, {0}},
		{"wanshoumopu_ui_cfg", 2, {TabIndex.wanshou}},
		{"wanshoumopu_ui_cfg", 3, {TabIndex.wanmo}},
	}
	self.title_img_path = ResPath.GetBoss("title_wanshoumopu")
	--页面表
	self.page_list = {}
	self.page_list[TabIndex.wanshou] = WanshoumopuWanshouPage.New()
	self.page_list[TabIndex.wanmo] = WanshoumopuWanmoPage.New()
end

function WanShouMoPuView:__delete()
	
end

function WanShouMoPuView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:InitTabbar()
	end
	if self.page_list[index] then
		self.page_list[index]:InitPage(self)
	end
	XUI.AddClickEventListener(self.node_t_list.helpBtn.node, BindTool.Bind2(self.OnHelp, self))
end

function WanShouMoPuView:OpenCallBack()
	WanShouMoPuCtrl.Instance:InfoReq()
end

function WanShouMoPuView:ShowIndexCallBack(index)
	if self.tabbar ~= nil then
		self.tabbar:SelectIndex(index)
	end
	self:Flush(index)
end

function WanShouMoPuView:CloseCallBack()
	if self.tabbar ~= nil then
		self.tabbar:SelectIndex(1)
	end
end

function WanShouMoPuView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	--清理页面生成信息
	for k,v in pairs(self.page_list) do
		v:DeleteMe()
	end
end


function WanShouMoPuView:InitTabbar()
	if nil == self.tabbar then
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.root_node, 64, 587,
			BindTool.Bind1(self.SelectTabCallback, self), 
			Language.AllDayActivity.TabGroup, false, ResPath.GetCommon("toggle_104_normal"), nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar:SetSpaceInterval(5)
	end
end
function WanShouMoPuView:SelectTabCallback(index)
	self.tab_index = index
	self:ChangeToIndex(index)
end
function WanShouMoPuView:OnFlush(param_list, index)
	for k,v in pairs(param_list) do
		if k == "all" then
			if self.page_list[index] ~= nil then
				self.page_list[index]:UpdateData(param_t)
			end
		elseif k == "data" then
			if self.page_list[index] ~= nil then
				self.page_list[index]:FlushData()
			end
		end
	end
	
end
function WanShouMoPuView:OnHelp()
	DescTip.Instance:SetContent(Language.AllDayActivity.WanshoumopuDesc,Language.AllDayActivity.WanshoumopuDescTitle)
end