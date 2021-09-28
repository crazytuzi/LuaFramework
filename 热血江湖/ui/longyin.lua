module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_longyin = i3k_class("wnd_longyin", ui.wnd_base)

local LAYER_LYL	= "ui/widgets/lyt1"
local LAYER_LYS	= "ui/widgets/lyt2"
local LAYER_LYT	= "ui/widgets/lyt3"
local LAYER_DEV = "ui/widgets/lyt4"
local COLOR1 = "ffb2ffda"
local COLOR2 = "ff67d3a2"

local WIDGETSXZ = "ui/widgets/lyjst"
local WIDGETSXH = "ui/widgets/lyjstjt"
local OKICON = 4688
local NOICON = 4689
local lvlTable = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十","十一","十二"}


function wnd_longyin:ctor()
	self.needItem = {}
	self.showType = 1
	self.needItemId = {  }
	self.needItemConunt = { }
	self.data = {}        --技能数据
	self.lvl = nil        --现在的等级
	self.propertyId = {}
	self.propertyCount = {}
	self._timeCount = 0
	self._compoundNeedInfo = {}
	self._unlockFlag = true
end

function wnd_longyin:configure()
	local widgets = self._layout.vars
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI, function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "updateRolePower")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy, "updateRolePower")
		g_i3k_ui_mgr:CloseUI(eUIID_UnlockHunyu)
	end)
	self.scroll   = widgets.scroll
	self.scroll2  = widgets.scroll2
	self.upLvlBtn = widgets.upBtn
	self.loseBtn = widgets.loseBtn
	self.saveBtn = widgets.saveBtn
	self.isShow = widgets.isShow
    self.lyLvl = widgets.pracLvlLabel
	--self.item_bg = widgets.item_bg
	--self.item_iron = widgets.item_iron
	self.item_name = widgets.item_name
	self.allItem = widgets.allItem
	self.btnLabel = widgets.btnLabel
	--self.leftIron = widgets.leftIron
	--self.rightIron = widgets.rightIron
	self.level = widgets.level
	self.red_point1 = widgets.red_point1
	self.red_point2 = widgets.red_point2
	self.animation = widgets.animation
	for i=1, 4 do
		local prac = "prac"..i
		local pracNameLabel = "pracNameLabel"..i
		local pracGradeIcon = "pracGradeIcon"..i
		local pracIcon = "pracIcon"..i
		local pracLock = "pracLock"..i
		local pracCountLabel = "pracCountLabel"..i
		local pracBtn = "pracBtn"..i
		self.needItem[i] = {
			prac	        = widgets[prac],
			pracNameLabel   = widgets[pracNameLabel],
			pracGradeIcon	= widgets[pracGradeIcon],
			pracIcon	    = widgets[pracIcon],
			pracLock	    = widgets[pracLock],
			pracCountLabel	= widgets[pracCountLabel],
			pracBtn	        = widgets[pracBtn],
		}
	end

	local argData = i3k_db_LongYin_arg
	local xlNeedItemId = {}
	local xlNeedItemConunt = {}
	local countNow = 0
	for k=1,4 do
		xlNeedItemId[k] = argData.needItems["needItem" .. k .. "ID"]
		xlNeedItemConunt[k] = argData.needItems["needItem" .. k .. "Count"]
		if xlNeedItemId[k] ~= 0 then
			countNow = countNow + 1
		end
	end
	local item = {itemId = xlNeedItemId, itemCount = xlNeedItemConunt, count = countNow}
	self._layout.vars.upSkillBtn:onClick(self,self.isCanUpLvlBtn, item)
	self._layout.vars.upSkillBtn2:onClick(self,self.isCanUpLvlBtn2, item)

	self.sxBtn = widgets.role_btn
	self.xlBtn = widgets.xl_btn
	self.sxBtn:stateToPressed()
	self.sxBtn:onClick(self,self.shuXingBtn)
	self._layout.vars.jzRoot:hide()

	widgets.fulingBtn:onClick(self, self.onFulingBtn)
	widgets.heishi:onClick(self, self.buyItem)
	widgets.jiesuobt:onClick(self, self.isHaveItem)	
end

function wnd_longyin:onUpdate(dTime)
	self._timeCount = self._timeCount + dTime
	if self._timeCount > 60 then
		self._timeCount = 0
		self:updateTimeLabel()
	end
end

function wnd_longyin:refresh()
	local lvlNow = g_i3k_game_context:GetIsHeChengLongYin()
	if lvlNow ~= 0 then
		self:updateHunYuState(true)
		self:refreshHunYuInfo(lvlNow)
	else
		self:updateHunYuState(false)
		self:updateCompoundHunYuunLockInfo()
	end
end
function wnd_longyin:updateHunYuState(value)
	local weight = self._layout.vars
	weight.role_btn:setVisible(value)
	weight.xl_btn:setVisible(value)
	weight.jz_btn:setVisible(value)
	weight.fulingBtn:setVisible(value)
	weight.zhanli:setVisible(value)
	weight.lyname1:setVisible(value)	
	weight.jiesuo:setVisible(not value)
	weight.lyname:setVisible(not value)	
end

function wnd_longyin:updateCompoundHunYuunLockInfo()
	if g_i3k_game_context:GetIsHeChengLongYin() ~= 0 then --AddItem刷新限制
		return
	end
	
	local weight = self._layout.vars
	self:showModel(0)
	weight.item_name2:setText(i3k_db_LongYin_arg.args.itemName)
	weight.scroll5:removeAllChildren()
	weight.scroll5:stateToNoSlip()
	local xzTables = {}	
	local needArg = i3k_db_LongYin_arg.openNeed
	local needLevel = needArg.needLvl
	local needPowerNow = needArg.needPower
	local needTransLvl = needArg.needTransLvl
	local NowLevel = g_i3k_game_context:GetLevel()
	local NowPower = g_i3k_game_context:GetRolePower()
	local NowVocation = g_i3k_game_context:GetTransformLvl()
	local str = i3k_get_string(396, needLevel)
	local value = NowLevel >= needLevel
	table.insert(xzTables, {text = str, flag = value})
	str = i3k_get_string(397, needPowerNow)
	value = NowPower >= needPowerNow
	table.insert(xzTables, {text = str, flag = value})
	str = i3k_get_string(398, i3k_get_string(409))
	value = NowVocation >= needTransLvl
	table.insert(xzTables, {text = str, flag = value})	

	for _, v in ipairs(xzTables) do
		local _layer = require(WIDGETSXZ)()	
		local node = _layer.vars
		node.pracCountLabel:setText(v.text)
		local id = v.flag and OKICON or NOICON
		node.image:setImage(g_i3k_db.i3k_db_get_icon_path(id))
		weight.scroll5:addItem(_layer)
		
		if not v.flag then
			self._unlockFlag = false
		end
	end
	
	local com = i3k_db_LongYin_arg.compose
	
	for i = 1, 4 do		
		self._compoundNeedInfo[i] = {id = com["needItem" .. i .."ID"], count = com["needItem" .. i .."Count"]}
	end
	
	weight.sxScroll2:removeAllChildren()
	for _, v in ipairs(self._compoundNeedInfo) do
		if v.id ~= 0 and v.count ~= 0 then
			local _layer = require(WIDGETSXH)()	
			local node = _layer.vars
			local ironImage = g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole())
			local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
			local cfg = g_i3k_db.i3k_db_get_common_item_cfg(v.id) 
			node.pracIcon:setImage(ironImage)
			node.pracGradeIcon:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.id)))
			--self.needItem[i].item_name:setText(cfg.name)
			node.suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(v.id))
			--self.needItem[i].item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(self.needArgsItemID[i])))
			local showtext = canUseCount .. "/" .. v.count
			node.pracCountLabel:setText(showtext)
			node.pracCountLabel:setTextColor(g_i3k_get_cond_color(canUseCount >= v.count))
			node.pracBtn:onClick(self, self.clickItem, v.id)
			weight.sxScroll2:addItem(_layer)
		end
	end
