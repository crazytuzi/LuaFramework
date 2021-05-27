--------------------------------------------------------
-- 经脉视图  配置 MeridiansCfg
--------------------------------------------------------
MeridiansView = MeridiansView or BaseClass(BaseView)

function MeridiansView:__init()
	self.texture_path_list[1] = 'res/xui/meridians.png'
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"meridians_ui_cfg", 1, {0}}, --背景
		{"meridians_ui_cfg", 2, {0}, false}, --默认隐藏layout_jm_1 初始化后才显示
		{"common_ui_cfg", 2, {0}},
	}
	self.get_dan_window = nil -- 经脉丹窗口
	self.power_view = nil --战力视图
	self.eff_list = {} -- 子等级图标特效列表
	self.is_bullet_window = false -- 是否弹出获取途径
end

function MeridiansView:__delete()

end

--释放回调
function MeridiansView:ReleaseCallBack()
	
	if self.power_view then
		self.power_view:DeleteMe()
		self.power_view = nil
	end

	self.text = nil
	self.next_eff = nil
	self.eff_list = {}
	self.is_bullet_window = nil
end

--加载回调
function MeridiansView:LoadCallBack(index, loaded_times)

	--按钮特效
	self.node_t_list.layout_up.remind_eff = RenderUnit.CreateEffect(23, self.node_t_list.layout_up.node, 1)

	self:InitPhaseView()  --初始化阶位视图
	self:CreateGetDanBtn() -- 创建获取经脉丹按钮
	self:CreateLevelEffectView() -- 创建子等级特效视图
	self:FlushDanView()	  -- 刷新消耗经脉丹视图
	self:FlushBtnUpView() -- 刷新升级按钮视图
	self:FlushBonusView() -- 刷新加成属性视图
	-- 生成战力视图
	local ph = self.ph_list.ph_power_value
	self.power_view = FightPowerView.New(ph.x, ph.y,self.node_t_list.layout_jm_1.node, 20)
	self.power_view:SetScale(1)
	self:FlushPowerValueView() -- 刷新战力值视图

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list.layout_up.node, BindTool.Bind(self.OnClickUPHandler, self), true)

	-- 数据监听
	EventProxy.New(MeridiansData.Instance, self):AddEventListener(MeridiansData.MERIDIANS_LEVEL_CHANGE, BindTool.Bind(self.LevelChangeHandler, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))

end

function MeridiansView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MeridiansView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function MeridiansView:ShowIndexCallBack(index)
	self.node_t_list.layout_jm_1.node:setVisible(true)
end

function MeridiansView:OnFlush(param_list)
	if param_list.bag_data_change then
		self:FlushDanView()
	end
end

function MeridiansView:OnBagItemChange()
	self:Flush(0, "bag_data_change")
end

----------视图函数----------

