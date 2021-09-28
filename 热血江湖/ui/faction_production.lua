-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_production = i3k_class("wnd_faction_production", ui.wnd_base)

local SelectExp =
{
	[ 1] = function(tbl) --
		local _cmp = function(d1, d2)
			return d1.order < d2.order;
		end
		table.sort(tbl, _cmp);
	end,
};

local LAYER_ZMSCT1 = "ui/widgets/zbsct1"
local LAYER_ZMSCT2 = "ui/widgets/zbsct2"
local LAYER_ZMSCT3 = "ui/widgets/zmsct3"
local LAYER_ZMSCT4 = "ui/widgets/zmsct"
local LAYER_ZMSCT5 = "ui/widgets/zmsct4"

local ITEM_WIDGET = "ui/widgets/zmscfjt"
local LAYER_ZMSCFMT = "ui/widgets/zmscfmt"
local LAYER_LIANHUAT = "ui/widgets/lianhuat"
local RowItemCount = 4

local production_namelist = {"武器","防具","饰品","神兵","宠物","药品","内甲","杂物"}
-- local ItemRole_typelist = {"刀系","剑系","枪系","弓系","医系","刺客","符师"}
local ItemRole_Clist = {"一转","二转","三转","四转"}
local ItemRole_Mlist = {"正派","邪派"}
local FontColorlist = { "FF0C6909","FFFF5715","FF0C6909"}
local SelectBglist = {707,706}
local e_Type_item_iron = 3
local e_Type_item_herb = 4
local once_max_recycle_item = i3k_db_clan_recycle_base_info.one_max_recycle_item_num  --一次最大可炼化道具数
local ProgressBarImglist = {3767, 3768, 3769, 3770}  --进度条颜色

function wnd_faction_production:ctor()
	self._production = {{},{},{},{},{},{},{}}
	self._sid = nil;
	self._gid = nil
	self._id = nil;
	self._pid = nil;
	self._clanID = nil;
	self._item = {}
	self._seperation = {}
	self._productionexp = 0;
	self._productionlvl = 1;
	self._herb = 0;
	self._iron = 0;
	self._sperationpower = 0;
	self._clanlvl = 1;
	self._productionID = nil;
	self._real_pro_id = nil
	self._productionCount = 0
	self._timer = 0;
	self._sendtype = 0
	self._seperationpower = 0

	self.ironID = true --是否是玄铁
	self.isHaveID = true --是否是（玄铁和药草）

	self._page = 1
	self._pageCnt = 1
	self._mark_count = 5

	self._select_bg = nil
	self._select_bg1 = nil

	self._select_lvl = nil
	self._select_exp = nil

	self._tmp_info = nil

	self._is_produnct_ok = false
	self._is_fenjie_ok = false

	self._is_produnction_all = false -- 是否全部生产
	self._is_fenjie_all = false --是否全部分解

	self._need_cell_count = 0

	self._is_select_equip = true --是否删选装备 默认勾选

	self._refine_property = {}

	self._current_equip_id = 0 -- 当前选中的装备id
	self._current_equip_guid = 0 -- 当前选中的装备guid
	self._current_equip_pos = 0 --当前精炼的装备是否是身上的装备
	self._current_equip_item = 0 --当前选中的精炼道具
	self._current_equip_free = false -- 默认全部使用，true只是用非绑定道具，false只用绑定道具
	self._current_equip_equip_type = eEquipWeapon --当前装备类型
	self._current_equip_equip_index = 1 -- 当前所选装备在列表中的下标

	self._curren_equip_is_have_refine = false --

	--炼化
	self._is_select_gather = false --是否选中堆叠炼化
	self._can_recycle_items = {}  --可以炼化的物品
	self._need_recycle_items = {} --需要炼化的物品
	self._recycle_all_points = 0  --炼化的总点数
	self._need_consume_itemCnt = 0  --炼化需要消耗道具的数量
	self._need_recycle_times = 0  --需要炼化的次数
	self._recycle_remain_points = 0  --不足一次的炼化点数

	self._current_select_item = nil  --当前选择的物品
	self._current_select_bar = nil  --当前点击的物品控件
	self._current_need_recycle_item_num = 0  --当前需要炼化物品的数量

	self._remainRecycleCnt = 0  --日剩余炼化物品数
end

function wnd_faction_production:refresh(index1,index2)
	if not self._gid then
		self._gid = 1;
	end
	self._id = index1
	if not self._id then
		self._id = 1;
	end
	self.selectRoot:setVisible(self._id == eProductionWeapon or self._id == eProductionArmor)
	if index2 and index2 <= self._mark_count then
		self._pid = index2
	end

	if not self._pid then
		self._pid = 1;
	end

	self:setTitleAttribute()
	self:onUpdata(index2)
	if self._gid == 1 then
		g_i3k_game_context:LeadCheck()
	end
end

function wnd_faction_production:freshPage(pageNum) --选择第几页
	-- body
	self._gid = pageNum
	self:refresh()
end

function wnd_faction_production:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
	self.productionpropanel = widgets.productionpropanel
	self.zhizhao_btn = widgets.zhizhao_btn
	self.fenjie_btn = widgets.fenjie_btn
	self.zhizhao_label = widgets.zhizhao_label
	self.fenjie_label = widgets.fenjie_label
	self.zhizhao_panel = widgets.zhizhao_panel
	self.fenjie_panel = widgets.fenjie_panel
	self.productionIcon = widgets.productionIcon
	self.productionname = widgets.productionname
	self.productionlvl = widgets.productionlvl
	self.productionlimit = widgets.productionlimit
	self.productionrank = widgets.productionrank
	self.productionhostericon = widgets.productionhostericon
	self.productbtn = widgets.productbtn
	self.productbtnall = widgets.productbtnall
	self.productbtn:onClick(self,self.onProductionStart,1)
	self.productbtnall:onClick(self,self.onProductionStartAll)
	self.productiondesc = widgets.productiondesc

	self.export = {}
	for i = 1, 4 do
		self.export[i] = {
			exportbtn = widgets['fj_btn'..i],
			exporticon = widgets['fj_icon'..i],
			Seperationexport = widgets['fj_bg'..i],
			exportcounttext = widgets['fj_num'..i],
			suo = widgets['fj_suo'..i],
		}
	end
	self.seperationpanel = widgets.seperationpanel
	self.Seperation_start = widgets.Seperation_start
	self.SeperationStartAll = widgets.SeperationStartAll
	self.scrollS = widgets.scrollS
	self.Seperation_start:onClick(self,self.onSeperationStart,1)
	self.SeperationStartAll:onClick(self,self.onSeperationStartAll)
	self.SeperationIcon = widgets.SeperationIcon
	self.SeperationSuo = widgets.SeperationSuo
	self.Seperationrank = widgets.Seperationrank
	self.powercosttext = widgets.powercosttext
	-- self.seperationtips = widgets.seperationtips
	self.seperationitemname = widgets.seperationitemname
	self.seperationiteminfo = widgets.seperationiteminfo
	self.seperationitempower = widgets.seperationitempower
	self.seperationitemlvl = widgets.seperationitemlvl
	self.seperationitemM = widgets.seperationitemM
	self.seperationitemC = widgets.seperationitemC
	self.seperationnamepanel = widgets.seperationnamepanel
	widgets.purple_btn:onClick(self, self.onToggleClick, "fenjie_show_purple")
	widgets.orange_btn:onClick(self, self.onToggleClick, "fenjie_show_orange")
	widgets.ignoreCanSell_btn:onClick(self, self.onToggleClick, "fenjie_hide_can_sell")
	widgets.ignoreHighPower_btn:onClick(self, self.onToggleClick, "fenjie_hide_high_power")
	self.toggles = {widgets.purple_btn, widgets.orange_btn, widgets.ignoreCanSell_btn, widgets.ignoreHighPower_btn}
	local usercfg = g_i3k_game_context:GetUserCfg()
	widgets.purple:setVisible(usercfg:GetFenJie("fenjie_show_purple"))
	widgets.orange:setVisible(usercfg:GetFenJie("fenjie_show_orange"))
	widgets.ignore_can_sell:setVisible(usercfg:GetFenJie("fenjie_hide_can_sell"))
	widgets.ignore_high_power:setVisible(usercfg:GetFenJie("fenjie_hide_high_power"))

	self.action_tips_btn = widgets.action_tips_btn
	self.action_tips_btn:onTouchEvent(self,self.onActionTips)
	--self.herb_tips_btn = widgets.herb_tips_btn
	--self.herb_tips_btn:onTouchEvent(self,self.onHerbTips)
	--self.iron_tips_btn = widgets.iron_tips_btn
	--self.iron_tips_btn:onTouchEvent(self,self.onIronTips)

	self.scroll2 = widgets.scroll2

	self.ingotRoot2 = widgets.ingotRoot2
	self.diamond = widgets.diamond

	self.zhizhao_btn:onTouchEvent(self,self.onSelectProduction)
	self.zhizhao_btn:setTag(1)
	self.fenjie_btn:onTouchEvent(self,self.onSelectSeperation)
	self.fenjie_btn:setTag(2)

	self.selectbtn = widgets.selectbtn
	self.selectbtn:onClick(self,self.onSelectEquipByRole)
	self.selectIcon = widgets.selectIcon
	self.selectIcon:setVisible(self._is_select_equip)

	self.selectRoot = widgets.selectRoot
	self.selectRoot:show()

	--精炼的界面数据
	self.refine_btn = widgets.refine_btn

	self.refine_btn:onClick(self,self.onSelectRefine)
	self.refine_btn:setTag(3)
	self.refine_root = widgets.refine_root
	self.refine_root:hide()

	self.weaponBtn = widgets.weaponBtn
	self.clothesBtn = widgets.clothesBtn
	self.headBtn = widgets.headBtn
	self.handBtn = widgets.handBtn
	self.shoesBtn = widgets.shoesBtn
	self.ringBtn = widgets.ringBtn
	self.weaponBtn:onClick(self,self.onEquip,eEquipWeapon)
	self.clothesBtn:onClick(self,self.onEquip,eEquipClothes)
	self.headBtn:onClick(self,self.onEquip,eEquipHead)
	self.handBtn:onClick(self,self.onEquip,eEquipHand)
	self.shoesBtn:onClick(self,self.onEquip,eEquipShoes)
	self.ringBtn:onClick(self,self.onEquip,eEquipRing)

	self.equipScroll = widgets.equipScroll

	self.equipBg = widgets.equipBg
	self.equipIcon = widgets.equipIcon
	self.equipName = widgets.equipName
	self.equipLvl = widgets.equipLvl
	self.equipJob = widgets.equipJob
	self.sjtx1 = widgets.sjtx1
	self.sjtx2 = widgets.sjtx2
	for i=1,3 do
		local tmp_property = string.format("property%s",i)
		local property = widgets[tmp_property]

		local tmp_value = string.format("propertyValue%s",i)
		local propertyValue = widgets[tmp_value]

		local tmp_max= string.format("maxImg%s",i)
		local maxImg = widgets[tmp_max]

		self._refine_property[i] = {property = property, propertyValue = propertyValue, maxImg = maxImg}
	end

	self.itemTitle = widgets.itemTitle

	self.itemScroll = widgets.itemScroll
	self.refineItemIcon = widgets.refineItemIcon
	self.refineItemIconSuo = widgets.refineItemIconSuo
	self.refineItemCount = widgets.refineItemCount

	self.equipPower = widgets.equipPower

	--local useFreeBtn = widgets.useFreeBtn
	--self.freeIcon = widgets.freeIcon
	--self.freeIcon:hide()

	self.refineBtn = widgets.refineBtn
	self.refineBtn:onClick(self,self.onRefineEquip)
	--useFreeBtn:onClick(self,self.onRefineEquipUseFreeItem)
	self.refineItemDesc = widgets.refineItemDesc
	self.refineItemDesc:hide()

	--炼化的界面数据
	self.recycle_root = widgets.recycle_root
	self.lianhua_btn = widgets.lianhua_btn
	self.lianhua_btn:onTouchEvent(self,self.onSelectRecycle)
	self.lianhua_btn:setTag(4)

	self.recycle_btn = widgets.recycle_btn
	self.recycle_btn:onClick(self,self.onClickRecycle)

	self.cost_energy = widgets.cost_energy

	self.gather_btn = widgets.gather_btn
	self.gather_btn:onClick(self,self.onRecycleGather)
	self.gather_img = widgets.gather_img

	self.recycleListView = widgets.equipScroll2

	self.lu_zi_model = widgets.lu_zi

	--消耗道具图标
	self.consume_icon_img = widgets.consume_icon_img
	self.consume_icon_btn = widgets.consume_icon_btn
	self.consume_icon = widgets.consume_icon
	self.remain_txt = widgets.remain_txt

	--
	self.rightBtn = widgets.rightBtn
	self.rightBtn:onClick(self,self.onRightBtn)
	self.leftBtn = widgets.leftBtn
	self.leftBtn:onClick(self,self.onLeftBtn)
	self.pageLable = widgets.pageLable
	self.itemlistview = widgets.itemlistview

