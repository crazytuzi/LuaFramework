ShenqiView = ShenqiView or BaseClass(BaseView)
--神器
--每一阶最大等级
function ShenqiView:__init()
 	self:SetModal(true)
	self:SetBackRenderTexture(true)
 	
 	self.texture_path_list = {
		"res/xui/shenqi.png",
		"res/xui/godfurnace.png",
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"shenqi_ui_cfg", 1, {0}},
        {"common_ui_cfg", 2, {0}, true, 999},
}
end

function ShenqiView:__delete()
end

function ShenqiView:ReleaseCallBack()
	if self.shenqi_list then
        self.shenqi_list:DeleteMe()
        self.shenqi_list = nil
    end

    if self.fight_power_view then
		self.fight_power_view:DeleteMe()
		self.fight_power_view = nil
	end

	if self.reimde_event then
		GlobalEventSystem:UnBind(self.reimde_event)
		self.reimde_event = nil
	end
end

function ShenqiView:OpenCallBack()
end

function ShenqiView:CloseCallBack()
	ShenqiData.Instance:SetCurDisplayFloor(ShenqiData.Instance:GetShenQiJieShu())
end

function ShenqiView:LoadCallBack(index, loaded_times)
	self:CreateListView()
	-- 中间展示动画
	local ph = self.ph_list.ph_shenqi
	self.shenqi_eff = RenderUnit.CreateEffect(391, self.node_t_list.layout_shenqi.node, 10, nil, nil, ph.x, ph.y -50)
	-- self.shenqi_eff:setAnchorPoint(0.5, 0.5)
	CommonAction.ShowJumpAction(self.shenqi_eff, 10)

	self.shenqi_eff.SetAnimateRes = function(node, res_id)
		if nil ~= node.animate_res_id and node.animate_res_id == res_id then
			return
		end

		node.animate_res_id = res_id
		if res_id == 0 then
			node:setStop()
			return
		end

		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(res_id)
		node:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end

	--战斗力
	self.fight_power_view = FightPowerView.New(self.ph_list.ph_fight.x, self.ph_list.ph_fight.y, self.node_t_list.layout_shenqi.node, 99)


	--天赋
    for i = 1,4 do
		local node_t = self.node_t_list["layout_attr" .. i]
		if node_t then
			XUI.AddClickEventListener(node_t.node, BindTool.Bind(self.OnClickAttr, self, i), true)
			XUI.AddRemingTip(self.node_t_list["layout_attr" .. i]["img_icon_" .. i].node, function ()
				return ShenqiData.Instance:GetAttrRemindNum(i) > 0
			end, 4)
		end
	end
	-- 星星
	local ph_stars = self.ph_list.ph_stars
	self.start_part = UiInstanceMgr.Instance:CreateStarsUi({x = ph_stars.x, y = ph_stars.y, star_num = PerFloorLevel,
		interval_x = 5, parent = self.node_t_list.layout_shenqi.node, zorder = 99})

	-- 等级数字
	local ph_level_num = self.ph_list.ph_level_num
	self.num_bar = NumberBar.New()
    self.num_bar:Create(ph_level_num.x, ph_level_num.y, 0, 0, ResPath.GetCommon("num_123_"))
    self.num_bar:SetSpace(-2)
    self.node_t_list.layout_shenqi.node:addChild(self.num_bar:GetView(), 101)

	self.link_stuff = RichTextUtil.CreateLinkText("获取材料", 20, COLOR3B.GREEN)
	self.link_stuff:setPosition(855, 47)
	self.node_t_list.layout_shenqi.node:addChild(self.link_stuff, 99)
	XUI.AddClickEventListener(self.link_stuff, BindTool.Bind(self.OnClickLinkStuff, self), true)
	
	XUI.AddClickEventListener(self.node_t_list.btn_qihun.node, BindTool.Bind(self.OnClickQiHun, self), true)
	XUI.AddRemingTip(self.node_t_list.btn_qihun.node, function ()
		return ShenqiData.Instance:GetQiHunRemindNum() > 0
	end, 23)

	EventProxy.New(ShenqiData.Instance, self):AddEventListener(ShenqiData.SHENQI_ATTR_CHANGE, BindTool.Bind(self.FlushFunction, self))
	EventProxy.New(ShenqiData.Instance, self):AddEventListener(ShenqiData.SHENQI_LEVEL_CHANGE, BindTool.Bind(self.OnFlush, self))
	-- EventProxy.New(ShenqiData.Instance, self):AddEventListener(ShenqiData.MONEY_CHANGE, BindTool.Bind(self.FlushConsume, self))
	self.reimde_event = GlobalEventSystem:Bind(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.RemindGroupChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	--EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.ChangeMoney, self))
