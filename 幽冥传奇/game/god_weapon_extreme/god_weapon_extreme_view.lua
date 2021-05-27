require("scripts/game/god_weapon_extreme/god_weapon_extreme_page")
require("scripts/game/god_weapon_extreme/god_weapon_decompose_page")
require("scripts/game/god_weapon_extreme/god_fashion_extreme_page")
GodWeapoExtremeView = GodWeapoExtremeView or BaseClass(XuiBaseView)

function GodWeapoExtremeView:__init()
	self:SetModal(true)
	self.def_index = TabIndex.extreme_weapon
 	self.texture_path_list[1] = 'res/xui/equipment.png'
 	self.texture_path_list[2] = 'res/xui/role.png'
 	--self.is_async_load = false
    self.config_tab = {
    	{"common_ui_cfg", 5, {0}},
		{"common_ui_cfg", 1, {0}},
	
		{"GodWeapon_ui_cfg", 1, {TabIndex.extreme_weapon}},
		{"GodWeapon_ui_cfg", 2, {TabIndex.extreme_fashion}},
		{"GodWeapon_ui_cfg", 3, {TabIndex.weapon_decompose}},
		{"common_ui_cfg", 2, {0}},
	}
	--页面表
	self.page_list = {}
	self.page_list[TabIndex.extreme_weapon] = ExtremeWeaponPage.New()
	self.page_list[TabIndex.extreme_fashion] = ExtremeFashionPage.New()
	self.page_list[TabIndex.weapon_decompose] = WeaponDecomposePage.New()
	
	self.tabbar = TabbarTwo.New(Str2C3b("fff999"), Str2C3b("bdaa93"))
	self.tabbar:SetInterval(-4)
	self.tabbar:Init(Language.GodWeapon.TabGroup, {}, true)
	self.tabbar:SetSelectCallback(BindTool.Bind1(self.OnTabChangeIndexHandler, self))

	self.title_img_path = ResPath.GetEquipment("txt_weapon")
	self.remind_temp = {}
	GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindChange, self))
end


function GodWeapoExtremeView:__delete()
	self.tabbar:DeleteMe()
	self.tabbar = nil
end

function GodWeapoExtremeView:ReleaseCallBack()
	--清理页面生成信息
	for k,v in pairs(self.page_list) do
		v:DeleteMe()
	end

	if self.tabbar then
		self.tabbar:Release()
	end

	ViewManager.Instance:UnRegsiterTabFunUi(ViewName.GodWeapon)
end

function GodWeapoExtremeView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		ViewManager.Instance:RegsiterTabFunUi(ViewName.GodWeapon, self.tabbar)
	end
	if nil == self.page_list[index] then
		return
	end
	--初始化页面接口
	self.page_list[index]:InitPage(self)
end

function GodWeapoExtremeView:ShowIndexCallBack(index)
	self.tabbar:ChangeToIndex(index, self.root_node)

	self:Flush(index)
end

function GodWeapoExtremeView:OnTabChangeIndexHandler(index)
	self:ChangeToIndex(index)
end

function GodWeapoExtremeView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function GodWeapoExtremeView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	--ViewManager.Instance:Close(ViewName.EquipmentSoulStoneTip)
end

--刷新相应界面
function GodWeapoExtremeView:OnFlush(flush_param_t, index)
	for k,v in pairs(flush_param_t) do
		if k == "all" then
			if nil ~= self.page_list[index] then
				--更新页面接口
				self.page_list[index]:UpdateData(flush_param_t)
			end
		elseif k == "remind" then
			self:FlushTabbar()
		end
	end
end

function GodWeapoExtremeView:RemindChange(remind_name, num)
	if remind_name == RemindName.GodWeaponUp then
		--self.remind_temp[TabIndex.extreme_weapon] = num 
		self:Flush(0, "remind")
	elseif remind_name == RemindName.GodFashionUp then
		--self.remind_temp[TabIndex.extreme_fashion] = num 
		self:Flush(0, "remind")
	end
end

function GodWeapoExtremeView:FlushTabbar()
	self.tabbar:SetRemindByIndex(TabIndex.extreme_weapon, RemindManager.Instance:GetRemind(RemindName.GodWeaponUp) > 0)
	self.tabbar:SetRemindByIndex(TabIndex.extreme_fashion, RemindManager.Instance:GetRemind(RemindName.GodFashionUp) > 0)
end