end

function wnd_faction_production:onShow()

end
--分解界面 四个按钮
local toggleMap = {
	["fenjie_hide_can_sell"] = {uiName = "ignore_can_sell"},
	["fenjie_hide_high_power"] = {uiName = "ignore_high_power"},
	["fenjie_show_orange"] = {uiName = "orange"},
	["fenjie_show_purple"] = {uiName = "purple"},
}
function wnd_faction_production:onToggleClick(sender, arg)
	local usercfg = g_i3k_game_context:GetUserCfg()
	local ui = self._layout.vars[toggleMap[arg].uiName]
	ui:setVisible(not ui:isVisible())
	usercfg:SetFenJie(arg, ui:isVisible())
	self._sid = nil
	self:setSeperationData()
end

function wnd_faction_production:addDiamondBtn(sender)
	g_i3k_logic:OpenChannelPayUI()
end

function wnd_faction_production:onActionTips(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_NewTips,i3k_get_string(15124,i3k_db_clan_separation.recover_time,i3k_db_clan_separation.recover_count), self:getActionBtnPosition())
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_NewTips)
		end
	end
end

function wnd_faction_production:getActionBtnPosition()
	local btnSize = self.action_tips_btn:getParent():getContentSize()
	local sectPos = self.action_tips_btn:getPosition()
	local btnPos = self.action_tips_btn:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

function wnd_faction_production:onHerbTips(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_NewTips,i3k_get_string(15118), self:getHerbBtnPosition())
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_NewTips)
		end
	end
end

function wnd_faction_production:getHerbBtnPosition()
	local btnSize = self.herb_tips_btn:getParent():getContentSize()
	local sectPos = self.herb_tips_btn:getPosition()
	local btnPos = self.herb_tips_btn:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

function wnd_faction_production:onIronTips(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_NewTips,i3k_get_string(15119), self:getIronBtnPosition())
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_NewTips)
		end
	end
end

function wnd_faction_production:getIronBtnPosition()
	local btnSize = self.iron_tips_btn:getParent():getContentSize()
	local sectPos = self.iron_tips_btn:getPosition()
	local btnPos = self.iron_tips_btn:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

function wnd_faction_production:onSelectEquipByRole(sender)

	if self._is_select_equip then
		self._is_select_equip = false
	else
		self._is_select_equip = true
	end
	self.selectIcon:setVisible(self._is_select_equip)
	self:setProductionData()
end

function wnd_faction_production:onUpdata(index)
	self.zhizhao_label:setText("制造")
	self.fenjie_label:setText("分解")

	local role_lvl = g_i3k_game_context:GetLevel()
	if role_lvl >= i3k_db_clan_recycle_base_info.tab_show_lvl then  --达到页签显示等级
		self.lianhua_btn:show()
		self.lianhua_btn:stateToNormal()

		if role_lvl >= i3k_db_clan_recycle_base_info.fun_open_lvl then  --达到功能开放等级
			if g_i3k_game_context:GetRecycleCanOpen() <= 0 and self._gid == 4 then  --未开启炼化炉功能
				g_i3k_ui_mgr:OpenUI(eUIID_RecycleOpen)
				g_i3k_ui_mgr:RefreshUI(eUIID_RecycleOpen)
				return
			end
		else
			if self._gid == 4 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15431, i3k_db_clan_recycle_base_info.fun_open_lvl))
				return
			end
		end
	else
		self.lianhua_btn:hide()
	end

	self.zhizhao_btn:stateToNormal()
	self.fenjie_btn:stateToNormal()
	self.refine_btn:stateToNormal()
	self.zhizhao_panel:hide()
	self.fenjie_panel:hide()
	self.refine_root:hide()
	self.recycle_root:hide()
	if self._gid == 1 then
		self:setProductionData(index)
		self:setProductionAttribute()
		self.zhizhao_btn:stateToPressed()
		self.zhizhao_panel:show()
		g_i3k_game_context:LeadCheck()
	elseif self._gid == 2 then
		self:setSeperationData()
		self.fenjie_btn:stateToPressed()
		self.fenjie_panel:show()
		self._select_bg = nil
		self._select_bg1 = nil
		self._select_lvl = nil
		self._select_exp = nil
	elseif self._gid == 3 then
		self.refine_btn:stateToPressed()
		self.refine_root:show()
		self:updateRefinebtn()
		self.weaponBtn:stateToPressed(true)
		self:updateEquipsList(self:getEquipsByType(eEquipWeapon),eEquipWeapon)
		self._current_equip_equip_type = eEquipWeapon
		self._current_equip_equip_index = 1
	elseif self._gid == 4 then
		self:resetRecycleData()
		self.lianhua_btn:stateToPressed()
		self.recycle_root:show()
		self:setRecycleData()
		self:playStoveFireAni("stand")
	end
end

