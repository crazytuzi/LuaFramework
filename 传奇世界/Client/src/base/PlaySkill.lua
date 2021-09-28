local skill_times = {
		[1000] = {0.35,0},
		[1001] = {0.35,0},
		[1002] = {0.35,0},
		[1003] = {0.35,0.3},
		[1004] = {0.35,0},
		[1005] = {0.05,0},
		[1006] = {0.35,0},
		[1009] = {0.35,0,8,nil,nil,0.6},
		[1010] = {0.2,0},
		[1102] = {0.35,0},
		[2001] = {0,4,6,0.3,0.1,0.2},
		[2002] = {2,0,4,0.3,0,0.3},
		[2003] = {15,0,0,0.5,0,0},
		[2004] = {8,0,0,0.3,0,0},
		[2005] = {10,0,0,0.3,0,0},
		[2007] = {0,0,9,0.3,0,0.5,3,30},
		[2008] = {5,0,11,0.3,0,0.95},
		[2010] = {6,0,14,0.5,0,1.12},
		[2011] = {0,0,19,0.3,0,2},
		[2202] = {9,3,20,0.3,0.3,1.0},
		[3001] = {0,0,19,0.3,0,0.5},
		[3002] = {12,1,9,0.4,0.1,0.8},
		[3003] = {0,0,17,0.25,0,1.2},
		[3004] = {8,0,14,0.35,0,0.84},
		[3005] = {9,0,9,0.3,0,0.3},
		[3006] = {0,1,7,0.25,0.1,0.5},
		[3007] = {0,0,0,0.3,0,0},
		[3008] = {15,0,0,1.0,0,0.3},
		[3009] = {9,0,0,0.3,0,0},
		[3011] = {11,0,10,0.66,0.1,0.5},
		[3012] = {0,0,0,0.3,0,0.3},
		[3303] = {16,6,17,0.5,0.3,1.0},
		[4001] = {0.35},
		[4006] = {0.4,0,0,0,0,0},
		[6000] = {0.5},
		[6001] = {0.65},
		[7000] = {9,0,4,0.4,0.2,0},
		[10001] = {0,0,5,0.3,0,1.0},
		[10005] = {5,0,0,0.8,0.0,0},
		[10006] = {0,0,15,0,0,1.0,1,10},
		[10008] = {7,1,0,1.0,2,0},
		[10009] = {0,0,9,0,0,1.0,5,10},
		[10010] = {0.4,0,0,0,0,0},
		[10012] = {5,0,0,0.8,0,0},
		[10013] = {0.35,0,16,0,0,0.8},
		[10014] = {4,1.5,1,0.6,0.2,0.8,8,10},
		[10015] = {5,0,0,0.8,0,0},
		[10016] = {7,7,7,0.8,0.8,0.8,10},
		[10017] = {0.4,0,5,0,0,0.5},
		[10026] = {0,1,0,0,0.8,0},
		[10027] = {0,1,0,0,0.8,0},
		[10028] = {0,1,0,0,0.8,0},
		[10029] = {0,1,0,0,0.8,0},
		[10030] = {0,1,0,0,0.8,0},
		[10031] = {0,1,0,0,0.8,0},
		[10032] = {0,5,9,0,0.8,1.0},
		[10033] = {0.24,0,12,0,0,0.6},
		[10034] = {0.2,0,11,6,0.5,1.0},
		[10036] = {25,0,0,0.9,0,0},
	}
local add_modes = {
	[1002] = {3},
	[1003] = {0},
	[1004] = {1},
	[1005] = {3},
	[1006] = {0},
	[1009] = {0,0,0},
	[1010] = {3},
	[1102] = {3},
	[2001] = {0,3,3},
	[2002] = {1,3,1},
	[2003] = {3,3,3},
	[2004] = {0,3,3},
	[2005] = {3,3,3},
	[2007] = {0,3,1},
	[2008] = {1,3,1},
	[2010] = {0,0,0},
	[2011] = {1,3,3},
	[2202] = {1,2,1},
	[3001] = {0,3,3},
	[3002] = {1,3,3},
	[3003] = {0,3,2},
	[3004] = {1,3,1},
	[3005] = {0,3,3},
	[3006] = {3,3,1},
	[3007] = {1,1,1},
	[3008] = {1,3,3},
	[3009] = {0,3,3},
	[3011] = {3,3,3},
	[3012] = {0,3,3},
	[3303] = {1,2,1},
	[6000] = {1,3,3},
	[6001] = {3,3,3},
	[10008] = {1,2,1},
	[10010] = {1,1,1},
	[10013] = {1,1,1},
	[10026] = {1,2,1},
	[10033] = {2,2,2},
	[10034] = {2,2,2},
	[10036] = {1,2,1},
}