-- 刷新战力值视图
function MeridiansView:FlushPowerValueView()
	local level = MeridiansData.Instance:GetLevel() -- 获取经脉等级
	if nil == MeridiansCfg.attrs[level] then 
		self.power_view:SetNumber(0)
		return
	end

	local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1) --获取角色基础职业,默认是战士
	local attr = {}
	for k, v in ipairs(MeridiansCfg.attrs[level]) do
		if v.job == prof or v.job == 0 then
			attr[#attr + 1] = v
		end
	end
	local power_value = CommonDataManager.GetAttrSetScore(attr)
	self.power_view:SetNumber(power_value)
end

-- 创建获取经脉丹按钮
function MeridiansView:CreateGetDanBtn()
	if self.text == nil then
		self.text = RichTextUtil.CreateLinkText(Language.Meridians.GetDan, 19, COLOR3B.GREEN)
		self.text:setPosition(900, 27)
		self.node_t_list.layout_jm_1.node:addChild(self.text, 9)
		XUI.AddClickEventListener(self.text, BindTool.Bind(self.OpenGetDanWindow, self), true)
	end
end

-- 刷新升级按钮视图
function MeridiansView:FlushBtnUpView()
	local level = MeridiansData.Instance:GetLevel()
	local child_level = level % 11 -- 经脉每阶的等级(每阶11级)

	if level == 0 then 
		self.node_t_list.lbl_up.node:setString(Language.Common.Activate)	
	elseif child_level == 10 then
		if level == #MeridiansCfg.upgrade then
			self.node_t_list.layout_up.node:setVisible(false)
		else
			self.node_t_list.lbl_up.node:setString(Language.Common.FreeAdvanced)
			self.node_t_list.lbl_up.node:setColor(COLOR3B.ORANGE)
		end
	else
		self.node_t_list.lbl_up.node:setString(Language.Meridians.Blunt)
		self.node_t_list.lbl_up.node:setColor(cc.c3b(0xED, 0xE6, 0xC1))
	end
end

-- 刷新消耗经脉丹视图
function MeridiansView:FlushDanView()
	local data = MeridiansData.Instance:GetData()
	local level = data.level
	local child_level = data.child_level

	if child_level == 10 or nil == MeridiansCfg.upgrade[level + 1] or level == 0 then
		self.node_t_list.rich_dan.node:setVisible(false)
		return
	end
	self.node_t_list.rich_dan.node:setVisible(true)

	local item = MeridiansCfg.upgrade[level + 1].consumes[1] -- 获取经脉丹配置
	local item_num = BagData.Instance:GetItemNumInBagById(item.id, nil)	--获取背包的经脉丹数量
	-- 背包的经脉丹数量足够冲脉时,显示绿色,否则显示红色
	local bool = item_num >= item.count
	item_num = bool and "{color;1eff00;" .. item_num .. "}" or "{color;ff2828;" .. item_num .. "}"

	local text = string.format(Language.Meridians.Need, item_num, item.count)
	RichTextUtil.ParseRichText(self.node_t_list.rich_dan.node, text, 18, COLOR3B.DULL_GOLD)
	XUI.RichTextSetCenter(self.node_t_list.rich_dan.node)

	self.node_t_list.layout_up.remind_eff:setVisible(bool)

	self.is_bullet_window = not bool
end

-- 刷新加成属性视图
function MeridiansView:FlushBonusView()
	local level = MeridiansData.Instance:GetLevel()
	local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1) --获取角色基础职业,默认是战士
	
	if nil == MeridiansCfg.attrs then return end -- 如果配置为空,则跳出

	local text1 = ""
	if level ~= 0 then
		local attr1 = {}
		for k, v in ipairs(MeridiansCfg.attrs[level]) do
			if v.job == prof or v.job == 0 then
				attr1[#attr1 + 1] = v
			end
		end
		text1 = RoleData.Instance.FormatAttrContent(attr1)
	else
		-- 未激活时,获取第一份属性配置并将属性(value)改为0
		local attr1 = {}
		for k, v in ipairs(MeridiansCfg.attrs[1]) do
			if v.job == prof or v.job == 0 then
				attr1[#attr1 + 1] = {type = v.type, job = v.job, value = 0}
			end
		end
		text1 = RoleData.Instance.FormatAttrContent(attr1)
	end

	local text2 = ""
	if (level + 1) <= #MeridiansCfg.attrs then
		local attr2 = {}
		for k, v in ipairs(MeridiansCfg.attrs[level + 1]) do
			if v.job == prof or v.job == 0 then
				attr2[#attr2 + 1] = v
			end
		end
		text2 = RoleData.Instance.FormatAttrContent(attr2)
	else
		text2 = Language.Common.AlreadyTopLv	--满级时,显示已是最高级了
	end

	RichTextUtil.ParseRichText(self.node_t_list.rich_bonus.node, text1, 18, COLOR3B.OLIVE)
	RichTextUtil.ParseRichText(self.node_t_list.rich_next_bonus.node, text2, 18, COLOR3B.OLIVE)
	self.node_t_list.rich_bonus.node:setVerticalSpace(5) --设置垂直间隔
	self.node_t_list.rich_next_bonus.node:setVerticalSpace(5)
end

-- 创建等级特效视图
function MeridiansView:CreateLevelEffectView()
	local data = MeridiansData.Instance:GetData()
	local level = data.level
	local child_level = data.child_level

	-- 当前等级的图标特效 创建时默认隐藏
	local path, name = ResPath.GetEffectUiAnimPath(253)
	for i = 1, 10 do
		self.eff_list[i] = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.eff_list[i]:setPosition(self.ph_list["ph_cell_" .. i].x, self.ph_list["ph_cell_" .. i].y)
		self.eff_list[i]:setVisible(false)
		self.node_t_list.layout_jm_1_1.node:addChild(self.eff_list[i], 50)
	end

	-- 下一级的图标特效
	path, name = ResPath.GetEffectUiAnimPath(254)
	self.next_eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	self.next_eff:setPosition(self.ph_list["ph_cell_1"].x, self.ph_list["ph_cell_1"].y)
	self.node_t_list.layout_jm_1_1.node:addChild(self.next_eff, 50)

	-- 子等级不等于10级和未满级才显示下一级的图标特效
	local bool = child_level ~= 10 and (not (level == #MeridiansCfg.upgrade))
	self.next_eff:setVisible(bool)
	if bool then
		local ph = self.ph_list["ph_cell_" .. (child_level + 1)]
		self.next_eff:setPosition(ph.x, ph.y)
	end
	
	-- 初始化图标特效显示
	for i = 1, child_level do
		self.eff_list[i]:setVisible(true)
	end
end

-- 播放升级特效
function MeridiansView:PlayUpLevelEffectView(child_level)
	if child_level == 0 then return end

	local path, name = ResPath.GetEffectUiAnimPath(252)
	local up_eff = AnimateSprite:create(path, name, 1, FrameTime.Effect, false)
	local ph = self.ph_list["ph_cell_" .. child_level]

	up_eff:setPosition(ph.x, ph.y)
	self.node_t_list.layout_jm_1_1.node:addChild(up_eff, 99)
	up_eff:setVisible(true)
end

-- 播放进阶特效
function MeridiansView:PlayUpPhaseEffectView(child_level)
	if child_level ~= 0 then return end

	local path, name = ResPath.GetEffectUiAnimPath(15)
	local up_phase_eff = AnimateSprite:create(path, name, 1, FrameTime.Effect, false)

	up_phase_eff:setPosition(200, 150)
	self.node_t_list.layout_jm_1_1.node:addChild(up_phase_eff, 99)
	up_phase_eff:setVisible(true)
end

-- 初始化段位视图
function MeridiansView:InitPhaseView()
	local data = MeridiansData.Instance:GetData()
	local level = data.level
	local phase = data.phase -- 经脉阶位
	local child_level = data.child_level

	for i = 2, 10 do
		self.node_t_list["img_jm_xt_" .. i].node:setVisible(child_level >= i)
	end

	if level == 0 then
		self.node_t_list.layout_phase.node:setVisible(false)
	else 
		self.node_t_list.img_jm_m.node:loadTexture(ResPath.GetMeridians("img_jm_m_" .. phase)) --刷新阶位名字图片
		self.node_t_list.img_jm_j.node:loadTexture(ResPath.GetMeridians("img_jm_j_" .. phase)) --刷新阶位图片
	end

end

-- 刷新阶位视图
function MeridiansView:FlushPhaseView()
	local data = MeridiansData.Instance:GetData()
	local level = data.level
	local phase = data.phase
	local child_level = data.child_level

	if level == 0 then
		self.node_t_list.layout_phase.node:setVisible(false)
	else 
		self.node_t_list.img_jm_m.node:loadTexture(ResPath.GetMeridians("img_jm_m_" .. phase))
		self.node_t_list.img_jm_j.node:loadTexture(ResPath.GetMeridians("img_jm_j_" .. phase))
		self.node_t_list.layout_phase.node:setVisible(true)
	end

	-- 根据每阶的等级,显示对应数量的图标和线条
	self.eff_list[1]:setVisible(child_level >= 1) -- 1级只需显示图标
	local bool = nil
	for i = 2, 10 do
		bool = child_level >= i
		self.eff_list[i]:setVisible(bool)
		self.node_t_list["img_jm_xt_" .. i].node:setVisible(bool)
	end

	-- 下一级的图标特效显示规则
	local bool = child_level ~= 10 and (not (level == #MeridiansCfg.upgrade))
	self.next_eff:setVisible(bool)
	if bool then
		local ph = self.ph_list["ph_cell_" .. (child_level + 1)]
		self.next_eff:setPosition(ph.x, ph.y)
	end

	-- 播放升级和进阶特效
	self:PlayUpLevelEffectView(child_level)
	self:PlayUpPhaseEffectView(child_level)
end

----------end----------

-- 打开获取经脉单窗口
function MeridiansView:OpenGetDanWindow()
	local item = MeridiansCfg.upgrade[1].consumes[1] -- 获取经脉丹配置

	local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item.id]
	local data = string.format("{reward;0;%d;1}", item.id) .. (ways and ways or "")
	TipCtrl.Instance:OpenBuyTip(data)
end

function MeridiansView:OnClickUPHandler()
	if self.is_bullet_window then
		self:OpenGetDanWindow()
	else
		MeridiansCtrl.Instance:SendMeridiansReq(2)
	end
end

function MeridiansView:LevelChangeHandler()
	if nil ~= self.node_t_list.layout_jm_1 then
		self:FlushPhaseView()
		self:FlushBtnUpView()
		self:FlushBonusView()
		self:FlushPowerValueView()
		self:OnBagItemChange()
	end
end