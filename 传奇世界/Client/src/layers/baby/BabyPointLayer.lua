local BabyPointLayer = class("BabyPointLayer", require("src/TabViewLayer"))
local path = "res/baby/"

function BabyPointLayer:ctor(data, mainSelectID)
	local msgids = {BABY_SC_UPPOINT_RET}
	require("src/MsgHandler").new(self, msgids)

	self:initData(data)
	self.school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
	self.level = require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL)

	local bg = createBgSprite(self, path.."icon.png", path.."title_2.png")
	self.bg = bg
	createSprite(bg, "res/common/split-1.png", cc.p(265, 18), cc.p(1, 0))
	createSprite(bg, path.."12.png", cc.p(15, 517), cc.p(0, 0))

	local bgImage = createSprite(bg, path.."9.jpg", cc.p(265, 18), cc.p(0, 0))
	self.bgImage = bgImage
	createSprite(bgImage, path.."16.png", cc.p(40, 320), cc.p(0, 0))

	self.pointInfoNode = cc.Node:create()
	bgImage:addChild(self.pointInfoNode)
	self.pointInfoNode:setPosition(cc.p(10, 175))

	local bgTop = createSprite(bgImage, path.."10.jpg", cc.p(bgImage:getContentSize().width/2+3, 360), cc.p(0.5, 0))
	self.bgTop = bgTop
	createSprite(bgTop, path.."13.png", cc.p(25, 120), cc.p(0, 0))
	local help = __createHelp(
	{
		parent = bgTop,
		str = require("src/config/PromptOp"):content(20),
		pos = cc.p(595, 40),
	})

	self.deputyNode = cc.Node:create()
	bgTop:addChild(self.deputyNode)
	self.deputyNode:setPosition(cc.p(0, 0))

	self.pointNode = cc.Node:create()
	bgImage:addChild(self.pointNode)
	self.pointNode:setPosition(cc.p(0, 0))

	local getPropFunc = function()
		self:createAllPointInfoNode()
	end
	local getPropBtn = createMenuItem(bgImage, "res/component/button/9.png", cc.p(600, 315), getPropFunc)
	self.getPropBtn = getPropBtn
	createLabel(getPropBtn, game.getStrByKey("baby_get_prop"), getCenterPos(getPropBtn), cc.p(0.5, 0.5), 18, true)

	local levelUpFunc = function()
		if self.selectPointId ~= nil then
			--g_msgHandlerInst:sendNetDataByFmtExEx(BABY_CS_UPPOINT, "ii", G_ROLE_MAIN.obj_id, self.selectPointId)
			--addNetLoading(BABY_CS_UPPOINT, BABY_SC_UPPOINT_RET)
		else
			--MessageBox(game.getStrByKey("baby_no_point_tip"))
			TIPS({type=1 , str=game.getStrByKey("baby_no_point_tip")})
		end
	end
	local levelUpBtn = createMenuItem(bgImage, "res/component/button/4.png", cc.p(600, 40), levelUpFunc)
	createLabel(levelUpBtn, game.getStrByKey("baby_point_level_up"), getCenterPos(levelUpBtn), cc.p(0.5, 0.5), 22, true)

	self.zqStr = createLabel(bg, game.getStrByKey("baby_my_zq"), cc.p(600, 585), cc.p(0, 0.5), 22, true, nil, nil, MColor.white)
	-- local Mcurrency = require "src/functional/currency"
	-- self.zqStr = Mcurrency.new(
	-- {
	-- 	cate = PLAYER_VITAL,
	-- 	--bg = "res/common/19.png",
	-- 	color = MColor.white,
	-- 	effect = true,
	-- })
	-- bg:addChild(self.zqStr)
	-- self.zqStr:setAnchorPoint(cc.p(0, 0.5))
	-- self.zqStr:setPosition(cc.p(720, 585))

	self:initMainData(mainSelectID)
	self:updateZqTip()
end

