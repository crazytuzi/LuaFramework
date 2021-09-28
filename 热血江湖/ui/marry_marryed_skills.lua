-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--姻缘破裂ui
-------------------------------------------------------
wnd_marry_marryed_skills = i3k_class("marry_marryed_skills", ui.wnd_base)



function wnd_marry_marryed_skills:ctor()
	
end

function wnd_marry_marryed_skills:configure()
	local widgets = self._layout.vars

	self.close_btn =  widgets.close_btn 
	self.close_btn:onClick(self, self.onCloseUI)
	
	self.skills_btn = widgets.skills_btn --技能
	self.skills_btn:stateToPressed()
	
	self.yinyuan_btn = widgets.yinyuan_btn  --姻缘
	self.yinyuan_btn:stateToNormal()
	self.yinyuan_btn:onClick(self, self.onYinYuanBtn)
	
	-- self.divorce_btn = widgets.divorce_btn --离婚
	-- self.divorce_btn:stateToNormal()
	-- self.divorce_btn:onClick(self, self.onDivorceBtn)
	
	self.achievement_btn = widgets.achievement_btn
	self.achievement_btn:stateToNormal()
	self.achievement_btn:onClick(self, self.onAchievementBtn)--成就

	self.maxUI = widgets.maxUI
	--
	self.skillsicon = widgets.skillsicon  
	self.skillsLevel = widgets.skillsLevel 
	self.skillsName = widgets.skillsName 
	self.expLoading = widgets.expLoading 
	--
	self.onceValue = widgets.onceValue 
	self.totalValue = widgets.totalValue  --铜钱总量
	
	self._layout.vars.help_btn:onClick(self, self.onHelp_btn)
	
	self.upgradeOneBtn = widgets.upgradeOneBtn 				--升级一次
	self.upgradeOneBtn:onClick(self, self.onUpgradeOneBtn)
	
	self.upgradeTenBtn = widgets.upgradeTenBtn
	self.upgradeTenBtn:onClick(self, self.onUpgradeTenBtn) --升级十次
	
	self.showUpgradeUI = widgets.showUpgradeUI --升级UI 
	self.maxLevel = widgets.maxLevel --满级标记
	self.qixueValue = widgets.qixueValue  --本级增加气血上限：
	--self.qixueValue:show()
	self.showUpgradeUI:show()
	self.maxLevel:hide()
	self.scroll = widgets.scroll
	

	
end
function wnd_marry_marryed_skills:refresh()
	self._layout.vars.achieve_red:setVisible(g_i3k_game_context:GetNoticeState(g_NOTICE_TYPE_MARRY_ACHIEVEMENT))
	self:initSkillsIcon()
	self:showSkillsDetails(1)
	--local data = {[1]={skillUpTimes = 0,skillLevel = 1,skillId = 1} ,[2]={skillUpTimes = 0,skillLevel = 1,skillId = 2}}
end
function wnd_marry_marryed_skills:onHelp_btn()
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(18558, g_i3k_db.i3k_db_marryTaskCfg.loopTaskCnt))
end

function wnd_marry_marryed_skills:initSkillsIcon()
	self.scroll:removeAllChildren()
	self.marriageSkill = g_i3k_game_context:getMarryEveryData("marriageSkill")
	for i,v in ipairs(self.marriageSkill) do
		local skill_data = i3k_db_marry_skills[v.skillId][v.skillLevel]
		local Layer = require("ui/widgets/jhfqyyt2")() --属性label
		Layer.vars.icon:setImage(i3k_db_icons[skill_data.skillsIcon].path)
		Layer.vars.level:setText(v.skillLevel.."级")
		Layer.vars.name:setText(skill_data.skillsName)
		Layer.vars.btn:onClick(self, self.onSelectSkillsShow,{widget = Layer.vars, index = i})
		if i==1 then
			Layer.vars.btn:stateToPressed()
		end
		self.scroll:addItem(Layer)
	end	
	--显示第一个技能的明细
	
