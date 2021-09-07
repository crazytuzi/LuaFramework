JianlingView = JianlingView or BaseClass(BaseRender)

-- 神兵-剑灵
function JianlingView:__init()
	self.cell_list = {}			-- 神器cell列表
	self.select_index = 1       -- 默认选中第1种神兵
	self.upgrade_next_time = 0
	self.last_level = 0
	self.is_auto = false		-- 是否自动升级
end

function JianlingView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function JianlingView:LoadCallBack(instance)
	-- 剑灵Item列表
	self.jianling_list_view = self:FindObj("JianlingItemList")
	local list_delegate = self.jianling_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	-- 剑灵模型
	self.model_display = self:FindObj("ModelDisplay")
	if self.model_display then
		self.model = RoleModel.New("shenbing_xiangqian_panel",700)
		self.model:SetDisplay(self.model_display.ui3d_display)
	end
	self:SetModel()
	
	-- 材料数量
	self.stuff_num = self:FindVariable("StuffNum")
	-- 升级剑灵按钮
	self:ListenEvent("OnClickUpgrade", BindTool.Bind(self.OnClickUpgrade, self))
	self:ListenEvent("OnClickShenqiTip", BindTool.Bind(self.OnClickShenqiTip, self))
	self:ListenEvent("OnClickShow", BindTool.Bind(self.OnClickShow, self))
	-- 进度条
	self.exp_progress = self:FindVariable("ExpProgress")
	-- 百分比
	self.percent = self:FindVariable("Percent")

	-- 属性
	self.hp = self:FindVariable("Hp")
	self.gongji = self:FindVariable("Gongji")
	self.fangyu = self:FindVariable("Fangyu")
	self.mingzhong = self:FindVariable("Mingzhong")
	self.baoji = self:FindVariable("Baoji")
	self.next_hp = self:FindVariable("NextHp")
	self.next_gongji = self:FindVariable("NextGongji")
	self.next_fangyu = self:FindVariable("NextFangyu")
	self.next_mingzhong = self:FindVariable("NextMingzhong")
	self.next_baoji = self:FindVariable("NextBaoji")
	self.cur_jianling_level = self:FindVariable("CurJianlingLevel")
	self.is_active_texiao = self:FindVariable("IsActiveTexiao")
	self.texiao_active_condition = self:FindVariable("TexiaoActiveCondition")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("ItemCell"))

	self.upgrade_btn = self:FindObj("UpGradeBtn")
	self.max_level = self:FindVariable("MaxLevel")

	--神器名字
	self.main_role_prof = GameVoManager.Instance:GetMainRoleVo().prof
	self.name_image = self:FindVariable("NameImage")

	self.jianlin_text = self:FindVariable("JianLinText")
	self.jianlin_baoshi = self:FindVariable("JianLinBaoshi")
	self.upgrade_text = self:FindVariable("UpGrade")

	self:Flush()
end

function JianlingView:OpenCallBack()
	if ShenqiCtrl.Instance.view.xiangqian_view then
		self:SetSelectIndex(ShenqiCtrl.Instance.view.xiangqian_view.select_index)
	end
	self:SetModel()
end

function JianlingView:OnFlush(param_list)		
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end

	self:FlushAttrData(self.select_index)

	self:FlushMaterialItem()

	self:FlushNameImage()
	self.jianling_list_view.scroller:ReloadData(0)
end

function JianlingView:FlushNameImage()
	if self.main_role_prof then
		local bundle, asset = ResPath.GetShenqiIcon(string.format("shenqi_%s_%s", self.select_index, self.main_role_prof))
		if bundle and asset then
			self.name_image:SetAsset(bundle, asset)
		end
	end
end

function JianlingView:FlushUpgradeOptResult(result)
	if 0 == result then 		-- 不再发送升级请求
		self.is_auto = false
	elseif 1 == result then 	-- 继续发送请求
		self:AutoUpgradeOnce()
	end
end

function JianlingView:OnClickShow()
	if self.select_index ~= nil then
		ShenqiCtrl.Instance:OpenShenQiTip(SHENQI_TIP_TYPE.SHENBING, self.select_index)
	end
end

-- 获得cell的数量
function JianlingView:GetNumberOfCells()
	return #ShenqiData.Instance:GetShenbingInlayCfg()
end

-- 刷新cell
function JianlingView:RefreshCell(cell, cell_index)
	local cur_cell = self.cell_list[cell]
	local data_list = ShenqiData.Instance:GetShenbingInlayCfg()
	if cur_cell == nil then
		cur_cell = ShenbingItem.New(cell.gameObject, self, ShenqiView.TabDef.ShenBingJianLing)
		self.cell_list[cell] = cur_cell
	end
	cell_index = cell_index + 1
	cur_cell:SetIndex(cell_index)
	cur_cell:SetData(data_list[cell_index])
end

function JianlingView:SetSelectIndex(index)
	if index then
		self.select_index = index
		self.is_auto = false
	end
end

function JianlingView:GetSelectIndex()
	return self.select_index
end

function JianlingView:SetModel()
	--设置神兵模型
	if self.model then
		if self.select_index == self.last_index then return end
		self.last_index = self.select_index
		local res_id = ShenqiData.Instance:GetResCfgByIamgeID(self.select_index)
		self.model:SetMainAsset(ResPath.GetShenQiWeaponModel(res_id))
	end