end

function wnd_longyin:buyItem(sender)
	if not self._unlockFlag then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1093))
		return
	end
	
	local money = i3k_db_LongYin_arg.compose.composeNeedMoney	
	local descText = i3k_get_string(414, money)
	
	local function callback(isOk)
		if isOk then
			if g_i3k_game_context:GetDiamondCanUse(false) >= money then
				local callfunc = function ()
					g_i3k_game_context:UseDiamond(money, false, AT_SEAL_DIAMOND_MAKE)
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(412))
				end
				
				i3k_sbean.goto_seal_make(2, callfunc)
				return true
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(415))
				return false
			end
		end
	end
	
	g_i3k_ui_mgr:ShowMessageBox2(descText, callback)
end

function wnd_longyin:isHaveItem(sender)
	if not self._unlockFlag then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1093))
		return
	end
	
	local flag = true
	
	for _, v in ipairs(self._compoundNeedInfo) do
		if v.id ~= 0 and v.count ~= 0 then
			local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
			
			if v.count > canUseCount then
				flag = false
			end
		end
	end
	
	if flag then
		local callfunc = function ()
			for _, v in ipairs(self._compoundNeedInfo) do
				if v.id ~= 0 and v.count ~= 0 then
					g_i3k_game_context:UseCommonItem(v.id, v.count, AT_SEAL_NORMAL_MAKE)
				end
			end

			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(412))
		end
		
		i3k_sbean.goto_seal_make(1, callfunc)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(413))
	end
end

function wnd_longyin:refreshHunYuInfo(lvlNow)
	self._layout.vars.item_name:setText(i3k_db_LongYin_arg.args.itemName)
	self:LongYinUpLevel(lvlNow)
	self.xlBtn:onClick(self,self.xiLianBtn, {lvlNow = lvlNow, info = g_i3k_game_context:GetLongYinInfo()})
	-- 如果是圆满则使用新模型
	self:setModelYuanman()
	self:checkShowFulingBtn()
	self:onChangeToFulingUI(false)
	self:updateFulingRedPoint()
end

function wnd_longyin:LongYinUpLevel(lvlNow)   --升阶
	self:updateBanedBtnState()
	self.red_point1:setVisible(g_i3k_game_context:GetLongYinRedpoint())
	self.red_point2:setVisible(g_i3k_game_context:GetLongYinRedpoint2())
	local isOpen = g_i3k_game_context:GetIsHeChengLongYin()
	local quality
	if isOpen ~= 0 then
		quality = g_i3k_game_context:GetLongYinQuality(isOpen)
	end
	self.item_name:setTextColor(g_i3k_get_color_by_rank(quality or 1))
	local UpLvlcfg = i3k_db_LongYin_UpLvl
	local i
	self.level:setText(lvlTable[lvlNow] .. "阶")
	if lvlNow < #UpLvlcfg then
		i = lvlNow + 1
	else
		i = lvlNow
	end
	self.lvl = lvlNow
	self:setItemScrollData(lvlNow, UpLvlcfg)
	self.animation:hide()
	self:showModel(lvlNow)
	self:setModelYuanman()
	if lvlNow == #UpLvlcfg then
		self:shuXingmaxLvl() --满级
		self._layout.vars.sxRoot:show()
		self._layout.vars.xlRoot:hide()
		self._layout.vars.xltRoot:hide()
	else
		self:refreshScrollData()
	end

end

function wnd_longyin:refreshScrollData()
	if g_i3k_game_context:GetIsHeChengLongYin() == 0 then
		return
	end
	
	local isPressedBysx = self.sxBtn:isStatePressed()
	local isPressedByxl = self.xlBtn:isStatePressed()
	if isPressedBysx then
		self._layout.vars.sxRoot:show()
		self._layout.vars.xlRoot:hide()
		self._layout.vars.xltRoot:hide()
		local UpLvlcfg = i3k_db_LongYin_UpLvl
		local i
		if self.lvl < #UpLvlcfg then
			i = self.lvl + 1
		else
			i = self.lvl
		end
		local countNow = 0
		self._layout.vars.sxScroll:removeAllChildren()
		for k=1, 4 do
			self.needItemId[k] = UpLvlcfg[i]["needItemId" .. k]
			self.needItemConunt[k] = UpLvlcfg[i]["needItemConunt" .. k]
			--self.needItem[k].prac:hide()
			if self.needItemId[k] ~= 0 then
				local layer = require(LAYER_LYT)()
				local widget = layer.vars
				--self.needItem[k].prac:show()
				local ironImage = g_i3k_db.i3k_db_get_common_item_icon_path(self.needItemId[k], g_i3k_game_context:IsFemaleRole())
				local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(self.needItemId[k])
				local cfg = g_i3k_db.i3k_db_get_common_item_cfg(self.needItemId[k])
				--self.needItem[k].pracNameLabel:setText(cfg.name)
				--self.needItem[k].pracNameLabel:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(self.needItemId[k])))
				widget.pracIcon:setImage(ironImage)
				widget.pracGradeIcon:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(self.needItemId[k])))
				--self.needItem[k].pracLock:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(self.needItemId[k]))
				local showtext = (self.needItemId[k] == g_BASE_ITEM_COIN or self.needItemId[k] == -g_BASE_ITEM_COIN) and self.needItemConunt[k] or canUseCount .. "/" .. self.needItemConunt[k]
				widget.pracCountLabel:setText(showtext)
				widget.pracCountLabel:setTextColor(g_i3k_get_cond_color(canUseCount >= self.needItemConunt[k]))
				widget.pracBtn:onClick(self, self.clickItem, self.needItemId[k])
				countNow = countNow + 1
				self._layout.vars.sxScroll:addItem(layer)
			end

		end
		self.upLvlBtn:onClick(self,self.isCanUpLvlBtn, {itemId = self.needItemId, itemCount = self.needItemConunt, count = countNow, lvlNow = self.lvl})
	elseif isPressedByxl then
		self:LongYinUpSkill()
	end

