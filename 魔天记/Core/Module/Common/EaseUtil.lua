EaseType={};
EaseType.easeInQuad=1;
EaseType.easeOutQuad=2;
EaseType.easeInOutQuad=3;
EaseType.easeInCubic=4;
EaseType.easeOutCubic=5;
EaseType.easeInOutCubic=6;
EaseType.easeInQuart=7;
EaseType.easeOutQuart=8;
EaseType.easeInOutQuart=9;
EaseType.easeInQuint=10;
EaseType.easeOutQuint=11;
EaseType.easeInOutQuint=12;
EaseType.easeInSine=13;
EaseType.easeOutSine=14;
EaseType.easeInOutSine=15;
EaseType.easeInExpo=16;
EaseType.easeOutExpo=17;
EaseType.easeInOutExpo=18;
EaseType.easeInCirc=19;
EaseType.easeOutCirc=20;
EaseType.easeInOutCirc=21;
EaseType.linear=22;
EaseType.spring=23;
--GFX47 MOD vStart
EaseType.easeInBounce=24;
EaseType.easeOutBounce=25;
EaseType.easeInOutBounce=26;
--GFX47 MOD END
EaseType.easeInBack=27;
EaseType.easeOutBack=28;
EaseType.easeInOutBack=29;
--GFX47 MOD vStart
EaseType.easeInElastic=30;
EaseType.easeOutElastic=31;
EaseType.easeInOutElastic=32;
--GFX47 MOD END

EaseUtil={};
function EaseUtil.Punch(amplitude, value)
	local s = 9;
    if value == 0 or value == 1 then
		return 0;
	end
	local period = 1 * 0.3;
    s = period / (2 * math.pi) * math.asin(0);
    return amplitude * math.pow(2, -10 * value) * math.sin((value * 1 - s) * (2 * math.pi) / period);
end

function EaseUtil.linear(vStart, vEnd, value)
    return math.lerp(vStart, vEnd, value);
end

function EaseUtil.clerp(vStart, vEnd, value)
	local min = 0;
	local max = 360;
	local half = math.abs((max - min) * 0.5);
	local retval = 0;
	local diff = 0;
	if vEnd - vStart < -half then
		diff = ((max - vStart) + vEnd) * value;
		retval = vStart + diff;
	elseif vEnd - vStart > half then
		diff = -((max - vEnd) + vStart) * value;
		retval = vStart + diff;
	else 
		retval = vStart + (vEnd - vStart) * value;
	end            
	return retval;
end

function EaseUtil.spring(vStart, vEnd, value)
	value = math.min(math.max(value, 0), 1);
	value = (math.sin(value * math.pi * (0.2 + 2.5 * value * value * value)) * math.pow(1 - value, 2.2) + value) * (1 + (1.2 * (1 - value)));
	return vStart + (vEnd - vStart) * value;
end

