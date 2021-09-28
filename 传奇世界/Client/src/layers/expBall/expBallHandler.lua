

local expBallConfig = function(thePropId,isBind,propNum,pos,gird)
	local MpropOp = require("src/config/propOp")
	if not MpropOp.canUsedInBatch(thePropId) then
		propNum = 1
	end
	local MRoleStruct = require("src/layers/role/RoleStruct")
	local lv = MRoleStruct:getAttr(ROLE_LEVEL)
	local limitLv = getConfigItemByKey("propCfg","q_id",thePropId,"q_level")
	local bag = MPackManager:getPack(MPackStruct.eBag)
	local bank = MPackManager:getPack(MPackStruct.eBank)
	local allBag = bag:maxNumOfGirdCanOpen()
	local haveBag = bag:numOfGirdOpened()
	local allBank = bank:maxNumOfGirdCanOpen()
	local haveBank = bank:numOfGirdOpened()
	local school = MRoleStruct:getAttr(ROLE_SCHOOL)

	local skillBook = {
		{["1511"] = true,["1512"] = true,["1513"] = true,["6003"] = true,["6000"] = true,["6200010"] = true,["6200009"] = true,["6009"] = true,["6200008"] = true},
		{["1514"] = true,["1515"] = true,["1516"] = true,["1517"] = true,["5998"] = true,["6001"] = true,["6200015"] = true,["6200016"] = true,["6007"] = true,["6200014"] = true},
		{["1518"] = true,["1519"] = true,["1520"] = true,["1521"] = true,["1522"] = true,["1523"] = true,["6002"] = true,["5999"] = true,["6200022"] = true,["6200023"] = true,["6008"] = true,["6200021"] = true}
	}



	local showTip = function(kind,thePropId,countDown)
		if getGameSetById(GAME_SET_PROPTIP) == 1 then 
			if kind == 1 then
				if not getRunScene():getChildByTag(thePropId+6520) then
					require("src/layers/tuto/AutoConfigNode").new(thePropId,3,countDown,thePropId+6520)
				end
			elseif kind == 2 then
				local temp = 20
				if isBind then
					temp = 10
				end

				if G_MAINSCENE and G_MAINSCENE.tipLayer then
					if G_MAINSCENE.tipLayer:getChildByTag(thePropId+temp) ~= nil then
						local theLayer1 = G_MAINSCENE.tipLayer:getChildByTag(thePropId+temp)
						removeFromParent(theLayer1)
						theLayer1 = nil
					end
				end
				local layer1 = require("src/layers/expBall/spoolerLayer").new(thePropId,isBind,propNum,pos)
				if G_MAINSCENE and G_MAINSCENE.tipLayer and G_MAINSCENE.networkHander  then
					if G_MAINSCENE.tipLayer:getChildByTag(thePropId+temp) == nil then
						layer1:setPosition(cc.p(0,0))
						layer1:setTag(thePropId+temp)

						G_MAINSCENE.tipLayer:addChild(layer1)
					end
				end			
			end
		end
	end	

	if lv and ((thePropId == 1070 and lv >= limitLv and (allBag - haveBag) > 0) or 
			(thePropId == 1071 and lv >= limitLv and (allBank - haveBank) > 0)) then
		if G_MAINSCENE and G_MAINSCENE.tipLayer then
			if G_MAINSCENE.tipLayer:getChildByTag(thePropId+6520) ~= nil then
				local theLayer = G_MAINSCENE.tipLayer:getChildByTag(thePropId+6520)
				removeFromParent(theLayer)
				theLayer = nil
			end
		end
		local countDown = nil
		if thePropId == 1070 or thePropId == 1071 then
			countDown = 6
		end
		showTip(1,thePropId,countDown)
	end
	if lv and skillBook[school][ thePropId .. ""] then
		local MskillOp = require "src/config/skillOp"
  		local skillTab = MskillOp:allSkills() 
  		local skillID = getConfigItemByKey("propCfg","q_id",thePropId,"skillID")
  		for k,v in pairs(G_SKILLPROP_POS) do
  			if v[3] == skillID then
  				return
  			end
  		end 
  		showTip(2,thePropId)
	end

	local taskIds = nil 
	if DATA_Mission then
		taskIds = DATA_Mission:getBranchPropID()
	end
	
	--提示id必须写死 每个id都可能有特殊条件
	if lv and ((thePropId >= 1212 and thePropId <= 1213) or
		(thePropId >= 2001  and thePropId <= 2012) or 
		(thePropId >= 10001 and thePropId <= 11000) or
		(thePropId >= 20031 and thePropId <= 20032) or
		(thePropId >= 1072 and thePropId <= 1073) or
		(thePropId >= 1441 and thePropId <= 1442) or
		( taskIds and taskIds[ thePropId .. "" ] ) or
		thePropId == 111002) and lv >= limitLv then		

		showTip(2,thePropId)
	end
end

expBallMessage = function(observable, event, pos, pos1, gird)

	-- if G_ROLE_MAIN and MRoleStruct:getAttr(ROLE_LEVEL) >= 30 and (event == "-" or event == "=") then		
	-- 	G_MAINSCENE:buyDrug() --物品减少 检查药品提示
 --    end

	if event == "+" or event == "=" then
		local protoId = MPackStruct.protoIdFromGird(gird)       --根据格子索引获取物品id
		local isBind = MPackStruct.attrFromGird(gird, MPackStruct.eAttrBind)  --获得格子的物品绑定属性
		local propNum = MPackStruct.overlayFromGird(gird)  --数量	
		expBallConfig(protoId,isBind,propNum,pos,gird)
		if G_ROLE_MAIN and MRoleStruct:getAttr(ROLE_LEVEL) >= 30 then
			G_MAINSCENE:buyDrug(protoId,false)--物品增加时 检查药品提示
		end
		if protoId == 2015 then
			checkSkillRed()
		end
		if protoId == 6200091 then
			checkWingSkillRed()
		end
	end

    DATA_Mission:UpdateCollectTask();
end

function expBallInit(theId)
	local MRoleStruct = require("src/layers/role/RoleStruct")
	local lv = MRoleStruct:getAttr(ROLE_LEVEL)
	local limitLv = getConfigItemByKey("propCfg","q_id",theId,"q_level")
	if lv >= limitLv then
		expBallConfig(theId)
	end
end
function spoolerInit(theId,theBind,thePropNum,thePropPos)
	local MRoleStruct = require("src/layers/role/RoleStruct")
	local lv = MRoleStruct:getAttr(ROLE_LEVEL)
	if lv then
		local limitLv = getConfigItemByKey("propCfg","q_id",theId,"q_level")
		if limitLv and lv >= limitLv then
			expBallConfig(theId,theBind,thePropNum,thePropPos)
		end
	end
end