-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/add_sub")
-------------------------------------------------------
wnd_steed_skill = i3k_class("wnd_steed_skill", ui.wnd_add_sub)



local f_state_table = {
	[g_HS_SKILL_BORN]	    = 1249,
	[g_HS_SKILL_CAN_ACT]	= 1246,
	[g_HS_SKILL_IN_USE]		= 1248,
	[g_HS_SKILL_CAN_USE]	= 1247,
	[g_HS_SKILL_NOT_ACT]	= 1245,
}

local ITEM_WIDGET = "ui/widgets/zqqsbgt"

function wnd_steed_skill:ctor()
	self._oldIndex = nil
end

function wnd_steed_skill:configure()
	local widgets = self._layout.vars
	self._skillIconTable = {
		[1] = widgets.skill1,
		[2] = widgets.skill2,
		[3] = widgets.skill3,
		[4] = widgets.skill4,
		[5] = widgets.skill5,
		[6] = widgets.skill6,
	}
	widgets.skill_btn:onClick(self, self.openSkillList)
	widgets.skillBag_btn:onClick(self, self.openSkillBooksBag)
	widgets.skill_btn:stateToPressed()
	self._scroll = widgets.scroll
	widgets.scroll:setBounceEnabled(false)
	self._skillTable = {}
	local index = 1
	for i,v in ipairs(i3k_db_steed_skill) do
		if v.skillType==2 then
			index = index + 1
			self._skillTable[index] = {}
			self._skillTable[index].cfg = v
			local needId = v.actNeedId
			local needCount = v.actNeedCount
			local itemCount = g_i3k_game_context:SearchHorseBook(needId)
			if needCount<=itemCount then
				self._skillTable[index].stateId = g_HS_SKILL_CAN_ACT--可以激活
			else
				self._skillTable[index].stateId = g_HS_SKILL_NOT_ACT--未激活
			end
		end
	end
	self._lockTable = {
		[1] = widgets.lock1,
		[2] = widgets.lock2,
		[3] = widgets.lock3,
		[4] = widgets.lock4,
		[5] = widgets.lock5,
	}
	
	self.add_btn = widgets.jia
	self.sub_btn = widgets.jian
	self.max_btn = widgets.max
	widgets.sale_count:setText(1)
	self._count_label = widgets.sale_count
	--self.current_add_num = info.booksCount
	
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self,self.onSub)
	self.max_btn:onTouchEvent(self,self.onMax)
	
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self._layout.vars.tips:setText(i3k_get_string(16943))
end

---------------与骑术背包相关------------------
function wnd_steed_skill:setNumCount(count)
	self._count_label:setText(count)
end

function wnd_steed_skill:updateFun()
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkill,"setNumCount",self.current_num)
	end
end

function wnd_steed_skill:showBagRedPoint()
	self._layout.vars.btn_point:setVisible(g_i3k_game_context:canAddBook())
	self._layout.vars.skillBagRedPoint:setVisible(g_i3k_game_context:canAddBook())
end

function wnd_steed_skill:setSkillBagInfo()
	self._horseBookId = nil
	self:showSkillBooks()
	self:updateFun()
	local tbl = self:getSortId()
	if next(tbl) then
		self._layout.vars.haveBooks:show()
		self._layout.vars.itemName:show()
		self._layout.vars.noBooks:hide()
		self:choseItem(nil, tbl[1])
	else
		self._layout.vars.haveBooks:hide()
		self._layout.vars.itemName:hide()
		self._layout.vars.noBooks:show()
		self._layout.vars.noBooksTip:setText(i3k_get_string(16918))
	end
	
	self._count_label:addEventListener(function(eventType)
		if eventType == "ended" then
			if self._count_label:getText() ~= "" and tonumber(self._count_label:getText()) then
			    local num = tonumber(self._count_label:getText())
			    if num > self.current_add_num then
			       self.current_num = self.current_add_num
			    elseif num < 1 then
			       self.current_num = 1
			    else 
					self.current_num = num
		        end
		        self._count_label:setText(self.current_num)
			else 
				self._count_label:setText(self.current_num)
		    end
		end
	end)
	
	self:showBagRedPoint()
end

