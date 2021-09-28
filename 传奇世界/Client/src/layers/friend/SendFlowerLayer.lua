local SendFlowerLayer = class("SendFlowerLayer",function() return cc.Layer:create() end )
-- SendFlowerLayer.left_time = 0
-- SendFlowerLayer.goldTime  = 0

local path = "res/layers/friend/"

function SendFlowerLayer:ctor(roleData, callBack)
	local msgids = {RELATION_SC_GIVEFLOWER_RET, RELATION_SC_GETREMAINFLOWERNUM_RET}
	require("src/MsgHandler").new(self,msgids)

	--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETREMAINFLOWERNUM, "i", G_ROLE_MAIN.obj_id)
	g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETREMAINFLOWERNUM, "GetRemainFlowerProtocol", {})
	addNetLoading(RELATION_CS_GETREMAINFLOWERNUM, RELATION_SC_GETREMAINFLOWERNUM_RET)

	self.roleData = roleData
	self.callBack = callBack
	self.btn = {}
	self.data = {}
	for i=1,4 do
		self.data[i] = 0
	end

	local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	self.bg = bg
	createLabel(bg, game.getStrByKey("send_flower_text"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-30), cc.p(0.5, 0.5), 24, true)
	
	local contentBg = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )
	local bottomBg = createSprite(bg, "res/common/bg/bg18-10.png", cc.p(bg:getContentSize().width/2, 15), cc.p(0.5, 0))

	local closeFunc = function() 
	   	self.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() self:removeFromParent() end)))	
	end
	local closeBtn = createTouchItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-48, bg:getContentSize().height-28), closeFunc)

	local posX = {contentBg:getContentSize().width/2-293, contentBg:getContentSize().width/2-97, contentBg:getContentSize().width/2+97, contentBg:getContentSize().width/2+293}
	local posY = 70
	local imgs = {"1.png", "1.png", "3.png", "4.png"}
	self.imgs = imgs
	local currencyImgs = {"res/group/currency/1.png", "res/group/currency/4.png", "res/group/currency/3.png"}
	-- local duos = {getConfigItemByKey("FlowerCfg", "q_style", 1, "q_giveflowerNum"), 
	-- getConfigItemByKey("FlowerCfg", "q_style", 2, "q_giveflowerNum"), 
	-- getConfigItemByKey("FlowerCfg", "q_style", 3, "q_giveflowerNum"), 
	-- getConfigItemByKey("FlowerCfg", "q_style", 4, "q_giveflowerNum")}

	local sendBtnFunc = function(type, num)

		if G_ROLE_MAIN and G_ROLE_MAIN:getTheName() == roleData[2] then
			TIPS({str = game.getStrByKey("charm_sendFlowerToSelf"), type = 1})
			return
		end
		local MRoleStruct = require("src/layers/role/RoleStruct")
        local lv = MRoleStruct:getAttr(ROLE_LEVEL)
        if lv < 24 then
        	TIPS( {str = game.getStrByKey("send_flowers_levneed") })
        	return
        end

		log("sendBtnFunc type = "..type)
		dump(tag)
		print("send flowers", roleData[1], roleData[2])
		--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GIVEFLOWER, "iiSc", G_ROLE_MAIN.obj_id, roleData[1], roleData[2], type)
		local t = {}
		t.targetSID = roleData[1]
		t.targetName = roleData[2]
		t.giveType = type
		t.giveNum = num
		dump(t)
		g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GIVEFLOWER, "GiveFlowerProtocol", t)
	end

	local setFlowerSpr = function(num)
		local flowerCfg = getConfigItemByKey("FlowerCfg","q_style")
		for i=2,4 do
			if num >= flowerCfg[i].q_giveflowerNum then
				self.flowerSpr:setTexture(path..self.imgs[i])
			end
		end
	end
	self.setFlowerSpr = setFlowerSpr

	local getMaterialNumber = function(id)
		local MPackStruct = require "src/layers/bag/PackStruct"
		local MPackManager = require "src/layers/bag/PackManager"
		local pack = MPackManager:getPack(MPackStruct.eBag)
		return pack:countByProtoId(id)
	end

	local flowerCfg = getConfigItemByKey("FlowerCfg","q_style")
	for i=1,4 do
	 	local imageBg = createSprite(contentBg, path.."bg.png", cc.p(posX[i], posY), cc.p(0.5, 0))
	 	--imageBg:setScale(0.8, 1)
	 	--local flowerBg = createSprite(imageBg, "res/common/bg/iconBg.png", cc.p(imageBg:getContentSize().width/2, 200), cc.p(0.5, 0))
	 	local flowerSpr = createSprite(imageBg, path..imgs[i], cc.p(imageBg:getContentSize().width/2, 260), cc.p(0.5, 0.5))
	 	local sendBtn
	 	if i == 1 or i == 2 then 
	 		sendBtn = createTouchItem(imageBg, "res/component/button/2.png", cc.p(imageBg:getContentSize().width/2, 55), function() sendBtnFunc(i, self.num) end)
	 	else
	 		sendBtn = createTouchItem(imageBg, "res/component/button/1.png", cc.p(imageBg:getContentSize().width/2, 55), function() sendBtnFunc(i, self.num) end)
	 	end
	 	sendBtn:setTag(20+i)
	 	sendBtn:addColorGray()
		sendBtn:setTouchEnable(false)
	 	self.btn[i] = sendBtn

	 	local valueIcon
	 	local valueNum
	 	if i~=1 and flowerCfg[i] then
			createLabel(imageBg, string.format(game.getStrByKey("send_how_duo"), flowerCfg[i].q_giveflowerNum), cc.p(imageBg:getContentSize().width/2, 130), cc.p(0.5, 0), 22, true, nil, nil, MColor.lable_yellow)
			createLabel(imageBg, string.format(game.getStrByKey("get_how_ml"), flowerCfg[i].q_friendGetVital), cc.p(imageBg:getContentSize().width/2, 100), cc.p(0.5, 0), 18, true, nil, nil, MColor.green)
			valueIcon = createSprite(sendBtn, currencyImgs[flowerCfg[i].q_costType], getCenterPos(sendBtn, -2, 3), cc.p(1, 0.5), 0.8)
			valueNum  = createLabel(sendBtn, numToFatString(flowerCfg[i].q_costValue), getCenterPos(sendBtn, 2), cc.p(0, 0.5), 22, true, nil, nil, MColor.white)					
		end

		if i == 1 then 
			self.flowerSpr = flowerSpr
			createLabel(sendBtn, game.getStrByKey("send_flowers_send"), getCenterPos(sendBtn), nil, 22, true)
			local inputBg = createSprite(imageBg, path.."inputBg.png", cc.p(imageBg:getContentSize().width/2, 148), cc.p(0.5, 0.5))
			self.num = self:getNum()
			self.numLabel = createLabel(inputBg, self.num, getCenterPos(inputBg), nil, 22, true, nil, nil, MColor.lable_yellow)
			setFlowerSpr(self.num)

			local function addBtnFunc()
				self.num = self.num + 1
				if self.num > getMaterialNumber(1490) then
					self.num = getMaterialNumber(1490)
					TIPS( {str = string.format(game.getStrByKey("send_flowers_no_more"), require("src/config/propOp").name(1490)) })
				end
				self.numLabel:setString(self.num)
				setFlowerSpr(self.num)
			end
			local addBtn = createMenuItem(imageBg, "res/component/button/plus.png", cc.p(imageBg:getContentSize().width/2+60, 148), addBtnFunc)
			addBtn:setLongTouchCallBack(addBtnFunc)

			local function minusBtnFunc()
				self.num = self.num - 1
				if self.num < 1 then
					if getMaterialNumber(1490) > 0 then
						self.num = 1
						TIPS( {str = game.getStrByKey("send_flowers_no_less") })
					else
						self.num = 0
						TIPS( {str = string.format(game.getStrByKey("send_flowers_without"), require("src/config/propOp").name(1490)) })
					end
				end 
				self.numLabel:setString(self.num)
				setFlowerSpr(self.num)
			end
			local minusBtn = createMenuItem(imageBg, "res/component/button/minus.png", cc.p(imageBg:getContentSize().width/2-60, 148), minusBtnFunc)
			minusBtn:setLongTouchCallBack(minusBtnFunc)

			createLabel(imageBg, require("src/config/propOp").name(1490), cc.p(imageBg:getContentSize().width/2, 180), cc.p(0.5, 0), 20, true, nil, nil, MColor.lable_yellow)
			local richText = require("src/RichText").new(imageBg, cc.p(25, 124), cc.size(145, 25), cc.p(0, 1), 20, 18, MColor.green)
			richText:addText(game.getStrByKey("get_ml_ex"), MColor.green, true)
			richText:format()
		end
		
		if i == 2 then 
			valueIcon:setVisible(false)
			valueNum:setVisible(false)
			self.free = createLabel(sendBtn, game.getStrByKey("free"), getCenterPos(sendBtn), nil, 22, true, nil, nil, MColor.lable_yellow)
			--self.free:setColor(MColor.white)
			-- self.goldIcon = valueIcon
			-- self.goldNum  = valueNum
		end
	end
	--self.leftTimelabel = createLabel(bottomBg, string.format(game.getStrByKey("left_how_times"), SendFlowerLayer.left_time), getCenterPos(bottomBg, 0, -5), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_black)
	--createLabel(bottomBg, game.getStrByKey("send_flower_tips"), getCenterPos(bottomBg, 0, -3), false, 18):setColor(MColor.red)
	createLabel(bottomBg, game.getStrByKey("send_flower_tips"), getCenterPos(bottomBg, 0, -5), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_yellow)

	registerOutsideCloseFunc(bg , closeFunc, true)
