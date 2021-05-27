----------------------------------------------------
-- 英雄信息展示带装备，带展示。如人物面板上的
----------------------------------------------------
HeroInfoView = HeroInfoView or BaseClass()
function HeroInfoView:__init()
	self.is_main_role = true
	self.view = nil
	self.ph_list = {}
	self.node_tree = {}
	self.node_t_list = {}
	self.show_shengqi = false
	self.vo = nil
	self.show_wuqi = 1
	self.show_cloth = 1
	self.change_sq_time = 0
	self.change_sj_time = 0
	self.all_text = {}
end

function HeroInfoView:__delete()
	if nil ~= self.shenzhu_event_handle then
		GlobalEventSystem:UnBind(self.shenzhu_event_handle)
		self.shenzhu_event_handle = nil
	end

	if nil ~= self.strengthen_event_handle then
		GlobalEventSystem:UnBind(self.strengthen_event_handle)
		self.strengthen_event_handle = nil
	end

	if nil ~= self.appearance_event_handle then
		GlobalEventSystem:UnBind(self.appearance_event_handle)
		self.appearance_event_handle = nil
	end

	if nil ~= self.event_handle then
		GlobalEventSystem:UnBind(self.event_handle)
		self.event_handle = nil
	end

	if nil ~= self.equip_grid then
		self.equip_grid:DeleteMe()
		self.equip_grid = nil
	end

	if self.hero_display then
		self.hero_display:DeleteMe()
		self.hero_display = nil
	end

	if self.hero_attr_change_evt then
		GlobalEventSystem:UnBind(self.hero_attr_change_evt)
		self.hero_attr_change_evt = nil
	end

	if self.equip_data_change_evt then
		GlobalEventSystem:UnBind(self.equip_data_change_evt)
		self.equip_data_change_evt = nil
	end

	-- if self.lbl_zhandoiuli then
	-- 	self.lbl_zhandoiuli:DeleteMe()
	-- 	self.lbl_zhandoiuli = nil
	-- end

	if RoleData.Instance and self.role_attr_change_fun then
		RoleData.Instance:UnNotifyAttrChange(self.role_attr_change_fun)
	end

	if ItemData.Instance and self.item_change_fun then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_fun)
	end
	if self.time_event then
		GlobalEventSystem:UnBind(self.time_event)
		self.time_event = nil
	end
	self.show_shengqi = false
	self.vo = nil
	self.change_sq_time = 0
	self.change_sj_time = 0
end


function HeroInfoView:GetView()
	return self.view
end

