 --------------------------------------------------------------------------------------
-- 文件名: LKA_XiaoChu.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 陆奎安
-- 日  期:    2014-10-5 9:37
-- 版  本:    1.0
-- 描  述:    消除游戏
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------
LKA_XiaoChu = class("LKA_XiaoChu")
LKA_XiaoChu.__index = LKA_XiaoChu
--三消游戏
local tlength = 7
local tb_XiaoChu = {}
local tb_XiaoChuItem = {}
local tb_XiaoChuCleanId = {}
local tb_XiaoChuCleanSendId = {}
local newCreateItemMsg = {}
local b_siJu = false
local DeadClear = true
g_moveItem = {}

local function tSwap(tbItem,x1,y1,x2,y2)
	if tbItem[x1] and tbItem[x1][y1] and tbItem[x2] and tbItem[x2][y2] then
	end
	local swap = tbItem[x1][y1]
	tbItem[x1][y1] = tbItem[x2][y2]
	tbItem[x2][y2] = swap
	return tbItem
end
local function tmove(tbItem,x,y,direction)
	--移动 
	if direction=="d" then
		tSwap(tbItem,x,y,x+1,y)
	elseif direction=="u" then 
		tSwap(tbItem,x,y,x-1,y)
	elseif direction=="l" then
		tSwap(tbItem,x,y,x,y-1)
	elseif direction=="r"  then 
		tSwap(tbItem,x,y,x,y+1)
	end 
	return tbItem
end
local function tSwapItem(tbItem,tag1,tag2)
	if tbItem[tag1] and tbItem[tag2] then
		local swap = tbItem[tag1]
		tbItem[tag1] = tbItem[tag2]
		tbItem[tag2] = swap
	end
	return tbItem
end
local function tmoveItem(x,y,direction,nNum)
	local nNum = nNum or 1
	local tag1 = x*10+y
	--移动 
	local str=nil 
	if direction=="d"  then
		local tag2 = tag1 + nNum*10
		tSwapItem(tb_XiaoChuItem,tag1,tag2)
	elseif direction=="u"  then
		local tag2 = tag1 - nNum*10
		tSwapItem(tb_XiaoChuItem,tag1,tag2)
	elseif direction=="l"  then
		local tag2 = tag1 - nNum
		tSwapItem(tb_XiaoChuItem,tag1,tag2)
	elseif direction=="r"  then 
		local tag2 = tag1 + nNum
		tSwapItem(tb_XiaoChuItem,tag1,tag2)
	end 
end

local function tcheckDeadPiont_U(tbItem,x,y,value)
	if tbItem[x-1] and tbItem[x-2] and tbItem[x-1][y] and tbItem[x-2][y] and  value == tbItem[x-1][y]%10 and value == tbItem[x-2][y]%10 then
		g_moveItem[1] = {x,y,"u"}
		b_siJu = true
	end
end
local function tcheckDeadPiont_D(tbItem,x,y,value)
	if tbItem[x+1] and tbItem[x+2] and tbItem[x+1][y] and tbItem[x+2][y] and  value == tbItem[x+1][y]%10 and value == tbItem[x+2][y]%10 then
		g_moveItem[1] = {x,y,"d"}
		b_siJu = true
	end
	return false
end
local function tcheckDeadPiont_R(tbItem,x,y,value)
	--右
	if  tbItem[x] and  tbItem[x][y+1] and tbItem[x][y+2] and  value == tbItem[x][y+1]%10 and value == tbItem[x][y+2]%10 then
		g_moveItem[1] = {x,y,"r"}
		b_siJu = true
	end
	return false
end
local function tcheckDeadPiont_L(tbItem,x,y,value)
	--左9/
	if tbItem[x] and tbItem[x][y-1] and tbItem[x][y-2] and  value == tbItem[x][y-1]%10 and value == tbItem[x][y-2]%10 then
		g_moveItem[1] = {x,y,"l"}
		b_siJu = true
	end
