-------------------------------------------------------
module(..., package.seeall)

local require = require;
require("ui/ui_funcs")
require("ui/base");
local ui = require("ui/underwear_profile");
-------------------------------------------------------
wnd_underwear_update = i3k_class("wnd_underwear_update", ui.wnd_underwear_profile)
local btnShowTab = { 
	upStage_btn 	= i3k_db_under_wear_alone.underWearUpStageShowLvl,
	talent_btn 		= i3k_db_under_wear_alone.underWearTalentShowLvl,
	fuwen_btn 		= i3k_db_under_wear_alone.underWearRuneShowLvl,
}
function wnd_underwear_update:ctor()
	self._canUse = true
	self.MaxLevel = false --达到做大等级
	self.co = nil
end

function wnd_underwear_update:configure()
	local widgets = self._layout.vars

	self.update_btn = widgets.update_btn  --升级
	self.update_btn:stateToPressed()
	self.upStage_btn = widgets.upStage_btn  --升阶
	self.upStage_btn:stateToNormal()
	self.upStage_btn:onClick(self, self.onuUpStageBtn)
	
	self.talent_btn = widgets.talent_btn
	self.talent_btn:stateToNormal()
	self.talent_btn:onClick(self, self.onTalentBtn)--天赋
	
	self.fuwen_btn = widgets.fuwen_btn
	self.fuwen_btn:stateToNormal()
	self.fuwen_btn:onClick(self, self.onFuwenBtn)--符文
	
	self.nameLabel   = widgets.job
	self.levelLabel  = widgets.level
	self.stageLabel  = widgets.stage
	self.stageLabel:hide()
	self.hero_module = widgets.hero_module
	
	self.expLoading = widgets.expLoading
	self.expLabel = widgets.expLabel
	
	self.nextAttr = widgets.nextAttr
	self.sx2 = widgets.sx2
	self._maxLevel = widgets.maxLevel
	--没加当前属性label
	--
	self.bgImage = widgets.bgImage --背景图
	
	self.akey_btn =  widgets.akey_btn
	self.akey_btn:onClick(self,self.onUseExpAuto)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	self._layout.vars.gotoBtn:onClick(self,function ()
		g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear)
		g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear)
		self:onCloseUI()
	end)
	
	self.upgradeTab = {}
	for i=1,3 do
		local temp_bg = string.format("item%s_bg",i)
		local temp_icon = string.format("item%s_icon",i)
		local temp_btn = string.format("item%s_btn",i)
		local temp_count = string.format("item%s_count",i)
		local tmp_value = string.format("item%s_value",i)
		local _upgradeTab = {item_bg =widgets[temp_bg],item_icon =widgets[temp_icon],item_btn = widgets[temp_btn] ,item_count = widgets[temp_count], item_value = widgets[tmp_value]}
		table.insert(self.upgradeTab , i , _upgradeTab)
	end
	self._maxLevel:hide()
	self.Sroll = widgets.Sroll
	
	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型
	self.widgets = widgets
	
	self.talentRp = widgets.talentRp
	self.forgeRp = widgets.forgeRp
	self.upgradeRp = widgets.upgradeRp
	self.runeRp = widgets.runeRp
end

function wnd_underwear_update:refresh(index ,tab)
	--local tab = {underwear_name = nameStr ,underwear_level =levelStr ,underwear_stage = stageStr }
	--打开界面时需要判断等级是否满足显示
	for k,v in pairs(btnShowTab) do
		self.widgets[tostring(k)]:show()
		if g_i3k_game_context:GetLevel() < v then
			self.widgets[tostring(k)]:hide()
		end
	end
	self.index= index
	self.tab = tab 
	local armorData = {id = index, stage = tab.underwear_stage}
	ui_set_hero_model(self.hero_module, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(), armorData)
	self:setBgImage(index)
	self:setData(index ,tab)
	self:setTrrData(self.index,self.tab)
end

--根据内甲id显示背景图
function wnd_underwear_update:setBgImage(index)
	local bgImageTab = {2701,2702,2703}
	self.bgImage:setImage(i3k_db_icons[bgImageTab[index]].path) 
end

