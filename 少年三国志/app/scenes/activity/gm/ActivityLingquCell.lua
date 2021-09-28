require("app.cfg.task_info")
local ActivityLingquCell = class("ActivityLingquCell",function()
	return CCSItemCellBase:create("ui_layout/activity_ActivityLingquCell.json")
	end)
local ActivityLimit  = require("app.scenes.activity.gm.ActivityLimit")
local ActivityDailyCellItem = require("app.scenes.activity.ActivityDailyCellItem")
local FunctionLevelConst = require("app.const.FunctionLevelConst")
local FuCommon = require("app.scenes.dafuweng.FuCommon")

function ActivityLingquCell:ctor(...)
	self._space = 10

	self._scrollView = self:getScrollViewByName("ScrollView_duihuan")
	self._conditionLabel = self:getLabelByName("Label_condition")
	self._progressTagLabel = self:getLabelByName("Label_progressTag")
	self._progressLabel = self:getLabelByName("Label_progress")

	self._conditionLabel:setText("")
	self._progressLabel:setText("")
	--注册点击事件
	self:_initEvent()
	self:attachImageTextForBtn("Button_lingqu","Image_25")

	self._richText = nil
end

function ActivityLingquCell:_initEvent()
	self:registerBtnClickEvent("Button_lingqu",function()
		if not self._quest or (not self._curQuest) then
			return
		end

		if not ActivityLimit.checkByQuest(self._quest) then
			return
		end
		--活动处于预览期
		if G_Me.activityData.custom:checkPreviewByActId(self._quest.act_id) then
			-- G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_IS_IN_PREVIEW"))
			G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_IS_IN_PREVIEW",{time=G_Me.activityData.custom:getStartDateByActId(self._quest.act_id)}))
			return
		end

		--判断是否过了领取时间
		if not G_Me.activityData.custom:checkActAward(self._quest.act_id) then
			G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_AWARD_TIME_OUT"))
			return
		end

		--是否已经领取
		if self._quest.award_limit ~= 0 and self._curQuest.award_times >= self._quest.award_limit then
			print("已经领取了")
			return
		end

		local act = G_Me.activityData.custom:getActivityByActId(self._quest.act_id)
		if not act then
			return
		end
		--先判断是否完成
		local value02 = self._quest.param1 or 0   --完成所需次数


		local progress = self._curQuest.progress or 0   --当前进度
		--[[
			[6] = {106,"活动期间获取#name##num#个",},
		]]
		if self._quest.quest_type == 106 then
			--此时第三个参数为所需次数
			value02 = self._quest.param3 or 0   --完成所需次数

			-- {303,"本日单笔充值满#num#元",},
			-- {306,"本日单笔充值满#num1#~#num2#元",},
		elseif self._quest.quest_type == 303 or self._quest.quest_type == 306 then    
			value02 = self._curQuest.award_times
		end

		local awardFunc = function()

			--判断包裹是否满了
			if G_Me.activityData.custom:checkBagFullByQuest(self._quest) then
				return
			end

			-- 判断是否多选1
			if self._quest.award_select > 0 then
				require("app.scenes.sanguozhi.SanguozhiSelectAwardLayer").showForCustomActivity(self._quest, function(index)
						G_HandlersManager.gmActivityHandler:sendGetCustomActivityAward(self._quest.act_id,self._quest.quest_id,(index-1)) 
					end)
			else
				G_HandlersManager.gmActivityHandler:sendGetCustomActivityAward(self._quest.act_id,self._quest.quest_id) 
			end
		end
		if self._quest.quest_type == 303 or self._quest.quest_type == 306 then
			if progress > value02 then
				awardFunc()
				return
			end
		else
			if progress >= value02 then
				awardFunc()
				return
			end
		end
		--未完成--前往

		--判断是否过期，过期了就不前往了
		if not G_Me.activityData.custom:checkActActivate(self._quest.act_id) then
			G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_IS_TIME_OUT_TIPS"))
			return
		end

		--[[
			[1] = {101,"主线副本战斗胜利#num#次",},
			[2] = {102,"名将副本战斗胜利#num#次",},
			[3] = {103,"三国无双挑战#num#次",},
			[4] = {104,"竞技场胜利#num#次",},
			[5] = {105,"夺宝#num#次",},
			[6] = {106,"活动期间获取#name##num#个",},
			[7] = {107,"击毙叛军#num#名",},
			[8] = {108,"攻打叛军#num#名",},
			[9] = {109,"累计登陆#num#天",},
			[10] = {301,"本日充值#num#元",},
			[11] = {302,"活动期间总共充值#num#元",},
			[12] = {303,"本日单笔充值满#num#元",},
			[13] = {304,"本日消耗元宝#num#",},
			[14] = {305,"活动期间总共消耗#num#元宝",},
			[15] = {110,"精英副本战斗胜利#num#次",},
			[16] = {111,"幸运轮盘总积分达到#num#",},
			  [16] = {112,"神将招募#num#",},
		]]
		if act and act.act_type == 1 then
			--领取类型
			local sceneName = nil
			if self._quest.quest_type == 101 then
				sceneName = G_GlobalFunc.getScenePath("DungeonMainScene")
			elseif self._quest.quest_type == 102 then
				if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.STORY_DUNGEON) then
				    sceneName = G_GlobalFunc.getScenePath("StoryDungeonMainScene")
				end
			elseif self._quest.quest_type == 103 then
				if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TOWER_SCENE) then
				    sceneName = G_GlobalFunc.getScenePath("WushScene")
				end
			elseif self._quest.quest_type == 104 then
				if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.ARENA_SCENE) then
				    sceneName = G_GlobalFunc.getScenePath("ArenaScene")
				end
			elseif self._quest.quest_type == 105 then
				if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TREASURE_COMPOSE) then
				    sceneName = G_GlobalFunc.getScenePath("TreasureComposeScene")
				end
			elseif self._quest.quest_type == 106 then
			elseif self._quest.quest_type == 107 or self._quest.quest_type == 108 then   -- 击毙叛军#num#名   || 攻打叛军#num#名
				if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.MOSHENG_SCENE) then
				    sceneName = G_GlobalFunc.getScenePath("MoShenScene")
				end
			elseif self._quest.quest_type == 109 then
			elseif self._quest.quest_type == 110 then
				-- 精英副本条件任务
				if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.HARDDUNGEON) then
					sceneName = G_GlobalFunc.getScenePath("HardDungeonMainScene")
				end
			elseif self._quest.quest_type == 111 then
				if G_Me.wheelData:getState() == 3 then
				    G_MovingTip:showMovingTip(G_lang:get("LANG_FU_NOACT"))
				    return 
				end
				uf_sceneManager:replaceScene(require("app.scenes.wheel.WheelScene").new())
				return
			elseif self._quest.quest_type == 112 then
				local layer = require("app.scenes.shop.ShopDropGodlyKnightLayer").new()
				uf_sceneManager:getCurScene():addChild(layer)
				return
			elseif self._quest.quest_type == 113 then
				if G_Me.richData:getState() == FuCommon.STATE_CLOSE  then
				    G_MovingTip:showMovingTip(G_lang:get("LANG_FU_NOACT"))
				    return 
				end
				if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.RICHMAN) == true then
				    uf_sceneManager:replaceScene(require("app.scenes.dafuweng.RichScene").new())
				    return
				end
				return
			elseif self._quest.quest_type == 114 then
				if G_Me.trigramsData:getState() == FuCommon.STATE_CLOSE then
				        G_MovingTip:showMovingTip(G_lang:get("LANG_FU_NOACT"))
				        return 
				end
				if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TRIGRAMS) == true then
				        uf_sceneManager:replaceScene(require("app.scenes.trigrams.TrigramsScene").new())
				        return
				end
				return
			elseif self._quest.quest_type == 115 then  --点将台点将次数
				if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.HERO_SOUL) then
					uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.herosoul.HeroSoulScene").new(nil, nil, nil, require("app.const.HeroSoulConst").TERRACE))
				end
			end
			if sceneName then
				uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new())
			end
		else
			--去充值
			require("app.scenes.shop.recharge.RechargeLayer").show()
		end
		end)
