allShopVoApi={
	shopLargNum = 10,--目前最大商店数
	allPropDialog = nil,	
	shopTypeTb ={},
	shopShowNameTb ={},
	subLbTb ={},
	useIconTb={},
}
function allShopVoApi:init( )
					  -- 金币，军团，	演习，	远征，	矩阵，	精工，	军功，	异元,   坦克涂装， 优惠商店
	self.shopTypeTb ={gems=1,army=2,drill=3,expe=4,matr=5,seiko=6,feat=7,diff=8,tskin=9,preferential=10}
	self.shopShowNameTb ={gems="gem",army="sample_build_name_15",drill="drill",expe="become_expedition",matr="armorMatrix_lineup",seiko="awaken",feat="military_rank_battlePoint",diff="diff",tskin="tankSkin_title",preferential="shop_preferential_title"}
end
function allShopVoApi:clear( )
	self.shopLargNum	= nil
	self.shopTypeTb 	= {}
	self.shopShowNameTb = {}
	self.subLbTb 		= {}
	self.featData 		= {}
	self.useIconTb 		= {}
	self.specialShopList = nil
	self.specialShopBuyData = {}
end
function allShopVoApi:getLargeNum()
	return self.shopLargNum or 10 --目前最大 10
end
function allShopVoApi:getCurIconSpName(selectShop)
	if SizeOfTable(self.useIconTb) == 0 then
		self.useIconTb = {gems="IconGold.png",army="IconGold.png",diff="IconGold.png",expe="expeditionPoint.png",drill="icon_medal_sports.png",seiko="icon_awaken_fragment.png",feat="rpCoin.png",matr="armorMatrixExp.png",tskin="IconGold.png",preferential="IconGold.png"}
	end
	return self.useIconTb[selectShop]
end
function allShopVoApi:getShopTypeByIndex(shopUseNum)
	if shopUseNum and SizeOfTable(self.shopTypeTb) > 0 then
		for k,v in pairs(self.shopTypeTb) do
			if v == shopUseNum then
				return k
			end
		end
	end
	return nil
end

function allShopVoApi:showAllPropDialog(layerNum,shopType,callBack1,subTabIndex,showItemId)
	
    require "luascript/script/game/scene/gamedialog/allPropDialog"
    require "luascript/script/game/scene/gamedialog/allShopSmalDiaChooseUsed"
    self:removeSelfAllDia()
    self:addNeedPlist()
    self:determineIsAllOpen()
    local dialogName = getlocal("mergeShop")
    local shopNum = self:getShopNum(shopType)
    local td=allPropDialog:new(layerNum,shopNum,shopType,callBack1,subTabIndex,showItemId)
    self.allPropDialog = td
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,dialogName,true,layerNum)
    sceneGame:addChild(dialog,layerNum)
    return td,dialog
end

function allShopVoApi:getShopNum(shopType)
	if shopType and self.shopTypeTb[shopType] then
		return	self.shopTypeTb[shopType],self.shopTypeTb
	end
	return nil , self.shopTypeTb
end


function allShopVoApi:addNeedPlist()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	spriteController:addPlist("public/mergedShopIconImage.plist")
    spriteController:addTexture("public/mergedShopIconImage.png")

    spriteController:addPlist("public/youhuaUI4.plist")
    spriteController:addTexture("public/youhuaUI4.png")
	--"gb"
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    spriteController:addPlist("public/datebaseShow.plist")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")

    --"army"
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")--跟上面重复了

    --"drill"
    spriteController:addTexture("public/acKafkaGift.pvr.ccz")
    spriteController:addPlist("public/acKafkaGift.plist")
    --"expe"
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
    --"matr"
    spriteController:addPlist("public/yellowFlicker.plist")
    spriteController:addTexture("public/yellowFlicker.png")

    spriteController:addPlist("public/acThfb.plist")
	spriteController:addTexture("public/acThfb.png")

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end
function allShopVoApi:removeAllPlist()
	spriteController:removePlist("public/mergedShopIconImage.plist")
    spriteController:removeTexture("public/mergedShopIconImage.png")
	--"gb"
	spriteController:removePlist("public/datebaseShow.plist")
    spriteController:removeTexture("public/datebaseShow.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")

    --"drill"
    spriteController:removeTexture("public/acKafkaGift.pvr.ccz")
    spriteController:removePlist("public/acKafkaGift.plist")

    --"expe"
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")--不能remove 切换远征界面会报错

    --"matr"
    spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removeTexture("public/yellowFlicker.png")

    spriteController:removePlist("public/acThfb.plist")
    spriteController:removeTexture("public/acThfb.png")
