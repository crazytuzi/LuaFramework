local FactionKnowLedgeListLayer = class("FactionKnowLedgeListLayer", function() return cc.Layer:create() end )

function FactionKnowLedgeListLayer:ctor(factionData)
	local msgids = {FACTION_SC_GETMSGRECORD_RET}
	require("src/MsgHandler").new(self,msgids)
    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETMSGRECORD, "GetFactionMsgRecord", { factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID), lowNum=1, highNum=50 })

    local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	self.bg = bg

    createLabel(bg, game.getStrByKey("faction_knowledge"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-27), cc.p(0.5, 0.5), 24, true)
	local contentBg = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )
	local closeFunc = function() 
	   	self.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() self:removeFromParent() end)))	
	end
	local closeBtn = createTouchItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-48, bg:getContentSize().height-28), closeFunc)


	self.load_data = {}
	local baseNode = cc.Node:create()
	self.bg:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode
	self:createScroll()
end

function FactionKnowLedgeListLayer:createScroll()
	local scrollView = cc.ScrollView:create()
    if nil ~= scrollView then
        scrollView:setViewSize(cc.size(790, 445))
        scrollView:setPosition(cc.p(35, 20))
        --scrollView:setScale(1.0)
        --scrollView:ignoreAnchorPointForPosition(true)
        local node = cc.Node:create()
        self.node = node
        scrollView:setContainer(node)
        scrollView:setContentSize(cc.size(790, 445))

        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        scrollView:setClippingToBounds(true)
        scrollView:setBounceable(true)
        self.baseNode:addChild(scrollView)
        self.scrollView = scrollView
    end
end

function FactionKnowLedgeListLayer:updateScrollView()
	self.node:removeAllChildren()

	local getTimeStr = function(time) 
		local dates = os.date("*t",time)
		return string.format(game.getStrByKey("date_format"),dates.year,dates.month,dates.day,dates.hour,dates.min)
	end
	local cellHeight = 25
	local x = 0
	local y = 0
	local index = 0
	local padding = 2
	for i,v in ipairs(self.load_data) do
		local data = self.load_data[i]

		local timeStr = getTimeStr(data[1])
		local timeStr1 = createLabel(self.node,  timeStr .. ": ", cc.p(5, 0), cc.p(0,0), 22, true, nil, nil, MColor.yellow)
		timeStr1:setZOrder(1)
		local richText = require("src/RichText").new(self.node, cc.p(5+timeStr1:getContentSize().width, 0), cc.size(770-timeStr1:getContentSize().width, cellHeight*2), cc.p(0, 0), cellHeight, 20, MColor.Lable_yellow)
    	richText:addText(data[3])
    	richText:format()
    	richText:setZOrder(1)
    	local offy = 0
    	local curIndex = index
    	if richText:getContentSize().height > cellHeight then --有两行
    		offy = cellHeight
    		index = index + 2
    	else
    		index = index + 1
    	end

		richText:setPositionY(y)
		timeStr1:setPositionY(y + offy)
		
		if index%2 == 1 or (index - curIndex) >1 then
			local bg = createScale9Sprite(self.node,"res/faction/cellbg.png",cc.p(0,y-1),cc.size(785,cellHeight),cc.p(0,0))
	   		bg:setZOrder(0)
	   		if (index - curIndex) >1  then
	   			bg:setPositionY(y-1 + (curIndex%2) * cellHeight )
	   		end
		end

		y = y + richText:getContentSize().height
		y = y + padding
	end
	self.scrollView:setContentSize(cc.size(780, y))
	dump(y)
	--if y < 510 then
	 	self.scrollView:setContentOffset(cc.p(0, 445-y), false)
	--else
	--	self.scrollView:setContentOffset(cc.p(0, 0), false)
	--end
end

function FactionKnowLedgeListLayer:networkHander(buff,msgid)
	local switch = {
		[FACTION_SC_GETMSGRECORD_RET] = function()    
			log("get FACTION_SC_GETMSGRECORD_RET"..msgid)
			
            local t = g_msgHandlerInst:convertBufferToTable("GetFactionMsgRecordRet", buff) 
            
            self.load_data = {} 
			local num =  #t.records
			for i=1,num do 
				self.load_data[i] = {t.records[i].time, t.records[i].id}
				for k,v in pairs(require("src/config/clientmsg"))do
					if 7000 == v.sth and  self.load_data[i][2] == v.mid then
						local param_num = #t.records[i].params
						if v.fat and param_num == string.len(v.fat) then
							if v.mid == 5 then
                                local tt = {t.records[i].params[1], t.records[i].params[2], t.records[i].params[3], t.records[i].params[4]}
                                local numTp = tonumber(tt[2])
                                if numTp == 1 then
                                    tt[2] = game.getStrByKey("factionQFT_xiang1")
                                elseif numTp == 2 then
                                    tt[2] = game.getStrByKey("factionQFT_xiang2")
                                else
                                    tt[2] = game.getStrByKey("factionQFT_xiang3")
                                end

                                self.load_data[i][3] = string.format(v.msg, tt[1], tt[2], tt[3], tt[4])
                            else
                                local s = t.records[i].params
                                self.load_data[i][3] = string.format(v.msg,s[1],s[2],s[3],s[4],s[5],s[6],s[7],s[8],s[9],s[10])
                            end
						else
							self.load_data[i][3] = v.msg
						end
						--[[
                        local link_num = buff:readByFmt("c")
						for j=1,link_num do 
							--self.load_data[i][4] = {buff:readByFmt("iS")}
                            buff:readByFmt("iS")
						end
                        ]]
						break
					end
				end
			end	
			dump(self.load_data)	
			self:updateScrollView()
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return FactionKnowLedgeListLayer