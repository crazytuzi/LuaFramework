-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/base");
local ui = require("ui/underwear_profile");

-------------------------------------------------------
wnd_underwear_upStage = i3k_class("wnd_underwear_upStage", ui.wnd_underwear_profile)

local btnShowTab = { 
	upStage_btn 	= i3k_db_under_wear_alone.underWearUpStageShowLvl,
	talent_btn 		= i3k_db_under_wear_alone.underWearTalentShowLvl,
	fuwen_btn 		= i3k_db_under_wear_alone.underWearRuneShowLvl,
}

function wnd_underwear_upStage:ctor()
	self.is_auto = false	--当前是否为自动
	self.stopAtuo = false   --是否手动停止
	self.schedler = nil
	self.touchItem = true
	self.setModel = false

end

function wnd_underwear_upStage:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self._layout.vars.gotoBtn:onClick(self,function ()
		g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear)
		g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear)
		self:onCloseUI()
	end)

	self.update_btn = widgets.update_btn  --升级
	self.update_btn:stateToNormal()
	self.update_btn:onClick(self, self.onUpdate_btn)
	
	self.upStage_btn = widgets.upStage_btn  --升阶
	self.upStage_btn:stateToPressed()
	
	
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
	
	--效果
	self.attr1 = widgets.attr1
	self.attr2 = widgets.attr2
	
	self.expLoading = widgets.expLoading
	self.expLabel = widgets.expLabel
	
	self.curTrr = widgets.curTrr
	self.nextTrr = widgets.nextTrr
	self.nextTrr1 = widgets.nextTrr1 --两条线
	self.nextTrr2 = widgets.nextTrr2
	
	self.sx2 = widgets.sx2
	self._maxStage = widgets.maxStage
	
	
	
	self.stage_btn =  widgets.stage_btn  --升阶
	self.stage_btn:onClick(self,self.onStage_btn)
	
	--自动升阶
	self.autoStage_btn = widgets.autoStage_btn
	self.autoStage_btn:onClick(self,self.onAutoStage_btn)
	self.autoStageAttr = widgets.autoStageAttr	
	
	self.stopAuto_btn = widgets.stopAuto_btn   --停止自动
	self.stopAuto_btn:onClick(self,self.onStopAuto)
	self.stopAuto_btn:hide()
	
	self.addWuxun = widgets.addWuxun
	self.cheakWuxun = widgets.cheakWuxun
	self.cheakWuxun:onClick(self, self.onCheakWuxun)--查看
	
	self.bgImage = widgets.bgImage --背景图 
	
	self.upStageTab = {}
	for i=1,2 do
		local temp_bg = string.format("item%s_bg",i)
		local temp_icon = string.format("item%s_icon",i)
		local temp_btn = string.format("item%s_btn",i)
		local temp_count = string.format("item%s_count",i)
		local tmp_name = string.format("item%s_name",i)
		local _upgradeTab = {item_bg =widgets[temp_bg],item_icon =widgets[temp_icon],item_btn = widgets[temp_btn] ,item_count = widgets[temp_count], item_name = widgets[tmp_name]}
		table.insert(self.upStageTab , i , _upgradeTab)
	end
	self._maxStage:hide()
	
	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型
	self.widgets = widgets

	self.talentRp = widgets.talentRp
	self.forgeRp = widgets.forgeRp
	self.upgradeRp = widgets.upgradeRp
	self.runeRp = widgets.runeRp
end

