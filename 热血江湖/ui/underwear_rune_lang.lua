-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base");
local langLayer = "ui/widgets/njfwmct"
-------------------------------------------------------
wnd_underwear_rune_lang = i3k_class("wnd_underwear_rune_lang", ui.wnd_base)
-- 符文之语
local normalColor = "ffecac94"
local pressColor = "ff7a4938"
local armorBg = {4084, 4085, 4086}

local PowerLelIcon = {8805,8806,8807}	
local LAYER_FUYUTIPST = "ui/widgets/njfwzyt"
function wnd_underwear_rune_lang:ctor()
	self.langIndex = 0
	self.signTab = {} --标志表
	self.curLangIndex = 0
	self._items = {}
	self._cutSigns = {}
end
function wnd_underwear_rune_lang:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	self.LangSroll = widgets.LangSroll
	self.Attrscroll= widgets.Attrscroll
	self.powerNum = widgets.powerNum --战斗力
	self.centerIcon = widgets.centerIcon
	--中间
	self.itemTab = {}
	for i=1,6 do
		local item = string.format("item%s",i) 
		local item_icon = string.format("item%s_icon",i) 
		-- local item_name = string.format("item%s_name",i) 
		-- local item_desc = string.format("item%s_desc",i) 
		local item_equip = string.format("item%s_equip",i)
		local ani = string.format("ani%s",i)
		local itemTab = {item =widgets[item],itemIcon = widgets[item_icon],itemEquip =widgets[item_equip], ani = widgets[ani]} 
		table.insert(self.itemTab,i,itemTab)
	end
	--生效中
	self.runeLangBtn = widgets.runeLangBtn 
	self.runeLangBtn:onClick(self, self.onRuneLangBtn)
	self.runeLangBtnLabel = widgets.runeLangBtnLabel 
	widgets.upgradeBtn:onClick(self, self.onOpenUpgradeUI)
	self.upgradeBtn = widgets.upgradeBtn
	self.upgradeLabel = widgets.upgradeLabel
	self.updateRed = widgets.updateRed
	self.armorBg = widgets.armorBg
	--self.nextLab = widgets.nextLab --新版UI此处删除了
	--符语铸锭
	self.zhuDingBtn = widgets.zhuDingBtn
	self.upgradeLabel2 = widgets.upgradeLabel2
	self.zhuDingBtn:onClick(self, self.onOpenZhuDingUI, self.langIndex)
	self.zhuDingData = {}
end


function wnd_underwear_rune_lang:refresh(armorTag,showType,index)
	self.showType = showType --第几套插槽
	self.armorTag = armorTag  --当前内甲
	self.zhuDingData = g_i3k_game_context:getFuYuZhudingData() --刷新铸锭
	if index then
		self.langIndex = index   --self.langIndex当前显示的是当前插槽生效的符文之语的id
		--附加一个生效中的标志
	end
	self.armorBg:setImage(g_i3k_db.i3k_db_get_icon_path(armorBg[armorTag]))
	local initIndex = 1
	if self.langIndex ~=0 then
		initIndex = self.langIndex
	end
	self:updateCurrSlotRunes()
	self:setRuneLangData(initIndex)
	self:setRuneData(initIndex)
end
function wnd_underwear_rune_lang:setRuneLangData(index)
	self.LangSroll:removeAllChildren()	
	self.langTab = {}
	self.upReds = {}
	self.zhuDingData = g_i3k_game_context:getFuYuZhudingData()
	for i,v in ipairs(i3k_db_under_wear_rune_lang) do
		local widget = require(langLayer)()
		vars = widget.vars
		vars.LangName:setText(self:getRuneLangName(v.runeLangName, i))
		vars.LangBtn:onClick(self, self.onShowRuneLang ,i)
		if i == index then
			vars.LangBtn:stateToPressed()
			vars.LangName:setTextColor(pressColor)
		else
			vars.LangBtn:stateToNormal()
			vars.LangName:setTextColor(normalColor)	
		end
		vars.upred:hide()
		self.LangSroll:addItem(widget)
		table.insert(self.langTab, {btn = vars.LangBtn, lab = vars.LangName})
		self.signTab[i] = vars.sign
		self.upReds[i] = vars.upred
		self._cutSigns[i] = vars.cutSign
		self._items[i] = {v.slotRuneId1, v.slotRuneId2, v.slotRuneId3, v.slotRuneId4, v.slotRuneId5, v.slotRuneId6}
		--铸锭等级显示
		local data = self.zhuDingData[i]
		if data and data.level > 0 then
			vars.star:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_under_wear_alone.zhuDingLvStarIcon[data.level]))
			vars.star:show()
		else
			vars.star:hide()
		end
		vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(PowerLelIcon[v.powerLvl]))
	end
	if index then
		self.LangSroll:jumpToChildWithIndex(index)
	end
	self:updateListUpRed()
	self:checkCanLangActivate()
