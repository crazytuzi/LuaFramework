 --------------------------------------------------------------------------------------
-- 文件名: EliminateNode.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 
-- 日  期:   
-- 版  本:    只处理 没有消除的情况
-- 描  述:    XOX XXO OXX
-- 应  用:  
---------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--[[消除列表]]
--------------------------------------------------------------------------------------------
EliminateNode = class("EliminateNode")
EliminateNode.__index = EliminateNode

function EliminateNode:ctor()
	--能产生消除的元素列表
	self.tbElement = {}

	--两端能产生消除的下标
	-- key 周围的点 index
	-- vaule 在消除列表中的 index
	self.tbActiva = {}

	--保存随机的出的两个消除下标
	self.nIndexForm = 0 --form
	self.nIndexTo = 0 --to
end


function EliminateNode:GetEliminateTable()
	return self.tbElement
end


function EliminateNode:GetElementCount()
	return #self.tbElement
end


--通过消除列表的下标获取消除列表中的元素
function EliminateNode:GetElementByIndex(nIndex)
	if nIndex == 0 or nIndex > #self.tbElement then return nil end

	return self.tbElement[nIndex]
end


function EliminateNode:SetEliminateList(tbList)
	self.tbElement = {}
	self.tbElement = tbList
end


function EliminateNode:PushElement(element)
	table.insert(self.tbElement, element)
end


function EliminateNode:GetActivaTable()
	return self.tbActiva
end

--设置周围激活的点
function EliminateNode:SetActive(key, vaule)
	self.tbActiva[key] = self.tbActiva[key] == nil and {} or self.tbActiva[key]

	self.tbActiva[key] = vaule
end


--检测附近的可消除点
function EliminateNode:FindEliminatePoint()
	self.tbActiva = {}

	-- echoj("EliminateNode:FindEliminatePoint ========beg", self.tbElement)

	for k, v in ipairs(self.tbElement) do
		self:CheckActiva(v)
	end

	--if #self.tbActiva == 0 then return false end --如果附近的激活点没空 那就说明这个消除node 没用
	for i, j in pairs(self.tbActiva)do return true end

	return false
end


--通过下标查找元素
function EliminateNode:FindElement(cpoint)

	for k, v in ipairs(self.tbElement)do
		if self:Comparison(cpoint, v:GetPonit()) then
			--cclog("cpoint.x="..cpoint.x.." cpoint.y="..cpoint.y.." v:GetPonit().x="..v:GetPonit().x.." v:GetPonit().y"..v:GetPonit().y)
			return v
		end
	end

	return nil
end


function EliminateNode:Comparison(comA, comB)
	return comA.x == comB.x and comA.y == comB.y
end


