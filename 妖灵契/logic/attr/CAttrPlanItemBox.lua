local CAttrPlanItemBox = class("CAttrPlanItemBox", CBox)

function CAttrPlanItemBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_NowPointLabel = self:NewUI(1, CLabel)
	self.m_AddPointLabel = self:NewUI(2, CLabel)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_Index = 0
	self.m_NowPoint = 0
	self.m_AddPoint = 0
	self.m_PlayerPlaneItemName = {"生命", "法力", "物攻", "法攻", "物防", "法防", "速度"}
	self.m_IndexList = {hp = 1, mp = 2, phy_attack = 3, mag_attack = 4, phy_defense = 5, mag_defense = 6, speed = 7}
	self.m_CData = data.rolepointdata.INIT
end

function CAttrPlanItemBox.SetInfo(self, text)
	-- self.m_Index = self.m_IndexList[datalist[1]]
	-- -- if self.m_Index == 2 then
	-- -- 	printc("==========SetInfo=========")
	-- -- 	table.print(datalist)
	-- -- end
	-- self.m_NowPoint = datalist[2]
	-- self.m_AddPoint = datalist[3] or 0
	
	-- self.m_NameLabel:SetText(self.m_PlayerPlaneItemName[self.m_Index])
	-- local iNum = 0 			--特殊处理时的数据问题,例如人物初始化时的生命值和物攻值,法力值获取
	-- if self.m_Index == 1 then
	-- 	iNum = g_AttrCtrl.max_hp or 0
	-- elseif self.m_Index == 2 then
	-- 	iNum = g_AttrCtrl.max_mp or 0
	-- --printc("=======mp========",g_AttrCtrl.max_mp.."NOW:"..self.m_NowPoint)
	-- elseif self.m_Index == 3 then
	-- 	iNum = self.m_CData[1].phy_attack or 0
	-- end
	
	-- -- if self.m_Index == 2 then
	-- -- 	-- printc("=+++++++++++",iNum)
	-- -- 	self.m_NowPointLabel:SetText(self:MathRound(iNum))
	-- -- else
	self.m_NowPointLabel:SetText(text)
	--end	
	self:RefreshAddLabel(self.m_AddPoint)
end

function CAttrPlanItemBox.RefreshAddLabel(self, addpoint)
	addpoint = tonumber(string.format("%.1f",addpoint))
	if addpoint >= 1.0 then
		self.m_AddPointLabel:SetText("+"..math.floor(addpoint))
		self.m_AddPointLabel:SetActive(true)
	else
		self.m_AddPointLabel:SetActive(false)
	end
end

--切换方案时清空数据缓存
function CAttrPlanItemBox.DelateData(self)
	self.m_Index = 0
	self.m_AddPoint = 0
	self.m_NowPoint = 0
end

function CAttrPlanItemBox.MathRound(self, data)	
	local num,modf = math.modf(data)
	num = (modf >= 0.99 and math.ceil(num)) or math.floor(num)
	-- local num = data * 100
	-- num = (num % 1 >= 0.5 and math.ceil(num/100)) or math.floor(num/100)
	return num 
end

return CAttrPlanItemBox