local BiQiNode = class("BiQiNode", function() return cc.Node:create() end)
local EMPIRE_TYPE_BIQI = 1
local path = "res/empire/"

function BiQiNode:ctor(bgSize)
	local msgids = {MANORWAR_SC_GETALLREWARDINFO_RET, MANORWAR_SC_PICKREWARD_RET}
	require("src/MsgHandler").new(self,msgids)

	self.dbData = getConfigItemByKey("AreaFlag", "mapID", 6005)
	g_msgHandlerInst:sendNetDataByTableExEx(MANORWAR_CS_GETALLREWARDINFO, "GetAllRewardInfoProtocol",{manorID = EMPIRE_TYPE_BIQI})

	self.data = {}

	local bg=cc.Node:create()
	bg:setPosition(cc.p(0, 0))
	self:addChild(bg)
	self.bg = bg
	local bgSize = bg:getContentSize()

	createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(176 - 88, 640 - 115),
        cc.size(790, 454),
        5,
        cc.p(0.0, 1)
     )
	createScale9Sprite(bg,"res/common/scalable/panel_inside_scale9.png",cc.p(185 - 88, 640 - 424),cc.size(331, 300),cc.p(0, 0))
	createScale9Sprite(bg,"res/common/scalable/panel_inside_scale9.png",cc.p(524 - 88, 640 - 424),cc.size(433, 300),cc.p(0, 0))
    
	--皇宫背景
	createSprite(bg, "res/empire/biqibg.jpg", cc.p(185 - 88, 640 - 424 + 2), cc.p(0, 0))
	-- --排行榜背景
	-- createSprite(bg, "res/empire/ranbg.png", cc.p(524 - 88, 640 - 424), cc.p(0, 0))

	--中州王奖励
	local lab = createLabel(self.bg, game.getStrByKey("worShip_Title") .. game.getStrByKey("award") .. ":", cc.p(100, 216 + 65), cc.p(0, 0.5), 22, true)
	
	local award = self.dbData.leaderReward
	local DropOp = require("src/config/DropAwardOp")
	local gdItem = DropOp:getItemBySexAndSchool(tonumber(award))

	local j = 1
	local offsetX = 110
	local propOP = require("src/config/propOp")
	--dump(gdItem)
	table.sort(gdItem, function(a, b) return a.q_group < b.q_group end)
	local tableNum = tablenums(gdItem)
	for m,n in pairs(gdItem) do
		local Mprop = require "src/layers/bag/prop"
		local icon = Mprop.new(
		{
			protoId = tonumber(n.q_item),
			num = tonumber(n.q_count),
			swallow = true,
			cb = "tips",
			showBind = true,
			isBind = tonumber(n.bdlx or 0) == 1,
		})
		icon:setScale(0.98)
		icon:setTag(9)
		bg:addChild(icon)
		icon:setPosition(cc.p(offsetX + 120 + (j - 1) * 85 + 2, 216 + 10))
		icon:setAnchorPoint(0, 0)
		j = j + 1
	end

	self:addBtn()
	DATA_Battle:setRedData("ZZZB", false)
end

function BiQiNode:addBtn()
	local function ruleBtnFunc()
		self:showRule()
	end
	local ruleBtn = createMenuItem(self.bg, "res/component/button/small_help2.png", cc.p(117, 418 + 76), ruleBtnFunc)
	local function enterBtnFunc()
		g_msgHandlerInst:sendNetDataByTableExEx(MANORWAR_CS_ENTERMANORWAR, "EnterManorWarProtocol", {manorID = EMPIRE_TYPE_BIQI})
	end
	local enterBtn = createMenuItem(self.bg, "res/component/button/50.png", cc.p( 750 , 126), enterBtnFunc)
	createLabel(enterBtn, game.getStrByKey("biqi_enter"), getCenterPos(enterBtn), cc.p(0.5, 0.5), 20, true)
	self.enterBtn = enterBtn

	local function getBtnFunc()
		g_msgHandlerInst:sendNetDataByTableExEx(MANORWAR_CS_PICKREWARD, "PickManorRewardProtocol", {manorID = EMPIRE_TYPE_BIQI})
	end
	local getBtn = createMenuItem(self.bg, "res/component/button/50.png", cc.p(545 + 20, 126), getBtnFunc)
	self.getBtn = getBtn
	--getBtn:setEnabled(false)
	createLabel(getBtn, game.getStrByKey("get_awards"), getCenterPos(getBtn), cc.p(0.5, 0.5), 20, true)
