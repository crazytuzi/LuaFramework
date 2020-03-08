local MathHelper = {}
function MathHelper.Floor(fValue, p)
  local precision = p or 1.0E-5
  local result
  if precision > math.ceil(fValue) - fValue then
    result = math.ceil(fValue)
  else
    result = math.floor(fValue)
  end
  return result
end
function MathHelper.Ceil(fValue, p)
  local precision = p or 1.0E-5
  local result
  if precision > fValue - math.floor(fValue) then
    result = math.floor(fValue)
  else
    result = math.ceil(fValue)
  end
  return result
end
function MathHelper.Round(fValue, p)
  return MathHelper.Floor(fValue + 0.5, p)
end
function MathHelper.Between(left, right, middle)
  return left <= middle and middle <= right
end
function MathHelper.Plier(down, up, val)
  if up < down then
    error("param[up] must larger than param[down]")
  end
  if val < down then
    return down
  elseif up < val then
    return up
  else
    return val
  end
end
function MathHelper.ShuffleTable(tab, from, to)
  local start = from ~= nil and from or 1
  local finish = to ~= nil and to <= #tab - 1 and to or #tab
  for i = start, finish - 1 do
    local x = math.random(i, finish)
    local temp = tab[x]
    tab[x] = tab[i]
    tab[i] = temp
  end
