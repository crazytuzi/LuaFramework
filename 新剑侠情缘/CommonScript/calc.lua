-- 一些数学函数，提供给Npc、Skill等模块设定数值用

local tbCalc	= {};


--根据2个点，求线形函数f(x)=k*x+b
-- y = (y2-y1)*(x-x1)/(x2-x1)+y1
function tbCalc:Line(x,x1,y1,x2,y2)
	if (x2==x1) then
		return y2;
	end;
	return (y2-y1)*(x-x1)/(x2-x1)+y1;
end;

--根据2个点，求线形函数f(x)=k*x+b ,反求 x
function tbCalc:LineY(y, x1, y1, x2, y2)
 	if (y2 == y1) then
 		return x2
 	end
 	return (y - y1) * (x2 - x1) / (y2 - y1) + x1
end

--根据2个点，求2次形函数f(x)=a*x^2+c
-- y = (y2-y1)*(x^2-x1^2)/(x2^2-x1^2)+y1
function tbCalc:Conic(x,x1,y1,x2,y2)
	if ((x1<0) or (x2<0)) then
		return 0;
	end;
	if (x2==x1) then
		return y2;
	end;
	return (y2-y1)*(x*x-x1*x1)/(x2*x2-x1*x1)+y1;
end;

--根据2个点，求1/2次形函数f(x)=a*sqrt(x)+c
-- y = (y2-y1)*(sqrt(x)-sqrt(x1))/(sqrt(x2)-sqrt(x1)) + y1
function tbCalc:Extrac(x,x1,y1,x2,y2)
	if ((x1<0) or (x2<0)) then
		return 0;
	end;
	if (x2==x1) then
		return y2;
	end;
	return (y2-y1)*(x^0.5-x1^0.5)/(x2^0.5-x1^0.5) + y1;
end;


--描绘连接线:Link(x, tbPoint)
--根据tbPoint提供的一系列点，用相邻的两个点描绘曲线
--参数：
--	x		输入值
--	tbPoint	点集合，形如：{ {x1,y1,"Line"}, {x2,y2,"Conic"}, ..., {xn,yn} };
--返回：y 值
function tbCalc:Link(x, tbPoint, bFloat)
	if (not tbPoint) then
		return 0;
	end;
	if (type(tbPoint) == "number") then
		return tbPoint;
	end;
	local nSize = #tbPoint;
	assert(nSize >= 2);	-- 如果需要固定值，可以采用直接写数值的形式，而不要只写一个点
	local nPoint2	= nSize;
	local szFunc	= tbPoint[nSize][3];
	for i = 1, nSize do
		if (x < tbPoint[i][1]) then
			if (i == 1) then
				nPoint2	= 2;
			else
				nPoint2	= i;
			end;
			szFunc	= tbPoint[i][3];
			break;
		end;
	end;
	local tb1	= tbPoint[nPoint2-1];
	local tb2	= tbPoint[nPoint2];
	if (not szFunc) then
		szFunc	= "Line";
	end;
	local fnFunc	= self[szFunc];
	assert(fnFunc);	-- 计算方法如上定义，注意大小写
	local nResult = fnFunc(self, x, tb1[1], tb1[2], tb2[1], tb2[2])
	if not bFloat then
		return math.floor(nResult);
	end
	return nResult
end;

--描绘连接线:Link(x, tbPoint)
--根据tbPoint提供的一系列点，用相邻的两个点描绘曲线
--参数：
--	y		输入值
--	tbPoint	点集合，形如：{ {x1,y1,"Line"}, {x2,y2,"Conic"}, ..., {xn,yn} };
--返回：x 值
function tbCalc:LinkY(y, tbPoint, bFloat)
	if (not tbPoint) then
		return 0;
	end;
	if (type(tbPoint) == "number") then
		return tbPoint;
	end;
	local nSize = #tbPoint;
	assert(nSize >= 2);	-- 如果需要固定值，可以采用直接写数值的形式，而不要只写一个点
	local nPoint2	= nSize;
	local szFunc	= tbPoint[nSize][3];
	for i = 1, nSize do
		if (y < tbPoint[i][2]) then
			if (i == 1) then
				nPoint2	= 2;
			else
				nPoint2	= i;
			end;
			szFunc	= tbPoint[i][3];
			break;
		end;
	end;
	local tb1	= tbPoint[nPoint2-1];
	local tb2	= tbPoint[nPoint2];
	if (not szFunc) then
		szFunc	= "LineY";
	end;
	local fnFunc	= self[szFunc];
	assert(fnFunc);	-- 计算方法如上定义，注意大小写
	local nResult = fnFunc(self, y, tb1[1], tb1[2], tb2[1], tb2[2])
	if not bFloat then
		return math.floor(nResult);
	end
	return nResult
end;

Lib.Calc	= tbCalc;