function EaseUtil.easeInQuad(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	return vEnd * value * value + vStart;
end

function EaseUtil.easeOutQuad(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	return -vEnd * value * (value - 2) + vStart;
end

function EaseUtil.easeInOutQuad(vStart, vEnd, value)
	value = value / 0.5;
	vEnd = vEnd - vStart;
	if value < 1 then
		return vEnd * 0.5 * value * value + vStart;
	end
	value = value - 1;
	return -vEnd * 0.5 * (value * (value - 2) - 1) + vStart;
end

function EaseUtil.easeInCubic(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	return vEnd * value * value * value + vStart;
end

function EaseUtil.easeOutCubic(vStart, vEnd, value)
	value = value - 1;
	vEnd = vEnd - vStart;
	return vEnd * (value * value * value + 1) + vStart;
end

function EaseUtil.easeInOutCubic(vStart, vEnd, value)
	value = value / 0.5;
	vEnd = vEnd - vStart;
	if value < 1 then 
		return vEnd * 0.5 * value * value * value + vStart;
	end
	value = value - 2;
	return vEnd * 0.5 * (value * value * value + 2) + vStart;
end

function EaseUtil.easeInQuart(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	return vEnd * value * value * value * value + vStart;
end

function EaseUtil.easeOutQuart(vStart, vEnd, value)
	value = value - 1;
	vEnd = vEnd - vStart;
	return -vEnd * (value * value * value * value - 1) + vStart;
end

function EaseUtil.easeInOutQuart(vStart, vEnd, value)
	value = value / 0.5;
	vEnd = vEnd - vStart;
	if value < 1 then
		return vEnd * 0.5 * value * value * value * value + vStart;
	end 
	value = value - 2;
	return -vEnd * 0.5 * (value * value * value * value - 2) + vStart;
end

function EaseUtil.easeInQuint(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	return vEnd * value * value * value * value * value + vStart;
end

function EaseUtil.easeOutQuint(vStart, vEnd, value)
	value = value - 1;
	vEnd = vEnd - vStart;
	return vEnd * (value * value * value * value * value + 1) + vStart;
end

function EaseUtil.easeInOutQuint(vStart, vEnd, value)
	value = value / 0.5;
	vEnd = vEnd - vStart;
	if value < 1 then 
		return vEnd * 0.5 * value * value * value * value * value + vStart; 		
	end
	value = value - 2;
	return vEnd * 0.5 * (value * value * value * value * value + 2) + vStart;
end

function EaseUtil.easeInSine(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	return -vEnd * math.cos(value * (math.pi * 0.5)) + vEnd + vStart;
end

function EaseUtil.easeOutSine(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	return vEnd * math.sin(value * (math.pi * 0.5)) + vStart;
end

function EaseUtil.easeInOutSine(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	return -vEnd * 0.5 * (math.cos(math.pi * value) - 1) + vStart;
end

function EaseUtil.easeInExpo(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	return vEnd * math.pow(2, 10 * (value - 1)) + vStart;
end

function EaseUtil.easeOutExpo(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	return vEnd * (-math.pow(2, -10 * value) + 1) + vStart;
end

function EaseUtil.easeInOutExpo(vStart, vEnd, value)
	value = value / 0.5;
	vEnd = vEnd - vStart;
	if value < 1 then 
		return vEnd * 0.5 * math.pow(2, 10 * (value - 1)) + vStart;
	end
	value = value - 1;
	return vEnd * 0.5 * (-math.pow(2, -10 * value) + 2) + vStart;
end

function EaseUtil.easeInCirc(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	return -vEnd * (math.sqrt(1 - value * value) - 1) + vStart;
end

function EaseUtil.easeOutCirc(vStart, vEnd, value)
	value = value - 1;
	vEnd = vEnd - vStart;
	return vEnd * math.sqrt(1 - value * value) + vStart;
end

function EaseUtil.easeInOutCirc(vStart, vEnd, value)
	value = value / 0.5;
	vEnd = vEnd - vStart;
	if value < 1 then 
		return -vEnd * 0.5 * (math.sqrt(1 - value * value) - 1) + vStart;
	end
	value = value - 2;
	return vEnd * 0.5 * (math.sqrt(1 - value * value) + 1) + vStart;
end

--GFX47 MOD 
function EaseUtil.easeInBounce(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	local d = 1;
	return vEnd - EaseUtil.easeOutBounce(0, vEnd, d - value) + vStart;
end

-- GFX47 MOD
function EaseUtil.easeOutBounce(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	if value < 1 / 2.75 then
		return vEnd * (7.5625 * value * value) + vStart;
	elseif value < 2 / 2.75 then
		value = value - 1.5 / 2.75;
		return vEnd * (7.5625 * (value) * value + 0.75) + vStart;
	elseif value < 2.5 / 2.75 then
		value = value - 2.25 / 2.75;
		return vEnd * (7.5625 * (value) * value + 0.9375) + vStart;
	else
		value = value - 2.625 / 2.75;
		return vEnd * (7.5625 * (value) * value + .984375) + vStart;
	end
end

-- GFX47 MOD
function EaseUtil.easeInOutBounce(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	local d = 1;
	if value < d * 0.5 then
		return EaseUtil.easeInBounce(0, vEnd, value * 2) * 0.5 + vStart;
	else 
		return EaseUtil.easeOutBounce(0, vEnd, value * 2 - d) * 0.5 + vEnd * 0.5 + vStart;
	end
end

function EaseUtil.easeInBack(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	local s = 1.70158;
	return vEnd * (value) * value * ((s + 1) * value - s) + vStart;
end

function EaseUtil.easeOutBack(vStart, vEnd, value)
	local s = 1.70158;
	vEnd = vEnd - vStart;
	value = value - 1;
	return vEnd * ((value) * value * ((s + 1) * value + s) + 1) + vStart;
end

function EaseUtil.easeOutBack(vStart, vEnd, value, s)
	vEnd = vEnd - vStart;
	value = value - 1;
	return vEnd * ((value) * value * ((s + 1) * value + s) + 1) + vStart;
end

function EaseUtil.easeInOutBack(vStart, vEnd, value)
	local s = 1.70158;
	vEnd = vEnd - vStart;
	value = value / 0.5;
	if value < 1 then
		s = s * 1.525;
		return vEnd * 0.5 * (value * value * (((s) + 1) * value - s)) + vStart;
	end
	
	value = value - 2;
	s = s * 1.525;
	return vEnd * 0.5 * ((value) * value * (((s) + 1) * value + s) + 2) + vStart;
end

-- GFX47 MOD
function EaseUtil.easeInElastic(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	
	local d = 1;
	local p = d * 0.3;
	local s = 0;
	local a = 0;

	if value == 0 then return vStart; end

	value = value / d;
	if value == 1 then 
		return vStart + vEnd;
	end

	if a == 0 or a < math.abs(vEnd) then
		a = vEnd;
		s = p / 4;
	else
		s = p / (2 * math.pi) * math.asin(vEnd / a);
	end

	value = value - 1;
	return -(a * math.pow(2, 10 * value) * math.sin((value * d - s) * (2 * math.pi) / p)) + vStart;
end

-- GFX47 MOD
function EaseUtil.easeOutElastic(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	
	local d = 1;
	local p = d * 0.3;
	local s = 0;
	local a = 0;

	if value == 0 then return vStart; end

	value = value / d;
	if value == 1 then 
		return vStart + vEnd;
	end

	if a == 0 or a < math.abs(vEnd) then
		a = vEnd;
		s = p * 0.25;
	else
		s = p / (2 * math.pi) * math.asin(vEnd / a);
	end
	return (a * math.pow(2, -10 * value) * math.sin((value * d - s) * (2 * math.pi) / p) + vEnd + vStart);
end


-- GFX47 MOD
function EaseUtil.easeInOutElastic(vStart, vEnd, value)
	vEnd = vEnd - vStart;
	
	local d = 1;
	local p = d * 0.3;
	local s = 0;
	local a = 0;

	if value == 0 then return vStart; end

	value = value / d * 0.5;
	if value == 2 then 
		return vStart + vEnd;
	end
	if a == 0 or a < math.abs(vEnd) then
		a = vEnd;
		s = p / 4;
	else
		s = p / (2 * math.pi) * math.asin(vEnd / a);
	end

	value = value - 1;
	if value < 1 then 
		return -0.5 * (a * math.pow(2, 10 * value) * math.sin((value * d - s) * (2 * math.pi) / p)) + vStart;
	end
	value = value - 1;
	return a * math.pow(2, -10 * value) * math.sin((value * d - s) * (2 * math.pi) / p) * 0.5 + vEnd + vStart;
end

function EaseUtil.Curve(vStart, vEnd, value, type)
	if type == EaseType.easeInQuad then
		return EaseUtil.easeInQuad(vStart, vEnd, value);
	elseif type == EaseType.easeOutQuad then
		return EaseUtil.easeOutQuad(vStart, vEnd, value);
	elseif type == EaseType.easeInOutQuad then
		return EaseUtil.easeInOutQuad(vStart, vEnd, value);
	elseif type == EaseType.easeInCubic then
		return EaseUtil.easeInCubic(vStart, vEnd, value);
	elseif type == EaseType.easeOutCubic then
		return EaseUtil.easeOutCubic(vStart, vEnd, value);
	elseif type == EaseType.easeInOutCubic then
		return EaseUtil.easeInOutCubic(vStart, vEnd, value);
	elseif type == EaseType.easeInQuart then
		return EaseUtil.easeInQuart(vStart, vEnd, value);
	elseif type == EaseType.easeOutQuart then
		return EaseUtil.easeOutQuart(vStart, vEnd, value);
	elseif type == EaseType.easeInOutQuart then
		return EaseUtil.easeInOutQuart(vStart, vEnd, value);
	elseif type == EaseType.easeInQuint then
		return EaseUtil.easeInQuint(vStart, vEnd, value);
	elseif type == EaseType.easeOutQuint then
		return EaseUtil.easeOutQuint(vStart, vEnd, value);
	elseif type == EaseType.easeInOutQuint then
		return EaseUtil.easeInOutQuint(vStart, vEnd, value);
	elseif type == EaseType.easeInSine then
		return EaseUtil.easeInSine(vStart, vEnd, value);
	elseif type == EaseType.easeOutSine then
		return EaseUtil.easeOutSine(vStart, vEnd, value);
	elseif type == EaseType.easeInOutSine then
		return EaseUtil.easeInOutSine(vStart, vEnd, value);
	elseif type == EaseType.easeInExpo then
		return EaseUtil.easeInExpo(vStart, vEnd, value);
	elseif type == EaseType.easeOutExpo then
		return EaseUtil.easeOutExpo(vStart, vEnd, value);
	elseif type == EaseType.easeInOutExpo then
		return EaseUtil.easeInOutExpo(vStart, vEnd, value);
	elseif type == EaseType.easeInCirc then
		return EaseUtil.easeInCirc(vStart, vEnd, value);
	elseif type == EaseType.easeOutCirc then
		return EaseUtil.easeOutCirc(vStart, vEnd, value);
	elseif type == EaseType.easeInOutCirc then
		return EaseUtil.easeInOutCirc(vStart, vEnd, value);
	elseif type == EaseType.linear then
		return EaseUtil.linear(vStart, vEnd, value);
	elseif type == EaseType.spring then
		return EaseUtil.spring(vStart, vEnd, value);
	-- GFX47 MOD vStart 
	elseif type == EaseType.easeInBounce then
		return EaseUtil.easeInBounce(vStart, vEnd, value);
	elseif type == EaseType.easeOutBounce then
		return EaseUtil.easeOutBounce(vStart, vEnd, value);
	elseif type == EaseType.easeInOutBounce then
		return EaseUtil.easeInOutBounce(vStart, vEnd, value);
	-- GFX47 MOD END 
	elseif type == EaseType.easeInBack then
		return EaseUtil.easeInBack(vStart, vEnd, value);
	elseif type == EaseType.easeOutBack then
		return EaseUtil.easeOutBack(vStart, vEnd, value);
	elseif type == EaseType.easeInOutBack then
		return EaseUtil.easeInOutBack(vStart, vEnd, value);
	-- GFX47 MOD vStart 
	elseif type == EaseType.easeInElastic then
		return EaseUtil.easeInElastic(vStart, vEnd, value);
	elseif type == EaseType.easeOutElastic then
		return EaseUtil.easeOutElastic(vStart, vEnd, value);
	elseif type == EaseType.easeInOutElastic then
		return EaseUtil.easeInOutElastic(vStart, vEnd, value);
	-- GFX47 MOD END
	else
		return 0;
	end
end