------------------------------------------------------------
--物品tip
------------------------------------------------------------
EquipTip = EquipTip or BaseClass(XuiBaseView)

EquipTip.FROM_NORMAL = 0						--无
EquipTip.FROM_BAG = 1 							--在背包界面中（没有打开仓库和出售）
EquipTip.FROM_BAG_ON_BAG_STORAGE = 2			--打开仓库界面时，来自背包
EquipTip.FROM_STORAGE_ON_BAG_STORAGE = 3		--打开仓库界面时，来自仓库
EquipTip.FROM_BAG_ON_BAG_SALE = 4				--打开售卖界面时，来自背包
EquipTip.FROM_BAG_EQUIP = 5						--在装备界面时，来自装备
EquipTip.FROME_BROWSE_ROLE = 6					--查看角色界面时，来自查看
EquipTip.FROME_BROWSE_ROLE_VIEW = 7				--查看角色界面时, 来自界面
EquipTip.FROME_EQUIP_STONE = 8					--身上宝石卸下
EquipTip.FROM_BAG_ON_GUILD_STORAGE = 9			--打开行会仓库界面时， 来自背包
EquipTip.FROM_STORAGE_ON_GUILD_STORAGE = 10		--打开行会仓库界面时， 来自行会仓库
EquipTip.FROM_HERO_EQUIP = 11					--打开英雄界面时， 来自英雄装备
EquipTip.FROM_BAG_ON_RECYCLE = 12				--打回收将界面时， 来自背包
EquipTip.FROM_RECYCLE = 13						--打回收将界面时， 来自回收
EquipTip.FROM_CONSIGN_ON_BUY = 14 				--打开购买界面时， 来自寄售
EquipTip.FROM_CONSIGN_ON_SELL = 15 				--打开出售界面时， 来自寄售
EquipTip.FROM_XUNBAO_BAG = 16 					--取出仓库物品，   来自寻宝
EquipTip.FROM_EQUIP_COMPARE = 17 				--来自装备对比
EquipTip.FROM_WING_STONE = 18 					--来自翅膀魂石
EquipTip.FROM_CHAT_BAG = 19 					--来自聊天背包
EquipTip.FROM_EXCHANGE_BAG = 20					--来自交易背包
EquipTip.FROM_MAIL = 21							--来自邮件
EquipTip.FROM_BAG_ON_BUY = 22 					--打开背包界面时，来自购买
EquipTip.FROM_HERO_BAG = 23 					--来自英雄背包
EquipTip.FROM_HERO_COMPARE = 24 				--来自英雄装备对比
EquipTip.FROM_HERO_KEYEQUIP = 25 				--来自英雄一键装备
EquipTip.FROM_GEM_BAG = 26 						--来自宝石背包
	
EquipTip.HANDLE_EQUIP= 1						--装备
EquipTip.HANDLE_USE= 2							--使用
EquipTip.HANDLE_DISCARD = 3						--丢弃
EquipTip.HANDLE_STRENGTHEN = 4					--强化
EquipTip.HANDLE_INLAY = 5						--镶嵌
EquipTip.HANDLE_SPLIT = 6						--拆分
EquipTip.HANDLE_TAKEOFF= 7						--卸下
EquipTip.HANDLE_INPUT = 8						--投入
EquipTip.HANDLE_EXCHANGE = 9					--兑换
EquipTip.HANDLE_DESTROY = 10					--摧毁
EquipTip.HANDLE_TAKEOUT = 11					--取出
EquipTip.HANDLE_BUY = 12 						--购买
EquipTip.HANDLE_ZHURU = 13						--注入
EquipTip.HANDLE_SHOW = 14						--展示
EquipTip.HANDLE_FIND = 15						--寻路
EquipTip.HANDLE_DECOMSPOSE = 16					--分解
EquipTip.HANDLE_SUITEQUIP = 17					--套装

local SCROLLVIEWWIDTH = 510
local SCROLLVIEWHEIGHT = 400

local RICHCELLHEIGHT = 20

--基础 洗练 特殊 强化
local ATTR_CONTENT = 1
local ATTR_SUIT = 2
local ATTR_FUMO = 3 -- 附魔
local ATTR_ClearEquip = 4
local ATTR_SPECIAL_ATRR = 5
local ATTR_BASE = 6
local ATTR_QIANGHUA = 7

function EquipTip:__init()
	self.is_async_load = false
	self.zorder = COMMON_CONSTS.ZORDER_ITEM_TIPS
	self.is_any_click_close = true
	self.texture_path_list[1] = 'res/xui/equipment.png'
	self.config_tab = {{"itemtip_ui_cfg", 1, {0}}}
	self.is_modal = true

	self.buttons = {}
	self.label_t = Language.Tip.ButtonLabel
	self.num_txt = nil	
	self.handle_param_t = self.handle_param_t or {}
	self.data = nil
	self.attrslist = {}
	self.item_num = 1
	self.fromView = EquipTip.FROM_NORMAL
	self.handle_type = 0
	self.limit_level = 0
	
	self.star_list = {}

	--self.alert_window = nil
end

function EquipTip:__delete()
	self.label_t = nil

	if self.my_equip_tip then
		self.my_equip_tip:DeleteMe()
		self.my_equip_tip = nil
	end
end

function EquipTip:ReleaseCallBack()
	self.buttons = {}
	self.handle_param_t = {}
	self.data = nil
	self.attrslist = {}
	self.equip_stamp = nil

	-- if nil ~= self.alert_window then
	-- 	self.alert_window:DeleteMe()
	-- 	self.alert_window = nil
	-- end
	-- if nil ~= self.fuling_effect then
	-- 	self.fuling_effect:DeleteMe()
	-- 	self.fuling_effect = nil
	-- end
	self.equip_color_bg = nil
	self.scroll_view = nil
	self.scroll_roll_view = nil
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	--self.contrast_layout = nil
	--self.fabao_rich = nil
	--self.prop_countdown_rich = nil
	if RoleData.Instance then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	ClientCommonButtonDic[CommonButtonType.EQUIP_TIP_EUQIP_BTN] = nil
end

function EquipTip:LoadCallBack()
	self.rich_itemname_txt = self.node_t_list.rich_itemname_txt.node
	self.lbl_marks = self.node_t_list.top_txt3.node
	self.lbl_level = self.node_t_list.top_txt2.node
	self.lbl_type = self.node_t_list.top_txt1.node
	self.lbl_sex = self.node_t_list.top_txt4.node
	self.lbl_zhanliscore = self.node_t_list.top_txt5.node
	self.itemtips_bg = self.node_t_list.img9_itemtips_bg.node
	self.layout_btns = self.node_t_list.layout_btns.node
	self.layout_btns:setAnchorPoint(0.5, 0)
	-- self.img_nottrade = self.node_t_list.img_nottrade.node --交易图标

	self.cell = BaseCell.New()
	self.layout_content_top = self.node_t_list.layout_content_top.node
	self.layout_content_top:setAnchorPoint(0.5, 0)
	self.layout_content_top:addChild(self.cell:GetCell(), 200)
	local ph_itemcell = self.ph_list.ph_itemcell --占位符
	self.cell:GetCell():setPosition(ph_itemcell.x, ph_itemcell.y)
	self.cell:SetIsShowTips(false)

	self.buttons = {self.node_t_list.btn_0.node, self.node_t_list.btn_1.node, 
	self.node_t_list.btn_2.node, self.node_t_list.btn_3.node}
	for k, v in pairs(self.buttons) do
		v:addClickEventListener(BindTool.Bind1(self.OperationClickHandler, self))
	end
	self.node_t_list.btn_close_window.node:setLocalZOrder(999)


	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self, -1),  1)
