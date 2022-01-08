--url编码字符串
function url_encode(str)
  	if (str) then
  	  	str = string.gsub (str, "\n", "\r\n")
  	  	str = string.gsub (str, "([^%w ])",
  	  	    function (c) return string.format ("%%%02X", string.byte(c)) end)
  	  	      	str = string.gsub (str, " ", "+")
  	  	    end
  	return str    
end

-- install in the string library
if not string.url_encode then
  string.url_encode = url_encode
end

--解码url编码的字符串
function url_decode(str)
  	str = string.gsub (str, "+", " ")
  	str = string.gsub (str, "%%(%x%x)",
  	    function(h) return string.char(tonumber(h,16)) end)
  	str = string.gsub (str, "\r\n", "\n")
  	return str
end

-- install in the string library
if not string.url_decode then
  string.url_decode = url_decode
end