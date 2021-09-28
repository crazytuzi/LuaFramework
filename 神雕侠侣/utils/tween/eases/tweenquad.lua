TweenQuad = {
	type = "Quad",
	easeIn = 1,
	easeOut = 2,
	easeInOut = 3,
	easeOutIn = 4,
}

function TweenQuad.easeInFun(t, b, c, d, s)
	return c * math.pow(t / d, 2) + b
end

function TweenQuad.easeOutFun(t, b, c, d, s)
	 t = t / d
  return -c * t * (t - 2) + b
end

function TweenQuad.easeInOutFun(t, b, c, d, s)
 t = t / d * 2
  if t < 1 then return c / 2 * math.pow(t, 2) + b end
  return -c / 2 * ((t - 1) * (t - 3) - 1) + b
end

function TweenQuad.easeOutInFun(t, b, c, d, s)
if t < d / 2 then return TweenQuad.TweenQuad(t * 2, b, c / 2, d) end
  return TweenQuad.easeInFun((t * 2) - d, b + c / 2, c / 2, d)
end

TweenQuad[TweenQuad.easeIn] = TweenQuad.easeInFun
TweenQuad[TweenQuad.easeOut] = TweenQuad.easeOutFun
TweenQuad[TweenQuad.easeInOut] = TweenQuad.easeInOutFun
TweenQuad[TweenQuad.easeOutIn] = TweenQuad.easeOutIn