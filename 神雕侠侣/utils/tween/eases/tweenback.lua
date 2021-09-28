TweenBack = {
	type = "Back",
	easeIn = 1,
	easeOut = 2,
	easeInOut = 3,
	easeOutIn = 4,
}

function TweenBack.easeInFun(t, b, c, d, s)
	 s = s or 1.70158
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end

function TweenBack.easeOutFun(t, b, c, d, s)
	if s == nil then s = 1.70158 end
	t = t/d -1
	return c*((t)*t*((s+1)*t + s) + 1) + b
end

function TweenBack.easeInOutFun(t, b, c, d, s)
s = (s or 1.70158) * 1.525
  t = t / d * 2
  if t < 1 then return c / 2 * (t * t * ((s + 1) * t - s)) + b end
  t = t - 2
  return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
end

function TweenBack.easeOutInFun(t, b, c, d, s)
 if t < d / 2 then return TweenBack.easeOutFun(t * 2, b, c / 2, d, s) end
  return TweenBack.easeInFun((t * 2) - d, b + c / 2, c / 2, d, s)
end

TweenBack[TweenBack.easeIn] = TweenBack.easeInFun
TweenBack[TweenBack.easeOut] = TweenBack.easeOutFun
TweenBack[TweenBack.easeInOut] = TweenBack.easeInOutFun
TweenBack[TweenBack.easeOutIn] = TweenBack.easeOutInFun