local attack_frames = {	
	[6000] = {7},
	[10034] = {16},
}

local getaddId = function(skill_id,tag)
	return add_modes[skill_id] and add_modes[skill_id][tag] or 0
end

local getattackframes = function(skill_id,tag)
	return attack_frames[skill_id] and attack_frames[skill_id][tag] or 6
end

local playSkillEffect = function(self,delay,skill_id,role_item,target,d_pos,mofa)
	if not self.skill_item_Node then self.skill_item_Node = MapView:getSkillNode() end
	local start_pos = cc.p(role_item:getPosition())
	local role_id = role_item:getTag()
	local dest_pos = nil
	local target_id = 0
	if target then
		target_id = target:getTag()
		dest_pos = cc.p(target:getPosition()) 
	else 
		local span = 5
		if skill_id == 1009 then span = 1 end
		dest_pos = d_pos or self:getDestPosition(start_pos,span)
	end
	if skill_id == 10035 then skill_id = 2001 end
	--if skill_id == 2002 then skill_id = 2010 end
	local skill_info = getConfigItemByKey("SkillCfg","skillID",skill_id)
	if not skill_info then
		print("not get the skill info:",skill_id)
		return
	end
	local getSkillNode = function(node)
		return node:getSkillNode()
	end
    if (G_MAINSCENE and G_MAINSCENE.map_layer.mapID ~= 2116) or skill_id ~= 2011 or role_item == G_ROLE_MAIN then
	    AudioEnginer.randSkillMusic(skill_id)
    end
	--dump({skill_id,skill_times[skill_id]},"111111111111111111")
	local times = skill_times[skill_id]
	local skill_effect = nil
	local skill_type = tonumber(skill_info.jnxg)
	--print("skill_type",skill_type)
	if skill_type == 1 then
		local skillFunc = function()
			if skill_id == 1005 then
				return
			end
			--local fine_dir_map = {[1002]=true,[1003]=true,[1004]=true,[1005]=true,[1006]=true,[1010]=true,}
			local skill_effect = SpriteBase:create("s"..skill_id)
			if not skill_effect then return end 
			--skill_effect:set5DirMode(true)
	        local order = 12
	        local b_time = times[2] or 0.0
	        local span_pos = cc.p((dest_pos.x-start_pos.x),(dest_pos.y-start_pos.y))
	        local role_dir = role_item:getCurrectDir()
			local dir = getDirBrPos(span_pos,role_dir)
			if role_dir ~= dir then
				role_item:setSpriteDir(dir)
			end
			-- if skill_id == 6000 then 
			-- 	--if dir~=6  then order = 9 end
			-- 	b_time = 0.35
			-- end
			local skill_node = getSkillNode(role_item)
			skill_node:addChild(skill_effect,order,1124)
			local a_num = 6
			if skill_id == 1006 or skill_id == 1004  or skill_id == 6001 then a_num = 8 end

			skill_effect:initStandStatus(4,a_num,1.0,role_item:getCurrectDir())
			local lattackframes = getattackframes(skill_id,1)
			skill_effect:initAttackStatus(lattackframes)
			addEffectWithMode(skill_effect:getMainSprite(),getaddId(skill_id,1))
			
			local actions = {}
			actions[#actions+1] = cc.DelayTime:create(b_time)
			actions[#actions+1] = cc.CallFunc:create(function() 
					local role_item = tolua.cast(role_item,"SpriteMonster")
					if role_item then
						skill_effect:setSpriteDir(dir)
						skill_effect:attackOneTime(times[1],cc.p(0,0))
					end
				end)
			skill_effect:runAction(cc.Sequence:create(actions))
			local removeFunc = function()
				if skill_effect and tolua.cast(skill_effect,"SpriteBase") then
					removeFromParent(skill_effect) 
					skill_effect = nil
				end
			end
			performWithDelay(skill_effect,removeFunc,b_time+times[1]* lattackframes / 3+0.05)

		end
		if skill_id > 1001 and skill_id ~= 1009 then
			skillFunc()
		end

		---------------------------------------------------------

		if times[4] and times[4] > 0 then
			local start_Delay = 1.0

			local removeFunc = function()
				if skill_effect and tolua.cast(skill_effect,"Effects") then
					removeFromParent(skill_effect) 
					skill_effect = nil
				end
			end

			local doDandaoFunc = function()
			end
			local do_dandao = 0
			doDandaoFunc = function()
				local target_item = self:isValidStatus(target_id)
				if skill_id ~= 2003 and target_item then
					dest_pos = cc.p(target_item:getPosition()) 
					dest_pos.y = dest_pos.y + 15
				end
				if do_dandao == 0 then
					removeFunc()
					skill_effect = Effects:create(false)
					local role_item = tolua.cast(role_item,"SpriteMonster")
					if role_item then
						start_pos = cc.p(role_item:getPosition())
					end
					skill_effect:setPosition(start_pos)
					self.skill_item_Node:addChild(skill_effect)
					skill_effect:playActionData(""..skill_id.."/dandao",times[4],times[5],-1)
					addEffectWithMode(skill_effect,getaddId(skill_id,2))
				end
				if skill_effect then
					local start_pos = cc.p(skill_effect:getPosition())
					local distance = cc.pGetDistance(dest_pos,start_pos)
					do_dandao = do_dandao + 1 
					local flytime = distance/(skill_info.flySpeed*do_dandao)
					if distance > 30 then
						if skill_id == 10034 then
							local ro = math.atan2(dest_pos.x-start_pos.x,dest_pos.y-start_pos.y)
							skill_effect:setRotation(ro*180/3.1415926-90)
						end		
						if skill_effect.fly_action then
							skill_effect:stopAction(skill_effect.fly_action)
							skill_effect.fly_action = nil
						end
						skill_effect.fly_action = skill_effect:runAction(cc.MoveTo:create(flytime, dest_pos))
						performWithDelay(skill_effect,doDandaoFunc,0.05)
					else
						performWithDelay(skill_effect,removeFunc,flytime)
					end
				end
			end
			performWithDelay(getSkillNode(role_item),doDandaoFunc,start_Delay)
		end

		---------------------------------------------------------
		if times[3] and times[3] > 0 then
			local hitDelay = 0.2
			if skill_id == 10033 then
				hitDelay = 0.36
			elseif skill_id == 10034 then
				hitDelay = 1.1
			elseif skill_id == 1009 then
				hitDelay = 0.5
			end

			local doHitFunc = function()
				local skill_effect = nil
				local target_item = self:isValidStatus(target_id)
				local removeFunc = function()
					if skill_effect and tolua.cast(skill_effect,"Effects") then
						removeFromParent(skill_effect) 
						skill_effect = nil
					end
				end
				if target_item then
					dest_pos = cc.p(target_item:getPosition()) 
					local span_pos = cc.p((dest_pos.x-start_pos.x),(dest_pos.y-start_pos.y))
					local dir = getDirBrPos(span_pos,role_dir)
					if role_dir ~= dir then
						role_item:setSpriteDir(dir)
					end
					skill_effect = Effects:create(false)
					local skill_node = getSkillNode(target_item)
					skill_node:addChild(skill_effect,200,1124)
					performWithDelay(skill_effect,removeFunc,times[6])
				else
					skill_effect = Effects:create(false)
					skill_effect:setPosition(dest_pos)
					self.skill_item_Node:addChild(skill_effect)
					performWithDelay(skill_effect,removeFunc,times[6])
				end
				
				if skill_effect then
					skill_effect:playActionData(""..skill_id.."/hit",times[3],times[6],1)
					addEffectWithMode(skill_effect,getaddId(skill_id,3))
				end
			end
			performWithDelay(getSkillNode(role_item),doHitFunc,hitDelay)
		end
	elseif skill_type == 2 then
		local skill_node = getSkillNode(role_item)
		if skill_id == 10015 then
			skill_node:setLocalZOrder(-100)
		end

		if skill_info and skill_info.flySpeed and skill_info.flySpeed > 0 then
			local distance = cc.pGetDistance(dest_pos,start_pos)
			skill_times[skill_id][5] = distance/skill_info.flySpeed
			if distance and distance > 400 then
				skill_times[skill_id][5] = 0.0
			end
		end
		local role_dir = role_item:getCurrectDir()
		local span_pos = cc.p((dest_pos.x-start_pos.x),(dest_pos.y-start_pos.y))
		local dir = getDirBrPos(span_pos,role_dir)
		if role_dir ~= dir then
			role_item:setSpriteDir(dir)
		end
		local removeFunc = function()
			if skill_effect and tolua.cast(skill_effect,"Effects") then
				removeFromParent(skill_effect) 
				skill_effect = nil
			end
		end
		local sfunc = function()
			local role_item = tolua.cast(role_item,"SpriteMonster")
			if role_item then
				if skill_info.needStartHand == 1 and times[4] > 0 then
					skill_effect = Effects:create(false)
			        local order = 12
			        if skill_id == 3002 then
			        	order = 9
			        end
			        local skill_node = getSkillNode(role_item)
					skill_node:addChild(skill_effect,order,1124)
					-- if skill_id == 2008 then
					-- 	skill_effect:setPosition(cc.p(0,-50))
					-- end
					if skill_id == 10015 then
						skill_effect:setScale(2)
					end

					if times[1] > 0 then
						skill_effect:playActionData(""..skill_id.."/shifa",times[1],times[4],1)
					end
					if skill_id == 10008 then
						addEffectWithMode(skill_effect,2)
					elseif skill_id == 10015 then
						addEffectWithMode(skill_effect,4)
					else
						addEffectWithMode(skill_effect,getaddId(skill_id,1))
					end
				end
			end
		end
		local start_Delay = 0.2
		if skill_id == 2003 then 
			dest_pos = start_pos
			start_Delay = 0.3
		elseif skill_id == 2005 then
			start_Delay = 0.1
		elseif skill_id == 10008 then
			start_Delay = 0.0
		end
		performWithDelay(self.skill_item_Node,sfunc,start_Delay)
			dump(times,"111111111111111111111")
			if times[2] > 0 or times[3] > 0 then
				local doHitFunc = function()
					removeFunc()
					local target_item = self:isValidStatus(target_id)
					if skill_id ~= 2003 and times[3] > 0 then
						if target_item then
							dest_pos = cc.p(target_item:getPosition()) 
							local span_pos = cc.p((dest_pos.x-start_pos.x),(dest_pos.y-start_pos.y))
							local dir = getDirBrPos(span_pos,role_dir)
							if role_dir ~= dir then
								local role_item = tolua.cast(role_item,"SpriteMonster")
								if role_item then
									role_item:setSpriteDir(dir)
								end
							end
							skill_effect = Effects:create(false)
							local skill_node = getSkillNode(target_item)
							skill_node:addChild(skill_effect,200,1124)
							performWithDelay(skill_effect,removeFunc,times[6])
						else
							skill_effect = Effects:create(false)
							skill_effect:setPosition(dest_pos)
							self.skill_item_Node:addChild(skill_effect)
							performWithDelay(skill_effect,removeFunc,times[6])
						end
					end
					if skill_effect then
						skill_effect:playActionData(""..skill_id.."/hit",times[3],times[6],1)
						addEffectWithMode(skill_effect,getaddId(skill_id,3))
					end
				end
				if times[2] > 0 then
					local doDandaoFunc = function()
					end
					local do_dandao = 0
					doDandaoFunc = function()
						local target_item = self:isValidStatus(target_id)
						if skill_id ~= 2003 and target_item then
							dest_pos = cc.p(target_item:getPosition()) 
							dest_pos.y = dest_pos.y + 15
						end
						if do_dandao == 0 then
							removeFunc()
							skill_effect = Effects:create(false)
							local role_item = tolua.cast(role_item,"SpriteMonster")
							if role_item then
								start_pos = cc.p(role_item:getPosition())
							end
							skill_effect:setPosition(start_pos)
							self.skill_item_Node:addChild(skill_effect)
							skill_effect:playActionData(""..skill_id.."/dandao",times[2],times[5],-1)
							addEffectWithMode(skill_effect,getaddId(skill_id,2))
						end
						if skill_effect then
							local start_pos = cc.p(skill_effect:getPosition())
							local distance = cc.pGetDistance(dest_pos,start_pos)
							do_dandao = do_dandao + 1 
							local flytime = distance/(skill_info.flySpeed*do_dandao)
							if distance > 30 then
								if skill_id == 3002 or skill_id == 2001 or skill_id == 2202 or skill_id == 3011 or skill_id == 3006 or skill_id == 3303 or skill_id == 10008 or (skill_id >= 10026 and skill_id <= 10035) then
									local ro = math.atan2(dest_pos.x-start_pos.x,dest_pos.y-start_pos.y)
									skill_effect:setRotation(ro*180/3.1415926-90)
								end		
								if skill_effect.fly_action then
									skill_effect:stopAction(skill_effect.fly_action)
									skill_effect.fly_action = nil
								end
								skill_effect.fly_action = skill_effect:runAction(cc.MoveTo:create(flytime, dest_pos))
								performWithDelay(skill_effect,doDandaoFunc,0.05)
							else
								performWithDelay(skill_effect,doHitFunc,flytime)
							end
						else
							performWithDelay(getSkillNode(role_item),doHitFunc,flytime)
						end
					end
					performWithDelay(getSkillNode(role_item),doDandaoFunc,times[4]+start_Delay)
				else
					if skill_id == 2010 then
						doHitFunc()
					else
						performWithDelay(getSkillNode(role_item),doHitFunc,times[4]+start_Delay)
					end
				end
			else
				performWithDelay(getSkillNode(role_item),removeFunc,times[4]+start_Delay)
			end
	elseif skill_type == 3 then
		if self.isStory then

			if self:isBlock(self:space2Tile(dest_pos)) then
				return
			end

			local effRange = 1
			if skill_info.effectRangeType ~= nil then
				local skill_rangetype = tonumber(skill_info.effectRangeType)
				if skill_rangetype == 5 then
					effRange = 2
				elseif skill_rangetype == 6 then
					effRange = 2
				elseif skill_rangetype == 7 then
					effRange = 4
				end
			end

			local removeFunc = function()
				if skill_effect and tolua.cast(skill_effect,"Effects") then
					removeFromParent(skill_effect) 
					skill_effect = nil
				end
			end
			local doHitFunc = function()
				removeFunc()
				if skill_id	== 2011 then
                    if role_item == G_ROLE_MAIN then
					    G_MAINSCENE.storyNode:onSkillSend(skill_id,nil,self:space2Tile(dest_pos))
                    end
                    
                    skill_effect = Effects:create(false)
					skill_effect:setPosition(dest_pos)
					self.item_Node:addChild(skill_effect)
					skill_effect:setRenderMode(2)
					skill_effect:setPlistNum(2)

					local actions = {}
					local c_ani_begin = skill_effect:createEffect2(""..skill_id.."/dandao",60)
					c_ani_begin:setLoops(1)	
					actions[#actions+1] = cc.Animate:create(c_ani_begin)

					local c_ani_loop = skill_effect:createEffect2(""..skill_id.."/hit",90)
					c_ani_loop:setLoops(5)
					actions[#actions+1] = cc.Animate:create(c_ani_loop)

					actions[#actions+1] = cc.RemoveSelf:create()

					skill_effect:runAction(cc.Sequence:create(actions))
				else
					local repeatCount = effRange + 1
					if skill_id == 10006 then repeatCount = 1 end
					if repeatCount < 1 then repeatCount = 1 end
					if repeatCount > 30 then repeatCount = 30 end

					local offsetX = 48
					local offsetY = 32
					local startX = -offsetX * math.floor(repeatCount / 2)
					local startY = -offsetY * math.floor(repeatCount / 2)
					local effectX = startX
					local effectY = startY
					for x = 1, repeatCount do

						effectY = startY

						for y = 1, repeatCount do

							local chlid_eff = Effects:create(false)
							chlid_eff:setPosition(start_pos)
							chlid_eff:setVisible(false)
							local dest_tile = self:space2Tile(effectX+dest_pos.x, effectY+dest_pos.y)
							local color = cc.c3b(255, 255, 255)
							if self:isBlock(dest_tile) or self:isOpacity(dest_tile) then
								color = cc.c3b(100, 100, 100)
							end 
							local c_animation = chlid_eff:createEffect(""..skill_id.."/hit",times[3],times[6])
							if skill_id == 10006 then
								addEffectWithMode(chlid_eff,3)
							elseif skill_id == 10016 then
								addEffectWithMode(chlid_eff,4)
							else
								addEffectWithMode(chlid_eff,1)
							end
							c_animation:setLoops(times[8])
							self.item_Node:addChild(chlid_eff,6)
							local actions = {}
							--actions[#actions+1] = cc.DelayTime:create(times[4]+0.12)
							actions[#actions+1] = cc.MoveTo:create(times[5],dest_pos)
							actions[#actions+1] = cc.MoveBy:create(0,cc.p(effectX, effectY))
							actions[#actions+1] = cc.Show:create()
							actions[#actions+1] = cc.CallFunc:create(function()
							chlid_eff:setColor(color) end)
							actions[#actions+1] = cc.Animate:create(c_animation)
							actions[#actions+1] = cc.CallFunc:create(function()
							chlid_eff = tolua.cast(chlid_eff,"Effects")
							if chlid_eff then
								removeFromParent(chlid_eff)
								chlid_eff = nil
								end
							end)
							chlid_eff:runAction(cc.Sequence:create(actions))
							effectY = effectY + offsetY

						end

						effectX = effectX + offsetX
					end
				end
			end
			if skill_info.needStartHand == 1 and times[4] > 0 then
				skill_effect = Effects:create(false)
				local skill_node = getSkillNode(role_item)
				skill_node:addChild(skill_effect,200,1124)
				if times[1] > 0 then
					skill_effect:playActionData(""..skill_id.."/shifa",times[1],times[4],1)
				end
				--if (skill_id < 3000 and skill_id ~= 2003) or skill_id == 3003 then
					addEffectWithMode(skill_effect,3)
				--end
				performWithDelay(skill_effect,doHitFunc,times[4])
			else
				doHitFunc()
			end
		end
	elseif skill_type == 4 then
		local skillFunc = function()
			local role_item = self:isValidStatus(role_id)
			if role_item and times then
				local skill_effect = Effects:create(false)
				log("[PlaySkillEffect] called. skilltype = 4. skill_id = %d, times[1] = %f, times[2] = %f, times[3] = %d.", skill_id, times[1], times[2], times[3])
				skill_effect:playActionData("skill"..skill_id.."/begin", times[1], times[2], times[3])
				addEffectWithMode(skill_effect,getaddId(skill_id,1))
		        local skill_node = getSkillNode(role_item)
				skill_node:addChild(skill_effect, 100, 1124)
				local removeFunc = function()
					if skill_effect and tolua.cast(skill_effect,"Effects") then
						removeFromParent(skill_effect) 
						skill_effect = nil
					end
				end
				local dur = times[2] * times[3]
				performWithDelay(skill_effect, removeFunc, dur)
			end
		end
		performWithDelay(self.skill_item_Node,skillFunc,0.35)
	elseif skill_type == 5 then
		local effect_count = times[7]
		local effect_range = times[8]

		local centerTile = self:space2Tile(start_pos)
		local cornerTile = cc.p(0, 0)
		cornerTile.x = centerTile.x + effect_range
		cornerTile.y = centerTile.y + effect_range
		local cornerPos = self:tile2Space(cornerTile)
		local distX = math.abs(cornerPos.x - start_pos.x)
		local distY = math.abs(cornerPos.y - start_pos.y)

		local svc = 0

		for i = 1, effect_count do
			local skill_effect = Effects:create(false)
			local subeffect = skill_effect:createEffect(""..skill_id.."/hit", times[1], times[4])
			subeffect:setLoops(1)
			addEffectWithMode(skill_effect,2)
			math.randomseed(os.time()+svc)
			math.random()

			local posX = math.random(-distX, distX)
			local posY = math.random(-distY, distY)

			svc = posX + posY

			self:addChild(skill_effect,667)

			local centerPos = cc.p(0, 0)
			centerPos.x = start_pos.x - 132 + posX
			centerPos.y = start_pos.y + 132 + posY

			skill_effect:setPosition(centerPos)

			local actions = {}
			actions[#actions+1] = cc.DelayTime:create(0.4*(i-1))
	--		actions[#actions+1] = cc.CallFunc:create(function() --local pos = self:convertToNodeSpace(poss[i%5+1])
	--		skill_effect:setPosition(cc.p(posX, posY)) end)
			actions[#actions+1] = cc.Animate:create(subeffect)
			actions[#actions+1] = cc.CallFunc:create(function() skill_effect:setLocalZOrder(200) end)
			actions[#actions+1] = cc.DelayTime:create(0.0)
			actions[#actions+1] = cc.CallFunc:create(function() 
					skill_effect = tolua.cast(skill_effect,"Effects")
					if skill_effect then
						removeFromParent(skill_effect) 
						skill_effect = nil
					end 
				end)
			skill_effect:runAction(cc.Sequence:create(actions))
			local actions = {}
			actions[#actions+1] = cc.DelayTime:create(0.08*i)
		--	actions[#actions+1] = cc.MoveBy:create(times[5],cc.p(0,-600))
			skill_effect:runAction(cc.Sequence:create(actions))
		end
		AudioEnginer.randSkillMusic(skill_id)
	elseif skill_type == 6 then

		local delayBeginAdd = 0.1
		local delayLoopAdd = delayBeginAdd + times[4] - 0.1
		local delayEndAdd = delayLoopAdd + times[5]*times[7] -0.1

		local addFuncBegin = nil
		local addFuncLoop = nil
		local addFuncEnd = nil

		local skill_effect_begin = nil
		local skill_effect_loop = nil
		local skill_effect_end = nil

		local skill_node = getSkillNode(role_item)
		if skill_id == 10016 then
			skill_node:setLocalZOrder(-100)
		end

		local stepFuncBegin = function()
			if times[1] > 0 then
				skill_effect_begin = Effects:create(false)
				skill_node:addChild(skill_effect_begin, 0, 1124)
			--	skill_effect_begin:setPosition(dest_pos)
				skill_effect_begin:playActionData(""..skill_id.."/begin", times[1], times[4], 1)
			end
		end

		local stepFuncLoop = function()
			if times[2] > 0 then
				skill_effect_loop = Effects:create(false)
				skill_node:addChild(skill_effect_loop, 0, 1124)
			--	skill_effect_loop:setPosition(dest_pos)
				skill_effect_loop:playActionData(""..skill_id.."/loop", times[2], times[5], times[7])
				skill_effect_loop:setVisible(false)
			end
		end
		local stepFuncLoop2 = function()
			if skill_effect_begin and tolua.cast(skill_effect_begin, "Effects") then
				skill_effect_begin:setVisible(false)
				removeFromParent(skill_effect_begin) 
				skill_effect_begin = nil
			end

			if skill_effect_loop then
				skill_effect_loop:setVisible(true)
			end
		end


		local stepFuncEnd = function()
			if times[3] > 0 then
				skill_effect_end = Effects:create(false)
				skill_node:addChild(skill_effect_end, 0, 1124)
			--	skill_effect_end:setPosition(dest_pos)
				skill_effect_end:playActionData(""..skill_id.."/end", times[3], times[6], 1)
				skill_effect_end:setVisible(false)
			end
		end
		local stepFuncEnd2 = function()
			if skill_effect_loop and tolua.cast(skill_effect_loop, "Effects") then
				skill_effect_loop:setVisible(true)
				removeFromParent(skill_effect_loop)
				skill_effect_loop = nil
			end

			if skill_effect_end then
				skill_effect_end:setVisible(true)
			end
		end

		local stepFuncEndAll = function()
			if skill_effect_end and tolua.cast(skill_effect_end, "Effects") then
				removeFromParent(skill_effect_end) 
				skill_effect_end = nil
			end
		end

		performWithDelay(skill_node, stepFuncBegin, delayBeginAdd)
		performWithDelay(skill_node, stepFuncLoop, delayLoopAdd)
		performWithDelay(skill_node, stepFuncLoop2, delayLoopAdd+0.05)
		performWithDelay(skill_node, stepFuncEnd, delayEndAdd)
		performWithDelay(skill_node, stepFuncEnd2, delayEndAdd+0.05)
		performWithDelay(skill_node, stepFuncEndAll, delayEndAdd+times[6])

	elseif skill_type == 7 then		-- draw under scene

		local pos_target = start_pos

		local removeFunc = function()
			if skill_effect and tolua.cast(skill_effect,"Effects") then
				removeFromParent(skill_effect) 
				skill_effect = nil
			end
		end

		local role_item = tolua.cast(role_item,"SpriteMonster")
		if role_item then
			if skill_info.needStartHand == 1 and times[1] and times[4] then
				skill_effect = Effects:create(false)
				skill_effect:setPosition(pos_target)
				self.skill_item_Node:addChild(skill_effect)
				if times[1] > 0 then
					skill_effect:playActionData(""..skill_id.."/shifa",times[1],times[4],1)					
				end
				addEffectWithMode(skill_effect,getaddId(skill_id,1))
			end
		end

		performWithDelay(self.skill_item_Node, removeFunc, times[4])

	elseif skill_id	== 7000 then
		local span_x = (g_scrSize.width-960)/2
		local poss = {cc.p(0+span_x,900),cc.p(200+span_x,1260),cc.p(400+span_x,1032),cc.p(600+span_x,1132),cc.p(800+span_x,1032)}

		for i=1,15 do
			local chlid_eff = Effects:create(false)
			local c_a1 = chlid_eff:createEffect("s_7000",times[1],times[4])
			--c_a1:setLoops(2)
			--local c_a2 = chlid_eff:createEffect(""..skill_id.."/hit",times[3],times[6])
			--c_a2:setLoops(1)
			self:addChild(chlid_eff,666)
			local actions = {}
			actions[#actions+1] = cc.DelayTime:create(0.08*i)
			actions[#actions+1] = cc.CallFunc:create(function() local pos = self:convertToNodeSpace(poss[i%5+1])
			chlid_eff:setPosition(cc.p(pos.x-math.random(-50,50),pos.y-math.random(-250,50))) end)
			actions[#actions+1] = cc.Animate:create(c_a1)
			--actions[#actions+1] = cc.Animate:create(c_a2)
			--actions[#actions+1] = cc.MoveBy:create(0.0,cc.p(0,-60))
			actions[#actions+1] = cc.CallFunc:create(function() chlid_eff:setLocalZOrder(0) end)
			actions[#actions+1] = cc.DelayTime:create(0.0)
			actions[#actions+1] = cc.CallFunc:create(function() 
					chlid_eff = tolua.cast(chlid_eff,"Effects")
					if chlid_eff then
						removeFromParent(chlid_eff) 
						chlid_eff = nil
					end 
				end)
			chlid_eff:runAction(cc.Sequence:create(actions))
			local actions = {}
			actions[#actions+1] = cc.DelayTime:create(0.08*i)
			actions[#actions+1] = cc.MoveBy:create(times[5],cc.p(0,-600))
			chlid_eff:runAction(cc.Sequence:create(actions))
		end
		AudioEnginer.randSkillMusic(skill_id,true)
		earthQuake(0.1,0.8)
	elseif skill_id >= 6005 and skill_id <= 6007 then
		local skillFunc = function()
			local role_item = self:isValidStatus(role_id)
			if role_item then
				local skill_effect = Effects:create(false)
				if skill_id == 6007 then skill_effect:setScale(2) end
				skill_effect:playActionData("skill"..skill_id.."/begin" , 5 , 0.5 , 1 )
				local skill_node = getSkillNode(role_item)
				skill_node:addChild(skill_effect, 100, 1124)
				local removeFunc = function()
					if skill_effect and tolua.cast(skill_effect,"Effects") then
						removeFromParent(skill_effect) 
						skill_effect = nil
					end
				end
				performWithDelay(skill_effect,removeFunc,0.5)
			end
		end
		performWithDelay(self.skill_item_Node,skillFunc,0.35)
	end
end

return playSkillEffect