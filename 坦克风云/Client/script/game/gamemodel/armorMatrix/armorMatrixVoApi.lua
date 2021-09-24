armorMatrixVoApi=
{
	armorMatrixInfo=nil,
	pullFreeFlag=false, --是否拉取了免费抽取装甲矩阵的数据（用于免费抽取建筑提示）
	armorRequestFlag=false,--是否已经请求矩阵数据
}

function armorMatrixVoApi:clear()
	self.armorMatrixInfo=nil
	self.pullFreeFlag=false
	self.armorRequestFlag=false
end

function armorMatrixVoApi:isOpenArmorMatrix()
	if base.armor==1 then
		return true
	else
		return false
	end
end

function armorMatrixVoApi:getPermitLevel()
	local permitLevel
	local armorCfg=armorMatrixVoApi:getArmorCfg()
	if armorCfg and armorCfg.openLvLimit then
		permitLevel = armorCfg.openLvLimit
	end
	return permitLevel
end

function armorMatrixVoApi:canOpenArmorMatrixDialog(isTips)
	if self:isOpenArmorMatrix()==false then
		if isTips==false then
		else
			local str=getlocal("system_not_open",{getlocal("sample_build_name_105")})
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30)
		end
		do return false end
	end
	if playerVoApi:getPlayerLevel()<self:getPermitLevel() then
		if isTips==false then
		else
			local str=getlocal("armorMatrix_building_not_permit",{getlocal("sample_build_name_105"),self:getPermitLevel()})
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30)
		end
		do return false end
	end
	return true
end

