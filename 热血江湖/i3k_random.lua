-------------------------------------------
module(..., package.seeall)

local require = require;

require("i3k_global");

-------------------------------------------
i3k_random = i3k_class("i3k_random")
function i3k_random:ctor(seed)
	self._args	= { m = 714025, a = 1366, b = 150889 };
	self._seed	= seed;
	self._val	= seed % self._args.m;
end 

function i3k_random:Random()
	self._val = (self._args.a * self._val + self._args.b) % self._args.m;

	return self._val;
end

function i3k_random:RangeI(min, max)
	if min > max then
		local tmp = max;
		max = min;
		min = tmp;
	end

	local diff = max - min;
	local rand = (diff + 1) * self:Random();

	local res = min + i3k_integer(rand / self._args.m);

	if res < min then
		res = min;
	end

	if res > max then
		res = max;
	end

	return res;
end

function i3k_random:RangeF(min, max)
	if min > max then
		local tmp = max;
		max = min;
		min = tmp;
	end

	local rand = self:Random() / (self._args.m - 1);
	local res = i3k_integer((min + (max - min) * rand) * 100000) / 100000;

	if res < min then
		res = min;
	end

	if res > max then
		res = max;
	end

	return res;
end