end

function ActivityLingquCell:updateItem(quest)
	self._quest = quest
	self._curQuest = nil
	if not quest then
		if self._richText then
			self._richText:setVisible(false)
			self._conditionLabel:setVisible(false)
		end
		return
	end
	--先设定默认按钮状态
	self:getButtonByName("Button_lingqu"):setTouchEnabled(true)

	self._curQuest = G_Me.activityData.custom:getCurQuestByQuest(self._quest)
	if not self._curQuest then
		return
	end
	local task = task_info.get(quest.quest_type)
	if not task then
		return
	end
	local act = G_Me.activityData.custom:getActivityByActId(self._quest.act_id)
	local value02 = quest.param1 or 0   --完成所需次数
	local value01 = self._curQuest.progress or 0   --当前进度
	local condition = ""
	--[[
		[6] = {106,"活动期间获取#name##num#个",},
	]]
	if quest.quest_type == 106 then
		local good = G_Goods.convert(quest.param1,quest.param2,quest.param3)
		--此时第三个参数为所需次数
		value02 = quest.param3 or 0   --完成所需次数
		if good then
			condition = G_lang:getByString(task.comment,{name=good.name,num=good.size})
			-- condition = G_lang:get("LANG_ACTIVITY_SOU_JI",{name=good.name,color=Colors.qualityDecColors[good.quality],num=good.size})
			-- self:_createRickText(condition)
			-- self._richText:setVisible(true)
			self._conditionLabel:setVisible(true)
			self._conditionLabel:setText(condition or "")
		else
			self._conditionLabel:setVisible(true)
			if self._richText then
				self._richText:setVisible(false)
			end
			self._conditionLabel:setText("")
		end
	elseif quest.quest_type == 306 then   --单笔区间充值
		condition=G_lang:getByString(task.comment,{num1=quest.param1,num2=quest.param2})
		if quest.param2 <= quest.param1 then
			--配置错了
			condition = ""
		end
		self._conditionLabel:setText(condition)
	else
		condition = quest.param1 > 0 and G_lang:getByString(task.comment,{num=value02}) or ""
		self._conditionLabel:setText(condition)
	end

	-- 303需要做特殊处理   单笔充值
	--306也需要特殊处理    单笔区间充值
	if quest.quest_type == 303 or quest.quest_type == 306 then
		--当领取次数比进度小时，显示领取
		value02 = quest.award_limit
		value01 = self._curQuest.award_times or 0   --当前进度
		local leftimes = value02 > value01 and (value02-value01) or 0
		local leftTime = string.format("%s/%s",leftimes,value02)
		self._progressLabel:setText(leftTime)
		--显示剩余次数
		self._progressTagLabel:setText(G_lang:get("LANG_ACTIVITY_LEFT_TIMES_TAG"))
	else
		value01 =  value01 > value02 and value02 or value01
		local progress = string.format("%s/%s",value01,value02)
		self._progressLabel:setText(progress)
		--显示进度
		self._progressTagLabel:setText(G_lang:get("LANG_DAILYTASK_PRO"))
	end
	--刷新按钮状态
	if self._quest.award_limit ~= 0 and self._curQuest.award_times >= self._quest.award_limit then
		--已经领取了
		self:showWidgetByName("Image_yilingqu",true)
		self:showWidgetByName("Button_lingqu",false)
	else
		self:showWidgetByName("Image_yilingqu",false)
		self:showWidgetByName("Button_lingqu",true)
		if act and act.act_type == 1 then   --
			--显示前往
			if value01 >= value02 then 
				--领取
				self:getButtonByName("Button_lingqu"):loadTextureNormal("btn-small-red.png",UI_TEX_TYPE_PLIST)
				self:getImageViewByName("Image_25"):loadTexture(G_Path.getSmallBtnTxt("lingqu.png"))
			else
				--领取类型
				--[[
					[9] = {109,"累计登陆#num#天",},
					[6] = {106,"活动期间获取#name##num#个",},
				]]
				if quest.quest_type == 109 or quest.quest_type == 106 then   
					self:getButtonByName("Button_lingqu"):loadTextureNormal("btn-small-red.png",UI_TEX_TYPE_PLIST)
					self:getButtonByName("Button_lingqu"):setTouchEnabled(false)
					self:getImageViewByName("Image_25"):loadTexture(G_Path.getSmallBtnTxt("lingqu.png"))
				else
					self:getButtonByName("Button_lingqu"):setTouchEnabled(true)
					self:getButtonByName("Button_lingqu"):loadTextureNormal("btn-small-blue.png",UI_TEX_TYPE_PLIST)
					self:getImageViewByName("Image_25"):loadTexture(G_Path.getSmallBtnTxt("qianwang.png"))
				end

				--普通领取类显示前往
				--前往
			end
		else   --充值类型

			--[[
				type=301，充值类：剩余次数>=1时，未完成为充值按钮，完成后为领取按钮；剩余次数=0时，为水印
				type=302，同上
				type=303，同上  {303,"本日单笔充值满#num#元",},
				type=306，同上  {303,"本日单笔充值#num1#~#num2#元",},
				type=304，消耗类：剩余次数>=1时，未完成为灰色领取按钮，完成后为领取按钮；剩余次数=0时为水印
				type=305，同上
			]]


			if quest.quest_type == 304 or quest.quest_type == 305 then
				self:getImageViewByName("Image_25"):loadTexture(G_Path.getSmallBtnTxt("lingqu.png"))
				self:getButtonByName("Button_lingqu"):loadTextureNormal("btn-small-red.png",UI_TEX_TYPE_PLIST)
				if value01 >= value02 then
					--领取
					self:getButtonByName("Button_lingqu"):setTouchEnabled(true)
				else
					self:getButtonByName("Button_lingqu"):setTouchEnabled(false)
				end
			else 
				--{303,"本日单笔充值满#num#元",},
				--{306,"本日单笔充值#num1#~#num2#元",},
				if quest.quest_type == 303 or quest.quest_type == 306 then 
					--领取次数小于进度 时候显示领取
					if self._curQuest.award_times < self._curQuest.progress then
						self:getImageViewByName("Image_25"):loadTexture(G_Path.getSmallBtnTxt("lingqu.png"))
						self:getButtonByName("Button_lingqu"):loadTextureNormal("btn-small-red.png",UI_TEX_TYPE_PLIST)
					else
						self:getImageViewByName("Image_25"):loadTexture(G_Path.getSmallBtnTxt("quchongzhi.png"))
						self:getButtonByName("Button_lingqu"):loadTextureNormal("btn-small-blue.png",UI_TEX_TYPE_PLIST)
					end 
				else
					if value01 >= value02 then
						self:getImageViewByName("Image_25"):loadTexture(G_Path.getSmallBtnTxt("lingqu.png"))
						self:getButtonByName("Button_lingqu"):loadTextureNormal("btn-small-red.png",UI_TEX_TYPE_PLIST)
					else
						self:getImageViewByName("Image_25"):loadTexture(G_Path.getSmallBtnTxt("quchongzhi.png"))
						self:getButtonByName("Button_lingqu"):loadTextureNormal("btn-small-blue.png",UI_TEX_TYPE_PLIST)
					end
				end
			end
		end
		
	end
	self:attachImageTextForBtn("Button_lingqu","Image_25")
	self:_initScrollView(quest)
