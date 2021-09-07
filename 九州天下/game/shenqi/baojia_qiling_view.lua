QilingView = QilingView or BaseClass(BaseRender)

-- 宝甲-器灵
function QilingView:__init()
	self.cell_list = {}			-- 神器cell列表
	self.select_index = 1       -- 默认选中第1种神兵
	self.upgrade_next_time = 0
	self.last_level = 0
	self.is_auto = false		-- 是否自动升级
end

function QilingView:__delete()
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

function QilingView:LoadCallBack(instance)
	-- 器灵Item列表
	self.qiling_list_view = self:FindObj("QilingItemList")
	local list_delegate = self.qiling_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.qiling_list_view.scroller:ReloadData(0)

	-- 器灵模型
	self.model_display = self:FindObj("ModelDisplay")
	if self.model_display then
		self.model = RoleModel.New("baojia_xiangqian_panel", 500)
		self.model:SetDisplay(self.model_display.ui3d_display)
	end
	self:SetModel()

	-- 材料数量
	self.stuff_num = self:FindVariable("StuffNum")
	-- 升级剑灵按钮
	self:ListenEvent("OnClickUpgrade", BindTool.Bind(self.OnClickUpgrade, self))
	self:ListenEvent("OnClickShow", BindTool.Bind(self.OnClickShow, self))
	-- 进度条
	self.exp_progress = self:FindVariable("ExpProgress")
	-- 百分比
	self.percent = self:FindVariable("Percent")

	-- 属性
	self.hp = self:FindVariable("Hp")
	self.gongji = self:FindVariable("Gongji")
	self.fangyu = self:FindVariable("Fangyu")
	self.shanbi = self:FindVariable("Shanbi")
	self.baoji = self:FindVariable("Baoji")
	self.next_hp = self:FindVariable("NextHp")
	self.next_gongji = self:FindVariable("NextGongji")
	self.next_fangyu = self:FindVariable("NextFangyu")
	self.next_shanbi = self:FindVariable("NextShanbi")
	self.next_baoji = self:FindVariable("NextBaoji")
	self.cur_qiling_level = self:FindVariable("CurQilingLevel")
	self.is_active_texiao = self:FindVariable("IsActiveTexiao")
	self.texiao_active_condition = self:FindVariable("TexiaoActiveCondition")

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("ItemCell"))

	self.upgrade_btn = self:FindObj("UpgradeBtn")
	self.is_max_level = self:FindVariable("IsMaxLevel")
	--神器名字
	self.name_image = self:FindVariable("NameImage")
	self.qiLinTips = self:FindVariable("QiLinTips")
	self.qiLinBaoshi = self:FindVariable("QiLinBaoshi")
	self.upgrade_text = self:FindVariable("UpGrade")

	self:Flush()
end

function QilingView:OpenCallBack()
	if ShenqiCtrl.Instance.view.bj_xiangqian_view then
		self:SetSelectIndex(ShenqiCtrl.Instance.view.bj_xiangqian_view.select_index)
	end
	self:SetModel()
end

function QilingView:OnFlush(param_list)
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end

	self:FlushAttrData(self.select_index)

	self:FlushMaterialItem()

	self:FlushNameImage()
	self.qiling_list_view.scroller:ReloadData(0)
end

function QilingView:FlushNameImage()
	local bundle, asset = ResPath.GetShenqiIcon(string.format("shenqi_%s", self.select_index))
	if bundle and asset then
		self.name_image:SetAsset(bundle, asset)
	end
end

function QilingView:FlushUpgradeOptResult(result)
	if 0 == result then 		-- 不再发送升级请求
		self.is_auto = false
	elseif 1 == result then 	-- 继续发送请求
		self:AutoUpgradeOnce()
	end
end

function QilingView:OnClickShow()
	if self.select_index ~= nil then
		ShenqiCtrl.Instance:OpenShenQiTip(SHENQI_TIP_TYPE.BAOJIA, self.select_index)
	end
end

-- 获得cell的数量
function QilingView:GetNumberOfCells()
	return #ShenqiData.Instance:GetBaojiaInlayCfg()
end

-- 刷新cell
function QilingView:RefreshCell(cell, cell_index)
	local cur_cell = self.cell_list[cell]
	local data_list = ShenqiData.Instance:GetBaojiaInlayCfg()
	if cur_cell == nil then
		cur_cell = ShenbingItem.New(cell.gameObject, self, ShenqiView.TabDef.BaoJiaQiLing)
		self.cell_list[cell] = cur_cell
	end
	cell_index = cell_index + 1
	cur_cell:SetIndex(cell_index)
	cur_cell:SetData(data_list[cell_index])
end

function QilingView:SetSelectIndex(index)
	if index then
		self.select_index = index
		self.is_auto = false
	end
end

function QilingView:GetSelectIndex()
	return self.select_index
end

function QilingView:SetModel()
	--设置宝甲模型
	if self.model then
		if self.select_index == self.last_index then return end
		self.last_index = self.select_index

		self.model:SetModelResInfo(GameVoManager.Instance:GetMainRoleVo(), false, true, true, false, true, true, true, false)
		local res_id = ShenqiData.Instance:GetBaojiaResCfgByIamgeID(self.select_index)
		self.model:SetRoleResid(res_id)

		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		--self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.JUN], "120".. main_role_vo.prof .. "001", DISPLAY_PANEL.JUN)
	end