end

function ShenqiView:OnBagItemChange()
	self:Flush()
end

function ShenqiView:FlushRemindView()
	self.node_t_list.btn_qihun.node:UpdateReimd()

    for i = 1,4 do
		local node_t = self.node_t_list["layout_attr" .. i]["img_icon_" .. i]
		if node_t then
			node_t.node:UpdateReimd()
			node_t.node:setGrey(ShenqiData.Instance:GetShenqiAttrLevel(i) <= 0)
			-- XUI.MakeGrey(self.node_t_list["layout_attr" .. i].node, ShenqiData.Instance:GetShenqiAttrLevel(i) <= 0)
		end
	end
end

function ShenqiView:RemindGroupChange(group_name, num)
	if group_name ~= RemindGroupName.ShenQiView then return end
	self:FlushRemindView()
end

function ShenqiView:OnClickLinkStuff()
	local level = ShenqiData.Instance:GetShenQiLevel()
	local cfg = ShenqiData.GetShenqiConsume(level+1)
	local item_id = ItemData.GetVirtualItemId(cfg.type)
	if nil == item_id then
		item_id = cfg.id
	end

	TipCtrl.Instance:OpenGetStuffTip(item_id)
end


function ShenqiView:OnClickQiHun()
	ShenqiCtrl.Instance.SendShenQiUpgrade()
end

function ShenqiView:CreateListView()
    if nil == self.shenqi_list then
        local ph = self.ph_list.ph_shenqi_list
        self.shenqi_list = ListView.New()
        self.shenqi_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ShenqiItemRender, nil, nil, self.ph_list.ph_cell_view)
        self.node_t_list.layout_shenqi.node:addChild(self.shenqi_list:GetView(), 100)
        self.shenqi_list:SetMargin(2) --首尾留空
    end
end

function ShenqiView:OnClickAttr(index)
	ShenqiCtrl.Instance:OpenEquipView(index)
end