end

function allShopVoApi:tipIsNotShow(selectShop)--不显示！！！
	if selectShop == "gems" or selectShop == "drill" or selectShop == "expe" or selectShop =="seiko" or selectShop == "matr" or selectShop == "tskin" or selectShop == "preferential" then
		return true
	end
	return false
end

function allShopVoApi:determineIsAllOpen()
	self:init()
	-- local rp = (base.rpShop == 0 or base.rpshopopen == 0) and 0 or 1

	local useNumTb,useNum = {},0
	if base.ifAllianceShopOpen == 0 then
		useNum = self.shopTypeTb.army
		table.insert(useNumTb,useNum)
		self.shopTypeTb.army = nil
	end
	if base.ifMilitaryOpen == 0 then
		useNum = self.shopTypeTb.drill
		table.insert(useNumTb,useNum)
		self.shopTypeTb.drill = nil
	end
	if base.expeditionSwitch == 0 then
		useNum = self.shopTypeTb.expe
		table.insert(useNumTb,useNum)
		self.shopTypeTb.expe = nil
	end
	if base.dimensionalWarSwitch == 0 then
		useNum = self.shopTypeTb.diff
		table.insert(useNumTb,useNum)
		self.shopTypeTb.diff = nil
	end
	if base.he == 0 then--将领装备开关 精工商店与其同步
		useNum = self.shopTypeTb.seiko
		table.insert(useNumTb,useNum)
		self.shopTypeTb.seiko = nil
	end
	if base.rpShop == 0 and base.rpShopOpen == 0 then
		useNum = self.shopTypeTb.feat
		table.insert(useNumTb,useNum)
		self.shopTypeTb.feat = nil
	end
	if base.armor == 0 then
		useNum = self.shopTypeTb.matr
		table.insert(useNumTb,useNum)
		self.shopTypeTb.matr = nil
	end
	if base.tskinSwitch==0 then
		useNum = self.shopTypeTb.tskin
		table.insert(useNumTb,useNum)
		self.shopTypeTb.tskin = nil
	end
	if base.adjSwitch==0 then
		useNum = self.shopTypeTb.preferential
		table.insert(useNumTb,useNum)
		self.shopTypeTb.preferential = nil
	end

	for k,v in pairs(self.shopTypeTb) do
		for mm,nn in pairs(useNumTb) do
			local useNum = nn
			if v > useNum then
				self.shopTypeTb[k] = self.shopTypeTb[k] - 1
			end
		end
	end

end

function allShopVoApi:getNeedrLb(shopType,subTabUseIdx)
	-- 金币，	   军团，	  演习，	 远征，	 异元，	精工，	军功， 矩阵,   tskin:坦克皮肤, preferential:优惠商店
	--{gems=1,army=2,drill=3,expe=4,diff=5,seiko=6,feat=7,matr=8,}
	self:everyShopVoApiSpeicalUse(shopType)

	if shopType == "gems" or shopType == "tskin" or shopType == "preferential" then
		return getlocal("gem").."："..playerVoApi:getGems()
	elseif shopType == "army" then
		local upDes2 = getlocal("allianceShop_tip1")
		if subTabUseIdx == 2 then
			upDes2 = self:changeSubTabNeedLb(shopType,subTabUseIdx)
		end
		return getlocal("allianceShop_myDonate").." "..(allianceMemberVoApi:getCanUseDonate(playerVoApi:getUid()) or 0),upDes2
	elseif shopType == "drill" then
		local timeStr=arenaVoApi:getRefreshTimeStr()
		local nextTime = getlocal("expeditionRefreshTime",{timeStr})------------------------------------------需要最新的时间 好几个都需要
		return getlocal("shamBattle_medal").."："..(arenaVoApi:getPoint() or 0),nextTime
	elseif shopType == "expe" then--远征积分
		local timeStr=expeditionVoApi:getRefreshTimeStr()
		local nextTime = getlocal("expeditionRefreshTime",{timeStr})
		return getlocal("serverwar_my_point")..(expeditionVoApi:getPoint() or 0),nextTime
	elseif shopType == "diff" then
		local upDes2 = getlocal("dimensionalWar_shop_reset")
		if subTabUseIdx == 2 then
			upDes2 = getlocal("local_war_report_max_num",{userWarCfg.militaryrank})
		end
		return getlocal("serverwar_my_point")..(dimensionalWarVoApi:getPoint() or 0),upDes2
	elseif shopType == "seiko" then
		local propKey = heroEquipAwakeShopCfg.buyitem
		local name,pic,desc=getItem(propKey,"p")
		local id = tonumber(propKey) or tonumber(RemoveFirstChar(propKey))
		local num = bagVoApi:getItemNumId(id) or 0
		local upDes2 = getlocal(desc)
		return name.."："..num,upDes2
	elseif shopType == "feat" then--军功，

		return getlocal("military_rank_battlePoint").."："..(playerVoApi:getRpCoin())
	elseif shopType == "matr" then--矩阵
		local upDes2 = ""
		local stype = armorMatrixVoApi:getShopInfo()
		if stype == 1 then
			upDes2 = getlocal("armorMatrix_exp_des")
		else
			upDes2 = getlocal("armor_shop_des1")
		end
		local exp=armorMatrixVoApi:getArmorMatrixInfo()["exp"] or 0
		return getlocal("ownedXp",{exp}),upDes2
	else
		return ""
	end
