-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------五绝声望界面
wnd_fiveUnique_prestige = i3k_class("wnd_fiveUnique_prestige", ui.wnd_base)

local l_tTabName = {[1] = 707,[2]= 708}--[1] = "h#c4.png", [2] = "h#c1.png"}

function wnd_fiveUnique_prestige:ctor()
	self._id = nil
	self.modelValue = {}
	self.rewardValue = {}
	self.items = {}
	self._state = 1
	self._fameTower  = false
end

function wnd_fiveUnique_prestige:configure()
	local widgets = self._layout.vars
	self._layout.vars.close:onClick(self, self.onCloseUI)

	widgets.left_btn:onClick(self, self.onClickLeftBtn)
	widgets.right_btn:onClick(self, self.onClickRightBtn)
	widgets.rank_btn:onClick(self, self.onClickRankBtn)
	self.dialogue = widgets.dialogue 
end

function wnd_fiveUnique_prestige:addNewNode(layer)
	local nodeWidth = self.new_root:getContentSize().width
	local nodeHeight = self.new_root:getContentSize().height
	local old_layer = self.new_root:getAddChild()
	if old_layer[1] then
		self.new_root:removeChild(old_layer[1])
	end
	self.new_root:addChild(layer)
	layer.rootVar:setContentSize(nodeWidth,nodeHeight)
end

function wnd_fiveUnique_prestige:refresh(info,id,index)
	self._id = id
	self._layout.vars.sale_bat:show()
	self.modelValue = {}
	for i,e in ipairs(info) do
		table.insert(self.modelValue, e)
	end
	
	if next(info)~= nil and info[self._id] then
		self:setSelfData(id,info[self._id].reward,index )
		self:SetPayOutItemInfo(id)
	end
	
	
end



function wnd_fiveUnique_prestige:SetPayOutItemInfo(id)
	local level = g_i3k_game_context:GetRoleTowerPrestigeLvl(id)--获得当前声望等级
	local need_item = i3k_db_climbing_tower_prestige[id][level].consumeitemID
	local canBatch = false
	self.items = {}
	for i=1,4 do
		local temp_bg = "item"..i.."_bg"
		local temp_icon = "item"..i.."_icon"
		local temp_btn = "item"..i.."_btn"
		local temp_count = "item"..i.."_count"--下面的文字
		--local tempcountBg = "count"..i.."Root"--下面的图片
		local tmpValue = "item"..i.."_value"

		self._layout.vars[temp_bg]:setVisible(need_item[i]~=nil)
		self._layout.vars[temp_count]:setVisible(need_item[i]~=nil)
		--self.widgets.vars[tempcountBg]:setVisible(need_item[i]~=nil)
		if need_item[i] then
			local itemCount = g_i3k_game_context:GetCommonItemCount(need_item[i])
			local itemid = itemCount > 0 and need_item[i] or -need_item[i]
			local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
			table.insert(self.items, canUseCount)
			if canUseCount > 0 then
				canBatch = true
			end
			local tmp_cfg = g_i3k_db.i3k_db_get_common_item_cfg(itemid)
			local value = tmp_cfg.args1
			self._layout.vars[temp_bg]:show()
			self._layout.vars[temp_bg]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
			self._layout.vars[temp_icon]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
			self._layout.vars[temp_count]:setText("+"..value)---声望
			self._layout.vars[tmpValue]:setText(canUseCount)
			self._layout.vars[temp_btn]:onTouchEvent(self,self.onUseItem, {itemid = itemid,item = self.widgets})--捐赠 长按按钮
		end
	end
	if canBatch then
		self._layout.vars.sale_bat:enableWithChildren()
	else
		self._layout.vars.sale_bat:disableWithChildren()
	end
	self._layout.vars.sale_bat:onClick(self, self.onBatchUse)
end
----模型id
function wnd_fiveUnique_prestige:setModule(id, tagId )
	
	local path = i3k_db_models[id].path
	local uiscale = i3k_db_models[id].uiscale
	self._layout.vars.model:setSprite(path)
	self._layout.vars.model:setSprSize(uiscale)
	
	self._layout.vars.model:playAction("stand")

