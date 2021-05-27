require("scripts/game/boss_sport/boss_personal_page")
-- require("scripts/game/boss_sport/boss_equipment_page")
require("scripts/game/boss_sport/boss_team_page")
-- require("scripts/game/boss/boss_shouhun_page")
BossSportView = BossSportView or BaseClass(XuiBaseView)

function BossSportView:__init()
	self.def_index = TabIndex.boss_fuben_equipment
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/boss.png'
	self.texture_path_list[2] = 'res/xui/strength_fb.png'
	self.title_img_path = ResPath.GetBoss("title_biaoti")
	self.is_async_load = false
	self.config_tab = {
		{"common_ui_cfg", 5, {0}},
		{"common_ui_cfg", 1, {0}},
		{"boss_ui_cfg", 3, {TabIndex.boss_fuben_personal}},
		-- {"boss_ui_cfg", 7, {TabIndex.boss_fuben_equipment}},
		{"boss_ui_cfg", 9, {TabIndex.boss_fuben_team}},
		{"common_ui_cfg", 2, {0}},
	}


	--页面表
	self.page_list = {}
	self.page_list[TabIndex.boss_fuben_personal] = BossPersonPage.New()
	-- self.page_list[TabIndex.boss_fuben_equipment] = BossEquipmentPage.New()
	self.page_list[TabIndex.boss_fuben_team] = BossTeamPage.New()
	self.page_list[TabIndex.boss_shouhun] = BossShouhunPage.New()

	-- self.tabbar = TabbarTwo.New()
	self.tabbar = TabbarTwo.New(Str2C3b("fff999"), Str2C3b("bdaa93"))
	self.tabbar:Init(Language.Boss.TabGrop_1, {nil, nil, nil, nil}, true)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.SelectTabCallback, self))
	self.remind_temp = {}
	GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindChange, self))
end

function BossSportView:__delete()
	self.tabbar:DeleteMe()
	self.tabbar = nil
end

function BossSportView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:Release()
	end

	--清理页面生成信息
	for k,v in pairs(self.page_list) do
		v:DeleteMe()
	end

	ViewManager.Instance:UnRegsiterTabFunUi(ViewName.BossSportView)
end

function BossSportView:OpenCallBack()
	--BossSportCtrl.Instance:EquipBossReq(1, 0)
	BossSportCtrl.Instance:SendPersonalBossDataReq()
	BossSportCtrl.Instance:ReqPlayerFubenData()
	self.tabbar:ChangeToIndex(self.show_index, self.root_node)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BossSportView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BossSportView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		ViewManager.Instance:RegsiterTabFunUi(ViewName.BossSportView, self.tabbar)
		self.tabbar:SetToggleVisible(TabIndex.boss_fuben_personal, false)
	end

	if nil == self.page_list[index] then
		return
	end

	--初始化页面接口
	self.page_list[index]:InitPage(self)
end

function BossSportView:ShowIndexCallBack(index)
	self.tabbar:ChangeToIndex(index, self.root_node)
	self:Flush(index)
end

function BossSportView:OnFlush(flush_param_t, index)
	if nil ~= self.page_list[index] then
		--更新页面接口
		self.page_list[index]:UpdateData(flush_param_t)
	end
	self:FlushTabbarBtn()
end

function BossSportView:SelectTabCallback(index)
	self:ChangeToIndex(index)
end


function BossSportView:OnGetUiNode(node_name)
	local node, is_next = XuiBaseView.OnGetUiNode(self, node_name)
	if node then
		return XuiBaseView.OnGetUiNode(self, node_name) 
	end
	if node_name == NodeName.BossPersonal1 and self.boss_list and self.boss_list:GetItemAt(1) then
		local cell = self.boss_list:GetItemAt(1)
		return cell:GetView(), true
	end
end

function BossSportView:RemindChange(remind_name, num)
	if remind_name == RemindName.BossPersonal then
		self.remind_temp[TabIndex.boss_fuben_personal] = num 
		self:FlushTabbarBtn()
	-- elseif remind_name == RemindName.EquipBoss then
	-- 	self.remind_temp[TabIndex.boss_fuben_equipment] = num 
	-- 	self:FlushTabbarBtn()
	-- elseif remind_name == RemindName.BossShouhun then
	-- 	self.remind_temp[TabIndex.boss_shouhun] = num 
	-- 	self:FlushTabbarBtn()	
	end
end

function BossSportView:FlushTabbarBtn()
	for k,v in pairs(self.remind_temp) do
		self.tabbar:SetRemindByIndex(k, v > 0)
	end
end