function wnd_steed_skill:getSortId()
	local tbl = {}
	local tbl2 = {}
	local allBooks = g_i3k_game_context:GetHorseBooks()
	for i,v in pairs(allBooks) do
		if not table.indexof(tbl,  math.abs(i)) then
			table.insert(tbl, math.abs(i))
		end
	end
	table.sort(tbl)
	for i, v in ipairs(tbl) do
		if allBooks[v] and allBooks[v] > 0 then
			table.insert(tbl2, v)
		end
		if allBooks[-v] and allBooks[-v] > 0 then
			table.insert(tbl2, -v)
		end
	end
	return tbl2
end

function wnd_steed_skill:showSkillBooks()
	local allBooks = g_i3k_game_context:GetHorseBooks()
	local bookIdInfo = self:getSortId()
	local scroll = self._layout.vars.bagScroll
	scroll:removeAllChildren()
	local children = scroll:addChildWithCount(ITEM_WIDGET, 5, #bookIdInfo)
	for i, v in ipairs(children) do
		v.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(bookIdInfo[i], g_i3k_game_context:IsFemaleRole()))
		v.vars.bgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(bookIdInfo[i]))
		v.vars.count:setText("x" .. allBooks[bookIdInfo[i]])
		v.vars.lock:setVisible(bookIdInfo[i] > 0)
		v.vars.item_btn:setTag(bookIdInfo[i])
		v.vars.item_btn:onClick(self, self.choseItem, bookIdInfo[i])
	end
end

function wnd_steed_skill:choseItem(sender, id)
	if not self._horseBookId or self._horseBookId ~= id then
		local allBooks = g_i3k_game_context:GetHorseBooks()
		self._horseBookId = id
		self.current_add_num = allBooks[id]
		self._count_label:setText(1)
		self.current_num = 1
		self._layout.vars.itemName:setText(g_i3k_db.i3k_db_get_common_item_name(id))
		self:showChosenIcon(id)
	end
end

function wnd_steed_skill:showChosenIcon(id)
	local tbl = self._layout.vars.bagScroll:getAllChildren()
	for i, v in ipairs(tbl) do
		if id == v.vars.item_btn:getTag() then
			v.vars.chosenIcon:show()
		else
			v.vars.chosenIcon:hide()
		end
	end
end

function wnd_steed_skill:popHorseBook(sender, steedId)
	if self._horseBookId then
		local tbl = {}
		tbl[self._horseBookId] = self.current_num
		i3k_sbean.goto_horseBook_pop(tbl, steedId)
	end
end

function wnd_steed_skill:pushAllHorseBook(sender, steedId)
	local tbl = g_i3k_game_context:GetAllItemsForType(UseItemHorseBook)
	local tbl2 = {}
	if next(tbl) then
		for i, v in pairs(tbl) do
			tbl2[v.id] = v.count
		end
		i3k_sbean.goto_horseBook_push(tbl2, steedId)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16919))
	end
end