function HeroInfoView:CreateViewByUIConfig(t, grid_name)
	if t == nil then
		return
	end

	local config_t = TableCopy(t, 4)
	config_t.t = "layout"

	self.layout_t = XUI.CreateControl(config_t)
	if self.layout_t == nil then
		return
	end
	self.view = self.layout_t

	if config_t then
		XUI.Parse(config_t, self.layout_t,  self.node_t_list, self.node_tree, self.ph_list)
	end
	self.time_event = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.FlushBoolShowCell, self))
	self.equip_layout = self.node_t_list.layout_equip.node
	-- self.equip_layout2 = self.node_t_list.layout_equip2.node
	-- self.equip_layout2:setOpacity(0)
	-- GlobalTimerQuest:AddDelayTimer(function ()
	-- 	self.equip_layout2:setVisible(false)
	-- 	self.equip_layout2:setOpacity(255)
	-- end, 0.05)
	XUI.AddClickEventListener(self.node_t_list.lay_gold_dun.node,BindTool.Bind(self.OnGoTab1,self),true)
	XUI.AddClickEventListener(self.node_t_list.lay_gold_bing.node,BindTool.Bind(self.OnGoTab2,self),true)
	self.hero_display = HeroDisplay.New(self.view, -1)
	self.hero_display:SetPosition(274, 326)
	local hero_vo = ZhanjiangData.Instance:GetHeroVoData()
	--self.hero_display:SetScale(1.2)
	if hero_vo then
		self.hero_display:SetHeroVo(hero_vo)
		local name_txt = DelNumByString(hero_vo.name)
		self.node_t_list.label_role_name.node:setString(name_txt)
	end
	
	--装备网格
	local pos_t = {}
	for i = 0, COMMON_CONSTS.MAX_NORMAL_EQUIP_PART  do

		local ph_cell= self.ph_list["ph_equip_cell_" .. i]
		if ph_cell ~= nil then
			pos_t[i] = {ph_cell.x, ph_cell.y}	-- 获取占位符的位置
			if i <= COMMON_CONSTS.MAX_NORMAL_EQUIP_PART then
				local txt = XUI.CreateText(ph_cell.x + 40, ph_cell.y +35, 80, 24, cc.TEXT_ALIGNMENT_CENTER, Language.Role.CanEquip, nil, nil, COLOR3B.YELLOW, v_alignment)
				XUI.EnableShadow(txt)
				XUI.EnableOutline(txt)
				self.equip_layout:addChild(txt, 444)
				self.all_text[i] = txt
			end
		end
	end

	for k,v in pairs(self.all_text) do
		v:setVisible(false)
	end

	self.equip_grid = BaseGrid.New()
	self.equip_grid:SetGridName(grid_name)
	local size = self.equip_layout:getContentSize()
	local grid_node = self.equip_grid:CreateCellsByPos({w = size.width + 20, h = size.height + 20}, pos_t)
	self.equip_layout:addChild(grid_node, 0)
	self.equip_grid:SetSelectCallBack(BindTool.Bind(self.SelectCellCallBack, self, EquipData.EquipIndex.HeroWeapon))
	self.equip_grid:SetIsShowTips(false)
	self:SetGridStyle()

	-- self:CreateEquipGrid2(grid_name)

	self:ApperanceChange()
	-- if not RoleData.Instance:RoleInfoIsOk() then
	-- 	self.event_handle = GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
	-- elseif self.is_main_role then
	-- end
	self.equip_data_change_evt = GlobalEventSystem:Bind(HeroDataEvent.HERO_EQUIP_CHANGE,BindTool.Bind1(self.OnEquipDataChange, self))
	self.hero_attr_change_evt = GlobalEventSystem:Bind(HeroDataEvent.HERO_ATTR_CHANGE, BindTool.Bind(self.FlushAttrValue, self))
	self.item_change_fun = BindTool.Bind1(self.OnBagItemChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_fun)
	self.node_t_list.btn_suit_tip.node:setVisible(false)
	self.node_t_list.jobText.node:setString(Language.Common.ProfName[ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF) or 0])
	self.node_t_list.levelText.node:setString(ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) .. Language.Common.Zhuan .. ZhanjiangData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) .. Language.Common.Ji)
end

function HeroInfoView:FlushBoolShowCell()
	-- local state = EquipData.Instance:GetBoolShowEquipCell()
	-- for i = 10, 13 do
	-- 	local item = self.equip_grid:GetCell(i)
	-- 	if item ~= nil then
	-- 		item:GetView():setVisible(state)
	-- 	end
	-- end
	-- if self.is_main_role then
		self:OnEquipTips()
	-- end
end

function HeroInfoView:OnGoTab1()
	GlobalEventSystem:Fire(HeroDataEvent.HERO_UP_DUMP,2)
end

function HeroInfoView:OnGoTab2()
	GlobalEventSystem:Fire(HeroDataEvent.HERO_UP_DUMP,1)
end

function HeroInfoView:OnChangeShowEquip()
	-- self.equip_layout:setVisible(not self.btn_switch:isTogglePressed())
	-- self.equip_layout2:setVisible(self.btn_switch:isTogglePressed())
	-- if self.is_main_role then
	-- 	if ViewManager.Instance:IsOpen(ViewName.Role) then
	-- 		RoleCtrl.Instance:FlushRoleView(TabIndex.role_intro, "change_btn",{bool = self.btn_switch:isTogglePressed()})
	-- 	end
	-- end
end