end

function allShopVoApi:changeSubTabNeedLb(shopType,subTabUseIdx)
	if shopType == "army" then
		if subTabUseIdx == 2 then
			local timeStrTb={}
			for k,v in pairs(allianceShopCfg.aShopRefreshTime) do
				local str
				if(v[1]<10)then
					str="0"..v[1]
				else
					str=v[1]
				end
				str=str..":"
				if(v[2]<10)then
					str=str.."0"..v[2]
				else
					str=str..v[2]
				end
				table.insert(timeStrTb,str)
			end
			local timeStr=table.concat(timeStrTb, ", ")
			return getlocal("allianceShop_tip2",{timeStr})
		end

	end
end

function allShopVoApi:goToNewDia(selectShopType,layerNum)
	-- print("selectShopType===goToNewDia=====>>>>>",selectShopType)
	
	if selectShopType == "gems" or selectShopType == "tskin" or selectShopType == "preferential" then
		activityAndNoteDialog:closeAllDialog()
		vipVoApi:showRechargeDialog(layerNum)
	else
		local needTb = {}
		if selectShopType == "army" then
			local subTitleTb = {getlocal("gotoContributionSub_1"),getlocal("gotoContributionSub_2")}
			needTb = {selectShopType=selectShopType , titleStr=getlocal("getContribution") , subTitleTb=subTitleTb}
			
		elseif selectShopType == "drill" then
			local subTitleTb = {getlocal("gotoMilitaryExercises")}
			needTb = {selectShopType=selectShopType , titleStr=getlocal("getMedal") , subTitleTb=subTitleTb}
			
		elseif selectShopType == "expe" then--远征积分
			local subTitleTb = {getlocal("gotoExpedition")}
			needTb = {selectShopType=selectShopType , titleStr=getlocal("getPoint") , subTitleTb=subTitleTb}
			
		elseif selectShopType == "diff" then--异元
			local subTitleTb = {getlocal("gotoDiffBattle")}
			needTb = {selectShopType=selectShopType , titleStr=getlocal("getPoint") , subTitleTb=subTitleTb}
		elseif selectShopType == "seiko" then--精工
			local subTitleTb = {getlocal("gotoEquipForReesearch")}
			needTb = {selectShopType=selectShopType , titleStr=getlocal("getPieces") , subTitleTb=subTitleTb}
		elseif selectShopType == "feat" then--军功，
			local subTitleTb = {getlocal("gotoFighting")}
			needTb = {selectShopType=selectShopType , titleStr=getlocal("getCoins") , subTitleTb=subTitleTb}
		elseif selectShopType == "matr" then--矩阵
			local subTitleTb = {getlocal("gotoRecuit"),getlocal("gotoWareHouseForLayOff")}
			needTb = {selectShopType=selectShopType , titleStr=getlocal("getExperience") , subTitleTb=subTitleTb}
		end
		local bigAwardDia = allShopSmalDiaChooseUsed:new(layerNum+1,needTb)
        bigAwardDia:init()
	end
