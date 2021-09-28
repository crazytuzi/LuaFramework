-- Provides UTF-8 aware string functions implemented in pure lua:
-- * string.utf8len(s)
-- * string.utf8sub(s, i, j)
--
-- All functions behave as their non UTF-8 aware counterparts with the exception
-- that UTF-8 characters are used instead of bytes for all units.
--
-- Note: all validations had been removed due to awesome usage specifics.
--[[
Copyright (c) 2006-2007, Kyle Smith
All rights reserved.
 
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
 
* Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of the author nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
 
-- ABNF from RFC 3629
--
-- UTF8-octets = *( UTF8-char )
-- UTF8-char = UTF8-1 / UTF8-2 / UTF8-3 / UTF8-4
-- UTF8-1 = %x00-7F
-- UTF8-2 = %xC2-DF UTF8-tail
-- UTF8-3 = %xE0 %xA0-BF UTF8-tail / %xE1-EC 2( UTF8-tail ) /
-- %xED %x80-9F UTF8-tail / %xEE-EF 2( UTF8-tail )
-- UTF8-4 = %xF0 %x90-BF 2( UTF8-tail ) / %xF1-F3 3( UTF8-tail ) /
-- %xF4 %x80-8F 2( UTF8-tail )
-- UTF8-tail = %x80-BF
--
 
-- returns the number of bytes used by the UTF-8 character at byte i in s
-- also doubles as a UTF-8 character validator

local UTF8 = {}


function UTF8.utf8charbytes (s, i)
    -- argument defaults
    i = i or 1
    local c = string.byte(s, i)
 
    -- determine bytes needed for character, based on RFC 3629
    if c > 0 and c <= 127 then
        -- UTF8-1
        return 1
    elseif c >= 194 and c <= 223 then
        -- UTF8-2
        local c2 = string.byte(s, i + 1)
        return 2
    elseif c >= 224 and c <= 239 then
        -- UTF8-3
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)
        return 3
    elseif c >= 240 and c <= 244 then
        -- UTF8-4
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)
        local c4 = s:byte(i + 3)
        return 4
    end
end
 
-- returns the number of characters in a UTF-8 string
function UTF8.utf8len (s)
    local pos = 1
    local bytes = string.len(s)
    local len = 0
 
    while pos <= bytes and len ~= chars do
        local c = string.byte(s,pos)
        len = len + 1
 
        pos = pos + UTF8.utf8charbytes(s, pos)
    end
 
    if chars ~= nil then
        return pos - 1
    end
 
    return len
end
 
-- functions identically to string.sub except that i and j are UTF-8 characters
-- instead of bytes
function UTF8.utf8sub (s, i, j)
    j = j or -1
 
    if i == nil then
        return ""
    end
 
    local pos = 1
    local bytes = string.len(s)
    local len = 0
 
    -- only set l if i or j is negative
    local l = (i >= 0 and j >= 0) or UTF8.utf8len(s)
    local startChar = (i >= 0) and i or l + i + 1
    local endChar = (j >= 0) and j or l + j + 1
 
    -- can't have start before end!
    if startChar > endChar then
        return ""
    end
 
    -- byte offsets to pass to string.sub
    local startByte, endByte = 1, bytes
 
    while pos <= bytes do
        len = len + 1
 
        if len == startChar then
            startByte = pos
        end
 
        pos = pos + UTF8.utf8charbytes(s, pos)
 
        if len == endChar then
            endByte = pos - 1
            break
        end
    end
 
    return string.sub(s, startByte, endByte)
end
 
-- replace UTF-8 characters based on a mapping table
function UTF8.utf8replace (s, mapping)
    local pos = 1
    local bytes = string.len(s)
    local charbytes
    local newstr = ""
 
    while pos <= bytes do
        charbytes = UTF8.utf8charbytes(s, pos)
        local c = string.sub(s, pos, pos + charbytes - 1)
        newstr = newstr .. (mapping[c] or c)
        pos = pos + charbytes
    end
 
    return newstr
end

return UTF8