end

function wnd_longyin:getNeedItem(lvl, UpLvlcfg)
	local propertyId = {}
	local propertyCount = {}
	for k=1, 6 do
		propertyId[k] 	 = UpLvlcfg[lvl]["propertyId" .. k]
		propertyCount[k] = UpLvlcfg[lvl]["propertyCount" .. k]
	end
	return propertyId, propertyCount
end
function wnd_longyin:setItemScrollData(lvlNow, UpLvlcfg)
	self.scroll:removeAllChildren()
	self.propertyId, self.propertyCount = self:getNeedItem(lvlNow, UpLvlcfg)
	local info = g_i3k_game_context:getRoleSealAwaken()
	local rank = info.rank - 1
	local percent = 0
	if i3k_db_LongYin_ban[rank] then
		for i = 1, rank do
			percent = i3k_db_LongYin_ban[i].propPercent / 10000 + percent
		end
	end
	local devide = require(LAYER_DEV)()
	self.scroll:addItem(devide)
	for k=1,#self.propertyId do
		if self.propertyId[k] ~= 0 then
			local _layer = require(LAYER_LYL)()
			local widget = _layer.vars
			widget.nameLabel1:setText(i3k_db_prop_id[self.propertyId[k]].desc..":")
			widget.iron:setImage(g_i3k_db.i3k_db_get_property_icon_path(self.propertyId[k]))
			local attr = ""
			if percent ~= 0 then
				attr = " + "..i3k_get_prop_show(self.propertyId[k], self.propertyCount[k]* percent)
			end
			widget.attrLabel1:setText(i3k_get_prop_show(self.propertyId[k],self.propertyCount[k])..attr)
			self.scroll:addItem(_layer)
		end
	end
	self:addBanPropToScroll()
	self:addFulingPropToScroll()
	--self:updateWidgetBg()
	self:showPower()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "refreshLongYinRedPoint")
end

function wnd_longyin:addBanPropToScroll()
	local prop = g_i3k_game_context:getAwakenBanProp()
	local devide = require(LAYER_DEV)()
	devide.vars.name:setText("禁制解封属性")
	local count = 0
	for k, v in pairs(prop) do
		count = count + 1
	end
	if count > 0 then
		self.scroll:addItem(devide)
	end

	for k, v in pairs(prop)do
		local _layer = require(LAYER_LYL)()
		local widget = _layer.vars
		widget.nameLabel1:setText(i3k_db_prop_id[k].desc..":")
		widget.iron:setImage(g_i3k_db.i3k_db_get_property_icon_path(k))
		widget.attrLabel1:setText(i3k_get_prop_show(k ,v))
		self.scroll:addItem(_layer)
	end
end

function wnd_longyin:addFulingPropToScroll()
	local prop = g_i3k_game_context:getAllFulingProps()
	local devide = require(LAYER_DEV)()
	devide.vars.name:setText("附灵属性")
	local count = 0
	for k, v in pairs(prop) do
		count = count + 1
	end
	if count > 0 then
		self.scroll:addItem(devide)
	end
	local sortProps = g_i3k_db.i3k_db_sort_props(prop)

	for k, v in ipairs(sortProps)do
		if v.value ~= 0 then
			local _layer = require(LAYER_LYL)()
			local widget = _layer.vars
			widget.iron:setImage(g_i3k_db.i3k_db_get_property_icon_path(v.id)) -- 属性图标
			widget.nameLabel1:setText(i3k_db_prop_id[v.id].desc..":")
			widget.attrLabel1:setText(i3k_get_prop_show(v.id, v.value))
			self.scroll:addItem(_layer)
		end
	end
end

function wnd_longyin:LongYinUpSkill(sender)
	if sender then
		local tmp = {}
		g_i3k_game_context:SetNewLongYinSkills(tmp)
	end
	local newSkills = g_i3k_game_context:GetNewLongYinSkills()
	if next(newSkills) then
		self:chooseSkills()
		return
	end
	self._layout.vars.sxRoot:hide()
	self._layout.vars.xlRoot:show()
	self._layout.vars.xltRoot:hide()
	local skills = g_i3k_game_context:GetLongYinSkills()
	local argData = i3k_db_LongYin_arg
	self.red_point1:setVisible(g_i3k_game_context:GetLongYinRedpoint())
	self.red_point2:setVisible(g_i3k_game_context:GetLongYinRedpoint2())
	self.scroll2:removeAllChildren()
	self._layout.vars.xlScroll:removeAllChildren()
	--local power = g_i3k_game_context:GetRoleLongyinPower()
	--self.rightIron:setImage(g_i3k_db.i3k_db_get_icon_path(1840))
	--self.leftIron:setImage(g_i3k_db.i3k_db_get_icon_path(1838))
	--local skillID = data.skills.skillID
	for k,v in pairs(skills) do
		local _layer = require(LAYER_LYS)()
		local widget = _layer.vars
		local icon = i3k_db_skills[k].icon
		widget.skillIron:setImage(g_i3k_db.i3k_db_get_icon_path(icon),g_i3k_db.i3k_db_get_icon_path(icon))
		widget.nameLabel1:setText(i3k_db_skills[k].name)
		widget.attrLabel1:setText(i3k_get_string(399,v))
		widget.attrLabel1:setTextColor(g_i3k_get_color_by_rank(i3k_db_LongYin_arg.maxSkill["lvl"..v]))
		widget.shillBg:onClick(self, self.onSkillTips, k)
		self.scroll2:addItem(_layer)
	end
	local xlNeedItemId = {}
	local xlNeedItemConunt = {}
	local countNow = 0
	for k=1,4 do
		xlNeedItemId[k] = argData.needItems["needItem" .. k .. "ID"]
		xlNeedItemConunt[k] = argData.needItems["needItem" .. k .. "Count"]
		--self.needItem[k].prac:setVisible(xlNeedItemId[k] ~= 0);
		if xlNeedItemId[k] ~= 0 then
			local layer = require(LAYER_LYT)()
			local widget = layer.vars
			local ironImage = g_i3k_db.i3k_db_get_common_item_icon_path(xlNeedItemId[k], g_i3k_game_context:IsFemaleRole())
			local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(xlNeedItemId[k])
			local cfg = g_i3k_db.i3k_db_get_common_item_cfg(xlNeedItemId[k])
			--widget.pracNameLabel:setText(cfg.name)
			--widget.pracNameLabel:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(xlNeedItemId[k])))
			widget.pracIcon:setImage(ironImage)
			widget.pracGradeIcon:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(xlNeedItemId[k])))
			--widget.pracLock:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(xlNeedItemId[k]))
			local showtext = (xlNeedItemId[k] == g_BASE_ITEM_COIN or xlNeedItemId[k] == -g_BASE_ITEM_COIN) and xlNeedItemConunt[k] or canUseCount .. "/" .. xlNeedItemConunt[k]
			widget.pracCountLabel:setText(showtext)
			widget.pracCountLabel:setTextColor(g_i3k_get_cond_color(canUseCount >= xlNeedItemConunt[k]))
			widget.pracBtn:onClick(self, self.clickItem, xlNeedItemId[k])
			self._layout.vars.xlScroll:addItem(layer)
			countNow = countNow + 1
		end
	end
	--local item = {itemId = xlNeedItemId, itemCount = xlNeedItemConunt, count = countNow}
	--self._layout.vars.upSkillBtn:onClick(self,self.isCanUpLvlBtn, item)
	--self._layout.vars.upSkillBtn2:onClick(self,self.isCanUpLvlBtn2, item)
