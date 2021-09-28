--------------------------------------------------------------------------------------
-- 文件名:	Class_ShangXiang.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	
-- 描  述:	
-- 应  用:
---------------------------------------------------------------------------------------

--创建CShangXiangData类
Class_ShangXiang = class("Class_ShangXiang")
Class_ShangXiang.__index = Class_ShangXiang

function Class_ShangXiang:initData(data)
	self.accuPropValue = {0,0,0,0}
	-- self.curPropValue = {0,0,0,0,0,0,0,}
	
	for i = 1,#data.accu_prop_value do
		self.accuPropValue[i] = data.accu_prop_value[i]
	end
	
	-- for i = 1,#data.cur_prop_value do 
		-- self.curPropValue[i] = data.cur_prop_value[i]
	-- end
	
	-- self.incenseLevel = data.incense_lv
end

--已经累计的属性
function Class_ShangXiang:getAccuPropValue()
	return self.accuPropValue
end
--设置已经累计的属性
function Class_ShangXiang:setAccuPropValue(nIndex,nValue)
	self.accuPropValue[nIndex] = nValue
end

--当前属性
-- function Class_ShangXiang:getCurPropValue()
	-- return self.curPropValue
-- end

--设置当前属性
-- function Class_ShangXiang:setCurPropValue(nIndex,nValue)
	 -- self.curPropValue[nIndex] = nValue
	-- return self.curPropValue
-- end


function Class_ShangXiang:getColorCalculate(curPropValue,upperLimitValue)
	local value = curPropValue/upperLimitValue
	local colorType = 0
	if value >= 0 and value < 0.2 then 
	
		colorType = 1
		
	elseif value >= 0.2 and value < 0.4 then 
	
		colorType = 2
		
	elseif value >= 0.4  and value < 0.6 then 
	
		colorType = 3
		
	elseif value >= 0.6 and value < 0.8 then 
	
		colorType = 4
		
	elseif value >= 0.8 and value < 1  then 
	
		colorType = 5
		
	elseif value == 1 then 
	
		colorType = 6
		
	end
	return colorType
end