end
function MathHelper.ShuffleTableBySequence(tab, seq)
  if #tab ~= #seq then
    error("MathHelper.ShuffleTableBySequence bad params " .. #tab .. "~=" .. #seq)
    return
  end
  for k, v in ipairs(seq) do
    if tab[v] == nil then
      error("MathHelper.ShuffleTableBySequence bad content in sequence " .. k .. ":" .. v .. " not in table")
      return
    end
  end
  local tempTbl = {}
  for k, v in ipairs(tab) do
    tempTbl[k] = v
  end
  for k, v in ipairs(seq) do
    tab[k] = tempTbl[v]
  end
end
function MathHelper.CountTable(tbl)
  local count = 0
  for k, v in pairs(tbl) do
    count = count + 1
  end
  return count
end
function MathHelper.BitAnd(a, b)
  if b < a then
    a, b = b, a
  end
  local result = 0
  local shift = 1
  while a ~= 0 do
    local aRight = a % 2
    local bRight = b % 2
    local onebit = aRight == 1 and bRight == 1 and 1 or 0
    result = result + onebit * shift
    shift = shift * 2
    a = math.modf(a / 2)
    b = math.modf(b / 2)
  end
  return result
end
function MathHelper.BitOr(a, b)
  if a < b then
    a, b = b, a
  end
  local result = 0
  local shift = 1
  while num1 ~= 0 do
    local aRight = a % 2
    local bRight = b % 2
    local onebit = (aRight == 1 or bRight == 1) and 1 or 0
    result = result + onebit * shift
    shift = shift * 2
    a = math.modf(a / 2)
    b = math.modf(b / 2)
  end
  return result
end
function MathHelper.Div(a, b)
  if a == b and a == 0 then
    return 1
  end
  return a / b
end
function MathHelper.ComputeTipsAutoPositionX(sourceX, sourceY, sourceW, sourceH, targetW, targetH, prefer, preferY)
  local GUIMan = require("GUI.ECGUIMan")
  local screenHeight = GUIMan.Instance().m_uiRootCom:get_activeHeight()
  local screenWidth = screenHeight / Screen.height * Screen.width
  local targetX = sourceX
  local targetY = sourceY
  prefer = prefer or 0
  if prefer > 0 then
    targetX = sourceX + sourceW / 2 + targetW / 2
    if targetX + targetW / 2 > screenWidth / 2 then
      local diffX = targetX + targetW / 2 - screenWidth / 2
      targetX = targetX - diffX
    end
  elseif prefer < 0 then
    targetX = sourceX - sourceW / 2 - targetW / 2
    if targetX - targetW / 2 < -1 * screenWidth / 2 then
      local diffX = 0 - screenWidth / 2 - (targetX - targetW / 2)
      targetX = targetX + diffX
    end
  elseif sourceX >= 0 then
    targetX = sourceX - sourceW / 2 - targetW / 2
    if targetX - targetW / 2 < -1 * screenWidth / 2 then
      local diffX = 0 - screenWidth / 2 - (targetX - targetW / 2)
      targetX = targetX + diffX
    end
  else
    targetX = sourceX + sourceW / 2 + targetW / 2
    if targetX + targetW / 2 > screenWidth / 2 then
      local diffX = targetX + targetW / 2 - screenWidth / 2
      targetX = targetX - diffX
    end
  end
  if preferY then
    if preferY == 0 then
      if sourceY >= 0 then
        targetY = sourceY - (targetH / 2 - sourceH / 2)
      else
        targetY = sourceY + (targetH / 2 - sourceH / 2)
      end
    elseif preferY > 0 then
      targetY = sourceY - (targetH / 2 - sourceH / 2)
    else
      targetY = sourceY + (targetH / 2 - sourceH / 2)
    end
  end
  if targetY + targetH / 2 > screenHeight / 2 then
    local diffY = targetY + targetH / 2 - screenHeight / 2
    targetY = targetY - diffY
  elseif targetY - targetH / 2 < 0 - screenHeight / 2 then
    local diffY = 0 - screenHeight / 2 - (targetY - targetH / 2)
    targetY = targetY + diffY
  end
  return targetX, targetY
end
function MathHelper.ComputeTipsAutoPositionY(sourceX, sourceY, sourceW, sourceH, targetW, targetH, prefer, preferX)
  local GUIMan = require("GUI.ECGUIMan")
  local screenHeight = GUIMan.Instance().m_uiRootCom:get_activeHeight()
  local screenWidth = screenHeight / Screen.height * Screen.width
  local targetX = sourceX
  local targetY = sourceY
  prefer = prefer or 0
  if prefer > 0 then
    targetY = sourceY + sourceH / 2 + targetH / 2
    if targetY + targetH / 2 > screenHeight / 2 then
      local diffY = targetY + targetH / 2 - screenHeight / 2
      targetY = targetY - diffY
    end
  elseif prefer < 0 then
    targetY = sourceY - sourceH / 2 - targetH / 2
    if targetY - targetH / 2 < -1 * screenHeight / 2 then
      local diffY = 0 - screenHeight / 2 - (targetY - targetH / 2)
      targetY = targetY + diffY
    end
  elseif sourceY >= 0 then
    targetY = sourceY - sourceH / 2 - targetH / 2
    if targetY - targetH / 2 < -1 * screenHeight / 2 then
      local diffY = 0 - screenHeight / 2 - (targetY - targetH / 2)
      targetY = targetY + diffY
    end
  else
    targetY = sourceY + sourceH / 2 + targetH / 2
    if targetY + targetH / 2 > screenHeight / 2 then
      local diffY = targetY + targetH / 2 - screenHeight / 2
      targetY = targetY - diffY
    end
  end
  if preferX then
    if preferX == 0 then
      if sourceX >= 0 then
        targetX = sourceX - (targetW / 2 - sourceW / 2)
      else
        targetX = sourceX + (targetW / 2 - sourceW / 2)
      end
    elseif preferX > 0 then
      targetX = sourceX - (targetW / 2 - sourceW / 2)
    else
      targetX = sourceX + (targetW / 2 - sourceW / 2)
    end
  end
  if targetX + targetW / 2 > screenWidth / 2 then
    local diffX = targetX + targetW / 2 - screenWidth / 2
    targetX = targetX - diffX
  elseif targetX - targetW / 2 < 0 - screenWidth / 2 then
    local diffX = 0 - screenWidth / 2 - (targetX - targetW / 2)
    targetX = targetX + diffX
  end
  return targetX, targetY
end
function MathHelper.ComputeTipsAutoPosition(sourceX, sourceY, sourceW, sourceH, targetW, targetH, prefer, preferY)
  preferY = preferY or 0
  return MathHelper.ComputeTipsAutoPositionX(sourceX, sourceY, sourceW, sourceH, targetW, targetH, prefer, preferY)
end
function MathHelper.Arabic2Chinese(number)
  if number > 0 and number <= 10 then
    return textRes.ChineseNumber[number]
  end
  if number > 10 and number < 20 then
    return textRes.ChineseNumber[10] .. textRes.ChineseNumber[number - 10]
  end
  if number >= 20 and number < 100 then
    return textRes.ChineseNumber[math.floor(number / 10)] .. textRes.ChineseNumber[10] .. textRes.ChineseNumber[number % 10]
  end
  return ""
end
function MathHelper.CalcAng(x1, y1, x2, y2)
  return math.atan(y2 - y1, x2 - x1)
end
function MathHelper.Distance(x1, y1, x2, y2)
  local xdiff = x1 - x2
  local ydiff = y1 - y2
  return math.sqrt(xdiff * xdiff + ydiff * ydiff)
end
function MathHelper.CalcCoordByTwoPointAndDistance1(startX, startY, endX, endY, dis)
  if startX == endX and startY == endY then
    return startX, startY
  end
  local diffX, diffY = endX - startX, endY - startY
  local start2end = math.sqrt(diffX * diffX + diffY * diffY)
  if dis >= start2end then
    return endX, endY
  end
  local proportion = dis / start2end
  local x = proportion * diffX + startX
  local y = proportion * diffY + startY
  return x, y
end
function MathHelper.CalcCoordByTwoPointAndDistance2(startX, startY, endX, endY, dis)
  if startX == endX and startY == endY then
    return startX, startY
  end
  local diffX, diffY = endX - startX, endY - startY
  local start2end = math.sqrt(diffX * diffX + diffY * diffY)
  if dis >= start2end then
    return startX, startY
  end
  local proportion = (start2end - dis) / start2end
  local x = proportion * diffX + startX
  local y = proportion * diffY + startY
  return x, y
end
function MathHelper.Clamp(val, minVal, maxVal)
  if maxVal < minVal then
    return val
  end
  if maxVal < val then
    val = maxVal
  elseif minVal > val then
    val = minVal
  end
  return val
end
function MathHelper.Lerp(a, b, v)
  return a + (b - a) * v
end
function MathHelper.lower_bound(t, val, comp, firstIndex, lastIndex)
  firstIndex = firstIndex or 1
  lastIndex = lastIndex or #t + 1
  local defaultcmp = function(left, right)
    return left < right
  end
  comp = comp or defaultcmp
  local count = lastIndex - firstIndex
  local midIndex = lastIndex
  while count > 0 do
    midIndex = firstIndex
    local step = math.floor(count / 2)
    midIndex = firstIndex + step
    if comp(t[midIndex], val) then
      midIndex = midIndex + 1
      firstIndex = midIndex
      count = count - (step + 1)
    else
      count = step
    end
  end
  return midIndex
end
function MathHelper.upper_bound(t, val, comp, firstIndex, lastIndex)
  firstIndex = firstIndex or 1
  lastIndex = lastIndex or #t + 1
  local defaultcmp = function(left, right)
    return left < right
  end
  comp = comp or defaultcmp
  local count = lastIndex - firstIndex
  local midIndex = lastIndex
  while count > 0 do
    midIndex = firstIndex
    local step = math.floor(count / 2)
    midIndex = firstIndex + step
    if not comp(val, t[midIndex]) then
      midIndex = midIndex + 1
      firstIndex = midIndex
      count = count - (step + 1)
    else
      count = step
    end
  end
  return midIndex
end
function MathHelper.CheckInViewQuick(srcX, srcY, dstX, dstY, dis, angle, dirX, dirY)
  local x = dstX - srcX
  local y = dstY - srcY
  if x * x + y * y < dis * dis then
    local len = math.sqrt(x * x + y * y)
    x = x / len
    y = y / len
    local deg = math.deg(math.acos(x * dirX + y * dirY))
    if deg < angle / 2 then
      return true
    else
      return false
    end
  else
    return false
  end
end
function MathHelper.CheckInView(srcX, srcY, dstX, dstY, dis, angle, dir)
  local x = dstX - srcX
  local y = dstY - srcY
  if x * x + y * y < dis * dis then
    local len = math.sqrt(x * x + y * y)
    x = x / len
    y = y / len
    dir = math.rad((dir + 90) % 360)
    local dirX = math.cos(dir)
    local dirY = math.sin(dir)
    local deg = math.deg(math.acos(x * dirX + y * dirY))
    if deg < angle / 2 then
      return true
    else
      return false
    end
  else
    return false
  end
end
return MathHelper