function wnd_faction_production:onSelectProduction(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if self._gid ~= sender:getTag() then
			self._gid = sender:getTag()
			self:cancelCheck()
			self:onUpdata()
		end
	end
end

function wnd_faction_production:onSelectSeperation(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if self._gid ~= sender:getTag() then
			self._gid = sender:getTag()
			self:cancelCheck()
			self._sid = nil;
			self:onUpdata()
		end
	end
end

function wnd_faction_production:onSelectRefine(sender)
	if self._gid ~= sender:getTag() then
		self._gid = sender:getTag()
		self:cancelCheck()
		self._sid = nil;
		self:onUpdata()
	end
end

function wnd_faction_production:onSelectRecycle(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if g_i3k_game_context:GetRecycleCanOpen() <= 0 then  --未开启炼化炉功能
			self._gid = sender:getTag()
			self:cancelCheck()
			self._sid = nil;
			self:onUpdata()
		else
			if self._gid ~= sender:getTag() then
				self._gid = sender:getTag()
				self:cancelCheck()
				self._sid = nil;
				self:onUpdata()
			end
		end
	end
end

function wnd_faction_production:setProductionData(index)
	self.scroll2:removeAllChildren()
	self._page = math.modf(self._pid/self._mark_count)
	if self._pid%self._mark_count ~= 0 then
		self._page = self._page + 1
	end

	self.productionpropanel:hide()
	local scroll1 = self._layout.vars.scroll1
	if scroll1 then
		self._production = {{},{},{},{},{},{},{},{}}
		--local ProductionRecipes = g_i3k_game_context:getProductionRecipes();
		--[[if #ProductionRecipes >0 then
			for k,v in pairs(ProductionRecipes) do
				local production_cfg = i3k_db_productioninfo[v]
				if production_cfg then
					table.insert(self._production[production_cfg.type],production_cfg)
				end
			end
		end]]
		local base_cfg = i3k_db_common.production_base
		for k,v in ipairs(base_cfg.productionIDs) do
			local production_cfg = i3k_db_productioninfo[v]
			if production_cfg then
				if not self._is_select_equip then
					table.insert(self._production[production_cfg.type],production_cfg)
				else
					if eProductionWeapon == production_cfg.type or eProductionArmor == production_cfg.type then
						local equipcfg =  g_i3k_db.i3k_db_get_equip_item_cfg(production_cfg.productionID)
						if g_i3k_game_context:GetRoleType() == equipcfg.roleType then
							table.insert(self._production[production_cfg.type],production_cfg)
						end
					else
						table.insert(self._production[production_cfg.type],production_cfg)
					end
				end
			end
		end
		self._pageCnt, f = math.modf(#self._production[self._id]/self._mark_count)
		if f ~= 0 then
			self._pageCnt = self._pageCnt + 1
		end
		---------------一级显示--------------------
		local level1count = 0
		for k,v in ipairs(self._production) do
			if #v > 0 then
				level1count = level1count + 1
			end
		end
		self.pageLable:setText(string.format("第%s/%s页",self._page,self._pageCnt))
		local allBars = scroll1:addChildWithCount(LAYER_ZMSCT1, 1, #self._production)
		local barindex = 1;
		for k, v in pairs(allBars) do
			v.vars.typebtn:hide();
		end
		for k, v in ipairs(self._production) do
			if #v >0 then
				local bar = allBars[barindex]
				self:setProductionLevel1(v,k,bar,index)
				barindex = barindex + 1
			end
		end
	end
end

function wnd_faction_production:setProductionLevel1(typeinfo,index,bar,item_index)
	local name = production_namelist[index]
	local production_typename = bar.vars.typetext
	local production_typebtn = bar.vars.typebtn

	production_typename:setText(name)
	production_typebtn:show()
	production_typebtn:setTag(index)
	production_typebtn:onClick(self,self.onProductionType)
	--production_typebtn:stateToNormal()

	if self._id == index then
		production_typebtn:stateToPressed()
		---------------二级显示--------------------
		local tmp = {}
		for i= (self._page -1)*self._mark_count +1, self._mark_count * self._page  do
			if self._production[index][i] then
				table.insert(tmp,self._production[index][i])
			end
		end
		self._layout.vars.scroll2:cancelLoadEvent()

		self.scroll2:removeAllChildren()
		self.scroll2:addItemAndChild(LAYER_ZMSCT2, 1, #tmp)

		local allBars = self.scroll2:getAllChildren()
		for index, bar in ipairs(allBars) do
				if typeinfo[index] and bar then
				self:setProductionLevel2(tmp[index],index,bar)
			end
		end
		self.scroll2:jumpToChildWithIndex(self._pid)
	end
end

function wnd_faction_production:onLeftBtn(sender)
	if self._page > 1 then
		self._page = self._page - 1
		self._pid = 1
		local tmp = {}
		local a = self._page

		for i= (self._page -1)*self._mark_count +1, self._mark_count * self._page  do
			if self._production[self._id][i] then
				table.insert(tmp,self._production[self._id][i])
			end
		end
		self.scroll2:removeAllChildren()
		self.scroll2:addItemAndChild(LAYER_ZMSCT2, 1, #tmp)
		local allBars = self.scroll2:getAllChildren()
		for index, bar in ipairs(allBars) do
			if tmp[index] and bar then
				self:setProductionLevel2(tmp[index],index,bar)
			end
		end
		self.pageLable:setText(string.format("第%s/%s页",self._page,self._pageCnt))
		self.scroll2:jumpToChildWithIndex(self._pid)
	end
end

function wnd_faction_production:onRightBtn(sender)
	self._page = self._page + 1
	local tmp = {}
	local a = self._page
	for i= (self._page -1)*self._mark_count +1, self._mark_count * self._page  do
		if self._production[self._id][i] then
			table.insert(tmp,self._production[self._id][i])
		end
	end
	if #tmp == 0 then
		self._page = self._page - 1
		return
	end
	self._pid = 1
	self.scroll2:removeAllChildren()
	self.scroll2:addItemAndChild(LAYER_ZMSCT2, 1, #tmp)
	local allBars = self.scroll2:getAllChildren()
	for index, bar in ipairs(allBars) do
		if tmp[index] and bar then
			self:setProductionLevel2(tmp[index],index,bar)
		end
	end
	self.pageLable:setText(string.format("第%s/%s页",self._page,self._pageCnt))
	self.scroll2:jumpToChildWithIndex(self._pid)
end



function wnd_faction_production:setProductionLevel2(info,index,bar)
	---------------二级显示--------------------
	---------------数据处理--------------------
	local Itemlvl = nil
	local ItemRoleType = nil
	local ItemCType = nil
	local ItemMType = nil
	local attr = nil
	local ItemName = g_i3k_db.i3k_db_get_common_item_name(info.productionID)
	local ItemRank = g_i3k_db.i3k_db_get_common_item_rank(info.productionID)
	local ItemIcon = g_i3k_db.i3k_db_get_common_item_icon_path(info.productionID,i3k_game_context:IsFemaleRole())
	local Itemdesc = g_i3k_db.i3k_db_get_common_item_desc(info.productionID)
	local item = g_i3k_db.i3k_db_get_common_item_cfg(info.productionID)
	if math.abs(info.productionID) >=131073 and math.abs(info.productionID) <= 196607 then
		Itemlvl = item.level
	elseif math.abs(info.productionID) >=10000000 then
		Itemlvl = item.levelReq
		ItemRoleType = item.roleType
		ItemCType = item.C_require
		ItemMType = item.M_require
		attr = {}
		for k,v in pairs(item.properties) do
			if v.type ~= 0 then
				att = { type = v.type , value = v.value}
				table.insert(attr,att);
			end
		end
	end
	----------------界面处理------------------
	local production_icon = bar.vars.productionicon
	if not production_icon then
		return
	end
	local production_name = bar.vars.productionName
	local production_lvl = bar.vars.productionlvl
	local production_exp = bar.vars.productionexp
	local production_warn = bar.vars.productionwarn
	local production_btn = bar.vars.productionbtn
	local productionselect = bar.vars.productionselect
	local productionselectbg = bar.vars.productionselectbg
	local productionrank = bar.vars.productionrank
	production_name:setText(ItemName)
	production_icon:setImage(ItemIcon)
	production_lvl:hide()
	production_exp:hide()
	production_warn:hide()
	productionselect:hide()
	productionrank:setImage(g_i3k_get_icon_frame_path_by_rank(ItemRank))
	production_btn:setTag(index)
	production_btn:stateToNormal()
	local tmp = {info = info,productionselect = productionselect,productionselectbg = productionselectbg,production_lvl = production_lvl,production_exp = production_exp}
	production_btn:onClick(self,self.onProductionInfo,tmp)
	productionselectbg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBglist[1]))
	--production_name:setTextColor(FontColorlist[1])
	production_name:setTextColor(g_i3k_get_color_by_rank(ItemRank))

	production_lvl:setTextColor(FontColorlist[1])
	production_exp:setTextColor(FontColorlist[1])
	if info.productionCount>1 then
		production_name:setText(ItemName.."*"..info.productionCount)
	end

	if self._clanlvl >= info.need_clan_lvl and self._productionlvl >= info.need_lvl then

		if Itemlvl then
			production_lvl:show()
			production_lvl:setText(Itemlvl.."级")
		end
		if info.exp_get then
			production_exp:show()
			production_exp:setText("熟练+"..info.exp_get)
		end
	else
		production_warn:show()
		if self._productionlvl < info.need_lvl then
			production_warn:setText(string.format("需生产等级%d%s",info.need_lvl,"级"))
		elseif self._clanlvl < info.need_clan_lvl then
			production_warn:setText(string.format("需角色等级%d%s",info.need_clan_lvl,"级"))
		end
	end
	--[[
	if info.hosteronly == 1 then
		production_hosteronly:show()
	end
	--]]
	if self._pid == index then
		production_btn:stateToPressed()
		productionselect:show()
		self._select_bg = productionselect
		self._select_bg1 = productionselectbg
		self._select_lvl = production_lvl
		self._select_exp = production_exp
		--production_name:setTextColor(FontColorlist[3])
		production_lvl:setTextColor(FontColorlist[3])
		production_exp:setTextColor(FontColorlist[3])
		productionselectbg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBglist[2]))
		self._tmp_info = info
		self:setProductionLevel3()
	end
end
function wnd_faction_production:setProductionLevel3()
	if not self._tmp_info or self._gid == 2 then
		return
	end
	local info = self._tmp_info
	local Itemlvl = nil
	local ItemRoleType = nil
	local ItemCType = nil
	local ItemMType = nil
	local attr = nil
	local ItemName = g_i3k_db.i3k_db_get_common_item_name(info.productionID)
	local ItemRank = g_i3k_db.i3k_db_get_common_item_rank(info.productionID)
	local ItemIcon = g_i3k_db.i3k_db_get_common_item_icon_path(info.productionID,i3k_game_context:IsFemaleRole())
	local Itemdesc = g_i3k_db.i3k_db_get_common_item_desc(info.productionID)
	local item = g_i3k_db.i3k_db_get_common_item_cfg(info.productionID)
	if math.abs(info.productionID) >=131073 and math.abs(info.productionID) <= 196607 then
		Itemlvl = item.level
	elseif math.abs(info.productionID) >=10000000 then
		Itemlvl = item.levelReq
		ItemRoleType = item.roleType
		ItemCType = item.C_require
		ItemMType = item.M_require
		attr = {}
		for k,v in pairs(item.properties) do
			if v.type ~= 0 then
				att = { type = v.type , value = v.value}
				table.insert(attr,att);
			end
		end
	end

	----------三级显示--------------
	self.productionlvl:hide()
	self.productionIcon:setImage(ItemIcon)
	self.productionname:setText(ItemName)
	self.productionname:setTextColor(g_i3k_get_color_by_rank(ItemRank))
	self.productionlimit:hide()
	self.productbtn:disableWithChildren()
	self.productbtnall:disableWithChildren()
	self.productionhostericon:hide()
	self._productionCount = info.productionCount
	if Itemlvl then
		self.productionlvl:show()
		self.productionlvl:setText(Itemlvl.."级")
	end
	if ItemRoleType then
		local limit = "限定:"
		if ItemRoleType ~= 0 then
			limit = limit..TYPE_SERIES_NAME[ItemRoleType]
		end
		if ItemCType ~= 0 then
			limit = limit..ItemRole_Clist[ItemCType]
		end
		if ItemMType ~= 0 then
			limit = limit..ItemRole_Mlist[ItemMType]
		end
		if ItemMType ~= 0 or ItemCType ~= 0 or ItemRoleType ~= 0 then
			limit = limit.."职业"
			self.productionlimit:show()
			self.productionlimit:setText(limit)
		end
	end
	self.productionrank:setImage(g_i3k_get_icon_frame_path_by_rank(ItemRank))
	if info.productionCount>1 then
		self.productionname:setText(ItemName.."*"..info.productionCount)
	end
	if info.production_cost then
		local CanProduct = 0
		local kNow = 1
		local ironID = 0
		local itemEnoughFlag = true
		--local vNow = {}
		self.itemlistview:removeAllChildren()
		for k2,v2 in ipairs(info.production_cost) do
			if k2 == 3 then
				ironID = 41
				self.ironID = true
			elseif k2 == 4 then
				ironID = 42
				self.ironID = false
			end
			if v2.ItemID ~= nil then
				if v2.ItemID ~= 0 then
					local item = require(LAYER_ZMSCT5)()
					self.itemlistview:addItem(item)
					self.isHaveID = true
					item.vars.costtextbg:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v2.ItemID,i3k_game_context:IsFemaleRole())))
					item.vars.costIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v2.ItemID))
					item.vars.costbtn:setTag(k2)
					item.vars.costbtn:onClick(self,self.onProItemdetail, v2.ItemID)
					local checkTtemResult  = self:checkItem(kNow,v2.ItemCount,v2.ItemID,item.vars.costtext)
					if checkTtemResult == 0 then
						itemEnoughFlag = false
					end
					CanProduct = CanProduct + checkTtemResult
					kNow = kNow + 1
				else
					CanProduct = CanProduct + 1
				end
			end
		end

		local productionDesc = ""
		if Itemdesc then
			productionDesc = productionDesc .. Itemdesc
		end
		if math.abs(info.productionID) >=10000000 then
			productionDesc = ""
			productionDesc = productionDesc ..i3k_get_string(149)
			for k3,v3 in ipairs(attr) do
				local prop = i3k_db_prop_id[v3.type]
				if prop then
					productionDesc = productionDesc..prop.desc..":"..v3.value.."\n"
				end
			end
			productionDesc = productionDesc ..i3k_get_string(150)
		end
		self.productiondesc:setText(productionDesc)
		self._layout.vars.unBindLabel:setText(info.productionID > 0 and "绑定" or "非绑定")
		-- 魔数 4 是啥意思？经查：4是代表生产所需道具种类，只要有一种道具数量不足CanProduct就会小于4，不足4种道具CanProduct+1
		if itemEnoughFlag and CanProduct >=4 and self._clanlvl >= info.need_clan_lvl and self._productionlvl >= info.need_lvl  then
			self.productbtn:enableWithChildren()
			self.productbtnall:enableWithChildren()
			self._is_produnct_ok  = true
			self._productionID = info.id
			self._real_pro_id = info.productionID
		end
	end
	-------三级显示结束
end
function wnd_faction_production:checkItem(index,ItemCount,ItemID,costtext)
	local Itemhave = 0;
	if self.isHaveID == true then
		Itemhave = g_i3k_game_context:GetCommonItemCanUseCount(ItemID)
		local showtext = Itemhave.."/"..ItemCount
		costtext:setText(showtext)
	else
		if self.ironID == true then
			Itemhave = self._iron
		else
			Itemhave = self._herb
		end
	end

	if Itemhave >= ItemCount then
		costtext:setTextColor(g_i3k_get_green_color())
		return 1;
	else
		costtext:setTextColor(g_i3k_get_red_color())
		return 0;
	end
end

function wnd_faction_production:onProductionType(sender,eventType)

	if self.id ~= sender:getTag() then
		self._id = sender:getTag()
		self.selectRoot:setVisible(self._id == eProductionWeapon or self._id == eProductionArmor)
		self:cancelCheck()
		self._pid = 1;
		self:setProductionData()
	end

end

function wnd_faction_production:onProductionInfo(sender,tmp)
	if self._pid ~= sender:getTag() then
		if self._select_bg then
			self._select_bg:hide()
		end
		if self._select_bg1 then
			self._select_bg1:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBglist[1]))
		end
		if self._select_lvl then
			self._select_lvl:setTextColor(FontColorlist[1])
		end
		if self._select_exp then
			self._select_exp:setTextColor(FontColorlist[1])
		end
		self._select_lvl = tmp.production_lvl
		self._select_exp = tmp.production_exp
		self._select_bg = tmp.productionselect
		self._select_bg1 = tmp.productionselectbg
		if self._select_bg then
			self._select_bg:show()
		end
		if self._select_bg1 then
			self._select_bg1:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBglist[2]))
		end
		if self._select_lvl then
			self._select_lvl:setTextColor(FontColorlist[3])
		end
		if self._select_exp then
			self._select_exp:setTextColor(FontColorlist[3])
		end
		self._pid = sender:getTag()
		self:cancelCheck()
		--self:setProductionData()
		self._tmp_info = tmp.info
		self:setProductionLevel3()
	end

end

function wnd_faction_production:onProductionStart(sender,state)

	local test = {}
	test[self._real_pro_id] = self._productionCount
	if g_i3k_game_context:IsBagEnough(test) then
		self._sendtype = 1
		local production_cancel = self._layout.vars.production_cancel
		production_cancel:onTouchEvent(self,self.onProductionCancel)
		self.productionpropanel:show()
		self._timer = 0.01
		if state and state == 1 then
			self._is_produnction_all = false
		end
	else
		self._is_produnction_all = false
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足，无法制造此类物品")
	end
