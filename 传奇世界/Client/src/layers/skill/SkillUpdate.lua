local SkillUpdate = class("SkillUpdate",function() return cc.Layer:create() end)

function SkillUpdate:ctor(parent,skill_id,level,open,skillExp)
	self.parent = parent
	self.islvlimit = false
	self.skill_id = skill_id
	self.level = (level == 0) and 1 or level
	self.ismaxlv = false 

	self.currentExp = skillExp or 0
	self.scheduler = cc.Director:getInstance():getScheduler()
	local touchTemp = 0
	local touchTempTime = {1.1,2,2.8,3.5,4.1,4.6,5,5.3,5.5,5.6}
	local touchTime = 1
	local keepTouchTime = 0
	local touchEnable = true

	local msgids = {SKILL_SC_UPGRADESKILL}
	require("src/MsgHandler").new(self,msgids)

	self:registerScriptHandler(function(event)
		if event == "enter" then
			g_EventHandler["skillexpupdate"] = function(theSkillID,skillLev,skillExp,haveUpdate,skillExpAdd)
				local sld = getConfigItemByKey("SkillLevelCfg","skillID",theSkillID*1000+skillLev,"sld") 
				local showTip = function()
					local effectNeedLabel = createLabel(self, string.format(game.getStrByKey("skillUpdateTip1"),getConfigItemByKey("SkillCfg","skillID",theSkillID,"name"),tonumber(skillExpAdd)), cc.p(340,100), cc.p(0.5, 0.5), 20, false, nil, nil, MColor.white)
					effectNeedLabel:setScale(0.01)
					effectNeedLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.5), cc.ScaleTo:create(0.2, 1), cc.MoveBy:create(1, cc.p(0, 60)),
					cc.CallFunc:create(function() removeFromParent(effectNeedLabel) effectNeedLabel = nil end)))
					effectNeedLabel:runAction(cc.Sequence:create(cc.FadeOut:create(2)))
				end
				if theSkillID and not haveUpdate and theSkillID == skill_id then					
					self.skill_id = theSkillID
					self.currentExp = skillExp
					self.level = skillLev
					local tt = (sld == skillExp) and 2 or 1
					self:SkillUpdateExpFun(theSkillID,skillLev,self.currentExp,tt)
					if skillExpAdd and G_ROLE_MAIN.obj_id and skillExp then
						local temp = math.floor(touchTemp*10%3)		
						if touchTime <= #touchTempTime or ((touchTemp >= 0.5 and temp == 0) or touchTemp < 0.5) then
							showTip()
						end
					end
				else
					showTip()
				end
				if self.parent then					
					if sld and sld == skillExp then
						self.parent:reload(1)
					else		
						self.parent:reload(2,theSkillID,skillExp,sld)
					end
				end
			end
		elseif event == "exit" then
			g_EventHandler["skillexpupdate"] = nil
			if self.scheduler and self.schedulerHandle then
				self.scheduler:unscheduleScriptEntry(self.schedulerHandle)
			end
		end
	end)
	
	local skill_info = getConfigItemByKey("SkillCfg","skillID",self.skill_id)
	self.textBg = cc.Layer:create()
	self.textBg:setContentSize(cc.size(570,520))
	self.textBg:setPosition(cc.p(278,0))
	self:addChild(self.textBg)
	createLabel(self.textBg,game.getStrByKey("skilleffect"),cc.p(140,470),cc.p(0,0.5),20,nil,nil,nil,MColor.deep_brown)
		
	local title =  createSprite(self.textBg,"res/common/bg/titleLine.png",cc.p(375,505),cc.p(0.5,0.5))
	createLabel(title,game.getStrByKey("skillDesc"),cc.p(title:getContentSize().width/2,title:getContentSize().height/2),cc.p(0.5,0.5),21,nil,nil,nil,MColor.lable_yellow)
	local title1 = createSprite(self.textBg,"res/common/bg/titleLine.png",cc.p(375,280),cc.p(0.5,0.5))
	self.title1 = title1
	if skill_info.maxlv then
		if skill_info.maxlv > 1 then
			createLabel(self.textBg,game.getStrByKey("skilleffect1"),cc.p(140,380),cc.p(0,0.5),20,nil,nil,nil,MColor.deep_brown)
			self.descString1 = require("src/RichText").new(self.textBg, cc.p(140,365), cc.size(470, 100), cc.p(0.0, 1.0), 21, 19, MColor.black)
			self.descString1:addText(game.getStrByKey("needLearnFirst"), MColor.black,false)
			self.descString1:format()
		end
		if self.level == skill_info.maxlv or open == 2 then
			self.descString = require("src/RichText").new(self.textBg, cc.p(140,457), cc.size(470, 100), cc.p(0.0, 1.0), 21, 19, MColor.black)
			self.descString:addText(getConfigItemByKey("SkillLevelCfg", "skillID", skill_id*1000+self.level, "desc"), MColor.black,false)
			self.descString:format()
		end
	end

    local canUpdate = skill_info.canUpgrade
    local sldTemp = getConfigItemByKey("SkillLevelCfg","skillID",self.skill_id*1000+self.level,"sld") or -1
    --todo: updateButton, redPoint 已无用，需要移除相关逻辑
	if canUpdate == 0 and open ~= 2 and skill_info.maxlv > self.level and sldTemp ~= -1 then
		self.updateButtonOnce = createTouchItem(self.textBg,"res/component/button/50.png",cc.p(376, 100),function() 			
		 	self:youUpdate(self.skill_id,true)
		end,true)

		self.updateButton = GraySprite:create("res/component/button/50.png")
		self.redPoint = createSprite(self.updateButton,"res/component/flag/red.png",cc.p(self.updateButton:getContentSize().width,self.updateButton:getContentSize().height))
		self.redPoint:setVisible(false)
		self.updateButton:setPosition(cc.p(250,90))
		self.textBg:addChild(self.updateButton)
		self.updateButton:setVisible(false)

		local listenner = cc.EventListenerTouchOneByOne:create()
		listenner:setSwallowTouches(false)
		listenner:registerScriptHandler(function(touch,event)
			if self.updateButton and self.updateButton:isVisible() then
				local pt = touch:getLocation()		
				pt = self.updateButton:getParent():convertToNodeSpace(pt)
				if cc.rectContainsPoint(self.updateButton:getBoundingBox(),pt) and touchEnable and not self.islvlimit then
					touchTemp = 0
					touchTime = 1	
					keepTouchTime = 0
					self.updateButton:runAction(cc.ScaleTo:create(0.05,1.2,1.1))				
					local Update = function()
						if self.skill_id and self.level then
							local sld = getConfigItemByKey("SkillLevelCfg","skillID",self.skill_id*1000+self.level,"sld")
							if sld and sld > self.currentExp then
								touchTemp = touchTemp + 0.1
								local offset = sld - self.currentExp
								--控制定时器速度逻辑
								if touchTemp >= 0.5 then
									if touchTime <= #touchTempTime and touchTemp < touchTempTime[touchTime] then
									elseif touchTime > 10 and keepTouchTime == 0 and offset < 200 then
										keepTouchTime = touchTemp
									elseif keepTouchTime ~= 0 and touchTemp < keepTouchTime+0.3 then
									else
										touchTime = touchTime+1
										self:youUpdate(self.skill_id,false)
									end
									
								end
							end
						end
					end
					self.schedulerHandle = self.scheduler:scheduleScriptFunc(Update,0.1,false)
					return true
				end
			end
		end,cc.Handler.EVENT_TOUCH_BEGAN)

		listenner:registerScriptHandler(function(touch, event)
			self.updateButton:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,1,1)))
			AudioEnginer.playTouchPointEffect()
			local pt = touch:getLocation()
			pt = self.updateButton:getParent():convertToNodeSpace(pt)
			if self.scheduler and self.schedulerHandle then
				self.scheduler:unscheduleScriptEntry(self.schedulerHandle)
			end
			if cc.rectContainsPoint(self.updateButton:getBoundingBox(),pt) then
				if touchTemp < 0.5 then
					self:runAction(cc.Sequence:create(cc.CallFunc:create(function() self:youUpdate(self.skill_id,false)  touchEnable = false end),cc.DelayTime:create(0.2) ,cc.CallFunc:create(function() touchEnable = true end)))
				else
					touchEnable = true
				end
			end
		end,cc.Handler.EVENT_TOUCH_ENDED )

		listenner:registerScriptHandler(function(touch, event)
			self.updateButton:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,1,1)))
			AudioEnginer.playTouchPointEffect()
			local pt = touch:getLocation()
			pt = self.updateButton:getParent():convertToNodeSpace(pt)
			if self.scheduler and self.schedulerHandle then
				self.scheduler:unscheduleScriptEntry(self.schedulerHandle)
			end
			if cc.rectContainsPoint(self.updateButton:getBoundingBox(),pt) then	
				if touchTemp < 0.5 then
					self:runAction(cc.Sequence:create(cc.CallFunc:create(function() self:youUpdate(self.skill_id,false)  touchEnable = false end),cc.DelayTime:create(0.2) ,cc.CallFunc:create(function() touchEnable = true end)))
				else
					touchEnable = true
				end
			end
		end,cc.Handler.EVENT_TOUCH_CANCELLED )

		local eventDispatcher = self.updateButton:getParent():getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self.updateButton:getParent())

		
		local btnSize = self.updateButton:getContentSize()
		self.updateText = createLabel(self.updateButton,game.getStrByKey("upgrade"),cc.p(btnSize.width/2,btnSize.height/2),cc.p(0.5,0.5),24,true,nil,nil,MColor.yellow_gray)
		self.updateText1 = createLabel(self.updateButtonOnce,game.getStrByKey("skillUpdateDesc2"),cc.p(btnSize.width/2,btnSize.height/2),cc.p(0.5,0.5),24,true,nil,nil,MColor.yellow_gray)
		G_TUTO_NODE:setTouchNode(self.updateButtonOnce, TOUCH_SKILL_UPDATE)
	end
	if open ~= 2 then
		createLabel(title1,game.getStrByKey("updateFact"),cc.p(title1:getContentSize().width/2,title1:getContentSize().height/2),cc.p(0.5,0.5),21,nil,nil,nil,MColor.lable_yellow)
		if canUpdate == 0 then
			local property = getConfigItemByKey("SkillLevelCfg","skillID",self.skill_id*1000+self.level,"sld") or -1
			self:SkillUpdateExpFun(self.skill_id,self.level,self.currentExp,2)
		else
			createLabel(self.textBg,game.getStrByKey("skillUpdateDesc3"),cc.p(370,180),cc.p(0.5,0.5),19,nil,nil,nil,MColor.red)
		end
	else
		createLabel(self.textBg,game.getStrByKey("notLearnSkill"),cc.p(370,200),cc.p(0.5,0.5),20,nil,nil,nil,MColor.red)
		createLabel(title1,game.getStrByKey("skillStates"),cc.p(title1:getContentSize().width/2,title1:getContentSize().height/2),cc.p(0.5,0.5),21,nil,nil,nil,MColor.lable_yellow)
	end
    while true do
        if G_NO_OPEN_SKILLPREVIEW then
            break
        end
        self.skillPreviewButton = createTouchItem(self.textBg, "res/component/button/50.png", cc.p(376, 100), function()
		 	getRunScene():addChild(require("src/layers/skill/SkillPreview").new(skill_id), require("src/config/CommDef").ZVALUE_UI)
		end, true)
        createLabel(self.skillPreviewButton, game.getStrByKey("skillPreview"), getCenterPos(self.skillPreviewButton), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.yellow_gray)
        if self.updateButtonOnce then
            self.skillPreviewButton:setPosition(cc.p(416 + 50, 100))
            self.updateButtonOnce:setPosition(cc.p(336 - 50, 100))
        end
        break
    end
	if parent then 
		parent:addChild(self)
	end