--弹出装甲矩阵面板
function armorMatrixVoApi:showArmorMatrixDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/armorMatrix/armorMatrixDialog"
	local td=armorMatrixDialog:new()
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("armorMatrix"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

--弹出仓库面板
function armorMatrixVoApi:showBagDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/armorMatrix/armorMatrixBagDialog"
	local td=armorMatrixBagDialog:new()
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("sample_build_name_10"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

--弹出装配面板,tankPos:坦克位置，index:布阵位置
function armorMatrixVoApi:showSelectDialog(tankPos,index,layerNum)
    require "luascript/script/game/scene/gamedialog/armorMatrix/armorMatrixSelectDialog"
	local td=armorMatrixSelectDialog:new(tankPos,index)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("armorMatrix_fleet_equipped"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

--弹出面板信息
function armorMatrixVoApi:showInfoSmallDialog(id,layerNum,isShowBtn,rewardMid,level,isNewUI)
    require "luascript/script/game/scene/gamedialog/armorMatrix/armorMatrixInfoSmallDialog"
	local smallDialog=armorMatrixInfoSmallDialog:new()
	smallDialog:init(id,layerNum,isShowBtn,rewardMid,level,isNewUI)
	return smallDialog
end

--弹出升级面板
-- id:唯一id
function armorMatrixVoApi:showUpgradeSmallDialog(id,tankPos,layerNum,isShowBtn)
    require "luascript/script/game/scene/gamedialog/armorMatrix/armorMatrixUpgradeSmallDialog"
	local smallDialog=armorMatrixUpgradeSmallDialog:new()
	smallDialog:init(id,tankPos,layerNum,isShowBtn)
	return smallDialog
end

--弹出突破面板
function armorMatrixVoApi:showBreakThroughSmallDialog(id,tankPos,layerNum,isUpgrade)
	require "luascript/script/game/scene/gamedialog/armorMatrix/armorMatrixTPSmallDialog"
	local smallDialog = armorMatrixTPSmallDialog:showTPDialog(id, tankPos, layerNum, isUpgrade)
	return smallDialog
end

--弹出招募面板
function armorMatrixVoApi:showRecruitDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/armorMatrix/armorMatrixRecruitDialog"
	local td=armorMatrixRecruitDialog:new()
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("recruit"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

-- 批量分解弹板
function armorMatrixVoApi:showBulkSaleDialog(layerNum,sellBack)
	require "luascript/script/game/scene/gamedialog/armorMatrix/armorBulkSaleDialog"
	local smallDialog=armorBulkSaleDialog:new()
	smallDialog:init(layerNum,sellBack)
	return smallDialog
end

-- 获得经验弹板
function armorMatrixVoApi:showGetExpDialog(layerNum,titleStr,infoTb,isuseami)
	require "luascript/script/game/scene/gamedialog/armorMatrix/armorGetExpSmallDialog"
	local smallDialog=armorGetExpSmallDialog:new()
	smallDialog:init(layerNum,titleStr,infoTb,isuseami)
	return smallDialog
end

-- 套装效果弹板
function armorMatrixVoApi:showSuitDialog(layerNum,tankPos)
	require "luascript/script/game/scene/gamedialog/armorMatrix/armorMatrixSuitSmallDialog"
	local smallDialog=armorMatrixSuitSmallDialog:new()
	smallDialog:init(layerNum,tankPos)
	return smallDialog
end

function armorMatrixVoApi:showSellRewardDialog(layerNum,callback,titleStr,desStr,dataInfo)
	require "luascript/script/game/scene/gamedialog/armorMatrix/armorMatrixSellRewardSmallDialog"
	local sd=armorMatrixSellRewardSmallDialog:new(callback,dataInfo)
	sd:init(layerNum,titleStr,desStr)
end

function armorMatrixVoApi:showDescSmallDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/armorMatrix/armorMatrixDescSmallDialog"
	local sd=armorMatrixDescSmallDialog:new()
	sd:init(layerNum)
end

-- 装甲商店
function armorMatrixVoApi:showShopDialog(layerNum)
	-- require "luascript/script/game/scene/gamedialog/armorMatrix/armorMatrixShopDialog"
	-- local td=armorMatrixShopDialog:new()
	-- local tbArr={}
	-- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("market"),true,layerNum)
	-- sceneGame:addChild(dialog,layerNum)
	local td = allShopVoApi:showAllPropDialog(layerNum,"matr")
end

--mid:"m1" armorCfg.matrixList配置的key
function armorMatrixVoApi:getCfgByMid(mid)
	local armorCfg=armorMatrixVoApi:getArmorCfg()
	if armorCfg and armorCfg.matrixList and armorCfg.matrixList[mid] then
		return armorCfg.matrixList[mid]
	else
		return nil
	end
end

function armorMatrixVoApi:getColorByQuality(quality)
	local color=G_ColorWhite
	if quality then
	    if tonumber(quality)==1 then
	        color=G_ColorWhite
	    elseif tonumber(quality)==2 then
	        color=G_ColorGreen
	    elseif tonumber(quality)==3 then
	        color=G_ColorBlue
	    elseif tonumber(quality)==4 then
	        color=G_ColorPurple
	    elseif tonumber(quality)==5 then
	        color=G_ColorOrange
	    end
	end
    return color
end

function armorMatrixVoApi:getAttrByType(attType)
	local attrStr,pic="",""
	if attType==1 then
		pic="pro_ship_attack.png"
		attrStr=getlocal("tankAtk")
	elseif attType==2 then
		pic="pro_ship_life.png"
		attrStr=getlocal("tankBlood")
	elseif attType==3 then
		pic="skill_01.png"
		attrStr=getlocal("sample_skill_name_101")
	elseif attType==4 then
		pic="skill_02.png"
		attrStr=getlocal("sample_skill_name_102")
	elseif attType==5 then
		pic="skill_03.png"
		attrStr=getlocal("sample_skill_name_103")
	elseif attType==6 then
		pic="skill_04.png"
		attrStr=getlocal("sample_skill_name_104")
	end
    return attrStr,pic
end

function armorMatrixVoApi:getAttrAndValue(mid,level)
	local attrStr,value,vType="",0,0
	local cfg=self:getCfgByMid(mid)
	if cfg and cfg.attType and cfg.attType[1] then
		attrStr=self:getAttrByType(cfg.attType[1])
		if cfg.quality==5 then
			local lvGrow = 0
			for k, v in pairs(cfg.lvGrow) do 
				if level > k then
					lvGrow = lvGrow + v
				end
			end
			value = cfg.att[1]+lvGrow
		else
			value=cfg.att[1]+(level-1)*cfg.lvGrow[1]
		end
		vType=cfg.attType[1]
	end
    return attrStr,value,vType
end

function armorMatrixVoApi:getEquipedData(tankPos,index)
	local mid,id,lv
	local amInfo=self:getArmorMatrixInfo()
	if amInfo and amInfo.used then
		if tankPos and index then
			if amInfo.used[tankPos] and amInfo.used[tankPos][index] then
				id=amInfo.used[tankPos][index]
				if id and id~=0 then
					mid,lv=self:getMidAndLevelById(id)
					return mid,id,lv
				end
			end
		end
	end
	return mid,id,lv
end

function armorMatrixVoApi:getEquipedPos(id)
	local tankPos,index
	local amInfo=self:getArmorMatrixInfo()
	if id and amInfo and amInfo.used then
		for k,v in pairs(amInfo.used) do
			if v then
				for kk,vv in pairs(v) do
					if vv and vv==id then
						tankPos,index=k,kk
						return tankPos,index
					end
				end
			end
		end
	end
	return tankPos,index
end

function armorMatrixVoApi:getEquipedAttr(tankPos)
	local tb={0,0,0,0,0,0}
	local amInfo=self:getArmorMatrixInfo()
	if amInfo and amInfo.used and tankPos and amInfo.used[tankPos] then
		for k,v in pairs(amInfo.used[tankPos]) do
			local id=v
			-- print("id~~~~~~",id)
			if id and id~=0 then
				local mid,lv=self:getMidAndLevelById(id)
				-- print("mid,lv~~~~~~",mid,lv)
				local attrStr,value,vType=self:getAttrAndValue(mid,lv)
				if tb[vType]==nil then
					tb[vType]=value
				else
					tb[vType]=tb[vType]+value
				end
			end
		end
	end
	local allAddValue=0
	local tab=armorMatrixVoApi:getMatrixSuit(tankPos)
	for k,v in pairs(tab) do
		if v and v.value and v.value>0 then
			allAddValue=allAddValue+v.value
		end
	end
	for k,v in pairs(tb) do
		if tb[k] then
			tb[k]=tb[k]+(allAddValue*100)
		end
	end
	return tb
end

--获取图标
--param part: 支援部队的位置; iconWidth: 图标里面的配件的尺寸(无效); bgWidth: 整个图标的尺寸; callback: 点击事件; isAddLv 是否添加等级，默认添加
function armorMatrixVoApi:getArmorMatrixIcon(mid,iconWidth,bgWidth,callback,lv)
	local cfg=self:getCfgByMid(mid)
	local iconSP="armorMatrix_"..cfg.part..".png"
	local iconBg
	local quality=cfg.quality
	-- print("cfg.part,quality",cfg.part,quality)
	-- local spColor=ccc3(130, 169, 255)
	if(quality==1)then
		iconBg="equipBg_gray.png"
	elseif(quality==2)then
		iconBg="equipBg_green.png"
	elseif(quality==3)then
		iconBg="equipBg_blue.png"
	elseif(quality==4)then
		iconBg="equipBg_purple.png"
	elseif(quality==5)then
		iconBg="equipBg_orange.png"
	end
	local icon=GetBgIcon(iconSP,callback,iconBg,iconWidth,bgWidth)
	if icon then
		local scale=icon:getScale()
		local sp=icon:getChildByTag(99)
		if sp then
			--iconWidth无效，icon和sp固定比例1:1
			sp:setScale(bgWidth*(1/scale)/sp:getContentSize().width)
			-- if spColor then
			-- 	sp:setColor(spColor)
			-- end
		end
	end
	if lv then
		local lvBg=CCSprite:createWithSpriteFrameName("amHeaderBg.png")
		lvBg:setAnchorPoint(ccp(1,0))
		lvBg:setPosition(ccp(icon:getContentSize().width-6,7))
		lvBg:setFlipX(true)
		icon:addChild(lvBg)
		lvBg:setTag(2002)
		local lvLb=GetTTFLabel(getlocal("fightLevel",{lv}),25)
		lvLb:setAnchorPoint(ccp(1,0))
		lvLb:setPosition(ccp(icon:getContentSize().width-12,7))
		icon:addChild(lvLb,1)
		lvLb:setTag(2001)
		local color=self:getColorByQuality(quality)
		lvLb:setColor(color)
		lvBg:setScaleX((lvLb:getContentSize().width+25)/lvBg:getContentSize().width)
		lvBg:setScaleY(lvLb:getContentSize().height/lvBg:getContentSize().height)
	end
	-- if id then
	-- 	local idLb=GetTTFLabel(id,25)
	-- 	idLb:setPosition(getCenterPoint(icon))
	-- 	icon:addChild(idLb,1)
	-- end
	return icon
end

-- get 接口
function armorMatrixVoApi:armorGetData(refreshCalback)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.armor then
				if not self.armorMatrixInfo then
					require "luascript/script/game/gamemodel/armorMatrix/armorMatrixInfoVo"
					self.armorMatrixInfo=armorMatrixInfoVo:new()
				end
				self.armorMatrixInfo:initWithData(sData.data.armor)
				self.pullFreeFlag=false
				self.armorRequestFlag=true
			end
			if refreshCalback then
				refreshCalback()
			end
		end
	end
	if not self.armorMatrixInfo then
		socketHelper:armorGet(callback)
	elseif self.armorMatrixInfo and (not self.armorMatrixInfo.free or self.pullFreeFlag==true) then
		socketHelper:armorGet(callback)
	else
		if refreshCalback then
			refreshCalback()
		end
	end
	
end

-- 招募接口
function armorMatrixVoApi:armorRecruitData(free,num,type,refreshCalback)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.armor then
				if not self.armorMatrixInfo then
					require "luascript/script/game/gamemodel/armorMatrix/armorMatrixInfoVo"
					self.armorMatrixInfo=armorMatrixInfoVo:new()
				end
				self.armorMatrixInfo:initWithData(sData.data.armor)
			end

			-- if sData and sData.data and sData.data.amreward then
			-- 	for k,v in pairs(sData.data.amreward) do
			-- 		self:addArmorInfoById(k,v)
			-- 	end
			-- end
			local rewardP={}
			if sData and sData.data and sData.data.report then
				for k,v in pairs(sData.data.report) do
					local rewardItem=FormatItem(v)
					G_addPlayerAward(rewardItem[1].type,rewardItem[1].key,rewardItem[1].id,rewardItem[1].num)
					table.insert(rewardP,rewardItem[1])

					-- if rewardItem[1].type=="am" and rewardItem[1].key~="exp" then
					-- 	local cfg=self:getCfgByMid(rewardItem[1].key)
					-- 	if cfg.quality>=4 then
					-- 		local paramTab={}
					-- 		paramTab.functionStr="armor"
					-- 		paramTab.addStr="i_also_want"
					-- 		local message={key="armorMatrix_chatMessage1",param={playerVoApi:getPlayerName(),getlocal("armorMatrix_color_" .. cfg.quality),rewardItem[1].name}}
					-- 		chatVoApi:sendSystemMessage(message,paramTab)
					-- 	end
					-- end
					
				end
			end
			eventDispatcher:dispatchEvent("armorMatrix.dialog.refresh",{})
			if refreshCalback then
				refreshCalback(rewardP)
			end
		end
	end
	socketHelper:armorRecruit(free,num,type,callback)
end

-- 扩容 接口
function armorMatrixVoApi:armorAddBag(refreshCalback)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.armor then
				if not self.armorMatrixInfo then
					require "luascript/script/game/gamemodel/armorMatrix/armorMatrixInfoVo"
					self.armorMatrixInfo=armorMatrixInfoVo:new()
				end
				self.armorMatrixInfo:initWithData(sData.data.armor)
			end
			if refreshCalback then
				refreshCalback()
			end
		end
	end
	socketHelper:armorAddbag(callback)
end

-- 使用和卸下
function armorMatrixVoApi:armorUsedAndRemove(line,id,pos,refreshCalback)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.armor then
				if not self.armorMatrixInfo then
					require "luascript/script/game/gamemodel/armorMatrix/armorMatrixInfoVo"
					self.armorMatrixInfo=armorMatrixInfoVo:new()
				end
				self.armorMatrixInfo:initWithData(sData.data.armor)
			end
			eventDispatcher:dispatchEvent("armorMatrix.dialog.refresh",{})
			if refreshCalback then
				refreshCalback()
			end
			if(sData and sData.data and sData.data.oldfc and sData.data.newfc)then
				playerVoApi:setPlayerPower(tonumber(sData.data.newfc))
                G_showNumberChange(sData.data.oldfc,sData.data.newfc)
            end
		end
	end
    socketHelper:armorUsed(line,id,pos,callback)
end

-- 一键装配和部队位置互换
function armorMatrixVoApi:armorAssembly(line,line2,armors,refreshCalback)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.armor then
				if not self.armorMatrixInfo then
					require "luascript/script/game/gamemodel/armorMatrix/armorMatrixInfoVo"
					self.armorMatrixInfo=armorMatrixInfoVo:new()
				end
				self.armorMatrixInfo:initWithData(sData.data.armor)
			end
			if refreshCalback then
				refreshCalback(sData.data)
			end
			if(sData and sData.data and sData.data.oldfc and sData.data.newfc)then
				playerVoApi:setPlayerPower(tonumber(sData.data.newfc))
                G_showNumberChange(sData.data.oldfc,sData.data.newfc)
            end
		end
	end
    socketHelper:armorAssembly(line,line2,armors,callback)
end

-- 升级接口
function armorMatrixVoApi:armorUpgrade(id,level,refreshCalback)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.armor then
				local armor=sData.data.armor
				if armor.info then
					for k,v in pairs(armor.info) do
						self:addArmorInfoById(k,v)
					end
				end
				if armor.exp then
					self.armorMatrixInfo.exp=armor.exp
				end
			end
			eventDispatcher:dispatchEvent("armorMatrix.dialog.refresh",{})
			if refreshCalback then
				refreshCalback()
			end
		end
	end
	local _,nowLevel=armorMatrixVoApi:getMidAndLevelById(id)
	if nowLevel==playerVoApi:getPlayerLevel() then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armorMatrix_upgrade_limit"),30)
		return
	end
	socketHelper:armorUpgrade(id,level,callback)
end

-- 分解接口
function armorMatrixVoApi:armorResolve(id,quality,refreshCalback)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.armor and sData.data.armor then
				if not self.armorMatrixInfo then
					require "luascript/script/game/gamemodel/armorMatrix/armorMatrixInfoVo"
					self.armorMatrixInfo=armorMatrixInfoVo:new()
				end
				self.armorMatrixInfo:initWithData(sData.data.armor)
			end
			eventDispatcher:dispatchEvent("armorMatrix.dialog.refresh",{})
			if refreshCalback then
				refreshCalback()
			end
		end
	end
	socketHelper:armorResolve(id,quality,callback)
end

function armorMatrixVoApi:getArmorMatrixInfo()
	return self.armorMatrixInfo
end
function armorMatrixVoApi:getAllArmorMatrix()
	if self.armorMatrixInfo and self.armorMatrixInfo.info then
		return self.armorMatrixInfo.info
	else
		return nil
	end
end

function armorMatrixVoApi:getArmorCfg()
	return armorCfg
end

-- type 1:普通(只有单抽) 2：高级
-- num 1:免费或抽一次 10：抽10次
function armorMatrixVoApi:getRecruitCost(type,num)
	local armorCfg=self:getArmorCfg()
	local cost=0
	local freeFlag=false
	local freeNum=0
	local lastTime=0
	if self.armorMatrixInfo==nil then
		do return cost,freeFlag,freeNum,lastTime end
	end
	if type==1 then
		local freeTb=self.armorMatrixInfo.free[1]
		if freeTb[2]>0 then
			cost=0
			freeFlag=true
		else
			lastTime=freeTb[1]
			if base.serverTime-lastTime>=armorCfg.needFreeTime1 then
				cost=0
				freeFlag=true
			else
				cost=armorCfg.moneyCost1
			end
			lastTime=armorCfg.needFreeTime1+lastTime
		end
		freeNum=freeTb[2]+math.floor((base.serverTime-freeTb[1])/armorCfg.needFreeTime1)
		if freeNum>armorCfg.maxFreeNum1 then
			freeNum=armorCfg.maxFreeNum1
		end
	else
		if num==10 then
			cost=armorCfg.moneyCost2*num*armorCfg.discount
		else
			local freeTb=self.armorMatrixInfo.free[2]
			lastTime=freeTb[1]
			if freeTb[2]>0 then
				cost=0
				freeFlag=true
			else
				if base.serverTime-lastTime>=armorCfg.needFreeTime2 then
					cost=0
					freeFlag=true
				else
					cost=armorCfg.moneyCost2
				end
				lastTime=armorCfg.needFreeTime2+lastTime
			end
			
			freeNum=freeTb[2]+math.floor((base.serverTime-freeTb[1])/armorCfg.needFreeTime2)
			if freeNum>armorCfg.maxFreeNum2 then
				freeNum=armorCfg.maxFreeNum2
			end
		end
	end
	return cost,freeFlag,freeNum,lastTime
end

-- num:数量 （传0 判断是否满了）
-- return nil:数据未初始化
function armorMatrixVoApi:bagIsOver(num)
	if not self.armorMatrixInfo then
		return nil
	end

	if not num then
		num=0
	end

	local info=self.armorMatrixInfo.info or {} -- 所有装甲
	local haveNum=SizeOfTable(info)
	local usedNum=armorMatrixVoApi:getEquipedNum()

	local flag=true
	local leftNum=self.armorMatrixInfo.count-(haveNum-usedNum)
	if leftNum>=num then
		flag=false
	end

	return flag,leftNum
end

-- 仓库的list
function armorMatrixVoApi:getBagList(isSort)
	local bagList={}
	local info=self.armorMatrixInfo.info or {} -- 所有装甲
	local used=self.armorMatrixInfo.used or {}
	local tmpUsed={}

	for k,v in pairs(used) do
		for kk,vv in pairs(v) do
			tmpUsed[vv]=1
		end
	end
	for k,v in pairs(info) do
		if not tmpUsed[k] then
			table.insert(bagList,k)
		end
	end

	local armorCfg=self:getArmorCfg()
	local function sortFunc(a,b)
		local mid1=info[a][1]
		local mid2=info[b][1]
		local cfg1=self:getCfgByMid(mid1)
		local cfg2=self:getCfgByMid(mid2)
		local quality1=cfg1.quality
		local quality2=cfg2.quality
		if quality1==quality2 then
			local part1=cfg1.part
			local part2=cfg2.part
			if part1==part2 then
				return info[a][2]>info[b][2] -- 最后level
			else -- 次 部位
				return part1<part2
			end
		else -- 先品质
			return quality1>quality2
		end
	end
	if isSort~=false then
		table.sort(bagList,sortFunc)
	end
	return bagList
end

-- 根据id活动 mid 和 level
function armorMatrixVoApi:getMidAndLevelById(id)
	if id and self.armorMatrixInfo and self.armorMatrixInfo.info[id] then
		return self.armorMatrixInfo.info[id][1],self.armorMatrixInfo.info[id][2]
	end
	return nil
end

-- 获取本次扩容消耗金币
-- return nil:仓库已扩容到最大 cost:金币数量
function armorMatrixVoApi:getAddBagCost()
    local nowStoreCount=self.armorMatrixInfo.count or 50

    local armorCfg=self:getArmorCfg()

    local storeHouseMaxNum=armorCfg.storeHouseMaxNum
    if nowStoreCount>=storeHouseMaxNum then -- 已扩容到最大
    	return nil
    end

    local cost=0
    
    local addStoreHouseCost=armorCfg.addStoreHouseCost
    local startStoreCount=armorCfg.storeHouseNum
    local addStoreHouseNum=armorCfg.addStoreHouseNum
    local buyStoreNum=(nowStoreCount-startStoreCount)/addStoreHouseNum+1
    return addStoreHouseCost[buyStoreNum] or addStoreHouseCost[SizeOfTable(addStoreHouseCost)]
end

-- 能升的最大等级
-- return nil:已经升到最大等级 upgradeLevel:0 经验不足不能升级 n:最大能升n级  oneExp:升一级所需经验 totalExp：升 upgradeLevel 级所需经验
function armorMatrixVoApi:canUpgradeMaxlevel(id)
	local armorCfg=armorMatrixVoApi:getArmorCfg()
	local mid,level=self:getMidAndLevelById(id)

	if mid == nil then
		return nil
	end

	local armorCfg=armorMatrixVoApi:getArmorCfg()
	local cfg=self:getCfgByMid(mid)
	local quality=cfg.quality --  品质

	local levelLimit=armorCfg.upgradeMaxLv[quality]
	if level>=levelLimit then
		return nil -- 已经升到最大等级
	end

	-- 能升的最大等级不能超过玩家等级
	local playerLevel=playerVoApi:getPlayerLevel()
	if levelLimit>playerLevel then
		levelLimit=playerLevel
	end

	
	local part=cfg.part -- 支援部队部位


	local consumeTb=armorCfg["upgradeResource" .. quality][part]
	local haveExp=self.armorMatrixInfo.exp or 0
	
	local upgradeLevel=0
	for i=level+1,levelLimit do
		local needExp=consumeTb[i] or consumeTb[SizeOfTable(consumeTb)]
		if type(needExp)=="table" then
			needExp = needExp[1]
		end
		if needExp>haveExp then
			break
		else
			upgradeLevel=upgradeLevel+1
			haveExp=haveExp-needExp
		end
	end

	local oneExp=consumeTb[level+1] or consumeTb[SizeOfTable(consumeTb)] -- 升一级所需经验
	if type(needExp)=="table" then
		needExp = needExp[1]
	end
	local totalExp=(self.armorMatrixInfo.exp or 0)-haveExp -- 升 upgradeLevel 级所需jianyan

	if level==playerLevel and haveExp>=oneExp then
		return 1,oneExp,totalExp -- 按钮是亮的，能点击，提示装甲等级不能超过玩家等级
	end

	return upgradeLevel,oneExp,totalExp

end

-- 奖励是前台格式，添加经验
function armorMatrixVoApi:addArmorExp(value)
	if not self.armorMatrixInfo then -- 没有调过get不需要添加
		return 
	end
	self.armorMatrixInfo.exp=(self.armorMatrixInfo.exp or 0)+value
end

-- 获得新装甲前台自己添加
-- id=m198726 value={mid,level}
function armorMatrixVoApi:addArmorInfoById(id,value)
	if not self.armorMatrixInfo then -- 没有调过get不需要添加
		return 
	end
	if not self.armorMatrixInfo.info then
		self.armorMatrixInfo.info={}
	end
	self.armorMatrixInfo.info[id]=value
end

-- id=m198726
function armorMatrixVoApi:removeArmorInfoById(id)
	if not self.armorMatrixInfo then -- 没有调过get不需要删除（按说不应该存在这种情况）
		return 
	end
	if not self.armorMatrixInfo.info then
		return
	end
	self.armorMatrixInfo.info[id]=nil
end

--一只部队最好装甲矩阵(按战斗力排序)
--tankPos:第几只部队
function armorMatrixVoApi:getBestArmor(tankPos)
	-- 按位置排序(不包含套装)
	local armor={0,0,0,0,0,0}
	local isEmpty=true
	local isSame=true
	local tmpValueTb={{},{},{},{},{},{}}
	local bagList=self:getBagList(false)
	local function compareById(id)
		if id then
			local mid,lv=self:getMidAndLevelById(id)
			if mid and lv then
				local cfg=self:getCfgByMid(mid)
				if cfg and cfg.part and cfg.attType then
					local tmpTb=tmpValueTb[cfg.part]
					for k,v in pairs(cfg.attType) do
						if cfg.att and cfg.att[k] and cfg.lvGrow and cfg.lvGrow[k] then
							local value=cfg.att[k]+cfg.lvGrow[k]*lv
							if tmpTb and tmpTb[2] then
								local tmpValue=tmpTb[2] or 0
								if tmpValue<value then
									tmpValueTb[cfg.part]={id,value}
								end
							else
								tmpValueTb[cfg.part]={id,value}
							end
						end
					end
				end
			end
		end
	end
	for k,v in pairs(bagList) do
		compareById(v)
	end
	local amInfo=self:getArmorMatrixInfo()
	local usedTb={}
	if amInfo and amInfo.used and amInfo.used[tankPos] then
		usedTb=amInfo.used[tankPos]
		for k,v in pairs(usedTb) do
			compareById(v)
		end
	end
	-- print("tmpValueTb~~~~~~~~",tmpValueTb)
	-- G_dayin(tmpValueTb)
	for k,v in pairs(tmpValueTb) do
		if v and v[1] then
			armor[k]=v[1]
			isEmpty=false
		end
	end
	--isSame
	for k,v in pairs(armor) do
		if v and usedTb then
			-- print("v,usedTb[k]",v,usedTb[k])
			if usedTb[k]==nil and (v and v~=0) then
				isSame=false
			elseif v==usedTb[k] then
				-- isSame=true
			elseif v==0 or usedTb[k]==0 then
				isSame=false
			else
				local mid1,lv1=self:getMidAndLevelById(v)
				local mid2,lv2=self:getMidAndLevelById(usedTb[k])
				-- print("mid1,mid2,lv1,lv2",mid1,mid2,lv1,lv2)
				if mid1==mid2 and lv1==lv2 then
					-- isSame=true
				else
					isSame=false
				end
			end
		end
	end
	if isEmpty==true then
		isSame=false
	end
	-- print("armor,isEmpty,isSame",armor,isEmpty,isSame)
	return armor,isEmpty,isSame
end

--根据部队属性获取部队名字
function armorMatrixVoApi:getNameByAttr(tankPos)
	local name,attKey,value="",0,0
	local tab=self:getEquipedAttr(tankPos)
	if tab then
		for k,v in pairs(tab) do
			if v and value<v then
				attKey=k
				value=v
			end
		end
	end
	if attKey>0 then
		name=self:getAttrByType(attKey)
	end
	return name
end

--可以装配的装甲矩阵
function armorMatrixVoApi:canEquipArmor(tankPos,index,perPageNum)
	local list={}
	local infoData=armorMatrixVoApi:getArmorMatrixInfo()
	local bagList=self:getBagList(false)
	if bagList then
		for k,v in pairs(bagList) do
			if v and infoData.info and infoData.info[v] then
				local id=v
				local mid=infoData.info[v][1]
				local lv=tonumber(infoData.info[v][2])
				local cfg=armorMatrixVoApi:getCfgByMid(mid)
				-- print("cfg.part,self.index",cfg.part,self.index)
				if cfg and cfg.part and cfg.part==index then
					local index1=tonumber(string.sub(mid,2))
					table.insert(list,{id=id,mid=mid,lv=lv,quality=cfg.quality,index=index1})
				end
			end
		end
		local function sortFunc(a,b)
			if a.quality==b.quality then
				if a.lv==b.lv then
					return a.index<b.index
				else
					return a.lv>b.lv
				end
			else
				return a.quality>b.quality
			end
		end
		table.sort(list,sortFunc)
	end
	local tmpList=list
	if perPageNum and perPageNum>0 then
		tmpList={}
		-- local listNum=SizeOfTable(list)
		-- local maxPage=math.ceil(listNum/perPageNum)
		for k,v in pairs(list) do
			local page=math.ceil(k/perPageNum)
			-- print("k,page,v.quality,v.lv,v.mid",k,page,v.quality,v.lv,v.mid)
			if tmpList[page]==nil then
				tmpList[page]={}
			end
			table.insert(tmpList[page],v)
		end
	end
	return tmpList
end

--套装效果 返回数量位置固定{2,4,2}，有4件，前面2项品阶相同；没有4件按品阶顺序
function armorMatrixVoApi:getMatrixSuit(tankPos,amTab)
	local armorCfg=armorMatrixVoApi:getArmorCfg()
	local amInfo=self:getArmorMatrixInfo()
	local tmpTb={}
	local tb={}
	if amTab then
		tb=amTab
	else
		if amInfo and amInfo.used and tankPos and amInfo.used[tankPos] then
			tb=amInfo.used[tankPos]
		end
	end
	for k,v in pairs(tb) do
		local id=v
		if id and id~=0 then
			local mid,lv=self:getMidAndLevelById(id)
			local cfg=self:getCfgByMid(mid)
			local quality=cfg.quality
			if tmpTb[quality] then
				tmpTb[quality]=tmpTb[quality]+1
			else
				tmpTb[quality]=1
			end
		end
	end

	local tab={}
	for i=1,3 do
		if tab[i]==nil then
			local item={quality=1,num=2,value=0}
			if i==2 then
				item.num=4
			end
			tab[i]=item
		end
	end
	local minNum,midNum,maxNum=tab[1].num,tab[2].num,tab[1].num+tab[2].num
	if (tmpTb[3] and tmpTb[3]>=maxNum) or (tmpTb[4] and tmpTb[4]>=maxNum) or (tmpTb[5] and tmpTb[5]>=maxNum) then --6件套
		if tmpTb[3] and tmpTb[3]>=maxNum then --蓝色6件套
			tab[1].quality=3
			tab[2].quality=3
			tab[3].quality=3
		elseif tmpTb[4] and tmpTb[4]>=maxNum then --紫色6件套
			tab[1].quality=4
			tab[2].quality=4
			tab[3].quality=4
		else 									--橙色6件套
			tab[1].quality=5
			tab[2].quality=5
			tab[3].quality=5
		end
	elseif (tmpTb[3] and tmpTb[3]>=midNum) or (tmpTb[4] and tmpTb[4]>=midNum) or (tmpTb[5] and tmpTb[5]>=midNum) then --4件套
		if tmpTb[3] and tmpTb[3]>=midNum then --蓝色4件套
			tab[1].quality=3
			tab[2].quality=3

			--判断剩余两件是什么套装
			if tmpTb[4] and tmpTb[4]>=minNum then --紫色2件套
				tab[3].quality=4
			elseif tmpTb[5] and tmpTb[5]>=minNum then --橙色2件套
				tab[3].quality=5
			end
		elseif tmpTb[4] and tmpTb[4]>=midNum then --紫色4件套
			tab[1].quality=4
			tab[2].quality=4

			--判断剩余两件是什么套装
			if tmpTb[3] and tmpTb[3]>=minNum then --蓝色2件套
				tab[1].quality=3
				tab[3].quality=4
			elseif tmpTb[5] and tmpTb[5]>=minNum then --橙色2件套
				tab[3].quality=5
			end
		elseif tmpTb[5] and tmpTb[5]>=midNum then --橙色4件套
			tab[1].quality=5
			tab[2].quality=5

			--判断剩余两件是什么套装
			if tmpTb[3] and tmpTb[3]>=minNum then --蓝色2件套
				tab[1].quality=3
				tab[3].quality=5
			elseif tmpTb[4] and tmpTb[4]>=minNum then --紫色2件套
				tab[1].quality=4
				tab[3].quality=5
			end
		end
	elseif (tmpTb[3] and tmpTb[3]>=minNum) or (tmpTb[4] and tmpTb[4]>=minNum) or (tmpTb[5] and tmpTb[5]>=minNum) then --2件套
		if (tmpTb[4] and tmpTb[4]>=minNum) and (tmpTb[5] and tmpTb[5]>=minNum) then --2件紫色 2件橙色
			tab[1].quality=4
			tab[3].quality=5
		elseif (tmpTb[3] and tmpTb[3]>=minNum) and (tmpTb[5] and tmpTb[5]>=minNum) then --2件蓝色 2件橙色
			tab[1].quality=3
			tab[3].quality=5
		elseif (tmpTb[3] and tmpTb[3]>=minNum) and (tmpTb[4] and tmpTb[4]>=minNum) then --2件蓝色 2件紫色
			tab[1].quality=3
			tab[3].quality=4
		elseif tmpTb[5] and tmpTb[5]>=minNum then --橙色2件套
			tab[1].quality=5
		elseif tmpTb[4] and tmpTb[4]>=minNum then --紫色2件套
			tab[1].quality=4
		elseif tmpTb[3] and tmpTb[3]>=minNum then --蓝色2件套
			tab[1].quality=3
		end 
	end
	for k,v in pairs(tab) do
		if v and v.quality and v.num then
			if armorCfg.matrixSuit and armorCfg.matrixSuit[v.quality] and armorCfg.matrixSuit[v.quality][v.num] then
				local value=armorCfg.matrixSuit[v.quality][v.num]
				if type(value)=="table" then
					value=value[1]
				end
				tab[k].value=value
			end
		end
	end

	-- local tab={}
	-- local isInsert
	-- local function checkSuit()
	-- 	isInsert=false
	-- 	for k,v in pairs(tmpTb) do
	-- 		if armorCfg and armorCfg.matrixSuit and armorCfg.matrixSuit[k] then
	-- 			local tb=armorCfg.matrixSuit[k]
	-- 			local value=0
	-- 			for kk,vv in pairs(tb) do
	-- 				if vv and tmpTb[k]>=kk then
	-- 					value=kk
	-- 					table.insert(tab,{quality=k,num=kk,value=vv})
	-- 					isInsert=true
	-- 				end
	-- 			end
	-- 			tmpTb[k]=tmpTb[k]-value
	-- 		end
	-- 	end
	-- 	if isInsert==true then
	-- 		checkSuit()
	-- 	end
	-- end
	-- checkSuit()

	return tab
end

--套装图标
function armorMatrixVoApi:getSuitIcon(quality,num,size,callback,isNumGray)
	local iconBg
	if(quality==0 or quality==1)then
		iconBg="equipBg_gray.png"
	elseif(quality==2)then
		iconBg="equipBg_green.png"
	elseif(quality==3)then
		iconBg="equipBg_blue.png"
	elseif(quality==4)then
		iconBg="equipBg_purple.png"
	elseif(quality==5)then
		iconBg="equipBg_orange.png"
	end
	local icon
	if iconBg then
		icon=LuaCCSprite:createWithSpriteFrameName(iconBg,callback)
		icon:setScale(size/icon:getContentSize().width)
		local suitIcon
		if isNumGray==true then
			suitIcon=GraySprite:createWithSpriteFrameName("amSuitIcon.png")
		else
			suitIcon=CCSprite:createWithSpriteFrameName("amSuitIcon.png")
		end
		suitIcon:setPosition(getCenterPoint(icon))
		icon:addChild(suitIcon)
		if num and num>0 then
			if isNumGray==true or quality==3 or quality==4 or quality==5 then
				local numBg
				if isNumGray==true then
					numBg=GraySprite:createWithSpriteFrameName("amSuitBg3.png")
				else
					numBg=CCSprite:createWithSpriteFrameName("amSuitBg"..quality..".png")
				end
				if numBg then
					numBg:setPosition(ccp(icon:getContentSize().width/2,10))
					icon:addChild(numBg,1)
					numBg:setScale(2)
					local numLb=GetTTFLabel(num,19)
					numLb:setPosition(getCenterPoint(numBg))
					numBg:addChild(numLb,1)
				end
			end
		end
	end
	return icon
end

function armorMatrixVoApi:getEquipedNum()
	local num,maxNum=0,36
	local amInfo=self:getArmorMatrixInfo()
	if amInfo and amInfo.used then
		for k,v in pairs(amInfo.used) do
			if v then
				for kk,vv in pairs(v) do
					if vv and vv~=0 then
						num=num+1
					end
				end
			end
		end
	end
	return num,maxNum
end

function armorMatrixVoApi:getDecomposeExp(mid,lv)
	local armorCfg=self:getArmorCfg()

	local cfg=self:getCfgByMid(mid)
	local deExp=cfg.decompose.exp

	local quality=cfg.quality --  品质
	local part=cfg.part -- 支援部队部位
	local consumeTb=armorCfg["upgradeResource" .. quality][part]
	if lv==0 then
		lv=1
	end
	local needExp=0
	for i=lv,1,-1 do
		local value=consumeTb[i]
		if type(value)=="table" then
			value=value[1]
		end
		needExp=needExp+value
	end

	local tatalExp=deExp+math.floor(needExp*armorCfg.resolveupgradeResource)
	return tatalExp
end

function armorMatrixVoApi:getDescByMid(mid,level)
	local desc=""
	if mid then
		local cfg=self:getCfgByMid(mid)
		if cfg and cfg.attType and cfg.attType[1] then
			local attrStr=self:getAttrByType(cfg.attType[1]) or ""
			if cfg.quality==5 then
				if level==nil then
					level=1
				end
				local value=cfg.lvGrow[level] or 0
				desc=getlocal("armorMatrix_desc_orange",{value,attrStr})
			else
				local value=cfg.lvGrow[1] or 0
				desc=getlocal("armorMatrix_desc_all",{value,attrStr})
			end
		end
	end
	return desc
end

function armorMatrixVoApi:hasBetterTb(tankPos)
	local tab={0,0,0,0,0,0}
    local tmpValueTb={{},{},{},{},{},{}}
	local function compareById(id)
		if id then
			local mid,lv=self:getMidAndLevelById(id)
			if mid and lv then
				local cfg=self:getCfgByMid(mid)
				if cfg and cfg.part and cfg.quality then
					local tmpTb=tmpValueTb[cfg.part]
					local tmpQuality,tmpValue=0,0
					if tmpTb and tmpTb[2] then
						tmpQuality=tmpTb[2] or 0
					end
					if tmpTb and tmpTb[3] then
						tmpValue=tmpTb[3] or 0
					end
					local value=0
					if cfg.attType then
						for k,v in pairs(cfg.attType) do
							if cfg.att and cfg.att[k] and cfg.lvGrow and cfg.lvGrow[k] then
								value=cfg.att[k]+cfg.lvGrow[k]*lv
							end
						end
					end
					if tmpQuality<cfg.quality then
						tmpValueTb[cfg.part]={id,cfg.quality,value}
					elseif tmpQuality==cfg.quality then
						if tmpValue<value then
							tmpValueTb[cfg.part]={id,cfg.quality,value}
						end
					end
				end
			end
		end
	end
	local bagList=self:getBagList(false)
	for k,v in pairs(bagList) do
		compareById(v)
	end
	local amInfo=self:getArmorMatrixInfo()
	if amInfo and amInfo.used and amInfo.used[tankPos] then
		for k,v in pairs(amInfo.used[tankPos]) do
			compareById(v)
		end
	end
	-- local tmpValueTb=self:getBestArmor(tankPos)
    for i=1,6 do
        local amId
        if tmpValueTb and tmpValueTb[i] then
        	if type(tmpValueTb[i])=="table" and tmpValueTb[i][1] then
        		amId=tmpValueTb[i][1]
        	else
	        	amId=tmpValueTb[i]
	        end
        end
        if amId and amId~=0 then
        	local mid,id,lv=self:getEquipedData(tankPos,i)
        	if mid and mid~=0 and id and id~=0 then
	            local amInfo=self:getArmorMatrixInfo()
	            if amInfo and amInfo.info and amInfo.info[amId] and amInfo.info[amId][1] then
	                local amMid=amInfo.info[amId][1]
	                local amLv=amInfo.info[amId][2]
	                if amMid==mid and amLv==lv then
	                elseif amMid and amMid~=0 then
	                	tab[i]=1
	                end
	            end
	        end
        end
    end
    return tab
end

--一页显示装甲矩阵数量
function armorMatrixVoApi:perPageShowNum()
	local amCfg=self:getArmorCfg()
	if amCfg and amCfg.perPageShowNum then
		return amCfg.perPageShowNum
	else
		return 25
	end
end

--根据位置判断装配的装甲矩阵是否为空
function armorMatrixVoApi:isEmptyByPos(tankPos)
	local isEmpty=true
	local amInfo=self:getArmorMatrixInfo()
	if amInfo and amInfo.used and tankPos and amInfo.used[tankPos] then
		for k,v in pairs(amInfo.used[tankPos]) do
			if v and v~=0 then
				isEmpty=false
			end
		end
	end
	return isEmpty
end

--只设置部分数据（战力引导面板）
function armorMatrixVoApi:setPartArmorData(partData)
	if not self.armorMatrixInfo then
		require "luascript/script/game/gamemodel/armorMatrix/armorMatrixInfoVo"
		self.armorMatrixInfo=armorMatrixInfoVo:new()
	end
	if partData and self.armorMatrixInfo then
		self.armorMatrixInfo:initWithData(partData)
		if partData.free then --如果拉取的是免费抽取的相关数据的话置标识为true
			self.pullFreeFlag=true
		end
	end
end

-- 新加  矩阵商店
function armorMatrixVoApi:getArmorshopCfg()
	require "luascript/script/config/gameconfig/armorshopCfg"
	return armorshopCfg
end

function armorMatrixVoApi:shopExchange(refreshFunc,type,pid)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.armor then
				if not self.armorMatrixInfo then
					require "luascript/script/game/gamemodel/armorMatrix/armorMatrixInfoVo"
					self.armorMatrixInfo=armorMatrixInfoVo:new()
				end
				self.armorMatrixInfo:initWithData(sData.data.armor)
			end
			if refreshFunc then
				refreshFunc()
			end
		end
	end
	socketHelper:armorShopExchange(callback,type,pid)
end

function armorMatrixVoApi:getShopInfo()
	local shopType=1
	local shopInfo={}
	local shopNum=0
	if self.armorMatrixInfo then
		local armorshopCfg=self:getArmorshopCfg()
		local preshoplist=armorshopCfg.preshoplist
		local preNum=SizeOfTable(preshoplist)

		local exinfo=self.armorMatrixInfo.exinfo or {}
		local p=exinfo.p or {}
		local pNum=SizeOfTable(p)

		shopType=2
		for k,v in pairs(preshoplist) do
			local buyNum=p[k] or 0
			if buyNum<v.limittimes then
				shopType=1
				break
			end
		end

		if shopType==1 then
			local gems=playerVoApi:getGems() or 0
			for i=1,preNum do
				local id="i" .. i 
				local buyNum=p[id] or 0
				local preInfo=preshoplist[id]
				if buyNum<preInfo.limittimes then
					local index=i+10000
					if gems>=preInfo.price then
						index=i
					end
					table.insert(shopInfo,{index=index,id=id})
				end
				
			end
		else
			local exp=self.armorMatrixInfo.exp or 0

			local exinfo=self.armorMatrixInfo.exinfo or {}
			local s=exinfo.s or {}
			local ts=s[1] or 0
			if G_isToday(ts)==false then
				s[1]=base.serverTime
				s[2]={}
			end

			local shoplist=armorshopCfg.shoplist
			local sNum=SizeOfTable(shoplist)
			for i=1,sNum do
				local id="i" .. i 
				local buyNum=(s[2] or {})[id] or 0
				local sInfo=shoplist[id]
				local index=i
				if buyNum>=sInfo.limittimes then
					index=i+10000
				else
					if exp>=sInfo.aExpcost then
						index=i
					else
						index=1000+i
					end
				end
				table.insert(shopInfo,{index=index,id=id})
			end
		end
		local function sortFunc(a,b)
			return a.index<b.index
		end
		table.sort(shopInfo,sortFunc)
		shopNum=#shopInfo
	end
	return shopType,shopInfo,shopNum
end

function armorMatrixVoApi:getUsedQualityNum(quality,isPrecision)--拿到 对应颜色的矩阵个数 ：1 白色，2 绿色，3 蓝色，4 紫色，5 橙色 --isPrecision : 是否要精准数值（区别紫色，和 橙色 数量）
	local num=0
	if self.armorMatrixInfo then
		local usedInfo=self.armorMatrixInfo.used or {}
		local armorCfg=self.getArmorCfg()
		local matrixList=armorCfg.matrixList
		for k,v in pairs(usedInfo) do
			if v then
				for kk,vv in pairs(v) do
					if vv then
						local mid=self:getMidAndLevelById(vv)
						if mid then
							local nowQuality=matrixList[mid].quality
							if isPrecision then
								if nowQuality == quality then
									num=num+1
								end
							else
								if (quality>=4 and nowQuality>=quality) or nowQuality==quality then
									num=num+1
								end
							end
						end
					end
				end
			end
		end

	end
	return num
end

function armorMatrixVoApi:getUsedQualityAllLevel()--拿到所有矩阵的等级之和 等级基础从紫色开始 橙色自动 + 50级
	local num,allLv =0,0
	if self.armorMatrixInfo then
		local usedInfo=self.armorMatrixInfo.used or {}
		local armorCfg=self.getArmorCfg()
		local matrixList=armorCfg.matrixList
		for k,v in pairs(usedInfo) do
			if v then
				for kk,vv in pairs(v) do
					if vv then
						local mid,lv=self:getMidAndLevelById(vv)
						if mid and lv and tonumber(lv) then
							local nowQuality=matrixList[mid].quality
							if nowQuality == 4 then
								allLv = allLv + lv
							elseif nowQuality == 5 then--判断 如果是橙色 自动 加上 50级
								allLv = allLv + 50 + lv
							end
						end
					end
				end
			end
		end

	end
	return allLv
end

function armorMatrixVoApi:isAddShopTip()
	local flag=false
	if self.armorMatrixInfo then
		local armorshopCfg=self:getArmorshopCfg()
		local preshoplist=armorshopCfg.preshoplist

		local exinfo=self.armorMatrixInfo.exinfo or {}
		local p=exinfo.p or {}

		local gems=playerVoApi:getGems() or 0

		for k,v in pairs(preshoplist) do
			local buyNum=p[k] or 0
			if buyNum<v.limittimes then
				if gems>=v.price then
					local havaNum=self:getUsedQualityNum(v.needquality)
					if havaNum>=v.needNum then
						return true
					end
				end
			end
		end
	end
	return flag
end

function armorMatrixVoApi:isOpen()
	if self:isOpenArmorMatrix()==true then
		local permitLevel = self:getPermitLevel()
	    if permitLevel and playerVoApi:getPlayerLevel()>=permitLevel then
	    	return true
	    end
	end
	return false
end

--获取免费数据
--[[@return
	{ 
		普通：{ 当前免费次数, 最大免费次数 },
		高级：{ 当前免费次数, 最大免费次数 } 
	}
--]]
function armorMatrixVoApi:getFreeData()
	local armorCfg=self:getArmorCfg()
	local _,freeFlag1,freeNum1,lastTime1=self:getRecruitCost(1,1)
    local _,freeFlag2,freeNum2,lastTime2=self:getRecruitCost(2,1)
    if freeNum1<0 then
    	freeNum1=0
    end
    if freeNum2<0 then
    	freeNum2=0
    end
    return { {freeNum1,armorCfg.maxFreeNum1}, {freeNum2,armorCfg.maxFreeNum2} }
end

function armorMatrixVoApi:getBagListNum()
	if self.armorMatrixInfo.info~=nil then
		self.armorMatrixInfo.curNum=SizeOfTable(self:getBagList(false))
	end
	return self.armorMatrixInfo.curNum
end

--仓库是否已满
function armorMatrixVoApi:isFull()
	local armorMatrixInfo=self:getArmorMatrixInfo()
	local count=50
	if armorMatrixInfo then
		count=armorMatrixInfo.count
	end
	if self:getBagListNum()==count then
		return true
	end
	return false
end

--是否可以突破
function armorMatrixVoApi:isCanBreakThrough(id)
	if base.armorbr == 1 then
		local mid,level = armorMatrixVoApi:getMidAndLevelById(id)
		if mid and level then
			local armorCfg=self:getArmorCfg()
			local cfg=self:getCfgByMid(mid)
			if cfg.breakthrough and level>=armorCfg.upgradeMaxLv[cfg.quality] then
				return true
			end
		end
	end
	return false
end

--橙色矩阵突破接口
function armorMatrixVoApi:armorMatrixTP(mid,callback)
	local function socketCallback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.armor then
				if not self.armorMatrixInfo then
					require "luascript/script/game/gamemodel/armorMatrix/armorMatrixInfoVo"
					self.armorMatrixInfo=armorMatrixInfoVo:new()
				end
				self.armorMatrixInfo:initWithData(sData.data.armor)
				eventDispatcher:dispatchEvent("armorMatrix.dialog.refresh",{})
				if callback then
					callback()
				end
			end
		end
	end
	socketHelper:armorMatrixTP(mid,socketCallback)
end

--橙色矩阵的流光效果
function armorMatrixVoApi:addLightEffect(parentSp, mid)
    local cfg = self:getCfgByMid(mid)
    if cfg and cfg.quality==5 then
        local firstFrameSp = CCSprite:createWithSpriteFrameName("am_lightEffect_1.png")
        if firstFrameSp then
	        local blendFunc = ccBlendFunc:new()
	        blendFunc.src = GL_ONE
	        blendFunc.dst = GL_ONE_MINUS_SRC_COLOR
	        firstFrameSp:setBlendFunc(blendFunc)
	        local frameArray = CCArray:create()
	        for i = 1, 10 do
	            local frameName = "am_lightEffect_" .. i .. ".png"
	            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName)
	            if frame then
	                frameArray:addObject(frame)
	            end
	        end
	        local animation = CCAnimation:createWithSpriteFrames(frameArray, 0.08)
	        local animate = CCAnimate:create(animation)
	        local animArray = CCArray:create()
	        animArray:addObject(animate)
	        local seq = CCSequence:create(animArray)
	        firstFrameSp:setPosition(getCenterPoint(parentSp))
	        parentSp:addChild(firstFrameSp,5)
	        firstFrameSp:runAction(CCRepeatForever:create(seq))
	    end
    end
end