function ShenqiView:ShowIndexCallBack(index)
	self:Flush()
	self.shenqi_list:SetSelectItemToTop(#ShenqiData.Instance:GetFloorInfo())
end


function ShenqiView:OnFlush()
	local data = ShenqiData.Instance:GetFloorInfo()
	self.shenqi_list:SetDataList(data)
	-- self.shenqi_list:SetSelectItemToTop(#data)
	--属性加成
	self:FlushAttrView()
	self:ChangeDisplay()
	self:FlushFunction()
	self:FlushConsume()
end

-- function ShenqiView:ChangeMoney()
-- 	local old_money =  self.money
-- 	local new_money =  RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN)
-- 	if old_money ~= new_money then
-- 		self.money = new_money
-- 		self:FlushConsume()
-- 	end
-- end

function ShenqiView:FlushConsume()
	local level = ShenqiData.Instance:GetShenQiLevel() 
	local cfg = ShenqiData.GetShenqiConsume(level+1)

	if nil == cfg then cfg = ShenqiData.GetShenqiConsume(level) end

	local item_id = ItemData.GetVirtualItemId(cfg.type)
	if nil == item_id then
		item_id = cfg.id
	end

	local consume_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_id > 0 then
		self.node_t_list.img_consume.node:loadTexture(ResPath.GetItem(consume_cfg.icon))
		self.node_t_list.img_consume.node:setScale(0.5)
	end

	local have_num = ShenqiData.Instance:GetHaveNumByCfg(cfg)
	local color = have_num > cfg.count and "00ff00" or "ff0000"
	local content = string.format("{wordcolor;%s;%d / %d}",color, have_num, cfg.count)
	RichTextUtil.ParseRichText(self.node_t_list.rich_consume.node, content, 20)


	self:FlushRemindView()
end

-- 刷新属性
function ShenqiView:FlushAttrView()
	local attr1 = ShenqiData.GetShenqiAttr(ShenqiData.Instance:GetShenQiLevel())
	local attr2 = ShenqiData.GetShenqiAttr(ShenqiData.Instance:GetShenQiLevel()+1)
	UiInstanceMgr.FlushAttr(self.node_t_list.rich_bonus.node, attr1)
	UiInstanceMgr.FlushAttr(self.node_t_list.rich_next_bonus.node, attr2)

	--self.node_t_list.rich_bonus.node:setVerticalSpace(-3) --设置垂直间隔
	--self.node_t_list.rich_next_bonus.node:setVerticalSpace(-3)

end

--刷新四个功能等级
function ShenqiView:FlushFunction()
	for i=1 ,4 do
		local node_t = self.node_t_list["lbl_attr_level" .. i]
		local level = ShenqiData.Instance:GetShenqiAttrLevel(i)
		node_t.node:setString("Lv."..level)
	end
	self.fight_power_view:SetNumber(ShenqiData.Instance:GetMyShenqiFigth())
end

function ShenqiView:ChangeDisplay()
	local show_jieshu = ShenqiData.Instance:GetCurDisplayFloor() or 1
	local show_level = (show_jieshu - 1) * 11 + 1

	local my_level = ShenqiData.Instance:GetShenQiLevel()
	local jie_shu = ShenqiData.Instance:GetShenQiJieShu()

	--神器特效
	local cfg = ShenqiData.GetShenQiCfgByLevel(show_level)
	self.shenqi_eff:SetAnimateRes(cfg.eff_id)
	local is_act = show_jieshu <= jie_shu and true or false
	self.shenqi_eff:setScale(cfg.scale)
	
	XUI.MakeGrey(self.shenqi_eff, not is_act)

	--神器名字
	self.node_t_list.img_name.node:loadTexture(ResPath.GetShenQiResPath("name"..show_jieshu))
	
	--星星数量
	local star_num = 0
	if show_jieshu < jie_shu or (my_level > 0 and my_level % PerFloorLevel == 0) then
		star_num = PerFloorLevel
	else
		star_num = my_level % PerFloorLevel
	end

	self.start_part:SetStarActNum(star_num)

	--显示等级 即当前星数
	self.num_bar:SetNumber(star_num)
end
-----------------------------------------------------------------
-----------------------------------------------------------------
ShenqiItemRender = ShenqiItemRender or BaseClass(BaseRender)
function ShenqiItemRender:__init()
end

function ShenqiItemRender:__delete()
   
end

function ShenqiItemRender:CreateChild()
    BaseRender.CreateChild(self)
    -- 特效
    local size = self.node_tree.img_bg.node:getContentSize()
	self.eff = RenderUnit.CreateEffect(391, self.node_tree.img_bg.node, 10, nil, nil, size.width/2, size.height/2 )
	self.eff:setScale(0.3)
	XUI.AddClickEventListener(self.node_tree.img_bg.node, BindTool.Bind(self.OnClick, self), true)
end

function ShenqiItemRender:OnFlush()
    if nil == self.data then
        return
    end
    self.node_tree.lbl_name.node:setString(self.data.name)
    local anim_path, anim_name = ResPath.GetEffectUiAnimPath(self.data.eff_id)
	self.eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	XUI.MakeGrey(self.eff, not self.data.is_active)
end

function ShenqiItemRender:CreateSelectEffect()
	return
end

function ShenqiItemRender:OnClick()
	ShenqiCtrl.Instance:ChangeDisplay(self.index)
end