end

function SkillUpdate:youUpdate(skill_id,way)
	if skill_id and not self.ismaxlv then
		local t = {}
		t.skillId = skill_id
		t.quickUpgrade = way
		g_msgHandlerInst:sendNetDataByTable(SKILL_CS_UPGRADESKILL, "SkillUpgradeProtocol", t )
	end
end

function SkillUpdate:showProp(skillId,level,skillExp,skillExpSum,skill_info,skillLevelInfo,refreshWay)
	local MRoleStruct = require("src/layers/role/RoleStruct")
	-- local Mprop = require "src/layers/bag/prop"
	local MPropOp = require "src/config/propOp"
	local bag = MPackManager:getPack(MPackStruct.eBag)
	local propNum = 0
	-- if refreshWay == 2 then

		if self.tipText then
			removeFromParent(self.tipText)
			self.tipText =nil 
		end

		if self.payText then
			removeFromParent(self.payText)
			self.payText = nil
		end

		if self.lab then
			removeFromParent(self.lab)
			self.lab = nil
		end

		local func = function(pn)
	        local Mtips = require "src/layers/bag/tips"
			Mtips.new(
			{ 
				protoId = pn,
				pos = cc.p(0, 0),
			})
	    end
	    local jjjn = getConfigItemByKey("SkillLevelCfg","skillID",skillId*1000+level,"jjjn") or 2015
		if skillExpSum ~= -1 and skill_info.maxlv > level then
			if skillLevelInfo.needbook_Num and skillLevelInfo.needbook_ID and skillExp == skillExpSum then
				local pillNum = {skillLevelInfo.needbook_Num,skillLevelInfo.needbook_ID}								
				propNum = bag:countByProtoId(tonumber(pillNum[2]))
				local color = MColor.green
				if tonumber(pillNum[1]) > propNum then
					color = MColor.red
				end
				self.lab = cc.Node:create()
				self.textBg:addChild(self.lab)
				self.tipText = require("src/RichText").new(self.lab, cc.p(460,185), cc.size(500, 50), cc.p(0.5, 0.5), 22, 20, MColor.white)
				self.tipText:addText(game.getStrByKey("skill_tipText"),MColor.deep_brown,true)
				self.tipText:addTextItem(MPropOp.name(pillNum[2]), MColor.yellow, true, true, true, function() func(pillNum[2]) end )
				self.tipText:addText(string.format(game.getStrByKey("skill_tipText1"),(pillNum[1])),color,true)
				self.tipText:addText(game.getStrByKey("skill_tipText2"),MColor.deep_brown,true)
				self.tipText:addText(tostring(propNum),MColor.white,true)
				self.tipText:format()

				-----------------------------------------------------------------------------------
				local tmp_node = cc.Node:create()
				local tmp_func = function(observable, event, pos, pos1, new_grid)
					if event == "-" or event == "+" or event == "=" then
						propNum = bag:countByProtoId(tonumber(pillNum[2]))

						if self.tipText then
							removeFromParent(self.tipText)
							self.tipText = nil
						end
						local color = MColor.green
						if pillNum[1] > propNum then
							color = MColor.red
						end
						self.tipText = require("src/RichText").new(self.lab, cc.p(460,185), cc.size(500, 50), cc.p(0.5, 0.5), 22, 20, MColor.white)
						self.tipText:addText(game.getStrByKey("skill_tipText"),MColor.deep_brown,true)
						self.tipText:addTextItem(MPropOp.name(pillNum[2]), MColor.yellow, true, true, true, function() func(pillNum[2]) end )
						self.tipText:addText(string.format(game.getStrByKey("skill_tipText1"),(pillNum[1])),color,true)
						self.tipText:addText(game.getStrByKey("skill_tipText2"),MColor.deep_brown,true)
						self.tipText:addText(tostring(propNum),MColor.white,true)
						self.tipText:format()
					end
				end

				tmp_node:registerScriptHandler(function(event)
					if event == "enter" then
						bag:register(tmp_func)
					elseif event == "exit" then
						bag:unregister(tmp_func)
					end
				end)
				self.lab:addChild(tmp_node)
				--------------------------------------------------				

			else

				propNum = (math.ceil(skillExpSum/100)-math.floor(skillExp/100))	
				local numTemp = bag:countByProtoId(jjjn)
				local color = MColor.green
				if propNum > numTemp then
					color = MColor.red
				end
				self.lab = cc.Node:create()
				self.textBg:addChild(self.lab)
				self.tipText = require("src/RichText").new(self.lab, cc.p(460,185), cc.size(500, 50), cc.p(0.5, 0.5), 22, 20, MColor.white)
				self.tipText:addText(game.getStrByKey("skill_tipText"),MColor.deep_brown,true)
				self.tipText:addTextItem(MPropOp.name(jjjn), MColor.yellow, true, true, true, function() func(jjjn) end )
				self.tipText:addText(string.format(game.getStrByKey("skill_tipText1"),propNum),color,true)
				self.tipText:addText(game.getStrByKey("skill_tipText2"),MColor.deep_brown,true)
				self.tipText:addText(tostring(numTemp),MColor.white,true)
				self.tipText:format()									
				---------------------------------------------------------------------------------
				local tmp_node = cc.Node:create()
				local tmp_func = function(observable, event, pos, pos1, new_grid)
					if event == "-" or event == "+" or event == "=" then
						local tt = bag:countByProtoId(jjjn)
						if self.tipText then
							removeFromParent(self.tipText)
							self.tipText = nil
						end
						local color = MColor.green
						if propNum > tt then
							color = MColor.red
						end
						self.tipText = require("src/RichText").new(self.lab, cc.p(460,185), cc.size(500, 50), cc.p(0.5, 0.5), 22, 20, MColor.white)
						self.tipText:addText(game.getStrByKey("skill_tipText"),MColor.deep_brown,true)
						self.tipText:addTextItem(MPropOp.name(jjjn), MColor.yellow, true, true, true, function() func(jjjn) end )
						self.tipText:addText(string.format(game.getStrByKey("skill_tipText1"),propNum),color,true)
						self.tipText:addText(game.getStrByKey("skill_tipText2"),MColor.deep_brown,true)
						self.tipText:addText(tostring(tt),MColor.white,true)
						self.tipText:format()
					end
				end

				tmp_node:registerScriptHandler(function(event)
					if event == "enter" then
						bag:register(tmp_func)
					elseif event == "exit" then
						bag:unregister(tmp_func)
					end
				end)
				self.lab:addChild(tmp_node)
				------------------------------------------------	

				local mylv = MRoleStruct:getAttr(ROLE_LEVEL)
				if skillLevelInfo.djxz and mylv < skillLevelInfo.djxz then
					self.payText = createLabel(self.title1,string.format(game.getStrByKey("skillLevLimit"),getConfigItemByKey("SkillLevelCfg","skillID",skillId*1000+level,"djxz")),cc.p(130,-15),cc.p(0.5,0.5),20,true,nil,nil,MColor.red)
					self.islvlimit = true
					if self.updateButtonOnce then
						-- self.updateButton:addColorGray()
						self.updateButtonOnce:setEnable(false)
						-- self.updateText:setColor(MColor.gray)
						self.updateText1:setColor(MColor.gray)
					end
				else
					self.payText = require("src/RichText").new(self.title1, cc.p(130,-25), cc.size(465, 50),cc.p(0.5,0.5), 22, 19, MColor.black)
					self.payText:setAutoWidth()
					self.payText:addText(game.getStrByKey("skillUpdateDesc1"),MColor.deep_brown , false)
			    	self.payText:format()
			    end
			end
		else
			self.payText = createLabel(self.textBg,game.getStrByKey("skillUpdateDesc7"),cc.p(375,185),cc.p(0.5,0.5),21,false,nil,nil,MColor.black)	
			-- if self.updateButton then
			-- 	removeFromParent(self.updateButton)
			-- 	self.updateButton = nil
			-- end
			if self.updateButtonOnce then
				removeFromParent(self.updateButtonOnce)
				self.updateButtonOnce = nil
			end
		end
	-- else
		-- if self.tipText1 then
		-- 	propNum = (math.ceil(skillExpSum/100)-math.floor(skillExp/100))
		-- 	self.tipText1:setString(string.format(game.getStrByKey("skill_tipText1"),propNum))
		-- end
		-- if self.tipText2 then
		-- 	local tt = bag:countByProtoId(2015)
		-- 	self.tipText2:setString(tostring(tt))
		-- end
	-- end