end

function wnd_longyin:isCanUpLvlBtn2(sender, item)
	local message = self:getMessageText2()
	if message then
		local callback = function(ok)
			if ok then
				self:isCanUpLvlBtn(sender, item)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(message, callback)
	else
		self:isCanUpLvlBtn(sender, item)
	end
end

function wnd_longyin:isCanUpLvlBtn(sender, item)
	local itemCount = item.itemCount
	local itemId = item.itemId
	local haveCount = item.count
	local count = 0
	for i=1,haveCount do
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(itemId[i])
		if itemCount[i] <= canUseCount then
			count = count + 1
		end
	end
	if count == haveCount then
		local callfunc = function ()
			for i=1,haveCount do
				if item.count then
					g_i3k_game_context:UseCommonItem(itemId[i], itemCount[i],AT_SEAL_UPGRADE)
				else
					g_i3k_game_context:UseCommonItem(itemId[i], itemCount[i],AT_SEAL_ENHANCE)
				end
			end
		end
		if item.lvlNow then
			i3k_sbean.goto_seal_upgrade(callfunc,self.lvl + 1)                     --升阶协议
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(400))
		else
			i3k_sbean.goto_seal_enhance(callfunc)                     --洗练协议
			--i3k_sbean.seal_save_enhance(callfunc)
			--g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(401))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(402))
	end
end

function wnd_longyin:chooseSkills()
	self._layout.vars.sxRoot:hide()
	self._layout.vars.xlRoot:hide()
	self._layout.vars.xltRoot:show()
	--self.rightIron:setImage(g_i3k_db.i3k_db_get_icon_path(2860))
	--self.leftIron:setImage(g_i3k_db.i3k_db_get_icon_path(2861))
	self._layout.vars.scroll3:removeAllChildren()
	self._layout.vars.scroll4:removeAllChildren()
	local tab = {}
	tab.skills = g_i3k_game_context:GetLongYinSkills()
	tab.newSkills = g_i3k_game_context:GetNewLongYinSkills()
	for i,e in pairs(tab) do
		for k,v in pairs(e) do
			local _layer = require(LAYER_LYS)()
			local widget = _layer.vars
			local icon = i3k_db_skills[k].icon
			widget.skillIron:setImage(g_i3k_db.i3k_db_get_icon_path(icon),g_i3k_db.i3k_db_get_icon_path(icon))
			widget.nameLabel1:setText(i3k_db_skills[k].name)
			widget.attrLabel1:setText(i3k_get_string(399,v))
			widget.attrLabel1:setTextColor(g_i3k_get_color_by_rank(i3k_db_LongYin_arg.maxSkill["lvl"..v]))
			widget.shillBg:onClick(self, self.onSkillTips, k)
			if i=="skills" then
				self._layout.vars.scroll3:addItem(_layer)
			else
				self._layout.vars.scroll4:addItem(_layer)
			end
		end
	end
	self.saveBtn:onClick(self, self.upSkillBtn)
	self.loseBtn:onClick(self, self.giveupNewSkill)
end

function wnd_longyin:getMessageText()                  -----舍弃选项二次提示文本
	local message = nil
	local skills = g_i3k_game_context:GetLongYinSkills()
	local newSkills = g_i3k_game_context:GetNewLongYinSkills()
	local isHaveYellow = false
	local isAllPurple = true
	local isBetter = false
	local allSkillLvl = 0
	local allNewSkillLvl = 0
	for i, v in pairs(newSkills) do
		allNewSkillLvl = allNewSkillLvl + v
		if v >= 9 then
			isHaveYellow = true
		end
		if v < 7 then
			isAllPurple = false
		end
	end

	for i, v in pairs(skills) do
		allSkillLvl = allSkillLvl + v
	end
	if isHaveYellow then
		message = i3k_get_string(16894)
	end
	if isAllPurple then
		message = i3k_get_string(16895)
	end
	if allNewSkillLvl >= allSkillLvl then
		message = i3k_get_string(16896)
	end
	return message
end

function wnd_longyin:getMessageText2()
	local message = nil
	local skills = g_i3k_game_context:GetLongYinSkills()
	local newSkills = g_i3k_game_context:GetNewLongYinSkills()
	local isHaveYellow = false
	local isAllPurple = true
	local isBetter = false
	local allSkillLvl = 0
	local allNewSkillLvl = 0
	for i, v in pairs(newSkills) do
		allNewSkillLvl = allNewSkillLvl + v
		if v >= 9 then
			isHaveYellow = true
		end
		if v < 7 then
			isAllPurple = false
		end
	end

	for i, v in pairs(skills) do
		allSkillLvl = allSkillLvl + v
	end
	if isHaveYellow then
		message = i3k_get_string(16903)
	end
	if isAllPurple then
		message = i3k_get_string(16904)
	end
	if allNewSkillLvl >= allSkillLvl then
		message = i3k_get_string(16905)
	end
	return message
end

function wnd_longyin:giveupNewSkill(sender)
	local message = self:getMessageText()
	if message then
		local callback = function(ok)
			if ok then
				self:LongYinUpSkill(sender)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(message, callback)
	else
		self:LongYinUpSkill(sender)
	end
end

function wnd_longyin:upSkillBtn(sender)
	local callback = function(ok)
		if ok then
			i3k_sbean.seal_save_enhance(1)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16897), callback)
end