end

function SendFlowerLayer:getNum()
	local getMaterialNumber = function(id)
		local MPackStruct = require "src/layers/bag/PackStruct"
		local MPackManager = require "src/layers/bag/PackManager"
		local pack = MPackManager:getPack(MPackStruct.eBag)
		return pack:countByProtoId(id)
	end

	local num = getMaterialNumber(1490)
	if num > 0 then
		return 1
	else
		return 0
	end
end

function SendFlowerLayer:updateUI()
	--self.leftTimelabel:setString(string.format(game.getStrByKey("left_how_times"), SendFlowerLayer.left_time))
	for i,v in ipairs(self.data) do
		if self.btn[i] then
			if self.data[i] and self.data[i] > 0 then
				self.btn[i]:addColorGray()
				self.btn[i]:setTouchEnable(false)
			else
				self.btn[i]:removeColorGray()
				self.btn[i]:setTouchEnable(true)
			end
		end
	end

	self.num = self:getNum()
	if self.num == 0 then
		self.btn[1]:addColorGray()
		self.btn[1]:setTouchEnable(false)
	end
	self.numLabel:setString(self.num)
	self.setFlowerSpr(self.num)
end

function SendFlowerLayer:networkHander(buff,msgid)
	local switch = {
		[RELATION_SC_GIVEFLOWER_RET] = function() 
			log("get RELATION_SC_GIVEFLOWER_RET"..msgid)  
			local t = g_msgHandlerInst:convertBufferToTable("GiveFlowerRetProtocol", buff)
			local giveType = t.giveType
			local getGlamour = t.getGlamour
			--log("nums"..nums)
			if getGlamour > 0 then
				if self.callBack then
					self.callBack(getGlamour)
				end
			end				
		end,	

		[RELATION_SC_GETREMAINFLOWERNUM_RET] = function() 
			log("get RELATION_SC_GETREMAINFLOWERNUM_RET"..msgid)  
			local t = g_msgHandlerInst:convertBufferToTable("GetRemainFlowerRetProtocol", buff) 
			self.data = {}
			self.data[1] = t.firstFlowerNum
			self.data[2] = t.secondFlowerNum
			self.data[3] = t.thirdFlowerNum
			self.data[4] = t.fourthFlowerNum

			dump(self.data)
			self:updateUI()
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return SendFlowerLayer