end

function EquipTip:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_CIRCLE or key == OBJ_ATTR.CREATURE_LEVEL then
		self:Flush()
	end
end

function EquipTip:OpenCallBack()
	
end

function EquipTip:FlushTime()
	if self.data == nil then return end
	if self.data.use_time == nil or self.data.use_time and self.data.use_time < 0 then
		self.node_t_list.layout_content_top.txt_remain_time.node:setString("")
		self.node_t_list.layout_content_top.txt_remain_time1.node:setString("")
		return
	end
	local txt = ""
	if (self.data.use_time or 0) - TimeCtrl.Instance:GetServerTime() < 0 then
		txt = ""
	else
		local time_s = TimeUtil.FormatSecond2Str((self.data.use_time or 0) - TimeCtrl.Instance:GetServerTime())
		txt = time_s
	end
	self.node_t_list.layout_content_top.txt_remain_time1.node:setString(Language.Common.RemainTime)
	self.node_t_list.layout_content_top.txt_remain_time.node:setString(txt)
end

function EquipTip:ShowIndexCallBack(index)

end

function EquipTip:CloseCallBack()
	self.item_num = 1
	ParticleEffectSys.Instance:StopEffect("equipstar", true)
	if CountDownManager.Instance:HasCountDown("item_tip_fumo") then
		CountDownManager.Instance:RemoveCountDown("item_tip_fumo")
	end
	if self.my_equip_tip and self.my_equip_tip:IsOpen() then
		self.my_equip_tip:Close()
	end
end

function EquipTip:OnFlush(param_t)
	if self.data then
		self:ShowTipContent()
		self:ShowOperationState()
		-- self:ShowContrastContent()
		self:DoLayout()
		self:FlushTime()
	end
end

--data = {item_id=100....} 如果背包有的话最好把背包的物品传过来
function EquipTip:SetData(data, fromView, param_t)
	if not data then
		return
	end
	self.data = data
	self:Open()
	self.fromView = fromView or EquipTip.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self:Flush()
end

function EquipTip:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	if not self.data.frombody and not self.handle_param_t.not_compare then
		local equip = nil 
		if item_cfg.type == ItemData.ItemType.itBracelet or item_cfg.type == ItemData.ItemType.itRing then
			equip = EquipmentData.Instance:GetWorseEquip(item_cfg.type)
		else
			equip = EquipData.Instance:GetEquipByType(item_cfg.type)
		end
		local from_tip = EquipTip.FROM_EQUIP_COMPARE
		if self:IsFromHero() then
			from_tip = EquipTip.FROM_HERO_COMPARE
			equip = ZhanjiangData.Instance:GetEquipedEquipByType(item_cfg.type)
		end
		if equip then
			if self.my_equip_tip == nil then
				self.my_equip_tip = EquipTip.New()
				self.my_equip_tip.is_async_load = true
				self.my_equip_tip:SetModal(false)
				self.my_equip_tip:SetIsAnyClickClose(false)
			end
			self.my_equip_tip:SetData(equip, from_tip)
		end
	end
	self.node_t_list.btn_close_window.node:setVisible(self.fromView ~= EquipTip.FROM_EQUIP_COMPARE and self.fromView ~= EquipTip.FROM_HERO_COMPARE)
	local path = nil 
	if self:IsFromHero() then 
		path = ResPath.GetCommon("stamp_34")
	end
	self:ShowEquipStamp(self.data.frombody, path)
	self.cell:SetData(self.data)
	local color = ItemData.Instance:GetItemColor(self.data.item_id, self.data)
	self.lbl_type:setColor(COLOR3B.YELLOW)
	self.lbl_type:setString(string.format(Language.Tip.ZhuangBeiLeiXing, Language.EquipTypeName[item_cfg.type] or ""))
	self.lbl_marks:setColor(COLOR3B.YELLOW)
	local prof_str = string.format(Language.Tip.Prof, Language.Common.ProfName[0])

	if self.fromView == EquipTip.FROME_BROWSE_ROLE_VIEW then
		local role_vo = BrowseData.Instance:GetRoleInfo()
		out_prof = role_vo[OBJ_ATTR.ACTOR_PROF]
	elseif self:IsFromHero() then
		out_prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	else
		out_prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	end	
	local score = ItemData.Instance:GetItemScore(self.data, out_prof)
	self.lbl_zhanliscore:setString(string.format(Language.Tip.Zhanliscore,score))

	if ItemData.GetIsHeroEquip(self.data.item_id) then
		prof_str = string.format(Language.Tip.Prof, Language.Common.HeroProfName)
	end
	self.lbl_marks:setString(prof_str)
	self.lbl_level:setColor(COLOR3B.YELLOW)
	self.lbl_sex:setString(string.format(Language.Tip.Sex, Language.Common.No))
	self.lbl_sex:setColor(COLOR3B.YELLOW)
	self.limit_level = 0
	local zhuan = 0
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	if self:IsFromHero() then
		prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	end
	local is_enough_cond = false
	local circle_lv = self:IsFromHero() and ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	for k,v in pairs(item_cfg.conds) do
		if v.cond == ItemData.UseCondition.ucLevel then
			self.limit_level = v.value
			is_enough_cond = self:IsFromHero() and ZhanjiangData.Instance:IsEnoughLevelZhuan(v.value) or RoleData.Instance:IsEnoughLevelZhuan(v.value)
			if circle_lv <= 0 and is_enough_cond == false then
				self.lbl_level:setColor(COLOR3B.RED)
			end
		end
		if v.cond == ItemData.UseCondition.ucMinCircle then
			zhuan = v.value
			is_enough_cond = self:IsFromHero() and ZhanjiangData.Instance:IsEnoughZhuan(v.value) or RoleData.Instance:IsEnoughZhuan(v.value)
			if circle_lv > 0 and is_enough_cond == false then
				self.lbl_level:setColor(COLOR3B.RED)
			end
		end
		if v.cond == ItemData.UseCondition.ucGender then
				self.lbl_sex:setString(string.format(Language.Tip.Sex, Language.Common.SexName[v.value]))
				local self_sex = self:IsFromHero() == false and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) or ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
				if v.value ~= self_sex then
					self.lbl_sex:setColor(COLOR3B.RED)
				end
		end
		if v.cond == ItemData.UseCondition.ucJob then
			self.lbl_marks:setString(string.format(Language.Tip.Prof, Language.Common.ProfName[v.value]))
			if v.value ~= 0 and v.value ~= prof then
				self.lbl_marks:setColor(COLOR3B.RED)
			end
			local score = ItemData.Instance:GetItemScore(self.data, v.value)
			self.lbl_zhanliscore:setString(string.format(Language.Tip.Zhanliscore,score))
		end
	end
	--self.lbl_level:setString(string.format(Language.Tip.LvCircleCond, zhuan, self.limit_level))
	if zhuan > 0 then
		self.lbl_level:setString(string.format(Language.Tip.ZhuanDengJi, zhuan))
	else
		self.lbl_level:setString(string.format(Language.Tip.DengJi, self.limit_level))
	end
	self:ParseEquip(item_cfg)
	str = EquipTip.GetEquipName(item_cfg, self.data, self.fromView)
	RichTextUtil.ParseRichText(self.rich_itemname_txt, str, 24, Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))
end

function EquipTip:IsFromHero()
	return self.fromView == EquipTip.FROM_HERO_BAG or self.fromView == EquipTip.FROM_HERO_EQUIP or self.fromView == EquipTip.FROM_HERO_COMPARE or self.fromView == EquipTip.FROM_HERO_KEYEQUIP