----------------------------------------------------------------------------------------------------------------------------
function wnd_steed_skill:refresh(steedId, info, percent)
	self._layout.vars.pop:onClick(self, self.popHorseBook, steedId)
	self._layout.vars.push_all:onClick(self, self.pushAllHorseBook, steedId)
	self:setSkillBagInfo()

	local canUseCount = i3k_db_steed_star[info.id][info.star].canUseRideCount
	local btnTable = {
		[1] = self._layout.vars.lockBtn1,
		[2] = self._layout.vars.lockBtn2,
		[3] = self._layout.vars.lockBtn3,
		[4] = self._layout.vars.lockBtn4,
		[5] = self._layout.vars.lockBtn5,
	}
	for i,v in ipairs(self._lockTable) do
		v:setVisible(i>canUseCount)
		btnTable[i]:onClick(self, function ()
			for j,t in ipairs(i3k_db_steed_star[info.id]) do
				if t.canUseRideCount==i then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(273, j))
					break
				end
			end
		end)
	end
	
	local rideSkill = i3k_db_steed_cfg[steedId].equitationId--先天骑术
	if i3k_db_steed_skill[rideSkill] and i3k_db_steed_skill[rideSkill].skillType == 1 then--是先天骑术
		local skillCfg = i3k_db_steed_skill[rideSkill]
		self._skillTable[1] = {cfg = skillCfg, stateId = 1}
	end
	
	self:setUseData(info)
	
	local stateTable = {[g_HS_SKILL_BORN] = {}, [g_HS_SKILL_CAN_ACT] = {}, [g_HS_SKILL_IN_USE] = {}, [g_HS_SKILL_CAN_USE] = {}, [g_HS_SKILL_NOT_ACT] = {},}
	local allSkill = g_i3k_game_context:getAllSteedSkills()
	for i,v in ipairs(self._skillTable) do
		local isInUse = false
		for _,t in pairs(info.curHorseSkills) do
			if t==v.cfg.skillId then
				isInUse = true
				break
			end
		end
		if isInUse then
			v.stateId = g_HS_SKILL_IN_USE--装备中
		elseif allSkill[v.cfg.skillId] and rideSkill~= v.cfg.skillId then
			v.stateId = g_HS_SKILL_CAN_USE--可以装备
		end
		table.insert(stateTable[v.stateId], v) --根据当前是否装备词骑术 将骑术分类为装备中 可装备表中
	end
	self._skillTable = {}
	for i,v in ipairs(stateTable) do
		for _,t in ipairs(v) do
			table.insert(self._skillTable, t)
		end
	end
	local x = self._skillTable
	--jxw  此处需要读取服务器返回数据 = 
	local dataLevel = g_i3k_game_context:getSteedSkillLevelData()
	
	
	for i,v in ipairs(self._skillTable) do
		local node = require("ui/widgets/zqqst")()
		local skillLvl =dataLevel[v.cfg.skillId] 
		self:setNodeData(node, v.cfg, skillLvl, i, steedId)
		
		self._scroll:addItem(node)
	end
	
	if percent then
		self._scroll:jumpToListPercent(percent)
	end
	
	local widgets = self._layout.vars
	self._posTable = {
		[1] = {radius = widgets.skillRoot1:getContentSize().width/2, pos = widgets.image:getParent():convertToNodeSpace(widgets.skillRoot1:getParent():convertToWorldSpace(widgets.skillRoot1:getPosition()))},
		[2] = {radius = widgets.skillRoot2:getContentSize().width/2, pos = widgets.image:getParent():convertToNodeSpace(widgets.skillRoot2:getParent():convertToWorldSpace(widgets.skillRoot2:getPosition()))},
		[3] = {radius = widgets.skillRoot3:getContentSize().width/2, pos = widgets.image:getParent():convertToNodeSpace(widgets.skillRoot3:getParent():convertToWorldSpace(widgets.skillRoot3:getPosition()))},
		[4] = {radius = widgets.skillRoot4:getContentSize().width/2, pos = widgets.image:getParent():convertToNodeSpace(widgets.skillRoot4:getParent():convertToWorldSpace(widgets.skillRoot4:getPosition()))},
		[5] = {radius = widgets.skillRoot5:getContentSize().width/2, pos = widgets.image:getParent():convertToNodeSpace(widgets.skillRoot5:getParent():convertToWorldSpace(widgets.skillRoot5:getPosition()))},
		[6] = {radius = widgets.skillRoot6:getContentSize().width/2, pos = widgets.image:getParent():convertToNodeSpace(widgets.skillRoot6:getParent():convertToWorldSpace(widgets.skillRoot6:getPosition()))},
	}
	self:setSkillListRedPoint(steedId)
end