function BabyPointLayer:updateZqTip()
	startTimerAction(self, 0.5, true, function() 
			local zq = require("src/layers/role/RoleStruct"):getAttr(PLAYER_VITAL)
			self.zqStr:setString(game.getStrByKey("baby_my_zq")..zq)
		end)
end

function BabyPointLayer:initData(data)
	local pointRelationTab = getConfigItemByKey("BabyPointRelationDB")
	self.data = copyTable(pointRelationTab)
	self.pointPosTab = require("src/layers/baby/BabyPointDefine")
	--所有穴道初始化为0重
	for k,v in pairs(self.data) do
		v.q_lv = 0
	end


	self.dataEx = data
	for k,v in pairs(data.pointData) do
		local id = v.id
		local lv = v.lv
		for k,v in pairs(self.data) do
			if v.q_ID == id then
				v.q_lv = lv
				break
			end
		end
	end

	--dump(self.data)
end

function BabyPointLayer:updateData(changePointTab)
	print("updateData!!!!!!!!!!!!!!!")
	self:updateUI()
	if changePointTab then
		self:addChangePointEffect(changePointTab)
	end
end

function BabyPointLayer:initMainData(mainSelectID)
	self.mainData = {}
	for i=1,5 do
		self.mainData[i] = {}
		self.mainData[i].id = i*10000
	end
	
	self:initMainBtn()

	local selectIndex = 1
	if mainSelectID then
		for i=1,5 do
			if self.mainData[i].id == mainSelectID then
				selectIndex = i
				break
			end
		end
	end

	self:updateMainData(selectIndex)
end

function BabyPointLayer:initMainBtn()
	local x = 142
	local y = 470
	local addY = -102
	for i,v in ipairs(self.mainData) do
		self.mainData[i].btn = createMenuItem(self.bg, "res/component/button/35.png", cc.p(x, y+(i-1)*addY), function() print(i) self:updateMainData(i) end)
	end
end

function BabyPointLayer:updateMainData(selectIndex)
	self:updateDeputyData(self.mainData[selectIndex].id, 1)

	self:updateMainBtn(selectIndex)
end

function BabyPointLayer:updateMainDataById(selectId)
	local selectIndex = 1
	for i,v in ipairs(self.mainData) do
		if self.mainData[i].id == selectId then
			selectIndex = i
			break
		end
	end
	self:updateDeputyData(self.mainData[selectIndex].id, 1)

	self:updateMainBtn(selectIndex)
end

function BabyPointLayer:updateMainBtn(index)
	local sprite

	for i,v in ipairs(self.mainData) do
		self.mainData[i].btn:removeChildByTag(10)
		self.mainData[i].btn:removeChildByTag(20)
		self.mainData[i].btn:removeChildByTag(30)

		if i == index then
			sprite = createSprite(self.mainData[i].btn, "res/component/button/36.png", getCenterPos(self.mainData[i].btn), cc.p(0.5, 0.5))
			sprite:setTag(10)
		end
		sprite = createSprite(self.mainData[i].btn, path.."point/"..self.mainData[i].id..".png", getCenterPos(self.mainData[i].btn), cc.p(0.5, 0.5))
		sprite:setTag(20)
		local level = self:getItemByKey(self.data, "q_ID", self.mainData[i].id, "q_lv")
		-- dump(self.mainData[i].id)
		-- dump(lv)

		local needLevel = getConfigItemByKeys("BabyPointDB", {"q_ID", "q_level"}, {self.mainData[i].id, self.school}, "F5")
		needLevel = tonumber(needLevel)
		if needLevel and self.level < needLevel then
			self.mainData[i].btn:setVisible(false)
		end
	end

	self:updateMainBtnNum()
end

function BabyPointLayer:updateMainBtnNum()
	function addNumber(btn, number)
		btn:removeChildByTag(30)
		local label = cc.LabelAtlas:_create(number, "res/component/number/9.png", 29, 40, string.byte('0'))
		label:setScale(1)
		btn:addChild(label)
		label:setAnchorPoint(cc.p(0.5, 0.5))
		label:setPosition(158, 53)
		label:setTag(30)
	end

	for i,v in ipairs(self.mainData) do
		local level = self:getItemByKey(self.data, "q_ID", self.mainData[i].id, "q_lv")
		-- dump(self.mainData[i].id)
		-- dump(lv)
		addNumber(self.mainData[i].btn, level)
	end