end

--搜集类的富文本
function ActivityLingquCell:_createRickText(text)
	if self._richText ~= nil then
		self._richText:removeFromParentAndCleanup(true)
		self._richText = nil
	end
	if self._richText == nil then
		local size = self._conditionLabel:getContentSize()
		local width = 450
		self._richText = CCSRichText:create(width, 76)
		self._richText:setFontSize(self._conditionLabel:getFontSize())
		self._richText:setFontName(self._conditionLabel:getFontName())
		local x,y = self._conditionLabel:getPosition()
		self._conditionLabel:setVisible(false)
		self._richText:setPosition(ccp(x + width/2,y+10))
		-- self._richText:enableStroke(Colors.strokeBrown)
		self:addChild(self._richText)
	end
	self._richText:clearRichElement()
	if text then
	    self._richText:appendXmlContent(text)
	    self._richText:reloadData()
	end
end

function ActivityLingquCell:_getScrollViewHeight()
    if not self._scrollView then
        return 0
    end
    return self._scrollView:getContentSize().height
end

function ActivityLingquCell:_getScrollViewWidth()
    if not self._scrollView then
        return 0
    end
    return self._scrollView:getContentSize().width
end

function ActivityLingquCell:_initScrollView(quest)
	if self._scrollView then
		self._scrollView:removeAllChildrenWithCleanup(true)
	else
		return
	end
	local goodList = {}

	--scrollview的滑动宽度
	local innerWidth = 0

	local widgetWidth = 0  --icon的宽度
	for i=1,4 do
		local _type = quest["award_type" .. i]
		if _type > 0 then
			local value = quest["award_value" .. i]
			local size = quest["award_size" .. i]
			local good = G_Goods.convert(_type,value,size)
			if good then
				table.insert(goodList,good)
				local widget = ActivityDailyCellItem.new(good)
				widgetWidth = widget:getContentSize().width
				local height = widget:getContentSize().height
				widget:setPosition(ccp(self._space*i + (i-1)*widgetWidth,(self:_getScrollViewHeight()-height)/2))
				self._scrollView:addChild(widget)
			end
		end
	end
	--总长度
	local width = self._space*(#goodList+1) + #goodList*widgetWidth
	innerWidth = width > self:_getScrollViewWidth() and width or self:_getScrollViewWidth()
	self._scrollView:setInnerContainerSize(CCSizeMake(innerWidth,self:_getScrollViewHeight()))
end

return ActivityLingquCell