end

function wnd_faction_production:onProductionStartAll(sender)
	self._is_produnction_all = true
	local test = {}
	test[self._real_pro_id] = self._productionCount
	if g_i3k_game_context:IsBagEnough(test) then
		self._sendtype = 1
		local production_cancel = self._layout.vars.production_cancel
		production_cancel:onTouchEvent(self,self.onProductionCancel)
		self.productionpropanel:show()
		self._timer = 0.01
	else
		self._is_produnction_all = false
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足，无法制造此类物品")
	end
end

function wnd_faction_production:onProductionCancel(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self:productionCancel()

	end
end

function wnd_faction_production:onSeperationCancel(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self:seperationCancel()
	end
end

function wnd_faction_production:cancelCheck()
	if self._sendtype == 1 then
		self:productionCancel()
	elseif self._sendtype == 2 then
		self:seperationCancel()
	end
end
function wnd_faction_production:productionCancel()
	self._sendtype = 0
	self._timer = 0
	self.productionpropanel:hide()
	self._is_produnction_all = false
end

function wnd_faction_production:seperationCancel()
	self._sendtype = 0
	self._timer = 0
	for k,v in pairs(self.export) do
		v.exportbtn:enable()
	end
	for k,v in ipairs(self.toggles) do
		v:enable()
	end
	self.Seperation_start:show()
	self.SeperationStartAll:show()
	self.scrollS:show()
	self.seperationpanel:hide()
	self._is_fenjie_all = false
end

function wnd_faction_production:setTitleAttribute()
	local action_value = self._layout.vars.action_value
	local addAction_btn = self._layout.vars.addAction_btn

--	local data = g_i3k_game_context:getClanDetailData()
	self._clanID = 0
	self._herb = 0
	self._iron = 0
	self._productionexp = g_i3k_game_context:GetProdunctionExp()
	self._productionlvl = g_i3k_game_context:GetProdunctionLvl()
	self._sperationpower =  g_i3k_game_context:GetProductionSplit()
	self._clanlvl =	g_i3k_game_context:GetLevel()
	local maxpower = i3k_db_clan_separation.create_power

	action_value:setText(self._sperationpower.."/"..maxpower)
	addAction_btn:onTouchEvent(self,self.onEnergyaddbtn)
end

function wnd_faction_production:setProductionAttribute()

	local exp_text = self._layout.vars.exp_text
	local lvlinfo = self._layout.vars.lvlinfo
	local lvlinfodetail = self._layout.vars.lvlinfodetail
	local expprocess = self._layout.vars.expprocess


	local logic = i3k_game_get_logic()
	local player = logic:GetPlayer()
	local hero
	if player then
		hero = player:GetHero()
	end
	if not hero then
		return
	end
	local cfg = i3k_db_clan_production_up_lvl
	local cfg1 = cfg[self._productionlvl]
	local cfg2 = cfg[self._productionlvl]
	if self._productionlvl < #cfg then
		cfg2 = cfg[self._productionlvl+1]
		exp_text:show()
	exp_text:setText(self._productionexp.."/"..cfg2.exp_count)
		expprocess:setPercent(self._productionexp/cfg2.exp_count*100)
		self._layout.vars.maxIcon:hide()
	else
		exp_text:hide()
		self._layout.vars.maxIcon:show()
		expprocess:setPercent(100)
	end
	lvlinfo:setText("生产等级"..cfg1.level)
	lvlinfodetail:setText(cfg1.lvl_name)

end

function wnd_faction_production:setSeperationData()
	self.scrollS:hide()
	self.seperationpanel:hide()
	self._seperation = self:getSeperationItems()
	self._layout.vars.nofenjietips:setVisible(next(self._seperation) == nil)

	if not self._sid then
		if #self._seperation > 0 then
			self._sid = 1
		else
			self._sid = 0
		end
	end


	if self._sid ~= 0 then

		local allBars = self.scrollS:addChildWithCount(LAYER_ZMSCT4, 5, #self._seperation)
		for index, bar in ipairs(allBars) do
			self:setSeperationItemDetail(index,bar)
		end
		local selecticon = require(LAYER_ZMSCT3)()
		if allBars[self._sid] then
			local pos = allBars[self._sid].rootVar:getPositionInScroll(self.scrollS)
			local size = allBars[self._sid].rootVar:getSizeInScroll(self.scrollS)
			selecticon.rootVar:setPositionInScroll(self.scrollS,pos.x,pos.y+4)
			contentSize = selecticon.rootVar:getContentSize()
			local prop = size.width/contentSize.width
			selecticon.rootVar:setSizeInScroll(self.scrollS, contentSize.width*prop, contentSize.height*prop)
			self.scrollS:addChild(selecticon)
			self.scrollS:show()
		end
	else
		self:setSeperationExportData()
	end
end
--筛选满足条件的可分解装备
function wnd_faction_production:getSeperationItems()
	local bagsize,baginfo = g_i3k_game_context:GetBagInfo()
	local userCfg = g_i3k_game_context:GetUserCfg()
	local isHideCanSell = userCfg:GetFenJie("fenjie_hide_can_sell")
	local isHideHighPower = userCfg:GetFenJie("fenjie_hide_high_power")
	local isShowPurple = userCfg:GetFenJie("fenjie_show_purple")
	local isShowOrange = userCfg:GetFenJie("fenjie_show_orange")
	local _seperation = {}
	local recordPower = {}
	for k,v in pairs(baginfo) do
		while true do--use for continue
			if g_i3k_db.i3k_db_get_common_item_type(v.id) == g_COMMON_ITEM_TYPE_EQUIP then
				local cfg = g_i3k_db.i3k_db_get_equip_item_cfg(v.id)
				if cfg then
					if cfg.CanSeparation == 1 then
						if not isShowOrange and cfg.rank == 5 then break end--不显示橙装
						if not isShowPurple and cfg.rank == 4 then break end--不显示紫装
						if isHideCanSell and cfg.canSale == 1 and v.id < 0 then break end--隐藏可寄售
																			--隐藏高战力在下面
						---------进行装备优先级计算-------装备排序按照品质＞需求等级>是否己职业排序，其中品质低的排在前面
						local order = 0
						if cfg.rank then
							order = order + cfg.rank*10000
						end
						if cfg.levelReq then
							order = order + cfg.levelReq*100
						end
						local isCurRoleType = false --是否是本职业的
						local logic = i3k_game_get_logic();
						if logic then
							local player = logic:GetPlayer();
							if player and player:GetHero() then
								local hero = player:GetHero();
								if hero._cfg.id == cfg.roleType then
									isCurRoleType = true
									order = order + 10
								end
							end
						end
						for k1,v1 in pairs(v.equips) do
							local guid = v1.guid
							local equip = g_i3k_game_context:GetBagEquip(v.id, guid)
							local equipPower = g_i3k_game_context:GetBagEquipPower(equip.equip_id, equip.attribute, equip.naijiu, equip.refine, equip.legends, equip.smeltingProps)
							if isHideHighPower and isCurRoleType then
								if not recordPower[cfg.partID] then
									local wearEquip = g_i3k_game_context:GetWearEquips()[cfg.partID]
									if wearEquip and wearEquip.equip then
										local eq = wearEquip.equip
										local base_power = g_i3k_game_context:GetBagEquipPower(eq.equip_id, eq.attribute, eq.naijiu, eq.refine, eq.legends, eq.smeltingProps)
										recordPower[cfg.partID] = base_power
									else
										recordPower[cfg.partID] = 0
									end
								end
								if equipPower < recordPower[cfg.partID] then--隐藏高于穿戴战力
									local equipInfo = { guid = guid , id = v.id ,iconID = cfg.icon ,grade = cfg.rank , name = cfg.name , order = order ,SeparationCost = cfg.SeparationCost, SeparationItem = cfg.SeparationItem, partID = cfg.partID, ItemRoleType = cfg.roleType , M_require = cfg.M_require == 0 or cfg.M_require == g_i3k_game_context:GetTransformBWtype()}
									table.insert(_seperation,equipInfo)
								end
							else
								local equipInfo = { guid = guid , id = v.id ,iconID = cfg.icon ,grade = cfg.rank , name = cfg.name , order = order ,SeparationCost = cfg.SeparationCost, SeparationItem = cfg.SeparationItem, partID = cfg.partID, ItemRoleType = cfg.roleType , M_require = cfg.M_require == 0 or cfg.M_require == g_i3k_game_context:GetTransformBWtype()}
								table.insert(_seperation,equipInfo)
							end
						end
					end
				end
			end
			break
		end
	end
	if #_seperation > 0 then
		local exp = SelectExp[1];
		exp(_seperation);
	end
	return _seperation
end

function wnd_faction_production:setSeperationItemDetail(index,bar)
	local bt = bar.vars.bt
	local grade_icon = bar.vars.grade_icon
	local item_icon = bar.vars.item_icon
	local item_count = bar.vars.item_count
	local item_lock = bar.vars.item_lock
	item_count:hide()
	item_lock:hide()
	bar.vars.hideimg:hide()
	if self._sid == index then
		self:setSeperationExportData()
	end
	item_icon:setImage(i3k_db.i3k_db_get_common_item_icon_path(self._seperation[index].id,i3k_game_context:IsFemaleRole()))
	if self._seperation[index].id > 0 then
		item_lock:show()
	end
	grade_icon:setImage(i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self._seperation[index].id))
	bt:setTag(index)
	bt:onClick(self,self.onSeperationSelect,{id = self._seperation[index].id, guid = self._seperation[index].guid})
	if self._seperation[index].M_require then
		self:setUpIsShow(self._seperation[index].id,self._seperation[index].guid,bar.vars)
	else
		bar.vars.hideimg:show()
	end
end

function wnd_faction_production:setUpIsShow(id, guid, widget)
	if g_i3k_db.i3k_db_get_common_item_type(id) == g_COMMON_ITEM_TYPE_EQUIP then
		local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(id)
		if g_i3k_game_context:GetRoleType() == equip_cfg.roleType or equip_cfg.roleType == 0 then
			local equip = g_i3k_game_context:GetBagEquip(id, guid)
			local wearEquips = g_i3k_game_context:GetWearEquips()
			local _data = wearEquips[equip_cfg.partID].equip
			if _data then
				local wAttribute = _data.attribute
				local wNaijiu = _data.naijiu
				local wEquip_id = _data.equip_id
				local wPower = g_i3k_game_context:GetBagEquipPower(wEquip_id,wAttribute,wNaijiu, _data.refine,_data.legends)
				local total_power = g_i3k_game_context:GetBagEquipPower(id,equip.attribute,equip.naijiu,equip.refine,equip.legends)
				widget.is_up:show()
				if wPower > total_power then
					widget.is_up:setImage(g_i3k_db.i3k_db_get_icon_path(175))
				elseif wPower < total_power then
					widget.is_up:setImage(g_i3k_db.i3k_db_get_icon_path(174))
				else
					widget.is_up:hide()
				end
			else
				widget.is_up:show()
				widget.is_up:setImage(g_i3k_db.i3k_db_get_icon_path(174))
			end

		end
	end
end

function wnd_faction_production:updateSeperationLayer()

	self:setSeperationExportData()

end

function wnd_faction_production:setSeperationExportData()
	if not self._sid then
		return
	end
	self.seperationitemname:setText("分解目标")
	self.seperationiteminfo:hide()
	self.powercosttext:hide()
	self.SeperationIcon:hide()
	self.seperationnamepanel:hide()
	-- self.Seperationrank:setImage(g_i3k_get_icon_frame_path_by_rank(0))
	self.Seperation_start:disableWithChildren()
	self.SeperationStartAll:disableWithChildren()
	-- self.SeperationSuo:hide()
	local widgets = self._layout.vars
	for i, v in pairs(self.export) do
		v.exportbtn:enable()
		v.exporticon:hide()
		v.exportcounttext:hide()
		v.suo:hide()
		v.Seperationexport:setImage(g_i3k_get_icon_frame_path_by_rank(0))
	end
	widgets.needCostTxt:hide()
	if self._sid > 0 then
		local seperationItem = self._seperation[self._sid]
		if seperationItem then
			if seperationItem.iconID then
				-- if seperationItem.id > 0 then
				-- 	self.SeperationSuo:show()
				-- else
				-- 	self.SeperationSuo:hide()
				-- end
				self.SeperationIcon:show()
				self.SeperationIcon:setImage(g_i3k_db.i3k_db_get_icon_path(seperationItem.iconID))
			end
			-- self.Seperationrank:setImage(g_i3k_get_icon_frame_path_by_rank(seperationItem.grade))
			local equip = g_i3k_game_context:GetBagEquip(seperationItem.id, seperationItem.guid)
			if equip then
				-- self.seperationtips:hide()
				self:setEquipInfo(seperationItem,equip)
			end
			self.powercosttext:show()
			self.powercosttext:setText(seperationItem.SeparationCost)
			widgets.needCostTxt:show()
			--消耗能量判定
			if seperationItem.SeparationCost <= self._sperationpower then
				self.Seperation_start:enableWithChildren()
				self.SeperationStartAll:enableWithChildren()
				self.powercosttext:setTextColor(g_i3k_get_green_color())
				self._is_fenjie_ok = true
			else
				self.powercosttext:setTextColor(g_i3k_get_red_color())
			end
			self._need_cell_count = 0
			if seperationItem.SeparationItem then
				for k,v in ipairs(seperationItem.SeparationItem) do
					if v.ItemID ~= 0 then
						self._need_cell_count = k
						self.export[k].exportbtn:setTag(k)
						self.export[k].exportbtn:enable()
						self.export[k].exporticon:show()
						self.export[k].exportbtn:onTouchEvent(self,self.onSepItemdetail)
						local Costrank = g_i3k_db.i3k_db_get_common_item_rank(v.ItemID)
						self.export[k].Seperationexport:setImage(g_i3k_get_icon_frame_path_by_rank(Costrank))
						self.export[k].exporticon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.ItemID,i3k_game_context:IsFemaleRole()))
						self.export[k].suo:setVisible(v.ItemID > 0)
						if v.ItemCount > 1 then
							self.export[k].exportcounttext:show()
							self.export[k].exportcounttext:setText(v.ItemCount)
						end
					end
					end
				end
			end
		end
	for k,v in ipairs(self.toggles) do
		v:enable()
	end
