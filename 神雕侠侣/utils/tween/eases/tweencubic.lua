TweenCubic= {
	type = "Cubic",
	easeIn = 1,
	easeOut = 2,
	easeInOut = 3,
	easeOutIn = 4,
}

function TweenCubic.easeInFun(t, b, c, d)
	return c * math.pow(t / d, 3) + b
end

function TweenCubic.easeOutFun(t, b, c, d)
	return c * (math.pow(t / d - 1, 3) + 1) + b
end

function TweenCubic.easeInOutFun(t, b, c, d)
t = t / d * 2
  if t < 1 then return c / 2 * t * t * t + b end
  t = t - 2
  return c / 2 * (t * t * t + 2) + b
end

function TweenCubic.easeOutInFun(t, b, c, d)
 if t < d / 2 then return TweenCubic.easeOutFun(t * 2, b, c / 2, d) end
  return TweenCubic.easeInFun((t * 2) - d, b + c / 2, c / 2, d)
end

TweenCubic[TweenCubic.easeIn] = TweenCubic.easeInFun
TweenCubic[TweenCubic.easeOut] = TweenCubic.easeOutFun
TweenCubic[TweenCubic.easeInOut] = TweenCubic.easeInOutFun
TweenCubic[TweenCubic.easeOutIn] = TweenCubic.easeOutInFun