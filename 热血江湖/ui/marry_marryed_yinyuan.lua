-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--夫妻姻缘ui
-------------------------------------------------------
wnd_marry_marryed_yinyuan = i3k_class("wnd_marry_marryed_yinyuan", ui.wnd_base)

function wnd_marry_marryed_yinyuan:ctor()
	self._canUse = true
	self.MaxLevel = false --达到做大等级
	self.co = nil
	self._canTrans = false
	self.timeRefresh = 1
end

function wnd_marry_marryed_yinyuan:configure()
	local widgets = self._layout.vars
	self._layout.vars.cdTime:hide()
	self.close_btn =  widgets.close_btn
	self.close_btn:onClick(self, self.onCloseUI)
	self._layout.vars.helpBtn:onClick(self, self.onHelpBtn)
	self._layout.vars.help_btn:onClick(self, self.onHelp_btn)
	self.yinyuan_btn = widgets.yinyuan_btn  --姻缘
	self.yinyuan_btn:stateToPressed()

	self.skills_btn = widgets.skills_btn
	self.skills_btn:stateToNormal()
	self.skills_btn:onClick(self, self.onskillsBtn)--技能

	-- self.divorce_btn = widgets.divorce_btn
	-- self.divorce_btn:stateToNormal()
	-- self.divorce_btn:onClick(self, self.onDivorceBtn)--离婚
	
	self.achievement_btn = widgets.achievement_btn
	self.achievement_btn:stateToNormal()
	self.achievement_btn:onClick(self, self.onAchievementBtn)--成就

	self.yinyuanValue = widgets.yinyuanValue --姻缘值

	self.gotoLoversBtn = widgets.gotoLoversBtn
	self.gotoLoversBtn:onClick(self, self.onGotoLoversBtn)--传送至伴侣
	widgets.yjhb_btn:onClick(self, self.getTitle)

	widgets.cardBtn:onClick(self, self.openMarriageCardUI)

	self.scroll1 = widgets.scroll1
	self.scroll2 = widgets.scroll2
	self.level = widgets.level --姻缘等级

	--进度条
	self.expLoading = widgets.expLoading

	--个人信息
	self.myHeadIcon = widgets.myHeadIcon
	self.myLevelLabel= widgets.myLevelLabel
	self.otherHeadIcon = widgets.otherHeadIcon
	self.otherLevelLabel= widgets.otherLevelLabel
	self.widgets = widgets

	widgets.giftBtn:onClick(self, self.onGiftBtn)
	widgets.giftBtn:setVisible(g_i3k_db.i3k_db_get_is_activity_perfect_open(1))
end

function wnd_marry_marryed_yinyuan:refresh()
	--jhfqyyt
	self._layout.vars.achieve_red:setVisible(g_i3k_game_context:GetNoticeState(g_NOTICE_TYPE_MARRY_ACHIEVEMENT))
	self.marriageLevel  = g_i3k_game_context:getMarryEveryData("marriageLevel")
	self.marriageExp = g_i3k_game_context:getMarryEveryData("marriageExp")
	self:setAttribute()
	self:marriageLevelCalculate()
	local curMarryTime = i3k_game_get_time() - g_i3k_game_context:getRecordMarryTime()
	local day = math.modf(curMarryTime/86400)
	local min = math.modf((curMarryTime%3600)/60)
	local hour = math.modf((curMarryTime%86400)/3600)

	local dayStr = ""
	if day ~=0 then
		dayStr = string.format("%d天",day)
	end
	if hour ~=0 then
		dayStr = dayStr .. string.format("%d时",hour)
	end
	dayStr = dayStr .. string.format("%d分",min)
	self.widgets.dayTxt:setText(string.format("结婚天数：%s",dayStr))
	self:updateTitleRed()
	self:checkGiftRedPoint()
end