end

function JianlingView:FlushMaterialItem()
	local shenqi_other_cfg = ShenqiData.Instance:GetShenqiOtherCfg()
	local shenbing_uplevel_stuff_num = ItemData.Instance:GetItemNumInBagById(shenqi_other_cfg.shenbing_uplevel_stuff)
	self.item:SetData({item_id = shenqi_other_cfg.shenbing_uplevel_stuff, num = shenbing_uplevel_stuff_num})
end

function JianlingView:OnClickUpgrade()
	if self.is_auto then
		self.is_auto = false
	else
		self.is_auto = true
	end	
	self:AutoUpgradeOnce()
end

-- 刷新属性
function JianlingView:FlushAttrData(index)
	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	local cur_exp = shenqi_all_info.shenbing_list[index].exp
	local cur_level = shenqi_all_info.shenbing_list[index].level
	if cur_level~= self.last_level then
		self.is_auto = false
	end
	self.last_level = cur_level

	local shenbing_upgrade_cfg = ShenqiData.Instance:GetShenbingUpgradeCfg()
	-- 当前属性
	local cur_jianling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level,shenbing_upgrade_cfg)
	if next(cur_jianling_cfg) then
		self.hp:SetValue(cur_jianling_cfg.maxhp)
		self.gongji:SetValue(cur_jianling_cfg.gongji)
		self.fangyu:SetValue(cur_jianling_cfg.fangyu)
		self.mingzhong:SetValue(cur_jianling_cfg.mingzhong)
		self.baoji:SetValue(cur_jianling_cfg.baoji)
	else
		self.hp:SetValue(0)
		self.gongji:SetValue(0)
		self.fangyu:SetValue(0)
		self.mingzhong:SetValue(0)
		self.baoji:SetValue(0)
	end

	local jianling_active_state = ShenqiData.Instance:GetStuffActiveState(JIANLING_TAB,self.select_index,shenbing_upgrade_cfg)
	self.texiao_active_condition:SetValue(jianling_active_state)

	local next_jianling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level + 1,shenbing_upgrade_cfg)
	if nil == next(next_jianling_cfg) then 
		self.exp_progress:SetValue(0)
		self.percent:SetValue("0/0")
		-- 下一级属性
		self.next_hp:SetValue(cur_jianling_cfg.maxhp)
		self.next_gongji:SetValue(cur_jianling_cfg.gongji)
		self.next_fangyu:SetValue(cur_jianling_cfg.fangyu)
		self.next_mingzhong:SetValue(cur_jianling_cfg.mingzhong)
		self.next_baoji:SetValue(cur_jianling_cfg.baoji)

		self.upgrade_btn.button.interactable = false
		self.max_level:SetValue(true)
	else
		self.exp_progress:SetValue(cur_exp/next_jianling_cfg.need_exp)
		self.percent:SetValue(cur_exp .. "/" .. next_jianling_cfg.need_exp)
		-- 下一级属性
		self.next_hp:SetValue(next_jianling_cfg.maxhp)
		self.next_gongji:SetValue(next_jianling_cfg.gongji)
		self.next_fangyu:SetValue(next_jianling_cfg.fangyu)
		self.next_mingzhong:SetValue(next_jianling_cfg.mingzhong)
		self.next_baoji:SetValue(next_jianling_cfg.baoji)

		self.upgrade_btn.button.interactable = true
		self.max_level:SetValue(false)
	end

	self.cur_jianling_level:SetValue(cur_level)
	self.is_active_texiao:SetValue(cur_level < 30)
	local addnum = ShenqiData.Instance:GetShenBingLevel()
	local add_per = ShenqiData.Instance:GetJiaChengPer(SHENBING_ADDPER.QILING_TYPE)
	local act_num = (addnum * add_per) / 100
	self.jianlin_text:SetValue(act_num)
	self.jianlin_baoshi:SetValue(Language.ShenQiAddPer[SHENBING_ADDPER.QILING_TYPE])

	if self.is_auto then
		self.upgrade_text:SetValue(Language.Shenqi.StopUp)
	else
		self.upgrade_text:SetValue(Language.Shenqi.ShenJiJianLing)
	end
end

-- 自动升级
function JianlingView:AutoUpgradeOnce()
	local upgrade_next_time = 0
	if self.upgrade_timer_quest then
		if self.upgrade_next_time >= Status.NowTime then
			upgrade_next_time = self.upgrade_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end
	if self.is_auto then
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.UpdateOcne, self), upgrade_next_time)
	end
end

function JianlingView:UpdateOcne(upgrade_next_time)
	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	local cur_level = shenqi_all_info.shenbing_list[self.select_index].level
	local shenbing_upgrade_cfg = ShenqiData.Instance:GetShenbingUpgradeCfg()
	local level_num =  #shenbing_upgrade_cfg
	if cur_level == level_num then self.is_auto = false return end

	local next_jianling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level + 1,shenbing_upgrade_cfg)
	ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_SHENBING_UPLEVEL, self.select_index, 1, next_jianling_cfg.send_pack_num)

	self.upgrade_next_time = Status.NowTime + next_jianling_cfg.next_time
end

function JianlingView:OnClickShenqiTip()
	TipsCtrl.Instance:ShowHelpTipView(201)
end

function JianlingView:ClearData()
	self.is_auto = false
end