function wnd_underwear_update:setData(index,tab)
	--now_exp 当前内甲升级所匹配经验
	--local now_exp = g_i3k_game_context:getPetExp(index)
	self.index= index
	self.tab = tab 
	local now_exp = g_i3k_game_context:getAnyUnderWearAnyData(self.index,"exp")
	local need_exp = 0
	if i3k_db_under_wear_update[index][self.tab.underwear_level+1] then
		need_exp = i3k_db_under_wear_update[index][self.tab.underwear_level+1].needExp
		self.propTab = {}
	    local propTab = i3k_db_under_wear_update[index][self.tab.underwear_level+1].updateProp
		for k,v in pairs(propTab) do
			table.insert(self.propTab , v)
		end
	else
		self.MaxLevel = true
	end
	
	self.nameLabel:setText(self.tab.underwear_name)
	self.levelLabel:setText(self.tab.underwear_level.."级")
	self.stageLabel:setText(self.tab.underwear_stage.."阶")
	self:ShowRedPoint(index, tab)
	if self.MaxLevel then
		self.sx2:hide()
		self._maxLevel:show()
		self._layout.anis.c_max.play()
	else	
		self.expLoading:setPercent(now_exp/need_exp*100)
		local tmp_str = string.format("%s/%s",now_exp,need_exp)
		self.expLabel:setText(tmp_str)
		self:setPropData()
	end
end
function wnd_underwear_update:setPropData()
	for i,v in ipairs(self.upgradeTab) do
		v.item_bg:show()
		if self.propTab[i]~=0 and self.propTab[i] then
			local itemCount = g_i3k_game_context:GetCommonItemCount(self.propTab[i])
			local itemid = itemCount >= 0 and self.propTab[i] or -self.propTab[i]
			local item_cfg = g_i3k_db.i3k_db_get_common_item_cfg(itemid)
			local exp_value = item_cfg.args1
			local count = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
			
			v.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
			v.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
			v.item_count:setText("x"..count)
			v.item_value:setText("+"..exp_value)
			v.item_btn:onTouchEvent(self, self.onUseItem, {itemid = self.propTab[i], layer = true, count = count,index = i})--长按按钮	 --传递的数据只看配置表		
		else
			v.item_bg:hide()	
		end		
	end
end
function wnd_underwear_update:setTrrData(index,tab)
	if self.Sroll then
		self.Sroll:removeAllChildren()
	end
	local rank = g_i3k_game_context:getAnyUnderWearAnyData(index,"rank")
	local propMulti = i3k_db_under_wear_upStage[index][rank].attrUpPro / 10000 + 1
	for i=1 ,10 do
		local attrId = string.format("attrId%s",i)
		local attrValue = string.format("attrValue%s",i)
		local curAttr= i3k_db_under_wear_update[index][self.tab.underwear_level][attrId]
		local curAttrValue= i3k_db_under_wear_update[index][self.tab.underwear_level][attrValue]
		curAttrValue = math.modf(curAttrValue * propMulti)
		local nextAttValue =0
		if i3k_db_under_wear_update[index][self.tab.underwear_level+1] then  --存在下一级
			nextAttValue = i3k_db_under_wear_update[index][self.tab.underwear_level+1][attrValue]
			nextAttValue = math.modf(nextAttValue * propMulti)
		else
			self.MaxLevel = true
		end
		if curAttr and curAttr ~=0 then
			--todo 
			local Layer = require("ui/widgets/njsjt")() --属性label
			local icon = g_i3k_db.i3k_db_get_property_icon(curAttr)
	        Layer.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon)) 
			Layer.vars.propertyName:setText(i3k_db_prop_id[curAttr].desc)
			Layer.vars.propertyValue:setText(curAttrValue)
			--当前等级属性值， 下一等级属性值   做差值运算 nextAttValue - curAttr		
			local add = nextAttValue - curAttrValue
			Layer.vars.propertyAddValue:setText(add) 
			if self.MaxLevel then
				Layer.vars.propertyAddValue:hide()
				self.nextAttr:hide()
				Layer.vars.jiantou:hide()
			end 
			self.Sroll:addItem(Layer)
		end		
	end
end

function wnd_underwear_update:updateModule(curArmor)
	local data 
	local standData 
	if i3k_db_under_wear_cfg[curArmor] then
		data =  i3k_db_under_wear_cfg[curArmor].playCelebrateAction
		standData =  i3k_db_under_wear_cfg[curArmor].playStandbyAction
	end
	if data and standData then
		for i,v in ipairs(data)	do
			self.hero_module:pushActionList(v, 1)
		end
		self.hero_module:pushActionList(standData[1],-1)
		self.hero_module:playActionList()
	else
		self.hero_module:playAction("stand")
	end
end
	
function wnd_underwear_update:setCanUse(canUse)
	self._canUse = canUse
end

function wnd_underwear_update:onUseItem(sender, eventType, data)
	self.needId = data.itemid
	local itemid = data.itemid
	self.itemIdIndex = data.index

	if eventType == ccui.TouchEventType.began then
		if data.count == 0 then
			g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
			return
		end

		self:onUpLevelArmor(data.layer)
		self.co = g_i3k_coroutine_mgr:StartCoroutine(function()
			while true do
				g_i3k_coroutine_mgr.WaitForSeconds(0.5) --延时
				if g_i3k_game_context:GetCommonItemCanUseCount(itemid) <=0 then
					g_i3k_ui_mgr:PopupTipMessage("所需道具不足")
					return false
				end
				
				if self._canUse then
					self:onUpLevelArmor(data.layer)
					self._canUse = false
				end
			end
		end)
	elseif eventType == ccui.TouchEventType.ended then
		g_i3k_coroutine_mgr:StopCoroutine(self.co)
		self.co = nil
	elseif eventType==ccui.TouchEventType.canceled then
		g_i3k_coroutine_mgr:StopCoroutine(self.co)
		self.co = nil
	end