end

--显示介绍信息
function BiQiNode:showRule()
     local ruleBg = createSprite(self.bg,"res/common/helpBg.png",cc.p(480, 320), nil, 500)
    local root_size = ruleBg:getContentSize()
    createSprite(ruleBg, "res/common/helpBg_title.png", cc.p(261, 290))
    createLabel(ruleBg, "信息", cc.p(261, 290), nil, 20):setColor(MColor.brown)

    registerOutsideCloseFunc(ruleBg, function() removeFromParent(ruleBg) end, true)
    
    local Node = cc.Node:create()
	local function createRichTextContent(parent, content, pos, size, anchor, lineHeight, fontSize, fontColor)
		local richText = require("src/RichText").new(parent, pos, size, anchor, lineHeight, fontSize, fontColor)
	    richText:addText(content)
	    richText:format()
	    return richText
	end

	local height = 0
	local offSetX = 40
	local data = require("src/config/PromptOp")
	local strCfg = {44, 45, 46, 47, 48}
	local num = 5
	for i=1, num do
		local lab = createRichTextContent(Node, data:content(strCfg[num-i+1]), cc.p(offSetX, height), cc.size(root_size.width - 80, 30), cc.p(0, 0), 25, 20, MColor.brown_gray)
		height = height + lab:getContentSize().height
		lab = createLabel(Node, game.getStrByKey("empire_rule_"..(num-i+1) .. "_title_2") .. ":", cc.p(offSetX, height + 5 ), cc.p(0, 0), 22, true)
		lab:setColor(MColor.brown_gray)
		height = height + lab:getContentSize().height + 22
	end

	height = height - 10
	Node:setAnchorPoint(0,0)
	Node:setContentSize(cc.size(800, height))
    local scrollView1 = cc.ScrollView:create()
    scrollView1:setViewSize(cc.size(  root_size.width - 20, root_size.height - 60 ) )
    scrollView1:setPosition( cc.p( 0 , 15 ) ) --250 , 65
    scrollView1:ignoreAnchorPointForPosition(true)

    scrollView1:setContainer(Node)
    scrollView1:updateInset()

    scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView1:setClippingToBounds(true)
    scrollView1:setBounceable(true)
    ruleBg:addChild(scrollView1)

    scrollView1:setContentOffset( cc.p(0, - Node:getContentSize().height + root_size.height - 60))		
end

function BiQiNode:updateTimeInfo()
	local tempStr = ""
	local itemData = getConfigItemByKey("AreaFlag", "mapID", 6005)
	--createLabel(self.bg, game.getStrByKey("empire_biqi_time").., cc.p(725, 163 ), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.lable_yellow)
	if self.data.isActive then
		createLabel(self.bg, game.getStrByKey("empire_rule_5_title") .. "：", cc.p(615 - 47 - 12, 205 ), cc.p(1, 1), 22, false, nil, nil, MColor.lable_yellow)
	else
		if self.data.nextTime then
			tempStr = os.date("%Y-%m-%d ", tonumber(self.data.nextTime * 24 * 3600) + self.data.currTime)
		end

		createLabel(self.bg, game.getStrByKey("empire_rule_5_title") .. "：", cc.p(559 + 42, 205 ), cc.p(1, 1), 22, false, nil, nil, MColor.lable_yellow)
	end

	local strTime = ""
	if itemData and itemData.openTime then
		strTime = getStrTimeByValue(itemData.openTime, false)
	end
	createLabel(self.bg, tempStr .. strTime, cc.p(559 + 42 + 6, 205), cc.p(0, 1), 22, false, nil, nil,MColor.white)
end