end



function wnd_fiveUnique_prestige:setSelfData(id,rewardSeq,index )
	local level = g_i3k_game_context:GetRoleTowerPrestigeLvl(id)--获得当前声望等级
	local dialogueID = i3k_db_climbing_tower_prestige[id][level].dialogueID
	local maxCount = #i3k_db_dialogue[dialogueID]
	local tmp_dialogue = i3k_db_dialogue[dialogueID][math.random(1,maxCount)].txt
	self:updatePrestigeValue(id)
	if  not self._fameTower  then  --是捐赠引起的刷新 则不刷新模型
		self:setModule(i3k_db_climbing_tower[self._id].modelId)---
		self.dialogue:setText(tmp_dialogue)
	end
	self:setRewardsDataInfo(id,level,rewardSeq,index)
	if self._id == 1 then
		self._layout.vars.left_btn:hide()
		self._layout.vars.right_btn:show()
	
	elseif self._id == 5 then
		self._layout.vars.left_btn:show()
		self._layout.vars.right_btn:hide()
	else
		self._layout.vars.left_btn:show()
		self._layout.vars.right_btn:show()
	end
end
function wnd_fiveUnique_prestige:setRewardsDataInfo(id,level,rewardSeq,index)
	self._layout.vars.scroll:removeAllChildren()
	
	local prestigeRewards = i3k_db_climbing_tower_prestige[id]

	for i,v in ipairs(prestigeRewards) do
		local LAYER_SBLBT = require("ui/widgets/wjswt")()
		
		if level >= i then
			self._state = 1
			LAYER_SBLBT.vars.take:enableWithChildren()
		else
			self._state = 2
			LAYER_SBLBT.vars.take:disableWithChildren()
		end
		self:updateTakeGiftStateItem(LAYER_SBLBT,id,level,v.rewards,v.name,rewardSeq[v.lvl],v.uniqueSkillID,i)
		
		self._layout.vars.scroll:addItem(LAYER_SBLBT)
	end
	if index then
		self._layout.vars.scroll:jumpToListPercent( index )--跳到上一次记录的位置
	else
		self._layout.vars.scroll:jumpToListPercent(0 )
	end
	

