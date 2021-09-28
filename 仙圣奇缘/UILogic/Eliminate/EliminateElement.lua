 --------------------------------------------------------------------------------------
-- 文件名: EliminateElement.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 
-- 日  期:   
-- 版  本:    
-- 描  述:    
-- 应  用:  
---------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--[[消除的所有元素]]
--------------------------------------------------------------------------------------------
EliminateElement = class("EliminateElement")
EliminateElement.__index = EliminateElement


function EliminateElement:ctor()
	--下标 ccp()
	self.cPoint = {}

	--消除的颜色值
	self.nColor = -1 --
end


function EliminateElement:SetElement(row, ran, color)
	self.cPoint.x = row
	self.cPoint.y = ran
	self.nColor = color
end


function EliminateElement:GetPonit()
	return {x = self.cPoint.x, y = self.cPoint.y}
end


function EliminateElement:GetColor()
	return self.nColor
end


function EliminateElement:SetColor(nColor)
	self.nColor = nColor
end



function EliminateElement:GetIndex()
	return g_EliminateSystem:GetIndex(self.cPoint.x, self.cPoint.y)
end


--------------------------------------------------------------------------------------------
--[[消除使用技能改变的结构]]
--------------------------------------------------------------------------------------------

ChangeElement = class("ChangeElement")
ChangeElement.__index = ChangeElement


function ChangeElement:ctor()
	self.row 	= 1	-- 元素的行
	self.col 	= 2	-- 元素的列
	self.data	= 3	-- 当前位置上元素的值
end


function ChangeElement:Init(row, col, ndata)
	self.row 	= row	
	self.col 	= col	
	self.data	= ndata	
end


function ChangeElement:GetElementInfo()
	return self.row, self.col ,self.data
end


--------------------------------------------------------------------------------------------
--[[新添加的元素 只往下添加]]
--------------------------------------------------------------------------------------------
NewAddElement = class("NewAddElement")
NewAddElement.__index = NewAddElement

function NewAddElement:ctor()
	self.col = 0
	self.nColor = 0
end


function NewAddElement:Init(col , nColor)
	self.col = col
	self.nColor = nColor
end


function NewAddElement:GetCol()
	return self.col
end


function NewAddElement:GetColor()
	return self.nColor
end

--------------------------------------------------------------------------------------------
--[[感悟属性]]
--------------------------------------------------------------------------------------------
InspireAttribute = class("InspireAttribute")
InspireAttribute.__index = InspireAttribute

function InspireAttribute:ctor()
	self.use_skill_idx = nil 	--空值状态 表示 不用技能。
	self.is_coupons = false 	--true表示用元宝
	self.mult_num = 0 			--暴击倍数
	self.inc_incense = 0 		--收获香贡
	self.create_skill_idx = 0 	--产生技能  空值状态表示没技能
	self.update_cost = 0 		--元宝或者铜钱更新
	self.updated_incense = 0 	-- 香火更新
end


function InspireAttribute:UpdataAttribute(tbMsg)
	self.use_skill_idx 		= tbMsg.use_skill_idx
	self.is_coupons			= tbMsg.is_coupons
	self.mult_num 			= tbMsg.mult_num
	self.inc_incense 		= tbMsg.inc_incense
	self.create_skill_idx 	= tbMsg.create_skill_idx
	self.update_cost 		= tbMsg.update_cost
	self.updated_incense 	= tbMsg.updated_incense

	if tbMsg.is_coupons then
		g_Hero:setYuanBao(tbMsg.update_cost)
	else
		g_Hero:setCoins(tbMsg.update_cost)
	end

	g_Hero:setIncense(tbMsg.updated_incense)
end


--是否使用技能
function InspireAttribute:isUseSkill()
	return self.use_skill_idx ~= nil 
end


function InspireAttribute:isCoupons()
	return self.is_coupons
end


function InspireAttribute:GetMultNum()
	return self.mult_num
end


function InspireAttribute:GetInc_incense()
	return self.inc_incense
end


function InspireAttribute:create_skill_idx()
	return self.create_skill_idx
end


function InspireAttribute:update_cost()
	return self.update_cost
end


function InspireAttribute:updated_incense()
	return self.updated_incense
end