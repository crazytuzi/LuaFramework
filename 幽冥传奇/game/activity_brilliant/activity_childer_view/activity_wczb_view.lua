--------------------------------------------------------
-- 运营活动-王城争霸 7
--------------------------------------------------------

WCZBView = WCZBView or BaseClass(ActBaseView)

local AwardCellRender = BaseClass(BaseRender)

function WCZBView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function WCZBView:__delete()
	if type(self.award_list) == "table" then
		for i,v in ipairs(self.award_list) do
			v:DeleteMe()
		end
		self.award_list = nil
	end

	if self.role_display then
		self.role_display:DeleteMe()
		self.role_display = nil
	end
end

-- 初始化视图
function WCZBView:InitView()
	if nil == self.tree.node then return end

	self:CreateAwardList()
	self:CreateRoleDisplay()
end

-- 注册通用点击事件
function WCZBView:AddActCommonClickEventListener()

end

-- 视图关闭回调
function WCZBView:CloseCallback() 
end

-- 选中当前视图回调
function WCZBView:ShowIndexView()
end

-- 切换当前视图回调
function WCZBView:SwitchIndexView()
end

-- 刷新当前视图
function WCZBView:RefreshView(param_list)
	if nil == self.tree.node then return end

	for k,v in pairs(param_list) do
		if k == "flush_view" then
			self:FlushView()
		end
	end
end

----------------------------------------
-- 视图函数
----------------------------------------

function WCZBView:FlushView()
	
end


function WCZBView:CreateAwardList()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(self.act_id)
	local cfg = act_cfg.config or {}
	local awards = cfg.awards or {}

	self.award_list = {}
	for i = 1, 2 do -- 显示前三档
		local ph = self.ph_list["ph_award_list_" .. i] or {x = 0, y = 0, w = 1, h = 1,}
		local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE,}
		local parent = self.tree.node
		local item_render = ActBaseCell
		local line_dis = ph_item.w
		local direction = ScrollDir.Horizontal -- 滑动方向-横向
		local grid_scroll = GridScroll.New()
		grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, line_dis, item_render, direction, false, ph_item)
		parent:addChild(grid_scroll:GetView(), 99)
		self.award_list[i] = grid_scroll

		local list = {}
		for i,v in ipairs(awards[i] or {}) do
			list[#list + 1] = ItemData.InitItemDataByCfg(v)
		end
		grid_scroll:SetDataList(list)
		grid_scroll:SetCenter()
	end
end

function WCZBView:CreateRoleDisplay()
	local ph = self.ph_list["ph_role_eff"]
	self.role_display = RoleDisplay.New(self.tree.node, 999, false, false, true)
	self.role_display:SetPosition(ph.x, ph.y)
	self.role_display:SetScale(0.5)

	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(self.act_id) or {}
	local cfg = act_cfg.config or {}
	local role_sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) or 0
	local role_show = cfg.role_show and cfg.role_show[role_sex + 1] or {}
	local role_vo = {}
	role_vo[OBJ_ATTR.ENTITY_MODEL_ID] = role_show.role_res_id or 1
	role_vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = role_show.wuqi_res_id or 1
	role_vo[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = 0
	self.role_display:SetRoleVo(role_vo)

	local effect_id = role_show.title_eff_id or 1
	local path, name = ResPath.GetEffectUiAnimPath(effect_id)
	if nil == self.title_eff then
		self.title_eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.title_eff:setPosition(ph.x, ph.y + 150)
		self.tree.node:addChild(self.title_eff, 50)
	else
		self.title_eff:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end
end