function HeroInfoView:CreateEquipGrid2(grid_name)
	--装备网格
	local pos_t = {}
	for i = 0, COMMON_CONSTS.MAX_NORMAL_EQUIP_PART - 1 do
		local ph_cell= self.ph_list["ph_equip_cell2_" .. i]
		if ph_cell ~= nil then
			pos_t[i] = {ph_cell.x, ph_cell.y}	-- 获取占位符的位置
		end
	end

	self.equip_grid2 = BaseGrid.New()
	self.equip_grid2:SetGridName(grid_name)
	local size = self.equip_layout2:getContentSize()
	local grid_node = self.equip_grid2:CreateCellsByPos({w = size.width + 20, h = size.height + 20}, pos_t)
	self.equip_layout2:addChild(grid_node, 0)
	--self.equip_grid2:SetSelectCallBack(BindTool.Bind(self.SelectCellCallBack, self, COMMON_CONSTS.MAX_NORMAL_EQUIP_PART))
	self.equip_grid2:SetIsShowTips(false)
	self:SetGridStyle2()
end

function HeroInfoView:OnRecvMainRoleInfo()
	if self.is_main_role then
		self:ApperanceChange()
		GlobalEventSystem:UnBind(self.event_handle)
		self.event_handle = nil
	end
end

--设置人物数据
function HeroInfoView:SetRoleData(t)
	if t == nil then return end
	local data_list = ZhanjiangData.Instance:GetShowGrid()
	self.equip_grid:SetDataList(data_list)
	self:OnEquipTips()
	self:FlushBoolShowCell()
	self.vo = t
end



function HeroInfoView:SetEquip2Data(data, sex)
	local fashion_data = RoleData.Instance:GetHadUseFashion(data, sex)
	local cur_data = {}
	local index = 0
	for k,v in pairs(fashion_data) do
		local data = {}
		data.icon = v.icon
		cur_data[index] = data
		index = index + 1
	end
	self.equip_grid2:SetDataList(cur_data)
end

function HeroInfoView:FlushOtherRole()
	-- if nil == self.vo then return end
	-- self.hero_display:SetRoleVo(self.vo)
	-- local data_list = self.vo.grid_data_list
	-- self.equip_grid:SetDataList(data_list)
	-- local list = {}
	-- for i = 0, EquipData.EquipIndex.EquipMaxIndex do
	-- 	if i >= EquipData.EquipIndex.NorEquipMaxIndex then
	-- 		list[i - EquipData.EquipIndex.NorEquipMaxIndex] = data_list[i]
	-- 	end
	-- end
	-- -- self.equip_grid2:SetDataList(list)
	-- self.node_t_list.label_role_name.node:setString(self.vo.name)
end

HeroInfoView.EquipBgMap = {
	[0] = 0,
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 5,
	[6] = 6,
	[7] = 7,
	[8] = 8,
	[9] = 9,
	[10] = 17,
	[11] = 18,
	[12] = 19,
	[13] = 20,
}
function HeroInfoView:SetGridStyle()
	if not self.equip_grid then return end
	local celllist = {}
	for i = 0, EquipData.EquipIndex.HeroSaintKneecap - EquipData.EquipIndex.HeroWeapon do
		celllist[i] = {bg = ResPath.GetCommon("cell_100"), bg_ta = HeroInfoView.GetEquipBg(HeroInfoView.EquipBgMap[i])}
	end
	self.equip_grid:SetCellSkinStyle(celllist)
end

function HeroInfoView:SetGridStyle2()
	if not self.equip_grid2 then return end

	local celllist = {}
	for i = 0, EquipData.EquipIndex.EquipMaxIndex - EquipData.EquipIndex.NorEquipMaxIndex do
		celllist[i] = {bg = ResPath.GetCommon("cell_100"), bg_ta = HeroInfoView.GetEquipBg(i +  COMMON_CONSTS.MAX_NORMAL_EQUIP_PART + 1)}
	end
	self.equip_grid2:SetCellSkinStyle(celllist)
end

function HeroInfoView.GetEquipBg(i)
	local path = ""
	path = ResPath.GetEquipBg("equip_ta_" .. i)

	return path
end

function HeroInfoView:GetEquipGrid()
	return self.equip_grid
end

