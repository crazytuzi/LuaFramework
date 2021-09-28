 --------------------------------------------------------------------------------------
-- 文件名: EliminateSkill.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 
-- 日  期:   
-- 版  本:    技能逻辑算法
-- 描  述:    
-- 应  用:  
---------------------------------------------------------------------------------------
--[[
//感悟技能索引位置
enum INSPIRATION_SKILL_IDX
{
	I_S_I_ONE_KEY	= 0;	// 一键消除
	I_S_I_BA_ZHE	= 1;	// 引爆			
	I_S_I_LIAN_SUO	= 2;	// 消除连锁
	I_S_I_DOU_ZHUAN	= 3;	// 斗转星移
	I_S_I_DIAN_DAO	= 4;	// 颠倒乾坤
}
]]

I_S_I_AUTO_Eliminate_Logic = -99 --外部逻辑用 SetCurSkill
I_S_I_AUTO_Eliminate = -100

EliminateSkill = class("EliminateSkill")
EliminateSkill.__index = EliminateSkill

Enum_GanWuSkillName = {
	[1] = _T("免费消除"),
	[2] = _T("霸者横栏"),
	[3] = _T("清除连锁"),
	[4] = _T("斗转星移"),
	[5] = _T("颠倒乾坤"),
}
function EliminateSkill:ctor()
	self.nSkillTag = -1 --当前界面中技能的下标 

	self.tbSkillList = {}

	self.SkillBase = EliminateSkillBase.new()
end


function EliminateSkill:InitBaseInfo(tbskill)

	self.tbSkillList = {}
	for k,v in ipairs(tbskill)do
		table.insert(self.tbSkillList, v)
	end

	-- self.tbSkillList = {true, true, true, true, true}
end


function EliminateSkill:Reset()
	self.nSkillTag = -1
	-- self.tbSkillList = {}
	self.SkillBase = EliminateSkillBase.new()
end


function EliminateSkill:SetCurSkill(nSkillIndex)
	--服务器的下标从0开始 客户端的table 从1开始
	self.nSkillTag = nSkillIndex - 1

	self:UpdateCurSkill()
end


function EliminateSkill:GetCurSkill()
	--界面中的下标是从1开始
	return self.nSkillTag + 1
end


function EliminateSkill:GetSkillListCount()
	return #self.tbSkillList
end


function EliminateSkill:GetSkillEnableByIndex(nIndex)
	return self.tbSkillList[nIndex]
end

function EliminateSkill:SetCurActiveSkill(skillnIndex, vaule)
	if not skillnIndex then return false end
	--服务器从0开始
	if skillnIndex < 0 or skillnIndex + 1 > #self.tbSkillList then return false end

	self.tbSkillList[skillnIndex + 1] = vaule

	return true
end


function EliminateSkill:UpdateCurSkill()
	if self.nSkillTag == macro_pb.I_S_I_ONE_KEY then
		self.SkillBase = EliminateSkillFree.new()

		cclog("EliminateSkill:UpdateCurSkill 111111111")
	elseif self.nSkillTag == macro_pb.I_S_I_BA_ZHE then
		self.SkillBase = EliminateSkillDetonated.new()
		cclog("EliminateSkill:UpdateCurSkill 222222222")

	elseif self.nSkillTag == macro_pb.I_S_I_LIAN_SUO then
		self.SkillBase = EliminateSkillChain.new()
		cclog("EliminateSkill:UpdateCurSkill 3333333333")

	elseif self.nSkillTag == macro_pb.I_S_I_DOU_ZHUAN then
		self.SkillBase = EliminateSkillDZXY.new()
		cclog("EliminateSkill:UpdateCurSkill 44444444444")

	elseif self.nSkillTag == macro_pb.I_S_I_DIAN_DAO then
		self.SkillBase = EliminateSkillDDQK.new()
		cclog("EliminateSkill:UpdateCurSkill 5555555555")

	elseif self.nSkillTag == I_S_I_AUTO_Eliminate then
		self.SkillBase = EliminateSkillAuto.new()
		cclog("EliminateSkill:UpdateCurSkill 666666")
	end
end