end
function wnd_fiveUnique_prestige:updateTakeGiftStateItem(item,id,level,gifts,name,rewards,uniqueSkillID,index)
	local role_id = g_i3k_game_context:GetRoleType()

	local exskill = 0
	local _skill_data = 0
	local giftTb = {
	[1] = {root = item.vars.item_bg, icon = item.vars.item_icon, count = item.vars.item_count,suo = item.vars.item_suo},--,bg = item.vars.count_bg},
	[2] = {root = item.vars.item_bg2, icon = item.vars.item_icon2, count = item.vars.item_count2 ,suo = item.vars.item_suo2},--,bg = item.vars.count_bg2},
	[3] = {root = item.vars.item_bg3, icon = item.vars.item_icon3, count = item.vars.item_count3 ,suo = item.vars.item_suo3},--,bg = item.vars.count_bg3}
	}
	local juejiTab = {root= item.vars.item_icon4}
	item.vars.state:setText( string.format("达到%s",name))--状态i3k_db_climbing_tower_prestige[id][level].name
	
	for k,v in ipairs(gifts) do
		juejiTab.root:hide()
		if v.itemCount > 0 and v.itemID then
			giftTb[k].root:show()
			giftTb[k].root:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.itemID) )
			giftTb[k].icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemID,i3k_game_context:IsFemaleRole()))
			if v.itemCount > 1 then
				giftTb[k].count:setText("x"..v.itemCount)
			else
				--giftTb[k].bg:hide()
				giftTb[k].count:hide()
			end
			giftTb[k].icon:onClick(self, self.onTips,v.itemID)
		else
			--i3k_db_climbing_tower_prestige[id].uniqueSkillID,i3k_db_exskills[uniqueSkillID].skills[role_id]
			if uniqueSkillID > 0 then
				exskill = i3k_db_exskills[uniqueSkillID].skills[role_id]
				_skill_data = i3k_db_skills[exskill].icon
				--self.skill1Small:setImage(g_i3k_db.i3k_db_get_icon_path(_skill_data.icon))
				--local state = role_unique_skill[v].state
				--self.skill1:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[state + 1]))
				--giftTb[k].root:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path() )
				giftTb[k].root:hide()
				--giftTb[k].count:hide()
				--giftTb[k].icon:setImage(g_i3k_db.i3k_db_get_icon_path(_skill_data))--(i3k_db_icons[_skill_data].path)--i3k_db_icons[i3k_db_skills[skillid].icon].path
				--giftTb[k].icon:onClick(self, self.onSkillTips,exskill)
				juejiTab.root:show()
				juejiTab.root:setImage(g_i3k_db.i3k_db_get_icon_path(_skill_data))
				juejiTab.root:onClick(self, self.onSkillTips,exskill)
				
			else
				giftTb[k].root:hide()
			end
			
		end
		
		if v.itemID > 0 and v.itemID then
			giftTb[k].suo:show()
		
		else
			giftTb[k].suo:hide()
		end
	
	end
	if rewards then
		item.vars.btn_text:setText("已领取")
		self._state = 2
		item.vars.take:disableWithChildren()
	else
		
		item.vars.take:onClick(self, self.onClickTakeBtn,{id = index,gifts = gifts,item = item,skills = _skill_data,skillId = exskill,uniqueSkillId = uniqueSkillID})--领取
			
	end
	item.vars.isHave:setImage(g_i3k_db.i3k_db_get_icon_path(l_tTabName[self._state]))
end
-----------声望值
function wnd_fiveUnique_prestige:updatePrestigeValue(id)
	--uniqueSkillID 获得的绝技id
	local widgets = self._layout.vars
	local level = g_i3k_game_context:GetRoleTowerPrestigeLvl(id)--获得当前声望等级
	
	local value = g_i3k_game_context:GetRoleTowerPrestigeValue(id)--获得当前声望值
	local have_value = level == 1 and i3k_db_climbing_tower_prestige[id][level].needPrestige or value - i3k_db_climbing_tower_prestige[id][level-1].needPrestige---上一次的声望
	local maxLevel = #i3k_db_climbing_tower_prestige[id]
	
	local need_value = level == maxLevel and i3k_db_climbing_tower_prestige[id][level].needPrestige or i3k_db_climbing_tower_prestige[id][level+1].needPrestige
	--i3k_log("shengwangzhi = ",level,maxLevel,value,have_value,need_value,self._percent)
	if value == need_value and  level ~= maxLevel then
		level = level + 1
		need_value = i3k_db_climbing_tower_prestige[id][level+1].needPrestige
	elseif level == maxLevel then
		value = i3k_db_climbing_tower_prestige[id][maxLevel].needPrestige
	end
	--i3k_log("shengwangzhi after = ",level,maxLevel,value,need_value,self._percent)
	widgets.attFriend_value2:setVisible(value ~= need_value)
	widgets.attFriend_value2:setText(value.."/"..need_value)--声望值
	widgets.max:setVisible(value == need_value)
	widgets.max_txt:setVisible(value == need_value)
	local cfg = i3k_db_climbing_tower[id]
	widgets.max_txt:setText(string.format(cfg.maxDesc, cfg.title))
	widgets.donate_root:setVisible(value ~= need_value)
	widgets.attFriend_slider2:setPercent(value/need_value * 100)
end