end

--解析装备tips
function EquipTip:ParseEquip(item_cfg)
	self:ResetUi()
	self.attrslist = {}
	if self.data == nil or item_cfg == nil then
		return
	end

	self.scroll_roll_view = XUI.CreateScrollView(SCROLLVIEWWIDTH/2 - 16, SCROLLVIEWHEIGHT/2 + 55,SCROLLVIEWWIDTH, SCROLLVIEWHEIGHT, ccui.ScrollViewDir.vertical)
	self.node_t_list.layout_itemtip.node:addChild(self.scroll_roll_view, 10, 10)
	self.scroll_roll_view:setAnchorPoint(0,1)

	self.scroll_view = XUI.CreateLayout(SCROLLVIEWWIDTH/2, SCROLLVIEWHEIGHT/2 + 55,
		SCROLLVIEWWIDTH, SCROLLVIEWHEIGHT)
	self.scroll_roll_view:addChild(self.scroll_view, 10, 10)
	self.scroll_view:setAnchorPoint(0,0)

	local attribute = {} 
	attribute[ATTR_BASE] = CommonDataManager.GetAttributteByClass(item_cfg, true)
	attribute[ATTR_QIANGHUA] = CommonDataManager.GetAttributteByClass(item_cfg, true)
	attribute[ATTR_CONTENT] = CommonDataManager.GetAttributteByClass(item_cfg, true)
	attribute[ATTR_ClearEquip] = CommonDataManager.GetAttributteByClass(item_cfg, true)
	attribute[ATTR_SPECIAL_ATRR] = CommonDataManager.GetAttributteByClass(item_cfg, true)
	attribute[ATTR_SUIT] = CommonDataManager.GetAttributteByClass(item_cfg, true)
	attribute[ATTR_FUMO] = CommonDataManager.GetAttributteByClass(item_cfg, true)
	local hand_pos = self.data.hand_pos
	if self.fromView ~= EquipTip.FROM_BAG_EQUIP then
		hand_pos = EquipmentData.Instance:GetBetterStrengthHandPos(item_cfg.type)
	end
	local loop = 0
	local height_offset = 0
	local rich = nil
	local value = {}
	local rich_x = 35
	for i = 1, #attribute, 1 do
		local list = attribute[i]
		if ATTR_CONTENT == i then
			--物品描述
			if self.fromView == EquipTip.FROM_STORAGE_ON_GUILD_STORAGE and (item_cfg.contri and item_cfg.contri > 0) then
				local echange_cost_str = string.format(Language.Guild.ExhangeEquipCost, item_cfg.contri) or ""
				loop = loop + 1
				height_offset = height_offset + RICHCELLHEIGHT
				value = {dec = {key = echange_cost_str, color = COLOR3B.GREEN}}
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + rich_x, height_offset)
				self.scroll_view:addChild(rich)
			elseif self.fromView == EquipTip.FROM_BAG_ON_GUILD_STORAGE and (item_cfg.contri and item_cfg.contri > 0) then
				local echange_get = string.format(Language.Guild.ExhangeEquipGet, item_cfg.contri) or ""
				loop = loop + 1
				height_offset = height_offset + RICHCELLHEIGHT
				value = {dec = {key = echange_get, color = COLOR3B.GREEN}}
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + rich_x, height_offset)
				self.scroll_view:addChild(rich)
			end
			loop = loop + 1
			if item_cfg.desc then
				loop = loop + 1
				value = {dec = {key = item_cfg.desc, color = COLOR3B.GREEN}}
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
				self.scroll_view:addChild(rich)

				if ItemData.GetIsComposeEquip(self.data.item_id) == false then
					loop = loop + 1
					value = {title = Language.Tip.ItemContent}
					rich = self:CreateTextRichCell(loop, value)
					rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
					self.scroll_view:addChild(rich)
				end
			end
		elseif ATTR_SUIT == i and item_cfg.suitId and item_cfg.suitId > 0  then
			--if self.fromView == EquipTip.FROME_BROWSE_ROLE_VIEW or self.fromView == EquipTip.FROM_BAG_EQUIP or self.fromview == EquipTip.FROM_BAG then
				local suitId = item_cfg.suitId 
				local color = {}
				local num,colorNum = 0,0
				local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
				color, num = GodWeaponEtremeData.Instance:GetShowBySuitId(suitId, 1)
				if self.fromView == EquipTip.FROME_BROWSE_ROLE_VIEW then
					prof = BrowseData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
					color, num = GodWeaponEtremeData.Instance:GetShowBySuitId(suitId, 2)
				elseif self:IsFromHero() then
					prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
					color, num = GodWeaponEtremeData.Instance:GetShowBySuitId(suitId, 3)
				else
					if item_cfg.conds then
						for k,v in pairs(item_cfg.conds) do
							if v.cond == ItemData.UseCondition.ucJob then
								self.lbl_marks:setString(string.format(Language.Tip.Prof, Language.Common.ProfName[v.value]))
								if v.value ~= 0 then
									prof = v.value 
								end
							end
						end
					end
				end
				if self.fromView ~= EquipTip.FROM_EQUIP_COMPARE then
					local tipColor  = TipsCtrl.Instance:getTipData()
					for i,v in ipairs(tipColor) do
						if string.byte(v) < string.byte(color[i]) then
							colorNum = colorNum+1
							color[i] = v
						end
					end
				end
				local attr_t_list = GodWeaponEtremeData.Instance:GetServerAttrConfig(suitId, prof)
				local suitNum = {3,5,8}
				for i= #suitNum, 1,-1 do
					local v = RoleData.FormatRoleAttrStr(attr_t_list[i], nil, nil, prof, nil)
					local attr_color =nil
					if num >= suitNum[i] then
						attr_color = COLOR3B.GREEN
					else
						attr_color = COLOR3B.GRAY
					end
					loop = loop + 1
					local txt = "("..suitNum[i]..Language.Tip.Jian ..") "
					for k1, v1 in pairs(v) do
						txt = txt .. v1.type_str.. "  + " .. v1.value_str .."  "
					end
					if colorNum+num >= suitNum[i] then
						attr_color = COLOR3B.GREEN
					end
					value = {label = {[1] = {key = txt, color = attr_color}}}
					rich = self:CreateTextRichCell(loop, value)
					rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
					self.scroll_view:addChild(rich)
				end

				local txt = ""
				for i, v in ipairs(EquipType) do
					txt = txt .."  ".. string.format(Language.Tip.SuitEquipName,  color[i], Language.EquipTypeName[v])
				end
				loop = loop + 1
				value = {content = txt}
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
				self.scroll_view:addChild(rich)

				loop = loop + 1
				value = {title = Language.Tip.SuitProperty}
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
				self.scroll_view:addChild(rich)
			--end
		elseif ATTR_FUMO == i and EquipmentData.Instance:FilteBoolShow(item_cfg) and ViewManager.Instance:CanShowUi(ViewName.Equipment, TabIndex.equipment_enchanting) then
			local type_data  = EquipmentData.Instance:GetPropData(self.data.fumo_proprty)
			if type_data.value == 0 then
				loop = loop + 1
				value = {dec = {key = Language.Tip.EntantingTips, color = COLOR3B.GREEN}}
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
				self.scroll_view:addChild(rich)
			else
				local cur_txt = RoleData.FormatAttrContent({type_data})
				local name = EquipmentData.Instance:GetFuMoPropety(type_data.type)
				local bool, activite_desc = EquipmentData.Instance:GetAtcivateConditionByPropertyType(item_cfg.type, type_data.type)

				local color = COLOR3B.GREEN
				local color_1 = "878787"
				if bool then
					color = COLOR3B.GREEN
					color_1 = EquipEnchantColorCfg[type_data.type]
				else
					color = COLOR3B.GRAY
					color_1= "878787"
				end
				loop = loop + 1 
				value = {dec = {key = activite_desc, color = color}}
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
				self.scroll_view:addChild(rich)

				loop = loop + 1
				local txt = string.format(Language.Equipment.Enchanting_proprty, color_1, name, cur_txt) 
				value = {dec = {key = txt, color = color}}
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
				self.scroll_view:addChild(rich)
			end
			loop = loop + 1 
			value = {title = Language.Tip.Enchanting}
			rich = self:CreateTextRichCell(loop, value)
			rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
			self.scroll_view:addChild(rich)
		elseif ATTR_ClearEquip == i then
			if ItemData.GetIsComposeEquip(self.data.item_id) == false and --不是神炉准备
			  ItemData.GetIsGodEquip(self.data.item_id) == false and --不是圣器
			 item_cfg.type ~= ItemData.ItemType.itWarRunePos then --不是战符
			 --print("3333333333", EquipmentData.Instance:GetClearEquipCircle(item_cfg))
			 	--可以洗练，并且开启宝石
				if EquipmentData.Instance:GetClearEquipCircle(item_cfg) and ViewManager.Instance:CanShowUi(ViewName.Equipment,TabIndex.equipment_gemstone) then
					if self.fromView == EquipTip.FROME_BROWSE_ROLE_VIEW or self.fromView == EquipTip.FROM_BAG_EQUIP then
						local shuxing_num = item_cfg.smithAttrMax or 0
						local data = EquipmentData.Instance:GetBoolClearEquip(self.data, shuxing_num)
						local suilian_txt = {}
						if data[1] ~= nil then
							suilian_txt = data
						end
						local index = self.handle_param_t.fromIndex
						local txt = {}
						local txt_shuxing = {}
						local color = {}
						local bool_open = {}
						local bool_activate = 0

						local rich_txt = {}
						if self.fromView == EquipTip.FROM_BAG_EQUIP then
							local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
							txt, txt_shuxing, color, bool_open, bool_activate = EquipmentData.Instance:GetPlayerShuXing(index, true, prof)
						elseif self.fromView == EquipTip.FROME_BROWSE_ROLE_VIEW then
							local prof = BrowseData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
							txt, txt_shuxing, color, bool_open, bool_activate = EquipmentData.Instance:GetPlayerShuXing(index, false, prof)
						end
						local has_color = {}
						if bool_activate > 0 then
							for i = 1, #txt do
								local total_txt = ""
								total_txt = (txt[i] or "" ) .."  ".. (txt_shuxing[i] or "")
								has_color[i] = color[i]

								if bool_open[i] <= 0 then
									rich_txt[i] =  "{gem;1}" .."  " ..total_txt
								else
									rich_txt[i] =  "{gem;2}" .. "  " ..total_txt
								end
							end
						else
							rich_txt[1] = Language.Tip.NotOpenHunShi
						end
						loop = loop + 1
						value = {tabbar = {Language.Tip.Succinct,Language.Tip.HunShi}, rich_gem_content = {suilian_txt, rich_txt, has_color}}
						rich = self:CreateTextRichCell(loop, value)
						rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
						self.scroll_view:addChild(rich)
					else
						local shuxing_num = item_cfg.smithAttrMax or 0

						local data = EquipmentData.Instance:GetBoolClearEquip(self.data, shuxing_num)
						if data[1] ~= nil then
							for i = #data, 1, -1 do
								loop = loop + 1
								value = {content = data[i]}
								rich = self:CreateTextRichCell(loop, value)
								rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
								self.scroll_view:addChild(rich)
							end
							loop = loop + 1
							value = {title = Language.Tip.Succinct}
							rich = self:CreateTextRichCell(loop, value)
							rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
							self.scroll_view:addChild(rich)
						end
					end
				else --不可以洗练,可以查看宝石的
					if ViewManager.Instance:CanShowUi(ViewName.Equipment,TabIndex.equipment_gemstone) then
						if self.fromView == EquipTip.FROME_BROWSE_ROLE_VIEW or self.fromView == EquipTip.FROM_BAG_EQUIP then
							local index = self.handle_param_t.fromIndex
							local txt = {}
							local txt_shuxing = {}
							local color = {}
							local bool_open = {}
							local bool_activate = 0
							if self.fromView == EquipTip.FROM_BAG_EQUIP then
								txt, txt_shuxing, color, bool_open, bool_activate = EquipmentData.Instance:GetPlayerShuXing(index, true)
							elseif self.fromView == EquipTip.FROME_BROWSE_ROLE_VIEW then
								txt, txt_shuxing, color, bool_open, bool_activate = EquipmentData.Instance:GetPlayerShuXing(index, false)
							end
							if bool_activate == 1 then
								for i = #txt, 1, -1 do
									loop = loop + 1
									local total_txt = ""
									total_txt = (txt[i] or "" ) .."  ".. (txt_shuxing[i] or "")
									local hs_color = color[i]
									local path = ""
									if bool_open[i] == 0 then
										path = ResPath.GetCommon("orn_1")
									elseif bool_open[i] == 1 then
										path = ResPath.GetCommon("orn_102")
									end
									value = {hs_data = {img = path, hs_txt = total_txt, hs_txet_color = hs_color}}
									rich = self:CreateTextRichCell(loop, value)
									rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
									self.scroll_view:addChild(rich)
								end
								loop = loop + 1
								value = {title = Language.Tip.HunShi}
								rich = self:CreateTextRichCell(loop, value)
								rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
								self.scroll_view:addChild(rich)
							else
								loop = loop + 1
								value = {content = Language.Tip.NotOpenHunShi}
								rich = self:CreateTextRichCell(loop, value)
								rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
								self.scroll_view:addChild(rich)
								loop = loop + 1
								value = {title = Language.Tip.HunShi}
								rich = self:CreateTextRichCell(loop, value)
								rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
								self.scroll_view:addChild(rich)
							end
						end
					else
						if EquipmentData.Instance:GetClearEquipCircle(item_cfg) then
							local shuxing_num = item_cfg.smithAttrMax or 0
							local data = EquipmentData.Instance:GetBoolClearEquip(self.data, shuxing_num)
							if data[1] ~= nil then
								for i = #data, 1, -1 do
									loop = loop + 1
									value = {content = data[i]}
									rich = self:CreateTextRichCell(loop, value)
									rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
									self.scroll_view:addChild(rich)
								end
								loop = loop + 1
								value = {title = Language.Tip.Succinct}
								rich = self:CreateTextRichCell(loop, value)
								rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
								self.scroll_view:addChild(rich)
							end
						end
					end
				end
			end
		
		elseif ATTR_SPECIAL_ATRR == i and ItemData.GetIsGodEquip(self.data.item_id) or  ATTR_SPECIAL_ATRR == i and item_cfg.type == ItemData.ItemType.itSpecialRing then
			if item_cfg.freezeTime then
				loop = loop + 1
				local time = TimeUtil.FormatSecond(item_cfg.freezeTime, 2)
				value = {label = {[1] = {key = Language.Tip.FuHuoTime .. "：" .. time, color = COLOR3B.WHITE}}}
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
				self.scroll_view:addChild(rich)
			end

			local data = {}
			local special_attr = {}
			if item_cfg.type == ItemData.ItemType.itSpecialRing then
				if item_cfg.useType == 2 or item_cfg.useType == 3 then
					hand_pos = 0
				else
					hand_pos = 1
				end
				local composeType = ComposeData.Instance:GetType(item_cfg.type, hand_pos, item_cfg.useType)
				data = ComposeData.Instance:GetAttr(composeType, self.data.compose_level)
				special_attr = RoleData.Instance:GetSpecialProperty(data)
			elseif ItemData.GetIsGodEquip(self.data.item_id) then
				data = item_cfg.staitcAttrs
				special_attr = RoleData.Instance:GetSpecialProperty(data)
			end
			local special_attr_t = RoleData.FormatRoleAttrStr(special_attr)
			for i = #special_attr_t, 1, -1 do
				local v = special_attr_t[i]
				if v == nil then break end
				loop = loop + 1
				local attr_name = v.type_str
				local attr_value = v.value_str
				if attr_name ~= nil and attr_value ~= nil then
					value = {label = {[1] = {key = attr_name .. "：" .. attr_value, color = COLOR3B.WHITE}}}
				end
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
				self.scroll_view:addChild(rich)
			end
			loop = loop + 1
			value = {title = Language.Tip.SpecailATTR}
			rich = self:CreateTextRichCell(loop, value)
			rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
			self.scroll_view:addChild(rich)

		elseif ATTR_BASE == i  then
			--基础属性
			local cfg = {}
			if item_cfg.type == 1  then
				if self.data.lucky_value  ~= nil then
					if self.data.lucky_value > 0  then 
						cfg = {type_str = Language.Tip.Lucky , value_str = self.data.lucky_value}
					elseif self.data.lucky_value < 0 then
						cfg = {type_str = Language.Tip.Curse , value_str = math.abs(self.data.lucky_value)}
					end
					if cfg.type_str ~= nil and cfg.value_str ~= nil then
						loop = loop + 1
						rich = self:CreateTextRichCell(loop, {label = {[1] = {key = cfg.type_str .. "：".. cfg.value_str, color = COLOR3B.WHITE}}})
						rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
						self.scroll_view:addChild(rich)
					end
				end
			end
			-- 极品属性
			if self.data.property_jipin and self.data.property_jipin > 0 then
				loop = loop + 1
				local property_data = EquipmentData.Instance:GetPropData(self.data.property_jipin)
				local attr_t = RoleData.FormatRoleAttrStr({property_data}, is_range, nil, out_prof)
				local attr_name = attr_t[1] and attr_t[1].type_str or ""
				local attr_value = attr_t[1] and attr_t[1].value_str or ""
				local value = {content = attr_name .. "：" .. attr_value.."  "..Language.Tip.JIPinProperty, color = COLOR3B.GOLD}
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
				self.scroll_view:addChild(rich)
			else
				if item_cfg.flags and(item_cfg.flags.theShenArmy or item_cfg.flags.primeEquip) then
					loop = loop + 1
					local  attr_t  = RoleData.FormatRoleAttrStr(item_cfg.initSmithAttrs, is_range, nil, out_prof)
					local attr_name = attr_t[1] and attr_t[1].type_str or ""
					local attr_value = attr_t[1] and attr_t[1].value_str or ""
					local value = {content = attr_name .. "：" .. attr_value.."  "..Language.Tip.JIPinProperty, color = COLOR3B.GOLD}
					rich = self:CreateTextRichCell(loop, value)
					rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
					self.scroll_view:addChild(rich)
				end
			end
			local strength_cfg = {}
			local infuse_cfg = {}
			local strength_attr_t = {}
			local infuse_attr_t = {}
			local out_prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
			local bool = false
			if self.fromView == EquipTip.FROME_BROWSE_ROLE_VIEW then
				local role_vo = BrowseData.Instance:GetRoleInfo()
				out_prof = role_vo[OBJ_ATTR.ACTOR_PROF]
			elseif self:IsFromHero() then
				out_prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
			else
				if item_cfg.conds then
					for k,v in pairs(item_cfg.conds) do
						if v.cond == ItemData.UseCondition.ucJob then
							self.lbl_marks:setString(string.format(Language.Tip.Prof, Language.Common.ProfName[v.value]))
							if v.value ~= 0 then
								out_prof = v.value 
								bool = true
							end
						end
					end
				end
			end
			strength_cfg = EquipmentData.GetAttrConfig(item_cfg.type, self.data.strengthen_level) or {}
			infuse_cfg = EquipmentData.GetinfuseAttrConfig(item_cfg.type, self.data.infuse_level) or {}
			local base_attr = {} 
			if ItemData.GetIsComposeEquip(self.data.item_id)  then
				if item_cfg.type == ItemData.ItemType.itSpecialRing then 
					if item_cfg.useType == 2 or item_cfg.useType == 3 then
						hand_pos = 0
					else
						hand_pos = 1
					end
					local composeType = ComposeData.Instance:GetType(item_cfg.type, hand_pos, item_cfg.useType)
					local data = ComposeData.Instance:GetAttr(composeType, self.data.compose_level)
					base_attr = RoleData.Instance:GetCommonProperty(data)
				else
					local composeType = ComposeData.Instance:GetComposeTypeByItemType(item_cfg.type)
					if composeType == 5 then
						base_attr = AchieveData.Instance:GetAttr(self.data.compose_level)
					else
						base_attr = ComposeData.Instance:GetAttr(composeType, self.data.compose_level)
					end
				end
				strength_attr_t = RoleData.FormatRoleAttrStr(strength_cfg, is_range, nil, out_prof)
				infuse_attr_t = RoleData.FormatRoleAttrStr(infuse_cfg, is_range, nil, out_prof)
			elseif ItemData.GetIsGodEquip(self.data.item_id) then
				base_attr = RoleData.Instance:GetCommonProperty(item_cfg.staitcAttrs)
				strength_attr_t = RoleData.FormatRoleAttrStr(strength_cfg, is_range)
				infuse_attr_t = RoleData.FormatRoleAttrStr(infuse_cfg, is_range)
			else
				base_attr = item_cfg.staitcAttrs
				local data = bool and item_cfg or nil --如果装备是全职业装备，就不取装备本身职业
				strength_attr_t = RoleData.FormatRoleAttrStr(strength_cfg, is_range, data, out_prof)
				infuse_attr_t = RoleData.FormatRoleAttrStr(infuse_cfg, is_range, data, out_prof)
			end

			base_attr = CommonDataManager.DelAttrByProf(out_prof, base_attr)
			local base_attr_t = RoleData.FormatRoleAttrStr(base_attr, is_range, nil, out_prof)

			for i = #base_attr_t, 1, -1 do
				local v = base_attr_t[i]
				if v == nil then break end
				loop = loop + 1
				local attr_name = ""
				local attr_value = ""
				local s_attr_name = ""
				local s_attr_value = ""
				local i_attr_value = ""
				local attr_name = v.type_str
				local attr_value = v.value_str
				for k1,v1 in pairs(strength_attr_t) do
					if v.type == v1.type then
						s_attr_value = v1.value_str
					end
				end

				for k1,v1 in pairs(infuse_attr_t) do
					if v.type == v1.type then
						i_attr_value = v1.value_str
					end
				end
				if attr_name ~= nil and attr_value ~= nil then
					value = {label = {[1] = {key = attr_name .. "：" .. attr_value, color = COLOR3B.WHITE}}}
				end
				if s_attr_value ~= "" then
					table.insert(value.label, {key = "  " .."+ ".."(".. s_attr_value..")", color = COLOR3B.YELLOW})
				end
				if i_attr_value ~= "" then
					table.insert(value.label, {key = "  " .."+ ".."(".. i_attr_value..")", color = COLOR3B.BLUE})
				end
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
				self.scroll_view:addChild(rich)
			end
			
			loop = loop + 1
			value = {title = Language.Tip.BaseAttr}
			rich = self:CreateTextRichCell(loop, value)
			rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
			self.scroll_view:addChild(rich)
		elseif ATTR_QIANGHUA == i then
			--注灵
			if item_cfg.injectLimit ~= nil and   item_cfg.injectLimit > 0 then
				loop = loop + 1
				local star = self.data.infuse_level or 0
				local length = item_cfg.injectLimit or 0
				local grade = 1
				local paths = {}
				for i = 1, length do
					if star >= i then
						paths[i] = ResPath.GetCommon("icon_diamond")
					else
						paths[i] = ResPath.GetCommon("icon_diamond_an")
					end
				end
				local percent = star.."/"..length
				local data = {title = Language.Tip.InfuseName, imgs = paths, level = percent, color = "009deb"}
				value = {equip_data = data}
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
				self.scroll_view:addChild(rich)
			end
			--强化
			if item_cfg.strongLimit ~= nil and item_cfg.strongLimit > 0 then
				local star = self.data.strengthen_level or 0 
				local length = item_cfg.strongLimit or 0
				local grade = 1
				local paths = {}
				for i = 1, length do
					if star >= i then
						paths[i] = ResPath.GetCommon("star_1_select")
					else
						paths[i] = ResPath.GetCommon("star_1_lock")
					end
				end
				local percent = star.."/"..length
				local data = {title = Language.Tip.StrengthName, imgs = paths, level = percent, color = "FFFF00"}
				value = {equip_data = data}
				rich = self:CreateTextRichCell(loop, value)
				rich:setPosition(GetCenterPoint(rich).x + rich_x, RICHCELLHEIGHT * loop)
				self.scroll_view:addChild(rich)
			end

		end
	end
	self:FlushLayout()