end
local function tcheckDeadPiont(tbItem,x,y,direction)
	local value = tbItem[x][y]%10
	if direction == "u" then
		x = x - 1
		tcheckDeadPiont_U(tbItem,x,y,value)
		tcheckDeadPiont_R(tbItem,x,y,value)
		tcheckDeadPiont_L(tbItem,x,y,value)
		if tbItem[x] and tbItem[x][y+1] and tbItem[x][y-1] and  value == tbItem[x][y-1]%10 and value == tbItem[x][y+1]%10 then
			g_moveItem[1] = {x,y,"u"}
			b_siJu = true
		end
	elseif  direction == "d" then
		x = x + 1
		tcheckDeadPiont_D(tbItem,x,y,value)
		tcheckDeadPiont_R(tbItem,x,y,value)
		tcheckDeadPiont_L(tbItem,x,y,value)
		if tbItem[x] and tbItem[x][y+1] and tbItem[x][y-1] and  value == tbItem[x][y-1]%10 and value == tbItem[x][y+1]%10 then
			g_moveItem[1] = {x,y,"d"}
			b_siJu = true
		end
	elseif  direction == "l" then
		y = y - 1
		if  tbItem[x+1] and  tbItem[x-1] and  tbItem[x+1][y] and tbItem[x-1][y] and  value == tbItem[x-1][y]%10 and value == tbItem[x+1][y]%10 then
			g_moveItem[1] = {x,y,"l"}
			b_siJu = true
		end
		tcheckDeadPiont_U(tbItem,x,y,value)
		tcheckDeadPiont_D(tbItem,x,y,value)
		tcheckDeadPiont_L(tbItem,x,y,value)
	elseif  direction == "r" then
		y = y + 1
		if  tbItem[x+1] and  tbItem[x-1] and  tbItem[x+1][y] and tbItem[x-1][y] and  value == tbItem[x-1][y]%10 and value == tbItem[x+1][y]%10 then
			g_moveItem[1] = {x,y,"r"}
			b_siJu = true
		end
		tcheckDeadPiont_U(tbItem,x,y,value)
		tcheckDeadPiont_D(tbItem,x,y,value)
		tcheckDeadPiont_R(tbItem,x,y,value)
	end
	return b_siJu
end

local function tcheckDead(tbItem)
	b_siJu = false
	--检查死局
	local counter 
	for i=1,tlength do 
		for j=1,tlength do
			if  tcheckDeadPiont(tbItem,i,j,"u") ==true then
				g_moveItem[2] = {i,j,"u"}
				counter = true
				return counter
			end
			if  tcheckDeadPiont(tbItem,i,j,"d")==true then
				g_moveItem[2] = {i,j,"d"}
				counter = true
				return counter
			end
			if tcheckDeadPiont(tbItem,i,j,"r")==true then
				g_moveItem[2] = {i,j,"r"}
				counter = true
				return counter
			end
			if tcheckDeadPiont(tbItem,i,j,"l")==true then
				g_moveItem[2] = {i,j,"l"}
				counter = true
				return counter
			end			
		end
	end
	
	return false
end

local function tcheckBoomb(tbItem,x,y,t2)
	tbItem[x][y] = tbItem[x][y] % 10
	for i=1,tlength do
		t2[i*10+y] = tbItem[x][y]%10
		t2[x*10+i] = tbItem[x][y]%10
	end
end

local function tcheck(tbItem)
	--检查  
	tb_XiaoChuCleanId = {}
	local counter=0 
	for i=1,tlength do 
		for j=1,tlength do
			if j>2 and tbItem[i][j]%10 == tbItem[i][j-1]%10 and  tbItem[i][j]%10 == tbItem[i][j-2]%10 and tbItem[i][j] ~= 0 then 
				
				if tbItem[i][j] > 10 then tcheckBoomb(tbItem,i,j,tb_XiaoChuCleanId) end
				if tbItem[i][j-1] > 10 then tcheckBoomb(tbItem,i,j-1,tb_XiaoChuCleanId)end
				if tbItem[i][j-2] > 10 then tcheckBoomb(tbItem,i,j-2,tb_XiaoChuCleanId)end
				tb_XiaoChuCleanId[i*10+j] = tbItem[i][j]%10 
				tb_XiaoChuCleanId[i*10+j-1] = tbItem[i][j]%10 
				tb_XiaoChuCleanId[i*10+j-2] = tbItem[i][j]%10 
				tb_XiaoChuCleanSendId[i*10+j] = tbItem[i][j]%10 
				tb_XiaoChuCleanSendId[i*10+j-1] = tbItem[i][j]%10 
				tb_XiaoChuCleanSendId[i*10+j-2] = tbItem[i][j]%10 
				
				counter=counter+1
				
				if j>3 and tbItem[i][j]%10 == tbItem[i][j-3]%10 then
					if j>4 and tbItem[i][j]%10 == tbItem[i][j-4]%10 then 
						tb_XiaoChuCleanId[i*10+j-4] = tbItem[i][j]%10
						tb_XiaoChuCleanSendId[i*10+j-4] = tbItem[i][j]%10

						if tbItem[i][j-4] > 10 then tcheckBoomb(tbItem,i,j-4,tb_XiaoChuCleanId) end
					else
						tb_XiaoChuCleanId[i*10+j-3] = tbItem[i][j]%10
						tb_XiaoChuCleanSendId[i*10+j-3] = tbItem[i][j]%10

						if tbItem[i][j-3] > 10 then tcheckBoomb(tbItem,i,j-3,tb_XiaoChuCleanId) end
					end
				end
			end
			if i>2 and tbItem[i-1][j]%10 == tbItem[i][j]%10 and tbItem[i-2][j]%10 == tbItem[i][j]%10 and tbItem[i][j] ~= 0 then 
				tb_XiaoChuCleanId[i*10+j] = tbItem[i][j]%10
				tb_XiaoChuCleanId[(i-1)*10+j] = tbItem[i][j]%10
				tb_XiaoChuCleanId[(i-2)*10+j] = tbItem[i][j]%10
				tb_XiaoChuCleanSendId[i*10+j] = tbItem[i][j]%10
				tb_XiaoChuCleanSendId[(i-1)*10+j] = tbItem[i][j]%10
				tb_XiaoChuCleanSendId[(i-2)*10+j] = tbItem[i][j]%10

				if tbItem[i][j] > 10 then tcheckBoomb(tbItem,i,j,tb_XiaoChuCleanId) end
				if tbItem[i-1][j] > 10 then tcheckBoomb(tbItem,i-1,j,tb_XiaoChuCleanId)end
				if tbItem[i-2][j] > 10 then tcheckBoomb(tbItem,i-2,j,tb_XiaoChuCleanId)end
				counter=counter+1 
				if i>3 and  tbItem[i-3][j]%10 == tbItem[i][j]%10 then 
					if i>4 and tbItem[i-4][j]%10 == tbItem[i][j]%10 then 
						tb_XiaoChuCleanId[(i-4)*10+j] = tbItem[i][j]%10
						tb_XiaoChuCleanSendId[(i-4)*10+j] = tbItem[i][j]%10

						if tbItem[i-4][j] > 10 then tcheckBoomb(tbItem,i+4,j,tb_XiaoChuCleanId) end
					else
						tb_XiaoChuCleanId[(i-3)*10+j] = tbItem[i][j]%10
						tb_XiaoChuCleanSendId[(i-3)*10+j] = tbItem[i][j]%10

						if tbItem[i-3][j] > 10 then tcheckBoomb(tbItem,i+3,j,tb_XiaoChuCleanId) end
					end 
				end
			end
		end
	end
	
	for tag,v in pairs(tb_XiaoChuCleanId)do
		local i = math.floor(tag/10)
		local j = tag%10
		tbItem[i][j] = 0
	end
	return counter
