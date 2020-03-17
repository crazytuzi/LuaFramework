--[[
Tween缓动函数
lizhuangzhuang
2015年3月31日16:10:58
]]

_G.Ease = {};

function Ease:new(_type,_power)
	local obj = {};
	for k,v in pairs(Ease) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj._type = _type and _type or 0;
	obj._power = _power and _power or 0;
	return obj;
end

function Ease:GetRatio(p)
	local _type = self._type;
	local _power = self._power;
	local r = (_type == 1) and 1 - p or (_type == 2) and p or (p < 0.5) and p * 2 or (1 - p) * 2;
	if _power == 1 then
		r = r * r;
	elseif _power == 2 then
		r = r * r * r;
	elseif _power == 3 then
		r = r * r * r * r;
	elseif _power == 4 then
		r = r * r * r * r * r; 
	end
	return (_type == 1) and 1 - r or (_type == 2) and r or (p < 0.5) and r / 2 or 1 - (r / 2);
end


_G.Linear = {};
Linear.easeNone = Ease:new(1,0);
Linear.ease = Linear.easeNone;

_G.Cubic = {};
Cubic.easeOut = Ease:new(1,2);
Cubic.easeIn = Ease:new(2,2);
Cubic.easeInOut = Ease:new(3,2);

_G.Quad = {};
Quad.easeOut = Ease:new(1,1);
Quad.easeIn = Ease:new(2,1);
Quad.easeInOut = Ease:new(3,1);

_G.Quart = {};
Quart.easeOut = Ease:new(1,3);
Quart.easeIn = Ease:new(2,3);
Quart.easeInOut = Ease:new(3,3);



_G.BackIn = {};
function BackIn:new(overshoot)
	local obj = {};
	for k,v in pairs(BackIn) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj._p1 = (overshoot or overshoot == 0) and overshoot or 1.70158;
	return obj;
end
function BackIn:GetRatio(p)
	local _p1 = self._p1;
	return p * p * ((_p1 + 1) * p - _p1);
end

_G.BackInOut = {};
function BackInOut:new(overshoot)
	local obj = {};
	for k,v in pairs(BackInOut) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj._p1 = (overshoot or overshoot == 0) and overshoot or 1.70158;
	obj._p2 = obj._p1 * 1.525;
	return obj;
end
function BackInOut:GetRatio(p)
	local _p2 = self._p2;
	local r = 0;
	p = p * 2;
	if p < 1 then
		r = 0.5 * p * p * ((_p2 + 1) * p - _p2);
	else
		p = p - 2;
		r = 0.5 * (p * p * ((_p2 + 1) * p + _p2) + 2)
	end
	return r;
end

_G.BackOut = {};
function BackOut:new(overshoot)
	local obj = {};
	for k,v in pairs(BackOut) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj._p1 = (overshoot or overshoot == 0) and overshoot or 1.70158;
	return obj;
end
function BackOut:GetRatio(p)
	local _p1 = self._p1;
	p = p - 1;
	return (p * p * ((_p1 + 1) * p + _p1) + 1);
end

_G.Back = {};
Back.easeOut = BackOut:new();
Back.easeIn = BackIn:new();
Back.easeInOut = BackInOut:new();



_G.CircIn = {};
function CircIn:new()
	local obj = {};
	for k,v in pairs(CircIn) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	return obj;
end
function CircIn:GetRatio(p)
	return -(math.sqrt(1 - (p * p)) - 1);
end

_G.CircInOut = {};
function CircInOut:new()
	local obj = {};
	for k,v in pairs(CircInOut) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	return obj;
end
function CircInOut:GetRatio(p)
	local r = 0;
	p = p * 2;
	if p < 1 then
		r = -0.5 * (math.sqrt(1 - p * p) - 1)
	else
		p = p - 2;
		r = 0.5 * (math.sqrt(1 - p * p) + 1)
	end
	return r;
end

_G.CircOut = {};
function CircOut:new()
	local obj = {};
	for k,v in pairs(CircOut) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	return obj;
end
function CircOut:GetRatio(p)
	p = p - 1;
	return math.sqrt(1 - p * p);
end

_G.Circ = {};
Circ.easeOut = CircOut:new();
Circ.easeIn = CircIn:new();
Circ.easeInOut = CircInOut:new();



_G.ElasticIn = {};
ElasticIn._2PI = math.pi * 2;
function ElasticIn:new(amplitude,period)
	local obj = {};
	for k,v in pairs(ElasticIn) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj._p1 = amplitude or 1;
	obj._p2 = period or 0.3;
	obj._p3 = obj._p2 / self._2PI * (math.asin(1 / obj._p1) or 0); 
	return obj;
end
function ElasticIn:GetRatio(p)
	local _p1 = self._p1;
	local _p2 = self._p2;
	local _p3 = self._p3;
	local _2PI = ElasticIn._2PI;
	p = p - 1;
	return -(_p1 * math.pow(2, 10 * p) * Math.sin( (p - _p3) * _2PI / _p2 ));
end

_G.ElasticInOut = {};
ElasticInOut._2PI = math.pi * 2;
function ElasticInOut:new(amplitude,period)
	local obj = {};
	for k,v in pairs(ElasticInOut) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj._p1 = amplitude or 1;
	obj._p2 = period or 0.45;
	obj._p3 = obj._p2 / self._2PI * (math.asin(1 / obj._p1) or 0); 
	return obj;
end
function ElasticInOut:GetRatio(p)
	local _p1 = self._p1;
	local _p2 = self._p2;
	local _p3 = self._p3;
	local _2PI = ElasticInOut._2PI;
	local r = 0;
	p = p * 2;
	if p < 1 then
		p = p - 1;
		r = -0.5 * (_p1 * math.pow(2, 10 * p) * math.sin( (p - _p3) * _2PI / _p2))
	else
		p = p - 1;
		r = _p1 * math.pow(2, -10 *p)
	end
	return r;
end

_G.ElasticOut = {};
ElasticOut._2PI = math.pi * 2;
function ElasticOut:new(amplitude,period)
	local obj = {};
	for k,v in pairs(ElasticOut) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj._p1 = amplitude or 1;
	obj._p2 = period or 0.3;
	obj._p3 = obj._p2 / self._2PI * (math.asin(1 / obj._p1) or 0);
	return obj;
end
function ElasticOut:GetRatio(p)
	local _p1 = self._p1;
	local _p2 = self._p2;
	local _p3 = self._p3;
	local _2PI = ElasticOut._2PI;
	return _p1 * math.pow(2, -10 * p) * math.sin( (p - _p3) * _2PI / _p2 ) + 1;
end

_G.Elastic = {};
Elastic.easeOut = ElasticOut:new();
Elastic.easeIn = ElasticIn:new();
Elastic.easeInOut = ElasticInOut:new();