function wnd_underwear_upStage:refresh(index ,tab)
	self:setBgImage(index)
	
	--打开界面时需要判断等级是否满足显示
	for k,v in pairs(btnShowTab) do
		self.widgets[tostring(k)]:show()
		if g_i3k_game_context:GetLevel() < v then
			self.widgets[tostring(k)]:hide()
		end
	end	
	
	self.index= index
	self.tab = tab 
	self.stopAtuo = false 
	self.touchItem = true 
	if self.tab.underwear_stage>=  #i3k_db_under_wear_upStage[self.index] then
		self.nextTrr:hide()
		self.nextTrr2:hide()
		self.nextTrr1:hide()
		self.sx2:hide()
		self._maxStage:show()
	end
	self.nameLabel:setText(self.tab.underwear_name)
	self.levelLabel:setText(self.tab.underwear_level.."级")
	self.stageLabel:setText(self.tab.underwear_stage.."阶")
	
	if not self.setModel  then
		self.setModel  = true
		self:setModelData(index, tab.underwear_stage)
	end
	--当前效果
	local stageName = i3k_db_under_wear_upStage[self.index][self.tab.underwear_stage].stageName
	local stageName1 = string.split(stageName,"·")
	self.curTrr:setText(stageName1[2])
	local attr1 = i3k_db_under_wear_upStage[self.index][self.tab.underwear_stage].desc
	self.attr1:setText(attr1)
	
	--下阶效果
	if i3k_db_under_wear_upStage[self.index][self.tab.underwear_stage+1] then
		local attr2 = i3k_db_under_wear_upStage[self.index][self.tab.underwear_stage+1].desc
		self.attr2:setText(attr2)

		local nextNameStr = i3k_db_under_wear_upStage[self.index][self.tab.underwear_stage+1].stageName
		local nextNameStr = string.split(nextNameStr,"·")
		self.nextTrr:setText(nextNameStr[2])
	else
		self.attr2:hide()
		self.nextTrr2:hide()
		self.nextTrr1:hide()
	end
	self._layout.vars.propBtn:onClick(self, self.openProp)
	
	self.addWishNums = self:getAddWUxunNum()
	local need_point  = i3k_db_under_wear_upStage[self.index][self.tab.underwear_stage].wishMax
	if  self.addWishNums >=need_point*i3k_db_under_wear_alone.wuxunMaxAddRatio then
		self.addWishNums = math.modf(need_point*i3k_db_under_wear_alone.wuxunMaxAddRatio)
	end
	self.addWuxun:setText(self.addWishNums)
	self:setPropData()
	local wishPoint =  g_i3k_game_context:getAnyUnderWearAnyData(self.index , "wishPoint")
	self:setWishData(wishPoint)	
	self:ShowRedPoint(index, tab)
end

--根据内甲id显示背景图
function wnd_underwear_upStage:setBgImage(index)
	local bgImageTab = {2701,2702,2703}
	self.bgImage:setImage(i3k_db_icons[bgImageTab[index]].path) 
end

function wnd_underwear_upStage:setModelData(id, stage)
	ui_set_hero_model(self.hero_module, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(), {id = id, stage = stage})
end

function wnd_underwear_upStage:getAddWUxunNum()
	--武勋附加祝福值
	local Feat =  g_i3k_game_context:getForceWarAddFeat()
	if Feat < i3k_db_under_wear_wuxun[1].wuxunNum then
		return 0;
	end
	for i = 1,(#i3k_db_under_wear_wuxun-1) do
		if Feat >= i3k_db_under_wear_wuxun[i].wuxunNum and Feat < i3k_db_under_wear_wuxun[i+1].wuxunNum then
			return i3k_db_under_wear_wuxun[i].addWishNum;
		end
	end
	return i3k_db_under_wear_wuxun[#i3k_db_under_wear_wuxun].addWishNum;
end

--购买道具后界面控制变量需重置
function wnd_underwear_upStage:setDataInit()
	self.is_auto = false	--当前是否为自动
	self.stopAtuo = false   --是否手动停止
	self.schedler = nil
	self.touchItem = true
	self.setModel = false
end	
function wnd_underwear_upStage:setPropData()
	--self:setDataInit()
	self._itemTab = {} ----消耗道具表
	self._itemBtnTab = {} 
	for i,v in ipairs(self.upStageTab) do
		local upStageTakeId = string.format("upStageTakeId%s",i)
		local upStageTakeValue = string.format("upStageTakeValue%s",i)
		local upStageTakeIdStr = i3k_db_under_wear_upStage[self.index][self.tab.underwear_stage][upStageTakeId]
		local upStageTakeValueStr = i3k_db_under_wear_upStage[self.index][self.tab.underwear_stage][upStageTakeValue]
		v.item_bg:show()
		if upStageTakeIdStr and upStageTakeIdStr ~= 0 then
			local itemCount = g_i3k_game_context:GetCommonItemCount(upStageTakeIdStr)
			local itemid = itemCount >= 0 and upStageTakeIdStr or -upStageTakeIdStr
			local item_cfg = g_i3k_db.i3k_db_get_common_item_cfg(itemid)
			local name_color = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid))
			local count = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
			local count_color = upStageTakeValueStr <= count and g_i3k_get_green_color() or g_i3k_get_red_color()
			
			v.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
			v.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
			v.item_count:setText(count.."/"..upStageTakeValueStr)	
			v.item_count:setTextColor(count_color)	
			v.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemid))
			v.item_name:setTextColor(name_color)
			v.item_btn:onClick(self, self.onUseItem, itemid)--长按按钮		
			local itemTab = {itemid = upStageTakeIdStr,itemcount = upStageTakeValueStr}	
			table.insert(self._itemTab ,itemTab) 
			local itemBtn = {itemBtn = v.item_btn}
			table.insert(self._itemBtnTab ,itemBtn)
		else
			v.item_bg:hide()
		end
	end
end