end

function wnd_underwear_rune_lang:setRuneLangItemName(runeId)
	local allChild = self.LangSroll:getAllChildren()
	local name = i3k_db_under_wear_rune_lang[runeId].runeLangName
	allChild[runeId].vars.LangName:setText(self:getRuneLangName(name, runeId))
end

function wnd_underwear_rune_lang:updateListUpRed()
	if self.langIndex > 0 then
		local nextLvl = g_i3k_game_context:getRuneLangLevel(self.langIndex) + 1
		local isEnough = g_i3k_game_context:getUpLangRuneEnough(self.langIndex, nextLvl, self._items[self.langIndex])
		self.upReds[self.langIndex]:setVisible(isEnough)
		self.updateRed:setVisible(isEnough)
	end
end

function wnd_underwear_rune_lang:setRuneData(index)
	self.curLangIndex = index
	self.equipNum = 0
	self.curRuneLangTab = {}
	self.Attrscroll:removeAllChildren()	
	local data = i3k_db_under_wear_rune_lang[index] --配置表里
	self._layout.vars.titleName:setText(self:getRuneLangName(data.runeLangName, index))
	self.zhuDingData = g_i3k_game_context:getFuYuZhudingData()
	local runeBagData = self:getTempBagData()
	--当前持有的全部符文
	--中间的符文展示  slotRuneId1
	for i =1 ,6 do
		local slotRuneId = string.format("slotRuneId%s",i) 
		local runeId = data[slotRuneId]
		if runeId and runeId~=0 then
			self.itemTab[i].item:show()
			self.itemTab[i].itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(runeId,i3k_game_context:IsFemaleRole()))
			-- self.itemTab[i].itemName:setText(g_i3k_db.i3k_db_get_common_item_name(runeId))
			local item_rank = g_i3k_db.i3k_db_get_common_item_rank(runeId)
			-- self.itemTab[i].itemName:setTextColor(g_i3k_get_color_by_rank(item_rank))
			local itemid  = runeId > 0 and runeId or -runeId
			-- self.itemTab[i].itemDesc:setText(i3k_db_under_wear_rune[itemid].runeAttr)
			self.itemTab[i].itemEquip:show()
			-- self.itemTab[i].item:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
			self.itemTab[i].item:onClick(self, self.onRuneTips, itemid)
			if runeBagData[runeId] or runeBagData[-runeId] then
				if  runeBagData[-runeId] and runeBagData[-runeId]>0 then
					self.curRuneLangTab[i]= -runeId
				elseif runeBagData[runeId] and runeBagData[runeId]>0 then
					self.curRuneLangTab[i]= runeId
				end
				self.itemTab[i].itemEquip:show()
				self.itemTab[i].ani:show()
				self.equipNum =self.equipNum +1
			else
				self.itemTab[i].ani:hide()
				self.itemTab[i].itemEquip:hide()
			end
		else
			self.itemTab[i].item:hide()	
		end		
	end	
	self:setLangAttr(index)
	self:setBtnState(index)
	self:setCenterIcon()
end
function wnd_underwear_rune_lang:setCenterIcon()
	local iconId = i3k_db_under_wear_alone.zhuDingLvShowIcon[1]
	if self.zhuDingData[self.curLangIndex] then
		iconId = i3k_db_under_wear_alone.zhuDingLvShowIcon[self.zhuDingData[self.curLangIndex].level + 1]
	end
	self.centerIcon:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
end

function wnd_underwear_rune_lang:getTempBagData()
	g_i3k_game_context:setRuneWishData() --设置临时数据
	local _,runeBagData = g_i3k_game_context:getRuneWishData()	
	for i=1 ,6 do
		local runeid = self.curSoltRuneTab[i]
		if runeid~=0 then
			if runeBagData[runeid] then
				runeBagData[runeid] = runeBagData[runeid] +1
			else
				runeBagData[runeid] = 1
			end
		end
	end
	return runeBagData
end

function wnd_underwear_rune_lang:updateCurrSlotRunes()
	self.soltGroupData  = g_i3k_game_context:getAnyUnderWearAnyData(self.armorTag,"soltGroupData")
	local soltData =  self.soltGroupData[self.showType]
	self.curSoltRuneTab =soltData.solts 
end

