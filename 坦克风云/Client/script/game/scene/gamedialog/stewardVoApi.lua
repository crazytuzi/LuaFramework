stewardVoApi={
	openLevel=30, --开启等级
	swData  = {},--超武
	expData = {},--远征
	expRewardTb = {},--远征奖励表

	needZeroTime = G_getWeeTs(base.serverTime) + 86400,
	isSocketExp = false
}

--军务管家是否开启
function stewardVoApi:isOpen()
	if base.stewardSwitch==0 then
		do return false end
	end
	if playerVoApi:getPlayerLevel()>=self.openLevel then
		return true
	end
	return false
end

function stewardVoApi:getTabOneData(layerNum)
	return {
		{
			key = "s1", 
			name = getlocal("armorMatrix"), 
			icon = "freeLArmorTip.png", 
			isOpen = armorMatrixVoApi:isOpen(), 
			descTb = { getlocal("normal"), getlocal("daily_lotto_tip_6") },
			freeTb = armorMatrixVoApi:getFreeData(), 
			jumpTo = function()
				local function showCallback()
                    armorMatrixVoApi:showArmorMatrixDialog(layerNum+1)
					armorMatrixVoApi:showRecruitDialog(layerNum+2)
                end
                armorMatrixVoApi:armorGetData(showCallback)
			end 
		},

		{
			key = "s2", 
			name = getlocal("recruitTitle"), 
			icon = "recruitIcon.png", 
			isOpen = heroVoApi:isOpenHeroRecruit(), 
			descTb = { getlocal("normal"), getlocal("steward_crack") }, 
			freeTb = heroVoApi:getFreeData(), 
			jumpTo = function()
		    	require "luascript/script/game/scene/gamedialog/heroDialog/heroRecruitDialog"
		    	local td=heroRecruitDialog:new(layerNum+1)
		    	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("recruitTitle"),true,layerNum+1)
		    	sceneGame:addChild(dialog,layerNum+1)
			end 
		},

		{
			key = "s3", 
			name = getlocal("equip_lab_title"), 
			icon = "heroEquipIcon.png", 
			isOpen = heroEquipVoApi:isOpen(), 
			descTb = { getlocal("steward_equip_study") }, 
			freeTb = heroEquipVoApi:getFreeData(), 
			jumpTo = function()
				local function openEquipLab( ... )
		            heroEquipVoApi:openEquipLabDialog(layerNum+1)
		        end
		        local function callbackHandler4(fn,data)
		            openEquipLab()
		        end
		        if heroEquipVoApi and heroEquipVoApi.ifNeedSendRequest==true then
		            heroEquipVoApi:equipGet(callbackHandler4)
		        else
		            openEquipLab()
		        end
			end 
		},

		{
			key = "s4", 
			name = getlocal("emblem_btn_get"), 
			icon = "freeLEmblemTip.png", 
			isOpen = emblemVoApi:isOpen(), 
			descTb = { getlocal("emblem_draw_gold") }, 
			freeTb = emblemVoApi:getFreeData(), 
			jumpTo = function()
				emblemVoApi:showMainDialog(layerNum+1)
				emblemVoApi:showGetDialog(layerNum+2)
			end
		},

		{
			key = "s5", 
			name = getlocal("skill_lottery"), 
			icon = "freeLPlaneSkillTip.png", 
			isOpen = planeVoApi:isOpen(), 
			descTb = { getlocal("emblem_draw_gold") }, 
			freeTb = planeVoApi:getFreeData(), 
			jumpTo = function()
				planeVoApi:showMainDialog(layerNum+1,nil,nil,"get",nil)
			end
		},

		{
			key = "s6",
			name = getlocal("emblem_btn_get"),
			icon = "freeLEmblemTip.png",
			isOpen = emblemVoApi:isOpen(),
			descTb = { getlocal("emblem_draw_r5") },
			freeTb = emblemVoApi:getR5BuyNum(),
			isCheckBox = true,
			jumpTo = function()
				emblemVoApi:showMainDialog(layerNum+1)
				emblemVoApi:showGetDialog(layerNum+2)
			end
		},

		{
			key = "s7",
			name = getlocal("skill_lottery"),
			icon = "freeLPlaneSkillTip.png",
			isOpen = planeVoApi:isOpen(),
			descTb = { getlocal("emblem_draw_r5") },
			freeTb = planeVoApi:getR5BuyNum(),
			isCheckBox = true,
			jumpTo = function()
				planeVoApi:showMainDialog(layerNum+1,nil,nil,"get",nil)
			end
		},
	}
end