function wnd_underwear_upStage:setWishData(wishPoint)	
	local now_point = wishPoint+self.addWishNums
	local need_point  = i3k_db_under_wear_upStage[self.index][self.tab.underwear_stage].wishMax
	local showLoadingNum = now_point/need_point*100
	if now_point>=need_point then
		showLoadingNum = 100
	end
	self.expLoading:setPercent(showLoadingNum)
	local tmp_str = string.format("%s",now_point)
	self.expLabel:setText(tmp_str)
end

function wnd_underwear_upStage:updateWishData()
	local wishPoint =  g_i3k_game_context:getAnyUnderWearAnyData(self.index , "wishPoint")
	self:setPropData()
	self:setWishData(wishPoint)
end

function wnd_underwear_upStage:onUseItem(sender,itemid)
	if not self.touchItem then
		return
	end
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

function wnd_underwear_upStage:onStage_btn(sender)
	local anto = false
	if 	self.is_auto then
		self.is_auto = false
		anto =true
	end
	for i,v in ipairs(self._itemTab)  do 
		if g_i3k_game_context:GetCommonItemCanUseCount(v.itemid)<v.itemcount then
			g_i3k_ui_mgr:PopupTipMessage("所需道具不足")
			self:onStopUpStage()
			return 
		end
	end
	if self.stopAtuo then
		self.stopAtuo = false
		return
	end
	self._returnAuto = anto
	i3k_sbean.upStageArmor(self.index,self.tab.underwear_stage+1,self._itemTab ,anto)	
end


function wnd_underwear_upStage:updateModule(armorId, armorStage)
	local data 
	local standData 
	if i3k_db_under_wear_cfg[armorId] then
		data =  i3k_db_under_wear_cfg[armorId].playCelebrateAction
		standData =  i3k_db_under_wear_cfg[armorId].playStandbyAction
	end
	self:changeArmorEffect(self.hero_module, armorId, armorStage,true)
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

function wnd_underwear_upStage:onAutoStage_btn(sender)
	self.autoStage_btn:hide()
	self.stage_btn:setTouchEnabled(false)
	self.stopAuto_btn:show()	
	self.touchItem = false
	self.is_auto = true
	self.stopAtuo = false --尚未停止
	self:onStage_btn()
end

function wnd_underwear_upStage:onUpStage()
	
	function update(dTime)		
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedler)	
		self.schedler = nil
		self.is_auto = true
		self:onStage_btn()	
	end		
	if not self.schedler then
		self.schedler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.5, false)
	end			
end

function wnd_underwear_upStage:onStopUpStage()
	self:onStopAuto()
end

--服务器返回错误的情况下，将界面置回正常状态（自动的时候）
function wnd_underwear_upStage:canStopUpStage()
	if self._returnAuto then
		self:onStopUpStage()
	end
end

--停止自动
function wnd_underwear_upStage:onStopAuto()
	self.stopAtuo = true
	self.stopAuto_btn:hide()
	self.autoStage_btn:show()
	self.stage_btn:setTouchEnabled(true)
	self.touchItem = true
end	
		
function wnd_underwear_upStage:onUpdate_btn() --升级
	g_i3k_logic:OpenUnderWearUpdate(self.index,self.tab)
	self:onCloseUI()
end

function wnd_underwear_upStage:onTalentBtn() --天赋
	--天赋
	local canOpen ,level = g_i3k_game_context:isCanOpenUI(2)
	if canOpen then
		g_i3k_logic:OpenUnderWearTalent(self.index,self.tab)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(806,level))
	end
end

function wnd_underwear_upStage:onFuwenBtn()
	--符文
	local canOpen ,level = g_i3k_game_context:isCanOpenUI(3)
	if canOpen then
		g_i3k_logic:OpenUnderWearRune(self.index,self.tab)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(807,level))
	end
end

--查看
function wnd_underwear_upStage:onCheakWuxun()
	g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear_showWuXun)
	g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_showWuXun)	
end

function wnd_underwear_upStage:releaseSchedule()
	if self.schedler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedler)
		self.schedler = nil
	end
end

function wnd_underwear_upStage:onHide()
	self:releaseSchedule()
end

function wnd_underwear_upStage:openProp(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_UnderWear_upStage_Prop)
	g_i3k_ui_mgr:RefreshUI(eUIID_UnderWear_upStage_Prop, self.index, self.tab.underwear_stage)
end

function wnd_underwear_upStage:onCloseUI(sender)	
	if self.schedler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedler)
	end
	self:onStopAuto()
	g_i3k_ui_mgr:CloseUI(eUIID_Under_Wear_upStage)
end

function wnd_create(layout)
	local wnd = wnd_underwear_upStage.new()
	wnd:create(layout)
	return wnd
end