--简单形式    steedid 坐骑id  --默认全部技能都是1级 然后 不满足条件的不显示等级
function wnd_steed_skill:setNodeData(node, skillCfg, skillLvl, index, steedId)
	local dataLevel = g_i3k_game_context:getSteedSkillLevelData()
	local skillLvl = dataLevel[skillCfg.skillId] 
	local stateId = self._skillTable[index].stateId
	if stateId ==g_HS_SKILL_NOT_ACT or stateId ==g_HS_SKILL_CAN_ACT then
		node.vars.levelLabel:setVisible(false)
	end
	local cfg = i3k_db_steed_skill_cfg[skillCfg.skillId][skillLvl]
	node.vars.nameLabel:setText(i3k_db_steed_skill[skillCfg.skillId].skillName)
	node.vars.levelLabel:setText(skillLvl .. "级")
	local str
	if index==1 then
		str = string.format("%s", "先天骑术")
		node.vars.typeLabel:setTextColor(g_i3k_get_cond_color(false))
		
		node.vars.skillBtn:onTouchEvent(self, function(hoster, sender, eventType)
			if eventType==ccui.TouchEventType.began then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(274))
				self._scroll:stateToNoSlip()
			elseif eventType~=ccui.TouchEventType.moved then
				self._scroll:stateToSlip()
			end
		end)
		
		self._skillIconTable[index]:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.iconID))
	else
		str = string.format("%s", "后天骑术")
		node.vars.typeLabel:setTextColor(g_i3k_get_cond_color(true))
		if stateId~=g_HS_SKILL_CAN_ACT and stateId~=g_HS_SKILL_NOT_ACT then
			node.vars.skillBtn:setTag(skillCfg.iconID)
			node.vars.skillBtn:onTouchEvent(self, self.onSkillMove, {steedId = steedId, skillId = skillCfg.skillId, index = index})
		end
	end 
	node.vars.stateImg:show()
	node.vars.upLevelBtn:show()
	if stateId ==1 or stateId ==4 or stateId ==3 then  --显示升级  stateId ==1 先天骑术 ==4 可装备 ==5 未激活 --2 可激活
		node.vars.stateImg:hide()
		--升级按钮展示
		--点击事件 --骑术信息 
		node.vars.upLevelBtn:setTag(index+1000)
		local needValue = {node = node,skillCfg = skillCfg,skillLvl = skillLvl, index = index, steedId = steedId,types = 1}
		node.vars.upLevelBtn:onClick(self, self.onUpLevelBtn, needValue)
	else
		node.vars.upLevelBtn:hide()
		node.vars.stateImg:setImage(g_i3k_db.i3k_db_get_icon_path(f_state_table[stateId])) --只有激活 未激活展示图片
	end
	--当可升级或者可激活时 显示红点
	--stateId:1先天骑术 2可激活 3装备中 4 可装备 5 未激活		
	node.vars.redPoint:setVisible(stateId ==2 or g_i3k_game_context:isUpSteedSkillEnough(skillCfg.skillId,skillLvl,stateId~=5))
	node.vars.typeLabel:setText(str)
	node.vars.descLabel:setText(cfg.skillDesc)
	
	node.vars.skillIcon:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.iconID))
	--未激活时 icon灰化 --add by jxw 16.9.29
	if stateId ==5 then
		node.vars.skillIcon:disable()
	else
		node.vars.skillIcon:enable()
	end
	local nextCfg = i3k_db_steed_skill_cfg[skillCfg.skillId][skillLvl+1]
	if not nextCfg then
		node.vars.upLevelBtn:hide()
		node.vars.stateImg:show()
		node.vars.stateImg:setImage(g_i3k_db.i3k_db_get_icon_path(2705)) --满级标记
	end
	if stateId~=g_HS_SKILL_CAN_ACT and stateId~=g_HS_SKILL_NOT_ACT and not nextCfg then
		node.vars.btn:onClick(self, function ()
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(275))--骑术满级
		end)
	else
		local needValue = {skillLvl = skillLvl, steedId = steedId}
		node.vars.btn:setTag(index)
		node.vars.btn:onClick(self, self.onSkillClick, needValue)
	end
end