function EliminateSkill:GetCurSkillType()

	if self.SkillBase ~= nil then
		return self.SkillBase:GetSkillType()
	end

	return nil
end


function EliminateSkill:GetEliminateList(EliminateNode)

	if self.SkillBase ~= nil then
		return self.SkillBase:GetEliminateList(EliminateNode)
	end

	return nil
end


function EliminateSkill:GetCloneElement(row, col)
	return self.SkillBase:GetElementByIndex(row, col)
end

--技能改变的变量
function EliminateSkill:ChangedElementCount()
	return self.SkillBase:ChangedElementCount()
end

function EliminateSkill:ChangedElement(nIndex)
	return self.SkillBase:ChangedElement(nIndex)
end

function EliminateSkill:GetType()
	return self.SkillBase:GetSkillType()
end

function EliminateSkill:GetNeedTongQian()
	return  self.SkillBase:GetNeedTongQian()
end


function EliminateSkill:GetNeedYuanBao()
	return  self.SkillBase:GetNeedYuanBao()
end

--------------------------------------------------------------------------------------------
--[[感悟技能计算]]
--------------------------------------------------------------------------------------------
EliminateSkillBase = class("EliminateSkillBase")
EliminateSkillBase.__index = EliminateSkillBase

function EliminateSkillBase:ctor()
	--换算用 克隆system中的所有元素
	self.tbclone = {}

	--在使用技能的时候产生的改变
	self.tbChangeElement = {}
end


function EliminateSkillBase:GetSkillType()
	return -1
end


function EliminateSkillBase:CloneElement()
	self.tbclone  = {}
	self.tbChangeElement = {} 

	for i, l in ipairs(g_EliminateSystem:CloneElement()) do

		self.tbclone[i] = {}
		for j, v in ipairs(l)do

			local element = EliminateElement.new()
			element:SetElement(i, j, v:GetColor())

			self.tbclone[i][j] = element
		end
	end
end

function EliminateSkillBase:GetNeedTongQian()
	return g_VIPBase:getVipValue("InspireGold")
end


function EliminateSkillBase:GetNeedYuanBao()
	return g_VIPBase:getVipValue("InspireCoupon")
end


function EliminateSkillBase:GetElementByIndex(row, col)
	-- cclog("EliminateSkillBase:GetElementByIndex "..row.." "..col)
	-- echoj("======EliminateSkillBase:GetElementByIndex========", self.tbclone)
	if self.tbclone[row] == nil then return nil end

	

	return self.tbclone[row][col]
end


function EliminateSkillBase:GetElement(nindex)
	local row, col = g_EliminateSystem:GetRowAndRan(nindex)

	return self:GetElementByIndex(row, col)
end

function EliminateSkillBase:SwapElement(nIndexA, nIndexB)
	local rowA, colA = g_EliminateSystem:GetRowAndRan(nIndexA)
	local rowB, colB = g_EliminateSystem:GetRowAndRan(nIndexB)

	local temp = self.tbclone[rowA][colA]

	self.tbclone[rowA][colA] = self.tbclone[rowB][colB]
	local change = ChangeElement.new()
	change:Init(rowA, colA, self.tbclone[rowB][colB]:GetColor())
	table.insert(self.tbChangeElement, change)

	self.tbclone[rowB][colB] = temp
	change = ChangeElement.new()
	change:Init(rowB, colB, temp:GetColor())
	table.insert(self.tbChangeElement, change)
end


--消除后的列表
function EliminateSkillBase:GetEliminateList(EliminateNode)
	--手动替换两个值 替换后计算产生的消除列表 下标
	self:CloneElement()
	local nt, nf = EliminateNode:GetMovePoint()
	self:SwapElement(nt, nf)

	cclog("EliminateSkillBase:GetEliminateList nt="..nt.." nf="..nf)

	local frow, fcol = g_EliminateSystem:GetRowAndRan(nf)
	local fele = self:GetElementByIndex(frow, fcol)
	cclog("EliminateSkillBase:GetEliminateList frow="..frow.." fcol="..fcol)


	local trow, tcol = g_EliminateSystem:GetRowAndRan(nt)
	local tele = self:GetElementByIndex(trow, tcol)


	local F_tbReturn_V_1 = {}
	local F_tbReturn_V_2 = {}
	local F_tbReturn_H_1 = {}
	local F_tbReturn_H_2 = {}

