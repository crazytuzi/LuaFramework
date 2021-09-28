local ShaWarContributionLayer = class("ShaWarShaWarContributionLayer", function() return cc.Layer:create() end)

function ShaWarContributionLayer:ctor(bg)
	local msgids = {FACTION_SC_ADDSTATUE_RET}
    require("src/MsgHandler").new(self, msgids)

	local selfBg = createSprite(self, "res/common/bg/bg27.png", cc.p(0, 0), nil)
	local bgSize = selfBg:getContentSize()
	createScale9Sprite( selfBg , "res/common/scalable/panel_inside_scale9.png", getCenterPos(selfBg, 0, -20), cc.size( 376 , 449 ) , cc.p(0.5 , 0.5 ) )
	createSprite(selfBg, "res/common/bg/bg27-4-3.png", getCenterPos(selfBg, 0, 181))
	createLabel(selfBg, game.getStrByKey("contribution_btn"), cc.p(bgSize.width/2, bgSize.height -25), nil, 25, true)

	local pack = MPackManager:getPack(MPackStruct.eBag)
	local count = pack:countByProtoId(1081)
	local str = getConfigItemByKey( "propCfg", "q_id", 1081, "q_name")
	createLabel(selfBg, str, cc.p(bgSize.width/2 - 125, 447), nil, 22):setColor(MColor.lable_yellow)
	local iconBtn = iconCell( { isTip = true,parent = selfBg , tag = 0 , iconID = 1081} )
	setNodeAttr(iconBtn, cc.p(bgSize.width/2, 375))
	createLabel(selfBg, game.getStrByKey("contribution_haveNow"), cc.p(bgSize.width/2 + 130, 447), cc.p(1, 0.5), 22):setColor(MColor.lable_yellow)
	local numLab = createLabel(selfBg, "" .. count, cc.p(bgSize.width/2 + 130, 447), cc.p(0, 0.5), 22)
	numLab:setColor(MColor.white)
	self.numLab = numLab

	createSprite(selfBg, "res/common/bg/bg27-2.png", getCenterPos(selfBg, 0, 52), nil)
	str = string.format(game.getStrByKey("shawar_contriForFaction"), str)
	local lab = createLabel(selfBg, str, getCenterPos(selfBg, 0, 20), nil, 18, true)
	lab:setColor(MColor.lable_black)

	local selector = Mnode.createSelector(
	{
		config = {sp = 1, ep = count == 0 and 1 or count, cur =  1},
		onValueChanged = function(selector, value)
		end,
	})
	selfBg:addChild(selector)
	selector:setPosition(cc.p(bgSize.width/2, 201))
	self.selector = selector
	selector:setScale(0.9)

	local func1 = function()
		local value = selector:value()
		self:sendMsgToServer(value)
	end
	local Btn = createMenuItem(selfBg, "res/component/button/50.png", getCenterPos(selfBg, 0, -210), func1)
	createLabel(Btn, "上交", getCenterPos(Btn), nil, 22, true)
	
	local closeCallBack = function()
		removeFromParent(self)
	end
	Btn = createMenuItem(selfBg, "res/component/button/x2.png", cc.p(bgSize.width - 30, bgSize.height - 25), closeCallBack)
	registerOutsideCloseFunc( selfBg , closeCallBack ,true)
end

function ShaWarContributionLayer:sendMsgToServer(value)
	dump(value, "value")
	g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_ADDSTATUE,"FactionAddStatue",{addNum = value})
end

function ShaWarContributionLayer:networkHander(luabuffer,msgid)
	cclog("ShaWarContributionLayer:networkHander")
    local switch = {
    	[FACTION_SC_ADDSTATUE_RET] = function()
			local retTable = g_msgHandlerInst:convertBufferToTable("FactionAddStatueRet", luabuffer)
    		local num = retTable.addNum
    		local count = tonumber(self.numLab:getString()) - num
    		self.numLab:setString("" .. count)
    		self.selector:reloadData({sp = 1, ep = count == 0 and 1 or count, cur =  1})
    		g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETSTATUERANK, "FactionGetStatueRank", {})
    	end,
    }

    if switch[msgid] then 
        switch[msgid]()
    end
end

return ShaWarContributionLayer