function stewardVoApi:getTabThreeData(layerNum)
	return {
		{
			name = getlocal("alliance_duplicate"), 
			icon = "mainBtnCheckpoint_Down.png", 
			iconBg = "Icon_BG.png", 
			isOpen = function()
				if base.isAllianceSwitch==0 then
					return false
				end
				if allianceVoApi:isHasAlliance()==true then
					return true
				end
				return false
			end, 
			descTb = { getlocal("steward_attack_num") }, 
			freeTb = function()
				local fubenVo=allianceFubenVoApi:getFuben()
				local attackCount=fubenVo.attackCount or 0
				local attackMaxNum=allianceFubenVoApi:getDailyAttackNum()
				-- return { {attackCount,attackMaxNum} }
				return { {(attackMaxNum-attackCount)} }
			end, 
			jumpTo = function()
				local td=allianceFuDialog:new(layerNum+1)
			    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_duplicate"),true,layerNum+1)
			    sceneGame:addChild(dialog,layerNum+1)
			end
		},

		{
			name = getlocal("raids_open_tip"), 
			icon = "tech_fight_exp_up.png", 
			isOpen = true, 
			descTb = { getlocal("sample_prop_name_3326") }, 
			freeTb = function()
				local pid="p3326"
				local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
				local hasNum=bagVoApi:getItemNumId(id)
				return { {hasNum} }
			end, 
			jumpTo = function()
				storyScene:setShow()
			end
		},

		{
			name = getlocal("arena_title"), 
			icon = "arenaIcon.png", 
			isOpen = function()
				if base.ifMilitaryOpen==0 then
					return false
				end
				local limitLv=10
    			if playerVoApi:getPlayerLevel()>=limitLv then
    				return true
    			end
    			return false
			end, 
			descTb = { getlocal("steward_challenge_num") }, 
			freeTb = { {(arenaVoApi:getAttack_num()-arenaVoApi:getAttack_count())} }, 
			jumpTo = function()
				G_openArenaDialog(layerNum+1)
			end
		},

		{
			name = getlocal("equip_explore_title"), 
			icon = "heroEquipLabIcon.png", 
			isOpen = heroEquipVoApi:isOpen(), 
			descTb = { getlocal("energy") }, 
			freeTb = { {playerVoApi:getEnergy(), checkPointVoApi:getMaxEnergy()} }, 
			jumpTo = function()
				heroEquipChallengeVoApi:openExploreDialog(nil,nil,layerNum+1)
			end
		},

		{
			name = getlocal("steward_fragment_loot"), 
			icon = "sw_3.png", 
			isOpen = function()
				local challengeVo=superWeaponVoApi:getSWChallenge()
				if challengeVo.maxClearPos>0 then
					return true
				end
				return false
			end, 
			descTb = { getlocal("super_weapon_rob_food") }, 
			freeTb = function()
				local maxNum=weaponrobCfg.energyMax
				local energyNum,nextTime=superWeaponVoApi:setCurEnergy()
				return { {energyNum, maxNum} }
			end, 
			jumpTo = function()
				superWeaponVoApi:showRobDialog(layerNum+1)
			end
		},
	}
end

function stewardVoApi:getStewardData(layerNum,tabIndex)
	local tvData=nil
	if tabIndex==1 then
		tvData=self:getTabOneData(layerNum)
	elseif tabIndex==3 then
		tvData=self:getTabThreeData(layerNum)
	end
	if tvData then
		local data=nil
		for k, v in pairs(tvData) do
			-- if (type(v.isOpen)=="function" and v.isOpen()==false) or v.isOpen==false then
			-- 	table.remove(tvData,k)
			if (type(v.isOpen)=="function" and v.isOpen()==true) or v.isOpen==true then
				if data==nil then
					data={}
				end
				if type(v.freeTb)=="function" then
					v.freeTb=v.freeTb()
				end
				table.insert(data,v)
			end
		end
		if data then
			return data
		end
	end
	return {}
end

function stewardVoApi:isShowRedPoint(tabIndex)
	if tabIndex==2 then
		if self.allCanSweeping and self:allCanSweeping()==true then
			return true
		end
	else
		local tvData=self:getStewardData(nil,tabIndex)
		if tabIndex==1 then
			for k, v in pairs(tvData) do
				if v.freeTb then
					for m, n in pairs(v.freeTb) do
						if n[1]>0 then --只要有免费次数就显示红点
							if v.isCheckBox == true then
								if self:getCheckBoxState(v.key) == 1 and type(n[4]) == "number" and playerVoApi:getGold() >= n[4] then
									return true
								end
							else
								return true
							end
						end
					end
				end
			end
		end
	end
	return false
end