end

function EquipTip:FlushLayout()
	local hig = 0
	table.sort(self.attrslist, function(a, b) return a.tag < b.tag end )
	for k,v in pairs(self.attrslist) do
		v:refreshView()
		local inner_h = math.max(v:getInnerContainerSize().height, RICHCELLHEIGHT)
		hig = hig + inner_h + 5
		v:setPosition(v:getPositionX(), hig)
	end
	local item_tips_h = 650
	if hig<SCROLLVIEWHEIGHT+100 then	
		self.scroll_roll_view:setContentWH(SCROLLVIEWWIDTH,hig+20)
		item_tips_h = hig +self.layout_content_top:getContentSize().height+50
	else
		self.scroll_roll_view:setContentWH(SCROLLVIEWWIDTH,SCROLLVIEWHEIGHT+100)
	end
	self.scroll_roll_view:setInnerContainerSize(cc.size(SCROLLVIEWWIDTH/2 - 50, hig + 10))
	self.scroll_view:setPosition(-30,0)
	self.itemtips_bg:setContentWH(SCROLLVIEWWIDTH, item_tips_h)
	self.node_t_list.img_bg_1.node:setContentWH(SCROLLVIEWWIDTH +14, item_tips_h+10)
	local out_height = math.min(HandleRenderUnit:GetHeight() - item_tips_h, 0)
	self.itemtips_bg:setPositionY((item_tips_h + out_height) / 2 )
	self.node_t_list.img_bg_1.node:setPositionY((item_tips_h + out_height) / 2)
	self.layout_content_top:setPosition(SCROLLVIEWWIDTH/2-46, item_tips_h - 130 + out_height / 2)
	self.layout_btns:setPosition(SCROLLVIEWWIDTH + 40, 30 + out_height / 2)
	self.node_t_list.btn_close_window.node:setPosition(SCROLLVIEWWIDTH+11, item_tips_h - 35 + out_height / 2)
	self.root_node:setContentWH(self.root_node:getContentSize().width, item_tips_h + out_height)
	self.scroll_roll_view:setPosition(-18 ,self.layout_content_top:getPositionY()-5)
	self.scroll_roll_view:jumpToTop()