function wnd_fiveUnique_prestige:onItemInfo(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end
---领取奖励
function wnd_fiveUnique_prestige:onClickTakeBtn(sender,needValue)
	local gift = {}
	
	local percent = self._layout.vars.scroll:getListPercent()
	local giftsTb = needValue.gifts
	local isEnoughTable = { }
	local index = 0
	--local skillId = 0
	for i,v in ipairs(giftsTb) do
		if v.itemID == 0  then
			--isEnoughTable[needValue.skills] = 1
			--skillId = needValue.skillId
		else
			isEnoughTable[v.itemID] = v.itemCount
		end

	end
	
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	for i,v in pairs (isEnoughTable) do
		index = index + 1
		gift[index] = {id = i,count = v}
		
	end
	if isEnough then
		self:setFameTower(false)
		i3k_sbean.activities_towerfame_take(self._id,needValue.id,gift,needValue.item,percent,needValue.skillId,needValue.uniqueSkillId)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	end
	
	
end

---
function wnd_fiveUnique_prestige:changeBtnState(item)
	--i3k_log("changeBtnState = ")
	item.vars.take:disableWithChildren()
end


---排行榜
function wnd_fiveUnique_prestige:onClickRankBtn(sender)
	g_i3k_ui_mgr:PopupTipMessage("五绝排行榜正在制作中")
end

--购买道具后刷新UI展示//add by jxw
function wnd_fiveUnique_prestige:updateUI(id)
	self:SetPayOutItemInfo(self._id)
end

---左
function wnd_fiveUnique_prestige:onClickLeftBtn(sender)

	self._id = self._id - 1
	if self._id < 1 then
		self._id = 1
	end
	if self.modelValue[self._id] then
		self.rewardValue = self.modelValue[self._id].reward
		if next(self.modelValue[self._id]) ~= nil then
			self:setFameTower(false)
			i3k_sbean.sync_fame_tower(self._id )
		

		end
	end 
	
end
---右
function wnd_fiveUnique_prestige:onClickRightBtn(sender)

	self._id = self._id + 1
	if self._id > #i3k_db_climbing_tower_prestige then
		self._id = #i3k_db_climbing_tower_prestige
	end
	if self.modelValue[self._id] then 
		self.rewardValue = self.modelValue[self._id].reward
		if next(self.modelValue[self._id]) ~= nil then
			self:setFameTower(false)
			i3k_sbean.sync_fame_tower(self._id )
		
		end
	end 
	
end

--当捐赠时设置为true  其他刷新界面的操作设置为false
function wnd_fiveUnique_prestige:setFameTower(able)
	self._fameTower = able 
end

function wnd_fiveUnique_prestige:onUseItem(sender, eventType, data)
	local percent = self._layout.vars.scroll:getListPercent()
	if eventType==ccui.TouchEventType.began then
		if g_i3k_game_context:GetCommonItemCanUseCount(data.itemid) <= 0 then
			g_i3k_ui_mgr:ShowCommonItemInfo(data.itemid)
		else
			local maxLevel = #i3k_db_climbing_tower_prestige[self._id]
			local curLevel = self.modelValue[self._id].level
			if curLevel < maxLevel then
				i3k_sbean.activities_towerfame_donate(self._id,data.itemid,percent)--捐赠协议
			else
				g_i3k_ui_mgr:PopupTipMessage("声望已满")
			end
		end	
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
	end
end

function wnd_fiveUnique_prestige:onBatchUse(sender)  --一键使用
	local maxLevel = #i3k_db_climbing_tower_prestige[self._id]
	local curLevel = self.modelValue[self._id].level
	if curLevel < maxLevel then
		if self.items[1] > 0 or self.items[2] > 0 then
			i3k_sbean.tower_onekey_donate(1, self._id)
		else
			i3k_sbean.tower_onekey_donate(2, self._id)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("声望已满")
	end
end

function wnd_fiveUnique_prestige:onTips(sender,itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

---显示绝技tips
function wnd_fiveUnique_prestige:onSkillTips(sender,skillId)
	g_i3k_ui_mgr:OpenUI(eUIID_TransfromSkillTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_TransfromSkillTips,skillId)
end
--[[function wnd_fiveUnique_prestige:closeBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FiveUniquePrestige)
end--]]

function wnd_create(layout)
	local wnd = wnd_fiveUnique_prestige.new()
	wnd:create(layout)
	return wnd
end