end

local function onemove(tbItem,x,y,direction)
	--完整的一次移动 
	local counter=0 
	local counter2=0

	tbItem = tmove(tbItem,x,y,direction) 
	counter = tcheck(tbItem) 
	if counter>0 then 
		tmoveItem(x,y,direction,1)
	else 
		tbItem = tmove(tbItem,x,y,direction)
	end
	return counter
 end
 
--==============================================================================================
function LKA_XiaoChu:itemContItemDown()
	if not g_WndMgr:getWnd("Game_XianMai") then return end
	local nIndex = tlength
	for i=1,14 do
		local x = nIndex-i
		for j=1,tlength do
			local y = j
			if x < 0 then
				y = 0 - j
			end
			local tag = x*10+y
			if tb_XiaoChuItem[tag] then
				local item = tb_XiaoChuItem[tag].item
				local value = tb_XiaoChuItem[tag].value
				local step = tb_XiaoChuItem[tag].step

				if step ~= 0 then
					local y = math.abs(y)
					nextTag = x*10 + step*10 + y 
					
					local index_X = math.floor(nextTag/10)
					local index_Y = nextTag%10
					tb_XiaoChuItem[nextTag] = {}
					tb_XiaoChuItem[nextTag].step = 0
					tb_XiaoChuItem[nextTag].item = item
					tb_XiaoChuItem[nextTag].value = value
					item:setTag(nextTag)
					tb_XiaoChuItem[tag] = nil
					tb_XiaoChu[index_X][index_Y] = value
				end
			end
		end
	end
end

function LKA_XiaoChu:removeCover()
	if self.cover then 
		self.cover:removeFromParentAndCleanup(false)
		self.cover = nil
	end
end


function LKA_XiaoChu:itemSendMsg()
	self.b_actionEnd = false
	self.cover = creationCover(self.rootWidget)
	local counter = tcheck(tb_XiaoChu) 
	if counter>0 then
		self:setData()
	else
		local b_dead = tcheckDead(tb_XiaoChu)
		self.itemSkilStatus =  true
		if b_dead == true then
			cclog("=======活的=======")	
			self.b_actionEnd = true
			self:removeCover()
		else
			cclog("=====死局========")	
			self:requestDeadClearRequest()
		end	
	end		
end