end

function SkillUpdate:proficiency(skillID,skillPro,level,refreshWay)
	if skillID and skillPro and level then
		local skillLevel_info = getConfigItemByKey("SkillLevelCfg","skillID",skillID*1000+level)
		local skill_info = getConfigItemByKey("SkillCfg","skillID",skillID)
		local theProficiency = skillLevel_info.sld or -1
		if theProficiency and skillPro == theProficiency and self.updateButton then
			if self.scheduler and self.schedulerHandle then
				self.scheduler:unscheduleScriptEntry(self.schedulerHandle)
			end
			if self.redPoint then						
				self.redPoint:setVisible(true)
			end			
		elseif (skill_info.maxlv and skill_info.maxlv <= level) and theProficiency == -1 then
			self.ismaxlv = true
		  	if self.redPoint then
				self.redPoint:setVisible(false)
			end
		else
			if self.redPoint then
				self.redPoint:setVisible(false)
			end
		end
		
		self:showProp(skillID,level,skillPro,theProficiency,skill_info,skillLevel_info,refreshWay)
			
		if refreshWay == 2 then
			local str = game.getStrByKey("fullLevel")
			local describe = skillLevel_info.desc or "..."
			local describe1 = getConfigItemByKey("SkillLevelCfg","skillID",skillID*1000+level+1,"desc") or str
			if self.descString then
				removeFromParent(self.descString)
				self.descString = nil
			end
			if self.descString1 then
				removeFromParent(self.descString1)
				self.descString1 = nil
			end

			self.descString = require("src/RichText").new(self.textBg, cc.p(140,455), cc.size(470, 100), cc.p(0.0, 1.0), 21, 19, MColor.black)
			self.descString:addText(describe, MColor.black,false)
			self.descString:format()
			self.descString1 = require("src/RichText").new(self.textBg, cc.p(140,365), cc.size(470, 100), cc.p(0.0, 1.0), 21, 19, MColor.black)
			self.descString1:addText(describe1, MColor.black,false)
			self.descString1:format()
		end
	end