--主角身上的装备变化
function HeroInfoView:OnEquipDataChange(reason, index)
	-- print("英雄装备--------", reason, index)
	if reason == -1 then
		self:OnEquipDataListChange()
	else
		local item_data = ZhanjiangData.Instance:GetGridData(index)
		local is_select = false
		local cur_cell = nil
		if nil ~= item_data then
			cur_cell = self:GetOneGirdCell(index)
			if nil ~= cur_cell then
				is_select = cur_cell:IsSelect()
			end
		end
		self:UpdateOneGirdCell(index, item_data)
		if nil ~= cur_cell then
			cur_cell:SetSelect(is_select)
		end
		self:OnEquipTips()
	end
end

function HeroInfoView:OnEquipTips()
	-- local bool_show  = EquipData.Instance:GetBoolShowEquipCell()
	for k,v in pairs(self.all_text) do
		-- if k >= 10 and k <= 13 then
		-- 	if bool_show then
		-- 		v:setVisible(true)
		-- 	else
		-- 		v:setVisible(false)
		-- 	end
		-- end 
		local data = ZhanjiangData.Instance:GetBagBestEquipByType(k + EquipData.EquipIndex.HeroWeapon)
		if data == nil then
			v:setVisible(false)
		else
			local equip_data = ZhanjiangData.Instance:GetGridData(k + EquipData.EquipIndex.HeroWeapon)
			if equip_data == nil and (k <= 9) then
				v:setVisible(true)
				local fade_out = cc.FadeTo:create(0.75, 20)
				local fade_in = cc.FadeTo:create(1, 100)
				local action = cc.Sequence:create(fade_out, fade_in)
				v:runAction(cc.RepeatForever:create(action))
			else
				v:setVisible(false)
				v:stopAllActions()
			end
		end
	end
end

function HeroInfoView:GetOneGirdCell(index)
	if index >= EquipData.EquipIndex.HeroWeapon and index <= EquipData.EquipIndex.HeroSaintKneecap then
		-- return self.equip_grid2:GetCell(index - EquipData.EquipIndex.NorEquipMaxIndex)
		return self.equip_grid:GetCell(index - EquipData.EquipIndex.HeroWeapon)
	else
	end
end

function HeroInfoView:UpdateOneGirdCell(index, item_data)
	if index >= EquipData.EquipIndex.HeroWeapon and index <= EquipData.EquipIndex.HeroSaintKneecap then
		self.equip_grid:UpdateOneCell(index - EquipData.EquipIndex.HeroWeapon, item_data)
	else

	end
end

--主角身上的列表装备变化
function HeroInfoView:OnEquipDataListChange()
	local data_list = ZhanjiangData.Instance:GetShowGrid()
	self.equip_grid:SetDataList(data_list)
	local list = {}
	-- for i = 0, EquipData.EquipIndex.EquipMaxIndex do
	-- 	if i >= EquipData.EquipIndex.HeroWeapon then
	-- 		list[i - EquipData.EquipIndex.HeroWeapon] = data_list[i]
	-- 	end
	-- end
	-- self.equip_grid2:SetDataList(list)
end

--主角属性变化
function HeroInfoView:FlushAttrValue(key, value)
	if key == OBJ_ATTR.ENTITY_MODEL_ID or key == OBJ_ATTR.ACTOR_WEAPON_APPEARANCE or 
		key == OBJ_ATTR.ACTOR_EFFECTAPPEARANCE or key == OBJ_ATTR.ACTOR_WING_APPEARANCE then
		self:ApperanceChange()
	elseif key == "name" then
		local name_txt = DelNumByString(value)
		self.node_t_list.label_role_name.node:setString(name_txt)
	elseif key == OBJ_ATTR.CREATURE_LEVEL or key == OBJ_ATTR.ACTOR_CIRCLE then
		self.node_t_list.levelText.node:setString(ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) .. Language.Common.Zhuan .. ZhanjiangData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) .. Language.Common.Ji)	
	end
	-- 	if attr_name == OBJ_ATTR.ACTOR_SOCIAL_MASK then
	-- 		-- self.layout_hidesq_hook.img_hook.node:setVisible(RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.HIDE_WEAPON_EXTEND))
	-- 		-- self.layout_hidesj_hook.img_hook.node:setVisible(RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.HIDE_FATION_CLOTH))
	-- 	end
	-- 	if attr_name == OBJ_ATTR.CREATURE_LEVEL then
	-- 		self:FlushBodyEquip()
	-- 	end
	-- 	-- if attr_name == OBJ_ATTR.ACTOR_FASHION_MAN or
	-- 	-- 	attr_name == OBJ_ATTR.ACTOR_FASHION_WOMEN or 			
	-- 	-- 	attr_name == OBJ_ATTR.ACTOR_HUANWU	or 			
	-- 	-- 	attr_name == OBJ_ATTR.ACTOR_ZUJI or 						
	-- 	-- 	attr_name == OBJ_ATTR.ACTOR_ZHENQI	or				
	-- 	-- 	attr_name == OBJ_ATTR.ACTOR_USE_FASHION then
	-- 	-- 	local data = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_USE_FASHION)
	-- 	-- 	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	-- 	-- 	self:SetEquip2Data(data, sex)
	-- 	-- end 
	-- end