end

function allShopVoApi:getShopShowNameTb( )

	 return self.shopShowNameTb
end

function allShopVoApi:removeSelfAllDia()
	if self.allPropDialog then
		self.allPropDialog:close()
		self.allPropDialog = nil
	end
end

function allShopVoApi:getCursubLbStrTb(selectShop)

	if SizeOfTable(self.subLbTb) == 0 then
		  self.subLbTb = {
			gems={getlocal("resource"),getlocal("help4_t3"),getlocal("chestText"),getlocal("otherText")},
			army={getlocal("allianceShop_tab1"),getlocal("allianceShop_tab2")},
			drill={getlocal("allianceShop_tab1")},--空table 表示 就1个商品表，非多签
			expe={getlocal("allianceShop_tab1")},
			diff={getlocal("acMayDay_tab2_title"),getlocal("plat_war_sub_title33")},
			seiko={getlocal("allianceShop_tab1")},
			feat={getlocal("normal"),getlocal("allianceShop_tab2")},
			matr={getlocal("allianceShop_tab1")},
			tskin={getlocal("market")},
			preferential={getlocal("allianceShop_tab1")},
		  }
	end
	return self.subLbTb[selectShop] or {}
end

function allShopVoApi:getCurShopItem(selectShop,subTab,realTimeCallBack)
	
	if selectShop == "gems" then
		local gShopUseNum = {2,1,3,4}
		local shopItem = shopVoApi:getShopItemByType(gShopUseNum[subTab])
		return shopItem or nil
	elseif selectShop == "army" then
		if subTab == 1 then
			return self.alliancePShopData or nil
		else
			return self.allianceAShopData or nil
		end
	elseif selectShop == "drill" then
		local shamBattlePropItem = arenaVoApi:getShop() or nil		
		return shamBattlePropItem
	elseif selectShop == "expe" then
		local expeditionItem = expeditionVoApi:getShop() or nil
		return expeditionItem
	elseif selectShop == "diff" then
		if subTab == 1 then
			return dimensionalWarVoApi:getShopList() or nil
		else
			return dimensionalWarVoApi:getPointDetail() or nil
		end
	elseif selectShop == "seiko" then
		return heroEquipAwakeShopCfg.pShopItems or nil
	elseif selectShop == "matr" then
		local shopType,shopInfo,shopNum=armorMatrixVoApi:getShopInfo()
		local armorshopCfg=armorMatrixVoApi:getArmorshopCfg()
		if shopType == 1 then
			 return armorshopCfg.preshoplist or nil
		else
			return armorshopCfg.shoplist or nil
		end
	elseif selectShop == "feat" then
		return self.featData or nil
	elseif selectShop == "tskin" then
		return tankSkinVoApi:getShopList()
	elseif selectShop == "preferential" then --优惠商店
		return self:getSpecialShopList()
	end
end