--复杂形式
function wnd_steed_skill:setOpenNodeData(node, skillCfg, index, needValue)
	--设置展开前数据
	local skillId = skillCfg.skillId
	local dataLevel = g_i3k_game_context:getSteedSkillLevelData()
	needValue.skillLvl = dataLevel[skillId] 
	local stateId = self._skillTable[index].stateId
	if stateId ==g_HS_SKILL_NOT_ACT or stateId ==g_HS_SKILL_CAN_ACT then
		node.vars.levelLabel:setVisible(false)
	end
	
	local cfg = i3k_db_steed_skill_cfg[skillId][needValue.skillLvl]
	node.vars.nameLabel:setText(i3k_db_steed_skill[skillId].skillName)
	node.vars.levelLabel:setText(needValue.skillLvl .. "级")
	local str
	if index==1 then
		str = string.format("%s", "先天骑术")
		node.vars.typeLabel:setTextColor(g_i3k_get_cond_color(false))
		
		node.vars.skillBtn:onTouchEvent(self, function(hoster, sender, eventType)
			if eventType==ccui.TouchEventType.began then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(274))
				self._scroll:stateToNoSlip()
			elseif eventType~=ccui.TouchEventType.moved then
				self._scroll:stateToSlip()
			end
		end)
		
		self._skillIconTable[index]:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.iconID))
	else
		str = string.format("%s", "后天骑术")
		node.vars.typeLabel:setTextColor(g_i3k_get_cond_color(true))
		
		if stateId~=g_HS_SKILL_CAN_ACT and stateId~=g_HS_SKILL_NOT_ACT then
			node.vars.skillBtn:setTag(skillCfg.iconID)
			local needValue = {steedId = needValue.steedId, skillId = skillId, index = index}
			node.vars.skillBtn:onTouchEvent(self, self.onSkillMove, needValue)
		end
	end
	node.vars.stateImg:show()
	node.vars.upLevelBtn:show()
	if stateId ==1 or stateId ==4 or stateId ==3 then  --显示升级  stateId ==1 先天骑术 ==4 可装备 ==5 未激活 --2 可激活
		node.vars.stateImg:hide()
		--升级按钮展示
		--点击事件 --骑术信息 
		node.vars.upLevelBtn:setTag(index+1000)
		local needValue = {node = node,skillCfg = skillCfg,skillLvl = needValue.skillLvl,index = index, steedId = needValue.steedId,types = 2}
		--local needValue = {node = node,skillCfg = skillCfg,index = index,data = {skillLvl = skillLvl, steedId = steedId},types = 2}
		node.vars.upLevelBtn:onClick(self, self.onUpLevelBtn, needValue)
	else
		node.vars.upLevelBtn:hide()
		node.vars.stateImg:setImage(g_i3k_db.i3k_db_get_icon_path(f_state_table[stateId])) --只有激活 未激活展示图片
		--node.vars.redPoint:hide()
		--if  stateId ==2 then
		--	node.vars.redPoint:show()
		--end
	end
	--stateId:1先天骑术 2可激活 3装备中 4 可装备 5 未激活		
	node.vars.redPoint:setVisible(stateId ==2 or g_i3k_game_context:isUpSteedSkillEnough(skillCfg.skillId,needValue.skillLvl,stateId~=5))
	node.vars.typeLabel:setText(str)
	node.vars.descLabel:setText(cfg.skillDesc)
	
	node.vars.skillIcon:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.iconID))
	--未激活时 icon灰化 --add by jxw 16.9.29
	if stateId ==5 then
		node.vars.skillIcon:disable()
	else
		node.vars.skillIcon:enable()
	end
	
	node.vars.btn:setTag(index)
	node.vars.btn:onClick(self, self.onSkillClick, needValue)
	
	
	
	local nextCfg = i3k_db_steed_skill_cfg[skillId][needValue.skillLvl+1]
	
	--node.vars.maxImg:setVisible(not nextCfg)--设置展开前的max满级图标
	if not nextCfg then
		node.vars.upLevelBtn:hide()
		node.vars.stateImg:show()
		node.vars.stateImg:setImage(g_i3k_db.i3k_db_get_icon_path(2705)) --满级标记
	end
	--设置展开后数据
	node.vars.actRoot:setVisible(stateId==g_HS_SKILL_CAN_ACT or stateId==g_HS_SKILL_NOT_ACT)
	node.vars.actBtn:setVisible(stateId==g_HS_SKILL_CAN_ACT)
	node.vars.getDesc:setVisible(not node.vars.actBtn:isVisible())
	
	local needId = i3k_db_steed_skill[skillId].actNeedId
	local needCount = i3k_db_steed_skill[skillId].actNeedCount
	local getText = string.format("%s\n%s", "获取途径:", g_i3k_db.i3k_db_get_common_item_source(needId))
	node.vars.getDesc:setText(getText)
	node.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needId))
	node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needId,i3k_game_context:IsFemaleRole()))
	local name = g_i3k_db.i3k_db_get_common_item_name(needId)
	node.vars.countLabel:setText(name.."x"..needCount)
	node.vars.countLabel:setTextColor(g_i3k_get_cond_color(stateId==g_HS_SKILL_CAN_ACT))--颜色
	node.vars.actBtn:onClick(self, self.actSkill, {steedId = needValue.steedId, skillId = skillId, needItem = {[needId] = needCount}})
	
	node.vars.hasActRoot:setVisible(not node.vars.actRoot:isVisible())
	if nextCfg then
		node.vars.nextDesc:setText(nextCfg.skillDesc)
		node.vars.notesLabel:setVisible(stateId~=g_HS_SKILL_IN_USE)
		local str
		if stateId==g_HS_SKILL_BORN then
			str = string.format("%s", "先天骑术不可更换、卸下")
		elseif stateId==g_HS_SKILL_CAN_USE then
			str = string.format("%s", "拖拽图示进行装备")
		end
		node.vars.notesLabel:setText(str)
	end