end

-- 创建单元行
-- value = 
-- {
-- label = { key, color} 
-- img = path 
-- imgs = {path, ...} 
-- }
function EquipTip:CreateTextRichCell(tag, value, is_not_global)
	is_not_global = is_not_global or false
	local rich_content = XUI.CreateRichText(0, 0, SCROLLVIEWWIDTH - 40, 0)
	rich_content:setAnchorPoint(cc.p(0.5, 0.5))
	rich_content.tag = tag
	local cell = nil
	if value.img then 
		local sprite = XImage:create(value.img.path, true)
		if nil ~= sprite then
			if value.img.is_grey then
				sprite:setGrey(true)
			end
			local x = value.img.x or 0
			local y = value.img.y or 0
			sprite:setPosition(x, y)
			local layout = XUI.CreateLayout(20, 0, 50, RICHCELLHEIGHT)
			layout:addChild(sprite, 99, 99)
			XUI.RichTextAddElement(rich_content, layout)
		end
	end
	if value.imgs then 
		local layout = XUI.CreateLayout(0, 0, 0, RICHCELLHEIGHT)
		for k,v in pairs(value.imgs) do
			local sprite = XImage:create(v, true)
			if nil ~= sprite then
				sprite:setScale(1)
				sprite:setPosition(30 + (k - 1) * 26, RICHCELLHEIGHT)
				layout:addChild(sprite, 99, 99)
			end
		end
		XUI.RichTextAddElement(rich_content, layout)
	end

	if value.tabbar then

		local layout = XUI.CreateLayout(0, 0, 0, RICHCELLHEIGHT)
		local line_img = XUI.CreateImageViewScale9(250, 25, 500, 4,ResPath.GetCommon("line_106"), true, cap_rect)
		layout:addChild(line_img, 4)
		local tabbar = Tabbar.New()
		local temp_loop = 0
		local temp_list = {}
		tabbar:CreateWithNameList(layout, 0, RICHCELLHEIGHT,
		function (index)
			for i, v in ipairs(temp_list) do
				v:removeFromParent()
			end
			temp_loop = 0
			local cur_txt = {}
			local color = {}
			if index == 1 then
				cur_txt = value.rich_gem_content[1]
			else
				cur_txt = value.rich_gem_content[2]
				color = value.rich_gem_content[3]
			end
			temp_list = {}
			for i = #cur_txt, 1, -1 do
				local value = {content = cur_txt[i], color = color[i]}
				temp_loop = temp_loop + 1
				rich = self:CreateTextRichCell(0,value,true)
				rich:setPosition(GetCenterPoint(rich).x, (RICHCELLHEIGHT+3) * temp_loop)
				layout:addChild(rich)
				temp_list[i] = rich
			end
			temp_loop = temp_loop + 1
			tabbar:GetView():setPosition(0,RICHCELLHEIGHT * temp_loop + 2)
			line_img:setPosition(250, RICHCELLHEIGHT * temp_loop+20)
			layout:setContentWH(0, RICHCELLHEIGHT * temp_loop + RICHCELLHEIGHT + 20)
			self:FlushLayout()
		end,
		value.tabbar, false, ResPath.GetCommon("img9_159_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		tabbar:SetSelectCallbackIndex(0)
		tabbar:SelectIndex(1)
		
		XUI.RichTextAddElement(rich_content, layout)
	end

	if value.title_path then
		local layout = XUI.CreateLayout(0, 0, 0, RICHCELLHEIGHT)
		local line_img = XUI.CreateImageViewScale9(0, 0, 530, 4,ResPath.GetCommon("line_106"), true, cap_rect)
		layout:addChild(line_img, 4)
		local img = XUI.CreateImageView(0, 0, ResPath.GetCommon("img9_159"),true)
		layout:addChild(img)
		local title = RichTextUtil.ParseRichText(nil, value.title_path, 22, COLOR3B.R_Y)
		layout:addChild(title)
		title:setIgnoreSize(true)
		layout:addChild(title, 4, 4)
		--title:setPosition(0, RICHCELLHEIGHT)
	end
	if value.title then 
		local layout = XUI.CreateLayout(0, 0, 0, RICHCELLHEIGHT)
		local line_img = XUI.CreateImageViewScale9(250, 0, 500, RICHCELLHEIGHT,ResPath.GetCommon("line_102"), true, cc.rect(169,0,7,0))
		layout:addChild(line_img)
		local img = XUI.CreateImageView(250, RICHCELLHEIGHT, ResPath.GetCommon("img9_159"),true)
		layout:addChild(img)
		local title = XUI.CreateText(0, 0, 233, 0, cc.TEXT_ALIGNMENT_CENTER, value.title, font, font_size, COLOR3B.YELLOW)
		img:addChild(title)
		title:setAnchorPoint(0, 0.5)
		title:setPosition(0, 33*0.5)
		layout:setContentWH(0, RICHCELLHEIGHT + 20)
		line_img:setPosition(250, RICHCELLHEIGHT + 10)
		XUI.RichTextAddElement(rich_content, layout)
	end

	if value.content then 
		local layout = XUI.CreateLayout(0, 0, 0, RICHCELLHEIGHT)
		local title = RichTextUtil.ParseRichText(nil, value.content, 22, value.color or COLOR3B.GREEN)
		title:setIgnoreSize(true)
		layout:addChild(title, 4, 4)
		title:setPosition(0, RICHCELLHEIGHT)
		XUI.RichTextAddElement(rich_content, layout)
	end

	if value.title_line then
		local layout = XUI.CreateLayout(0, 0, 0, RICHCELLHEIGHT+15)
		local line_img = XUI.CreateImageViewScale9(265, 25, 530, 4,ResPath.GetCommon("line_106"), true, cap_rect)
		layout:addChild(line_img, 4)
		local title = RichTextUtil.ParseRichText(nil, value.title_line, 22, COLOR3B.R_Y)
		title:setIgnoreSize(true)
		layout:addChild(title, 4, 4)
		title:setPosition(0, RICHCELLHEIGHT)
		XUI.RichTextAddElement(rich_content, layout)
	end

	if value.equip_data then
		local layout = XUI.CreateLayout(0, 0, 0, RICHCELLHEIGHT+10)	 
		local txt = string.format(value.equip_data.title, value.equip_data.color)
		local title = RichTextUtil.ParseRichText(nil, txt, 22, COLOR3B.R_Y)
		title:setIgnoreSize(true)
		layout:addChild(title, 4, 4)
		title:setPosition(0, RICHCELLHEIGHT+9)
		for k,v in pairs(value.equip_data.imgs) do
			local sprite = XImage:create(v, true)
			if nil ~= sprite then
				sprite:setScale(1)
				sprite:setPosition(60 + (k - 1) * 26, RICHCELLHEIGHT-1)
				layout:addChild(sprite, 99, 99)
			end 
		end
		local txt_1 = string.format(Language.Tip.Percent, value.equip_data.color, value.equip_data.level)

		local title_1 = RichTextUtil.ParseRichText(nil, txt_1, 22, COLOR3B.R_Y)
		title_1:setIgnoreSize(true)
		layout:addChild(title_1, 4, 4)
		title_1:setPosition(50+#value.equip_data.imgs*26 + 5, RICHCELLHEIGHT+10)
		XUI.RichTextAddElement(rich_content, layout)
	end

	if value.hs_data then
		local layout = XUI.CreateLayout(0, 0, 0, RICHCELLHEIGHT)	 
		local sprite = XImage:create(value.hs_data.img, true)
		sprite:setPosition(10, RICHCELLHEIGHT - 12)
		layout:addChild(sprite, 99, 99)
		local content = RichTextUtil.ParseRichText(nil, value.hs_data.hs_txt, 22, value.hs_data.hs_txet_color)
		content:setIgnoreSize(true)
		layout:addChild(content, 4, 4)
		content:setPosition(25, RICHCELLHEIGHT)
		XUI.RichTextAddElement(rich_content, layout)
	end

	if value.label then
		local len = #value.label
		for i = 1, len do
			local temp = value.label[i]
			if temp and temp.key then
				XUI.RichTextAddText(rich_content, temp.key, COMMON_CONSTS.FONT, 22, temp.color or COLOR3B.WHITE)
			end
		end
	end

	if value.dec then
		RichTextUtil.ParseRichText(rich_content, value.dec.key or "", 20, value.dec.color)
		XUI.SetRichTextVerticalSpace(rich_content,RICHCELLHEIGHT - 20)
	end

	if not is_not_global then
		table.insert(self.attrslist, rich_content)
	end

	return rich_content
end

function EquipTip:ShowEquipStamp(show, path)
	path = path or ResPath.GetCommon("stamp_13")
	if show and nil == self.equip_stamp then
		self.equip_stamp = XUI.CreateImageView(420, 35, path)
		self.node_t_list.layout_content_top.node:addChild(self.equip_stamp, 99)
	elseif self.equip_stamp then
		self.equip_stamp:loadTexture(path)
		self.equip_stamp:setVisible(show)
	end
end

function EquipTip:ResetUi()
	if self.scroll_view then
		self.scroll_view:removeFromParent()
		self.scroll_view = nil
	end
	if self.scroll_roll_view then
		self.scroll_roll_view:removeFromParent()
		self.scroll_roll_view = nil
	end
	-- if self.label_expain then
	-- 	self.label_expain:removeFromParent()
	-- 	self.label_expain = nil
	-- end
	-- 情缘装备星星显示移除
	if self.star_list then
		for k, v in pairs(self.star_list) do
			v:removeFromParent()
		end
	end
	self.star_list = {}
	-- self.fabao_rich = nil
	-- if self.fabao_countdown_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.fabao_countdown_quest)
	-- 	self.fabao_countdown_quest = nil
	-- end

	-- if self.prop_curday_valid_countdown_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.prop_curday_valid_countdown_quest)
	-- 	self.prop_curday_valid_countdown_quest = nil
	-- end

	-- 移除星星特效
	-- ParticleEffectSys.Instance:StopEffect("equipstar", true)
end

--根据不同的状态出现不同的按钮
function EquipTip:ShowOperationState()
	local handle_types = self:GetOperationLabelByType(self.fromView)
	if handle_types then
		for k, v in ipairs(self.buttons) do
			local label = self.label_t[handle_types[k]]	--获得文字内容
			if label ~= nil then
				v:setVisible(true)
				v:setTag(handle_types[k])
				v:setTitleText(label)
			else
				v:setVisible(false)
			end
			if handle_types[k] == EquipTip.HANDLE_EQUIP then
				ClientCommonButtonDic[CommonButtonType.EQUIP_TIP_EUQIP_BTN] = v
			end	
		end
	end
end

function EquipTip:GetOperationLabelByType(fromView)
	--print("33333333333333333", fromView)
	local t = {}
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end

	if fromView == EquipTip.FROM_BAG then							--在背包界面中
		if not item_cfg.flags.denyDestroy then
			if self.data.is_bind == 0 then
				t[#t+1] = EquipTip.HANDLE_DISCARD
			else
				t[#t+1] = EquipTip.HANDLE_DESTROY
			end
		end
		if SKILL_BAR_ITEM_LIST[self.data.item_id] then
			t[#t+1] = EquipTip.HANDLE_USE
		end

		-- if EquipmentData.IsStoneEquip(item_cfg.type) and self.limit_level >= STONE_LEVEL_LIMIT then
		-- 	t[#t+1] = EquipTip.HANDLE_INLAY
		-- end
		t[#t+1] = EquipTip.HANDLE_EQUIP
	elseif fromView == EquipTip.FROM_BAG_EQUIP then
		if not EquipData.CannotTakeOffEquip(item_cfg.type) and EquipData.Instance:GetBoolShowBtn(self.data) then
			t[#t+1] = EquipTip.HANDLE_TAKEOFF
		end
		local hand_pos = 0
		if item_cfg.type == ItemData.ItemType.itSpecialRing then
			if item_cfg.useType == 2 or item_cfg.useType == 3 then
				hand_pos = 0
			else
				hand_pos = 1
			end
		else
			hand_pos = EquipmentData.Instance:GetBetterStrengthHandPos(item_cfg.type)
		end
		if EquipmentData.IsStrengthEquip(EquipData.Instance:GetEquipIndexByType(item_cfg.type, hand_pos)) and EquipData.Instance:GetBoolShowBtn(self.data)
		and item_cfg.type ~= ItemData.ItemType.itWarRunePos then
			t[#t+1] = EquipTip.HANDLE_STRENGTHEN
		end
		if ViewManager.Instance:CanShowUi(ViewName.Equipment, TabIndex.equipment_gemstone) and not EquipData.CannotTakeOffEquip(item_cfg.type) 
			and item_cfg.type ~= ItemData.ItemType.itWarRunePos then
			t[#t+1] = EquipTip.HANDLE_INLAY
		end
		-- if item_cfg.suitLevel and item_cfg.suitLevel > 0 then
		-- 	t[#t+1] = EquipTip.HANDLE_SUITEQUIP
		-- end
	elseif fromView == EquipTip.FROM_BAG_ON_GUILD_STORAGE then
		if not item_cfg.flags.denyDestroy then
			t[#t+1] = EquipTip.HANDLE_DISCARD
		end
		if SKILL_BAR_ITEM_LIST[self.data.item_id] then
			t[#t+1] = EquipTip.HANDLE_USE
		end
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_BAG_ON_BAG_STORAGE then
		if not item_cfg.flags.denyDestroy then
			t[#t+1] = EquipTip.HANDLE_DISCARD
		end
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_STORAGE_ON_GUILD_STORAGE then
		if not RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_COMMON) then
			-- 除了行会普通成员外，其它职位均可摧毁行会仓库物品
			t[#t+1] = EquipTip.HANDLE_DESTROY
		end
		t[#t+1] = EquipTip.HANDLE_EXCHANGE
	elseif fromView == EquipTip.FROM_STORAGE_ON_BAG_STORAGE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	-- elseif fromView == EquipTip.FROM_HERO_EQUIP and EquipData.Instance:GetBoolShowBtn(self.data) then
	-- 	t[#t+1] = EquipTip.HANDLE_TAKEOFF
	elseif fromView == EquipTip.FROM_BAG_ON_RECYCLE then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_RECYCLE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_CONSIGN_ON_SELL then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_CONSIGN_ON_BUY then
		if not ConsignData.Instance:GetItemSellerIsMe(self.data) then
			t[#t+1] = EquipTip.HANDLE_BUY
		end
	elseif fromView == EquipTip.FROM_XUNBAO_BAG then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_CHAT_BAG then
		t[#t+1] = EquipTip.HANDLE_SHOW
	elseif fromView == EquipTip.FROM_EXCHANGE_BAG then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_HERO_BAG then
		t[#t+1] = EquipTip.HANDLE_EQUIP
	elseif fromView == EquipTip.FROM_HERO_EQUIP then
		t[#t+1] = EquipTip.HANDLE_TAKEOFF
		t[#t+1] = EquipTip.HANDLE_STRENGTHEN
	end
		
	return t
end

function EquipTip:OperationClickHandler(psender)
	if self.data == nil then
		return
	end
	self.handle_type = psender:getTag()
	if self.handle_type == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end

	TipsCtrl.Instance:UseItem(self.handle_type, self.data, self.handle_param_t, self.fromView)
 	self:Close()
end

function EquipTip:DoLayout()
	local offset_x = 62
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	if self.my_equip_tip and self.my_equip_tip:IsOpen() then			--装备对比
		self.root_node:setPosition(cc.pAdd(VisibleRect:left(), cc.p(screen_w / 2 + 290, 0)))
	elseif self.fromView == EquipTip.FROM_EQUIP_COMPARE or self.fromView == EquipTip.FROM_HERO_COMPARE then 			--对比装备
		self.root_node:setPosition(cc.pAdd(VisibleRect:left(), cc.p(screen_w / 2 - 236, 0)))
	elseif self.fromView == EquipTip.FROM_BAG then						--在背包界面中（没有打开仓库和出售）
		self.root_node:setPosition(cc.pAdd(VisibleRect:left(), cc.p(GetCenterPoint(self.root_node).x +500- offset_x, 0)))
	elseif self.fromView == EquipTip.FROM_BAG_ON_BAG_STORAGE then		--打开仓库界面时，来自背包
		self.root_node:setPosition(cc.pAdd(VisibleRect:left(), cc.p(GetCenterPoint(self.root_node).x + 135 - offset_x, 0)))
	elseif self.fromView == EquipTip.FROM_STORAGE_ON_BAG_STORAGE then	--打开仓库界面时，来自仓库
		self.root_node:setPosition(cc.pAdd(VisibleRect:right(), cc.p(-GetCenterPoint(self.root_node).x - 135 - offset_x, 0)))
	elseif self.fromView == EquipTip.FROM_BAG_ON_BAG_SALE then		--打开售卖界面时，来自背包
		self.root_node:setPosition(cc.pAdd(VisibleRect:left(), cc.p(GetCenterPoint(self.root_node).x + 135 - offset_x, 0)))
	elseif self.fromView == EquipTip.FROM_BAG_EQUIP then				--打开装备界面时，来自装备
		self.root_node:setPosition(cc.pAdd(VisibleRect:right(), cc.p(-GetCenterPoint(self.root_node).x - 135 - offset_x, 0)))
	else
		self.root_node:setPosition(screen_w / 2, screen_h / 2)
	end
end

-- function EquipTip:ClickRecycleHandle()
-- 	self.alert_window:OnClickOK()
-- 	self.record_guide_operate_type = -1
-- end

-- function EquipTip:OpenPanelByName(panel_name)
-- 	if self.data and self.data.item_id == COMMON_CONSTS.GuildTanheItemId and RoleData.Instance.role_vo.guild_id == 0 then
-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
-- 		return
-- 	end
	
-- 	local item_id = nil
-- 	if self.data then
-- 		item_id = self.data.item_id
-- 	end
-- 	FunOpen.Instance:OpenViewNameByCfg(panel_name, item_id)
-- end

function EquipTip.GetEquipName(equip_cfg, equip_data, fromView)
	local name = equip_cfg.name
	if equip_data.office_level and equip_data.office_level > 0 then
		local prof = ComposeData.GetOfficeProf(equip_data.item_id)
		local office_cfg = ComposeData.GetOfficeItemCfg(equip_data.office_level, prof)
		if office_cfg then
			name = office_cfg.name .. Language.Compose.Suffix
		end
	end
	return name
end