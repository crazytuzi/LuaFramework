
local GetCardManager = class('GetCardManager')

local yuanBaoCost = {ConstantData:getValue("Recruit.Consume.Sycee.Hundred"), ConstantData:getValue("Recruit.Consume.Sycee.Million"), 
					 ConstantData:getValue("Recruit.Consume.Sycee.Million.Batch")}

RecruitRateData = require('lua.table.t_s_recruit_rate')

function GetCardManager:ctor()
	TFDirector:addProto(s2c.GET_CARD_ROLE, self, self.GetRoleState)
	TFDirector:addProto(s2c.GET_CARD_ROLE_RESULT, self, self.GetRoleResult)		
	self.cardStateInfo = {}
end

function GetCardManager:SendQueryStateMsg()
	local msg = {}
	TFDirector:send(c2s.QUERY_GET_ROLE, msg) 
end

function GetCardManager:GetRoleState(event)
	print("GetRoleState", event.data.stateList)
	local stateList = event.data.stateList
	if stateList == nil then
		return
	end
	for i=1,3 do
		self.cardStateInfo[i] = stateList[i]
		self.cardStateInfo[i].clientTime = MainPlayer:getNowtime() + self.cardStateInfo[i].cdTime
	end
end

function GetCardManager:IsFreeGet(cardType)

	local state = self.cardStateInfo[cardType]
	if not state then
		return false
	end
	if cardType <= 2 then
		if state.cdTime <= 0 and state.freeTimes >= 1 then
			return true
		elseif state.cdTime > 0  and state.clientTime < MainPlayer:getNowtime() and state.freeTimes >= 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function GetCardManager:SendGetCardMsg(cardType, freeGet)
	showLoading()

	local getRoleMsg = {cardType, freeGet}
	TFDirector:send(c2s.GET_CARD_ROLE, getRoleMsg)
	self.lastSendTime = os.time()

	return true
end

function GetCardManager:SendGetCardMsgWithAnimation(cardType)
	local bFreeGet = false

	-- 判断道具
	local enoughTool = false
	local RecruitData = RecruitRateData:objectByID(cardType)
    if RecruitData then
        local goodId 	= RecruitData.consume_goods_id
        local costTool 	= RecruitData.consume_goods_num
        local tool 		= BagManager:getItemById(goodId)

        if tool and tool.num >= costTool then
        	enoughTool = true
        end
    end
    -- end
	-- local bFreeGet = self:IsFreeGet(cardType)
	
	if enoughTool == false then
		bFreeGet = self:IsFreeGet(cardType)
		if not bFreeGet then
			if not MainPlayer:isEnoughSycee(yuanBaoCost[cardType] , true) then
				PayManager:setPaySource(1)
				return false
			end
		end
	end

	self.lastSendTime = self.lastSendTime or 0
	if os.time() - self.lastSendTime < 1 then
		return false
	end

	local blockUI = TFPanel:create()
	self.blockUI = blockUI
	blockUI:setSize(GameConfig.WS)
	blockUI:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
	blockUI:setBackGroundColorOpacity(200)
	blockUI:setBackGroundColor(ccc3(0, 0, 0))
	blockUI:setTouchEnabled(true)

	-- local cloudyUI = createUIByLuaNew("lua.uiconfig_mango_new.shop.yundonghua")
	-- self.cloudyUI = cloudyUI
	-- blockUI:addChild(cloudyUI)
	-- AlertManager:getTopLayer().toScene:addLayer(blockUI)
	-- self.cloudyUI:setAnimationCallBack("yunguan", TFANIMATION_END, function() self:SendGetCardMsg(cardType, bFreeGet) end)
	-- self.cloudyUI:runAnimation("yunguan", 1)

	local eftID = "cloudopen"
	ModelManager:addResourceFromFile(2, eftID, 1)
  	local eft = ModelManager:createResource(2, eftID)
  	self.cloudyEft = eft
  	local frameSize = GameConfig.WS
  	eft:setPosition(ccp(frameSize.width / 2, frameSize.height / 2))
  	AlertManager:getTopLayer().toScene:addLayer(blockUI)
  	blockUI:addChild(eft)

  	ModelManager:addListener(self.cloudyEft, "ANIMATION_COMPLETE", function() 
  		self:SendGetCardMsg(cardType, bFreeGet)
	end)
	ModelManager:playWithNameAndIndex(self.cloudyEft, "", 1, 0, -1, -1)

	return true
end


