 --------------------------------------------------------------------------------------
-- 文件名: InspireShow.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 
-- 日  期:   
-- 版  本:    感悟系统技能表现
-- 描  述:    
-- 应  用:  依赖Game_InspireForm
---------------------------------------------------------------------------------------

InspireBase = class("InspireBase")
InspireBase.__index = InspireBase

function InspireBase:ctor()
	self.next = nil
	self.form = nil
	self.tbWgt = {} --感悟界面的root窗口
end

function InspireBase:InitWgt(tbWgt, form)
	self.tbWgt = tbWgt
	self.form = form
end

function InspireBase:SetNextShow(anext)
		self.next = anext
		anext:InitWgt(self.tbWgt, self.form)
end

function InspireBase:GetNextShow()
	return self.next
end

function InspireBase:ShowEnd()
	cclog("-------------InspireBase:ShowEnd------------")
	if self.next ~= nil then
		self.next:ShowAction()
	else
		self:ActionOver()
	end
end

function InspireBase:ActionOver()
	--先吧system的元素颜色重置
	if self.tbWgt ~= nil then
		local nindex = 0
		local ncolor = -1
		local wgt = nil
		for i=1, 7 do
			for j=1, 7 do
				nindex = g_EliminateSystem:GetIndex(i, j)
				wgt = self.tbWgt:getChildByTag(nindex)
				if wgt ~= nil then
					local wgtMask = wgt:getChildByName("Image_Mask")
					ncolor = wgtMask:getTag()
					g_EliminateSystem:SetElementColor(i, j, ncolor)
				end
				
			end
		end
		-- if self.form ~= nil then
			-- self.form:CritecalAction()
		-- end
	end
	--通知system
	g_FormMsgSystem:SendFormMsg(FormMsg_InspireForm_ActionOver, nil)
	cclog("=======InspireBase:ActionOver======="..FormMsg_InspireForm_ActionOver)
end

--派生类必须重载
function InspireBase:ShowAction()
	return true
end


------------------替换-----------------------
InspireExchange = class("InspireExchange", function () return InspireBase:new() end)
InspireExchange.__index = InspireExchange

function InspireExchange:ctor()
	self.tick = 0
	self.iMax = 2
end

function InspireExchange:ShowAction()
	local elenode = g_EliminateSystem:GetRandEliminateNode()
	if elenode == nil then
	 	return self:ShowEnd()
	end

	local indexa , indexb = elenode:GetMovePoint()

	if indexa == 0 or indexb == 0 then
		return self:ShowEnd()
	end

	--获取窗口
	local wgta = self.tbWgt:getChildByTag(indexa)
	local wgtb = self.tbWgt:getChildByTag(indexb)

	if wgta == nil or wgtb == nil then
		return self:ShowEnd()
	end

	local pa = wgta:getPosition()
	local pb = wgtb:getPosition()

	local moveBya = CCMoveTo:create(0.2,pb)

	local moveByb = CCMoveTo:create(0.2,pa)

	local function CallBack()
		self.tick = self.tick + 1
		if self.tick == self.iMax then
			self:ShowEnd()
			cclog("========================InspireExchange:ShowAction()=== CallEnd()")
		end
		
	end

	local arrAct = CCArray:create()
    arrAct:addObject(moveByb)
	arrAct:addObject(CCCallFuncN:create(CallBack))
	local mActionSpa1 = CCSequence:create(arrAct)

	local arrActa = CCArray:create()
	arrActa:addObject(moveBya)
	arrActa:addObject(CCCallFuncN:create(CallBack))
	local mActionSpa2 = CCSequence:create(arrActa)

	g_playSoundEffect("Sound/ButtonClick1.mp3")

	wgta:runAction(mActionSpa2)
	wgtb:runAction(mActionSpa1)

	wgta:setTag(indexb)
	wgtb:setTag(indexa)

	return true

end


--------------------刷新-------------------------
InspireRefresh = class("InspireRefresh", function () return InspireBase:new() end)
InspireRefresh.__index = InspireRefresh

function InspireRefresh:ctor()
	self.tick = 0
end