function allShopVoApi:SocketNewData(selectShop,subTab,realTimeCallBack,isSpeical,isNeedRef)
	
	if selectShop == "army" then
		if subTab == 1 then
			local function getDataCallback(data)
				self.alliancePShopData={}
				for k,v in pairs(allianceShopCfg.pShopItems) do
					if not (k == "i20" and base.redAccessoryPromote ~= 1) then
						local cellData={}
						cellData.id=v.id
						cellData.rewardTb=FormatItem(v.reward)
						cellData.lv=v.lv
						cellData.price=v.price
						cellData.maxTime=v.pBuyNum
						if(data[v.id])then
							cellData.curTime=data[v.id]
						else
							cellData.curTime=0
						end
						local length=#self.alliancePShopData
						local flag=false
						for i=1,length do
							if(cellData.lv<self.alliancePShopData[i].lv)then
								flag=true
								table.insert(self.alliancePShopData,i,cellData)
								break
							elseif(cellData.lv==self.alliancePShopData[i].lv)then
								local id1=tonumber(string.sub(cellData.id,2))
								local id2=tonumber(string.sub(self.alliancePShopData[i].id,2))
								if(id1<id2)then
									flag=true
									table.insert(self.alliancePShopData,i,cellData)
									break
								end
							end
						end
						if(flag==false)then
							table.insert(self.alliancePShopData,cellData)
						end
					end
				end
				if realTimeCallBack then
					realTimeCallBack(selectShop,subTab)
				end
			end
			allianceShopVoApi:getPShopData(getDataCallback)
		elseif subTab == 2 then
			local function getADataCallback(data)
				self.allianceAShopData={}
				for k,v in pairs(data) do
					local cellData={}
					local cfg=allianceShopCfg.aShopItems[v.id]
					cellData.id=v.id
					cellData.rewardTb=FormatItem(cfg.reward)
					cellData.price=cfg.price
					cellData.maxTime=cfg.aBuyNum
					cellData.maxPTime=cfg.pBuyNum
					cellData.curTime=v.aNum
					cellData.userBuy=v.pNum
					cellData.index=v.index
					table.insert(self.allianceAShopData,cellData)
				end	
				if realTimeCallBack then
					realTimeCallBack(selectShop,subTab)
				end
			end
			if isNeedRef then
				allianceShopVoApi:getAShopData(getADataCallback)
			else
				if realTimeCallBack then
					realTimeCallBack(selectShop,subTab)
				end
			end
			
		end
	elseif selectShop == "drill" then
		local function callback(fn,data)
	        local ret,sData=base:checkServerData(data)
	        if ret==true then
				local function reCallback(fn,data)
			        local ret,sData=base:checkServerData(data)
			        if ret==true then
			        	if realTimeCallBack then
				            realTimeCallBack(selectShop,subTab)
				        end
			        end
			    end
			    socketHelper:shamBattleGetshop(reCallback)
		    end
		end
		-- print("isNeedRef~=====>>>>",isNeedRef)
		if isNeedRef == nil then
			if realTimeCallBack then
	            realTimeCallBack(selectShop,subTab)
	        end
	    -- elseif shamBattleDialog then
	    -- 	local function reCallback(fn,data)
		   --      local ret,sData=base:checkServerData(data)
		   --      if ret==true then
		   --      	if realTimeCallBack then
			  --           realTimeCallBack(selectShop,subTab)
			  --       end
		   --      end
		   --  end
		   --  socketHelper:shamBattleGetshop(reCallback)
	    else
	    	socketHelper:militaryGet(callback)
	    end
	elseif selectShop == "expe" then
		local function callback(fn,data)
	    	local ret,sData=base:checkServerData(data)
	    	if ret == true then
				local function reCallback(fn,data)
		            local ret,sData=base:checkServerData(data)
		            if ret==true then
		            	if realTimeCallBack then
				            realTimeCallBack(selectShop,subTab)
				        end
		            end
		        end
		        socketHelper:expeditionGetshop(reCallback)
		    end
		end
		-- print("isNeedRef~=====in expe~~~~>>>>",isNeedRef)
		if isNeedRef == nil then
			if realTimeCallBack then
	            realTimeCallBack(selectShop,subTab)
	        end
		-- elseif expeditionDialog then
		-- 		local function reCallback(fn,data)
		--             local ret,sData=base:checkServerData(data)
		--             if ret==true then
		--             	if realTimeCallBack then
		-- 		            realTimeCallBack(selectShop,subTab)
		-- 		        end
		--             end
		--         end
		--         socketHelper:expeditionGetshop(reCallback)
		else
			socketHelper:expeditionGet(callback)
		end
    elseif selectShop == "diff" then
    	if subTab == 1 then
    		local function shopInfoCall()
	    		local function reCallback(fn,data)
	            	if realTimeCallBack then
			            realTimeCallBack(selectShop,subTab)
			        end
		        end
		        dimensionalWarVoApi:formatPointDetail(reCallback)
		    end
	        if isNeedRef == nil then
		    	if realTimeCallBack then
		            realTimeCallBack(selectShop,subTab)
		        end
		    else
		    	dimensionalWarVoApi:getShopInfo(shopInfoCall)
		    end
	    elseif subTab == 2 then
	    	if realTimeCallBack then
	    		realTimeCallBack(selectShop,subTab)
	    	end
	    end
	elseif selectShop == "matr" then
		if armorMatrixVoApi:canOpenArmorMatrixDialog(true) then
            local function showCallback()
                if realTimeCallBack then
		            realTimeCallBack(selectShop,subTab)
		        end
            end
	    	armorMatrixVoApi:armorGetData(showCallback)
        end
    elseif selectShop == "feat" then
    	-- selectShop = selectShop == nil and 1 or selectShop
    	local function callback()
			self.featData={}
			local useData = subTab == 1 and rpShopVoApi:getSbItemList() or rpShopVoApi:getNbItemList()
			if(useData==nil)then
				return realTimeCallBack(selectShop,subTab)
			end
			local length=#useData
			for i=1,length do
				local vo=useData[i]
				local cellData={}
				cellData.id=vo.id
				cellData.rewardTb=FormatItem(vo.cfg.reward)
				cellData.rank=vo.cfg.rank
				cellData.price=vo.cfg.price
				cellData.maxTime=vo.cfg.buynum
				cellData.curTime=vo.buyNum
				cellData.gemprice=vo.cfg.gemprice
				table.insert(self.featData,cellData)
			end
			if realTimeCallBack then
	            realTimeCallBack(selectShop,subTab)
	        end
		end
		-- self:checkShopOpen()
		if isSpeical then
			callback()
		else
	    	rpShopVoApi:refresh(callback)
	    end
	elseif realTimeCallBack then
		realTimeCallBack(selectShop,subTab)
	end