end

function SkillUpdate:SkillUpdateExpFun(theSkillID,skillLev,skillExp,refreshWay)  --获取技能每10点熟练度消息
	if not skillExp then
		skillExp = 0
	end
	if theSkillID and skillLev then
		self:proficiency(theSkillID,skillExp,skillLev,refreshWay)
	end
end

function SkillUpdate:SkillUpdateTip(skillId ,skillLev )
	if skillId and skillLev then
		local tempForLev = ""
		local tempForLev1 = ""
		local starColor = getConfigItemByKey("SkillLevelCfg", "skillID", skillId*1000+skillLev, "skill_color")
		local starNum = getConfigItemByKey("SkillLevelCfg", "skillID", skillId*1000+skillLev, "skill_starNum")	
		tempForLev = tostring(starColor)	
		if starColor and starColor > 3 then			
			if starNum then
				tempForLev1 = tostring(starNum..game.getStrByKey("task_d_x"))
			end
		end
		TIPS({type = 1, str = string.format(game.getStrByKey("skillUpdateTip"),getConfigItemByKey("SkillCfg","skillID",skillId,"name"),game.getStrByKey("skillLevel"..tempForLev)..tempForLev1)})
	end
end

function SkillUpdate:networkHander(buff,msgid)
	local switch = {
		[SKILL_SC_UPGRADESKILL] = function()

			local t = g_msgHandlerInst:convertBufferToTable("SkillUpgradeRetProtocol", buff)
			local skills = {t.skillId,t.level,t.shutKey,t.exp}
			self.currentExp = skills[4]
			self.level = skills[2]
			if getConfigItemByKey("SkillCfg","skillID",skills[1],"jnfenlie") == 1 then
				self:SkillUpdateExpFun(skills[1],skills[2],skills[4],2)
				self:SkillUpdateTip(skills[1],skills[2])
				if G_ROLE_MAIN and G_ROLE_MAIN.skills then --由客户端修改本地强化度的值
					for k,v in pairs(G_ROLE_MAIN.skills) do
						if skills[1] == v[1] then
							v[4] = skills[4]
							v[2] = skills[2]
							if self.parent then
								self.parent:reload(1)
							end
							break
						end
					end
				end
			end		
			-- local isRed = false
			-- checkSkillRed()
			-- for k,v in pairs(G_SKILL_REDCHECK[1]) do
			-- 	if v then
			-- 		isRed = true
			-- 	end
			-- end	
			-- if not isRed then
			-- 	for k,v in pairs(G_SKILL_REDCHECK[2]) do
			-- 		if v then
			-- 			isRed = true
			-- 			break
			-- 		end				
			-- 	end	
			-- end		
			-- if G_MAINSCENE and G_MAINSCENE.red_points and not isRed then
 		-- 		G_MAINSCENE.red_points:removeRedPoint(4, 2)
   --  		end
		end,
	}

 	if switch[msgid] then
 		switch[msgid]()
 	end
end

return SkillUpdate