function GetCardManager:GetRoleResult(event)
	hideAllLoading()
	
	print("GetRoleResult", event.data)
	local cardType = event.data.state.cardType
	self.cardStateInfo[cardType] = event.data.state
	self.cardStateInfo[cardType].clientTime = self.cardStateInfo[cardType].cdTime + MainPlayer:getNowtime()

	self.getCardTypeList = event.data.element
	-- self.hunNumberList = event.data.num

	if #self.getCardTypeList > 0 and cardType == 3 then
		for i=1,30 do
			local first =  math.random(1, #self.getCardTypeList - 1)
			local second =  math.random(1, #self.getCardTypeList - 1)
			if first ~= second then
				local temp_typid = self.getCardTypeList[first]
				self.getCardTypeList[first] = self.getCardTypeList[second]
				self.getCardTypeList[second] = temp_typid

				-- local temp_num = self.hunNumberList[first]
				-- self.hunNumberList[first] = self.hunNumberList[second]
				-- self.hunNumberList[second] = temp_num
			end
		end
	end

	print("self.getCardTypeList", self.getCardTypeList)

	self:showGetEffect(cardType)
	-- if #self.getCardTypeList > 0 then
	-- 	if cardType < 3 then
	-- 		play_shili_bailizhaomu()
	-- 		self:ShowGetOneRoleLayer(cardType, 1)
	--     else
 --    		play_wanlizhaomu()
	-- 		local layer = require("lua.logic.shop.GetTenRoleResultLayer"):new(cardType)
	-- 		layer.name = "lua.logic.shop.GetTenRoleResultLayer"
	--     	AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
	--     	AlertManager:show()
	--     end
 --    end
end

function GetCardManager:showGetEffect(cardType)
	-- local blockUI = TFPanel:create();
	-- blockUI:setSize(GameConfig.WS);
	-- blockUI:setTouchEnabled(true); 

	-- blockUI:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID);
	-- blockUI:setBackGroundColorOpacity(200);
	-- blockUI:setBackGroundColor(ccc3(  0,   0,   0));
	-- AlertManager:getTopLayer().toScene:addLayer(blockUI);

	-- TFResourceHelper:instance():addArmatureFromJsonFile("effect/NewCardEffect.xml")
	-- local effect = TFArmature:create("NewCardEffect_anim")
	-- if effect == nil then
	-- 	return
	-- end
	-- -- effect:setZOrder(-100)
	-- effect:setAnimationFps(GameConfig.ANIM_FPS)
	-- effect:playByIndex(0, -1, -1, 0)
	-- effect:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2))

	-- blockUI:addChild(effect)
	-- play_zhaomu_pengwan()

	
	-- local function showResult()
	-- 	blockUI:removeFromParent()
	-- 	if #self.getCardTypeList > 0 then
	-- 		if cardType < 3 then
	-- 			-- play_shili_bailizhaomu()
	-- 			if self.getCardTypeList[1].resType == EnumDropType.ROLE then
	-- 				self:ShowGetOneRoleLayer(cardType, 1)
	-- 			else
	-- 				self:ShowGetOneItemLayer(cardType, 1)
	-- 			end
	-- 		else
	-- 			-- play_wanlizhaomu()
	-- 			local layer = require("lua.logic.shop.GetTenRoleResultLayer"):new(cardType)
	-- 			layer.name = "lua.logic.shop.GetTenRoleResultLayer"
	-- 		AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
	-- 		AlertManager:show()
	-- 		end
	-- 	end
	-- end

	-- effect:addMEListener(TFARMATURE_COMPLETE,showResult)
	-- blockUI:addMEListener(TFWIDGET_CLICK,showResult)
	-- -- effect:addMEListener(TFARMATURE_COMPLETE,showResult)

	local function showResult()
		self.blockUI:removeFromParent()
		self.blockUI = nil
		-- blockUI:removeFromParent()
		if #self.getCardTypeList > 0 then
			if cardType < 3 then
				-- play_shili_bailizhaomu()
				if self.getCardTypeList[1].resType == EnumDropType.ROLE then
					self:ShowGetOneRoleLayer(cardType, 1)
				else
					self:ShowGetOneItemLayer(cardType, 1)
				end
			else
				-- play_wanlizhaomu()
				local layer = require("lua.logic.shop.GetTenRoleResultLayer"):new(cardType)
				layer.name = "lua.logic.shop.GetTenRoleResultLayer"
				AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
				AlertManager:show()
			end
		end
	end

	-- self.cloudyEft:setVisible(true)
	-- self.cloudyUI:removeFromParent()
	ModelManager:addListener(self.cloudyEft, "ANIMATION_COMPLETE", function() 
		ModelManager:removeListener(self.cloudyEft, "ANIMATION_COMPLETE")
		showResult()
	end)
	ModelManager:playWithNameAndIndex(self.cloudyEft, "", 0, 0, -1, -1)
	
	-- self.cloudyUI:setAnimationCallBack("yunkai", TFANIMATION_END, function() showResult() end)
	-- self.cloudyUI:runAnimation("yunkai", 1)
end

function GetCardManager:ShowGetOneRoleLayer(cardType, roleIndex)
	local layer = require("lua.logic.shop.GetRoleResultLayer"):new({cardType, roleIndex})
	AlertManager:addLayer(layer, AlertManager.BLOCK)
	AlertManager:show()
end

function GetCardManager:ShowGetOneItemLayer(cardType, roleIndex)
	local layer = require("lua.logic.shop.GetItemResultLayer"):new({cardType, roleIndex})
	AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
	AlertManager:show()
end

--红点判断逻辑
--是否该招募免费
function GetCardManager:isGetCardFree(index)
	return self:IsFreeGet(index);
end

--是否有招募免费
function GetCardManager:isHaveGetCardFree()
	for i =1,3 do
		if self:IsFreeGet(i) then
			return true
		end
	end
	return false;
end

return GetCardManager:new()