end

function QilingView:OnClickUpgrade()
	if self.is_auto then
		self.is_auto = false		
	else
		self.is_auto = true		
	end	
	self:UpdateOcne()
end


function QilingView:FlushMaterialItem()
	local shenqi_other_cfg = ShenqiData.Instance:GetShenqiOtherCfg()
	local baojia_uplevel_stuff_num = ItemData.Instance:GetItemNumInBagById(shenqi_other_cfg.baojia_uplevel_stuff_id)
	self.item:SetData({item_id = shenqi_other_cfg.baojia_uplevel_stuff_id, num = baojia_uplevel_stuff_num})
end

-- 刷新属性
function QilingView:FlushAttrData(index)
	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	local cur_exp = shenqi_all_info.baojia_list[index].exp
	local cur_level = shenqi_all_info.baojia_list[index].level
	if cur_level~= self.last_level then
		self.is_auto = false
	end
	self.last_level = cur_level
	local baojia_upgrade_cfg = ShenqiData.Instance:GetBaojiaUpgradeCfg()
	-- 当前属性
	local cur_qiling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level,baojia_upgrade_cfg)
	if next(cur_qiling_cfg) then
		self.hp:SetValue(cur_qiling_cfg.maxhp)
		self.gongji:SetValue(cur_qiling_cfg.gongji)
		self.fangyu:SetValue(cur_qiling_cfg.fangyu)
		self.shanbi:SetValue(cur_qiling_cfg.shanbi)
		self.baoji:SetValue(cur_qiling_cfg.jianren)
	else
		self.hp:SetValue(0)
		self.gongji:SetValue(0)
		self.fangyu:SetValue(0)
		self.shanbi:SetValue(0)
		self.baoji:SetValue(0)
	end

	local qiling_active_state = ShenqiData.Instance:GetStuffActiveState(QILING_TAB,self.select_index,baojia_upgrade_cfg)
	self.texiao_active_condition:SetValue(qiling_active_state)

	local next_qiling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level + 1,baojia_upgrade_cfg)
	if nil == next(next_qiling_cfg) then 
		self.exp_progress:SetValue(0)
		self.percent:SetValue("0/0")
		-- 下一级属性
		self.next_hp:SetValue(cur_qiling_cfg.maxhp)
		self.next_gongji:SetValue(cur_qiling_cfg.gongji)
		self.next_fangyu:SetValue(cur_qiling_cfg.fangyu)
		self.next_shanbi:SetValue(cur_qiling_cfg.shanbi)
		self.next_baoji:SetValue(cur_qiling_cfg.jianren)

		self.upgrade_btn.button.interactable = false
		self.is_max_level:SetValue(true)
	else
		self.exp_progress:SetValue(cur_exp/next_qiling_cfg.need_exp)
		self.percent:SetValue(cur_exp .. "/" .. next_qiling_cfg.need_exp)

		-- 下一级属性
		self.next_hp:SetValue(next_qiling_cfg.maxhp)
		self.next_gongji:SetValue(next_qiling_cfg.gongji)
		self.next_fangyu:SetValue(next_qiling_cfg.fangyu)
		self.next_shanbi:SetValue(next_qiling_cfg.shanbi)
		self.next_baoji:SetValue(next_qiling_cfg.jianren)

		self.upgrade_btn.button.interactable = true
		self.is_max_level:SetValue(false)
	end
	self.cur_qiling_level:SetValue(cur_level)
	self.is_active_texiao:SetValue(cur_level < 30)

	local add_per = ShenqiData.Instance:GetJiaChengPer(SHENBING_ADDPER.QILING_TYPE)
	local act_num = (ShenqiData.Instance:GetQiLingLevel() * add_per) / 100
	self.qiLinTips:SetValue(act_num)
	self.qiLinBaoshi:SetValue(Language.ShenQiAddPer[SHENBING_ADDPER.QILING_TYPE])

	if self.is_auto then
		self.upgrade_text:SetValue(Language.Shenqi.StopUp)
	else
		self.upgrade_text:SetValue(Language.Shenqi.ShengJiQiLing)
	end
end

-- 自动升级
function QilingView:AutoUpgradeOnce()
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

function QilingView:UpdateOcne(upgrade_next_time)
	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	local cur_level = shenqi_all_info.baojia_list[self.select_index].level
	local baojia_upgrade_cfg = ShenqiData.Instance:GetBaojiaUpgradeCfg()
	local level_num =  #baojia_upgrade_cfg
	if cur_level == level_num then self.is_auto = false return end

	local next_qiling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level + 1,baojia_upgrade_cfg)
	ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BAOJIA_UPLEVEL,self.select_index,1,next_qiling_cfg.send_pack_num)

	self.upgrade_next_time = Status.NowTime + next_qiling_cfg.next_time
end

function QilingView:ClearData()
	self.is_auto = false
end