function InspireRefresh:ShowAction()
	--有替换的 替换跟更新时不能同时出现的
	--基础消除 跟 免费消除 必定有替换
	-- if  g_EliminateSystem:GetCurSkillType() <= macro_pb.I_S_I_ONE_KEY then 
	-- 		return self:ShowEnd()
	-- end

	cclog("=============InspireRefresh:ShowAction============="..g_EliminateSystem:GetSkillChangeCount())

	local elechange = nil
	local row 	= -1
	local col 	= -1
	local color = -1
	local ntag = -1
	local fwait = 0
	local sp = 0.05
	local wgt = nil
	for i=1, g_EliminateSystem:GetSkillChangeCount() do
		elechange = g_EliminateSystem:GetSkillChangeByIndex(i)
		if elechange ~= nil then
			row, col , color = elechange:GetElementInfo()
			ntag = g_EliminateSystem:GetIndex(row, col)

			wgt = self.tbWgt:getChildByTag(ntag)
			if wgt ~= nil then
				self:RefreshAction(fwait, wgt, color)
				fwait = fwait + sp
				self.tick = self.tick  + 1
			end
		end
	end

	if g_EliminateSystem:GetSkillChangeCount() == 0 then
		self:ShowEnd()
	end
end

function InspireRefresh:RefreshAction(wtime, wgt, color)
	local action1 = CCDelayTime:create(wtime)
	local action2 = CCRotateBy:create(0.1, 360)

	local function CallBack()
		wgt:setRotation(0)
		wgt:loadTextureNormal(getXianMaiImg("Element"..color))
		wgt:loadTexturePressed(getXianMaiImg("Element"..color.."_Press"))

		local wgtMask = wgt:getChildAllByName("Image_Mask")
		wgtMask:setVisible(false)
		wgtMask:setTag(color)

		self.tick = self.tick  - 1
		if self.tick == 0 then
			self:ShowEnd()
		end
	end
	local action3 =  CCCallFuncN:create(CallBack)

	local arryAct  = CCArray:create()
	arryAct:addObject(action1)
	arryAct:addObject(action2)
	arryAct:addObject(action3)

	local squ = CCSequence:create(arryAct)
	wgt:runAction(squ)
end

------------------消除-----------------------
InspireDelete = class("InspireDelete", function () return InspireBase:new() end)
InspireDelete.__index = InspireDelete

function InspireDelete:ctor()
	self.tick = 0
end

function InspireDelete:ShowAction()
	cclog("=================InspireDelete=============="..g_EliminateSystem:GetDelElementCount())
	local index = 0
	for i=1, g_EliminateSystem:GetDelElementCount() do

		index = g_EliminateSystem:GetCurSkillDelElement(i)
		local wgt = self.tbWgt:getChildByTag(index)
		self.tick = self.tick + 1
		if wgt == nil then
			return self:ShowEnd()
		else
			local armatureSanXiaoClear,userAnimationSanXiaoClear
			local function SanXiaoClearEndCallBack()
				cclog("InspireDelete----->delete = "..wgt:getTag())
				wgt:removeFromParentAndCleanup(true)
				self.tick = self.tick - 1
				if self.tick == 0 then
					self:ShowEnd()
					-- cclog("")
				end
			end
			armatureSanXiaoClear,userAnimationSanXiaoClear = g_CreateCoCosAnimationWithCallBacks("SanXiaoClearAnimation", nil, SanXiaoClearEndCallBack, 5)
			if armatureSanXiaoClear ~= nil and  userAnimationSanXiaoClear ~= nil then

				wgt:addNode(armatureSanXiaoClear, 12)
				userAnimationSanXiaoClear:playWithIndex(0)
			end
		end
	end

	if g_EliminateSystem:GetDelElementCount() == 0 then
		self:ShowEnd()
	end
end


-------------------添加新元素---------------------
InspireAddNew = class("InspireAddNew", function () return InspireBase:new() end)
InspireAddNew.__index = InspireAddNew

function InspireAddNew:ctor()
	self.tbMoveWgt = {}

	self.tick = 0
end


function InspireAddNew:ShowAction()
	cclog("==================InspireAddNew:ShowAction=================== ")
	self.tbMoveWgt = {}
	local bgo = true
	for k, v in pairs(g_EliminateSystem:GetNewAddElement())do -- 二维
		bgo = false
		local EndRow = self:GetBegRow(k)
		cclog("===InspireAddNew:ShowAction============k"..k.." nIndex="..EndRow)
		for i, j in ipairs(v)do
			cclog("添加的新元素 列＝"..EndRow)
			if EndRow > 0 then
				self:CreateMoveWgt(j:GetColor(), EndRow, k)
			end
			EndRow = EndRow - 1
		end
	end

	if bgo then
		self:ShowEnd()
	end
end