function LKA_XiaoChu:itemContItemDownAction(tbmsg,b_first,b_end)
	if not g_WndMgr:getWnd("Game_XianMai") then return end
	local widget = tbmsg.item
	local nNum = tbmsg.step
	local value = tbmsg.value
	local poY = -70*nNum
	if not widget or not widget:isExsit() then
		return
	end
	local poX = widget:getPositionX()
	local ntime = 0.05
	local tag = widget:getTag()
	local x = math.floor(tag/10)
	local y = tag%10
	local swp = tag
	if tag < 0 then
		swp = 0 - tag
		y = swp%10
		x = 0-math.floor(swp/10)
	end
	local pos2 = ccp(40+70*(y-1),460-70*(x-1+nNum))
	local moveBy = CCMoveTo:create(ntime,pos2)
	local function CallBack()
		b_end = b_end + 1
		if b_end == b_first then
			self:itemContItemDown()
			tb_XiaoChuCleanId = {}
			tb_XiaoChuCleanSendId = {}
			self:requestBoxInfoRequest()		
		end
	end
	local arrAct = CCArray:create()
    arrAct:addObject(moveBy)
	arrAct:addObject(CCCallFuncN:create(CallBack))
	local mActionSpa1 = CCSequence:create(arrAct)
	widget:runAction(mActionSpa1)
end

function LKA_XiaoChu:itemAddAction()
	for tag,v in pairs(tb_XiaoChuCleanId)do
		local x = math.floor(tag/10)
		local y = tag%10
		if newCreateItemMsg[y] then
			local nNum = 1- #newCreateItemMsg[y]
			for i=nNum,x-1 do
				if i<0 then
					y = 0-(tag%10)
				else
					y = tag%10
				end
				local nTag = i*10+y
				if tb_XiaoChuItem[nTag] then
					tb_XiaoChuItem[nTag].step = tb_XiaoChuItem[nTag].step + 1
				end
			end
		else
			--
		end 
	end
	local b_first = 1
	local b_end = 1
	for i,v in pairs(tb_XiaoChuItem) do
		if v.step > 0 then
			b_first = b_first + 1
			self:itemContItemDownAction(v,b_first,b_end)
		end
	end
end
function LKA_XiaoChu:itemCleanAction()
	local b_first = 1
	local b_end = 1
	for tag,v in pairs(tb_XiaoChuCleanId)do
		local armatureSanXiaoClear,userAnimationSanXiaoClear
		local function SanXiaoClearEndCallBack()
			local item = tb_XiaoChuItem[tag].item
			item:removeFromParentAndCleanup(true)
			tb_XiaoChuItem[tag] = nil
			b_end = b_end + 1
			if b_end == b_first then
				self:itemAddAction()
			end
		end
		armatureSanXiaoClear,userAnimationSanXiaoClear = g_CreateCoCosAnimationWithCallBacks("SanXiaoClearAnimation", nil, SanXiaoClearEndCallBack, 5)
		b_first = b_first + 1
		local item = tb_XiaoChuItem[tag] and tb_XiaoChuItem[tag].item
		if item and item:isExsit() then --会出现空的情况 
			item:addNode(armatureSanXiaoClear, 12)
			userAnimationSanXiaoClear:playWithIndex(0)
		end
	end
end
function LKA_XiaoChu:itemAction(widge1,widge2,b_Reverse)
	if not widge1 or not widge1:isExsit() or not widge2 or not widge2:isExsit() then
		return 
	end
	local tag1 = widge1:getTag()
	local tag2 = widge2:getTag()
	local i = math.floor(tag1/10)
	local j = tag1%10
	local pos1 = ccp(40+70*(j-1),460-70*(i-1))
	local i = math.floor(tag2/10)
	local j = tag2%10
	local pos2 = ccp(40+70*(j-1),460-70*(i-1))
	
	local moveBy1 = CCMoveTo:create(0.1,pos2)
	local moveBy2 = CCMoveTo:create(0.1,pos1)
	local moveBy11 = CCMoveTo:create(0.1,pos1)
	local moveBy21 = CCMoveTo:create(0.1,pos2)
	local function CallBack111()
		self.b_actionEnd = true
		self:removeCover()
		self.itemSkilStatus =  true
	end
	local arrAct = CCArray:create()
    arrAct:addObject(moveBy1)
	arrAct:addObject(moveBy11)
	arrAct:addObject(CCCallFuncN:create(CallBack111))
	local mActionSpa1 = CCSequence:create(arrAct)
	local mActionSpa2 = CCSequence:createWithTwoActions(moveBy2,moveBy21)
	
	local function funcCallBack11()
		self.b_actionEnd = false
		self.cover = creationCover(self.rootWidget)
		self:setData(tag1,tag2)
	end
	local mActionSpa11 = CCSequence:createWithTwoActions(moveBy1,CCCallFuncN:create(funcCallBack11) )
	if b_Reverse == true then
		widge1:runAction(mActionSpa1)
		widge2:runAction(mActionSpa2)
	else
		widge1:runAction(mActionSpa11)
		widge2:runAction(moveBy2)
	end
