local BaseLayer = class("BaseLayer",function() return cc.Layer:create() end )

--require("src/layers/setting/SettingMsg")

function BaseLayer:ctor(parent)

end

function BaseLayer:addScroll(size,nodeSize,pos,isneedSlide)
	local scrollView = cc.ScrollView:create()
    if nil ~= scrollView then
        --scrollView:setViewSize(cc.size(935,465))
        scrollView:setViewSize(size)
        scrollView:setPosition(pos)
        scrollView:setScale(1.0)
        scrollView:ignoreAnchorPointForPosition(true)
        local node = cc.Node:create()
        self.base_node = node
        -- if pos then
        -- 	self.base_node:setPosition(pos)
        -- end
        node:setContentSize(nodeSize)
        scrollView:setContainer(node)
        scrollView:updateInset()
        if isneedSlide then
        	scrollView:addSlider("res/common/slider.png")
        end
        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
        scrollView:setClippingToBounds(true)
        scrollView:setBounceable(false)
        -- scrollView1:setDelegate()
        -- scrollView1:registerScriptHandler(scrollView1DidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
        -- scrollView1:registerScriptHandler(scrollView1DidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
        self:addChild(scrollView)
        self.srollView = scrollView
    end
end

function BaseLayer:getScroll()
	return self.srollView
end

function BaseLayer:createSwitch(parent,pos,str,value,flag,callback,indefinePor,relativeFlag,loadFile_open,loadFile_close)
	self.switchs = self.switchs or {}
	self.lab = {}
	self.switchs[flag] = (value == 1)
	local loadstr1,loadstr2

	local drugSpecial = function(flag)
		local deal = function(tab)			
			local j = 1
		    while j <= #G_DRUG_CHECK do
		        for k,v in pairs(tab) do		           
		            if v[4] == G_DRUG_CHECK[j] then
		                table.remove(G_DRUG_CHECK,j)		           
		                break
		            end
		        end

		        j = j + 1
		    end
		    if G_MAINSCENE then
		    	G_MAINSCENE.shouldShowDrug = {}
		    end
		end
		if flag == GAME_SET_RED1 and getGameSetById(GAME_SET_RED1) == 0 then
			deal(G_DRUG_HP)
		end
		if flag == GAME_SET_RED2 and getGameSetById(GAME_SET_RED2) == 0 then
			deal(G_DRUG_HP_SHORT)
		end
		if flag == GAME_SET_BLUE and getGameSetById(GAME_SET_BLUE) == 0 then
			deal(G_DRUG_MP)
		end
	end
	

	if loadFile_open and loadFile_close then
		loadstr1 = loadFile_open
		loadstr2 = loadFile_close
	else
		loadstr1 = "res/component/checkbox/openBtn1.png"
		loadstr2 = "res/component/checkbox/closeBtn1.png"
	end
	local isSkillLeanred = function(skillId)
		for k,v in ipairs(G_ROLE_MAIN.skills)do
			if skillId == v[1] then
				return true
			end
		end
		return false
	end

	

	local switchFunc = function(sender, flag, isTrue)
		--行会指挥者说话时，不可操作声音和声效
        if flag == GAME_SET_ID_CLOSE_MUSIC or flag == GAME_SET_ID_CLOSE_VOICE then
            if getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 and  G_FACTION_INFO.zhihuiID and G_FACTION_INFO.zhihuiID == userInfo.currRoleStaticId then
                TIPS( { type = 1 , str = game.getStrByKey( "chat_voice_set_tips7" ) }  )
                return false
            end
        end
        
        if isTrue ~= nil then
			self.switchs[flag] = isTrue
		else
			self.switchs[flag] = not self.switchs[flag]
		end

		local item = self.switchItems[flag]
		local lab_1 = tolua.cast(item:getChildByTag(10),"cc.Label")
		local lab_2 = tolua.cast(item:getChildByTag(11),"cc.Label")
--[[
		if isSettingSkill(flag) then
			local skillId = getSettingSkillId(flag)

			if type(skillId) == "table" then
				local skillName = ""
				for i,j in pairs(skillId) do
					if isSkillLeanred(j) then
						skillName = ""
						break
					else
						if string.len(skillName) > 1 then
							skillName = skillName .. game.getStrByKey("set_or")
						end
						skillName = skillName .. getConfigItemByKey("SkillCfg", "skillID", j, "name")
					end
				end
				if string.len(skillName) > 1 then
					local tip = string.format(game.getStrByKey("tip_skill_no_learned"), skillName)
				    TIPS({type = 1, str = tip})
				    return false
				end
			elseif isSkillLeanred(skillId) == false and self.switchs[flag] == true then
                local isRealNotLearnSkill = true;
                local tmpSkillId = skillId;

                -------------- µÀÊ¿Ç¿»¯ ÕÙ»½¡¢Ê©¶¾ ÉèÖÃÒª×öÌØÊâ´¦Àí ------------------
                if skillId == 3303 then -- Ç¿»¯Ê©¶¾
                    if isSkillLeanred(3004) == false then
                        tmpSkillId = 3004;
                    else
                        isRealNotLearnSkill = false;
                    end
                elseif skillId == 3012 then   -- Ç¿»¯÷¼÷Ã
                    if isSkillLeanred(3008) == false then
                        tmpSkillId = 3008;
                    else
                        isRealNotLearnSkill = false;
                    end
                end

                if (isRealNotLearnSkill == true) then
				    self.switchs[flag] = false
                
				    local skillName = getConfigItemByKey("SkillCfg", "skillID", tmpSkillId, "name")
				    local tip = string.format(game.getStrByKey("tip_skill_no_learned"), skillName)
				    TIPS({type = 1, str = tip})
				    return false
                end
			end
		end
		]]
		if self.switchs[flag] then
			item:setTexture(loadstr1)
			local specialSwitch = {
				[GAME_SET_ID_AUTO_SUMMON_GW] = function()
					self.switchItems[GAME_SET_ID_AUTO_SUMMON]:setTexture(loadstr2)
					setGameSetById(GAME_SET_ID_AUTO_SUMMON,0)
					self.switchs[GAME_SET_ID_AUTO_SUMMON] = false
				end,
				[GAME_SET_ID_AUTO_SUMMON] = function()
					self.switchItems[GAME_SET_ID_AUTO_SUMMON_GW]:setTexture(loadstr2)
					setGameSetById(GAME_SET_ID_AUTO_SUMMON_GW,0)
					self.switchs[GAME_SET_ID_AUTO_SUMMON_GW] = false
				end,
				[GAME_SET_ID_AUTO_FIRE] = function()
					self.switchItems[GAME_SET_ID_AUTO_DOUBLE_FIRE]:setTexture(loadstr2)
					setGameSetById(GAME_SET_ID_AUTO_DOUBLE_FIRE,0)
					self.switchs[GAME_SET_ID_AUTO_DOUBLE_FIRE] = false
				end,
				[GAME_SET_ID_AUTO_DOUBLE_FIRE] = function()
					self.switchItems[GAME_SET_ID_AUTO_FIRE]:setTexture(loadstr2)
					setGameSetById(GAME_SET_ID_AUTO_FIRE,0)
					self.switchs[GAME_SET_ID_AUTO_FIRE] = false
				end,
				[GAME_SET_ACTIVE_SKILL] = function()
					self.switchItems[GAME_SET_CHOOSE_SKILL]:setTexture(loadstr2)
					setGameSetById(GAME_SET_CHOOSE_SKILL,0)
					self.switchs[GAME_SET_CHOOSE_SKILL] = false					
				end,
				[GAME_SET_CHOOSE_SKILL] = function()
					self.switchItems[GAME_SET_ACTIVE_SKILL]:setTexture(loadstr2)
					setGameSetById(GAME_SET_ACTIVE_SKILL,0)
					self.switchs[GAME_SET_ACTIVE_SKILL] = false					
				end,
			}
			if specialSwitch[flag] then specialSwitch[flag]() end

			-- if switch_label then 
			-- 	switch_label:setString(game.getStrByKey(""))
			-- end
			if lab_1 and lab_2 then
				lab_1:setColor(MColor.lable_yellow)
				lab_2:setColor(MColor.lable_black)
			end
		else
			item:setTexture(loadstr2)
			-- if switch_label then 
			-- 	switch_label:setString(game.getStrByKey("set_close"))
			-- end
			if lab_1 and lab_2 then
				lab_1:setColor(MColor.lable_black)
				lab_2:setColor(MColor.lable_yellow)
			end
		end



		local set_value = 0
		if self.switchs[flag] then set_value = 1 end
		--g_msgHandlerInst:sendNetDataByFmtExEx(GAMECONFIG_CS_CHANGE,"ici",G_ROLE_MAIN.obj_id,flag,set_value)
		setGameSetById(flag,set_value)
		if flag == GAME_SET_SNOWLOTUS and getGameSetById(flag) == 1 and G_MAINSCENE then
			G_MAINSCENE:buyDrug(20023,true)
		end
		return true
	end

	local touchFunc = callback or function(sender) 
		drugSpecial(flag)
		if switchFunc(sender, flag) == false then
			return
		end

		if self.switchs[flag] == true then
			local SettingRelative = getSettingRelative()
			for k,v in pairs(SettingRelative) do
				local record = v
				for k,v in pairs(record) do
					if flag == v then
						dump(record)
						for k,v in pairs(record) do
							if flag ~= v then
								print("switch false v="..v)
								switchFunc(sender, v, false)
							end
						end
					end
				end
			end
		else
			local specialSwitch1 = {
				[GAME_SET_ACTIVE_SKILL] = function()
					self.switchItems[GAME_SET_CHOOSE_SKILL]:setTexture(loadstr1)
					setGameSetById(GAME_SET_CHOOSE_SKILL,1)
					self.switchs[GAME_SET_CHOOSE_SKILL] = true
				end,
				[GAME_SET_CHOOSE_SKILL] = function()					
					self.switchItems[GAME_SET_ACTIVE_SKILL]:setTexture(loadstr1)
					setGameSetById(GAME_SET_ACTIVE_SKILL,1)
					self.switchs[GAME_SET_ACTIVE_SKILL] = true
				end,
			}

			if specialSwitch1[flag] then specialSwitch1[flag]() end

		end
	end
	local node = cc.Node:create()
	node:setPosition(pos)
	local item = createTouchItem(node,loadstr1,cc.p(0,0),touchFunc)
	self.switchItems = self.switchItems or {}
	self.switchItems[flag] = item
--[[
	-- local switch_label = createLabel(item,"",cc.p(170,25),nil,20,nil,nil,nil,MColor.lable_black)
	if not self.switchs[flag] then
		item:setTexture(loadstr2)
		if lab_1 and lab_2 then
			lab_1:setColor(MColor.lable_black)
			lab_2:setColor(MColor.lable_yellow)
		end
		-- switch_label:setString("")
		-- switch_label:setPosition(cc.p(-57,25))
	end
	-- switch_label:setTag(10)
]]
	local position,anc,color,fontSize = cc.p(-25,0),cc.p(0,0.5),MColor.lable_black,18
	local la_1,la_2
	if type(str) == "table" then
		la_1 = createLabel(item,str[1],cc.p(140,28),nil,20,nil,nil,nil,MColor.lable_black,10)
		la_2 = createLabel(item,str[2],cc.p(-38,28),nil,20,nil,nil,nil,MColor.lable_black,11)		
	else
		if indefinePor and #indefinePor > 0 then
			position,anc,color,fontSize = indefinePor[1],indefinePor[2],indefinePor[3],indefinePor[4]
		end
		createLabel(node, str,position,anc, fontSize,nil,nil,nil,color)
	end

	if not self.switchs[flag] then
		item:setTexture(loadstr2)
		if la_1 and la_2 then
			la_1:setColor(MColor.lable_black)
			la_2:setColor(MColor.lable_yellow)
		end
	else
		if la_1 and la_2 then
			la_1:setColor(MColor.lable_yellow)
			la_2:setColor(MColor.lable_black)
		end
	end

	local parent =  self.base_node or parent
	if parent then
		parent:addChild(node)
	end
	return item
end

function BaseLayer:floor(loadfile,rect,pos)
	local bg = cc.Sprite:create(loadfile, rect)
	if bg then
	    bg:setAnchorPoint(cc.p(0.5, 0.5))
	    bg:setPosition(pos)
	    bg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
	    return bg
	end
end

return BaseLayer