end

function wnd_faction_production:setEquipInfo(seperationItem,equip)
	-- self.seperationtips:hide()
	self.seperationiteminfo:hide()
	self.seperationnamepanel:show()
	local equipcfg =  g_i3k_db.i3k_db_get_equip_item_cfg(equip.equip_id)
	self.seperationitemname:setText(seperationItem.name)
	self.seperationitemlvl:setText("等级"..equipcfg.levelReq)
	self._seperationpower = g_i3k_game_context:GetBagEquipPower(equip.equip_id,equip.attribute,equip.naijiu,equip.refine,equip.legends, equip.smeltingProps)
	self._seperationpower = math.modf(self._seperationpower)
	self.seperationitempower:setText(self._seperationpower)
	self._current_equip_id = equip.equip_id
	self.seperationitemC:setText(TYPE_SERIES_NAME[equipcfg.roleType])
	local limit = ""
	if equipcfg.C_require ~= 0 then
		limit = limit..ItemRole_Clist[equipcfg.C_require]
	end
	if equipcfg.M_require ~= 0 then
		limit = limit..ItemRole_Mlist[equipcfg.M_require]
	end
	self.seperationitemM:setText(limit)

end

function wnd_faction_production:onSeperationSelect(sender,args)
	if self.sid ~= sender:getTag() then
		self._sid = sender:getTag()
		self:cancelCheck()
		self:setSeperationData()
		g_i3k_ui_mgr:ShowCommonEquipInfo(g_i3k_game_context:GetBagEquip(args.id, args.guid))
	end
end

function wnd_faction_production:onSepItemdetail(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self:cancelCheck()
		local seperationItem = self._seperation[self._sid]
		if seperationItem.SeparationItem then
			local seperationItem = seperationItem.SeparationItem[sender:getTag()]
			g_i3k_ui_mgr:ShowCommonItemInfo(seperationItem.ItemID)
		end
	end
end

function wnd_faction_production:onProItemdetail(sender, itemId)
	self:cancelCheck()
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_faction_production:onEnergyaddbtn(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		--TODO 能量购买
		self:cancelCheck()
		local maxpower = i3k_db_clan_separation.create_power

		local fun = (function(ok)
				if ok then
					--local buy = i3k_sbean.arena_buytimes_req.new()
					--i3k_sbean.clan_splitSPBuy(self._timeBuyed+1)
					i3k_sbean.produce_by_split(self._timeBuyed+1)
				end

			end)

		--local data = g_i3k_game_context:getClanDetailData()
		self._timeBuyed = g_i3k_game_context:GetProdunctionTImes()

		local buyTimeCfg = i3k_db_clan_separation.buy_count
		if buyTimeCfg == self._timeBuyed then
			self._isNeedChallenge = true
		end
		local needDiamond
		if self._timeBuyed+1 <= #i3k_db_clan_separation.cost_money then
			needDiamond = i3k_db_clan_separation.cost_money[self._timeBuyed+1]
		else
			needDiamond = i3k_db_clan_separation.cost_money[#i3k_db_clan_separation.cost_money]
		end
		local cost_power = i3k_db_clan_separation.cost_power
		if self._isNeedChallenge then
			g_i3k_ui_mgr:PopupTipMessage("今日能量购买次数已经全部用完")
		elseif self._sperationpower >= i3k_db_clan_separation.create_power then
			g_i3k_ui_mgr:PopupTipMessage("能量已超过最大值，请使用后再购买")
		else
			local descText = string.format("是否花费<c=green>%d绑定元宝</c>购买%d分解能量\n今日还可购买%d次", needDiamond,cost_power ,buyTimeCfg-(self._timeBuyed))
			g_i3k_ui_mgr:ShowMessageBox2(descText,fun)
		end
	end
end

function wnd_faction_production:onSeperationStart(sender,state)
	local all_count = g_i3k_game_context:GetBagSize()
	local use_count = g_i3k_game_context:GetBagUseCell()
	if all_count - use_count  >= self._need_cell_count - 1 then
		local textId = g_i3k_db.i3k_db_get_equip_item_cfg(self._current_equip_id).resolveTips
		if textId > 0 then
			local callback = (function(ok)
				if ok then
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production, "seperationCheck")
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(textId), callback)
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production, "seperationCheck")
		end
		self._is_fenjie_ok = false
		if state and state == 1 then
			self._is_fenjie_all = false
		end
	else
		self._is_fenjie_all = false
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足，无法分解此物品")
	end

end

function wnd_faction_production:onSeperationStartAll(sender)
	self._is_fenjie_all = true
	local all_count = g_i3k_game_context:GetBagSize()
	local use_count = g_i3k_game_context:GetBagUseCell()
	if all_count - use_count >= self._need_cell_count - 1 then
		local textId = g_i3k_db.i3k_db_get_equip_item_cfg(self._current_equip_id).resolveTips
		if textId > 0 then
			local callback = (function(ok)
				if ok then
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production, "seperationCheck")
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(textId), callback)
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production, "seperationCheck")
		end
		self._is_fenjie_ok = false
	else
		self._is_fenjie_all = false
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足，无法分解此物品")
	end

end

function wnd_faction_production:seperationCheck()
	local DirectStart = self:seperationPowerCheck()
	if DirectStart then
		self:seperationStart()
	end
end

function wnd_faction_production:seperationPowerCheck()
	if not self._sid or not self._seperation[self._sid] then
		return true
	end
	local partID = self._seperation[self._sid].partID
	local wequips = g_i3k_game_context:GetWearEquips()
	if wequips then
		local Equip =  wequips[partID];
		local fun = (function(ok)
			if ok then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production, "seperationStart")
			end
		end)
		local wearpower
		if Equip and Equip.equip then
			wearpower = g_i3k_game_context:GetBagEquipPower(Equip.equip.equip_id,Equip.equip.attribute,Equip.equip.naijiu,Equip.equip.refine,Equip.equip.legends, Equip.equip.smeltingProps)
		else
			wearpower = 0
		end			
			wearpower = math.modf(wearpower)
			if self._seperation[self._sid].M_require and self._seperationpower > wearpower then
				local logic = i3k_game_get_logic();
				if logic then
					local player = logic:GetPlayer();
					if player and player:GetHero() then
						local hero = player:GetHero();
						if hero._cfg.id == self._seperation[self._sid].ItemRoleType then
							local descText = "你即将分解一个可能优于你穿戴装备的装备，是否确定分解？"
							g_i3k_ui_mgr:ShowMessageBox2(descText,fun)
							return false
						end
					end
				end
			end
		
	end
	return true
end

function wnd_faction_production:seperationStart()
	self._sendtype = 2
	
	local seperation_cancel = self._layout.vars.seperation_cancel
	for k,v in pairs(self.export) do
		v.exportbtn:disable()
	end
	for k,v in ipairs(self.toggles) do
		v:disable()
	end
	seperation_cancel:onTouchEvent(self,self.onSeperationCancel)
	self.scrollS:hide()
	self.seperationpanel:show()
	self._timer = 0.01
	self.Seperation_start:hide()
	self.SeperationStartAll:hide()
end

function  wnd_faction_production:seperationSuccess()
	self._sid = nil;
	self:setTitleAttribute()
	self:setSeperationData()
	if not self._is_fenjie_ok then
		self._is_fenjie_all = false
	end
	if self._is_fenjie_ok and self._is_fenjie_all and self._sid and self._sid~= 0 then
		self:onSeperationStart()
	end
end

function  wnd_faction_production:productionSuccess(state)
	self._is_produnct_ok = false
	self:setTitleAttribute()
	if state then
		self:setProductionData()
	end
	self:setProductionLevel3()
	self:setProductionAttribute()
	if not self._is_produnct_ok then
		self._is_produnction_all = false
	end
	if self._is_produnct_ok  and self._is_produnction_all then
		self:onProductionStart()
	end
end
function wnd_faction_production:onUpdate(dTime)
	if self._timer ~= 0 then
		self._timer = self._timer + dTime
		local vipLv1= g_i3k_game_context:GetVipLevel()
		local timeLimit = i3k_db_kungfu_vip[vipLv1].resolveTime
		if self._sendtype == 1 then
			local producitonprogress = self._layout.vars.producitonprogress
			producitonprogress:setPercent(self._timer/timeLimit*100)
			if self._timer > timeLimit then
				self._timer = 0;
				self._sendtype = 0;
				self.productionpropanel:hide()
				--i3k_sbean.clan_produce(self._clanID,self._productionID)
				i3k_sbean.produnce_create(self._productionID,self._id)
			end
			--i3k_log("Send")
		elseif self._sendtype == 2 then
			local seperationprocess = self._layout.vars.seperationprocess
			seperationprocess:setPercent(self._timer/timeLimit*100)
			if self._timer > timeLimit then
				self._timer = 0;
				self._sendtype = 0;
				self.scrollS:show()
				self.seperationpanel:hide()
				self.SeperationStartAll:show()
				self.Seperation_start:show()
				--i3k_sbean.clan_split(self._clanID,self._seperation[self._sid].guid,self._seperation[self._sid].id)
				if self._sid and self._seperation[self._sid] then
					i3k_sbean.produce_fenjie(self._seperation[self._sid].id,self._seperation[self._sid].guid)
				end
			end
			--i3k_log("Send")
		end
	end
end

----------------------------装备精炼的数据----------------------------------------