end
function LKA_XiaoChu:onClickCallBack(pSender)
	local nPos = pSender:getTouchMovePos()
	if not self.curPos then
		return
	end
	local posX =  nPos.x - self.curPos.x
	local posY =  nPos.y - self.curPos.y
	local counter = nil
	local widge1 = pSender
	local widge2 = nil
	if math.abs(posX) > math.abs(posY)  then
		local tag = pSender:getTag()
		if  posX > 20 then
			if tb_XiaoChuItem[tag+1] then
				widge2 = tb_XiaoChuItem[tag+1].item
				counter = onemove(tb_XiaoChu,math.floor(tag/10),tag%10,"r")
				self.b_actionEnd = false
				self.touch = false
				self.cover = creationCover(self.rootWidget)
			end
		elseif  posX < -20 then
			if tb_XiaoChuItem[tag-1] then
				widge2 = tb_XiaoChuItem[tag-1].item
				counter = onemove(tb_XiaoChu,math.floor(tag/10),tag%10,"l")
				self.b_actionEnd = false
				self.touch = false
				self.cover = creationCover(self.rootWidget)
			end
		end
	elseif math.abs(posX) < math.abs(posY) then
		local tag = pSender:getTag()
		if posY > 20  then
			if tb_XiaoChuItem[tag-10] then
				widge2 = tb_XiaoChuItem[tag-10].item
				counter = onemove(tb_XiaoChu,math.floor(tag/10),tag%10,"u")	
				self.b_actionEnd = false
				self.touch = false
				self.cover = creationCover(self.rootWidget)
			end
		elseif posY < -20 then
			if tb_XiaoChuItem[tag+10] then
				widge2 = tb_XiaoChuItem[tag+10].item
				counter = onemove(tb_XiaoChu,math.floor(tag/10),tag%10,"d")	
				self.b_actionEnd = false
				self.cover = creationCover(self.rootWidget)
				self.touch  = false
			end
		end
	end 
	if not counter  then
	elseif counter >= 1  then
		g_playSoundEffect("Sound/ButtonClick1.mp3")
		self:itemAction(widge1,widge2)
	elseif counter < 1 then
		g_playSoundEffect("Sound/ButtonClick1.mp3")
		self:itemAction(widge1,widge2,true)
	end
end

function LKA_XiaoChu:Init()
	--消除响应
	local order = msgid_pb.MSGID_ELEMENT_CLEAR_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestElementClearResponse))
	local order = msgid_pb.MSGID_XIANMAI_DEAD_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestDeadResponse))
	local order = msgid_pb.MSGID_XIANMAI_BOXINFO_NOTIFY
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestBoxInfoResponse))
	local order = msgid_pb.MSGID_XIANMAI_ONE_KEY_CLEAR_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.XianMaiOneKeyClearResponse))
	local order = msgid_pb.MSGID_XIANMAI_SKILL_LIANSUO_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.XianMaiSkillLianSuoResponse))
	local order = msgid_pb.MSGID_XIANMAI_SKILL_DOUZHUAN_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.XianMaiSkillDouZhuanResponse))
	local order = msgid_pb.MSGID_XIANMAI_SKILL_COMMON_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.XianMaiSkillCommonResponse))
	self.itemSkilStatus =  true
end

function LKA_XiaoChu:setElement(i,j,newValue)
	local  value
	if newValue then
		value = newValue
	else
		value = tb_XiaoChu[i][j] 
	end

	if value == 0 then
		return
	end
	local nIconIndex = value%10
	local Button_Element = tolua.cast(self.Button_Element11:clone(), "Button")
	Button_Element:setVisible(true)
	Button_Element:loadTextureNormal(getXianMaiImg("Element"..nIconIndex))
	Button_Element:loadTexturePressed(getXianMaiImg("Element"..nIconIndex.."_Press"))
	local y = j
	if i<0 then
		y = 0-j
	end
	local tag = i*10+y
	Button_Element:setTag(tag)
	self.sanXiaoWidge:addChild(Button_Element)
	
	Button_Element:setPosition(ccp(40+70*(j-1),460-70*(i-1)))
	tb_XiaoChuItem[tag] = {}
	tb_XiaoChuItem[tag]= {item = Button_Element,step = 0,value = value}
	local function BtnRunAction()
		self.b_actionEnd = true
		self:removeCover()
	end
	
	local function onClickUpgradeFate(pSender,eventType)
		local tag = pSender:getTag()
		local Essence =	g_Hero:getEssence()
		local NeedElementCoreNum = self.tbXianMaimsg.NeedElementCoreNum
		if Essence < NeedElementCoreNum then
            if eventType ==ccs.TouchEventType.began then
			    g_ClientMsgTips:showMsgConfirm( _T("您的灵力不足请休息会吧") )
            end
			return
		end
		if eventType ==ccs.TouchEventType.began and self.b_actionEnd == true then
			local value = tb_XiaoChuItem[tag].value

			self.touch = true
			local i = math.floor(tag/10)
			local j = tag%10

			self.curIdex = tag
			self.curPos = pSender:getTouchStartPos()   
		elseif eventType ==ccs.TouchEventType.moved and self.b_actionEnd == true and self.touch  == true then

			self.cover = creationCover(self.rootWidget)
			self.itemSkilStatus =  false
			self:onClickCallBack(pSender)
		elseif eventType ==ccs.TouchEventType.ended or eventType ==ccs.TouchEventType.canceled then
			self.touch  = true 
			self.curIdex = 0
			self.curPos = ccp(0,0)
		end
	end
	
	Button_Element:addTouchEventListener(onClickUpgradeFate)
	Button_Element:setTouchEnabled(true)
	if value > 10 then
		local armatureSanXiaoClear,userAnimationSanXiaoClear = g_CreateCoCosAnimationWithCallBacks("SanXiaoElementBomb", nil, nil, 5)
		Button_Element:addNode(armatureSanXiaoClear, 12)
		userAnimationSanXiaoClear:playWithIndex(0)
	end