function wnd_underwear_rune_lang:checkCanLangActivate()
	local runeBagData = self:getTempBagData()
	local node
	local runeKey = {"slotRuneId1", "slotRuneId2", "slotRuneId3", "slotRuneId4", "slotRuneId5" , "slotRuneId6"}
	for i,v in ipairs(i3k_db_under_wear_rune_lang) do
		if i ~= self.langIndex then
			node = self._cutSigns[i]
			node:show()
			for i = 1 , #runeKey do
				local runeId = v[runeKey[i]]
				if runeBagData[runeId] or runeBagData[-runeId] then
				else
					node:hide()
					break
				end
			end
		end
	end
end

function wnd_underwear_rune_lang:getRuneLangName(name, index)
	local lvl = g_i3k_game_context:getRuneLangLevel(index)
	return lvl == 0 and name or name.."·"..i3k_db_rune_lang_upgrade[index][lvl].lvlName
end

function wnd_underwear_rune_lang:setLangAttr(index)
	self.Attrscroll:removeAllChildren()
	--属性展示
	--index 当前选中符文之语  attrValue4 = 100, attrId5
	local currlvl = g_i3k_game_context:getRuneLangLevel(index)
	local attr = g_i3k_db.i3k_db_get_rune_lang_attr(index, currlvl)
	local nextAttr = g_i3k_db.i3k_db_get_rune_lang_attr(index, currlvl+1)
	self.zhuDingData = g_i3k_game_context:getFuYuZhudingData()
	--符语属性标题
	local header_1 = require(LAYER_FUYUTIPST)()
	header_1.vars.desc:setText("符语属性")
	self.Attrscroll:addItem(header_1)
	self.upgradeBtn:show()
	if not nextAttr then
		if i3k_db_rune_zhuDing[self.curLangIndex] then
			self.zhuDingBtn:show()
			self.upgradeBtn:hide()
			self.zhuDingBtn:enable()
			self.upgradeLabel2:setText("符语铸锭")
			if self.zhuDingData[self.curLangIndex] and self.zhuDingData[self.curLangIndex].level == #i3k_db_rune_zhuDing[self.curLangIndex] then
				self.zhuDingBtn:disable()
				self.upgradeLabel2:setText(i3k_get_string(985))
			end
		else
		self.upgradeBtn:disable()
		self.upgradeLabel:setText(i3k_get_string(985)) --已满阶
		self.updateRed:hide()
			self.zhuDingBtn:hide()
		end
		header_1.vars.nextLab:hide()
	else
		self.zhuDingBtn:hide()
		header_1.vars.nextLab:show()
		self.upgradeBtn:show()
		self.upgradeBtn:enable()
		self.upgradeLabel:setText(i3k_get_string(986)) --升阶符语
		local _,bag = g_i3k_game_context:GetRuneBagInfo()
		local visible = self.langIndex == index and g_i3k_game_context:getUpLangRuneEnough(index, currlvl + 1, self._items[index])
		self.updateRed:setVisible(visible)
	end

	local powerTab = {}
	local function createNode(id, value)
		local node = require("ui/widgets/njfwjct")()
		local widget = node.vars
		widget.itemCount:setText("+".. i3k_get_prop_show(id, value))
		widget.itemName:setText(i3k_db_prop_id[id].desc)
		widget.itemIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(id)))
		self.Attrscroll:addItem(node)
		return node.vars
	end
	for i =1 , #attr do
		local attrId = attr[i].id
		local attrValue = attr[i].value
		if attrId~=0 then
			local widget = createNode(attrId, attrValue)
	        if nextAttr then
	       		widget.nextAttr:setText("+"..i3k_get_prop_show(attrId, nextAttr[i].value - attrValue))
	       	else
	       		widget.nextAttr:hide()
	       	end
			powerTab[attrId] = attrValue
		elseif nextAttr and nextAttr[i].id ~= 0 then
			local widget = createNode(nextAttr[i].id, 0)
			widget.nextAttr:setText("+"..i3k_get_prop_show(nextAttr[i].id, nextAttr[i].value))
		end
	end
	--铸锭属性标题
	local zhuDingData = g_i3k_game_context:getFuYuZhudingData()
	if zhuDingData[index] and zhuDingData[index].level > 0 then
		local header_2 = require(LAYER_FUYUTIPST)()
		header_2.vars.desc:setText("铸锭属性")
		header_2.vars.nextLab:hide()
		self.Attrscroll:addItem(header_2)
		for i,v in ipairs(i3k_db_rune_zhuDing[index][zhuDingData[index].level].attribute) do
			local attrId = v.id
			local attrValue = v.value
			if v.id ~= 0 then
				local widget = createNode(attrId, attrValue)
				widget.nextAttr:hide()
			end
			powerTab[attrId] =  powerTab[attrId] and  powerTab[attrId] + attrValue or attrValue
		end
	end
	--战力
	local power = g_i3k_db.i3k_db_get_battle_power(powerTab, true)
	self.powerNum:setText(power)
end