function wnd_faction_production:updateRefinebtn()
	self.weaponBtn:stateToNormal(true)
	self.clothesBtn:stateToNormal(true)
	self.headBtn:stateToNormal(true)
	self.handBtn:stateToNormal(true)
	self.shoesBtn:stateToNormal(true)
	self.ringBtn:stateToNormal(true)
end

function wnd_faction_production:onEquip(sender,equipType)
	self:updateRefinebtn()
	self._current_equip_equip_type = equipType
	if equipType == eEquipWeapon then
		self.weaponBtn:stateToPressed(true)
	elseif equipType == eEquipHand then
		self.handBtn:stateToPressed(true)
	elseif equipType == eEquipClothes then
		self.clothesBtn:stateToPressed(true)
	elseif equipType == eEquipShoes then
		self.shoesBtn:stateToPressed(true)
	elseif equipType == eEquipHead then
		self.headBtn:stateToPressed(true)
	elseif equipType == eEquipRing then
		self.ringBtn:stateToPressed(true)
	end

	local equips = self:getEquipsByType(equipType)

	self:updateEquipsList(equips,equipType)
	self._current_equip_equip_index = 1
end

function wnd_faction_production:getBagEquips()
	local temp = {}
	local bagSize, bagItems = g_i3k_game_context:GetBagInfo()
	for k, v in pairs(bagItems) do
		if g_i3k_db.i3k_db_get_common_item_type(k) == g_COMMON_ITEM_TYPE_EQUIP then
			if next(v.equips) then
				for a, b in pairs(v.equips) do
					table.insert(temp, {id = k, guid = a,refine= b.refine})
				end
			end
		end
	end
	return temp
end

function wnd_faction_production:getEquipsByType(equipType)
	local wearEquips = g_i3k_game_context:GetWearEquips()
	local equips = self:getBagEquips()

	local tmp_equips = {}

	table.insert(tmp_equips,tmp)
	for k,v in ipairs(equips) do
		local equipcfg = g_i3k_db.i3k_db_get_equip_item_cfg(v.id)
		if equipcfg.partID == equipType then
			local tmp = {id = v.id,guid = v.guid,refine= v.refine}
			table.insert(tmp_equips,tmp)
		end

	end
	table.sort(tmp_equips,function (a,b)
		local aCfg =  g_i3k_db.i3k_db_get_equip_item_cfg(a.id)
		local bCfg =  g_i3k_db.i3k_db_get_equip_item_cfg(b.id)
		return aCfg.sortid < bCfg.sortid
	end)
	if wearEquips[equipType] and wearEquips[equipType].equip then
		local tmp = {id = wearEquips[equipType].equip.equip_id,guid = wearEquips[equipType].equip.equip_guid, refine = wearEquips[equipType].equip.refine}
		table.insert(tmp_equips,1,tmp)
	end
	return tmp_equips
end

function wnd_faction_production:getCurEquipsByType(id,equipType)
	local equips = self:getEquipsByType(equipType)
	for k,v in pairs(equips) do
		if v.id == id then
			return v
		end
	end
end

function wnd_faction_production:updateEquipListSuo(id,guid)

	local allBars = self.equipScroll:getAllChildren()
	for i,bar in ipairs(allBars) do
		local suo = bar.vars.suo
		local production_btn = bar.vars.productionbtn
		if i == self._current_equip_equip_index then
			suo:setVisible(true)
			production_btn:onClick(self,self.onSelectEquip,{id =-id,guid = guid,equipType = self._current_equip_equip_type,index = i })
			self.equipBg:onClick(self,self.onRefineEquipInfo,{id = -id,guid = equipGuid})
			self._current_equip_id = -self._current_equip_id
			break
		end
	end
end

--左侧列表更新
function wnd_faction_production:updateEquipsList(equips,equipType)
	self.equipScroll:removeAllChildren()

	self.equipScroll:addItemAndChild(LAYER_ZMSCT2, 1, #equips)

	local allBars = self.equipScroll:getAllChildren()
	local wearEquips = g_i3k_game_context:GetWearEquips()
	for i,bar in ipairs(allBars) do
		local ItemName = g_i3k_db.i3k_db_get_common_item_name(equips[i].id)
		local ItemRank = g_i3k_db.i3k_db_get_common_item_rank(equips[i].id)
		local ItemIcon = g_i3k_db.i3k_db_get_common_item_icon_path(equips[i].id,i3k_game_context:IsFemaleRole())
		local production_icon = bar.vars.productionicon
		local production_name = bar.vars.productionName
		local production_lvl = bar.vars.productionlvl
		local production_exp = bar.vars.productionexp
		local production_warn = bar.vars.productionwarn
		local production_btn = bar.vars.productionbtn
		local suo = bar.vars.suo
		local productionselect = bar.vars.productionselect
		local productionselectbg = bar.vars.productionselectbg
		local productionrank = bar.vars.productionrank
		local equip = self:getCurEquipsByType(equips[i].id,equipType)
		if equip then
			if ItemRank == 5 then
				bar.vars.sjtx1:setVisible(equip.naijiu ~= -1)
			end
			if ItemRank == 4 then
				bar.vars.sjtx2:setVisible(equip.naijiu ~= -1)
			end
		end
		production_lvl:hide()
		production_exp:hide()
		production_warn:hide()
		productionselect:hide()
		production_name:setText(ItemName)
		productionrank:setImage(g_i3k_get_icon_frame_path_by_rank(ItemRank))
		production_icon:setImage(ItemIcon)
		production_name:setTextColor(g_i3k_get_color_by_rank(ItemRank))
		production_btn:onClick(self,self.onSelectEquip,{id =equips[i].id,guid = equips[i].guid,equipType = equipType,index = i,refine=equips[i].refine })
		productionselectbg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBglist[1]))
		suo:setVisible(equips[i].id > 0)
		if i == 1 then

			if wearEquips[equipType] and wearEquips[equipType].equip and wearEquips[equipType].equip.equip_id == equips[i].id and wearEquips[equipType].equip.equip_guid == equips[i].guid then
				production_warn:show()
				production_warn:setText("装备中")
			end
			self._current_equip_id = equips[i].id
			self._current_equip_guid = equips[i].guid
			self._current_equip_refine = equips[i].refine
			productionselect:show()
			productionselectbg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBglist[2]))
			self:updateOneEquipData(equips[i].id,equips[i].guid,equipType)

		end
	end
end

function wnd_faction_production:onSelectEquip(sender,args)
	if self._current_equip_id == args.id and self._current_equip_guid == args.guid then
		return
	end
	self._current_equip_id = args.id
	self._current_equip_guid = args.guid
	self._current_equip_refine = args.refine
	self._current_equip_equip_index = args.index
	self:updateOneEquipData(args.id,args.guid,args.equipType)
	local allBars = self.equipScroll:getAllChildren()
	for i,bar in ipairs(allBars) do
		local productionselect = bar.vars.productionselect
		local productionselectbg = bar.vars.productionselectbg
		if i == args.index then
			productionselectbg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBglist[2]))
			productionselect:show()
		else
			productionselectbg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBglist[1]))
			productionselect:hide()
		end

	end
end

function wnd_faction_production:getOneEquipRefine(id ,guid,equipType)
	local wearEquips = g_i3k_game_context:GetWearEquips()
	local equips = self:getBagEquips()
	if wearEquips[equipType] and wearEquips[equipType].equip and wearEquips[equipType].equip.equip_id == id and wearEquips[equipType].equip.equip_guid == guid then
		self._current_equip_pos = equipType
		return {refine = wearEquips[equipType].equip.refine}
	else
		self._current_equip_pos = 0
		return g_i3k_game_context:GetBagEquip(id,guid)
	end
end

function wnd_faction_production:updateOneEquipData(equipId,equipGuid,equipType)
	local equipcfg =  g_i3k_db.i3k_db_get_equip_item_cfg(equipId)
	local ItemName = g_i3k_db.i3k_db_get_common_item_name(equipId)
	local ItemRank = g_i3k_db.i3k_db_get_common_item_rank(equipId)
	local ItemIcon = g_i3k_db.i3k_db_get_common_item_icon_path(equipId,i3k_game_context:IsFemaleRole())
	self.equipBg:setImage(g_i3k_get_icon_frame_path_by_rank(ItemRank))
	self.sjtx1:setVisible(false)
	self.sjtx2:setVisible(false)
	local equip = self:getCurEquipsByType(equipId,equipType)
	if equip then
		if ItemRank == 5 then
			self.sjtx1:setVisible(equip.naijiu ~= -1)
		end
		if ItemRank == 4 then
			self.sjtx2:setVisible(equip.naijiu ~= -1)
		end
	end
	self.equipIcon:setImage(ItemIcon)
	self.equipName:setText(ItemName)
	self.equipName:setTextColor(g_i3k_get_color_by_rank(ItemRank))
	self.equipLvl:setText(string.format("等级%s",equipcfg.levelReq))
	local ItemRoleType = equipcfg.roleType
	local ItemCType = equipcfg.C_require
	local ItemMType = equipcfg.M_require
	if ItemRoleType then
		local limit = "限定:"
		if ItemRoleType ~= 0 then
			limit = limit..TYPE_SERIES_NAME[ItemRoleType]
		end
		if ItemCType ~= 0 then
			limit = limit..ItemRole_Clist[ItemCType]
		end
		if ItemMType ~= 0 then
			limit = limit..ItemRole_Mlist[ItemMType]
		end
		if ItemMType ~= 0 or ItemCType ~= 0 or ItemRoleType ~= 0 then
			limit = limit.."职业"
			self.equipJob:setText(limit)
		end
	end

	local refineData = self:getOneEquipRefine(equipId,equipGuid,equipType)
	self:updateOneEquipRefineItems(equipId)
	self:updateEquipProperty(refineData.refine,equipcfg.levelReq)
	-- g_i3k_ui_mgr:InvokeUIFunction(eUIID_RefineTip,"onRefineEquip",)

	if self._current_equip_pos == 0 then
		self.equipBg:onClick(self,self.onRefineEquipInfo,{id = equipId,guid = equipGuid})


	else
		local wearEquips = g_i3k_game_context:GetWearEquips()
		self.equipBg:onClick(self,self.onRefineEquipInfoOther,{equip = wearEquips[self._current_equip_pos].equip})
		--self.equipBg:onClick(self,self.onRefineEquipInfoOther,{id = equipId,guid = equipGuid})

	end
end

function wnd_faction_production:updateEquipProperty(refine,equipLvl)
	self._current_equip_refine = refine
	table.sort(refine,function (a,b)
		if a.id == b. id then
			return a.value > b.value
		else
			return a.id < b.id
		end
	end)
	self._curren_equip_is_have_refine = false
	self.refineItemDesc:hide()
	for i,v in ipairs(self._refine_property) do
		v.property:hide()
		v.propertyValue:hide()
		v.maxImg:hide()
		if refine[i] then
			-- local lvlSection = i3k_db_prop_id[refine[i].id].lvlSection
			-- local argsSection = i3k_db_prop_id[refine[i].id].argsSection
			-- local proSection = i3k_db_prop_id[refine[i].id].proSection
			-- local index = 1
			-- for a,b in ipairs(lvlSection) do
			-- 	if b > equipLvl then
			-- 		index = a
			-- 		break
			-- 	end
			-- end
			-- 精炼属性颜色改变
			-- local agrs = argsSection[index]
			-- local needColour = 1
			-- for a,b in ipairs(proSection) do
			-- 	if b*agrs >= refine[i].value then
			-- 		needColour = a
			-- 		break
			-- 	end
			-- end

			v.property:setText(i3k_db_prop_id[refine[i].id].desc)
			local isShowMax = self:maxRefineShow(refine[i].value,refine[i].id)
			v.maxImg:setVisible(isShowMax)
			v.propertyValue:setText("+"..i3k_get_prop_show(refine[i].id, refine[i].value))
			v.property:show()
			v.propertyValue:show()
			--v.property:setTextColor(g_i3k_get_color_by_rank(needColour))
			--v.propertyValue:setTextColor(g_i3k_get_color_by_rank(needColour))
			self._curren_equip_is_have_refine = true
		end
	end
	local equipPower = 0
	if self._current_equip_pos == 0 then
		local equip = g_i3k_game_context:GetBagEquip(self._current_equip_id,self._current_equip_guid)
		if equip then
			equipPower = g_i3k_game_context:GetBagEquipPower(self._current_equip_id,equip.attribute,equip.naijiu,equip.refine,equip.legends, equip.smeltingProps)
		end
	else
		local wearEquips = g_i3k_game_context:GetWearEquips()
		local _data = wearEquips[self._current_equip_pos].equip
		local wAttribute = _data.attribute
		local wNaijiu = _data.naijiu
		local wEquip_id = _data.equip_id
		equipPower = g_i3k_game_context:GetBagEquipPower(wEquip_id,wAttribute,wNaijiu, _data.refine, _data.legends, _data.smeltingProps)
	end
	self.equipPower:setText(string.format("战力：%s",equipPower))
	self:updateRefineItemDesc(self._current_equip_item)
