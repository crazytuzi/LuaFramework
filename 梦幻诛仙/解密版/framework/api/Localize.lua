local Localize = {}
PRINT_DEPRECATED("module api.Localize is deprecated, please use new cc.utils.Localize")
Localize.strings = {}
function Localize.loadStrings(strings)
  Localize.strings = strings
end
function Localize.query(key, default)
  default = default or key
  local lang = device.language
  if not Localize.strings[lang] or not Localize.strings[lang][key] then
    return default
  end
  return Localize.strings[lang][key]
end
function Localize.filename(filenameOrigin)
  local fi = io.pathinfo(filenameOrigin)
  return fi.dirname .. fi.basename .. "_" .. device.language .. fi.extname
end
return Localize