--周围四方向检测 排除自己列表中的成员
function EliminateNode:CheckActiva(element)
	local nVaule = element:GetColor()
	local pt = element:GetPonit()

	local tm = nil

	local nk 	= 0
	local nv 	= 0

	--上
	local pt_u = ccp(pt.x - 1, pt.y)
	tm = g_EliminateSystem:GetElementByIndex(pt_u.x, pt_u.y)
	if tm ~= nil and self:FindElement(pt_u) == nil and self:CheckActivaSwap(element, tm) then
		--有消除的可能
		-- cclog("pt_u x="..pt_u.x.." y="..pt_u.y.." ptx,="..pt.x.." pty,="..pt.y)
		-- table.insert(self.tbActiva, tm)
		nk = g_EliminateSystem:GetIndex(pt_u.x, pt_u.y)
		nv = g_EliminateSystem:GetIndex(pt.x, pt.y)
		self:SetActive(nk, nv)
	end

	--下
	local pt_d = ccp(pt.x + 1, pt.y)
	tm = g_EliminateSystem:GetElementByIndex(pt_d.x, pt_d.y)
	if tm ~= nil and self:FindElement(pt_d) == nil and self:CheckActivaSwap(element, tm) then
		--有消除的可能
		-- cclog("pt_d x="..pt_d.x.." y="..pt_d.y.." ptx,="..pt.x.." pty,="..pt.y)
		-- table.insert(self.tbActiva, tm)

		nk = g_EliminateSystem:GetIndex(pt_d.x, pt_d.y)
		nv = g_EliminateSystem:GetIndex(pt.x, pt.y)
		self:SetActive(nk, nv)
	end

	--左
	local pt_l = ccp(pt.x , pt.y - 1)
	tm = g_EliminateSystem:GetElementByIndex(pt_l.x, pt_l.y)
	if tm ~= nil and self:FindElement(pt_l) == nil and self:CheckActivaSwap(element, tm) then
		--有消除的可能
		-- cclog("pt_l x="..pt_l.x.." y="..pt_l.y.." ptx,="..pt.x.." pty,="..pt.y)
		-- table.insert(self.tbActiva, tm)
		nk = g_EliminateSystem:GetIndex(pt_l.x, pt_l.y)
		nv = g_EliminateSystem:GetIndex(pt.x, pt.y)
		self:SetActive(nk, nv)
	end

	--右
	local pt_r = ccp(pt.x , pt.y + 1)
	tm = g_EliminateSystem:GetElementByIndex(pt_r.x, pt_r.y)
	if tm ~= nil and self:FindElement(pt_r) == nil and self:CheckActivaSwap(element, tm) then
		--有消除的可能
		-- cclog("pt_r x="..pt_r.x.." y="..pt_r.y.." ptx,="..pt.x.." pty,="..pt.y)
		-- table.insert(self.tbActiva, tm)
		nk = g_EliminateSystem:GetIndex(pt_r.x, pt_r.y)
		nv = g_EliminateSystem:GetIndex(pt.x, pt.y)
		self:SetActive(nk, nv)
	end

end


function EliminateNode:CheckActivaSwap(Srcele, direle)
	--除Srcele以外 剩下的如果颜色都相同的。就是可以删除的
	local nVaule = direle:GetColor()
	-- cclog("EliminateNode:CheckActivaSwap ======beg======"..nVaule)
	local titk = 0
	for k, v in ipairs(self.tbElement)do
		if Srcele:GetPonit().x ~= v:GetPonit().x or Srcele:GetPonit().y ~= v:GetPonit().y  then
			if v:GetColor() == nVaule then
				-- echoj("swapA", direle:GetPonit())
				-- echoj("swapB", v:GetPonit())
				titk = titk + 1
				-- cclog(" ---------why" )
			end
		end
	end

	-- cclog("-----EliminateNode:CheckActivaSwap----="..titk)
	-- echoj("EliminateNode:CheckActivaSwap u",Srcele)
	-- echoj("EliminateNode:CheckActivaSwap d",direle)

	if titk == (#self.tbElement - 1) then
		return true
	end

	return false
end


--随机一组可以匹配的消除点
function EliminateNode:RandomEliminate()
	local tempkey = {}
	for k, v in pairs(self.tbActiva)do
		table.insert(tempkey, k)
	end

	local randbase = #tempkey
	if randbase == 0 then
	 	cclog("此消除node 没有可消除的元素")
	 	self.nIndexForm = 0
		self.nIndexTo = 0
	 	return -1234, -12345
	end

	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	local randnum = math.random(10000000)
	local x = randnum%randbase
	cclog("EliminateNode === "..randnum.." xxxxxxx="..x)
	local index =  math.max(1, randnum%randbase)
	--交换可以产生消除的两个下标
	-- cclog("可以产生的消除下标 index1="..tempkey[index].." index2="..(self.tbActiva[tempkey[index]) )
	self.nIndexForm = tempkey[index]
	self.nIndexTo = self.tbActiva[tempkey[index]]

	return tempkey[index], self.tbActiva[tempkey[index]]
end

function EliminateNode:GetMovePoint()
	return self.nIndexForm, self.nIndexTo
end

