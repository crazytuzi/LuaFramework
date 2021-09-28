Linear = {
	type = "Linear",
	easeIn = 1,
	easeOut = 2,
	easeInOut = 3,
	easeOutIn = 4,
}
function Linear.ease( t, b, c, d)
	return c*t/d + b
end

Linear[Linear.easeIn] = Linear.ease
Linear[Linear.easeOut] = Linear.ease
Linear[Linear.easeInOut] = Linear.ease
Linear[Linear.easeOutIn] = Linear.ease