end

--展示当前点中技能详情 index--技能
function wnd_marry_marryed_skills:showSkillsDetails(index)
	self.curSiklls = index
	local curLevel = self.marriageSkill[index].skillLevel
	--当前技能总投入次数
	local skillUpTimes = self.marriageSkill[index].skillUpTimes
	local skill_data = i3k_db_marry_skills[index][curLevel] --[self.marriageSkill[index]当前等级
	--self.qixueValue:show()
	self.showUpgradeUI:show()
	self.maxUI:hide()
	self.maxLevel:hide()
	if index then
		self.skillsicon:setImage(i3k_db_icons[skill_data.skillsIcon].path)
		self.skillsLevel:setText("LV."..curLevel)
		self.skillsName:setText(skill_data.skillsName)
		local nextLevel = curLevel+1
		if i3k_db_marry_skills[index][nextLevel] then
			local nextLevelData = i3k_db_marry_skills[index][nextLevel] 
			--升级需要投入次数
			local upgradeNeedTimes =nextLevelData.skillsUpgradeNeedTimes
			--单次需投入金币数
			local onecNeedUseMoney = i3k_db_marry_rules.everyTimeUseMoney 
			-- 需要总投入金币数 = 需要投入次数*单次投入金币数
			local needpropCount =upgradeNeedTimes *onecNeedUseMoney 
			--当前投入金币总值
			local curPush =skillUpTimes* onecNeedUseMoney
			self.onceValue:setText(i3k_db_marry_rules.everyTimeUseMoney)--单次消耗数值
			self.totalValue:setText(g_i3k_game_context:GetMoneyCanUse(false))--// 当前持有金钱
			self.expLoading:setPercent(curPush/needpropCount*100) --进度条 投入金币次数*每次金币=总投入金币数量/ 当前等级升级需要金币数量
			for i=1, 2 do
				local data = i==1 and i3k_db_buff[skill_data.buffId] or i3k_db_buff[nextLevelData.buffId]
				if data then
					local str = i3k_get_string(848, i3k_db_marry_rules.skillRange, data.affectTick/1000, data.affectValue/100)
					self._layout.vars["affectValue"..i]:setText(str)
				end
				self._layout.vars["moneyIcon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_COIN,i3k_game_context:IsFemaleRole()))
			end
			self._layout.vars.limitLabel:setText(i3k_get_string(857, nextLevelData.usedMarryLevel))
		else
			self.maxUI:show()
			local data = i3k_db_buff[skill_data.buffId]
			if data then
				str = i3k_get_string(848, i3k_db_marry_rules.skillRange, data.affectTick/1000, data.affectValue/100)
			else
				str = i3k_get_string(847, i3k_db_marry_rules.transitCoolingTime)
			end
			self.qixueValue:setText(str)
			self.showUpgradeUI:hide()
			self.maxLevel:show()
			self.expLoading:setPercent(1/1*100) --进度条	
		end
	end	
end

function wnd_marry_marryed_skills:onSelectSkillsShow(sender,data)
	self:AllBtnstateToPressed()
	data.widget.btn:stateToPressed()
	self:showSkillsDetails(data.index)
	
end

function wnd_marry_marryed_skills:onUpgrade(curTimes)
	local nowLevel = self.marriageSkill[self.curSiklls].skillLevel -- // 当前等级
	local nLevel = self.marriageSkill[self.curSiklls].skillLevel -- // 当前等级
	local nCount = self.marriageSkill[self.curSiklls].skillUpTimes--// 当前等级投入了几次

	local nNeedCount = 0;-- // 当前升级还需要几次
	local nMaxCount = 0; --//最大次数
	local nMarryLv = g_i3k_game_context:getMarryEveryData("marriageLevel")-- // 当前姻缘等级
	local nOnceMoney = i3k_db_marry_rules.everyTimeUseMoney--; --// 投入一次所需金钱
	local nMoney = g_i3k_game_context:GetMoneyCanUse(false)--// 当前持有金钱
	local data = i3k_db_marry_skills[self.curSiklls]
	local needCount--=data.skillsUpgradeNeedTimes; --// 所需投入次数
	local needMarryLv--=data.usedMarryLevel; --// 所需姻缘等级
	local nUpNums = 0;-- // 投入了几次
	local bIsLoop = true;-- // 是否继续循环
	local bIsToSever = true; --// 是否发数据给服务器
	while(bIsLoop) do
		--// 如果有升级所需的数据
		if data[nLevel+1]  then
		
			--// 先检查姻缘等级
			if nMarryLv < data[nLevel+1].usedMarryLevel then
				if nowLevel ~= nLevel then
					g_i3k_ui_mgr:PopupTipMessage("当前姻缘等级前提下投入最大次数:"..nUpNums)
				else
					bIsToSever = false
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(857,data[nLevel+1].usedMarryLevel))
				end
				break
			end
			--// 当前升级还需投入多少次
			nNeedCount = data[nLevel+1].skillsUpgradeNeedTimes - nCount;
			
			for i = 1 ,nNeedCount do 		
				--// 先检查金钱
				if nMoney < nOnceMoney then
					g_i3k_ui_mgr:PopupTipMessage("当前金币不足，升级失败")
					bIsLoop = false
					break
				end	
				--// 扣钱
				nMoney = nMoney - nOnceMoney
				
				--// 增加投入次数
				nUpNums = nUpNums +1
				nCount = nCount + 1
				
				--// 最多投入10次
				if nUpNums >= curTimes then
					bIsLoop = false
					break
				end
			end

			--// 当前投入次数大于等于本级所需投入次数 技能升级
			if nCount >= data[nLevel+1].skillsUpgradeNeedTimes then
				nLevel = nLevel +1
				--// 投入次数归0
				nCount = 0
			end
		else
		
			break
		end
	end	
	if bIsToSever and nUpNums ~=0 then
		--// 发给服务器
		i3k_sbean.skillsLevelup(self.curSiklls,nLevel,nUpNums)
		--sendtoServer(skillid, nLevel, nUpNums);
	end

end

--升级一次
function wnd_marry_marryed_skills:onUpgradeOneBtn(sender)
	self:onUpgrade(1)
end

--升级十次
function wnd_marry_marryed_skills:onUpgradeTenBtn(sender)
	self:onUpgrade(10)
end

--当前技能，投入铜钱后技能等级 ， 投入铜钱次数
function wnd_marry_marryed_skills:senderToServer(skillId,skillLevel,times)
	local needUseMoneyNum = i3k_db_marry_rules.everyTimeUseMoney  * times
	local _canUseMoney = g_i3k_game_context:GetMoneyCanUse(false)
	if needUseMoneyNum<=_canUseMoney then
		i3k_sbean.skillsLevelup(skillId,skillLevel,times)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(855))
	end
	
end

function wnd_marry_marryed_skills:AllBtnstateToPressed()
	for i, e in pairs(self.scroll:getAllChildren()) do
		if e.vars.btn then
			e.vars.btn:stateToNormal()
		end
	end
end


function wnd_marry_marryed_skills:onYinYuanBtn()
	--姻缘
	g_i3k_logic:OpenMarried_Yinyuan()
	--self:onCloseUI()
end

-- function wnd_marry_marryed_skills:onDivorceBtn()
-- 	--离婚
-- 	g_i3k_logic:OpenMarried_lihun()
-- 	--self:onCloseUI()
-- end

function wnd_marry_marryed_skills:onAchievementBtn(sender)
	g_i3k_logic:OpenMarried_achievement()
end

function wnd_marry_marryed_skills:release()
	
end

function wnd_marry_marryed_skills:onHide()
	self:release()
end

function wnd_marry_marryed_skills:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Marry_Marryed_skills)
end

function wnd_create(layout)
	local wnd = wnd_marry_marryed_skills.new()
	wnd:create(layout)
	return wnd
end