function stewardVoApi:getStewardIconState()
	if self:isShowRedPoint(1)==true or self:isShowRedPoint(2)==true then
		return true
	end
	return false
end

function stewardVoApi:lottery(tvData,callback)
	local _rData={}
	local checkBoxStates = nil
	for k, v in pairs(tvData) do
		if v.isCheckBox == true then
			if checkBoxStates == nil then
				checkBoxStates = {}
			end
			checkBoxStates[#checkBoxStates + 1] = (self:getCheckBoxState(v.key) or 0)
		else
			for m, n in pairs(v.freeTb) do
				if n and type(n[1])=="number" and n[1]>0 then
					table.insert(_rData,v)
					do break end
				end
			end
		end
	end
	local function get_rData(_key)
		for k, v in pairs(_rData) do
			if v.key==_key then
				return v
			end
		end
		for k, v in pairs(tvData) do
			if v.key == _key then
				return v
			end
		end
	end
	local function addReward(_key,_reward,_stringTb)
		local isAddSuccess = false
		for k, v in pairs(_rData) do
			if v.key==_key then
				v.reward=_reward
				v.stringTb=_stringTb
				isAddSuccess = true
				do break end
			end
		end
		if isAddSuccess == false then
			for k, v in pairs(tvData) do
				if v.key == _key then
					table.insert(_rData, v)
					do break end
				end
			end
			for k, v in pairs(_rData) do
				if v.key==_key then
					v.reward=_reward
					v.stringTb=_stringTb
					do break end
				end
			end
		end
	end
	local oldHeroList = heroVoApi:getHeroList()
	local function socketCallback(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data then

				--@装甲矩阵
				if sData.data.armor then
					if not armorMatrixVoApi.armorMatrixInfo then
						require "luascript/script/game/gamemodel/armorMatrix/armorMatrixInfoVo"
						armorMatrixVoApi.armorMatrixInfo=armorMatrixInfoVo:new()
					end
					armorMatrixVoApi.armorMatrixInfo:initWithData(sData.data.armor)
				end
				local s1Data = get_rData("s1")
				if sData.data.amreport then
					local armorReward = {}
					for k,v in pairs(sData.data.amreport) do
						local rewardItem=FormatItem(v)
						G_addPlayerAward(rewardItem[1].type,rewardItem[1].key,rewardItem[1].id,rewardItem[1].num)
						table.insert(armorReward,rewardItem[1])
						-- if rewardItem[1].type=="am" and rewardItem[1].key~="exp" then
						-- 	local cfg=armorMatrixVoApi:getCfgByMid(rewardItem[1].key)
						-- 	if cfg.quality>=4 then
						-- 		local paramTab={}
						-- 		paramTab.functionStr="armor"
						-- 		paramTab.addStr="i_also_want"
						-- 		local message={key="armorMatrix_chatMessage1",param={playerVoApi:getPlayerName(),getlocal("armorMatrix_color_" .. cfg.quality),rewardItem[1].name}}
						-- 		chatVoApi:sendSystemMessage(message,paramTab)
						-- 	end
						-- end
					end
					local stringTb=nil
					local _freeTb=armorMatrixVoApi:getFreeData()
					local _newNum=0
					for k, v in pairs(_freeTb) do
						_newNum=_newNum+v[1]
					end
					if _newNum>0 then
						stringTb={ {getlocal("steward_armor_tip",{_newNum}),G_ColorRed} }
					end
					if base.hexieMode==1 and s1Data then
						for k, v in pairs(s1Data.freeTb) do
							local _useNum=v[1]-_freeTb[k][1]
							if _useNum>0 then
				                local award=FormatItem(armorCfg["mustReward"..k].reward)
				                for k,v in pairs(award) do
				                    v.num=v.num*_useNum
				                    G_addPlayerAward(v.type,v.key,v.id,v.num)
				                    table.insert(armorReward,v)
				                end
				                -- G_showRewardTip(award, true)
			            	end
		            	end
		            end
					addReward("s1",armorReward,stringTb)
				elseif s1Data and armorMatrixVoApi:isFull()==true then
					local _freeNum=0
					for k, v in pairs(s1Data.freeTb) do
						_freeNum=_freeNum+v[1]
					end
					if _freeNum>0 then
						local stringTb={ {getlocal("steward_armor_tip",{_freeNum}),G_ColorRed} }
						addReward("s1",nil,stringTb)
					end
				end

				--@将领招募
				-- if sData.data.hero then  --在base.lua中自动处理过该字段
				-- end
				if sData.data.hreport then
					local heroReward = {}
					local stringTb = nil
					for k, v in pairs(sData.data.hreport) do
						local rewardItem=FormatItem(v)[1]

						if rewardItem.type=="h" then
			                local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(rewardItem,oldHeroList)
			                -- G_recruitShowHero(type,award,self.layerNum+1,heroIsExist,addNum,nil,newProductOrder)

			                if rewardItem.eType=="h" and heroIsExist==false then
			                	local vo = heroVo:new()
                                vo.hid=rewardItem.key
                                vo.level=1
                                vo.points=0
                                vo.productOrder=rewardItem.num
                                vo.skill={}
                                table.insert(oldHeroList,vo)
			                    heroVoApi:getNewHeroChat(rewardItem.key)
			                end

			                if heroVoApi:heroHonorIsOpen()==true then
			                    local hid
			                    if rewardItem.eType=="h" then 
			                        hid=rewardItem.key
			                    elseif rewardItem.eType=="s" then
			                        hid=heroCfg.soul2hero[rewardItem.key]
			                    end 
			                    if hid and heroVoApi:getIsHonored(hid)==true then
			                        local pid=heroCfg.getSkillItem
			                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
			                        bagVoApi:addBag(id,addNum)
			                    end
			                end

			                if addNum and addNum>0 then
			                    local hid
			                    if rewardItem.type=="h" then
			                        if rewardItem.eType=="h" then
			                            hid=rewardItem.key
			                        elseif rewardItem.eType=="s" then
			                            hid=heroCfg.soul2hero[rewardItem.key]
			                        end
			                    end
			                    local existStr
			                    if hid and heroVoApi:getIsHonored(hid)==true and heroVoApi:heroHonorIsOpen()==true then
			                        existStr=getlocal("steward_hero_recruit_1",{rewardItem.name,addNum})
			                    elseif type==1 and heroIsExist==true then
			                        if newProductOrder then
			                            existStr=getlocal("steward_hero_recruit_2",{rewardItem.name,newProductOrder})
			                        else
			                            existStr=getlocal("steward_hero_recruit_3",{rewardItem.name,addNum})
			                        end
			                    end
			                    if existStr then
			                    	if stringTb==nil then
			                    		stringTb={}
			                    	end
			                    	table.insert(stringTb,{existStr,G_ColorYellowPro})
			                    end
			                end

			            else
			                G_addPlayerAward(rewardItem.type,rewardItem.key,rewardItem.id,rewardItem.num,false,true)
			                -- G_recruitShowHero(3,award,self.layerNum+1,nil,nil,nil)
			            end

			            table.insert(heroReward,rewardItem)
					end

					local s2Data = get_rData("s2") --高级招募才有和谐模式
					if s2Data and type(s2Data.freeTb)=="table" and SizeOfTable(s2Data.freeTb)>1 and s2Data.freeTb[2][1]>0 then
						if(base.hexieMode==1)then
                            local award=FormatItem(heroCfg.mustReward1.reward)
                            for k,v in pairs(award) do
                                G_addPlayerAward(v.type,v.key,v.id,v.num)
                                table.insert(heroReward,v)
                            end
                            -- G_showRewardTip(award, true)
                        end
					end
					addReward("s2",heroReward,stringTb)
				end

				--@装备研究所
				if sData.data.equip then
					heroEquipVoApi:formatData(sData.data.equip)
				end
				if sData.data.hereport then
					local getid = tonumber(heroEquipAwakeShopCfg.buyitem) or tonumber(RemoveFirstChar(heroEquipAwakeShopCfg.buyitem))
					bagVoApi:addBag(getid,1)
					local equipReward = {}
					for k, v in pairs(sData.data.hereport) do
						local rewardItem=FormatItem(v)[1]

						if rewardItem.type=="h" then
			                local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(rewardItem,oldHeroList)
			                -- self:showOneSearch(4,rewardItem,self.layerNum+1,heroIsExist,addNum,nil,newProductOrder,nil,"public/hero/heroequip/equipLabBigBg.jpg")

			                if rewardItem.eType=="h" and heroIsExist==false then
			                    heroVoApi:getNewHeroChat(rewardItem.key)
			                end

			                if heroVoApi:heroHonorIsOpen()==true then
			                    local hid
			                    if rewardItem.eType=="h" then 
			                        hid=rewardItem.key
			                    elseif rewardItem.eType=="s" then
			                        hid=heroCfg.soul2hero[rewardItem.key]
			                    end 
			                    if hid and heroVoApi:getIsHonored(hid)==true then
			                        local pid=heroCfg.getSkillItem
			                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
			                        bagVoApi:addBag(id,addNum)
			                    end
			                end
			            else
			            	if rewardItem.type ~= "f" then --装备exp后端有同步，前端就不再添加了
				            	if not (sData.data.userinfo and rewardItem.type == "u" and (rewardItem.key=="gem" or rewardItem.key=="gems")) then
				                	G_addPlayerAward(rewardItem.type,rewardItem.key,rewardItem.id,rewardItem.num,false,true)
				            	end
			            	end
			                -- self:showOneSearch(4,rewardItem,self.layerNum+1,nil,nil,nil,nil,nil,"public/hero/heroequip/equipLabBigBg.jpg")
			            end

						table.insert(equipReward,rewardItem)
					end
					addReward("s3",equipReward)
				end

				--@军徽获取
				local s6Data = get_rData("s6")
				if sData.data.sereport then
					local emblemReward = {}
					for k, v in pairs(sData.data.sereport) do
						local rewardItem=FormatItem(v)[1]
						if rewardItem.type ~= "se" then
							G_addPlayerAward(rewardItem.type,rewardItem.key,rewardItem.id,rewardItem.num)
						end
						table.insert(emblemReward,rewardItem)
					end
					local numIndex
					local _type = 1
					for k,v in pairs(emblemVoApi:getEquipNumCfg()[_type]) do
						if(1==v)then
							numIndex=k
							break
						end
					end

					local stringTb = nil
					if self:getCheckBoxState("s6") == 1 and s6Data and s6Data.freeTb[1][1] > 0 then
						stringTb = {}
						-- local r5CostNum, r5Cost = emblemVoApi:getR5Cost(s6Data.freeTb[1][1], s6Data.freeTb[1][2])
						local r5CostNum, r5Cost = 0, 0
						if sData.data.elblemCrystalNum then
							r5CostNum = sData.data.elblemCrystalNum[1] or 0
							r5Cost = sData.data.elblemCrystalNum[2] or 0
						end
						if r5CostNum == 0 and r5Cost == 0 then
							table.insert(stringTb,{getlocal("steward_costR5_tips2"), G_ColorRed})
						else
							table.insert(stringTb,{getlocal("steward_costR5_tips1", {r5CostNum, FormatNumber(r5Cost)}), G_ColorYellowPro})
							emblemVoApi:updateLastGetTimes(2, r5CostNum)
							-- playerVoApi:setGold(playerVoApi:getGold() - r5Cost)
						end
					end
					-- local cost=emblemVoApi:getEquipCost(_type,numIndex) -- 获取当前使用钻石/稀土抽取1次/多次的消耗
					-- if _type== 1 then
					-- 	playerVoApi:setGems(playerVoApi:getGems() - cost)
					-- end
					emblemVoApi:afterGetEquip(emblemReward,_type,numIndex)--刷新数据
					addReward("s4",emblemReward,stringTb)
				elseif s6Data and s6Data.freeTb[1][1] > 0 and self:getCheckBoxState("s6") == 1 then
					if type(s6Data.freeTb[1][4]) == "number" and playerVoApi:getGold() < s6Data.freeTb[1][4] then
						local stringTb = {}
						table.insert(stringTb,{getlocal("steward_costR5_tips2"), G_ColorRed})
						addReward("s4",nil,stringTb)
					end
				end

				--@飞机技能获取
				local s7Data = get_rData("s7")
				if sData.data.plreward then
					local rewardItem=FormatItem(sData.data.plreward)
					for k,v in pairs(rewardItem) do
						G_addPlayerAward(v.type,v.key,v.id,v.num)
					end

					local numIndex
					local ltype = 1
					for k,v in pairs(planeVoApi:getSkillNumCfg()[ltype]) do
						if(1==v)then
							numIndex=k
							break
						end
					end

					local stringTb = nil
					if self:getCheckBoxState("s7") == 1 and s7Data and s7Data.freeTb[1][1] > 0 then
						stringTb = {}
						-- local r5CostNum, r5Cost = planeVoApi:getR5Cost(s7Data.freeTb[1][1], s7Data.freeTb[1][2])
						local r5CostNum, r5Cost = 0, 0
						if sData.data.planeCrystalNum then
							r5CostNum = sData.data.planeCrystalNum[1] or 0
							r5Cost = sData.data.planeCrystalNum[2] or 0
						end
						if r5CostNum == 0 and r5Cost == 0 then
							table.insert(stringTb,{getlocal("steward_costR5_tips2"), G_ColorRed})
						else
							table.insert(stringTb,{getlocal("steward_costR5_tips1", {r5CostNum, FormatNumber(r5Cost)}), G_ColorYellowPro})
							-- planeVoApi:updateLastGetTimes(2, r5CostNum)
							-- playerVoApi:setGold(playerVoApi:getGold() - r5Cost)
						end
					end
					-- if ltype==1 then
					-- 	playerVoApi:setGems(playerVoApi:getGems() - cost)
					-- end
					planeVoApi:afterGetSkill(rewardItem,ltype,numIndex)--刷新数据
					-- eventDispatcher:dispatchEvent("skill.freeget.refresh")

					addReward("s5",rewardItem,stringTb)
				elseif s7Data and s7Data.freeTb[1][1] > 0 and self:getCheckBoxState("s7") == 1 then
					if type(s7Data.freeTb[1][4]) == "number" and playerVoApi:getGold() < s7Data.freeTb[1][4] then
						local stringTb = {}
						table.insert(stringTb,{getlocal("steward_costR5_tips2"), G_ColorRed})
						addReward("s5",nil,stringTb)
					end
				end
				if sData.data.plane then
					planeVoApi:initLotterySkill(sData.data.plane)
				end

			end
			if type(callback)=="function" then
				callback(_rData)
			end
		end
	end
	socketHelper:stewardLottery(socketCallback, checkBoxStates)
end

function stewardVoApi:setCheckBoxState(key, value)
	local dataKey = "steward_" .. key .. "@" .. tostring(playerVoApi:getUid()) .. "@" .. tostring(base.curZoneID)
	CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey, value)
	CCUserDefault:sharedUserDefault():flush()
end

function stewardVoApi:getCheckBoxState(key)
	local dataKey = "steward_" .. key .. "@" .. tostring(playerVoApi:getUid()) .. "@" .. tostring(base.curZoneID)
	return CCUserDefault:sharedUserDefault():getIntegerForKey(dataKey)
end

function stewardVoApi:clear()
	self.swData  = {}
	self.expData = {}
	self.needZeroTime = 0
	self.isSocketExp = false
end


--------------------------------------- t a b 2 - s t a r t -------------------------------------
function stewardVoApi:isSocketExpFun( )
	return self.isSocketExp
end
function stewardVoApi:setIsSocketExp(newType )
	self.isSocketExp = newType
end

function stewardVoApi:getZeroTime( )
	if self.needZeroTime == 0 then
		self.needZeroTime = G_getWeeTs(base.serverTime) + 86400
	end
	return self.needZeroTime
end
function stewardVoApi:setZeroTime(newT)
	self.needZeroTime = newT
end

function stewardVoApi:isAllSweepOpened( )--所有功能是否开启
	--补给线 新版默认开启，所以无开关
	local _isAllOpen,_notOpenTb = true,{}
	local _allOpenNum = 3
	-- print("expeditionCfg.openLevel=======>>>>>",expeditionCfg.openLevel)
	if base.expeditionSwitch == 0 or playerVoApi:getPlayerLevel() < expeditionCfg.openLevel then--远征
		_isAllOpen = false
		_notOpenTb[2] = 2
	end

	local superWeaponOpenLv=base.superWeaponOpenLv or 25
	if base.ifSuperWeaponOpen==0 or playerVoApi:getPlayerLevel() < superWeaponOpenLv then--超级武器
		_isAllOpen = false
		_notOpenTb[3] = 3
	end
	if SizeOfTable(_notOpenTb) > 0 then
		_allOpenNum = _allOpenNum - SizeOfTable(_notOpenTb)
	end

	return _isAllOpen ,_notOpenTb,_allOpenNum
end


function stewardVoApi:isHasLeftSpace( )
	if accessoryVoApi.abag then
		local isFull = accessoryVoApi:bagIsFull()
		-- print(".abag~~~~~isFull-->>>>",isFull)
		return isFull
	else
		local _abagLeftNum = accessoryVoApi:getAbagLeftNum()--self.abagLeftNum
		local _fbagLeftNum = accessoryVoApi:getFbagLeftNum()
		-- print("_abagLeftNum== 0 or _fbagLeftNum == 0------->>>>>>",_abagLeftNum, _fbagLeftNum)
		if _abagLeftNum== 0 or _fbagLeftNum == 0 then 
	    	return false
	    end
	    return true
	end
end

function stewardVoApi:vipUseInSupplyLine()--是否能扫荡补给线 0：可以，1：vip等级不够，2：没有剩余的3星关卡，3：仓库不足，4：能量不足
	if accessoryVoApi and accessoryVoApi.canRaid and accessoryVoApi.getLeftResetNum then
		local _canRaid,_needVipLevel=accessoryVoApi:canRaid()
		-- print("_canRaid------->>>>>>",_canRaid)
		if _canRaid == 3 and stewardVoApi:isHasLeftSpace( ) then--特殊处理，用 isHasLeftSpace 修正背包信息
			_canRaid = 0
		end
		local _leftResetNum= accessoryVoApi:getLeftResetNum()--剩余重置次数
		return _canRaid,_needVipLevel or 4,_leftResetNum
	else
		print "accessoryVoApi is not require and init ############### accessoryVoApi #############"
		return false --accessoryVoApi 未加载
	end
end
-- 初始数据
function stewardVoApi:setSwchallenge(swData)--超武 --作废
	-- superWeaponVoApi:setSWChallenge(swData)
	-- self.swData = swData
end
function stewardVoApi:setExpedt(expData)--远征 --作废
	-- self.expData = expData
end
--远征
function stewardVoApi:expeditionCanSweep()--远征是否可以扫荡 
	if base.expeditionSwitch > 0 and base.ea > 0 and playerVoApi:getPlayerLevel() >= expeditionCfg.openLevel then
		if expeditionVoApi and expeditionVoApi.userInfo and expeditionVoApi.userInfo.win == false and expeditionVoApi.userInfo.acount >= expeditionCfg.acount then
			return true,expeditionVoApi.userInfo.acount,tonumber(expeditionVoApi:getLeftNum()) or 0
		else
			return false,expeditionVoApi.userInfo.acount or 0,expeditionVoApi:getLeftNum() or 0
		end
	else
		return false
	end
end

-- 超武
function stewardVoApi:getResetMaxNum()-- 超武 今日最大重置次数
	local resetTab=swChallengeCfg.resetNum
    local vipLevel=playerVoApi:getVipLevel()
    local maxResetNum=resetTab[vipLevel+1]
    local freeNum=swChallengeCfg.freeResetNum
    local maxNum=maxResetNum+freeNum
    return maxNum
end

function stewardVoApi:getLeftResetNum()-- 超武 今日剩余重置次数
	-- print("superWeaponVoApi:getLeftResetNum()==============>>>>>",superWeaponVoApi:getLeftResetNum())
	local leftNum = superWeaponVoApi:getLeftResetNum() or 0
    return leftNum
end

function stewardVoApi:superWeaponCanSweep()--超武 是否可以扫荡 
	if base.ifSuperWeaponOpen > 0 and playerVoApi:getPlayerLevel() >= base.superWeaponOpenLv then
	    local  _curPos = 0--=tonumber(self.swData.pos) or 0
	    local _maxPos = 0--=tonumber(self.swData.maxpos) or 0
	    local cVo=superWeaponVoApi:getSWChallenge()
	    if cVo then
	        _curPos = tonumber(cVo.curClearPos) or 0
	        _maxPos=tonumber(cVo.maxClearPos) or 0
	    end
		return _curPos < _maxPos or false,_curPos
	else
		return false
	end
end

function stewardVoApi:allCanSweeping( )-- 判断是否可以扫荡
	--if superWeaponVoApi:getRaidLeftTime() == 0 and 
	if self:vipUseInSupplyLine() == 0 or self:expeditionCanSweep() or (self:superWeaponCanSweep() and superWeaponVoApi:getRaidLeftTime() == 0) then
		return true
	else
		return false
	end
end

--一键扫荡接口
function stewardVoApi:socketSweeping(layerNum,diaRefCallBack)
	local function sweepingCallback(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			print("一键扫荡 成功~~~~~~~~~~~~~~~~~~~~~~")
			
			if sData.data then
				accessoryVoApi:formatECData(sData.data)--更新space

				local allAwardTb,allAwardTipTb = {},{}
				--补给线数据，             奖励显示 还未从新处理
				if sData.data.echallengeraid and sData.data.echallengeraid.report then
					local raidReward=sData.data.echallengeraid.report

                	local isFull=false
                	local eIsEnough=true
                	local rewardTab={}
            		rewardTab,eIsEnough,isFull=accessoryVoApi:raidUpdate(raidReward)

            		--添加配件和碎片、原材料
                    if sData.data and sData.data.echallengeraid and sData.data.echallengeraid.reward then
                        local accessory=sData.data.echallengeraid.reward
                        accessoryVoApi:addNewData(accessory)
                    end

                    local cfg=accessoryVoApi:getEChallengeCfg()
            		local ecCfg=accessoryVoApi:getECCfg()

            		local title=getlocal("elite_challenge_raid_btn")
				    local content={}
				    local lbColor={}
                    local showStrTb={}
            		if rewardTab and SizeOfTable(rewardTab)>0 then
                		for k,v in pairs(rewardTab) do
                            local awardTab=v.awardTab
                            local id=v.id
                			local eCfg=ecCfg["s"..id]
                			local name=getlocal(eCfg.name)
                            for kk,vv in pairs(awardTab) do
                                if vv.type=="e" then
                                    vv.index=1000+kk
                                elseif vv.type=="u" then
                                    vv.index=0+kk
                                else
                                    vv.index=100+kk
                                end
                            end
                            local function sortFunc(a,b)
                                return a.index<b.index
                            end
                            table.sort(awardTab,sortFunc)
                            table.insert(content,{award=awardTab})

                			local showStr=getlocal("accessory_rout_des",{name})
                            table.insert(showStrTb,showStr)
                		end
                	end
                	allAwardTb[1] = content
                	allAwardTipTb["slShowStrTb"] = showStrTb

                    local endRaidStrTb
                    if isFull==true then
                        endRaidStr=getlocal("accessory_bag_full")
                        endRaidStrTb={endRaidStr,G_ColorRed,1}
                    elseif eIsEnough==false then
                        endRaidStr=getlocal("elite_challenge_raid_energy")
                        endRaidStrTb={endRaidStr,G_ColorRed,2}
                    else
                        endRaidStr=getlocal("elite_challenge_raid_complete")
                        endRaidStrTb={endRaidStr,G_ColorGreen,0}
                    end
                    allAwardTipTb["slEndRaidStr"] = endRaidStrTb
				end

				--远征数据，				 奖励显示 还未从新处理
				if sData.data.expedition then
			       expeditionVoApi:initVo(sData.data.expedition)
			       -- self:setExpedt(sData.data.expedition)
			       -- expeditionVoApi:initVo(sData.data.expedition)
			    end
			    if sData.data.expeditionraid then--用reward加身上 用report显示
			    	if sData.data.expeditionraid.reward then
			    	  local award=FormatItem(sData.data.expeditionraid.reward) or {}
	                  for k,v in pairs(award) do
						if v.type=="h" then
							heroVoApi:addSoul(v.key,v.num)
						else
							G_addPlayerAward(v.type,v.key,v.id,v.num)
						end
	                  end
	              	end
	              	if sData.data.expeditionraid.report then
		                  local expRewardTb = {}
		                  for k,v in pairs(sData.data.expeditionraid.report) do
		                  		local itemTb = FormatItem(v,nil,true)
		                  		-- print("sizeoftable -- itemTb---->>>>",SizeOfTable(itemTb))
		                  		for m,n in pairs(itemTb) do
		                  			table.insert(expRewardTb,n)	
		                  		end
	                        	-- expRewardTb[k]=itemTb[1]
	                      end
	                      allAwardTb[2] = expRewardTb
	                      local addPoint = tonumber(sData.data.expeditionraid.addpoint) or 0
	                      allAwardTipTb["expTip"] = getlocal("steward_tabTwo_expSweepingTip",{addPoint})
	                      -- print("SizeOfTable(self.expRewardTb)------->>>>>>",SizeOfTable(expRewardTb))
                    end
                end

                --超武 神秘组织数据，				 奖励显示 还未从新处理
                if sData.data.swchallenge then
	        		superWeaponVoApi:setSWChallenge(sData.data.swchallenge)
	        		local moPrivilegeFlag
		        	if militaryOrdersVoApi then
		        		moPrivilegeFlag = militaryOrdersVoApi:isUnlockByPrivilegeId(2)
		        	end
	        		allAwardTipTb["swTip"] = (moPrivilegeFlag == true) and getlocal("steward_tabTwo_swAwardShow2") or getlocal("steward_tabTwo_swAwardShow")
	        		allAwardTb[3] = {}
	        	end

				if diaRefCallBack then
					-- print("diaRefCallBack 要 回调~~~~~~~~~~~~~~~~~~~")
					diaRefCallBack(allAwardTb,allAwardTipTb)
				end
			end
			
		end
	end
	local eclist = nil --记录补给线最近一次扫荡
	local resetNum = accessoryVoApi:getUsedResetNum() --今日重置次数
	local lastRaidList = accessoryVoApi:getLastSelectRaidList()
    local raidTb = G_clone(accessoryVoApi:getLeft3Star())
    for k,v in pairs(raidTb) do
    	local ecid = "s"..v
    	if eclist == nil then
	    	eclist = {}
	    end
    	if resetNum==0 then--重置次数为0时，扫荡上次被选中的
	    	if lastRaidList[ecid] == 1 then --最近一次扫荡被选中
	            table.insert(eclist, ecid)
	    	end
	    else  --重置过，不消耗能量的话就全扫
	    	table.insert(eclist, ecid)
	    end
    end
	socketHelper:stewardSweeping(sweepingCallback, eclist)
end

--------------------------------------- t a b 2 - e n d -------------------------------------------