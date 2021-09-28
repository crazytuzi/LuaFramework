local pow, sin, cos, pi, sqrt, abs, asin = math.pow, math.sin, math.cos, math.pi, math.sqrt, math.abs, math.asin
-- quart
local function inQuart(t, b, c, d) return c * pow(t / d, 4) + b end
local function outQuart(t, b, c, d) return -c * (pow(t / d - 1, 4) - 1) + b end
local function inOutQuart(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * pow(t, 4) + b end
  return -c / 2 * (pow(t - 2, 4) - 2) + b
end
local function outInQuart(t, b, c, d)
  if t < d / 2 then return outQuart(t * 2, b, c / 2, d) end
  return inQuart((t * 2) - d, b + c / 2, c / 2, d)
end

-- quint
local function inQuint(t, b, c, d) return c * pow(t / d, 5) + b end
local function outQuint(t, b, c, d) return c * (pow(t / d - 1, 5) + 1) + b end
local function inOutQuint(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * pow(t, 5) + b end
  return c / 2 * (pow(t - 2, 5) + 2) + b
end
local function outInQuint(t, b, c, d)
  if t < d / 2 then return outQuint(t * 2, b, c / 2, d) end
  return inQuint((t * 2) - d, b + c / 2, c / 2, d)
end

-- sine
local function inSine(t, b, c, d) return -c * cos(t / d * (pi / 2)) + c + b end
local function outSine(t, b, c, d) return c * sin(t / d * (pi / 2)) + b end
local function inOutSine(t, b, c, d) return -c / 2 * (cos(pi * t / d) - 1) + b end
local function outInSine(t, b, c, d)
  if t < d / 2 then return outSine(t * 2, b, c / 2, d) end
  return inSine((t * 2) -d, b + c / 2, c / 2, d)
end

-- expo
local function inExpo(t, b, c, d)
  if t == 0 then return b end
  return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
end
local function outExpo(t, b, c, d)
  if t == d then return b + c end
  return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
end
local function inOutExpo(t, b, c, d)
  if t == 0 then return b end
  if t == d then return b + c end
  t = t / d * 2
  if t < 1 then return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005 end
  return c / 2 * 1.0005 * (-pow(2, -10 * (t - 1)) + 2) + b
end
local function outInExpo(t, b, c, d)
  if t < d / 2 then return outExpo(t * 2, b, c / 2, d) end
  return inExpo((t * 2) - d, b + c / 2, c / 2, d)
end

-- circ
local function inCirc(t, b, c, d) return(-c * (sqrt(1 - pow(t / d, 2)) - 1) + b) end
local function outCirc(t, b, c, d)  return(c * sqrt(1 - pow(t / d - 1, 2)) + b) end
local function inOutCirc(t, b, c, d)
  t = t / d * 2
  if t < 1 then return -c / 2 * (sqrt(1 - t * t) - 1) + b end
  t = t - 2
  return c / 2 * (sqrt(1 - t * t) + 1) + b
end
local function outInCirc(t, b, c, d)
  if t < d / 2 then return outCirc(t * 2, b, c / 2, d) end
  return inCirc((t * 2) - d, b + c / 2, c / 2, d)
end

-- elastic
local function calculatePAS(p,a,c,d)
  p, a = p or d * 0.3, a or 0
  if a < abs(c) then return p, c, p / 4 end -- p, a, s
  return p, a, p / (2 * pi) * asin(c/a) -- p,a,s
end
local function inElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1  then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  t = t - 1
  return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end
local function outElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1 then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end
local function inOutElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d * 2
  if t == 2 then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  t = t - 1
  if t < 0 then return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b end
  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
end
local function outInElastic(t, b, c, d, a, p)
  if t < d / 2 then return outElastic(t * 2, b, c / 2, d, a, p) end
  return inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
end

TweenQuart = {
  type = "Quart",
  easeIn = 1,
  easeOut = 2,
  easeInOut = 3,
   easeOutIn = 4,
}
TweenQuart[TweenQuart.easeIn] = inQuart
TweenQuart[TweenQuart.easeOut] = outQuart
TweenQuart[TweenQuart.easeInOut] = inOutQuart
TweenQuart[TweenQuart.easeOutIn] = outInQuart

TweenQuint = {
  type = "Quint",
  easeIn = 1,
  easeOut = 2,
  easeInOut = 3,
   easeOutIn = 4,
}
TweenQuint[TweenQuint.easeIn] = inQuint
TweenQuint[TweenQuint.easeOut] = outQuint
TweenQuint[TweenQuint.easeInOut] = inOutQuint
TweenQuint[TweenQuint.easeOutIn] = outInQuint

TweenSine = {
  type = "Sine",
  easeIn = 1,
  easeOut = 2,
  easeInOut = 3,
   easeOutIn = 4,
}
TweenSine[TweenSine.easeIn] = inSine
TweenSine[TweenSine.easeOut] = outSine
TweenSine[TweenSine.easeInOut] = inOutSine
TweenSine[TweenSine.easeOutIn] = outInSine


TweenExpo = {
  type = "Expo",
  easeIn = 1,
  easeOut = 2,
  easeInOut = 3,
   easeOutIn = 4,
}
TweenExpo[TweenExpo.easeIn] = inExpo
TweenExpo[TweenExpo.easeOut] = outExpo
TweenExpo[TweenExpo.easeInOut] = inOutExpo
TweenExpo[TweenExpo.easeOutIn] = outInExpo

TweenCirc = {
  type = "Circ",
  easeIn = 1,
  easeOut = 2,
  easeInOut = 3,
   easeOutIn = 4,
}
TweenCirc[TweenCirc.easeIn] = inCirc
TweenCirc[TweenCirc.easeOut] = outCirc
TweenCirc[TweenCirc.easeInOut] = inOutCirc
TweenCirc[TweenCirc.easeOutIn] = outInCirc

TweenElastic = {
  type = "Elastic",
  easeIn = 1,
  easeOut = 2,
  easeInOut = 3,
   easeOutIn = 4,
}
TweenElastic[TweenElastic.easeIn] = inElastic
TweenElastic[TweenElastic.easeOut] = outElastic
TweenElastic[TweenElastic.easeInOut] = inOutElastic
TweenElastic[TweenElastic.easeOutIn] = outInElastic