end

function LKA_XiaoChu:checkData()
	tb_XiaoChu = g_XianMaiInfoData:getTbBox_info()
	if not tb_XiaoChu then
		return false
	end
	return true
end

function LKA_XiaoChu:Open(tb_nedmsg)
	self.tb_nedmsg = tb_nedmsg or self.tb_nedmsg
	local Level = g_XianMaiInfoData:getXianmaiLevel()
	self.tbXianMaimsg = g_DataMgr:getCsvConfigByOneKey("PlayerXianMai",Level)
	self.sanXiaoWidge = self.tb_nedmsg.widget
	self.Button_Element11 = self.tb_nedmsg.Element
	self:Init()
	tb_XiaoChu = g_XianMaiInfoData:getTbBox_info()
	if not tb_XiaoChu then
		--找不到定义的地方
		--self:requestXianmaiInfoResponses()
		return
	end
	self.sanXiaoWidge:removeAllChildren()
	for i=1,tlength do
		for j=1,tlength do
			self:setElement(i,j)
		end
	end
	self.b_actionEnd =  true
	self:removeCover()
	self.touch = true
	
	local b_dead = tcheckDead(tb_XiaoChu)
	if b_dead == true then
		cclog("=====死局========")	
	else
		self:requestDeadClearRequest()
	end	
	self.itemSkilStatus =  true
end

function LKA_XiaoChu:setNewItemData(tbMsg)
	local nNum = 0
	newCreateItemMsg = {}
	for i,v in ipairs(tbMsg) do
		local y = v.col+1
		newCreateItemMsg[y] = {}
		for j,n in ipairs(v.data) do
			local value = n
			table.insert(newCreateItemMsg[y],value)
			nNum = nNum + 1
			self:setElement(1-j,y,n)
		end
	end

	local clianNum = 0
	for tag,v in pairs(tb_XiaoChuCleanId)do
		clianNum = clianNum + 1
	end
	if nNum == clianNum then
		return true
	else
		return false
	end
end

function LKA_XiaoChu:requestDeadResponse(tbMsg)
	--
end
--死局
function LKA_XiaoChu:requestDeadClearRequest()
	if DeadClear then
		self.b_actionEnd = true
		self:removeCover()
		g_MsgMgr:sendMsg(msgid_pb.MSGID_XIANMAI_DEAD_REQUEST)
	else
		
	end
end
--更换颜色
function LKA_XiaoChu:changeItemByColor(fromColor,toColor)
	for i=1,tlength do  
		for j = 1,tlength do
			if tb_XiaoChu[i][j]%10 == fromColor then
				local toColor = toColor or 1
				if tb_XiaoChu[i][j] > 10 then
					toColor = 10 + toColor
					tb_XiaoChu[i][j] = toColor
				else
					tb_XiaoChu[i][j] = toColor
				end
				self:setElement(i,j,toColor)
			end
		end
	end
	local counter = tcheck(tb_XiaoChu) 
	if counter>0 then
		self:setData()
	else
		self.itemSkilStatus =  true	
	end
end

--************************************消息*******************************************************
--仙脉格子信息请求
function LKA_XiaoChu:requestBoxInfoRequest()
	g_MsgMgr:sendMsg(msgid_pb.MSGID_XIANMAI_BOXINFO_REQUEST)