function wnd_marry_marryed_yinyuan:setAttribute()

	self.level:setText("姻缘等级:"..self.marriageLevel)
	if i3k_db_marry_attribute[self.marriageLevel+1] then
		local need_exp = i3k_db_marry_attribute[self.marriageLevel+1].marriageValues
		self.expLoading:setPercent(self.marriageExp/need_exp*100) --升到下一级的展示效果
		self.yinyuanValue:setText(self.marriageExp.."/"..need_exp)
	else
		self.expLoading:setPercent(self.marriageExp/self.marriageExp*100) --最高级的展示效果
		self.yinyuanValue:setText(self.marriageExp)
	end


	local data = i3k_db_marry_attribute[self.marriageLevel]
	for i= 1 ,6 do
		local RewardId = string.format("attributeRewardId%s",i)
		local attributeRewardCount = string.format("attributeRewardCount%s",i)
		if data[RewardId]~=0 then
			local Layer = require("ui/widgets/jhfqyyt")()
			--itemName:setText(i3k_db_prop_id[attrId].desc)
			local icon = g_i3k_db.i3k_db_get_property_icon(data[RewardId])
			Layer.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))

			Layer.vars.name:setText(i3k_db_prop_id[data[RewardId]].desc)
			Layer.vars.value:setText(data[attributeRewardCount])
			if i<=3 then
				self.scroll1:addItem(Layer)
			else
				self.scroll2:addItem(Layer)
			end
		end
	end
	local otherInfo =  g_i3k_game_context:getMarryEveryData("marriageRole")
	--otherInfo.name
	--otherInfo.id
	--otherInfo.type
	--otherInfo.headIcon
	--otherInfo.gender
	--otherInfo.level

	--头像
	--自己self._widgets.role.headIcon
	local myHeadIcon = g_i3k_game_context:GetRoleHeadIconId()
	self.myHeadIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(myHeadIcon, false))--headIcon
	self.myLevelLabel:setText(g_i3k_game_context:GetLevel())
	--对方
	self.otherHeadIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(otherInfo.headIcon, false))--headIcon
	self.otherLevelLabel:setText(otherInfo.level)
end

function wnd_marry_marryed_yinyuan:marriageLevelCalculate()
	-- self._layout.vars.achieve_red:setVisible(g_i3k_game_context:GetNoticeState(g_NOTICE_TYPE_MARRY_ACHIEVEMENT))
	-- self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_COIN,i3k_game_context:IsFemaleRole()))
	-- self._layout.vars.label:setText("x"..i3k_db_marry_rules.divorceCost)
	local marriageTime = g_i3k_game_context:getMarryEveryData("marriageTime") --1474455864 --结婚时间
	local curtime = math.modf(i3k_game_get_time())
	local curMarryTime = curtime - marriageTime
	--local havetime = curMarryTime /60
	--local sec = curMarryTime%60
	--local min = havetime  % 60
	--local hour = math.floor(havetime/60%24)
	--local day = math.floor(havetime/3600/24)
	local min=(curMarryTime/60)%60
	local hour=(curMarryTime/60)/60%24
	local day=math.floor((curMarryTime-min*60-hour*3600)/86400)+1
	-- local dayStr = ""
	-- if day ~=0 then
	-- 	dayStr = string.format("%d天",day)
	-- end
	-- local hourStr = ""
	-- if hour ~=0 then
	-- 	hourStr = string.format("%d时",hour)
	-- end
	-- local minStr = ""
	-- if min ~=0 then
	-- 	minStr = string.format("%d分",min)
	-- end
	-- local time = dayStr..hourStr..minStr
	-- local marriageRole = g_i3k_game_context:getMarryEveryData("marriageRole")   --结婚对象
	--local divorcePunishmentTime = i3k_db_marry_rules.divorcePunishmentTime/86400 --离婚冷却时间 （秒） 换算成天
	--local other = g_i3k_game_context:GetTeamOtherMembersProfile() 
	--local otherUesrName =marriageRole.name
	--self.textLabel:setText(i3k_get_string(689,string.format("%s",divorcePunishmentTime),string.format("%s",otherUesrName),string.format("%s",time)))
	self._layout.vars.marryNameLabel:setText(i3k_get_string(690))	--姻缘称谓：
	--计算婚姻称谓
	local hourTime = math.floor(curMarryTime/3600)
	local cnt = #i3k_db_marry_levels
	for i ,v in ipairs(i3k_db_marry_levels) do	
		if hourTime <= v.marryTime or i == cnt then
			self._layout.vars.marryName:setText(v.marryName)
			break
		end
	end
end
function wnd_marry_marryed_yinyuan:onskillsBtn()
	--技能
	--self:onCloseUI()
	g_i3k_logic:OpenMarried_skills()

end

function wnd_marry_marryed_yinyuan:onHelp_btn()
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(18558, g_i3k_db.i3k_db_marryTaskCfg.loopTaskCnt))
end