function wnd_longyin:shuXingBtn(sender)
	local lvlNow = g_i3k_game_context:GetIsHeChengLongYin()
	self.btnLabel:setText(i3k_get_string(403))
	self.xlBtn:stateToNormal()
	self.sxBtn:stateToPressed()
	self._layout.vars.jz_btn:stateToNormal()
	self._layout.vars.jzRoot:hide()
	self:LongYinUpLevel(lvlNow)
	self._layout.vars.yuanman:hide()
	self:setModelYuanman()
	self:onChangeToFulingUI(false)
end

function wnd_longyin:xiLianBtn(sender, data)
	local info = data.info
	local lvlNow = data.lvlNow
	local skills = g_i3k_game_context:GetLongYinSkills()
	if self.lvl >= 3 then
		if self.red_point2:isVisible() then
			self.red_point2:hide()
			g_i3k_game_context:setLongYinPracticeRedPoint(false) --魂玉洗练红点优化，点开就不显示了
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "refreshLongYinRedPoint")
			g_i3k_game_context:RefreshBagIsFull()
		end
		self.scroll:removeAllChildren()
		self.animation:hide()
		self.btnLabel:setText(i3k_get_string(405))
		self.sxBtn:stateToNormal()
		self.xlBtn:stateToPressed()
		self._layout.vars.jz_btn:stateToNormal()
		self._layout.vars.jzRoot:hide()
		self:LongYinUpSkill()
		self._layout.vars.yuanman:hide()
		self:setModelYuanman()
		self:onChangeToFulingUI(false)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(404))
	end
end

function wnd_longyin:shuXingmaxLvl()
	self._layout.vars.sxExpend:hide()
	self._layout.vars.upBtn:hide()
	self.animation:show()
	self._layout.anis.c_max.play()
	--g_i3k_ui_mgr:PopupTipMessage("恭喜您，成功升至满级")
end

function wnd_longyin:showPower()
	local propertyTb = {}
	for i=1,#self.propertyId do
		propertyTb[self.propertyId[i]] = self.propertyCount[i]
	end
	local power =  g_i3k_game_context:GetRoleLongyinPower()
	local banPower = g_i3k_game_context:getAwakenProp()
	power = power + g_i3k_db.i3k_db_get_battle_power(propertyTb) + g_i3k_db.i3k_db_get_battle_power(banPower)
	local props = g_i3k_game_context:getAllFulingProps()
	power = g_i3k_db.i3k_db_get_battle_power(props) + power
	self.lyLvl:setText(power)
end

function wnd_longyin:updateWidgetBg()
	local all_child = self.scroll:getAllChildren()
	for i, e in pairs(all_child) do
		local widget = e.vars
		widget.propertyBg2:hide()
		widget.propertyBg1:hide()
		if i%2 ~= 0 then
			widget.propertyBg1:show()
			widget.nameLabel1:setTextColor(COLOR2)
			widget.attrLabel1:setTextColor(COLOR2)
		else
			widget.propertyBg2:show()
			widget.nameLabel1:setTextColor(COLOR1)
			widget.attrLabel1:setTextColor(COLOR1)
		end
	end
end

function wnd_longyin:showModel(level)
	local id = i3k_db_LongYin_UpLvl[level] and i3k_db_LongYin_UpLvl[level].modelID or i3k_db_LongYin_arg.args.unLockmodelID 
	local path = i3k_db_models[id].path
	local uiscale = i3k_db_models[id].uiscale
	self._layout.vars.model:setSprite(path)
	self._layout.vars.model:setSprSize(uiscale)
	for _,e in ipairs(i3k_db_LongYin_arg.args.actionList) do
		self._layout.vars.model:pushActionList(e,1)
	end
	self._layout.vars.model:pushActionList("stand",-1)
	self._layout.vars.model:playActionList()
end

function wnd_longyin:setModelYuanman()
	if self:checkIsYuanman() then
		local npcmodule = self._layout.vars.model
		local modelID = i3k_db_LongYin_UpLvl[1].unlockModelID
		ui_set_hero_model(npcmodule, modelID)
	end
end

function wnd_longyin:onSkillTips(sender, id)
	g_i3k_ui_mgr:OpenUI(eUIID_TransfromSkillTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_TransfromSkillTips,id)
end

function wnd_longyin:clickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

--[[function wnd_longyin:onClose(sender)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "updateRolePower")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy, "updateRolePower")
	g_i3k_ui_mgr:CloseUI(eUIID_LongYin)

end--]]

----------------魂玉二期需求begin---------------------
function wnd_longyin:updateBanedBtnState()
	local lvlNow = g_i3k_game_context:GetIsHeChengLongYin()
	local showLevel = i3k_db_LongYin_arg.hunyuWenyang.visiableLevel
	self._layout.vars.jz_btn:setVisible(lvlNow >= showLevel)
	self._layout.vars.red_point3:setVisible(lvlNow >= showLevel and g_i3k_game_context:GetLongYinRedpoint3() or g_i3k_game_context:jingxiuUnlock())--禁制红点
	self._layout.vars.jz_btn:onClick(self, self.onJinZhiBtn)
end
function wnd_longyin:onJinZhiBtn(sender)
	local unlockLevel = i3k_db_LongYin_arg.hunyuWenyang.unlockLevel
	local lvlNow = g_i3k_game_context:GetIsHeChengLongYin()
	if lvlNow < unlockLevel then
		g_i3k_ui_mgr:PopupTipMessage("你隐隐觉察出魂玉中蕴藏的奥秘，似乎达到"..unlockLevel.."阶后方可知晓")
		return
	end
	--self._layout.vars.red_point3:setVisible(g_i3k_game_context:GetLongYinRedpoint3() or self:jingxiuUnlock())--禁制红点
	self:updateJinZhiUI()
	self:onChangeToFulingUI(false)
end

function wnd_longyin:updateJinZhiUI()
	
	self.xlBtn:stateToNormal()
	self.sxBtn:stateToNormal()
	local widgets = self._layout.vars
	widgets.jz_btn:stateToPressed()
	widgets.xlRoot:hide()
	widgets.sxRoot:hide()
	widgets.jzRoot:show()
	widgets.xltRoot:hide()
	widgets.animation:hide()
	self:updateLongyinRightView()
	self:updateZhufuBtn()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "refreshLongYinRedPoint")
end
-- 更新紧制 里面ui控件的通用方法
function wnd_longyin:changeContentSize(control)
	local size = self._layout.vars.RightView:getContentSize()
	control.rootVar:setContentSize(size.width, size.height)
end
function wnd_longyin:updateRightView(control)
	local AddChild = self._layout.vars.RightView:getAddChild()
	for i,v in ipairs (AddChild) do
		self._layout.vars.RightView:removeChild(v)
	end
	self._layout.vars.RightView:addChild(control)
	self:changeContentSize(control)
end