end

function wnd_underwear_update:onUpLevelArmor(layer)
	--升级后，持续按住的道具槽，若有道具，则继续持续升级，否则需停止
	if not self.propTab[self.itemIdIndex] then 
		--当前配置表里没有这个id道具
		g_i3k_coroutine_mgr:StopCoroutine(self.co)
		return false
	end
	local itemid = self.propTab[self.itemIdIndex]
	if g_i3k_game_context:GetCommonItemCanUseCount(itemid) <=0 then
		g_i3k_ui_mgr:PopupTipMessage("所需道具不足")
		return false
	end
	
	local lvl = g_i3k_game_context:getAnyUnderWearAnyData(self.index ,"level")  --获取该内甲等级
	local now_exp = g_i3k_game_context:getAnyUnderWearAnyData(self.index ,"exp")    --获取该内甲经验
	local item_cfg = g_i3k_db.i3k_db_get_common_item_cfg(itemid)
	local total_exp = item_cfg.args1   --当前物品能兑换的经验点数
	----------------------
	local up_lvl = lvl
	local need_exp = 0
	local uplvl_cfg =i3k_db_under_wear_update[self.index][self.tab.underwear_level+1]  --该内甲对应等级配置表
	while uplvl_cfg do
		need_exp = uplvl_cfg.needExp + need_exp
		if need_exp > now_exp + total_exp then                 --需要的exp>总和 --不能升级 
			need_exp = need_exp - uplvl_cfg.needExp             --退回去
			break
		else
			up_lvl = up_lvl + 1
			uplvl_cfg = i3k_db_under_wear_update[self.index][up_lvl+1] 
		end
	end
	local last_exp = now_exp + total_exp - need_exp   --超出的部分经验（升级后剩余经验）
	local temp_count = 1
	local temp = {}
	temp[itemid] = temp_count
	local need_items = {}
	for k, v in pairs(temp) do
		if v~=0 then
			if g_i3k_game_context:GetCommonItemCount(k) >= v then
				need_items[k] = v
			else
				if g_i3k_game_context:GetCommonItemCount(k) > 0 then
					need_items[k] = g_i3k_game_context:GetCommonItemCount(k)
				end
				need_items[-k] = v - g_i3k_game_context:GetCommonItemCount(k)
			end
		end
 	end
	local compare_lvl = {isUpLvl= false,before_lvl=0}
	if up_lvl ~= lvl then
		compare_lvl.isUpLvl = true
		compare_lvl.before_lvl = lvl
	end
	--该内甲tag ，道具表，升级后等级，剩余经验，判断是否升级（升级前后等级不同），true
	i3k_sbean.goto_underWear_levelup(self.index, need_items, up_lvl, last_exp, compare_lvl, layer)
end

function wnd_underwear_update:onUseExpAuto()
	if g_i3k_game_context:isEnoughUpArmorLevel(self.index) then
		i3k_sbean.goto_underWear_levelup(self.index, g_i3k_game_context:isEnoughUpArmorLevel(self.index))
	else
		g_i3k_ui_mgr:PopupTipMessage("您不满足升级条件")
	end
end

function wnd_underwear_update:onuUpStageBtn()
	--升阶
	local canOpen ,level = g_i3k_game_context:isCanOpenUI(1)
	if canOpen then
		g_i3k_logic:OpenUnderWearUpStage(self.index,self.tab)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(805,string.format("%s",level)))
	end

end

function wnd_underwear_update:onTalentBtn()
	--天赋
	local canOpen ,level = g_i3k_game_context:isCanOpenUI(2)
	if canOpen then
		g_i3k_logic:OpenUnderWearTalent(self.index,self.tab)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(806, level))
	end
end

function wnd_underwear_update:onFuwenBtn()
	--符文
	local canOpen ,level= g_i3k_game_context:isCanOpenUI(3)
	if canOpen then
		g_i3k_logic:OpenUnderWearRune(self.index,self.tab)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(807,level))
	end
end


function wnd_underwear_update:release()
	if self.co then
		g_i3k_coroutine_mgr:StopCoroutine(self.co)
		self.co = nil
	end
end

function wnd_underwear_update:onHide()
	self:release()
end

function wnd_underwear_update:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Under_Wear_update)
end

function wnd_create(layout)
	local wnd = wnd_underwear_update.new()
	wnd:create(layout)
	return wnd
end