--点击背包Item
function wnd_underwear_rune_lang:onRuneTips(sender, itemId)
	g_i3k_ui_mgr:OpenUI(eUIID_RuneBagItemInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_RuneBagItemInfo, nil, nil,  itemId, 3)
end

function wnd_underwear_rune_lang:setBtnState(index)
	if self.equipNum==6 then
		--TODO 生效or 一键切换
		if self.langIndex ==index then
			self.runeLangBtn:enableWithChildren()
			self.runeLangBtn:setTouchEnabled(false)
			self.runeLangBtnLabel:setText(i3k_get_string(987)) --生效中
			self.signTab[index]:show()
		else --一键切换
			self.runeLangBtn:enableWithChildren()
			self.runeLangBtn:setTouchEnabled(true)
			self.runeLangBtnLabel:setText(i3k_get_string(988)) --一键切换
			self.signTab[index]:hide()
		end
	else
		--未生效
		self.runeLangBtn:disableWithChildren()--置灰
		self.runeLangBtn:setTouchEnabled(false)
		self.runeLangBtnLabel:setText(i3k_get_string(989)) --未生效
		self.signTab[index]:hide()
	end
end

function wnd_underwear_rune_lang:onRuneLangBtn(sender)
	--一键切换 可以点击
	--卸载当前镶嵌的符文
	--装备符文之语上的符文
	--当前内甲id，当前插槽id，当前符文之语id,当前插槽内符文集合，当前符文之语集合
	if g_i3k_game_context:runeLangIsGet(self.armorTag, self.showType, nil, nil, self.curRuneLangTab) then
		return
	end
	i3k_sbean.runeLangPush(self.armorTag,self.showType,self.curLangIndex,self.curSoltRuneTab,self.curRuneLangTab,self.curLangIndex)
end

function wnd_underwear_rune_lang:setTouchIndex(index)
	if self.curLangIndex ~= index then
		--for i,v in ipairs(self.langTab) do
			local wdg = self.langTab[self.curLangIndex]
			wdg.btn:stateToNormal(normalColor)
			wdg.lab:setTextColor(normalColor)
		--end
		self.curLangIndex = index
		wdg = self.langTab[index]
		wdg.btn:stateToPressed()
		wdg.lab:setTextColor(pressColor)
	end
end

function wnd_underwear_rune_lang:onShowRuneLang(sender,index)
	self:setTouchIndex(index)
	self:setRuneData(index)
end

function wnd_underwear_rune_lang:setSignState()
	for k,v in ipairs(self.signTab) do
		v:hide()
	end
end

function wnd_underwear_rune_lang:setState(tag)
	--self:setSignState()
	self:updateCurrSlotRunes()
	if self.langIndex > 0 then
		self.upReds[self.langIndex]:hide()
		self.signTab[self.langIndex]:hide()
		self._cutSigns[self.langIndex]:show()
	end
	self.upReds[tag]:show()
	self.signTab[tag]:show()
	self._cutSigns[tag]:hide()
	self.langIndex =tag
	self:setBtnState(self.langIndex)
	self:updateListUpRed()
end

function wnd_underwear_rune_lang:showBtntag(index)
	self._cutSigns[index]:show()
end
function wnd_underwear_rune_lang:onCloseUI(sender)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "setData")
	g_i3k_ui_mgr:CloseUI(eUIID_Under_Wear_Rune_Lang)
end

function wnd_underwear_rune_lang:onOpenUpgradeUI()
	if self.langIndex ~= self.curLangIndex then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(984)) --请契合当前符文之语再进行升阶
	end
	local nextLvl = g_i3k_game_context:getRuneLangLevel(self.curLangIndex)+ 1
	local cfg = i3k_db_under_wear_rune_lang[self.curLangIndex]
	local expendNum = i3k_db_rune_lang_upgrade[self.curLangIndex][nextLvl].expendNum
	g_i3k_ui_mgr:OpenUI(eUIID_Upgrade_Rune_lang)
	g_i3k_ui_mgr:RefreshUI(eUIID_Upgrade_Rune_lang, self._items[self.curLangIndex], nextLvl, self.curLangIndex, expendNum)
end

--符语铸锭按钮方法
function wnd_underwear_rune_lang:onOpenZhuDingUI()
	if self.langIndex ~= self.curLangIndex then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(984)) --请契合当前符文之语再进行升阶
	end
	g_i3k_ui_mgr:OpenUI(eUIID_FuYuZhuDing)
	g_i3k_ui_mgr:RefreshUI(eUIID_FuYuZhuDing, self.curLangIndex, self.showType, self.armorTag)
end
function wnd_create(layout)
	local wnd = wnd_underwear_rune_lang.new();
	wnd:create(layout);
	return wnd;
end