end
--仙脉格子信息
function LKA_XiaoChu:requestBoxInfoResponse(tbMsg)
	local msgDetail = zone_pb.XianMaiBoxNotify()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	self.b_actionEnd = false
	self.cover = creationCover(self.rootWidget)

	local dif = {}

	for i = 1,7 do	
		local wps = ""
		for j=1,7 do
			local value = msgDetail.box_info[i].box_data[j]
			wps = wps.."  "..msgDetail.box_info[i].box_data[j]
			if tb_XiaoChu[i][j] ~= value then
				local tag = i*10 + j
				table.insert(dif,tag)
			end
		end
	end

	for i = 1,7 do	
		local wps = ""
		for j=1,7 do
			wps = wps.."  "..tb_XiaoChu[i][j]
		end
	end		
	
	if #dif == 0 then
		self:itemSendMsg()
	else
		for i,v in ipairs(dif) do
			--找不到定义的地方
			--self:requestXianmaiInfoResponses()
		end
	end
end

function LKA_XiaoChu:requestElementClearResponse(tbMsg)
	local msgDetail = zone_pb.ElementClearResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local new_box_info = msgDetail.new_box_info
	local b_true = self:setNewItemData(new_box_info)
	
	--消除动画
	self.b_actionEnd = false
	self.cover = creationCover(self.rootWidget)
	self:itemCleanAction()
	self.b_actionEnd = false
	self.cover = creationCover(self.rootWidget)

	self.tb_nedmsg.func(msgDetail.update_essence, msgDetail.update_eleinfo)

	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_XianMai") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end

--请求消除的序号
function LKA_XiaoChu:requestElementClearRequest(msg,tag1,tag2)
	local rootMsg = zone_pb.ElementClearRequest()
	if tag1 and tag2 then
		rootMsg.movefrom = tag1-11
		rootMsg.moveto  = tag2-11
	end
	for i,v in ipairs(msg) do
		table.insert(rootMsg.index,v)
	end	
	if tb_XiaoChuItem[tag1] then
		tb_XiaoChuItem[tag1].item:setTag(tag1)
	end
	if tb_XiaoChuItem[tag2] then
		tb_XiaoChuItem[tag2].item:setTag(tag2)
	end
	
	g_MsgMgr:sendMsg(msgid_pb.MSGID_ELEMENT_CLEAR_REQUEST,rootMsg)
end

function LKA_XiaoChu:setData(tag1,tag2)
	self.tb_serverCleanId = {}
	for tag,v in pairs(tb_XiaoChuCleanSendId)do
		local value = v*100+tag-11
		table.insert(self.tb_serverCleanId,value)
	end
	if self.OneKeyStatus ~= true then
		self:requestElementClearRequest(self.tb_serverCleanId,tag1,tag2)
	else
		self:XianMaiOneKeyClearRequest(self.tb_serverCleanId,tag1,tag2)
	end
end

--一键消除
function LKA_XiaoChu:itemOneKeyClear()
	if self.itemSkilStatus ==  true then
		self.OneKeyStatus = true
		self.itemSkilStatus =  false
		counter = onemove(tb_XiaoChu,g_moveItem[2][1],g_moveItem[2][2],g_moveItem[2][3])
		g_playSoundEffect("Sound/ButtonClick1.mp3")
		local tag = g_moveItem[1][1]*10 + g_moveItem[1][2]
		local tag2 = g_moveItem[2][1]*10 + g_moveItem[2][2]
		local widge1 = tb_XiaoChuItem[tag].item
		local widge2 = tb_XiaoChuItem[tag2].item
		self:itemAction(widge1,widge2)
	end
end

--技能
--一键消除信息请求
function LKA_XiaoChu:XianMaiOneKeyClearRequest(msg,tag1,tag2)
	local rootMsg = zone_pb.XianMaiOneKeyClearRequest()
	if tag1 and tag2 then
		rootMsg.movefrom = tag2-11
		rootMsg.moveto  = tag1-11
	end
	for i,v in ipairs(msg) do
		table.insert(rootMsg.index,v)
	end	
	if tb_XiaoChuItem[tag1] then
		tb_XiaoChuItem[tag1].item:setTag(tag1)
	end
	if tb_XiaoChuItem[tag2] then
		tb_XiaoChuItem[tag2].item:setTag(tag2)
	end
	g_MsgMgr:sendMsg(msgid_pb.MSGID_XIANMAI_ONE_KEY_CLEAR_REQUEST,rootMsg)
end

--一键消除信息信息
function LKA_XiaoChu:XianMaiOneKeyClearResponse(tbMsg)
	local tbMsgDetail = zone_pb.XianMaiOneKeyClearResponse()
	tbMsgDetail:ParseFromString(tbMsg.buffer)
	
	local msgDetail = tbMsgDetail.res
	local new_box_info = msgDetail.new_box_info
	local b_true = self:setNewItemData(new_box_info)
	self.OneKeyStatus = false
	
	--消除动画
	self.b_actionEnd = false
	self.cover = creationCover(self.rootWidget)
	self:itemCleanAction()
	self.b_actionEnd = false
	self.cover = creationCover(self.rootWidget)

	self.tb_nedmsg.func(msgDetail.update_essence, msgDetail.update_eleinfo)
	local wnd = g_WndMgr:getWnd("Game_XianMai")
	g_XianMaiInfoData:setTbXianmaiSkillNum(1,tbMsgDetail.can_use_times)
	
	if wnd then
		wnd:setSkillButton(1)
	end