--垂直
	self:GetLoad_U(frow , fcol, fele:GetColor(), F_tbReturn_V_1)
	-- echoj("F_tbReturn_V_1", F_tbReturn_V_1)
	self:GetLoad_D(frow, fcol, fele:GetColor(), F_tbReturn_V_2)
	-- echoj("F_tbReturn_V_2", F_tbReturn_V_2)
	local F_tbReturn_V = self:MergeTable(F_tbReturn_V_1, F_tbReturn_V_2)
	-- echoj("F_tbReturn_V", F_tbReturn_V)
--水平
	self:GetLoad_L(frow, fcol, fele:GetColor(), F_tbReturn_H_1)
	-- echoj("F_tbReturn_H_1", F_tbReturn_H_1)
	self:GetLoad_R(frow, fcol, fele:GetColor(), F_tbReturn_H_2)
	-- echoj("F_tbReturn_H_2", F_tbReturn_H_2)
	local F_tbReturn_H = self:MergeTable(F_tbReturn_H_1, F_tbReturn_H_2)
	-- echoj("F_tbReturn_H", F_tbReturn_H)




-- 第二个选中点
	local T_tbReturn_V_1 = {}
	local T_tbReturn_V_2 = {}
	local T_tbReturn_H_1 = {}
	local T_tbReturn_H_2 = {}

--垂直
	self:GetLoad_U(trow, tcol, tele:GetColor(), T_tbReturn_V_1)
	self:GetLoad_D(trow, tcol, tele:GetColor(), T_tbReturn_V_2)
	local T_tbReturn_V = self:MergeTable(T_tbReturn_V_1, T_tbReturn_V_2)

--水平
	self:GetLoad_L(trow, tcol, tele:GetColor(), T_tbReturn_H_1)
	self:GetLoad_R(trow, tcol, tele:GetColor(), T_tbReturn_H_2)
	local T_tbReturn_H = self:MergeTable(T_tbReturn_H_1, T_tbReturn_H_2)

--长度小于 3 的都不计算
	local F_tbReturn = {}
	if #F_tbReturn_V > 2 and #F_tbReturn_H > 2 then
		F_tbReturn = self:MergeTable(F_tbReturn_V, F_tbReturn_H)
	elseif #F_tbReturn_V > 2 then
		F_tbReturn = F_tbReturn_V
	elseif #F_tbReturn_H > 2 then
		F_tbReturn = F_tbReturn_H
	end

	local T_tbReturn = {}
	if #T_tbReturn_V > 2 and #T_tbReturn_H > 2 then
		T_tbReturn = self:MergeTable(T_tbReturn_V, T_tbReturn_H)
	elseif #T_tbReturn_V > 2 then
		T_tbReturn = T_tbReturn_V
	elseif #T_tbReturn_H > 2 then
		T_tbReturn = T_tbReturn_H
	end

	-- echoj("F_tbReturn", F_tbReturn)
	-- echoj("T_tbReturn", T_tbReturn)

--计算最终结果
	local TbReturn = self:MergeTable(F_tbReturn, T_tbReturn)
	-- echoj("感悟结算结果 ",self.tbclone)
	return TbReturn
end