end
function wnd_faction_production:maxRefineShow(powerNum,itemId)
	local refineItem = g_i3k_db.i3k_db_get_equip_item_cfg(self._current_equip_id).refineAllItems --使用的精炼道具列表
	local powerTime = nil --属性最大值
	local mutiArgs1 = nil --等级区分
	local mutiArgs2 = nil --属性系数
	local index = 1
	for i,v in ipairs(refineItem) do --精炼道具遍历
		local gid = g_i3k_db.i3k_db_get_other_item_cfg(v).args1 --组id
		for a,b in ipairs(i3k_db_equip_refine[gid]) do --遍历装备精炼表的组内情况通过组id
			if itemId == b.propID then --取到的功能id是否等于遍历组id得到的功能id
				if not powerTime then --判断属性是否为最大值
					powerTime = b.propUp
					mutiArgs1 = b.mutiArgs1
					mutiArgs2 = b.mutiArgs2
				elseif powerTime < b.propUp then
					powerTime = b.propUp
					mutiArgs1 = b.mutiArgs1
					mutiArgs2 = b.mutiArgs2
				else
				end
			end
		end
	end
	if not mutiArgs1 or not mutiArgs2 then
		return
	end
	for i,v in ipairs(mutiArgs1) do
		if not (g_i3k_db.i3k_db_get_equip_item_cfg(self._current_equip_id).levelReq > v) then
			index = i
			break
		end
	end
	mutiArgs2 = mutiArgs2[index]
	if powerNum >= powerTime * mutiArgs2 then
		return true
	else
		return false
	end
end
function wnd_faction_production:updateRefineItemDesc(ItemId)
	local cfg = g_i3k_db.i3k_db_get_common_item_cfg(ItemId)
	if cfg and not self._curren_equip_is_have_refine then
		local tmp_str = string.format("附加%s条精炼属性",cfg.args2)
		self.refineItemDesc:setText(tmp_str)
		self.refineItemDesc:show()
	end
end

function wnd_faction_production:getEquipRefineItemByType(equipId)
	local equipcfg =  g_i3k_db.i3k_db_get_equip_item_cfg(equipId)
	local tmp_items = {}
	local index= 0
	for i,v in ipairs(equipcfg.refineAllItems) do
		local freeItemCount = g_i3k_game_context:GetCommonItemCount(-v)
		local itemCount = g_i3k_game_context:GetCommonItemCount(v)
		local sortIdF = 0
		if freeItemCount ~= 0 then
			sortIdF = sortIdF + 1
		end
		local sortId = 0
		if itemCount ~= 0 then
			sortId = sortId + 1
		end
		local item1 = {id = -v,count = freeItemCount,sort1 = sortIdF,sort2 = g_i3k_db.i3k_db_get_common_item_rank(v),sort3 = math.abs(v)}
		local item2 = {id = v,count = itemCount,sort1 = sortId,sort2 = g_i3k_db.i3k_db_get_common_item_rank(v),sort3 = math.abs(v)}
		if freeItemCount == 0 and itemCount == 0 then
			table.insert(tmp_items,item1)
		else
			if freeItemCount > 0 then
				table.insert(tmp_items,item1)
			end
			if itemCount > 0 then
				table.insert(tmp_items,item2)
			end
		end
	end
	table.sort(tmp_items,function (a,b)
		if a.sort1 == b.sort1 then
			if a.sort2 == b.sort2 then
				return a.sort3 < b.sort3
			else
				return a.sort2 > b.sort2
			end
		else
			return a.sort1 > b.sort1
		end
	end)

	return tmp_items,equipcfg.refineItemId,equipcfg.refineItemCount
end

function wnd_faction_production:updateOneEquipRefineItems(equipId)
	self.itemTitle:setText("可以用下列任一种道具")


	self.itemScroll:removeAllChildren()

	local items,specilItemId,specilItemCount = self:getEquipRefineItemByType(equipId)

	self.itemScroll:addItemAndChild(LAYER_ZMSCFMT, RowItemCount, #items)
	local allBars = self.itemScroll:getAllChildren()

	for i,v in ipairs(allBars) do
		local tmp_item = items[i]
		if tmp_item.count ~= 0 then
			v.vars.bt:onClick(self,self.onRefineItems,{itemId = tmp_item.id,index = i})
		else
			v.vars.bt:onClick(self,self.onItemInfo,{itemId = tmp_item.id,index = i})
		end
		v.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(tmp_item.id))
		v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(tmp_item.id,i3k_game_context:IsFemaleRole()))
		v.vars.item_count:setText(string.format("×%s",tmp_item.count))
		v.vars.item_count:setVisible(tmp_item.count~= 0)
		v.vars.suo:setVisible(tmp_item.id > 0)
		v.vars.is_select:hide()
		if tmp_item.count == 0 then
			v.vars.grade_icon:disableWithChildren()
		end
		if i == 1 then
			v.vars.is_select:show()
			self._current_equip_item = tmp_item.id
			self:updateRefineMainBtn()
		end
	end
	self.refineItemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(specilItemId,i3k_game_context:IsFemaleRole()))
	self.refineItemIconSuo:setVisible(false)
	self.refineItemCount:setText(specilItemCount)
	self:setTitleAttribute()
end
function wnd_faction_production:onRefineEquipUseFreeItem(sender)
	if self._current_equip_free then
		self._current_equip_free = false
	else
		self._current_equip_free = true
	end
	self._current_equip_item = 0
	--self.freeIcon:setVisible(self._current_equip_free)
	self:updateOneEquipRefineItems(self._current_equip_id)
end

function wnd_faction_production:updateRefineItemsCount(equipId)
	local items,specilItemId,specilItemCount = self:getEquipRefineItemByType(equipId)
	local allBars = self.itemScroll:getAllChildren()
	for i,v in ipairs(allBars) do
		local tmp_item = items[i]
		if tmp_item.count == 0 then
			v.vars.bt:onClick(self,self.onItemInfo,{itemId = tmp_item.id,index = i})
			v.vars.is_select:hide()
		else
			v.vars.bt:onClick(self,self.onRefineItems,{itemId = tmp_item.id,index = i})
		end
		v.vars.item_count:setText(string.format("×%s",tmp_item.count))
		v.vars.item_count:setVisible(tmp_item.count~= 0)
	end
end

function wnd_faction_production:onRefineItems(sender,args)
	self._current_equip_item = args.itemId
	self:updateRefineItemDesc(self._current_equip_item)
	local allBars = self.itemScroll:getAllChildren()
	for i,v in ipairs(allBars) do
		v.vars.is_select:setVisible(i == args.index)
	end
	self:updateRefineMainBtn()
end

function wnd_faction_production:onItemInfo(sender,args)
	self._current_equip_item = args.itemId
	self:updateRefineItemDesc(self._current_equip_item)
	g_i3k_ui_mgr:ShowCommonItemInfo(args.itemId)
	local allBars = self.itemScroll:getAllChildren()
	for i,v in ipairs(allBars) do
		v.vars.is_select:setVisible(i == args.index)
	end
	self:updateRefineMainBtn()
end

function wnd_faction_production:updateRefineMainBtn()
	local freeItemCount = g_i3k_game_context:GetCommonItemCount(self._current_equip_item)
	if freeItemCount == 0 then
		self.refineBtn:disableWithChildren()
	else
		self.refineBtn:enableWithChildren()
	end

end
function wnd_faction_production:onRefineEquip(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.refineOpenLvl then
		return g_i3k_ui_mgr:PopupTipMessage(string.format("精炼%d%s",i3k_db_common.functionOpen.refineOpenLvl,"级开启"))
	end
	local equipcfg =  g_i3k_db.i3k_db_get_equip_item_cfg(self._current_equip_id)
	if not equipcfg then
		return
	end
	local itemId = equipcfg.refineItemId
	local itemCount = equipcfg.refineItemCount

	local have_count = g_i3k_game_context:GetCommonItemCanUseCount(itemId)
	if have_count < itemCount then
		return g_i3k_ui_mgr:PopupTipMessage("工坊能量不足")
	end

	if self._current_equip_id < 0 and self._current_equip_item > 0  then
		local fun = (function(ok)
			if ok then
				i3k_sbean.refine_equip(self._current_equip_id,self._current_equip_guid,self._current_equip_pos,self._current_equip_item,self._current_equip_refine,true)
			end
		end)
		g_i3k_ui_mgr:ShowMessageBox2("继续精炼会导致装备绑定，是否继续",fun)
		return
	end
	i3k_sbean.refine_equip(self._current_equip_id,self._current_equip_guid,self._current_equip_pos,self._current_equip_item,self._current_equip_refine)
end

function wnd_faction_production:onRefineEquipInfo(sender,args)
	g_i3k_ui_mgr:ShowCommonEquipInfo(g_i3k_game_context:GetBagEquip(args.id, args.guid))
end

function wnd_faction_production:onRefineEquipInfoOther(sender,args)
	--g_i3k_ui_mgr:OpenUI(eUIID_EquipTips)
	--g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTips, "updateWearEquipInfo", args.equip)
	g_i3k_ui_mgr:ShowCommonEquipInfo(args.equip,true)
end

---------炼化炉
--开启炼化炉
function wnd_faction_production:openRecycleFun()
	self.zhizhao_label:setText("制造")
	self.fenjie_label:setText("分解")

	self.zhizhao_btn:stateToNormal()
	self.fenjie_btn:stateToNormal()
	self.refine_btn:stateToNormal()
	self.zhizhao_panel:hide()
	self.fenjie_panel:hide()
	self.refine_root:hide()
	self.recycle_root:hide()

	self:resetRecycleData()
	self.lianhua_btn:stateToPressed()
	self.recycle_root:show()
	self:setRecycleData()
	self:playStoveFireAni("stand")
end

function wnd_faction_production:resetRecycleData()
	self._is_select_gather = false
	self._can_recycle_items = {}
	self._need_recycle_items = {}
	self._recycle_all_points = 0
	self._need_consume_itemCnt = 0
	self._need_recycle_times = 0
	self._recycle_remain_points = 0
	self._current_select_item = nil
	self._current_select_bar = nil
	self._current_need_recycle_item_num = 0
	self.gather_img:hide()
	self.cost_energy:setText("x"..0)

	self.consume_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(i3k_db_clan_recycle_base_info.recycle_need_itemId))
	self.consume_icon_img:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_clan_recycle_base_info.recycle_need_itemId))
	self.consume_icon_btn:onClick(self, self.onStoveReward, i3k_db_clan_recycle_base_info.recycle_need_itemId)

	self.remain_txt:setText(i3k_get_string(15505, i3k_db_recycle_day_limit.day_limit - g_i3k_game_context:GetRecycledItemCnt()))
end

function wnd_faction_production:setRecycleData()
	self:resetRecycleData()
	self:setStoveReward()
	self:getCanRecycleItems()
	self:setRecycleItemData()
