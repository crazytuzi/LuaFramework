-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local ui = require("ui/underwear_profile");
-------------------------------------------------------
wnd_underwear_talent = i3k_class("wnd_underwear_talent", ui.wnd_underwear_profile)

local btnShowTab = { 
	upStage_btn 	= i3k_db_under_wear_alone.underWearUpStageShowLvl,
	talent_btn 		= i3k_db_under_wear_alone.underWearTalentShowLvl,
	fuwen_btn 		= i3k_db_under_wear_alone.underWearRuneShowLvl,
}

function wnd_underwear_talent:ctor()
	self._canUse = true
	self.MaxLevel = false --达到做大等级
	self.Layer = nil
end

function wnd_underwear_talent:configure()
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
	self.upStage_btn:stateToNormal()
	self.upStage_btn:onClick(self, self.onuUpStageBtn)
	
	self.talent_btn = widgets.talent_btn --天赋
	self.talent_btn:stateToPressed()
	
	
	self.fuwen_btn = widgets.fuwen_btn
	self.fuwen_btn:stateToNormal()
	self.fuwen_btn:onClick(self, self.onFuwenBtn)--符文

	self.tfLayer = widgets.tfLayer --天赋layer
	self.widgets = widgets
	self.talentRp = widgets.talentRp
	self.forgeRp = widgets.forgeRp
	self.upgradeRp = widgets.upgradeRp
	self.runeRp = widgets.runeRp
end

function wnd_underwear_talent:setTalentInitData(index)
	--local index = string.format("njtft%s",index)
	if index ==1 then
		 self.Layer = require("ui/widgets/njtft1")() 
	elseif index ==2 then
		 self.Layer = require("ui/widgets/njtft2")() 
	elseif index ==3 then
		 self.Layer = require("ui/widgets/njtft3")() 
	end	
	local widgets  = self.Layer.vars	
	self.upgradeTab = {}
	local num = #i3k_db_under_wear_upTalent[index]
	for i=1,num do
		local temp_bg = string.format("item_bg%s",i)
		local temp_icon = string.format("item_icon%s",i)
		local temp_btn = string.format("item_btn%s",i)
		local temp_name = string.format("item_name%s",i)
		local tmp_value = string.format("item_value%s",i)
		local _upgradeTab = {item_bg =widgets[temp_bg],item_icon =widgets[temp_icon],item_btn = widgets[temp_btn] ,item_name = widgets[temp_name], item_value = widgets[tmp_value]}
		table.insert(self.upgradeTab , i , _upgradeTab)
	end	
	self.totalpoint = widgets.totalpoint
	self.residuePoint = widgets.residuePoint
	self.nextAddPointAttr = widgets.nextAddPointAttr
	
	self.resetTalentBtn = widgets.resetTalent  --重置
	self.resetTalentBtn:stateToNormal()
	self.resetTalentBtn:onClick(self, self.onResetTalentBtn)
	self.tfLayer:addChild(self.Layer)
end