end

function wnd_steed_skill:onSkillClick(sender, needValue)
	local index = sender:getTag()
	if self._oldIndex then
		local node = require("ui/widgets/zqqst")()
		
		self:setNodeData(node, self._skillTable[self._oldIndex].cfg, needValue.skillLvl, self._oldIndex, needValue.steedId)
		
		self._scroll:replaceItemAtIndex(node, self._oldIndex, true)
		if self._oldIndex==index then
			self._oldIndex = nil
			return 
		end
	end
	
	
	local node = require("ui/widgets/zqqst2")()
	
	self:setOpenNodeData(node, self._skillTable[index].cfg, index, needValue)
	
	self._scroll:replaceItemAtIndex(node, index)
	self._oldIndex = index
end

function wnd_steed_skill:useSteedSkill(info, oldSkillId,index)
	if oldSkillId then
		for i,v in ipairs(self._skillTable) do
			if v.cfg.skillId==oldSkillId then
				v.stateId = g_HS_SKILL_CAN_USE
				self:replaceAndSetNodeData(info, i)
				break
			end
		end
	end
	
	self._skillTable[index].stateId = g_HS_SKILL_IN_USE
	self:replaceAndSetNodeData(info, index)
	g_i3k_game_context:RefreshRideProps()
end

function wnd_steed_skill:onSkillMove(sender, eventType, needValue)
	local pos = self._layout.vars.image:getParent():convertToNodeSpace(g_i3k_ui_mgr:GetMousePos())
	local image = self._layout.vars.image
	if eventType==ccui.TouchEventType.began then
		image:show()
		image:setPosition(pos)
		image:setImage(g_i3k_db.i3k_db_get_icon_path(sender:getTag()))
		self._scroll:stateToNoSlip()
	elseif eventType==ccui.TouchEventType.moved then
		image:setPosition(pos)
	else
		local x = self._posTable
		local disTable = {
			[1] = math.sqrt(math.pow(pos.x - self._posTable[1].pos.x, 2) + math.pow(pos.y - self._posTable[1].pos.y, 2)),
			[2] = math.sqrt(math.pow(pos.x - self._posTable[2].pos.x, 2) + math.pow(pos.y - self._posTable[2].pos.y, 2)),
			[3] = math.sqrt(math.pow(pos.x - self._posTable[3].pos.x, 2) + math.pow(pos.y - self._posTable[3].pos.y, 2)),
			[4] = math.sqrt(math.pow(pos.x - self._posTable[4].pos.x, 2) + math.pow(pos.y - self._posTable[4].pos.y, 2)),
			[5] = math.sqrt(math.pow(pos.x - self._posTable[5].pos.x, 2) + math.pow(pos.y - self._posTable[5].pos.y, 2)),
			[6] = math.sqrt(math.pow(pos.x - self._posTable[6].pos.x, 2) + math.pow(pos.y - self._posTable[6].pos.y, 2)),
		}
		for i,v in ipairs(disTable) do
			if v<=self._posTable[i].radius then
				if i==1 then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(274))
				elseif not self._lockTable[i-1]:isVisible() then
					i3k_sbean.use_steed_skill(needValue.steedId, i-1, needValue.skillId, needValue.index)
					--self._skillIconTable[i]:setImage(g_i3k_db.i3k_db_get_icon_path(sender:getTag()))
				else
					for j,t in ipairs(i3k_db_steed_star[needValue.steedId]) do
						if t.canUseRideCount==i-1 then
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(273, j))
							break
						end
					end
				end
				break
			end
		end
		image:hide()
		self._scroll:stateToSlip()
	end
end