end


function allShopVoApi:everyShopVoApiSpeicalUse(shopType)
	
	if shopType == "feat" then
		if rpShopVoApi then
			rpShopVoApi:refreshSelfRecentOpenTime()
		end
	end
end

function allShopVoApi:isCanGo(selectKey,useNum)--商店跳转功能 等级限制提示
    local curLv = playerVoApi:getPlayerLevel()--needRoleLevel
    local NeedTipLv = 0
    if selectKey == "army" then
    	local isHasAlliance = allianceVoApi:isHasAlliance()--是否加入军团
    	local isHasBuilding = true
        local bid,bType=1,7
        local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
        if buildVo and buildVo.level<5 then --指挥中心5级开放军团
        	isHasBuilding = false
            --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("port_scene_building_tip_6"),30)
        end
        return isHasAlliance,isHasBuilding
    elseif selectKey == "drill" and curLv < 10 then
        NeedTipLv = 10
    elseif selectKey == "expe" and curLv < 25 then
        NeedTipLv = 25
    elseif selectKey == "diff" and curLv < 30 then
        NeedTipLv = 30
    elseif selectKey == "seiko" and curLv < 30 then
        NeedTipLv = 30
    elseif selectKey == "feat" and curLv < 3 then
        NeedTipLv = 3
    elseif selectKey == "matr" and curLv < 3 then        
        NeedTipLv = 3
    end
    -- print("selectKey===rpShopVoApi:checkShopOpen()=====>>>",selectKey,rpShopVoApi:checkShopOpen())
    if selectKey == "feat" and rpShopVoApi:checkShopOpen() == false then -- 军功不到开放时间
        -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("not_to_time"),30)
        return false
    end

    if NeedTipLv > 0 then
        return false,NeedTipLv
    end
    return true
end
function allShopVoApi:showTipDia(selectShop,curSubTab,layerNum )
	local tabStr,titleStr,textSize={},getlocal("dialog_title_prompt"),G_getCurChoseLanguage() =="ru" and 22 or 25
	local textColorTab = {}
	if selectShop == "army" then
			titleStr = getlocal("activity_baseLeveling_ruleTitle")
			if curSubTab == 1 then
				for i=1,2 do
			        table.insert(tabStr,getlocal("allianceShop_info_p"..i,{allianceShopCfg.cdTime/3600}))
			    end
			else
				table.insert(tabStr,getlocal("allianceShop_info_a1",{allianceShopCfg.cdTime/3600}))
				table.insert(tabStr,getlocal("allianceShop_info_p2"))
			end
			
	elseif selectShop == "diff" then
			textColorTab = {G_ColorYellow,G_ColorYellow,G_ColorRed}
			for i=1,3 do
		        table.insert(tabStr,getlocal("dimensionalWar_point_shop_desc"..i))
		    end
	elseif selectShop == "feat" then
			textColorTab = {G_ColorYellow,G_ColorYellow,G_ColorYellow,G_ColorYellow,G_ColorYellow}
			for i=1,5 do
		        table.insert(tabStr,getlocal("rpshop_info"..i))
		    end
	end
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(layerNum+1,true,true,nil,titleStr,tabStr,textColorTab,textSize)
end