end

--炉子上的道具显示
function wnd_faction_production:setStoveReward()
	local stove_icon = self._layout.vars.stove_icon
	local stove_icon_btn = self._layout.vars.stove_icon_btn
	local stove_item_count = self._layout.vars.stove_item_count
	local suo = self._layout.vars.suo

	local hero_lvl = g_i3k_game_context:GetLevel()
	local stove_item_id = 0
	for i=1,#i3k_db_recycle_lvl_and_drop do
		local min_lvl = i3k_db_recycle_lvl_and_drop[i].level[1]
		local max_lvl = i3k_db_recycle_lvl_and_drop[i].level[2]
		if hero_lvl >= min_lvl and hero_lvl <= max_lvl then
			stove_item_id = i3k_db_recycle_lvl_and_drop[i].stove_item_id
			break
		end
	end
	stove_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(stove_item_id))
	stove_icon_btn:onClick(self,self.onStoveReward,stove_item_id)
	stove_item_count:hide()
	if stove_item_id > 0 then
		suo:show()
	end
end

function wnd_faction_production:getCanRecycleItems()
	local bagsize,baginfo = g_i3k_game_context:GetBagInfo()
	for k,v in pairs(baginfo) do
		if g_i3k_db.i3k_db_get_common_item_type(v.id) == g_COMMON_ITEM_TYPE_ITEM then  --只能炼化道具
			local cfg = g_i3k_db.i3k_db_get_other_item_cfg(v.id)
			if cfg then
				if cfg.isCanRecycle == 1 then
					local itemCount = g_i3k_game_context:GetBagItemCount(v.id)
					local order = 0
					if cfg.rank then
						order = order + cfg.rank*10000000
					end
					order = order + math.abs(v.id)
					local itemInfo = {id = v.id, count = itemCount, order = order, recycleEnergy = cfg.recycleEnergy}
					table.insert(self._can_recycle_items, itemInfo)
				end
			end
		end
	end
end

function wnd_faction_production:setRecycleItemData()
	if #self._can_recycle_items > 0 then
		local exp = SelectExp[1]
		exp(self._can_recycle_items)  --道具排序

		local canRecycleItems = self._can_recycle_items
		self.recycleListView:jumpToListPercent(0)
		local allBars = self.recycleListView:addChildWithCount(LAYER_LIANHUAT, 5, #canRecycleItems)
		for k,v in ipairs(allBars) do
			v.vars.grade_icon:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(canRecycleItems[k].id)))
			v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(canRecycleItems[k].id))
			v.vars.item_count:setText(canRecycleItems[k].count)
			if canRecycleItems[k].id > 0 then
				v.vars.suo:show()
			end
			v.vars.is_select:hide()
			v.vars.bt:setTag(k)
			v.vars.bt:onClick(self,self.onSelectItem,v)
		end
	else
		--25个空的物品格子
		self.recycleListView:jumpToListPercent(0)
		local allBars = self.recycleListView:addChildWithCount(LAYER_LIANHUAT, 5, 25)
		for k,v in ipairs(allBars) do
			v.vars.is_select:hide()
			v.vars.item_count:hide()
		end
	end
	self:setRecycleProgressData()
end

function wnd_faction_production:onSelectItem(sender,bar)
	local index = sender:getTag()
	local itemInfo = self._can_recycle_items[index]
	if itemInfo then
		local item = {}
		item.id = itemInfo.id
		item.count = itemInfo.count
		local isNeedTips = g_i3k_db.i3k_db_get_other_item_cfg(item.id).isNeedTips
		local is_select = bar.vars.is_select:isVisible()
		if not is_select then
			if isNeedTips == 1 then
				local desc = i3k_get_string(15432)
				local fun = (function(ok)
					if ok then
						self:onClickItem(item,bar)
					end
				end)
				g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
			elseif isNeedTips == 0 then
				self:onClickItem(item,bar)
			end
		else
			self:cancleRecycleItem(item,bar)
		end
	end
end

--选中物品
function wnd_faction_production:onClickItem(itemInfo,bar)
	self._current_select_item = itemInfo
	self._current_select_bar = bar

	local count = itemInfo.count
	if self._is_select_gather then
		self:selectRecycleItem()
	else
		if count > 1 then
            self:onItemTips()
		else
			self:selectRecycleItem()
		end
	end
end

--获取物品可炼化的最大数量
function wnd_faction_production:getItemRecycleMaxNum(itemInfo,isTips)
	local item_num = itemInfo.count
	local current_num = self._current_need_recycle_item_num
	local total_num = current_num + item_num

	local recycledItemCnt = g_i3k_game_context:GetRecycledItemCnt()  --日已炼化道具数
	local dayRecycleLimit = i3k_db_recycle_day_limit.day_limit       --日最大可炼化道具数
	self._remainRecycleCnt = dayRecycleLimit - recycledItemCnt       --日剩余可炼化道具数
	local canRecycleItemCnt = self._remainRecycleCnt < once_max_recycle_item and self._remainRecycleCnt or once_max_recycle_item

	if total_num > canRecycleItemCnt then
		item_num = item_num - (total_num - canRecycleItemCnt)
		total_num = canRecycleItemCnt
	end
	if not isTips then
		itemInfo.count = item_num
		self._current_need_recycle_item_num = total_num
	end
	return item_num
end

function wnd_faction_production:selectRecycleItem(currentNum)
	local itemInfo = self._current_select_item
	local bar = self._current_select_bar

	if itemInfo and bar then
		if currentNum ~= nil then
			itemInfo.count = currentNum
		end

		local item_num = self:getItemRecycleMaxNum(itemInfo, false)

		if item_num > 0 then
			bar.vars.is_select:show()
			bar.vars.selected_count:setText(string.format("%s", item_num))
			table.insert(self._need_recycle_items,itemInfo)
			self:setRecycleProgressData()
		else
			if self._remainRecycleCnt < once_max_recycle_item then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15506))
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15507, i3k_db_clan_recycle_base_info.one_max_recycle_item_num))
			end
		end
	end
end

function wnd_faction_production:onItemTips()
	local itemInfo = self._current_select_item
	local bar = self._current_select_bar
	if itemInfo and bar then
		local item_num = self:getItemRecycleMaxNum(itemInfo, true)
		if item_num > 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_UseItems)
			g_i3k_ui_mgr:RefreshUI(eUIID_UseItems, itemInfo.id)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_UseItems,"setRecycleMaxNum",item_num)
		else
			if self._remainRecycleCnt < once_max_recycle_item then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15506))
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15507, i3k_db_clan_recycle_base_info.one_max_recycle_item_num))
			end
		end
	end
end

--取消选中物品
function wnd_faction_production:cancleRecycleItem(itemInfo,bar)
	self._current_select_item = nil
	self._current_select_bar = nil

	bar.vars.is_select:hide()
	for i=#self._need_recycle_items,1,-1 do
		if self._need_recycle_items[i].id == itemInfo.id then
			self._current_need_recycle_item_num = self._current_need_recycle_item_num - self._need_recycle_items[i].count
			table.remove(self._need_recycle_items,i)
			break
		end
	end
	self:setRecycleProgressData()
end

function wnd_faction_production:setRecycleProgressData()
	local recycleProgress = self._layout.vars.expbar
	local recycleProgressCount = self._layout.vars.expbarCount
	local recycleTips = self._layout.vars.barTips
	local recycleProgressBg = self._layout.vars.bar_img

	self._recycle_all_points = g_i3k_game_context:GetRecycleRemainPoint()
	local needRecycleItems = self._need_recycle_items
	for k,v in pairs(needRecycleItems) do
		local recycleEnergy = 0
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(v.id)
		if cfg then
			recycleEnergy = cfg.recycleEnergy
		end
		self._recycle_all_points = self._recycle_all_points + recycleEnergy*v.count
	end

	local progressLimit = i3k_db_clan_recycle_base_info.one_recycle_need_point
	local i,f = math.modf(self._recycle_all_points/progressLimit)
	if i >= 1 then
		self._need_consume_itemCnt = i*i3k_db_clan_recycle_base_info.one_recycle_need_item_num
		self.cost_energy:setText("x"..self._need_consume_itemCnt)
		self._need_recycle_times = i
		recycleTips:setText(i3k_get_string(15458, ""..i))
	else
		self._need_recycle_times = 0
		self._need_consume_itemCnt = 0
		self.cost_energy:setText("x"..0)
		recycleTips:setText(i3k_get_string(15457))
	end

	if not next(self._need_recycle_items) then
		recycleTips:setText(i3k_get_string(15456))
	end

	self:setProgressColor(recycleProgress, recycleProgressBg, f)
	self._recycle_remain_points = self._recycle_all_points - i*progressLimit
	if i >= 1 and f == 0 then  --表示炼化刚好满整数次
		recycleProgress:setPercent(100)
		recycleProgressCount:setText(string.format("%d/%d", progressLimit, progressLimit))
	else
		recycleProgress:setPercent(f*100)
		recycleProgressCount:setText(string.format("%d/%d", self._recycle_remain_points, progressLimit))
	end
end

--变化进度条颜色
function wnd_faction_production:setProgressColor(progressBar, progressBg, decimal)
	local times = self._need_recycle_times
	local barImgID = 0
	local bgImgID = 0

	if times >= 1 and decimal ~= 0 then  --进度条至少达到一次，并且不满格
		barImgID = ProgressBarImglist[(times % #ProgressBarImglist) + 1]
		bgImgID = ProgressBarImglist[((times - 1) % #ProgressBarImglist) + 1]
	elseif times >=1 and decimal == 0 then  --进度条至少到达一次，且进度条满格
		barImgID = ProgressBarImglist[((times - 1) % #ProgressBarImglist) + 1]
		bgImgID = 0
	elseif times == 0 then  --进度条不足一次，默认第一种颜色
		barImgID = ProgressBarImglist[1]
		bgImgID = 0
	end

	if bgImgID ~= 0 then
		progressBg:show()
	else
		progressBg:hide()
	end
	progressBar:setImage(g_i3k_db.i3k_db_get_icon_path(barImgID))
	progressBg:setImage(g_i3k_db.i3k_db_get_icon_path(bgImgID))
end

--点击堆叠炼化
function wnd_faction_production:onRecycleGather(sender)
	if self._is_select_gather then
		self.gather_img:hide()
		self._is_select_gather = false
	else
		self.gather_img:show()
		self._is_select_gather = true
	end
end

function wnd_faction_production:onClickRecycle(sender)
	local items = self._need_recycle_items
	if next(items) then
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_clan_recycle_base_info.recycle_need_itemId)  --查询道具数量
		local needCount = self._need_consume_itemCnt
		if haveCount < needCount then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15508))
		else
			self:startRecycle()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15434))
	end
end

--开始炼化
function wnd_faction_production:startRecycle()
	local _temp = {}
	for k,v in pairs(self._need_recycle_items) do
		local _t = i3k_sbean.DummyGoods.new()
		_t.id = v.id
		_t.count = v.count
		table.insert(_temp,_t)
	end
	i3k_sbean.produce_fusion(_temp,self._recycle_remain_points,self._need_consume_itemCnt)
end

function wnd_faction_production:onStoveReward(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

--播放炉子火焰动画
function wnd_faction_production:playStoveFireAni(mode)
	local id = 1303 --丹炉模型id
	local path = i3k_db_models[id].path
	local uiscale = i3k_db_models[id].uiscale
	self.lu_zi_model:setSprite(path)
	self.lu_zi_model:setSprSize(uiscale)
	if mode == "stand" then
		self.lu_zi_model:playAction("stand01")
	elseif mode == "fire" then
		self.lu_zi_model:pushActionList("stand02", 1)
		self.lu_zi_model:pushActionList("stand01", -1)
		self.lu_zi_model:playActionList()
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_faction_production.new();
		wnd:create(layout, ...);

	return wnd;
end