function wnd_longyin:setJinZhiWidgets(ui, count, info)
	local cfg = g_i3k_db.i3k_db_get_longyin_ban(info.rank)
	local vis = true
	for i = 1, count do
		local btnName = "bt"..i
		local labelName = "label"..i
		local imgName = "img"..i
		local countName = "count"..i
		local fengyinID = cfg.items[i]
		local fengyinCfg = g_i3k_db.i3k_db_get_longyin_lock(fengyinID)
		if info.awaken[fengyinID] then
			ui.vars[imgName]:setImage(g_i3k_db.i3k_db_get_icon_path(3905))
			-- ui.vars[labelName]:setTextColor(g_i3k_get_cond_color(true))
		else
			ui.vars[imgName]:setImage(g_i3k_db.i3k_db_get_icon_path(3904))
			-- ui.vars[labelName]:setTextColor(g_i3k_get_cond_color(false))
			ui.vars[btnName]:onClick(self, self.onSealDispelling, fengyinID)
			vis = false
		end
		-- TODO 设置按钮的点击状态和文字颜色（不满足是灰色的   满足了  用绿色吧）
		ui.vars[labelName]:setText(g_i3k_db.i3k_db_get_property_name(fengyinCfg.propID))
		ui.vars[countName]:setText(fengyinCfg.propValue)
	end
	self:setSpeedUpBtn(vis)
	self._layout.vars.red_point3:setVisible(g_i3k_game_context:GetLongYinRedpoint3() or g_i3k_game_context:jingxiuUnlock())--禁制红点
end

-- 解封属性
function wnd_longyin:onSealDispelling(sender, fengyinID)
	g_i3k_ui_mgr:OpenUI(eUIID_UnlockHunyu)
	g_i3k_ui_mgr:RefreshUI(eUIID_UnlockHunyu, fengyinID)
end

local UI_LIST = {
	{ ui = "ui/widgets/jinzhi1", count = 3 },
	{ ui = "ui/widgets/jinzhi2", count = 4 },
	{ ui = "ui/widgets/jinzh3", count = 5 },
	{ ui = "ui/widgets/jinzh4", count = 6 },
}

function wnd_longyin:checkIsYuanman()
	local info = g_i3k_game_context:getRoleSealAwaken()
	local cfg = g_i3k_db.i3k_db_get_longyin_ban(info.rank)
	if info.rank <= #i3k_db_LongYin_ban and cfg then
		return false
	end
	return true
end

function wnd_longyin:updateLongyinRightView()
	local info = g_i3k_game_context:getRoleSealAwaken()
	local cfg = g_i3k_db.i3k_db_get_longyin_ban(info.rank)
	if info.rank <= #i3k_db_LongYin_ban and cfg then
		local count = #cfg.items
		local id = count - 2
		local ui = require(UI_LIST[id].ui)()
		self:updateRightView(ui)
		self:setJinZhiWidgets(ui, UI_LIST[id].count, info)
	else
		-- 设置圆满
		local widget = self._layout.vars
		widget.yuanman:show()
		widget.RightView:hide()
		widget.descLabel:hide()
		widget.speedUpBtn:hide()
		widget.timeLabel:hide()
		self:setModelYuanman()
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "refreshLongYinRedPoint")
end

function wnd_longyin:setSpeedUpBtn(vis)
	self._layout.vars.speedUpBtn:setVisible(vis)
	self._layout.vars.timeLabel:setVisible(vis)
	if vis then
		self._layout.vars.descLabel:setText(i3k_get_string(15518))
	else
		self._layout.vars.descLabel:setText(i3k_get_string(15517))
	end
	self:updateTimeLabel()
end

-- minute task
function wnd_longyin:updateTimeLabel()
	local info = g_i3k_game_context:getRoleSealAwaken()
	local allAwakenTime = info.allAwakenTime
	if allAwakenTime > 0 then
		local nowTime = i3k_game_get_time()
		local cfg = g_i3k_db.i3k_db_get_longyin_ban(info.rank)
		local targetTime = allAwakenTime + cfg.allUnlockTime
		local deltTime = targetTime - nowTime
		if deltTime > 0 then
			local hour = math.modf(deltTime/3600)
			local minute = math.modf(deltTime%3600/60)
			-- local second = math.modf(deltTime-hour*3600-60*minute)
			self._layout.vars.timeLabel:setText("需要温养的时间："..hour.."小时"..minute.."分钟")
			self._layout.vars.btnLabel3:setText("加 速")
			self._layout.vars.speedUpBtn:onClick(self, self.onSpeedUpBtn)
		else
			self._layout.vars.timeLabel:hide()
			self._layout.vars.speedUpBtn:onClick(self, self.onJingXiuBtn)
			self._layout.vars.btnLabel3:setText("精 修")
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "refreshLongYinRedPoint")
			self._layout.vars.red_point3:setVisible(g_i3k_game_context:GetLongYinRedpoint3() or g_i3k_game_context:jingxiuUnlock())--禁制红点
		end
	end
end


-- 每次解锁一个之后，检查是否都解锁成功 -- InvokeUIFunction
function wnd_longyin:checkAllUnlock()
	local flag = g_i3k_game_context:checkAllAwakenUnlock()
	if flag then
		g_i3k_game_context:setAllAwakenTime()
		self:updateTimeLabel()
	end
	self._layout.vars.red_point3:setVisible(g_i3k_game_context:GetLongYinRedpoint3() or g_i3k_game_context:jingxiuUnlock())--禁制红点
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "refreshLongYinRedPoint")             --背包红点
end

function wnd_longyin:onSpeedUpBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_longyinSpeedup)
end
function wnd_longyin:onJingXiuBtn(sender)
	i3k_sbean.seal_awaken()
end


-- 根据rank，显示几个祝福按钮
function wnd_longyin:updateZhufuBtn()
	local info = g_i3k_game_context:getRoleSealAwaken()
	local rank = info.rank > #i3k_db_LongYin_ban and #i3k_db_LongYin_ban or info.rank
	for i = 1, rank do
		varName = "zf"..i
		self._layout.vars[varName]:show()
		self._layout.vars[varName]:onTouchEvent(self, self.onZhufuBtn, i)
	end
end

function wnd_longyin:onZhufuBtn(sender, eventType, id)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_UnlockHunyuTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_UnlockHunyuTips, id)
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		g_i3k_ui_mgr:CloseUI(eUIID_UnlockHunyuTips)
	end
end

-- 用到显示的数据，还是在同步协议里传过来的。需要在context中存一份。

----------------魂玉二期需求 end---------------------

-------------- fuling 魂玉附灵 begin---------------
function wnd_longyin:onChangeToFulingUI(show)
	local widgets = self._layout.vars
	widgets.baseRoot:setVisible(not show)
	widgets.fulingRoot:setVisible(show)
	if show then
		widgets.fulingBtn:stateToPressed()
	else
		widgets.fulingBtn:stateToNormal()
	end
end