function wnd_marry_marryed_yinyuan:onHelpBtn()
	local cfg = i3k_db_marry_levels
	g_i3k_ui_mgr:OpenUI(eUIID_MarryHelp)
	g_i3k_ui_mgr:RefreshUI(eUIID_MarryHelp, cfg)

	-- local data = {}
	-- data.isMarriage = true
	-- data.name = i3k_get_string(18559)
	-- data.time = i3k_get_string(18582)
	-- g_i3k_ui_mgr:ShowHelp(data)
end
-- function wnd_marry_marryed_yinyuan:onDivorceBtn()
-- 	--离婚
-- 	--self:onCloseUI()
-- 	g_i3k_logic:OpenMarried_lihun()
-- end

function wnd_marry_marryed_yinyuan:onAchievementBtn(sender)
	g_i3k_logic:OpenMarried_achievement()
end

function wnd_marry_marryed_yinyuan:onGotoLoversBtn()
	local tips = g_i3k_game_context:GetNotEnterTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	--传送至伴侣
	if self._canTrans then
		--g_i3k_ui_mgr:PopupTipMessage("传送至伴侣")
		local function mulHorseCheckCb()
			i3k_sbean.sendToLover()
			self:onCloseUI()
		end
		g_i3k_game_context:CheckMulHorse(mulHorseCheckCb)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(854))
	end
end

function wnd_marry_marryed_yinyuan:onUpdate(dTime)
	self.timeRefresh = self.timeRefresh + dTime
	if self.timeRefresh >= 1 then
		timeRefresh = 0
		local recordTime = g_i3k_game_context:getMarryTransFromTime()
		if recordTime ~= 0 then
			local nowServerTime = i3k_integer(i3k_game_get_time())
			local lastTime = recordTime + i3k_db_marry_rules.transitCoolingTime - nowServerTime
			if lastTime > 0 then
				self._canTrans = false
				self._layout.vars.cdTime:show()
				local time = os.date("%M:%S", lastTime)
				self._layout.vars.cdTime:setText("剩余："..time)
			else
				self._canTrans = true
				g_i3k_game_context:setMarryTransFromTime(0)
			end
		else
			self._canTrans = true
			self._layout.vars.cdTime:hide()
		end
	end
end

function wnd_marry_marryed_yinyuan:getTitle()
	g_i3k_ui_mgr:OpenUI(eUIID_MarriageTitle)
	g_i3k_ui_mgr:RefreshUI(eUIID_MarriageTitle)
end

function wnd_marry_marryed_yinyuan:updateTitleRed()
	self.widgets.yinyuanRed:setVisible(g_i3k_game_context:marryTitleRed())
end

function wnd_marry_marryed_yinyuan:release()

end

function wnd_marry_marryed_yinyuan:onHide()
	self:release()
end

function wnd_marry_marryed_yinyuan:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Marry_Marryed_Yinyuan)
end

function wnd_marry_marryed_yinyuan:openMarriageCardUI()
	i3k_sbean.marriage_card_syncReq(g_i3k_game_context:GetMarriageId())
end


function wnd_marry_marryed_yinyuan:onGiftBtn(sender)
	local checkTime = g_i3k_db.i3k_db_get_is_activity_perfect_can_get_reward(g_activity_show_perfect)
	if not checkTime then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17242))
		return
	end

	local info = g_i3k_game_context:getRoleFestivalGifts(g_activity_show_perfect)
	if info and info.isTake == 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17241))
		return
	end

	i3k_sbean.getMarriageGift(g_activity_show_perfect)
end

function wnd_marry_marryed_yinyuan:checkGiftRedPoint()
	local info = g_i3k_game_context:getRoleFestivalGifts(g_activity_show_perfect) -- 默认id为1，十全十美
	local isOpen = g_i3k_db.i3k_db_get_is_activity_perfect_open(g_activity_show_perfect)
	local widgets = self._layout.vars
	if isOpen then
		if not info then
			widgets.yinyuanRed2:show() -- 初始为空，表示未领取
		elseif info.isTake == 0 then
			widgets.yinyuanRed2:show()
		else
			widgets.yinyuanRed2:hide()
		end
	else
		widgets.yinyuanRed2:hide()
	end
end


function wnd_create(layout)
	local wnd = wnd_marry_marryed_yinyuan.new()
	wnd:create(layout)
	return wnd
end
