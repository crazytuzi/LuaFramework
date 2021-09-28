-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_underwear_talentPoint = i3k_class("wnd_underwear_talentPoint",ui.wnd_base)

function wnd_underwear_talentPoint:ctor()
	--self.canOpenAble = {} --记录前提条件是否满足
	--self.canOpen = false
	self.canOpen1 = true  --记录前提条件是否满足
end

function wnd_underwear_talentPoint:configure()
	local widgets = self._layout.vars
	self._layout.vars.close:onClick(self,self.onCloseUI)
	self.item_bg = widgets.item_bg
	self.item_icon = widgets.item_icon
	self.item_btn = widgets.item_btn
	self.item_name = widgets.item_name
	self.attr1 = widgets.attr1
	self.attr2 = widgets.attr2
	self.attr3 = widgets.attr3
	self.curEffect = widgets.curEffect
	self.curAttr = widgets.curAttr
	self.nextEffect = widgets.nextEffect
	self.nextAttr = widgets.nextAttr
	self.pointCount = widgets.pointCount
	self.ok_word = widgets.ok_word
	self.ok = widgets.ok
	self.verseTxt = widgets.verseTxt
	self.ok:onClick(self,self.OnInputBtn)
end

function wnd_underwear_talentPoint:refresh(index,tab ,talentId)
	self.index= index
	self.tab = tab 
	self.talentId = talentId
	local totalPoint = 0--拥有的全部天赋点
	self.canOpen1 = true
	--数据
	local talent = g_i3k_game_context:getAnyUnderWearAnyData(self.index,"talentPoint") --map 使用的明细
	local data = i3k_db_under_wear_upTalent[self.index][talentId]
	self.talentIdPoint = 0			
	if talent and talent[self.talentId] then
		self.talentIdPoint = talent[self.talentId]
	end
	local itemCount = g_i3k_game_context:GetCommonItemCount(data.talentIconId)
	local itemid = itemCount >= 0 and data.talentIconId or -data.talentIconId
	
	self.verseTxt:setText(data.verse)
	--self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	self.item_icon:setImage(i3k_db_icons[itemid].path)
	self.item_btn:onTouchEvent(self, self.onUseItem,itemid)	
	self.item_name:setText(data.talentName)	
	local needProTalent = data.NeedPreTalent
	local needProTalentInputPoint = data.NeedPrePoint --前提天赋需要投入的合数	
	local NeedTotalInputPoint = data.NeedInputPoint --总投入需要[5]点
	local NeedWuXunValue = data.NeedPreWuXun --武勋达
	local needProTalentName
	if needProTalent ~=0 and i3k_db_under_wear_upTalent[self.index][data.NeedPreTalent] then
		needProTalentName = i3k_db_under_wear_upTalent[self.index][data.NeedPreTalent].talentName
	end
	--实际拥有的
	local actualProInputPoint = 0
	local actualTotalInputPoint =g_i3k_game_context:getAnyUnderWearAnyData(self.index,"useTalentPoint")  --使用的总数
	local feat =  g_i3k_game_context:getForceWarAddFeat()
	
	if talent and talent[needProTalent] then
		actualProInputPoint = talent[needProTalent] --前提天赋实际投入数
	end
	
	if data.NeedPreTalent~=0 then  --前提为解锁某天赋
		local _Str1 =string.format("<c=green>%d</c>", needProTalentInputPoint) 
		--加条件颜色判断
		if actualProInputPoint < needProTalentInputPoint then
			_Str1 =string.format("<c=red>%d</c>", needProTalentInputPoint) 
			self.canOpen1 =false 			
		end
		self.attr1:setText(string.format("需要【%s%s%s%s",needProTalentName,"】投入[",_Str1,"]点"))
		if NeedTotalInputPoint ~=0 then
			local _Str2 =string.format("<c=green>%d</c>", NeedTotalInputPoint) 
			if actualTotalInputPoint < NeedTotalInputPoint then
				_Str2 =string.format("<c=red>%d</c>", NeedTotalInputPoint)
				self.canOpen1 =false 		
			end
			self.attr2:setText("总投入需要[".._Str2.."]点")
			if NeedWuXunValue~=0 then
				local _Str3 =string.format("<c=green>%d</c>", NeedWuXunValue) 
				if feat < NeedWuXunValue then
					_Str3 =string.format("<c=red>%d</c>", NeedWuXunValue) 
					self.canOpen1 =false 		
				end	
				self.attr3:setText("武勋达到[".._Str3.."]")
			else
				self.attr3:setText("")
			end
		else
			self.attr3:setText("")
			if NeedWuXunValue~=0 then
				local _Str3 =string.format("<c=green>%d</c>", NeedWuXunValue) 
				if feat < NeedWuXunValue then
					_Str3 =string.format("<c=red>%d</c>", NeedWuXunValue) 
					self.canOpen1 =false 		
				end	
				self.attr2:setText("武勋达到[".._Str3.."]")
			else
				self.attr2:setText("")
			end
		end
	else
		self.attr3:setText("")
		if NeedTotalInputPoint ~=0 then
			local _Str2 =string.format("<c=green>%d</c>", NeedTotalInputPoint) 
			if actualTotalInputPoint < NeedTotalInputPoint then
				_Str2 =string.format("<c=red>%d</c>", NeedTotalInputPoint)
				self.canOpen1 =false 		
			end
			self.attr1:setText("总投入需要[".._Str2.."]点")
			if NeedWuXunValue~=0 then
				local _Str3 =string.format("<c=green>%d</c>", NeedWuXunValue) 
				if feat < NeedWuXunValue then
					_Str3 =string.format("<c=red>%d</c>", NeedWuXunValue) 
					self.canOpen1 =false 		
				end	
				self.attr2:setText("武勋达到[".._Str3.."]")
			else
				self.attr2:setText("")
			end
		else
			self.attr2:setText("")
			if NeedWuXunValue~=0 then
				local _Str3 =string.format("<c=green>%d</c>", NeedWuXunValue) 
				if feat < NeedWuXunValue then
					_Str3 =string.format("<c=red>%d</c>", NeedWuXunValue) 
					self.canOpen1 =false 		
				end	
				self.attr1:setText("武勋达到[".._Str3.."]")
			else
				self.attr1:setText("无限制")
			end
		end	
	end
	--当前级天赋的效果描述
	--下一级天赋的效果描述
	local effectStr = data.talentAttr
	if talent and talent[self.talentId] then--当前天赋投入的点数 --有可能空表
		self.curAttr:setText(effectStr[self.talentIdPoint])
		self.nextAttr:setText(effectStr[self.talentIdPoint+1])
	else		
		self.curAttr:setText("暂无")
		self.nextAttr:setText(effectStr[1])
	end
	--剩余天赋点
	local totalPoint = 0--拥有的全部天赋点
	for i=1 ,self.tab.underwear_level do
		totalPoint = totalPoint +i3k_db_under_wear_update[self.index][i].talentPoint
	end
	self.lostPoint = totalPoint - actualTotalInputPoint
	--已经投入个数
	self.inputPoinit = talent[self.talentId] or 0
	self.MaxPoint = data.talentMaxPoint
	if self.inputPoinit >= self.MaxPoint then
		self.ok_word:setText("已满级")
		self.nextEffect:hide()
		self.nextAttr:setText("")
		self.ok:setTouchEnabled(false)
	end
	self.pointCount:setText(self.inputPoinit.."/"..self.MaxPoint)
end

function wnd_underwear_talentPoint:onUseItem(itemid)
	--g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

function wnd_underwear_talentPoint:OnInputBtn(sender)
	
	if not self.canOpen1 then
		g_i3k_ui_mgr:PopupTipMessage("前提不足，无法投入")
	elseif self.lostPoint <1 then
		g_i3k_ui_mgr:PopupTipMessage("点数不足，无法投入")
	elseif self.inputPoinit >=self.MaxPoint then
		return
	else
		i3k_sbean.upTalent(self.index ,self.tab,self.talentId )
	end
end

function wnd_create(layout)
	local wnd = wnd_underwear_talentPoint.new()
		wnd:create(layout)
	return wnd
end