--[[要移动的下标
{row col}最下方的 第一个加入点
]]
function InspireAddNew:CreateMoveWgt(nvaule, row , col)
	cclog("InspireAddNew:CreateMoveWgt======= row＝"..row.." col＝"..col.." nvaule="..nvaule)
	if row == 0 or  col == 0 or nvaule == 0 then
		cclog("=====InspireAddNew:CreateMoveWgt======= 添加的元素有误") 
		return self:ShowEnd()
	end

	local x, y = self.form:GetPoint()
	local w, h = self.form:GetSize()

	

	local wgt = self.tbWgt:getChildByTag(g_EliminateSystem:GetIndex(row, col))
	if wgt ~= nil then
		cclog("=====InspireAddNew:CreateMoveWgt======= 添加的目标位子不为空 错误") 
		return self:ShowEnd()
	end

	local ptx, pty = self.form:GetWgtPoint(row, col)
	local pt  =  ccp(ptx, pty)

	local wgtMoudle = self.tbWgt:getChildAllByName("Button_Element11")
	if wgtMoudle == nil then
		cclog("InspireAddNew:CreateMoveWgt Error 克隆窗口失败")
		return self:ShowEnd()
	end

	wgt = tolua.cast(wgtMoudle:clone(), "Button")

	wgt:setPosition(ccp(ptx, y))
	wgt:loadTextureNormal(getXianMaiImg("Element"..nvaule))
	wgt:loadTexturePressed(getXianMaiImg("Element"..nvaule.."_Press"))

	g_SetBtnWithPressingEvent(wgt, 0, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)

	local tag = g_EliminateSystem:GetIndex(row, col)
	wgt:setTag(tag)

	local wgtMask = wgt:getChildAllByName("Image_Mask")
	wgtMask:setVisible(false)
	wgtMask:setTag(nvaule)

	self.tbWgt:addChild(wgt)

	-- self:MovetoAction(wgt, pt)
	self:AddNewElementAction(wgt, pt)
	
end


--每一列开始的移动元素 用当前列已有元素填充空元素 并且放回能添加的第一个位子
function InspireAddNew:GetBegRow(col)
	local wgt = nil 			--本列中最下方第一个可移动的窗口 nil 表示该列全部删除

	local function getEmpty()
		for i=7, 1, -1 do
			local temp = self.tbWgt:getChildByTag(g_EliminateSystem:GetIndex(i, col) )
			if temp == nil then return i end
		end
		return 0
	end

	for i=7, 1, -1 do
		wgt = self.tbWgt:getChildByTag(g_EliminateSystem:GetIndex(i, col) )
		if wgt ~= nil and i ~= 7 then 
			local nto = getEmpty()
			if i < nto then -- 可以移动
				cclog("可以移动的点 x ,y "..i..","..col.." 移动到 "..nto..","..col)
				local ptx, pty = self.form:GetWgtPoint(nto, col)
				self:MovetoAction(wgt, ccp(ptx, pty))
				wgt:setTag(g_EliminateSystem:GetIndex(nto, col))
			end
		end
	end

	return getEmpty()
end


function InspireAddNew:MovetoAction(wgt, pb)
	local function CallBack()
		self.tick = self.tick  - 1
		if self.tick == 0 then
			self:ShowEnd()
		end
	end
	local action2 =  CCCallFuncN:create(CallBack)

	self.tick = self.tick + 1
	local moveBya = CCMoveTo:create(0.1,pb)

	local arryAct  = CCArray:create()
	arryAct:addObject(moveBya)
	arryAct:addObject(action2)

	local squ = CCSequence:create(arryAct)
	wgt:runAction(squ)

	wgt:setVisible(true)
end

function InspireAddNew:AddNewElementAction(wgt, pb)
	local function CallBack()
		self.tick = self.tick  - 1
		if self.tick == 0 then
			self:ShowEnd()
		end
	end
	local action2 =  CCCallFuncN:create(CallBack)

	self.tick = self.tick + 1
	wgt:setScale(0)

	local moveBya = CCMoveTo:create(0.1,pb)

	local Scale = CCScaleTo:create(0.1, 1)

	local sqawn =  CCSpawn:createWithTwoActions(moveBya, Scale)

	local arryAct  = CCArray:create()
	arryAct:addObject(sqawn)
	arryAct:addObject(action2)

	local squ = CCSequence:create(arryAct)
	wgt:runAction(squ)

	wgt:setVisible(true)
end