function wnd_steed_skill:replaceAndSetNodeData(info, index)
	local skillLvl = i3k_db_steed_lvl[info.id][info.enhanceLvl].rideLvl
	local node = require("ui/widgets/zqqst")()
	self:setNodeData(node, self._skillTable[index].cfg, skillLvl, index, info.id)
	self._scroll:replaceItemAtIndex(node, index, true)
	if self._oldIndex==index then
		self._oldIndex = nil
	end
end
---激活 弹窗
function wnd_steed_skill:actSkill(sender, needValue)
	g_i3k_ui_mgr:OpenUI(eUIID_SteedActSkill)
	g_i3k_ui_mgr:RefreshUI(eUIID_SteedActSkill, needValue.steedId, needValue.skillId, needValue.needItem)
end
--激活成功回调函数
function wnd_steed_skill:actCallbackFunc(info)
	self._skillTable[self._oldIndex].stateId = g_HS_SKILL_CAN_USE
	self:replaceAndSetNodeData(info, self._oldIndex)
end


function wnd_steed_skill:setUseData(info)
	for i,v in ipairs(self._skillIconTable) do
		if i>1 then
			v:hide()
			if info.curHorseSkills[i-1] then
				v:show()
				local icon = i3k_db_steed_skill[info.curHorseSkills[i-1]].iconID
				v:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			end
		end
	end
end

function wnd_steed_skill:onUpLevelBtn(sender,needValue)
	local tag = sender:getTag() - 1000
	self._onSelect = tag
	g_i3k_ui_mgr:OpenUI(eUIID_steedSkillUpLevel)
	g_i3k_ui_mgr:RefreshUI(eUIID_steedSkillUpLevel,tag ,needValue)
	--local cfg = i3k_db_steed_skill_cfg[skillCfg.skillId][skillLvl]
	--local needValue = {node = node,skillCfg = skillCfg,skillLvl = needValue.skillLvl,
	--index = index, steedId = needValue.steedId,types = 2}
	
	--local needValue = {node = node,skillCfg = skillCfg,skillLvl = skillLvl, index = index, steedId = steedId,types = 1}
end

--
function wnd_steed_skill:setRedPointData(data)
		local needValue = {}
		if data.types ==1 then
			needValue = {skillLvl = data.skillLvl,steedId = data.steedId}
		elseif data.types ==2 then
			needValue = {skillLvl = data.skillLvl,steedId = data.steedId}
		end
		self:setUpLevelData(needValue) --
	--for i,v in ipairs(self._skillTable) do
		--if i3k_db_steed_skill_cfg[data.skillCfg.skillId][data.skillLvl] then 
	--	tab[i]:setVisible(v.stateId ==2 or g_i3k_game_context:isUpSteedSkillEnough(data.skillCfg.skillId,data.skillLvl,v.stateId~=5))
	--end	
end

--升级后替换对应node数据(关闭状态) --jxw
function wnd_steed_skill:setUpLevelData(needValue)
	local index = self._onSelect
	
	local node = require("ui/widgets/zqqst")()
	self:setNodeData(node, self._skillTable[self._onSelect].cfg, needValue.skillLvl, self._onSelect, needValue.steedId)
	self._scroll:replaceItemAtIndex(node, self._onSelect, true)
	if self._oldIndex ==index then
		self._oldIndex = nil
	end
end

function  wnd_steed_skill:openSkillList(sender)
	if not self._layout.vars.skill_btn:isStatePressed() then
		self._layout.vars.skill_btn:stateToPressed()
		self._layout.vars.skillBag_btn:stateToNormal()
		self._layout.vars.skilllRoot:show()
		self._layout.vars.skillBagRoot:hide()
	end
end

function wnd_steed_skill:openSkillBooksBag(sender)
	if not self._layout.vars.skillBag_btn:isStatePressed() then
		self._layout.vars.skillBag_btn:stateToPressed()
		self._layout.vars.skill_btn:stateToNormal()
		self._layout.vars.skillBagRoot:show()
		self._layout.vars.skilllRoot:hide()
	end
end

function wnd_steed_skill:setSkillListRedPoint(id)
	local steedInfo = g_i3k_game_context:getAllSteedInfo()
	local info = steedInfo[id]

	self._layout.vars.skillListRedPoint:setVisible(g_i3k_game_context:isEnoughUpSteedSkillToAct(id,info))
end

function wnd_create(layout, ...)
	local wnd = wnd_steed_skill.new()
	wnd:create(layout, ...)
	return wnd;
end