end
--其他技能信息请求
function LKA_XiaoChu:XianMaiSkillRequest(index)
	if self.itemSkilStatus == true then
		self.itemSkilStatus = false
		local rootTbMsg = zone_pb.XianMaiSkillRequest()
		rootTbMsg.skill_pos = index - 1
		g_MsgMgr:sendMsg(msgid_pb.MSGID_XIANMAI_USE_SKILL_REQUEST,rootTbMsg)
	end
end

--使用技能 清除连锁
function LKA_XiaoChu:skillLianSuo(value)
	self.tb_serverCleanId = {}
	tb_XiaoChuCleanId = {}
	for i=1,tlength do  
		for j = 1,tlength do
			if tb_XiaoChu[i][j] == value then
				local itemValue = value*100 + (i-1)*10 + j - 1
				tb_XiaoChuCleanId[i*10+j] = itemValue
			elseif tb_XiaoChu[i][j]%10 == value then
				local itemValue = value*100 + (i-1)*10 + j - 1
				for col = 1,tlength do
					tb_XiaoChuCleanId[col*10+j] = itemValue
				end
				for row = 1,tlength do
					tb_XiaoChuCleanId[i*10+row] = itemValue
				end
			end
		end
	end
	for i,v in pairs(tb_XiaoChuCleanId)do
		table.insert(self.tb_serverCleanId,v)
	end
	self:requestElementClearRequest(self.tb_serverCleanId)
end

--使用技能 清除连锁的响应返回
function LKA_XiaoChu:XianMaiSkillLianSuoResponse(tbMsg)
	local msgDetail = zone_pb.XianMaiSkillLianSuoResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local index = msgDetail.skill_pos + 1
	g_XianMaiInfoData:setTbXianmaiSkillNum(index,msgDetail.can_use_times)
	local wnd = g_WndMgr:getWnd("Game_XianMai")
	if wnd then
		wnd:setSkillButton(index)
	end
	self:skillLianSuo(msgDetail.to_del_data)
	if wnd then
		wnd:essenceNum(msgDetail.update_essence)
	end
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_XiaoChuSkill") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end

--使用技能 斗转星移的响应返回
function LKA_XiaoChu:XianMaiSkillDouZhuanResponse(tbMsg)
	local msgDetail = zone_pb.XianMaiSkillDouZhuanResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local index = msgDetail.skill_pos + 1
	g_XianMaiInfoData:setTbXianmaiSkillNum(index,msgDetail.can_use_times)
	local wnd = g_WndMgr:getWnd("Game_XianMai")
	if wnd then
		wnd:setSkillButton(index)
	end
	
	self:changeItemByColor(msgDetail.from_data,msgDetail.to_data)
	
	if wnd then
		wnd:essenceNum(msgDetail.update_essence)
	end
end 

--改变7*7里面格子
function LKA_XiaoChu:setSkillCommonItems(tbMsg)
	tb_XiaoChu = g_XianMaiInfoData:getTbBox_info()
	if not tb_XiaoChu then
		--找不到定义的地方
		--self:requestXianmaiInfoResponses()
		return
	end
	self.sanXiaoWidge:removeAllChildren()
	for i=1,tlength do
		for j=1,tlength do
			self:setElement(i,j)
		end
	end
	self.b_actionEnd =  true
	self:removeCover()
	self.touch = true
	local b_dead = tcheckDead(tb_XiaoChu)
	if b_dead == true then
		cclog("=====死局========")	
	else
		self:requestDeadClearRequest()
	end	
	self.itemSkilStatus =  true
end
-- 其他仙脉技能使用返回， 都是改变7*7里面格子的信息
function LKA_XiaoChu:XianMaiSkillCommonResponse(tbMsg)
	local msgDetail = zone_pb.XianMaiSkillCommonResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	local wnd = g_WndMgr:getWnd("Game_XianMai")
	local index = msgDetail.skill_pos + 1

	g_XianMaiInfoData:setTbXianmaiSkillNum(index,msgDetail.can_use_times)
	if wnd then
		wnd:setSkillButton(index)
	end
	
	for i,v in ipairs(msgDetail.change_list)do  
		local col = v.col+1
		local row = v.row+1
		g_XianMaiInfoData:setTbBox_infoByIndex(row,col,v.data)
	end
	self:setSkillCommonItems(tb_nedmsg)
	
	if wnd then
		wnd:essenceNum(msgDetail.update_essence)
	end
end
g_XiaoChu = LKA_XiaoChu.new()   