function wnd_longyin:onFulingBtn(sender)
	local levelCfg = g_i3k_db.i3k_db_get_hunyu_fuling_level()
	local roleLevel = g_i3k_game_context:GetLevel()
	local lvlNow = g_i3k_game_context:GetIsHeChengLongYin()
	if roleLevel < levelCfg.openLevel then
		g_i3k_ui_mgr:PopupTipMessage(levelCfg.openLevel.."级开放附灵玩法")
		return
	end
	if lvlNow < levelCfg.openState then
		g_i3k_ui_mgr:PopupTipMessage(levelCfg.openState.."阶开放附灵玩法")
		return
	end

	self:onChangeToFulingUI(true)
	local widgets = self._layout.vars
	self.xlBtn:stateToNormal()
	self.sxBtn:stateToNormal()
	widgets.jz_btn:stateToNormal()
	widgets.xlRoot:hide()
	widgets.sxRoot:hide()
	widgets.jzRoot:hide()
	widgets.xltRoot:hide()
	widgets.animation:hide()

	self:initFuling()

end

-- 是否满足显示附灵入口按钮
function wnd_longyin:checkShowFulingBtn()
	local levelCfg = g_i3k_db.i3k_db_get_hunyu_fuling_level()
	local roleLevel = g_i3k_game_context:GetLevel()
	local lvlNow = g_i3k_game_context:GetIsHeChengLongYin()
	if roleLevel >= levelCfg.showLevel and lvlNow >= levelCfg.showState then
		self._layout.vars.fulingBtn:show()
	else
		self._layout.vars.fulingBtn:hide()
	end
end


-- 入口，初始化显示
function wnd_longyin:initFuling()
	if g_i3k_game_context:GetIsHeChengLongYin() == 0 then
		return
	end
	local UpLvlcfg = i3k_db_LongYin_UpLvl
	local lvlNow = g_i3k_game_context:GetIsHeChengLongYin()
	self:setItemScrollData(lvlNow, UpLvlcfg)

	local curLevel = g_i3k_game_context:getFulingCurLevel() -- 初始为0，
	self:initFulingWuxing()
	local stars = g_i3k_db.i3k_db_fuling_stars_by_curLevel(curLevel - 1)
	self:setFulingStars(stars)
	self:setFulingPropScroll()
	self:setFulingNeedItems()
	self:updateFulingRedPoint()
	self:setWuxingEffect()
end

function wnd_longyin:updateFulingRedPoint()
	local status = g_i3k_game_context:getFulingRedPoint()
	local widgets = self._layout.vars
	widgets.red_point4:setVisible(status)
end

