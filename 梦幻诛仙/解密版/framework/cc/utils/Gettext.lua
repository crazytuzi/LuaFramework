local Gettext = {}
function Gettext._getFileData(mo_file)
  local mo_data = CCFileUtils:sharedFileUtils():getFileData(mo_file)
  return mo_data
end
function Gettext.loadMOFromFile(mo_file)
  return Gettext.parseData(Gettext._getFileData(mo_file))
end
function Gettext.gettextFromFile(mo_file)
  return Gettext.gettext(Gettext._getFileData(mo_file))
end
function Gettext.gettext(mo_data)
  local __hash = Gettext.parseData(mo_data)
  return function(text)
    return __hash[text] or text
  end
end
function Gettext.parseData(mo_data)
  local byte = string.byte
  local sub = string.sub
  local peek_long
  local magic = sub(mo_data, 1, 4)
  if magic == "\222\018\004\149" then
    function peek_long(offs)
      local a, b, c, d = byte(mo_data, offs + 1, offs + 4)
      return ((d * 256 + c) * 256 + b) * 256 + a
    end
  elseif magic == "\149\004\018\222" then
    function peek_long(offs)
      local a, b, c, d = byte(mo_data, offs + 1, offs + 4)
      return ((a * 256 + b) * 256 + c) * 256 + d
    end
  else
    return nil, "no valid mo-file"
  end
  local V = peek_long(4)
  if V ~= 0 then
    return nul, "unsupported version"
  end
  local N, O, T = peek_long(8), peek_long(12), peek_long(16)
  local hash = {}
  for nstr = 1, N do
    local ol, oo = peek_long(O), peek_long(O + 4)
    O = O + 8
    local tl, to = peek_long(T), peek_long(T + 4)
    T = T + 8
    hash[sub(mo_data, oo + 1, oo + ol)] = sub(mo_data, to + 1, to + tl)
  end
  return hash
end
return Gettext
