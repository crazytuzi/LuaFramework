local fightLog = class("fightLog", require("src/TabViewLayer"))

function fightLog:ctor(parent)
	self.fightList = {}
	self.killNum = 0

	--local tipSp = popupBox({isNoSwallow = true,createScale9Sprite = { size = cc.size( 706 , 445 ) } , close = { scale = 0.7 , offX = 28,offY = 15 , callback = function() end } ,  bg = "res/common/5.png" ,  actionType = 5 ,  zorder = 200 } )
    local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	createLabel(bg, game.getStrByKey("fight_log"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-30), cc.p(0.5, 0.5), 24, true)
	local tipSp = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )
	local closeFunc = function() 
	   	bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0), cc.CallFunc:create(function() removeFromParent(self) end)))	
	end
	local closeBtn = createTouchItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-48, bg:getContentSize().height-28), closeFunc)

    self.tipSp = tipSp
    local bgsize = tipSp:getContentSize()
    registerOutsideCloseFunc( bg , function() closeFunc() end,true)
    -- createLabel(tipSp, game.getStrByKey("fight_log"),cc.p(  bgsize.width/2+5 , bgsize.height - 12 ) , cc.p( 0.5 , 1 ), 22, true)
    createSprite(tipSp, "res/common/bg/bg-1.png", cc.p(bgsize.width/2, 65), cc.p(0.5, 0.5))
    if parent then 
		parent:addChild(self,125)
	end
	local menu_item = createMenuItem(bg, "res/component/button/50.png", cc.p(bgsize.width/2+30, 45), closeFunc)
	createLabel(menu_item,game.getStrByKey("sure"),getCenterPos(menu_item),cc.p(0.5,0.5),22,true)
	self.lab = createLabel(tipSp,string.format(game.getStrByKey("kill_player1"),self.killNum),cc.p(bgsize.width-20,35),cc.p(1.0,0.5),25,true,nil,nil,MColor.white)
	--self.lab = createLabel(tipSp,self.killNum.."人",cc.p(bgsize.width-20,35),cc.p(1.0,0.5),25,true,nil,nil,MColor.green)
	self:showLog()
	self:createTableView(self.tipSp,cc.size(785,385),cc.p(3,65),true)
end

function fightLog:tableCellTouched(table,cell)

end

function fightLog:cellSizeForTable(table,idx) 
    return 50,775
end

function fightLog:tableCellAtIndex(table,idx)
	local strTemp = nil
	local data = self.fightList[idx+1]
	if not data then 
		return
	end
	local getTimeStr = function(time)
		local dates = os.date("*t",time)
		return string.format(game.getStrByKey("date_format"),dates.year,dates.month,dates.day,dates.hour,dates.min)
	end
	local str_tab = getTimeStr(data[2])
   
	local cell = table:dequeueCell()
	
	if not cell then
		cell = cc.TableViewCell:new() 
	end
	cell:removeAllChildren()
	if tonumber(data[3]) == 1 then
		
    	strTemp = string.format(game.getStrByKey("kill_player"),tostring(data[5]),tostring(data[4]))
    elseif tonumber(data[3]) == 2 then
    	strTemp = string.format(game.getStrByKey("killedByPlayer"),tostring(data[5]),tostring(data[4]))
    elseif tonumber(data[3]) == 3 then
    	strTemp = string.format(game.getStrByKey("kill_boss"),tostring(data[5]),tostring(data[4]))
    elseif tonumber(data[3]) == 4 then
    	strTemp = string.format(game.getStrByKey("kill_enemy"),tostring(data[5]),tostring(data[4]))
    end
	local l_item = createRichText(cell, cc.p(5,30), cc.size(775, 30), cc.p(0, 0.5), false, 10)
    addRichTextItem(l_item,str_tab.."   "..strTemp,MColor.lable_yellow,nil,20,255)
    return cell
end

function fightLog:numberOfCellsInTableView(table)
   	return self.temp
end

function fightLog:showLog()
	self.temp = 0
	local fightKeep = {}
	local setfile = getDownloadDir().."fight_"..tostring(userInfo.currRoleStaticId)..".cfg"
	local file = io.open(setfile,"r")
	if file then
		local line = file:read()
		while line do
			self.temp = self.temp + 1
			table.insert(fightKeep,line)
			line = file:read()
		end
		local fightTable = {}
		for i=#fightKeep,1,-1 do
			dump(fightKeep[i],"uuuuuuuuuuuuuuuuuu")
			fightTable = stringsplit(fightKeep[i],",")
			table.insert(self.fightList,fightTable)
		end
		self.killNum = tonumber(self.fightList[1][1])
		if self.killNum then
			self.lab:setString(string.format(game.getStrByKey("kill_player1"),self.killNum))
		end
		file:close()
	end
	
	
end

return fightLog