function wnd_underwear_talent:refresh(index ,tab)
	--打开界面时需要判断等级是否满足显示
	for k,v in pairs(btnShowTab) do
		self.widgets[tostring(k)]:show()
		if g_i3k_game_context:GetLevel() < v then
			self.widgets[tostring(k)]:hide()
		end
	end	
	self.index= index
	self.tab = tab 
	if not self.Layer then
		self:setTalentInitData(index)
	end
	local totalPoint = 0--拥有的全部天赋点
	for i=1 ,self.tab.underwear_level do
		totalPoint = totalPoint +i3k_db_under_wear_update[self.index][i].talentPoint
	end
	local talent = g_i3k_game_context:getAnyUnderWearAnyData(self.index,"talentPoint") --map 使用的明细
	local Data = i3k_db_under_wear_upTalent[self.index]
	local useTalentPoint = 	g_i3k_game_context:getAnyUnderWearAnyData(self.index,"useTalentPoint")  --使用的总数
	self.resetTalentBtn:show()	
	if useTalentPoint == 0 then
		self.resetTalentBtn:hide()	
	end
	for i,v in ipairs(Data) do	
		local talentId = v. talentNumber 
		local itemIconid = g_i3k_game_context:GetCommonItemCount(v.talentIconId)
		local itemid = itemIconid >= 0 and v.talentIconId or -v.talentIconId
		local name = v.talentName
		local talentNowInputPoint =0
		if  talent and  talent[talentId] then
			talentNowInputPoint =talent[talentId] --当前 天赋投入点数
		end
		local talentMaxPoint = v.talentMaxPoint
		--v.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
		self.upgradeTab[i].item_icon:setImage(i3k_db_icons[itemid].path)
		self.upgradeTab[i].item_name:setText(name)	
		self.upgradeTab[i].item_value:setText(talentNowInputPoint.."/"..talentMaxPoint)--点数投入：天赋当前投入 / 天赋最大可投入。		
		--所需总投入点数v.NeedInputPoint 所需前提天赋ID[所需前提点数]v.NeedPreTalent 所需前提点数v.NeedPrePoint 所需武勋v.NeedPreWuXun NeedPreTalent
		local needPrePoint = 0
		if  talent and  talent[v.NeedPreTalent] then
			needPrePoint = talent[v.NeedPreTalent] --前提天赋 所具备 提点数
		end
		
	    local feat =  g_i3k_game_context:getForceWarAddFeat()
		if useTalentPoint >= v.NeedInputPoint and needPrePoint >=v.NeedPrePoint and feat >= v.NeedPreWuXun  then
			self.upgradeTab[i].item_value:setTextColor(g_i3k_get_green_color())--绿色
		else
			self.upgradeTab[i].item_value:setTextColor(g_i3k_get_red_color())--红色
		end
		--local itemTab = {itemId =itemid ,itemName = name,preTalent =v.NeedPreTalent,prePoint = v.NeedPreTalent , totalInputPiont =v.NeedInputPoint ,wuXunValue = v.NeedPreWuXun }
		------------------- 
		
		self.upgradeTab[i].item_btn:onClick(self, self.onUseItem ,talentId)--长按按钮			
	end	
	
	--剩余天赋点
	local lostPoint = totalPoint - useTalentPoint
	self.totalpoint:setText(useTalentPoint)
	self.residuePoint:setText(lostPoint)
	if i3k_db_under_wear_update[self.index][self.tab.underwear_level+1] then
		local nextPoint = i3k_db_under_wear_update[self.index][self.tab.underwear_level+1].talentPoint
		if nextPoint > 0 then
			self.nextAddPointAttr:show()
			self.nextAddPointAttr:setText(string.format("（下级升级增加%d%s",nextPoint,"点）"))
		else
			self.nextAddPointAttr:hide()
		end
	else
		self.nextAddPointAttr:setText("")
	end
	self:ShowRedPoint(index,tab)
end

function wnd_underwear_talent:onUseItem(sender ,talentId)
	--弹出提示
	g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear_Talent_Point)
	g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_Talent_Point ,self.index,self.tab,talentId )
end

function wnd_underwear_talent:onUpdate_btn()
	--升级
	g_i3k_logic:OpenUnderWearUpdate(self.index,self.tab)
	self:onCloseUI()
end

function wnd_underwear_talent:onuUpStageBtn()
	--升阶
	local canOpen ,level = g_i3k_game_context:isCanOpenUI(1)
	if canOpen then
		g_i3k_logic:OpenUnderWearUpStage(self.index,self.tab)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(805,string.format("%s",level)))
	end
end

function wnd_underwear_talent:onFuwenBtn()
	--符文
	local canOpen,level = g_i3k_game_context:isCanOpenUI(3)
	if canOpen then
		g_i3k_logic:OpenUnderWearRune(self.index,self.tab)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(807,level))
	end
end

--重置
function wnd_underwear_talent:onResetTalentBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear_Talent_Point_Reset)
	g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_Talent_Point_Reset ,self.index,self.tab)
end

function wnd_underwear_talent:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Under_Wear_Talent)
end

function wnd_create(layout)
	local wnd = wnd_underwear_talent.new()
	wnd:create(layout)
	return wnd
end
