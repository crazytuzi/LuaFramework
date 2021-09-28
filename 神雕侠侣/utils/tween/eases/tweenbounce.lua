
TweenBounce = {
	type = "Bounce",
	easeIn = 1,
	easeOut = 2,
	easeInOut = 3,
	easeOutIn = 4,
}

function TweenBounce.easeOutFun(t, b, c, d) 
	t = t/d
	if (t < (1/2.75)) then
		return c*(7.5625*t*t) + b
	elseif (t < (2/2.75)) then
		t = t-(1.5/2.75)
		return c*(7.5625*t*t + .75) + b
	elseif (t < (2.5/2.75)) then
		t = t-(2.25/2.75)
		return c*(7.5625*t*t + .9375) + b
	else
		t = t-(2.625/2.75)
		return c*(7.5625*t*t + .984375) + b
	end
end
function TweenBounce.easeInFun(t, b, c, d)
	return c - TweenBounce.easeOut(d-t, 0, c, d) + b
end
function TweenBounce.easeInOutFun(t, b, c, d)
	if (t < d*0.5) then
		return TweenBounce.easeIn(t*2, 0, c, d) * .5 + b
	else 
		return TweenBounce.easeOut(t*2-d, 0, c, d) * .5 + c*.5 + b
	end
end

function TweenBounce.easeOutInFun(t, b, c, d)
	if t < d / 2 then return TweenBounce.easeOutFun(t * 2, b, c / 2, d) end
  return TweenBounce.easeInFun((t * 2) - d, b + c / 2, c / 2, d)
end

TweenBounce[TweenBounce.easeIn] = TweenBounce.easeInFun
TweenBounce[TweenBounce.easeOut] = TweenBounce.easeOutFun
TweenBounce[TweenBounce.easeInOut] = TweenBounce.easeInOutFun
TweenBounce[TweenBounce.easeOutIn] = TweenBounce.easeOutInFun