end

function BabyPointLayer:updateDeputyData(mainId, selectIndex)
	self.selectMainId = mainId
	self.deputyData = {}

	for k,v in pairs(self.data) do
		if v.q_higher == mainId and v.q_type == 2 then
			local record = copyTable(v)
			self.deputyData[#self.deputyData+1] = {}
			self.deputyData[#self.deputyData].data = record
		end
	end

	self:updateDeputyBtn(selectIndex)
	self:updatePointData(self.deputyData[selectIndex].data.q_ID)
end

function BabyPointLayer:updateDeputyBtn(selectIndex)
	self.deputyNode:removeAllChildren()

	local x = self.bgTop:getContentSize().width/2 - 150
	local y = self.bgTop:getContentSize().height/2
	local addX = 150
	for i,v in ipairs(self.deputyData) do
		local res = "11-1.png"
		if i == selectIndex then
			res = "11-2.png"
		end
		self.deputyData[i].btn = createMenuItem(self.deputyNode, path..res, cc.p(x+(i-1)*addX, y), function() print(self.deputyData[i].data.q_ID) self:updateDeputyData(self.selectMainId, i) end)
		createLabel(self.deputyData[i].btn, self.deputyData[i].data.q_name, getCenterPos(self.deputyData[i].btn), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.white)
	end

	self:updateDeputyBtnNum()
end

function BabyPointLayer:updateDeputyBtnNum()
	function addNumber(btn, number)
		btn:removeChildByTag(10)
		local redBg = createSprite(btn, path.."14.png", getCenterPos(btn, -40, 30), cc.p(0.5, 0.5))
		redBg:setTag(10)
		createLabel(redBg, number, getCenterPos(redBg), cc.p(0.5, 0.5), 18, true, nil, nil, MColor.white)
	end

	for i,v in ipairs(self.deputyData) do
		local level = self:getItemByKey(self.data, "q_ID", self.deputyData[i].data.q_ID, "q_lv")
		-- dump(self.deputyData[i].data.q_ID)
		-- dump(lv)
		addNumber(self.deputyData[i].btn, level)
	end
end

function BabyPointLayer:updatePointData(deputyId)
	self.selectDeputyId = deputyId
	self.pointData = {}

	self.selectPointId = nil
	self.selectPointLv = nil

	for k,v in pairs(self.data) do
		if v.q_higher == deputyId and v.q_type == 3 then
			local record = copyTable(v)
			self.pointData[#self.pointData+1] = {}
			self.pointData[#self.pointData].data = record
		end
	end
	--dump(self.pointData)
	self:updatePointBtn(deputyId)
	self:updatePointInfo()
end

function BabyPointLayer:updatePointBtn(deputyId)
	self.pointNode:removeAllChildren()
	self.selectPointEffect = nil

	createSprite(self.pointNode, path.."point/"..deputyId..".png", cc.p(0, 0), cc.p(0, 0))

	for i,v in ipairs(self.pointData) do
		self.pointData[i].btn = createMenuItem(self.pointNode, path.."point.png", self:findPointPos(self.pointData[i].data.q_ID), 
			function() 
				--dump(self.pointData[i].data)
				self.selectPointId = self.pointData[i].data.q_ID  
				self.selectPointLv = self:getItemByKey(self.data, "q_ID", self.pointData[i].data.q_ID, "q_lv")

				if self.selectPointEffect then
					removeFromParent(self.selectPointEffect)
					self.selectPointEffect = nil
				end
				for i,v in ipairs(self.pointData) do
					--self.pointData[i].btn:setScale(1.3)
					--self.pointData[i].btn:removeChildByTag(10)
					if self.pointData[i].data.q_ID == self.selectPointId then
						--startTimerAction(self.pointData[i].btn, 0.2, false, function() self.pointData[i].btn:setScale(2) end)
						--self.pointData[i].btn:setColor(MColor.green)
						local animate = Effects:create(false)
						animate:setCleanCache()
						self.selectPointEffect = animate
						animate:playActionData("babyPointSelect", 4, 1, -1)
						self.pointNode:addChild(animate)
						animate:setPosition(cc.p(self.pointData[i].btn:getPosition()))
					end
				end
				self:updatePointInfo()
			end)
		self.pointData[i].btn:setScale(1.3)
		self:addPointBtnEffect(self.pointData[i].btn)
	end
end

function BabyPointLayer:updatePointInfo()
	self.pointInfoNode:removeAllChildren()

	if self.selectPointId ~= nil then
		local record = getConfigItemByKeys("BabyPointDB", {"q_ID", "q_level"}, {self.selectPointId, self.selectPointLv})
		dump(record)
		if record then
			local propBg = createSprite(self.pointInfoNode, "res/common/property.jpg", cc.p(0, 0), cc.p(0, 0))

			createLabel(propBg, record.q_name, cc.p(propBg:getContentSize().width/2, 130), cc.p(0.5, 1), 20, true, nil, nil, MColor.green)

			local attNode = createAttNode(record, 18, MColor.white)
			propBg:addChild(attNode)
			attNode:setAnchorPoint(cc.p(0, 1))
			attNode:setPosition(cc.p(10, 100))

			if record.q_level == 0 and record.q_word then
				if attNode then
					removeFromParent(attNode)
					attNode = nil
				end
				createLabel(propBg, record.q_word, cc.p(10, 100), cc.p(0, 1), 18, true, nil, nil, MColor.white, nil, 155)
			end

			if record.q_needZq then
				local zq = require("src/layers/role/RoleStruct"):getAttr(PLAYER_VITAL)
				local colorStr = "red"
				if zq >= tonumber(record.q_needZq) then
					colorStr = "green"
				end
				local richText = require("src/RichText").new(propBg, cc.p(10, 25), cc.size(160, 30), cc.p(0, 1), 20, 16, MColor.yellow_gray)
			    richText:addText(string.format(game.getStrByKey("baby_point_zq"), colorStr, record.q_needZq))
			    richText:format()
			else
				createLabel(propBg, game.getStrByKey("baby_point_max_level_tip"), cc.p(10, 25), cc.p(0, 1), 16, true, nil, nil, MColor.blue)
			end
		end
	end
end

function BabyPointLayer:addPointBtnEffect(btn)
	--local effectAction = cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(2, 180)))
	local effectAction = cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.75), cc.FadeIn:create(0.75)))
	btn:runAction(effectAction)