function wnd_longyin:initFulingWuxing()

	local widgets = self._layout.vars
	widgets.fulingHelp:onClick(self, self.onFulingHelp)
	local curLevel = g_i3k_game_context:getFulingCurLevel()
	if curLevel > #i3k_db_longyin_sprite then
		-- 满阶
		widgets.needItems:hide()
		widgets.fulingMan:show()
		if self._layout.anis.c_max2 then
			self._layout.anis.c_max2.play(-1)
		end
	else

	end

	for i = 1,5 do
		widgets["wuxing"..i]:show()
		widgets["sheng" .. i]:show()
	end
	widgets.resetBtn:show()
	widgets.lastPoint:show()
	widgets.buyPointBtn:show()

	if (curLevel - 1) < i3k_db_LongYin_arg.fuling.wuxingShow then
		for i = 1,5 do
			widgets["wuxing"..i]:hide()
			widgets["sheng" .. i]:hide()
		end
		widgets.resetBtn:hide()
		widgets.lastPoint:hide()
		widgets.buyPointBtn:hide()
	end
	local curBuyPointsCnt = g_i3k_game_context:GetFulingBuyPointsCnt()
	if curBuyPointsCnt >= #i3k_db_longyin_sprite_buy_point then
		widgets.buyPointBtn:hide()
	end

	if (curLevel - 1) >= i3k_db_LongYin_arg.fuling.wuxingShow and  (curLevel - 1) < i3k_db_LongYin_arg.fuling.shengShow then
		for i = 1,5 do
			widgets["sheng" .. i]:hide()
		end
	end

	local upLimitPoints = g_i3k_db.i3k_db_get_fuling_upLimit_points(curLevel - 1)
	for i = 1, 5 do
		widgets["wuxingBtn"..i]:onClick(self, self.onWuxingBtn, i)
		local cfgID = g_i3k_db.i3k_db_get_wuxing_index(i, #i3k_db_longyin_sprite_addPoint)
		local point = g_i3k_game_context:getXiangshengPoint(cfgID)
		widgets["line"..i]:setVisible(point > 0)
		local point = g_i3k_game_context:getWuxingPoint(i)
		widgets["wuxingCount"..i]:setText(point.."/"..upLimitPoints)
		local iconID = i3k_db_longyin_sprite_addPoint[i][1].icon
		widgets["wuxing"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
	end
	local usedPoints = g_i3k_game_context:getWuxingUsedPoints()
	local allPoints = g_i3k_game_context:getWuxingAllCount()
	local haveBuyPoints = g_i3k_db.i3k_db_fuling_have_buy_points(curBuyPointsCnt)
	local remainPoint = allPoints - usedPoints
	if haveBuyPoints <= 0 then
		widgets.lastPoint:setText(i3k_get_string(17741, remainPoint, allPoints))
	else
		widgets.lastPoint:setText(i3k_get_string(17741, remainPoint, allPoints) .. i3k_get_string(17742, haveBuyPoints))
	end
	widgets.doFuling:onClick(self, self.onFuling)
	local rate = g_i3k_db.i3k_db_get_fuling_success_rate(curLevel)
	widgets.success1:setText("成功率：".. rate .."%")
	local times = g_i3k_db.i3k_db_get_fuling_must_success_times(curLevel)
	local curTimes = g_i3k_game_context:getFulingUpTimes()
	if times - curTimes > 1 then
		widgets.success2:setText((times - curTimes).."次必然成功")
	else
		widgets.success2:setText("本次必然成功")
	end
	-- local name = g_i3k_db.i3k_db_get_fuling_name(curLevel - 1)
	-- widgets.fulingName:setText(name)
	local iconID = g_i3k_db.i3k_db_get_fuling_icon(curLevel - 1)
	widgets.jieName:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
	widgets.resetBtn:onClick(self, self.onReset)
	widgets.propsBtn:onClick(self, self.onPropsBtn)
	widgets.buyPointBtn:onClick(self, self.onBuyFulingPoint)

	-------- 五行相生 按钮初始化 ----------
	for i = 1, 5 do
		widgets["sheng"..i]:onClick(self, self.onShengBtn, i)
	end
end

-- 设置显示几个星星
function wnd_longyin:setFulingStars(count)
	local widgets = self._layout.vars
	for i = 1, 5 do
		widgets["star"..i]:setVisible(i <= count)
	end
end

-- 设置星星显示动画
function wnd_longyin:starAnimation()
	local widgets = self._layout.vars
	local curLevel = g_i3k_game_context:getFulingCurLevel()
	local count = g_i3k_db.i3k_db_fuling_stars_by_curLevel(curLevel - 1)
	widgets.stardh:setPosition(widgets["xing" .. count]:getPosition())
	self._layout.anis.c_xx1.play()
end

function wnd_longyin:setWuxingEffect()
	local anisRoot = self._layout.anis
	local anisName = { "c_j", "c_s", "c_m", "c_h", "c_t"} -- 金水木火土
	local list = g_i3k_game_context:getFulingEffectID()
	if self._fulingAnis then
		for k, v in ipairs(self._fulingAnis) do
			v.stop()
		end
	end
	self._fulingAnis = {}
	for k, v in ipairs(anisName) do
		local effectID = list[k]
		local anis = anisRoot[v..effectID]
		if effectID ~= 0 and anis then
			table.insert(self._fulingAnis, anis)
			anis.play(-1)
		end
	end
end

function wnd_longyin:setFulingPropScroll()
	local props = g_i3k_game_context:getFulingProps()
	local nextLevelProps = g_i3k_game_context:getFulingNextLevelProps()
	local minProps = g_i3k_db.i3k_db_get_props_min(props, nextLevelProps)
	local widgets = self._layout.vars
	local scroll = widgets.propScroll
	scroll:removeAllChildren()
	for k, v in pairs(props) do
		local ui = require("ui/widgets/lyflt1")()
		ui.vars.name:setText(i3k_db_prop_id[k].desc)
		ui.vars.count1:setText(i3k_get_prop_show(k, v))
		if nextLevelProps[k] then
			ui.vars.count2:setText("+"..i3k_get_prop_show(k, nextLevelProps[k] - v))
		else
			ui.vars.count2:hide()
		end
		scroll:addItem(ui)
	end
	for k, v in pairs(minProps) do
		local ui = require("ui/widgets/lyflt1")()
		ui.vars.name:setText(i3k_db_prop_id[k].desc)
		ui.vars.count1:setText(0)
		ui.vars.count2:setText("+".. i3k_get_prop_show(k, v))
		scroll:addItem(ui)
	end

	local allPoints = g_i3k_game_context:getWuxingAllCount() - g_i3k_game_context:GetFulingHaveBuyPoints()
	local nextAllPoints = g_i3k_game_context:getWuxingNextLevelAllCount()
	local curLevel = g_i3k_game_context:getFulingCurLevel()
	local upLimitPoints = g_i3k_db.i3k_db_get_fuling_upLimit_points(curLevel - 1)
	local nextUpLimitPoints = g_i3k_db.i3k_db_get_fuling_upLimit_points(curLevel)
	local statusProps =
	{
		[1] = { name = "可分配点数", value = allPoints, value2 = nextAllPoints - allPoints},
		[2] = { name = "加点上限", value = upLimitPoints, value2 = nextUpLimitPoints - upLimitPoints}
	}
	for k, v in ipairs(statusProps) do
		local ui = require("ui/widgets/lyflt1")()
		ui.vars.name:setText(v.name)
		ui.vars.count1:setText(v.value)
		if v.value2 ~= 0 then
			ui.vars.count2:setText("+"..v.value2)
		else
			ui.vars.count2:hide()
		end
		scroll:addItem(ui)
	end
end

function wnd_longyin:setFulingNeedItems()
	local items = g_i3k_game_context:getFulingConsumes()
	local widgets = self._layout.vars
	local scroll = widgets.needScroll
	scroll:removeAllChildren()
	for i, v in ipairs(items) do
		local ui = require("ui/widgets/lyflt2")()
		local itemID = v.id
		local name = g_i3k_db.i3k_db_get_common_item_name(itemID)
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
		if math.abs(itemID) == g_BASE_ITEM_COIN then
			ui.vars.price:setText((v.count))
		else
			ui.vars.price:setText(haveCount.."/"..(v.count))
		end
		ui.vars.price:setTextColor(g_i3k_get_cond_color(haveCount >= v.count))
		ui.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		ui.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID))
		ui.vars.suo:setVisible(itemID > 0)
		ui.vars.bt:onClick(self, self.onItemTips, itemID)
		scroll:addItem(ui)
	end
end

-- 附灵，发送协议
function wnd_longyin:onFuling(sender)
	-- 检查道具充足
	local items = g_i3k_game_context:getFulingConsumes()
	for k, v in ipairs(items) do
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		if v.count > haveCount then
			g_i3k_ui_mgr:PopupTipMessage("道具不足")
			return
		end
	end
	-- 是否满级
	local curClientLevel = g_i3k_game_context:getFulingCurLevel()
	i3k_sbean.fulingUplvl(curClientLevel)
end

-- 重置
function wnd_longyin:onReset(sender)
	local usedPoints = g_i3k_game_context:getWuxingUsedPoints()
	if usedPoints == 0 then
		g_i3k_ui_mgr:PopupTipMessage("五行未投入任何点，已经是初始状态")
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_FulingReset)
	g_i3k_ui_mgr:RefreshUI(eUIID_FulingReset)
end

-- 查看属性
function wnd_longyin:onPropsBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_FulingTips)
end

function wnd_longyin:onWuxingBtn(sender, id)
	g_i3k_ui_mgr:OpenUI(eUIID_FulingAddPoint)
	g_i3k_ui_mgr:RefreshUI(eUIID_FulingAddPoint, id)
end

-- 五行相生按钮
function wnd_longyin:onShengBtn(sender, id)
	local cfgID = g_i3k_db.i3k_db_get_wuxing_index(id, #i3k_db_longyin_sprite_addPoint)
	local cfg = i3k_db_longyin_sprite_born[cfgID]
	local points = g_i3k_game_context:getXiangshengPoint(cfgID)
	if not cfg[points + 1] then
		g_i3k_ui_mgr:OpenUI(eUIID_FulingUpLevelMax)
		g_i3k_ui_mgr:RefreshUI(eUIID_FulingUpLevelMax, id)
		return
	end

	g_i3k_ui_mgr:OpenUI(eUIID_FulingUpLevel)
	g_i3k_ui_mgr:RefreshUI(eUIID_FulingUpLevel, id)
end

function wnd_longyin:onFulingHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(17210))
end

function wnd_longyin:onBuyFulingPoint(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyFulingPoint)
	g_i3k_ui_mgr:RefreshUI(eUIID_BuyFulingPoint)
end
--------------------------------------
function wnd_longyin:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_create(layout)
	local wnd = wnd_longyin.new();
		wnd:create(layout);
	return wnd;
end
