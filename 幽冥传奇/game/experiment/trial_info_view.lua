--------------------------------------------------------
-- 试炼信息  配置 
--------------------------------------------------------

TrialInfoView = TrialInfoView or BaseClass(BaseView)

function TrialInfoView:__init()
	self.is_any_click_close = true
	self:SetModal(true)
	self.config_tab = {
		{"trial_ui_cfg", 2, {0}},
	}
end

function TrialInfoView:__delete()

end

--释放回调
function TrialInfoView:ReleaseCallBack()
	-- if nil ~= self.tabbar then
	-- 	self.tabbar:DeleteMe()
	-- 	self.tabbar = nil
	-- end

	self.data = nil
end

--加载回调
function TrialInfoView:LoadCallBack(index, loaded_times)
	self:CreateCellList()

	-- 按钮监听
	-- XUI.AddClickEventListener(self.node_t_list.layout_xunbao_10.node, BindTool.Bind(self.OnClickXunBaoHandler, self, 2), true)


	-- 数据监听
	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))
end

function TrialInfoView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TrialInfoView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TrialInfoView:SetData(data)
	self.data = data
end

--显示指数回调
function TrialInfoView:ShowIndexCallBack(index)
	self:Flush()
end

----------视图函数----------

function TrialInfoView:OnFlush(param_list, index)
	local section_count, floor = ExperimentData.GetSectionAndFloor(self.data.guan_index)
	self.node_t_list["lbl_guan_name"].node:setString(string.format(Language.Trial.SectionTitle, section_count, floor))

	local cfg = self.data.cfg or {}
	local gjawards = cfg.gjawards or {}
	local moneys = cfg.moneys or {}

	for i = 1, 4 do
		local award, count
		if i == 1 then
			award = moneys[i] or {id = 0, type = 0, count = 0}
			count = award.count or 0
			count = count * 60 * 60
		else
			award = gjawards[i - 1] or {id = 0, type = 0, count = 0}
			count = award.count or 0
		end
		count = CommonDataManager.ConverMoney(count)

		-- 图标
		local item = ItemData.InitItemDataByCfg(award)
		local item_cfg = ItemData.Instance:GetItemConfig(item.item_id)
		self.node_t_list["img_award_" .. i].node:loadTexture(ResPath.GetItem(tonumber(item_cfg.icon)))
		self.node_t_list["img_award_" .. i].node:setScale(0.35)
		
		-- 每小时效率
		local text = count .. "/小时"
		self.node_t_list["lbl_award_" .. i].node:setString(text)
		self.node_t_list["lbl_award_" .. i].node:setVisible(true)
	end

	self:FlushCellList()
	self:FlushConditions()
end

function TrialInfoView:CreateCellList()
	local ph = self.ph_list["ph_award_list"]
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.node_t_list["layout_trial_info"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, ActBaseCell, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.cell_list = grid_scroll
	self:AddObj("cell_list")
end

function TrialInfoView:FlushCellList()
	local cfg = self.data.cfg or {}
	local awards = cfg.awards or {}
	local show_list = {}
	for i,v in ipairs(awards) do
		show_list[#show_list + 1] = ItemData.InitItemDataByCfg(v)
	end
	self.cell_list:SetDataList(show_list)

	-- 居中处理
	self.cell_list:SetCenter()
end

function TrialInfoView:FlushConditions()
	local cfg = self.data.cfg or {}
	local conditions = cfg.conditions or {}
	local text = ""
	if self.data.guan_index > 1 then
		text = text .. "通关上一关\n"
	end

	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	-- local wing_jie = WingData.Instance:GetWingJie()
	local wing_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL)
	local wing_jie, _ = WingData.GetWingLevelAndGrade(wing_lv)
	local role_data = {["level"] = role_lv, ["circle"] = circle;["swinglv"] = wing_jie}
	local conditions_key = {{"level", "{color;%s;等级达到%d级\n}"}, {"circle","{color;%s;转生达到%d转\n}"},{"swinglv", "{color;%s;翅膀达到%d阶\n}"}}
	for i,v in ipairs(conditions_key) do
		local key = v[1]
		local conditions_lv = conditions[key] or 0
		if conditions_lv > 0 then
			local color = role_data[key] >= conditions_lv and COLORSTR.GREEN or COLORSTR.RED
			text = text .. string.format(v[2], color, conditions_lv)
		end
	end

	RichTextUtil.ParseRichText(self.node_t_list["rich_conditions"].node, text, 20, COLOR3B.GREEN)
	self.node_t_list["rich_conditions"].node:refreshView()

	local x, y = self.node_t_list["rich_conditions"].node:getPosition()
	local size = self.node_t_list["rich_conditions"].node:getInnerContainerSize()
	local title_y = y - size.height / 2
	self.node_t_list["lbl_conditions_title"].node:setPositionY(title_y)
	self.node_t_list["lbl_conditions_title"].node:setAnchorPoint(0, 0.5)
end

----------end----------

--------------------
