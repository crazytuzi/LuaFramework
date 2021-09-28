-- FileName: FriendMail.lua 
-- Author: Li Cong 
-- Date: 13-8-20 
-- Purpose: function description of module 


module("FriendMail", package.seeall)

local mainLayer = nil
friendMailTableView = nil

-- 创建滑动列表
function createFriendMailTabView()
	-- cell的size
	local cellSize = { width = 584, height = 190 } 
	-- 得到好友邮件邮件列表数据
	MailData.showMailData = MailData.friendMailData.list
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

	friendMailTableView = LuaTableView:createWithHandler(handler, CCSizeMake(Mail.set_width,Mail.set_height))
	friendMailTableView:setBounceable(true)
	friendMailTableView:ignoreAnchorPointForPosition(false)
	friendMailTableView:setAnchorPoint(ccp(0.5, 1))
	friendMailTableView:setPosition(ccp(Mail.content_bg:getPositionX(),Mail.content_bg:getPositionY()-13))
	mainLayer:addChild(friendMailTableView)
	-- 设置单元格升序排列
	friendMailTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- 设置滑动列表的优先级
	friendMailTableView:setTouchPriority(-130)
end



-- 创建战报邮件层
function createFriendMail( ... )
	mainLayer = CCLayer:create()
	mainLayer:registerScriptHandler(function ( eventType,node )
        if(eventType == "enter") then
           friendMailTableView = nil
        end
        if(eventType == "exit") then
            friendMailTableView = nil
        end
    end)
	-- 创建下一步UI
	local function createNext( ... )
		-- 创建好友邮件列表
		createFriendMailTabView()
	end
	-- 初始化邮件数据 
	MailService.getPlayMailList(0,10,"true",createNext)

	return mainLayer
end