function EliminateSkillBase:GetLoad_U(row, col, nvalue, tbReturn)
-- cclog("row, col, nvalue, tbReturn "..row.." "..col.." "..nvalue.." "..#tbReturn)
	local ele = self:GetElementByIndex(row, col)
	if ele ~= nil and ele:GetColor() == nvalue then
		-- cclog("insert row, col, nvalue, tbReturn "..row.." "..col.." "..nvalue.." "..#tbReturn)
		 table.insert(tbReturn, g_EliminateSystem:GetIndex(row, col))
	else
		return
	end

	self:GetLoad_U(row-1, col, nvalue, tbReturn)
	
end


function EliminateSkillBase:GetLoad_D(row, col, nvalue, tbReturn)

	local ele = self:GetElementByIndex(row, col)
	if ele ~=nil and ele:GetColor() == nvalue then
		 table.insert(tbReturn, g_EliminateSystem:GetIndex(row, col))
	else
		return
	end

	self:GetLoad_D(row+1, col, nvalue, tbReturn)
	
end


function EliminateSkillBase:GetLoad_L(row, col, nvalue, tbReturn)

	local ele = self:GetElementByIndex(row, col)
	if ele ~=nil and ele:GetColor() == nvalue then
		 table.insert(tbReturn, g_EliminateSystem:GetIndex(row, col))
	else
		return
	end

	self:GetLoad_L(row, col-1, nvalue, tbReturn)
	
end


function EliminateSkillBase:GetLoad_R(row, col, nvalue, tbReturn)

	local ele = self:GetElementByIndex(row, col)
	if ele ~=nil and ele:GetColor() == nvalue then
		 table.insert(tbReturn, g_EliminateSystem:GetIndex(row, col))
	else
		return
	end

	self:GetLoad_R(row, col+1, nvalue, tbReturn)
	
end


function EliminateSkillBase:MergeTable(tabL, tabR)
	local tmp = {}
	local restab = {}

	for k, v in ipairs(tabL)do
		tmp[v] = v
	end

	for i, j in ipairs(tabR)do
		tmp[j] = j
	end

	for k, v in pairs(tmp)do
		table.insert(restab, k)
	end

	local function sortfunc(a, b)
		return a < b
	end

	table.sort( restab, sortfunc )

	-- echoj("--EliminateSkillBase:MergeTable ", restab )

	return restab
end


function EliminateSkillBase:ChangedElementCount()
	return #self.tbChangeElement
end


function EliminateSkillBase:ChangedElement(nIndex)
	return self.tbChangeElement[nIndex]
end

--2选1
function EliminateSkillBase:GetRandomIndex(indexa, indexb)
	
	math.randomseed(os.time())
	local randnum = math.random(100000)
	local random = randnum%2
	if random == 0 then
		return indexa
	end

	return indexb
end

--------------------------------------------------------------------------------------------
--[[自动消除 在服务器下发元素数据的时候产生消除]]
--------------------------------------------------------------------------------------------
EliminateSkillAuto = class("EliminateSkillAuto",  function () return EliminateSkillBase:new() end)
EliminateSkillAuto.__index = EliminateSkillAuto

function EliminateSkillAuto:ctor()
end


function EliminateSkillAuto:GetSkillType()
	return I_S_I_AUTO_Eliminate
end

function EliminateSkillAuto:GetEliminateList(EliminateNode)
	cclog("=============EliminateSkillAuto:GetEliminateList============")
	return nil
end


function EliminateSkillAuto:ChangedElementCount()
	return nil
end


function EliminateSkillAuto:ChangedElement(nIndex)
	return nil
end


function EliminateSkillAuto:GetElementByIndex(row, col)
	return nil
end


function EliminateSkillAuto:GetNeedTongQian()
	return 0
end


function EliminateSkillAuto:GetNeedYuanBao()
	return 0
end

--------------------------------------------------------------------------------------------
--[[免费消除技能 一般的换位消除 只不过是免费的]]
--------------------------------------------------------------------------------------------
EliminateSkillFree = class("EliminateSkillFree",  function () return EliminateSkillBase:new() end)
EliminateSkillFree.__index = EliminateSkillFree

function EliminateSkillFree:GetSkillType()
	return macro_pb.I_S_I_ONE_KEY
end


function EliminateSkillFree:GetEliminateList(EliminateNode)
	cclog("=============EliminateSkillFree:GetEliminateList============")
	return EliminateSkillBase:GetEliminateList(EliminateNode)
end


function EliminateSkillFree:ChangedElementCount()
	return EliminateSkillBase:ChangedElementCount()
end


function EliminateSkillFree:ChangedElement(nIndex)
	return EliminateSkillBase:ChangedElement(nIndex)
end


function EliminateSkillFree:GetElementByIndex(row, col)
	return EliminateSkillBase:GetElementByIndex(row, col)
end

function EliminateSkillFree:GetNeedTongQian()
	return 0
end


function EliminateSkillFree:GetNeedYuanBao()
	return 0
end


--------------------------------------------------------------------------------------------
--[[引爆技能 十字架 把相同的行 列 都删除]]
--------------------------------------------------------------------------------------------
EliminateSkillDetonated = class("EliminateSkillDetonated", function () return EliminateSkillBase:new() end)

EliminateSkillDetonated.__index = EliminateSkillDetonated

function EliminateSkillDetonated:GetSkillType()
	return macro_pb.I_S_I_BA_ZHE
end

function EliminateSkillDetonated:GetEliminateList(EliminateNode)
	--手动替换两个值 替换后计算产生的消除列表 下标
	local tbReturn = {}
	EliminateSkillBase:CloneElement()
	local nt, nf = EliminateNode:GetMovePoint()
	cclog("感悟引爆技能 nt="..nt.." nf="..nf)

	local rowa, cola = g_EliminateSystem:GetRowAndRan(nt)
	local rowb, colb = g_EliminateSystem:GetRowAndRan(nf)

	if rowa == rowb then rowb = -1 end
	if cola == colb then colb = -1 end

	cclog("感悟引爆 rowa="..rowa.." rowb="..rowb.." cola="..cola.." colb="..colb)

	--不添加重复的元素到删除列表
	local function InsertTabel(nIndex)
		local brest = true
		for k, v in ipairs(tbReturn)do
			if v == nIndex then
				brest = false
			end
		end
		if brest then
			table.insert(tbReturn, nIndex)
		end
	end

	for row=1, 7 do
		if row == rowa or row == rowb then
			for col=1, 7 do
				InsertTabel(g_EliminateSystem:GetIndex(row, col))
			end

		else
			for col=1, 7 do
				if col == cola or col == colb then
					InsertTabel(g_EliminateSystem:GetIndex(row, col))
				end
			end
		end
	end

	return tbReturn
end


function EliminateSkillDetonated:ChangedElementCount()
	return EliminateSkillBase:ChangedElementCount()
end


function EliminateSkillDetonated:ChangedElement(nIndex)
	return EliminateSkillBase:ChangedElement(nIndex)
end


function EliminateSkillDetonated:GetElementByIndex(row, col)
	return EliminateSkillBase:GetElementByIndex(row, col)
end

--------------------------------------------------------------------------------------------
--[[消除连锁技能 清除当前选定两种元素对应的所有花色]]
--------------------------------------------------------------------------------------------
EliminateSkillChain = class("EliminateSkillChain", function () return EliminateSkillBase:new() end)

EliminateSkillChain.__index = EliminateSkillChain


function EliminateSkillChain:GetSkillType()
	return macro_pb.I_S_I_LIAN_SUO
end


function EliminateSkillChain:GetEliminateList(EliminateNode)
	--手动替换两个值 替换后计算产生的消除列表 下标
	local tbReturn = {}
	local element = nil
	EliminateSkillBase:CloneElement()
	local nt, nf = EliminateNode:GetMovePoint()
	cclog("感悟引爆技能 nt="..nt.." nf="..nf)

	local colora = -1 
	local colarb = -1

	element = self:GetElement(nt)
	if element ~= nil then
		colora = element:GetColor()
	end

	element = self:GetElement(nf)
	if element ~= nil then
		colorb = element:GetColor()
	end

	for row=1, 7 do
		for col=1, 7 do
			element = self:GetElementByIndex(row, col)
			if element ~= nil then
				if element:GetColor() == colora or element:GetColor() == colorb then
					table.insert(tbReturn, g_EliminateSystem:GetIndex(row, col))
				end
			end
		end
	end

	return tbReturn
end


function EliminateSkillChain:ChangedElementCount()
	return EliminateSkillBase:ChangedElementCount()
end


function EliminateSkillChain:ChangedElement(nIndex)
	return EliminateSkillBase:ChangedElement(nIndex)
end


function EliminateSkillChain:GetElementByIndex(row, col)
	return EliminateSkillBase:GetElementByIndex(row, col)
end


--------------------------------------------------------------------------------------------
--[[斗转星移技能 清除当前选定两种元素对应的所有花色]]
--------------------------------------------------------------------------------------------
EliminateSkillDZXY= class("EliminateSkillDZXY", function () return EliminateSkillBase:new() end)

EliminateSkillDZXY.__index = EliminateSkillDZXY

function EliminateSkillDZXY:GetSkillType()
	return macro_pb.I_S_I_DOU_ZHUAN
end


function EliminateSkillDZXY:GetEliminateList(EliminateNode)
	--手动替换两个值 替换后计算产生的消除列表 下标
	local tbReturn = {}
	local element = nil
	EliminateSkillBase:CloneElement()

	local nt, nf = EliminateNode:GetMovePoint()
	cclog("斗转星移技能 nt="..nt.." nf="..nf)

	local index = self:GetRandomIndex(nt, nf)
	local tocolor  = -1 
	element = self:GetElement(index)
	if element ~= nil then
		tocolor = element:GetColor()
	end

	local formcolor = -1
	if index == nt then
		element = self:GetElement(nf)
		if element ~= nil then
			formcolor =  element:GetColor()
		end
	end

	if index == nf then
		element = self:GetElement(nt)
		if element ~= nil then
			formcolor =  element:GetColor()
		end
	end

	self:CreateChange(formcolor, tocolor)

	return tbReturn
end


--把列表中 formcolor 变成 tocolor
function EliminateSkillDZXY:CreateChange(formcolor, tocolor)
	local element = nil
	for row=1, 7 do
		for col=1, 7 do
			element = self:GetElementByIndex(row, col)
			if element ~= nil then
				if element:GetColor() == formcolor then

					local change = ChangeElement.new()
					change:Init(row, col, tocolor)
					table.insert(self.tbChangeElement, change)

				end
			end
		end
	end
end



function EliminateSkillDZXY:ChangedElementCount()
	return #self.tbChangeElement
end


function EliminateSkillDZXY:ChangedElement(nIndex)
	return self.tbChangeElement[nIndex]
end


function EliminateSkillDZXY:GetElementByIndex(row, col)
	return EliminateSkillBase:GetElementByIndex(row, col)
end


--------------------------------------------------------------------------------------------
--[[颠倒乾坤 将屏幕内的元素变为两两相间的花色, 花色为之前选定的两种颜色]]
--------------------------------------------------------------------------------------------
EliminateSkillDDQK= class("EliminateSkillDDQK", function () return EliminateSkillBase:new() end)

EliminateSkillDDQK.__index = EliminateSkillDDQK

function EliminateSkillDDQK:GetSkillType()
	return macro_pb.I_S_I_DIAN_DAO
end


function EliminateSkillDDQK:GetEliminateList(EliminateNode)
	--手动替换两个值 替换后计算产生的消除列表 下标
	local tbReturn = {}
	local element = nil
	EliminateSkillBase:CloneElement()

	local nt, nf = EliminateNode:GetMovePoint()
	cclog("颠倒乾坤 nt="..nt.." nf="..nf)

	local colora = -1
	element = self:GetElement(nt)
	if element ~= nil then
		colora =  element:GetColor()
	end

	local colorb = -1
	element = self:GetElement(nf)
	if element ~= nil then
		colorb =  element:GetColor()
	end

	self:CreateChange(colora, colorb)

	return tbReturn
end


function EliminateSkillDDQK:CreateChange(colora, colorb)
	cclog("颠倒乾坤 colora, colorb"..colora.." "..colorb)
	local element = nil
	for row=1, 7 do
		for col=1, 7 do
			element = self:GetElementByIndex(row, col)
			echoj("颠倒乾坤", element)
			if element ~= nil then
				if g_EliminateSystem:GetIndex(row, col)%2 == 0 then

					local change = ChangeElement.new()
					change:Init(row, col, colorb)
					table.insert(self.tbChangeElement, change)

				else

					local change = ChangeElement.new()
					change:Init(row, col, colora)
					table.insert(self.tbChangeElement, change)

				end
			end
		end
	end
end


function EliminateSkillDDQK:ChangedElementCount()
	return #self.tbChangeElement
end


function EliminateSkillDDQK:ChangedElement(nIndex)
	return self.tbChangeElement[nIndex]
end


function EliminateSkillDDQK:GetElementByIndex(row, col)
	return EliminateSkillBase:GetElementByIndex(row, col)
end
