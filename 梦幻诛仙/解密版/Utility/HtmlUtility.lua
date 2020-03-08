local Lplus = require("Lplus")
local lpeg = require("lpeg")
local tonumber = tonumber
local stringchar = string.char
local select = select
local byte_sharp = ("#"):byte()
local byte_x = ("x"):byte()
local byte_X = ("X"):byte()
local entityMap = {
  amp = "&",
  lt = "<",
  gt = ">",
  quot = "\"",
  nbsp = " "
}
local function unescapeNumberic(escapeInnerText)
  local secondByte = escapeInnerText:byte(2)
  local byte_value = 0
  if secondByte == byte_x or secondByte == byte_X then
    byte_value = tonumber(escapeInnerText:sub(3), 16)
  else
    byte_value = tonumber(escapeInnerText:sub(2))
  end
  if byte_value ~= 0 then
    return stringchar(byte_value)
  else
    return ""
  end
end
local function unescapeRep(escapeInnerText)
  if escapeInnerText:byte(1) == byte_sharp then
    return unescapeNumberic(escapeInnerText)
  else
    return entityMap[escapeInnerText] or ""
  end
end
local HtmlUtility = Lplus.Class()
do
  local def = HtmlUtility.define
  local fontStack = {}
  local function resetState()
    fontStack = {}
  end
  local function clearState()
    fontStack = nil
  end
  local htmlConvPatt
  do
    local elementOpenMap = {
      b = "[b]",
      i = "[i]",
      u = "[u]",
      s = "[s]",
      strike = "[s]",
      br = "\n"
    }
    local function replaceElementOpen(tag, ...)
      if tag == "font" then
        local color
        for i = 1, select("#", ...), 2 do
          local attr_name, attr_value = select(i, ...), select(i + 1, ...)
          if attr_name == "color" then
            if attr_value:byte() == byte_sharp then
              color = attr_value:sub(2)
              break
            end
            color = attr_value
            break
          end
        end
        if color then
          fontStack[#fontStack + 1] = true
          return "[" .. color .. "]"
        else
          fontStack[#fontStack + 1] = false
          return ""
        end
      end
      return elementOpenMap[tag] or ""
    end
    local elementCloseMap = {
      b = "[/b]",
      i = "[/i]",
      u = "[/u]",
      s = "[/s]",
      strike = "[/s]"
    }
    local function replaceElementClose(tag)
      if tag == "font" then
        local hasColor = fontStack[#fontStack]
        fontStack[#fontStack] = nil
        if hasColor then
          return "[-]"
        else
          return ""
        end
      end
      return elementCloseMap[tag] or ""
    end
    local escapeChar = lpeg.P("&") / "" * ((1 - lpeg.S(";")) ^ 0 / unescapeRep) * (lpeg.P(";") ^ -1 / "")
    local plainChar = escapeChar + lpeg.P(1)
    local space = lpeg.S(" \t\n\r") ^ 1
    local optSpace = lpeg.S(" \t\n\r") ^ 0
    local alpha = lpeg.R("az") + lpeg.R("AZ") + lpeg.S("_")
    local digit = lpeg.R("09")
    local alphadigit = alpha + digit
    local name = alpha * alphadigit ^ 0
    local attributeSingleQuotedValue = (plainChar - lpeg.P("'")) ^ 0
    local attributeDoubleQuotedValue = (plainChar - lpeg.P("\"")) ^ 0
    local attributeNonQuotedValue = (plainChar - space - lpeg.S("'\"<>=`")) ^ 1
    local attributeValue = lpeg.P("'") * lpeg.C(attributeSingleQuotedValue) * lpeg.P("'") + lpeg.P("\"") * lpeg.C(attributeDoubleQuotedValue) * lpeg.P("\"") + lpeg.C(attributeNonQuotedValue)
    local attribute = lpeg.C(name) * optSpace * "=" * optSpace * attributeValue
    local elementOpenContent = lpeg.P("<") * lpeg.C(name) * (space * attribute) ^ 0 * optSpace * (lpeg.P("/>") + lpeg.P(">"))
    local elementOpenPatt = elementOpenContent / replaceElementOpen
    local elementCloseContent = lpeg.P("</") * lpeg.C(name) * optSpace * lpeg.P(">")
    local elementClosePatt = elementCloseContent / replaceElementClose
    local htmlContent = (elementClosePatt + elementOpenPatt + plainChar) ^ 0
    htmlConvPatt = lpeg.Cs(htmlContent) * -1
  end
  def.static("string", "=>", "string").HtmlToNguiText = function(htmlText)
    resetState()
    local result = htmlConvPatt:match(htmlText) or "html parse error"
    clearState()
    return result
  end
end
return HtmlUtility.Commit()
