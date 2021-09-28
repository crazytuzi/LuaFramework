-- FileName: AllMail.lua 
-- Author: Li Cong 
-- Date: 13-8-20 
-- Purpose: function description of module 


module("AllMail", package.seeall)


local mainLayer = nil
allMailTableView = nil

-- 创建滑动列表
function createAllMailTabView()
	-- cell的size
	local cellSize = { width = 584, height = 190 } 
	MailData.showMailData = MailData.getShowMailData(MailData.allMailData)
	print("showMailData:")
	print_t(MailData.showMailData)
	require "script/ui/mail/MailCell"
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			-- 显示单元格的间距
			local interval = 10
			r = CCSizeMake(cellSize.width*g_fScaleX, (cellSize.height + interval)*g_fScaleX)
		elseif (fn == "cellAtIndex") then
			r = MailCell.createCell(MailData.showMailData[a1+1])
			r:setScale(g_fScaleX)
		elseif (fn == "numberOfCells") then
			r = #MailData.showMailData
		elseif (fn == "cellTouched") then
			-- print ("a1: ", a1, ", a2: ", a2)
			-- print ("cellTouched, index is: ", a1:getIdx())
		elseif (fn == "scroll") then
			-- print ("scroll, index is: ")
		else
			-- print (fn, " event is not handled.")
		end
		return r
	end)

	allMailTableView = LuaTableView:createWithHandler(handler, CCSizeMake(Mail.set_width,Mail.set_height))
	allMailTableView:setBounceable(true)
	allMailTableView:ignoreAnchorPointForPosition(false)
	allMailTableView:setAnchorPoint(ccp(0.5, 1))
	allMailTableView:setPosition(ccp(Mail.content_bg:getPositionX(),Mail.content_bg:getPositionY()-13))
	mainLayer:addChild(allMailTableView)
	-- 设置单元格升序排列
	allMailTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- 设置滑动列表的优先级
	allMailTableView:setTouchPriority(-130)
end




-- 创建全部邮件层
function createAllMail( ... )
	mainLayer = CCLayer:create()
	-- mainLayer = CCLayerColor:create(ccc4(0,0,0,200))
	mainLayer:registerScriptHandler(function ( eventType,node )
        if(eventType == "enter") then
           allMailTableView = nil
        end
        if(eventType == "exit") then
            allMailTableView = nil
        end
    end)
	-- 创建下一步UI
	local function createNext( ... )
		-- 创建全部邮件列表
		createAllMailTabView()
	end
	-- 初始化全部邮件数据 
	MailService.getMailBoxList(0,10,"true",createNext)
	
	return mainLayer
end























