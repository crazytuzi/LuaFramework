-- $Id: html.lua,v 1.2 2007-05-12 04:37:20 tclua Exp $

module(..., package.seeall)

entity = {
  nbsp = " ",
  lt = "<",
  gt = ">",
  quot = "\"",
  amp = "&",
}

-- keep unknown entity as is
setmetatable(entity, {
  __index = function (t, key)
    return "&" .. key .. ";"
  end
})

block = {
  "address",
  "blockquote",
  "center",
  "dir", "div", "dl",
  "fieldset", "form",
  "h1", "h2", "h3", "h4", "h5", "h6", "hr", 
  "isindex",
  "menu",
  "noframes",
  "ol",
  "p",
  "pre",
  "table",
  "ul",
}

inline = {
  "a", "abbr", "acronym", "applet",
  "b", "basefont", "bdo", "big", "br", "button",
  "cite", "code",
  "dfn",
  "em",
  "font",
  "i", "iframe", "img", "input",
  "kbd",
  "label",
  "map",
  "object",
  "q",
  "s", "samp", "select", "small", "span", "strike", "strong", "sub", "sup",
  "textarea", "tt",
  "u",
  "var",
}

tags = {
  a = { empty = false },
  abbr = {empty = false} ,
  acronym = {empty = false} ,
  address = {empty = false} ,
  applet = {empty = false} ,
  area = {empty = true} ,
  b = {empty = false} ,
  base = {empty = true} ,
  basefont = {empty = true} ,
  bdo = {empty = false} ,
  big = {empty = false} ,
  blockquote = {empty = false} ,
  body = { empty = false, },
  br = {empty = true} ,
  button = {empty = false} ,
  caption = {empty = false} ,
  center = {empty = false} ,
  cite = {empty = false} ,
  code = {empty = false} ,
  col = {empty = true} ,
  colgroup = {
    empty = false,
    optional_end = true,
    child = {"col",},
  },
  dd = {empty = false} ,
  del = {empty = false} ,
  dfn = {empty = false} ,
  dir = {empty = false} ,
  div = {empty = false} ,
  dl = {empty = false} ,
  dt = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      "del",
      "ins",
      "noscript",
      "script",
    },
  },
  em = {empty = false} ,
  fieldset = {empty = false} ,
  font = {empty = false} ,
  form = {empty = false} ,
  frame = {empty = true} ,
  frameset = {empty = false} ,
  h1 = {empty = false} ,
  h2 = {empty = false} ,
  h3 = {empty = false} ,
  h4 = {empty = false} ,
  h5 = {empty = false} ,
  h6 = {empty = false} ,
  head = {empty = false} ,
  hr = {empty = true} ,
  html = {empty = false} ,
  i = {empty = false} ,
  iframe = {empty = false} ,
  img = {empty = true} ,
  input = {empty = true} ,
  ins = {empty = false} ,
  isindex = {empty = true} ,
  kbd = {empty = false} ,
  label = {empty = false} ,
  legend = {empty = false} ,
  li = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      block,
      "del",
      "ins",
      "noscript",
      "script",
    },
  },
  link = {empty = true} ,
  map = {empty = false} ,
  menu = {empty = false} ,
  meta = {empty = true} ,
  noframes = {empty = false} ,
  noscript = {empty = false} ,
  object = {empty = false} ,
  ol = {empty = false} ,
  optgroup = {empty = false} ,
  option = {
    empty = false,
    optional_end = true,
    child = {},
  },
  p = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      "del",
      "ins",
      "noscript",
      "script",
    },
  } ,
  param = {empty = true} ,
  pre = {empty = false} ,
  q = {empty = false} ,
  s =  {empty = false} ,
  samp = {empty = false} ,
  script = {empty = false} ,
  select = {empty = false} ,
  small = {empty = false} ,
  span = {empty = false} ,
  strike = {empty = false} ,
  strong = {empty = false} ,
  style = {empty = false} ,
  sub = {empty = false} ,
  sup = {empty = false} ,
  table = {empty = false} ,
  tbody = {empty = false} ,
  td = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      block,
      "del",
      "ins",
      "noscript",
      "script",
    },
  },
  textarea = {empty = false} ,
  tfoot = {
    empty = false,
    optional_end = true,
    child = {"tr",},
  },
  th = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      block,
      "del",
      "ins",
      "noscript",
      "script",
    },
  },
  thead = {
    empty = false,
    optional_end = true,
    child = {"tr",},
  },
  title = {empty = false} ,
  tr = {
    empty = false,
    optional_end = true,
    child = {
      "td", "th",
    },
  },
  tt = {empty = false} ,
  u = {empty = false} ,
  ul = {empty = false} ,
  var = {empty = false} ,
}