end

--主角外观变化
function HeroInfoView:ApperanceChange()
	if self.hero_display then
		self.hero_display:SetHeroVo(ZhanjiangData.Instance:GetHeroVoData())
	end
end

function HeroInfoView:OnBagItemChange(change_type, change_item_id, change_item_index, series, reason)
	if ItemData.GetIsEquip(change_item_id) then
		self:OnEquipTips()
	end
end

--选择格子
function HeroInfoView:SelectCellCallBack(cell_index, cell)
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	if cell ~= nil and cell:GetData() == nil then
		if self.is_main_role == true then
			if cell:GetIndex() < 10 then
				local index = cell:GetIndex() + cell_index
				local data = ZhanjiangData.Instance:GetBagBestEquipByType(index)
				if data == nil then
					SysMsgCtrl.Instance:FloatingTopRightText(Language.Role.NoCanEquip)
				else
					local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
					if item_cfg == nil then
						return
					end
					local hand_pos = ZhanjiangData.Instance:GetEquipHandPosByIndex(index)
					RoleCtrl.SendFitOutEquip(data.series, hand_pos, 1)
				end
			end
		end
	end
	local tempType
	if cell:GetData() and cell:GetData().item_id then
		tempType= ItemData.Instance:GetItemConfig(cell:GetData().item_id)
	end
	local TempData = {}
	TempData.color= {}
	if tempType and tempType.suitId >0 then
		for i=0,9 do
			TempData.color[i+1] = "afafaf"		
			local cellData = self.equip_grid:GetCell(i)
			if cellData and cellData:GetData() then
				local it_cfg = ItemData.Instance:GetItemConfig(cellData:GetData().item_id)
				if it_cfg and it_cfg.suitId>=tempType.suitId then
					TempData.color[i+1] = "00ff00"
					if tempType.type ==6 then
						TempData.color[5] = "afafaf"
						TempData.color[6] = "afafaf"
					elseif tempType.type == 7 then
						TempData.color[8] = "afafaf"
						TempData.color[7] = "afafaf"
					end
				end
			end
		end
	end
	local removestr1,removestr2 = "afafaf","afafaf"
	if TempData.color[6]== "00ff00" or TempData.color[5] == "00ff00" then
		removestr1="00ff00"
	end
	if  TempData.color[7] == "00ff00" or TempData.color[8] == "00ff00" then
		removestr2="00ff00"
	end
	local tempcolor = {}
	for i=1,8 do
		if i<=4 then
			tempcolor[i]= TempData.color[i]
		elseif i==5 then
			tempcolor[i] = removestr1
		elseif  i==6 then
			tempcolor[i] = removestr2
		elseif i>6 then
			tempcolor[i]= TempData.color[i+2]
		end
	end
	TipsCtrl.Instance:setTipData(tempcolor)
	--打开tip, 提示脱下装备
	if cell:GetName() == "equip" then
		-- print("点击装备")
		TipsCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROM_HERO_EQUIP, {fromIndex = cell.index})
	elseif cell:GetName() == "player_equip" then
		TipsCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROME_BROWSE_ROLE_VIEW, {fromIndex = cell.index})
	end
end