function BiQiNode:updateUI(rankInfo)
	self:updateTimeInfo()

	--package.loaded["src/layers/empire/BiQiEmpireRank"] = nil
	local subNode = require("src/layers/empire/BiQiEmpireRank").new(rankInfo)
	if subNode then
		self.bg:addChild(subNode,3)
		subNode:setPosition(cc.p(524 - 88, 216))
	end
	
	local awardBtn = self.getBtn

	if self.data.haveAward then
		awardBtn:setEnabled(true)
	else
		awardBtn:setEnabled(false)
	end
	self.awardBtn = awardBtn
end

function BiQiNode:showAward()
	createLabel(self.bg, game.getStrByKey("worShip_Title") .. "：", cc.p( 100, 205), cc.p(0, 1), 22, true)
	local str = game.getStrByKey("biqi_str9")
	if self.data.factionData then
		str = self.data.factionKingName .. " (" .. self.data.factionName .. ")"
	end
	createLabel(self.bg, str, cc.p( 100 + 110 - 25, 205), cc.p(0, 1), 22):setColor(MColor.yellow)

	createLabel(self.bg, game.getStrByKey("empire_canAwardCondition"), cc.p( 100, 205 - 35), cc.p(0, 1), 22, true)

	local award = self.dbData.dailyReward
	local tab = unserialize(award)
	local awardID = tab[#tab]
	if self.data.king and G_ROLE_MAIN:getTheName() == self.data.factionKingName then
		awardID = tab[1]
	elseif self.data.deputyname and G_ROLE_MAIN:getTheName() == self.data.deputyname then
		awardID = tab[2] or tab[#tab]
	end

	
	local DropOp = require("src/config/DropAwardOp")
	local gdItem = DropOp:dropItem(tonumber(awardID))

	local j = 1
	for m,n in pairs(gdItem) do
		if j > 4 then break end
		local Mprop = require "src/layers/bag/prop"
		local icon = Mprop.new(
		{
			protoId = tonumber(n.q_item),
			num = tonumber(n.q_count),
			swallow = true,
			cb = "tips",
			showBind = true,
			isBind = tonumber(n.bdlx or 0) == 1,
		})
		icon:setTag(9)
		self.bg:addChild(icon)
		icon:setPosition(cc.p(250 + (j - 1) * 90, 126))
		icon:setScale(0.98)
		j = j + 1
	end
end

function BiQiNode:networkHander(buff, msgid)
	local switch = {
		[MANORWAR_SC_GETALLREWARDINFO_RET] = function()
			print("get MANORWAR_SC_GETALLREWARDINFO_RET")
			local retTab = g_msgHandlerInst:convertBufferToTable("GetAllRewardInfoRetProtocol", buff)
			local id = retTab.manorID
			if id == EMPIRE_TYPE_BIQI then
				self.data.isActive = retTab.isOpen
				self.data.nextTime = retTab.remainDay
				self.data.currTime = retTab.curTime
				self.enterBtn:setEnabled(self.data.isActive)
				self.data.factionData = retTab.hasFaction
				if self.data.factionData then
					self.data.factionName = retTab.facName
					self.data.factionKingName = retTab.leaderName
					
					self.data.king = {}
					self.data.king.name = self.data.factionKingName 
					self.data.king.sex = retTab.sex
					self.data.king.school = retTab.school
					self.data.king.weaponId = retTab.weapon
					self.data.king.clothes = retTab.cloth
					self.data.king.wing = retTab.wing				
					self.data.deputyname = retTab.assleaderName
				end

				self.data.haveAward = retTab.canReward
				local tempJoinData = retTab.zzFacId
				self.data.joinNum = tempJoinData and tablenums(tempJoinData) or 0
				self.data.joinData = {}
				for i=1, self.data.joinNum do
					local recode = {tempJoinData[i].manorID, tempJoinData[i].facId, tempJoinData[i].facName, tempJoinData[i].leaderName}
					self.data.joinData[tempJoinData[i].manorID] = {recode[1], recode[3], recode[4], recode[2]}
				end
				
				dump(self.data)
				self:updateUI(self.data.joinData)
				self:showAward()
			end
			
		end,
		[MANORWAR_SC_PICKREWARD_RET] = function()
			self.data.haveAward = false
			if self.awardBtn then
				performWithDelay(self, function() self.awardBtn:setEnabled(false) end ,0.25 )
			end
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return BiQiNode