end

function BabyPointLayer:findPointPos(pointId)
	for k,v in pairs(self.pointPosTab) do
		if pointId == v[1] then
			return v[2]
		end
	end

	return nil
end

function BabyPointLayer:updateUI()
	print("updateUI!!!!!!!!!!!!!!!")
	self:updateMainBtnNum()
	self:updateDeputyBtnNum()
	self:updatePointInfo()
end

function BabyPointLayer:getItemByKey(tab, key, keyValue, retKey)
	for k,v in pairs(tab) do
		--dump(v[key])
		if v[key] == keyValue then
			--dump("find!!!!!!!!!!!!!!!")
			return v[retKey]
		end
	end

	return nil
end

function BabyPointLayer:setItemByKey(tab, key, keyValue, setKey, setValue)
	for k,v in pairs(tab) do
		--dump(v[key])
		if v[key] == keyValue then
			--dump("find!!!!!!!!!!!!!!!")
			v[setKey] = setValue
			break
		end
	end
end

function BabyPointLayer:createAllPointInfoNode()
	function isAttStr(str)
		dump(str)
		local attTab = 
		{
			"q_max_hp",
			"q_attack_min",
			"q_attack_max",
			"q_magic_attack_min",
			"q_magic_attack_max",
			"q_sc_attack_min",
			"q_sc_attack_max",
			"q_defence_min",
			"q_defence_max",
			"q_magic_defence_min",
			"q_magic_defence_max",
			"q_subAt",
			"q_subMt",
			"q_subDt",
			"q_addAt",
			"q_addMt",
			"q_addDt",
		}
		for i,v in ipairs(attTab) do
			if str == v then
				print("return true")
				return true
			end
		end

		return false
	end

	local layer = cc.Layer:create()
	Manimation:transit(
	{
		ref = self,
		node = layer,
		curve = "-",
		sp = self.getPropBtn:getParent():convertToWorldSpace(cc.p(self.getPropBtn:getPosition())),
		swallow = true,
	})

	local bg = createSprite(layer, "res/common/5a.jpg", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	local closeBtnFunc = function()
		removeFromParent(layer)
	end
	local closeBtn = createMenuItem(bg, "res/common/13.png", cc.p(bg:getContentSize().width, bg:getContentSize().height), closeBtnFunc)
	closeBtn:setScale(0.75)

	local titleBg = createSprite(bg, path.."17.png", cc.p(bg:getContentSize().width/2, 275), cc.p(0.5, 0))
	createSprite(titleBg, path.."18.png", getCenterPos(titleBg), cc.p(0.5, 0.5))

	local totalRecord = {}
	for i,v in ipairs(self.pointData) do
		local record = self.pointData[i].data
		record = getConfigItemByKeys("BabyPointDB", {"q_ID", "q_level"}, {record.q_ID, self:getItemByKey(self.data, "q_ID", record.q_ID, "q_lv")})
		dump(self.pointData)
		for k,v in pairs(record) do
			if isAttStr(k) then
				if totalRecord[k] == nil then
					totalRecord[k] = tonumber(v)
				else
					totalRecord[k] = totalRecord[k] + tonumber(v)
				end
			end
		end
	end
	dump(totalRecord)

	local attNode = createAttNode(totalRecord, 26, MColor.white)
	bg:addChild(attNode)
	attNode:setAnchorPoint(0, 1)
	attNode:setPosition(cc.p(140, 260))
end

function BabyPointLayer:addChangePointEffect(changePointTab)
	for i,v in ipairs(changePointTab) do
		local id = v.id

		for i,v in ipairs(self.mainData) do
			if self.mainData[i].id == id then
				
				break
			end
		end

		for i,v in ipairs(self.deputyData) do
			if self.deputyData[i].data.q_ID == id then
				local animate = Effects:create(true)
				animate:setCleanCache()
				animate:playActionData("babyDeputySuccess", 13, 1, 1)
				self.deputyData[i].btn:addChild(animate)
				animate:setPosition(getCenterPos(self.deputyData[i].btn))

				self:addChangePointParticle()
				break
			end
		end

		for i,v in ipairs(self.pointData) do
			if self.pointData[i].data.q_ID == id then
				local animate = Effects:create(true)
				animate:setCleanCache()
				animate:playActionData("babyPointSuccess", 12, 1, 1)
				self.pointData[i].btn:addChild(animate)
				animate:setPosition(getCenterPos(self.pointData[i].btn))
				animate:setScale(1.2)
				self:addChangePointParticle()
				break
			end
		end
	end
end

function BabyPointLayer:addChangePointParticle()

end

function BabyPointLayer:networkHander(buff,msgid)
	local switch = {
		[BABY_SC_UPPOINT_RET] = function()
			log("get BABY_SC_UPPOINT_RET")
			local changePointTab = {}
			local pointNum = buff:popChar()
			for i=1,pointNum do
				local id = buff:popInt()
				local lv = buff:popChar()
				table.insert(changePointTab, {id=id})
				self:setItemByKey(self.data, "q_ID", id, "q_lv", lv)

				if id == self.selectPointId then
					self.selectPointLv = lv
				end
				print(id.." up to "..lv)
			end
			self:updateData(changePointTab)
			self:getParent():updatePointData(self.data)
		end
		,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return BabyPointLayer