--点击婚戒
function HeroInfoView:SelectHunjieCallBack(cell)
	if cell == nil or cell:GetData() == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.HunjieEquipGetTip)
		return
	end
	if cell:GetName() == "equip" then			--打开tip, 提示脱下装备	
		TipsCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROM_BAG_EQUIP)
	end
end

--点击法宝
function HeroInfoView:SelectFabaoCallBack(cell)
	if cell == nil or cell:GetData() == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.FabaoEquipGetTip)
		return
	end
	if cell:GetName() == "equip" then			--打开tip, 提示脱下装备
		TipsCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROM_BAG_EQUIP)
	end
end

function HeroInfoView:GetEquipCellByIndex(index)
	return self.equip_grid:GetCell(index)
end

function HeroInfoView:SetSpecialEquipCellShow(is_show_fabao, is_show_xuefu, is_show_zhanhun)

	local xuefu = self.equip_grid:GetCell(GameEnum.EQUIP_INDEX_XUEFU)
	if nil ~= xuefu then
		xuefu:SetVisible(is_show_xuefu)
	end

	local zhanhun = self.equip_grid:GetCell(GameEnum.EQUIP_INDEX_ZHANHUN)
	if nil ~= zhanhun then
		zhanhun:SetVisible(is_show_zhanhun)
	end
end

function HeroInfoView:FlushBodyEquip()
	local equip_data = EquipData.Instance:GetDataList()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	for k, v in pairs(equip_data) do
		if ItemData.GetIsComposeEquip(v.item_id) == false then
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg == nil then
				return 
			end
			for k1,v1 in pairs(item_cfg.conds) do
				if v1.cond == ItemData.UseCondition.ucLevel then
					if v1.value > role_level then
						RoleCtrl.SendTakeOffEquip(v.series)
					end
				end
			end
		end
	end
end

function HeroInfoView:OnOpenSuitEquip()
	ViewManager.Instance:Open(ViewName.SuitTip)
	
	if self.is_main_role then
		local num = EquipData.Instance:GetGodEquipNum()
		local circle = EquipData.Instance:GetSuitStep()
		local job = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local data = EquipData.Instance:GetNumT()
		-- PrintTable(data)
		ViewManager.Instance:FlushView(ViewName.SuitTip, 0, "myself", {index = num, circle = circle, prof = job, my_data = data})
	else
		local num = BrowseData.Instance:GetGodEquipNum()
		local circle = BrowseData.Instance:GetSuitStep()
		local data = BrowseData.Instance:GetNumT()
		local job = self.vo[OBJ_ATTR.ACTOR_PROF]
		ViewManager.Instance:FlushView(ViewName.SuitTip, 0, "other", {index = num, circle = circle, prof = job, other_data = data})
	end
end

--更新视图界面
function HeroInfoView:UpdateIcon()
	self.node_t_list.lay_gold_bing.node:setVisible(false)
	self.node_t_list.lay_gold_dun.node:setVisible(false)
	local cfg = ZhanjiangData.Instance:getHeroGold(ZhanjiangData.TempType.GoldBingLevel)
	if cfg and cfg.temp_value and cfg.temp_value >=1 then
		local cur_step = math.ceil(cfg.temp_value/10)
		local icon  = ZhanjiangData.Instance:GetHeroGoldIconCfg(ZhanjiangData.TempType.GoldBingLevel,cur_step)
		self.node_t_list.lay_gold_bing.img_show_bing.node:loadTexture(ResPath.GetItem(icon))
		self.node_t_list.lay_gold_bing.node:setVisible(true)
	end
	cfg = ZhanjiangData.Instance:getHeroGold(ZhanjiangData.TempType.GoldDunLevel)
	if cfg and cfg.temp_value and cfg.temp_value >=1 then
		local cur_step = math.ceil(cfg.temp_value/10)
		local icon  = ZhanjiangData.Instance:GetHeroGoldIconCfg(ZhanjiangData.TempType.GoldDunLevel,cur_step)
		self.node_t_list.lay_gold_dun.img_show_dun.node:loadTexture(ResPath.GetItem(icon))
		self.node_t_list.lay_gold_dun.node:setVisible(true)
	end
end