setmetatable(tags, {
  __index = function (t, key)
    return {empty = false}
  end
})

-- string buffer implementation
function newbuf ()
  local buf = {
    _buf = {},
    clear =   function (self) self._buf = {}; return self end,
    content = function (self) return table.concat(self._buf) end,
    append =  function (self, s)
      self._buf[#(self._buf) + 1] = s
      return self
    end,
    set =     function (self, s) self._buf = {s}; return self end,
  }
  return buf
end

-- unescape character entities
function unescape (s)
  function entity2string (e)
    return entity[e]
  end
  return s.gsub(s, "&(#?%w+);", entity2string)
end

-- iterator factory
function makeiter (f)
  local co = coroutine.create(f)
  return function ()
    local code, res = coroutine.resume(co)
    return res
  end
end

-- constructors for token
function Tag (s) 
  return string.find(s, "^</") and
    {type = "End",   value = s} or
    {type = "Start", value = s}
end

function Text (s)
  local unescaped = unescape(s) 
  return {type = "Text", value = unescaped} 
end

-- lexer: text mode
function text (f, buf)
  local c = f:read(1)
  if c == "<" then
    if buf:content() ~= "" then coroutine.yield(Text(buf:content())) end
    buf:set(c)
    return tag(f, buf)
  elseif c then
    buf:append(c)
    return text(f, buf)
  else
    if buf:content() ~= "" then coroutine.yield(Text(buf:content())) end
  end
end

-- lexer: tag mode
function tag (f, buf)
  local c = f:read(1)
  if c == ">" then
    coroutine.yield(Tag(buf:append(c):content()))
    buf:clear()
    return text(f, buf)
  elseif c then
    buf:append(c)
    return tag(f, buf)
  else
    if buf:content() ~= "" then coroutine.yield(Tag(buf:content())) end
  end
end

function parse_starttag(tag)
  local tagname = string.match(tag, "<%s*(%w+)")
  local elem = {_attr = {}}
  elem._tag = tagname
  for key, _, val in string.gmatch(tag, "(%w+)%s*=%s*([\"'])(.-)%2", i) do
    local unescaped = unescape(val)
    elem._attr[key] = unescaped
  end
  return elem
end

function parse_endtag(tag)
  local tagname = string.match(tag, "<%s*/%s*(%w+)")
  return tagname
end

-- find last element that satisfies given predicate
function rfind(t, pred)
  local length = #t
  for i=length,1,-1 do
    if pred(t[i]) then
      return i, t[i]
    end
  end
end

function flatten(t, acc)
  acc = acc or {}
  for i,v in ipairs(t) do
    if type(v) == "table" then
      flatten(v, acc)
    else
      acc[#acc + 1] = v
    end
  end
  return acc
end

function optional_end_p(elem)
  if tags[elem._tag].optional_end then
    return true
  else
    return false
  end
end

function valid_child_p(child, parent)
  local schema = tags[parent._tag].child
  if not schema then return true end

  for i,v in ipairs(flatten(schema)) do
    if v == child._tag then
      return true
    end
  end

  return false
end

-- tree builder
function parse(f)
  local root = {_tag = "#document", _attr = {}}
  local stack = {root}
  for i in makeiter(function () return text(f, newbuf()) end) do
    if i.type == "Start" then
      local new = parse_starttag(i.value)
      local top = stack[#stack]

      while
        top._tag ~= "#document" and 
        optional_end_p(top) and
        not valid_child_p(new, top)
      do
        stack[#stack] = nil 
        top = stack[#stack]
      end

      top[#top+1] = new -- appendchild
      if not tags[new._tag].empty then 
        stack[#stack+1] = new -- push
      end
    elseif i.type == "End" then
      local tag = parse_endtag(i.value)
      local openingpos = rfind(stack, function(v) 
          if v._tag == tag then
            return true
          else
            return false
          end
        end)
      if openingpos then
        local length = #stack
        for j=length,openingpos,-1 do
          table.remove(stack, j)
        end
      end
    else -- Text
      local top = stack[#stack]
      top[#top+1] = i.value
    end
  end
  return root
end

function parsestr(s)
  local handle = {
    _content = s,
    _pos = 1,
    read = function (self, length)
      if self._pos > string.len(self._content) then return end
      local ret = string.sub(self._content, self._pos, self._pos + length - 1)
      self._pos = self._pos + length
      return ret
    end
  }
  return parse(handle)
end