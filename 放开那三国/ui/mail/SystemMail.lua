-- FileName: SystemMail.lua 
-- Author: Li Cong 
-- Date: 13-8-20 
-- Purpose: function description of module 


module("SystemMail", package.seeall)


local mainLayer = nil
systemMailTableView = nil

-- 创建滑动列表
function createSystemMailTabView()
	-- cell的size
	local cellSize = { width = 584, height = 190 } 
	-- 得到系统邮件列表数据
	MailData.showMailData = MailData.systemMailData.list
	-- print(GetLocalizeStringBy("key_3256")) 
	-- print_t(MailData.showMailData)
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

	systemMailTableView = LuaTableView:createWithHandler(handler, CCSizeMake(Mail.set_width,Mail.set_height))
	systemMailTableView:setBounceable(true)
	systemMailTableView:ignoreAnchorPointForPosition(false)
	systemMailTableView:setAnchorPoint(ccp(0.5, 1))
	systemMailTableView:setPosition(ccp(Mail.content_bg:getPositionX(),Mail.content_bg:getPositionY()-13))
	mainLayer:addChild(systemMailTableView)
	-- 设置单元格升序排列
	systemMailTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- 设置滑动列表的优先级
	systemMailTableView:setTouchPriority(-130)
end


-- 创建战报邮件层
function createSystemMail( ... )
	mainLayer = CCLayer:create()
	mainLayer:registerScriptHandler(function ( eventType,node )
        if(eventType == "enter") then
           systemMailTableView = nil
        end
        if(eventType == "exit") then
            systemMailTableView = nil
        end
    end)
	-- 创建下一步UI
	local function createNext( ... )
		-- 创建系统邮件列表
		createSystemMailTabView()
	end
	-- 初始化邮件数据 
	MailService.getSysMailList(0,10,"true",createNext)
	return mainLayer
end







