local fontConfig = {}
local lfs = require("lfs")
local fontDirPath = device.writablePath .. "xft/"
lfs.mkdir(fontDirPath)
function getAllFontConfig()
  local key = "tfx.tfx."
  local fontNameList = {
    "Arial-BoldMT",
    "Arial"
  }
  local charNum = 40
  local charFontNum = 20
  for _, fontName in pairs(fontNameList) do
    local fileName = "Font" .. fontName
    if fontConfig[fileName] == nil then
      local encodeFileName = crypto.encodeBase64(crypto.encryptXXTEA(fileName, key))
      encodeFileName, _ = string.gsub(encodeFileName, "/", "_")
      encodeFileName, _ = string.gsub(encodeFileName, "\\", "_")
      local fileNameStr = string.format("%s.xft", encodeFileName)
      local encodeFilePath = fontDirPath .. fileNameStr
      local encodeData = io.readfile(encodeFilePath)
      if encodeData then
        local cryptoD = crypto.decodeBase64(encodeData)
        local lenDictStr = crypto.decryptXXTEA(cryptoD, key)
        local lenDict = json.decode(lenDictStr)
        fontConfig[fileName] = lenDict
      else
        local textStr = ""
        for i = 1, charNum do
          textStr = textStr .. "国"
        end
        local tempObj = CCLabelTTF:create(textStr, fontName, charFontNum, CCSize(0, 0), ui.TEXT_ALIGN_LEFT, ui.TEXT_VALIGN_CENTER)
        local size = tempObj:getContentSize()
        local chineseTotalLen = size.width
        local lenDict = {}
        for i = 32, 126 do
          local char = string.char(i)
          lenDict[i] = getFontOneCharLen(char, charNum, fontName, charFontNum, chineseTotalLen)
        end
        local newEncodeData = crypto.encodeBase64(crypto.encryptXXTEA(json.encode(lenDict), key))
        io.writefile(encodeFilePath, newEncodeData)
        fontConfig[fileName] = lenDict
      end
    end
  end
end
function getFontOneCharLen(char, charNum, charFontName, charFontNum, chineseTotalLen)
  local textStr = ""
  for i = 1, charNum do
    textStr = textStr .. char
  end
  local tempObj = CCLabelTTF:create(textStr, charFontName, charFontNum, CCSize(0, 0), ui.TEXT_ALIGN_LEFT, ui.TEXT_VALIGN_CENTER)
  local size = tempObj:getContentSize()
  local charTotalLen = size.width
  return charTotalLen / chineseTotalLen * 2
end
function getFontConfig(fontName)
  return fontConfig["Font" .. fontName] or {}
end
getAllFontConfig()
