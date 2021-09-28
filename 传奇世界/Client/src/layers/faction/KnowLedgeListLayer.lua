local KnowLedgeListLayer = class("KnowLedgeListLayer", require ("src/TabViewLayer") )

function KnowLedgeListLayer:ctor(factionData, bg)
	local msgids = {FACTION_SC_GETMSGRECORD_RET}
	require("src/MsgHandler").new(self,msgids)
    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETMSGRECORD, "GetFactionMsgRecord", { factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID), lowNum=1, highNum=20 })

	self.load_data = {}

	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode
	--self:createTableView(bg, cc.size(720, 510), cc.p(5, 5), true)

	self:createScroll()
end

function KnowLedgeListLayer:createScroll()
	local scrollView = cc.ScrollView:create()
    if nil ~= scrollView then
        scrollView:setViewSize(cc.size(720, 510))
        scrollView:setPosition(cc.p(15, 15))
        --scrollView:setScale(1.0)
        --scrollView:ignoreAnchorPointForPosition(true)
        local node = cc.Node:create()
        self.node = node
        scrollView:setContainer(node)
        scrollView:setContentSize(cc.size(720, 500))

        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        scrollView:setClippingToBounds(true)
        scrollView:setBounceable(true)
        self.baseNode:addChild(scrollView)
        self.scrollView = scrollView
    end
end

function KnowLedgeListLayer:updateScrollView()
	self.node:removeAllChildren()

	local getTimeStr = function(time) 
		local dates = os.date("*t",time)
		return string.format(game.getStrByKey("date_format"),dates.year,dates.month,dates.day,dates.hour,dates.min)
	end

	local x = 0
	local y = 0
	local padding = 0
	for i,v in ipairs(self.load_data) do
		local data = self.load_data[i]

		local timeStr = getTimeStr(data[1])
		local richText = require("src/RichText").new(self.node, cc.p(0, 0), cc.size(700, 30), cc.p(0, 0), 30, 20, MColor.Lable_yellow)
    	richText:addText(timeStr..": "..data[3])
    	richText:format()
		richText:setPosition(cc.p(x, y))

		y = y + richText:getContentSize().height
		y = y + padding
	end
	self.scrollView:setContentSize(cc.size(720, y))
	dump(y)
	if y < 510 then
	 	self.scrollView:setContentOffset(cc.p(0, 510-y), false)
	else
		self.scrollView:setContentOffset(cc.p(0, 0), false)
	end
end

function KnowLedgeListLayer:networkHander(buff,msgid)
--[[	local switch = {
		[FACTION_SC_GETMSGRECORD_RET] = function()    
			log("get FACTION_SC_GETMSGRECORD_RET"..msgid)
			self.load_data = {} 
			local num =  buff:readByFmt("c")
			for i=1,num do 
				self.load_data[i] = {buff:readByFmt("is")}
				for k,v in pairs(require("src/config/clientmsg"))do
					if 7000 == v.sth and  self.load_data[i][2] == v.mid then
						local param_num = buff:readByFmt("c")
						if v.fat and param_num == string.len(v.fat) then
							self.load_data[i][3] = string.format(v.msg,buff:readByFmt(v.fat))
						else
							self.load_data[i][3] = v.msg
						end
						local link_num = buff:readByFmt("c")
						for i=1,link_num do 
							self.load_data[i][4] = {buff:readByFmt("iS")}
						end
						break
					end
				end
			end	
			dump(self.load_data)
			--self:getTableView():reloadData()			
			self:updateScrollView()
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
    ]]
end

return KnowLedgeListLayer