function allShopVoApi:getShopBtnPic(selectShop)
	if selectShop=="tskin" then
		return "tskinTipPic.png"
	else
		return selectShop.."ShopIcon.png"
	end
end

--获取优惠商店列表
function allShopVoApi:getSpecialShopList()
	if self.specialShopList then
		do return self.specialShopList end
	end
	self.specialShopList={}
	for  k,v in pairs(propCfg) do
        if tonumber(v.isSpecialSell)==1 then
            table.insert(self.specialShopList,k)
        end
    end
    local function sort(a,b)
    	local acfg = propCfg[a]
    	local bcfg = propCfg[b]
    	if acfg and bcfg and acfg.sortId and bcfg.sortId then
    		if tonumber(acfg.sortId)<tonumber(bcfg.sortId) then
    			return true
    		end
    		return false
    	end
    end
    table.sort(self.specialShopList,sort)
    return self.specialShopList
end

function allShopVoApi:getSpecialShopBuyData()
	return self.specialShopBuyData or {}
end

function allShopVoApi:setSpecialShopBuyData(binfo)
	self.specialShopBuyData = binfo or {}
end

function allShopVoApi:clearSpecialShopBuyData()
	self.specialShopBuyData = {}
end

function allShopVoApi:getSpecialShopBuyNum(pid)
	local propId = tonumber(pid) and "p"..pid or tostring(pid)
	local buyData = self:getSpecialShopBuyData()
	if buyData.ts and G_isToday(buyData.ts)==false then --购买次数跨天重置
        self:clearSpecialShopBuyData()
    end
    buyData=self:getSpecialShopBuyData()
    return tonumber(buyData[pid]) or 0
end

--num：本次购买的个数
function allShopVoApi:getSpecialShopItemCost(pid,num)
	local costNum = 0
	local needBuyNum = num or 1
	local propId = tonumber(pid) and "p"..pid or tostring(pid)
	local hasBuyNum = self:getSpecialShopBuyNum(propId)
	local pcfg = propCfg[propId]
	local cfglen = #pcfg.spCost
	if needBuyNum and needBuyNum > 0 then
		for k=1,needBuyNum do
			local tnum = hasBuyNum + k
			if tnum >= cfglen then
		        costNum = costNum + pcfg.spCost[cfglen]
		    else
		        costNum = costNum + pcfg.spCost[tnum]
		    end
		end
	end

    return costNum
end

--当前金币玩家可以购买特惠商品的最大次数
function allShopVoApi:getSpecialShopItemMaxBuyNum(pid)
	local propId = tonumber(pid) and "p"..pid or tostring(pid)
	local maxNum = 0
	local gems = playerVoApi:getGems()
	local hasBuyNum = self:getSpecialShopBuyNum(propId)
	local pcfg = propCfg[propId]
	local cfglen = #pcfg.spCost
	if hasBuyNum >= cfglen then
		maxNum = math.floor(gems/pcfg.spCost[cfglen])
	else
		local remainGems = gems
		for k=(hasBuyNum +1 ),cfglen do
			if remainGems >= pcfg.spCost[k] then
				remainGems = remainGems - pcfg.spCost[k]
				maxNum = maxNum + 1
			else
				do break end
			end
		end
		if remainGems > 0 and remainGems >= pcfg.spCost[cfglen] then
			maxNum = maxNum + math.floor(remainGems/pcfg.spCost[cfglen])
		end
	end
	return maxNum
end

function allShopVoApi:tankSkinIsInSale()
	local saleEndTime = G_tzzkSaleData and (G_tzzkSaleData.et and G_tzzkSaleData.st) or nil
	if not saleEndTime then
		return false
	end
	-- print("base.serverTime---->>>>",base.serverTime)
	return (base.serverTime >= G_tzzkSaleData.st and base.serverTime <= G_tzzkSaleData.et) and true or false
end

function allShopVoApi:getTankSkinSaleData( )
	if not self:tankSkinIsInSale() then
		return {}
	end

	local saleData = (G_tzzkSaleData and G_tzzkSaleData._activeCfg) and G_tzzkSaleData._activeCfg.tsDisList or {}
	return saleData
end

--取涂装的折扣价格
function allShopVoApi:getTankSkinSaleDis()
	local saledata = self:getTankSkinSaleData()
	for k,v in pairs(saledata) do
		return v.dis
	end
	return 1
end